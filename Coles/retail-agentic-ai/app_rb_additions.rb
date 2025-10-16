#!/usr/bin/env ruby
# Version: 3.0.0
# Add these routes to your app.rb file

# Route to display the add agent question wizard
get '/add_agent_question' do
  erb :add_agent_question
end

# API endpoint to save the new scenario configuration
post '/api/save-scenario' do
  content_type :json
  
  begin
    request.body.rewind
    data = JSON.parse(request.body.read)
    
    scenario_slug = data['scenario_name'].downcase.gsub(/[^a-z0-9]+/, '-')
    files_created = []
    
    # 1. Update system prompt
    prompt_file = File.expand_path('../../prompts/produce-optimization-agent.txt', __FILE__)
    current_prompt = File.read(prompt_file)
    
    new_section = "\n\n" + "="*70 + "\n"
    new_section += "ADDITIONAL CAPABILITY: #{data['scenario_name'].upcase}\n"
    new_section += "="*70 + "\n\n"
    new_section += data['system_prompt']
    
    File.write(prompt_file, current_prompt + new_section)
    files_created << "prompts/produce-optimization-agent.txt (updated)"
    
    # 2. Create/update policy text file
    policy_text_file = File.expand_path("../../policies/#{scenario_slug}-policy.txt", __FILE__)
    File.write(policy_text_file, data['policy_text'])
    files_created << "policies/#{scenario_slug}-policy.txt"
    
    # 3. Create/update policy JSON file
    policy_json_file = File.expand_path("../../policies/#{scenario_slug}-policy.json", __FILE__)
    
    # Parse and validate JSON
    policy_data = JSON.parse(data['policy_json'])
    File.write(policy_json_file, JSON.pretty_generate(policy_data))
    files_created << "policies/#{scenario_slug}-policy.json"
    
    # 4. Create example file
    example_file = File.expand_path("../../examples/#{data['example_name']}.txt", __FILE__)
    File.write(example_file, data['example_dialog'])
    files_created << "examples/#{data['example_name']}.txt"
    
    # 5. Update app.rb with new tool implementations
    # Create a new file with tool code that can be required
    tools_file = File.expand_path("../tools/#{scenario_slug}_tools.rb", __FILE__)
    FileUtils.mkdir_p(File.dirname(tools_file))
    
    tools_code = "# #{data['scenario_name']} Tools\n"
    tools_code += "# Auto-generated on #{Time.now}\n\n"
    tools_code += data['tool_implementation']
    
    File.write(tools_file, tools_code)
    files_created << "app/tools/#{scenario_slug}_tools.rb"
    
    # 6. Create tools configuration file
    tools_config_file = File.expand_path("../config/tools/#{scenario_slug}.json", __FILE__)
    FileUtils.mkdir_p(File.dirname(tools_config_file))
    
    tools_config = JSON.parse(data['tool_definitions'])
    File.write(tools_config_file, JSON.pretty_generate(tools_config))
    files_created << "app/config/tools/#{scenario_slug}.json"
    
    # 7. Update index.erb with new quick action button
    index_file = File.expand_path('../views/index.erb', __FILE__)
    index_content = File.read(index_file)
    
    # Find the action-grid section and add new button before the closing </div>
    new_button = <<~BUTTON
      <button class="action-card" onclick="askQuestion('#{data['button_question'].gsub("'", "\\'")}')">
        <span class="action-icon">#{data['button_icon']}</span>
        <span class="action-label">#{data['button_label']}</span>
      </button>
    BUTTON
    
    # Insert before </div> that closes action-grid
    index_content = index_content.sub(
      %r{(</div>\s*</div>\s*<script)},
      "    #{new_button.strip}\n    \\1"
    )
    
    File.write(index_file, index_content)
    files_created << "app/views/index.erb (updated)"
    
    # 8. Create a scenario manifest file for documentation
    manifest = {
      scenario_name: data['scenario_name'],
      scenario_slug: scenario_slug,
      created_at: Time.now.iso8601,
      description: data['scenario_description'],
      sample_questions: data['sample_questions'].split("\n"),
      files: {
        system_prompt: "prompts/produce-optimization-agent.txt",
        policy_text: "policies/#{scenario_slug}-policy.txt",
        policy_json: "policies/#{scenario_slug}-policy.json",
        example: "examples/#{data['example_name']}.txt",
        tools_implementation: "app/tools/#{scenario_slug}_tools.rb",
        tools_config: "app/config/tools/#{scenario_slug}.json"
      },
      quick_action: {
        icon: data['button_icon'],
        label: data['button_label'],
        question: data['button_question']
      }
    }
    
    manifest_file = File.expand_path("../../scenarios/#{scenario_slug}.json", __FILE__)
    FileUtils.mkdir_p(File.dirname(manifest_file))
    File.write(manifest_file, JSON.pretty_generate(manifest))
    files_created << "scenarios/#{scenario_slug}.json"
    
    json({
      success: true,
      message: "Scenario '#{data['scenario_name']}' saved successfully",
      files_created: files_created,
      scenario_slug: scenario_slug
    })
    
  rescue JSON::ParserError => e
    json({
      success: false,
      error: "Invalid JSON: #{e.message}"
    })
  rescue => e
    json({
      success: false,
      error: e.message
    })
  end
