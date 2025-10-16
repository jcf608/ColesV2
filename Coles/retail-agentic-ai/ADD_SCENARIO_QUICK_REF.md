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
