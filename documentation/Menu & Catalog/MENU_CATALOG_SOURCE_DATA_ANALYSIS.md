# Menu & Catalog Entity - Source Data Analysis
**Date:** January 7, 2025  
**Status:** 🔍 **IN PROGRESS**  
**Goal:** Verify all V1/V2 source data integrity before comparing to menuca_v3

---

## 📊 SECTION 1: SOURCE DATA ROW COUNTS

### V1 Tables (Staging)
| Table | Rows Loaded | Status |
|-------|-------------|--------|
| **v1_courses** | 12,924 | ✅ Loaded |
| **v1_menu** | 117,704 | ✅ Loaded |
| **v1_menuothers** | 70,381 | ✅ Loaded |
| **v1_ingredients** | 52,305 | ✅ Loaded |
| **v1_ingredient_groups** | 13,255 | ✅ Loaded |
| **v1_combo_groups** | 62,353 | ✅ Loaded |
| **v1_combos** | 16,461 | ✅ Loaded |
| **TOTAL V1** | **345,383** | ✅ |

### V2 Tables (Staging)
| Table | Rows Loaded | Status |
|-------|-------------|--------|
| **v2_global_courses** | 33 | ✅ Loaded |
| **v2_global_ingredients** | 5,023 | ✅ Loaded |
| **v2_restaurants_courses** | 1,269 | ✅ Loaded |
| **v2_restaurants_dishes** | 10,289 | ✅ Loaded |
| **v2_restaurants_dishes_customization** | 13,412 | ✅ Loaded |
| **v2_restaurants_combo_groups** | 13 | ✅ Loaded |
| **v2_restaurants_combo_groups_items** | 220 | ✅ Loaded |
| **v2_restaurants_ingredient_groups** | 588 | ✅ Loaded |
| **v2_restaurants_ingredient_groups_items** | 3,108 | ✅ Loaded |
| **v2_restaurants_ingredients** | 2,681 | ✅ Loaded |
| **TOTAL V2** | **36,636** | ✅ |

**TOTAL SOURCE DATA: 382,019 rows**

---

## 🚨 SECTION 2: V1 DATA QUALITY ISSUES

### V1 Menu (Dishes) - 117,704 Total Records

| Issue Type | Count | % of Total | Severity | Action |
|------------|-------|------------|----------|--------|
| **Blank Names** | **15,391** | **13.1%** | 🔴 HIGH | EXCLUDE |
| **Hidden from Menu (N)** | **25,296** | **21.5%** | 🟡 MEDIUM | EXCLUDE or keep as inactive |
| **NULL/Zero Course** | **16,072** | **13.7%** | 🟡 MEDIUM | ACCEPTABLE (uncategorized) |
| **Empty/Zero Price** | **15,400** | **13.1%** | 🟡 MEDIUM | Mark inactive or fix |
| **NULL/Zero Restaurant** | **47** | **0.0%** | 🔴 HIGH | EXCLUDE |

**Clean Records Estimate:** ~70,000 (59.5% of total)

### V1 Courses - 12,924 Total Records

| Issue Type | Count | % of Total | Severity | Action |
|------------|-------|------------|----------|--------|
| Blank Names | 0 | 0.0% | ✅ PERFECT | None |
| NULL/Zero Restaurant | 0 | 0.0% | ✅ PERFECT | None |

**Clean Records:** 12,924 (100%)

### V1 Ingredients - 52,305 Total Records

| Issue Type | Count | % of Total | Severity | Action |
|------------|-------|------------|----------|--------|
| Blank/Invalid Names | 0 | 0.0% | ✅ PERFECT | None |
| NULL/Zero Restaurant | 18 | 0.0% | 🟡 LOW | EXCLUDE |

**Clean Records:** 52,287 (99.97%)

### V1 Ingredient Groups - 13,255 Total Records

| Issue Type | Count | % of Total | Severity | Action |
|------------|-------|------------|----------|--------|
| **Blank Names** | **2,052** | **15.5%** | 🟡 MEDIUM | EXCLUDE or investigate |

**Clean Records:** 11,203 (84.5%)

### V1 Combo Groups - 62,353 Total Records

| Issue Type | Count | % of Total | Severity | Action |
|------------|-------|------------|----------|--------|
| **Blank Names** | **53,304** | **85.5%** | 🔴 CRITICAL | EXCLUDE (likely duplicates) |

**Clean Records:** 9,049 (14.5%)

**📋 Note:** The docs mention this is expected due to heavy duplication in V1 combo data.

---

## 🚨 SECTION 3: V2 DATA QUALITY ISSUES

### V2 Restaurants Dishes - 10,289 Total Records

| Issue Type | Count | % of Total | Severity | Status |
|------------|-------|------------|----------|--------|
| Blank Names | ? | TBD | 🔴 HIGH | **NEEDS CHECK** |
| Disabled (enabled=n) | ? | TBD | 🟡 MEDIUM | **NEEDS CHECK** |
| NULL/Zero Course ID | ? | TBD | 🔴 HIGH | **NEEDS CHECK** |

### V2 Restaurants Courses - 1,269 Total Records

