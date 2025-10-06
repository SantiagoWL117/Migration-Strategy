# Supabase CSV Import Guide - Service Configuration & Schedules

**Date**: October 6, 2025  
**Purpose**: Step-by-step instructions for importing CSV data into staging tables via Supabase.com

---

## Prerequisites

✅ **Step 1**: Run `create_staging_tables.sql` in Supabase SQL Editor  
- This creates all 7 staging tables with exact column names matching CSV files
- Verify tables exist in `staging` schema

✅ **Step 2**: Ensure all CSV files are ready  
- Location: `Database/Service Configuration & Schedules/CSV/`
- Total files: 7
- Total rows: 9,898

---

## Import Process

### General Steps for Each Table

1. **Navigate to Supabase Dashboard**
   - URL: https://supabase.com/dashboard/project/[your-project-id]
   - Go to: **Table Editor** (left sidebar)

2. **Select Schema**
   - Click schema dropdown (top left)
   - Select: **`staging`**

3. **Open Target Table**
   - Find and click the table name from the list below

4. **Import CSV**
   - Click **"Insert"** button → **"Import data from CSV"**
   - Click **"Browse..."** and select the corresponding CSV file
   - **Verify column mapping** (should auto-map by name)
   - **IMPORTANT**: Check the preview - first row should be data, not headers
   - Click **"Import"**

5. **Verify Import**
   - Check row count matches expected count
   - Spot-check a few rows for data accuracy

---

## Import Order & Details

### 1️⃣ V1 Regular Schedules

**Table**: `staging.v1_restaurants_schedule_normalized`  
**CSV File**: `menuca_v1_restaurants_schedule_normalized.csv`  
**Expected Rows**: **6,341**

**Columns to verify**:
- `id`, `restaurant_id`, `day_start`, `time_start`, `day_stop`, `time_stop`, `type`, `enabled`, `created_at`, `updated_at`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v1_restaurants_schedule_normalized;
-- Expected: 6,341
```

---

### 2️⃣ V1 Special Schedules

**Table**: `staging.v1_restaurants_special_schedule`  
**CSV File**: `menuca_v1_restaurants_special_schedule.csv`  
**Expected Rows**: **5**

**Columns to verify**:
- `id`, `restaurant_id`, `special_date`, `time_start`, `time_stop`, `enabled`, `note`, `created_at`, `updated_at`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v1_restaurants_special_schedule;
-- Expected: 5
```

---

### 3️⃣ V2 Regular Schedules

**Table**: `staging.v2_restaurants_schedule`  
**CSV File**: `menuca_v2_restaurants_schedule.csv`  
**Expected Rows**: **1,984**

**Columns to verify**:
- `id`, `restaurant_id`, `day_start`, `time_start`, `day_stop`, `time_stop`, `type`, `enabled`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v2_restaurants_schedule;
-- Expected: 1,984
```

---

### 4️⃣ V2 Special Schedules

**Table**: `staging.v2_restaurants_special_schedule`  
**CSV File**: `menuca_v2_restaurants_special_schedule.csv`  
**Expected Rows**: **84**

**Columns to verify**:
- `id`, `restaurant_id`, `date_start`, `date_stop`, `schedule_type`, `reason`, `apply_to`, `enabled`, `added_by`, `added_at`, `updated_by`, `updated_at`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v2_restaurants_special_schedule;
-- Expected: 84
```

---

### 5️⃣ V2 Time Periods

**Table**: `staging.v2_restaurants_time_periods`  
**CSV File**: `menuca_v2_restaurants_time_periods.csv`  
**Expected Rows**: **8**

**Columns to verify**:
- `id`, `restaurant_id`, `name`, `start`, `stop`, `enabled`, `added_by`, `added_at`, `disabled_by`, `disabled_at`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v2_restaurants_time_periods;
-- Expected: 8
```

---

### 6️⃣ V1 Service Flags

**Table**: `staging.v1_restaurants_service_flags`  
**CSV File**: `migration_db_menuca_v1_restaurants_service_flags.csv`  
**Expected Rows**: **847**

**⚠️ IMPORTANT**: CSV column `id` IS the restaurant_id

**Columns to verify**:
- `id`, `pickup`, `delivery`, `takeout`, `delivery_time`, `takeout_time`, `vacation`, `vacationStart`, `vacationStop`, `suspendOrdering`, `suspend_operation`, `suspended_at`, `comingSoon`, `overrideAutoSuspend`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v1_restaurants_service_flags;
-- Expected: 847
```

---

### 7️⃣ V2 Service Flags

**Table**: `staging.v2_restaurants_service_flags`  
**CSV File**: `migration_db_menuca_v2_restaurants_service_flags.csv`  
**Expected Rows**: **629**

