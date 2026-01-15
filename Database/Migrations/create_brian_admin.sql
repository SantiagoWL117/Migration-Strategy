-- Create Brian Lapp as Super Admin
-- Date: January 15, 2026

BEGIN;

-- Step 1: Create user in auth.users
WITH new_auth_user AS (
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    phone
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'brian+1@worklocal.ca',
    crypt('WL!2w3e4r5t', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"first_name": "Brian", "last_name": "Lapp"}'::jsonb,
    NOW(),
    NOW(),
    '',
    '6138663429'
  )
  RETURNING id, email
)
-- Step 2: Create admin_users record linked to auth.users
INSERT INTO menuca_v3.admin_users (
  email,
  first_name,
  last_name,
  phone,
  role_id,
  auth_user_id,
  is_active,
  status,
  created_at,
  updated_at
)
SELECT 
  'brian+1@worklocal.ca',
  'Brian',
  'Lapp',
  '6138663429',
  1,  -- Super Admin
  new_auth_user.id,
  true,
  'active'::menuca_v3.admin_user_status,
  NOW(),
  NOW()
FROM new_auth_user
RETURNING id, email, first_name, last_name, role_id, auth_user_id;

COMMIT;
