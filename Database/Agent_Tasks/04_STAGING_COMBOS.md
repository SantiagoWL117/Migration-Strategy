# TICKET 04: Staging Combo Fix

**Phase:** Staging Deployment - Step 4 of 5  
**Environment:** Staging Database  
**Estimated Duration:** 15-25 minutes  
**Prerequisites:** Tickets 01-03 (Backup, Indexes, RLS) must be COMPLETE

---

## CONTEXT

- **Current Step:** 4 of 11 (Staging Combo Fix)
- **Purpose:** Fix 99.8% orphaned combo groups by migrating V1 combos data
- **Risk Level:** MEDIUM-HIGH (modifies data, inserts ~110K rows)
- **Dependency:** Indexes (02) and RLS (03) must be working

**Before You Begin:**
- Verify combo orphan rate from Ticket 00 baseline (~99.8%)
- Have Ticket 01 backup ID ready for emergency rollback
- Understand this inserts substantial data (~110,000 combo_items)

**What This Does:**
- Loads V1 combos junction table data
- Maps V1 IDs → V3 IDs (combo_groups + dishes)
- Inserts missing combo_items records
- **Expected Result:** Combo orphan rate drops from 99.8% → < 5%

---

## TASK

Execute the combo fix migration to repair the broken combo system. This migration reads V1 legacy data, maps it to V3 IDs, and populates the combo_items table that should have been migrated initially but wasn't.

**Impact:**
- **Before:** 8,218 combo groups with no items (99.8% broken)
- **After:** < 400 combo groups with no items (< 5% acceptable)
- **Revenue Impact:** 8,000+ restaurants can now sell combos

---

## COMMANDS TO RUN

### Step 1: Verify V1 Combos Source File Exists

**Agent Action:** Confirm the source data file is present

```bash
# Check for V1 combos converted file
ls -lh "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/converted/menuca_v1_combos_postgres.sql"

# Should show file exists (may be several MB)
# If file missing, STOP - cannot proceed without source data
```

**Expected Output:**
- File exists
- Size: Several MB (contains ~110K combos)

**If File Missing:**
- STOP immediately
- Alert human operator
- Cannot proceed without V1 source data

### Step 2: Document Pre-Migration State

**Agent Action:** Capture baseline before fix

```sql
-- Check current combo state
SELECT 
  'PRE-FIX STATE' as label,
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as total_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as total_items,
  (SELECT COUNT(DISTINCT combo_group_id) FROM menuca_v3.combo_items) as groups_with_items,
  NOW() as timestamp;
```

**Expected Output:**
- total_groups: ~8,234
- total_items: ~63 (very few!)
- groups_with_items: ~16 (only 0.2%!)

### Step 3: Calculate Expected Orphan Rate

```sql
-- Calculate current orphan rate
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned,
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;
```

**Expected Output:**
- orphan_pct: ~99.8%

**Agent Note:** Record exact orphan_pct. We need it < 5% after fix.

### Step 4: Verify Legacy ID Columns Exist

**Agent Action:** Confirm mapping columns are present

```sql
-- Check for legacy_v1_id columns
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name IN ('combo_groups', 'dishes')
  AND column_name = 'legacy_v1_id';
```

**Expected Output:**
- 2 rows: combo_groups.legacy_v1_id, dishes.legacy_v1_id
- Both should be integer or bigint

**If Missing:**
- CRITICAL: Cannot map V1 → V3 without these columns
- STOP and alert human

### Step 5: Execute Combo Fix Migration