**⚠️ IMPORTANT**: CSV column `id` IS the restaurant_id

**Columns to verify**:
- `id`, `suspend_operation`, `suspended_at`, `coming_soon`, `vacation`, `vacation_start`, `vacation_stop`, `suspend_ordering`, `suspend_ordering_start`, `suspend_ordering_stop`, `active`, `pending`

**Verification Query**:
```sql
SELECT COUNT(*) as imported_rows FROM staging.v2_restaurants_service_flags;
-- Expected: 629
```

---

## Final Verification

After importing all 7 CSV files, run this comprehensive verification:

```sql
-- Check all table row counts at once
SELECT 
    'v1_restaurants_schedule_normalized' as table_name,
    COUNT(*) as imported_rows,
    6341 as expected_rows,
    CASE WHEN COUNT(*) = 6341 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM staging.v1_restaurants_schedule_normalized

UNION ALL

SELECT 
    'v1_restaurants_special_schedule',
    COUNT(*),
    5,
    CASE WHEN COUNT(*) = 5 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_restaurants_special_schedule

UNION ALL

SELECT 
    'v2_restaurants_schedule',
    COUNT(*),
    1984,
    CASE WHEN COUNT(*) = 1984 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v2_restaurants_schedule

UNION ALL

SELECT 
    'v2_restaurants_special_schedule',
    COUNT(*),
    84,
    CASE WHEN COUNT(*) = 84 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v2_restaurants_special_schedule

UNION ALL

SELECT 
    'v2_restaurants_time_periods',
    COUNT(*),
    8,
    CASE WHEN COUNT(*) = 8 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v2_restaurants_time_periods

UNION ALL

SELECT 
    'v1_restaurants_service_flags',
    COUNT(*),
    847,
    CASE WHEN COUNT(*) = 847 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v1_restaurants_service_flags

UNION ALL

SELECT 
    'v2_restaurants_service_flags',
    COUNT(*),
    629,
    CASE WHEN COUNT(*) = 629 THEN '✅ PASS' ELSE '❌ FAIL' END
FROM staging.v2_restaurants_service_flags;
```

**Expected Result**: All 7 rows should show **✅ PASS**

---

## Troubleshooting

### Issue: Column names don't match

**Solution**: The staging tables were specifically designed to match CSV headers exactly. If you see mismatches:
1. Verify you're using the correct CSV file (check mapping in `CSV_TO_STAGING_MAPPING.md`)
2. Check that the CSV file hasn't been modified
3. Ensure you're importing into the correct staging table

### Issue: Date/Timestamp parsing errors

**Solution**: Invalid dates/timestamps like `0000-00-00` or `0000-00-00 00:00:00` are stored as VARCHAR in staging tables:
- V1 flags: `vacationStart`, `vacationStop` → VARCHAR(20)
- V1 flags: `suspended_at` → VARCHAR(30)
- V2 flags: `vacation_start`, `vacation_stop` → VARCHAR(20)
- V2 flags: `suspended_at` → VARCHAR(30)
- V2 flags: `suspend_ordering_start`, `suspend_ordering_stop` → VARCHAR(30)

These will be handled during transformation (Phase 4), where they'll be converted to NULL or valid timestamps.

### Issue: Row count doesn't match

**Solution**:
1. Check if import completed successfully (no timeout errors)
2. Verify CSV file integrity (check file size, open in text editor)
3. Re-run the import (tables will append, so drop and recreate if needed)

### Issue: Duplicate staging_id values

**Solution**: The `staging_id` is auto-generated (BIGSERIAL). If you see duplicates:
1. Drop the table: `DROP TABLE staging.[table_name] CASCADE;`
2. Re-run the relevant section from `create_staging_tables.sql`
3. Re-import the CSV

---

## Post-Import Checklist

After all imports are complete:

- [ ] All 7 tables show correct row counts (9,898 total)
- [ ] Spot-check data in each table (first 5-10 rows)
- [ ] Verify no NULL values in critical columns (restaurant_id, time fields)
- [ ] Check that enum values are preserved ('d', 't', 'y', 'n', etc.)
- [ ] Verify timestamps are in correct format
- [ ] Update `SERVICE_SCHEDULES_MIGRATION_GUIDE.md` - Phase 3 status to ✅ COMPLETE

---

## Next Steps

Once all data is imported and verified:

1. ✅ Mark Phase 3 as complete in documentation
2. ▶️ Proceed to **Phase 4: Data Transformation**
   - Transform staging data to V3 format
   - Handle conflicts (V2 wins)
   - Apply business rules
3. ▶️ Continue to **Phase 5: Load to V3**
4. ▶️ Complete **Phase 6: Verification**

---

**Document Created**: October 6, 2025  
**Last Updated**: October 6, 2025  
**Status**: Ready for use

