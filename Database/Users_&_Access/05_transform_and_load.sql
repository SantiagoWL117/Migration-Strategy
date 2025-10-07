-- ================================================================
-- Phase 3: Data Transformation & Loading
-- ================================================================
-- Transforms staging data → menuca_v3 production tables
-- Strategy: V2 is authoritative for duplicate emails
-- ================================================================

BEGIN;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 1: CUSTOMER USERS (V2 first, then V1)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Load V2 users first (authoritative)
-- Handle internal V2 duplicates by keeping most recent
INSERT INTO menuca_v3.users (
    email,
    email_verified,
    first_name,
    last_name,
    phone,
    language,
    password_hash,
    password_changed_at,
    newsletter_subscribed,
    login_count,
    last_login_at,
    last_login_ip,
    facebook_id,
    created_at,
    updated_at,
    v2_user_id
)
SELECT DISTINCT ON (LOWER(email))
    LOWER(TRIM(email)) as email,
    TRUE as email_verified,  -- V2 users are verified
    NULLIF(TRIM(fname), '') as first_name,
    NULLIF(TRIM(lname), '') as last_name,
    NULLIF(TRIM(phone), '') as phone,
    COALESCE(UPPER(language), 'EN') as language,
    password as password_hash,
    passwordchangedon as password_changed_at,
    newsletter = 'y' as newsletter_subscribed,
    COALESCE(logincount, 0) as login_count,
    lastlogin as last_login_at,
    CASE 
        WHEN creationip IS NOT NULL AND creationip != '' 
        THEN creationip::inet 
        ELSE NULL 
    END as last_login_ip,
    NULLIF(TRIM(fbid), '') as facebook_id,
    COALESCE(createdon, NOW()) as created_at,
    NOW() as updated_at,
    id as v2_user_id
FROM staging.v2_site_users
WHERE email IS NOT NULL 
  AND TRIM(email) != ''
  AND password IS NOT NULL
ORDER BY LOWER(email), lastlogin DESC NULLS LAST, id DESC;

-- Load V1 users (skip if email already exists from V2)
INSERT INTO menuca_v3.users (
    email,
    email_verified,
    first_name,
    last_name,
    language,
    password_hash,
    password_changed_at,
    newsletter_subscribed,
    vegan_newsletter_subscribed,
    login_count,
    last_login_at,
    last_login_ip,
    credit_balance,
    credit_earned_at,
    facebook_id,
    origin_restaurant_id,
    created_at,
    updated_at,
    v1_user_id
)
SELECT DISTINCT ON (LOWER(email))
    LOWER(TRIM(email)) as email,
    isEmailConfirmed = 'y' as email_verified,
    NULLIF(TRIM(fname), '') as first_name,
    NULLIF(TRIM(lname), '') as last_name,
    COALESCE(UPPER(language), 'EN') as language,
    password as password_hash,
    passwordChangedOn as password_changed_at,
    newsletter = '1' as newsletter_subscribed,
    vegan_newsletter = '1' as vegan_newsletter_subscribed,
    COALESCE(loginCount, 0) as login_count,
    lastLogin as last_login_at,
    CASE 
        WHEN creationip IS NOT NULL AND creationip != '' 
        THEN creationip::inet 
        ELSE NULL 
    END as last_login_ip,
    COALESCE(creditValue, 0) as credit_balance,
    creditStartOn as credit_earned_at,
    NULLIF(TRIM(fbid), '') as facebook_id,
    NULLIF(restaurant, 0) as origin_restaurant_id,
    NOW() as created_at,
    NOW() as updated_at,
    id as v1_user_id
FROM staging.v1_users
WHERE email IS NOT NULL 
  AND TRIM(email) != ''
  AND password IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM menuca_v3.users 
    WHERE LOWER(menuca_v3.users.email) = LOWER(TRIM(staging.v1_users.email))
  )
ORDER BY LOWER(email), lastLogin DESC NULLS LAST, id DESC;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 2: ADMIN USERS (V2 first, then V1)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Load V2 admin users
INSERT INTO menuca_v3.admin_users (
    email,
    first_name,
    last_name,
    password_hash,
    permissions,
    last_login_at,
    created_at,
    v2_admin_id
)
SELECT DISTINCT ON (LOWER(email))
    LOWER(TRIM(email)) as email,
    NULLIF(TRIM(fname), '') as first_name,
    NULLIF(TRIM(lname), '') as last_name,
    password as password_hash,
    '{}' as permissions,  -- V2 didn't have serialized permissions
    lastlogin as last_login_at,
    COALESCE(createdon, NOW()) as created_at,
    id as v2_admin_id
FROM staging.v2_admin_users
WHERE email IS NOT NULL 
  AND TRIM(email) != ''
  AND password IS NOT NULL
ORDER BY LOWER(email), id DESC;

-- Note: V1 admin users will be loaded separately (they need restaurant context)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 3: ADMIN-RESTAURANT RELATIONSHIPS (V2 only for now)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO menuca_v3.admin_user_restaurants (
    admin_user_id,
    restaurant_id,
    role,
    created_at
)
SELECT 
    a.id as admin_user_id,
    r.restaurant_id,
    'staff' as role,  -- Default role, can be updated later
    COALESCE(r.createdon, NOW()) as created_at
