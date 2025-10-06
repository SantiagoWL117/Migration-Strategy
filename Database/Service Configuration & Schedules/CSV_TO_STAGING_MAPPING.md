# CSV to Staging Table Column Mapping

**Purpose**: Document exact column mappings between CSV files and Supabase staging tables for manual import

**Date**: October 6, 2025

---

## 1. V1 Regular Schedules

**CSV File**: `menuca_v1_restaurants_schedule_normalized.csv`  
**Staging Table**: `staging.v1_restaurants_schedule_normalized`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Source primary key |
| `restaurant_id` | INTEGER | `restaurant_id` | Restaurant reference |
| `day_start` | SMALLINT | `day_start` | 1-7 (Mon-Sun) |
| `time_start` | TIME | `time_start` | Local time |
| `day_stop` | SMALLINT | `day_stop` | 1-7 (Mon-Sun) |
| `time_stop` | TIME | `time_stop` | Local time |
| `type` | VARCHAR(1) | `type` | 'd' or 't' |
| `enabled` | VARCHAR(1) | `enabled` | 'y' or 'n' |
| `created_at` | TIMESTAMP | `created_at` | Source timestamp |
| `updated_at` | TIMESTAMP | `updated_at` | Source timestamp |

**Expected Rows**: 6,341

---

## 2. V1 Special Schedules

**CSV File**: `menuca_v1_restaurants_special_schedule.csv`  
**Staging Table**: `staging.v1_restaurants_special_schedule`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Source primary key |
| `restaurant_id` | INTEGER | `restaurant_id` | Restaurant reference |
| `special_date` | DATE | `special_date` | Specific date |
| `time_start` | TIME | `time_start` | Local time |
| `time_stop` | TIME | `time_stop` | Local time |
| `enabled` | VARCHAR(1) | `enabled` | 'y' or 'n' |
| `note` | TEXT | `note` | Notes (nullable) |
| `created_at` | TIMESTAMP | `created_at` | Source timestamp |
| `updated_at` | TIMESTAMP | `updated_at` | Source timestamp |

**Expected Rows**: 5 (historical data only)

---

## 3. V2 Regular Schedules

**CSV File**: `menuca_v2_restaurants_schedule.csv`  
**Staging Table**: `staging.v2_restaurants_schedule`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Source primary key |
| `restaurant_id` | INTEGER | `restaurant_id` | Restaurant reference |
| `day_start` | SMALLINT | `day_start` | 1-7 (Mon-Sun) |
| `time_start` | TIME | `time_start` | Local time |
| `day_stop` | SMALLINT | `day_stop` | 1-7 (Mon-Sun) |
| `time_stop` | TIME | `time_stop` | Local time |
| `type` | VARCHAR(1) | `type` | 'd' or 't' |
| `enabled` | VARCHAR(1) | `enabled` | 'y' or 'n' |

**Expected Rows**: 1,984

---

## 4. V2 Special Schedules

**CSV File**: `menuca_v2_restaurants_special_schedule.csv`  
**Staging Table**: `staging.v2_restaurants_special_schedule`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Source primary key |
| `restaurant_id` | INTEGER | `restaurant_id` | Restaurant reference |
| `date_start` | TIMESTAMP | `date_start` | Start date/time |
| `date_stop` | TIMESTAMP | `date_stop` | Stop date/time |
| `schedule_type` | VARCHAR(1) | `schedule_type` | 'c'=closed, 'o'=open |
| `reason` | VARCHAR(50) | `reason` | Reason (nullable) |
| `apply_to` | VARCHAR(1) | `apply_to` | 'd'=delivery, 't'=takeout |
| `enabled` | VARCHAR(1) | `enabled` | 'y' or 'n' |
| `added_by` | INTEGER | `added_by` | User who added |
| `added_at` | TIMESTAMP | `added_at` | When added |
| `updated_by` | INTEGER | `updated_by` | User who updated |
| `updated_at` | TIMESTAMP | `updated_at` | When updated |

**Expected Rows**: 84

---

## 5. V2 Time Periods

**CSV File**: `menuca_v2_restaurants_time_periods.csv`  
**Staging Table**: `staging.v2_restaurants_time_periods`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Source primary key |
| `restaurant_id` | INTEGER | `restaurant_id` | Restaurant reference |
| `name` | VARCHAR(50) | `name` | Period name (Lunch, Dinner) |
| `start` | TIME | `start` | Start time |
| `stop` | TIME | `stop` | Stop time |
| `enabled` | VARCHAR(1) | `enabled` | 'y' or 'n' |
| `added_by` | INTEGER | `added_by` | User who added |
| `added_at` | TIMESTAMP | `added_at` | When added |
| `disabled_by` | INTEGER | `disabled_by` | User who disabled (nullable) |
| `disabled_at` | TIMESTAMP | `disabled_at` | When disabled (nullable) |

