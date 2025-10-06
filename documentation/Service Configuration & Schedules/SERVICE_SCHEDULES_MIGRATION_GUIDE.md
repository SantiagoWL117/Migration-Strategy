# Service Configuration & Schedules - Complete Migration Guide

## Document Status
✅ **FINALIZED** - Ready for implementation  
✅ **SCHEMA CREATED** - V3 tables successfully created (2025-10-03)  
📅 **Last Updated**: 2025-10-03  
👤 **Approved by**: Junior Software Developer

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Migration Scope](#migration-scope)
3. [V3 Schema Overview](#v3-schema-overview)
4. [Data Sources](#data-sources)
5. [Tables Excluded and Why](#tables-excluded-and-why)
6. [Migration Steps](#migration-steps)
7. [Verification & Validation](#verification--validation)
8. [Key Decisions](#key-decisions)

---

## Executive Summary

### Migration Overview
- **Entity**: Service Configuration & Schedules
- **Purpose**: Migrate service capabilities (delivery/takeout), business hours, special schedules, and operational status
- **Complexity**: 🟢 LOW-MEDIUM (simplified due to V1 pre-normalized data)
- **Timeline**: 6-8 business days

### V3 Target Tables (All Created ✅)
1. `restaurant_schedules` - Regular delivery/takeout hours
2. `restaurant_special_schedules` - Holiday/vacation schedules (NEW)
3. `restaurant_service_configs` - Service capabilities (NEW)
4. `restaurant_time_periods` - Named time windows for menu items (NEW)

### Data Volume
- **Regular schedules**: ~2,500-3,000 rows (V1 + V2 deduplicated)
- **Special schedules**: ~134 rows (V2 only)
- **Service configs**: ~944 restaurants
- **Time periods**: 15 rows (7 restaurants use this)

---

## Migration Scope

### ✅ Tables TO MIGRATE

#### V1 Sources (menuca_v1):
| Table | Rows | Purpose | Status |
|-------|------|---------|--------|
| `restaurants_schedule_normalized` | Variable | Regular schedules (d=delivery, t=takeout) | ✅ Pre-normalized, clean |
| Service flags in `restaurants` | N/A | vacation, suspend_operation, etc. | ✅ Ready |

#### V2 Sources (menuca_v2):
| Table | Rows | Purpose | Status |
|-------|------|---------|--------|
| `restaurants_schedule` | 2,502 | Regular schedules | ✅ Ready |
| `restaurants_special_schedule` | 134 | Holiday/closure schedules | ✅ Ready |
| `restaurants_configs` | Variable | Service configuration | ✅ Ready |
| `restaurants_time_periods` | 15 | Named time windows | ✅ Menu items reference these |
| Service flags in `restaurants` | N/A | Enhanced operational flags | ✅ Ready |

---

## V3 Schema Overview

### 1. `menuca_v3.restaurant_schedules` ✅
**Purpose**: Regular delivery and takeout service hours

**Key Columns**:
- `restaurant_id` BIGINT FK → restaurants(id) CASCADE
- `type` service_type ('delivery', 'takeout')
- `day_start`, `day_stop` SMALLINT (1-7 for Mon-Sun)
- `time_start`, `time_stop` TIME (local time)
- `is_enabled` BOOLEAN

**Unique Constraint**: (restaurant_id, type, day_start, time_start, time_stop)

---

### 2. `menuca_v3.restaurant_special_schedules` ✅ (NEW)
**Purpose**: Holiday, vacation, and special hour overrides

**Key Columns**:
- `restaurant_id` BIGINT FK → restaurants(id) CASCADE
- `schedule_type` VARCHAR ('closed', 'open', 'modified')
- `date_start`, `date_stop` DATE
- `time_start`, `time_stop` TIME (nullable, local time)
- `reason` VARCHAR ('vacation', 'bad_weather', 'holiday', 'maintenance')
- `apply_to` VARCHAR ('delivery', 'takeout', 'both')
- `notes` TEXT
- `is_active` BOOLEAN

**Check Constraints**: 
- `date_stop >= date_start`
- Valid schedule_type and apply_to values

---

### 3. `menuca_v3.restaurant_service_configs` ✅ (NEW)
**Purpose**: Service capabilities and configuration per restaurant

**Key Columns**:
- `restaurant_id` BIGINT FK → restaurants(id) CASCADE
- **Delivery**: `delivery_enabled`, `delivery_time_minutes`, `delivery_min_order`
- **Takeout**: `takeout_enabled`, `takeout_time_minutes`, `takeout_discount_*`
- **Preorder**: `allow_preorders`, `preorder_time_frame_hours`
- **Language**: `is_bilingual`, `default_language`

**Unique Constraint**: One config per restaurant

---

### 4. `menuca_v3.restaurant_time_periods` ✅ (NEW)
**Purpose**: Named time windows (Lunch, Dinner) for menu item availability

**Key Columns**:
- `restaurant_id` BIGINT FK → restaurants(id) CASCADE
- `name` VARCHAR(50) ('Lunch', 'Dinner', 'Happy Hour', etc.)
- `time_start`, `time_stop` TIME (local time)
- `is_enabled` BOOLEAN
- `display_order` INTEGER

**Unique Constraint**: (restaurant_id, name)

---

## Data Sources

### V1 Pre-Normalized Tables (Use These!)

#### `restaurants_schedule_normalized`
**Why use this**: Already normalized from 416K+ rows of blob data
```sql
Structure:
- restaurant_id int
- day_start, day_stop smallint (1-7)
- time_start, time_stop time
- type enum('d', 't')  -- d=delivery, t=takeout
- enabled enum('y', 'n')
```

**Sample Data**:
```
id=1, restaurant_id=72, day_start=2, day_stop=2, 
time_start='09:00:00', time_stop='23:59:00', type='d', enabled='y'
```

#### V1 Service Flags (restaurants table)
- `pickup`, `delivery`, `takeout` enum('1','0')
- `delivery_time`, `takeout_time` int (minutes)
- `vacation`, `vacationStart`, `vacationStop`
- `suspendOrdering`, `suspend_operation`, `comingSoon`

---

### V2 Tables (Use These!)

#### `restaurants_schedule`
```sql
Structure:
- restaurant_id int
- day_start, day_stop smallint (1-7)
- time_start, time_stop time
- type enum('d', 't')
- enabled enum('y', 'n')
```

#### `restaurants_special_schedule`
```sql
Structure:
- restaurant_id int
- date_start, date_stop timestamp
- schedule_type enum('c', 'o')  -- c=closed, o=open
- reason varchar ('vacation', 'bad_weather')
- apply_to enum('d', 't')  -- d=delivery, t=takeout
- enabled enum('y', 'n')
```

#### `restaurants_configs`
```sql
Key fields:
- delivery enum('y','n')
- takeout enum('y','n')
- delivery_time, takeout_time int
- min_delivery float
- takeout_discount, takeout_discount_type
- allow_preorders, preorders_time_frame
- bilingual, default_language
```

#### `restaurants_time_periods`
```sql
Structure:
- restaurant_id int
- name varchar(50)
- time_start, time_stop time
- enabled enum('y', 'n')
- display_order int
```

---

## Tables Excluded and Why

### ❌ V1 Exclusions

| Table | Rows | Reason |
|-------|------|--------|
| `restaurant_schedule` | 416,526 | ✅ Already normalized into `restaurants_schedule_normalized` |
| `delivery_schedule` | 1,310 | ✅ Already merged into `restaurants_schedule_normalized` |
| `delivery_disable` | 1,792 | ❌ Historical events (temporary suspensions), not schedules |
| `restaurants_special_schedule` | 5 | ❌ **USER DECISION**: Only historical data (2016-2021), V2 has better data |
| Blob fields | N/A | ✅ Already parsed during normalization |

### ❌ V2 Exclusions

| Table | Rows | Reason |
|-------|------|--------|
| `restaurants_disable_delivery` | 31 | ❌ **USER DECISION**: Only 2019 data (expired) |
| `restaurants_delivery_schedule` | 7 | ➡️ **USER DECISION**: Delivery partner schedule → Delivery Operations entity |

**Key Principle**: Don't migrate historical operational events or data from wrong entity scope.

---

## Migration Steps

### Phase 1: Schema Creation ✅ COMPLETE

All V3 tables created with:
- Foreign keys to restaurants(id) with CASCADE delete
- Appropriate indexes and unique constraints
- Auto-update triggers for updated_at fields
- Check constraints for data integrity

**Enum Type**: `public.service_type` enum values confirmed: 'delivery', 'takeout'

---

### Phase 2: Data Extraction ✅ COMPLETE

**Status**: All CSV conversions completed successfully (2025-10-04)

**Completed CSV Conversions** (Verified 2025-10-04):
1. ✅ `menuca_v1_restaurants_schedule_normalized_dump.csv` - **6,341 rows** ✓ Complete
2. ✅ `menuca_v1_restaurants_special_schedule_dump.csv` - **5 rows** ✓ Complete  
3. ✅ `menuca_v2_restaurants_schedule.csv` - **1,984 rows** ✓ Complete
4. ✅ `menuca_v2_restaurants_special_schedule.csv` - **84 rows** ✓ Complete
5. ✅ `menuca_v2_restaurants_time_periods.csv` - **8 rows** ✓ Complete
6. ✅ `migration_db_menuca_v1_restaurants_service_flags.csv` - **847 rows** ✓ Complete
7. ✅ `migration_db_menuca_v2_restaurants_service_flags.csv` - **629 rows** ✓ Complete

**Total Records Extracted**: **9,898 rows** across 7 CSV files  
**Data Integrity**: ✅ All data successfully converted with no loss

**Excluded - BLOB Column Issue**:
8. ⚠️ `menuca_v2_restaurants_configs.sql` - **Contains `custom_meta` BLOB column**
   - **Status**: ✅ EXCLUDED - Data deemed irrelevant for migration
   - **Decision Date**: 2025-10-04
   - **Rationale**: Analysis revealed only 4 out of 165 restaurants (2.4%) contain custom metadata
     - 3 restaurants: Custom H1/H2/Footer branding text (cosmetic, not functional)
     - 1 restaurant: Test data with generic key-value pairs
   - **Impact**: None. This data represents legacy custom branding that is not part of V3 service configuration model

#### 🔍 BLOB Column Analysis - restaurants_configs.custom_meta

**File**: `menuca_v2_restaurants_configs.sql`  
**Column**: `custom_meta` BLOB (JSON in binary format)  
**Analysis Date**: 2025-10-04

**Findings**:
- **Total Records**: 165
- **Records with Data**: 4 (2.4%)
- **Records Empty**: 161 (97.6%)

**Data Content**:
| Restaurant ID | Metadata Type | Purpose |
|---------------|---------------|---------|
| 1595 | Test data | Generic key-value pairs ("1"→"2", "3"→"4") |
| 1611 | Branding | "All Out Burger" H1/H2 text |
| 1171 | Branding | Vietnamese restaurant tagline |
| 1636 | Branding | "All Out Burger" H1/H2/Footer |

**Decision**: ❌ **DO NOT MIGRATE**
- Custom branding text is not part of V3 service configuration schema
- Only 4 restaurants affected (can be manually re-entered if needed)
- V3 uses separate content management approach for branding

#### Extract V1 Data (Example - Will be updated)
```powershell
# Regular schedules (pre-normalized)
mysql -u root -p menuca_v1 -e "SELECT * FROM restaurants_schedule_normalized" > v1_schedules.csv

# Service flags from restaurants table
mysql -u root -p menuca_v1 -e "
SELECT id, pickup, delivery, takeout, delivery_time, takeout_time, 
       vacation, vacationStart, vacationStop, suspendOrdering, 
       suspend_operation, suspended_at, comingSoon
FROM restaurants" > v1_service_flags.csv
```

#### Extract V2 Data
```powershell
# Regular schedules
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_schedule" > v2_schedules.csv

# Special schedules
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_special_schedule" > v2_special.csv

# Service configs
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_configs" > v2_configs.csv

# Time periods
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_time_periods" > v2_time_periods.csv

# Service flags
mysql -u root -p menuca_v2 -e "
SELECT id, suspend_operation, suspended_at, coming_soon, vacation, 
       vacation_start, vacation_stop, suspend_ordering, 
       suspend_ordering_start, suspend_ordering_stop, active, pending
FROM restaurants" > v2_service_flags.csv
```

---

### Phase 3: Create Staging Tables ✅ COMPLETE

**Status**: All staging tables successfully created in Supabase (2025-10-04)

**SQL Script**: `Database/Service Configuration & Schedules/create_staging_tables.sql`  
**Migration Applied**: `create_service_schedules_staging_tables`

**Staging Tables Created** (in `staging` schema):
1. ✅ `staging.v1_restaurants_schedule_normalized` - V1 regular schedules (6,342 rows expected)
2. ✅ `staging.v1_restaurants_special_schedule` - V1 special schedules (5 rows, historical)
3. ✅ `staging.v2_restaurants_schedule` - V2 regular schedules (1,984 rows expected)
4. ✅ `staging.v2_restaurants_special_schedule` - V2 special schedules (84 rows expected)
5. ✅ `staging.v2_restaurants_time_periods` - V2 time periods (8 rows expected)
6. ✅ `staging.v1_restaurants_service_flags` - V1 service configuration flags (847 rows expected)
7. ✅ `staging.v2_restaurants_service_flags` - V2 service configuration flags (629 rows expected)

**Key Design Decisions**:
- **Schema**: Using `staging` (not `menuca_v3_staging`)
- **Column Preservation**: Staging tables preserve source column names and data types from CSV files
- **ETL Metadata**: Each table includes `loaded_at`, `notes`, `is_processed` for tracking
- **Indexing**: Indexes on `restaurant_id` for efficient lookups during transformation

**Table Structure Pattern**:
```sql
CREATE TABLE staging.{source_table_name} (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source columns (matching CSV exactly)
    source_id INTEGER,
    restaurant_id INTEGER,
    [source columns...]
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);
```

**See**: Full SQL in `Database/Service Configuration & Schedules/create_staging_tables.sql`

---

### Phase 4: Data Transformation & Load to V3 ⏳ NEXT

**Status**: Ready to transform staging data and load into V3 tables

**Overview**: Transform staging data (handle date conversions, enum mappings, conflict resolution) and load into final V3 tables.

---

#### 4.1 Transform & Load V1 Regular Schedules

**Purpose**: Convert V1 schedules from staging to V3 format with proper type mappings

```sql
-- Transform V1 schedules into V3 format
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v1_id
    FROM menuca_v3.restaurants
    WHERE legacy_v1_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_schedules 
    (restaurant_id, type, day_start, day_stop, time_start, time_stop, is_enabled, notes, created_at)
SELECT DISTINCT
    rm.v3_id,
    CASE s.type
        WHEN 'd' THEN 'delivery'::public.service_type
        WHEN 't' THEN 'takeout'::public.service_type
    END,
    s.day_start,
    s.day_stop,
    s.time_start,
    s.time_stop,
    CASE s.enabled WHEN 'y' THEN true ELSE false END,
    'Migrated from V1 (source_id: ' || s.id || ')',
    NOW()
FROM staging.v1_restaurants_schedule_normalized s
JOIN restaurant_mapping rm ON rm.legacy_v1_id = s.restaurant_id
WHERE s.type IN ('d', 't')
AND s.day_start BETWEEN 1 AND 7
AND s.day_stop BETWEEN 1 AND 7
AND s.time_start IS NOT NULL
AND s.time_stop IS NOT NULL
-- Avoid duplicates
ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) DO NOTHING;

-- Mark as processed
UPDATE staging.v1_restaurants_schedule_normalized
SET is_processed = TRUE, notes = 'Loaded to V3'
WHERE id IN (
    SELECT s.id FROM staging.v1_restaurants_schedule_normalized s
    JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.restaurant_id
);
```

#### 4.2 Transform & Load V2 Regular Schedules (OVERWRITES V1)

**Purpose**: Load V2 schedules with UPSERT logic - V2 data wins conflicts with V1

```sql
-- Transform V2 schedules into V3 format (UPSERT: V2 wins)
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_schedules 
    (restaurant_id, type, day_start, day_stop, time_start, time_stop, is_enabled, notes, created_at)
SELECT DISTINCT
    rm.v3_id,
    CASE s.type
        WHEN 'd' THEN 'delivery'::public.service_type
        WHEN 't' THEN 'takeout'::public.service_type
    END,
    s.day_start,
    s.day_stop,
    s.time_start,
    s.time_stop,
    CASE s.enabled WHEN 'y' THEN true WHEN 'n' THEN false ELSE false END,
    'Migrated from V2 (source_id: ' || s.id || ')',
    NOW()
FROM staging.v2_restaurants_schedule s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id
WHERE s.type IN ('d', 't')
AND s.day_start BETWEEN 1 AND 7
AND s.day_stop BETWEEN 1 AND 7
AND s.time_start IS NOT NULL
AND s.time_stop IS NOT NULL
-- V2 WINS: Update existing records if conflict
ON CONFLICT (restaurant_id, type, day_start, time_start, time_stop) 
DO UPDATE SET
    day_stop = EXCLUDED.day_stop,
    is_enabled = EXCLUDED.is_enabled,
    notes = EXCLUDED.notes || ' [V2 overwrote V1]',
    updated_at = NOW();

-- Mark as processed
UPDATE staging.v2_restaurants_schedule
SET is_processed = TRUE, notes = 'Loaded to V3'
WHERE id IN (
    SELECT s.id FROM staging.v2_restaurants_schedule s
    JOIN menuca_v3.restaurants r ON r.legacy_v2_id = s.restaurant_id
);
```

#### 4.3 Transform & Load V2 Special Schedules

**Purpose**: Load special schedules (holidays, closures) from V2 only (V1 excluded)

```sql
-- Transform V2 special schedules into V3 format
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_special_schedules 
    (restaurant_id, schedule_type, date_start, date_stop, time_start, time_stop, 
     reason, apply_to, notes, is_active, created_at)
SELECT 
    rm.v3_id,
    CASE s.schedule_type
        WHEN 'c' THEN 'closed'
        WHEN 'o' THEN 'open'
        ELSE 'modified'
    END,
    DATE(s.date_start),
    DATE(s.date_stop),
    NULLIF(TIME(s.date_start), '00:00:00'),  -- NULL if midnight (all-day closure)
    NULLIF(TIME(s.date_stop), '00:00:00'),
    s.reason,
    CASE s.apply_to
        WHEN 'd' THEN 'delivery'
        WHEN 't' THEN 'takeout'
        ELSE 'both'
    END,
    'Migrated from V2 (source_id: ' || s.id || ')',
    CASE s.enabled WHEN 'y' THEN true ELSE false END,
    NOW()
FROM staging.v2_restaurants_special_schedule s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id
WHERE s.date_start IS NOT NULL
AND s.date_stop IS NOT NULL
AND DATE(s.date_stop) >= DATE(s.date_start);

-- Mark as processed
UPDATE staging.v2_restaurants_special_schedule
SET is_processed = TRUE, notes = 'Loaded to V3';
```

#### 4.4 Transform & Load Service Configs (V1 + V2 merged)

**Purpose**: Merge service configuration from both V1 and V2, prioritizing V2 when both exist

```sql
-- Transform and merge service configs from V1 and V2
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v1_id, legacy_v2_id
    FROM menuca_v3.restaurants
),
v1_configs AS (
    SELECT 
        rm.v3_id as restaurant_id,
        CASE v1.delivery WHEN '1' THEN true ELSE false END as delivery_enabled,
        v1.delivery_time as delivery_time_minutes,
        NULL::NUMERIC(10,2) as delivery_min_order,
        CASE v1.takeout WHEN '1' THEN true ELSE false END as takeout_enabled,
        v1.takeout_time as takeout_time_minutes,
        false as takeout_discount_enabled,
        NULL::VARCHAR(20) as takeout_discount_type,
        NULL::NUMERIC(10,2) as takeout_discount_value,
        false as allow_preorders,
        NULL::INTEGER as preorder_time_frame_hours,
        false as is_bilingual,
        'en'::VARCHAR(5) as default_language,
        false as accepts_tips,
        false as requires_phone,
        'v1' as source_system
    FROM staging.v1_restaurants_service_flags v1
    JOIN restaurant_mapping rm ON rm.legacy_v1_id = v1.id
),
v2_configs AS (
    SELECT 
        rm.v3_id as restaurant_id,
        CASE v2.delivery WHEN 'y' THEN true ELSE false END as delivery_enabled,
        v2.delivery_time as delivery_time_minutes,
        v2.min_delivery as delivery_min_order,
        CASE v2.takeout WHEN 'y' THEN true ELSE false END as takeout_enabled,
        v2.takeout_time as takeout_time_minutes,
        CASE v2.takeout_discount WHEN 'y' THEN true ELSE false END as takeout_discount_enabled,
        CASE v2.takeout_remove_type 
            WHEN 'p' THEN 'percentage'
            WHEN 'v' THEN 'fixed'
        END as takeout_discount_type,
        COALESCE(v2.takeout_remove, v2.takeout_remove_percent, v2.takeout_remove_value) as takeout_discount_value,
        CASE v2.allow_preorders WHEN 'y' THEN true ELSE false END as allow_preorders,
        v2.preorders_time_frame as preorder_time_frame_hours,
        CASE v2.bilingual WHEN 'y' THEN true ELSE false END as is_bilingual,
        CASE CAST(v2.default_language AS INTEGER)
            WHEN 1 THEN 'en'
            WHEN 2 THEN 'fr'
            ELSE 'en'
        END as default_language,
        true as accepts_tips,
        false as requires_phone,
        'v2' as source_system
    FROM staging.v2_restaurants_configs v2
    JOIN restaurant_mapping rm ON rm.legacy_v2_id = v2.restaurant_id
)
INSERT INTO menuca_v3.restaurant_service_configs 
    (restaurant_id, delivery_enabled, delivery_time_minutes, delivery_min_order,
     takeout_enabled, takeout_time_minutes, takeout_discount_enabled,
     takeout_discount_type, takeout_discount_value, allow_preorders, 
     preorder_time_frame_hours, is_bilingual, default_language, 
     accepts_tips, requires_phone, created_at)
SELECT 
    COALESCE(v2.restaurant_id, v1.restaurant_id) as restaurant_id,
    COALESCE(v2.delivery_enabled, v1.delivery_enabled) as delivery_enabled,
    COALESCE(v2.delivery_time_minutes, v1.delivery_time_minutes) as delivery_time_minutes,
    COALESCE(v2.delivery_min_order, v1.delivery_min_order) as delivery_min_order,
    COALESCE(v2.takeout_enabled, v1.takeout_enabled) as takeout_enabled,
    COALESCE(v2.takeout_time_minutes, v1.takeout_time_minutes) as takeout_time_minutes,
    COALESCE(v2.takeout_discount_enabled, v1.takeout_discount_enabled) as takeout_discount_enabled,
    COALESCE(v2.takeout_discount_type, v1.takeout_discount_type) as takeout_discount_type,
    COALESCE(v2.takeout_discount_value, v1.takeout_discount_value) as takeout_discount_value,
    COALESCE(v2.allow_preorders, v1.allow_preorders) as allow_preorders,
    COALESCE(v2.preorder_time_frame_hours, v1.preorder_time_frame_hours) as preorder_time_frame_hours,
    COALESCE(v2.is_bilingual, v1.is_bilingual) as is_bilingual,
    COALESCE(v2.default_language, v1.default_language) as default_language,
    COALESCE(v2.accepts_tips, v1.accepts_tips) as accepts_tips,
    COALESCE(v2.requires_phone, v1.requires_phone) as requires_phone,
    NOW()
FROM v1_configs v1
FULL OUTER JOIN v2_configs v2 ON v2.restaurant_id = v1.restaurant_id;

-- Mark as processed
UPDATE staging.v1_restaurants_service_flags SET is_processed = TRUE;
UPDATE staging.v2_restaurants_configs SET is_processed = TRUE;
```

#### 4.5 Transform & Load Time Periods

**Purpose**: Load named time windows (Lunch, Dinner) for menu item availability

```sql
-- Transform V2 time periods into V3 format
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_time_periods 
    (restaurant_id, name, time_start, time_stop, is_enabled, display_order, created_at)
SELECT 
    rm.v3_id,
    s.name,
    s.start,  -- CSV column is 'start' not 'time_start'
    s.stop,   -- CSV column is 'stop' not 'time_stop'
    CASE s.enabled WHEN 'y' THEN true ELSE false END,
    0,  -- Default display_order (can be updated later by admin)
    NOW()
FROM staging.v2_restaurants_time_periods s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id
WHERE s.start IS NOT NULL
AND s.stop IS NOT NULL
AND s.stop > s.start;

-- Mark as processed
UPDATE staging.v2_restaurants_time_periods
SET is_processed = TRUE, notes = 'Loaded to V3';
```

---

### Phase 5: Verification & Data Quality Checks ⏳ AFTER PHASE 4

**Purpose**: Verify data integrity, completeness, and identify any issues before finalizing

---

#### 5.1 Row Count Verification

**Check that data loaded correctly from staging to V3**

```sql
-- Compare staging vs V3 row counts
SELECT 
    'V1 Schedules (Staging)' as source,
    COUNT(*) as count
FROM staging.v1_restaurants_schedule_normalized
WHERE is_processed = TRUE

UNION ALL

SELECT 'V2 Schedules (Staging)', COUNT(*)
FROM staging.v2_restaurants_schedule
WHERE is_processed = TRUE

UNION ALL

SELECT 'V3 Schedules (Final)', COUNT(*)
FROM menuca_v3.restaurant_schedules

UNION ALL

SELECT 'V2 Special Schedules (Staging)', COUNT(*)
FROM staging.v2_restaurants_special_schedule
WHERE is_processed = TRUE

UNION ALL

SELECT 'V3 Special Schedules (Final)', COUNT(*)
FROM menuca_v3.restaurant_special_schedules

UNION ALL

SELECT 'V3 Service Configs (Final)', COUNT(*)
FROM menuca_v3.restaurant_service_configs

UNION ALL

SELECT 'V2 Time Periods (Staging)', COUNT(*)
FROM staging.v2_restaurants_time_periods
WHERE is_processed = TRUE

UNION ALL

SELECT 'V3 Time Periods (Final)', COUNT(*)
FROM menuca_v3.restaurant_time_periods;
```

**Expected Results**:
- V3 Schedules should be close to V1 + V2 combined (with some overlap/conflicts resolved)
- V3 Special Schedules = V2 Staging count (84 rows expected)
- V3 Service Configs = Number of restaurants with configs
- V3 Time Periods = V2 Staging count (8 rows expected)

---

#### 5.2 Data Integrity Checks

**Verify no orphaned records or constraint violations**

```sql
-- Check for orphaned schedules (no restaurant exists)
SELECT 'Orphaned Schedules' as check_name, COUNT(*) as issue_count
FROM menuca_v3.restaurant_schedules s
LEFT JOIN menuca_v3.restaurants r ON r.id = s.restaurant_id
WHERE r.id IS NULL

UNION ALL

-- Check for invalid day ranges
SELECT 'Invalid Day Ranges', COUNT(*)
FROM menuca_v3.restaurant_schedules
WHERE day_start NOT BETWEEN 1 AND 7
   OR day_stop NOT BETWEEN 1 AND 7

UNION ALL

-- Check for NULL times
SELECT 'NULL Time Fields', COUNT(*)
FROM menuca_v3.restaurant_schedules
WHERE time_start IS NOT NULL
AND time_stop IS NULL

UNION ALL

-- Check special schedules date validity
SELECT 'Invalid Special Date Ranges', COUNT(*)
FROM menuca_v3.restaurant_special_schedules
WHERE date_stop < date_start

UNION ALL

-- Check for duplicate schedules (same restaurant, type, day, times)
SELECT 'Duplicate Schedules', COUNT(*) - COUNT(DISTINCT (restaurant_id, type, day_start, time_start, time_stop))
FROM menuca_v3.restaurant_schedules;
```

**Expected**: All checks should return `0` issues

---

#### 5.3 Business Logic Validation

**Verify restaurants have consistent configuration**

```sql
-- Restaurants with no schedules (should investigate)
SELECT 
    'Restaurants with no schedules' as check_name,
    COUNT(*) as count,
    array_agg(r.id) as restaurant_ids
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
WHERE s.id IS NULL
AND r.status IN ('active', 'pending')
GROUP BY check_name

UNION ALL

-- Restaurants with delivery enabled but no delivery schedule
SELECT 
    'Delivery enabled, no delivery schedule',
    COUNT(*),
    array_agg(c.restaurant_id)
FROM menuca_v3.restaurant_service_configs c
LEFT JOIN menuca_v3.restaurant_schedules s 
    ON s.restaurant_id = c.restaurant_id AND s.type = 'delivery'
WHERE c.delivery_enabled = true
AND s.id IS NULL
GROUP BY check_name

UNION ALL

-- Restaurants with takeout enabled but no takeout schedule
SELECT 
    'Takeout enabled, no takeout schedule',
    COUNT(*),
    array_agg(c.restaurant_id)
FROM menuca_v3.restaurant_service_configs c
LEFT JOIN menuca_v3.restaurant_schedules s 
    ON s.restaurant_id = c.restaurant_id AND s.type = 'takeout'
WHERE c.takeout_enabled = true
AND s.id IS NULL;
```

---

#### 5.4 Sample Data Spot Checks

**Manual verification of specific restaurants**

```sql
-- Check restaurants with time periods have correct data
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT s.id) as schedule_count,
    COUNT(DISTINCT sp.id) as special_schedule_count,
    CASE WHEN c.id IS NOT NULL THEN 'Yes' ELSE 'No' END as has_config,
    COUNT(DISTINCT tp.id) as time_period_count,
    json_agg(DISTINCT tp.name) as time_period_names
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_special_schedules sp ON sp.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_service_configs c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_time_periods tp ON tp.restaurant_id = r.id
WHERE r.legacy_v2_id IN (1603, 1634, 1656, 1665, 1641, 1668)  -- Known restaurants with time periods
GROUP BY r.id, r.name, c.id
ORDER BY r.id;
```

**Expected**: All 7 restaurants (1603, 1634, 1656, 1665, 1641, 1668) should have time periods

---

#### 5.5 Data Quality Report

**Generate summary report for stakeholders**

```sql
SELECT 
    'Total Restaurants' as metric,
    COUNT(*) as value
FROM menuca_v3.restaurants

UNION ALL

SELECT 'Restaurants with Schedules', COUNT(DISTINCT restaurant_id)
FROM menuca_v3.restaurant_schedules

UNION ALL

SELECT 'Total Schedule Entries', COUNT(*)
FROM menuca_v3.restaurant_schedules

UNION ALL

SELECT 'Delivery Schedules', COUNT(*)
FROM menuca_v3.restaurant_schedules WHERE type = 'delivery'

UNION ALL

SELECT 'Takeout Schedules', COUNT(*)
FROM menuca_v3.restaurant_schedules WHERE type = 'takeout'

UNION ALL

SELECT 'Special Schedules', COUNT(*)
FROM menuca_v3.restaurant_special_schedules

UNION ALL

SELECT 'Service Configs', COUNT(*)
FROM menuca_v3.restaurant_service_configs

UNION ALL

SELECT 'Time Periods', COUNT(*)
FROM menuca_v3.restaurant_time_periods

UNION ALL

SELECT 'Restaurants with Delivery', COUNT(*)
FROM menuca_v3.restaurant_service_configs WHERE delivery_enabled = true

UNION ALL

SELECT 'Restaurants with Takeout', COUNT(*)
FROM menuca_v3.restaurant_service_configs WHERE takeout_enabled = true;
```

---

### Phase 6: Final Sign-Off ⏳ PENDING

#### 6.1 Migrate Regular Schedules
```sql
-- Map restaurant IDs and insert
WITH restaurant_mapping AS (
    SELECT 
        id as v3_id,
        legacy_v1_id,
        legacy_v2_id
    FROM menuca_v3.restaurants
)
INSERT INTO menuca_v3.restaurant_schedules 
    (restaurant_id, type, day_start, day_stop, time_start, time_stop, is_enabled, created_at)
SELECT DISTINCT
    COALESCE(
        (SELECT v3_id FROM restaurant_mapping WHERE legacy_v2_id = s.restaurant_id),
        (SELECT v3_id FROM restaurant_mapping WHERE legacy_v1_id = s.restaurant_id)
    ),
    s.type::public.service_type,
    s.day_start,
    s.day_stop,
    s.time_start,
    s.time_stop,
    COALESCE(s.is_enabled, true),
    NOW()
FROM menuca_v3_staging.restaurant_schedules_staging s
WHERE notes NOT LIKE '%SUPERSEDED%'
AND s.day_start BETWEEN 1 AND 7
AND s.day_stop BETWEEN 1 AND 7
AND s.time_start IS NOT NULL
AND s.time_stop IS NOT NULL
-- Ensure restaurant exists
AND EXISTS (
    SELECT 1 FROM menuca_v3.restaurants r
    WHERE r.id = COALESCE(
        (SELECT v3_id FROM restaurant_mapping WHERE legacy_v2_id = s.restaurant_id),
        (SELECT v3_id FROM restaurant_mapping WHERE legacy_v1_id = s.restaurant_id)
    )
);
```

#### 6.2 Migrate Special Schedules
```sql
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_special_schedules 
    (restaurant_id, schedule_type, date_start, date_stop, 
     time_start, time_stop, reason, apply_to, notes, is_active, created_at)
SELECT 
    rm.v3_id,
    s.schedule_type,
    s.date_start,
    s.date_stop,
    s.time_start,
    s.time_stop,
    s.reason,
    s.apply_to,
    s.notes,
    COALESCE(s.is_active, true),
    NOW()
FROM menuca_v3_staging.special_schedules_staging s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id
WHERE s.date_start IS NOT NULL
AND s.date_stop IS NOT NULL;
```

#### 6.3 Migrate Service Configs
```sql
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_service_configs 
    (restaurant_id, delivery_enabled, delivery_time_minutes, delivery_min_order,
     takeout_enabled, takeout_time_minutes, takeout_discount_enabled,
     takeout_discount_type, takeout_discount_value, allow_preorders, 
     preorder_time_frame_hours, is_bilingual, default_language, created_at)
SELECT 
    rm.v3_id,
    COALESCE(s.delivery_enabled, false),
    s.delivery_time_minutes,
    s.delivery_min_order,
    COALESCE(s.takeout_enabled, false),
    s.takeout_time_minutes,
    COALESCE(s.takeout_discount_enabled, false),
    s.takeout_discount_type,
    s.takeout_discount_value,
    COALESCE(s.allow_preorders, false),
    s.preorder_time_frame_hours,
    COALESCE(s.is_bilingual, false),
    COALESCE(s.default_language, 'en')
FROM menuca_v3_staging.service_configs_staging s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id;
```

#### 6.4 Migrate Time Periods
```sql
WITH restaurant_mapping AS (
    SELECT id as v3_id, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v2_id IS NOT NULL
)
INSERT INTO menuca_v3.restaurant_time_periods 
    (restaurant_id, name, time_start, time_stop, is_enabled, display_order, created_at)
SELECT 
    rm.v3_id,
    s.name,
    s.time_start,
    s.time_stop,
    COALESCE(s.is_enabled, true),
    COALESCE(s.display_order, 0),
    NOW()
FROM menuca_v3_staging.time_periods_staging s
JOIN restaurant_mapping rm ON rm.legacy_v2_id = s.restaurant_id
WHERE s.time_start IS NOT NULL
AND s.time_stop IS NOT NULL;
```

---

## Verification & Validation

### 1. Record Count Verification
```sql
-- Regular schedules
SELECT 'V1 Source' as source, COUNT(*) as cnt 
FROM menuca_v1.restaurants_schedule_normalized
UNION ALL
SELECT 'V2 Source', COUNT(*) 
FROM menuca_v2.restaurants_schedule
UNION ALL
SELECT 'Staging', COUNT(*) 
FROM menuca_v3_staging.restaurant_schedules_staging 
WHERE notes NOT LIKE '%SUPERSEDED%'
UNION ALL
SELECT 'V3 Target', COUNT(*) 
FROM menuca_v3.restaurant_schedules;

-- Special schedules
SELECT 'V2 Source' as source, COUNT(*) as cnt 
FROM menuca_v2.restaurants_special_schedule
UNION ALL
SELECT 'V3 Target', COUNT(*) 
FROM menuca_v3.restaurant_special_schedules;

-- Service configs
SELECT 'V2 Source' as source, COUNT(*) as cnt 
FROM menuca_v2.restaurants_configs
UNION ALL
SELECT 'V3 Target', COUNT(*) 
FROM menuca_v3.restaurant_service_configs;

-- Time periods
SELECT 'V2 Source' as source, COUNT(*) as cnt 
FROM menuca_v2.restaurants_time_periods
UNION ALL
SELECT 'V3 Target', COUNT(*) 
FROM menuca_v3.restaurant_time_periods;
```

### 2. Data Integrity Checks
```sql
-- Check for orphaned schedules
SELECT 'Orphaned Schedules' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_schedules s
LEFT JOIN menuca_v3.restaurants r ON r.id = s.restaurant_id
WHERE r.id IS NULL;

-- Check for invalid day ranges
SELECT 'Invalid Days' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_schedules
WHERE day_start NOT BETWEEN 1 AND 7
   OR day_stop NOT BETWEEN 1 AND 7;

-- Check for null times
SELECT 'Null Times' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_schedules
WHERE time_start IS NULL OR time_stop IS NULL;

-- Check special schedules date validity
SELECT 'Invalid Special Dates' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_special_schedules
WHERE date_stop < date_start;
```

### 3. Business Logic Validation
```sql
-- Restaurants with no schedules (should investigate)
SELECT 'No Schedules' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
WHERE s.id IS NULL
AND r.status IN ('active', 'pending');

-- Restaurants with delivery enabled but no delivery schedule
SELECT 'Delivery Enabled No Schedule' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_service_configs c
LEFT JOIN menuca_v3.restaurant_schedules s 
    ON s.restaurant_id = c.restaurant_id AND s.type = 'delivery'
WHERE c.delivery_enabled = true
AND s.id IS NULL;

-- Restaurants with takeout enabled but no takeout schedule
SELECT 'Takeout Enabled No Schedule' as check_name, COUNT(*) as cnt
FROM menuca_v3.restaurant_service_configs c
LEFT JOIN menuca_v3.restaurant_schedules s 
    ON s.restaurant_id = c.restaurant_id AND s.type = 'takeout'
WHERE c.takeout_enabled = true
AND s.id IS NULL;

-- Check time periods are referenced correctly
SELECT 'Time Periods' as check_name, COUNT(DISTINCT restaurant_id) as restaurants_with_periods
FROM menuca_v3.restaurant_time_periods;
```

### 4. Sample Data Spot Checks
```sql
-- Check a few restaurants have complete data
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT s.id) as schedule_count,
    COUNT(DISTINCT sp.id) as special_schedule_count,
    CASE WHEN c.id IS NOT NULL THEN 'Yes' ELSE 'No' END as has_config,
    COUNT(DISTINCT tp.id) as time_period_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_special_schedules sp ON sp.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_service_configs c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_time_periods tp ON tp.restaurant_id = r.id
WHERE r.status = 'active'
GROUP BY r.id, r.name, c.id
LIMIT 10;
```

---

## Key Decisions

### 1. Service Type Mapping ✅
- **Mapping**: `'d'` → `'delivery'`, `'t'` → `'takeout'`
- **Implementation**: CASE statements in transformation queries
- **Enum**: `public.service_type` confirmed with values 'delivery' and 'takeout'

### 2. Conflict Resolution ✅
- **Decision**: V2 data takes precedence over V1
- **Rationale**: V2 is newer and represents current system state
- **Implementation**: 
  - Load V1 first
  - Load V2 with UPSERT logic
  - Mark V1 conflicts as superseded

### 3. Timezone Handling ✅
- **Decision**: Option C - Local Time + Timezone Column
- **Implementation**:
  - Store all TIME values as local time (no conversion)
  - `cities` table has `timezone` column (e.g., 'America/Toronto')
  - Restaurants link to city → city has timezone
  - Application converts to/from UTC when checking if restaurant is open
- **Why**: Schedules are inherently local ("We open at 9am")
- **Migration Impact**: No time conversion needed, times stay as-is

### 4. Special Schedules ✅
- **V1 Exclusion**: Only 5 rows of historical data (2016, 2020-2021)
- **V2 Inclusion**: 134 rows with current and relevant data
- **Decision**: Use V2 special schedules exclusively

### 5. Time Periods ✅
- **Decision**: Must migrate - menu items reference these periods
- **Usage**: 7 restaurants (IDs: 1603, 1634, 1656, 1665, 1641, 1668)
- **Purpose**: Named time windows for menu item availability

### 6. Delivery Partner Schedule ➡️
- **Table**: `restaurants_delivery_schedule` (7 rows for restaurant 1635)
- **Decision**: Move to Delivery Operations entity
- **Rationale**: This is delivery partner availability, not restaurant hours

---

## Success Criteria

### Mandatory Requirements
- [x] All 4 V3 tables created with proper schema ✅
- [ ] All regular schedules migrated from V1 + V2 (deduplicated)
- [ ] All V2 special schedules migrated
- [ ] All service configs migrated
- [ ] All 15 time period records migrated
- [ ] Zero orphaned schedules (all reference valid restaurants)
- [ ] All constraints pass (day ranges 1-7, time validations)
- [ ] Service type enum properly mapped ('d'/'t' → 'delivery'/'takeout')
- [ ] Boolean conversions correct ('y'/'n' → true/false)
- [ ] Cross-entity validation: Menu items can reference time periods

### Quality Checks
- [ ] Row counts match expectations (source vs target with deduplication)
- [ ] No data loss (all enabled/active schedules migrated)
- [ ] Business rules validated (delivery-enabled restaurants have delivery schedules)
- [ ] Performance acceptable (queries < 100ms)
- [ ] Application functions correctly with new schema

---

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Data Analysis | 1-2 days | ✅ Complete |
| Schema Creation | 1 day | ✅ Complete |
| Data Extraction & Staging | 2-3 days | ⏳ Next |
| Validation & Testing | 2-3 days | ⏳ Pending |
| Final Migration | 1 day | ⏳ Pending |
| Post-Migration Verification | 1 day | ⏳ Pending |
| **Total** | **6-8 days** | 🟢 On Track |

---

## References

**Related Documentation**:
- Core business entities: `../core-business-entities.md`
- Migration tracking: `../migration-steps.md`
- V3 schema file: `Database/Legacy schemas/Menuca v3 schema/menuca_v3.sql`

**Data Sources**:
- V1 normalized dumps: `Database/Service Configuration & Schedules/dumps/`
- V2 source database: menuca_v2

---

**Document Version**: 3.0 (Consolidated)  
**Last Updated**: 2025-10-03  
**Status**: ✅ Ready for ETL execution

