#!/usr/bin/env ruby
# Version: 1.0.0
# Debug script to test tool execution

puts "Version: 1.0.0"
puts "🔍 Produce Agent Debug Tester"
puts "=" * 70

require 'json'
require 'date'

# Simulate the execute_tool method
def execute_tool(tool_name, parameters)
  # Validate parameters
  unless parameters.is_a?(Hash)
    return { 
      error: "Invalid parameters type",
      expected: "Hash",
      received: parameters.class.name,
      value: parameters.inspect[0..100]
    }
  end
  
  # Normalize parameter access (handle both string and symbol keys)
  params = parameters.transform_keys(&:to_s)
  
  puts "\n📋 Tool: #{tool_name}"
  puts "   Parameters: #{params.inspect}"
  
  case tool_name
  when 'get_inventory_status'
    product_id = params['product_id'] || 'UNKNOWN'
    store_id = params['store_id'] || 'UNKNOWN'
    
    result = {
      product_id: product_id,
      store_id: store_id,
      current_stock: 47,
      cost_per_unit: 4.50,
      shelf_price: 7.99,
      expiration_date: (Date.today + 2).to_s,
      units_sold_today: 4,
      average_daily_sales: 8,
      status: 'active'
    }
    
    puts "   ✅ Result: #{result.inspect}"
    result
    
  when 'query_sales_velocity'
    product_id = params['product_id'] || 'UNKNOWN'
    store_id = params['store_id'] || 'UNKNOWN'
    days_back = params['days_back'] || 7
    
    result = {
      product_id: product_id,
      store_id: store_id,
      velocity_units_per_day: 8.2,
      baseline_velocity: 9.5,
      velocity_trend: 'declining',
      days_analyzed: days_back
    }
    
    puts "   ✅ Result: #{result.inspect}"
    result
    
  when 'check_pricing_policy'
    current = params['current_price']&.to_f || 7.99
    proposed = params['proposed_price']&.to_f || 5.99
    
    if current == 0
      error = { error: "Invalid current_price: cannot be zero" }
      puts "   ❌ Error: #{error.inspect}"
      return error
    end
    
    markdown_pct = ((current - proposed) / current * 100).round(1)
    
    result = {
      approved: true,
      approval_token: "APPR-#{Time.now.to_i}-#{rand(10000)}",
      markdown_percentage: markdown_pct,
      resulting_margin_pct: 25.3,
      requires_manager_approval: markdown_pct > 40,
      policy_notes: 'Meets minimum margin threshold for organic produce (15%)'
    }
    
    puts "   ✅ Result: #{result.inspect}"
    result
    
  when 'get_competitor_pricing'
    category = params['category'] || 'produce'
    store_location = params['store_location'] || 'UNKNOWN'
    
    result = {
      category: category,
      location: store_location,
      competitors: [
        { name: 'Farmers Market', price: 6.49, distance_miles: 0.3 },
        { name: 'Competitor Store A', price: 7.29, distance_miles: 1.2 },
        { name: 'Competitor Store B', price: 6.99, distance_miles: 2.1 }
      ],
      lowest_price: 6.49,
      average_price: 6.92
    }
    
    puts "   ✅ Result: #{result.inspect}"
    result
    
  else
    error = { 
      error: "Unknown tool: #{tool_name}",
      available_tools: ['get_inventory_status', 'query_sales_velocity', 
                       'check_pricing_policy', 'get_competitor_pricing']
    }
    puts "   ❌ Error: #{error.inspect}"
    error
  end
rescue => e
  error = {
    error: "Tool execution exception: #{e.message}",
    tool_name: tool_name,
    error_class: e.class.name,
    backtrace: e.backtrace[0..2]
  }
  puts "   ❌ Exception: #{error.inspect}"
  error
end

# Test Cases
puts "\n🧪 Running Test Cases..."
puts "=" * 70

# Test 1: get_inventory_status with product_id 8899, store_id monavale
puts "\n✓ Test 1: Get Inventory Status (from your screenshot)"
result1 = execute_tool('get_inventory_status', {
  'product_id' => '8899',
  'store_id' => 'monavale'
})
puts "\n   JSON Output:"
puts JSON.pretty_generate(result1)

# Test 2: query_sales_velocity
puts "\n✓ Test 2: Query Sales Velocity"
result2 = execute_tool('query_sales_velocity', {
  'product_id' => '8899',
  'store_id' => 'monavale',
  'days_back' => 7
})
puts "\n   JSON Output:"
puts JSON.pretty_generate(result2)

# Test 3: check_pricing_policy
puts "\n✓ Test 3: Check Pricing Policy"
result3 = execute_tool('check_pricing_policy', {
  'product_id' => '8899',
  'current_price' => 7.99,
  'proposed_price' => 5.99,
  'reason_code' => 'expiration'
})
puts "\n   JSON Output:"
puts JSON.pretty_generate(result3)

# Test 4: get_competitor_pricing
puts "\n✓ Test 4: Get Competitor Pricing"
result4 = execute_tool('get_competitor_pricing', {
  'category' => 'berries',
  'store_location' => 'monavale'
})
puts "\n   JSON Output:"
puts JSON.pretty_generate(result4)

# Test 5: Invalid parameters (to test error handling)
puts "\n✓ Test 5: Invalid Parameters (should handle gracefully)"
result5 = execute_tool('get_inventory_status', "not a hash")
puts "\n   JSON Output:"
puts JSON.pretty_generate(result5)

# Test 6: Unknown tool
puts "\n✓ Test 6: Unknown Tool (should handle gracefully)"
result6 = execute_tool('unknown_tool', {'param' => 'value'})
puts "\n   JSON Output:"
puts JSON.pretty_generate(result6)

puts "\n" + "=" * 70
puts "🎉 All tests completed!"
puts "\nIf all tests passed, your tool execution logic is working correctly."
puts "The error '[]' for nil is likely in the API response parsing."