**Agent Action:** Run the migration script

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql`

**IMPORTANT:** This script is complex with multiple steps:

1. **Creates temporary tables** for V1 data
2. **Loads V1 combos** from converted file
3. **Maps V1 IDs → V3 IDs** using legacy columns
4. **Inserts combo_items** (bulk insert of ~110K rows)
5. **Validates results** (orphan rate check)
6. **Cleans up** temporary tables

**Execution Notes:**

The script has a file read operation that may not work with MCP tools:
```sql
-- Line 69-70: Uses COPY FROM PROGRAM (may fail)
COPY temp_v1_combos FROM PROGRAM ...
```

**If File Read Fails:**

**Alternative Approach:** The script includes a backup method starting at line 74:
```sql
INSERT INTO temp_v1_combos...
SELECT regexp_matches...
FROM pg_read_file('[path]')...
```

**Agent Decision:**
1. Try executing the full script first
2. If COPY FROM PROGRAM fails, note the error
3. The script should continue with the INSERT method
4. Watch for "V1 combos loaded: XXXXX" message

**Expected Output:**
```
BEGIN
CREATE TEMPORARY TABLE
INSERT... (loading V1 data)
NOTICE: === STAGING VALIDATION ===
NOTICE: V1 combos loaded: ~110,000
CREATE TEMPORARY TABLE
INSERT... (mapping)
NOTICE: === MAPPING RESULTS ===
NOTICE: Successfully mapped: ~110,000
INSERT... (into combo_items)
NOTICE: === INSERTION COMPLETE ===
NOTICE: New combo_items inserted: ~110,000
NOTICE: === POST-MIGRATION STATE ===
NOTICE: Orphaned combo groups: XXX (X.XX%)
DROP TABLE
COMMIT
```

**Watch For:**
- "V1 combos loaded" > 100,000 (good!)
- "Successfully mapped" > 100,000 (good!)
- "New combo_items inserted" > 100,000 (good!)
- **Final orphan rate < 5%** (CRITICAL!)

### Step 6: Verify Post-Migration State

**Agent Action:** Check combo_items were created

```sql
-- Count combo_items after migration
SELECT 
  'POST-FIX STATE' as label,
  (SELECT COUNT(*) FROM menuca_v3.combo_groups) as total_groups,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as total_items,
  (SELECT COUNT(DISTINCT combo_group_id) FROM menuca_v3.combo_items) as groups_with_items,
  NOW() as timestamp;
```

**Expected Output:**
- total_groups: ~8,234 (unchanged)
- total_items: 50,000-120,000 (HUGE increase!)
- groups_with_items: 7,800+ (most groups now have items!)

**If total_items < 10,000:**
- Migration likely failed or only partially succeeded
- Check error logs from Step 5
- May need to investigate or rollback

### Step 7: Calculate Post-Fix Orphan Rate

```sql
-- Calculate new orphan rate
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned,
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct,
  CASE 
    WHEN ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) < 1.0 
      THEN 'EXCELLENT'
    WHEN ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) < 5.0 
      THEN 'PASS'
    WHEN ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) < 20.0 
      THEN 'WARNING'
    ELSE 'FAIL'
  END as status
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;
```

**Expected Output:**
- orphan_pct: < 5% (ideally < 1%)
- status: 'PASS' or 'EXCELLENT'

**Agent Note:** This is the CRITICAL validation. Must be < 5% to pass.

### Step 8: Run Comprehensive Validation

**Agent Action:** Execute validation script

**File:** `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/validate_combo_fix.sql`

**Execute All Validation Tests:**

```sql
-- This script has 12 test sections
-- Execute each and capture results

-- Test 1: Overall Statistics
-- Test 2: Orphan Rate Check
-- Test 3: Expected vs Actual Item Counts
-- Test 4: Item Count Distribution
-- Test 5: Sample Well-Populated Combo Groups
-- Test 6: Remaining Orphaned Combo Groups
-- Test 7: Source System Breakdown
-- Test 8: Restaurant Coverage
-- Test 9: Dish Usage in Combos
-- Test 10: Recently Created Items
-- Test 11: Data Integrity Checks
-- Test 12: Duplicate Check
```

**Key Validations:**
- Orphan rate < 5% ✓
- No null dish_ids ✓
- No invalid FK references ✓
- No duplicate combo-dish pairs ✓
- Expected vs actual item counts reasonable

### Step 9: Sample Combo Check

**Agent Action:** Spot check actual combos look correct

```sql
-- Get 5 random combos to inspect
SELECT 
  cg.id,
  cg.name,
  cg.restaurant_id,
  COUNT(ci.id) as item_count,
  string_agg(d.name, ' | ' ORDER BY ci.display_order) as dishes
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
WHERE ci.created_at >= CURRENT_DATE  -- Only newly migrated
GROUP BY cg.id, cg.name, cg.restaurant_id
ORDER BY random()
LIMIT 5;
```

**Expected Output:**
- 5 combos shown
- Each has 2+ dishes (most combos are 2-4 items)
- Dish names look reasonable (not weird data)

**Manual Review:**
- Do the dish names make sense for a combo?
- Are there 2+ items per combo?
- Does it look like real menu data?

### Step 10: Update EXECUTION_LOG

**Agent Action:** Document all results

```bash
cat >> /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md <<EOF