FROM staging.v2_admin_users_restaurants r
JOIN menuca_v3.admin_users a ON a.v2_admin_id = r.admin_user_id
WHERE r.restaurant_id IS NOT NULL;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 4: USER DELIVERY ADDRESSES (V2 only, with city FK validation)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO menuca_v3.user_addresses (
    user_id,
    street_address,
    apartment,
    city_id,
    postal_code,
    phone,
    delivery_instructions,
    is_default,
    created_at,
    v2_address_id
)
SELECT 
    u.id as user_id,
    NULLIF(TRIM(a.addressline1), '') as street_address,
    NULLIF(TRIM(a.addressline2), '') as apartment,
    a.city_id,
    NULLIF(TRIM(a.postalcode), '') as postal_code,
    NULLIF(TRIM(a.phone), '') as phone,
    NULLIF(TRIM(a.deliveryinstructions), '') as delivery_instructions,
    FALSE as is_default,  -- Will set default separately
    COALESCE(a.createdon, NOW()) as created_at,
    a.id as v2_address_id
FROM staging.v2_site_users_delivery_addresses a
JOIN menuca_v3.users u ON u.v2_user_id = a.user_id
WHERE a.city_id IS NOT NULL
  -- Validate city exists in menuca_v3.cities
  AND EXISTS (
    SELECT 1 FROM menuca_v3.cities c WHERE c.id = a.city_id
  );

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 5: FAVORITE RESTAURANTS (V2 only)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO menuca_v3.user_favorite_restaurants (
    user_id,
    restaurant_id,
    created_at
)
SELECT 
    u.id as user_id,
    f.restaurant_id,
    COALESCE(f.createdon, NOW()) as created_at
FROM staging.v2_site_users_favorite_restaurants f
JOIN menuca_v3.users u ON u.v2_user_id = f.user_id
WHERE f.restaurant_id IS NOT NULL;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 6: PASSWORD RESET TOKENS (V2 only, active only)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO menuca_v3.password_reset_tokens (
    user_id,
    token,
    expires_at,
    created_at
)
SELECT 
    u.id as user_id,
    r.code as token,
    -- V2 codes expire in 24 hours from creation
    COALESCE(r.createdon, NOW()) + INTERVAL '24 hours' as expires_at,
    COALESCE(r.createdon, NOW()) as created_at
FROM staging.v2_reset_codes r
JOIN menuca_v3.users u ON u.v2_user_id = r.user_id
WHERE r.code IS NOT NULL
  AND r.code != ''
  -- Only load active (non-expired) tokens
  AND COALESCE(r.createdon, NOW()) + INTERVAL '24 hours' > NOW();

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- STEP 7: AUTOLOGIN TOKENS (V2 only, active only)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO menuca_v3.autologin_tokens (
    user_id,
    token,
    expires_at,
    last_used_at,
    created_at
)
SELECT 
    u.id as user_id,
    a.selector as token,
    -- V2 autologins expire in 30 days from last use (or creation)
    COALESCE(a.lastuseon, a.createdon, NOW()) + INTERVAL '30 days' as expires_at,
    a.lastuseon as last_used_at,
    COALESCE(a.createdon, NOW()) as created_at
FROM staging.v2_site_users_autologins a
JOIN menuca_v3.users u ON u.v2_user_id = a.user_id
WHERE a.selector IS NOT NULL
  AND a.selector != ''
  -- Only load active (non-expired) tokens
  AND COALESCE(a.lastuseon, a.createdon, NOW()) + INTERVAL '30 days' > NOW();

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- VERIFICATION COUNTS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DO $$
DECLARE
    v_users INT;
    v_admins INT;
    v_admin_rels INT;
    v_addresses INT;
    v_favorites INT;
    v_reset_tokens INT;
    v_autologin_tokens INT;
BEGIN
    SELECT COUNT(*) INTO v_users FROM menuca_v3.users;
    SELECT COUNT(*) INTO v_admins FROM menuca_v3.admin_users;
    SELECT COUNT(*) INTO v_admin_rels FROM menuca_v3.admin_user_restaurants;
    SELECT COUNT(*) INTO v_addresses FROM menuca_v3.user_addresses;
    SELECT COUNT(*) INTO v_favorites FROM menuca_v3.user_favorite_restaurants;
    SELECT COUNT(*) INTO v_reset_tokens FROM menuca_v3.password_reset_tokens;
    SELECT COUNT(*) INTO v_autologin_tokens FROM menuca_v3.autologin_tokens;
    
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '✅ PHASE 3 COMPLETE - DATA TRANSFORMATION SUCCESS!';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE 'Records Loaded:';
    RAISE NOTICE '  • Users: %', v_users;
    RAISE NOTICE '  • Admin Users: %', v_admins;
    RAISE NOTICE '  • Admin-Restaurant Links: %', v_admin_rels;
    RAISE NOTICE '  • Delivery Addresses: %', v_addresses;
    RAISE NOTICE '  • Favorite Restaurants: %', v_favorites;
    RAISE NOTICE '  • Reset Tokens (active): %', v_reset_tokens;
    RAISE NOTICE '  • Autologin Tokens (active): %', v_autologin_tokens;
    RAISE NOTICE '';
    RAISE NOTICE 'Next: Phase 4 - Data Quality Validation';
    RAISE NOTICE '════════════════════════════════════════════════════════';
END $$;

COMMIT;
