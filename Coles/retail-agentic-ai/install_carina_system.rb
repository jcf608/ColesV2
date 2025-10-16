#!/usr/bin/env ruby
# install_carina_system.rb
# Complete installation script for Carina multi-mode agentic AI system

require 'fileutils'
require 'json'
require 'open3'

puts "Version: 1.0.0"

class CarinaInstaller
  COLORS = {
    primary: "\e[36m",
    success: "\e[32m",
    warning: "\e[33m",
    error: "\e[31m",
    info: "\e[34m",
    reset: "\e[0m"
  }

  def initialize
    @project_root = Dir.pwd
    @prompts_dir = File.join(@project_root, 'prompts')
    @policies_dir = File.join(@project_root, 'policies')
    @examples_dir = File.join(@project_root, 'examples')
    @mcp_server_dir = File.join(@project_root, 'mcp-server')
    @ui_dir = File.join(@project_root, 'ui')
    @app_dir = File.join(@project_root, 'app')
    @db_dir = File.join(@project_root, 'db')
    @config_dir = File.join(@project_root, 'config')
    @services_dir = File.join(@app_dir, 'services')
    @docs_dir = File.join(@project_root, 'docs')
  end

  def install
    puts colorize("=" * 70, :primary)
    puts colorize("  CARINA MULTI-MODE AGENTIC AI SYSTEM INSTALLER", :primary)
    puts colorize("=" * 70, :primary)
    puts ""

    create_directory_structure
    install_prompts
    install_policies
    install_examples
    install_mcp_tools
    install_ui_components
    install_backend_services
    install_database_schema
    install_configuration
    generate_documentation
    
    puts ""
    puts colorize("=" * 70, :success)
    puts colorize("  ✓ INSTALLATION COMPLETE", :success)
    puts colorize("=" * 70, :success)
    puts ""
    puts colorize("Next steps:", :info)
    puts colorize("  1. cd ui && npm install", :info)
    puts colorize("  2. cd mcp-server && npm install && npm run build", :info)
    puts colorize("  3. ruby db/setup_database.rb", :info)
    puts colorize("  4. cd app && ruby app.rb", :info)
    puts colorize("  5. Open http://localhost:4567 in your browser", :info)
    puts ""
    puts colorize("View installation manifest: docs/installation-manifest.html", :info)
    puts ""
  end

  private

  def create_directory_structure
    puts colorize("\n📁 Creating directory structure...", :primary)
    
    dirs = [
      @ui_dir,
      File.join(@ui_dir, 'components'),
      File.join(@ui_dir, 'store'),
      File.join(@ui_dir, 'styles'),
      File.join(@ui_dir, 'public'),
      @services_dir,
      @db_dir,
      File.join(@db_dir, 'migrations'),
      @config_dir,
      @docs_dir,
      File.join(@mcp_server_dir, 'src', 'tools'),
      File.join(@mcp_server_dir, 'config')
    ]
    
    dirs.each do |dir|
      FileUtils.mkdir_p(dir)
      puts colorize("  ✓ #{dir}", :success)
    end
  end

  def install_prompts
    puts colorize("\n📝 Installing system prompts...", :primary)
    
    # Ask Mode Prompt
    ask_prompt = <<~PROMPT
# CARINA ASK MODE SYSTEM PROMPT

You are Carina's Ask Mode - an intelligent query and insight engine for retail store operations.

## ROLE
Answer questions about store operations, provide detailed insights, and help users understand their business through natural conversation and data analysis.

## CAPABILITIES
- Query inventory levels and product status
- Analyze sales velocity and trends
- Review staff allocation and scheduling
- Compare competitor pricing
- Surface operational insights from historical data
- Explain policies and procedures

## INTERACTION STYLE
- Conversational and helpful
- Proactive in offering relevant insights
- Clear explanations with supporting data
- Suggest follow-up questions when appropriate
- Surface unexpected patterns or anomalies

## TOOL USAGE
Use available tools to:
1. Retrieve current operational data
2. Analyze historical trends
3. Compare metrics across stores or time periods
4. Validate information against policies

## OUTPUT FORMAT
- Start with direct answer to the question
- Support with relevant data points
- Highlight key insights or patterns
- Suggest related information if valuable
- Use clear, scannable formatting

## EXAMPLE INTERACTIONS

User: "Which stores need additional staff this weekend?"
Response:
"Based on predicted foot traffic and current scheduling, 3 stores need additional coverage:

**Parramatta Store** - Short 2 staff members
- Saturday peak: 2pm-6pm (historical +35% traffic)
- Current: 8 scheduled, Recommended: 10

**Westfield Store** - Short 1 staff member  
- Sunday afternoon gap
- Local event nearby (Westfield Markets Festival)

**Broadway Store** - Adequate staffing
- Current schedule aligns with predicted traffic

Would you like me to check available staff for shift coverage?"

User: "How can I get restock sooner?"
Response:
"I'll check your current restock schedule and explore options:

[Uses tools: get_inventory_status, query_delivery_schedule]

Your next delivery for produce is scheduled for Thursday. Here are your options to get restock sooner:

1. **Emergency Restock Request** (Within 24hrs)
   - Available for critical items only
   - Requires regional manager approval
   - Additional $150 delivery fee

2. **Transfer from Nearby Store** (Same day)
   - Broadway store has surplus of items you need
   - Free inter-store transfer
   - Can arrive by 6pm today

3. **Modify Standing Order** (Future weeks)
   - Increase delivery frequency
   - No additional fees
   
The transfer option looks most practical for today. Should I check specific availability?"

