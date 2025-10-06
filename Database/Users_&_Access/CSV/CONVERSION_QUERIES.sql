-- SQL Queries for Converting Dumps to CSV
-- Run these queries in MySQL Workbench for each table
-- All exports will be saved to: C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/

-- =====================================================
-- 1. menuca_v2_admin_users
-- =====================================================
SELECT *
FROM menuca_v2.admin_users
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_admin_users.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 2. menuca_v2_admin_users_restaurants
-- =====================================================
SELECT *
FROM menuca_v2.admin_users_restaurants
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_admin_users_restaurants.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 3. menuca_v2_ci_sessions (contains BLOB - text-based session data)
-- =====================================================
SELECT *
FROM menuca_v2.ci_sessions
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_ci_sessions.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 4. menuca_v2_login_attempts
-- =====================================================
SELECT *
FROM menuca_v2.login_attempts
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_login_attempts.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 5. menuca_v2_reset_codes
-- =====================================================
SELECT *
FROM menuca_v2.reset_codes
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_reset_codes.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 6. menuca_v2_site_users_autologins
-- =====================================================
SELECT *
FROM menuca_v2.site_users_autologins
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_site_users_autologins.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 7. menuca_v2_site_users_delivery_addresses
-- =====================================================
SELECT *
FROM menuca_v2.site_users_delivery_addresses
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_site_users_delivery_addresses.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 8. menuca_v2_site_users_favorite_restaurants
-- =====================================================
SELECT *
FROM menuca_v2.site_users_favorite_restaurants
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_site_users_favorite_restaurants.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- 9. menuca_v2_site_users_fb
-- =====================================================
SELECT *
FROM menuca_v2.site_users_fb
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/menuca_v2_site_users_fb.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- =====================================================
-- AFTER EXPORT: Move files to project directory
-- =====================================================
-- Run this in PowerShell after exports complete:
-- 
-- cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy"
-- Copy-Item "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\menuca_v2_*.csv" "Database\Users_&_Access\CSV\" -Force
-- 

