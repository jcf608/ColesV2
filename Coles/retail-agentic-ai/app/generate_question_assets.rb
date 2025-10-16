#!/usr/bin/env ruby
# Version: 2.0.0 - Now with Claude-powered content generation! 🎉

require 'json'
require 'fileutils'
require 'net/http'
require 'uri'

class ClaudePoweredAssetGenerator
  BASE_DIR = File.expand_path('..', __dir__)
  QUESTIONS_DIR = File.join(BASE_DIR, 'ask_questions')
  PROMPTS_DIR = File.join(BASE_DIR, 'prompts', 'scenarios')
  POLICIES_DIR = File.join(BASE_DIR, 'policies')
  EXAMPLES_DIR = File.join(BASE_DIR, 'examples')
  TOOLS_CONFIG_DIR = File.join(BASE_DIR, 'config', 'tools')
  TOOLS_IMPL_DIR = File.join(BASE_DIR, 'tools')
  
  def initialize
    ensure_directories_exist
    load_api_key
  end
  
  def generate_all
    puts "Version: 2.0.0"
    puts "🔍 Scanning for questions in: #{QUESTIONS_DIR}"
    
    unless Dir.exist?(QUESTIONS_DIR)
      puts "❌ Questions directory not found: #{QUESTIONS_DIR}"
      return
    end
    
    questions = load_questions
    
    if questions.empty?
      puts "⚠️  No enabled questions found"
      return
    end
    
    puts "📋 Found #{questions.length} enabled question(s)"
    puts "🤖 Using Claude to generate premium content..."
    
    questions.each do |question|
      generate_assets_for_question(question)
    end
    
    puts "\n✅ Asset generation complete"
  end
  
  def generate_for_question_id(question_id)
    puts "Version: 2.0.0"
    question_file = File.join(QUESTIONS_DIR, "#{question_id}.json")
    
    unless File.exist?(question_file)
      puts "❌ Question file not found: #{question_file}"
      return false
    end
    
    question = JSON.parse(File.read(question_file))
    
    unless question['enabled']
      puts "⚠️  Question '#{question_id}' is disabled"
      return false
    end
    
    puts "🤖 Using Claude to generate premium content..."
    generate_assets_for_question(question)
    true
  end
  
  private
  
  def ensure_directories_exist
    [PROMPTS_DIR, POLICIES_DIR, EXAMPLES_DIR, TOOLS_CONFIG_DIR, TOOLS_IMPL_DIR].each do |dir|
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end
  end
  
  def load_api_key
    keys_file = File.join(BASE_DIR, 'keys.json')
    
    unless File.exist?(keys_file)
      raise "❌ keys.json not found at #{keys_file}"
    end
    
    keys = JSON.parse(File.read(keys_file))
    @api_key = keys['anthropic_api_key']
    
    unless @api_key
      raise "❌ anthropic_api_key not found in keys.json"
    end
  end
  
  def load_questions
    questions = []
    
    Dir.glob(File.join(QUESTIONS_DIR, '*.json')).each do |file|
      begin
        question = JSON.parse(File.read(file))
        questions << question if question['enabled']
      rescue => e
        puts "⚠️  Warning: Could not load #{File.basename(file)}: #{e.message}"
      end
    end
    
    questions.sort_by { |q| q['order'] || 999 }
  end
  
  def generate_assets_for_question(question)
    id = question['id']
    puts "\n" + "=" * 80
    puts "📝 Generating premium assets for: #{question['label']} (#{id})"
    puts "=" * 80
    
    create_system_prompt(id, question)
    create_policy_files(id, question)
    create_example_dialog(id, question)
    create_tool_config(id, question)
    create_tool_implementation(id, question)
  end
  
  def call_claude(prompt)
    uri = URI('https://api.anthropic.com/v1/messages')
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-api-key'] = @api_key
    request['anthropic-version'] = '2023-06-01'
    
    request.body = JSON.generate({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      messages: [{ role: 'user', content: prompt }]
    })
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    unless response.is_a?(Net::HTTPSuccess)
      raise "API Error: #{response.code} - #{response.body}"
    end
    
    result = JSON.parse(response.body)
    result['content'][0]['text']
  rescue => e
    puts "  ⚠️  API call failed: #{e.message}"
    puts "  📝 Falling back to template content"
    nil
  end
  
  def create_system_prompt(id, question)
    file_path = File.join(PROMPTS_DIR, "#{id}.txt")
    
    if File.exist?(file_path)
      puts "  ⏭️  System prompt already exists"
      return
    end
    
    puts "  🤖 Asking Claude to write system prompt..."
    
    prompt = <<~PROMPT
      You are writing a system prompt addition for an AI agent that helps retail grocery managers.
      
      The agent needs to handle this scenario:
      - Question: "#{question['question']}"
      - Category: #{question['category']}
      - Label: #{question['label']}
      
      Write a clear, professional system prompt section that:
      1. Defines when and how to use this capability
      2. Lists the decision framework (what to check, what to analyze)
      3. Specifies output requirements (what to include in responses)
      4. Includes relevant thresholds, rules, or guidelines
      
      Keep it practical and actionable. Write in present tense, direct style.
      Do not include XML tags or markdown formatting.
      Focus on the specific decision-making logic for this scenario.
    PROMPT
    
    content = call_claude(prompt)
    
    if content
      File.write(file_path, content)
      puts "  ✅ Created AI-generated system prompt"
    else
      content = generate_fallback_system_prompt(id, question)
      File.write(file_path, content)
      puts "  ✅ Created template system prompt"
    end
  end
  
  def create_policy_files(id, question)
    text_path = File.join(POLICIES_DIR, "#{id}.txt")
    json_path = File.join(POLICIES_DIR, "#{id}.json")
    
    # Generate policy text
    unless File.exist?(text_path)
      puts "  🤖 Asking Claude to write policy document..."
      
      prompt = <<~PROMPT
        You are writing a business policy document for a retail grocery operation.
        
        The policy covers: #{question['label']}
        Context: #{question['question']}
        Category: #{question['category']}
        
        Write a comprehensive policy document that includes:
        1. Scope and purpose
        2. Decision thresholds (when automation is OK, when to escalate)
        3. Approval requirements (who needs to approve what)
        4. Safety constraints and guardrails
        5. Documentation requirements
        
        Write in clear business language. Use headings and structure.
        Be specific about percentages, thresholds, and approval levels.
        Do not use markdown formatting.
      PROMPT
      
      content = call_claude(prompt)
      
      if content
        File.write(text_path, content)
        puts "  ✅ Created AI-generated policy text"
      else
        content = generate_fallback_policy_text(id, question)
        File.write(text_path, content)
        puts "  ✅ Created template policy text"
      end
    else
      puts "  ⏭️  Policy text already exists"
    end
    
    # Generate policy JSON
    unless File.exist?(json_path)
      puts "  🤖 Asking Claude to write policy JSON..."
      
      prompt = <<~PROMPT
        You are writing a machine-readable policy configuration in JSON format.
        
        The policy covers: #{question['label']}
        Context: #{question['question']}
        Category: #{question['category']}
        
        Create a JSON structure that includes:
        1. Policy metadata (id, version, effective_date)
        2. Approval thresholds with specific rules
        3. Safety constraints
        4. Category-specific rules if applicable
        5. Any numeric thresholds or limits
        
        Output ONLY valid JSON. No markdown, no explanation, just the JSON object.
        Make it comprehensive and realistic for a retail grocery operation.
      PROMPT
      
      content = call_claude(prompt)
      
      if content && valid_json?(content)
        # Clean up any markdown artifacts
        clean_json = content.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
        File.write(json_path, clean_json)
        puts "  ✅ Created AI-generated policy JSON"
      else
        content = generate_fallback_policy_json(id, question)
        File.write(json_path, JSON.pretty_generate(content))
        puts "  ✅ Created template policy JSON"
      end
    else
      puts "  ⏭️  Policy JSON already exists"
    end
  end
  
  def create_example_dialog(id, question)
    file_path = File.join(EXAMPLES_DIR, "#{id}.txt")
    
    if File.exist?(file_path)
      puts "  ⏭️  Example dialog already exists"
      return
    end
    
    puts "  🤖 Asking Claude to write example dialog..."
    
    prompt = <<~PROMPT
      You are creating a training example for an AI agent that helps grocery managers.
      
      Scenario: #{question['label']}
      User asks: "#{question['question']}"
      Category: #{question['category']}
      
      Write a complete example that shows:
      1. The user's question (natural language)
      2. The agent's internal reasoning process (what it considers)
      3. What tools it would call and why
      4. The analysis it performs
      5. The final recommendation it provides
      
      Make it realistic with specific numbers, products, and business logic.
      Show good decision-making process.
      Format as a clear example dialog.
      Do not use markdown formatting.
    PROMPT
    
    content = call_claude(prompt)
    
    if content
      File.write(file_path, content)
      puts "  ✅ Created AI-generated example dialog"
    else
      content = generate_fallback_example(id, question)
      File.write(file_path, content)
      puts "  ✅ Created template example dialog"
    end
  end
  
  def create_tool_config(id, question)
    file_path = File.join(TOOLS_CONFIG_DIR, "#{id}_tools.json")
    
    if File.exist?(file_path)
      puts "  ⏭️  Tool config already exists"
      return
    end
    
    puts "  🤖 Asking Claude to design tool definitions..."
    
    prompt = <<~PROMPT
      You are designing tool definitions for Claude's function calling API.
      
      Scenario: #{question['label']}
      User asks: "#{question['question']}"
      Category: #{question['category']}
      
      Design 2-4 tools that would help answer this question. Each tool should:
      1. Have a clear, specific purpose
      2. Use snake_case naming (e.g., get_inventory_status)
      3. Include a good description
      4. Have a proper input_schema with required/optional parameters
      
      Output ONLY valid JSON array. No markdown, no explanation.
      Follow this structure:
      [
        {
          "name": "tool_name",
          "description": "What this tool does",
          "input_schema": {
            "type": "object",
            "properties": {
              "param_name": {
                "type": "string",
                "description": "What this parameter is"
              }
            },
            "required": ["param_name"]
          }
        }
      ]
    PROMPT
    
    content = call_claude(prompt)
    
    if content && valid_json?(content)
      # Clean up markdown artifacts
      clean_json = content.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
      File.write(file_path, clean_json)
      puts "  ✅ Created AI-generated tool definitions"
    else
      content = generate_fallback_tool_config(id, question)
      File.write(file_path, JSON.pretty_generate(content))
      puts "  ✅ Created template tool config"
    end
  end
  
  def create_tool_implementation(id, question)
    file_path = File.join(TOOLS_IMPL_DIR, "#{id}_tools.rb")
    
    if File.exist?(file_path)
      puts "  ⏭️  Tool implementation already exists"
      return
    end
    
    puts "  🤖 Asking Claude to write tool implementation..."
    
    # First, read the tool config we just created
    config_path = File.join(TOOLS_CONFIG_DIR, "#{id}_tools.json")
    tool_names = []
    
    if File.exist?(config_path)
      begin
        tools = JSON.parse(File.read(config_path))
        tool_names = tools.map { |t| t['name'] }
      rescue
        # Will use fallback
      end
    end
    
    tools_list = tool_names.empty? ? "appropriate tools" : tool_names.join(', ')
    
    prompt = <<~PROMPT
      You are writing Ruby method implementations for tools that an AI agent will call.
      
      Scenario: #{question['label']}
      Tools to implement: #{tools_list}
      
      Write Ruby methods that:
      1. Take a params hash as input
      2. Extract and validate parameters
      3. Return realistic sample data (mock implementation)
      4. Include error handling
      5. Return structured hashes with relevant data
      
      Use clear Ruby code. Include comments.
      Each method should return a hash with realistic grocery retail data.
      Make the data specific and useful for the scenario.
      
      Output only Ruby code, no markdown code blocks.
    PROMPT
    
    content = call_claude(prompt)
    
    if content
      # Clean up any markdown artifacts
      clean_ruby = content.gsub(/```ruby\n?/, '').gsub(/```\n?/, '').strip
      File.write(file_path, "# Tool implementations for: #{question['label']}\n# Generated: #{Time.now}\n\n#{clean_ruby}")
      puts "  ✅ Created AI-generated tool implementation"
    else
      content = generate_fallback_tool_implementation(id, question)
      File.write(file_path, content)
      puts "  ✅ Created template tool implementation"
    end
  end
  
  def valid_json?(str)
    return false unless str
    JSON.parse(str.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip)
    true
  rescue JSON::ParserError
    false
  end
  
  # Fallback methods for when API fails
  
  def generate_fallback_system_prompt(id, question)
    category_name = format_category_name(question['category'])
    
    <<~PROMPT
    #{category_name.upcase} CAPABILITY:
    
    When users ask: "#{question['question']}"
    
    Decision Framework:
    1. Identify the key parameters from the user's question
    2. Use available tools to gather necessary data
    3. Apply relevant policies and constraints
    4. Provide clear, actionable recommendations
    
    Output Requirements:
    - State the current situation clearly
    - List specific items or areas requiring attention
    - Provide actionable recommendations
    - Include confidence level based on available data
    - Flag any missing information or uncertainties
    PROMPT
  end
  
  def generate_fallback_policy_text(id, question)
    category_name = format_category_name(question['category'])
    
    <<~POLICY
    #{category_name.upcase} POLICY
    
    Scope:
    This policy governs how the system handles requests related to: #{question['label']}
    
    General Requirements:
    - Use only approved data sources
    - Apply minimum confidence thresholds before making recommendations
    - Document all decisions with relevant context
    - Escalate edge cases to appropriate managers
    
    Decision Thresholds:
    - Minor decisions: Automatic approval
    - Moderate decisions: Store manager notification
    - Major decisions: Regional manager approval required
    
    Safety Constraints:
    - Never compromise product quality or safety
    - Maintain minimum stock levels for critical items
    - Document all policy-based decisions
    
    Last Updated: #{Time.now.strftime('%Y-%m-%d')}
    POLICY
  end
  
  def generate_fallback_policy_json(id, question)
    {
      "policy_id" => id,
      "version" => "1.0",
      "effective_date" => Time.now.strftime('%Y-%m-%d'),
      "category" => question['category'],
      "approval_thresholds" => {
        "minor" => {
          "approval" => "automatic",
          "description" => "Low-impact decisions"
        },
        "moderate" => {
          "approval" => "store_manager",
          "description" => "Medium-impact decisions requiring notification"
        },
        "major" => {
          "approval" => "regional_manager",
          "description" => "High-impact decisions requiring approval"
        }
      },
      "safety_constraints" => {
        "requires_documentation" => true,
        "minimum_confidence_pct" => 70
      }
    }
  end
  
  def generate_fallback_example(id, question)
    <<~EXAMPLE
    EXAMPLE DECISION: #{question['label']}
    
    Query: "#{question['question']}"
    
    Agent reasoning:
    - Analyzing current data from available sources
    - Checking relevant policies and constraints
    - Evaluating options and trade-offs
    - Determining confidence level
    
    Analysis:
    [The agent would gather data using available tools, apply policy rules, 
    and analyze the situation based on the specific context of this question.]
    
    Decision:
    [Based on the analysis, the agent provides specific, actionable recommendations
    with clear reasoning and confidence levels.]
    
    Tool calls made:
    1. [Tool name and parameters]
    2. [Tool name and parameters]
    
    Final recommendation:
    [Clear, specific actions to take, with any necessary caveats or conditions.]
    EXAMPLE
  end
  
  def generate_fallback_tool_config(id, question)
    tool_name = "get_#{id.gsub('-', '_')}_data"
    
    [
      {
        "name" => tool_name,
        "description" => "Retrieve data relevant to: #{question['label']}",
        "input_schema" => {
          "type" => "object",
          "properties" => {
            "scope" => {
              "type" => "string",
              "description" => "The scope of data to retrieve"
            },
            "timeframe" => {
              "type" => "string",
              "description" => "Time period for analysis"
            }
          },
          "required" => ["scope"]
        }
      }
    ]
  end
  
  def generate_fallback_tool_implementation(id, question)
    tool_name = "get_#{id.gsub('-', '_')}_data"
    
    <<~RUBY
    # Tool implementation for: #{question['label']}
    # Generated: #{Time.now}
    
    def #{tool_name}(params)
      scope = params['scope'] || 'default'
      timeframe = params['timeframe'] || '24h'
      
      {
        tool: '#{tool_name}',
        scope: scope,
        timeframe: timeframe,
        data: {
          status: 'success',
          message: 'Data retrieved successfully',
          results: []
        },
        timestamp: Time.now.iso8601
      }
    rescue => e
      {
        error: "Tool execution failed: \#{e.message}",
        tool: '#{tool_name}'
      }
    end
    RUBY
  end
  
  def format_category_name(category)
    category.split('-').map(&:capitalize).join(' ')
  end
end

if __FILE__ == $0
  puts "Version: 2.0.0"
  puts "=" * 80
  
  generator = ClaudePoweredAssetGenerator.new
  
  if ARGV.length > 0
    question_id = ARGV[0]
    puts "Generating Claude-powered assets for: #{question_id}"
    success = generator.generate_for_question_id(question_id)
    exit(success ? 0 : 1)
  else
    puts "Generating Claude-powered assets for all enabled questions"
    generator.generate_all
  end
end