## CONSTRAINTS
- Never make decisions or execute actions (that's Act Mode)
- Always cite data sources for factual claims
- Acknowledge uncertainty when appropriate
- Redirect operational actions to Act Mode
- Flag policy violations or concerns
PROMPT

    File.write(File.join(@prompts_dir, 'carina-ask-mode.txt'), ask_prompt)
    
    # Act Mode Prompt
    act_prompt = <<~PROMPT
# CARINA ACT MODE SYSTEM PROMPT

You are Carina's Act Mode - an action recommendation and execution engine for retail operations.

## ROLE
Review operational conditions, recommend specific actions, route for approval when needed, and coordinate execution while maintaining audit trails.

## CAPABILITIES
- Analyze situations requiring intervention
- Recommend specific actions with justification
- Route actions through approval workflows
- Execute approved actions via backend systems
- Track action completion and outcomes
- Generate audit logs

## DECISION FRAMEWORK
For each potential action:
1. Assess situation urgency and impact
2. Check policy compliance and approval requirements
3. Calculate financial and operational impact
4. Identify dependencies and blockers
5. Recommend action with clear rationale
6. Route for appropriate approval level
7. Execute when approved
8. Monitor outcome and log results

## APPROVAL ROUTING
- **Automatic**: <$100, policy compliant, routine operations
- **Store Manager**: $100-$500, moderate impact, standard procedures
- **Regional Manager**: >$500, policy exceptions, high impact

## ACTION TYPES
- Price changes and markdowns
- Inventory adjustments
- Staff schedule modifications
- Emergency restocks
- Quality removals
- Competitor responses

## OUTPUT FORMAT FOR ACTION RECOMMENDATIONS

**Action Title**: [Clear, specific action]

**Priority**: Critical | Actionable | Standard

**Justification**:
- Current situation and impact
- Supporting data and analysis
- Expected outcome

**Financial Impact**: [Estimated cost/savings]

**Approval Required**: [Level and reason]

**Dependencies**: [Blockers or prerequisites]

**Recommended Timeline**: [When to execute]

**Buttons**: [Take Action] [Investigate Further]

## EXAMPLE INTERACTION

Situation: 24 units of organic strawberries expiring tomorrow, slow sales

**Action Recommendation**

**Action Title**: 35% Markdown on Organic Strawberries (SKU: STR001)

**Priority**: Actionable

**Justification**:
- 24 units expiring in 24 hours
- Current velocity: 3 units/day (need 24 units/day)
- Shrinkage cost if unsold: $191.76
- Margin after markdown: 16.2% (meets 15% minimum)
- Competitor pricing: Woolworths at $5.49 (we'd match)

**Financial Impact**: 
- Cost if unsold: -$191.76 (100% loss)
- Revenue with markdown: $131.76
- Net impact: +$131.76 vs. shrinkage

**Approval Required**: Automatic (policy compliant, <$200 value)

**Dependencies**: None

**Recommended Timeline**: Execute immediately

[Take Action] [Investigate Further]

## EXECUTION PROTOCOL
When action approved:
1. Validate approval token
2. Execute via appropriate backend API
3. Confirm execution success
4. Log complete audit trail
5. Monitor outcome vs. expectation
6. Report completion to user

## CONSTRAINTS
- Never execute actions without proper approval
- Always maintain complete audit trail
- Validate policy compliance before execution
- Flag high-risk actions for human review
- Surface execution failures immediately
PROMPT

    File.write(File.join(@prompts_dir, 'carina-act-mode.txt'), act_prompt)
    
    # Alert Mode Prompt
    alert_prompt = <<~PROMPT
# CARINA ALERT MODE SYSTEM PROMPT

You are Carina's Alert Mode - a monitoring and notification system for retail operations.

## ROLE
Continuously monitor operational metrics, detect issues and opportunities, prioritize alerts, and enable rapid response to time-sensitive situations.

## ALERT PRIORITIES

**Critical** (Red)
- Immediate business impact
- Requires action within 5 minutes
- Examples: System outages, safety issues, major blockers
- Notification: SMS + Email + In-app

**Actionable** (Yellow)
- Significant impact if not addressed
- Requires action within 24 hours
- Examples: Schedule delays, inventory issues, deadline risks
- Notification: Email + In-app

**Informational** (Blue)
- Good to know, track for trends
- Review within 48 hours
- Examples: Status updates, minor delays, FYI items
- Notification: In-app only

## MONITORING DOMAINS
1. **Task Status**: Blockers, delays, completion rates
2. **Inventory Levels**: Stock-outs, overstock, expiration risks
3. **Schedule Adherence**: Timeline slippage, deadline risks
4. **Quality Issues**: Product quality, customer complaints
5. **Financial Thresholds**: Budget variances, margin erosion
6. **System Health**: API failures, integration issues
7. **Competitive Threats**: Major price changes, new competition

## ALERT GENERATION
Create alerts when:
- Metric crosses defined threshold
- Pattern deviates from baseline
- Dependency creates blocker
- Time-sensitive deadline approaches
- Policy violation detected
- System anomaly identified

## ALERT FORMAT

**Alert Title**: [Concise, action-oriented title]

**Priority Badge**: Critical | Actionable | Informational

**Description**: 
[Clear explanation of what happened, why it matters, and potential impact]

**Source**: [Task Monitor, Inventory System, Quality Assurance, etc.]

**Timestamp**: [When detected]

**Affected Scope**: [Stores, departments, or systems impacted]

**Recommended Actions**:
- [Specific action 1]
- [Specific action 2]

**Buttons**: [Take Action] [Investigate] [Dismiss]

## EXAMPLE ALERTS

### Critical Priority

**Critical Priority Task Blocker**

Q4 Planning Review is blocked due to resource constraints from 2 dependent teams. Potential 5-day delay if not resolved within 48 hours.

**Source**: Task Monitor  
**Timestamp**: Just now  
**Affected**: Q4 Planning Team, 2 dependent teams

**Impact**: 
- 5-day potential delay
- Deadline: 48 hours to resolve
- Dependencies: Resource allocation from Analytics and Ops teams

**Recommended Actions**:
- Escalate to regional manager
- Request resource reallocation
- Consider timeline adjustment

[Take Action] [Investigate]

---

### Actionable Priority

**Customer Feedback Analysis Behind Schedule**

Analysis task is tracking 15% behind target pace. Data team dependency may cause further delays. Recommend check-in meeting.

**Source**: Project Tracking  
**Timestamp**: 15 minutes ago  
**Affected**: Customer Experience Team

**Impact**:
- Currently 15% behind pace
- Risk of missing deadline
- Requires data team coordination

**Recommended Actions**:
- Schedule check-in with data team
- Review and adjust timeline if needed
- Identify specific blockers

[Take Action] [Investigate]

---

### Informational Priority

**System Integration Testing On Track**

Testing proceeding as planned with 30% completion. No blockers detected. Team documented 12 test cases for knowledge base.

**Source**: Quality Assurance  
**Timestamp**: 1 hour ago  
**Affected**: QA Team

**Status**: On track, no action needed

[Investigate]

## ALERT AGGREGATION
- Group related alerts together
- Surface root causes when multiple alerts stem from same issue
- Show dependency relationships between alerts
- Prevent alert fatigue with intelligent filtering

## CONSTRAINTS
- Never create duplicate alerts for same issue
- Always provide clear, actionable information
- Prioritize accurately - don't over-escalate
- Include relevant context and data
- Suggest specific next steps
- Maintain alert history and resolution tracking
PROMPT

    File.write(File.join(@prompts_dir, 'carina-alert-mode.txt'), alert_prompt)
    
    # Mode Orchestrator Prompt
    orchestrator_prompt = <<~PROMPT
# CARINA MODE ORCHESTRATOR SYSTEM PROMPT

You are Carina's Mode Orchestrator - the intelligent router that determines which mode should handle each user interaction.

## ROLE
Analyze user input, determine appropriate mode, route to correct handler, and maintain context across mode transitions.

## MODE CHARACTERISTICS

**Ask Mode**: Questions, information requests, analysis, explanations
- Keywords: "what", "why", "how", "show me", "explain", "tell me"
- User wants information or insights
- No action required, just understanding

**Act Mode**: Action requests, decision execution, operations changes
- Keywords: "do", "change", "update", "execute", "approve", "fix"
- User wants something done
- Requires validation and potentially approval

**Alert Mode**: Monitoring status, notification review, urgent issues
- Keywords: "alerts", "notifications", "what's wrong", "issues", "critical"
- User checking on system status
- Time-sensitive or monitoring-focused

## ROUTING LOGIC

```
IF query contains question words AND no action verbs
  → Ask Mode

ELSE IF query contains action verbs OR imperative mood
  → Act Mode

ELSE IF query mentions alerts, notifications, or status
  → Alert Mode

ELSE IF ambiguous
  → Ask Mode (default, can route to other modes as needed)
```

## CONTEXT MAINTENANCE
- Track conversation across mode transitions
- Pass relevant context when switching modes
- Maintain user preferences and session state
- Remember previous actions and decisions

## EXAMPLES

"Which stores need more staff?" → **Ask Mode**
- Question seeking information

"Add 2 staff to Parramatta store on Saturday" → **Act Mode**
- Action request

"Show me critical alerts" → **Alert Mode**
- Monitoring/notification request

"Why was the Q4 task blocked?" → **Ask Mode**
- Question about specific situation

"Approve the strawberry markdown" → **Act Mode**
- Decision/action execution

"What's the status of system integration?" → **Alert Mode** or **Ask Mode**
- Could be either, check for active alerts first, then provide information

## OUTPUT FORMAT
Do not expose mode routing to user. Simply route to appropriate mode and let that mode handle the response naturally.

Internal routing decision should log:
- Selected mode
- Routing reason
- Context passed
- Timestamp

## SPECIAL CASES
- If user explicitly requests mode ("switch to act mode"), honor it
- If action fails in Act Mode, offer to explain in Ask Mode
- If asking about alert details, transition from Alert to Ask Mode
- If user wants to act on an alert, transition from Alert to Act Mode
PROMPT

    File.write(File.join(@prompts_dir, 'carina-mode-orchestrator.txt'), orchestrator_prompt)
    
    puts colorize("  ✓ 4 mode prompts installed", :success)
  end

  def install_policies
    puts colorize("\n📋 Installing policies...", :primary)
    
    # Alert Escalation Policy
    alert_policy = {
      policy_name: "Alert Escalation and Notification Policy",
      version: "1.0",
      effective_date: "2025-10-16",
      priority_levels: {
        critical: {
          response_time_minutes: 5,
          approval_required: true,
          notification_channels: ["sms", "email", "in_app"],
          escalation_path: ["store_manager", "regional_manager"],
          auto_escalate_after_minutes: 10
        },
        actionable: {
          response_time_hours: 24,
          approval_required: false,
          notification_channels: ["email", "in_app"],
          escalation_path: ["store_manager"],
          auto_escalate_after_hours: 48
        },
        informational: {
          response_time_hours: 48,
          approval_required: false,
          notification_channels: ["in_app"],
          escalation_path: [],
          auto_escalate: false
        }
      },
      monitoring_rules: {
        duplicate_detection: {
          enabled: true,
          time_window_minutes: 30,
          similarity_threshold: 0.8
        },
        aggregation: {
          enabled: true,
          group_related_alerts: true,
          max_group_size: 5
        },
        quiet_hours: {
          enabled: true,
          start_time: "22:00",
          end_time: "06:00",
          critical_only: true
        }
      }
    }
    
    File.write(
      File.join(@policies_dir, 'alert-escalation-policy.json'),
      JSON.pretty_generate(alert_policy)
    )
    
    # Action Approval Policy
    approval_policy = {
      policy_name: "Action Approval and Authorization Policy",
      version: "1.0",
      effective_date: "2025-10-16",
      approval_workflows: {
        automatic: {
          description: "Auto-approved actions that meet all criteria",
          conditions: [
            "low_financial_impact",
            "policy_compliant",
            "within_authority",
            "routine_operation"
          ],
          max_value_usd: 100,
          audit_required: true,
          examples: [
            "Standard markdowns <20%",
            "Routine inventory adjustments",
            "Schedule swaps between staff"
          ]
        },
        store_manager: {
          description: "Store manager approval required",
          conditions: [
            "moderate_financial_impact",
            "non_routine_operation"
          ],
          value_range_usd: [100, 500],
          timeout_hours: 4,
          notification_method: "email_and_app",
          audit_required: true,
          examples: [
            "Markdowns 20-40%",
            "Emergency restocks",
            "Staff schedule overrides"
          ]
        },
        regional_manager: {
          description: "Regional manager approval required",
          conditions: [
            "high_financial_impact",
            "policy_exception",
            "cross_store_impact"
          ],
          min_value_usd: 500,
          timeout_hours: 24,
          notification_method: "phone_and_email",
          audit_required: true,
          escalation_required: true,
          examples: [
            "Markdowns >40%",
            "Policy exceptions",
            "Store-wide operational changes"
          ]
        }
      },
      audit_requirements: {
        retention_period_days: 730,
        required_fields: [
          "action_type",
          "initiator",
          "approver",
          "timestamp",
          "financial_impact",
          "rationale",
          "outcome"
        ],
        review_frequency: "quarterly"
      }
    }
    
    File.write(
      File.join(@policies_dir, 'action-approval-policy.json'),
      JSON.pretty_generate(approval_policy)
    )
    
    # Task Monitoring Policy
    task_policy = {
      policy_name: "Task Monitoring and Tracking Policy",
      version: "1.0",
      effective_date: "2025-10-16",
      monitoring_rules: {
        task_blockers: {
          detection_interval_minutes: 15,
          escalation_threshold_hours: 4,
          notification_priority: "critical",
          auto_create_alert: true
        },
        schedule_delays: {
          warning_threshold_percent: 15,
          critical_threshold_percent: 25,
          check_frequency_hours: 4,
          notification_priority: "actionable"
        },
        dependency_tracking: {
          enabled: true,
          max_dependency_depth: 3,
          circular_dependency_detection: true,
          alert_on_dependency_failure: true
        },
        completion_tracking: {
          require_outcome_documentation: true,
          outcome_review_period_days: 7,
          variance_reporting_threshold_percent: 20
        }
      },
      task_priorities: {
        critical: {
          max_duration_days: 1,
          requires_daily_updates: true,
          auto_escalate_if_stalled: true
        },
        high: {
          max_duration_days: 7,
          requires_weekly_updates: true,
          auto_escalate_if_stalled: false
        },
        normal: {
          max_duration_days: 30,
          requires_weekly_updates: false,
          auto_escalate_if_stalled: false
        }
      }
    }
    
    File.write(
      File.join(@policies_dir, 'task-monitoring-policy.json'),
      JSON.pretty_generate(task_policy)
    )
    
    puts colorize("  ✓ 3 policy documents installed", :success)
  end

  def install_examples
    puts colorize("\n💡 Installing example scenarios...", :primary)
    
    # Ask Mode Examples
    ask_examples = <<~EXAMPLES
# ASK MODE EXAMPLE SCENARIOS

## Scenario 1: Staff Allocation Query

**User Query**: "Which stores need additional staff this weekend?"

**Expected Tool Calls**:
1. get_staff_allocation(time_range: "this_weekend")
2. get_predicted_traffic(time_range: "this_weekend")

**Expected Response**:
Identifies stores with staffing gaps, explains rationale using traffic predictions, suggests specific coverage needs.

**Key Elements**:
- Clear identification of stores with shortfalls
- Quantified gaps (how many staff short)
- Time-specific details (which shifts)
- Context (why the gap exists)
- Proactive follow-up offer

---

## Scenario 2: Inventory Status Query

**User Query**: "What's the status of our organic produce inventory?"

**Expected Tool Calls**:
1. get_inventory_status(category: "organic_produce")
2. query_sales_velocity(category: "organic_produce")

**Expected Response**:
Comprehensive inventory overview with quantities, expiration dates, velocity trends, and flagged at-risk items.

**Key Elements**:
- Current quantities by product
- Days until expiration
- Sales velocity comparison
- Flagged issues (slow movers, near expiration)
- Suggested actions (if any)

---

## Scenario 3: Competitive Intelligence

**User Query**: "How does our produce pricing compare to competitors?"

**Expected Tool Calls**:
1. get_competitor_pricing(category: "produce")
2. get_current_pricing(category: "produce")
3. check_pricing_policy()

**Expected Response**:
Side-by-side comparison of pricing, identification of significant gaps, policy-compliant recommendations.

**Key Elements**:
- Clear comparison table or list
- Highlighted significant differences
- Context on margin impact
- Policy compliance notes
- Suggested responses if warranted
EXAMPLES

    File.write(File.join(@examples_dir, 'ask-mode-examples.txt'), ask_examples)
    
    # Act Mode Examples
    act_examples = <<~EXAMPLES
# ACT MODE EXAMPLE SCENARIOS

## Scenario 1: Markdown Execution

**Situation**: 24 units organic strawberries expiring tomorrow

**Tool Calls**:
1. get_inventory_status(product_id: "STR001")
2. query_sales_velocity(product_id: "STR001")
3. check_pricing_policy(markdown_percent: 35)

**Action Recommended**:
- Title: "35% Markdown on Organic Strawberries"
- Priority: Actionable
- Financial Impact: +$131.76 vs shrinkage
- Approval: Automatic (policy compliant)

**Execution Flow**:
1. User clicks [Take Action]
2. System validates policy compliance
3. Generates approval token
4. Calls submit_price_change()
5. Confirms execution
6. Logs audit trail

---

## Scenario 2: Emergency Restock

**Situation**: Store critically low on salad kits, event tomorrow

**Tool Calls**:
1. get_inventory_status(product_id: "SAL001")
2. check_delivery_schedule(store_id: "PAR001")
3. find_nearby_inventory(product_id: "SAL001")

**Action Recommended**:
- Title: "Emergency Inter-Store Transfer - Salad Kits"
- Priority: Critical
- Financial Impact: $0 (no transfer fee)
- Approval: Store Manager

**Execution Flow**:
1. System notifies store manager
2. Manager reviews on mobile
3. Approves with one tap
4. System initiates transfer request
5. Confirms pickup/delivery times
6. Updates inventory systems

---

## Scenario 3: Schedule Override

**Situation**: Staff called in sick, need replacement for peak hours

**Tool Calls**:
1. get_current_schedule(store_id: "PAR001", date: "today")
2. find_available_staff(store_id: "PAR001", shift: "afternoon")
3. check_labor_policy(overtime_check: true)

**Action Recommended**:
- Title: "Add Coverage - Afternoon Shift"
- Priority: Actionable
- Financial Impact: +$120 labor cost
- Approval: Automatic (within budget)

**Execution Flow**:
1. System identifies available staff
2. Validates against labor policies
3. Auto-approves (routine operation)
4. Sends shift offer to available staff
5. Confirms acceptance
6. Updates schedule system
EXAMPLES

    File.write(File.join(@examples_dir, 'act-mode-examples.txt'), act_examples)
    
    # Alert Mode Examples
    alert_examples = <<~EXAMPLES
# ALERT MODE EXAMPLE SCENARIOS

## Scenario 1: Critical Task Blocker

**Detection**: Task dependency analysis identifies blocker

**Alert Generated**:
- Title: "Critical Priority Task Blocker"
- Priority: Critical (Red)
- Source: Task Monitor
- Description: "Q4 Planning Review is blocked due to resource constraints from 2 dependent teams. Potential 5-day delay if not resolved within 48 hours."

**User Actions Available**:
1. [Take Action] - Routes to Act Mode to resolve
2. [Investigate] - Routes to Ask Mode for details

**Expected Flow**:
1. Alert appears in real-time
2. SMS + Email sent to store manager
3. User clicks [Investigate]
4. Ask Mode provides dependency details
5. User returns, clicks [Take Action]
6. Act Mode recommends resource reallocation
7. Manager approves
8. Alert marked resolved

---

## Scenario 2: Schedule Delay Warning

**Detection**: Project tracking detects 15% pace lag

**Alert Generated**:
- Title: "Customer Feedback Analysis Behind Schedule"
- Priority: Actionable (Yellow)
- Source: Project Tracking
- Description: "Analysis task is tracking 15% behind target pace. Data team dependency may cause further delays. Recommend check-in meeting."

**User Actions Available**:
1. [Take Action] - Schedule check-in meeting
2. [Investigate] - Get detailed timeline analysis

**Expected Flow**:
1. Alert appears in dashboard
2. Email notification sent
3. User reviews alert context
4. Clicks [Take Action]
5. Act Mode suggests meeting times
6. Meeting scheduled
7. Alert moves to "In Progress"

---

## Scenario 3: Informational Status Update

**Detection**: Regular status check shows positive progress

**Alert Generated**:
- Title: "System Integration Testing On Track"
- Priority: Informational (Blue)
- Source: Quality Assurance
- Description: "Testing proceeding as planned with 30% completion. No blockers detected. Team documented 12 test cases for knowledge base."

**User Actions Available**:
1. [Investigate] - View detailed progress

**Expected Flow**:
1. Alert appears in feed
2. No immediate action needed
3. Available for review
4. Auto-dismissed after 48 hours if not interacted
5. Logged for trend analysis
EXAMPLES

    File.write(File.join(@examples_dir, 'alert-mode-examples.txt'), alert_examples)
    
    puts colorize("  ✓ 3 example scenario files installed", :success)
  end

  def install_mcp_tools
    puts colorize("\n🔧 Installing MCP tools...", :primary)
    
    # Tools Registry
    tools_registry = {
      version: "1.0",
      categories: {
        task_management: [
          "get_pending_actions",
          "execute_action",
          "complete_action",
          "analyze_task_dependencies"
        ],
        alert_management: [
          "create_alert",
          "get_active_alerts",
          "dismiss_alert",
          "update_alert_status"
        ],
        analytics: [
          "search_knowledge_base",
          "get_staff_allocation",
          "get_predicted_traffic",
          "analyze_sales_trends"
        ],
        inventory: [
          "get_inventory_status",
          "query_sales_velocity",
          "find_nearby_inventory"
        ],
        pricing: [
          "check_pricing_policy",
          "submit_price_change",
          "get_competitor_pricing"
        ]
      },
      tool_definitions: [
        {
          name: "get_pending_actions",
          description: "Retrieve pending actions across stores",
          category: "task_management",
          input_schema: {
            type: "object",
            properties: {
              store_id: { type: "string", description: "Filter by store ID" },
              priority: { 
                type: "string", 
                enum: ["critical", "high", "normal"],
                description: "Filter by priority level"
              },
              status: {
                type: "string",
                enum: ["pending", "in_progress", "completed"],
                description: "Filter by status"
              }
            }
          }
        },
        {
          name: "execute_action",
          description: "Execute an approved action",
          category: "task_management",
          input_schema: {
            type: "object",
            properties: {
              action_id: { type: "string", required: true },
              approval_token: { type: "string", required: true },
              execution_parameters: { type: "object" }
            },
            required: ["action_id", "approval_token"]
          }
        },
        {
          name: "complete_action",
          description: "Mark action as completed with outcome",
          category: "task_management",
          input_schema: {
            type: "object",
            properties: {
              action_id: { type: "string", required: true },
              outcome: { 
                type: "object",
                properties: {
                  status: { type: "string", enum: ["success", "partial", "failed"] },
                  actual_impact: { type: "object" },
                  variance_from_expected: { type: "number" },
                  notes: { type: "string" }
                }
              },
              completion_notes: { type: "string" }
            },
            required: ["action_id", "outcome"]
          }
        },
        {
          name: "create_alert",
          description: "Create a new alert for monitoring",
          category: "alert_management",
          input_schema: {
            type: "object",
            properties: {
              title: { type: "string", required: true },
              description: { type: "string", required: true },
              priority: {
                type: "string",
                enum: ["critical", "actionable", "informational"],
                required: true
              },
              source: { type: "string", required: true },
              action_items: {
                type: "array",
                items: { type: "string" }
              },
              affected_scope: { type: "object" }
            },
            required: ["title", "description", "priority", "source"]
          }
        },
        {
          name: "get_active_alerts",
          description: "Retrieve current active alerts",
          category: "alert_management",
          input_schema: {
            type: "object",
            properties: {
              priority: {
                type: "string",
                enum: ["critical", "actionable", "informational"]
              },
              time_range_hours: { type: "number", default: 24 },
              include_dismissed: { type: "boolean", default: false }
            }
          }
        },
        {
          name: "dismiss_alert",
          description: "Dismiss or resolve an alert",
          category: "alert_management",
          input_schema: {
            type: "object",
            properties: {
              alert_id: { type: "string", required: true },
              resolution_notes: { type: "string", required: true },
              resolution_type: {
                type: "string",
                enum: ["resolved", "false_positive", "duplicate"]
              }
            },
            required: ["alert_id", "resolution_notes"]
          }
        },
        {
          name: "search_knowledge_base",
          description: "Search store operations knowledge base",
          category: "analytics",
          input_schema: {
            type: "object",
            properties: {
              query: { type: "string", required: true },
              category: {
                type: "string",
                enum: ["policies", "procedures", "best_practices", "faq"]
              },
              max_results: { type: "number", default: 5 }
            },
            required: ["query"]
          }
        },
        {
          name: "get_staff_allocation",
          description: "Get current and recommended staff allocation",
          category: "analytics",
          input_schema: {
            type: "object",
            properties: {
              store_id: { type: "string" },
              date_range: {
                type: "object",
                properties: {
                  start_date: { type: "string", format: "date" },
                  end_date: { type: "string", format: "date" }
                }
              },
              include_recommendations: { type: "boolean", default: true }
            }
          }
        },
        {
          name: "analyze_task_dependencies",
          description: "Identify task dependencies and blockers",
          category: "analytics",
          input_schema: {
            type: "object",
            properties: {
              task_ids: {
                type: "array",
                items: { type: "string" }
              },
              depth: { type: "number", default: 3 },
              include_recommendations: { type: "boolean", default: true }
            }
          }
        }
      ]
    }
    
    File.write(
      File.join(@mcp_server_dir, 'config', 'tools-registry.json'),
      JSON.pretty_generate(tools_registry)
    )
    
    # Update MCP Server index.ts with new tools
    mcp_tools_addition = <<~TYPESCRIPT
// Additional tools for Carina multi-mode system
// Add to existing index.ts

case "get_pending_actions": {
  const { store_id, priority, status } = args as any;
  
  // Mock implementation - replace with real database query
  const actions = [
    {
      id: "ACT001",
      title: "35% Markdown on Organic Strawberries",
      priority: "actionable",
      status: "pending",
      store_id: "PAR001",
      created_at: new Date().toISOString()
    }
  ];
  
  let filtered = actions;
  if (store_id) filtered = filtered.filter(a => a.store_id === store_id);
  if (priority) filtered = filtered.filter(a => a.priority === priority);
  if (status) filtered = filtered.filter(a => a.status === status);
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({ actions: filtered }, null, 2)
    }]
  };
}

