# Agent Quick Start: Supabase Connection

**Purpose:** Connect any agent to Supabase database securely using environment variables.

**Project:** `menu-rebuild-vo` (nthpbtdjhhnwfxqsxbvy)

---

## 🔐 SECURITY FIRST: Environment Variables

**ALL credentials are stored in:**
```
.env files/.env
```

**⚠️ NEVER hardcode credentials in this file or any other file!**

**To access credentials, see:** `.env files/ENV_ACCESS_GUIDE.md`

---

## 🚀 Quick Start: Choose Your Method

### **Method 1: Use Setup Scripts (Recommended)**

The setup scripts automatically load all credentials from `.env files/.env`.

**Windows:**
```powershell
. "Supabase Connection\windows_setup_supabase_session.ps1"
```

**Mac/Linux:**
```bash
source "Supabase Connection/mac_setup_supabase_session.sh"
```

**Then verify connection:**
```bash
supabase projects list
```

---

### **Method 2: Load Environment Variables Manually**

If you need to run a single command without the setup script:

**Load from .env first:**
```powershell
# PowerShell - Load variables
Get-Content ".\.env files\.env" | ForEach-Object {
    if ($_ -match '^([A-Z_]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# Then use them
supabase projects list
```

---

## 📦 What Gets Configured

The setup scripts configure these environment variables from `.env files/.env`:

| Variable | Purpose | Source in .env |
|----------|---------|----------------|
| `SUPABASE_URL` | Project API URL | `SUPABASE_URL` |
| `SUPABASE_KEY` | Service role key for admin operations | `SUPABASE_KEY` |
| `DB_CONNECTION_STRING` | PostgreSQL connection string | `DB_CONNECTION_STRING` |
| `CRM_USERNAME` | Legacy CRM username | `CRM_USERNAME` |
| `CRM_PASSWORD` | Legacy CRM password | `CRM_PASSWORD` |

**Additional derived variables:**
- `SUPABASE_PROJECT_REF` = `nthpbtdjhhnwfxqsxbvy`
- `SUPABASE_REST_API` = `${SUPABASE_URL}/rest/v1`
- `PSQL_PATH` = Path to PostgreSQL client

---

## 🔍 Understanding the Tools: Supabase CLI vs curl vs psql

### **Which Tool to Use?**

| Task | Tool to Use | Why |
|------|-------------|-----|
| **List/Deploy Edge Functions** | Supabase CLI | Only tool that can manage Edge Functions |
| **Test SQL Functions (with auth)** | curl (REST API) | Tests with JWT tokens, enforces RLS, production-accurate |
| **Test Edge Functions** | curl (REST API) | Production testing with proper auth keys |
| **Create/Login Users** | curl (Auth API) | Supabase Auth endpoints |
| **Pull/Push Schema** | Supabase CLI | Schema migration management |
| **Check Table Structure** | psql | Quick inspection, view definitions |
| **Execute Raw SQL** | psql | Direct database access |
| **Performance Analysis** | psql | EXPLAIN ANALYZE queries |

---

## 🎯 Common Operations

### 1. List Supabase Projects

```bash
# After running setup script:
supabase projects list

# Or inline (loads from .env):
. "Supabase Connection\windows_setup_supabase_session.ps1" && supabase projects list
```

---

### 2. List Edge Functions

```bash
# After running setup script:
supabase functions list

# Or inline:
. "Supabase Connection\windows_setup_supabase_session.ps1" && supabase functions list
```

---

### 3. Pull Database Schema

```bash
# After running setup script:
supabase db pull

# Or inline:
. "Supabase Connection\windows_setup_supabase_session.ps1" && supabase db pull
```

---

### 4. Query Database with psql

**⚠️ For debugging only! Does NOT test auth context or RLS.**

```powershell
# Windows - After running setup script:
. "Supabase Connection\windows_setup_supabase_session.ps1"
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "SELECT COUNT(*) FROM menuca_v3.restaurants;"
```

