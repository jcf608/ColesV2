#!/usr/bin/env ruby
# Version: 2.0.0

require 'json'
require 'net/http'
require 'uri'
require 'open3'
require 'date'
require 'sinatra'
require 'sinatra/base'

# Storage for pending tool requests and responses
$pending_tool_requests = {}
$tool_responses = {}
$request_counter = 0

class ClaudeAgentClient
  COLORS = {
    primary: "\e[36m",
    success: "\e[32m",
    warning: "\e[33m",
    error: "\e[31m",
    agent: "\e[35m",
    reset: "\e[0m"
  }

  def initialize
    @keys_file = File.expand_path('keys.json')
    @api_key = load_api_key
    @mcp_server_path = File.expand_path('~/Dropbox/Valorica/Coles/retail-agentic-ai/mcp-server/build/index.js')
    @system_prompt_path = File.expand_path('~/Dropbox/Valorica/Coles/retail-agentic-ai/prompts/produce-optimization-agent.txt')
    
    validate_setup
  end

  def run_interactive
    puts colorize("🤖 Claude Agent with MCP Tools", :primary)
    puts colorize("Connected to: Retail Operations MCP Server", :success)
    puts colorize("\nType 'exit' or 'quit' to end session", :warning)
    puts colorize("=" * 60, :primary)
    
    loop do
      print colorize("\n👤 You: ", :primary)
      user_input = gets.chomp
      
      break if ['exit', 'quit'].include?(user_input.downcase)
      
      if user_input.strip.empty?
        puts colorize("Please enter a message", :warning)
        next
      end
      
      process_query(user_input)
    end
    
    puts colorize("\n👋 Goodbye!", :success)
  end

  def process_query_for_web(user_message)
    system_prompt = File.read(@system_prompt_path)
    
    messages = [
      {
        role: "user",
        content: user_message
      }
    ]
    
    tool_calls = []
    final_response = ""
    
    begin
      response = call_claude_api(system_prompt, messages)
      
      if response['content']
        response['content'].each do |content_block|
          case content_block['type']
          when 'text'
            final_response = content_block['text']
          when 'tool_use'
            # Store tool request for admin panel
            request_id = store_tool_request(content_block['name'], content_block['input'], content_block['id'])
            
            # Wait for admin response (with timeout)
            tool_result = wait_for_tool_response(content_block['name'], request_id, timeout: 300)
            
            tool_calls << {
              name: content_block['name'],
              parameters: content_block['input'],
              result: JSON.parse(tool_result)
            }
            
            messages << {
              role: "assistant",
              content: response['content']
            }
            
            messages << {
              role: "user",
              content: [
                {
                  type: "tool_result",
                  tool_use_id: content_block['id'],
                  content: tool_result
                }
              ]
            }
            
            final_response_obj = call_claude_api(system_prompt, messages)
            
            if final_response_obj['content']
              final_response_obj['content'].each do |final_block|
                if final_block['type'] == 'text'
                  final_response = final_block['text']
                end
              end
            end
          end
        end
      end
      
      {
        success: true,
        response: final_response,
        tool_calls: tool_calls
      }
    rescue => e
      {
        success: false,
        error: e.message
      }
    end
  end

  private

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

  def wait_for_tool_response(tool_name, request_id, timeout: 300)
    start_time = Time.now
    
    loop do
      # Check if response is available
      if $tool_responses[request_id]
        response = $tool_responses[request_id]
        $tool_responses.delete(request_id)
        return response
      end
      
      # Check timeout
      if Time.now - start_time > timeout
        # Fallback to mock data if no admin response
        return generate_mock_response(tool_name, $pending_tool_requests[tool_name][:parameters])
      end
      
      sleep(0.5)
    end
  end

  def generate_mock_response(tool_name, parameters)
    case tool_name
    when "get_inventory_status"
      {
        product_id: parameters['product_id'],
        store_id: parameters['store_id'],
        current_stock: 47,
        cost_per_unit: 4.50,
        shelf_price: 7.99,
        expiration_date: (Date.today + 2).to_s,
        units_sold_today: 4,
        average_daily_sales: 8,
        status: "active"
      }.to_json
    when "query_sales_velocity"
      {
        product_id: parameters['product_id'],
        store_id: parameters['store_id'],
        velocity_units_per_day: 8.2,
        baseline_velocity: 9.5,
        velocity_trend: "declining",
        days_analyzed: parameters['days_back']
      }.to_json
    when "check_pricing_policy"
      current = parameters['current_price']
      proposed = parameters['proposed_price']
      markdown_pct = ((current - proposed) / current * 100).round(1)
      
      {
        approved: true,
        approval_token: "APPR-#{Time.now.to_i}-#{rand(10000)}",
        markdown_percentage: markdown_pct,
        resulting_margin_pct: 25.3,
        requires_manager_approval: markdown_pct > 40,
        policy_notes: "Meets minimum margin threshold for organic produce (15%)"
      }.to_json
    when "submit_price_change"
      {
        success: true,
        change_id: "CHG-#{Time.now.to_i}",
        updated_at: Time.now.iso8601,
        message: "Price change executed successfully"
      }.to_json
    when "get_competitor_pricing"
      {
        category: parameters['category'],
        location: parameters['store_location'],
        competitors: [
          { name: "Farmers Market", price: 6.49, distance_miles: 0.3 },
          { name: "Competitor Store A", price: 7.29, distance_miles: 1.2 },
          { name: "Competitor Store B", price: 6.99, distance_miles: 2.1 }
        ],
        lowest_price: 6.49,
        average_price: 6.92
      }.to_json
    else
      { error: "Unknown tool: #{tool_name}" }.to_json
    end
  end

  def load_api_key
    unless File.exist?(@keys_file)
      puts colorize("❌ Error: keys.json not found", :error)
      puts colorize("\nCreate a keys.json file with your API key:", :warning)
      puts colorize('  {', :warning)
      puts colorize('    "anthropic_api_key": "your-api-key-here"', :warning)
      puts colorize('  }', :warning)
      exit 1
    end
    
    begin
      keys = JSON.parse(File.read(@keys_file))
      api_key = keys['anthropic_api_key']
      
      unless api_key
        puts colorize("❌ Error: 'anthropic_api_key' not found in keys.json", :error)
        exit 1
      end
      
      api_key
    rescue JSON::ParserError => e
      puts colorize("❌ Error: Invalid JSON in keys.json", :error)
      puts colorize("   #{e.message}", :error)
      exit 1
    end
  end

  def validate_setup
    unless File.exist?(@system_prompt_path)
      puts colorize("❌ Error: System prompt not found", :error)
      exit 1
    end
  end

  def process_query(user_message)
    system_prompt = File.read(@system_prompt_path)
    
    puts colorize("\n🤖 Claude (thinking...):", :agent)
    
    messages = [
      {
        role: "user",
        content: user_message
      }
    ]
    
    response = call_claude_api(system_prompt, messages)
    
    if response['content']
      response['content'].each do |content_block|
        case content_block['type']
        when 'text'
          puts colorize("\n#{content_block['text']}", :agent)
        when 'tool_use'
          puts colorize("\n🔧 Using tool: #{content_block['name']}", :primary)
          puts colorize("   Parameters: #{JSON.pretty_generate(content_block['input'])}", :primary)
          
          tool_result = execute_mcp_tool(content_block['name'], content_block['input'])
          
          puts colorize("\n📊 Tool result:", :success)
          puts colorize("   #{tool_result}", :success)
          
          messages << {
            role: "assistant",
            content: response['content']
          }
          
          messages << {
            role: "user",
            content: [
              {
                type: "tool_result",
                tool_use_id: content_block['id'],
                content: tool_result
              }
            ]
          }
          
          final_response = call_claude_api(system_prompt, messages)
          
          if final_response['content']
            final_response['content'].each do |final_block|
              if final_block['type'] == 'text'
                puts colorize("\n🤖 Claude:", :agent)
                puts colorize(final_block['text'], :agent)
              end
            end
          end
        end
      end
    end
    
    if response['stop_reason'] == 'end_turn'
      puts colorize("\n✓ Response complete", :success)
    end
    
  rescue => e
    puts colorize("\n❌ Error: #{e.message}", :error)
    puts colorize(e.backtrace.join("\n"), :error) if ENV['DEBUG']
  end

  def call_claude_api(system_prompt, messages)
    uri = URI('https://api.anthropic.com/v1/messages')
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-api-key'] = @api_key
    request['anthropic-version'] = '2023-06-01'
    
    tools = get_mcp_tools
    
    body = {
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      system: system_prompt,
      messages: messages
    }
    
    body[:tools] = tools unless tools.empty?
    
    request.body = JSON.generate(body)
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    unless response.is_a?(Net::HTTPSuccess)
      raise "API Error: #{response.code} - #{response.body}"
    end
    
    JSON.parse(response.body)
  end

  def get_mcp_tools
    [
      {
        name: "get_inventory_status",
        description: "Retrieve current inventory level, expiration dates, and recent movement for a product",
        input_schema: {
          type: "object",
          properties: {
            product_id: {
              type: "string",
              description: "Unique product identifier"
            },
            store_id: {
              type: "string",
              description: "Store location identifier"
            },
            include_supply_schedule: {
              type: "boolean",
              description: "Include upcoming delivery schedule"
            }
          },
          required: ["product_id", "store_id"]
        }
      },
      {
        name: "query_sales_velocity",
        description: "Get sales rate for product over specified time period with comparison to baseline",
        input_schema: {
          type: "object",
          properties: {
            product_id: { type: "string" },
            store_id: { type: "string" },
            days_back: { 
              type: "integer",
              description: "Number of days of historical data to analyze"
            }
          },
          required: ["product_id", "store_id", "days_back"]
        }
      },
      {
        name: "check_pricing_policy",
        description: "Validate proposed markdown against margin rules and approval requirements",
        input_schema: {
          type: "object",
          properties: {
            product_id: { type: "string" },
            current_price: { type: "number" },
            proposed_price: { type: "number" },
            reason_code: { 
              type: "string",
              description: "Reason for markdown (expiration, quality, competition)"
            }
          },
          required: ["product_id", "current_price", "proposed_price", "reason_code"]
        }
      },
      {
        name: "submit_price_change",
        description: "Execute approved price change in POS system (requires prior policy approval)",
        input_schema: {
          type: "object",
          properties: {
            product_id: { type: "string" },
            store_id: { type: "string" },
            new_price: { type: "number" },
            approval_token: { 
              type: "string",
              description: "Token from check_pricing_policy approval"
            }
          },
          required: ["product_id", "store_id", "new_price", "approval_token"]
        }
      },
      {
        name: "get_competitor_pricing",
        description: "Retrieve current pricing for product category from local competitors",
        input_schema: {
          type: "object",
          properties: {
            category: { type: "string" },
            radius_miles: { type: "number" },
            store_location: { type: "string" }
          },
          required: ["category", "store_location"]
        }
      }
    ]
  end

  def execute_mcp_tool(tool_name, parameters)
    generate_mock_response(tool_name, parameters)
  end

  def colorize(text, color)
    "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end
