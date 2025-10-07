-- ================================================================
-- Users & Access Entity - Phase 1: Load Staging Data
-- ================================================================
-- Purpose: Load CSV data into staging tables with filters
-- Created: 2025-10-06
--
-- CRITICAL: Run 01_create_staging_tables.sql FIRST
--
-- CSV Delimiter Differences:
-- - V1 files: DELIMITER ';' (semicolon)
-- - V2 files: DELIMITER ',' (comma)
--
-- Active Users Only Strategy:
-- - V1 users: Filter WHERE lastLogin > '2020-01-01'
-- - V2 tokens: Filter WHERE expires_at > NOW()
-- - Sessions: Skip entirely
-- ================================================================

-- ================================================================
-- STEP 1: Load V1 Customer Users (WITH FILTER)
-- ================================================================

-- Load main V1 users file (14,292 rows)
\echo 'Loading V1 users main file...'
\COPY staging.v1_users (id,isActive,fname,lname,email,password,passwordChangedOn,language,newsletter,vegan_newsletter,isEmailConfirmed,lastLogin,loginCount,autologinCode,restaurant,globalUser,createdFrom,creationip,forwardedfor,firstMailFeedback,unsub,sent,opens,clicks,total_opens,total_clicks,last_send,last_click,last_open,creditValue,creditStartOn,fbid,storageToken,fsi) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v1_users.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ';', NULL '', ENCODING 'UTF8');

UPDATE staging.v1_users SET _source_file = 'menuca_v1_users.csv' WHERE _source_file IS NULL;

-- Load V1 users part 1 (142,665 rows)
\echo 'Loading V1 users part 1...'
\COPY staging.v1_users (id,isActive,fname,lname,email,password,passwordChangedOn,language,newsletter,vegan_newsletter,isEmailConfirmed,lastLogin,loginCount,autologinCode,restaurant,globalUser,createdFrom,creationip,forwardedfor,firstMailFeedback,unsub,sent,opens,clicks,total_opens,total_clicks,last_send,last_click,last_open,creditValue,creditStartOn,fbid,storageToken,fsi) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v1_users_part1.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ';', NULL '', ENCODING 'UTF8');

UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part1.csv' WHERE _source_file IS NULL;

-- Load V1 users part 2 (142,665 rows)
\echo 'Loading V1 users part 2...'
\COPY staging.v1_users (id,isActive,fname,lname,email,password,passwordChangedOn,language,newsletter,vegan_newsletter,isEmailConfirmed,lastLogin,loginCount,autologinCode,restaurant,globalUser,createdFrom,creationip,forwardedfor,firstMailFeedback,unsub,sent,opens,clicks,total_opens,total_clicks,last_send,last_click,last_open,creditValue,creditStartOn,fbid,storageToken,fsi) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v1_users_part2.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ';', NULL '', ENCODING 'UTF8');

UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part2.csv' WHERE _source_file IS NULL;

-- Load V1 users part 3 (142,664 rows)
\echo 'Loading V1 users part 3...'
\COPY staging.v1_users (id,isActive,fname,lname,email,password,passwordChangedOn,language,newsletter,vegan_newsletter,isEmailConfirmed,lastLogin,loginCount,autologinCode,restaurant,globalUser,createdFrom,creationip,forwardedfor,firstMailFeedback,unsub,sent,opens,clicks,total_opens,total_clicks,last_send,last_click,last_open,creditValue,creditStartOn,fbid,storageToken,fsi) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v1_users_part3.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ';', NULL '', ENCODING 'UTF8');

UPDATE staging.v1_users SET _source_file = 'menuca_v1_users_part3.csv' WHERE _source_file IS NULL;

-- Verify initial load count
\echo 'V1 users initial load count:'
SELECT COUNT(*) as total_loaded, 
       COUNT(DISTINCT id) as unique_ids,
       MIN(lastLogin) as oldest_login,
       MAX(lastLogin) as newest_login
FROM staging.v1_users;

-- ================================================================
-- CRITICAL: Filter for ACTIVE USERS ONLY
-- ================================================================

\echo 'Applying active users filter (lastLogin > 2020-01-01)...'

-- Create backup of full dataset before deletion
CREATE TABLE IF NOT EXISTS staging.v1_users_excluded AS
SELECT *, 'inactive_old_login'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v1_users
WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';

-- Delete inactive users (keep active only)
DELETE FROM staging.v1_users
WHERE lastLogin IS NULL OR lastLogin <= '2020-01-01';

