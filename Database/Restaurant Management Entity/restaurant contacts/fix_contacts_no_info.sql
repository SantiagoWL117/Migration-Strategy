/**
 * Fix: Mark Contacts with No Email/Phone as Inactive
 * 
 * Issue: 7 contacts (0.8%) have neither email nor phone number
 * Impact: These contacts cannot be reached and have no operational value
 * Solution: Mark as is_active=FALSE to preserve data while preventing use
 * 
 * Affected Records: 7
 * Severity: Low
 * Risk: None (safe operation, preserves data)
 * 
 * Execution: Run in Supabase SQL Editor
 * Rollback: See ROLLBACK section at bottom if needed
 */

-- ============================================
-- STEP 1: VERIFICATION (Safe to run anytime)
-- ============================================

-- Preview: Show current state of affected records
SELECT 
  id,
  restaurant_id,
  first_name,
  last_name,
  email,
  phone,
  is_active,
  title,
  created_at
FROM menuca_v3.restaurant_contacts
WHERE (email IS NULL OR email = '')
  AND (phone IS NULL OR phone = '')
ORDER BY id;

-- Expected: 7 records, all with is_active=TRUE

-- ============================================
-- STEP 2: APPLY FIX (Run after verification)
-- ============================================

BEGIN;

-- Mark contacts with no contact info as inactive
UPDATE menuca_v3.restaurant_contacts
SET 
  is_active = FALSE,
  updated_at = NOW()
WHERE (email IS NULL OR email = '')
  AND (phone IS NULL OR phone = '')
RETURNING 
  id,
  restaurant_id,
  first_name,
  last_name,
  is_active,
  updated_at;

-- Expected: 7 rows updated

COMMIT;

-- ============================================
-- STEP 3: POST-VERIFICATION (Run after commit)
-- ============================================

-- Confirm: All affected records now inactive
SELECT 
  id,
  restaurant_id,
  first_name,
  last_name,
  email,
  phone,
  is_active,
  updated_at
FROM menuca_v3.restaurant_contacts
WHERE (email IS NULL OR email = '')
  AND (phone IS NULL OR phone = '')
ORDER BY id;

-- Expected: 7 records, all with is_active=FALSE and recent updated_at

-- Summary statistics
SELECT 
  is_active,
  COUNT(*) AS contact_count
FROM menuca_v3.restaurant_contacts
GROUP BY is_active;

-- Expected: 
--   is_active=TRUE:  828
--   is_active=FALSE: 7

-- ============================================
-- ROLLBACK (Only if needed - before COMMIT)
-- ============================================

-- If you need to undo the change before COMMIT:
-- ROLLBACK;

-- ============================================
-- MANUAL ROLLBACK (If already committed)
-- ============================================

-- If you need to revert after COMMIT (restore to active):
/*
BEGIN;

UPDATE menuca_v3.restaurant_contacts
SET 
  is_active = TRUE,
  updated_at = NOW()
WHERE id IN (1750, 1968, 2080, 2182, 2305, 2355, 2395);

-- Expected: 7 rows updated

COMMIT;
*/

-- ============================================
-- AFFECTED RECORDS DETAIL
-- ============================================

/*
ID    | Restaurant ID | Name                | Title   | Issue
------|---------------|---------------------|---------|-------
1750  | 115          | Bromina Mehta (wife)| owner   | No email, no phone
1968  | 294          | Jian Xiong Lin      | owner   | No email, no phone
2080  | 403          | Lam Truyen          | owner   | No email, no phone
2182  | 508          | Miao Ci Deng        | owner   | No email, no phone
2305  | 644          | Mohamed Maaloul     | owner   | No email, no phone
2355  | 698          | Adnan Amidi         | manager | No email, no phone
2395  | 745          | Maria               | owner   | No email, no phone

Note: Most of these are for closed/dropped restaurants based on earlier analysis
*/


