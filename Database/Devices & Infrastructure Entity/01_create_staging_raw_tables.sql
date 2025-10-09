-- ============================================================================
-- DEVICES & INFRASTRUCTURE ENTITY - PHASE 2: RAW DATA STAGING
-- ============================================================================
-- Purpose: Create staging tables to hold raw V1/V2 tablets data
-- Date: 2025-10-09
-- Source: menuca_v1.tablets (894 rows)
-- Target: staging.v1_tablets
-- ============================================================================

-- Create staging schema if not exists
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- TABLE: staging.v1_tablets
-- ============================================================================
-- Purpose: Hold raw V1 tablets data with exact structure from MySQL
-- Source: /Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql
-- Rows: 894
-- ============================================================================

DROP TABLE IF EXISTS staging.v1_tablets CASCADE;

CREATE TABLE staging.v1_tablets (
  -- Primary Key
  id INTEGER PRIMARY KEY,
  
  -- Device Identification
  designator VARCHAR(255) NOT NULL,
  key BYTEA NOT NULL, -- Binary device key (VARBINARY 20 from MySQL)
  
  -- Relationships
  restaurant INTEGER NOT NULL DEFAULT 0,
  
  -- Device Capabilities (tinyint from MySQL)
  printing SMALLINT NOT NULL DEFAULT 0,
  config_edit SMALLINT NOT NULL DEFAULT 0,
  v2 SMALLINT NOT NULL DEFAULT 0, -- V2 protocol support flag
  
  -- Version Information
  fw_ver SMALLINT NOT NULL DEFAULT 0, -- Firmware version
  sw_ver SMALLINT NOT NULL DEFAULT 0, -- Software version
  
  -- Device Status
  desynced SMALLINT NOT NULL DEFAULT 0, -- Out of sync flag
  last_boot INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  last_check INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  
  -- Audit Fields (Unix timestamps)
  created_at INTEGER NOT NULL DEFAULT 0,
  modified_at INTEGER NOT NULL DEFAULT 0
);

-- Indexes for staging (lightweight, for verification queries)
CREATE INDEX idx_staging_v1_tablets_restaurant ON staging.v1_tablets(restaurant);
CREATE INDEX idx_staging_v1_tablets_designator ON staging.v1_tablets(designator);

-- Comments
COMMENT ON TABLE staging.v1_tablets IS 'Raw V1 tablets data from menuca_v1.tablets (894 rows)';
COMMENT ON COLUMN staging.v1_tablets.key IS 'Binary device key from MySQL VARBINARY(20)';
COMMENT ON COLUMN staging.v1_tablets.v2 IS 'V2 protocol support flag (1=yes, 0=no)';
COMMENT ON COLUMN staging.v1_tablets.last_boot IS 'Unix timestamp of last device boot';
COMMENT ON COLUMN staging.v1_tablets.last_check IS 'Unix timestamp of last check-in';

-- ============================================================================
-- TABLE: staging.v2_tablets (PLACEHOLDER - Need dump from user)
-- ============================================================================
-- Purpose: Hold raw V2 tablets data if dump becomes available
-- Source: menuca_v2.tablets (~87 rows estimated)
-- Status: ON HOLD - Need dump from Santiago
-- ============================================================================

DROP TABLE IF EXISTS staging.v2_tablets CASCADE;

CREATE TABLE staging.v2_tablets (
  -- Primary Key
  id INTEGER PRIMARY KEY,
  
  -- Device Identification
  designator VARCHAR(255) NOT NULL,
  key BYTEA NOT NULL, -- Binary device key
  
  -- Relationships
  restaurant INTEGER NOT NULL DEFAULT 0,
  
  -- Device Capabilities
  printing SMALLINT NOT NULL DEFAULT 0,
  config_edit SMALLINT NOT NULL DEFAULT 0,
  -- NOTE: V2 does NOT have 'v2' field (will infer TRUE during transform)
  
  -- Version Information
  fw_ver SMALLINT NOT NULL DEFAULT 0,
  sw_ver SMALLINT NOT NULL DEFAULT 0,
  
  -- Device Status
  desynced SMALLINT NOT NULL DEFAULT 0,
  last_boot INTEGER NOT NULL DEFAULT 0,
  last_check INTEGER NOT NULL DEFAULT 0, -- NOTE: V2 uses signed int
  
  -- Audit Fields
  created_at INTEGER NOT NULL DEFAULT 0,
  modified_at INTEGER NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX idx_staging_v2_tablets_restaurant ON staging.v2_tablets(restaurant);
CREATE INDEX idx_staging_v2_tablets_designator ON staging.v2_tablets(designator);

-- Comments
COMMENT ON TABLE staging.v2_tablets IS 'Raw V2 tablets data from menuca_v2.tablets (~87 rows) - NEEDS DUMP';
COMMENT ON COLUMN staging.v2_tablets.key IS 'Binary device key from MySQL VARBINARY(20)';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Query 1: Count V1 tablets
-- Expected: 0 (before load), 894 (after load)
SELECT 'V1 Tablets' AS source, COUNT(*) AS row_count
FROM staging.v1_tablets;

-- Query 2: Count V2 tablets
-- Expected: 0 (before load), ~87 (after load if dump provided)
SELECT 'V2 Tablets' AS source, COUNT(*) AS row_count
FROM staging.v2_tablets;

-- Query 3: Sample V1 data
SELECT id, designator, restaurant, printing, v2, fw_ver, sw_ver
FROM staging.v1_tablets
ORDER BY id
LIMIT 10;

-- Query 4: Check for NULL keys (should be 0)
SELECT COUNT(*) AS null_keys
FROM staging.v1_tablets
WHERE key IS NULL;

-- Query 5: Restaurant ID distribution
SELECT 
  CASE 
    WHEN restaurant = 0 THEN 'Test/Unassigned'
    ELSE 'Assigned'
  END AS restaurant_status,
  COUNT(*) AS device_count
FROM staging.v1_tablets
GROUP BY restaurant_status;

-- ============================================================================
-- EXECUTION SUMMARY
-- ============================================================================
/*
PHASE 2 - STEP 1 COMPLETE: Staging tables created

Next Steps:
1. Load V1 tablets dump (894 rows) via MCP
2. Verify row count = 894
3. Check BLOB field integrity
4. Proceed to Phase 3: BLOB Deserialization

Tables Created:
- staging.v1_tablets (ready for load)
- staging.v2_tablets (placeholder, needs dump)

Status: ✅ Ready for data load
*/
-- ============================================================================

