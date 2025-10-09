-- ============================================================================
-- Devices & Infrastructure Entity - Phase 3: Data Transformation
-- ============================================================================
-- Purpose: Transform V1 tablets from staging to V3 format
-- Author: AI Agent (Brian)
-- Date: 2025-10-09
--
-- Key Transformations:
-- 1. Restaurant FK: V1 restaurant.id → V3 restaurants.id (via legacy_v1_id)
-- 2. Boolean conversions: tinyint (0/1) → BOOLEAN
-- 3. Timestamp conversions: Unix int → TIMESTAMPTZ
-- 4. UUID generation for each device
-- 5. Handle orphaned FKs (restaurant 708 → NULL)
-- ============================================================================

-- Drop if exists for idempotent execution
DROP TABLE IF EXISTS staging.v3_devices CASCADE;

-- Create staging table with V3 structure
CREATE TABLE staging.v3_devices (
  -- Primary key
  id BIGSERIAL PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT gen_random_uuid(),
  
  -- Legacy tracking
  legacy_v1_id INTEGER,
  legacy_v2_id INTEGER,
  source_version TEXT DEFAULT 'v1',
  
  -- Core device fields
  device_name VARCHAR(255) NOT NULL,
  device_key_hash BYTEA,  -- Binary device key from V1
  
  -- Foreign keys
  restaurant_id BIGINT,  -- Will resolve to V3 restaurant ID
  
  -- Device configuration
  supports_printing BOOLEAN NOT NULL DEFAULT false,
  allows_config_edit BOOLEAN NOT NULL DEFAULT false,
  is_v2_device BOOLEAN NOT NULL DEFAULT false,
  
  -- Versioning
  firmware_version INTEGER NOT NULL DEFAULT 0,
  software_version INTEGER NOT NULL DEFAULT 0,
  
  -- Status flags
  is_desynced BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps (will be TIMESTAMPTZ)
  last_boot_at TIMESTAMPTZ,
  last_check_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Audit fields
  created_by INTEGER,
  updated_by INTEGER,
  
  -- Constraints
  CONSTRAINT unique_device_key UNIQUE (device_key_hash),
  CONSTRAINT unique_legacy_v1_id UNIQUE (legacy_v1_id)
);

-- Create indexes for performance
CREATE INDEX idx_v3_devices_restaurant ON staging.v3_devices(restaurant_id);
CREATE INDEX idx_v3_devices_legacy_v1 ON staging.v3_devices(legacy_v1_id);
CREATE INDEX idx_v3_devices_device_name ON staging.v3_devices(device_name);

-- ============================================================================
-- Transform and load data from staging.v1_tablets
-- ============================================================================

INSERT INTO staging.v3_devices (
  legacy_v1_id,
  source_version,
  device_name,
  device_key_hash,
  restaurant_id,
  supports_printing,
  allows_config_edit,
  is_v2_device,
  firmware_version,
  software_version,
  is_desynced,
  last_boot_at,
  last_check_at,
  created_at,
  updated_at
)
SELECT
  -- Legacy tracking
  v1.id as legacy_v1_id,
  'v1' as source_version,
  
  -- Core device fields
  v1.designator as device_name,
  v1.key as device_key_hash,
  
  -- FK resolution: V1 restaurant.id → V3 restaurants.id
  -- NULL if restaurant=0 or restaurant doesn't exist in V3
  CASE 
    WHEN v1.restaurant = 0 THEN NULL
    ELSE r.id
  END as restaurant_id,
  
  -- Boolean conversions (tinyint → BOOLEAN)
  (v1.printing = 1) as supports_printing,
  (v1.config_edit = 1) as allows_config_edit,
  (v1.v2 = 1) as is_v2_device,
  
  -- Version numbers (direct copy)
  v1.fw_ver as firmware_version,
  v1.sw_ver as software_version,
  
  -- Status flag
  (v1.desynced = 1) as is_desynced,
  
  -- Timestamp conversions (Unix int → TIMESTAMPTZ)
  -- Use NULL for invalid timestamps (0 or NULL)
  CASE 
    WHEN v1.last_boot = 0 THEN NULL
    ELSE to_timestamp(v1.last_boot)
  END as last_boot_at,
  
  CASE 
    WHEN v1.last_check = 0 THEN NULL
    ELSE to_timestamp(v1.last_check)
  END as last_check_at,
  
  CASE 
    WHEN v1.created_at = 0 THEN NULL
    ELSE to_timestamp(v1.created_at)
  END as created_at,
  
  CASE 
    WHEN v1.modified_at = 0 THEN NULL
    ELSE to_timestamp(v1.modified_at)
  END as updated_at

FROM staging.v1_tablets v1
LEFT JOIN menuca_v3.restaurants r 
  ON v1.restaurant = r.legacy_v1_id
  AND v1.restaurant != 0;

-- ============================================================================
-- Verification queries
-- ============================================================================

-- Count total devices
SELECT COUNT(*) as total_devices FROM staging.v3_devices;

-- Count devices with restaurant assignments
SELECT 
  COUNT(*) as total,
  COUNT(restaurant_id) as with_restaurant,
  COUNT(*) - COUNT(restaurant_id) as without_restaurant
FROM staging.v3_devices;

-- Count by source version
SELECT 
  source_version,
  COUNT(*) as device_count
FROM staging.v3_devices
GROUP BY source_version;

-- Check orphaned restaurant references (should be 1: V1 ID 708)
SELECT 
  v1.id as legacy_v1_id,
  v1.designator as device_name,
  v1.restaurant as v1_restaurant_id,
  v3.restaurant_id as resolved_v3_id
FROM staging.v1_tablets v1
LEFT JOIN staging.v3_devices v3 ON v1.id = v3.legacy_v1_id
WHERE v1.restaurant != 0 
  AND v3.restaurant_id IS NULL;

-- Sample transformed data
SELECT 
  id,
  uuid,
  legacy_v1_id,
  device_name,
  restaurant_id,
  supports_printing,
  is_v2_device,
  last_boot_at,
  created_at
FROM staging.v3_devices
ORDER BY legacy_v1_id
LIMIT 10;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- Expected results:
-- - 894 devices transformed
-- - 376 with restaurant_id (232 unique restaurants)
-- - 518 without restaurant_id (517 with restaurant=0 + 1 orphaned)
-- ============================================================================
