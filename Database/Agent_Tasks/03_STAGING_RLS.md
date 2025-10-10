# TICKET 03: Staging RLS Policies

**Phase:** Staging Deployment - Step 3 of 5  
**Environment:** Staging Database  
**Estimated Duration:** 25-35 minutes  
**Prerequisites:** Ticket 02 (Staging Indexes) must be COMPLETE

---

## CONTEXT

- **Current Step:** 3 of 11 (Staging RLS Deployment)
- **Purpose:** Deploy Row Level Security policies for multi-tenant isolation
- **Risk Level:** MEDIUM (can block access if misconfigured)
- **Dependency:** Indexes from Ticket 02 are CRITICAL for RLS performance

**Before You Begin:**
- Verify Ticket 02 shows 45+ indexes deployed
- Have rollback script ready (can disable RLS quickly)
- Understand RLS can be disabled without data loss

**What This Does:**
- Enables RLS on all 50 tables
- Creates ~100-150 policies across tables
- Enforces tenant isolation (restaurants can only see their data)
- **Expected Result:** Security enforced, minimal performance overhead (<10%)

---

## TASK

Deploy comprehensive Row Level Security policies to enforce multi-tenant data isolation at the database level. This ensures restaurants can only access their own data, even with direct database access.

**Security Impact:**
- **Without RLS:** Any authenticated user could query all data
- **With RLS:** Users automatically filtered to their restaurant's data only

---

## COMMANDS TO RUN

### Step 1: Verify Pre-RLS State

**Agent Action:** Capture baseline before enabling RLS

```sql
-- Check current RLS status
SELECT 
  'PRE-RLS STATE' as label,
  COUNT(*) as total_tables,
  COUNT(CASE WHEN rowsecurity = true THEN 1 END) as rls_enabled_tables,
  COUNT(*) - COUNT(CASE WHEN rowsecurity = true THEN 1 END) as rls_disabled_tables
FROM pg_tables
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- total_tables: ~50
- rls_enabled_tables: 0 (or very few)
- rls_disabled_tables: ~50

### Step 2: Count Existing Policies

```sql
-- Check for existing policies
SELECT 
  COUNT(*) as existing_policies,
  COUNT(DISTINCT tablename) as tables_with_policies
FROM pg_policies
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- existing_policies: 0 (or very few if any)
- tables_with_policies: 0

### Step 3: Deploy RLS Policies Script

**Agent Action:** Execute the RLS policies creation script

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql`

**IMPORTANT:** Execute in sections (script has 9 sections with BEGIN/COMMIT blocks):

1. **Section 1: Enable RLS** (lines 14-73) - Enable on all tables
2. **Section 2: Restaurant Management Policies** (lines 75-208)
3. **Section 3: Menu & Catalog Policies** (lines 210-431)
4. **Section 4: Delivery Configuration Policies** (lines 433-508)
5. **Section 5: Marketing & Promotions Policies** (lines 510-571)
6. **Section 6: User Policies** (lines 573-627)
7. **Section 7: Admin Policies** (lines 629-644)
8. **Section 8: Infrastructure Policies** (lines 646-662)
9. **Section 9: Geography Policies** (lines 664-689)

**Execute Each Section:**

```bash
# For each section, execute the SQL between BEGIN; and COMMIT;
# Agent: Use MCP tools to execute each section

# Watch for:
# - "ALTER TABLE... ENABLE ROW LEVEL SECURITY" (Section 1)
# - "CREATE POLICY... ON..." (Sections 2-9)
# - No errors about policies already existing
```

**Expected Output per Section:**
```
BEGIN
ALTER TABLE
ALTER TABLE
...
COMMIT
```

Or:

```
BEGIN
CREATE POLICY
CREATE POLICY
...
COMMIT
```

**If Error Occurs:**
- "policy already exists" → OK, continue
- "table does not exist" → STOP, investigate
- "column does not exist" → STOP, check schema
- Permission denied → STOP, check database role

### Step 4: Verify RLS Enabled on All Tables

**Agent Action:** Confirm RLS is active

```sql
-- Check RLS enabled on all tables
SELECT 
  'POST-RLS ENABLE' as label,
  COUNT(*) as total_tables,
  COUNT(CASE WHEN rowsecurity = true THEN 1 END) as rls_enabled_tables,
  COUNT(CASE WHEN rowsecurity = false THEN 1 END) as rls_disabled_tables
