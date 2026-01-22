-- Fix admin functions that reference non-existent columns
-- Date: 2026-01-19
-- Issue 1: get_admin_profile references mfa_enabled which was dropped
-- Issue 2: get_admin_restaurants returns NULL for phone/email instead of fetching from restaurant_locations

-- ============================================
-- FIX 1: get_admin_profile
-- ============================================
-- Drop old function (signature is changing)
DROP FUNCTION IF EXISTS menuca_v3.get_admin_profile();

-- Create updated function
CREATE OR REPLACE FUNCTION menuca_v3.get_admin_profile()
RETURNS TABLE(
  id bigint, 
  auth_user_id uuid, 
  email varchar, 
  first_name varchar, 
  last_name varchar, 
  phone varchar,
  preferred_language char(2),
  role_id bigint,
  status varchar, 
  created_at timestamptz, 
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'menuca_v3', 'public'
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.auth_user_id,
    a.email,
    a.first_name,
    a.last_name,
    a.phone,
    a.preferred_language,
    a.role_id,
    a.status::VARCHAR,
    a.created_at,
    a.updated_at
  FROM menuca_v3.admin_users a
  WHERE a.auth_user_id = auth.uid()
    AND a.deleted_at IS NULL
    AND a.status = 'active'
  LIMIT 1;
END;
$function$;

-- ============================================
-- FIX 2: get_admin_restaurants
-- ============================================
CREATE OR REPLACE FUNCTION menuca_v3.get_admin_restaurants()
RETURNS TABLE(
  restaurant_id bigint, 
  restaurant_name varchar, 
  restaurant_slug varchar, 
  restaurant_phone varchar, 
  restaurant_email varchar, 
  assigned_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'menuca_v3', 'auth', 'public'
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    r.slug AS restaurant_slug,
    rl.phone AS restaurant_phone,
    rl.email AS restaurant_email,
    aur.created_at AS assigned_at
  FROM menuca_v3.admin_user_restaurants aur
  JOIN menuca_v3.admin_users au ON au.id = aur.admin_user_id
  JOIN menuca_v3.restaurants r ON r.id = aur.restaurant_id
  LEFT JOIN menuca_v3.restaurant_locations rl 
    ON rl.restaurant_id = r.id AND rl.is_primary = true
  WHERE au.auth_user_id = auth.uid()
    AND au.deleted_at IS NULL
    AND au.status = 'active'
    AND r.deleted_at IS NULL
  ORDER BY r.name;
END;
$function$;