end

# Helper method to load tool configurations dynamically
def load_tool_configs
  tools = []
  config_dir = File.expand_path('../config/tools', __FILE__)
  
  if Dir.exist?(config_dir)
    Dir.glob(File.join(config_dir, '*.json')).each do |config_file|
      begin
        tool_config = JSON.parse(File.read(config_file))
        tools.concat(tool_config) if tool_config.is_a?(Array)
      rescue => e
        puts "Warning: Could not load tool config #{config_file}: #{e.message}"
      end
    end
  end
  
  tools
end

# Helper method to execute tools dynamically
def execute_dynamic_tool(tool_name, parameters)
  # Load tool implementations from the tools directory
  tools_dir = File.expand_path('../tools', __FILE__)
  
  if Dir.exist?(tools_dir)
    Dir.glob(File.join(tools_dir, '*_tools.rb')).each do |tool_file|
      begin
        require tool_file
        
        # Try to find a method that matches the tool name
        method_name = tool_name.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '')
        
        if respond_to?(method_name)
          return send(method_name, parameters)
        end
      rescue => e
        puts "Warning: Could not load tool file #{tool_file}: #{e.message}"
      end
    end
  end
  
  # Return error if tool not found
  { error: "Tool #{tool_name} not found or not implemented" }
end

# Update the get_mcp_tools method to include dynamically loaded tools
def get_mcp_tools_with_dynamic
  base_tools = [
    {
      name: 'get_inventory_status',
      description: 'Retrieve current inventory level, expiration dates, and recent movement for a product',
      input_schema: {
        type: 'object',
        properties: {
          product_id: { type: 'string' },
          store_id: { type: 'string' },
          include_supply_schedule: { type: 'boolean' }
        },
        required: ['product_id', 'store_id']
      }
    },
    {
      name: 'query_sales_velocity',
      description: 'Get sales rate for product over specified time period with comparison to baseline',
      input_schema: {
        type: 'object',
        properties: {
          product_id: { type: 'string' },
          store_id: { type: 'string' },
          days_back: { type: 'integer' }
        },
        required: ['product_id', 'store_id', 'days_back']
      }
    },
    {
      name: 'check_pricing_policy',
      description: 'Validate proposed markdown against margin rules',
      input_schema: {
        type: 'object',
        properties: {
          product_id: { type: 'string' },
          current_price: { type: 'number' },
          proposed_price: { type: 'number' },
          reason_code: { type: 'string' }
        },
        required: ['product_id', 'current_price', 'proposed_price', 'reason_code']
      }
    },
    {
      name: 'submit_price_change',
      description: 'Execute approved price change in POS system',
      input_schema: {
        type: 'object',
        properties: {
          product_id: { type: 'string' },
          store_id: { type: 'string' },
          new_price: { type: 'number' },
          approval_token: { type: 'string' }
        },
        required: ['product_id', 'store_id', 'new_price', 'approval_token']
      }
    },
    {
      name: 'get_competitor_pricing',
      description: 'Retrieve current pricing for product category from local competitors',
      input_schema: {
        type: 'object',
        properties: {
          category: { type: 'string' },
          radius_miles: { type: 'number' },
          store_location: { type: 'string' }
        },
        required: ['category', 'store_location']
      }
    }
  ]
  
  # Add dynamically loaded tools
  dynamic_tools = load_tool_configs
  
  base_tools + dynamic_tools
end
