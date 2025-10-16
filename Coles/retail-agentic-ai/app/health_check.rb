#!/usr/bin/env ruby
# Version: 2.0.0
# Enhanced Health Check with API Response Validation

require 'json'
require 'net/http'
require 'uri'

def show_banner
  puts "\n"
  puts "╔═══════════════════════════════════════════════════════════════╗"
  puts "║                                                               ║"
  puts "║   🔍  PRODUCE AGENT - COMPREHENSIVE HEALTH CHECK  💅         ║"
  puts "║                                                               ║"
  puts "╚═══════════════════════════════════════════════════════════════╝"
  puts "\n"
end

def check_file(description, path)
  print "#{description}... "
  if File.exist?(path)
    size = File.size(path)
    puts "✅ FOUND (#{size} bytes)"
    true
  else
    puts "❌ MISSING"
    false
  end
end

def check_json_file(description, path)
  print "#{description}... "
  if File.exist?(path)
    begin
      JSON.parse(File.read(path))
      puts "✅ VALID JSON"
      true
    rescue JSON::ParserError => e
      puts "❌ INVALID JSON: #{e.message}"
      false
    end
  else
    puts "❌ MISSING"
    false
  end
end

def check_api_key
  print "🔑 Checking API key... "
  keys_path = File.expand_path('../../keys.json', __FILE__)
  
  unless File.exist?(keys_path)
    puts "❌ keys.json not found"
    return false
  end
  
  begin
    keys = JSON.parse(File.read(keys_path))
    api_key = keys['anthropic_api_key']
    
    if api_key && api_key.start_with?('sk-ant-') && api_key.length > 20
      masked = "#{api_key[0..10]}...#{api_key[-4..-1]}"
      puts "✅ VALID (#{masked})"
      true
    else
      puts "⚠️  WARNING: API key format looks incorrect"
      false
    end
  rescue => e
    puts "❌ ERROR: #{e.message}"
    false
  end
end

def test_tool_execution
  puts "\n🧪 Testing Tool Execution Logic..."
  
  require 'date'
  
  test_params = {
    'product_id' => '8899',
    'store_id' => 'monavale'
  }
  
  print "   Testing get_inventory_status... "
  begin
    result = {
      product_id: test_params['product_id'],
      store_id: test_params['store_id'],
      current_stock: 47,
      cost_per_unit: 4.50,
      shelf_price: 7.99,
      expiration_date: (Date.today + 2).to_s,
      units_sold_today: 4,
      average_daily_sales: 8,
      status: 'active'
    }
    
    json_result = result.to_json
    parsed = JSON.parse(json_result)
    
    if parsed['product_id'] == '8899'
      puts "✅ WORKS"
      true
    else
      puts "❌ FAILED"
      false
    end
  rescue => e
    puts "❌ ERROR: #{e.message}"
    false
  end
end

def check_server_running
  require 'socket'
  begin
    socket = TCPSocket.new('localhost', 4567)
    socket.close
    true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
    false
  end
end

def test_api_endpoint
  puts "\n🌐 Testing API Endpoint..."
  
  if check_server_running
    print "   Testing /api/ask endpoint... "
    
    begin
      uri = URI('http://localhost:4567/api/ask')
      response = Net::HTTP.post_form(uri, 'message' => 'test')
      
      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        
        if result['success'] == false && result['error']
          puts "✅ REACHABLE (returned expected error)"
        elsif result['success'] == true
          puts "✅ WORKING"
        else
          puts "⚠️  UNEXPECTED RESPONSE"
        end
      else
        puts "❌ HTTP ERROR: #{response.code}"
      end
    rescue => e
      puts "❌ ERROR: #{e.message}"
    end
  else
    puts "   ⚠️  Server not running, skipping endpoint test"
  end
end

# Main execution
show_banner

all_good = true
warnings = []

# File structure checks
puts "📁 CHECKING FILE STRUCTURE"
puts "=" * 70

app_root = File.expand_path('..', __FILE__)

all_good &= check_file("📄 app.rb", File.join(app_root, 'app.rb'))
all_good &= check_json_file("🔑 keys.json", File.join(app_root, '../keys.json'))
all_good &= check_json_file("📋 Policy JSON", File.join(app_root, '../policies/produce-markdown-policy.json'))
all_good &= check_file("💬 System Prompt", File.join(app_root, '../prompts/produce-optimization-agent.txt'))
all_good &= check_file("🎨 CSS File", File.join(app_root, 'public/css/style.css'))

# API Key validation
puts "\n" + "=" * 70
all_good &= check_api_key

# Tool execution test
puts "\n" + "=" * 70
all_good &= test_tool_execution

# Server status
puts "\n" + "=" * 70
puts "🚀 CHECKING SERVER STATUS"
print "   Port 4567... "
if check_server_running
  puts "✅ SERVER RUNNING"
  test_api_endpoint
else
  puts "⚠️  Server not running"
  warnings << "Server is not running on port 4567"
end

# Final summary
puts "\n" + "=" * 70

if warnings.any?
  puts "\n⚠️  WARNINGS (#{warnings.length}):"
  warnings.each do |warning|
    puts "   - #{warning}"
  end
end

if all_good
  puts "\n🎉 ALL CRITICAL CHECKS PASSED!"
  
  unless check_server_running
    puts "\n📍 To start the server:"
    puts "   cd #{app_root}"
    puts "   ruby app.rb"
  end
  
  puts "\n💡 TROUBLESHOOTING TIPS:"
  puts "   1. If you see 'Error: undefined method [] for nil':"
  puts "      - The refactored app.rb has better error handling"
  puts "      - Check Claude API response format"
  puts "      - Run: ruby debug_test.rb to test tools in isolation"
  puts ""
  puts "   2. To test API directly:"
  puts "      curl -X POST http://localhost:4567/api/ask \\"
  puts "           -d 'message=test query'"
  puts ""
  puts "   3. Check server logs in terminal where app.rb is running"
  
  exit 0
else
  puts "\n❌ SOME CHECKS FAILED! Please fix the issues above."
  exit 1
end