case "execute_action": {
  const { action_id, approval_token, execution_parameters } = args as any;
  
  // Validate approval token
  // Execute action via appropriate backend system
  // Log audit trail
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        success: true,
        action_id,
        execution_id: "EXE" + Date.now(),
        executed_at: new Date().toISOString()
      }, null, 2)
    }]
  };
}

case "create_alert": {
  const { title, description, priority, source, action_items } = args as any;
  
  const alert = {
    id: "ALT" + Date.now(),
    title,
    description,
    priority,
    source,
    action_items: action_items || [],
    created_at: new Date().toISOString(),
    status: "active"
  };
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({ alert }, null, 2)
    }]
  };
}

case "get_active_alerts": {
  const { priority, time_range_hours, include_dismissed } = args as any;
  
  // Mock implementation
  const alerts = [
    {
      id: "ALT001",
      title: "Critical Priority Task Blocker",
      priority: "critical",
      status: "active",
      created_at: new Date().toISOString()
    },
    {
      id: "ALT002",
      title: "Customer Feedback Analysis Behind Schedule",
      priority: "actionable",
      status: "active",
      created_at: new Date(Date.now() - 15 * 60000).toISOString()
    }
  ];
  
  let filtered = alerts;
  if (priority) filtered = filtered.filter(a => a.priority === priority);
  if (!include_dismissed) filtered = filtered.filter(a => a.status === "active");
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify({ alerts: filtered }, null, 2)
    }]
  };
}

