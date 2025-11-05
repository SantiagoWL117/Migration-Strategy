# V1 Data Migration Issue - Summary & Action Plan

**Date:** October 31, 2025  
**Status:** 🔴 **CRITICAL ISSUE CONFIRMED**  
**Severity:** HIGH - 264 restaurants affected

---

## 🚨 Critical Finding

**ISSUE CONFIRMED:** V1 menu data was **never loaded** into `temp_migration.v1_menu`, resulting in 264 restaurants missing V3 dishes despite having V1 source data.

**Root Cause:** The `load_v1_v2_dumps.sh` script exists but appears to have never been executed, or failed silently.

---

## 📊 Issue Scale

| Metric | Value |
|--------|-------|
| **temp_migration.v1_menu rows** | 0 ❌ (should have V1 data) |
| **Restaurants missing V3 dishes** | 264 |
| **Restaurants with legacy_v1_id but no dishes** | 261 |
| **Mapping status = "active" missing dishes** | 2 |
| **Mapping status = "suspended" missing dishes** | 255 |
| **Mapping status = "pending" missing dishes** | 7 |

---

## 🔍 Verification Results

### ✅ Confirmed: Pizza Shark Case

- **V3 Restaurant ID:** 4
- **V1 Restaurant ID:** 81  
- **Status:** suspended
- **Current V3 State:** 0 dishes, 0 courses, 0 prices
- **Expected V1 Data:** 60 menu rows (per user report)
- **temp_migration.v1_menu:** 0 rows for restaurant 81 ❌

### ✅ Confirmed: temp_migration is Empty

```sql
SELECT COUNT(*) FROM temp_migration.v1_menu;
-- Result: 0 rows
```

**Impact:** All V1 restaurants affected, regardless of status (pending, active, suspended).

### ✅ Confirmed: Active Restaurants Affected

**Restaurants with mapping status = "active" but missing dishes:** 2

**Note:** These may be suspended in V3 (status mismatch between mapping and V3), but mapping shows them as "active" which suggests they should have data.

---

## 🎯 Root Cause Analysis

### Primary Issue: V1 Data Never Loaded

**Evidence:**
1. `temp_migration.v1_menu` has 0 rows
2. Script `load_v1_v2_dumps.sh` exists but appears unused
3. Dumps directory exists but may be empty or files not accessible

**Possible Reasons:**
1. **Script never executed** - Dump files never loaded
2. **Script failed silently** - Errors not caught
3. **Dump files missing** - Files don't exist or wrong location
4. **Type mismatch** - Silent failures due to varchar/int issues

---

## 💡 Proposed Solution

### Phase 1: Verify Data Availability (READ-ONLY)

**Action Items:**

1. **Check if dump files exist:**
   - Location: `/Database/Menu & Catalog Entity/dumps/`
   - Files needed: `menuca_v1_menu.sql` (or similar)
   - Verify restaurant 81 data exists in files

2. **If files exist, create preview query:**
   ```sql
   -- Preview: Count restaurants in dump file
   -- Preview: Sample restaurant 81 data
   -- Preview: Check data structure
   ```

3. **If files don't exist:**
   - Determine where V1 source data is stored
   - May need to export from original V1 database
   - Or obtain dump files from backup

### Phase 2: Create Robust V1 Loading Script

**Requirements:**

1. **Load ALL V1 restaurants** (ignore mapping.status)
   - Don't filter by status during data import
   - Import all data, handle activation separately

2. **Use explicit type casting:**
   ```sql
   -- Join using: CAST(v1.restaurant AS INTEGER) = old_restaurant_id
   -- Prevent silent failures from type mismatches
   ```

3. **Handle multi-size prices:**
   - Parse comma-separated prices: "11.86,16.06,20.26"
   - Create multiple dish_prices rows per dish
   - Map sizes appropriately

4. **Create courses:**
   - Map V1 categories to V3 courses
   - Create "Uncategorized" placeholder if course missing
   - Preserve display_order

5. **Error handling:**
   - Log errors to error table
   - Continue processing on non-fatal errors
   - Report summary at end

### Phase 3: Create V1→V3 Migration Script

**Key Features:**

1. **Idempotent design:**
   ```sql
   INSERT INTO menuca_v3.dishes (...)
   SELECT ... FROM temp_migration.v1_menu
   ON CONFLICT (restaurant_id, name, legacy_v1_id) DO UPDATE ...
   ```

2. **Preserve audit trail:**
   - Set `source_system = 'V1'`
   - Set `source_id = v1_menu.id`
   - Set `legacy_v1_id = v1_menu.id`
   - Set `created_at = NOW()`

3. **Handle pricing:**
   - Parse multi-size prices into dish_prices table
   - Create one price row per size variant
   - Use proper size_variant codes

4. **Validation:**
   - Check for cartesian joins
   - Verify required fields present
   - Deduplicate by (restaurant_id, name, course_id)

### Phase 4: Test & Execute

**Testing Strategy:**

1. **Dry-run with Pizza Shark (restaurant 81):**
   - Load V1 data for restaurant 81 only
   - Preview what would be created
   - Verify data quality

2. **Test migration:**
   - Run migration for restaurant 81
   - Verify courses, dishes, prices created
   - Check data integrity

