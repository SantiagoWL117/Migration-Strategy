# DATA REMEDIATION MASTER PLAN
## Menu & Catalog V1/V2 Data Cleanup

**Created:** 2025-10-01  
**Database:** Supabase PostgreSQL (staging schema)  
**Scope:** Fix critical data quality issues before V3 migration  
**Execution:** Parallel workstreams via autonomous agents

---

## 📊 ISSUE SUMMARY

| Category | Affected Records | Priority | Complexity | Est. Time |
|----------|-----------------|----------|------------|-----------|
| **WORKSTREAM 1:** Blank Names | 13,799 | HIGH | LOW | 30 min |
| **WORKSTREAM 2:** Orphaned Records | 1,228 | CRITICAL | MEDIUM | 45 min |
| **WORKSTREAM 3:** Business Logic | 312 | MEDIUM | MEDIUM | 60 min |
| **WORKSTREAM 4:** Invalid References | 2 | LOW | LOW | 15 min |

**Total Records to Fix:** 15,341  
**Estimated Total Time:** 2.5 hours (30 min if parallel)

---

## 🔧 WORKSTREAM 1: BLANK NAMES
**Agent:** `blank-names-agent`  
**Priority:** HIGH  
**Affected Tables:** `v1_menu`, `v2_global_ingredients`  
**Record Count:** 13,799

### 📋 Problem Statement
- 13,798 `v1_menu` records have blank names
- 1 `v2_global_ingredients` record has blank name
- 97.8% are hidden from menu (soft-deleted)
- Inherited from previous V1→V2 migration

### 🎯 Resolution Strategy
**Option A: Mark for Exclusion** (Recommended)
- Add `exclude_from_v3` flag column
- Mark all blank-name records
- Document exclusion reason

**Option B: Auto-populate from ingredients**
- Only 1 record (Greek salad) has inferable name
- Not worth complex logic for 0.007% of records

### ✅ Detailed Action Plan

#### Task 1.1: Add Exclusion Flag Column
```sql
-- Add tracking column to v1_menu
ALTER TABLE staging.v1_menu 
ADD COLUMN IF NOT EXISTS exclude_from_v3 BOOLEAN DEFAULT FALSE;

ALTER TABLE staging.v1_menu 
ADD COLUMN IF NOT EXISTS exclusion_reason VARCHAR(255);

-- Add tracking column to v2_global_ingredients
ALTER TABLE staging.v2_global_ingredients 
ADD COLUMN IF NOT EXISTS exclude_from_v3 BOOLEAN DEFAULT FALSE;

ALTER TABLE staging.v2_global_ingredients 
ADD COLUMN IF NOT EXISTS exclusion_reason VARCHAR(255);
```

**Validation:**
```sql
-- Verify columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' 
  AND table_name IN ('v1_menu', 'v2_global_ingredients')
  AND column_name IN ('exclude_from_v3', 'exclusion_reason');
```

#### Task 1.2: Mark Blank Name Records
```sql
-- Mark v1_menu blank names
UPDATE staging.v1_menu
SET 
  exclude_from_v3 = TRUE,
  exclusion_reason = 'Blank name - inherited from V1→V2 migration'
WHERE name IS NULL 
   OR TRIM(name) = '';

-- Mark v2_global_ingredients blank name
UPDATE staging.v2_global_ingredients
SET 
  exclude_from_v3 = TRUE,
  exclusion_reason = 'Blank name - incomplete record'
WHERE name IS NULL 
   OR TRIM(name) = '';
```

**Validation:**
```sql
-- Verify counts match
SELECT 
  'v1_menu' as table_name,
  COUNT(*) as marked_for_exclusion
FROM staging.v1_menu
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Blank name%'

UNION ALL

SELECT 
  'v2_global_ingredients',
  COUNT(*)
FROM staging.v2_global_ingredients
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Blank name%';

-- Expected: v1_menu = 13,798, v2_global_ingredients = 1
```

