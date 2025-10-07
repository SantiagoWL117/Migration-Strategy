# 🚨 CRITICAL FINDING: Menu & Catalog Source Data Analysis

**Date:** January 7, 2025  
**Analyst:** AI Migration Reviewer  
**Status:** 🛑 **STOPPED FOR REVIEW** (per user request)

---

## 📋 EXECUTIVE SUMMARY

**Critical Issue Detected:** Massive data loss in Menu & Catalog entity migration

- **Expected Clean Dishes:** 95,073 (V1: 85,162 + V2: 9,911)
- **Actual Dishes in menuca_v3:** 42,930
- **Missing Dishes:** **52,143 (54.8% data loss)** 🚨

---

## 🔍 SECTION 1: SOURCE DATA VERIFICATION

### All V1 and V2 Source Data Successfully Loaded

✅ **All dumps loaded into staging tables successfully**

| Source | Table | Rows Loaded | Status |
|--------|-------|-------------|--------|
| **V1** | v1_courses | 12,924 | ✅ |
| **V1** | v1_menu (dishes) | 117,704 | ✅ |
| **V1** | v1_menuothers | 70,381 | ✅ |
| **V1** | v1_ingredients | 52,305 | ✅ |
| **V1** | v1_ingredient_groups | 13,255 | ✅ |
| **V1** | v1_combo_groups | 62,353 | ✅ |
| **V1** | v1_combos | 16,461 | ✅ |
| **V2** | v2_global_courses | 33 | ✅ |
| **V2** | v2_global_ingredients | 5,023 | ✅ |
| **V2** | v2_restaurants_courses | 1,269 | ✅ |
| **V2** | v2_restaurants_dishes | 10,289 | ✅ |
| **V2** | v2_restaurants_dishes_customization | 13,412 | ✅ |
| **V2** | v2_restaurants_combo_groups | 13 | ✅ |
| **V2** | v2_restaurants_combo_groups_items | 220 | ✅ |
| **V2** | v2_restaurants_ingredient_groups | 588 | ✅ |
| **V2** | v2_restaurants_ingredient_groups_items | 3,108 | ✅ |
| **V2** | v2_restaurants_ingredients | 2,681 | ✅ |
| **TOTAL** | **All Tables** | **380,655** | ✅ **COMPLETE** |

**Note:** `menuca_v2.courses` (1,269 rows) and `menuca_v2.menu` (95 rows) excluded as deprecated/not used in production.

---

## 🚨 SECTION 2: V1 DATA QUALITY ISSUES IDENTIFIED

### V1 Menu (Dishes) - 117,704 Total Records

| Issue Type | Count | % of Total | Action Required |
|------------|-------|------------|-----------------|
| **Dishes from test restaurants** | 24,323 | 20.7% | EXCLUDE ✅ |
| **Blank names** | 46 | 0.04% | EXCLUDE ✅ |
| **Hidden from menu (showInMenu='N')** | 8,173 | 6.9% | EXCLUDE ✅ |
| **Zero/empty price** | 0 | 0% | None |
| **EXPECTED CLEAN V1 DISHES** | **85,162** | **72.4%** | **MIGRATE** |

#### Test Restaurant Identification

- **Total V1 restaurants:** 1,183
- **Test/problematic restaurants identified:** 380 (32.1%)
  - 38 restaurants with "test"/"dummy"/"sample"/"demo" in dish names
  - 343 restaurants with >80% dishes hidden from menu (IDs 1095-1435 range)
  - These are clearly incomplete/abandoned restaurant setups

- **Problem restaurants in menuca_v3:** 37 (9.7%)
- **Problem restaurants NOT in menuca_v3:** 343 (90.3%) ✅ **Correctly excluded**

- **Clean V1 restaurants:** 803 (67.9%)

### V1 Other Tables

| Table | Total | Issues | Clean Records | Clean % |
|-------|-------|--------|---------------|---------|
| **v1_courses** | 12,924 | 0 blank names, 0 NULL restaurants | 12,924 | 100% ✅ |
| **v1_ingredients** | 52,305 | 18 NULL restaurant | 52,287 | 99.97% ✅ |
| **v1_ingredient_groups** | 13,255 | 2,052 blank names (15.5%) | 11,203 | 84.5% |
| **v1_combo_groups** | 62,353 | 53,304 blank names (85.5%) | 9,049 | 14.5% ⚠️ |

**Note:** Per migration docs, heavy duplication in V1 combo_groups is expected.

---

## 🚨 SECTION 3: V2 DATA QUALITY ISSUES IDENTIFIED

### V2 Restaurants Dishes - 10,289 Total Records

| Issue Type | Count | % of Total | Action |
|------------|-------|------------|--------|
| Blank names | 0 | 0% | None ✅ |
| NULL/Zero course_id | 1 | 0.01% | EXCLUDE |
| Orphaned (course_id not in v2_courses) | 49 | 0.48% | EXCLUDE |
| Disabled (enabled='n') | 378 | 3.67% | EXCLUDE |
| **EXPECTED CLEAN V2 DISHES** | **9,911** | **96.3%** | **MIGRATE** |

### V2 Restaurants Courses - 1,269 Total Records

| Issue Type | Count | % of Total | Action |
|------------|-------|------------|--------|
| Blank names | 0 | 0% | None ✅ |
| NULL/Zero restaurant_id | 0 | 0% | None ✅ |
| Disabled (enabled='n') | 20 | 1.6% | EXCLUDE |
| **EXPECTED CLEAN** | **1,249** | **98.4%** | **MIGRATE** |

### V2 Dish Customizations - 13,412 Total Records

