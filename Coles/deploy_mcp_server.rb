#!/usr/bin/env ruby
# Version: 1.0.0

require 'json'
require 'fileutils'
require 'open3'

class AgenticAIDeployer
  COLORS = {
    primary: "\e[36m",
    success: "\e[32m",
    warning: "\e[33m",
    error: "\e[31m",
    reset: "\e[0m"
  }

  def initialize
    @project_root = File.expand_path('retail-agentic-ai')
    @mcp_server_dir = File.join(@project_root, 'mcp-server')
    @prompts_dir = File.join(@project_root, 'prompts')
    @policies_dir = File.join(@project_root, 'policies')
    @examples_dir = File.join(@project_root, 'examples')
    @build_dir = File.join(@mcp_server_dir, 'build')
    @config_file = File.expand_path('~/.config/mcp/servers.json')
  end

  def deploy
    puts colorize("🚀 Starting Complete Agentic AI Deployment", :primary)
    puts colorize("   This deploys: System Prompts + Policies + Examples + MCP Server", :primary)
    
    check_prerequisites
    create_project_structure
    generate_system_prompts
    generate_policy_documents
    generate_few_shot_examples
    generate_mcp_package_json
    generate_tsconfig
    generate_mcp_server_code
    install_dependencies
    build_server
    configure_mcp_client
    generate_deployment_manifest
    
    puts colorize("\n✨ Complete deployment finished!", :success)
    puts colorize("📁 Project location: #{@project_root}", :success)
    puts colorize("📋 See deployment-manifest.json for details", :success)
  end

  private

  def check_prerequisites
    puts colorize("\n📋 Checking prerequisites...", :primary)
    
    check_command('node', 'Node.js is required. Install from https://nodejs.org')
    check_command('npm', 'npm is required. Install Node.js to get npm')
    
    puts colorize("✓ All prerequisites met", :success)
  end

  def check_command(cmd, error_msg)
    stdout, stderr, status = Open3.capture3("which #{cmd}")
    unless status.success?
      puts colorize("✗ #{error_msg}", :error)
      exit 1
    end
    puts colorize("  ✓ #{cmd} found", :success)
  end

  def create_project_structure
    puts colorize("\n📁 Creating project structure...", :primary)
    
    [
      @project_root,
      @mcp_server_dir,
      File.join(@mcp_server_dir, 'src'),
      @build_dir,
      @prompts_dir,
      @policies_dir,
      @examples_dir
    ].each { |dir| FileUtils.mkdir_p(dir) }
    
    puts colorize("✓ Project structure created", :success)
  end

  def generate_system_prompts
    puts colorize("\n📝 Generating system prompts...", :primary)
    
    system_prompt = <<~PROMPT
      You are a produce optimization agent for a retail grocery operation. Your role is to analyze inventory, sales velocity, quality timelines, and market conditions to recommend markdown decisions that minimize waste while protecting margin.

      CAPABILITIES:
      - Access real-time inventory levels and expiration dates
      - Query sales history and velocity trends
      - Retrieve competitor pricing and local market conditions
      - Check weather forecasts and local events
      - Validate pricing changes against margin policies
      - Submit approved markdowns to POS systems

      DECISION FRAMEWORK:
      When evaluating markdown recommendations, consider:
      1. Days until quality degradation or expiration
      2. Current sales velocity vs. historical baseline
      3. Margin impact of markdown vs. shrinkage cost
      4. Competitive pricing in local market
      5. Upcoming supply deliveries
      6. Store traffic patterns and local events

      CONSTRAINTS:
      - Never recommend markdowns that violate minimum margin thresholds
      - All pricing changes require policy engine approval before POS update
      - Flag decisions involving >$500 potential waste for human review
      - Maintain audit trail of all recommendations and outcomes

      OUTPUT FORMAT:
      - State clear recommendation (Yes/No with specific markdown %)
      - Provide quantitative justification (units, timeline, financial impact)
      - Highlight key trade-offs or risks
      - Identify required approvals or deterministic actions
      - Suggest follow-up monitoring if needed

      TONE:
      Direct, analytical, focused on actionable decisions. Surface uncertainty explicitly rather than overconfident predictions.
    PROMPT
    
    File.write(
      File.join(@prompts_dir, 'produce-optimization-agent.txt'),
      system_prompt
    )
    
    readme = <<~README
      # System Prompts

      This directory contains the system prompts that define the agent's role, capabilities, and behavior.

      ## Files

      - `produce-optimization-agent.txt`: Main system prompt for the produce optimization agent

      ## Usage

      These prompts should be loaded at agent initialization time and remain constant throughout the agent's operation. The prompt defines:

      1. Role and purpose
      2. Available capabilities (tools)
      3. Decision-making framework
      4. Operational constraints
      5. Output formatting requirements
      6. Communication tone and style

      ## Updating Prompts

      When updating system prompts:
      - Version the prompt file (e.g., produce-optimization-agent-v2.txt)
      - Test thoroughly in staging environment
      - Document changes in version control
      - Monitor agent behavior after deployment
      - Maintain rollback capability
    README
    
    File.write(
      File.join(@prompts_dir, 'README.md'),
      readme
    )
    
    puts colorize("✓ System prompts generated", :success)
  end

  def generate_policy_documents
    puts colorize("\n📋 Generating policy documents...", :primary)
    
    markdown_policy = <<~POLICY
      PRODUCE MARKDOWN POLICY

      Minimum Margin Thresholds:
      - Organic produce: 15% minimum margin after markdown
      - Conventional produce: 12% minimum margin after markdown
      - Pre-packaged salads: 10% minimum margin after markdown

      Approval Requirements:
      - Markdowns <20%: Automatic approval if margin threshold met
      - Markdowns 20-40%: Store manager notification required
      - Markdowns >40%: Regional manager approval required
      - Estimated waste >$500: Regional manager approval required

      Quality Guidelines:
      - Items within 1 day of expiration: Markdown to move inventory
      - Items showing visible quality degradation: Remove from floor
      - Items with supplier quality issues: Document and escalate to procurement

      Competitive Response:
      - Match competitor pricing if margin threshold maintained
      - Flag sustained competitor underpricing for category review
      - Coordinate multi-store response for regional competitive threats

      Audit Requirements:
      - All markdown decisions must be logged with rationale
      - Include: product ID, original price, new price, reason code, approval chain
      - Retain records for 2 years for compliance review
      - Weekly reporting to category managers on markdown effectiveness
    POLICY
    
    File.write(
      File.join(@policies_dir, 'produce-markdown-policy.txt'),
      markdown_policy
    )
    
    markdown_policy_json = {
      policy_name: "Produce Markdown Policy",
      version: "1.0",
      effective_date: "2025-01-01",
      margin_thresholds: {
        organic_produce: { minimum_margin_pct: 15 },
        conventional_produce: { minimum_margin_pct: 12 },
        prepackaged_salads: { minimum_margin_pct: 10 }
      },
      approval_rules: [
        { markdown_pct_min: 0, markdown_pct_max: 20, approval_level: "automatic", condition: "margin_threshold_met" },
        { markdown_pct_min: 20, markdown_pct_max: 40, approval_level: "store_manager", notification_required: true },
        { markdown_pct_min: 40, markdown_pct_max: 100, approval_level: "regional_manager", escalation_required: true },
        { estimated_waste_usd_min: 500, approval_level: "regional_manager", escalation_required: true }
      ],
      quality_actions: {
        days_to_expiration: {
          "1": "markdown_to_move",
          "0": "remove_from_floor"
        },
        visible_degradation: "remove_from_floor",
        supplier_issues: "document_and_escalate"
      }
    }
    
    File.write(
      File.join(@policies_dir, 'produce-markdown-policy.json'),
      JSON.pretty_generate(markdown_policy_json)
    )
    
    readme = <<~README
      # Policy Documents

      This directory contains business rules and operational policies that guide agent decision-making.

      ## Files

      - `produce-markdown-policy.txt`: Human-readable markdown policy
      - `produce-markdown-policy.json`: Machine-readable policy rules

      ## Policy Structure

      Policies define:
      1. Business rules (margin thresholds, approval workflows)
      2. Operational constraints (quality guidelines, competitive response)
      3. Compliance requirements (audit trails, reporting)

      ## Policy Enforcement

      - Policies are enforced through MCP tool validation
      - The pricing policy engine validates all requests deterministically
      - Agent cannot bypass policy rules
      - All policy violations are logged and flagged

      ## Updating Policies

      Policy changes require:
      1. Update both .txt and .json versions
      2. Increment version number
      3. Deploy to staging environment first
      4. Test with historical scenarios
      5. Coordinate deployment with operations team
      6. Monitor for policy conflicts or gaps
    README
    
    File.write(
      File.join(@policies_dir, 'README.md'),
      readme
    )
    
    puts colorize("✓ Policy documents generated", :success)
  end

  def generate_few_shot_examples
    puts colorize("\n💡 Generating few-shot examples...", :primary)
    
    example_1 = <<~EXAMPLE
      EXAMPLE DECISION: Organic Blueberries Markdown

      Query: "Should we mark down organic blueberries today?"

      Agent reasoning:
      - Current inventory: 32 units, cost $4.50, shelf price $7.99
      - Sales velocity: 8 units/day average, only 4 units sold today
      - Expiration: 2 days remaining
      - Competitor pricing: Farmers market selling at $6.49
      - Weather: Rain forecast reduces foot traffic tomorrow
      - Supply schedule: No delivery for 3 days

      Analysis:
      At current velocity, 16 units remain at expiration (50% waste = $72 loss).
      Markdown to $5.99 (25% reduction) maintains 25% margin above policy minimum.
      Competitive with farmers market pricing.
      Estimated recovery: 24 units sold = $144 revenue vs. $72 waste.

      Recommendation: Yes, mark down to $5.99 today.
      Financial impact: $64 margin recovered vs. shrinkage alternative.
      Required actions: Submit to pricing policy engine, update POS if approved, monitor sales at 6pm for further adjustment.

      Tool calls executed:
      1. get_inventory_status(product_id="BLU-ORG-6OZ", store_id="STORE-001")
      2. query_sales_velocity(product_id="BLU-ORG-6OZ", store_id="STORE-001", days_back=7)
      3. get_competitor_pricing(category="berries", store_location="STORE-001")
      4. check_pricing_policy(product_id="BLU-ORG-6OZ", current_price=7.99, proposed_price=5.99, reason_code="expiration")
      5. submit_price_change(product_id="BLU-ORG-6OZ", store_id="STORE-001", new_price=5.99, approval_token="...")
    EXAMPLE
    
    example_2 = <<~EXAMPLE
      EXAMPLE DECISION: Pre-packaged Salad - No Markdown

      Query: "Should we mark down Caesar salad kits today?"

      Agent reasoning:
      - Current inventory: 18 units, cost $2.25, shelf price $4.99
      - Sales velocity: 6 units/day average, 7 units sold today
      - Expiration: 3 days remaining
      - Competitor pricing: No local competition for this SKU
      - Weather: Clear forecast, high foot traffic expected
      - Supply schedule: Delivery tomorrow (20 units)

      Analysis:
      At current velocity, all 18 units will sell before expiration with normal traffic.
      Markdown would reduce margin without preventing waste.
      Delivery tomorrow provides buffer for any velocity changes.
      Current price maintains healthy 55% margin vs. 10% policy minimum.

      Recommendation: No, maintain current price.
      Rationale: Strong velocity and sufficient days to expiration. Monitor daily.
      Required actions: Set reminder to reassess if velocity drops below 5 units/day or if units remain at 1 day before expiration.

      Tool calls executed:
      1. get_inventory_status(product_id="SAL-CAES-12OZ", store_id="STORE-001", include_supply_schedule=true)
      2. query_sales_velocity(product_id="SAL-CAES-12OZ", store_id="STORE-001", days_back=7)
    EXAMPLE
    
    example_3 = <<~EXAMPLE
      EXAMPLE DECISION: Competitive Response - Strawberries

      Query: "Competitor just dropped strawberry prices to $2.99. What should we do?"

      Agent reasoning:
      - Current inventory: 45 units, cost $2.00, shelf price $4.99
      - Sales velocity: 12 units/day average, only 3 units sold today
      - Expiration: 2 days remaining
      - Competitor pricing: Across the street now at $2.99 (40% below our price)
      - Weather: Normal conditions
      - Supply schedule: No delivery for 4 days

      Analysis:
      Competitor pricing is depressing our velocity significantly (75% below average).
      At reduced velocity, 21 units remain at expiration (47% waste = $42 loss).
      Matching competitor at $2.99 maintains 33% margin (well above 12% minimum).
      Competitive match likely recovers velocity to historical baseline.
      Estimated recovery at $2.99: 36 units sold = $108 revenue vs. $42 waste.

      Recommendation: Yes, match competitor price at $2.99.
      Financial impact: $66 margin recovered vs. shrinkage alternative.
      Strategic note: Flag to category manager - sustained underpricing requires regional response.
      Required actions: Submit to pricing policy engine, update POS if approved, notify store manager per policy (>40% markdown), monitor competitor pricing daily.

      Tool calls executed:
      1. get_inventory_status(product_id="STR-CONV-16OZ", store_id="STORE-001")
      2. query_sales_velocity(product_id="STR-CONV-16OZ", store_id="STORE-001", days_back=7)
      3. get_competitor_pricing(category="berries", store_location="STORE-001")
      4. check_pricing_policy(product_id="STR-CONV-16OZ", current_price=4.99, proposed_price=2.99, reason_code="competition")
    EXAMPLE
    
    [
      ['blueberries-markdown.txt', example_1],
      ['salad-no-markdown.txt', example_2],
      ['strawberries-competitive-response.txt', example_3]
    ].each do |filename, content|
      File.write(File.join(@examples_dir, filename), content)
    end
    
    readme = <<~README
      # Few-Shot Examples

      This directory contains example decision scenarios that demonstrate correct agent reasoning patterns.

      ## Purpose

      Few-shot examples serve as training data to:
      1. Show correct reasoning patterns
      2. Demonstrate proper tool usage
      3. Illustrate decision quality standards
      4. Provide templates for edge cases

      ## Structure

      Each example includes:
      - Initial query
      - Agent's reasoning process
      - Data gathered and analysis
      - Final recommendation with justification
      - Tool calls executed in sequence

      ## Usage in Production

      - Examples are NOT executed at runtime
      - They inform agent training and fine-tuning
      - Reference for human reviewers evaluating agent performance
      - Basis for regression testing when updating system prompts

      ## Adding New Examples

      When adding examples:
      1. Use real (anonymized) scenarios when possible
      2. Show both positive and negative examples
      3. Include edge cases and policy boundary conditions
      4. Document the reasoning chain clearly
      5. Validate example follows current policies
    README
    
    File.write(
      File.join(@examples_dir, 'README.md'),
      readme
    )
    
    puts colorize("✓ Few-shot examples generated", :success)
  end

  def generate_mcp_package_json
    puts colorize("\n📦 Generating package.json...", :primary)
    
    package = {
      name: "retail-mcp-server",
      version: "1.0.0",
      description: "MCP server for retail operations with produce optimization tools",
      type: "module",
      main: "build/index.js",
      scripts: {
        build: "tsc",
        start: "node build/index.js",
        dev: "tsc --watch"
      },
      dependencies: {
        "@modelcontextprotocol/sdk": "^0.5.0",
        "axios": "^1.6.0"
      },
      devDependencies: {
        "@types/node": "^20.0.0",
        "typescript": "^5.3.0"
      }
    }
    
    File.write(
      File.join(@mcp_server_dir, 'package.json'),
      JSON.pretty_generate(package)
    )
    
    puts colorize("✓ package.json created", :success)
  end

  def generate_tsconfig
    puts colorize("\n⚙️  Generating tsconfig.json...", :primary)
    
    tsconfig = {
      compilerOptions: {
        target: "ES2022",
        module: "Node16",
        moduleResolution: "Node16",
        outDir: "./build",
        rootDir: "./src",
        strict: true,
        esModuleInterop: true,
        skipLibCheck: true,
        forceConsistentCasingInFileNames: true
      },
      include: ["src/**/*"],
      exclude: ["node_modules", "build"]
    }
    
    File.write(
      File.join(@mcp_server_dir, 'tsconfig.json'),
      JSON.pretty_generate(tsconfig)
    )
    
    puts colorize("✓ tsconfig.json created", :success)
  end

  def generate_mcp_server_code
    puts colorize("\n💻 Generating MCP server implementation...", :primary)
    
    server_code = <<~TYPESCRIPT
      import { Server } from "@modelcontextprotocol/sdk/server/index.js";
      import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
      import { 
        CallToolRequestSchema,
        ListToolsRequestSchema 
      } from "@modelcontextprotocol/sdk/types.js";
      import axios, { AxiosInstance } from "axios";

      class APIClient {
        private client: AxiosInstance;
        
        constructor(baseURL: string) {
          this.client = axios.create({
            baseURL,
            headers: {
              'Content-Type': 'application/json'
            }
          });
        }
        
        async get(path: string, config?: any) {
          return await this.client.get(path, config);
        }
        
        async post(path: string, data: any) {
          return await this.client.post(path, data);
        }
      }

      const inventoryClient = new APIClient(
        process.env.INVENTORY_API_ENDPOINT || "https://api.retailco.internal/inventory/v1"
      );
      const pricingClient = new APIClient(
        process.env.PRICING_API_ENDPOINT || "https://api.retailco.internal/pricing/v1"
      );
      const posClient = new APIClient(
        process.env.POS_API_ENDPOINT || "https://api.retailco.internal/pos/v1"
      );

      const server = new Server(
        {
          name: "retail-operations",
          version: "1.0.0",
        },
        {
          capabilities: {
            tools: {},
          },
        }
      );

      server.setRequestHandler(ListToolsRequestSchema, async () => {
        return {
          tools: [
            {
              name: "get_inventory_status",
              description: "Retrieve current inventory level, expiration dates, and recent movement for a product",
              inputSchema: {
                type: "object",
                properties: {
                  product_id: {
                    type: "string",
                    description: "Unique product identifier"
                  },
                  store_id: {
                    type: "string",
                    description: "Store location identifier"
                  },
                  include_supply_schedule: {
                    type: "boolean",
                    description: "Include upcoming delivery schedule"
                  }
                },
                required: ["product_id", "store_id"]
              }
            },
            {
              name: "query_sales_velocity",
              description: "Get sales rate for product over specified time period with comparison to baseline",
              inputSchema: {
                type: "object",
                properties: {
                  product_id: { type: "string" },
                  store_id: { type: "string" },
                  days_back: { 
                    type: "integer",
                    description: "Number of days of historical data to analyze"
                  }
                },
                required: ["product_id", "store_id", "days_back"]
              }
            },
            {
              name: "check_pricing_policy",
              description: "Validate proposed markdown against margin rules and approval requirements",
              inputSchema: {
                type: "object",
                properties: {
                  product_id: { type: "string" },
                  current_price: { type: "number" },
                  proposed_price: { type: "number" },
                  reason_code: { 
                    type: "string",
                    description: "Reason for markdown (expiration, quality, competition)"
                  }
                },
                required: ["product_id", "current_price", "proposed_price", "reason_code"]
              }
            },
            {
              name: "submit_price_change",
              description: "Execute approved price change in POS system (requires prior policy approval)",
              inputSchema: {
                type: "object",
                properties: {
                  product_id: { type: "string" },
                  store_id: { type: "string" },
                  new_price: { type: "number" },
                  approval_token: { 
                    type: "string",
                    description: "Token from check_pricing_policy approval"
                  },
                  effective_datetime: { 
                    type: "string",
                    format: "date-time"
                  }
                },
                required: ["product_id", "store_id", "new_price", "approval_token"]
              }
            },
            {
              name: "get_competitor_pricing",
              description: "Retrieve current pricing for product category from local competitors",
              inputSchema: {
                type: "object",
                properties: {
                  category: { type: "string" },
                  radius_miles: { type: "number" },
                  store_location: { type: "string" }
                },
                required: ["category", "store_location"]
              }
            }
          ]
        };
      });

      server.setRequestHandler(CallToolRequestSchema, async (request) => {
        const { name, arguments: args } = request.params;
        
        try {
          switch (name) {
            case "get_inventory_status": {
              const { product_id, store_id, include_supply_schedule } = args as any;
              
              if (!product_id || !store_id) {
                throw new Error("Missing required parameters");
              }
              
              const response = await inventoryClient.get(
                \`/products/\${product_id}/stores/\${store_id}\`,
                { params: { include_supply: include_supply_schedule } }
              );
              
              return {
                content: [{
                  type: "text",
                  text: JSON.stringify(response.data, null, 2)
                }]
              };
            }
            
            case "query_sales_velocity": {
              const { product_id, store_id, days_back } = args as any;
              
              const response = await inventoryClient.get(
                \`/products/\${product_id}/stores/\${store_id}/velocity\`,
                { params: { days: days_back } }
              );
              
              return {
                content: [{
                  type: "text",
                  text: JSON.stringify(response.data, null, 2)
                }]
              };
            }
            
            case "check_pricing_policy": {
              const { product_id, current_price, proposed_price, reason_code } = args as any;
              
              const product = await inventoryClient.get(\`/products/\${product_id}\`);
              
              const validation = await pricingClient.post("/policy/validate", {
                product_id,
                category: product.data.category,
                cost: product.data.cost,
                current_price,
                proposed_price,
                reason: reason_code
              });
              
              return {
                content: [{
                  type: "text",
                  text: JSON.stringify({
                    approved: validation.data.approved,
                    approval_token: validation.data.token,
                    margin_pct: validation.data.resulting_margin,
                    requires_manager_approval: validation.data.needs_escalation
                  }, null, 2)
                }]
              };
            }
            
            case "submit_price_change": {
              const { product_id, store_id, new_price, approval_token } = args as any;
              
              const tokenValid = await pricingClient.post("/policy/verify-token", {
                token: approval_token,
                product_id,
                price: new_price
              });
              
              if (!tokenValid.data.valid) {
                throw new Error("Invalid or expired approval token");
              }
              
              const result = await posClient.post("/price-changes", {
                product_id,
                store_id,
                new_price,
                effective_immediately: true,
                audit_token: approval_token
              });
              
              return {
                content: [{
                  type: "text",
                  text: JSON.stringify({
                    success: true,
                    change_id: result.data.change_id,
                    updated_at: result.data.timestamp
                  }, null, 2)
                }]
              };
            }
            
            case "get_competitor_pricing": {
              const { category, radius_miles, store_location } = args as any;
              
              const competitorClient = new APIClient(
                process.env.COMPETITOR_API_ENDPOINT || "https://api.marketdata.com/v2/pricing"
              );
              
              const response = await competitorClient.get("/pricing", {
                params: { category, radius: radius_miles, location: store_location }
              });
              
              return {
                content: [{
                  type: "text",
                  text: JSON.stringify(response.data, null, 2)
                }]
              };
            }
            
            default:
              throw new Error(\`Unknown tool: \${name}\`);
          }
        } catch (error: any) {
          return {
            content: [{
              type: "text",
              text: JSON.stringify({ error: error.message }, null, 2)
            }],
            isError: true
          };
        }
      });

      async function main() {
        const transport = new StdioServerTransport();
        await server.connect(transport);
        console.error("Retail Operations MCP Server running on stdio");
      }

      main().catch((error) => {
        console.error("Fatal error:", error);
        process.exit(1);
      });
    TYPESCRIPT
    
    File.write(
      File.join(@mcp_server_dir, 'src', 'index.ts'),
      server_code
    )
    
    puts colorize("✓ MCP server implementation created", :success)
  end

  def install_dependencies
    puts colorize("\n📚 Installing dependencies...", :primary)
    
    Dir.chdir(@mcp_server_dir) do
      stdout, stderr, status = Open3.capture3("npm install")
      unless status.success?
        puts colorize("✗ Failed to install dependencies", :error)
        puts stderr
        exit 1
      end
    end
    
    puts colorize("✓ Dependencies installed", :success)
  end

  def build_server
    puts colorize("\n🔨 Building server...", :primary)
    
    Dir.chdir(@mcp_server_dir) do
      stdout, stderr, status = Open3.capture3("npm run build")
      unless status.success?
        puts colorize("✗ Build failed", :error)
        puts stderr
        exit 1
      end
    end
    
    puts colorize("✓ Server built successfully", :success)
  end

  def configure_mcp_client
    puts colorize("\n⚙️  Configuring MCP client...", :primary)
    
    config_dir = File.dirname(@config_file)
    FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
    
    existing_config = if File.exist?(@config_file)
      JSON.parse(File.read(@config_file))
    else
      { "mcpServers" => {} }
    end
    
    existing_config["mcpServers"]["retail-operations"] = {
      "command" => "node",
      "args" => [File.join(@build_dir, 'index.js')],
      "env" => {
        "INVENTORY_API_ENDPOINT" => "https://api.retailco.internal/inventory/v1",
        "PRICING_API_ENDPOINT" => "https://api.retailco.internal/pricing/v1",
        "POS_API_ENDPOINT" => "https://api.retailco.internal/pos/v1",
        "COMPETITOR_API_ENDPOINT" => "https://api.marketdata.com/v2/pricing",
        "API_KEY_SECRET_NAME" => "retail-ops-api-key",
        "AUTH_TYPE" => "oauth2",
        "TOKEN_ENDPOINT" => "https://auth.retailco.internal/oauth/token"
      }
    }
    
    File.write(@config_file, JSON.pretty_generate(existing_config))
    
    puts colorize("✓ MCP client configured at #{@config_file}", :success)
  end

  def generate_deployment_manifest
    puts colorize("\n📋 Generating deployment manifest...", :primary)
    
    manifest = {
      deployment_date: Time.now.iso8601,
      version: "1.0.0",
      components: {
        system_prompts: {
          location: @prompts_dir,
          files: Dir.glob(File.join(@prompts_dir, '*.txt')).map { |f| File.basename(f) }
        },
        policies: {
          location: @policies_dir,
          files: Dir.glob(File.join(@policies_dir, '*.{txt,json}')).map { |f| File.basename(f) }
        },
        examples: {
          location: @examples_dir,
          files: Dir.glob(File.join(@examples_dir, '*.txt')).map { |f| File.basename(f) }
        },
        mcp_server: {
          location: @mcp_server_dir,
          build_output: @build_dir,
          config_file: @config_file,
          tools: [
            "get_inventory_status",
            "query_sales_velocity",
            "check_pricing_policy",
            "submit_price_change",
            "get_competitor_pricing"
          ]
        }
      },
      usage_instructions: {
        load_system_prompt: "Load #{File.join(@prompts_dir, 'produce-optimization-agent.txt')} at agent initialization",
        reference_policies: "Agent should reference policies in #{@policies_dir} when reasoning",
        use_examples: "Examples in #{@examples_dir} guide training and evaluation",
        start_mcp_server: "MCP server auto-starts via config at #{@config_file}",
        test_server: "cd #{@mcp_server_dir} && npm start"
      },
      next_steps: [
        "Review and customize API endpoints in #{@config_file}",
        "Configure authentication credentials for backend APIs",
        "Test MCP server connectivity",
        "Deploy system prompt to agent runtime",
        "Monitor agent decisions against policy compliance",
        "Review few-shot examples periodically and add new scenarios"
      ]
    }
    
    File.write(
      File.join(@project_root, 'deployment-manifest.json'),
      JSON.pretty_generate(manifest)
    )
    
    readme = <<~README
      # Retail Agentic AI System

      Complete deployment of an agentic AI system for retail produce optimization.

      ## Components

      ### 1. System Prompts (`prompts/`)
      Defines the agent's role, capabilities, decision framework, and behavior.

      ### 2. Policy Documents (`policies/`)
      Business rules and operational constraints that guide decision-making.

      ### 3. Few-Shot Examples (`examples/`)
      Training examples demonstrating correct reasoning patterns.

      ### 4. MCP Server (`mcp-server/`)
      Model Context Protocol server that binds agent to backend systems.

      ## Architecture

      ```
      Agent (Probabilistic Reasoning)
         ↓
      System Prompt + Policies + Examples
         ↓
      MCP Server (Validation & Routing)
         ↓
      Backend APIs (Deterministic Execution)
      ```

      ## Getting Started

      1. **Review Configuration**
         - Edit API endpoints in `~/.config/mcp/servers.json`
         - Configure authentication credentials

      2. **Load System Prompt**
         - Load `prompts/produce-optimization-agent.txt` at agent initialization
         - Agent will reference policies and examples during reasoning

      3. **Start MCP Server**
         - Server auto-starts when agent connects
         - Or manually: `cd mcp-server && npm start`

      4. **Test Agent**
         - Send test query: "Should we mark down organic strawberries?"
         - Verify agent uses tools and follows policies

      ## Deployment Manifest

      See `deployment-manifest.json` for complete deployment details.

      ## Monitoring

      - Monitor agent tool usage
      - Review policy compliance
      - Track markdown effectiveness
      - Audit approval workflows

      ## Updates

      When updating components:
      - Version all changes
      - Test in staging first
      - Update manifest
      - Document in CHANGELOG
    README
    
    File.write(
      File.join(@project_root, 'README.md'),
      readme
    )
    
    puts colorize("✓ Deployment manifest created", :success)
  end

  def colorize(text, color)
    "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end
end

if __FILE__ == $0
  puts "Version: 1.0.0"
  deployer = AgenticAIDeployer.new
  deployer.deploy
end

