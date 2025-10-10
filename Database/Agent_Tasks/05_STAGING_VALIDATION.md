# TICKET 05: Staging Validation

**Phase:** Staging Deployment - Step 5 of 5 (FINAL STAGING STEP)  
**Environment:** Staging Database  
**Estimated Duration:** 30-45 minutes active + 4 hours passive monitoring  
**Prerequisites:** Tickets 01-04 (All staging deployment) must be COMPLETE

---

## CONTEXT

- **Current Step:** 5 of 11 (Staging Final Validation)
- **Purpose:** Comprehensive validation of all staging changes before production
- **Risk Level:** LOW (read-only validation, no changes made)
- **Dependency:** All previous staging tickets must show SUCCESS

**Before You Begin:**
- Review EXECUTION_LOG.md - verify tickets 01-04 all show COMPLETE
- Confirm no errors or warnings from previous tickets
- Understand this is the GO/NO-GO gate for production deployment

**What This Does:**
- Validates indexes are working (performance improved)
- Validates RLS policies are functional (security enforced)
- Validates combo fix succeeded (orphan rate < 5%)
- Monitors stability for 4+ hours
- **Expected Result:** All systems validated, ready for production

---

## TASK

Execute comprehensive validation suite to verify all staging changes are working correctly and the database is stable. This ticket is the final checkpoint before proceeding to production deployment.

**GO/NO-GO Decision:**
- **GO:** All validations pass + 4h stability → Proceed to Production (Ticket 06)
- **NO-GO:** Any failures → STOP, investigate, fix, or rollback

---

## COMMANDS TO RUN

### Step 1: Verify All Previous Tickets Complete

**Agent Action:** Check EXECUTION_LOG.md for completion status

```bash
# Check that all previous tickets show COMPLETE
grep -E "TICKET 0[0-4]" /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md | grep "STATUS: COMPLETE"

# Should show 5 lines (tickets 00-04)
```

**Expected Output:**
- 5 lines showing "STATUS: COMPLETE"
- If any ticket shows FAILED or is missing, STOP

**If Not All Complete:**
- Review which ticket(s) are incomplete
- DO NOT proceed to validation
- Go back and complete/fix previous tickets

### Step 2: Comprehensive Database State Check

**Agent Action:** Capture complete current state

```sql
-- Complete database state summary
SELECT 
  'STAGING FINAL STATE' as label,
  -- Tables
  (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'menuca_v3') as total_tables,
  -- Indexes
  (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'menuca_v3' AND indexname LIKE 'idx_%') as custom_indexes,
  -- RLS
  (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'menuca_v3' AND rowsecurity = true) as rls_enabled_tables,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'menuca_v3') as total_policies,
  -- Data
  (SELECT COUNT(*) FROM menuca_v3.restaurants) as restaurants,
  (SELECT COUNT(*) FROM menuca_v3.dishes) as dishes,
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as combo_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as combo_items,
  -- Timestamp
  NOW() as validation_time;
```

**Expected Output:**
- total_tables: ~50
- custom_indexes: 45-50
- rls_enabled_tables: ~50
- total_policies: 100-150
- restaurants: ~944
- dishes: ~10,585
- combo_groups: ~8,234
- combo_items: 50,000-120,000 (HUGE increase from ~63!)

**Agent Note:** Record all counts. These are the validated staging values.

### Step 3: Performance Validation

**Agent Action:** Verify query performance improvements

```sql
-- Test 1: Menu Query Performance
EXPLAIN ANALYZE
SELECT 
  d.id, d.name, d.base_price, d.prices,
  c.name as course,
  COUNT(dm.id) as modifier_count
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
LEFT JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id
WHERE d.restaurant_id = 123 AND d.is_active = true
GROUP BY d.id, c.name, d.name, d.base_price, d.prices;

-- Expected:
-- - Execution Time: < 100ms
-- - Planning Time: < 10ms
-- - Query Plan uses "Index Scan" not "Seq Scan"
```

