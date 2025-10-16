# MCP Schema Alignment Documentation

## Overview
This document outlines the schema alignment between the admin panel, MCP response panels, and the tooling schema to ensure consistent data structures across the system.

## Tool Schema Definitions

### 1. get_inventory_status
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "product_id": { "type": "string", "required": true },
    "store_id": { "type": "string", "required": true },
    "include_supply_schedule": { "type": "boolean", "default": false }
  }
}
```

**Response Schema:**
```json
{
  "product_id": "string",
  "store_id": "string", 
  "current_stock": "number",
  "cost_per_unit": "number",
  "shelf_price": "number",
  "expiration_date": "string (ISO date)",
  "units_sold_today": "number",
  "average_daily_sales": "number",
  "status": "string",
  "supply_schedule": "array (optional)"
}
```

### 2. query_sales_velocity
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "product_id": { "type": "string", "required": true },
    "store_id": { "type": "string", "required": true },
    "days_back": { "type": "integer", "required": true }
  }
}
```

**Response Schema:**
```json
{
  "product_id": "string",
  "store_id": "string",
  "velocity_units_per_day": "number",
  "baseline_velocity": "number", 
  "velocity_trend": "string",
  "days_analyzed": "number",
  "daily_breakdown": "array"
}
```

### 3. check_pricing_policy
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "product_id": { "type": "string", "required": true },
    "current_price": { "type": "number", "required": true },
    "proposed_price": { "type": "number", "required": true },
    "reason_code": { "type": "string", "required": true }
  }
}
```

**Response Schema:**
```json
{
  "product_id": "string",
  "approved": "boolean",
  "approval_token": "string",
  "markdown_percentage": "number",
  "resulting_margin_pct": "number",
  "requires_manager_approval": "boolean",
  "reason_code": "string",
  "policy_notes": "string"
}
```

### 4. submit_price_change
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "product_id": { "type": "string", "required": true },
    "store_id": { "type": "string", "required": true },
    "new_price": { "type": "number", "required": true },
    "approval_token": { "type": "string", "required": true },
    "effective_datetime": { "type": "string", "format": "date-time" }
  }
}
```

**Response Schema:**
```json
{
  "success": "boolean",
  "change_id": "string",
  "updated_at": "string (ISO datetime)",
  "message": "string"
}
```

### 5. get_competitor_pricing
**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "category": { "type": "string", "required": true },
    "store_location": { "type": "string", "required": true },
    "radius_miles": { "type": "number", "default": 5 }
  }
}
```

**Response Schema:**
```json
{
  "category": "string",
  "location": "string",
  "competitors": "array",
  "lowest_price": "number",
  "average_price": "number",
  "updated_at": "string (ISO datetime)"
}
```

## MCP Response Format
All tool responses must follow the MCP standard format:

```json
{
  "content": [{
    "type": "text",
    "text": "[JSON string of actual response data]"
  }]
}
```

## UI Tool Call Display Format
The chat interface expects tool calls in this format:

```json
{
  "name": "string",
  "input": "object (parameters sent to tool)",
  "result": "object (response from tool)",
  "status": "string (executed, pending, failed)"
}
```

## Alignment Fixes Applied

1. **Schema Consistency**: Updated base app schema to match MCP server schema requirements
2. **Required Parameters**: Ensured all required parameters are properly validated and included
3. **Response Format**: Standardized response format across admin panel and MCP responses
4. **UI Display**: Enhanced tool call display in chat interface with structured parameter/result view
5. **CSS Styling**: Added proper styling for tool call components
6. **Validation**: Added client-side validation for tool call formatting

## Testing Checklist

- [ ] Admin panel generates complete requests with all required parameters
- [ ] MCP responses follow standard format
- [ ] Chat interface displays tool calls with proper structure
- [ ] All tool schemas match between base app, MCP server, and admin panel
- [ ] Error handling works for invalid/missing parameters
- [ ] CSS styling renders properly for all tool call components