#### Task 1.3: Generate Cleanup Report
```sql
-- Detailed breakdown by characteristics
SELECT 
  'Blank Names Total' as category,
  COUNT(*) as total,
  COUNT(CASE WHEN showinmenu = 'Y' THEN 1 END) as visible_in_menu,
  COUNT(CASE WHEN showinmenu = 'N' THEN 1 END) as hidden,
  COUNT(CASE WHEN restaurant = 0 THEN 1 END) as orphaned_restaurant,
  COUNT(CASE WHEN course = 0 THEN 1 END) as orphaned_course
FROM staging.v1_menu
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Blank name%';
```

### 📊 Success Criteria
- ✅ 13,798 v1_menu records marked for exclusion
- ✅ 1 v2_global_ingredients record marked for exclusion
- ✅ All have `exclusion_reason` populated
- ✅ No false positives (records with actual names marked)

### 🔄 Rollback Plan
```sql
-- Rollback if needed
UPDATE staging.v1_menu
SET exclude_from_v3 = FALSE, exclusion_reason = NULL
WHERE exclusion_reason LIKE 'Blank name%';

UPDATE staging.v2_global_ingredients
SET exclude_from_v3 = FALSE, exclusion_reason = NULL
WHERE exclusion_reason LIKE 'Blank name%';
```

---

## 🔧 WORKSTREAM 2: ORPHANED RECORDS
**Agent:** `orphaned-records-agent`  
**Priority:** CRITICAL  
**Affected Tables:** `v2_restaurants_courses`, `v2_restaurants_dishes`, `v2_restaurants_dishes_customization`  
**Record Count:** 1,228

### 📋 Problem Statement
- **1,162** `v2_restaurants_courses` missing valid `restaurant_id`
- **49** `v2_restaurants_dishes` missing valid `course_id`
- **17** `v2_restaurants_dishes_customization` missing valid `dish_id`

### 🎯 Resolution Strategy
**Three-Phase Approach:**
1. Attempt to infer valid parent IDs from context
2. Mark unrecoverable records for exclusion
3. Generate report of orphaned data for manual review

### ✅ Detailed Action Plan

#### Task 2.1: Add Tracking Columns
```sql
-- Add columns to all affected tables
ALTER TABLE staging.v2_restaurants_courses 
ADD COLUMN IF NOT EXISTS exclude_from_v3 BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS exclusion_reason VARCHAR(255);

ALTER TABLE staging.v2_restaurants_dishes 
ADD COLUMN IF NOT EXISTS exclude_from_v3 BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS exclusion_reason VARCHAR(255);

ALTER TABLE staging.v2_restaurants_dishes_customization 
ADD COLUMN IF NOT EXISTS exclude_from_v3 BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS exclusion_reason VARCHAR(255);
```

#### Task 2.2: Analyze Orphaned Courses (1,162 records)
```sql
-- Detailed analysis of orphaned courses
SELECT 
  id,
  restaurant_id,
  name,
  enabled,
  added_at,
  disabled_at,
  CASE 
    WHEN restaurant_id = 0 THEN 'Missing restaurant'
    WHEN restaurant_id IS NULL THEN 'NULL restaurant'
    ELSE 'Invalid restaurant ID'
  END as issue_type
FROM staging.v2_restaurants_courses
WHERE restaurant_id NOT IN (
  SELECT DISTINCT restaurant 
  FROM staging.v1_menu 
  WHERE restaurant > 0
)
ORDER BY restaurant_id, id
LIMIT 100;
```

#### Task 2.3: Mark Orphaned Courses
```sql
-- Mark courses with invalid restaurant_id
UPDATE staging.v2_restaurants_courses
SET 
  exclude_from_v3 = TRUE,
  exclusion_reason = 'Orphaned: Invalid restaurant_id (' || COALESCE(restaurant_id::TEXT, 'NULL') || ')'
WHERE restaurant_id NOT IN (
  SELECT DISTINCT restaurant 
  FROM staging.v1_menu 
  WHERE restaurant > 0
)
OR restaurant_id IS NULL
OR restaurant_id = 0;
```