FROM pg_tables
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- rls_enabled_tables: ~50 (all tables)
- rls_disabled_tables: 0

**If rls_disabled_tables > 0:**
- List which tables don't have RLS
- May need to enable manually
- Not necessarily a failure, but investigate

### Step 5: Count Created Policies

```sql
-- Count all policies created
SELECT 
  COUNT(*) as total_policies,
  COUNT(DISTINCT tablename) as tables_with_policies
FROM pg_policies
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- total_policies: 100-150 (script creates many policies)
- tables_with_policies: ~50 (all tables should have policies)

### Step 6: Verify Critical Policies Exist

```sql
-- Check for key policies
SELECT 
  tablename,
  policyname,
  cmd as command,
  qual as using_clause
FROM pg_policies
WHERE schemaname = 'menuca_v3'
  AND tablename IN ('dishes', 'restaurants', 'users', 'combo_groups')
ORDER BY tablename, policyname;
```

**Expected Output:**
- Each table should have 2-4 policies
- dishes: tenant_manage_dishes, public_view_active_dishes, admin_access_dishes
- restaurants: tenant_access_restaurants, tenant_update_restaurants, admin_manage_restaurants
- users: user_view_own_profile, user_update_own_profile, admin_access_users

**If Critical Policies Missing:**
- STOP and investigate
- These are essential for system function

### Step 7: Run RLS Test Suite

**Agent Action:** Execute comprehensive RLS tests

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/test_rls_policies.sql`

**IMPORTANT:** This test file has special formatting (uses `\echo` and `\timing`). 

**Adapt for execution:**
- Remove `\echo` commands (or log their text)
- Remove `\timing` command (track timing separately)
- Execute DO blocks and SELECT statements
- Capture all test results

**Key Tests to Run:**

```sql
-- Test 1.1: Tenant Isolation
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123", "role": "restaurant_owner"}', true);
END $$;

SELECT 
  COUNT(*) as my_restaurant_count,
  CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END as result
FROM menuca_v3.restaurants
WHERE id = 123;
-- Expected: PASS

-- Test 1.2: Cross-Tenant Block
SELECT 
  COUNT(*) as other_restaurant_dishes,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM menuca_v3.dishes
WHERE restaurant_id != 123;
-- Expected: PASS (should see 0 dishes from other restaurants)

-- Test 1.3: Public Read Access
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM menuca_v3.dishes
WHERE is_active = true
LIMIT 10;
-- Expected: PASS

-- Test 1.4: Admin Full Access
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"role": "admin"}', true);
END $$;

SELECT 
  CASE WHEN COUNT(*) > 1 THEN 'PASS' ELSE 'FAIL' END as result
FROM menuca_v3.restaurants;
-- Expected: PASS (admin sees all restaurants)
```

**Execute all tests from test_rls_policies.sql and track results.**

### Step 8: Performance Test (RLS Overhead)

**Agent Action:** Measure RLS impact on query performance

```sql
-- Test WITHOUT RLS (temporarily disable)
ALTER TABLE menuca_v3.dishes DISABLE ROW LEVEL SECURITY;

-- Measure query time
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 123;
-- Record execution time: [baseline_time]

-- Re-enable RLS
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;

-- Set context for RLS
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

-- Measure query time WITH RLS
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.dishes;
-- Record execution time: [rls_time]

-- Calculate overhead: ((rls_time - baseline_time) / baseline_time) * 100
```

**Expected Result:**
- RLS Overhead: < 10%
- Example: If baseline = 20ms, with RLS should be < 22ms

**Agent Note:** If overhead > 20%, investigate. May indicate missing indexes.

### Step 9: Verify Query Plans Use Indexes