3. **Full migration:**
   - Load all V1 data into temp_migration
   - Run migration for all affected restaurants
   - Verify results

---

## 🚨 Immediate Actions Required

### Priority 1: Identify Critical Active Restaurants

**Action:** Query to find restaurants that are active in V3 but missing dishes:
```sql
SELECT 
    r.id,
    r.name,
    r.status,
    r.legacy_v1_id,
    arm.old_restaurant_id,
    arm.status as mapping_status
FROM menuca_v3.restaurants r
LEFT JOIN archive.restaurant_id_mapping arm ON arm.new_restaurant_id = r.id
WHERE r.status = 'active'
    AND r.deleted_at IS NULL
    AND NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    );
```

**Impact:** These restaurants cannot serve customers.

### Priority 2: Locate V1 Dump Files

**Action:**
1. Check `/Database/Menu & Catalog Entity/dumps/` directory
2. Verify dump files exist and contain expected data
3. Check file format (SQL, CSV, etc.)

**Files Expected:**
- `menuca_v1_menu.sql` (or similar)
- `menuca_v1_courses.sql` (or similar)
- Other V1 tables as needed

### Priority 3: Create Data Loading Plan

**Action:**
1. Review `load_v1_v2_dumps.sh` script
2. Understand why it wasn't executed
3. Create updated script with proper error handling
4. Test with single restaurant first

---

## 📋 Recommended Next Steps

### Step 1: Data Discovery (READ-ONLY)

1. ✅ **Verify dump files exist** (check dumps directory)
2. ✅ **If files exist:** Create preview queries to inspect data
3. ✅ **If files don't exist:** Identify where V1 source data is stored

### Step 2: Create Loading Script

1. **Load V1 data into temp_migration:**
   - Use proper type casting
   - Handle all restaurants (ignore status)
   - Add error logging

2. **Test with Pizza Shark:**
   - Load restaurant 81 data only
   - Verify data quality
   - Check for issues

### Step 3: Create Migration Script

1. **V1→V3 migration:**
   - Create courses from V1 categories
   - Create dishes from V1 menu
   - Create prices from V1 pricing (handle multi-size)
   - Preserve audit columns

2. **Test migration:**
   - Run for restaurant 81
   - Verify results
   - Check data integrity

### Step 4: Full Migration (After Approval)

1. **Load all V1 data**
2. **Run migration for all 264 restaurants**
3. **Verify and validate results**
4. **Generate completion report**

---

## 🔍 Diagnostic Queries for Further Investigation

### Query 1: Count Restaurants by Legacy ID Status
```sql
SELECT 
    CASE 
        WHEN r.legacy_v1_id IS NOT NULL THEN 'Has V1 ID'
        WHEN r.legacy_v2_id IS NOT NULL THEN 'Has V2 ID Only'
        ELSE 'No Legacy ID'
    END as legacy_status,
    COUNT(*) as restaurant_count,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    )) as missing_dishes
FROM menuca_v3.restaurants r
WHERE r.deleted_at IS NULL
GROUP BY legacy_status;
```

### Query 2: Check temp_migration Coverage
```sql
SELECT 
    COUNT(DISTINCT arm.old_restaurant_id) as v1_restaurants_in_mapping,
    COUNT(DISTINCT tm.restaurant) as v1_restaurants_in_temp_migration,
    COUNT(DISTINCT arm.old_restaurant_id) FILTER (WHERE tm.restaurant IS NULL) as missing_from_temp
FROM archive.restaurant_id_mapping arm
LEFT JOIN temp_migration.v1_menu tm ON tm.restaurant = arm.old_restaurant_id;
```

### Query 3: Sample Affected Restaurants
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
WHERE r.legacy_v1_id IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM menuca_v3.dishes d 
        WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL
    )
ORDER BY r.name
LIMIT 10;
```

---

## ⚠️ Critical Issues Summary

1. **temp_migration.v1_menu is empty** - V1 data never loaded ❌
2. **264 restaurants missing dishes** - Significant data loss ❌
3. **2 active restaurants affected** - Customer impact ⚠️
4. **Type casting may be required** - varchar vs int mismatches ⚠️
5. **Dump files location unknown** - Need to verify accessibility ⚠️

---

## ✅ Recommended Immediate Actions

### For User:

1. **Verify V1 dump files exist:**
   - Check if files are in dumps directory
   - Or provide location of V1 source data
   - Confirm restaurant 81 data is available

2. **Decide on migration approach:**
   - Should we load ALL V1 restaurants?
   - Or only specific restaurants?
   - Should we ignore mapping.status?

3. **Approve migration plan:**
   - Review proposed solution
   - Approve test with Pizza Shark
   - Approve full migration if test succeeds

### For Developer:

1. **Create data loading script** (once dump files confirmed)
2. **Create V1→V3 migration script** (idempotent, tested)
3. **Test with Pizza Shark** before full migration
4. **Generate verification report** after migration

---

**Report Generated:** October 31, 2025  
**Database:** menuca_v3 (Supabase)  
**Verification Method:** Direct SQL queries via Supabase MCP  
**Status:** 🔴 **CRITICAL ISSUE - ACTION REQUIRED**

