# Add Agent Question Feature - Complete Package

## Overview

This package contains everything you need to add a **step-by-step wizard interface** for creating new agent scenarios/questions in your Produce Optimization Agent system.

## What This Does

Users can now add new types of questions the agent can answer through a guided web interface. Each scenario includes:

1. **System Prompt** - Instructions for the AI on how to handle this question type
2. **Policy Rules** - Business rules and constraints (both human-readable and machine-executable)
3. **Example Dialog** - Few-shot learning examples showing proper agent behavior
4. **MCP Tools** - New API integrations for data access
5. **Quick Action Button** - One-click access from the home page

## Package Contents

### Core Files (Required)

1. **add_agent_question.erb** (8.5KB)
   - The 6-step wizard interface
   - Pre-filled with sample "Weather Impact Analysis" scenario
   - Live preview and validation
   - Location: Copy to `app/views/`

2. **app_rb_additions.rb** (6.2KB)
   - Backend routes and API endpoints
   - Dynamic tool loading system
   - File writing and configuration management
   - Location: Add code to your `app/app.rb`

3. **INTEGRATION_GUIDE.md** (4.8KB)
   - Complete installation instructions
   - Usage guide with examples
   - Best practices and troubleshooting
   - Architecture documentation

### Helper Files (Optional but Recommended)

4. **install_add_scenario.rb** (3.5KB)
   - Automated installation script
   - Checks prerequisites
   - Creates required directories
   - Validates setup
   - Usage: `ruby install_add_scenario.rb`

5. **test_scenario.json** (3.2KB)
   - Complete example scenario: "Quality Degradation Alert"
   - Can be used to test the system
   - Shows proper JSON structure for all components

6. **This README** - You're reading it!

## Quick Start (5 Minutes)

### Option A: Automated Installation (Recommended)

```bash
# 1. Make the script executable
chmod +x install_add_scenario.rb

# 2. Run the installer
ruby install_add_scenario.rb

# 3. Follow the on-screen instructions
```

### Option B: Manual Installation

```bash
# 1. Copy the view file
cp add_agent_question.erb ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/views/

# 2. Add routes to app.rb (see app_rb_additions.rb)

# 3. Add navigation link to layout.erb

# 4. Restart your app
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app
ruby app.rb

# 5. Visit the page
open http://localhost:4567/add_agent_question
```

## The 6-Step Wizard

### Step 1: Question Type
- Name your scenario
- Describe what it does
- Provide sample questions users might ask

**Example:** "Weather Impact Analysis" - Analyzes how weather affects produce sales

### Step 2: System Prompt
- Write AI instructions for decision-making
- Define the reasoning framework
- Specify output format requirements

**Pre-filled with:** Complete weather analysis decision framework

### Step 3: Policy Rules
- Define business rules (human-readable text)
- Create machine-executable rules (JSON)
- Set approval thresholds and constraints

**Pre-filled with:** Weather-based inventory adjustment policies

### Step 4: Example Dialog
- Show complete agent reasoning
- Include tool calls and results
- Demonstrate proper format

**Pre-filled with:** Rain forecast berry adjustment example

### Step 5: Tools Config
- Define new MCP tools (JSON schema)
- Write Ruby implementation
- Specify parameters and return values

**Pre-filled with:** Weather forecast and delivery adjustment tools

### Step 6: Quick Action
- Choose an emoji icon
- Write button label
- Set default question

**Pre-filled with:** 🌧️ "Weather Impact" button

## What Gets Created

When you save a scenario, the system generates:

```
prompts/
  └── produce-optimization-agent.txt (UPDATED with new section)

policies/
  ├── {scenario-slug}-policy.txt
  └── {scenario-slug}-policy.json

examples/
  └── {example-name}.txt

scenarios/
  └── {scenario-slug}.json (manifest file)

app/
  ├── views/
  │   └── index.erb (UPDATED with quick action button)
  ├── tools/
  │   └── {scenario-slug}_tools.rb
  └── config/
      └── tools/
          └── {scenario-slug}.json
```

## Sample Scenarios Included

### 1. Weather Impact Analysis (Pre-filled in wizard)
- Analyzes weather effects on produce sales
- Recommends inventory adjustments
- Tools: Weather forecast, delivery schedule updates

### 2. Quality Degradation Alert (test_scenario.json)
- Monitors produce quality indicators
- Alerts when items need attention
- Tools: Quality inspections, temperature logs, shrinkage calculations

## Key Features

### Dynamic Tool Loading
- Tools are loaded from `app/config/tools/*.json` at runtime
- Implementations in `app/tools/*_tools.rb` are auto-required
- No need to modify core app.rb for new tools

### Automatic Integration
- System prompts updated automatically
- Quick action buttons added to home page
- Policies integrated with existing policy engine
- Examples added to few-shot library

### Validation & Safety
- JSON syntax validation
- File name sanitization
- Permission checks before writing
- Manifest files for tracking changes