```sql
-- Check that RLS + indexes work together
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

EXPLAIN 
SELECT * FROM menuca_v3.dishes;

-- Should show:
-- "Index Scan using idx_dishes_restaurant"
-- NOT "Seq Scan"
```

**Expected Output:**
- Query plan uses index
- RLS filter applied efficiently

### Step 10: Update EXECUTION_LOG

**Agent Action:** Document all results

```bash
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 03: Staging RLS Policies
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## Pre-RLS State
- Tables with RLS: [count from step 1]
- Existing Policies: [count from step 2]

## RLS Deployment
- Sections Executed: 9/9
- Tables RLS Enabled: [from step 4]
- Policies Created: [from step 5]

## RLS Testing
- Test 1.1 Tenant Isolation: PASS/FAIL
- Test 1.2 Cross-Tenant Block: PASS/FAIL
- Test 1.3 Public Read: PASS/FAIL
- Test 1.4 Admin Access: PASS/FAIL
- [Additional tests...]

## Performance Impact
- Query Time (no RLS): [baseline] ms
- Query Time (with RLS): [rls_time] ms
- RLS Overhead: [percentage]%
- Target: < 10% ✓ PASS / ✗ FAIL

## Query Plan Verification
- Uses Index Scan: ✓ YES / ✗ NO (Seq Scan detected)

## Validation Results (see below)

EOF
```

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **All 9 sections executed without fatal errors**
  - Check: Each section completed
  
- [ ] **RLS enabled on all ~50 tables**
  - Check: Step 4 shows rls_enabled_tables ≈ 50
  
- [ ] **100+ policies created**
  - Check: Step 5 shows total_policies >= 100
  
- [ ] **All tables have policies**
  - Check: Step 5 shows tables_with_policies ≈ 50
  
- [ ] **Critical policies exist**
  - Check: Step 6 found policies for dishes, restaurants, users
  
- [ ] **Tenant isolation test PASSES**
  - Check: Test 1.2 returns 0 dishes from other restaurants
  
- [ ] **Public read test PASSES**
  - Check: Test 1.3 can read active dishes
  
- [ ] **Admin access test PASSES**
  - Check: Test 1.4 admin sees all restaurants
  
- [ ] **RLS overhead < 10%**
  - Check: Step 8 overhead calculation
  
- [ ] **Query plans use indexes with RLS**
  - Check: Step 9 shows Index Scan not Seq Scan

---

## SUCCESS CONDITIONS

**All validation criteria must PASS.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Validation Results
   - ✓ RLS enabled: 50/50 tables
   - ✓ Policies created: [count]
   - ✓ Functional tests: ALL PASS
   - ✓ RLS overhead: [X]% (target <10%) ✓
   - ✓ Query plans: Using indexes ✓
   
   STATUS: COMPLETE
   ```

2. **Proceed to next ticket:**
   - Next: `04_STAGING_COMBOS.md`
   - RLS secured, ready for data migration

---

## FAILURE CONDITIONS

**If ANY validation fails:**

### Scenario 1: RLS Tests Fail

**Symptoms:**
- Tenant isolation test shows other restaurant's data
- Public read blocked when it shouldn't be
- Admin can't see all data

**Actions:**
1. STOP - Security issue
2. Check which specific test failed
3. Review policy for that table:
   ```sql
   SELECT * FROM pg_policies 
   WHERE schemaname = 'menuca_v3' 
     AND tablename = '[failing_table]';
   ```
4. Verify policy logic matches expectations
5. May need to fix policy and recreate
6. DO NOT PROCEED until all tests PASS

### Scenario 2: RLS Overhead > 20%

**Symptoms:**
- Queries significantly slower with RLS
- Overhead exceeds acceptable threshold

**Actions:**
1. Check if indexes from Ticket 02 exist:
   ```sql
   SELECT * FROM pg_indexes 
   WHERE schemaname = 'menuca_v3' 
     AND indexname = 'idx_dishes_restaurant';
   ```
2. If indexes missing, ROLLBACK to Ticket 02
3. Run ANALYZE on tables:
   ```sql
   ANALYZE menuca_v3.dishes;
   ANALYZE menuca_v3.restaurants;
   ```
4. Retry performance test
5. If still slow, review policy complexity

### Scenario 3: Query Plans Don't Use Indexes

**Symptoms:**
- EXPLAIN shows "Seq Scan" with RLS enabled
- Suggests indexes not being used

**Actions:**
1. Verify index exists and is valid
2. Run ANALYZE on table
3. Check RLS policy uses indexed column:
   ```sql
   SELECT qual FROM pg_policies 
   WHERE tablename = 'dishes';
   ```
4. Should see: `restaurant_id = ...`
5. If policy uses non-indexed column, critical issue

### Scenario 4: Policies Block Valid Access

**Symptoms:**
- Legitimate users can't access their data
- Application errors about permission denied

**Actions:**
1. STOP immediately
2. Check which table/operation is blocked
3. Review policy for that operation:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = '[table]' AND cmd = 'SELECT';
   ```