**Validation:**
```sql
-- Should be ~1,162 records
SELECT COUNT(*) as orphaned_courses
FROM staging.v2_restaurants_courses
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Orphaned: Invalid restaurant_id%';
```

#### Task 2.4: Analyze Orphaned Dishes (49 records)
```sql
-- Detailed analysis of orphaned dishes
SELECT 
  d.id,
  d.restaurant_id,
  d.course_id,
  d.name,
  d.enabled,
  CASE 
    WHEN d.course_id = 0 THEN 'Missing course (0)'
    WHEN d.course_id IS NULL THEN 'NULL course'
    ELSE 'Invalid course ID: ' || d.course_id::TEXT
  END as issue_type
FROM staging.v2_restaurants_dishes d
WHERE d.course_id NOT IN (
  SELECT id 
  FROM staging.v2_restaurants_courses
  WHERE exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL
)
ORDER BY d.course_id, d.id
LIMIT 100;
```

#### Task 2.5: Mark Orphaned Dishes
```sql
-- Mark dishes with invalid course_id
UPDATE staging.v2_restaurants_dishes
SET 
  exclude_from_v3 = TRUE,
  exclusion_reason = 'Orphaned: Invalid course_id (' || COALESCE(course_id::TEXT, 'NULL') || ')'
WHERE course_id NOT IN (
  SELECT id 
  FROM staging.v2_restaurants_courses
  WHERE exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL
)
OR course_id IS NULL
OR course_id = 0;
```

**Validation:**
```sql
-- Should be ~49 records
SELECT COUNT(*) as orphaned_dishes
FROM staging.v2_restaurants_dishes
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Orphaned: Invalid course_id%';
```

#### Task 2.6: Analyze Orphaned Customizations (17 records)
```sql
-- Detailed analysis of orphaned customizations
SELECT 
  c.id,
  c.dish_id,
  c.customization_id,
  c.enabled,
  CASE 
    WHEN c.dish_id = 0 THEN 'Missing dish (0)'
    WHEN c.dish_id IS NULL THEN 'NULL dish'
    ELSE 'Invalid dish ID: ' || c.dish_id::TEXT
  END as issue_type
FROM staging.v2_restaurants_dishes_customization c
WHERE c.dish_id NOT IN (
  SELECT id 
  FROM staging.v2_restaurants_dishes
  WHERE exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL
)
ORDER BY c.dish_id, c.id;
```

#### Task 2.7: Mark Orphaned Customizations
```sql
-- Mark customizations with invalid dish_id
UPDATE staging.v2_restaurants_dishes_customization
SET 
  exclude_from_v3 = TRUE,
  exclusion_reason = 'Orphaned: Invalid dish_id (' || COALESCE(dish_id::TEXT, 'NULL') || ')'
WHERE dish_id NOT IN (
  SELECT id 
  FROM staging.v2_restaurants_dishes
  WHERE exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL
)
OR dish_id IS NULL
OR dish_id = 0;
```

**Validation:**
```sql
-- Should be ~17 records
SELECT COUNT(*) as orphaned_customizations
FROM staging.v2_restaurants_dishes_customization
WHERE exclude_from_v3 = TRUE
  AND exclusion_reason LIKE 'Orphaned: Invalid dish_id%';
```

#### Task 2.8: Generate Orphaned Data Report
```sql
-- Summary of all orphaned records
SELECT 
  'v2_restaurants_courses' as table_name,
  COUNT(*) as orphaned_records,
  'Invalid restaurant_id' as issue
FROM staging.v2_restaurants_courses
WHERE exclude_from_v3 = TRUE

UNION ALL

SELECT 
  'v2_restaurants_dishes',
  COUNT(*),
  'Invalid course_id'
FROM staging.v2_restaurants_dishes
WHERE exclude_from_v3 = TRUE

UNION ALL

SELECT 
  'v2_restaurants_dishes_customization',
  COUNT(*),
  'Invalid dish_id'
FROM staging.v2_restaurants_dishes_customization
WHERE exclude_from_v3 = TRUE;
```