**Success Criteria:**
- Execution Time < 100ms ✓
- Uses idx_dishes_restaurant ✓
- Uses idx_dish_modifiers_dish ✓

```sql
-- Test 2: Combo Assembly Query
EXPLAIN ANALYZE
SELECT 
  cg.id, cg.name,
  COUNT(ci.id) as item_count,
  string_agg(d.name, ', ') as dishes
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
WHERE cg.restaurant_id = 123
GROUP BY cg.id, cg.name;

-- Expected:
-- - Execution Time: < 100ms
-- - Uses idx_combo_items_group
-- - Uses idx_combo_groups_restaurant
```

**Success Criteria:**
- Execution Time < 100ms ✓
- Proper index usage ✓
- Results returned (combos have dishes) ✓

### Step 4: RLS Functional Validation

**Agent Action:** Run comprehensive RLS security tests

```sql
-- Test 1: Tenant Isolation Working
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"restaurant_id": "123"}', true);
END $$;

-- Should only see restaurant 123's data
SELECT 
  COUNT(*) as accessible_dishes,
  COUNT(CASE WHEN restaurant_id != 123 THEN 1 END) as wrong_restaurant,
  CASE 
    WHEN COUNT(CASE WHEN restaurant_id != 123 THEN 1 END) = 0 THEN 'PASS'
    ELSE 'FAIL'
  END as result
FROM menuca_v3.dishes;
-- Expected: wrong_restaurant = 0, result = PASS

-- Test 2: Public Can See Active Items
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{}', true);
END $$;

SELECT 
  COUNT(*) as public_dishes,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASS'
    ELSE 'FAIL'
  END as result
FROM menuca_v3.dishes
WHERE is_active = true
LIMIT 100;
-- Expected: public_dishes > 0, result = PASS

-- Test 3: Admin Sees Everything
DO $$
BEGIN
  PERFORM set_config('request.jwt.claims', '{"role": "admin"}', true);
END $$;

SELECT 
  COUNT(DISTINCT restaurant_id) as restaurant_count,
  CASE 
    WHEN COUNT(DISTINCT restaurant_id) > 1 THEN 'PASS'
    ELSE 'FAIL'
  END as result
FROM menuca_v3.dishes;
-- Expected: restaurant_count > 1, result = PASS
```

**Success Criteria:**
- All 3 tests show result = 'PASS'
- RLS enforcing security correctly

### Step 5: Combo System Validation

**Agent Action:** Verify combo fix was successful

```sql
-- Calculate final orphan rate
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned_groups,
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct,
  CASE 
    WHEN ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) < 1.0 
      THEN 'EXCELLENT'
    WHEN ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) < 5.0 
      THEN 'PASS'
    ELSE 'FAIL'
  END as result
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;
```

**Success Criteria:**
- orphan_pct < 5.0 ✓ (ideally < 1.0)
- result = 'PASS' or 'EXCELLENT'

```sql
-- Check item distribution
SELECT 
  items_per_combo,
  COUNT(*) as combo_count,
  ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) as percentage
FROM (
  SELECT 
    cg.id,
    COUNT(ci.id) as items_per_combo
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
  GROUP BY cg.id
) subquery
GROUP BY items_per_combo
ORDER BY items_per_combo;

-- Expected distribution:
-- - 0 items: < 5% of combos
-- - 2-4 items: Most combos (60-80%)
-- - 5+ items: Some combos (10-20%)
```

### Step 6: Data Integrity Validation

**Agent Action:** Run comprehensive integrity checks

