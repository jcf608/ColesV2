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
