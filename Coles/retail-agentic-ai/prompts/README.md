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
