#!/usr/bin/env ruby
# Version: 1.0.1
# Startup script with health checks - FIXED for spaces in paths!

puts "🚀 Starting Produce Optimization Agent..."
puts ""

# Run health checks first - properly quote the path!
puts "Running health checks..."
health_check_path = File.expand_path('health_check.rb', __dir__)
health_check_result = system("ruby", health_check_path)

if health_check_result
  puts ""
  puts "🎉 Health checks passed! Starting server..."
  puts ""
  
  # Start the actual app
  app_path = File.expand_path('app.rb', __dir__)
  exec("ruby", app_path)
else
  puts ""
  puts "❌ Health checks failed! Please fix the issues before starting."
  exit 1
end
