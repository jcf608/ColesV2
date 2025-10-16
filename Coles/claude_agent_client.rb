#!/usr/bin/env ruby
# Version: 1.0.1

require 'json'
require 'net/http'
require 'uri'
require 'open3'
require 'date'

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

  def run_example_queries
    puts colorize("🤖 Running Example Queries", :primary)
    puts colorize("=" * 60, :primary)
    
    example_queries = [
      "Should we mark down organic strawberries today? We have 47 units in stock, cost is $4.50 per unit, current shelf price is $7.99, and they expire in 2 days.",
      "What's the current inventory status for product BLU-ORG-6OZ at store STORE-001?",
      "Check if we can markdown a product from $7.99 to $5.99 due to expiration."
    ]
    
    example_queries.each_with_index do |query, index|
      puts colorize("\n\n📝 Example #{index + 1}:", :primary)
      puts colorize("Query: #{query}", :warning)
      puts colorize("-" * 60, :primary)
      
      process_query(query)
      
      sleep(2) if index < example_queries.length - 1
    end
    
    puts colorize("\n\n✨ Example queries complete!", :success)
    puts colorize("\nTo run interactively, use: ruby claude_agent_client.rb --interactive", :primary)
  end

  private

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
    unless File.exist?(@mcp_server_path)
      puts colorize("❌ Error: MCP server not found at #{@mcp_server_path}", :error)
      puts colorize("\nRun the deployment script first:", :warning)
      puts colorize("  ruby deploy_mcp_server.rb", :warning)
      exit 1
    end
    
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
    puts colorize("   Note: MCP tools require backend APIs. Returning mock data for demo.", :warning)
    
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

  def colorize(text, color)
    "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end
end

if __FILE__ == $0
  puts "Version: 1.0.1"
  
  if ARGV.include?('--interactive') || ARGV.include?('-i')
    ClaudeAgentClient.new.run_interactive
  else
    ClaudeAgentClient.new.run_example_queries
  end
end
