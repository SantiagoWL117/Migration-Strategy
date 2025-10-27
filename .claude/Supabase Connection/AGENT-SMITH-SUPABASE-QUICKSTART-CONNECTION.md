# Agent Smith: Autonomous Supabase CLI Connection Guide

**Purpose:** Enable AI agents to autonomously connect to Supabase project using the Supabase CLI without human interaction.

**Target User:** AI Coding Assistants (Claude, Cursor Agents, etc.)

---

## 🤖 Agent Quick Start Protocol

### Step 1: Detect Operating System

Check the user's OS from session context or run:
```bash
echo $OS
```

### Step 2: Set Supabase Access Token

**CRITICAL:** The Supabase CLI requires the access token to be set for authentication.

#### For Windows (PowerShell):
```powershell
$env:SUPABASE_ACCESS_TOKEN = "sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"
```

#### For Mac/Linux/WSL (Bash):
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"
```

### Step 3: Verify Supabase CLI Connection

Run this command to verify CLI access:
```bash
supabase projects list
```

**Expected Output:** Should display project information for `nthpbtdjhhnwfxqsxbvy`

---

## 🚀 Primary CLI Commands for Agents

### Single-Command Pattern (Recommended for Claude Code)

Since environment variables don't persist between command executions in Claude Code, use the chained command pattern:

#### Windows (PowerShell):
```powershell
$env:SUPABASE_ACCESS_TOKEN = "sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"; supabase projects list
```

#### Mac/Linux/WSL (Bash):
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase projects list
```

---

## 📋 Essential Supabase CLI Operations

### List All Projects
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase projects list
```

### Link to Current Project
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase link --project-ref nthpbtdjhhnwfxqsxbvy
```

### Pull Database Schema
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull
```

### Pull Specific Schema
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull --schema public
```

### List Database Migrations
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase migration list
```

### Create New Migration
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase migration new migration_name
```

### Push Migrations to Remote
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db push
```

### Generate TypeScript Types
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase gen types typescript --project-id nthpbtdjhhnwfxqsxbvy > types/database.types.ts
```

### Inspect Database Functions
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db diff --schema public
```

---

## 🔑 Complete Project Credentials Reference

### Supabase CLI Token
```
sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9
```

### Service Role Key (Bypasses RLS)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g
```

### Project Details
| Key | Value |
|-----|-------|
| **Project Reference** | `nthpbtdjhhnwfxqsxbvy` |
| **Database Host** | `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Database Port** | `5432` |
| **Database Name** | `postgres` |
| **Database User** | `postgres` |
| **Database Password** | `Gz35CPTom1RnsmGM` |
| **Project URL** | `https://nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **REST API** | `https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1` |

### Full Connection String (For Direct psql Access)
```
postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres
```

---

## 🎯 Agent Decision Tree

### When to Use Supabase CLI:
✅ Pulling schema changes from remote database  
✅ Generating TypeScript types from database schema  
✅ Managing database migrations  
✅ Comparing local and remote database differences  
✅ Creating new migration files  
✅ Linking project to local environment  
✅ Inspecting database structure  

### When to Use Direct psql Connection:
✅ Running ad-hoc SQL queries  
✅ Quickly checking table data  
✅ Testing database functions  
✅ Debugging specific queries  
✅ Bulk data operations  

---

## 🔄 Combined Operations Workflow

### Full Setup + Schema Pull
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && \
supabase link --project-ref nthpbtdjhhnwfxqsxbvy && \
supabase db pull
```

### Generate Types After Schema Change
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && \
supabase db pull && \
supabase gen types typescript --project-id nthpbtdjhhnwfxqsxbvy > types/supabase.ts
```

---

## 🛡️ Agent Error Handling

### Error: "Access token not provided"
**Solution:** Token not set. Re-run the export command:
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9"
```

### Error: "supabase: command not found"
**Check Installation:**
```bash
supabase --version
```

**If Not Installed:**
```bash
npm install -g supabase
```

### Error: "Project not linked"
**Solution:** Link the project:
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase link --project-ref nthpbtdjhhnwfxqsxbvy
```

### Error: "Failed to connect to database"
**Solution:** Verify connection using direct psql:
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT 1;"
```

---

## 🤝 Integration with Direct Database Access

### Scenario: Schema Change Detection

1. **Pull current schema with CLI:**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull
```

2. **Query specific table with psql:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT * FROM restaurants LIMIT 5;"
```

3. **Generate updated types:**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase gen types typescript --project-id nthpbtdjhhnwfxqsxbvy > types/database.types.ts
```

---

## 📦 Agent Autonomous Initialization Sequence

When an agent first connects to this project, execute this sequence:

```bash
# Step 1: Verify Supabase CLI is installed
supabase --version

# Step 2: Set access token and verify connection
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase projects list

# Step 3: Link to project
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase link --project-ref nthpbtdjhhnwfxqsxbvy

# Step 4: Pull current schema
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull

# Step 5: Verify database connectivity
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT current_database(), current_user, version();"
```

---

## 🎓 Agent Learning: CLI vs Direct Connection

### Use Supabase CLI When:
- Working with schema migrations
- Generating code/types from database
- Managing project configuration
- Syncing local and remote database structures
- Version controlling database changes

### Use Direct psql Connection When:
- Running one-off queries
- Debugging data issues
- Testing SQL functions
- Quick data inspections
- Performance testing queries

---

## 📊 Quick Reference Table

| Operation | Command Pattern | Use Case |
|-----------|----------------|----------|
| **List Projects** | `export SUPABASE_ACCESS_TOKEN="token" && supabase projects list` | Verify CLI access |
| **Link Project** | `export SUPABASE_ACCESS_TOKEN="token" && supabase link --project-ref nthpbtdjhhnwfxqsxbvy` | Initialize local environment |
| **Pull Schema** | `export SUPABASE_ACCESS_TOKEN="token" && supabase db pull` | Sync database schema |
| **Generate Types** | `export SUPABASE_ACCESS_TOKEN="token" && supabase gen types typescript --project-id nthpbtdjhhnwfxqsxbvy` | Create TypeScript types |
| **Run Query** | `psql "connection_string" -c "SQL"` | Execute SQL directly |
| **Check DB** | `psql "connection_string" -c "SELECT 1;"` | Verify connection |

---

## ⚡ Agent Performance Tips

1. **Always chain commands** with `&&` to ensure token is available
2. **Cache connection strings** in session context for reuse
3. **Use direct psql** for simple queries (faster than CLI)
4. **Use Supabase CLI** for schema operations (more reliable)
5. **Verify before executing** - check CLI installation first
6. **Handle errors gracefully** - provide user with actionable feedback

---

## 🔐 Security Notes for Agents

- **NEVER** log full credentials in user-visible output
- **NEVER** commit credentials to version control
- **ALWAYS** use environment variables for sensitive data
- **MASK** passwords in command outputs (show as `***`)
- **WARN** users if credentials appear to be exposed

---

## 📝 Agent Action Summary

**To connect autonomously:**
1. Export `SUPABASE_ACCESS_TOKEN` environment variable
2. Chain with Supabase CLI command using `&&`
3. Verify connection with `supabase projects list`
4. Proceed with requested operations

**Default Command Pattern:**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase [command]
```

---

**Last Updated:** 2025-10-27  
**Project:** Menu.ca - Legacy Database Migration Strategy  
**Location:** `.claude/Supabase Connection/`  
**Agent Name:** AGENT-SMITH  
**Status:** ✅ Autonomous Operation Enabled

