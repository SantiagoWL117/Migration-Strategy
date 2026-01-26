-- Fix data quality issues in users table
-- Date: 2026-01-26
-- Issues identified during User Entity audit

BEGIN;

-- Fix 1: Set language to 'EN' where NULL (89 rows expected)
UPDATE menuca_v3.users 
SET language = 'EN', updated_at = now()
WHERE language IS NULL;

-- Fix 2: Set origin_restaurant_id to NULL where = 0 (8,910 rows expected)
-- 0 is not a valid restaurant ID, NULL is the correct representation of "no origin"
UPDATE menuca_v3.users 
SET origin_restaurant_id = NULL, updated_at = now()
WHERE origin_restaurant_id = 0;

COMMIT;

-- Verify fixes
SELECT 
    'NULL language remaining' as check_name, 
    COUNT(*) as count 
FROM menuca_v3.users WHERE language IS NULL
UNION ALL
SELECT 
    'origin_restaurant_id = 0 remaining', 
    COUNT(*) 
FROM menuca_v3.users WHERE origin_restaurant_id = 0;
