# TICKET 08: Production RLS Policies

**Phase:** Production Deployment - Step 3 of 5  
**Environment:** Production Database ⚠️  
**Estimated Duration:** 30-40 minutes  
**Prerequisites:** Ticket 07 (Production Indexes) must be COMPLETE

---

## CONTEXT

- **Current Step:** 8 of 11 (Production RLS Deployment)
- **Purpose:** Deploy Row Level Security policies to production
- **Risk Level:** MEDIUM-HIGH (can block legitimate access if misconfigured)
- **⚠️ CRITICAL:** RLS errors can block all users - test thoroughly

**Before You Begin:**
- Verify Ticket 07 indexes deployed successfully
- Confirm indexes working (RLS needs them for performance)
- Have quick RLS disable script ready
- This matches staging Ticket 03

**What This Does:**
- Enables RLS on all 50 tables
- Creates ~100-150 security policies
- Enforces multi-tenant isolation
- **Expected Result:** Security enforced, < 10% performance overhead

---

## TASK

Deploy comprehensive RLS policies to production. This is identical to Ticket 03 but requires extra caution as RLS misconfiguration can block legitimate user access.

**Critical Success Factors:**
- All policies deploy without errors
- Test each type of access (tenant, public, admin)
- Verify performance acceptable
- Monitor for blocked users
- **Ready to disable RLS quickly if issues occur**

---

## COMMANDS TO RUN

### Steps 1-9: Follow Ticket 03 Process

Execute the same steps as Ticket 03:
1. Verify pre-RLS state
2. Count existing policies
3. Deploy RLS policies script (9 sections)
4. Verify RLS enabled
5. Count created policies
6. Verify critical policies
7. Run RLS test suite
8. Performance test (RLS overhead)
9. Verify query plans use indexes

**Reference Ticket 03 for detailed commands.**

### Step 10: Production-Specific RLS Testing

**⚠️ CRITICAL:** Test with real production scenarios

```sql
-- Test 1: Can real users access their data?
-- Use actual production restaurant ID
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', 
    '{"restaurant_id": "(SELECT id FROM menuca_v3.restaurants WHERE is_active = true LIMIT 1)"}', 
    true);
END $$;

SELECT 
  COUNT(*) as accessible_data,
  CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - USER BLOCKED!' END as result
FROM menuca_v3.dishes;

-- Expected: PASS (user can see their data)
```

```sql
-- Test 2: Public menu access working?
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  COUNT(*) as public_dishes,
  CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL - PUBLIC BLOCKED!' END as result
FROM menuca_v3.dishes 
WHERE is_active = true
LIMIT 10;

-- Expected: PASS (public can see active menus)
```

**If Either Test FAILS:**
- **CRITICAL:** RLS is blocking legitimate access
- **STOP** - Do not proceed
- Execute quick disable (see Rollback section)
- Investigate policy issue
- Fix and redeploy

### Step 11: Monitor for User Access Issues

**Agent Action:** Check for blocked queries

```sql
-- Check for permission denied errors
SELECT 
  query,
  COUNT(*) as error_count
FROM pg_stat_statements
WHERE query LIKE '%menuca_v3%'
  AND calls > 0
  AND (mean_exec_time > 1000 OR rows = 0)
GROUP BY query
ORDER BY error_count DESC
LIMIT 10;

-- Look for:
-- - Queries returning 0 rows (may indicate RLS blocking)
-- - Sudden spike in errors
```

### Step 12: Production Impact Assessment

**Agent Action:** Verify RLS not impacting users

```sql
-- Check overall database health post-RLS
SELECT 
  'RLS PRODUCTION IMPACT' as label,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') as active_connections,
  (SELECT SUM(xact_rollback) FROM pg_stat_database WHERE datname = current_database()) as total_rollbacks,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE wait_event_type = 'Lock') as waiting_queries,
  NOW() as check_time;
```

**Expected Output:**
- active_connections: Normal range
- No spike in rollbacks
- waiting_queries: < 5

---

## VALIDATION CRITERIA

All Ticket 03 validations PLUS:

- [ ] **Production access tests pass**
  - Real users can access their data ✓
  - Public can see active menus ✓
  
- [ ] **No blocked queries detected**
  - No spike in 0-row results
  - No permission denied errors
  
- [ ] **Production metrics stable**
  - Connections normal
  - No rollback spike
  - No lock contention

---

## SUCCESS CONDITIONS

