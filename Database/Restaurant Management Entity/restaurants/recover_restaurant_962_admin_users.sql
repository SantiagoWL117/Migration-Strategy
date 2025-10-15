-- ================================================================
-- Recovery Script: Restaurant 962 (Chicco Pizza) Admin Users
-- ================================================================
-- Purpose: Restore 3 lost V2 admin users for restaurant 962
-- Date: October 14, 2025
-- Context: Active Status Correction - Missing Admin Users Investigation
--
-- SOURCE DATA: Database/Users_&_Access/CSV/user_structure.csv
-- V2 Admin User IDs: 2, 62, 65
-- V3 Restaurant ID: 962 (Chicco Pizza & Shawarma Buckingham)
-- V2 Restaurant ID: 1659
--
-- VERIFICATION QUERIES AT END OF FILE
-- ================================================================

BEGIN;

-- ================================================================
-- STEP 1: Insert 3 admin users into menuca_v3.admin_users
-- ================================================================

INSERT INTO menuca_v3.admin_users (
    email,
    first_name,
    last_name,
    password_hash,
    permissions,
    last_login_at,
    created_at,
    updated_at,
    v2_admin_id
)
VALUES
    -- User 1: Menu Ottawa (Corporate/Platform Admin - Group 12)
    (
        'mattmenuottawa@gmail.com',
        'Menu',
        'Ottawa',
        '$2y$10$khcktnnSIMZK9eYdY0ELAuxUc9FuLGCD8AZYc78Bi.a9qVFGQJ7ei',
        jsonb_build_object(
            'group', 12,
            'receive_statements', false,
            'override_restaurants', true,
            'allow_login_to_sites', false,
            'settings', jsonb_build_object(
                'size', ' ',
                'skin', 'smart-style-0',
                'navigation', ' '
            )
        ),
        '2025-09-12 08:52:27'::timestamptz,
        '2016-09-30 13:35:17'::timestamptz,
        now(),
        2  -- V2 admin_id
    ),
    
    -- User 2: Chicco Khalife (Restaurant Owner - Group 10)
    (
        'chiccokhalife@icloud.com',
        'Chicco',
        'Khalife',
        '$2y$10$4hOp2/y1IoPc3HpHs62v4OvOybM/T92coEcTvq.FLzT4zzG9zj4ge',
        jsonb_build_object(
            'group', 10,
            'receive_statements', true,
            'phone', '(819) 921-0711',
            'override_restaurants', true,
            'allow_login_to_sites', true
        ),
        NULL,  -- last_login_at (never logged in)
        '2024-03-25 15:43:51'::timestamptz,
        now(),
        62  -- V2 admin_id
    ),
    
    -- User 3: Darrell Corcoran (Corporate/Vendor Admin - Group 12)
    (
        'darrellcorcoran1967@gmail.com',
        'Darrell',
        'Corcoran',
        '$2y$10$0aiFAloS3pJpw/QWWptrYuIIGtdtXBMYy9ZHQzLT5mYM/NGMwWcyy',
        jsonb_build_object(
            'group', 12,
            'receive_statements', false,
            'override_restaurants', true,
            'allow_login_to_sites', true
        ),
        '2025-07-22 09:47:08'::timestamptz,
        '2024-05-06 11:20:03'::timestamptz,
        now(),
        65  -- V2 admin_id
    )
ON CONFLICT (email) DO NOTHING;  -- Prevent duplicates if script is re-run

-- ================================================================
-- STEP 2: Link admin users to restaurant 962
-- ================================================================

-- Get the admin_user IDs we just created (or existing ones if re-run)
WITH new_admins AS (
    SELECT 
        id,
        email,
        v2_admin_id
    FROM menuca_v3.admin_users
    WHERE v2_admin_id IN (2, 62, 65)
)
INSERT INTO menuca_v3.admin_user_restaurants (
    admin_user_id,
    restaurant_id,
    role,
    permissions,
    created_at
)
SELECT 
    na.id,
    962,  -- Restaurant ID for Chicco Pizza & Shawarma Buckingham
    CASE 
        WHEN na.v2_admin_id IN (2, 65) THEN 'admin'  -- Corporate/vendor admins
        WHEN na.v2_admin_id = 62 THEN 'owner'        -- Restaurant owner
    END,
    '{}'::jsonb,  -- Default empty permissions (inherited from admin_users.permissions)
    now()
FROM new_admins na
ON CONFLICT (admin_user_id, restaurant_id) DO NOTHING;  -- Prevent duplicates

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================

-- Check if users were created
SELECT 
    id,
    email,
    first_name,
    last_name,
    v2_admin_id,
    last_login_at,
    created_at
FROM menuca_v3.admin_users
WHERE v2_admin_id IN (2, 62, 65)
ORDER BY v2_admin_id;

-- Check if restaurant associations were created
SELECT 
    aur.id,
    au.email,
    au.first_name || ' ' || au.last_name as admin_name,
    aur.restaurant_id,
    r.name as restaurant_name,
    aur.role,
    aur.created_at
FROM menuca_v3.admin_user_restaurants aur
JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON aur.restaurant_id = r.id
WHERE au.v2_admin_id IN (2, 62, 65)
  AND aur.restaurant_id = 962
ORDER BY au.v2_admin_id;

-- Final verification: Check restaurant 962 admin count
SELECT 
    r.id,
    r.name,
    COUNT(aur.id) as admin_count,
    STRING_AGG(au.email, ', ' ORDER BY au.email) as admin_emails
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.admin_user_restaurants aur ON r.id = aur.restaurant_id
LEFT JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
WHERE r.id = 962
GROUP BY r.id, r.name;

COMMIT;

-- ================================================================
-- EXECUTION NOTES
-- ================================================================
-- 
-- EXPECTED RESULTS:
-- - 3 new rows in menuca_v3.admin_users (or 0 if already exist)
-- - 3 new rows in menuca_v3.admin_user_restaurants
-- - Restaurant 962 should now have 3 admin users
--
-- ROLLBACK IF NEEDED:
-- If something goes wrong, run:
--   ROLLBACK;
--
-- CLEANUP (if you need to re-run from scratch):
--   DELETE FROM menuca_v3.admin_user_restaurants 
--   WHERE admin_user_id IN (
--       SELECT id FROM menuca_v3.admin_users WHERE v2_admin_id IN (2, 62, 65)
--   ) AND restaurant_id = 962;
--
--   DELETE FROM menuca_v3.admin_users WHERE v2_admin_id IN (2, 62, 65);
--
-- ================================================================