**Expected Rows**: 8

---

## 6. V1 Service Flags

**CSV File**: `migration_db_menuca_v1_restaurants_service_flags.csv`  
**Staging Table**: `staging.v1_restaurants_service_flags`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Restaurant ID (same as restaurant_id) |
| `pickup` | VARCHAR(1) | `pickup` | '1' or '0' |
| `delivery` | VARCHAR(1) | `delivery` | '1' or '0' |
| `takeout` | VARCHAR(1) | `takeout` | '1' or '0' |
| `delivery_time` | INTEGER | `delivery_time` | Minutes |
| `takeout_time` | INTEGER | `takeout_time` | Minutes |
| `vacation` | VARCHAR(1) | `vacation` | 'y' or 'n' |
| `vacationStart` | VARCHAR(20) | `vacationStart` | Date as string (handles '0000-00-00') |
| `vacationStop` | VARCHAR(20) | `vacationStop` | Date as string (handles '0000-00-00') |
| `suspendOrdering` | VARCHAR(1) | `suspendOrdering` | 'y' or 'n' |
| `suspend_operation` | VARCHAR(1) | `suspend_operation` | '1' or '0' |
| `suspended_at` | VARCHAR(30) | `suspended_at` | Timestamp as string (handles '0000-00-00 00:00:00') |
| `comingSoon` | VARCHAR(1) | `comingSoon` | 'y' or 'n' |
| `overrideAutoSuspend` | VARCHAR(1) | `overrideAutoSuspend` | 'y' or 'n' |

**Expected Rows**: 847

---

## 7. V2 Service Flags

**CSV File**: `migration_db_menuca_v2_restaurants_service_flags.csv`  
**Staging Table**: `staging.v2_restaurants_service_flags`

| CSV Column | Data Type | Staging Column | Notes |
|------------|-----------|----------------|-------|
| `id` | INTEGER | `id` | Restaurant ID (same as restaurant_id) |
| `suspend_operation` | VARCHAR(10) | `suspend_operation` | '0', '1', '2' |
| `suspended_at` | VARCHAR(30) | `suspended_at` | Timestamp as string (handles '0000-00-00 00:00:00') |
| `coming_soon` | VARCHAR(10) | `coming_soon` | '1', '2' |
| `vacation` | VARCHAR(10) | `vacation` | '2', etc. |
| `vacation_start` | VARCHAR(20) | `vacation_start` | Date as string (handles '0000-00-00') |
| `vacation_stop` | VARCHAR(20) | `vacation_stop` | Date as string (handles '0000-00-00') |
| `suspend_ordering` | VARCHAR(10) | `suspend_ordering` | '2', etc. |
| `suspend_ordering_start` | VARCHAR(30) | `suspend_ordering_start` | Timestamp as string (handles '0000-00-00 00:00:00') |
| `suspend_ordering_stop` | VARCHAR(30) | `suspend_ordering_stop` | Timestamp as string (handles '0000-00-00 00:00:00') |
| `active` | VARCHAR(10) | `active` | '1', '2' |
| `pending` | VARCHAR(10) | `pending` | '1', '2' |

**Expected Rows**: 629

---

## Import Instructions

### Using Supabase Table Editor

1. Navigate to **Supabase Dashboard** → **Table Editor**
2. Select the `staging` schema
3. Open the target staging table
4. Click **"Insert"** → **"Import data from CSV"**
5. Select the corresponding CSV file from the mapping above
6. **Important**: Ensure column mapping is correct (columns should auto-map by name)
7. Verify the preview shows correct data alignment
8. Click **"Import"** to load the data

### Post-Import Verification

After importing each CSV file, run this query to verify:

```sql
-- Verify row counts
SELECT 
    'v1_restaurants_schedule_normalized' as table_name,
    COUNT(*) as row_count,
    6341 as expected_count
FROM staging.v1_restaurants_schedule_normalized
UNION ALL
SELECT 'v1_restaurants_special_schedule', COUNT(*), 5
FROM staging.v1_restaurants_special_schedule
UNION ALL
SELECT 'v2_restaurants_schedule', COUNT(*), 1984
FROM staging.v2_restaurants_schedule
UNION ALL
SELECT 'v2_restaurants_special_schedule', COUNT(*), 84
FROM staging.v2_restaurants_special_schedule
UNION ALL
SELECT 'v2_restaurants_time_periods', COUNT(*), 8
FROM staging.v2_restaurants_time_periods
UNION ALL
SELECT 'v1_restaurants_service_flags', COUNT(*), 847
FROM staging.v1_restaurants_service_flags
UNION ALL
SELECT 'v2_restaurants_service_flags', COUNT(*), 629
FROM staging.v2_restaurants_service_flags;
```

---

**Total Expected Rows**: 9,898 across all 7 staging tables

