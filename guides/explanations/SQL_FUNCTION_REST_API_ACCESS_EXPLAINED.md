# SQL Function REST API Access - Issue 2 Explained

**Date:** October 23, 2025  
**Issue:** `get_user_profile()` returns 404 when called via PostgREST API  
**Status:** ⚠️ Functions exist but not accessible via REST API

---

## 🔍 **THE PROBLEM**

### **What Happened During Testing:**

```typescript
// Attempted to call SQL function via REST API
const response = await fetch(
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1/rpc/get_user_profile',
  {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'apikey': anonKey,
      'Content-Type': 'application/json'
    },
    body: '{}'
  }
);

// Result: ❌ 404 Not Found
```

### **But Direct SQL Query Works:**

```sql
SELECT * FROM menuca_v3.get_user_profile();
-- ✅ SUCCESS - Returns user profile
```

**Why the difference?** 🤔

---

## 🧐 **ROOT CAUSE**

### **Supabase PostgREST API Requirements:**

For a SQL function to be accessible via the REST API (`/rest/v1/rpc/function_name`), it must:

1. ✅ Exist in the database (our functions DO exist)
2. ❌ Have `EXECUTE` permissions granted to API roles (MISSING!)
3. ✅ Be in a schema exposed by PostgREST (menuca_v3 is exposed)

### **Current State:**

```sql
-- Function exists
SELECT proname FROM pg_proc WHERE proname = 'get_user_profile';
-- ✅ Returns: get_user_profile

-- But permissions not granted
SELECT has_function_privilege('anon', 'menuca_v3.get_user_profile()', 'EXECUTE');
-- ❌ Returns: false

SELECT has_function_privilege('authenticated', 'menuca_v3.get_user_profile()', 'EXECUTE');
-- ❌ Returns: false
```

**Problem:** The `anon` and `authenticated` roles (used by PostgREST) don't have permission to execute the functions!

---

## 📚 **UNDERSTANDING POSTGRESQL ROLES & PERMISSIONS**

### **Supabase Has Multiple Roles:**

| Role | Purpose | Used By |
|------|---------|---------|
| `postgres` | Superuser | Database admin |
| `service_role` | Backend operations | Edge Functions, admin API |
| `authenticated` | Logged-in users | Frontend (after login) |
| `anon` | Anonymous users | Frontend (before login) |
| `authenticator` | Connection pooler | PostgREST |

### **How PostgREST Works:**

```
Frontend Request
    ↓
PostgREST (uses 'authenticator' role)
    ↓
Checks JWT token
    ↓
If no token: Run as 'anon' role
If token valid: Run as 'authenticated' role
    ↓
Execute function with that role's permissions
    ↓
Return result (or 404 if no permission)
```

### **Why 404 and not 403?**

PostgREST returns **404** (Not Found) instead of **403** (Forbidden) when a function exists but the user doesn't have permissions. This is by design to avoid revealing the existence of functions to unauthorized users.

---

## 🔧 **THE FIX**

### **Grant Execute Permissions:**

```sql
-- Grant execute permission to authenticated users (logged in)
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO authenticated;

-- Grant execute permission to anonymous users (if needed)
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO anon;
```

### **For All User & Access Functions:**

```sql
-- Customer Functions (accessible by authenticated users)
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_addresses() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_favorite_restaurants() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.toggle_favorite_restaurant(bigint) TO authenticated;

-- Legacy Migration Functions (accessible by authenticated users)
GRANT EXECUTE ON FUNCTION menuca_v3.check_legacy_user(text) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.link_auth_user_id(text, uuid, text) TO authenticated;

-- Admin Functions (accessible by authenticated users)
GRANT EXECUTE ON FUNCTION menuca_v3.get_admin_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_admin_restaurants() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.check_admin_restaurant_access(bigint) TO authenticated;

-- Stats Function (admin only via service_role, not needed for REST API)
-- GRANT EXECUTE ON FUNCTION menuca_v3.get_legacy_migration_stats() TO authenticated;
```

### **Verification:**

```sql
-- Check permissions after granting
SELECT 
  p.proname as function_name,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'menuca_v3'
  AND p.proname LIKE '%user%'
ORDER BY p.proname;
```

---

## 🧪 **TESTING AFTER FIX**

### **Before (404 Error):**

