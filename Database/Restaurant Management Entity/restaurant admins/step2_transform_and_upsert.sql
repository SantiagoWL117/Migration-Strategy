-- ============================================================================
-- Step 2: Transform and Upsert restaurant_admin_users (IDEMPOTENT)
-- ============================================================================
-- Purpose: Migrate V1 restaurant_admins to menuca_v3.restaurant_admin_users
-- Source: staging.v1_restaurant_admin_users (loaded from V1 data)
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================
-- IMPORTANT: 
-- - Only migrates user_type='r' with restaurant > 0 (restaurant-level admins)
-- - Excludes user_type='g' with restaurant=0 (global admins - handle via junction table)
-- - Deduplicates by (restaurant_id, email) keeping most recent last_login
-- - Upsert key: (restaurant_id, email) per unique constraint
-- ============================================================================

\echo '🚀 Starting restaurant_admin_users migration...'
\echo ''

BEGIN;

-- Ensure unique index exists
CREATE UNIQUE INDEX IF NOT EXISTS u_admin_email_per_restaurant
  ON menuca_v3.restaurant_admin_users (restaurant_id, email);

\echo '✅ Unique constraint verified'
\echo ''

-- Main transformation and upsert
\echo '📊 Transforming and upserting data...'

WITH base AS (
  -- Join staging data with restaurants to resolve FK
  SELECT
    s.legacy_admin_id,
    r.id AS restaurant_id,
    COALESCE(s.user_type, 'r') AS user_type,
    s.fname AS first_name,
    s.lname AS last_name,
    lower(trim(s.email)) AS email,
    s.password_hash,
    s.lastlogin AS last_login,
    s.login_count,
    CASE WHEN s.active_user = '1' THEN true ELSE false END AS is_active,
    CASE WHEN s.send_statement = 'y' THEN true ELSE false END AS send_statement,
    COALESCE(s.created_at, s.lastlogin, now()) AS created_at,
    s.updated_at
  FROM staging.v1_restaurant_admin_users s
  JOIN menuca_v3.restaurants r
    ON r.legacy_v1_id = s.legacy_v1_restaurant_id
  WHERE s.legacy_v1_restaurant_id > 0  -- Exclude global admins with restaurant=0
    AND COALESCE(s.user_type, 'r') = 'r'  -- Only restaurant-level admins
    AND s.email IS NOT NULL  -- Must have email for unique constraint
), ranked AS (
  -- Deduplicate by (restaurant_id, email) - keep most recent lastlogin
  SELECT b.*,
         row_number() OVER (
           PARTITION BY restaurant_id, email
           ORDER BY last_login DESC NULLS LAST, legacy_admin_id
         ) AS rn
  FROM base b
), insert_result AS (
  INSERT INTO menuca_v3.restaurant_admin_users (
    restaurant_id, user_type, first_name, last_name, email,
    password_hash, last_login, login_count, is_active, send_statement,
    created_at, updated_at
  )
  SELECT
    restaurant_id, user_type, first_name, last_name, email,
    password_hash, last_login, login_count, is_active, send_statement,
    created_at, updated_at
  FROM ranked
  WHERE rn = 1  -- Only keep the most recent record per (restaurant_id, email)
  ON CONFLICT (restaurant_id, email)
  DO UPDATE SET
    user_type = COALESCE(EXCLUDED.user_type, menuca_v3.restaurant_admin_users.user_type),
    first_name = COALESCE(EXCLUDED.first_name, menuca_v3.restaurant_admin_users.first_name),
    last_name = COALESCE(EXCLUDED.last_name, menuca_v3.restaurant_admin_users.last_name),
    password_hash = COALESCE(EXCLUDED.password_hash, menuca_v3.restaurant_admin_users.password_hash),
    last_login = GREATEST(EXCLUDED.last_login, menuca_v3.restaurant_admin_users.last_login),
    login_count = EXCLUDED.login_count,
    is_active = EXCLUDED.is_active,
    send_statement = EXCLUDED.send_statement,
    updated_at = now()
  RETURNING 
    CASE 
      WHEN xmax = 0 THEN 'inserted'
      ELSE 'updated'
    END AS operation
)
SELECT 
    COUNT(*) FILTER (WHERE operation = 'inserted') AS records_inserted,
    COUNT(*) FILTER (WHERE operation = 'updated') AS records_updated
FROM insert_result;

COMMIT;

\echo ''
\echo '✅ Migration complete!'
\echo ''
\echo '📊 Summary statistics:'
SELECT 
    COUNT(*) AS total_admin_users,
    COUNT(CASE WHEN user_type = 'r' THEN 1 END) AS restaurant_type,
    COUNT(CASE WHEN user_type = 'g' THEN 1 END) AS global_type,
    COUNT(CASE WHEN is_active = true THEN 1 END) AS active_users,
    COUNT(CASE WHEN is_active = false THEN 1 END) AS inactive_users,
    COUNT(CASE WHEN send_statement = true THEN 1 END) AS receives_statements,
    COUNT(DISTINCT restaurant_id) AS unique_restaurants
FROM menuca_v3.restaurant_admin_users;

\echo ''
\echo '📝 Next step: Run step3_normalization_checks.sql'




