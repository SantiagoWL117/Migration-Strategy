-- ============================================================================
-- Devices & Infrastructure Entity - Phase 4: Production Load
-- ============================================================================
-- Purpose: Create menuca_v3.devices production table and load from staging
-- Author: AI Agent (Brian)
-- Date: 2025-10-09
-- ============================================================================

-- Ensure menuca_v3 schema exists
CREATE SCHEMA IF NOT EXISTS menuca_v3;

-- Drop if exists for idempotent execution
DROP TABLE IF EXISTS menuca_v3.devices CASCADE;

-- Create production table
CREATE TABLE menuca_v3.devices (
  -- Primary key
  id BIGSERIAL PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT gen_random_uuid(),
  
  -- Legacy tracking
  legacy_v1_id INTEGER,
  legacy_v2_id INTEGER,
  source_version TEXT DEFAULT 'v1',
  
  -- Core device fields
  device_name VARCHAR(255) NOT NULL,
  device_key_hash BYTEA,
  
  -- Foreign keys
  restaurant_id BIGINT,
  
  -- Device configuration
  supports_printing BOOLEAN NOT NULL DEFAULT false,
  allows_config_edit BOOLEAN NOT NULL DEFAULT false,
  is_v2_device BOOLEAN NOT NULL DEFAULT false,
  
  -- Versioning
  firmware_version INTEGER NOT NULL DEFAULT 0,
  software_version INTEGER NOT NULL DEFAULT 0,
  
  -- Status flags
  is_desynced BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  
  -- Timestamps
  last_boot_at TIMESTAMPTZ,
  last_check_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Audit fields
  created_by INTEGER,
  updated_by INTEGER,
  
  -- Constraints
  CONSTRAINT unique_device_uuid UNIQUE (uuid),
  CONSTRAINT unique_device_key UNIQUE (device_key_hash),
  CONSTRAINT unique_legacy_v1_id UNIQUE (legacy_v1_id),
  CONSTRAINT unique_legacy_v2_id UNIQUE (legacy_v2_id),
  CONSTRAINT fk_devices_restaurant 
    FOREIGN KEY (restaurant_id) 
    REFERENCES menuca_v3.restaurants(id) 
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT check_device_name_not_empty 
    CHECK (length(device_name) > 0),
  CONSTRAINT check_firmware_version_non_negative 
    CHECK (firmware_version >= 0),
  CONSTRAINT check_software_version_non_negative 
    CHECK (software_version >= 0)
);

-- Create indexes
CREATE INDEX idx_devices_restaurant ON menuca_v3.devices(restaurant_id);
CREATE INDEX idx_devices_legacy_v1 ON menuca_v3.devices(legacy_v1_id);
CREATE INDEX idx_devices_legacy_v2 ON menuca_v3.devices(legacy_v2_id);
CREATE INDEX idx_devices_device_name ON menuca_v3.devices(device_name);
CREATE INDEX idx_devices_is_active ON menuca_v3.devices(is_active);
CREATE INDEX idx_devices_source_version ON menuca_v3.devices(source_version);

-- Add comments
COMMENT ON TABLE menuca_v3.devices IS 'Consolidated device registry from V1 and V2 tablets';
COMMENT ON COLUMN menuca_v3.devices.device_key_hash IS 'Binary device authentication key (VARBINARY from V1/V2)';
COMMENT ON COLUMN menuca_v3.devices.legacy_v1_id IS 'Original ID from menuca_v1.tablets';
COMMENT ON COLUMN menuca_v3.devices.legacy_v2_id IS 'Original ID from menuca_v2.tablets';

-- ============================================================================
-- Load data from staging
-- ============================================================================

INSERT INTO menuca_v3.devices (
  uuid,
  legacy_v1_id,
  legacy_v2_id,
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
  uuid,
  legacy_v1_id,
  legacy_v2_id,
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
FROM staging.v3_devices
ORDER BY legacy_v1_id NULLS LAST, legacy_v2_id NULLS LAST;

-- ============================================================================
-- Verification
-- ============================================================================

-- Count total devices
SELECT 'Total devices' as metric, COUNT(*) as value 
FROM menuca_v3.devices;

-- Count by source
SELECT source_version, COUNT(*) as device_count
FROM menuca_v3.devices
GROUP BY source_version;

-- FK integrity check
SELECT 
  'Devices with valid restaurant FK' as metric,
  COUNT(*) as value
FROM menuca_v3.devices
WHERE restaurant_id IS NOT NULL;

-- Orphaned devices (no restaurant assigned or orphaned FK)
SELECT 
  'Devices without restaurant' as metric,
  COUNT(*) as value
FROM menuca_v3.devices
WHERE restaurant_id IS NULL;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