case "get_staff_allocation": {
  const { store_id, date_range, include_recommendations } = args as any;
  
  // Mock implementation
  const allocation = {
    store_id: store_id || "PAR001",
    current_allocation: {
      saturday: { scheduled: 8, required: 10, gap: 2 },
      sunday: { scheduled: 9, required: 9, gap: 0 }
    },
    recommendations: include_recommendations ? [
      "Add 2 staff Saturday 2pm-6pm",
      "Consider shifting Sunday staff to Saturday"
    ] : []
  };
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify(allocation, null, 2)
    }]
  };
}

case "analyze_task_dependencies": {
  const { task_ids, depth, include_recommendations } = args as any;
  
  // Mock implementation
  const analysis = {
    tasks: task_ids,
    dependencies: [
      {
        task_id: task_ids[0],
        blocked_by: ["TASK_123", "TASK_456"],
        blocking: [],
        depth: 1
      }
    ],
    blockers: [
      {
        blocker_id: "TASK_123",
        reason: "Resource unavailable",
        estimated_delay_days: 3
      }
    ],
    recommendations: include_recommendations ? [
      "Escalate resource allocation",
      "Consider parallel work on unblocked components"
    ] : []
  };
  
  return {
    content: [{
      type: "text",
      text: JSON.stringify(analysis, null, 2)
    }]
  };
}
TYPESCRIPT

    File.write(
      File.join(@mcp_server_dir, 'src', 'tools', 'carina-tools.ts'),
      mcp_tools_addition
    )
    
    puts colorize("  ✓ MCP tools registry and implementations installed", :success)
  end

  def install_ui_components
    puts colorize("\n🎨 Installing UI components...", :primary)
    
    # Package.json for UI
    package_json = {
      name: "carina-ui",
      version: "1.0.0",
      description: "Carina multi-mode interface",
      main: "index.js",
      scripts: {
        dev: "vite",
        build: "vite build",
        preview: "vite preview"
      },
      dependencies: {
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "zustand": "^4.4.0",
        "lucide-react": "^0.263.1"
      },
      devDependencies: {
        "@vitejs/plugin-react": "^4.0.0",
        "vite": "^4.4.0"
      }
    }
    
    File.write(
      File.join(@ui_dir, 'package.json'),
      JSON.pretty_generate(package_json)
    )
    
    # Mode Selector Component
    mode_selector = <<~JSX
import React from 'react';
import { MessageSquare, Zap, Bell } from 'lucide-react';

export default function ModeSelector({ currentMode, onModeChange }) {
  const modes = [
    {
      id: 'ask',
      name: 'Ask',
      icon: MessageSquare,
      color: 'blue',
      description: 'Query the system and get detailed insights'
    },
    {
      id: 'act',
      name: 'Act',
      icon: Zap,
      color: 'green',
      description: 'Review and execute recommended actions'
    },
    {
      id: 'alert',
      name: 'Alert',
      icon: Bell,
      color: 'yellow',
      description: 'Monitor outcomes and receive notifications'
    }
  ];

  return (
    <div className="mode-selector">
      <h1 className="title">Hey Carina</h1>
      <p className="subtitle">Ask questions, take actions, and manage alerts.</p>
      
      <div className="search-container">
        <input
          type="text"
          placeholder="Ask a question or search..."
          className="search-input"
        />
      </div>

      <div className="modes-grid">
        {modes.map((mode) => {
          const Icon = mode.icon;
          return (
            <button
              key={mode.id}
              onClick={() => onModeChange(mode.id)}
              className={`mode-card ${currentMode === mode.id ? 'active' : ''}`}
            >
              <div className={`icon-container icon-${mode.color}`}>
                <Icon size={24} />
              </div>
              <h3 className="mode-name">{mode.name}</h3>
              <p className="mode-description">{mode.description}</p>
            </button>
          );
        })}
      </div>

      <p className="footer-text">Select a mode to begin your workflow</p>
    </div>
  );
}
JSX

    File.write(
      File.join(@ui_dir, 'components', 'ModeSelector.jsx'),
      mode_selector
    )
    
    # Ask Interface Component
    ask_interface = <<~JSX
import React, { useState } from 'react';
import { Send, Mic } from 'lucide-react';

