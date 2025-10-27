# Direct PSQL Usage Guide

**Purpose:** Avoid Supabase MCP crashes by using direct `psql` commands

## Setup

### 1. Source the environment script
```bash
source /Users/brianlapp/Documents/GitHub/Migration-Strategy/.claude/Supabase\ Connection/mac_setup_supabase_session.sh
```

### 2. Environment Variables Available
- `SUPABASE_PROJECT_REF`: nthpbtdjhhnwfxqsxbvy
- `SUPABASE_CONNECTION_STRING`: Full PostgreSQL connection string
- `PSQL_PATH`: /opt/homebrew/opt/postgresql@17/bin/psql

## Usage Methods

### Method 1: Direct psql commands (What I'll use)
```bash
/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR SQL HERE"
```

### Method 2: Using shell functions (if you source the script)
```bash
# Run inline SQL
supabase-sql "SELECT * FROM menuca_v3.restaurants LIMIT 5"

# Run SQL from file
supabase-sql-file migration.sql

# Quiet output (for scripts)
supabase-sql-quiet "SELECT COUNT(*) FROM menuca_v3.dishes"
```

## Common Operations

### Run a Query
```bash
/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT * FROM menuca_v3.modifier_groups"
```

### Run Migration from File
```bash
/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -f /path/to/migration.sql
```

### Run Multi-line SQL
```bash
/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" << 'EOF'
-- Your multi-line SQL here
CREATE TABLE test (
  id SERIAL PRIMARY KEY,
  name TEXT
);
EOF
```

## What I'll Do Going Forward

Instead of using MCP tools like:
```
❌ mcp_supabase_execute_sql
❌ mcp_supabase_apply_migration
```

I'll use:
```
✅ run_terminal_cmd with direct psql commands
```

## Example: Creating a Migration

**Old Way (MCP - causes crashes):**
```typescript
mcp_supabase_apply_migration({
  name: "migration_name",
  query: "SQL HERE"
})
```

**New Way (Direct psql - stable):**
```bash
run_terminal_cmd({
  command: '/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SQL HERE"',
  required_permissions: ["network"]
})
```

## Connection String Components

- **Host:** db.nthpbtdjhhnwfxqsxbvy.supabase.co
- **Port:** 5432
- **Database:** postgres
- **User:** postgres
- **Password:** Gz35CPTom1RnsmGM

## Verification

Test connection:
```bash
/opt/homebrew/opt/postgresql@17/bin/psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT 'Connected!' as status"
```

Expected output:
```
  status   
-----------
 Connected!
(1 row)
```

## Notes

- ✅ **Stable**: No MCP crashes
- ✅ **Fast**: Direct connection to PostgreSQL
- ✅ **Reliable**: Standard PostgreSQL client
- ✅ **Full SQL support**: No limitations
- ⚠️ **Requires network permission**: Must use `required_permissions: ["network"]` in run_terminal_cmd

---

**Status:** ✅ Tested and working (2025-10-27)