4. May need to adjust policy USING clause
5. Consider temporary RLS disable while fixing

---

## ROLLBACK

**If RLS deployment fails:**

### Option A: Disable RLS (Quick - 2 minutes)

```sql
-- Disable RLS on all tables (fast)
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename FROM pg_tables WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'ALTER TABLE menuca_v3.' || tbl.tablename || ' DISABLE ROW LEVEL SECURITY';
  END LOOP;
END $$;
```

**Time:** 2 minutes  
**Impact:** Returns to pre-RLS access (no tenant isolation)

### Option B: Drop All Policies (Medium - 5 minutes)

```sql
-- Drop all policies but keep RLS enabled
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS ' || pol.policyname || ' ON menuca_v3.' || pol.tablename;
  END LOOP;
END $$;
```

**Time:** 5 minutes  
**Impact:** RLS enabled but no policies (blocks all access)

### Option C: Full Database Restore

```bash
# Use backup from Ticket 01
supabase db restore --backup-id [backup-id-from-ticket-01]
```

**Time:** 15 minutes  
**Impact:** Reverts indexes AND RLS

**When to Use:**
- Option A: Quick fix, allows access testing
- Option B: Need to recreate policies from scratch
- Option C: Complete failure, corrupted state

---

## CONTEXT FOR NEXT STEP

```
RLS DEPLOYMENT RESULTS:
- Tables with RLS: ___/50
- Policies Created: _____
- Deployment Status: ✓ SUCCESS / ⚠ PARTIAL / ✗ FAILED

RLS TESTING:
- Tenant Isolation: ✓ PASS / ✗ FAIL
- Public Read: ✓ PASS / ✗ FAIL
- Admin Access: ✓ PASS / ✗ FAIL
- RLS Overhead: ____% (target: <10%)

READY FOR DATA MIGRATION:
✓ RLS policies deployed
✓ Security tests pass
✓ Performance acceptable
✓ Proceed to 04_STAGING_COMBOS.md
```

**Next Ticket:** `04_STAGING_COMBOS.md`

---

## NOTES FOR AGENT

### Why RLS Matters

**Security Benefits:**
- Database-level enforcement (can't be bypassed)
- Works even with direct SQL access
- Automatic filtering (no app logic needed)

**Without RLS:**
- Restaurant A queries: sees ALL restaurants' data
- Relies on application filtering (can be buggy)
- Direct DB access = security breach

**With RLS:**
- Restaurant A queries: automatically filtered to restaurant A only
- Impossible to see other restaurants' data
- Defense in depth

### Performance Keys

**RLS is fast IF:**
- ✓ Indexed columns in policies (restaurant_id)
- ✓ Simple equality predicates (restaurant_id = X)
- ✓ No subqueries in policies

**RLS is slow IF:**
- ✗ Non-indexed columns in policies
- ✗ Complex OR conditions
- ✗ Subqueries or JOINs in USING clause

Our policies follow all best practices.

---

**Ticket Status:** READY  
**Dependencies:** Ticket 02 COMPLETE (indexes required)  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

