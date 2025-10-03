-- ============================================================================
-- Step 1: Create Staging Table for V1 restaurant_admins Migration
-- ============================================================================
-- Purpose: Create staging table to hold V1 restaurant_admins data
-- Source: V1 restaurant_admins table ONLY (V2 admin_users is out of scope)
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================

\echo '📋 Creating staging table for V1 restaurant_admins...'
\echo ''

-- Create staging schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS staging;

-- Drop and recreate staging table (idempotent)
DROP TABLE IF EXISTS staging.v1_restaurant_admin_users CASCADE;

CREATE TABLE staging.v1_restaurant_admin_users (
  legacy_admin_id integer,
  legacy_v1_restaurant_id integer,
  user_type text,
  fname text,
  lname text,
  email text,
  password_hash text,
  lastlogin timestamptz,
  login_count integer,
  active_user text,
  send_statement text,
  allowed_restaurants bytea,  -- Store BLOB for optional Step 5
  created_at timestamptz,
  updated_at timestamptz
);

\echo '✅ Staging table created: staging.v1_restaurant_admin_users'
\echo ''
\echo '📝 Next steps:'
\echo '   1. Export V1 restaurant_admins data to CSV'
\echo '   2. Load CSV into staging.v1_restaurant_admin_users using COPY or INSERT'
\echo '   3. Run optional cleanup (see step1b_cleanup_staging.sql)'
\echo ''
\echo 'Example V1 MySQL export command:'
\echo 'mysql -u root -p menuca_v1 -e "SELECT id, restaurant, user_type, fname, lname, email, password, lastlogin, loginCount, activeUser, sendStatement, allowed_restaurants, created_at, updated_at FROM restaurant_admins" > restaurant_admins.csv'
\echo ''
\echo 'Example PostgreSQL COPY command:'
\echo '\COPY staging.v1_restaurant_admin_users FROM ''restaurant_admins.csv'' WITH (FORMAT csv, HEADER true);'
\echo ''