export default function AskInterface() {
  const [message, setMessage] = useState('');
  const [conversation, setConversation] = useState([]);

  const suggestions = [
    "Which stores need additional staff this weekend?",
    "How can I get restock sooner? What are my options?",
    "Staff allocation optimization recommendations"
  ];

  const handleSend = async () => {
    if (!message.trim()) return;

    const userMessage = { role: 'user', content: message };
    setConversation([...conversation, userMessage]);
    setMessage('');

    // Call API
    try {
      const response = await fetch('/api/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message })
      });
      const data = await response.json();
      
      setConversation(prev => [...prev, {
        role: 'assistant',
        content: data.response,
        toolCalls: data.tool_calls
      }]);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div className="ask-interface">
      <div className="mode-badge">Ask Mode</div>
      <h2>Ask</h2>
      
      <div className="ask-header">
        <h3>Hi Carina, what would you like to know?</h3>
        <p>Ask a question to get detailed, actionable insights for your stores</p>
      </div>

      <div className="suggestions">
        {suggestions.map((suggestion, idx) => (
          <button
            key={idx}
            onClick={() => setMessage(suggestion)}
            className="suggestion-card"
          >
            {suggestion}
          </button>
        ))}
      </div>

      <div className="conversation">
        {conversation.map((msg, idx) => (
          <div key={idx} className={`message message-${msg.role}`}>
            <div className="message-content">{msg.content}</div>
            {msg.toolCalls && msg.toolCalls.length > 0 && (
              <div className="tool-calls">
                {msg.toolCalls.map((tool, i) => (
                  <div key={i} className="tool-call">
                    <strong>{tool.name}</strong>
                  </div>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="input-container">
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          placeholder="Ask here ..."
          className="message-input"
        />
        <button onClick={handleSend} className="send-button">
          <Send size={20} />
        </button>
        <button className="voice-button">
          <Mic size={20} />
        </button>
      </div>
    </div>
  );
}
JSX

    File.write(
      File.join(@ui_dir, 'components', 'AskInterface.jsx'),
      ask_interface
    )
    
    # Act Interface Component
    act_interface = <<~JSX
import React, { useState, useEffect } from 'react';
import { Search, Mic, Send, ChevronDown } from 'lucide-react';

export default function ActInterface() {
  const [pendingActions, setPendingActions] = useState([]);
  const [completedActions, setCompletedActions] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadActions();
  }, []);

  const loadActions = async () => {
    try {
      const response = await fetch('/api/actions');
      const data = await response.json();
      setPendingActions(data.pending || []);
      setCompletedActions(data.completed || []);
    } catch (error) {
      console.error('Error loading actions:', error);
    }
  };

  const handleTakeAction = async (actionId) => {
    try {
      await fetch(`/api/actions/${actionId}/execute`, {
        method: 'POST'
      });
      loadActions();
    } catch (error) {
      console.error('Error executing action:', error);
    }
  };

  return (
    <div className="act-interface">
      <div className="mode-badge mode-badge-act">Act Mode</div>
      
      <div className="act-header">
        <h2>Review & Execute Actions</h2>
        <p>Confirm and execute recommended interventions</p>
      </div>

      <div className="completed-section">
        <button className="collapsible-header">
          <span>Completed Actions ({completedActions.length})</span>
          <ChevronDown size={20} />
        </button>
      </div>

      {pendingActions.length === 0 ? (
        <div className="empty-state">
          <p>No pending actions. All actions completed.</p>
        </div>
      ) : (
        <div className="actions-list">
          {pendingActions.map(action => (
            <div key={action.id} className={`action-card action-${action.priority}`}>
              <div className="action-header">
                <h3>{action.title}</h3>
                <span className={`priority-badge priority-${action.priority}`}>
                  {action.priority}
                </span>
              </div>
              <p className="action-description">{action.description}</p>
              <div className="action-meta">
                <span>{action.source}</span>
                <span>{action.timestamp}</span>
              </div>
              <div className="action-buttons">
                <button 
                  onClick={() => handleTakeAction(action.id)}
                  className="btn-take-action"
                >
                  Take Action
                </button>
                <button className="btn-investigate">
                  Investigate
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="search-container">
        <Search size={20} className="search-icon" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search actions or type command..."
          className="search-input"
        />
        <Mic size={20} className="voice-icon" />
        <button className="send-icon-btn">
          <Send size={20} />
        </button>
      </div>
    </div>
  );
}
JSX

    File.write(
      File.join(@ui_dir, 'components', 'ActInterface.jsx'),
      act_interface
    )
    
    # Alert Interface Component
    alert_interface = <<~JSX
import React, { useState, useEffect } from 'react';
import { Search, Mic, Send, X } from 'lucide-react';

export default function AlertInterface() {
  const [alerts, setAlerts] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadAlerts();
    const interval = setInterval(loadAlerts, 30000); // Refresh every 30s
    return () => clearInterval(interval);
  }, []);

  const loadAlerts = async () => {
    try {
      const response = await fetch('/api/alerts');
      const data = await response.json();
      setAlerts(data.alerts || []);
    } catch (error) {
      console.error('Error loading alerts:', error);
    }
  };

  const handleDismiss = async (alertId) => {
    try {
      await fetch(`/api/alerts/${alertId}/dismiss`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ resolution_notes: 'Dismissed by user' })
      });
      loadAlerts();
    } catch (error) {
      console.error('Error dismissing alert:', error);
    }
  };

  const getPriorityColor = (priority) => {
    const colors = {
      critical: 'red',
      actionable: 'yellow',
      informational: 'blue'
    };
    return colors[priority] || 'gray';
  };

  return (
    <div className="alert-interface">
      <div className="mode-badge mode-badge-alert">Alert Mode</div>
      
      <div className="alert-header">
        <h2>Monitor & Respond</h2>
        <p>Stay informed about critical updates and take action on what matters</p>
      </div>

      <div className="loading-placeholder">...</div>

      <div className="alerts-list">
        {alerts.map(alert => (
          <div 
            key={alert.id} 
            className={`alert-card alert-priority-${getPriorityColor(alert.priority)}`}
          >
            <button 
              onClick={() => handleDismiss(alert.id)}
              className="dismiss-button"
            >
              <X size={16} />
            </button>
            
            <div className="alert-icon-container">
              <div className={`alert-icon alert-icon-${getPriorityColor(alert.priority)}`}>
                !
              </div>
            </div>

            <div className="alert-content">
              <div className="alert-title-row">
                <h3>{alert.title}</h3>
                <span className={`priority-tag priority-${alert.priority}`}>
                  {alert.priority}
                </span>
              </div>
              
              <p className="alert-description">{alert.description}</p>
              
              <div className="alert-meta">
                <span className="alert-source">{alert.source}</span>
                <span className="alert-time">{alert.timestamp}</span>
              </div>

              <div className="alert-actions">
                <button className="btn-take-action">Take Action</button>
                <button className="btn-investigate">Investigate</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="search-container">
        <Search size={20} className="search-icon" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search alerts or type command..."
          className="search-input"
        />
        <Mic size={20} className="voice-icon" />
        <button className="send-icon-btn">
          <Send size={20} />
        </button>
      </div>
    </div>
  );
}
JSX

    File.write(
      File.join(@ui_dir, 'components', 'AlertInterface.jsx'),
      alert_interface
    )
    
    # Main App Component
    main_app = <<~JSX
import React, { useState } from 'react';
import ModeSelector from './components/ModeSelector';
import AskInterface from './components/AskInterface';
import ActInterface from './components/ActInterface';
import AlertInterface from './components/AlertInterface';
import './styles/app.css';

export default function App() {
  const [currentMode, setCurrentMode] = useState(null);

  const renderMode = () => {
    switch (currentMode) {
      case 'ask':
        return <AskInterface />;
      case 'act':
        return <ActInterface />;
      case 'alert':
        return <AlertInterface />;
      default:
        return <ModeSelector currentMode={currentMode} onModeChange={setCurrentMode} />;
    }
  };

  return (
    <div className="app">
      <nav className="sidebar">
        <div className="logo">CA</div>
        <div className="nav-items">
          <button onClick={() => setCurrentMode(null)} className="nav-item">🏠</button>
          <button onClick={() => setCurrentMode('ask')} className="nav-item">💬</button>
          <button onClick={() => setCurrentMode('act')} className="nav-item">⚡</button>
          <button onClick={() => setCurrentMode('alert')} className="nav-item">🔔</button>
        </div>
      </nav>
      <main className="main-content">
        {renderMode()}
      </main>
    </div>
  );
}
JSX

    File.write(
      File.join(@ui_dir, 'App.jsx'),
      main_app
    )
    
    # Styles
    styles = <<~CSS
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #f5f5f5;
}

.app {
  display: flex;
  height: 100vh;
}

.sidebar {
  width: 60px;
  background: #1a1a1a;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 0;
}

.logo {
  width: 40px;
  height: 40px;
  background: white;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-bottom: 40px;
}

.nav-items {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.nav-item {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: background 0.2s;
}

.nav-item:hover {
  background: rgba(255,255,255,0.1);
}

.main-content {
  flex: 1;
  overflow-y: auto;
  padding: 40px;
}

.mode-selector {
  max-width: 960px;
  margin: 0 auto;
}

.title {
  font-size: 48px;
  font-weight: 600;
  text-align: center;
  margin-bottom: 16px;
}

.subtitle {
  text-align: center;
  color: #666;
  margin-bottom: 40px;
}

.search-container {
  max-width: 600px;
  margin: 0 auto 60px;
}

.search-input {
  width: 100%;
  padding: 16px 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
}

.modes-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 40px;
}

.mode-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  padding: 32px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
}

.mode-card:hover {
  border-color: #999;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.icon-container {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
}

.icon-blue { background: #e3f2fd; color: #1976d2; }
.icon-green { background: #e8f5e9; color: #388e3c; }
.icon-yellow { background: #fff9c4; color: #f57c00; }

.mode-name {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 12px;
}

.mode-description {
  color: #666;
  font-size: 14px;
}

.footer-text {
  text-align: center;
  color: #999;
}

/* Ask Mode */
.ask-interface {
  max-width: 800px;
  margin: 0 auto;
}

.mode-badge {
  display: inline-block;
  padding: 4px 12px;
  background: #e3f2fd;
  color: #1976d2;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 16px;
}

.mode-badge-act {
  background: #e8f5e9;
  color: #388e3c;
}

.mode-badge-alert {
  background: #fff9c4;
  color: #f57c00;
}

.ask-header h3 {
  font-size: 24px;
  margin-bottom: 8px;
}

.ask-header p {
  color: #666;
  margin-bottom: 32px;
}

.suggestions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 40px;
}

.suggestion-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.suggestion-card:hover {
  border-color: #1976d2;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.conversation {
  margin-bottom: 20px;
}

.message {
  margin-bottom: 16px;
  padding: 16px;
  border-radius: 8px;
}

.message-user {
  background: #e3f2fd;
  margin-left: 60px;
}

.message-assistant {
  background: white;
  border: 1px solid #e0e0e0;
  margin-right: 60px;
}

.input-container {
  display: flex;
  gap: 12px;
  align-items: center;
}

.message-input {
  flex: 1;
  padding: 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
}

.send-button, .voice-button {
  width: 48px;
  height: 48px;
  border: none;
  border-radius: 50%;
  background: #1976d2;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.voice-button {
  background: white;
  border: 1px solid #ddd;
  color: #666;
}

/* Act Mode */
.act-interface {
  max-width: 1000px;
  margin: 0 auto;
}

.act-header {
  margin-bottom: 32px;
}

.completed-section {
  margin-bottom: 32px;
}

.collapsible-header {
  width: 100%;
  padding: 16px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  font-weight: 600;
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
  color: #999;
}

.actions-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 40px;
}

.action-card {
  background: white;
  border-left: 4px solid;
  border-radius: 8px;
  padding: 24px;
}

.action-card.action-critical {
  border-left-color: #d32f2f;
}

.action-card.action-actionable {
  border-left-color: #f57c00;
}

.action-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 12px;
}

.action-header h3 {
  font-size: 18px;
  font-weight: 600;
}

.priority-badge {
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
}

.priority-critical {
  background: #ffebee;
  color: #d32f2f;
}

.priority-actionable {
  background: #fff3e0;
  color: #f57c00;
}

.action-description {
  color: #666;
  margin-bottom: 16px;
  line-height: 1.6;
}

.action-meta {
  display: flex;
  gap: 16px;
  color: #999;
  font-size: 14px;
  margin-bottom: 16px;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.btn-take-action {
  padding: 10px 20px;
  background: #388e3c;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.btn-investigate {
  padding: 10px 20px;
  background: white;
  color: #1976d2;
  border: 1px solid #1976d2;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

/* Alert Mode */
.alert-interface {
  max-width: 1000px;
  margin: 0 auto;
}

.loading-placeholder {
  text-align: center;
  padding: 20px;
  color: #999;
}

.alerts-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 40px;
}

.alert-card {
  background: white;
  border-left: 4px solid;
  border-radius: 8px;
  padding: 24px;
  position: relative;
  display: flex;
  gap: 20px;
}

.alert-priority-red {
  border-left-color: #d32f2f;
}

.alert-priority-yellow {
  border-left-color: #f57c00;
}

.alert-priority-blue {
  border-left-color: #1976d2;
}

.dismiss-button {
  position: absolute;
  top: 12px;
  right: 12px;
  background: none;
  border: none;
  cursor: pointer;
  color: #999;
  padding: 4px;
}

.alert-icon-container {
  flex-shrink: 0;
}

.alert-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 20px;
}

.alert-icon-red {
  background: #ffebee;
  color: #d32f2f;
}

.alert-icon-yellow {
  background: #fff3e0;
  color: #f57c00;
}

.alert-icon-blue {
  background: #e3f2fd;
  color: #1976d2;
}

.alert-content {
  flex: 1;
}

.alert-title-row {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 8px;
}

.alert-title-row h3 {
  font-size: 16px;
  font-weight: 600;
}

.priority-tag {
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
}

.priority-critical {
  background: #ffebee;
  color: #d32f2f;
}

.priority-actionable {
  background: #fff3e0;
  color: #f57c00;
}

.priority-informational {
  background: #e3f2fd;
  color: #1976d2;
}

.alert-description {
  color: #666;
  margin-bottom: 12px;
  line-height: 1.5;
}

.alert-meta {
  display: flex;
  gap: 16px;
  color: #999;
  font-size: 13px;
  margin-bottom: 16px;
}

.alert-actions {
  display: flex;
  gap: 12px;
}
CSS

    File.write(
      File.join(@ui_dir, 'styles', 'app.css'),
      styles
    )
    
    puts colorize("  ✓ UI components installed", :success)
  end

  def install_backend_services
    puts colorize("\n⚙️  Installing backend services...", :primary)
    
    # Mode Router Service
    mode_router = <<~'RUBY'
# services/mode_router.rb
# Routes queries to appropriate mode based on intent analysis

require 'json'

class ModeRouter
  QUESTION_WORDS = %w[what why how when where which who whose whom]
  ACTION_WORDS = %w[do change update execute approve fix create delete add remove]
  ALERT_WORDS = %w[alert notification issue critical problem blocker]

  def self.route(message)
    message_lower = message.downcase
    
    # Check for explicit mode requests
    return :alert if message_lower.include?('alert') || message_lower.include?('notification')
    return :act if contains_action_intent?(message_lower)
    return :ask if contains_question_intent?(message_lower)
    
    # Default to ask mode
    :ask
  end

  def self.contains_question_intent?(message)
    QUESTION_WORDS.any? { |word| message.start_with?(word) }
  end

  def self.contains_action_intent?(message)
    ACTION_WORDS.any? { |word| message.include?(word) }
  end
end
RUBY

    File.write(
      File.join(@services_dir, 'mode_router.rb'),
      mode_router
    )
    
    # Action Executor Service
    action_executor = <<~'RUBY'
# services/action_executor.rb
# Validates and executes approved actions

require 'json'
require 'securerandom'

class ActionExecutor
  def self.execute(action_id, approval_token, execution_params = {})
    # Validate approval token
    unless valid_approval?(action_id, approval_token)
      return {
        success: false,
        error: 'Invalid approval token'
      }
    end

    # Load action details
    action = load_action(action_id)
    
    # Execute via appropriate backend
    result = case action[:type]
    when 'price_change'
      execute_price_change(action, execution_params)
    when 'schedule_update'
      execute_schedule_update(action, execution_params)
    when 'inventory_adjustment'
      execute_inventory_adjustment(action, execution_params)
    else
      { success: false, error: 'Unknown action type' }
    end

    # Log audit trail
    log_execution(action_id, result)

    result
  end

  def self.valid_approval?(action_id, token)
    # In production, validate against secure token store
    !token.nil? && !token.empty?
  end

  def self.load_action(action_id)
    # In production, load from database
    {
      id: action_id,
      type: 'price_change',
      details: {}
    }
  end

  def self.execute_price_change(action, params)
    # Call pricing API
    {
      success: true,
      execution_id: SecureRandom.uuid,
      executed_at: Time.now.iso8601
    }
  end

  def self.execute_schedule_update(action, params)
    # Call scheduling API
    {
      success: true,
      execution_id: SecureRandom.uuid,
      executed_at: Time.now.iso8601
    }
  end

  def self.execute_inventory_adjustment(action, params)
    # Call inventory API
    {
      success: true,
      execution_id: SecureRandom.uuid,
      executed_at: Time.now.iso8601
    }
  end

  def self.log_execution(act_id, result)
    # Log to audit system
    puts "[AUDIT] Action #{act_id}: #{result[:success] ? 'SUCCESS' : 'FAILED'}"
  end
end
RUBY

    File.write(
      File.join(@services_dir, 'action_executor.rb'),
      action_executor
    )
    
    # Alert Monitor Service
    alert_monitor = <<~'RUBY'
# services/alert_monitor.rb
# Background monitoring and alert generation

require 'json'
require 'securerandom'

class AlertMonitor
  def self.create_alert(title:, description:, priority:, source:, action_items: [])
    alert = {
      id: "ALT#{SecureRandom.hex(6)}",
      title: title,
      description: description,
      priority: priority,
      source: source,
      action_items: action_items,
      created_at: Time.now.iso8601,
      status: 'active'
    }

    # Store alert (in production, save to database)
    store_alert(alert)

    # Send notifications based on priority
    send_notifications(alert)

    alert
  end

  def self.get_active_alerts(filters = {})
    # In production, query from database
    []
  end

  def self.dismiss_alert(alert_id, resolution_notes)
    # In production, update database
    {
      alert_id: alert_id,
      dismissed_at: Time.now.iso8601,
      resolution_notes: resolution_notes
    }
  end

  private

  def self.store_alert(alert)
    # Store in database
    puts "[ALERT CREATED] #{alert[:priority].upcase}: #{alert[:title]}"
  end

  def self.send_notifications(alert)
    # Send based on priority
    case alert[:priority]
    when 'critical'
      # Send SMS, email, and in-app
      puts "[NOTIFICATION] Sending critical alert via SMS, email, in-app"
    when 'actionable'
      # Send email and in-app
      puts "[NOTIFICATION] Sending actionable alert via email, in-app"
    when 'informational'
      # Send in-app only
      puts "[NOTIFICATION] Sending informational alert via in-app"
    end
  end
end
RUBY

    File.write(
      File.join(@services_dir, 'alert_monitor.rb'),
      alert_monitor
    )
    
    # Update main app.rb with new routes
    app_routes = <<~'RUBY'
# Add to app/app.rb

require_relative 'services/mode_router'
require_relative 'services/action_executor'
require_relative 'services/alert_monitor'

# Ask Mode Endpoint
post '/api/ask' do
  content_type :json
  
  message = params[:message]
  
  # Route through mode orchestrator
  mode = ModeRouter.route(message)
  
  # Process through Ask mode handler
  # Call MCP tools as needed
  # Return conversational response
  
  {
    success: true,
    mode: mode,
    response: "This is a response from Ask mode",
    tool_calls: []
  }.to_json
end

# Get Actions
get '/api/actions' do
  content_type :json
  
  {
    pending: [],
    completed: []
  }.to_json
end

# Execute Action
post '/api/actions/:id/execute' do
  content_type :json
  
  action_id = params[:id]
  approval_token = request.env['HTTP_AUTHORIZATION']
  
  result = ActionExecutor.execute(action_id, approval_token)
  
  result.to_json
end

# Get Alerts
get '/api/alerts' do
  content_type :json
  
  filters = {
    priority: params[:priority],
    time_range_hours: params[:time_range_hours]&.to_i || 24
  }
  
  alerts = AlertMonitor.get_active_alerts(filters)
  
  { alerts: alerts }.to_json
end

# Create Alert
post '/api/alerts' do
  content_type :json
  
  data = JSON.parse(request.body.read)
  
  alert = AlertMonitor.create_alert(
    title: data['title'],
    description: data['description'],
    priority: data['priority'],
    source: data['source'],
    action_items: data['action_items'] || []
  )
  
  { alert: alert }.to_json
end

# Dismiss Alert
post '/api/alerts/:id/dismiss' do
  content_type :json
  
  alert_id = params[:id]
  data = JSON.parse(request.body.read)
  
  result = AlertMonitor.dismiss_alert(alert_id, data['resolution_notes'])
  
  result.to_json
end
RUBY

    File.write(
      File.join(@app_dir, 'routes_addition.rb'),
      app_routes
    )
    
    puts colorize("  ✓ Backend services installed", :success)
    puts colorize("  ⚠️  Note: Add routes_addition.rb content to app.rb manually", :warning)
  end

  def install_database_schema
    puts colorize("\n💾 Installing database schema...", :primary)
    
    schema_sql = <<~SQL
-- Carina Database Schema

-- Actions Table
CREATE TABLE IF NOT EXISTS actions (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT CHECK(priority IN ('critical', 'high', 'normal')),
  status TEXT CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')),
  type TEXT NOT NULL,
  store_id TEXT,
  financial_impact_usd DECIMAL(10,2),
  approval_level TEXT,
  approval_token TEXT,
  approver_id TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved_at TIMESTAMP,
  executed_at TIMESTAMP,
  completed_at TIMESTAMP,
  execution_params JSON,
  outcome JSON,
  audit_trail JSON
);

CREATE INDEX idx_actions_status ON actions(status);
CREATE INDEX idx_actions_priority ON actions(priority);
CREATE INDEX idx_actions_store ON actions(store_id);

-- Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT CHECK(priority IN ('critical', 'actionable', 'informational')),
  status TEXT CHECK(status IN ('active', 'in_progress', 'resolved', 'dismissed')),
  source TEXT NOT NULL,
  affected_scope JSON,
  action_items JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,
  dismissed_at TIMESTAMP,
  resolution_type TEXT,
  resolution_notes TEXT,
  notifications_sent JSON
);

CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_priority ON alerts(priority);
CREATE INDEX idx_alerts_created ON alerts(created_at);

-- Conversations Table
CREATE TABLE IF NOT EXISTS conversations (
  id TEXT PRIMARY KEY,
  mode TEXT CHECK(mode IN ('ask', 'act', 'alert')),
  user_id TEXT NOT NULL,
  store_id TEXT,
  messages JSON,
  tool_calls JSON,
  context JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_mode ON conversations(mode);

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_log (
  id TEXT PRIMARY KEY,
  event_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  user_id TEXT,
  action TEXT,
  changes JSON,
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_created ON audit_log(created_at);
SQL

    File.write(
      File.join(@db_dir, 'schema.sql'),
      schema_sql
    )
    
    # Setup script
    setup_script = <<~'RUBY'
#!/usr/bin/env ruby
# db/setup_database.rb

require 'sqlite3'

DB_PATH = File.join(__dir__, 'carina.db')

puts "Setting up Carina database..."

db = SQLite3::Database.new(DB_PATH)

schema = File.read(File.join(__dir__, 'schema.sql'))

db.execute_batch(schema)

puts "✓ Database created at #{DB_PATH}"
puts "✓ Tables created: actions, alerts, conversations, audit_log"

# Seed some sample data
db.execute(<<~SQL)
  INSERT INTO actions (id, title, description, priority, status, type, store_id)
  VALUES (
    'ACT001',
    '35% Markdown on Organic Strawberries',
    '24 units expiring tomorrow, slow sales velocity',
    'high',
    'pending',
    'price_change',
    'PAR001'
  )
SQL

db.execute(<<~SQL)
  INSERT INTO alerts (id, title, description, priority, status, source)
  VALUES (
    'ALT001',
    'Critical Priority Task Blocker',
    'Q4 Planning Review is blocked due to resource constraints',
    'critical',
    'active',
    'Task Monitor'
  )
SQL

puts "✓ Sample data seeded"
puts ""
puts "Database ready!"

db.close
RUBY

    File.write(
      File.join(@db_dir, 'setup_database.rb'),
      setup_script
    )
    
    FileUtils.chmod(0755, File.join(@db_dir, 'setup_database.rb'))
    
    puts colorize("  ✓ Database schema installed", :success)
  end

  def install_configuration
    puts colorize("\n⚙️  Installing configuration files...", :primary)
    
    carina_config = {
      version: "1.0",
      modes: {
        ask: {
          enabled: true,
          default_tools: [
            "get_inventory_status",
            "query_sales_velocity",
            "get_staff_allocation",
            "search_knowledge_base"
          ],
          max_context_messages: 10,
          streaming_enabled: true
        },
        act: {
          enabled: true,
          approval_required: true,
          default_tools: [
            "get_pending_actions",
            "execute_action",
            "complete_action"
          ],
          auto_refresh_seconds: 60
        },
        alert: {
          enabled: true,
          auto_refresh_seconds: 30,
          default_tools: [
            "get_active_alerts",
            "create_alert",
            "dismiss_alert"
          ],
          notification_settings: {
            critical: ["sms", "email", "in_app"],
            actionable: ["email", "in_app"],
            informational: ["in_app"]
          }
        }
      },
      api: {
        base_url: "http://localhost:4567",
        timeout_seconds: 30
      },
      ui: {
        theme: "light",
        enable_voice_input: true,
        show_tool_calls: true
      }
    }
    
    File.write(
      File.join(@config_dir, 'carina-config.json'),
      JSON.pretty_generate(carina_config)
    )
    
    puts colorize("  ✓ Configuration files installed", :success)
  end

  def generate_documentation
    puts colorize("\n📚 Generating documentation...", :primary)
    
    html_doc = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Carina Multi-Mode System - Installation Manifest</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      line-height: 1.6;
      color: #333;
      background: #f5f5f5;
      padding: 40px 20px;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: white;
      padding: 40px;
      border-radius: 12px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.1);
    }
    h1 {
      font-size: 36px;
      margin-bottom: 12px;
      color: #1a1a1a;
    }
    .subtitle {
      font-size: 18px;
      color: #666;
      margin-bottom: 40px;
    }
    h2 {
      font-size: 28px;
      margin: 40px 0 20px;
      color: #1a1a1a;
      border-bottom: 2px solid #e0e0e0;
      padding-bottom: 12px;
    }
    h3 {
      font-size: 22px;
      margin: 28px 0 16px;
      color: #333;
    }
    h4 {
      font-size: 18px;
      margin: 20px 0 12px;
      color: #555;
    }
    ul, ol {
      margin-left: 24px;
      margin-bottom: 20px;
    }
    li {
      margin-bottom: 8px;
    }
    .section {
      margin-bottom: 40px;
    }
    .component {
      background: #f9f9f9;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      border-left: 4px solid #1976d2;
    }
    .file-list {
      background: #f9f9f9;
      padding: 16px;
      border-radius: 6px;
      margin: 12px 0;
      font-family: 'Courier New', monospace;
      font-size: 14px;
    }
    .status {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 600;
      margin-left: 8px;
    }
    .status-new { background: #e8f5e9; color: #388e3c; }
    .status-modified { background: #fff3e0; color: #f57c00; }
    .status-required { background: #ffebee; color: #d32f2f; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #e0e0e0;
    }
    th {
      background: #f5f5f5;
      font-weight: 600;
    }
    code {
      background: #f5f5f5;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
      font-size: 14px;
    }
    .workflow {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 24px;
      border-radius: 8px;
      margin: 24px 0;
    }
    .workflow h3 {
      color: white;
      margin-top: 0;
    }
    .note {
      background: #e3f2fd;
      border-left: 4px solid #1976d2;
      padding: 16px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .warning {
      background: #fff3e0;
      border-left: 4px solid #f57c00;
      padding: 16px;
      margin: 20px 0;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🤖 Carina Multi-Mode Agentic AI System</h1>
    <p class="subtitle">Complete Installation Manifest & Asset Guide</p>

    <div class="section">
      <h2>📋 Overview</h2>
      <p>Carina is a multi-mode agentic AI system for retail operations with three distinct modes:</p>
      <ul>
        <li><strong>Ask Mode:</strong> Query engine for operational insights and information</li>
        <li><strong>Act Mode:</strong> Action recommendation and execution engine</li>
        <li><strong>Alert Mode:</strong> Monitoring and notification system</li>
      </ul>
    </div>

    <div class="section">
      <h2>🏗️ System Architecture</h2>
      <div class="workflow">
        <h3>Information Flow</h3>
        <pre style="color: white; line-height: 1.8;">
User Input
    ↓
Mode Orchestrator (Routes to appropriate mode)
    ↓
Mode-Specific Handler (Ask/Act/Alert)
    ↓
System Prompt + Policies
    ↓
MCP Tools (Via MCP Server)
    ↓
Backend APIs & Databases
    ↓
Response with Actions/Insights/Alerts
        </pre>
      </div>
    </div>

    <div class="section">
      <h2>📁 Component Inventory</h2>

      <div class="component">
        <h3>1. System Prompts <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>prompts/</code></p>
        <div class="file-list">
prompts/
├── carina-ask-mode.txt
├── carina-act-mode.txt
├── carina-alert-mode.txt
└── carina-mode-orchestrator.txt
        </div>
        <p><strong>Purpose:</strong> Define behavior, decision frameworks, and response patterns for each mode.</p>
      </div>

      <div class="component">
        <h3>2. Policy Documents <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>policies/</code></p>
        <div class="file-list">
policies/
├── alert-escalation-policy.json
├── action-approval-policy.json
└── task-monitoring-policy.json
        </div>
        <p><strong>Purpose:</strong> Business rules for approvals, escalation, and monitoring thresholds.</p>
      </div>

      <div class="component">
        <h3>3. Example Scenarios <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>examples/</code></p>
        <div class="file-list">
examples/
├── ask-mode-examples.txt
├── act-mode-examples.txt
└── alert-mode-examples.txt
        </div>
        <p><strong>Purpose:</strong> Few-shot examples demonstrating correct reasoning and tool usage patterns.</p>
      </div>

      <div class="component">
        <h3>4. MCP Server Tools <span class="status status-modified">MODIFIED</span></h3>
        <p><strong>Location:</strong> <code>mcp-server/</code></p>
        <div class="file-list">
mcp-server/
├── src/
│   ├── index.ts (existing)
│   └── tools/
│       └── carina-tools.ts (NEW)
└── config/
    └── tools-registry.json (NEW)
        </div>
        <p><strong>New Tools Added:</strong></p>
        <ul>
          <li>get_pending_actions</li>
          <li>execute_action</li>
          <li>complete_action</li>
          <li>create_alert</li>
          <li>get_active_alerts</li>
          <li>dismiss_alert</li>
          <li>search_knowledge_base</li>
          <li>get_staff_allocation</li>
          <li>analyze_task_dependencies</li>
        </ul>
      </div>

      <div class="component">
        <h3>5. UI Components <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>ui/</code></p>
        <div class="file-list">
ui/
├── components/
│   ├── ModeSelector.jsx
│   ├── AskInterface.jsx
│   ├── ActInterface.jsx
│   └── AlertInterface.jsx
├── styles/
│   └── app.css
├── App.jsx
└── package.json
        </div>
        <p><strong>Purpose:</strong> React-based frontend implementing the three-mode interface.</p>
      </div>

      <div class="component">
        <h3>6. Backend Services <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>app/services/</code></p>
        <div class="file-list">
app/services/
├── mode_router.rb
├── action_executor.rb
└── alert_monitor.rb
        </div>
        <p><strong>Purpose:</strong> Ruby services for routing, action execution, and alert management.</p>
      </div>

      <div class="component">
        <h3>7. Database Schema <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>db/</code></p>
        <div class="file-list">
db/
├── schema.sql
└── setup_database.rb
        </div>
        <p><strong>Tables:</strong></p>
        <ul>
          <li>actions (pending and completed actions)</li>
          <li>alerts (active and resolved alerts)</li>
          <li>conversations (chat history by mode)</li>
          <li>audit_log (full audit trail)</li>
        </ul>
      </div>

      <div class="component">
        <h3>8. Configuration <span class="status status-new">NEW</span></h3>
        <p><strong>Location:</strong> <code>config/</code></p>
        <div class="file-list">
config/
└── carina-config.json
        </div>
        <p><strong>Purpose:</strong> Central configuration for modes, tools, API settings, and UI preferences.</p>
      </div>
    </div>

    <div class="section">
      <h2>🔧 API Endpoints</h2>
      <table>
        <thead>
          <tr>
            <th>Endpoint</th>
            <th>Method</th>
            <th>Purpose</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>/api/ask</code></td>
            <td>POST</td>
            <td>Process Ask mode queries</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
          <tr>
            <td><code>/api/actions</code></td>
            <td>GET</td>
            <td>Retrieve pending/completed actions</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
          <tr>
            <td><code>/api/actions/:id/execute</code></td>
            <td>POST</td>
            <td>Execute approved action</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
          <tr>
            <td><code>/api/alerts</code></td>
            <td>GET</td>
            <td>Retrieve active alerts</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
          <tr>
            <td><code>/api/alerts</code></td>
            <td>POST</td>
            <td>Create new alert</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
          <tr>
            <td><code>/api/alerts/:id/dismiss</code></td>
            <td>POST</td>
            <td>Dismiss/resolve alert</td>
            <td><span class="status status-new">NEW</span></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="section">
      <h2>➕ Adding New Scenarios</h2>
      <p>When adding a new scenario (e.g., "Staff scheduling optimization"), you need to create/modify:</p>

      <h3>Required Assets:</h3>
      <ol>
        <li>
          <strong>System Prompt Addition</strong>
          <p>Add scenario-specific guidance to the relevant mode prompt</p>
          <div class="file-list">prompts/carina-ask-mode.txt (or act-mode.txt or alert-mode.txt)</div>
        </li>
        <li>
          <strong>Policy Document</strong>
          <p>Define business rules and constraints</p>
          <div class="file-list">policies/staff-scheduling-policy.json</div>
        </li>
        <li>
          <strong>Example Scenarios</strong>
          <p>Create few-shot examples</p>
          <div class="file-list">examples/staff-scheduling-examples.txt</div>
        </li>
        <li>
          <strong>MCP Tool(s)</strong>
          <p>Add new tool to MCP server if needed</p>
          <div class="file-list">mcp-server/src/tools/carina-tools.ts</div>
          <code>
{
  name: "optimize_staff_schedule",
  description: "Generate optimized staff schedule",
  inputSchema: { ... }
}
          </code>
        </li>
        <li>
          <strong>Backend Service Logic</strong>
          <p>Implement business logic if complex</p>
          <div class="file-list">app/services/staff_scheduler.rb</div>
        </li>
        <li>
          <strong>Database Migration</strong> <span class="status status-required">IF NEEDED</span>
          <p>Add tables/columns if new data types required</p>
          <div class="file-list">db/migrations/add_staff_schedules.sql</div>
        </li>
      </ol>

      <div class="note">
        <strong>💡 Quick Add Checklist:</strong>
        <ul style="margin-top: 12px;">
          <li>☐ Update relevant mode prompt (prompts/)</li>
          <li>☐ Create policy document (policies/)</li>
          <li>☐ Add example scenarios (examples/)</li>
          <li>☐ Implement MCP tool if needed (mcp-server/)</li>
          <li>☐ Add service logic if complex (app/services/)</li>
          <li>☐ Update database schema if needed (db/)</li>
          <li>☐ Test with few-shot examples</li>
          <li>☐ Update documentation</li>
        </ul>
      </div>
    </div>

    <div class="section">
      <h2>🚀 Installation Steps</h2>
      <ol>
        <li>Run installation script: <code>ruby install_carina_system.rb</code></li>
        <li>Install UI dependencies: <code>cd ui && npm install</code></li>
        <li>Install MCP server dependencies: <code>cd mcp-server && npm install && npm run build</code></li>
        <li>Setup database: <code>ruby db/setup_database.rb</code></li>
        <li>Manually merge routes: Add content from <code>app/routes_addition.rb</code> to <code>app/app.rb</code></li>
        <li>Start backend: <code>cd app && ruby app.rb</code></li>
        <li>Start UI (separate terminal): <code>cd ui && npm run dev</code></li>
        <li>Open browser: <code>http://localhost:4567</code></li>
      </ol>
    </div>

    <div class="section">
      <h2>📊 Testing</h2>
      <h3>Test Each Mode:</h3>
      
      <h4>Ask Mode:</h4>
      <ul>
        <li>"Which stores need additional staff this weekend?"</li>
        <li>"What's the status of organic produce inventory?"</li>
        <li>"How does our pricing compare to competitors?"</li>
      </ul>

      <h4>Act Mode:</h4>
      <ul>
        <li>Check for pending actions in the interface</li>
        <li>Click "Take Action" on a recommendation</li>
        <li>Verify approval routing works correctly</li>
      </ul>

      <h4>Alert Mode:</h4>
      <ul>
        <li>Create a test alert via API or monitoring service</li>
        <li>Verify alert appears with correct priority</li>
        <li>Test dismiss functionality</li>
      </ul>
    </div>

    <div class="warning">
      <strong>⚠️ Important Notes:</strong>
      <ul style="margin-top: 12px;">
        <li>Backend services currently use mock data - connect to real databases and APIs in production</li>
        <li>MCP tools require backend API endpoints to be configured</li>
        <li>Update <code>app/app.rb</code> manually with routes from <code>app/routes_addition.rb</code></li>
        <li>Configure authentication and authorization before production deployment</li>
      </ul>
    </div>

    <div class="section">
      <h2>📖 Additional Resources</h2>
      <ul>
        <li><strong>System Prompts:</strong> See <code>prompts/</code> directory for detailed mode behaviors</li>
        <li><strong>Policy Reference:</strong> See <code>policies/</code> for complete business rules</li>
        <li><strong>API Documentation:</strong> See <code>docs/api-reference.md</code> (to be created)</li>
        <li><strong>Deployment Guide:</strong> See <code>deployment-manifest.json</code></li>
      </ul>
    </div>

    <div style="margin-top: 60px; padding-top: 20px; border-top: 2px solid #e0e0e0; color: #999; text-align: center;">
      <p>Generated by Carina Installation System v1.0.0</p>
      <p>Installation Date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
  </div>
</body>
</html>
HTML

    File.write(
      File.join(@docs_dir, 'installation-manifest.html'),
      html_doc
    )
    
    puts colorize("  ✓ Documentation generated", :success)
  end

  def colorize(text, color)
    "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end
end

if __FILE__ == $0
  installer = CarinaInstaller.new
  installer.install
end