```sql
-- Check for data quality issues
SELECT 
  'NULL CHECK' as test,
  COUNT(*) as issues,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM (
  SELECT * FROM menuca_v3.combo_items WHERE dish_id IS NULL
  UNION ALL
  SELECT * FROM menuca_v3.combo_items WHERE combo_group_id IS NULL
  UNION ALL
  SELECT * FROM menuca_v3.dishes WHERE restaurant_id IS NULL
) issues;

-- Foreign Key Integrity
SELECT 
  'FK INTEGRITY' as test,
  COUNT(*) as issues,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM (
  SELECT ci.id FROM menuca_v3.combo_items ci
  LEFT JOIN menuca_v3.dishes d ON ci.dish_id = d.id
  WHERE d.id IS NULL
  UNION ALL
  SELECT ci.id FROM menuca_v3.combo_items ci
  LEFT JOIN menuca_v3.combo_groups cg ON ci.combo_group_id = cg.id
  WHERE cg.id IS NULL
) issues;

-- Duplicate Check
SELECT 
  'DUPLICATES' as test,
  COUNT(*) as issues,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as result
FROM (
  SELECT combo_group_id, dish_id, COUNT(*)
  FROM menuca_v3.combo_items
  GROUP BY combo_group_id, dish_id
  HAVING COUNT(*) > 1
) duplicates;
```

**Success Criteria:**
- All tests show result = 'PASS'
- All issues counts = 0

### Step 7: Error Log Check

**Agent Action:** Check for database errors

```sql
-- Check for recent errors (if pg_stat_statements available)
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  rows
FROM pg_stat_statements
WHERE query LIKE '%menuca_v3%'
  AND calls > 0
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Look for:
-- - No queries with extremely high execution times (> 1 second)
-- - No queries with very high call counts and slow times
```

### Step 8: Database Health Metrics

**Agent Action:** Check overall database health

```sql
-- Connection and resource usage
SELECT 
  'DATABASE HEALTH' as label,
  numbackends as active_connections,
  xact_commit as transactions_committed,
  xact_rollback as transactions_rolled_back,
  blks_read as disk_blocks_read,
  blks_hit as cache_blocks_hit,
  ROUND((blks_hit::numeric / NULLIF(blks_hit + blks_read, 0)::numeric * 100), 2) as cache_hit_ratio
FROM pg_stat_database
WHERE datname = current_database();
```

**Success Criteria:**
- cache_hit_ratio > 95% (good cache performance)
- active_connections reasonable (< 100)
- transactions_rolled_back / transactions_committed < 0.01 (< 1% rollback rate)

### Step 9: Generate Validation Report

**Agent Action:** Create comprehensive validation summary

```bash
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 05: Staging Final Validation
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## Validation Summary

### Prerequisites Check
- Ticket 00: ✓ COMPLETE / ✗ INCOMPLETE
- Ticket 01: ✓ COMPLETE / ✗ INCOMPLETE
- Ticket 02: ✓ COMPLETE / ✗ INCOMPLETE
- Ticket 03: ✓ COMPLETE / ✗ INCOMPLETE
- Ticket 04: ✓ COMPLETE / ✗ INCOMPLETE

### Database State (Step 2)
- Tables: [count]
- Custom Indexes: [count]/45+
- RLS Enabled Tables: [count]/50
- Policies: [count]/100+
- Combo Items: [count] (was ~63)

### Performance Tests (Step 3)
- Menu Query: [time]ms (target: <100ms) → PASS/FAIL
- Combo Query: [time]ms (target: <100ms) → PASS/FAIL
- Index Usage: VERIFIED / NOT VERIFIED

### Security Tests (Step 4)
- Tenant Isolation: PASS / FAIL
- Public Read: PASS / FAIL
- Admin Access: PASS / FAIL

### Combo Validation (Step 5)
- Orphan Rate: [X]% (target: <5%) → PASS / FAIL
- Item Distribution: REASONABLE / CONCERNING

### Data Integrity (Step 6)
- NULL Check: PASS / FAIL
- FK Integrity: PASS / FAIL
- Duplicates: PASS / FAIL

### Database Health (Step 8)
- Cache Hit Ratio: [X]% (target: >95%)
- Active Connections: [count]
- Health Status: GOOD / CONCERNING / BAD

## 4-Hour Monitoring (Step 10)
[To be filled during monitoring period]

EOF
```

### Step 10: 4-Hour Stability Monitoring

