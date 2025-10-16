#!/usr/bin/env ruby
# Version: 1.0.0
# Installation script for Add Agent Question feature

require 'fileutils'

puts "Version: 1.0.0"
puts "\n🚀 Installing Add Agent Question Feature\n"
puts "=" * 70

# Configuration
PROJECT_ROOT = File.expand_path('~/Dropbox/Valorica/Coles/retail-agentic-ai')
APP_DIR = File.join(PROJECT_ROOT, 'app')
VIEWS_DIR = File.join(APP_DIR, 'views')
TOOLS_DIR = File.join(APP_DIR, 'tools')
CONFIG_DIR = File.join(APP_DIR, 'config', 'tools')
SCENARIOS_DIR = File.join(PROJECT_ROOT, 'scenarios')

def colorize(text, color)
  colors = {
    green: "\e[32m",
    yellow: "\e[33m",
    red: "\e[31m",
    blue: "\e[36m",
    reset: "\e[0m"
  }
  "#{colors[color]}#{text}#{colors[:reset]}"
end

def check_directory(dir, name)
  print "📁 Checking #{name}... "
  if Dir.exist?(dir)
    puts colorize("✓ Found", :green)
    true
  else
    puts colorize("✗ Missing", :red)
    false
  end
end

def create_directory(dir, name)
  print "📁 Creating #{name}... "
  begin
    FileUtils.mkdir_p(dir)
    puts colorize("✓ Created", :green)
    true
  rescue => e
    puts colorize("✗ Failed: #{e.message}", :red)
    false
  end
end

# Step 1: Check prerequisites
puts "\n#{colorize('Step 1: Checking Prerequisites', :blue)}"
puts "-" * 70

project_exists = check_directory(PROJECT_ROOT, 'Project root')
app_exists = check_directory(APP_DIR, 'App directory')
views_exists = check_directory(VIEWS_DIR, 'Views directory')

unless project_exists && app_exists && views_exists
  puts "\n#{colorize('ERROR: Required directories not found!', :red)}"
  puts "Please ensure the retail-agentic-ai project exists at:"
  puts PROJECT_ROOT
  exit 1
end

# Step 2: Create required directories
puts "\n#{colorize('Step 2: Creating Required Directories', :blue)}"
puts "-" * 70

create_directory(TOOLS_DIR, 'Tools directory')
create_directory(CONFIG_DIR, 'Config/tools directory')
create_directory(SCENARIOS_DIR, 'Scenarios directory')

# Step 3: Copy view file
puts "\n#{colorize('Step 3: Installing View File', :blue)}"
puts "-" * 70

view_source = 'add_agent_question.erb'
view_dest = File.join(VIEWS_DIR, 'add_agent_question.erb')

print "📄 Copying add_agent_question.erb... "
if File.exist?(view_source)
  FileUtils.cp(view_source, view_dest)
  puts colorize("✓ Copied", :green)
elsif File.exist?(view_dest)
  puts colorize("✓ Already exists", :yellow)
else
  puts colorize("✗ Source file not found", :red)
  puts "\n#{colorize('Please ensure add_agent_question.erb is in the current directory', :yellow)}"
end

# Step 4: Check if app.rb needs updating
puts "\n#{colorize('Step 4: Checking app.rb', :blue)}"
puts "-" * 70

app_rb_path = File.join(APP_DIR, 'app.rb')
print "📄 Checking app.rb... "

if File.exist?(app_rb_path)
  puts colorize("✓ Found", :green)
  
  content = File.read(app_rb_path)
  
  print "   Checking for /add_agent_question route... "
  if content.include?("get '/add_agent_question'")
    puts colorize("✓ Already added", :yellow)
  else
    puts colorize("✗ Needs to be added", :red)
    puts "\n#{colorize('ACTION REQUIRED:', :yellow)}"
    puts "Add the routes from app_rb_additions.rb to your app.rb file"
    puts "Location: #{app_rb_path}"
  end
  
  print "   Checking for /api/save-scenario route... "
  if content.include?("post '/api/save-scenario'")
    puts colorize("✓ Already added", :yellow)
  else
    puts colorize("✗ Needs to be added", :red)
  end
  
  print "   Checking for dynamic tool loading... "
  if content.include?("load_tool_configs")
    puts colorize("✓ Already added", :yellow)
  else
    puts colorize("✗ Needs to be added", :red)
  end
else
  puts colorize("✗ Not found", :red)
  puts "\n#{colorize('ERROR: app.rb not found!', :red)}"
  exit 1
end

