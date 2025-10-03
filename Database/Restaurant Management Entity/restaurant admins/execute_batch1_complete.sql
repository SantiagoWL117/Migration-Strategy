-- Complete Batch 1 execution - All 50 records
-- First, let's verify current count, then load remaining records

-- Current count should be 10
SELECT COUNT(*) AS current_count FROM staging.v1_restaurant_admin_users;

-- Clear and reload all 50 records
TRUNCATE TABLE staging.v1_restaurant_admin_users;

