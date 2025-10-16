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