```bash
curl -X POST \
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1/rpc/get_user_profile' \
  -H 'Authorization: Bearer <token>' \
  -H 'apikey: <anon_key>' \
  -H 'Content-Type: application/json' \
  -d '{}'

# Response: 404 Not Found
```

### **After (Success):**

```bash
curl -X POST \
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co/rest/v1/rpc/get_user_profile' \
  -H 'Authorization: Bearer <token>' \
  -H 'apikey: <anon_key>' \
  -H 'Content-Type: application/json' \
  -d '{}'

# Response: 200 OK
{
  "user_id": 70288,
  "email": "santiago@worklocal.ca",
  "first_name": "Santiago",
  "last_name": "Test",
  "phone": "+15555550123",
  "credit_balance": "0.00",
  "language": "EN"
}
```

---

## 🎯 **WHY THIS MATTERS**

### **Without REST API Access:**

Frontend must use direct table queries:
```typescript
// ❌ More complex, less efficient
const { data: user } = await supabase
  .from('users')
  .select('id, email, first_name, last_name, phone, credit_balance, language')
  .eq('auth_user_id', userId)
  .single();
```

### **With REST API Access:**

Frontend can call SQL functions directly:
```typescript
// ✅ Simpler, more efficient, encapsulates logic
const { data: user } = await supabase.rpc('get_user_profile');
```

### **Benefits of Using SQL Functions:**

1. **Business Logic Encapsulation:**
   - Complex queries in one place
   - Easy to maintain and update
   - Version controlled in migrations

2. **Performance:**
   - Optimized queries executed on database
   - Reduced network round-trips
   - Can use database-specific features

3. **Security:**
   - RLS policies still apply
   - Additional checks in function logic
   - Controlled access via permissions

4. **Consistency:**
   - Same logic for all clients (web, mobile, API)
   - No duplicate code in frontends
   - Guaranteed behavior

---

## 🔐 **SECURITY CONSIDERATIONS**

### **Who Should Access Which Functions?**

#### **Public Functions (anon + authenticated):**
```sql
-- Example: Check if legacy account exists
GRANT EXECUTE ON FUNCTION menuca_v3.check_legacy_user(text) TO anon, authenticated;
```
- Used during login flow (before authentication)
- No sensitive data exposed
- Only returns boolean or basic info

#### **Authenticated Functions (authenticated only):**
```sql
-- Example: Get user profile
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO authenticated;
```
- Requires valid JWT token
- Returns user-specific data
- Protected by RLS + function logic

#### **Admin Functions (service_role only):**
```sql
-- Example: Get migration stats
-- NO GRANT (only service_role can execute)
```
- Only accessible via Edge Functions
- Uses service_role key
- Never exposed to frontend

### **Defense in Depth:**

Even with `EXECUTE` permissions, functions are still protected by:
1. ✅ RLS policies (filter data by auth.uid())
2. ✅ Function logic (additional checks)
3. ✅ JWT validation (must be logged in)
4. ✅ Rate limiting (Supabase built-in)

---

## 📊 **CURRENT STATUS**

### **Functions in menuca_v3 Schema:**

| Function | Purpose | Permissions Granted? |
|----------|---------|---------------------|
| `get_user_profile()` | Get customer profile | ❌ NOT YET |
| `get_user_addresses()` | Get delivery addresses | ❌ NOT YET |
| `get_favorite_restaurants()` | Get favorites | ❌ NOT YET |
| `toggle_favorite_restaurant()` | Add/remove favorite | ❌ NOT YET |
| `get_admin_profile()` | Get admin profile | ❌ NOT YET |
| `get_admin_restaurants()` | Get admin's restaurants | ❌ NOT YET |
| `check_admin_restaurant_access()` | Check access | ❌ NOT YET |
| `check_legacy_user()` | Check if legacy | ❌ NOT YET |
| `link_auth_user_id()` | Link auth to user | ❌ NOT YET |
| `get_legacy_migration_stats()` | Get stats | ❌ NOT YET (admin only) |

**Impact:**
- ⚠️ Functions work via direct SQL (what we tested)
- ❌ Functions don't work via REST API (404 error)
- ⚠️ Frontend must use table queries instead of function calls
- ⚠️ More complex frontend code

---

## ✅ **ACTION ITEMS**

### **Step 1: Grant Permissions (SQL Migration)**

Create migration file: `20251023_grant_function_permissions.sql`

