-- =====================================================
-- Admin User Management Functions - PUBLIC SCHEMA
-- Secure alternatives to Edge Functions using JWT auth
-- Created in public schema for REST API accessibility
-- =====================================================

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.get_my_admin_info() CASCADE;
DROP FUNCTION IF EXISTS public.assign_restaurants_to_admin(BIGINT, BIGINT[], TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.create_admin_user_request(TEXT, TEXT, TEXT, TEXT) CASCADE;

-- =====================================================
-- Helper Function: Get current admin user info
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_my_admin_info()
RETURNS TABLE(
  admin_id BIGINT,
  email TEXT,
  first_name TEXT,
  last_name TEXT,
  status TEXT,
  is_active BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, auth, public
AS $$
BEGIN
  -- Check if user is authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  -- Get admin user info
  RETURN QUERY
  SELECT
    a.id,
    a.email::TEXT,
    a.first_name::TEXT,
    a.last_name::TEXT,
    a.status::TEXT,
    (a.status = 'active' AND a.deleted_at IS NULL) as is_active
  FROM menuca_v3.admin_users a
  WHERE a.auth_user_id = auth.uid()
  AND a.deleted_at IS NULL;

  -- Raise error if not an admin
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User is not an admin';
  END IF;
END;
$$;

COMMENT ON FUNCTION public.get_my_admin_info() IS
'Returns information about the currently authenticated admin user';

-- =====================================================
-- Function: Assign/Remove/Replace restaurants for admin
-- =====================================================
CREATE OR REPLACE FUNCTION public.assign_restaurants_to_admin(
  p_admin_user_id BIGINT,
  p_restaurant_ids BIGINT[],
  p_action TEXT DEFAULT 'add' -- 'add', 'remove', 'replace'
)
RETURNS TABLE(
  success BOOLEAN,
  action TEXT,
  out_admin_user_id BIGINT,
  admin_email TEXT,
  assignments_before INTEGER,
  assignments_after INTEGER,
  affected_count INTEGER,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, auth, public
AS $$
DECLARE
  v_caller_admin_id BIGINT;
  v_caller_status TEXT;
  v_target_admin_email TEXT;
  v_target_admin_status TEXT;
  v_assignments_before INTEGER;
  v_assignments_after INTEGER;
  v_affected INTEGER := 0;
  v_valid_restaurants BIGINT[];
BEGIN
  -- STEP 1: Verify caller is an active admin
  SELECT id, status::TEXT INTO v_caller_admin_id, v_caller_status
  FROM menuca_v3.admin_users
  WHERE auth_user_id = auth.uid()
  AND deleted_at IS NULL;

  IF v_caller_admin_id IS NULL THEN
    RAISE EXCEPTION 'User is not an admin';
  END IF;

  IF v_caller_status != 'active' THEN
    RAISE EXCEPTION 'Admin account is not active (status: %)', v_caller_status;
  END IF;

  -- STEP 2: Validate target admin exists
  SELECT email::TEXT, status::TEXT INTO v_target_admin_email, v_target_admin_status
  FROM menuca_v3.admin_users
  WHERE id = p_admin_user_id
  AND deleted_at IS NULL;

  IF v_target_admin_email IS NULL THEN
    RAISE EXCEPTION 'Target admin user (id: %) not found', p_admin_user_id;
  END IF;

  IF v_target_admin_status != 'active' THEN
    RAISE EXCEPTION 'Target admin status is not active (status: %)', v_target_admin_status;
  END IF;

  -- STEP 3: Validate action
  IF p_action NOT IN ('add', 'remove', 'replace') THEN
    RAISE EXCEPTION 'Invalid action: %. Must be one of: add, remove, replace', p_action;
  END IF;

  -- STEP 4: Get current assignments count
  SELECT COUNT(*) INTO v_assignments_before
  FROM menuca_v3.admin_user_restaurants aur
  WHERE aur.admin_user_id = p_admin_user_id;

  -- STEP 5: Validate restaurants exist and are not deleted
  SELECT ARRAY_AGG(id) INTO v_valid_restaurants
  FROM menuca_v3.restaurants
  WHERE id = ANY(p_restaurant_ids)
  AND deleted_at IS NULL;

  IF v_valid_restaurants IS NULL OR array_length(v_valid_restaurants, 1) = 0 THEN
    RAISE EXCEPTION 'No valid restaurants found in provided IDs';
  END IF;

  IF array_length(v_valid_restaurants, 1) < array_length(p_restaurant_ids, 1) THEN
    RAISE WARNING 'Some restaurants not found or deleted. Requested: %, Valid: %',
      array_length(p_restaurant_ids, 1),
      array_length(v_valid_restaurants, 1);
  END IF;

  -- STEP 6: Perform action
  IF p_action = 'add' THEN
    -- Add new assignments (ignore duplicates)
    INSERT INTO menuca_v3.admin_user_restaurants (admin_user_id, restaurant_id)
    SELECT p_admin_user_id, unnest(v_valid_restaurants)
    ON CONFLICT (admin_user_id, restaurant_id) DO NOTHING;
    GET DIAGNOSTICS v_affected = ROW_COUNT;

  ELSIF p_action = 'remove' THEN
    -- Remove specified assignments
    DELETE FROM menuca_v3.admin_user_restaurants aur
    WHERE aur.admin_user_id = p_admin_user_id
    AND aur.restaurant_id = ANY(v_valid_restaurants);
    GET DIAGNOSTICS v_affected = ROW_COUNT;

  ELSIF p_action = 'replace' THEN
    -- Remove all existing assignments
    DELETE FROM menuca_v3.admin_user_restaurants aur
    WHERE aur.admin_user_id = p_admin_user_id;

    -- Add new assignments
    INSERT INTO menuca_v3.admin_user_restaurants (admin_user_id, restaurant_id)
    SELECT p_admin_user_id, unnest(v_valid_restaurants);
    GET DIAGNOSTICS v_affected = ROW_COUNT;
  END IF;

  -- STEP 7: Get final assignments count
  SELECT COUNT(*) INTO v_assignments_after
  FROM menuca_v3.admin_user_restaurants aur
  WHERE aur.admin_user_id = p_admin_user_id;

  -- STEP 8: Return result
  RETURN QUERY SELECT
    TRUE,
    p_action,
    p_admin_user_id,
    v_target_admin_email,
    v_assignments_before,
    v_assignments_after,
    v_affected,
    format('Successfully %sed %s restaurant(s) for %s',
      p_action,
      v_affected,
      v_target_admin_email
    );
END;
$$;

COMMENT ON FUNCTION public.assign_restaurants_to_admin(BIGINT, BIGINT[], TEXT) IS
'Assign, remove, or replace restaurant assignments for an admin user.
Requires caller to be an active admin. Uses JWT auth via auth.uid().';

-- =====================================================
-- Function: Create admin user request (pending approval)
-- =====================================================
CREATE OR REPLACE FUNCTION public.create_admin_user_request(
  p_email TEXT,
  p_first_name TEXT,
  p_last_name TEXT,
  p_phone TEXT DEFAULT NULL
)
RETURNS TABLE(
  success BOOLEAN,
  admin_user_id BIGINT,
  email TEXT,
  status TEXT,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, auth, public
AS $$
DECLARE
  v_caller_admin_id BIGINT;
  v_caller_status TEXT;
  v_new_admin_id BIGINT;
BEGIN
  -- STEP 1: Verify caller is an active admin
  SELECT id, status::TEXT INTO v_caller_admin_id, v_caller_status
  FROM menuca_v3.admin_users
  WHERE auth_user_id = auth.uid()
  AND deleted_at IS NULL;

  IF v_caller_admin_id IS NULL THEN
    RAISE EXCEPTION 'User is not an admin';
  END IF;

  IF v_caller_status != 'active' THEN
    RAISE EXCEPTION 'Admin account is not active (status: %)', v_caller_status;
  END IF;

  -- STEP 2: Validate email format
  IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Invalid email format: %', p_email;
  END IF;

  -- STEP 3: Check if email already exists
  IF EXISTS (
    SELECT 1 FROM menuca_v3.admin_users
    WHERE email = p_email
    AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Admin user with email % already exists', p_email;
  END IF;

  -- STEP 4: Create admin user record (status = 'pending')
  -- Auth account must be created manually via Supabase Dashboard
  INSERT INTO menuca_v3.admin_users (
    email,
    first_name,
    last_name,
    phone,
    status
  )
  VALUES (
    p_email,
    p_first_name,
    p_last_name,
    p_phone,
    'pending' -- Must be activated after auth account is created
  )
  RETURNING id INTO v_new_admin_id;

  -- STEP 5: Return result
  RETURN QUERY SELECT
    TRUE,
    v_new_admin_id,
    p_email,
    'pending'::TEXT,
    format('Admin user created with id %s. NEXT STEPS: 1. Create auth account in Supabase Dashboard 2. Update admin_users.auth_user_id with the UUID 3. Update admin_users.status to active',
      v_new_admin_id
    );
END;
$$;

COMMENT ON FUNCTION public.create_admin_user_request(TEXT, TEXT, TEXT, TEXT) IS
'Creates a pending admin user record. Auth account must be created manually in Dashboard.
Requires caller to be an active admin. Uses JWT auth via auth.uid().';

-- =====================================================
-- Grant execute permissions to authenticated users
-- =====================================================
GRANT EXECUTE ON FUNCTION public.get_my_admin_info() TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_restaurants_to_admin(BIGINT, BIGINT[], TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_admin_user_request(TEXT, TEXT, TEXT, TEXT) TO authenticated;