end

# Web Application
class ProduceAgentWeb < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  
  configure do
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end
  
  before do
    @agent = ClaudeAgentClient.new
  end
  
  get '/' do
    erb :index
  end
  
  get '/dashboard' do
    erb :dashboard
  end
  
  get '/decisions' do
    erb :decisions
  end
  
  get '/admin' do
    erb :admin
  end
  
  post '/api/ask' do
    message = params[:message]
    result = @agent.process_query_for_web(message)
    content_type :json
    result.to_json
  end
  
  get '/api/admin/pending-requests' do
    content_type :json
    {
      success: true,
      requests: $pending_tool_requests
    }.to_json
  end
  
  post '/api/admin/tool-response' do
    request.body.rewind
    data = JSON.parse(request.body.read)
    
    tool_name = data['tool_name']
    request_id = data['request_id']
    response_data = data['response']
    
    # Store the response
    $tool_responses[request_id] = response_data.to_json
    
    # Clean up the pending request
    $pending_tool_requests.delete(tool_name)
    
    content_type :json
    { success: true }.to_json
  end
  
  run! if app_file == $0
end

if __FILE__ == $0
  puts "Version: 2.0.0"
  
  if ARGV.include?('--web') || ARGV.include?('-w')
    puts "Starting web server on http://localhost:4567"
    puts "Admin panel available at http://localhost:4567/admin"
    ProduceAgentWeb.run!
  elsif ARGV.include?('--interactive') || ARGV.include?('-i')
    ClaudeAgentClient.new.run_interactive
  else
    puts "Usage:"
    puts "  ruby claude_agent_client.rb --web           # Start web server"
    puts "  ruby claude_agent_client.rb --interactive   # Interactive CLI mode"
  end
end
