# Add Agent Question - Architecture & Data Flow

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  /add_agent_question (Wizard Interface)                   │  │
│  │                                                           │  │
│  │  Step 1: Question Type                                   │  │
│  │  Step 2: System Prompt                                   │  │
│  │  Step 3: Policy Rules                                    │  │
│  │  Step 4: Example Dialog                                  │  │
│  │  Step 5: Tools Config                                    │  │
│  │  Step 6: Quick Action                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            │ HTTP POST                          │
│                            ▼                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     BACKEND PROCESSING                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  POST /api/save-scenario                                 │  │
│  │                                                           │  │
│  │  1. Validate JSON syntax                                 │  │
│  │  2. Sanitize file names                                  │  │
│  │  3. Generate scenario slug                               │  │
│  │  4. Write configuration files                            │  │
│  │  5. Update system files                                  │  │
│  │  6. Create manifest                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
                             │ File I/O
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FILE SYSTEM CHANGES                        │
│                                                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │ prompts/             │  │ policies/            │           │
│  │  └─ agent.txt        │  │  ├─ scenario.txt    │           │
│  │     (append new      │  │  └─ scenario.json   │           │
│  │      section)        │  └──────────────────────┘           │
│  └──────────────────────┘                                      │
│                                                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │ examples/            │  │ scenarios/           │           │
│  │  └─ example.txt      │  │  └─ manifest.json   │           │
│  └──────────────────────┘  └──────────────────────┘           │
│                                                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │ app/tools/           │  │ app/config/tools/    │           │
│  │  └─ scenario_tools.rb│  │  └─ scenario.json   │           │
│  └──────────────────────┘  └──────────────────────┘           │
│                                                                 │
│  ┌──────────────────────┐                                      │
│  │ app/views/           │                                      │
│  │  └─ index.erb        │                                      │
│  │     (add quick       │                                      │
│  │      action button)  │                                      │
│  └──────────────────────┘                                      │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
                             │ App Restart
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       RUNTIME LOADING                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Application Initialization                              │  │
│  │                                                           │  │
│  │  1. Load system prompt (with new section)               │  │
│  │  2. Load policies (all .json files)                     │  │
│  │  3. Load tool configs (app/config/tools/*.json)         │  │
│  │  4. Require tool implementations (app/tools/*_tools.rb) │  │
│  │  5. Build combined tool list                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
                             │ Runtime Ready
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT RUNTIME                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  User asks question via home page or quick action        │  │
│  │                                                           │  │
│  │  1. Claude AI receives request with:                    │  │
│  │     - Enhanced system prompt                             │  │
│  │     - All available tools (base + dynamic)              │  │
│  │     - Policy context                                     │  │
│  │                                                           │  │
│  │  2. Agent reasons about question                         │  │
│  │     - Matches to scenario type                           │  │
│  │     - References policy rules                            │  │
│  │     - Recalls example dialogs                            │  │
│  │                                                           │  │
│  │  3. Agent calls appropriate tools                        │  │
│  │     - execute_tool() dispatches to:                      │  │
│  │       • Base tools (hardcoded)                           │  │
│  │       • Dynamic tools (loaded from files)                │  │
│  │                                                           │  │
│  │  4. Agent constructs response                            │  │
│  │     - Follows prompt format                              │  │
│  │     - Cites policy compliance                            │  │
│  │     - Provides actionable recommendations                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
                             ▼
                      Response to User
```

## Data Flow Sequence

### 1. Scenario Creation Flow

```
User fills wizard
       ↓
Clicks "Save"
       ↓
JavaScript collects all field values
       ↓
POST /api/save-scenario {json data}
       ↓
Sinatra receives request
       ↓
Parse and validate JSON
       ↓
Generate scenario slug from name
       ↓
┌───────────────────────────────┐
│ Write Files in Order:         │
│                               │
│ 1. System prompt (append)     │
│ 2. Policy text file           │
│ 3. Policy JSON file           │
│ 4. Example dialog file        │
│ 5. Tool implementation (.rb)  │
│ 6. Tool configuration (.json) │
│ 7. Update index.erb           │
│ 8. Scenario manifest          │
└───────────────────────────────┘
       ↓
Return success + file list
       ↓
Show success page with files created
```

### 2. Tool Execution Flow

```
User asks question
       ↓
Claude receives message + tools list
       ↓
Claude decides to use tool "get_weather_forecast"
       ↓
POST /api/ask with tool call
       ↓
Sinatra's execute_tool() called
       ↓
Is it a base tool?
  ├─ Yes → Execute hardcoded tool
  └─ No → execute_dynamic_tool()
              ↓
       Load tools/*.rb files
              ↓
       Find matching method
              ↓
       Call method with params
              ↓
       Return result
       ↓
Return to Claude
       ↓
Claude uses result in reasoning
       ↓
Claude generates response
       ↓
Response shown to user
```

### 3. Dynamic Tool Loading Flow

```
App starts
       ↓
load_tool_configs() called
       ↓
Scan app/config/tools/*.json
       ┌────────────────────┐
       │ For each file:     │
       │ 1. Read JSON       │
       │ 2. Parse array     │
       │ 3. Validate schema │
       │ 4. Add to list     │
       └────────────────────┘
       ↓
get_mcp_tools_with_dynamic() called
       ↓
Combine base_tools + dynamic_tools
       ↓
Return unified tool list to Claude
```

## Component Interaction Matrix

```
┌─────────────────┬─────────────────────────────────────────────┐
│ Component       │ Interacts With                              │
├─────────────────┼─────────────────────────────────────────────┤
│ Wizard UI       │ • app.rb (POST /api/save-scenario)         │
│                 │ • Browser localStorage (form state)         │
│                 │ • CSS styles (presentation)                 │
├─────────────────┼─────────────────────────────────────────────┤
│ app.rb          │ • File system (read/write)                  │
│                 │ • Claude API (send messages)                │
│                 │ • Tool files (require .rb)                  │
│                 │ • Config files (load JSON)                  │
│                 │ • View files (ERB rendering)                │
├─────────────────┼─────────────────────────────────────────────┤
│ System Prompt   │ • Claude API (system context)               │
│                 │ • Policy files (referenced in prompt)       │
│                 │ • Example files (few-shot learning)         │
├─────────────────┼─────────────────────────────────────────────┤
│ Policy Files    │ • Tool validation (check_pricing_policy)    │
│                 │ • Agent reasoning (decision constraints)    │
│                 │ • Audit logging (compliance tracking)       │
├─────────────────┼─────────────────────────────────────────────┤
│ Tool Configs    │ • Claude API (tool definitions)             │
│                 │ • Tool implementations (schema validation)  │
│                 │ • Agent reasoning (available actions)       │
├─────────────────┼─────────────────────────────────────────────┤
│ Tool Impls      │ • app.rb (execute_dynamic_tool)            │
│                 │ • External APIs (data sources)              │
│                 │ • Database (persistence)                    │
├─────────────────┼─────────────────────────────────────────────┤
│ Example Files   │ • System prompt (few-shot examples)         │
│                 │ • Testing (validation scenarios)            │
│                 │ • Documentation (usage patterns)            │
├─────────────────┼─────────────────────────────────────────────┤
│ Manifest Files  │ • Version control (change tracking)         │
│                 │ • Auditing (configuration history)          │
│                 │ • Documentation (scenario metadata)         │
└─────────────────┴─────────────────────────────────────────────┘
```

## Directory Structure Tree

```
retail-agentic-ai/
│
├── app/
│   ├── app.rb ◄─────────────── Main application
│   ├── views/
│   │   ├── layout.erb ◄──────── Page template
│   │   ├── index.erb ◄───────── Home (quick actions added here)
│   │   └── add_agent_question.erb ◄── Wizard interface
│   │
│   ├── tools/ ◄───────────────── Dynamic tool implementations
│   │   ├── weather-impact-analysis_tools.rb
│   │   └── quality-degradation_tools.rb
│   │
│   └── config/
│       └── tools/ ◄────────────── Dynamic tool definitions
│           ├── weather-impact-analysis.json
│           └── quality-degradation.json
│
├── prompts/
│   └── produce-optimization-agent.txt ◄── System prompt (appended)
│
├── policies/
│   ├── produce-markdown-policy.txt
│   ├── produce-markdown-policy.json
│   ├── weather-impact-analysis-policy.txt ◄── Added scenarios
│   └── weather-impact-analysis-policy.json
│
├── examples/
│   ├── blueberries-markdown.txt
│   └── rain-berry-adjustment.txt ◄── Added examples
│
└── scenarios/ ◄───────────────── Scenario manifests
    ├── weather-impact-analysis.json
    └── quality-degradation.json
```

## Key Design Decisions

### 1. File-Based Configuration
**Why:** Simple, version-controllable, no database needed
**Trade-off:** Requires app restart to load changes

### 2. Slug-Based Naming
**Why:** Consistent, filesystem-safe, predictable
**Example:** "Weather Impact" → "weather-impact-analysis"

### 3. Append-Only System Prompt
**Why:** Preserve base functionality, non-destructive
**Trade-off:** File grows over time (manageable with structure)

### 4. Dynamic Tool Loading
**Why:** No code changes needed for new tools
**Trade-off:** Slight performance overhead (negligible)

### 5. Dual Policy Format (TXT + JSON)
**Why:** Human-readable + machine-executable
**Trade-off:** Must keep both in sync

### 6. Manifest Files
**Why:** Track metadata, versioning, dependencies
**Trade-off:** Additional files to maintain

## Security Model

```
User Input → Validation → Sanitization → File Write
    ↓            ↓             ↓             ↓
  Wizard    JSON parse    Slug gen      Check perms
             Schema val   Lowercase      Write audit
             Length check  Alphanumeric  Manifest log
```

## Performance Characteristics

- **Wizard Load:** < 100ms (static HTML + CSS)
- **Save Operation:** 200-500ms (7-8 file writes)
- **Dynamic Tool Load:** < 50ms per tool (startup only)
- **Tool Execution:** Depends on implementation
- **System Prompt Reload:** On app restart only

## Scalability Considerations

- **Scenarios:** 50-100 before prompt becomes unwieldy
- **Tools per Scenario:** 2-10 recommended
- **Tools Total:** 100+ supported
- **File System:** Standard filesystem limits apply

## Error Handling Strategy

```
┌────────────────────────────┐
│ Error Detection            │
├────────────────────────────┤
│ • JSON syntax validation   │
│ • File permission checks   │
│ • Duplicate name detection │
│ • Schema compliance        │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│ Error Response             │
├────────────────────────────┤
│ • HTTP 400 for user errors │
│ • HTTP 500 for system errors│
│ • Detailed error messages  │
│ • No partial writes        │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│ Error Recovery             │
├────────────────────────────┤
│ • Rollback on failure      │
│ • Preserve existing files  │
│ • Log to manifest          │
│ • User-friendly guidance   │
└────────────────────────────┘
```

---

**This architecture ensures:**
- Clean separation of concerns
- Easy extensibility
- Minimal code changes
- Version-controllable configuration
- Graceful degradation
- Audit trail for compliance
