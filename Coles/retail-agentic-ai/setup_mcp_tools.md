# Setting Up MCP Tools for Your Produce Agent 🛠️

## What You Need to Do:

### 1. Make sure your MCP server is running
```bash
cd mcp-server
npm install
npm run build
npm start
```

### 2. Update your app.rb to connect to MCP tools

Your Sinatra app needs to call the MCP server. Here's what you need:

```ruby
require 'sinatra'
require 'json'
require 'net/http'
require 'uri'

# MCP Server configuration
MCP_SERVER_URL = 'http://localhost:3000'  # or whatever port your MCP server uses

# Helper to call MCP tools
def call_mcp_tool(tool_name, params = {})
  uri = URI("#{MCP_SERVER_URL}/tools/#{tool_name}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = params.to_json
  
  response = http.request(request)
  JSON.parse(response.body)
rescue => e
  { error: e.message }
end

# Tool: Check Policy
def check_policy(product_id, current_price, markdown_percent, reason)
  policy_path = File.join(__dir__, '../policies/produce-markdown-policy.json')
  policy = JSON.parse(File.read(policy_path))
  
  # Calculate new price
  new_price = current_price * (1 - markdown_percent / 100.0)
  margin = ((new_price - cost_estimate(product_id)) / new_price * 100).round(2)
  
  # Check against policy rules
  result = {
    approved: margin >= policy['minimum_margin_percent'],
    reason: reason,
    margin: "#{margin}%",
    policy_check: "Minimum margin: #{policy['minimum_margin_percent']}%"
  }
  
  result
end

# Tool: Check Inventory
def check_inventory(product_id)
  # Simulate inventory check - replace with real database
  inventory = {
    'STR001' => { name: 'Organic Strawberries', quantity: 24, expiration: '2 days', velocity: 'slow' },
    'BLUE001' => { name: 'Blueberries', quantity: 45, expiration: '4 days', velocity: 'fast' },
    'SAL001' => { name: 'Caesar Salad Kit', quantity: 18, expiration: '3 days', velocity: 'healthy' }
  }
  
  inventory[product_id] || { error: 'Product not found' }
end

# Tool: Check Competitor Pricing
def check_competitor_pricing(category)
  # Simulate competitor data - replace with real API
  competitors = {
    'berries' => {
      'Woolworths' => { strawberries: 7.99, blueberries: 4.50 },
      'Coles' => { strawberries: 7.50, blueberries: 4.99 }
    }
  }
  
  competitors[category] || { error: 'Category not found' }
end

# Estimate cost (simplified)
def cost_estimate(product_id)
  costs = {
    'STR001' => 4.50,
    'BLUE001' => 2.00,
    'SAL001' => 1.80
  }
  costs[product_id] || 2.00
end
```

### 3. Update your /api/ask endpoint

```ruby
post '/api/ask' do
  content_type :json
  
  message = params[:message]
  
  # Simple tool routing based on keywords
  tool_calls = []
  response_text = ""
  
  if message.downcase.include?('policy')
    # Extract markdown percentage if mentioned
    markdown = message[/(\d+)%/, 1]&.to_i || 30
    
    result = check_policy('STR001', 7.99, markdown, 'expiration approaching')
    
    tool_calls << {
      name: 'check_policy',
      input: { markdown_percent: markdown },
      result: result
    }
    
    if result[:approved]
      response_text = "✅ A #{markdown}% markdown is APPROVED by policy. The margin would be #{result[:margin]}, which meets the minimum requirement."
    else
      response_text = "❌ A #{markdown}% markdown is REJECTED by policy. The margin of #{result[:margin]} is below the minimum requirement."
    end
    
  elsif message.downcase.include?('inventory')
    result = check_inventory('STR001')
    
    tool_calls << {
      name: 'check_inventory',
      input: { product_id: 'STR001' },
      result: result
    }
    
    response_text = "📦 #{result[:name]}: #{result[:quantity]} units in stock, expires in #{result[:expiration]}, #{result[:velocity]} velocity"
    
  elsif message.downcase.include?('competitor')
    result = check_competitor_pricing('berries')
    
    tool_calls << {
      name: 'check_competitor_pricing',
      input: { category: 'berries' },
      result: result
    }
    
    response_text = "💰 Competitor pricing for berries:\n" + 
                   result.map { |store, prices| "#{store}: #{prices.inspect}" }.join("\n")
  else
    response_text = "I can help you with:\n" +
                   "• Checking pricing policy compliance\n" +
                   "• Looking up inventory status\n" +
                   "• Comparing competitor prices"
  end
  
  {
    success: true,
    response: response_text,
    tool_calls: tool_calls
  }.to_json
end
```

### 4. Test it!

Restart your Sinatra app:
```bash
cd app
ruby app.rb
```

Now when you ask "Check pricing policy for 30% markdown", it should:
1. Load the policy from `/policies/produce-markdown-policy.json`
2. Calculate margins
3. Return approval/rejection based on policy rules
4. Show the tool call in the UI

## Next Steps:

1. ✅ Get basic tools working (policy, inventory, competitor)
2. 🔄 Connect to real database for inventory
3. 🌐 Connect to real competitor pricing APIs
4. 🤖 Add Claude AI integration for natural language understanding
5. 📊 Add more sophisticated decision logic

