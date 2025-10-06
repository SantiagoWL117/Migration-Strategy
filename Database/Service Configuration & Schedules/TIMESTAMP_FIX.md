# Timestamp Import Fix

**Date**: October 6, 2025  
**Issue**: Date/time field value out of range: `"0000-00-00 00:00:00"`  
**Status**: ✅ RESOLVED

---

## Problem

When importing CSV files for service flags tables, Supabase was throwing an error:
```
Failed to import data: date/time field value out of range: "0000-00-00 00:00:00"
```

This occurred because:
1. Legacy V1 and V2 databases used `'0000-00-00'` as placeholder dates
2. MySQL allows these invalid dates, but PostgreSQL/Supabase does not
3. The staging tables had `suspended_at` defined as `TIMESTAMP` type

---

## Solution

Changed all date/timestamp columns that may contain invalid values to `VARCHAR` type in staging tables:

### V1 Service Flags (`staging.v1_restaurants_service_flags`)

| Column | OLD Type | NEW Type | Reason |
|--------|----------|----------|--------|
| `vacationStart` | DATE | VARCHAR(20) | May contain `'0000-00-00'` |
| `vacationStop` | DATE | VARCHAR(20) | May contain `'0000-00-00'` |
| `suspended_at` | TIMESTAMP | VARCHAR(30) | May contain `'0000-00-00 00:00:00'` |

### V2 Service Flags (`staging.v2_restaurants_service_flags`)

| Column | OLD Type | NEW Type | Reason |
|--------|----------|----------|--------|
| `vacation_start` | DATE | VARCHAR(20) | May contain `'0000-00-00'` |
| `vacation_stop` | DATE | VARCHAR(20) | May contain `'0000-00-00'` |
| `suspended_at` | TIMESTAMP | VARCHAR(30) | May contain `'0000-00-00 00:00:00'` |
| `suspend_ordering_start` | TIMESTAMP | VARCHAR(30) | May contain `'0000-00-00 00:00:00'` |
| `suspend_ordering_stop` | TIMESTAMP | VARCHAR(30) | May contain `'0000-00-00 00:00:00'` |

---

## Implementation

### Step 1: Drop Existing Tables (if already created)

```sql
DROP TABLE IF EXISTS staging.v1_restaurants_service_flags CASCADE;
DROP TABLE IF EXISTS staging.v2_restaurants_service_flags CASCADE;
```

### Step 2: Re-run Updated SQL

Run the updated `create_staging_tables.sql` script in Supabase SQL Editor. The script now has VARCHAR types for all potentially invalid date/timestamp columns.

### Step 3: Import CSV Files

Now you can successfully import the CSV files:
- `migration_db_menuca_v1_restaurants_service_flags.csv` → `staging.v1_restaurants_service_flags`
- `migration_db_menuca_v2_restaurants_service_flags.csv` → `staging.v2_restaurants_service_flags`

---

## Data Transformation (Phase 4)

During Phase 4 (Data Transformation), these VARCHAR date/timestamp fields will be converted to proper DATE/TIMESTAMP types:

```sql
-- Example transformation logic
CASE 
    WHEN suspended_at = '' OR suspended_at IS NULL THEN NULL
    WHEN suspended_at = '0000-00-00 00:00:00' THEN NULL
    WHEN suspended_at LIKE '0000-00-00%' THEN NULL
    ELSE suspended_at::TIMESTAMP
END as suspended_at
```

---

## Verification

After re-importing, verify the data loaded correctly:

```sql
-- Check V1 flags
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "vacationStart" = '0000-00-00' THEN 1 END) as invalid_vacation_start,
    COUNT(CASE WHEN "vacationStop" = '0000-00-00' THEN 1 END) as invalid_vacation_stop,
    COUNT(CASE WHEN suspended_at = '0000-00-00 00:00:00' THEN 1 END) as invalid_suspended_at
FROM staging.v1_restaurants_service_flags;

-- Check V2 flags
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN vacation_start = '0000-00-00' THEN 1 END) as invalid_vacation_start,
    COUNT(CASE WHEN vacation_stop = '0000-00-00' THEN 1 END) as invalid_vacation_stop,
    COUNT(CASE WHEN suspended_at LIKE '0000-00-00%' THEN 1 END) as invalid_suspended_at,
    COUNT(CASE WHEN suspend_ordering_start LIKE '0000-00-00%' THEN 1 END) as invalid_ordering_start,
    COUNT(CASE WHEN suspend_ordering_stop LIKE '0000-00-00%' THEN 1 END) as invalid_ordering_stop
FROM staging.v2_restaurants_service_flags;
```

---

## Files Updated

1. ✅ `create_staging_tables.sql` - Changed timestamp columns to VARCHAR
2. ✅ `CSV_TO_STAGING_MAPPING.md` - Updated data type documentation
3. ✅ `SUPABASE_IMPORT_GUIDE.md` - Updated troubleshooting section

---

## Status

✅ **RESOLVED** - You can now proceed with importing the service flags CSV files without timestamp errors.

**Next Steps**:
1. Drop the old staging tables (if they exist)
2. Re-run `create_staging_tables.sql` (sections 6 & 7)
3. Import the CSV files using Supabase Table Editor
4. Verify row counts (847 for V1, 629 for V2)

