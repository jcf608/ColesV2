# Add these helper methods to your app.rb

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
    policy_check: "Minimum margin: #{policy['minimum_margin_percent']}%",
    new_price: "$#{new_price.round(2)}",
    current_price: "$#{current_price}"
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
      'Woolworths' => { strawberries: '$7.99', blueberries: '$4.50' },
      'Coles' => { strawberries: '$7.50', blueberries: '$4.99' }
    },
    'salads' => {
      'Woolworths' => { caesar_salad: '$5.50' },
      'Coles' => { caesar_salad: '$5.99' }
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

# Update your /api/ask endpoint with this:
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
      input: { product_id: 'STR001', current_price: 7.99, markdown_percent: markdown },
      result: result
    }
    
    if result[:approved]
      response_text = "✅ A #{markdown}% markdown is APPROVED by policy.\n\n" +
                     "Current: #{result[:current_price]} → New: #{result[:new_price]}\n" +
                     "Projected margin: #{result[:margin]}\n" +
                     "#{result[:policy_check]}"
    else
      response_text = "❌ A #{markdown}% markdown is REJECTED by policy.\n\n" +
                     "Current: #{result[:current_price]} → New: #{result[:new_price]}\n" +
                     "Projected margin: #{result[:margin]} (below minimum)\n" +
                     "#{result[:policy_check]}"
    end
    
  elsif message.downcase.include?('inventory')
    result = check_inventory('STR001')
    
    tool_calls << {
      name: 'check_inventory',
      input: { product_id: 'STR001' },
      result: result
    }
    
    response_text = "📦 Inventory Status:\n\n" +
                   "Product: #{result[:name]}\n" +
                   "Quantity: #{result[:quantity]} units\n" +
                   "Expiration: #{result[:expiration]}\n" +
                   "Sales velocity: #{result[:velocity]}"
    
  elsif message.downcase.include?('competitor')
    result = check_competitor_pricing('berries')
    
    tool_calls << {
      name: 'check_competitor_pricing',
      input: { category: 'berries' },
      result: result
    }
    
    pricing_details = result.map { |store, prices| 
      "#{store}: " + prices.map { |item, price| "#{item} #{price}" }.join(", ")
    }.join("\n")
    
    response_text = "💰 Competitor Pricing for Berries:\n\n#{pricing_details}"
    
  else
    response_text = "🤔 I can help you with:\n\n" +
                   "• Checking pricing policy compliance (try: 'Check pricing policy for 30% markdown')\n" +
                   "• Looking up inventory status (try: 'What's the inventory status?')\n" +
                   "• Comparing competitor prices (try: 'What are competitor prices for berries?')"
  end
  
  {
    success: true,
    response: response_text,
    tool_calls: tool_calls
  }.to_json
end
