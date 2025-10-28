# Agent Quick Start: Supabase Connection

**Purpose:** Connect Claude Code session to Supabase database and test backend functionality.

---

## ⭐ Recommended Approach: Supabase CLI with Setup Scripts

**Why:** Supabase CLI is the **ONLY accurate way** to test backend functionality because it:
- ✅ **Tests with Auth Context** - Uses JWT tokens (`auth.uid()` works correctly)
- ✅ **Enforces RLS Policies** - Tests security policies as production would
- ✅ **Tests Edge Functions** - Can invoke and test Edge Functions
- ✅ **Production-Accurate** - Exactly how frontend and API clients interact
- ✅ **Complete Stack Testing** - Tests full auth → RLS → function flow

**When to use psql:** Only for quick database debugging (see bottom of this guide).

---

## 🚀 Step 1: Detect Operating System & Run Setup Script

### **For Windows Users:**

Run the PowerShell setup script:
```powershell
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1"
```

**Then verify connection:**
```powershell
supabase projects list
```

### **For Mac/Linux Users:**

Run the bash setup script:
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh"
```

**Then verify connection:**
```bash
supabase projects list
```

---

## 📦 What the Setup Scripts Configure

Both setup scripts set these environment variables:

| Variable | Purpose |
|----------|---------|
| `SUPABASE_ACCESS_TOKEN` | CLI access token for project management |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key for admin operations & Edge Functions |
| `SUPABASE_PROJECT_REF` | Project reference ID (`nthpbtdjhhnwfxqsxbvy`) |
| `SUPABASE_URL` | Project API URL (`https://nthpbtdjhhnwfxqsxbvy.supabase.co`) |
| `SUPABASE_CONNECTION_STRING` | PostgreSQL connection string |
| `SUPABASE_REST_API` | REST API endpoint |
| `PSQL_PATH` | Path to PostgreSQL client |

**Important for Claude Code:** Since each bash command runs in a separate session, you need to chain the setup script with your commands using `&&` or `; ` or run the script in each command.

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

### **Tool Capabilities Comparison**

#### **1. Supabase CLI** ✅ Project & Function Management

**What it CAN do:**
- ✅ List Edge Functions: `supabase functions list`
- ✅ Deploy Edge Functions: `supabase functions deploy`
- ✅ View function logs: `supabase functions logs`
- ✅ Pull database schema: `supabase db pull`
- ✅ Manage projects: `supabase projects list`
- ✅ Push migrations: `supabase db push`

**What it CANNOT do:**
- ❌ Execute SQL queries directly
- ❌ Call SQL functions with auth context
- ❌ Test RLS policies
- ❌ Create/read/update/delete table data

**Authentication:** Uses `SUPABASE_ACCESS_TOKEN`

---

#### **2. curl (Supabase REST API)** ✅ Production-Accurate Testing

**What it CAN do:**
- ✅ Call SQL functions with JWT tokens (auth.uid() works!)
- ✅ Test RLS policies (properly enforced)
- ✅ Invoke Edge Functions
- ✅ Create/login users via Auth API
- ✅ CRUD operations on tables (as user would)
- ✅ Test exactly how frontend interacts with backend

**What it CANNOT do:**
- ❌ Deploy functions
- ❌ Manage schema/migrations
- ❌ Execute arbitrary SQL (only via SQL functions)
- ❌ Direct database administration

**Authentication:**
- `Anon Key` + User JWT Token (for customer operations)
- `Service Role Key` (for admin operations)

---

#### **3. psql (PostgreSQL Client)** ✅ Database Debugging

**What it CAN do:**
- ✅ Execute ANY SQL query
- ✅ Check table structure: `\dt`, `\d table_name`
- ✅ View function definitions: `\sf function_name`
- ✅ Performance analysis: `EXPLAIN ANALYZE`
- ✅ Manual data inspection/fixes
- ✅ Check indexes, triggers, constraints

**What it CANNOT do:**
- ❌ Test auth context (auth.uid() returns NULL)
- ❌ Properly test RLS policies (connects as superuser)
- ❌ Test Edge Functions
- ❌ Represent production behavior

**Authentication:** PostgreSQL credentials (postgres user + password)

⚠️ **WARNING:** Use psql ONLY for debugging. It bypasses auth and RLS!

---

### **Decision Matrix: Which Tool for Your Task?**

**Need to test backend functionality?**
→ Use **curl** (REST API) with JWT tokens

**Need to deploy or manage Edge Functions?**
→ Use **Supabase CLI**

**Need to check schema or debug data?**
→ Use **psql** (debugging only)