### 📊 Success Criteria
- ✅ 1,162 orphaned courses marked
- ✅ 49 orphaned dishes marked
- ✅ 17 orphaned customizations marked
- ✅ All have clear `exclusion_reason`
- ✅ Cascade effect documented (dishes orphaned by excluded courses)

### 🔄 Rollback Plan
```sql
-- Rollback all orphaned marks
UPDATE staging.v2_restaurants_courses
SET exclude_from_v3 = FALSE, exclusion_reason = NULL
WHERE exclusion_reason LIKE 'Orphaned:%';

UPDATE staging.v2_restaurants_dishes
SET exclude_from_v3 = FALSE, exclusion_reason = NULL
WHERE exclusion_reason LIKE 'Orphaned:%';

UPDATE staging.v2_restaurants_dishes_customization
SET exclude_from_v3 = FALSE, exclusion_reason = NULL
WHERE exclusion_reason LIKE 'Orphaned:%';
```

---

## 🔧 WORKSTREAM 3: BUSINESS LOGIC INCONSISTENCIES
**Agent:** `business-logic-agent`  
**Priority:** MEDIUM  
**Affected Tables:** `v2_restaurants_dishes`, `v2_global_ingredients`  
**Record Count:** 312

### 📋 Problem Statement
- **177** `v2_restaurants_dishes` marked `enabled=1` but have `disabled_at` timestamp
- **123** `v2_global_ingredients` marked `enabled=1` but have `disabled_at` timestamp
- **12** `v2_restaurants_dishes` have `added_at > disabled_at` (backwards timestamps)

### 🎯 Resolution Strategy
**Logic-Based Auto-Fix:**
1. If `disabled_at` is set and recent → set `enabled=0`
2. If `disabled_at` is very old (>1 year) → clear `disabled_at`
3. If timestamps backwards → swap or NULL the invalid one
4. Document all corrections

### ✅ Detailed Action Plan

#### Task 3.1: Add Tracking Columns
```sql
-- Add correction tracking
ALTER TABLE staging.v2_restaurants_dishes 
ADD COLUMN IF NOT EXISTS data_corrected BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS correction_notes TEXT;

ALTER TABLE staging.v2_global_ingredients 
ADD COLUMN IF NOT EXISTS data_corrected BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS correction_notes TEXT;
```

#### Task 3.2: Analyze Enabled+Disabled Dishes (177 records)
```sql
-- Categorize by how old the disabled_at timestamp is
SELECT 
  id,
  restaurant_id,
  name,
  enabled,
  added_at,
  disabled_at,
  EXTRACT(DAY FROM NOW() - disabled_at) as days_since_disabled,
  CASE 
    WHEN EXTRACT(DAY FROM NOW() - disabled_at) <= 30 THEN 'Recently disabled'
    WHEN EXTRACT(DAY FROM NOW() - disabled_at) <= 365 THEN 'Disabled <1 year'
    ELSE 'Disabled >1 year'
  END as category
FROM staging.v2_restaurants_dishes
WHERE enabled = 1 
  AND disabled_at IS NOT NULL
ORDER BY disabled_at DESC;
```

#### Task 3.3: Fix Enabled+Disabled Dishes
```sql
-- Fix: If disabled_at is set, should be enabled=0
UPDATE staging.v2_restaurants_dishes
SET 
  enabled = 0,
  data_corrected = TRUE,
  correction_notes = 'Auto-corrected: enabled was TRUE despite disabled_at being set to ' || disabled_at::TEXT
WHERE enabled = 1 
  AND disabled_at IS NOT NULL;
```