### User-Friendly Interface
- Step-by-step wizard with progress indicator
- Sample content pre-filled in every field
- Live preview of quick action buttons
- Clear success/error messages

## Architecture

```
User Input (Wizard)
        ↓
Save Configuration API
        ↓
File Generation
   ├── System Prompt (append)
   ├── Policy Files (create)
   ├── Example Files (create)
   ├── Tool Files (create)
   ├── Config Files (create)
   └── Manifest (create)
        ↓
Dynamic Loading
   ├── load_tool_configs()
   ├── execute_dynamic_tool()
   └── get_mcp_tools_with_dynamic()
        ↓
Agent Runtime
   ├── Enhanced system prompt
   ├── Policy enforcement
   ├── Tool execution
   └── Example-guided responses
```

## Best Practices

### System Prompts
✅ **Do:**
- Be specific about decision logic
- Include numbered steps for clarity
- Define output format requirements
- Specify edge cases and constraints

❌ **Don't:**
- Duplicate existing agent capabilities
- Write vague or ambiguous instructions
- Forget to specify decision criteria

### Policy Rules
✅ **Do:**
- Provide both text and JSON versions
- Include approval workflows
- Define numeric thresholds
- Document audit requirements

❌ **Don't:**
- Create policies that conflict with existing rules
- Forget minimum/maximum constraints
- Skip safety checks

### Example Dialogs
✅ **Do:**
- Show complete reasoning chain
- Include all tool calls
- Use realistic data
- Demonstrate error handling

❌ **Don't:**
- Skip intermediate reasoning steps
- Use unrealistic scenarios
- Omit tool call details

### Tools
✅ **Do:**
- Follow JSON Schema standards
- Validate all parameters
- Return consistent structures
- Handle errors gracefully

❌ **Don't:**
- Make breaking API changes
- Return inconsistent data types
- Skip error handling

## Troubleshooting

### Wizard won't load
- Check that add_agent_question.erb is in app/views/
- Verify the route exists in app.rb
- Check server logs for errors
- Ensure layout.erb has correct navigation

### Save fails
- Check directory permissions
- Verify JSON syntax in policy/tools
- Check server logs for detailed errors
- Ensure no duplicate scenario names

### Tools don't work
- Verify tools directory exists (app/tools/)
- Check Ruby syntax in tool files
- Ensure method names match conventions
- Look for require errors in logs

### Agent doesn't use new scenario
- Restart the application server
- Check that system prompt was updated
- Verify tool definitions are valid JSON
- Test with the quick action button

## Security Notes

- All file names are sanitized (lowercase, hyphens only)
- Directory traversal attacks prevented
- File permissions checked before writing
- All actions logged to scenario manifest
- User input validated before processing

## Testing

### Test the Wizard Interface
1. Navigate to `/add_agent_question`
2. Review pre-filled sample scenario
3. Click through all 6 steps
4. Verify preview in Step 6
5. Don't save (just test navigation)

### Test Scenario Creation
1. Load test_scenario.json content
2. Copy/paste into wizard fields
3. Save configuration
4. Verify all files created
5. Restart app and test

### Test Agent Behavior
1. Use new quick action button
2. Ask sample questions
3. Verify tool calls executed
4. Check agent reasoning
5. Confirm policy compliance

## Version History

### v1.0.0 (2025-10-16)
- Initial release
- 6-step wizard interface
- Dynamic tool loading
- Automatic file generation
- Weather Impact sample scenario
- Quality Alert test scenario

## Support & Next Steps

### Immediate Actions
1. Run install_add_scenario.rb
2. Review INTEGRATION_GUIDE.md
3. Test with the Weather Impact scenario
4. Try creating the Quality Alert scenario
5. Create your first custom scenario

### Future Enhancements
- Scenario editing interface
- Version control integration
- Scenario templates library
- Import/export functionality
- A/B testing framework
- Performance analytics

### Getting Help
1. Check INTEGRATION_GUIDE.md troubleshooting
2. Review example scenarios
3. Examine generated files
4. Check server logs
5. Test with simple scenarios first

## File Checksums

For verification:

- add_agent_question.erb: ~350 lines, 8.5KB
- app_rb_additions.rb: ~280 lines, 6.2KB
- INTEGRATION_GUIDE.md: ~420 lines, 4.8KB
- install_add_scenario.rb: ~250 lines, 3.5KB
- test_scenario.json: ~195 lines, 3.2KB

## License & Credits

Created for the Retail Agentic AI System
Produce Optimization Agent
Kyndryl × Coles Partnership

---

**Ready to get started?**

```bash
# Quick start command sequence
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai
ruby install_add_scenario.rb
# Follow the prompts, then visit http://localhost:4567/add_agent_question
```

**Questions?** Review the INTEGRATION_GUIDE.md for detailed instructions.