**Need to test as a user would (with auth)?**
→ Use **curl** (REST API) with user JWT token

**Need to perform admin operations?**
→ Use **curl** with Service Role Key

**Need to pull database schema for version control?**
→ Use **Supabase CLI** (`db pull`)

---

## 💡 Agent Instructions: How to Use in Claude Code

**Since Claude Code runs each command in a separate session**, you have two options:

### **Option A: Chain Setup Script with Commands (Recommended for single commands)**

**Windows (PowerShell syntax in bash):**
```bash
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1" && supabase functions list
```

**Mac/Linux:**
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh" && supabase functions list
```

### **Option B: Export Variables Inline (Recommended for multiple commands)**

**For any OS (bash syntax):**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g" && supabase functions list
```

---

## 🎯 Common Supabase CLI Operations

### Check Supabase projects
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase projects list
```

### List all deployed Edge Functions
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase functions list
```

### Pull database schema
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase db pull
```

**Note:** Supabase CLI does **not** support direct SQL query execution. For SQL queries, use:
- **REST API with curl** (see Testing Backend Functionality section below)
- **psql client** (see Alternative: Direct Database Access section below)

---

## 🧪 Testing Backend Functionality

### Test SQL Functions via Supabase API

**Important:** SQL functions that use `auth.uid()` (like `get_user_profile()`) MUST be tested with proper auth context, not via direct psql.

**Create Test User via Supabase Auth API:**
```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/signup" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "options": {
      "data": {
        "first_name": "Test",
        "last_name": "User",
        "phone": "+1234567890"
      }
    }
  }'
```

**Login and Get JWT Token:**
```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/token?grant_type=password" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Test SQL Function with JWT Token:**
```bash
# Use the access_token from login response
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1/rpc/get_user_profile" \
  -H "Authorization: Bearer YOUR_USER_JWT_TOKEN" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI" \
  -H "Content-Type: application/json"
```

**Delete Test User (Cleanup):**
```bash
# Use service role key to delete user
curl -X DELETE "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/admin/users/USER_UUID" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g"
```

---

## 🔌 Testing Edge Functions

### List all Edge Functions
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase functions list
```

### Invoke Edge Function (Service Role Required)

**Example: Create Admin User**
```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/create-admin-user" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123",
    "first_name": "Admin",
    "last_name": "User",
    "restaurant_ids": [349]
  }'
```

**Example: Assign Admin Restaurants**
```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/assign-admin-restaurants" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_user_id": 1,
    "action": "add",
    "restaurant_ids": [349, 350]
  }'
```

### View Edge Function Logs
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase functions logs create-admin-user --follow
```

---

## 🔑 Connection Details Reference

| Detail | Value |
|--------|-------|
| **Host** | `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **User** | `postgres` |
| **Password** | `Gz35CPTom1RnsmGM` |
| **Project Ref** | `nthpbtdjhhnwfxqsxbvy` |
| **Project URL** | `https://nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Full Connection String** | `postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres` |
| **Access Token** | `sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9` |
| **Anon Key** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI` |
| **Service Role Key** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g` |

---

## 🛠️ Alternative: Direct Database Access (DEBUGGING ONLY)

**⚠️ WARNING:** Direct psql access should ONLY be used for debugging database schema or quick data inspection. It does NOT:
- ❌ Test auth context (`auth.uid()` returns NULL)
- ❌ Enforce RLS policies properly
- ❌ Test Edge Functions
- ❌ Represent how frontend/API interacts with backend

**Use psql only for:**
- Quick schema inspection
- Direct data queries (not function testing)
- Performance analysis (EXPLAIN)
- Migration verification

### PostgreSQL Client (psql) - Debugging Only

**For Windows:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR_SQL_HERE"
```

**For Mac/Linux:**
```bash
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "YOUR_SQL_HERE"
```

### Quick psql Commands (Debugging)

**List all tables:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "\dt menuca_v3.*"
```

**Check function definitions:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "\sf menuca_v3.get_user_profile"
```

**Query data directly:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT id, name FROM menuca_v3.restaurants LIMIT 5;"
```

---

## 🔧 Troubleshooting

### Supabase CLI not found
Install Supabase CLI:
```bash
# macOS
brew install supabase/tap/supabase

# Windows (via npm)
npm install -g supabase

# Or via scoop
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

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

### Setup script not loading environment variables
**Issue:** Variables not persisting in Claude Code.

**Solution:** Chain the script with your command using `&&`:
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh" && supabase functions list
```

### Connection timeout
- Check internet connection
- Verify Supabase project is not paused
- Confirm credentials are correct