If all checks pass:
1. **Log results (Ticket 03 format)**
2. **Production RLS verification:**
   ```
   ## Production RLS Status
   - Tenant Isolation: ✓ WORKING
   - Public Access: ✓ WORKING  
   - Admin Access: ✓ WORKING
   - User Impact: ✓ NONE (no blocked queries)
   - Performance Overhead: [X]% (target: <10%)
   
   STATUS: COMPLETE
   ```
3. **Communicate:** Post in war room: "Production RLS deployed. Security enforced. No user impact detected. Proceeding to combo fix."
4. **Proceed:** Next ticket 09_PRODUCTION_COMBOS.md

---

## FAILURE CONDITIONS

### Scenario: RLS Blocking Legitimate Users

**Symptoms:**
- Users can't access their own data
- Public menu shows no results
- Customer support tickets spiking

**Actions:**
1. **IMMEDIATE:** Execute quick RLS disable (see Rollback)
2. **Communicate:** Alert team "RLS blocking users - disabled for investigation"
3. **Investigate:** Which policy is too restrictive?
4. **Fix:** Correct policy logic
5. **Re-test:** In staging first
6. **Re-deploy:** When confident

### Scenario: Performance Degradation

**Symptoms:**
- Queries suddenly very slow (> 500ms)
- RLS overhead > 20%

**Actions:**
1. Check indexes exist and being used
2. Run ANALYZE on tables
3. If no improvement, may need to disable RLS
4. Investigate policy complexity

---

## ROLLBACK

### Quick RLS Disable (2 minutes) - Use if Blocking Users

```sql
-- EMERGENCY: Disable RLS immediately
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename FROM pg_tables WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'ALTER TABLE menuca_v3.' || tbl.tablename || ' DISABLE ROW LEVEL SECURITY';
    RAISE NOTICE 'Disabled RLS on menuca_v3.%', tbl.tablename;
  END LOOP;
END $$;

-- Verify disabled
SELECT COUNT(*) FROM pg_tables 
WHERE schemaname = 'menuca_v3' AND rowsecurity = true;
-- Should return 0
```

**After disabling:**
- Users should regain access immediately
- Security temporarily relaxed (not ideal but necessary)
- Fix policies and redeploy when ready

### Full Database Restore

```bash
# Use backup from Ticket 06
supabase db restore --backup-id [production-backup-id-from-ticket-06]
```

**Time:** 15 minutes  
**Use when:** Complete failure, can't quick-fix

---

## CONTEXT FOR NEXT STEP

```
PRODUCTION RLS DEPLOYED
================================================================================

RLS DEPLOYMENT:
- Tables with RLS: ___/50
- Policies Created: _____
- Status: ✓ SUCCESS

RLS TESTING:
- Tenant Isolation: ✓ PASS
- Public Access: ✓ PASS
- Admin Access: ✓ PASS
- Performance Overhead: ____% (<10%)

PRODUCTION IMPACT:
- User Access: ✓ NO ISSUES
- Customer Reports: ✓ NONE
- Performance: ✓ ACCEPTABLE

NEXT STEP:
→ Proceed to 09_PRODUCTION_COMBOS.md

SAFETY:
- Can disable RLS in 2 minutes if needed
- Rollback to backup in 15 minutes
```

**Next Ticket:** `09_PRODUCTION_COMBOS.md`

---

## NOTES FOR AGENT

### Why RLS is High Risk

**Potential Issues:**
- **Overly restrictive policy** → Blocks legitimate users
- **Performance issue** → Queries become very slow
- **Logic error** → Wrong data returned

**That's why we:**
- Test heavily before deploying
- Monitor closely during deployment
- Have quick disable ready
- Can rollback if needed

### Good Indicators

**RLS Working Well:**
- All tests pass immediately
- Performance overhead < 5%
- No user-facing issues
- Query plans use indexes

**RLS Having Issues:**
- Tests fail or timeout
- Performance overhead > 15%
- Support tickets spike
- Queries returning 0 rows unexpectedly

### Communication Critical

**Keep war room updated:**
- When RLS deployment starts
- Each test result
- Any concerning metrics
- When complete

**If issues occur:**
- Immediate alert
- Don't wait to investigate
- Team needs to know NOW

---

**Ticket Status:** READY  
**Dependencies:** Ticket 07 COMPLETE  
**Last Updated:** October 10, 2025  

**⚠️ HIGH RISK - READY TO DISABLE IF NEEDED ⚠️**

