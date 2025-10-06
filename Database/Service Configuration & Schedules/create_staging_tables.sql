-- ============================================================================
-- Service Configuration & Schedules - Staging Tables
-- ============================================================================
-- Created: 2025-10-04
-- Purpose: Staging tables for ETL process from V1/V2 to V3
-- Schema: staging (NOT menuca_v3_staging)
-- ============================================================================

-- Ensure staging schema exists
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- 1. STAGING: V1 Regular Schedules (restaurants_schedule_normalized)
-- ============================================================================
-- CSV: menuca_v1_restaurants_schedule_normalized.csv (6,341 rows)
-- Columns: id, restaurant_id, day_start, time_start, day_stop, time_stop, type, enabled, created_at, updated_at
-- ============================================================================
DROP TABLE IF EXISTS staging.v1_restaurants_schedule_normalized CASCADE;

CREATE TABLE staging.v1_restaurants_schedule_normalized (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id
    restaurant_id INTEGER,                -- CSV: restaurant_id
    day_start SMALLINT,                   -- CSV: day_start (1-7 for Mon-Sun)
    time_start TIME,                      -- CSV: time_start (local time)
    day_stop SMALLINT,                    -- CSV: day_stop (1-7 for Mon-Sun)
    time_stop TIME,                       -- CSV: time_stop (local time)
    type VARCHAR(1),                      -- CSV: type ('d' or 't')
    enabled VARCHAR(1),                   -- CSV: enabled ('y' or 'n')
    created_at TIMESTAMP,                 -- CSV: created_at
    updated_at TIMESTAMP,                 -- CSV: updated_at
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v1_sched_restaurant ON staging.v1_restaurants_schedule_normalized(restaurant_id);
CREATE INDEX idx_v1_sched_type ON staging.v1_restaurants_schedule_normalized(type);
CREATE INDEX idx_v1_sched_id ON staging.v1_restaurants_schedule_normalized(id);

COMMENT ON TABLE staging.v1_restaurants_schedule_normalized IS 'Staging: V1 regular delivery/takeout schedules (pre-normalized). Expected: 6,341 rows';

-- ============================================================================
-- 2. STAGING: V1 Special Schedules (restaurants_special_schedule)
-- ============================================================================
-- CSV: menuca_v1_restaurants_special_schedule.csv (5 rows)
-- Columns: id, restaurant_id, special_date, time_start, time_stop, enabled, note, created_at, updated_at
-- ============================================================================
DROP TABLE IF EXISTS staging.v1_restaurants_special_schedule CASCADE;

CREATE TABLE staging.v1_restaurants_special_schedule (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id
    restaurant_id INTEGER,                -- CSV: restaurant_id
    special_date DATE,                    -- CSV: special_date
    time_start TIME,                      -- CSV: time_start (local time)
    time_stop TIME,                       -- CSV: time_stop (local time)
    enabled VARCHAR(1),                   -- CSV: enabled ('y' or 'n')
    note TEXT,                            -- CSV: note (nullable)
    created_at TIMESTAMP,                 -- CSV: created_at
    updated_at TIMESTAMP,                 -- CSV: updated_at
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v1_special_restaurant ON staging.v1_restaurants_special_schedule(restaurant_id);
CREATE INDEX idx_v1_special_id ON staging.v1_restaurants_special_schedule(id);

COMMENT ON TABLE staging.v1_restaurants_special_schedule IS 'Staging: V1 special/holiday schedules (historical data only). Expected: 5 rows';

-- ============================================================================
-- 3. STAGING: V2 Regular Schedules (restaurants_schedule)
-- ============================================================================
-- CSV: menuca_v2_restaurants_schedule.csv (1,984 rows)
-- Columns: id, restaurant_id, day_start, time_start, day_stop, time_stop, type, enabled
-- ============================================================================
DROP TABLE IF EXISTS staging.v2_restaurants_schedule CASCADE;

CREATE TABLE staging.v2_restaurants_schedule (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id
    restaurant_id INTEGER,                -- CSV: restaurant_id
    day_start SMALLINT,                   -- CSV: day_start (1-7 for Mon-Sun)
    time_start TIME,                      -- CSV: time_start (local time)
    day_stop SMALLINT,                    -- CSV: day_stop (1-7 for Mon-Sun)
    time_stop TIME,                       -- CSV: time_stop (local time)
    type VARCHAR(1),                      -- CSV: type ('d' or 't')
    enabled VARCHAR(1),                   -- CSV: enabled ('y' or 'n')
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v2_sched_restaurant ON staging.v2_restaurants_schedule(restaurant_id);
CREATE INDEX idx_v2_sched_type ON staging.v2_restaurants_schedule(type);
CREATE INDEX idx_v2_sched_id ON staging.v2_restaurants_schedule(id);

COMMENT ON TABLE staging.v2_restaurants_schedule IS 'Staging: V2 regular delivery/takeout schedules. Expected: 1,984 rows';

-- ============================================================================
-- 4. STAGING: V2 Special Schedules (restaurants_special_schedule)
-- ============================================================================
-- CSV: menuca_v2_restaurants_special_schedule.csv (84 rows)
-- Columns: id, restaurant_id, date_start, date_stop, schedule_type, reason, apply_to, enabled, added_by, added_at, updated_by, updated_at
-- ============================================================================
DROP TABLE IF EXISTS staging.v2_restaurants_special_schedule CASCADE;

CREATE TABLE staging.v2_restaurants_special_schedule (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id
    restaurant_id INTEGER,                -- CSV: restaurant_id
    date_start TIMESTAMP,                 -- CSV: date_start (start date/time)
    date_stop TIMESTAMP,                  -- CSV: date_stop (stop date/time)
    schedule_type VARCHAR(1),             -- CSV: schedule_type ('c'=closed, 'o'=open)
    reason VARCHAR(50),                   -- CSV: reason (nullable)
    apply_to VARCHAR(1),                  -- CSV: apply_to ('d'=delivery, 't'=takeout)
    enabled VARCHAR(1),                   -- CSV: enabled ('y' or 'n')
    added_by INTEGER,                     -- CSV: added_by (user who added)
    added_at TIMESTAMP,                   -- CSV: added_at (when added)
    updated_by INTEGER,                   -- CSV: updated_by (user who updated)
    updated_at TIMESTAMP,                 -- CSV: updated_at (when updated)
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v2_special_restaurant ON staging.v2_restaurants_special_schedule(restaurant_id);
CREATE INDEX idx_v2_special_type ON staging.v2_restaurants_special_schedule(schedule_type);
CREATE INDEX idx_v2_special_id ON staging.v2_restaurants_special_schedule(id);

COMMENT ON TABLE staging.v2_restaurants_special_schedule IS 'Staging: V2 special/holiday schedules. Expected: 84 rows';

-- ============================================================================
-- 5. STAGING: V2 Time Periods (restaurants_time_periods)
-- ============================================================================
-- CSV: menuca_v2_restaurants_time_periods.csv (8 rows)
-- Columns: id, restaurant_id, name, start, stop, enabled, added_by, added_at, disabled_by, disabled_at
-- ============================================================================
DROP TABLE IF EXISTS staging.v2_restaurants_time_periods CASCADE;

CREATE TABLE staging.v2_restaurants_time_periods (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id
    restaurant_id INTEGER,                -- CSV: restaurant_id
    name VARCHAR(50),                     -- CSV: name (period name: Lunch, Dinner, etc)
    start TIME,                           -- CSV: start (start time)
    stop TIME,                            -- CSV: stop (stop time)
    enabled VARCHAR(1),                   -- CSV: enabled ('y' or 'n')
    added_by INTEGER,                     -- CSV: added_by (user who added)
    added_at TIMESTAMP,                   -- CSV: added_at (when added)
    disabled_by INTEGER,                  -- CSV: disabled_by (user who disabled, nullable)
    disabled_at TIMESTAMP,                -- CSV: disabled_at (when disabled, nullable)
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v2_time_periods_restaurant ON staging.v2_restaurants_time_periods(restaurant_id);
CREATE INDEX idx_v2_time_periods_id ON staging.v2_restaurants_time_periods(id);

COMMENT ON TABLE staging.v2_restaurants_time_periods IS 'Staging: V2 named time windows for menu item availability. Expected: 8 rows';

-- ============================================================================
-- 6. STAGING: V1 Service Flags (from restaurants table)
-- ============================================================================
-- CSV: migration_db_menuca_v1_restaurants_service_flags.csv (847 rows)
-- Columns: id, pickup, delivery, takeout, delivery_time, takeout_time, vacation, vacationStart, vacationStop, suspendOrdering, suspend_operation, suspended_at, comingSoon, overrideAutoSuspend
-- NOTE: CSV 'id' column IS the restaurant_id
-- ============================================================================
DROP TABLE IF EXISTS staging.v1_restaurants_service_flags CASCADE;

CREATE TABLE staging.v1_restaurants_service_flags (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id (THIS IS restaurant_id)
    pickup VARCHAR(1),                    -- CSV: pickup ('1' or '0')
    delivery VARCHAR(1),                  -- CSV: delivery ('1' or '0')
    takeout VARCHAR(1),                   -- CSV: takeout ('1' or '0')
    delivery_time INTEGER,                -- CSV: delivery_time (minutes)
    takeout_time INTEGER,                 -- CSV: takeout_time (minutes)
    vacation VARCHAR(1),                  -- CSV: vacation ('y' or 'n')
    "vacationStart" VARCHAR(20),          -- CSV: vacationStart (as string, handles '0000-00-00')
    "vacationStop" VARCHAR(20),           -- CSV: vacationStop (as string, handles '0000-00-00')
    "suspendOrdering" VARCHAR(1),         -- CSV: suspendOrdering ('y' or 'n')
    suspend_operation VARCHAR(1),         -- CSV: suspend_operation ('1' or '0')
    suspended_at VARCHAR(30),             -- CSV: suspended_at (as string, handles '0000-00-00 00:00:00')
    "comingSoon" VARCHAR(1),              -- CSV: comingSoon ('y' or 'n')
    "overrideAutoSuspend" VARCHAR(1),     -- CSV: overrideAutoSuspend ('y' or 'n')
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v1_flags_id ON staging.v1_restaurants_service_flags(id);

COMMENT ON TABLE staging.v1_restaurants_service_flags IS 'Staging: V1 service flags from restaurants table. Expected: 847 rows. Note: id column IS restaurant_id';

-- ============================================================================
-- 7. STAGING: V2 Service Flags (from restaurants table)
-- ============================================================================
-- CSV: migration_db_menuca_v2_restaurants_service_flags.csv (629 rows)
-- Columns: id, suspend_operation, suspended_at, coming_soon, vacation, vacation_start, vacation_stop, suspend_ordering, suspend_ordering_start, suspend_ordering_stop, active, pending
-- NOTE: CSV 'id' column IS the restaurant_id
-- ============================================================================
DROP TABLE IF EXISTS staging.v2_restaurants_service_flags CASCADE;

CREATE TABLE staging.v2_restaurants_service_flags (
    staging_id BIGSERIAL PRIMARY KEY,
    -- Source data columns (EXACT match to CSV headers)
    id INTEGER,                           -- CSV: id (THIS IS restaurant_id)
    suspend_operation VARCHAR(10),        -- CSV: suspend_operation ('0', '1', '2')
    suspended_at VARCHAR(30),             -- CSV: suspended_at (as string, handles '0000-00-00 00:00:00')
    coming_soon VARCHAR(10),              -- CSV: coming_soon ('1', '2')
    vacation VARCHAR(10),                 -- CSV: vacation ('2', etc.)
    vacation_start VARCHAR(20),           -- CSV: vacation_start (as string, handles '0000-00-00')
    vacation_stop VARCHAR(20),            -- CSV: vacation_stop (as string, handles '0000-00-00')
    suspend_ordering VARCHAR(10),         -- CSV: suspend_ordering ('2', etc.)
    suspend_ordering_start VARCHAR(30),   -- CSV: suspend_ordering_start (as string, handles '0000-00-00 00:00:00')
    suspend_ordering_stop VARCHAR(30),    -- CSV: suspend_ordering_stop (as string, handles '0000-00-00 00:00:00')
    active VARCHAR(10),                   -- CSV: active ('1', '2')
    pending VARCHAR(10),                  -- CSV: pending ('1', '2')
    -- ETL metadata
    loaded_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    is_processed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_v2_flags_id ON staging.v2_restaurants_service_flags(id);

COMMENT ON TABLE staging.v2_restaurants_service_flags IS 'Staging: V2 service flags from restaurants table. Expected: 629 rows. Note: id column IS restaurant_id';

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================
-- Grant appropriate permissions to application role (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA staging TO app_role;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA staging TO app_role;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Total staging tables created: 7
-- 
-- IMPORTANT: All staging tables have columns that EXACTLY match their CSV files
--            for direct import via Supabase "Import data from CSV"
-- 
-- Table                                      | CSV File                                          | Expected Rows
-- -------------------------------------------|---------------------------------------------------|---------------
-- 1. staging.v1_restaurants_schedule_normalized | menuca_v1_restaurants_schedule_normalized.csv  | 6,341
-- 2. staging.v1_restaurants_special_schedule    | menuca_v1_restaurants_special_schedule.csv     | 5
-- 3. staging.v2_restaurants_schedule            | menuca_v2_restaurants_schedule.csv             | 1,984
-- 4. staging.v2_restaurants_special_schedule    | menuca_v2_restaurants_special_schedule.csv     | 84
-- 5. staging.v2_restaurants_time_periods        | menuca_v2_restaurants_time_periods.csv         | 8
-- 6. staging.v1_restaurants_service_flags       | migration_db_menuca_v1_restaurants_service_flags.csv | 847
-- 7. staging.v2_restaurants_service_flags       | migration_db_menuca_v2_restaurants_service_flags.csv | 629
-- 
-- TOTAL EXPECTED ROWS: 9,898
-- 
-- See: Database/Service Configuration & Schedules/CSV_TO_STAGING_MAPPING.md
--      for detailed column mapping and import instructions
-- ============================================================================


