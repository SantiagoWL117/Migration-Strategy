# Claude Code + Supabase Quick Setup Scripts

This directory contains quick setup scripts to initialize Supabase environment variables for new Claude Code sessions.

---

## 📁 Files

- **`mac_setup_supabase_session.sh`** - Bash/Git Bash/WSL/macOS setup script
- **`windows_setup_supabase_session.ps1`** - PowerShell/Windows setup script
- **`agent-quick-start-connection.md`** - Agent-friendly quick start guide
- **`README.md`** - This file (comprehensive guide)

---

## 🚀 Usage

### For Git Bash / WSL / Linux / macOS

```bash
# Navigate to this directory
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\.claude\Supabase Connection"

# Source the setup script
source mac_setup_supabase_session.sh
```

**Note:** Must use `source` (or `.`) to apply environment variables to current session.

### For PowerShell (Windows)

```powershell
# Navigate to this directory
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\.claude\Supabase Connection"

# Run the setup script
. .\windows_setup_supabase_session.ps1
```

**Note:** Must use `. .\` (dot-space-dot-backslash) to apply environment variables to current session.

---

## ✅ What Gets Configured

After running the setup script, the following environment variables are available:

| Variable | Description |
|----------|-------------|
| `SUPABASE_ACCESS_TOKEN` | CLI authentication token |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role API key (bypasses RLS) |
| `SUPABASE_PROJECT_REF` | Project reference ID |
| `SUPABASE_DB_PASSWORD` | Database password |
| `SUPABASE_CONNECTION_STRING` | Full PostgreSQL connection string |
| `SUPABASE_URL` | Base Supabase project URL |
| `SUPABASE_REST_API` | REST API endpoint |
| `PSQL_PATH` | Path to PostgreSQL client (psql) |

---

## 🎯 Quick Commands After Setup

### Test Supabase CLI Connection
```bash
supabase projects list
```

### Test Database Connection
```bash
# Bash/WSL
"$PSQL_PATH" "$SUPABASE_CONNECTION_STRING" -c "SELECT 1;"

# PowerShell
& $env:PSQL_PATH $env:SUPABASE_CONNECTION_STRING -c "SELECT 1;"
```

### Query Database
```bash
# Bash/WSL
"$PSQL_PATH" "$SUPABASE_CONNECTION_STRING" -c "SELECT * FROM restaurants LIMIT 5;"

# PowerShell
& $env:PSQL_PATH $env:SUPABASE_CONNECTION_STRING -c "SELECT * FROM restaurants LIMIT 5;"
```

### Using the Alias (Quick psql access)
```bash
# Bash/WSL
supabase-psql -c "SELECT COUNT(*) FROM restaurants;"

# PowerShell
supabase-psql "SELECT COUNT(*) FROM restaurants;"
```

---

## 🔄 New Claude Code Session Workflow

When starting a **new Claude Code session**:

### Option 1: Run Setup Script First (Recommended)

**For Mac/Linux/WSL:**
```bash
# 1. Source the setup script
source ".claude/Supabase Connection/mac_setup_supabase_session.sh"

# 2. Start working - environment is ready!
supabase projects list
```

**For Windows PowerShell:**
```powershell
# 1. Run the setup script
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1"

# 2. Start working - environment is ready!
supabase projects list
```

### Option 2: Claude Can Run It Automatically

Tell Claude:
```
Before we start, read .claude/Supabase Connection/agent-quick-start-connection.md and run the appropriate setup script for my OS.
```

### Option 3: Direct Connection (No Setup Needed)

Claude can always connect directly without setup by using the full connection string:

```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR SQL"
```

---

## 🔒 Security Notes

**⚠️ IMPORTANT:**

1. **DO NOT commit these scripts to public repositories** - They contain sensitive credentials
2. These scripts are in `.gitignore` by default
3. Keep these files local to your development machine
4. Rotate tokens regularly via Supabase dashboard

**Already in `.gitignore`:**
```gitignore
# Claude Code Supabase setup scripts (contain credentials)
.claude/Supabase Connection/*.ps1
.claude/Supabase Connection/*.sh
```

This allows `README.md` and `agent-quick-start-connection.md` to be committed while protecting credentials.

---

## 🛠️ Customization

### Changing Credentials

Edit the setup scripts and update these values:

```bash
# In mac_setup_supabase_session.sh or windows_setup_supabase_session.ps1
export SUPABASE_ACCESS_TOKEN="your-new-token"
export SUPABASE_DB_PASSWORD="your-new-password"
# etc...
```

### Adding More Variables

You can add project-specific variables:

```bash
# Example: Add schema name
export SUPABASE_SCHEMA="menuca_v3"

# Example: Add default table prefix
export TABLE_PREFIX="menuca_v3."
```

---

## 🐛 Troubleshooting

### "Command not found: supabase"

**Solution:** Supabase CLI not installed or not in PATH.

```bash
# Check installation
supabase --version

# Reinstall if needed
npm install -g supabase
```

### "psql: command not found"

**Solution:** PostgreSQL client not installed. Use full path:

```bash
# Update PSQL_PATH in the setup script to correct location
export PSQL_PATH="/c/Program Files/PostgreSQL/17/bin/psql.exe"
```

### "Access token not provided"

**Solution:** Environment variable not set. Re-run the setup script:

```bash
# Mac/Linux/WSL
source mac_setup_supabase_session.sh

# Windows PowerShell
. .\windows_setup_supabase_session.ps1
```

### Environment Variables Not Persisting

**Remember:** You must use `source` (bash) or `. .\` (PowerShell) to apply to current session.

**Wrong:**
```bash
# This creates a sub-shell - variables don't persist
./mac_setup_supabase_session.sh
```

**Correct:**
```bash
# This applies to current session
source mac_setup_supabase_session.sh
```

---

## 📚 Additional Resources

- **Main Setup Guide:** `../CLAUDE_SUPABASE_SETUP_GUIDE.md`
- **Supabase Dashboard:** https://supabase.com/dashboard
- **Supabase CLI Docs:** https://supabase.com/docs/guides/cli
- **PostgreSQL Docs:** https://www.postgresql.org/docs/

---

## 🎉 You're Ready!

With these setup scripts, any new Claude Code session can be operational in **under 5 seconds**!

**Quick start:**
```bash
# Mac/Linux/WSL
source ".claude/Supabase Connection/mac_setup_supabase_session.sh" && supabase projects list

# Windows PowerShell
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1"; supabase projects list
```

---

**Last Updated:** 2025-10-25
**Project:** Menu.ca - Legacy Database Migration Strategy
**Location:** `.claude/Supabase Connection/`