-- Report on filtering
\echo 'Active users filter results:'
SELECT 
    (SELECT COUNT(*) FROM staging.v1_users) as active_users_kept,
    (SELECT COUNT(*) FROM staging.v1_users_excluded) as inactive_users_excluded,
    ROUND(100.0 * (SELECT COUNT(*) FROM staging.v1_users) / 
          ((SELECT COUNT(*) FROM staging.v1_users) + (SELECT COUNT(*) FROM staging.v1_users_excluded)), 2) as pct_kept
;

-- ================================================================
-- STEP 2: Load V1 Callcenter Users (NO FILTER)
-- ================================================================

\echo 'Loading V1 callcenter users...'
\COPY staging.v1_callcenter_users (id,fname,lname,email,password,last_login,is_active,rank) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v1_callcenter_users.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ';', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v1_callcenter_users_loaded FROM staging.v1_callcenter_users;

-- ================================================================
-- STEP 3: Load V2 Customer Users (NO FILTER - all active)
-- ================================================================

\echo 'Loading V2 site_users...'
\COPY staging.v2_site_users (id,active,fname,lname,email,password,language_id,gender,locale,oauth_provider,oauth_uid,picture_url,profile_url,created_at,newsletter,sms,origin_restaurant,last_login,disabled_by,disabled_at) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_site_users.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_site_users_loaded FROM staging.v2_site_users;

-- ================================================================
-- STEP 4: Load V2 Admin Users (NO FILTER)
-- ================================================================

\echo 'Loading V2 admin_users...'
\COPY staging.v2_admin_users (id,preferred_language,fname,lname,email,password,"group",receive_statements,phone,active,override_restaurants,settings,billing_info,allow_login_to_sites,last_activity,created_by,created_at,disabled_by,disabled_at) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_admin_users.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_admin_users_loaded FROM staging.v2_admin_users;

-- ================================================================
-- STEP 5: Load V2 Admin-Restaurant Junction (NO FILTER)
-- ================================================================

\echo 'Loading V2 admin_users_restaurants...'
\COPY staging.v2_admin_users_restaurants (id,user_id,restaurant_id) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_admin_users_restaurants.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_admin_restaurants_loaded FROM staging.v2_admin_users_restaurants;

-- ================================================================
-- STEP 6: Load V2 Delivery Addresses (NO FILTER)
-- ================================================================

\echo 'Loading V2 site_users_delivery_addresses...'
\COPY staging.v2_site_users_delivery_addresses (id,active,place_id,user_id,lat,lng,street,apartment,zip,ringer,extension,special_instructions,city,province,phone,missingData) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_site_users_delivery_addresses.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_addresses_loaded FROM staging.v2_site_users_delivery_addresses;

-- ================================================================
-- STEP 7: Load V2 Password Reset Tokens (WITH FILTER)
-- ================================================================

\echo 'Loading V2 reset_codes...'
\COPY staging.v2_reset_codes (id,code,user_id,added_at,expires_at,request_ip) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_reset_codes.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

-- Show initial count
SELECT COUNT(*) as reset_codes_initial FROM staging.v2_reset_codes;

-- Filter for active tokens only (expires_at > NOW())
\echo 'Filtering for active reset codes only...'

CREATE TABLE IF NOT EXISTS staging.v2_reset_codes_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_reset_codes
WHERE expires_at IS NULL OR expires_at <= NOW();

DELETE FROM staging.v2_reset_codes
WHERE expires_at IS NULL OR expires_at <= NOW();

SELECT 
    (SELECT COUNT(*) FROM staging.v2_reset_codes) as active_tokens_kept,
    (SELECT COUNT(*) FROM staging.v2_reset_codes_excluded) as expired_tokens_excluded;

-- ================================================================
-- STEP 8: Load V2 Autologin Tokens (WITH FILTER)
-- ================================================================

\echo 'Loading V2 site_users_autologins...'
\COPY staging.v2_site_users_autologins (id,user_login,selector,password,expire) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_site_users_autologins.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

-- Show initial count
SELECT COUNT(*) as autologins_initial FROM staging.v2_site_users_autologins;

-- Filter for active tokens only (expire > NOW())
\echo 'Filtering for active autologin tokens only...'

CREATE TABLE IF NOT EXISTS staging.v2_site_users_autologins_excluded AS
SELECT *, 'expired_token'::TEXT as exclusion_reason, NOW() as excluded_at
FROM staging.v2_site_users_autologins
WHERE expire IS NULL OR expire <= NOW();

DELETE FROM staging.v2_site_users_autologins
WHERE expire IS NULL OR expire <= NOW();

