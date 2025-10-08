-- Marketing & Promotions: Direct BLOB Deserialization for V1 Deals
-- Phase 3: Deserialize PHP BLOBs directly in PostgreSQL using plpython3u
-- This approach is faster than external Python processing

-- Note: Since plpython3u may not be available, we'll use a hybrid approach:
-- 1. Export data to process with Python
-- 2. Generate UPDATE statements
-- 3. Execute in batches

-- For now, let's handle the most common patterns directly in SQL
-- and use Python only for complex cases

-- Pattern 1: Handle active_days conversion (day numbers to day names)
-- Pattern 2: Handle active_dates parsing (CSV to JSON array)
-- Pattern 3: Mark empty arrays (a:0:{}) as NULL

-- Let's start with the simpler fields that don't need full PHP deserialization:

-- Update active_dates (CSV parsing - no PHP deserialization needed)
UPDATE staging.v1_deals
SET active_dates_json = 
  CASE 
    WHEN active_dates IS NULL OR active_dates = '' THEN NULL
    ELSE (
      SELECT jsonb_agg(trim(value))
      FROM regexp_split_to_table(active_dates, ',') AS value
      WHERE trim(value) != ''
    )
  END;

-- For the PHP serialized fields (exceptions, active_days, items), 
-- we need Python processing. Let's generate a mapping table first.

-- Create a temporary table to hold deserialization results
CREATE TEMP TABLE IF NOT EXISTS deal_deserialize_temp (
  deal_id INTEGER PRIMARY KEY,
  exceptions_parsed JSONB,
  active_days_parsed JSONB,
  items_parsed JSONB
);

-- The actual deserialization will be done via Python script + batch UPDATEs
-- This file documents the structure for reference

COMMENT ON COLUMN staging.v1_deals.exceptions_json IS 'Deserialized from PHP: array of excluded course/dish IDs';
COMMENT ON COLUMN staging.v1_deals.active_days_json IS 'Deserialized from PHP: ["mon","tue","wed",...]';
COMMENT ON COLUMN staging.v1_deals.items_json IS 'Deserialized from PHP: array of dish IDs';
COMMENT ON COLUMN staging.v1_deals.active_dates_json IS 'Parsed from CSV: array of date strings';

-- Verification query to check progress
SELECT 
  COUNT(*) as total_deals,
  COUNT(exceptions_json) as exceptions_done,
  COUNT(active_days_json) as active_days_done,
  COUNT(items_json) as items_done,
  COUNT(active_dates_json) as active_dates_done,
  ROUND(100.0 * COUNT(active_dates_json) / COUNT(*), 1) as percent_complete
FROM staging.v1_deals;