```bash
# Mac/Linux - After running setup script:
source "Supabase Connection/mac_setup_supabase_session.sh"
psql "$DB_CONNECTION_STRING" -c "SELECT COUNT(*) FROM menuca_v3.restaurants;"
```

---

### 5. Test SQL Functions (Production-Accurate)

**Important:** SQL functions that use `auth.uid()` MUST be tested via REST API, not psql!

```bash
# Step 1: Load environment
. "Supabase Connection\windows_setup_supabase_session.ps1"

# Step 2: Create test user
curl -X POST "${SUPABASE_URL}/auth/v1/signup" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!",
    "options": {
      "data": {
        "first_name": "Test",
        "last_name": "User"
      }
    }
  }'

# Step 3: Login to get JWT token
curl -X POST "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }' | jq -r '.access_token'

# Step 4: Test function with JWT (replace YOUR_JWT_TOKEN with token from step 3)
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/get_user_profile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json"
```

---

### 6. Invoke Edge Functions

```bash
# Load environment
. "Supabase Connection\windows_setup_supabase_session.ps1"

# Invoke function (requires service role key)
curl -X POST "${SUPABASE_URL}/functions/v1/create-admin-user" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePass123!",
    "first_name": "Admin",
    "last_name": "User",
    "restaurant_ids": [349]
  }'
```

---

### 7. View Edge Function Logs

```bash
# After running setup script:
supabase functions logs create-admin-user --follow
```

---

## 🧪 Testing Backend Functionality

### Complete Test Flow Example

```bash
# 1. Load environment variables
. "Supabase Connection\windows_setup_supabase_session.ps1"

# 2. Create test user
TEST_EMAIL="test-$(date +%s)@example.com"
curl -X POST "${SUPABASE_URL}/auth/v1/signup" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"TestPass123!\",
    \"options\": {
      \"data\": {
        \"first_name\": \"Test\",
        \"last_name\": \"User\"
      }
    }
  }"

# 3. Login and capture JWT token
JWT_TOKEN=$(curl -X POST "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"TestPass123!\"
  }" | jq -r '.access_token')

# 4. Test SQL function with auth context
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/get_user_profile" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json"

# 5. Cleanup - Delete test user (requires user UUID from step 2)
# curl -X DELETE "${SUPABASE_URL}/auth/v1/admin/users/USER_UUID" \
#   -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
#   -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}"
```

---

## 🔌 Project Details

| Detail | Value | Where to Find |
|--------|-------|---------------|
| **Project Name** | menu-rebuild-vo | Dashboard |
| **Project Ref** | nthpbtdjhhnwfxqsxbvy | Dashboard / `.env files/.env` |
| **Host** | db.nthpbtdjhhnwfxqsxbvy.supabase.co | From `DB_CONNECTION_STRING` |
| **Port** | 5432 | Standard PostgreSQL |
| **Database** | postgres | Standard |
| **Schema** | menuca_v3 | Application schema |
| **Project URL** | https://nthpbtdjhhnwfxqsxbvy.supabase.co | `.env files/.env` → `SUPABASE_URL` |
| **Connection String** | See `.env files/.env` | `DB_CONNECTION_STRING` |
| **Service Role Key** | See `.env files/.env` | `SUPABASE_KEY` |
| **Anon Key** | Contact admin | Not in .env (public key) |

**🔐 To access any credential:** See `.env files/ENV_ACCESS_GUIDE.md`

---

## 🛠️ Tool Comparison

### **1. Supabase CLI** ✅ Project & Function Management

**Can do:**
- ✅ List Edge Functions: `supabase functions list`
- ✅ Deploy Edge Functions: `supabase functions deploy`
- ✅ View function logs: `supabase functions logs`
- ✅ Pull database schema: `supabase db pull`
- ✅ Manage projects: `supabase projects list`
- ✅ Push migrations: `supabase db push`

