# Phase 4 & 5 Overview - Service Configuration & Schedules Migration

**Date**: October 6, 2025  
**Status**: Phase 3 Complete ✅ | Phase 4 Ready to Execute ⏳

---

## ✅ What's Been Completed

### Phase 1: Schema Creation ✅
- 4 V3 tables created in `menuca_v3` schema
- All constraints, indexes, and triggers in place

### Phase 2: Data Extraction ✅
- 9,898 rows exported to 7 CSV files
- All data integrity verified

### Phase 3: Staging Tables ✅
- 7 staging tables created in `staging` schema
- **9,898 rows successfully imported** via Supabase CSV import
- Invalid dates stored as VARCHAR for transformation

---

## 🔄 Phase 4: Data Transformation & Load to V3

### Overview

**Purpose**: Transform staging data and load it into final V3 tables with proper data types, enum conversions, and conflict resolution.

**Key Features**:
- ✅ **Date Handling**: Converts VARCHAR dates to proper DATE/TIMESTAMP (handles `'0000-00-00'`)
- ✅ **Enum Mapping**: `'d'`→`'delivery'`, `'t'`→`'takeout'`, `'y'`→`true`, `'n'`→`false`
- ✅ **Conflict Resolution**: V2 data overwrites V1 using `ON CONFLICT` UPSERT
- ✅ **Data Merging**: V1 and V2 service configs merged with COALESCE (V2 priority)
- ✅ **Audit Trail**: `notes` column tracks migration source and conflicts

---

### 4.1 Transform & Load V1 Regular Schedules

**What it does**:
- Loads V1 schedules from `staging.v1_restaurants_schedule_normalized`
- Maps `'d'` → `'delivery'`, `'t'` → `'takeout'`
- Converts `'y'`/`'n'` → `true`/`false`
- Uses `ON CONFLICT DO NOTHING` (V2 will overwrite later)

**Expected Output**: ~6,341 schedule rows loaded

---

### 4.2 Transform & Load V2 Regular Schedules

**What it does**:
- Loads V2 schedules from `staging.v2_restaurants_schedule`
- Same enum mappings as V1
- **Uses `ON CONFLICT DO UPDATE`** - **V2 WINS**
- Marks conflicts in `notes` column

**Expected Output**: ~1,984 schedule rows loaded/updated

**Key SQL**:
```sql
ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) 
DO UPDATE SET
    day_stop = EXCLUDED.day_stop,
    is_enabled = EXCLUDED.is_enabled,
    notes = EXCLUDED.notes || ' [V2 overwrote V1]',
    updated_at = NOW();
```

---

### 4.3 Transform & Load V2 Special Schedules

**What it does**:
- Loads holiday/closure schedules from `staging.v2_restaurants_special_schedule`
- Converts timestamp columns to separate DATE and TIME
- Maps schedule types: `'c'`→`'closed'`, `'o'`→`'open'`
- Maps apply_to: `'d'`→`'delivery'`, `'t'`→`'takeout'`

**Expected Output**: ~84 special schedule rows

**Special Handling**:
- `NULLIF(TIME(...), '00:00:00')` - Sets TIME to NULL if midnight (all-day closure)

---

### 4.4 Transform & Load Service Configs (V1 + V2 Merged)

**What it does**:
- **Merges** V1 and V2 service configuration flags
- Uses **CTEs** to prepare each source
- `FULL OUTER JOIN` with `COALESCE` - **V2 values take priority**
- Handles VARCHAR→DATE conversion for invalid dates

**Date Conversion Logic**:
```sql
CASE 
    WHEN vacation_start IS NULL OR vacation_start = '' THEN NULL
    WHEN vacation_start = '0000-00-00' THEN NULL
    ELSE vacation_start::DATE
END as vacation_start
```

**Expected Output**: One config row per restaurant (up to 847 from V1 + 629 from V2, merged)

---

### 4.5 Transform & Load Time Periods

**What it does**:
- Loads named time windows (Lunch, Dinner, etc.)
- Maps `'y'`/`'n'` → `true`/`false`
- Uses CSV column names: `start` and `stop` (not `time_start`/`time_stop`)

**Expected Output**: 8 time period rows (7 unique restaurants)

---

## ✅ Phase 5: Verification & Data Quality Checks

### Overview

**Purpose**: Verify migration success and identify any data quality issues before sign-off.

---

### 5.1 Row Count Verification

**Checks**:
- Staging row counts vs V3 final counts
- Processed flags in staging tables

**Expected**:
- V3 Schedules: ~6,341 (V1) + ~1,984 (V2) minus duplicates
- V3 Special Schedules: 84
- V3 Service Configs: Number of unique restaurants
- V3 Time Periods: 8

---

### 5.2 Data Integrity Checks

