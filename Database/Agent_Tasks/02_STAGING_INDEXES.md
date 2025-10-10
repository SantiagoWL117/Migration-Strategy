# TICKET 02: Staging Indexes

**Phase:** Staging Deployment - Step 2 of 5  
**Environment:** Staging Database  
**Estimated Duration:** 20-30 minutes  
**Prerequisites:** Ticket 01 (Staging Backup) must be COMPLETE

---

## CONTEXT

- **Current Step:** 2 of 11 (Staging Index Deployment)
- **Purpose:** Add 45+ critical performance indexes to staging database
- **Risk Level:** LOW (CREATE INDEX CONCURRENTLY doesn't lock tables)
- **Dependency:** Ticket 01 backup must exist for rollback safety

**Before You Begin:**
- Verify Ticket 01 backup ID is recorded in EXECUTION_LOG.md
- Confirm staging database connection active
- Note current index count from Ticket 00 baseline

**What This Does:**
- Adds foreign key indexes for menu queries
- Adds modifier system indexes
- Adds combo system indexes
- Adds JSONB GIN indexes for pricing
- **Expected Result:** Menu queries 10x faster (500ms → 50ms)

---

## TASK

Deploy the comprehensive index creation script to staging database. This script adds 45+ indexes across all critical tables using `CREATE INDEX CONCURRENTLY` to avoid locking tables.

**Performance Impact:**
- **During:** Minimal (CONCURRENTLY avoids locks)
- **After:** Dramatic improvement (10x faster queries)

---

## COMMANDS TO RUN

### Step 1: Verify Pre-Index State

**Agent Action:** Capture baseline before adding indexes

```sql
-- Count current indexes
SELECT 
  'PRE-INDEX STATE' as label,
  COUNT(*) as total_indexes,
  COUNT(CASE WHEN indexname LIKE 'idx_%' THEN 1 END) as custom_indexes
FROM pg_indexes
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- total_indexes: [Current count - likely 50-100]
- custom_indexes: [Current custom indexes - likely 0-10]

**Agent Note:** Record these counts. We'll verify 45+ new indexes appear.

### Step 2: Test Baseline Query Performance

**Agent Action:** Measure query speed before indexes

```sql
-- Time a typical menu query (no indexes yet)
EXPLAIN ANALYZE
SELECT 
  d.id, d.name, d.base_price, d.prices,
  c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.restaurant_id = 123 
  AND d.is_active = true
ORDER BY c.display_order, d.display_order
LIMIT 100;
```

**Expected Output:**
- Execution Time: Likely 100-500ms (slow without indexes)
- Query Plan: Look for "Seq Scan" (bad - we're fixing this)

**Agent Note:** Record the execution time. We'll compare after indexes added.

### Step 3: Deploy Index Script

**Agent Action:** Run the full index creation script

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes_FIXED.sql`

**⚠️ CRITICAL:** Use the FIXED version - the original has `BEGIN/COMMIT` conflicts with `CONCURRENTLY`

**Execution Method:**

```bash
# Option A: Using MCP tool to apply migration
# Use mcp_supabase_apply_migration with the SQL file content

# Option B: Using MCP tool to execute SQL directly
# Read the file and execute via mcp_supabase_execute_sql
```

**Agent Decision:** 
- If MCP tools support file upload, use apply_migration
- Otherwise, read file content and execute as a single script

**Script Structure:**
The FIXED script runs linearly without transaction blocks:
1. **Section 1: Critical Menu Indexes** (~6 indexes)
2. **Section 2: Modifier System Indexes** (~6 indexes)
3. **Section 3: Ingredient Group Indexes** (~6 indexes)
4. **Section 4: Combo System Indexes** (~7 indexes)
5. **Section 5: Restaurant Management Indexes** (~8 indexes)
6. **Section 6: Delivery & Service Indexes** (~6 indexes)
7. **Section 7: Marketing & Promotions Indexes** (~6 indexes)
8. **Section 8: User Indexes** (~7 indexes)
9. **Section 9: JSONB GIN Indexes** (~4 indexes)
10. **Section 10: Devices & Infrastructure** (~2 indexes)

**Expected Output:**
```
CREATE INDEX
CREATE INDEX
CREATE INDEX
...
(45+ CREATE INDEX statements, some may show NOTICE if already exists)
```

**If Error Occurs:**
- Note which section failed
- Note the exact error message
- Check if index already exists (may need IF NOT EXISTS)
- If "already exists" error, that's OK - continue
- If other error, STOP and log it

### Step 4: Verify Index Creation

**Agent Action:** Count indexes after deployment

```sql
-- Count indexes after creation
SELECT 
  'POST-INDEX STATE' as label,
  COUNT(*) as total_indexes,
  COUNT(CASE WHEN indexname LIKE 'idx_%' THEN 1 END) as custom_indexes,
  COUNT(CASE WHEN indexname LIKE 'idx_%' AND indexdef LIKE '%CONCURRENTLY%' THEN 1 END) as concurrent_indexes
FROM pg_indexes
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- total_indexes: [Pre-count] + 45+ new indexes
- custom_indexes: Should increase by ~45-50
- Change: ~45+ indexes added

**Agent Note:** If change is < 40, something may have failed. Review logs.

### Step 5: List New Indexes

**Agent Action:** Confirm all critical indexes exist

```sql
-- Check for critical indexes
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND indexname IN (
    'idx_dishes_restaurant',
    'idx_dishes_course',
    'idx_dish_modifiers_dish',
    'idx_ingredients_restaurant',
    'idx_combo_groups_restaurant',
    'idx_combo_items_group',
    'idx_courses_restaurant'
  )
ORDER BY tablename, indexname;
```

**Expected Output:**
- All 7 critical indexes should appear
- Each should have proper index definition
- No nulls or errors

**Agent Note:** If any critical index is missing, that's a FAIL condition.

### Step 6: Test Query Performance (After Indexes)

**Agent Action:** Measure query speed after indexes

```sql
-- Same query as Step 2, should be much faster now
EXPLAIN ANALYZE
SELECT 
  d.id, d.name, d.base_price, d.prices,
  c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.restaurant_id = 123 
  AND d.is_active = true
ORDER BY c.display_order, d.display_order
LIMIT 100;
```

**Expected Output:**
- Execution Time: Should be < 100ms (10x faster!)
- Query Plan: Look for "Index Scan" (good!)
- No more "Seq Scan" on indexed columns

**Agent Note:** Compare to Step 2 baseline. Should see dramatic improvement.

### Step 7: Verify Index Usage

**Agent Action:** Check indexes are being used

```sql
-- Check query plan uses indexes
EXPLAIN 
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 123;
```

**Expected Output:**
```
Index Scan using idx_dishes_restaurant on dishes
  Index Cond: (restaurant_id = 123)
```

**NOT Expected:**
```
Seq Scan on dishes
  Filter: (restaurant_id = 123)
```

**Agent Note:** "Index Scan" = SUCCESS, "Seq Scan" = FAIL

### Step 8: Check Index Sizes

**Agent Action:** Verify indexes created successfully

```sql
-- Get index sizes
SELECT
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as index_size
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND indexname LIKE 'idx_%'
ORDER BY pg_relation_size(schemaname||'.'||indexname) DESC
LIMIT 20;
```

**Expected Output:**
- Largest indexes on dishes, ingredients, combo_items tables
- Sizes range from few KB to several MB
- No zero-size indexes (would indicate failed creation)

### Step 9: Run Validation Queries from Script

**Agent Action:** Execute validation queries from lines 280-335 of add_critical_indexes_FIXED.sql

```sql
-- 1. Test critical menu query (from line 333)
EXPLAIN ANALYZE
SELECT 
  d.id, d.name, d.base_price, d.prices,
  c.name as course_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
WHERE d.restaurant_id = 123 
  AND d.is_active = true
ORDER BY c.display_order, d.display_order;

-- 2. Test modifier lookup (from line 345)
EXPLAIN ANALYZE
SELECT dm.*, i.name as ingredient_name
FROM menuca_v3.dish_modifiers dm
JOIN menuca_v3.ingredients i ON dm.ingredient_id = i.id
WHERE dm.dish_id = 1000;

-- Both should show Index Scan, not Seq Scan
```

### Step 10: Update EXECUTION_LOG

**Agent Action:** Document results

```bash
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 02: Staging Indexes
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## Pre-Index State
- Total Indexes: [count from step 1]
- Custom Indexes: [count from step 1]
- Baseline Query Time: [time from step 2] ms

## Index Deployment
- Sections Executed: 10/10
- Indexes Created: [actual count added]
- Errors Encountered: [none or list errors]

## Post-Index State
- Total Indexes: [count from step 4]
- New Indexes Added: [difference]
- Critical Indexes Verified: ✓ All present

## Performance Improvement
- Query Time Before: [step 2] ms
- Query Time After: [step 6] ms
- Improvement: [calculate %] faster
- Query Plan: Index Scan ✓ (no Seq Scan)

## Validation Results (see below)

EOF
```

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **Baseline metrics captured**
  - Check: Pre-index count and query time recorded
  
- [ ] **All 10 sections executed successfully**
  - Check: Each section completed without fatal errors
  - Note: "Index already exists" is OK
  
- [ ] **45+ new indexes created**
  - Check: Index count increased by 45-50
  - Formula: post_count - pre_count >= 45
  
- [ ] **All critical indexes present**
  - Check: Step 5 query found all 7 critical indexes
  
- [ ] **Query performance improved**
  - Check: Test query execution time reduced
  - Target: At least 50% faster (ideally 80-90% faster)
  
- [ ] **Indexes being used in queries**
  - Check: EXPLAIN shows "Index Scan" not "Seq Scan"
  
- [ ] **No zero-size indexes**
  - Check: All new indexes have size > 0
  
- [ ] **Validation queries pass**
  - Check: Both validation queries use indexes
  
- [ ] **No database errors**
  - Check: No connection issues, no fatal errors

---

## SUCCESS CONDITIONS

**All validation criteria must PASS.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Validation Results
   - ✓ Indexes created: [actual count]
   - ✓ Critical indexes: ALL PRESENT
   - ✓ Performance improvement: [X%] faster
   - ✓ Query plans: Using indexes ✓
   - ✓ No errors
   
   STATUS: COMPLETE
   ```

2. **Performance Metrics to Record:**
   - Indexes added: [actual count]
   - Query speedup: [X times faster]
   - Query plan: Index Scan ✓

3. **Proceed to next ticket:**
   - Next: `03_STAGING_RLS.md`
   - Indexes ready for RLS policy testing

---

## FAILURE CONDITIONS

**If ANY validation fails:**

### Scenario 1: Less Than 45 Indexes Created

**Symptoms:**
- Index count only increased by 20-30
- Some sections may have failed silently

**Actions:**
1. Review EXECUTION_LOG.md for section errors
2. Check for "already exists" errors (OK to ignore)
3. If real failures, identify which indexes failed
4. Attempt to create missing indexes manually
5. If < 35 indexes created, consider ROLLBACK

**Decision:** 
- 45+ indexes: PASS (proceed)
- 35-44 indexes: REVIEW (may proceed with caution)
- < 35 indexes: FAIL (rollback recommended)

### Scenario 2: Critical Indexes Missing

**Symptoms:**
- Step 5 query doesn't find all 7 critical indexes
- Specifically: dishes_restaurant, dishes_course, etc.

**Actions:**
1. STOP - Critical indexes are non-negotiable
2. Check error logs for why they failed
3. Attempt to create missing critical indexes manually
4. If manual creation fails, ROLLBACK
5. Alert human operator

### Scenario 3: Queries Still Using Seq Scan

**Symptoms:**
- EXPLAIN shows "Seq Scan" instead of "Index Scan"
- Suggests indexes not being used

**Actions:**
1. Run ANALYZE on tables:
   ```sql
   ANALYZE menuca_v3.dishes;
   ANALYZE menuca_v3.courses;
   ANALYZE menuca_v3.dish_modifiers;
   ```
2. Retry EXPLAIN query
3. If still Seq Scan, check index exists:
   ```sql
   SELECT * FROM pg_indexes 
   WHERE indexname = 'idx_dishes_restaurant';
   ```
4. If index exists but not used, may be PostgreSQL planner issue
5. Alert human operator for investigation

### Scenario 4: Index Creation Timed Out

**Symptoms:**
- Command appears to hang
- No response for > 5 minutes per section

**Actions:**
1. Wait up to 10 minutes per section (large tables take time)
2. Check database connection still active
3. If connection lost, reconnect and verify state
4. Check which indexes were created before timeout
5. May need to create remaining indexes manually

---

## ROLLBACK

**If deployment fails and rollback is needed:**

### Option A: Drop New Indexes

```sql
-- Generate drop statements for new indexes
SELECT 'DROP INDEX CONCURRENTLY IF EXISTS menuca_v3.' || indexname || ';'
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND indexname LIKE 'idx_%'
  AND indexname NOT IN (
    -- List any pre-existing indexes from Ticket 00
    [list from baseline]
  );

-- Execute generated DROP statements
```

**Time:** ~10 minutes  
**Impact:** Returns to pre-index state

### Option B: Full Database Restore

```bash
# Use backup from Ticket 01
# Backup ID: [from EXECUTION_LOG.md]

# Via Supabase:
supabase db restore --backup-id [backup-id-from-ticket-01]
```

**Time:** ~15 minutes  
**Impact:** Reverts all changes since Ticket 01

**When to Use:**
- Option A: Minor issues, only indexes affected
- Option B: Major corruption, or Option A fails

---

## CONTEXT FOR NEXT STEP

**Record these details for Ticket 03:**

```
INDEX DEPLOYMENT RESULTS:
- Indexes Added: _____ (target: 45+)
- Deployment Status: ✓ SUCCESS / ⚠ PARTIAL / ✗ FAILED
- Critical Indexes: ✓ ALL PRESENT / ⚠ SOME MISSING / ✗ MANY MISSING

PERFORMANCE IMPROVEMENTS:
- Menu Query: [before]ms → [after]ms ([X%] faster)
- Modifier Query: [before]ms → [after]ms ([X%] faster)
- Query Plans: ✓ Using Index Scan / ✗ Still Seq Scan

READY FOR RLS:
✓ Indexes deployed (RLS policies will use these indexes)
✓ Performance validated
✓ Proceed to 03_STAGING_RLS.md
```

**Next Ticket:** `03_STAGING_RLS.md`

---

## NOTES FOR AGENT

### Why So Many Indexes?

**Current Problem:**
- Menu queries scan entire tables (slow)
- RLS policies will scan even more (very slow)
- Modifiers load one-by-one (terrible UX)

**With Indexes:**
- Menu queries use indexes (10x faster)
- RLS policies use indexes (minimal overhead)
- Modifiers load in bulk (great UX)

### CONCURRENTLY is Safe

- `CREATE INDEX CONCURRENTLY` doesn't lock tables
- Users can still query during creation
- Takes longer but safe for production
- Staging is low traffic anyway

### Expected Timings

**Per Section:**
- Small tables (< 1000 rows): 5-10 seconds
- Medium tables (1000-10000 rows): 30-60 seconds
- Large tables (> 10000 rows): 1-3 minutes

**Total:** 10-15 minutes for all 45+ indexes

### Index Size Impact

**Rough Guidelines:**
- 45 indexes on this schema: +50-200 MB
- Acceptable overhead for 10x query speedup
- Monitor disk space if database > 5 GB

---

**Ticket Status:** READY  
**Dependencies:** Ticket 01 COMPLETE  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