**Cannot do:**
- ❌ Execute SQL queries directly
- ❌ Call SQL functions with auth context
- ❌ Test RLS policies
- ❌ CRUD operations on tables

**Authentication:** Uses `SUPABASE_ACCESS_TOKEN` (from .env)

---

### **2. curl (Supabase REST API)** ✅ Production-Accurate Testing

**Can do:**
- ✅ Call SQL functions with JWT tokens (`auth.uid()` works!)
- ✅ Test RLS policies (properly enforced)
- ✅ Invoke Edge Functions
- ✅ Create/login users via Auth API
- ✅ CRUD operations on tables (as user would)
- ✅ Test exactly how frontend interacts with backend

**Cannot do:**
- ❌ Deploy functions
- ❌ Manage schema/migrations
- ❌ Execute arbitrary SQL (only via SQL functions)
- ❌ Direct database administration

**Authentication:**
- Anon Key + User JWT Token (for customer operations)
- Service Role Key (for admin operations) - from `.env files/.env`

---

### **3. psql (PostgreSQL Client)** ✅ Database Debugging

**Can do:**
- ✅ Execute ANY SQL query
- ✅ Check table structure: `\dt`, `\d table_name`
- ✅ View function definitions: `\sf function_name`
- ✅ Performance analysis: `EXPLAIN ANALYZE`
- ✅ Manual data inspection/fixes
- ✅ Check indexes, triggers, constraints

**Cannot do:**
- ❌ Test auth context (`auth.uid()` returns NULL)
- ❌ Properly test RLS policies (connects as superuser)
- ❌ Test Edge Functions
- ❌ Represent production behavior

**Authentication:** PostgreSQL credentials (from `DB_CONNECTION_STRING`)

**⚠️ WARNING:** Use psql ONLY for debugging. It bypasses auth and RLS!

---

## 💡 Decision Matrix: Which Tool for Your Task?

| Your Goal | Use This Tool | Why |
|-----------|---------------|-----|
| **Test user-facing functionality** | curl + JWT | Tests auth, RLS, exactly like production |
| **Test admin operations** | curl + Service Role Key | Admin-level testing |
| **Deploy Edge Functions** | Supabase CLI | Only way to deploy |
| **View function logs** | Supabase CLI | Built-in log viewer |
| **Check table schema** | psql | Quick schema inspection |
| **Debug SQL performance** | psql | EXPLAIN ANALYZE |
| **Pull schema for version control** | Supabase CLI | Schema management |
| **Create/authenticate users** | curl + Auth API | User management |

---

## 🔧 Common psql Commands (Debugging Only)

**⚠️ Remember: psql does NOT test auth context or RLS!**

```bash
# Load environment first
. "Supabase Connection\windows_setup_supabase_session.ps1"

# List all tables in menuca_v3 schema
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "\dt menuca_v3.*"

# Describe a specific table
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "\d menuca_v3.restaurants"

# View function definition
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "\sf menuca_v3.get_user_profile"

# List all functions in schema
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "\df menuca_v3.*"

# Count rows in table
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "SELECT COUNT(*) FROM menuca_v3.restaurants;"

# Check indexes
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = 'menuca_v3';"

# Query with formatting
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "SELECT id, name, status FROM menuca_v3.restaurants LIMIT 5;"
```

---

## 🚨 Important Security Notes

### ✅ DO's

- ✅ **Always load credentials from `.env files/.env`**
- ✅ **Use setup scripts for consistent environment**
- ✅ **Test with proper auth context (curl + JWT)**
- ✅ **Use psql only for debugging schema**
- ✅ **Verify environment variables are loaded before commands**

### ❌ DON'Ts

- ❌ **NEVER hardcode credentials in files**
- ❌ **NEVER use psql to test SQL functions** (auth.uid() returns NULL!)
- ❌ **NEVER commit `.env files/.env` to git**
- ❌ **NEVER share credentials in chat, logs, or documentation**
- ❌ **NEVER test production features without auth context**

---

