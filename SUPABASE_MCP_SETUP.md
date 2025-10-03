# Supabase MCP Configuration with Service Role Key

## ✅ Security Setup Complete

Your `.gitignore` has been updated to exclude environment variable files from source control.

---

## 🔐 Step 1: Create Environment Variable File

Create a file named `.env` in the project root with this content:

```bash
# Supabase Service Role Key (KEEP SECRET - DO NOT COMMIT)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g

# Supabase Project URL
SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
```

**⚠️ IMPORTANT: This file is already in .gitignore and will NOT be committed!**

---

## 🔧 Step 2: Update Cursor MCP Settings

### Option A: Using Cursor Settings UI (Recommended)

1. Open Cursor
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type: "MCP: Configure Servers"
4. Find the Supabase MCP configuration
5. Update it to use the service role key

### Option B: Edit Configuration File Manually

The MCP configuration is typically at:

**Windows:**
```
%APPDATA%\Cursor\User\globalStorage\rooveterinaryinc.roo-cline\settings\cline_mcp_settings.json
```

**macOS/Linux:**
```
~/.cursor/User/globalStorage/rooveterinaryinc.roo-cline/settings/cline_mcp_settings.json
```

Update the Supabase MCP configuration to:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server@latest"],
      "env": {
        "SUPABASE_URL": "https://nthpbtdjhhnwfxqsxbvy.supabase.co",
        "SUPABASE_SERVICE_ROLE_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g"
      }
    }
  }
}
```

**Key Changes:**
- Changed `SUPABASE_ANON_KEY` → `SUPABASE_SERVICE_ROLE_KEY`
- Updated the key value to the service role key

---

## 🔄 Step 3: Restart Cursor

1. **Completely close** Cursor (File → Exit, or Alt+F4)
2. **Reopen** Cursor
3. The MCP will reconnect with write permissions

---

## ✅ Step 4: Verify Write Access

After restarting, I'll test the connection by creating the staging table.

You can verify by running:
```sql
SELECT current_user, session_user;
```

If configured correctly, you should see the service role user.

---

## 🔒 Security Notes

✅ **Protected:**
- `.env` file is in `.gitignore` (will NOT be committed)
- Service role key has admin access (keep secure!)

⚠️ **Important:**
- Never share the service role key
- Never commit it to version control
- Only use it for backend/migration operations
- For frontend apps, use the anonymous key

---

## 📋 Next Steps

After completing the setup:
1. ✅ Update .gitignore (DONE)
2. ⏳ Create .env file
3. ⏳ Update MCP settings
4. ⏳ Restart Cursor
5. ⏳ I'll verify and continue with Step 1 migration

---

**Ready to proceed?** Let me know when you've:
1. Created the `.env` file
2. Updated the MCP configuration
3. Restarted Cursor

Then I'll verify the connection and continue creating the staging table!