| Issue Type | Count | % of Total | Action |
|------------|-------|------------|--------|
| NULL/Zero dish_id | 0 | 0% | None ✅ |
| Orphaned (dish_id not in v2_dishes) | 17 | 0.13% | EXCLUDE |
| Disabled (enabled='n') | 3,250 | 24.2% | EXCLUDE |
| **EXPECTED CLEAN** | **~10,145** | **75.6%** | **MIGRATE** |

---

## 🚨 SECTION 4: THE CRITICAL PROBLEM

### Expected vs Actual Dishes in menuca_v3

| Metric | Count | Notes |
|--------|-------|-------|
| **Expected clean V1 dishes** | 85,162 | After excluding test restaurants, blank names, hidden dishes |
| **Expected clean V2 dishes** | 9,911 | After excluding disabled dishes |
| **TOTAL EXPECTED** | **95,073** | Combined clean data |
| **ACTUAL in menuca_v3.dishes** | **42,930** | Current production count |
| **==> MISSING DISHES** | **52,143** | **54.8% DATA LOSS** 🚨 |

### Additional Critical Finding: NULL Source System

**ALL 42,930 dishes in menuca_v3 have `source_system = NULL`**

This indicates:
1. The `source_system` column was not populated during migration
2. Cannot trace which dishes came from V1 vs V2
3. Impossible to audit which specific source records made it to production
4. May indicate incomplete migration logic

---

## 🔍 SECTION 5: PROPOSED ROOT CAUSE ANALYSIS

### Hypothesis 1: Additional Hidden Filters (Most Likely)
The migration may have applied additional exclusion criteria not documented, such as:
- Excluding dishes with NULL `course_id` (16,072 V1 dishes)
- Excluding "side dishes" that are not shown in menu
- Excluding combo components
- Additional business rules not captured in analysis

### Hypothesis 2: Restaurant Mapping Issues
- V1 restaurant IDs may not have mapped to menuca_v3 restaurant IDs
- FK constraints may have prevented dish insertion if parent restaurant missing
- Need to verify: How many of the 85,162 "clean" V1 dishes belong to restaurants that ARE in menuca_v3?

### Hypothesis 3: Schema Mismatch (menu_v3 vs menuca_v3)
- Previous notes indicated data was loaded into `menu_v3` schema, not `menuca_v3`
- Need user clarification on which schema contains production data
- If data is still in `menu_v3`, this entire analysis is querying the wrong schema

### Hypothesis 4: Migration Incomplete
- Phase 4 (BLOB deserialization) was marked complete
- But perhaps the V3 staging → menuca_v3 migration was never fully executed
- Data may still be in `staging.*` or `menu_v3.*` tables

---

## 📋 SECTION 6: RECOMMENDED NEXT STEPS

### STOP: User Decision Required

Before proceeding, the user MUST clarify:

1. **Which schema contains the production menu data?**
   - `menu_v3` (as mentioned in deployment docs)?
   - `menuca_v3` (as assumed in current analysis)?
   - Both (data was copied)?

2. **Is the 54.8% data loss acceptable?**
   - Are the missing 52,143 dishes intentionally excluded?
   - Are they side dishes, combo components, or other non-displayable items?
   - Should they be migrated?

3. **Why is `source_system` NULL for all dishes?**
   - Was this column never populated?
   - Should it be populated for audit/traceability?

### If menuca_v3 is correct schema:

#### Immediate Analysis Tasks:
1. ✅ **Verify restaurant mapping**
   - Of the 85,162 clean V1 dishes, how many belong to restaurants IN menuca_v3?
   - This will tell us if FK constraints caused the data loss

2. ✅ **Identify the 42,930 dishes**
   - Query `menuca_v3.dishes` by restaurant_id
   - Cross-reference with staging tables to identify which source records made it
   - Identify exclusion pattern

3. ✅ **Check for NULL course_id handling**
   - 16,072 V1 dishes have NULL/zero `course_id`
   - These may have been intentionally excluded
   - Does menuca_v3.dishes require non-NULL course_id?

4. ✅ **Review migration scripts**
   - Check the actual SQL used to migrate staging → menuca_v3
   - Identify undocumented filters

#### Data Recovery Options:
1. **Option A:** Re-run migration with corrected filters
2. **Option B:** Backfill missing dishes from staging tables
3. **Option C:** Accept data loss if dishes are non-displayable components

### If menu_v3 is correct schema:

1. ✅ **Re-run entire analysis against `menu_v3` schema**
2. ✅ **Compare `menu_v3` vs `menuca_v3` row counts**
3. ✅ **Clarify migration status**

---

## 🎯 SECTION 7: SUCCESS CRITERIA (Not Met)

Current Status:
- [❌] All clean V1/V2 data accounted for → **54.8% missing**
- [✅] Test data properly identified → **380 test restaurants identified**
- [⚠️] Disabled/inactive records handled → **Applied, but may be over-aggressive**
- [❌] FK integrity maintained → **Cannot verify with NULL source_system**
- [⚠️] Data quality issues documented → **In progress**
- [❌] Migration filters documented → **Additional hidden filters suspected**

---

## 🛑 RECOMMENDATION

**STOP MIGRATION VALIDATION**

I am stopping the process as requested by the user. Critical issues have been identified:

1. 🚨 **52,143 dishes missing (54.8% data loss)**
2. 🚨 **All dishes have NULL `source_system` (no traceability)**
3. ❓ **Schema uncertainty (menu_v3 vs menuca_v3)**

**User must review and provide direction before proceeding.**

---

**Prepared by:** AI Migration Reviewer  
**Date:** January 7, 2025  
**Status:** 🛑 AWAITING USER REVIEW