**⏰ IMPORTANT:** After passing all above tests, monitor for 4+ hours before proceeding to production.

**Monitoring Tasks:**

**Hour 1 (Active Monitoring - Every 15 Minutes):**

```sql
-- Run this query every 15 minutes
SELECT 
  NOW() as check_time,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as combo_items_count,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') as active_queries,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') as idle_in_transaction,
  (SELECT pg_size_pretty(pg_database_size(current_database()))) as db_size;

-- Watch for:
-- - Combo_items_count stays stable (no unexpected changes)
-- - Active_queries reasonable (< 20)
-- - Idle_in_transaction low (< 5)
-- - DB size not growing unexpectedly
```

**Record in EXECUTION_LOG.md:**
```
Hour 1 Monitoring:
- 0:15 - [counts] - Status: OK/Issue
- 0:30 - [counts] - Status: OK/Issue
- 0:45 - [counts] - Status: OK/Issue
- 1:00 - [counts] - Status: OK/Issue
```

**Hours 2-4 (Passive Monitoring - Hourly):**

```sql
-- Run this query each hour
SELECT 
  NOW() as check_time,
  -- Error check
  (SELECT COUNT(*) FROM pg_stat_database WHERE datname = current_database() AND deadlocks > 0) as has_deadlocks,
  -- Performance check
  (SELECT ROUND(AVG(mean_exec_time), 2) FROM pg_stat_statements WHERE query LIKE '%menuca_v3%') as avg_query_time_ms,
  -- Resource check
  (SELECT numbackends FROM pg_stat_database WHERE datname = current_database()) as connections;

-- Watch for:
-- - No deadlocks
-- - Avg query time stable (< 100ms)
-- - Connections stable
```

**Record Results:**
```
Extended Monitoring:
- Hour 2: [metrics] - Status: STABLE/ISSUE
- Hour 3: [metrics] - Status: STABLE/ISSUE
- Hour 4: [metrics] - Status: STABLE/ISSUE
```

**Alert Conditions (Require Investigation):**
- ⚠️ Combo_items count changes unexpectedly
- ⚠️ Active queries spike > 50
- ⚠️ Average query time > 200ms
- ⚠️ Deadlocks detected
- ⚠️ Database size growing rapidly

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **All previous tickets complete**
  - Check: Step 1 shows 5 COMPLETE statuses
  
- [ ] **Database state correct**
  - 45+ indexes, 50 RLS tables, 100+ policies, 50K+ combo_items
  
- [ ] **Performance tests pass**
  - Menu query < 100ms ✓
  - Combo query < 100ms ✓
  - Using indexes ✓
  
- [ ] **Security tests pass**
  - Tenant isolation ✓
  - Public read ✓
  - Admin access ✓
  
- [ ] **Combo system validated**
  - Orphan rate < 5% ✓
  - Reasonable distribution ✓
  
- [ ] **Data integrity clean**
  - No nulls ✓
  - No invalid FKs ✓
  - No duplicates ✓
  
- [ ] **Database health good**
  - Cache hit ratio > 95% ✓
  - No concerning metrics
  
- [ ] **4-hour stability confirmed**
  - No errors during monitoring
  - No performance degradation
  - No unexpected changes

---

## SUCCESS CONDITIONS