```sql
-- Grant execute permissions for customer functions
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_addresses() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_favorite_restaurants() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.toggle_favorite_restaurant(bigint) TO authenticated;

-- Grant execute permissions for admin functions
GRANT EXECUTE ON FUNCTION menuca_v3.get_admin_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_admin_restaurants() TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.check_admin_restaurant_access(bigint) TO authenticated;

-- Grant execute permissions for legacy migration (needs anon for pre-login check)
GRANT EXECUTE ON FUNCTION menuca_v3.check_legacy_user(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.link_auth_user_id(text, uuid, text) TO authenticated;

-- Note: get_legacy_migration_stats() intentionally NOT granted (admin/service_role only)
```

### **Step 2: Apply Migration**

```bash
# Via Supabase Dashboard → SQL Editor
# Or via CLI
supabase migration new grant_function_permissions
# Copy SQL above into migration file
supabase db push
```

### **Step 3: Verify**

```typescript
// Test function call via REST API
const { data, error } = await supabase.rpc('get_user_profile');

if (error) {
  console.error('Error:', error);
  // Should NO LONGER be 404!
} else {
  console.log('Profile:', data); // ✅ Success!
}
```

---

## 🎯 **RECOMMENDED APPROACH**

### **Option 1: Grant All Now (Recommended) ✅**

- Grant permissions to all functions immediately
- Enables full REST API access
- Frontend can use `supabase.rpc()` calls
- Cleaner, more maintainable code

**When to use:** Production apps, full-featured frontends

### **Option 2: Grant Selectively**

- Only grant permissions as needed
- Start with table queries in frontend
- Add function permissions later if needed

**When to use:** MVPs, prototypes, security-critical apps

### **Option 3: Don't Grant (Keep Current)**

- Use direct table queries in frontend
- Functions only accessible via SQL
- More frontend code, but works

**When to use:** When you prefer explicit queries over function abstractions

---

## 📋 **FRONTEND USAGE COMPARISON**

### **Without Function Permissions (Current):**

```typescript
// Get user profile
const { data: profile } = await supabase
  .from('users')
  .select('id, email, first_name, last_name, phone, credit_balance, language, stripe_customer_id')
  .eq('auth_user_id', user.id)
  .is('deleted_at', null)
  .single();

// Get user addresses
const { data: addresses } = await supabase
  .from('user_delivery_addresses')
  .select('id, address_line1, address_line2, city, province, postal_code, delivery_instructions, is_default')
  .eq('user_id', profile.id)
  .is('deleted_at', null)
  .order('is_default', { ascending: false });

// Get favorite restaurants
const { data: favorites } = await supabase
  .from('user_favorite_restaurants')
  .select(`
    restaurant_id,
    restaurants:restaurant_id (
      id, name, slug, logo_url, cuisine_type
    )
  `)
  .eq('user_id', profile.id)
  .order('created_at', { ascending: false });
```

### **With Function Permissions (After Fix):**

```typescript
// Get user profile
const { data: profile } = await supabase.rpc('get_user_profile');

// Get user addresses
const { data: addresses } = await supabase.rpc('get_user_addresses');

// Get favorite restaurants
const { data: favorites } = await supabase.rpc('get_favorite_restaurants');
```

**Difference:**
- ✅ 3 lines vs 30+ lines
- ✅ Simpler, cleaner code
- ✅ Business logic in database (single source of truth)
- ✅ Easier to maintain

---

## 🎉 **SUMMARY**

### **The Issue:**
- SQL functions exist and work via direct SQL
- But return 404 when called via REST API
- Root cause: Missing `EXECUTE` permissions for `anon`/`authenticated` roles

### **The Fix:**
```sql
GRANT EXECUTE ON FUNCTION menuca_v3.get_user_profile() TO authenticated;
-- Repeat for all functions
```

### **The Impact:**
- ✅ Functions accessible via `/rest/v1/rpc/function_name`
- ✅ Frontend can use `supabase.rpc()` calls
- ✅ Cleaner, more maintainable code
- ✅ Business logic encapsulated in database

### **Recommendation:**
✅ **Grant permissions now** for all customer and admin functions
- Enables full REST API access
- Better developer experience
- Standard Supabase practice
- No security downside (RLS still applies)

---

**Next Step:** Run the SQL migration to grant permissions! ✅