**Validation:**
```sql
-- Should be ~177 records corrected
SELECT COUNT(*) as corrected_dishes
FROM staging.v2_restaurants_dishes
WHERE data_corrected = TRUE
  AND correction_notes LIKE 'Auto-corrected: enabled was TRUE%';
```

#### Task 3.4: Analyze Enabled+Disabled Ingredients (123 records)
```sql
-- Categorize ingredients
SELECT 
  id,
  name,
  enabled,
  added_at,
  disabled_at,
  EXTRACT(DAY FROM NOW() - disabled_at) as days_since_disabled,
  CASE 
    WHEN EXTRACT(DAY FROM NOW() - disabled_at) <= 30 THEN 'Recently disabled'
    WHEN EXTRACT(DAY FROM NOW() - disabled_at) <= 365 THEN 'Disabled <1 year'
    ELSE 'Disabled >1 year'
  END as category
FROM staging.v2_global_ingredients
WHERE enabled = 1 
  AND disabled_at IS NOT NULL
ORDER BY disabled_at DESC;
```

#### Task 3.5: Fix Enabled+Disabled Ingredients
```sql
-- Fix: If disabled_at is set, should be enabled=0
UPDATE staging.v2_global_ingredients
SET 
  enabled = 0,
  data_corrected = TRUE,
  correction_notes = 'Auto-corrected: enabled was TRUE despite disabled_at being set to ' || disabled_at::TEXT
WHERE enabled = 1 
  AND disabled_at IS NOT NULL;
```

**Validation:**
```sql
-- Should be ~123 records corrected
SELECT COUNT(*) as corrected_ingredients
FROM staging.v2_global_ingredients
WHERE data_corrected = TRUE
  AND correction_notes LIKE 'Auto-corrected: enabled was TRUE%';
```

#### Task 3.6: Analyze Backwards Timestamps (12 records)
```sql
-- Find dishes with added_at > disabled_at
SELECT 
  id,
  restaurant_id,
  name,
  enabled,
  added_at,
  disabled_at,
  EXTRACT(DAY FROM added_at - disabled_at) as days_difference
FROM staging.v2_restaurants_dishes
WHERE added_at > disabled_at
ORDER BY (added_at - disabled_at) DESC;
```

#### Task 3.7: Fix Backwards Timestamps
```sql
-- Strategy: NULL the disabled_at if it's before added_at (logically impossible)
UPDATE staging.v2_restaurants_dishes
SET 
  disabled_at = NULL,
  data_corrected = TRUE,
  correction_notes = COALESCE(correction_notes || ' | ', '') || 
    'Removed invalid disabled_at (' || disabled_at::TEXT || ') which was before added_at (' || added_at::TEXT || ')'
WHERE added_at > disabled_at;
```

**Validation:**
```sql
-- Should be ~12 records corrected
SELECT COUNT(*) as fixed_backwards_timestamps
FROM staging.v2_restaurants_dishes
WHERE correction_notes LIKE '%Removed invalid disabled_at%';

-- Verify no more backwards timestamps exist
SELECT COUNT(*) as should_be_zero
FROM staging.v2_restaurants_dishes
WHERE added_at > disabled_at;
```

#### Task 3.8: Generate Business Logic Corrections Report
```sql
-- Summary of all corrections
SELECT 
  'Dishes: enabled+disabled' as correction_type,
  COUNT(*) as records_fixed
FROM staging.v2_restaurants_dishes
WHERE correction_notes LIKE 'Auto-corrected: enabled was TRUE%'

UNION ALL

SELECT 
  'Ingredients: enabled+disabled',
  COUNT(*)
FROM staging.v2_global_ingredients
WHERE correction_notes LIKE 'Auto-corrected: enabled was TRUE%'

UNION ALL

SELECT 
  'Dishes: backwards timestamps',
  COUNT(*)
FROM staging.v2_restaurants_dishes
WHERE correction_notes LIKE '%Removed invalid disabled_at%';
```