================================================================================
TICKET 04: Staging Combo Fix
================================================================================
Date/Time: $(date +"%Y-%m-%d %H:%M:%S")
Status: IN_PROGRESS

## Pre-Fix State
- Combo Groups: [from step 2]
- Combo Items: [from step 2] (~63)
- Orphan Rate: [from step 3]%

## Migration Execution
- V1 Combos Loaded: [from step 5]
- Successfully Mapped: [from step 5]
- New Items Inserted: [from step 5]
- Migration Status: SUCCESS / PARTIAL / FAILED

## Post-Fix State
- Combo Groups: [from step 6] (unchanged)
- Combo Items: [from step 6] (huge increase!)
- Groups with Items: [from step 6]
- Orphan Rate: [from step 7]%

## Validation Results
- Orphan Rate: [X]% < 5% → PASS / FAIL
- Data Integrity: ALL CHECKS PASS / ISSUES FOUND
- Sample Combos: LOOK CORRECT / LOOK WRONG
- Duplicate Check: NONE FOUND / DUPLICATES EXIST

## Critical Metrics
- Improvement: 99.8% → [final]% orphan rate
- Items Created: ~[count] new combo_items
- Restaurants Affected: [from test 8]

STATUS: [see validation]

EOF
```

---

## VALIDATION CRITERIA

Complete this checklist:

- [ ] **V1 source file exists**
  - Check: Step 1 found the file
  
- [ ] **Legacy ID columns present**
  - Check: Step 4 found both legacy_v1_id columns
  
- [ ] **Migration script executed fully**
  - Check: Step 5 reached COMMIT without fatal errors
  
- [ ] **Substantial items inserted**
  - Check: Step 6 shows 50,000+ new combo_items
  
- [ ] **Orphan rate < 5%**
  - Check: Step 7 orphan_pct < 5.0
  - **CRITICAL:** This must pass
  
- [ ] **All validation tests pass**
  - Check: Step 8 validation script results
  
- [ ] **No data integrity issues**
  - Check: No nulls, no invalid FKs, no duplicates
  
- [ ] **Sample combos look correct**
  - Check: Step 9 shows reasonable combo data

---

## SUCCESS CONDITIONS

**All validation criteria must PASS, especially orphan rate < 5%.**

If all checks pass:
1. **Log to EXECUTION_LOG.md:**
   ```
   ## Final Validation
   - ✓ Combo Items Inserted: ~[count]
   - ✓ Orphan Rate: [X]% (was 99.8%) ✓
   - ✓ Data Integrity: PASS
   - ✓ Sample Check: PASS
   
   STATUS: COMPLETE
   ```

2. **Proceed to next ticket:**
   - Next: `05_STAGING_VALIDATION.md`
   - Combo system repaired, ready for full validation

---

## FAILURE CONDITIONS

**If ANY critical validation fails:**

### Scenario 1: Orphan Rate Still > 20%

**Symptoms:**
- Step 7 shows orphan_pct > 20%
- Most groups still don't have items

**Actions:**
1. STOP - Migration largely failed
2. Check how many items were actually inserted (Step 6)
3. Review migration script output for errors
4. Check if V1 data loaded:
   ```sql
   -- Check if V1 combos were mapped
   SELECT COUNT(*) FROM menuca_v3.combo_items 
   WHERE source_system = 'v1' AND created_at >= CURRENT_DATE;
   ```
5. If < 10,000 items, migration failed
6. **Recommend ROLLBACK** and investigate

**Common Causes:**
- V1 file not found/not readable
- Legacy ID columns don't match
- V1 IDs not in V3 tables
- Script error during mapping

### Scenario 2: Data Integrity Issues

**Symptoms:**
- Null dish_ids or combo_group_ids
- Invalid foreign key references
- Duplicate combo-dish pairs

**Actions:**
1. STOP - Data corruption
2. Check which integrity test failed
3. Query the bad data:
   ```sql
   -- Find null FKs
   SELECT * FROM menuca_v3.combo_items 
   WHERE dish_id IS NULL OR combo_group_id IS NULL;
   
   -- Find invalid FKs
   SELECT ci.* FROM menuca_v3.combo_items ci
   LEFT JOIN menuca_v3.dishes d ON ci.dish_id = d.id
   WHERE d.id IS NULL;
   ```
4. **Recommend ROLLBACK** - Do NOT proceed with corrupt data

### Scenario 3: Too Few Items Created

**Symptoms:**
- Step 6 shows < 10,000 new items
- Expected ~110,000

**Actions:**
1. Check V1 load count from migration output
2. If V1 combos loaded but not mapped:
   - Legacy ID issue
   - V1 IDs don't match V3
3. If V1 combos didn't load:
   - File read problem
   - Path incorrect
   - File format issue
4. **Recommend ROLLBACK** and investigate

### Scenario 4: Sample Combos Look Wrong

**Symptoms:**
- Dishes don't make sense together
- Random/unrelated items in combos
- Clearly wrong data

**Actions:**
1. Check 10-20 more samples manually
2. If pattern of incorrect data, mapping is wrong
3. Verify legacy_v1_id values are correct
4. **Recommend ROLLBACK** if data is systematically wrong

---

## ROLLBACK

**If combo fix fails:**

### Option A: Delete New Combo Items (5 minutes)

```sql
BEGIN;

