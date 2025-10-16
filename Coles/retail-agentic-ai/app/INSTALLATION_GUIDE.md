# 🚀 Installation Guide for Refactored Files

## What's Been Fixed

### Version 2.1.0 Changes

**app.rb** - Comprehensive error handling:
- ✅ Validates API response structure before accessing
- ✅ Handles nil blocks in content array
- ✅ Safe JSON parsing with fallback
- ✅ Better parameter normalization for tool calls
- ✅ Detailed error messages with debug info
- ✅ Type checking for all tool parameters

**New Files:**
- `debug_test.rb` - Tests tool execution in isolation
- `health_check.rb` - Validates entire system setup

## Installation Steps

### 1. Backup Your Current Files

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app

# Backup current app.rb
cp app.rb app.rb.backup.$(date +%Y%m%d-%H%M%S)

# Backup health_check.rb if you want
cp health_check.rb health_check.rb.backup.$(date +%Y%m%d-%H%M%S)
```

### 2. Download the Refactored Files

Download these files from the outputs:
- `app.rb` (main application - **CRITICAL**)
- `debug_test.rb` (debugging tool)
- `health_check.rb` (enhanced health check)

### 3. Place Files in Correct Locations

```bash
# Place the new app.rb
mv ~/Downloads/app.rb ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/

# Place debug_test.rb
mv ~/Downloads/debug_test.rb ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/

# Place health_check.rb
mv ~/Downloads/health_check.rb ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/

# Make scripts executable
chmod +x ~/Dropbox/Valorica/Coles/retail-agentic-ai/app/*.rb
```

### 4. Run Health Check

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app
ruby health_check.rb
```

Expected output:
```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🔍  PRODUCE AGENT - COMPREHENSIVE HEALTH CHECK  💅         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

📁 CHECKING FILE STRUCTURE
======================================================================
📄 app.rb... ✅ FOUND (xxxxx bytes)
🔑 keys.json... ✅ VALID JSON
📋 Policy JSON... ✅ VALID JSON
💬 System Prompt... ✅ FOUND (xxxx bytes)
🎨 CSS File... ✅ FOUND (xxxx bytes)

======================================================================
🔑 Checking API key... ✅ VALID (sk-ant-a...bAAA)

======================================================================
🧪 Testing Tool Execution Logic...
   Testing get_inventory_status... ✅ WORKS

🎉 ALL CRITICAL CHECKS PASSED!
```

### 5. Test Tool Execution Independently

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app
ruby debug_test.rb
```

This will test all your tool methods without hitting the Claude API. You should see:

```
🔍 Produce Agent Debug Tester
======================================================================

🧪 Running Test Cases...
======================================================================

✓ Test 1: Get Inventory Status (from your screenshot)

📋 Tool: get_inventory_status
   Parameters: {"product_id"=>"8899", "store_id"=>"monavale"}
   ✅ Result: {...}

   JSON Output:
{
  "product_id": "8899",
  "store_id": "monavale",
  "current_stock": 47,
  ...
}

🎉 All tests completed!
```

### 6. Start the Server

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app

# Stop any existing server
# Press Ctrl+C in the terminal where it's running

# Start with new code
ruby app.rb
```

### 7. Test the Fix

Open your browser to `http://localhost:4567`

Try the exact query from your screenshot:
```
"Should we mark down organic strawberries today?" product id 8899 store id monavale
```

## What Should Happen Now

### Before (with error):
```
Error: undefined method '[]' for nil
```

### After (working):
```
🤖 Claude:
Based on the inventory data, I recommend marking down the strawberries...

🔧 Tool Calls:
- get_inventory_status
  Result: { product_id: "8899", store_id: "monavale", ... }
```

## Troubleshooting

### If you still get errors:

1. **Check the server logs** in the terminal:
   - Look for "❌" or error messages
   - The new code prints detailed debug info

2. **Test the API directly**:
   ```bash
   curl -X POST http://localhost:4567/api/ask \
        -d 'message=Should we mark down strawberries?'
   ```

3. **Check API response structure**:
   If the error persists, the issue might be with Claude's API response format. The new code will show you:
   ```json
   {
     "success": false,
     "error": "Invalid response structure from Claude API",
     "debug_info": {
       "result_class": "...",
       "result_keys": [...],
       "raw_response": "..."
     }
   }
   ```

4. **Verify your API key**:
   ```bash
   cd ~/Dropbox/Valorica/Coles/retail-agentic-ai
   cat keys.json
   ```
   Make sure it starts with `sk-ant-` and is complete.

## Key Improvements

### Error Handling
- **Before**: Crashed on nil values
- **After**: Gracefully handles nil, provides debug info

### Parameter Handling
- **Before**: Only handled string keys
- **After**: Handles both string and symbol keys

### Debug Info
- **Before**: Generic Ruby error message
- **After**: Detailed error with context, backtrace, and suggestions

### Tool Validation
- **Before**: Assumed parameters were correct
- **After**: Validates type and structure before processing

## Rolling Back

If something goes wrong:

```bash
cd ~/Dropbox/Valorica/Coles/retail-agentic-ai/app

# Find your backup
ls -la app.rb.backup.*

# Restore it
cp app.rb.backup.YYYYMMDD-HHMMSS app.rb

# Restart server
ruby app.rb
```

## Next Steps

Once this is working:

1. ✅ Test all tool types (inventory, velocity, pricing, competitor)
2. ✅ Test with Admin panel for manual tool responses
3. ✅ Monitor logs for any remaining issues
4. 🚀 Deploy to production when stable

## Questions?

If you encounter issues:

1. Run `ruby health_check.rb` - shows what's broken
2. Run `ruby debug_test.rb` - tests tools in isolation
3. Check server logs - look for error messages
4. Share the error output from health_check or server logs

## File Versions

- **app.rb**: Version 2.1.0 (refactored with error handling)
- **health_check.rb**: Version 2.0.0 (enhanced diagnostics)
- **debug_test.rb**: Version 1.0.0 (tool testing)

Good luck! 🎉
