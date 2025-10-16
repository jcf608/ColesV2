# Add Agent Question Feature - Integration Guide

## Overview

This feature allows you to add new user scenarios/questions to the agent system through a guided web interface. Users can configure:

1. Question type and sample queries
2. System prompt additions
3. Policy rules (text and JSON)
4. Example dialogs (few-shot learning)
5. MCP tool definitions and implementations
6. Quick action buttons for the home page

## Files Included

1. `add_agent_question.erb` - The wizard interface view
2. `app_rb_additions.rb` - Backend Ruby code to add to your app.rb
3. This README

## Installation Steps

### Step 1: Copy the View File

Copy `add_agent_question.erb` to your views directory:

```bash
cp add_agent_question.erb ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/views/
```

### Step 2: Update app.rb

Add the routes and helper methods from `app_rb_additions.rb` to your `app.rb` file.

You can either:
- Copy the entire content and paste it into your `app.rb` before the final `end`
- Or manually add the routes one by one

Key additions:
```ruby
# Add this route
get '/add_agent_question' do
  erb :add_agent_question
end

# Add this API endpoint
post '/api/save-scenario' do
  # ... (see app_rb_additions.rb for full code)
end

# Add helper methods for dynamic tool loading
def load_tool_configs
  # ...
end

def execute_dynamic_tool(tool_name, parameters)
  # ...
end

def get_mcp_tools_with_dynamic
  # ...
end
```

### Step 3: Create Required Directories

Create the directories needed for storing scenario configurations:

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai
mkdir -p app/tools
mkdir -p app/config/tools
mkdir -p scenarios
```

### Step 4: Update Navigation

Add a link to the new page in your `layout.erb` navigation:

```erb
<div class="nav-links">
  <a href="/" class="nav-link">Home</a>
  <a href="/dashboard" class="nav-link">Dashboard</a>
  <a href="/decisions" class="nav-link">Decisions</a>
  <a href="/admin" class="nav-link">🔧 Admin</a>
  <a href="/add_agent_question" class="nav-link">➕ Add Scenario</a>
</div>
```

### Step 5: Update Tool Execution

In your existing `execute_tool` method in app.rb, add a fallback to the dynamic tool loader:

```ruby
def execute_tool(tool_name, parameters)
  case tool_name
  when 'get_inventory_status'
    # ... existing code
  when 'query_sales_velocity'
    # ... existing code
  # ... other existing tools
  else
    # Try dynamic tool execution
    result = execute_dynamic_tool(tool_name, parameters)
    return result unless result[:error]
    
    # Original fallback
    { error: "Unknown tool: #{tool_name}" }
  end
end
```

### Step 6: Update Tool List

Replace your `get_mcp_tools` method with `get_mcp_tools_with_dynamic` to include dynamically loaded tools:

```ruby
# In call_claude_api method, change:
tools: get_mcp_tools

# To:
tools: get_mcp_tools_with_dynamic
```

## Usage

### Adding a New Scenario

1. Navigate to http://localhost:4567/add_agent_question
2. Follow the 6-step wizard:
   - **Step 1**: Define the question type and sample questions
   - **Step 2**: Write the system prompt addition
   - **Step 3**: Define policy rules (text and JSON)
   - **Step 4**: Create an example dialog showing proper agent behavior
   - **Step 5**: Define MCP tools needed (JSON schema + Ruby implementation)
   - **Step 6**: Configure the quick action button for the home page
3. Click "Save Configuration"
4. Restart your app to load the new configuration

### Files Created

When you save a scenario, the system creates:

```
prompts/produce-optimization-agent.txt (updated with new section)
policies/{scenario-slug}-policy.txt
policies/{scenario-slug}-policy.json
examples/{example-name}.txt
app/tools/{scenario-slug}_tools.rb
app/config/tools/{scenario-slug}.json
scenarios/{scenario-slug}.json (manifest)
app/views/index.erb (updated with quick action button)
```

### Example: Weather Impact Scenario

The wizard comes pre-populated with a sample "Weather Impact Analysis" scenario that shows:

- How to structure system prompts for decision-making
- Policy rules with both human-readable and JSON formats
- Complete tool definitions for weather forecasting
- Ruby implementation of weather-related tools
- Example agent reasoning and tool usage

## Architecture

### Wizard Flow

```
Step 1: Question Type
   ↓
