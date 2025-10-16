# Branding Update: Claude → Generative AI 🤖

## Changes Made

All user-facing references to "Claude" have been replaced with "AI" or "Generative AI" to make the interface more generic and professional.

### Updated Text (26 instances)

**Button Labels:**
- ✅ "Generate with Claude AI" → "Generate with AI"
- ✅ "Generate System Prompt with Claude" → "Generate System Prompt with AI"
- ✅ "Generate Policy Documents with Claude" → "Generate Policy Documents with AI"
- ✅ "Generate Example Dialog with Claude" → "Generate Example Dialog with AI"
- ✅ "Generate Tools with Claude" → "Generate Tools with AI"

**Helper Text:**
- ✅ "Let Claude help you..." → "Let generative AI help you..."
- ✅ "Claude will write..." → "AI will write..."
- ✅ "Claude will create..." → "AI will create..."
- ✅ "Claude will design..." → "AI will design..."
- ✅ "Claude's function calling schema" → "the function calling schema"

### What Stayed the Same

**Internal Code (Not User-Facing):**
- Function names like `generateQuestionWithClaude()` remain unchanged
- Backend variable names remain unchanged
- API endpoint names remain unchanged

**Why?** Changing internal function names could break existing code and isn't necessary since users never see them.

## Visual Comparison

### Before:
```
┌─────────────────────────────────────┐
│  [🤖 Generate with Claude AI]      │
│  Let Claude help you write this... │
└─────────────────────────────────────┘
```

### After:
```
┌─────────────────────────────────────┐
│  [🤖 Generate with AI]              │
│  Let generative AI help you...     │
└─────────────────────────────────────┘
```

## Benefits

✅ **Brand Agnostic** - Not tied to specific AI provider
✅ **Professional** - More enterprise-friendly terminology
✅ **Future-Proof** - Easy to swap AI backends without UI changes
✅ **Clear** - Users understand it's AI-powered without specifics
✅ **Consistent** - All user-facing text uses same terminology

## Files Updated

- `/mnt/user-data/outputs/add_agent_question_enhanced.erb`

## Testing Checklist

- [ ] Load the wizard page
- [ ] Check all 6 wizard steps for button text
- [ ] Verify helper text below buttons
- [ ] Test button functionality (should still work)
- [ ] Check field labels and placeholders

## Notes

The backend still uses Claude API (via `call_claude_api` method), but this is an implementation detail. The generic "AI" branding allows flexibility to:
- Use different AI models in the future
- A/B test different providers
- Meet enterprise requirements for vendor neutrality
- Avoid brand confusion if Claude's branding changes
