# Re-Import Test Plan

**Date:** 2025-11-05  
**Purpose:** Test re-import process on 3 restaurants to validate data quality before proceeding with all 94

---

## Test Cases Selected

### Test Case 1: New Mukut Restaurant Indian Cuisine (ID: 234)
- **Source Type:** V1 Available
- **Current State:** 0 dishes, 0 courses (complete data loss)
- **Menu URL:** https://mukutorleans.menu.ca/?p=menu ✅
- **Why Selected:** Complete data loss - good test of full re-import
- **Expected Outcome:** Full menu with courses and dishes restored

### Test Case 2: Pizza Joanna (ID: 726)
- **Source Type:** V1 Available
- **Current State:** 1 dish, 1 course (partial data loss)
- **Menu URL:** https://pizzajoanna.menu.ca/?p=menu&lang=fr ✅
- **Why Selected:** Partial data loss - good test of incremental re-import
- **Expected Outcome:** Full menu restored, existing data preserved/merged

### Test Case 3: Mozza Pizza Gatineau (ID: 35)
- **Source Type:** V2 Available
- **Current State:** 3 dishes, 1 course (partial data loss, suspiciously low)
- **Menu URL:** https://mozzapizzagatineau.com/?p=menu&lang=fr ✅
- **Why Selected:** V2 source, partial data loss - tests V2 re-import path
- **Expected Outcome:** Full menu restored from V2 staging

---

## Re-Import Process

### Step 1: Backup Current Data
```sql
-- Create backup tables for each test restaurant
CREATE TABLE menuca_v3.dishes_backup_test_234 AS 
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 234;

CREATE TABLE menuca_v3.courses_backup_test_234 AS 
SELECT * FROM menuca_v3.courses WHERE restaurant_id = 234;

-- Repeat for IDs 726 and 35
```

### Step 2: Check Source Data Availability
```sql
-- For V1 restaurants (234, 726)
SELECT COUNT(*) as dish_count, COUNT(DISTINCT category) as category_count
FROM staging.menuca_v1_menu
WHERE restaurant IN (374, 964); -- legacy_v1_ids

-- For V2 restaurant (35)
-- Check V2 staging tables (need to identify correct table names)
```

### Step 3: Re-Import Process
- **V1 Restaurants:** Import from `staging.menuca_v1_menu`
- **V2 Restaurants:** Import from V2 staging tables (TBD - need to identify tables)

### Step 4: Quality Audit (Compare Re-Imported vs Live Menu)

---

## Quality Audit Checklist

For each test restaurant, compare:

### 1. Dish Count Comparison
- [ ] Count dishes in re-imported data
- [ ] Count dishes on live menu (manual count from URL)
- [ ] Calculate completeness percentage
- [ ] Document missing dishes

### 2. Course Structure Comparison
- [ ] List courses in re-imported data
- [ ] List courses on live menu
- [ ] Verify course names match
- [ ] Verify course order matches
- [ ] Document missing/extra courses

### 3. Dish-to-Course Assignment
- [ ] Verify each dish is assigned to correct course
- [ ] Check for dishes in "Uncategorized"
- [ ] Verify dish names match between source and live menu
- [ ] Document any mismatches

### 4. Modifier/Ingredient Groups
- [ ] Count modifiers in re-imported data
- [ ] Count modifiers on live menu (if visible)
- [ ] Verify modifier groups exist
- [ ] Verify modifier assignments to dishes

### 5. Data Quality Metrics
- [ ] Dish name accuracy (% matching live menu)
- [ ] Course assignment accuracy (% correct)
- [ ] Price accuracy (if available in source)
- [ ] Description accuracy (if available in source)

### 6. Usability Assessment
- [ ] Can menu be displayed correctly?
- [ ] Are all courses visible?
- [ ] Are all dishes visible?
- [ ] Are modifiers functional?
- [ ] Any data format issues?

---

## Success Criteria

### Minimum Acceptable Quality:
- **Dish Completeness:** ≥ 90% of live menu dishes present
- **Course Structure:** All major courses present and correctly named
- **Course Assignment:** ≥ 95% of dishes assigned to correct course
- **No "Uncategorized":** Zero dishes in uncategorized course

### Ideal Quality:
- **Dish Completeness:** 100% of live menu dishes present
- **Course Structure:** 100% match with live menu
- **Course Assignment:** 100% correct
- **Modifiers:** All modifiers present and correctly assigned

---

## Test Execution Plan

1. **Backup current data** (5 min)
2. **Check source data availability** (10 min)
3. **Re-import test case 1** (New Mukut) (30 min)
4. **Quality audit test case 1** (30 min)
5. **Re-import test case 2** (Pizza Joanna) (30 min)
6. **Quality audit test case 2** (30 min)
7. **Re-import test case 3** (Mozza Pizza) (30 min)
8. **Quality audit test case 3** (30 min)
9. **Compare results and document findings** (30 min)

**Total Estimated Time:** ~3.5 hours

---

## Documentation Template

For each test case, document:

```markdown
### Test Case X: [Restaurant Name] (ID: XXX)

**Re-Import Date:** YYYY-MM-DD
**Source Type:** V1/V2
**Menu URL:** [URL]

#### Pre-Re-Import State:
- Dishes: X
- Courses: X
- Modifiers: X

#### Source Data Available:
- V1 dishes in staging: X
- V2 dishes in staging: X (if applicable)

#### Post-Re-Import State:
- Dishes: X
- Courses: X
- Modifiers: X

#### Quality Audit Results:

**Dish Count:**
- Re-imported: X
- Live menu: X
- Completeness: X% ✅/⚠️/❌

**Course Structure:**
- Re-imported courses: [list]
- Live menu courses: [list]
- Match: ✅/⚠️/❌

**Course Assignment:**
- Correctly assigned: X%
- In "Uncategorized": X
- Match: ✅/⚠️/❌

**Modifiers:**
- Re-imported: X
- Live menu: X (if visible)
- Match: ✅/⚠️/❌

**Overall Assessment:**
- Quality Score: X/100
- Usable: ✅/❌
- Issues Found: [list]
- Recommendations: [list]
```

---

## Next Steps After Test

Based on test results:

1. **If Quality ≥ 90%:** Proceed with re-import for all 94 restaurants
2. **If Quality 70-89%:** Investigate issues, refine process, retest
3. **If Quality < 70%:** Consider alternative approach (scraping vs re-import)

---

**Status:** ⏳ Pending Execution  
**Next Action:** Identify V2 staging table structure, then begin test execution