### 📊 Success Criteria
- ✅ 177 dishes corrected (enabled → 0)
- ✅ 123 ingredients corrected (enabled → 0)
- ✅ 12 dishes with backwards timestamps fixed
- ✅ No remaining enabled=1 records with disabled_at set
- ✅ No remaining added_at > disabled_at records

### 🔄 Rollback Plan
```sql
-- Note: This is harder to rollback since we're changing data
-- Best to keep a backup before running

-- To reverse enabled changes (if you have original data):
UPDATE staging.v2_restaurants_dishes
SET enabled = 1, data_corrected = FALSE, correction_notes = NULL
WHERE correction_notes LIKE 'Auto-corrected: enabled was TRUE%';

UPDATE staging.v2_global_ingredients
SET enabled = 1, data_corrected = FALSE, correction_notes = NULL
WHERE correction_notes LIKE 'Auto-corrected: enabled was TRUE%';
```

---

## 🔧 WORKSTREAM 4: INVALID REFERENCES
**Agent:** `invalid-refs-agent`  
**Priority:** LOW  
**Affected Tables:** `v2_global_ingredients`  
**Record Count:** 2

### 📋 Problem Statement
- **2** `v2_global_ingredients` records have `language_id = 0` (invalid)
- Should be 1 (English) or 2 (French) based on system design

### 🎯 Resolution Strategy
**Context-Based Inference:**
1. Check if ingredient name is English or French
2. Infer language_id from name
3. Default to 1 (English) if unclear

### ✅ Detailed Action Plan

#### Task 4.1: Analyze Invalid Language Records
```sql
-- Find and analyze the 2 records
SELECT 
  id,
  name,
  restaurant_id,
  language_id,
  enabled,
  added_at
FROM staging.v2_global_ingredients
WHERE language_id = 0;
```

#### Task 4.2: Fix Language IDs
```sql
-- Default to English (language_id = 1)
UPDATE staging.v2_global_ingredients
SET 
  language_id = 1,
  data_corrected = TRUE,
  correction_notes = 'Corrected invalid language_id from 0 to 1 (English default)'
WHERE language_id = 0;
```

**Validation:**
```sql
-- Should be 0 records remaining
SELECT COUNT(*) as should_be_zero
FROM staging.v2_global_ingredients
WHERE language_id = 0;

-- Verify fix was applied
SELECT COUNT(*) as should_be_2
FROM staging.v2_global_ingredients
WHERE correction_notes LIKE 'Corrected invalid language_id%';
```

### 📊 Success Criteria
- ✅ 2 records corrected
- ✅ No remaining language_id = 0 records
- ✅ All ingredients have valid language_id (1 or 2)

### 🔄 Rollback Plan
```sql
-- Rollback language_id changes
UPDATE staging.v2_global_ingredients
SET language_id = 0, data_corrected = FALSE, correction_notes = NULL
WHERE correction_notes LIKE 'Corrected invalid language_id%';
```

---

## 🚀 EXECUTION PLAN

### Phase 1: Pre-Flight Checks (5 min)
```sql
-- Verify all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'staging'
  AND table_name IN (
    'v1_menu',
    'v2_global_ingredients',
    'v2_restaurants_courses',
    'v2_restaurants_dishes',
    'v2_restaurants_dishes_customization'
  );

-- Verify row counts match expectations
SELECT 
  'v1_menu' as table_name, COUNT(*) as total_rows
FROM staging.v1_menu
UNION ALL
SELECT 'v2_global_ingredients', COUNT(*) FROM staging.v2_global_ingredients
UNION ALL
SELECT 'v2_restaurants_courses', COUNT(*) FROM staging.v2_restaurants_courses
UNION ALL
SELECT 'v2_restaurants_dishes', COUNT(*) FROM staging.v2_restaurants_dishes
UNION ALL
SELECT 'v2_restaurants_dishes_customization', COUNT(*) FROM staging.v2_restaurants_dishes_customization;
```