-- Backup before deletion
CREATE TABLE menuca_v3.combo_items_rollback_backup AS
SELECT * FROM menuca_v3.combo_items;

-- Delete items created today
DELETE FROM menuca_v3.combo_items 
WHERE created_at >= CURRENT_DATE;

-- Verify count
SELECT COUNT(*) FROM menuca_v3.combo_items;
-- Should match pre-migration count (~63)

-- Check orphan rate
SELECT 
  ROUND(((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100), 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;
-- Should be back to ~99.8%

COMMIT;
```

**Time:** 5 minutes  
**Impact:** Returns to broken state, but clean

### Option B: Full Database Restore

```bash
# Use backup from Ticket 01
supabase db restore --backup-id [backup-id-from-ticket-01]
```

**Time:** 15 minutes  
**Impact:** Reverts indexes, RLS, and combo fix

**When to Use:**
- Option A: Combo fix only issue, keep indexes/RLS
- Option B: Multiple systems broken, full reset needed

---

## CONTEXT FOR NEXT STEP

```
COMBO FIX RESULTS:
- Items Inserted: ~[count]
- Orphan Rate Before: 99.8%
- Orphan Rate After: _____%
- Fix Status: ✓ SUCCESS / ⚠ PARTIAL / ✗ FAILED

DATA VALIDATION:
- Integrity Checks: ✓ PASS / ✗ FAIL
- Sample Combos: ✓ CORRECT / ✗ WRONG
- Expected vs Actual: ✓ REASONABLE / ✗ MISMATCH

STAGING DEPLOYMENT STATUS:
✓ Backup complete (Ticket 01)
✓ Indexes deployed (Ticket 02)
✓ RLS policies active (Ticket 03)
✓ Combo system repaired (Ticket 04)

READY FOR FULL VALIDATION:
✓ Proceed to 05_STAGING_VALIDATION.md
```

**Next Ticket:** `05_STAGING_VALIDATION.md`

---

## NOTES FOR AGENT

### Why This is Risky

**Data Modification:**
- Inserts ~110,000 rows (substantial)
- Permanent change (not easily reversed)
- Wrong mapping = wrong combos forever

**That's Why We:**
- Validate heavily (12 test sections)
- Check samples manually
- Have clear rollback procedure
- Required backup first (Ticket 01)

### Expected Success Indicators

**Good Migration:**
- V1 combos loaded: > 100,000
- Items inserted: 50,000-120,000
- Orphan rate: < 1%
- No integrity errors

**Marginal Migration:**
- Items inserted: 30,000-50,000
- Orphan rate: 1-5%
- Some unmapped items (acceptable)

**Failed Migration:**
- Items inserted: < 10,000
- Orphan rate: > 20%
- Data integrity errors

---

**Ticket Status:** READY  
**Dependencies:** Tickets 01-03 COMPLETE  
**Last Updated:** October 10, 2025  
**Validated By:** Brian Lapp

