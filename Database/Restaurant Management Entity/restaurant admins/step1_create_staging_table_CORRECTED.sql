-- Step 1a: Create Staging Table for V1 restaurant_admins
-- CORRECTED: V1 has NO created_at/updated_at columns
-- V1 has additional columns: showAllStats, fb_token, showOrderManagement, etc.

-- Drop existing staging table if needed
DROP TABLE IF EXISTS staging.v1_restaurant_admin_users CASCADE;

-- Create staging table matching V1 schema
CREATE TABLE staging.v1_restaurant_admin_users (
  -- Core identity
  legacy_admin_id integer PRIMARY KEY,
  legacy_v1_restaurant_id integer,  -- 0 = global admin, >0 = restaurant admin
  
  -- User info
  fname text,
  lname text,
  email text,
  password_hash text,
  
  -- Login tracking
  lastlogin timestamptz,
  login_count integer,
  active_user text,  -- V1: enum('1','0') → will convert to boolean
  
  -- V1-specific settings (NOT in V2/V3)
  show_all_stats text,  -- enum('y','n') → boolean
  fb_token text,  -- Facebook token (may not migrate to V3)
  show_order_management text,  -- enum('y','n') → boolean
  send_statement text,  -- enum('y','n') → boolean
  send_statement_to text,  -- Email for statements
  allow_ar text,  -- enum('y','n') → boolean (Arabic support?)
  show_clients text  -- enum('y','n') → boolean
  
  -- NOTE: BLOB field 'allowed_restaurants' NOT loaded here (Step 5)
  -- NOTE: V1 has NO created_at or updated_at columns!
);

-- Create indexes for lookups
CREATE INDEX idx_v1_admin_restaurant ON staging.v1_restaurant_admin_users(legacy_v1_restaurant_id);
CREATE INDEX idx_v1_admin_email ON staging.v1_restaurant_admin_users(email);

-- Verification comments
COMMENT ON TABLE staging.v1_restaurant_admin_users IS 
  'Staging table for V1 restaurant_admins migration. V1 has NO created_at/updated_at.';

COMMENT ON COLUMN staging.v1_restaurant_admin_users.legacy_v1_restaurant_id IS 
  'V1 restaurant ID. 0=global admin (22 records), >0=restaurant admin (471 records)';

COMMENT ON COLUMN staging.v1_restaurant_admin_users.fb_token IS 
  'Facebook token from V1. May not be needed in V3.';

COMMENT ON COLUMN staging.v1_restaurant_admin_users.send_statement_to IS 
  'Email address where statements should be sent. Maps to V1 sendStatementTo.';

