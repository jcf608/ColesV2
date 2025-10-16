#!/usr/bin/env ruby
# Version: 3.0.0 - Refactored with new Lovable.dev inspired routes

require 'sinatra'
require 'sinatra/json'
require 'json'
require 'net/http'
require 'uri'
require 'date'
require 'fileutils'
require_relative 'routes'

# Global state for MCP tool handling
$pending_tool_requests = {}
$tool_responses = {}
$request_counter = 0

class ProduceOptimizationApp < Sinatra::Base
  register ProduceOptimizationRoutes
  set :views, File.expand_path('../views', __FILE__)
  set :public_folder, File.expand_path('../public', __FILE__)
  
  configure do
    keys_file = File.expand_path('../../keys.json', __FILE__)
    keys = JSON.parse(File.read(keys_file))
    set :api_key, keys['anthropic_api_key']
    
    system_prompt_path = File.expand_path('../../prompts/produce-optimization-agent.txt', __FILE__)
    set :system_prompt, File.read(system_prompt_path)
  end
  
  # ============================================
  # CLAUDE API INTEGRATION
  # ============================================
  
  def call_claude_api(user_message)
    messages = [{ role: 'user', content: user_message }]
    tool_calls = []
    final_response = ''
    
    # Conversation loop - allow up to 5 turns for tool use
    5.times do
      result = send_claude_request(messages)
      
      return result unless result[:success]
      
      # Check if Claude is done
      if result[:stop_reason] == 'end_turn'
        final_response = result[:response_text]
        break
      end
      
      # Handle tool use
      if result[:tool_uses]&.any?
        messages << { role: 'assistant', content: result[:full_content] }
        
        tool_results_content = process_tool_uses(result[:tool_uses], tool_calls)
        
        messages << { role: 'user', content: tool_results_content }
      else
        final_response = result[:response_text]
        break
      end
    end
    
    { success: true, response: final_response, tool_calls: tool_calls }
  rescue => e
    build_error_response(e)
  end
  
  def send_claude_request(messages)
    response = make_api_request(messages)
    
    return parse_error_response(response) unless response.is_a?(Net::HTTPSuccess)
    
    result = JSON.parse(response.body)
    
    return invalid_response_error(result, response) unless valid_response_structure?(result)
    
    parse_claude_response(result)
  rescue JSON::ParserError => e
    { success: false, error: "JSON parsing failed: #{e.message}", response_preview: safe_body_preview(response) }
  rescue => e
    { success: false, error: "Request error: #{e.message}", backtrace: e.backtrace[0..2] }
  end
  
  def make_api_request(messages)
    uri = URI('https://api.anthropic.com/v1/messages')
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-api-key'] = settings.api_key
    request['anthropic-version'] = '2023-06-01'
    
    request.body = JSON.generate({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      system: settings.system_prompt,
      messages: messages,
      tools: get_mcp_tools
    })
    
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  end
  
  def parse_claude_response(result)
    response_text = ''
    tool_uses = []
    
    result['content'].each do |block|
      next unless block&.is_a?(Hash) && block['type']
      
      case block['type']
      when 'text'
        response_text += (block['text'] || '')
      when 'tool_use'
        tool_uses << block if valid_tool_use?(block)
      end
    end
    
    {
      success: true,
      response_text: response_text,
      tool_uses: tool_uses,
      full_content: result['content'],
      stop_reason: result['stop_reason']
    }
  end
  
  def process_tool_uses(tool_uses, tool_calls)
    tool_results_content = []
    
    tool_uses.each do |tool_use|
      begin
        tool_result_json = execute_tool_with_admin(
          tool_use['name'], 
          tool_use['input'], 
          tool_use['id']
        )
        
        parsed_result = parse_tool_result(tool_result_json)
        
        tool_calls << {
          name: tool_use['name'],
          input: tool_use['input'],
          result: parsed_result
        }
        
        tool_results_content << {
          type: 'tool_result',
          tool_use_id: tool_use['id'],
          content: parsed_result.to_json
        }
      rescue => e
        puts "❌ Tool Error: #{e.message}"
        tool_results_content << {
          type: 'tool_result',
          tool_use_id: tool_use['id'],
          content: { error: e.message }.to_json
        }
      end
    end
    
    tool_results_content
  end
  
  # ============================================
  # TOOL EXECUTION & MANAGEMENT
  # ============================================
  
  def execute_tool_with_admin(tool_name, parameters, tool_use_id)
    request_id = store_tool_request(tool_name, parameters, tool_use_id)
    wait_for_tool_response(tool_name, request_id, timeout: 30)
  end
  
  def store_tool_request(tool_name, parameters, tool_use_id)
    $request_counter += 1
    request_id = "REQ-#{Time.now.to_i}-#{$request_counter}"
    
    $pending_tool_requests[tool_name] = {
      id: request_id,
      tool_use_id: tool_use_id,
      parameters: parameters,
      timestamp: Time.now.iso8601
    }
    
    request_id
  end
  
  def wait_for_tool_response(tool_name, request_id, timeout: 30)
    start_time = Time.now
    
    loop do
      if $tool_responses[request_id]
        response = $tool_responses[request_id]
        $tool_responses.delete(request_id)
        return response
      end
      
      if Time.now - start_time > timeout
        parameters = $pending_tool_requests[tool_name][:parameters]
        return generate_mock_response(tool_name, parameters)
      end
      
      sleep(0.5)
    end
  end
  
  def generate_mock_response(tool_name, parameters)
    execute_tool(tool_name, parameters).to_json
  end
  
  def execute_tool(tool_name, parameters)
    return invalid_parameters_error(parameters) unless parameters.is_a?(Hash)
    
    params = parameters.transform_keys(&:to_s)
    
    case tool_name
    when 'get_inventory_status'
      get_inventory_status(params)
    when 'query_sales_velocity'
      query_sales_velocity(params)
    when 'check_pricing_policy'
      check_pricing_policy(params)
    when 'get_competitor_pricing'
      get_competitor_pricing(params)
    else
      unknown_tool_error(tool_name)
    end
  rescue => e
    tool_execution_error(e, tool_name)
  end
  
  # ============================================
  # TOOL IMPLEMENTATIONS
  # ============================================
  
  def get_inventory_status(params)
    {
      product_id: params['product_id'] || 'UNKNOWN',
      store_id: params['store_id'] || 'UNKNOWN',
      current_stock: 47,
      cost_per_unit: 4.50,
      shelf_price: 7.99,
      expiration_date: (Date.today + 2).to_s,
      units_sold_today: 4,
      average_daily_sales: 8,
      status: 'active'
    }
  end
  
  def query_sales_velocity(params)
    {
      product_id: params['product_id'] || 'UNKNOWN',
      store_id: params['store_id'] || 'UNKNOWN',
      velocity_units_per_day: 8.2,
      baseline_velocity: 9.5,
      velocity_trend: 'declining',
      days_analyzed: params['days_back'] || 7
    }
  end
  
  def check_pricing_policy(params)
    current = params['current_price']&.to_f || 7.99
    proposed = params['proposed_price']&.to_f || 5.99
    
    return { error: "Invalid current_price: cannot be zero" } if current == 0
    
    markdown_pct = ((current - proposed) / current * 100).round(1)
    
    {
      approved: true,
      approval_token: "APPR-#{Time.now.to_i}-#{rand(10000)}",
      markdown_percentage: markdown_pct,
      resulting_margin_pct: 25.3,
      requires_manager_approval: markdown_pct > 40,
      policy_notes: 'Meets minimum margin threshold for organic produce (15%)'
    }
  end
  
  def get_competitor_pricing(params)
    {
      category: params['category'] || 'produce',
      location: params['store_location'] || 'UNKNOWN',
      competitors: [
        { name: 'Farmers Market', price: 6.49, distance_miles: 0.3 },
        { name: 'Competitor Store A', price: 7.29, distance_miles: 1.2 },
        { name: 'Competitor Store B', price: 6.99, distance_miles: 2.1 }
      ],
      lowest_price: 6.49,
      average_price: 6.92
    }
  end
  
  # ============================================
  # MCP TOOLS SCHEMA
  # ============================================
  
  def get_mcp_tools
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
            days_back: { 
              type: 'integer',
              description: 'Number of days of historical data to analyze'
            }
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
          required: ['product_id', 'current_price', 'proposed_price']
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
  
  # ============================================
  # SAMPLE DATA HELPERS
  # ============================================
  
  def get_sample_inventory
    [
      {
        product_id: 'STR-ORG-16OZ',
        name: 'Organic Strawberries',
        current_stock: 47,
        cost: 4.50,
        price: 7.99,
        expires_in_days: 2,
        velocity: 8,
        status: 'warning'
      },
      {
        product_id: 'BLU-ORG-6OZ',
        name: 'Organic Blueberries',
        current_stock: 32,
        cost: 4.50,
        price: 7.99,
        expires_in_days: 2,
        velocity: 8,
        status: 'warning'
      },
      {
        product_id: 'SAL-CAES-12OZ',
        name: 'Caesar Salad Kit',
        current_stock: 18,
        cost: 2.25,
        price: 4.99,
        expires_in_days: 3,
        velocity: 6,
        status: 'good'
      }
    ]
  end
  
  def get_recent_decisions
    [
      {
        timestamp: Time.now - 3600,
        product: 'Organic Strawberries',
        decision: 'Markdown to $5.99',
        reason: 'Expiration in 2 days, slow velocity',
        margin: '25%',
        approved: true
      },
      {
        timestamp: Time.now - 7200,
        product: 'Caesar Salad Kit',
        decision: 'No action',
        reason: 'Healthy velocity, 3 days to expiration',
        margin: '55%',
        approved: true
      }
    ]
  end
  
  def execute_markdown(product_id, store_id, new_price, reason)
    {
      success: true,
      change_id: "CHG-#{Time.now.to_i}",
      message: "Markdown executed: #{product_id} to $#{new_price}",
      timestamp: Time.now.iso8601
    }
  rescue => e
    { success: false, error: e.message }
  end
  
  # ============================================
  # HELPER METHODS
  # ============================================
  
  # Helper method to load ask questions dynamically
  def load_ask_questions
    questions = []
    questions_dir = File.expand_path('../../ask_questions', __FILE__)
    
    if Dir.exist?(questions_dir)
      Dir.glob(File.join(questions_dir, '*.json')).each do |question_file|
        begin
          question = JSON.parse(File.read(question_file))
          questions << question if question['enabled']
        rescue => e
          puts "Warning: Could not load question file #{question_file}: #{e.message}"
        end
      end
    end
    
    # Sort by order field
    questions.sort_by { |q| q['order'] || 999 }
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
    tools_dir = File.expand_path('../tools', __FILE__)
    
    if Dir.exist?(tools_dir)
      Dir.glob(File.join(tools_dir, '*_tools.rb')).each do |tool_file|
        begin
          require tool_file
          
          method_name = tool_name.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '')
          
          if respond_to?(method_name)
            return send(method_name, parameters)
          end
        rescue => e
          puts "Warning: Could not load tool file #{tool_file}: #{e.message}"
        end
      end
    end
    
    { error: "Tool #{tool_name} not found or not implemented" }
  end
  
  def valid_response_structure?(result)
    result && result.is_a?(Hash) && result['content']
  end
  
  def valid_tool_use?(block)
    block['name'] && block['input'] && block['id']
  end
  
  def parse_tool_result(tool_result_json)
    if tool_result_json.is_a?(String)
      JSON.parse(tool_result_json)
    elsif tool_result_json.is_a?(Hash)
      tool_result_json
    else
      { error: "Unexpected tool result type: #{tool_result_json.class}" }
    end
  end
  
  def safe_body_preview(response)
    response.body[0..200] rescue 'N/A'
  end
  
  # ============================================
  # ERROR BUILDERS
  # ============================================
  
  def build_error_response(exception)
    { 
      success: false, 
      error: "Exception: #{exception.message}",
      error_class: exception.class.name,
      backtrace: exception.backtrace[0..3]
    }
  end
  
  def parse_error_response(response)
    { 
      success: false, 
      error: "API Error: #{response.code}",
      details: response.body[0..500]
    }
  end
  
  def invalid_response_error(result, response)
    {
      success: false,
      error: 'Invalid response structure from Claude API',
      debug_info: {
        result_class: result.class,
        result_keys: result.is_a?(Hash) ? result.keys : 'N/A',
        raw_response: response.body[0..500]
      }
    }
  end
  
  def invalid_parameters_error(parameters)
    { 
      error: "Invalid parameters type",
      expected: "Hash",
      received: parameters.class.name,
      value: parameters.inspect[0..100]
    }
  end
  
  def unknown_tool_error(tool_name)
    { 
      error: "Unknown tool: #{tool_name}",
      available_tools: ['get_inventory_status', 'query_sales_velocity', 
                       'check_pricing_policy', 'get_competitor_pricing']
    }
  end
  
  def tool_execution_error(exception, tool_name)
    {
      error: "Tool execution exception: #{exception.message}",
      tool_name: tool_name,
      error_class: exception.class.name,
      backtrace: exception.backtrace[0..2]
    }
  end
  
  run! if app_file == $0
end
