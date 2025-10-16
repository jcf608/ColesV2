#!/usr/bin/env ruby
# Version: 4.0.0 - Refactored with Claude-powered wizard support
# Routes file for Produce Optimization App

module ProduceOptimizationRoutes
  def self.registered(app)
    
    # ============================================
    # PAGE ROUTES - MAIN PAGES
    # ============================================
    
    app.get '/' do
      erb :index
    end
    
    app.get '/home' do
      erb :home, layout: :modern_layout
    end
    
    app.get '/dashboard' do
      @inventory_items = get_sample_inventory
      erb :dashboard
    end
    
    app.get '/decisions' do
      @recent_decisions = get_recent_decisions
      erb :decisions
    end
    
    # ============================================
    # PAGE ROUTES - MODE INTERFACES
    # ============================================
    
    app.get '/ask' do
      erb :ask, layout: :modern_layout
    end
    
    app.get '/act' do
      erb :act, layout: :modern_layout
    end
    
    app.get '/alert' do
      erb :alert, layout: :modern_layout
    end
    
    # ============================================
    # PAGE ROUTES - ADMIN & CONFIGURATION
    # ============================================
    
    app.get '/admin' do
      erb :admin
    end
    
    app.get '/add_agent_question' do
      erb :add_agent_question, layout: false
    end
    
    # ============================================
    # API ROUTES - QUESTION MANAGEMENT
    # ============================================
    
    # List all questions
    app.get '/api/questions' do
      content_type :json
      
      questions_dir = File.expand_path('../../ask_questions', __FILE__)
      questions = []
      
      if Dir.exist?(questions_dir)
        Dir.glob(File.join(questions_dir, '*.json')).each do |file|
          begin
            question = JSON.parse(File.read(file))
            questions << question
          rescue => e
            # Skip malformed files
          end
        end
      end
      
      json({ success: true, questions: questions.sort_by { |q| q['order'] || 999 } })
    end
    
    # Load ask questions for quick actions
    app.get '/api/ask-questions' do
      content_type :json
      questions = load_ask_questions
      json({ success: true, questions: questions })
    end
    
    # Get a specific question with all its assets
    app.get '/api/question/:id' do
      content_type :json
      question_id = params[:id]
      
      base_dir = File.expand_path('../..', __FILE__)
      question_file = File.join(base_dir, 'ask_questions', "#{question_id}.json")
      
      unless File.exist?(question_file)
        status 404
        return json({ success: false, error: 'Question not found' })
      end
      
      begin
        question_data = JSON.parse(File.read(question_file))
        
        # Load all associated assets
        system_prompt_file = File.join(base_dir, 'prompts', 'scenarios', "#{question_id}.txt")
        policy_text_file = File.join(base_dir, 'policies', "#{question_id}.txt")
        policy_json_file = File.join(base_dir, 'policies', "#{question_id}.json")
        example_file = File.join(base_dir, 'examples', "#{question_id}.txt")
        
        # Try to load from new rationalized structure first
        tool_category = CARINARoutes.determine_tool_category(question_data['label'] || question_id)
        new_tool_config_file = File.join(base_dir, 'config', tool_category, "#{question_id}.json")
        new_tool_impl_file = File.join(base_dir, 'tools', tool_category, "#{question_id}.rb")
        
        # Fallback to old structure for backward compatibility
        old_tool_config_file = File.join(base_dir, 'config', 'tools', "#{question_id}_tools.json")
        old_tool_impl_file = File.join(base_dir, 'tools', "#{question_id}_tools.rb")
        
        # Choose which files to use (new structure takes precedence)
        tool_config_file = File.exist?(new_tool_config_file) ? new_tool_config_file : old_tool_config_file
        tool_impl_file = File.exist?(new_tool_impl_file) ? new_tool_impl_file : old_tool_impl_file
        
        full_data = {
          scenario_name: question_data['label'],
          scenario_description: question_data['question'],
          sample_questions: '',
          system_prompt: File.exist?(system_prompt_file) ? File.read(system_prompt_file) : '',
          policy_name: question_data['label'] + ' Policy',
          policy_text: File.exist?(policy_text_file) ? File.read(policy_text_file) : '',
          policy_json: File.exist?(policy_json_file) ? File.read(policy_json_file) : '',
          example_name: question_id,
          example_dialog: File.exist?(example_file) ? File.read(example_file) : '',
          tool_definitions: load_tool_definitions(tool_config_file),
          tool_implementation: File.exist?(tool_impl_file) ? File.read(tool_impl_file) : '',
          button_icon: question_data['icon'],
          button_label: question_data['label'],
          button_question: question_data['question']
        }
        
        json({ success: true, question: full_data })
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # ============================================
    # API ROUTES - CLAUDE-POWERED GENERATION
    # ============================================
    
    # Generate question details with Claude
    app.post '/api/generate-question-details' do
      content_type :json
      
      begin
        request.body.rewind
        data = JSON.parse(request.body.read)
        scenario_name = data['scenario_name'] || 'New Scenario'
        
        prompt = <<~PROMPT
          You are helping design a new scenario for a retail grocery AI agent.
          
          Scenario name: #{scenario_name}
          
          Generate:
          1. A clear, concise description (2-3 sentences) of what this scenario handles
          2. Three realistic sample questions that a grocery manager might ask
          
          Return ONLY a JSON object with this structure:
          {
            "scenario_name": "Refined scenario name",
            "description": "Clear description",
            "sample_questions": ["Question 1", "Question 2", "Question 3"]
          }
          
          No markdown, no explanation, just the JSON.
        PROMPT
        
        result = call_claude_api(prompt)
        
        if result[:success]
          response_text = result[:response].gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
          parsed = JSON.parse(response_text)
          json({ success: true }.merge(parsed))
        else
          json({ success: false, error: result[:error] })
        end
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # Generate system prompt with Claude
    app.post '/api/generate-system-prompt' do
      content_type :json
      
      begin
        request.body.rewind
        data = JSON.parse(request.body.read)
        
        prompt = <<~PROMPT
          You are writing a system prompt addition for an AI agent that helps retail grocery managers.
          
          Scenario: #{data['scenario_name']}
          Description: #{data['description']}
          Sample questions: #{data['sample_questions']}
          
          Write a clear, professional system prompt section that:
          1. Defines when and how to use this capability
          2. Lists the decision framework (what to check, what to analyze)
          3. Specifies output requirements (what to include in responses)
          4. Includes relevant thresholds, rules, or guidelines
          
          Keep it practical and actionable. Write in present tense, direct style.
          Do not include XML tags or markdown formatting.
          Focus on the specific decision-making logic for this scenario.
          
          Output the system prompt text directly, no JSON wrapper.
        PROMPT
        
        result = call_claude_api(prompt)
        
        if result[:success]
          json({ success: true, system_prompt: result[:response] })
        else
          json({ success: false, error: result[:error] })
        end
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # Generate policy documents with Claude
    app.post '/api/generate-policy' do
      content_type :json
      
      begin
        request.body.rewind
        data = JSON.parse(request.body.read)
        
        prompt = <<~PROMPT
          You are writing policy documents for a retail grocery operation.
          
          Scenario: #{data['scenario_name']}
          Description: #{data['description']}
          
          Generate TWO policy documents:
          
          1. Human-readable policy text that includes:
             - Scope and purpose
             - Decision thresholds
             - Approval requirements
             - Safety constraints
             - Documentation requirements
          
          2. Machine-readable JSON policy with specific thresholds and rules
          
          Return as JSON:
          {
            "policy_name": "Policy Section Name",
            "policy_text": "Full human-readable policy...",
            "policy_json": "{\\"policy\\": {...}}"
          }
          
          Make it comprehensive and realistic. No markdown formatting.
        PROMPT
        
        result = call_claude_api(prompt)
        
        if result[:success]
          response_text = result[:response].gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
          parsed = JSON.parse(response_text)
          json({ success: true }.merge(parsed))
        else
          json({ success: false, error: result[:error] })
        end
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # Generate example dialog with Claude
    app.post '/api/generate-example' do
      content_type :json
      
      begin
        request.body.rewind
        data = JSON.parse(request.body.read)
        
        prompt = <<~PROMPT
          You are creating a training example for an AI agent that helps grocery managers.
          
          Scenario: #{data['scenario_name']}
          Description: #{data['description']}
          Sample questions: #{data['sample_questions']}
          
          Write a complete example that shows:
          1. The user's question (natural language)
          2. The agent's internal reasoning process
          3. What tools it would call and why
          4. The analysis it performs
          5. The final recommendation it provides
          
          Make it realistic with specific numbers, products, and business logic.
          Format as a clear example dialog.
          
          Return as JSON:
          {
            "example_name": "kebab-case-name",
            "example_dialog": "Full example text..."
          }
          
          No markdown formatting in the example text itself.
        PROMPT
        
        result = call_claude_api(prompt)
        
        if result[:success]
          response_text = result[:response].gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
          parsed = JSON.parse(response_text)
          json({ success: true }.merge(parsed))
        else
          json({ success: false, error: result[:error] })
        end
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # Generate tools with Claude
    app.post '/api/generate-tools' do
      content_type :json
      
      begin
        request.body.rewind
        data = JSON.parse(request.body.read)
        
        prompt = <<~PROMPT
          You are designing tools for Claude's function calling API.
          
          Scenario: #{data['scenario_name']}
          Description: #{data['description']}
          
          Create 2-4 tools and their Ruby implementations.
          
          Return as JSON:
          {
            "tool_definitions": "[{tool schema array}]",
            "tool_implementation": "# Ruby code\\ndef tool_name(params)\\n  ...\\nend"
          }
          
          Tool definitions should follow Claude's function calling schema.
          Implementations should be working Ruby methods with realistic mock data.
          No markdown code blocks in the strings.
        PROMPT
        
        result = call_claude_api(prompt)
        
        if result[:success]
          response_text = result[:response].gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
          parsed = JSON.parse(response_text)
          
          # Clean up any remaining markdown in the Ruby code
          if parsed['tool_implementation']
            parsed['tool_implementation'] = parsed['tool_implementation']
              .gsub(/```ruby\n?/, '').gsub(/```\n?/, '').strip
          end
          
          json({ success: true }.merge(parsed))
        else
          json({ success: false, error: result[:error] })
        end
      rescue => e
        status 500
        json({ success: false, error: e.message })
      end
    end
    
    # ============================================
    # API ROUTES - SCENARIO SAVE & MANAGEMENT
    # ============================================
    
    app.post '/api/save-scenario' do
      content_type :json
      
      begin
        request.body.rewind
        config = JSON.parse(request.body.read)
        
        # Generate question ID from scenario name
        question_id = config['question_id'] || config['scenario_name']
          .downcase
          .gsub(/[^a-z0-9\s-]/, '')
          .gsub(/\s+/, '-')
        
        base_dir = File.expand_path('../..', __FILE__)
        files_created = []
        
        # Determine tool category based on scenario name
        tool_category = determine_tool_category(config['scenario_name'])
        
        # Ensure directories exist (using NEW rationalized structure)
        [
          File.join(base_dir, 'prompts', 'scenarios'),
          File.join(base_dir, 'policies'),
          File.join(base_dir, 'examples'),
          File.join(base_dir, 'config', tool_category),
          File.join(base_dir, 'tools', tool_category),
          File.join(base_dir, 'ask_questions'),
          File.join(base_dir, 'scenarios')
        ].each { |dir| FileUtils.mkdir_p(dir) }
        
        # 1. System prompt
        prompt_path = File.join(base_dir, 'prompts', 'scenarios', "#{question_id}.txt")
        File.write(prompt_path, config['system_prompt'])
        files_created << "prompts/scenarios/#{question_id}.txt"
        
        # 2. Policy text
        policy_text_path = File.join(base_dir, 'policies', "#{question_id}.txt")
        File.write(policy_text_path, config['policy_text'])
        files_created << "policies/#{question_id}.txt"
        
        # 3. Policy JSON
        policy_json_path = File.join(base_dir, 'policies', "#{question_id}.json")
        policy_data = begin
          JSON.parse(config['policy_json'])
        rescue JSON::ParserError
          { policy_id: question_id, version: "1.0" }
        end
        File.write(policy_json_path, JSON.pretty_generate(policy_data))
        files_created << "policies/#{question_id}.json"
        
        # 4. Example dialog
        example_path = File.join(base_dir, 'examples', "#{question_id}.txt")
        File.write(example_path, config['example_dialog'])
        files_created << "examples/#{question_id}.txt"
        
        # 5. Tool config (NEW rationalized structure)
        tool_config_path = File.join(base_dir, 'config', tool_category, "#{question_id}.json")
        tool_config = begin
          parsed_tools = JSON.parse(config['tool_definitions'])
          # Wrap in new rationalized config format
          {
            "category" => tool_category,
            "module" => classify_name(question_id),
            "description" => config['scenario_description'],
            "tools" => parsed_tools.is_a?(Array) ? parsed_tools : [parsed_tools]
          }
        rescue JSON::ParserError
          {
            "category" => tool_category,
            "module" => classify_name(question_id),
            "description" => config['scenario_description'],
            "tools" => []
          }
        end
        File.write(tool_config_path, JSON.pretty_generate(tool_config))
        files_created << "config/#{tool_category}/#{question_id}.json"
        
        # 6. Tool implementation (NEW rationalized structure)
        tool_impl_path = File.join(base_dir, 'tools', tool_category, "#{question_id}.rb")
        class_name = classify_name(question_id)
        module_name = tool_category.capitalize
        
        tool_impl = <<~RUBY
          # CARINA #{module_name} Tools - #{config['scenario_name']}
          # Generated: #{Time.now}
          # Category: #{tool_category}
          # Description: #{config['scenario_description']}

          module CARINA
            module #{module_name}
              class #{class_name}
                
                # Original implementation refactored into class methods
                #{indent_ruby_code(config['tool_implementation'])}
                
              end
            end
          end
        RUBY
        
        File.write(tool_impl_path, tool_impl)
        files_created << "tools/#{tool_category}/#{question_id}.rb"
        
        # 7. Question JSON file
        question_file_path = File.join(base_dir, 'ask_questions', "#{question_id}.json")
        question_data = {
          'id' => question_id,
          'icon' => config['button_icon'],
          'label' => config['button_label'],
          'question' => config['button_question'],
          'category' => 'custom',
          'order' => 100,
          'enabled' => true
        }
        File.write(question_file_path, JSON.pretty_generate(question_data))
        files_created << "ask_questions/#{question_id}.json"
        
        # 8. Scenario manifest
        manifest = {
          scenario_name: config['scenario_name'],
          scenario_id: question_id,
          created_at: Time.now.iso8601,
          description: config['scenario_description'],
          sample_questions: config['sample_questions'].to_s.split("\n").map(&:strip).reject(&:empty?),
          files: {
            system_prompt: "prompts/scenarios/#{question_id}.txt",
            policy_text: "policies/#{question_id}.txt",
            policy_json: "policies/#{question_id}.json",
            example: "examples/#{question_id}.txt",
            tools_config: "config/#{tool_category}/#{question_id}.json",
            tools_implementation: "tools/#{tool_category}/#{question_id}.rb",
            ask_question: "ask_questions/#{question_id}.json"
          },
          quick_action: {
            icon: config['button_icon'],
            label: config['button_label'],
            question: config['button_question']
          }
        }
        
        manifest_file = File.join(base_dir, 'scenarios', "#{question_id}.json")
        File.write(manifest_file, JSON.pretty_generate(manifest))
        files_created << "scenarios/#{question_id}.json"
        
        json({
          success: true,
          message: "Scenario '#{config['scenario_name']}' saved successfully",
          question_id: question_id,
          files_created: files_created
        })
        
      rescue JSON::ParserError => e
        status 400
        json({ success: false, error: "Invalid JSON: #{e.message}" })
      rescue => e
        status 500
        json({ success: false, error: e.message, backtrace: e.backtrace[0..2] })
      end
    end
    
    # ============================================
    # API ROUTES - CORE AGENT FUNCTIONALITY
    # ============================================
    
    app.post '/api/ask' do
      content_type :json
      
      user_message = params[:message]
      
      if user_message.nil? || user_message.strip.empty?
        return json({ error: 'Message is required' })
      end
      
      response = call_claude_api(user_message)
      json(response)
    end
    
    app.post '/api/execute_markdown' do
      content_type :json
      
      product_id = params[:product_id]
      store_id = params[:store_id]
      new_price = params[:new_price].to_f
      reason = params[:reason]
      
      result = execute_markdown(product_id, store_id, new_price, reason)
      json(result)
    end
    
    # ============================================
    # API ROUTES - ADMIN & TOOL MANAGEMENT
    # ============================================
    
    app.get '/api/admin/pending-requests' do
      content_type :json
      json({ success: true, requests: $pending_tool_requests })
    end
    
    app.post '/api/admin/tool-response' do
      content_type :json
      request.body.rewind
      data = JSON.parse(request.body.read)
      
      tool_name = data['tool_name']
      request_id = data['request_id']
      response_data = data['response']
      
      $tool_responses[request_id] = response_data.to_json
      $pending_tool_requests.delete(tool_name)
      
      json({ success: true })
    end
    
    # ============================================
    # HELPER METHODS - CLAUDE API
    # ============================================
    
    # Helper method to call Claude API using app settings
    def call_claude_api(prompt)
      # Access the app's configured API key
      api_key = app.settings.api_key
      
      unless api_key
        return {
          success: false,
          error: "API key not configured in app settings"
        }
      end
      
      # Call Claude API
      uri = URI('https://api.anthropic.com/v1/messages')
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['x-api-key'] = api_key
      request['anthropic-version'] = '2023-06-01'
      
      body = {
        model: 'claude-sonnet-4-20250514',
        max_tokens: 4096,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ]
      }
      
      request.body = JSON.generate(body)
      
      begin
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.read_timeout = 120
          http.request(request)
        end
        
        if response.is_a?(Net::HTTPSuccess)
          result = JSON.parse(response.body)
          
          if result['content'] && result['content'][0] && result['content'][0]['text']
            return {
              success: true,
              response: result['content'][0]['text']
            }
          else
            return {
              success: false,
              error: "Unexpected API response format"
            }
          end
        else
          error_body = begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            { 'error' => { 'message' => response.body } }
          end
          
          return {
            success: false,
            error: "API Error #{response.code}: #{error_body.dig('error', 'message') || response.message}"
          }
        end
      rescue StandardError => e
        return {
          success: false,
          error: "Network error: #{e.message}"
        }
      end
    end
    
    # ============================================
    # HELPER FUNCTIONS FOR RATIONALIZED TOOLS
    # ============================================
    
    # Determine tool category based on scenario name
    def self.determine_tool_category(scenario_name)
      case scenario_name.downcase
      when /competitor|pricing|inventory|stock|restock|expir|product|policy|compli/
        'retail'
      when /staff|allocation|capacity|shortfall|workforce|schedul/
        'operations'  
      when /system|server|backup|health|outage|critical|infrastructure/
        'systems'
      when /security|alert|threat|breach|incident/
        'security'
      when /incident|change|calendar|release|deploy/
        'incidents'
      when /weather|external|forecast|api|integration/
        'external'
      else
        'operations' # Default category
      end
    end
    
    # Convert question_id to proper class name
    def self.classify_name(question_id)
      question_id.split('-').map(&:capitalize).join
    end
    
    # Indent Ruby code for class method insertion
    def self.indent_ruby_code(code)
      return '' if code.nil? || code.empty?
      
      # Convert function definitions to class methods
      code.lines.map do |line|
        if line.strip.start_with?('def ')
          "        #{line.gsub(/^def /, 'def self.')}"
        else
          "        #{line}"
        end
      end.join
    end
    
    # Load tool definitions handling both old and new formats
    def self.load_tool_definitions(tool_config_file)
      return '' unless File.exist?(tool_config_file)
      
      begin
        config = JSON.parse(File.read(tool_config_file))
        
        # New rationalized format has 'tools' array
        if config.is_a?(Hash) && config['tools']
          JSON.pretty_generate(config['tools'])
        # Old format is directly an array
        elsif config.is_a?(Array)
          JSON.pretty_generate(config)
        else
          File.read(tool_config_file)
        end
      rescue JSON::ParserError
        File.read(tool_config_file)
      end
    end
    
  end
end