**Verifies**:
- ✅ No orphaned schedules (all have valid `restaurant_id`)
- ✅ No invalid day ranges (must be 1-7)
- ✅ No NULL time fields
- ✅ No invalid special date ranges (`date_stop < date_start`)
- ✅ No duplicate schedules

**Expected Result**: All checks return `0` issues

---

### 5.3 Business Logic Validation

**Checks**:
- Restaurants with no schedules (warning, may be intentional)
- Restaurants with delivery enabled but no delivery schedule (error)
- Restaurants with takeout enabled but no takeout schedule (error)

**Action Required**: Investigate any restaurants flagged

---

### 5.4 Sample Data Spot Checks

**Verifies**:
- Restaurants 1603, 1634, 1656, 1665, 1641, 1668 all have time periods
- Schedules, configs, and special schedules linked correctly

---

### 5.5 Data Quality Report

**Generates**:
- Total restaurants
- Restaurants with schedules
- Schedule breakdown (delivery vs takeout)
- Special schedules count
- Service configs count
- Time periods count

**Purpose**: Summary for stakeholders/sign-off

---

## 🚀 Execution Plan

### Step 1: Run Phase 4 Transformations (in order)

Execute these queries in Supabase SQL Editor:

1. ✅ Run 4.1: V1 Regular Schedules
2. ✅ Run 4.2: V2 Regular Schedules (UPSERT)
3. ✅ Run 4.3: V2 Special Schedules
4. ✅ Run 4.4: Service Configs (V1+V2 Merged)
5. ✅ Run 4.5: Time Periods

**Estimated Time**: 5-10 minutes

---

### Step 2: Run Phase 5 Verifications

Execute verification queries in order:

1. ✅ 5.1: Row Count Verification
2. ✅ 5.2: Data Integrity Checks
3. ✅ 5.3: Business Logic Validation
4. ✅ 5.4: Sample Data Spot Checks
5. ✅ 5.5: Data Quality Report

**Estimated Time**: 5 minutes

---

### Step 3: Review & Sign-Off

**Review**:
- All verification checks pass
- Row counts match expectations
- Business logic validations clean (or explained)
- Sample data looks correct

**Action**: Document any issues and resolve before finalizing

---

## 📊 Success Criteria

### Phase 4 Success
- [ ] All 5 transformation queries execute without errors
- [ ] All staging tables marked as `is_processed = TRUE`
- [ ] No SQL constraint violations
- [ ] V3 tables populated with data

### Phase 5 Success
- [ ] All row count verifications pass
- [ ] Zero data integrity issues
- [ ] Business logic validations explained (if any)
- [ ] Sample data spot checks pass
- [ ] Data quality report reviewed

---

## ⚠️ Important Notes

### Invalid Date Handling

**Problem**: Legacy databases contain `'0000-00-00'` dates that PostgreSQL rejects

**Solution**: Stored as VARCHAR in staging, converted in Phase 4:
```sql
CASE 
    WHEN date_field IS NULL OR date_field = '' THEN NULL
    WHEN date_field = '0000-00-00' THEN NULL
    WHEN date_field LIKE '0000-00-00%' THEN NULL
    ELSE date_field::DATE
END
```

**Result**: Invalid dates become NULL in V3 tables

---

### Conflict Resolution Strategy

**Rule**: **V2 Data Wins**

**Implementation**:
1. Load V1 first with `ON CONFLICT DO NOTHING`
2. Load V2 second with `ON CONFLICT DO UPDATE`
3. Mark conflicts in `notes` column: `'[V2 overwrote V1]'`

**Audit Trail**: Original values preserved in staging tables for reference

---

### Service Config Merging

**Strategy**: `FULL OUTER JOIN` with `COALESCE`

**Why**: Some restaurants only in V1, some only in V2, some in both

**Logic**: 
- If restaurant in both V1 and V2 → Use V2 value
- If restaurant only in V1 → Use V1 value
- If restaurant only in V2 → Use V2 value

---

## 📁 Files Reference

1. **`create_staging_tables.sql`** - Staging table DDL (executed)
2. **`SERVICE_SCHEDULES_MIGRATION_GUIDE.md`** - Complete migration guide (updated with Phase 4 & 5)
3. **`TIMESTAMP_FIX.md`** - Invalid date handling documentation
4. **`CSV_TO_STAGING_MAPPING.md`** - Column mappings
5. **`SUPABASE_IMPORT_GUIDE.md`** - CSV import instructions

---

## 🎯 Next Steps

1. **Review** Phase 4 SQL queries in `SERVICE_SCHEDULES_MIGRATION_GUIDE.md`
2. **Execute** Phase 4 queries in order (4.1 → 4.5)
3. **Run** Phase 5 verification queries
4. **Document** any issues or discrepancies
5. **Sign-off** when all checks pass

**Ready to proceed with Phase 4?** All staging data is loaded and ready for transformation! 🚀