**All validation criteria must PASS + 4-hour stability.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Final Staging Validation Result
   
   ✅ ALL VALIDATIONS PASSED
   
   - Performance: EXCELLENT (<100ms queries)
   - Security: ENFORCED (RLS working)
   - Combo Fix: SUCCESS (<5% orphan rate)
   - Data Integrity: CLEAN (no issues)
   - Stability: CONFIRMED (4+ hours stable)
   
   GO/NO-GO DECISION: ✅ GO
   
   APPROVED TO PROCEED TO PRODUCTION
   
   STATUS: COMPLETE
   
   Ready for Ticket 06: PRODUCTION_BACKUP.md
   ```

2. **Santiago Sign-Off Required:**
   - Review EXECUTION_LOG.md
   - Confirm all metrics acceptable
   - Approve production deployment

3. **Proceed to production:**
   - Next: `06_PRODUCTION_BACKUP.md`
   - Schedule production maintenance window
   - Notify team

---

## FAILURE CONDITIONS

**If ANY validation fails OR instability detected:**

### GO/NO-GO: NO-GO

**Do NOT proceed to production if:**
- ❌ Any performance test fails
- ❌ Any security test fails
- ❌ Combo orphan rate > 5%
- ❌ Data integrity issues found
- ❌ Database health concerning
- ❌ Instability during 4-hour monitoring

**Actions:**
1. **STOP** - Do NOT proceed to production
2. **Document** - Log which validation(s) failed
3. **Investigate** - Determine root cause
4. **Fix** - Resolve issues in staging
5. **Re-validate** - Run this ticket again
6. **Alert human** - Get approval before production

### Example Failure Scenarios

**Performance Degradation:**
- Queries still slow (> 200ms)
- Not using indexes
- **Action:** Investigate index creation, run ANALYZE

**RLS Not Working:**
- Can see other restaurants' data
- Policies not enforcing
- **Action:** Review policies, may need to fix and redeploy

**High Orphan Rate:**
- Combo orphan rate > 5%
- Migration didn't work fully
- **Action:** Review migration logs, may need to re-run or investigate mapping

**Instability:**
- Errors during monitoring period
- Performance degrading over time
- **Action:** Investigate root cause, may indicate deeper issue

---

## ROLLBACK

**Not Applicable for this ticket** - This ticket only validates.

**However, if validation reveals problems:**
- Can rollback to Ticket 01 backup if needed
- See ROLLBACK_GUIDE.md for procedures

---

## CONTEXT FOR NEXT STEP

```
STAGING VALIDATION COMPLETE
================================================================================

DEPLOYMENT RESULTS:
✓ Indexes: [count] deployed, queries < 100ms
✓ RLS: [policies] policies, security enforced
✓ Combo Fix: Orphan rate [X]% (target: <5%)

VALIDATION STATUS:
✓ Performance: PASS
✓ Security: PASS
✓ Data Integrity: PASS
✓ Stability: CONFIRMED (4h)

GO/NO-GO DECISION: ✅ GO TO PRODUCTION

NEXT STEPS:
1. Schedule production maintenance window (2-6am EST preferred)
2. Notify team 24 hours in advance
3. Brief customer support team
4. Proceed to Ticket 06: PRODUCTION_BACKUP.md

SANTIAGO SIGN-OFF:
- Reviewed By: ______________
- Approved: YES / NO
- Date: _______
- Notes: _______________
```

**Next Ticket:** `06_PRODUCTION_BACKUP.md` (ONLY if GO decision)

---

## NOTES FOR AGENT

### This is the Gate

**Critical Decision Point:**
- Staging success → Production deployment
- Staging failure → Stop, fix, retry

**Do NOT Rush:**
- 4-hour monitoring is REQUIRED
- Better to wait than deploy broken code
- Production has real users and revenue

### What Good Looks Like

**Excellent Validation:**
- All tests PASS on first try
- Performance < 50ms (2x better than target)
- Orphan rate < 1% (5x better than target)
- Zero issues during 4h monitoring
- Database metrics all green

**Acceptable Validation:**
- All tests PASS (may need 1-2 retries)
- Performance < 100ms (meets target)
- Orphan rate < 5% (meets target)
- Minor issues during monitoring (resolved)
- Database metrics mostly green

**Unacceptable - DO NOT DEPLOY:**
- Any test FAILS repeatedly
- Performance > 200ms
- Orphan rate > 5%
- Persistent issues during monitoring
- Degrading metrics

### Timing Note

**Minimum Time for This Ticket:** 4 hours 30 minutes
- Active validation: 30 minutes
- Monitoring: 4 hours minimum

**This is intentional** - We need confidence before production.

---

**Ticket Status:** READY  
**Dependencies:** Tickets 01-04 ALL COMPLETE  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

