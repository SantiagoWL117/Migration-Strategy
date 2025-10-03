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

### Phase 2: Data Extraction

#### Extract V1 Data
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

### Phase 3: Create Staging Tables

```sql
-- Staging for regular schedules
CREATE TABLE menuca_v3_staging.restaurant_schedules_staging (
    staging_id BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(10), -- 'v1' or 'v2'
    source_id INTEGER,
    restaurant_id BIGINT,
    type VARCHAR(20),
    day_start SMALLINT,
    day_stop SMALLINT,
    time_start TIME,
    time_stop TIME,
    is_enabled BOOLEAN,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Staging for special schedules
CREATE TABLE menuca_v3_staging.special_schedules_staging (
    staging_id BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(10),
    source_id INTEGER,
    restaurant_id BIGINT,
    schedule_type VARCHAR(20),
    date_start DATE,
    date_stop DATE,
    time_start TIME,
    time_stop TIME,
    reason VARCHAR(50),
    apply_to VARCHAR(20),
    notes TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Staging for service configs
CREATE TABLE menuca_v3_staging.service_configs_staging (
    staging_id BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(10),
    restaurant_id BIGINT,
    delivery_enabled BOOLEAN,
    delivery_time_minutes INTEGER,
    delivery_min_order NUMERIC(10,2),
    takeout_enabled BOOLEAN,
    takeout_time_minutes INTEGER,
    takeout_discount_enabled BOOLEAN,
    takeout_discount_type VARCHAR(20),
    takeout_discount_value NUMERIC(10,2),
    allow_preorders BOOLEAN,
    preorder_time_frame_hours INTEGER,
    is_bilingual BOOLEAN,
    default_language VARCHAR(5),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Staging for time periods
CREATE TABLE menuca_v3_staging.time_periods_staging (
    staging_id BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(10),
    source_id INTEGER,
    restaurant_id BIGINT,
    name VARCHAR(50),
    time_start TIME,
    time_stop TIME,
    is_enabled BOOLEAN,
    display_order INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

### Phase 4: Load Data into Staging

#### 4.1 Load V1 Regular Schedules
```sql
INSERT INTO menuca_v3_staging.restaurant_schedules_staging 
    (source_system, source_id, restaurant_id, type, 
     day_start, day_stop, time_start, time_stop, is_enabled)
SELECT 
    'v1',
    id,
    restaurant_id,
    CASE type
        WHEN 'd' THEN 'delivery'
        WHEN 't' THEN 'takeout'
    END,
    day_start,
    day_stop,
    time_start,
    time_stop,
    CASE enabled WHEN 'y' THEN true ELSE false END
FROM menuca_v1.restaurants_schedule_normalized
WHERE restaurant_id IN (
    SELECT legacy_v1_id 
    FROM menuca_v3.restaurants 
    WHERE legacy_v1_id IS NOT NULL
);
```

#### 4.2 Load V2 Regular Schedules
```sql
INSERT INTO menuca_v3_staging.restaurant_schedules_staging 
    (source_system, source_id, restaurant_id, type, 
     day_start, day_stop, time_start, time_stop, is_enabled)
SELECT 
    'v2',
    id,
    restaurant_id,
    CASE type
        WHEN 'd' THEN 'delivery'
        WHEN 't' THEN 'takeout'
    END,
    day_start,
    day_stop,
    time_start,
    time_stop,
    CASE enabled WHEN 'y' THEN true ELSE false END
FROM menuca_v2.restaurants_schedule
WHERE restaurant_id IN (
    SELECT legacy_v2_id 
    FROM menuca_v3.restaurants 
    WHERE legacy_v2_id IS NOT NULL
);
```

#### 4.3 Load V2 Special Schedules
```sql
INSERT INTO menuca_v3_staging.special_schedules_staging 
    (source_system, source_id, restaurant_id, schedule_type,
     date_start, date_stop, time_start, time_stop, reason, apply_to, is_active)
SELECT 
    'v2',
    id,
    restaurant_id,
    CASE schedule_type
        WHEN 'c' THEN 'closed'
        WHEN 'o' THEN 'open'
        ELSE 'modified'
    END,
    DATE(date_start),
    DATE(date_stop),
    TIME(date_start),
    TIME(date_stop),
    reason,
    CASE apply_to
        WHEN 'd' THEN 'delivery'
        WHEN 't' THEN 'takeout'
        ELSE 'both'
    END,
    CASE enabled WHEN 'y' THEN true ELSE false END
FROM menuca_v2.restaurants_special_schedule
WHERE restaurant_id IN (
    SELECT legacy_v2_id 
    FROM menuca_v3.restaurants 
    WHERE legacy_v2_id IS NOT NULL
);
```

#### 4.4 Load V2 Service Configs
```sql
INSERT INTO menuca_v3_staging.service_configs_staging 
    (source_system, restaurant_id, delivery_enabled, delivery_time_minutes, 
     delivery_min_order, takeout_enabled, takeout_time_minutes, 
     takeout_discount_enabled, takeout_discount_type, takeout_discount_value,
     allow_preorders, preorder_time_frame_hours, is_bilingual, default_language)
SELECT 
    'v2',
    restaurant_id,
    CASE delivery WHEN 'y' THEN true ELSE false END,
    delivery_time,
    min_delivery,
    CASE takeout WHEN 'y' THEN true ELSE false END,
    takeout_time,
    CASE takeout_discount WHEN 'y' THEN true ELSE false END,
    CASE takeout_remove_type 
        WHEN 'p' THEN 'percentage'
        WHEN 'v' THEN 'fixed'
    END,
    COALESCE(takeout_remove, takeout_remove_percent, takeout_remove_value),
    CASE allow_preorders WHEN 'y' THEN true ELSE false END,
    preorders_time_frame,
    CASE bilingual WHEN 'y' THEN true ELSE false END,
    CASE default_language
        WHEN 1 THEN 'en'
        WHEN 2 THEN 'fr'
        ELSE 'en'
    END
FROM menuca_v2.restaurants_configs
WHERE restaurant_id IN (
    SELECT legacy_v2_id 
    FROM menuca_v3.restaurants 
    WHERE legacy_v2_id IS NOT NULL
);
```

#### 4.5 Load V2 Time Periods
```sql
INSERT INTO menuca_v3_staging.time_periods_staging 
    (source_system, source_id, restaurant_id, name, 
     time_start, time_stop, is_enabled, display_order)
SELECT 
    'v2',
    id,
    restaurant_id,
    name,
    time_start,
    time_stop,
    CASE enabled WHEN 'y' THEN true ELSE false END,
    COALESCE(display_order, 0)
FROM menuca_v2.restaurants_time_periods
WHERE restaurant_id IN (
    SELECT legacy_v2_id 
    FROM menuca_v3.restaurants 
    WHERE legacy_v2_id IS NOT NULL
);
```

---

### Phase 5: Handle Conflicts (V2 Wins)

```sql
-- Mark V1 records that conflict with V2 as superseded
UPDATE menuca_v3_staging.restaurant_schedules_staging s1
SET notes = '[SUPERSEDED by V2]'
WHERE source_system = 'v1'
AND EXISTS (
    SELECT 1 
    FROM menuca_v3_staging.restaurant_schedules_staging s2
    WHERE s2.source_system = 'v2'
    AND s2.restaurant_id = s1.restaurant_id
    AND s2.type = s1.type
    AND s2.day_start = s1.day_start
    AND s2.time_start = s1.time_start
    AND s2.time_stop = s1.time_stop
);
```

---

### Phase 6: Load to V3 Tables

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

