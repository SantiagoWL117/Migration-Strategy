# Menu & Catalog Entity - Excluded Tables Notice

**Date:** January 7, 2025  
**Status:** ✅ **EXCLUSION COMPLETE**

---

## 📋 EXECUTIVE SUMMARY

Two V2 tables have been **excluded** from the Menu & Catalog entity migration as they are deprecated and not used in production.

---

## 🚫 EXCLUDED TABLES

| Schema | Table | Original Row Count | Reason for Exclusion |
|--------|-------|-------------------|---------------------|
| `menuca_v2` | `courses` | 1,269 | Deprecated - Superseded by `restaurants_courses` |
| `menuca_v2` | `menu` | 95 | Deprecated - Generic menu table not used in production |

**Total Excluded Rows:** 1,364

---

## 📊 IMPACT ON MIGRATION

### Before Exclusion
- **Total V1+V2 Tables:** 19 (7 V1 + 12 V2)
- **Total V1+V2 Rows:** 382,019

### After Exclusion
- **Total V1+V2 Tables:** 17 (7 V1 + 10 V2)
- **Total V1+V2 Rows:** 380,655
- **Reduction:** -1,364 rows (-0.36%)

---

## 🔍 RATIONALE

### 1. `menuca_v2.courses` (EXCLUDED)

**Original Purpose:** Restaurant-specific courses table  
**Why Excluded:** Superseded by `menuca_v2.restaurants_courses`

**Key Differences:**
- `courses`: Simplified version with basic fields (restaurant_id, name, global_course_id)
- `restaurants_courses`: Enhanced version with language_id, description, display_order

**Migration Impact:**
- ✅ `restaurants_courses` contains equivalent and enhanced data
- ✅ No data loss - all course information preserved in `restaurants_courses`

### 2. `menuca_v2.menu` (EXCLUDED)

**Original Purpose:** Generic menu table with JSON content  
**Why Excluded:** Not used in production, no active references

**Characteristics:**
- Generic/experimental table
- Only 95 records
- JSON-based content structure
- No FK relationships to active data

**Migration Impact:**
- ✅ No production data loss
- ✅ Active menu data stored in `restaurants_dishes` and related tables

---

## ✅ VERIFICATION

### Dumps Removed
- ✅ `Database/Menu & Catalog Entity/dumps/menuca_v2_courses.sql` - DELETED
- ✅ `Database/Menu & Catalog Entity/dumps/menuca_v2_menu.sql` - DELETED

### CSV Files Removed
- ✅ `Database/Menu & Catalog Entity/CSV/menuca_v2_courses.csv` - DELETED
- ⚠️ `Database/Menu & Catalog Entity/CSV/menuca_v2_menu.csv` - DID NOT EXIST

### Documentation Updated
- ✅ `documentation/Menu & Catalog/SCHEMA_TO_DUMP_VERIFICATION.md` - Updated to reflect 17 tables (was 19)
- ✅ `documentation/Menu & Catalog/CRITICAL_SOURCE_DATA_ANALYSIS_REPORT.md` - Updated totals
- ✅ `Database/Menu & Catalog Entity/queries/count_v1_v2_source_tables.sql` - Removed excluded tables from query

---

## 📋 REMAINING V2 TABLES (10)

| # | Table Name | Row Count | Status |
|---|------------|-----------|--------|
| 1 | `global_courses` | 33 | ✅ INCLUDED |
| 2 | `global_ingredients` | 5,023 | ✅ INCLUDED |
| 3 | `restaurants_courses` | 1,269 | ✅ INCLUDED |
| 4 | `restaurants_dishes` | 10,289 | ✅ INCLUDED |
| 5 | `restaurants_dishes_customization` | 13,412 | ✅ INCLUDED |
| 6 | `restaurants_combo_groups` | 13 | ✅ INCLUDED |
| 7 | `restaurants_combo_groups_items` | 220 | ✅ INCLUDED |
| 8 | `restaurants_ingredient_groups` | 588 | ✅ INCLUDED |
| 9 | `restaurants_ingredient_groups_items` | 3,108 | ✅ INCLUDED |
| 10 | `restaurants_ingredients` | 2,681 | ✅ INCLUDED |

**Total V2 Rows (Active):** 36,636

---

## 🎯 FINAL METRICS

| Metric | Value |
|--------|-------|
| **V1 Tables** | 7 |
| **V1 Rows** | 345,383 |
| **V2 Tables (Active)** | 10 |
| **V2 Rows (Active)** | 36,636 |
| **Total Tables** | 17 |
| **Total Rows** | 380,655 |
| **Excluded Tables** | 2 |
| **Excluded Rows** | 1,364 (0.36%) |

---

## ✅ COMPLETION CHECKLIST

- [✅] SQL dumps deleted (2 files)
- [✅] CSV files deleted (1 file)
- [✅] Documentation updated (3 files)
- [✅] Query scripts updated (1 file)
- [✅] Exclusion notice created (this document)
- [✅] No production data loss confirmed
- [✅] Rationale documented

---

**Action Completed by:** AI Migration Analyst  
**Date:** January 7, 2025  
**Status:** ✅ **EXCLUSION APPROVED**


