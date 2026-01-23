-- Fix get_user_profile() function
-- Issue: Function referenced newsletter_subscribed column which was dropped on 2026-01-19
-- Date: 2026-01-23

-- Must drop first because return type is changing (removing newsletter_subscribed column)
DROP FUNCTION IF EXISTS menuca_v3.get_user_profile();

CREATE OR REPLACE FUNCTION menuca_v3.get_user_profile()
RETURNS TABLE(
    id bigint,
    auth_user_id uuid,
    email character varying,
    first_name character varying,
    last_name character varying,
    phone character varying,
    language character varying,
    credit_balance numeric,
    stripe_customer_id character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'menuca_v3', 'public'
AS $$
BEGIN
  -- Return the profile for the current authenticated user
  RETURN QUERY
  SELECT 
    u.id,
    u.auth_user_id,
    u.email,
    u.first_name,
    u.last_name,
    u.phone,
    u.language,
    u.credit_balance,
    u.stripe_customer_id,
    u.created_at,
    u.updated_at
  FROM menuca_v3.users u
  WHERE u.auth_user_id = auth.uid()
    AND u.deleted_at IS NULL
  LIMIT 1;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION menuca_v3.get_user_profile() IS 'Returns the profile for the currently authenticated user. Uses auth.uid() to identify the user.';