Step 2: System Prompt
   ↓
Step 3: Policy Rules
   ↓
Step 4: Example Dialog
   ↓
Step 5: Tools Config
   ↓
Step 6: Quick Action
   ↓
Save → Generate Files
```

### File Organization

```
retail-agentic-ai/
├── prompts/
│   └── produce-optimization-agent.txt (main prompt + scenarios)
├── policies/
│   ├── produce-markdown-policy.txt
│   ├── produce-markdown-policy.json
│   ├── weather-impact-policy.txt
│   └── weather-impact-policy.json
├── examples/
│   ├── blueberries-markdown.txt
│   └── rain-berry-adjustment.txt
├── scenarios/
│   └── weather-impact-analysis.json (manifests)
└── app/
    ├── tools/
    │   └── weather-impact-analysis_tools.rb
    └── config/
        └── tools/
            └── weather-impact-analysis.json
```

### Dynamic Tool Loading

The system supports dynamic tool loading:

1. Tool definitions are stored as JSON in `app/config/tools/`
2. Tool implementations are in Ruby files in `app/tools/`
3. `load_tool_configs()` reads JSON definitions at runtime
4. `execute_dynamic_tool()` requires and calls the Ruby implementations
5. Tools are automatically added to the Claude API tool list

## Best Practices

### System Prompts

- Be specific about decision-making logic
- Include clear output format requirements
- Define constraints and edge cases
- Use numbered steps for complex processes

### Policy Rules

- Always provide both text and JSON versions
- Include approval thresholds and workflows
- Define safety constraints
- Document audit requirements

### Example Dialogs

- Show complete reasoning process
- Include tool calls and their results
- Demonstrate proper error handling
- Use realistic data and scenarios

### Tool Definitions

- Follow JSON Schema standards
- Include helpful descriptions
- Mark required vs optional parameters
- Provide parameter validation rules

### Tool Implementations

- Return consistent data structures
- Handle errors gracefully
- Use mock data for demo purposes
- Document data sources and assumptions

## Troubleshooting

### Tools Not Loading

Check that:
- The `app/tools/` directory exists
- Tool files end with `_tools.rb`
- Ruby syntax is valid in tool files
- Methods match expected naming patterns

### Scenario Not Appearing

Verify:
- App was restarted after saving
- Files were created in correct directories
- No JSON parsing errors in logs
- Quick action button was added to index.erb

### System Prompt Not Working

Ensure:
- System prompt file was updated
- New section added with proper formatting
- App reloaded the prompt file
- Prompt follows existing format patterns

## Advanced Features

### Scenario Versioning

Create versioned policy files:
```
policies/weather-impact-policy-v1.json
policies/weather-impact-policy-v2.json
```

### Tool Chaining

Tools can call other tools:
```ruby
def complex_analysis_tool(parameters)
  weather = get_weather_forecast(parameters)
  inventory = get_inventory_status(parameters)
  
  # Combine results
  {
    analysis: combine_data(weather, inventory)
  }
end
```

### Conditional Logic

Use policy JSON for conditional rules:
```json
{
  "rules": [
    {
      "condition": "temperature > 30",
      "action": "increase_berry_orders",
      "adjustment_pct": 20
    }
  ]
}
```

## Security Considerations

- Validate all user input before file writes
- Sanitize file names (use slugs)
- Restrict file write permissions
- Log all scenario additions
- Review generated code before deployment
- Test scenarios in staging first

## Future Enhancements

Potential improvements:
- Scenario editing interface
- Version control integration
- A/B testing framework
- Performance analytics
- Scenario templates library
- Import/export scenarios
- Collaborative editing
- Approval workflows

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review example scenarios in the wizard
3. Examine generated files for correctness
4. Test with simple scenarios first
5. Review app logs for errors

## Version History

- **v1.0** (2025-10-16): Initial release
  - 6-step wizard interface
  - Dynamic tool loading
  - Automatic file generation
  - Quick action button creation