# Step 5: Check layout.erb
puts "\n#{colorize('Step 5: Checking Navigation', :blue)}"
puts "-" * 70

layout_path = File.join(VIEWS_DIR, 'layout.erb')
print "📄 Checking layout.erb... "

if File.exist?(layout_path)
  puts colorize("✓ Found", :green)
  
  content = File.read(layout_path)
  
  print "   Checking for Add Scenario link... "
  if content.include?('/add_agent_question')
    puts colorize("✓ Already added", :yellow)
  else
    puts colorize("✗ Needs to be added", :red)
    puts "\n#{colorize('ACTION REQUIRED:', :yellow)}"
    puts "Add this link to your navigation in layout.erb:"
    puts '<a href="/add_agent_question" class="nav-link">➕ Add Scenario</a>'
  end
else
  puts colorize("✗ Not found", :red)
end

# Step 6: Test permissions
puts "\n#{colorize('Step 6: Testing Permissions', :blue)}"
puts "-" * 70

test_file = File.join(SCENARIOS_DIR, '.test')
print "🔐 Testing write permissions... "

begin
  File.write(test_file, 'test')
  File.delete(test_file)
  puts colorize("✓ Permissions OK", :green)
rescue => e
  puts colorize("✗ Permission denied", :red)
  puts "   #{e.message}"
end

# Summary
puts "\n" + "=" * 70
puts colorize("Installation Summary", :blue)
puts "=" * 70

puts "\n✅ Directories Created:"
puts "   - #{TOOLS_DIR}"
puts "   - #{CONFIG_DIR}"
puts "   - #{SCENARIOS_DIR}"

if File.exist?(view_dest)
  puts "\n✅ View File Installed:"
  puts "   - #{view_dest}"
end

puts "\n📋 Manual Steps Required:"
puts "   1. Add routes from app_rb_additions.rb to app.rb"
puts "   2. Add helper methods to app.rb"
puts "   3. Add navigation link to layout.erb"
puts "   4. Restart your application server"

puts "\n📚 Documentation:"
puts "   See INTEGRATION_GUIDE.md for detailed instructions"

puts "\n🎯 Next Steps:"
puts "   1. cd #{APP_DIR}"
puts "   2. Edit app.rb (add routes and helpers)"
puts "   3. Edit views/layout.erb (add navigation link)"
puts "   4. ruby app.rb (restart server)"
puts "   5. Visit http://localhost:4567/add_agent_question"

puts "\n" + "=" * 70
puts colorize("Installation Complete!", :green)
puts "=" * 70

# Create a quick reference card
quick_ref_path = File.join(PROJECT_ROOT, 'ADD_SCENARIO_QUICK_REF.md')
quick_ref = <<~QUICKREF
# Add Agent Scenario - Quick Reference

## Access
http://localhost:4567/add_agent_question

## Files Created Per Scenario
1. `prompts/produce-optimization-agent.txt` (updated)
2. `policies/{scenario-slug}-policy.txt`
3. `policies/{scenario-slug}-policy.json`
4. `examples/{example-name}.txt`
5. `app/tools/{scenario-slug}_tools.rb`
6. `app/config/tools/{scenario-slug}.json`
7. `scenarios/{scenario-slug}.json`
8. `app/views/index.erb` (updated with quick action)

## Wizard Steps
1. **Question Type**: Name, description, sample questions
2. **System Prompt**: AI decision-making instructions
3. **Policy Rules**: Business rules (text + JSON)
4. **Example Dialog**: Few-shot learning example
5. **Tools Config**: MCP tool definitions + Ruby code
6. **Quick Action**: Home page button configuration

## After Adding Scenario
1. Restart the app: `ruby app.rb`
2. Test on home page
3. Review agent responses
4. Refine configuration if needed

## Directory Structure
```
retail-agentic-ai/
├── prompts/           # System prompts
├── policies/          # Business rules
├── examples/          # Few-shot examples
├── scenarios/         # Scenario manifests
└── app/
    ├── tools/         # Tool implementations
    └── config/
        └── tools/     # Tool definitions
```

## Troubleshooting
- **Tools not working**: Check `app/tools/` directory permissions
- **Scenario not appearing**: Restart app after saving
- **Errors in console**: Check JSON syntax in policy/tools

## Support Files
- `INTEGRATION_GUIDE.md` - Full installation and usage guide
- `app_rb_additions.rb` - Code to add to app.rb
- `add_agent_question.erb` - Wizard view file
QUICKREF

File.write(quick_ref_path, quick_ref)
puts "\n📝 Quick reference created: ADD_SCENARIO_QUICK_REF.md"