| Issue Type | Count | % of Total | Severity | Status |
|------------|-------|------------|----------|--------|
| Blank Names | ? | TBD | 🔴 HIGH | **NEEDS CHECK** |
| Disabled (enabled=n) | ? | TBD | 🟡 MEDIUM | **NEEDS CHECK** |
| NULL Restaurant ID | ? | TBD | 🔴 HIGH | **NEEDS CHECK** |

### V2 Dish Customizations - 13,412 Total Records

| Issue Type | Count | % of Total | Severity | Status |
|------------|-------|------------|----------|--------|
| NULL Dish ID | ? | TBD | 🔴 HIGH | **NEEDS CHECK** |

---

## 📊 SECTION 4: EXPECTED CLEAN DATA COUNTS

Based on data quality issues identified:

| Source Table | Total | Quality Issues | Expected Clean | Clean % |
|--------------|-------|----------------|----------------|---------|
| **v1_menu** | 117,704 | ~47,000 | **~70,000** | 59.5% |
| **v1_courses** | 12,924 | 0 | **12,924** | 100% |
| **v1_ingredients** | 52,305 | 18 | **52,287** | 99.97% |
| **v1_ingredient_groups** | 13,255 | 2,052 | **11,203** | 84.5% |
| **v1_combo_groups** | 62,353 | 53,304 | **9,049** | 14.5% |
| **v1_combos** | 16,461 | TBD | **TBD** | TBD |
| **v2_restaurants_dishes** | 10,289 | TBD | **~10,000?** | ~97%? |
| **v2_restaurants_courses** | 1,269 | TBD | **~1,200?** | ~95%? |
| **v2_dish_customizations** | 13,412 | TBD | **~13,000?** | ~97%? |

---

## 🔍 SECTION 5: DATA LOSS ANALYSIS

### Current menuca_v3 vs Expected Clean Data

| Table | menuca_v3 | Expected Clean | Difference | Status |
|-------|-----------|----------------|------------|--------|
| **courses** | 12,194 | ~14,100 | **-1,906** | ⚠️ Some missing |
| **dishes** | 42,930 | ~80,000 | **-37,070** | 🚨 **MAJOR LOSS** |
| **ingredients** | 45,176 | ~52,287 | **-7,111** | ⚠️ Some missing |
| **ingredient_groups** | 9,572 | ~11,200 | **-1,628** | ⚠️ Some missing |
| **combo_groups** | 8,341 | ~9,049 | **-708** | ⚠️ Some missing |
| **dish_customizations** | 310 | ~13,000 | **-12,690** | 🚨 **CRITICAL LOSS** |

---

## ⚠️ SECTION 6: CRITICAL FINDINGS

### 🔴 CRITICAL ISSUE #1: Massive Dish Loss
- **Expected clean dishes:** ~80,000 (V1: 70k + V2: 10k)
- **Current menuca_v3:** 42,930
- **Missing:** ~37,070 dishes (46% data loss)

**Possible Causes:**
1. Additional exclusion filters applied during migration
2. Test restaurants filtered out
3. Inactive/disabled records excluded
4. Migration incomplete

### 🔴 CRITICAL ISSUE #2: Dish Customizations Loss
- **Expected:** ~13,000 (V2 source)
- **Current:** 310
- **Missing:** ~12,690 (97.6% data loss)

**Possible Causes:**
1. FK constraints failing (dishes not in menuca_v3)
2. Only V2 customizations migrated (V1 extraction pending per docs)
3. Orphaned records filtered out

### 🟡 ISSUE #3: V1 Combo Groups Heavy Duplication
- **85.5% have blank names** (53,304 out of 62,353)
- **Docs confirm this is expected:** Heavy duplication in V1
- Current menuca_v3 has 8,341 combo_groups (close to expected ~9,049)

---

## 📋 SECTION 7: NEXT STEPS

### Immediate Actions Needed:

1. ✅ **Complete V2 data quality analysis** (pending)
   - Check for blank names, disabled records, NULL FKs
   
2. ✅ **Identify test restaurants** 
   - Determine which restaurants are test data
   - Check if test data was intentionally excluded
   
3. ✅ **Analyze the 37,070 missing dishes**
   - Are they test data? (acceptable loss)
   - Are they inactive? (acceptable loss)
   - Are they valid production data? (🚨 unacceptable loss)
   
4. ✅ **Investigate dish customizations**
   - Why only 310 out of 13,000?
   - Are parent dishes missing?
   - Check FK integrity
   
5. ✅ **Compare staging vs menuca_v3**
   - Run direct comparison queries
   - Identify what was filtered out and why

---

## 🎯 SUCCESS CRITERIA

Before declaring migration complete, verify:

- [ ] All clean V1/V2 data accounted for (no unintentional loss)
- [ ] Test data properly identified and excluded
- [ ] Disabled/inactive records handled appropriately  
- [ ] FK integrity maintained (no orphaned records)
- [ ] Data quality issues documented with rationale
- [ ] Migration filters documented and justified

---

**Status:** 🔄 Analysis in progress - Need to complete V2 checks and comparison with menuca_v3


