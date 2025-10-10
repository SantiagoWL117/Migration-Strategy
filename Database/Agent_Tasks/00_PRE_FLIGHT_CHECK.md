# TICKET 00: Pre-Flight Check

**Phase:** Preparation  
**Environment:** Local + Staging + Production  
**Estimated Duration:** 15-20 minutes  
**Prerequisites:** None (first ticket)

---

## CONTEXT

- **Current Step:** 0 of 11 (Pre-Flight)
- **Purpose:** Verify all prerequisites before starting deployment
- **Risk Level:** LOW (read-only validation)
- **Can Proceed:** Always safe to run

---

## TASK

Validate that all required tools, files, credentials, and configurations are in place before starting the database migration. This prevents mid-migration failures due to missing prerequisites.

---

## COMMANDS TO RUN

### Step 1: Verify Directory Structure

```bash
# Check that all source files exist
ls -la /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql
ls -la /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql
ls -la /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/test_rls_policies.sql
ls -la "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql"
ls -la "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/validate_combo_fix.sql"

# Expected: All files should exist and be readable
```

### Step 2: Check File Sizes

```bash
# Verify SQL scripts are not empty
wc -l /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql
wc -l /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql
wc -l /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/test_rls_policies.sql
wc -l "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql"
wc -l "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/validate_combo_fix.sql"

# Expected:
# - add_critical_indexes.sql: ~417 lines
# - create_rls_policies.sql: ~769 lines
# - test_rls_policies.sql: ~407 lines
# - fix_combo_items_migration.sql: ~328 lines
# - validate_combo_fix.sql: ~378 lines
```

### Step 3: Verify Supabase MCP Tools

```bash
# Check if Supabase MCP tools are available
# (Agent: Use your available MCP tools to verify)

# Expected: You should have access to:
# - mcp_supabase_execute_sql
# - mcp_supabase_list_tables
# - mcp_supabase_apply_migration
```

**Agent Note:** Verify you can call Supabase MCP tools. If not available, STOP and alert human operator.

### Step 4: Test Database Connectivity (Staging)

**Agent Action:** Use MCP tool to test staging database connection

```sql
-- Test query (read-only)
SELECT 
  'Staging Connection' as test,
  version() as postgres_version,
  current_database() as database_name,
  NOW() as current_time;
```

**Expected Output:**
- PostgreSQL version displayed
- Database name shown
- Current timestamp returned
- No connection errors

### Step 5: Test Database Connectivity (Production)

**⚠️ CAUTION:** Production database - read-only test only!

**Agent Action:** Use MCP tool to test production database connection

```sql
-- Test query (read-only)
SELECT 
  'Production Connection' as test,
  version() as postgres_version,
  current_database() as database_name,
  NOW() as current_time;
```

**Expected Output:**
- PostgreSQL version displayed
- Database name shown
- Current timestamp returned
- No connection errors

### Step 6: Verify Current Schema State

**Agent Action:** Check current state of menuca_v3 schema

```sql
-- Check key table counts
SELECT 
  'restaurants' as table_name, COUNT(*) as row_count FROM menuca_v3.restaurants
UNION ALL
SELECT 'dishes', COUNT(*) FROM menuca_v3.dishes
UNION ALL
SELECT 'combo_groups', COUNT(*) FROM menuca_v3.combo_groups
UNION ALL
SELECT 'combo_items', COUNT(*) FROM menuca_v3.combo_items;
```

