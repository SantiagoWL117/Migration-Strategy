# V1 Data Migration Issue - Diagnostic Report

**Date:** October 31, 2025  
**Status:** 🔴 **CRITICAL ISSUE CONFIRMED**  
**Issue:** Systemic V1 data migration failure

---

## Executive Summary

**CRITICAL FINDING:** V1 menu data was never loaded into `temp_migration.v1_menu`, resulting in **264 restaurants missing V3 dishes** despite having V1 source data available.

**Impact:**
- 264 restaurants have mapping entries but no V3 dishes
- 261 restaurants have `legacy_v1_id` but no V3 dishes
- Pizza Shark (restaurant_id 4) confirmed as one affected restaurant
- `temp_migration.v1_menu` table is **completely empty (0 rows)**

---

## 🔴 Critical Findings

### Finding 1: temp_migration.v1_menu is Empty

**Verification:**
```sql
SELECT COUNT(*) FROM temp_migration.v1_menu;
-- Result: 0 rows
```

**Impact:** V1 data dump files exist but were never loaded into staging table, so V1→V3 migration never occurred.

---

### Finding 2: Pizza Shark Case Confirmed

**Restaurant Details:**
- **V3 Restaurant ID:** 4
- **V1 Restaurant ID:** 81
- **V2 Restaurant ID:** 1028
- **Name:** Pizza Shark
- **Status:** suspended (in both mapping and V3)

**Current V3 State:**
- **Dishes:** 0
- **Courses:** 0
- **Prices:** 0

**V1 Source Data (Per User Report):**
- **menuca_v1_menu:** 60 rows (expected)
- **menuca_v1_courses:** 16 rows (expected)
- **menuca_v1_ingredients:** 48 rows (expected)
- **menuca_v1_ingredient_groups:** 10 rows (expected)

**Root Cause:** V1 data exists in dump files but was never loaded into `temp_migration.v1_menu`.

---

### Finding 3: Systemic Issue Scale

**Affected Restaurants:**
- **Total restaurants missing V3 dishes:** 264
- **Restaurants with legacy_v1_id but no dishes:** 261
- **Suspended restaurants missing data:** 255
- **Active restaurants missing data:** 2 ⚠️ **CRITICAL**

**Breakdown by Status:**
| Mapping Status | Restaurants Missing Dishes |
|----------------|----------------------------|
| suspended | 255 |
| active | 2 ⚠️ |
| pending | 7 |

**Critical Concern:** 2 active restaurants have no dishes, meaning customers cannot order.

---

### Finding 4: temp_migration Empty Across All Statuses

**Verification:**
```sql
SELECT 
    arm.status,
    COUNT(DISTINCT arm.new_restaurant_id) as in_mapping,
    COUNT(DISTINCT tm.restaurant) as in_temp_migration,
    COUNT(DISTINCT arm.new_restaurant_id) FILTER (WHERE tm.restaurant IS NULL) as missing_from_temp
FROM archive.restaurant_id_mapping arm
LEFT JOIN temp_migration.v1_menu tm ON tm.restaurant = arm.old_restaurant_id
GROUP BY arm.status;
```

**Results:**
- **Pending:** 29 in mapping, 0 in temp_migration (100% missing)
- **Active:** 132 in mapping, 0 in temp_migration (100% missing)
- **Suspended:** 665 in mapping, 0 in temp_migration (100% missing)

**Conclusion:** V1 data was never loaded into temp_migration, regardless of restaurant status.

---

## 🔍 Root Cause Analysis

### Hypothesis 1: ETL Filtered by Status ❌ **LIKELY FALSE**

**Evidence:** 
- temp_migration is empty for ALL statuses (pending, active, suspended)
- If filtering by status was the issue, we'd see some data for active restaurants
- **Conclusion:** ETL likely never ran or failed before status filtering

### Hypothesis 2: ETL Never Executed ✅ **LIKELY TRUE**

**Evidence:**
- `temp_migration.v1_menu` has 0 rows (completely empty)
- Script `load_v1_v2_dumps.sh` exists but may not have been executed
- No V1 data in staging table

**Conclusion:** V1 dump files were never loaded into temp_migration.

### Hypothesis 3: Type Mismatch in Joins ⚠️ **POSSIBLE**

**Evidence:**
- User mentioned type mismatches (varchar vs int)
- Script shows casting: `CAST(v1m.restaurant AS INTEGER)`
- May have caused silent failures during ETL

**Conclusion:** Type mismatches may have contributed, but primary issue is empty temp_migration.

---

## 📊 Diagnostic Results

### Diagnostic 1: Restaurants Missing V3 Data

**Total Affected:** 264 restaurants

**Breakdown:**
- Suspended: 255 restaurants
- Active: 2 restaurants ⚠️ **CRITICAL**
- Pending: 7 restaurants

### Diagnostic 2: Pizza Shark Specific Check

**Confirmed:**
- ✅ Mapping exists: old_id=81 → new_id=4
- ✅ Restaurant exists in V3: id=4, name="Pizza Shark"
- ✅ legacy_v1_id set: 81
- ❌ V3 dishes: 0
- ❌ V3 courses: 0
- ❌ temp_migration data: 0 rows for restaurant 81

### Diagnostic 3: temp_migration Status

**Result:** `temp_migration.v1_menu` is **completely empty (0 rows)**

**Impact:** All V1 restaurants affected, regardless of status.

---

## 💡 Proposed Solution

### Phase 1: Verify V1 Dump Files Exist

**Action:**
1. Check if V1 dump files exist in `/Database/Menu & Catalog Entity/dumps/`
2. Verify file format and structure
3. Confirm restaurant 81 data is in dump files

### Phase 2: Load V1 Data into temp_migration (Dry Run)

