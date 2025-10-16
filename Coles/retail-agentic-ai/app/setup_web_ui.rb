#!/usr/bin/env ruby
# Version: 1.0.0

require 'fileutils'

puts "Version: 1.0.0"
puts "🎨 Setting up Web UI for Agentic AI System"
puts "=" * 60

app_root = File.expand_path('~/Dropbox/Valorica/Coles/retail-agentic-ai/app')

FileUtils.mkdir_p("#{app_root}/views")
FileUtils.mkdir_p("#{app_root}/public/css")
FileUtils.mkdir_p("#{app_root}/public/js")

files_to_copy = [
  ['app.rb', "#{app_root}/app.rb"],
  ['Gemfile', "#{app_root}/Gemfile"],
  ['layout.erb', "#{app_root}/views/layout.erb"],
  ['index.erb', "#{app_root}/views/index.erb"],
  ['dashboard.erb', "#{app_root}/views/dashboard.erb"],
  ['decisions.erb', "#{app_root}/views/decisions.erb"],
  ['style.css', "#{app_root}/public/css/style.css"]
]

puts "\n📁 Copying files..."
files_to_copy.each do |source, dest|
  source_path = File.expand_path("../#{source}", __FILE__)
  if File.exist?(source_path)
    FileUtils.cp(source_path, dest)
    puts "  ✓ #{source}"
  else
    puts "  ✗ #{source} not found"
  end
end

puts "\n📦 Installing gems..."
Dir.chdir(app_root) do
  system('bundle install')
end

puts "\n✨ Setup complete!"
puts "\nTo start the server:"
puts "  cd #{app_root}"
puts "  ruby app.rb"
puts "\nThen visit: http://localhost:4567"
