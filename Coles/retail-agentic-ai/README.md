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