### Permission denied
- Verify you're using the correct key (anon vs service role)
- Check if IP is whitelisted (if applicable)
- Ensure proper Authorization header

### Edge Function not found
- Verify function is deployed: `supabase functions list`
- Check function name spelling
- Ensure service role key is used (not anon key)

---

## 📝 Summary for Agents

### ⭐ CRITICAL: Choose the Right Tool for Each Task

**Before executing any command, determine which tool to use:**

| Your Task | Use This Tool | Command Pattern |
|-----------|---------------|-----------------|
| List/deploy Edge Functions | Supabase CLI | `export SUPABASE_ACCESS_TOKEN="..." && supabase functions list` |
| Test SQL functions | curl + JWT | `curl -X POST ".../rpc/function" -H "Authorization: Bearer JWT"` |
| Test Edge Functions | curl + Service Key | `curl -X POST ".../functions/v1/func" -H "Authorization: Bearer SERVICE_KEY"` |
| Create/login users | curl + Anon Key | `curl -X POST ".../auth/v1/signup" -H "apikey: ANON_KEY"` |
| Pull schema | Supabase CLI | `export SUPABASE_ACCESS_TOKEN="..." && supabase db pull` |
| Debug schema | psql | `psql "CONNECTION_STRING" -c "\sf function_name"` |

---

### **1. For Supabase CLI Operations (Functions & Schema Management)**

**Windows:**
```bash
. ".claude\Supabase Connection\windows_setup_supabase_session.ps1" && supabase [command]
```

**Mac/Linux:**
```bash
source ".claude/Supabase Connection/mac_setup_supabase_session.sh" && supabase [command]
```

**Or use inline:**
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase [command]
```

---

### **2. For Backend Testing (SQL Functions, Edge Functions, Auth)**

**Test SQL Functions (as authenticated user):**
```bash
# Step 1: Create user and get JWT token
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/signup" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'

# Step 2: Call SQL function with JWT token
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1/rpc/function_name" \
  -H "Authorization: Bearer USER_JWT_TOKEN" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNzM0ODQsImV4cCI6MjA3MDg0OTQ4NH0.q5JTULfxdk_ijOhWiOzG6dB6GjvT0M6LNjjX-JjM3mI" \
  -H "Content-Type: application/json"
```

**Test Edge Functions (as admin):**
```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/function-name" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI3MzQ4NCwiZXhwIjoyMDcwODQ5NDg0fQ.THhg9RhwfeN2B9V1SZdef0iJIeBntwd2w67p_J0ch1g" \
  -H "Content-Type: application/json" \
  -d '{"data": "value"}'
```

---

### **3. For Debugging ONLY (Schema Inspection)**

**Use psql for quick checks:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "\sf menuca_v3.function_name"
```

⚠️ **CRITICAL:** psql does NOT test auth context, RLS policies, or represent production behavior!

---

### **🚨 Common Mistakes to Avoid**

❌ **WRONG:** Using psql to test SQL functions
- Problem: auth.uid() returns NULL, RLS not enforced
- Solution: Use curl with JWT token

❌ **WRONG:** Using Supabase CLI to execute SQL queries
- Problem: `supabase db execute` doesn't exist
- Solution: Use curl for queries or psql for debugging

❌ **WRONG:** Using curl to deploy Edge Functions
- Problem: No API endpoint for deployment
- Solution: Use Supabase CLI `supabase functions deploy`

✅ **CORRECT:** Match the tool to the task using the table above

---

## ✅ Testing Checklist

When testing backend functionality, use this checklist:

### For SQL Functions:
- [ ] Use Supabase REST API with curl (NOT psql)
- [ ] Create test user via Auth API
- [ ] Login and get JWT token
- [ ] Test function with proper Authorization header
- [ ] Verify RLS policies are enforced
- [ ] Test error cases (unauthorized, missing params)
- [ ] Clean up test data when done

### For Edge Functions:
- [ ] List functions: `supabase functions list`
- [ ] Invoke with service role key via curl
- [ ] Check response for success/error
- [ ] Check logs: `supabase functions logs function-name`
- [ ] Test error cases
- [ ] Clean up test data when done

### For Database Schema:
- [x] Use psql for quick inspection (OK for this)
- [ ] Verify indexes exist
- [ ] Check function definitions
- [ ] Validate table structure

---

**Location:** `.claude/Supabase Connection/`
**Full Documentation:** See `README.md` in this directory
**Last Updated:** 2025-10-28
**Version:** 4.0 (Complete Tool Comparison & Decision Guide)
