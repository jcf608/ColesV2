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
          `/products/${product_id}/stores/${store_id}`,
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
          `/products/${product_id}/stores/${store_id}/velocity`,
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
        
        const product = await inventoryClient.get(`/products/${product_id}`);
        
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
        throw new Error(`Unknown tool: ${name}`);
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