### Phase 2: Launch All Agents (Parallel)
**Agent Launch Order:**
1. ✅ **Workstream 4** (fastest, no dependencies) - 15 min
2. ✅ **Workstream 1** (no dependencies) - 30 min
3. ✅ **Workstream 3** (no dependencies) - 60 min
4. ✅ **Workstream 2** (depends on W1/W3 for accurate counts) - 45 min

**Total Time (Parallel):** ~60 min  
**Total Time (Sequential):** ~2.5 hours

### Phase 3: Final Verification (10 min)
```sql
-- Verify all issues resolved
WITH issue_summary AS (
  SELECT 
    'Blank Names' as issue,
    COUNT(*) as remaining
  FROM staging.v1_menu
  WHERE (name IS NULL OR TRIM(name) = '')
    AND (exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL)
  
  UNION ALL
  
  SELECT 
    'Orphaned Courses',
    COUNT(*)
  FROM staging.v2_restaurants_courses
  WHERE restaurant_id NOT IN (SELECT DISTINCT restaurant FROM staging.v1_menu WHERE restaurant > 0)
    AND (exclude_from_v3 = FALSE OR exclude_from_v3 IS NULL)
  
  UNION ALL
  
  SELECT 
    'Enabled + Disabled',
    COUNT(*)
  FROM staging.v2_restaurants_dishes
  WHERE enabled = 1 AND disabled_at IS NOT NULL
  
  UNION ALL
  
  SELECT 
    'Invalid Language',
    COUNT(*)
  FROM staging.v2_global_ingredients
  WHERE language_id = 0
)
SELECT * FROM issue_summary
WHERE remaining > 0;

-- Should return 0 rows if all fixed!
```

---

## 📊 SUCCESS METRICS

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| **Blank Names** | 13,799 | 0 (marked) | 0 active |
| **Orphaned Records** | 1,228 | 0 (marked) | 0 active |
| **Business Logic Issues** | 312 | 0 | 0 |
| **Invalid References** | 2 | 0 | 0 |
| **Total Data Quality Issues** | 15,341 | 0 | 0 |
| **Records Excluded from V3** | 0 | 15,027 | Document all |
| **Records Auto-Corrected** | 0 | 314 | Document all |

---

## 📝 POST-REMEDIATION DELIVERABLES

1. **Remediation Summary Report** (SQL-generated)
2. **Excluded Records List** (CSV export)
3. **Auto-Correction Log** (CSV export)
4. **Final Verification Report** (confirms 0 issues)
5. **Updated V3 Migration Filter** (WHERE clause)

---

## ⚠️ SAFETY PROTOCOLS

### Backup Strategy
```sql
-- Create backup tables before any changes
CREATE TABLE staging.v1_menu_backup_20251001 AS 
SELECT * FROM staging.v1_menu;

CREATE TABLE staging.v2_global_ingredients_backup_20251001 AS 
SELECT * FROM staging.v2_global_ingredients;

CREATE TABLE staging.v2_restaurants_courses_backup_20251001 AS 
SELECT * FROM staging.v2_restaurants_courses;

CREATE TABLE staging.v2_restaurants_dishes_backup_20251001 AS 
SELECT * FROM staging.v2_restaurants_dishes;

CREATE TABLE staging.v2_restaurants_dishes_customization_backup_20251001 AS 
SELECT * FROM staging.v2_restaurants_dishes_customization;
```

### Validation Gates
- ✅ Each agent must validate after every step
- ✅ No agent proceeds if validation fails
- ✅ All agents report progress to master log
- ✅ Final cross-check validates all workstreams together

---

## 🎯 READY TO LAUNCH?

**Next Steps:**
1. Review this plan
2. Confirm execution strategy (parallel vs sequential)
3. Create backup tables
4. Launch agents with this plan as their instruction set
5. Monitor progress
6. Run final verification
7. Generate deliverables

**Estimated Timeline:**
- Planning: ✅ Complete
- Backup: 5 min
- Execution (Parallel): 60 min
- Verification: 10 min
- **Total: ~75 minutes**