**Expected Output:**
- restaurants: ~944
- dishes: ~10,585
- combo_groups: ~8,234
- combo_items: ~63 (this is the problem we're fixing!)

### Step 7: Check Existing Indexes

```sql
-- Count current indexes
SELECT 
  COUNT(*) as total_indexes,
  COUNT(CASE WHEN indexname LIKE 'idx_%' THEN 1 END) as custom_indexes
FROM pg_indexes
WHERE schemaname = 'menuca_v3';
```

**Expected Output:**
- Should have some indexes but not the 45+ we're about to add
- Note the current count for comparison

### Step 8: Check RLS Status

```sql
-- Check if RLS is already enabled
SELECT 
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'menuca_v3'
  AND rowsecurity = true;
```

**Expected Output:**
- Should return 0 rows (no RLS currently enabled)
- If rows returned, note which tables already have RLS

### Step 9: Check Combo Orphan Rate

```sql
-- Verify the combo system is broken
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned_groups,
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;
```

**Expected Output:**
- orphan_pct: ~99.8% (confirming the problem exists)
- If orphan_pct < 50%, something is different from analysis

### Step 10: Verify Disk Space

```sql
-- Check database size
SELECT 
  pg_size_pretty(pg_database_size(current_database())) as database_size,
  pg_size_pretty(pg_total_relation_size('menuca_v3.dishes')) as dishes_table_size,
  pg_size_pretty(pg_total_relation_size('menuca_v3.combo_items')) as combo_items_size;
```

**Expected Output:**
- Database size: Several hundred MB to a few GB
- Enough space for indexes and new combo_items

### Step 11: Create EXECUTION_LOG Entry

**Agent Action:** Initialize the EXECUTION_LOG.md file

```bash
# Append to EXECUTION_LOG.md
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<'EOF'

================================================================================
TICKET 00: Pre-Flight Check
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Agent: [Your identifier]
Status: IN_PROGRESS

## Actions Taken
1. Verified all SQL source files exist
2. Checked file sizes and line counts
3. Confirmed Supabase MCP tools available
4. Tested staging database connectivity
5. Tested production database connectivity
6. Verified schema state (944 restaurants, 10,585 dishes, 8,234 combo_groups)
7. Checked existing indexes: [current count]
8. Verified RLS status: [enabled/disabled]
9. Confirmed combo orphan rate: [actual %]
10. Checked disk space: [size]

## Validation Results (see below)

EOF
```

---

## VALIDATION CRITERIA

Run through this checklist and mark each item:

- [ ] **All SQL files exist and are readable**
  - Check: `ls` commands returned files successfully
  
- [ ] **SQL files have expected line counts** (±10% tolerance)
  - Check: `wc -l` output matches expected ranges
  
- [ ] **Supabase MCP tools are available**
  - Check: Can call mcp_supabase_execute_sql
  
- [ ] **Staging database connection works**
  - Check: Test query returned results
  
- [ ] **Production database connection works**
  - Check: Test query returned results
  
- [ ] **Schema exists with expected tables**
  - Check: menuca_v3 schema has restaurants, dishes, combo_groups, combo_items
  
- [ ] **Table counts are in expected ranges**
  - restaurants: 900-1000
  - dishes: 10,000-11,000
  - combo_groups: 8,000-8,500
  - combo_items: 50-100 (low because broken)
  
- [ ] **Combo orphan rate confirms the problem**
  - Check: Orphan rate > 95% (ideally ~99.8%)
  
- [ ] **No RLS currently enabled** (or note which tables have it)
  - Check: Zero or few tables have rowsecurity = true
  
- [ ] **Sufficient disk space available**
  - Check: Database size reasonable, space for growth
  
- [ ] **EXECUTION_LOG.md initialized**
  - Check: File updated with ticket 00 entry

---

## SUCCESS CONDITIONS

**All validation criteria must be checked and PASS.**

If all checks pass:
1. Log "PRE-FLIGHT CHECK: PASS" to EXECUTION_LOG.md
2. Note any warnings or observations
3. Record baseline metrics (row counts, index counts, orphan rate)
4. Mark this ticket as COMPLETE in EXECUTION_LOG.md
5. **Proceed to Ticket 01: STAGING_BACKUP.md**

---

## FAILURE CONDITIONS

**If ANY validation criterion fails:**

1. **STOP** - Do not proceed to next ticket
2. **Log the failure** in EXECUTION_LOG.md with details:
   - Which check failed
   - Actual vs expected values
   - Error messages if any
3. **Alert human operator:**
   - Post in #database-migrations
   - Include specific failure details
   - Wait for human to resolve issue
4. **Do NOT attempt to fix** - Let human operator diagnose

### Common Failure Scenarios

**Missing SQL Files:**
- Cause: Files not in expected location or deleted
- Action: Human needs to verify file paths and restore files

**Database Connection Failed:**
- Cause: Credentials incorrect, network issue, database down
- Action: Human needs to verify credentials and database status

**Orphan Rate is Low (<50%):**
- Cause: Combo system may have been partially fixed already
- Action: Human needs to review actual state vs documented state
- Decision: May need to adjust migration approach

**RLS Already Enabled:**
- Cause: Previous partial deployment
- Action: Human needs to determine if safe to proceed or rollback first

**Wrong Table Counts:**
- Cause: Database state different from analysis
- Action: Human needs to verify we're connecting to correct database

---

## ROLLBACK

**Not Applicable** - This ticket only performs read-only checks. No rollback needed.

---

## CONTEXT FOR NEXT STEP

Document these baseline metrics for Ticket 01:

```
BASELINE METRICS (to be filled by agent):
- Staging Database Size: _____ GB
- Current Index Count: _____
- Current Combo Items: _____ (should be ~63)
- Combo Orphan Rate: _____% (should be ~99.8%)
- RLS Enabled Tables: _____ (should be 0)

ENVIRONMENT VERIFICATION:
- Staging Connection: ✓ PASS / ✗ FAIL
- Production Connection: ✓ PASS / ✗ FAIL
- All SQL Files Present: ✓ PASS / ✗ FAIL
- Supabase MCP Tools: ✓ AVAILABLE / ✗ NOT AVAILABLE

DECISION:
✓ PROCEED to Ticket 01 (All checks passed)
✗ STOP (Failures detected - human intervention required)
```

**Next Ticket:** `01_STAGING_BACKUP.md`

---

## NOTES FOR AGENT

- **Be thorough** - This ticket prevents mid-deployment failures
- **Log everything** - Record all actual values, not just pass/fail
- **Don't guess** - If something is unclear, STOP and ask
- **Read-only** - All commands in this ticket are safe (no writes)
- **Take your time** - Better to be slow and accurate than fast and wrong

---

**Ticket Status:** READY  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

