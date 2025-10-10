# TICKET 07: Production Indexes

**Phase:** Production Deployment - Step 2 of 5  
**Environment:** Production Database ⚠️  
**Estimated Duration:** 25-35 minutes  
**Prerequisites:** Ticket 06 (Production Backup) must be COMPLETE

---

## CONTEXT

- **Current Step:** 7 of 11 (Production Index Deployment)
- **Purpose:** Deploy 45+ performance indexes to production
- **Risk Level:** LOW-MEDIUM (CONCURRENTLY avoids locks)
- **⚠️ PRODUCTION:** Live system, be cautious

**Before You Begin:**
- Verify Ticket 06 backup ID is recorded
- Confirm this matches staging deployment (Ticket 02)
- Have rollback plan ready

**What This Does:**
- Same as Ticket 02, but on production
- Adds 45+ performance indexes
- Should complete without disrupting users (CONCURRENTLY)
- **Expected Result:** Queries 10x faster, zero downtime

---

## TASK

Deploy the index creation script to production database. This is identical to staging (Ticket 02) but requires extra monitoring for production impact.

**Execution Strategy:**
- Same SQL script as staging
- Same validation process
- Extra monitoring for user impact
- Ready to abort if issues detected

---

## COMMANDS TO RUN

### Step 1: Verify Production Baseline

**Agent Action:** Capture pre-index state

```sql
-- Production pre-index state
SELECT 
  'PRODUCTION PRE-INDEX' as label,
  (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'menuca_v3' AND indexname LIKE 'idx_%') as custom_indexes,
  (SELECT pg_size_pretty(pg_database_size(current_database()))) as db_size,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') as active_connections,
  NOW() as timestamp;
```

**Expected Output:**
- custom_indexes: Low (pre-optimization count)
- active_connections: < 20 (maintenance window)

### Step 2: Test Baseline Query Performance

```sql
-- Measure query speed before indexes (production data)
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.dishes 
WHERE restaurant_id = (SELECT id FROM menuca_v3.restaurants WHERE is_active = true LIMIT 1)
  AND is_active = true
LIMIT 100;
```

**Record baseline execution time for comparison.**

### Step 3: Deploy Index Script (Same as Ticket 02)

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql`

**Execute all 10 sections as in Ticket 02.**

**⚠️ Production Monitoring:**

After each section, check impact:

```sql
-- Quick health check between sections
SELECT 
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND query NOT LIKE '%pg_stat%') as active_queries,
  (SELECT COUNT(*) FROM pg_stat_activity WHERE wait_event_type = 'Lock') as waiting_on_locks;

-- Should show:
-- - active_queries: Normal levels (< 30)
-- - waiting_on_locks: 0 or very low (CONCURRENTLY shouldn't lock)
```

**If waiting_on_locks > 10:**
- Pause deployment
- Investigate which queries are blocked
- May need to wait or abort

### Step 4-9: Same as Ticket 02

Follow Steps 4-9 from Ticket 02:
- Verify index creation
- List new indexes
- Test query performance  
- Verify index usage
- Check index sizes
- Run validation queries
- Update EXECUTION_LOG

**Reference Ticket 02 for detailed commands.**

**Key Difference:** Monitor production impact continuously.

### Step 10: Production Impact Check

**Agent Action:** Verify no negative impact on users

```sql
-- Check for issues during deployment
SELECT 
  'PRODUCTION IMPACT CHECK' as label,
  -- Error rate
  (SELECT SUM(xact_rollback) FROM pg_stat_database WHERE datname = current_database()) as total_rollbacks,
  -- Lock contention
  (SELECT COUNT(*) FROM pg_locks WHERE NOT granted) as blocked_queries,
  -- Connection health
  (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') as active_connections,
  NOW() as check_time;
```

**Expected Output:**
- blocked_queries: 0 (no locks from index creation)
- active_connections: Normal range
- No spike in rollbacks

**If Issues Detected:**
- Document in log
- May indicate problem
- Consider slowing down deployment

---

## VALIDATION CRITERIA

Same as Ticket 02, plus production-specific checks:

- [ ] **All staging validations (from Ticket 02)**
  - 45+ indexes created
  - Critical indexes present
  - Query performance improved
  - Using indexes in query plans
  
- [ ] **Production-specific validations**
  - No user-facing errors during deployment
  - No lock contention
  - Active connections stable
  - No spike in transaction rollbacks

---

## SUCCESS CONDITIONS

If all checks pass:
1. **Log results (same format as Ticket 02)**
2. **Production impact assessment:**
   ```
   ## Production Impact
   - User Errors: NONE DETECTED
   - Lock Contention: NONE
   - Connection Stability: STABLE
   - Performance Impact: POSITIVE (queries faster)
   
   STATUS: COMPLETE
   ```
3. **Communicate:** Post in war room: "Production indexes deployed successfully. Query performance improved. Proceeding to RLS."
4. **Proceed:** Next ticket 08_PRODUCTION_RLS.md

---

## FAILURE CONDITIONS

Same as Ticket 02, plus:

### Production-Specific Failures

**Scenario: User Impact Detected**

**Symptoms:**
- Spike in errors
- Users reporting issues
- Queries timing out

**Actions:**
1. **PAUSE** deployment
2. Check which section caused issue
3. Roll back if necessary (Option A from Ticket 02)
4. Alert human operator
5. May need to abort and investigate

---

## ROLLBACK

Same options as Ticket 02:
- **Option A:** Drop new indexes (10 min)
- **Option B:** Full restore from Ticket 06 backup (15 min)

Use Option B if serious production issues occur.

---

## CONTEXT FOR NEXT STEP

```
PRODUCTION INDEXES DEPLOYED
================================================================================

DEPLOYMENT RESULTS:
- Indexes Added: _____ (target: 45+)
- Query Performance: [before]ms → [after]ms
- Index Usage: ✓ VERIFIED
- Deployment Status: ✓ SUCCESS

PRODUCTION IMPACT:
- User Errors: NONE
- Lock Contention: NONE  
- Connection Stability: STABLE
- Customer Reports: NONE

NEXT STEP:
→ Proceed to 08_PRODUCTION_RLS.md

ROLLBACK INFO:
- Backup ID: [from Ticket 06]
- Can rollback in 15 minutes if needed
```

**Next Ticket:** `08_PRODUCTION_RLS.md`

---

## NOTES FOR AGENT

### Production vs Staging

**Key Differences:**
- **Real users** - Monitor for impact
- **Real data** - Larger scale may take longer
- **Real revenue** - Errors cost money
- **Extra caution** - Better slow than broken

### CONCURRENTLY is Safe, But...

- Usually safe for production
- Can cause issues if:
  - Database under heavy load
  - Long-running transactions present
  - Resource constraints

**Monitor continuously during deployment.**

---

**Ticket Status:** READY  
**Dependencies:** Ticket 06 COMPLETE  
**Last Updated:** October 10, 2025  

**⚠️ PRODUCTION DEPLOYMENT - MONITOR CLOSELY ⚠️**

