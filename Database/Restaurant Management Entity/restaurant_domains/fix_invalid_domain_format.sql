-- ============================================================================
-- Fix Invalid Domain Format - Remove Leading '!' from phovanvan.menu.ca
-- ============================================================================
-- Purpose: Fix the 1 invalid domain found in migration review (Section 5.8)
-- Date: 2025-10-02
-- Target: menuca_v3.restaurant_domains (ID 2659)
-- Issue: Domain has invalid leading '!' character
-- ============================================================================

BEGIN;

-- Fix the invalid domain format
UPDATE menuca_v3.restaurant_domains
SET 
  domain = 'phovanvan.menu.ca',
  updated_at = NOW()
WHERE id = 2659
  AND domain = '!phovanvan.menu.ca';

-- Verify the fix
SELECT 
  id,
  restaurant_id,
  domain,
  is_enabled,
  updated_at,
  '✅ Fixed' AS status
FROM menuca_v3.restaurant_domains
WHERE id = 2659;

COMMIT;

-- ============================================================================
-- Post-Fix Verification
-- ============================================================================

-- Verify no more invalid domain formats remain
SELECT COUNT(*) AS remaining_invalid_domains
FROM menuca_v3.restaurant_domains
WHERE domain !~* '^[a-z0-9.-]+\.[a-z]{2,}$';

-- Expected: 0 rows

-- ============================================================================
-- END OF FIX SCRIPT
-- ============================================================================