## 🔧 Troubleshooting

### Issue: "SUPABASE_ACCESS_TOKEN not set"

**Solution:**
```powershell
# Run the setup script first
. "Supabase Connection\windows_setup_supabase_session.ps1"

# Verify it's loaded
echo $env:SUPABASE_ACCESS_TOKEN
```

---

### Issue: "Connection refused" or "Timeout"

**Checklist:**
1. Verify `.env files/.env` exists and contains `DB_CONNECTION_STRING`
2. Check internet connection
3. Verify Supabase project is not paused
4. Test with: `curl ${SUPABASE_URL}/rest/v1/`

---

### Issue: "psql not found"

**Windows:**
```powershell
# Use full path
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $env:DB_CONNECTION_STRING -c "SELECT 1;"
```

**Mac/Linux:**
```bash
# Install PostgreSQL client
brew install postgresql@17  # macOS
sudo apt install postgresql-client  # Ubuntu/Debian
```

---

### Issue: "auth.uid() returns NULL in function"

**Problem:** You're using psql to test the function.

**Solution:** Test via REST API with JWT token (see "Test SQL Functions" section above).

---

### Issue: "Setup script errors"

**Check:**
```powershell
# Verify .env file exists
Test-Path ".\.env files\.env"

# Check file contents (without exposing secrets)
Get-Content ".\.env files\.env" | Select-String "SUPABASE_URL"
```

---

### Issue: "Edge Function not found"

**Solution:**
```bash
# List all deployed functions
. "Supabase Connection\windows_setup_supabase_session.ps1" && supabase functions list

# Verify function name spelling
# Deploy if needed (from function directory):
# supabase functions deploy function-name
```

---

## 📚 Additional Resources

### Documentation Files

- **`.env files/ENV_ACCESS_GUIDE.md`** - How to access environment variables
- **`windows_setup_supabase_session.ps1`** - Windows setup script
- **`mac_setup_supabase_session.sh`** - Mac/Linux setup script
- **`ENVIRONMENT_LOADING_UPDATE.md`** - Security implementation details

### Supabase Dashboard

- **URL:** https://supabase.com/dashboard
- **Project:** menu-rebuild-vo (nthpbtdjhhnwfxqsxbvy)
- **View:** Tables, Functions, Policies, Edge Functions, Logs

### External Documentation

- **Supabase Docs:** https://supabase.com/docs
- **Supabase CLI:** https://supabase.com/docs/guides/cli
- **PostgreSQL Docs:** https://www.postgresql.org/docs/

---

## ✅ Quick Reference Card

### For New Agents: 3-Step Connection

```bash
# 1. Load environment
. "Supabase Connection\windows_setup_supabase_session.ps1"

# 2. Verify connection
supabase projects list

# 3. Start working
# - Use Supabase CLI for Edge Functions
# - Use curl for API testing
# - Use psql for schema debugging only
```

### Command Templates

**Supabase CLI:**
```bash
. "Supabase Connection\windows_setup_supabase_session.ps1" && supabase [command]
```

**REST API Call:**
```bash
. "Supabase Connection\windows_setup_supabase_session.ps1"
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/function_name" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json"
```

**psql Query:**
```bash
. "Supabase Connection\windows_setup_supabase_session.ps1"
& $env:PSQL_PATH $env:DB_CONNECTION_STRING -c "YOUR_SQL"
```

---

## 🎯 Summary

**To connect to Supabase securely:**

1. ✅ **All credentials are in** `.env files/.env`
2. ✅ **Use setup scripts** to load environment
3. ✅ **Choose the right tool** for each task
4. ✅ **Test with auth context** (curl + JWT)
5. ✅ **Use psql only for debugging** schema

**Never hardcode credentials anywhere!**

---

**Last Updated:** December 3, 2025  
**Version:** 5.0 (Secure - Environment Variables Only)  
**Project:** menu-rebuild-vo (nthpbtdjhhnwfxqsxbvy)
