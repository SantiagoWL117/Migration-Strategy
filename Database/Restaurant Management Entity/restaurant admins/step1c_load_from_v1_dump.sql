-- ============================================================================
-- Step 1c: Load V1 Data from MySQL Dump (Alternative Loading Method)
-- ============================================================================
-- Purpose: Load V1 restaurant_admins data directly from MySQL dump file
-- Source: menuca_v1_restaurant_admins.sql dump file
-- Author: Migration Plan
-- Date: 2025-10-02
-- ============================================================================
-- NOTE: This script shows how to use mysql2pgsql or manual conversion
--       Since we have a MySQL dump, we need to convert it to PostgreSQL format
-- ============================================================================

\echo '📦 Loading V1 restaurant_admins data from MySQL dump...'
\echo ''
\echo '⚠️  This requires converting MySQL dump to PostgreSQL format'
\echo ''

-- Option 1: Use mysql2pgsql tool (if available)
-- mysql2pgsql menuca_v1_restaurant_admins.sql > v1_admins_pg.sql

-- Option 2: Load into temporary MySQL database and export as CSV
\echo '📝 Recommended Approach: Export from MySQL to CSV'
\echo ''
\echo 'Step 1: Load MySQL dump into temporary MySQL database:'
\echo '  mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS temp_v1;"'
\echo '  mysql -u root -p temp_v1 < Database/Restaurant\ Management\ Entity/restaurant\ admins/dumps/menuca_v1_restaurant_admins.sql'
\echo ''
\echo 'Step 2: Export to CSV:'
\echo '  mysql -u root -p temp_v1 -e "SELECT id, restaurant, user_type, fname, lname, email, password, lastlogin, loginCount, activeUser, sendStatement, allowed_restaurants, NULL as created_at, NULL as updated_at FROM restaurant_admins INTO OUTFILE ''C:/temp/v1_restaurant_admins.csv'' FIELDS TERMINATED BY '','' OPTIONALLY ENCLOSED BY ''\\\"'' LINES TERMINATED BY ''\\n'';"'
\echo ''
\echo 'Step 3: Load CSV into PostgreSQL staging:'
\echo '  \COPY staging.v1_restaurant_admin_users (legacy_admin_id, legacy_v1_restaurant_id, user_type, fname, lname, email, password_hash, lastlogin, login_count, active_user, send_statement, allowed_restaurants, created_at, updated_at) FROM ''C:/temp/v1_restaurant_admins.csv'' WITH (FORMAT csv, HEADER false, NULL ''NULL'');'
\echo ''

-- Option 3: Direct PostgreSQL foreign data wrapper (advanced)
\echo '📝 Alternative: Use PostgreSQL Foreign Data Wrapper (Advanced)'
\echo ''
\echo 'If you have mysql_fdw installed:'
\echo '  CREATE EXTENSION IF NOT EXISTS mysql_fdw;'
\echo '  CREATE SERVER mysql_server FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host ''localhost'', port ''3306'');'
\echo '  CREATE USER MAPPING FOR postgres SERVER mysql_server OPTIONS (username ''root'', password ''yourpass'');'
\echo '  CREATE FOREIGN TABLE staging.v1_restaurant_admins_fdw (...) SERVER mysql_server OPTIONS (dbname ''menuca_v1'', table_name ''restaurant_admins'');'
\echo '  INSERT INTO staging.v1_restaurant_admin_users SELECT * FROM staging.v1_restaurant_admins_fdw;'
\echo ''

-- Record count after loading (uncomment after data is loaded)
-- SELECT COUNT(*) AS records_loaded FROM staging.v1_restaurant_admin_users;