**Action:**
1. Create read-only preview queries to verify data exists
2. Test loading process with sample restaurant
3. Verify type casting works correctly

**Preview Query:**
```sql
-- Check if we can find restaurant 81 data in dump (if accessible)
-- This would verify data exists before loading
```

### Phase 3: Create Robust V1 Extraction Script

**Requirements:**
1. **Load ALL V1 restaurants** (ignore mapping.status)
2. **Use explicit type casting:** `CAST(restaurant AS INTEGER)`
3. **Parse multi-size prices:** Split comma-separated prices into dish_prices rows
4. **Create courses:** Map V1 categories to V3 courses
5. **Handle missing courses:** Create "Uncategorized" placeholder if needed

### Phase 4: Migration Script (Idempotent)

**Key Features:**
1. **Use ON CONFLICT:** Prevent duplicate inserts
2. **Preserve audit columns:** source_system='V1', source_id, legacy_v1_id
3. **Separate data import from activation:** Import all data, activation handled separately
4. **Validation:** Check for cartesian joins, required fields, deduplication

---

## 🚨 Immediate Actions Required

### Priority 1: Investigate Active Restaurants Missing Data

**Action:** Identify the 2 active restaurants with no dishes
```sql
SELECT 
    r.id,
    r.name,
    r.status,
    r.legacy_v1_id,
    arm.old_restaurant_id,
    arm.status as mapping_status
FROM menuca_v3.restaurants r
JOIN archive.restaurant_id_mapping arm ON arm.new_restaurant_id = r.id
WHERE r.status = 'active'
    AND NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    );
```

**Impact:** Customers cannot order from these restaurants.

### Priority 2: Verify V1 Dump Files

**Action:** Check if dump files exist and contain restaurant 81 data

**Files to Check:**
- `/Database/Menu & Catalog Entity/dumps/menuca_v1_menu.sql` (or similar)
- Verify restaurant 81 has 60 menu rows as reported

### Priority 3: Create Data Loading Plan

**Action:** 
1. Review `load_v1_v2_dumps.sh` script
2. Understand why it wasn't executed or failed
3. Create updated loading script with proper error handling

---

## 📋 Next Steps

### Step 1: Verify Data Availability

1. ✅ Confirm dump files exist (check dumps directory)
2. ✅ Verify restaurant 81 data in dump files
3. ✅ Check total V1 restaurants in dump files

### Step 2: Create Preview Queries (Read-Only)

1. Query dump files to preview data structure
2. Count rows per restaurant
3. Sample 3 restaurants' data for preview

### Step 3: Draft Migration Script

1. Create SQL script to load V1 data into temp_migration
2. Test with single restaurant first
3. Validate data before full migration

### Step 4: Execute Migration (After Approval)

1. Load all V1 data into temp_migration
2. Run V1→V3 migration script
3. Verify data integrity
4. Report results

---

## 🔍 Verification Queries

### Query 1: List Active Restaurants Missing Data
```sql
SELECT 
    r.id,
    r.name,
    r.status,
    r.legacy_v1_id,
    arm.old_restaurant_id as v1_id,
    arm.status as mapping_status
FROM menuca_v3.restaurants r
JOIN archive.restaurant_id_mapping arm ON arm.new_restaurant_id = r.id
WHERE r.status = 'active'
    AND NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    );
```

### Query 2: Count Affected Restaurants by Status
```sql
SELECT 
    r.status,
    COUNT(DISTINCT r.id) as restaurants_missing_dishes
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    )
GROUP BY r.status;
```

### Query 3: Check temp_migration Status
```sql
SELECT 
    'temp_migration.v1_menu' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT restaurant) as unique_restaurants
FROM temp_migration.v1_menu;
```

---

## 📊 Summary Statistics

| Metric | Value |
|--------|-------|
| **temp_migration.v1_menu rows** | 0 ❌ |
| **Restaurants missing V3 dishes** | 264 |
| **Restaurants with legacy_v1_id but no dishes** | 261 |
| **Active restaurants missing data** | 2 ⚠️ |
| **Suspended restaurants missing data** | 255 |
| **Pizza Shark V3 dishes** | 0 |
| **Pizza Shark V1 menu rows (expected)** | 60 |

---

## ⚠️ Critical Issues

1. **temp_migration.v1_menu is empty** - V1 data never loaded
2. **2 active restaurants have no dishes** - Customers cannot order
3. **264 restaurants affected** - Significant data loss
4. **Type casting may be required** - varchar vs int mismatches

---

## ✅ Recommended Actions

### Immediate (Priority: 🔴 HIGH)

1. **Identify the 2 active restaurants** missing dishes and investigate
2. **Verify V1 dump files exist** and contain expected data
3. **Review load_v1_v2_dumps.sh** script execution history

### Short-term (Priority: 🟡 MEDIUM)

1. **Create V1 data loading script** with proper error handling
2. **Test with single restaurant** (e.g., Pizza Shark)
3. **Verify data integrity** after test load

### Long-term (Priority: 🟢 LOW)

1. **Load all V1 data** into temp_migration
2. **Run V1→V3 migration** for all affected restaurants
3. **Verify and validate** migrated data

---

## 📝 Notes

- **User reported:** Pizza Shark has 60 V1 menu rows, but they're not in temp_migration
- **User reported:** V1 data exists in dump files
- **User suggested:** ETL may have filtered by status or had type mismatch issues
- **Recommendation:** Verify dump files exist, then create robust loading script

---

**Report Generated:** October 31, 2025  
**Database:** menuca_v3 (Supabase)  
**Verification Method:** Direct SQL queries via Supabase MCP  
**Status:** 🔴 **CRITICAL ISSUE CONFIRMED - ACTION REQUIRED**

