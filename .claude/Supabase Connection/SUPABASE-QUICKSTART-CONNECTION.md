# Agent Quick Start: Supabase Connection

**Purpose:** Connect Claude Code session to Supabase database.

---

## Recommended Approach: Direct Connection String

**Why:** Claude Code runs each bash command in a separate session. Environment variables from setup scripts don't persist between commands. Using the direct connection string is simpler and more reliable.

---

## Database Connection Commands

### PostgreSQL Client (psql) - Primary Method

**For Windows:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR_SQL_HERE"
```

**For Mac/Linux:**
```bash
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR_SQL_HERE"
```

---

## Quick Reference Commands

### List all tables
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "\dt"
```

### Query restaurants
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT * FROM restaurants LIMIT 5;"
```

### Check connection
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT current_database(), current_user, version();"
```

### List all functions
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "\df"
```

---

## Supabase CLI Commands

### Check Supabase CLI status
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase projects list
```

### Pull database schema
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull
```

**Note:** For Supabase CLI commands, chain the token export with && in the same command.

---

## Connection Details Reference

| Detail | Value |
|--------|-------|
| **Host** | `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **User** | `postgres` |
| **Password** | `Gz35CPTom1RnsmGM` |
| **Project Ref** | `nthpbtdjhhnwfxqsxbvy` |
| **Full Connection String** | `postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres` |

---

## Alternative: Setup Scripts (Optional)

If you need persistent environment variables for a terminal session (not Claude Code), use these scripts:

**Mac/Linux/WSL:**
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh"
```

**Windows PowerShell:**
```powershell
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1"
```

**Important:** These only work in persistent terminal sessions. In Claude Code, you must chain commands:
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh" && "$PSQL_PATH" "$SUPABASE_CONNECTION_STRING" -c "YOUR SQL"
```

---

## Troubleshooting

### psql not found (Mac/Linux)
Install PostgreSQL client:
```bash
# macOS
brew install postgresql@17

# Ubuntu/Debian
sudo apt install postgresql-client
```

### psql not found (Windows)
PostgreSQL may be installed but not in PATH. Use full path:
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe"
```

### Connection timeout
- Check internet connection
- Verify Supabase project is not paused
- Confirm credentials are correct

### Permission denied
- Verify you're using the correct password
- Check if IP is whitelisted (if applicable)
- Ensure database user has required permissions

---

## Summary for Agents

**Default command pattern for database queries:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SQL_QUERY"
```

**For Supabase CLI:**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase [command]
```

**No setup scripts needed** - Use direct connection strings for all database operations.

---

**Location:** `.claude/Supabase Connection/`
**Full Documentation:** See `README.md` in this directory
**Last Updated:** 2025-10-25