SELECT 
    (SELECT COUNT(*) FROM staging.v2_site_users_autologins) as active_tokens_kept,
    (SELECT COUNT(*) FROM staging.v2_site_users_autologins_excluded) as expired_tokens_excluded;

-- ================================================================
-- STEP 9: Load V2 Favorite Restaurants (NO FILTER)
-- ================================================================

\echo 'Loading V2 site_users_favorite_restaurants...'
\COPY staging.v2_site_users_favorite_restaurants (id,user_id,restaurant_id,created_at,removed_at,enabled) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_site_users_favorite_restaurants.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_favorites_loaded FROM staging.v2_site_users_favorite_restaurants;

-- ================================================================
-- STEP 10: Load V2 Facebook OAuth Profiles (NO FILTER)
-- ================================================================

\echo 'Loading V2 site_users_fb...'
\COPY staging.v2_site_users_fb (id,oauth_provider,oauth_uid,first_name,last_name,email,gender,locale,picture_url,profile_url,created,modified) FROM '/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/menuca_v2_site_users_fb.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

SELECT COUNT(*) as v2_fb_profiles_loaded FROM staging.v2_site_users_fb;

-- ================================================================
-- FINAL SUMMARY REPORT
-- ================================================================

\echo '================================================================'
\echo 'STAGING DATA LOAD COMPLETE!'
\echo '================================================================'

SELECT 
    'Staging Load Summary' as report_type,
    NOW() as generated_at;

-- V1 Tables
SELECT 'V1 users (active only)' as table_name, COUNT(*) as row_count, 'FILTERED: lastLogin > 2020-01-01' as notes
FROM staging.v1_users
UNION ALL
SELECT 'V1 users excluded', COUNT(*), 'Backup of inactive users'
FROM staging.v1_users_excluded
UNION ALL
SELECT 'V1 callcenter_users', COUNT(*), 'All staff accounts'
FROM staging.v1_callcenter_users
UNION ALL

-- V2 Tables
SELECT 'V2 site_users', COUNT(*), 'All V2 users (all active)'
FROM staging.v2_site_users
UNION ALL
SELECT 'V2 admin_users', COUNT(*), 'Platform admins'
FROM staging.v2_admin_users
UNION ALL
SELECT 'V2 admin_users_restaurants', COUNT(*), 'Admin-restaurant junction'
FROM staging.v2_admin_users_restaurants
UNION ALL
SELECT 'V2 delivery_addresses', COUNT(*), 'User saved addresses'
FROM staging.v2_site_users_delivery_addresses
UNION ALL
SELECT 'V2 reset_codes (active)', COUNT(*), 'FILTERED: expires_at > NOW()'
FROM staging.v2_reset_codes
UNION ALL
SELECT 'V2 reset_codes excluded', COUNT(*), 'Backup of expired tokens'
FROM staging.v2_reset_codes_excluded
UNION ALL
SELECT 'V2 autologins (active)', COUNT(*), 'FILTERED: expire > NOW()'
FROM staging.v2_site_users_autologins
UNION ALL
SELECT 'V2 autologins excluded', COUNT(*), 'Backup of expired tokens'
FROM staging.v2_site_users_autologins_excluded
UNION ALL
SELECT 'V2 favorite_restaurants', COUNT(*), 'User favorites'
FROM staging.v2_site_users_favorite_restaurants
UNION ALL
SELECT 'V2 fb_profiles', COUNT(*), 'Facebook OAuth'
FROM staging.v2_site_users_fb
ORDER BY table_name;

-- Email overlap analysis
\echo '================================================================'
\echo 'EMAIL DEDUPLICATION PREVIEW'
\echo '================================================================'

SELECT 
    'Email Analysis' as metric,
    COUNT(DISTINCT email_normalized) as unique_emails,
    (SELECT COUNT(*) FROM staging.v1_users) + (SELECT COUNT(*) FROM staging.v2_site_users) as total_users,
    (SELECT COUNT(*) FROM staging.v1_users) + (SELECT COUNT(*) FROM staging.v2_site_users) - COUNT(DISTINCT email_normalized) as duplicate_emails
FROM (
    SELECT LOWER(TRIM(email)) as email_normalized FROM staging.v1_users WHERE email IS NOT NULL
    UNION ALL
    SELECT LOWER(TRIM(email)) FROM staging.v2_site_users WHERE email IS NOT NULL
) combined;

\echo '================================================================'
\echo 'Next Step: Run 03_data_quality_assessment.sql'
\echo '================================================================'
