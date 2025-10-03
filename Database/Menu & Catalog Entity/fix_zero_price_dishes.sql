-- ============================================================================
-- Fix Zero-Price Dishes - Mark as Inactive
-- ============================================================================
-- Purpose: Mark dishes with $0.00 price as inactive (hidden from customers)
-- Strategy: Update is_available flag instead of deleting data
-- Date: 2025-10-02
-- ============================================================================

-- RATIONALE:
-- - Preserves all data (no loss)
-- - Restaurant owners can still see these items in admin
-- - Customers don't see "$0.00" or "FREE" items
-- - Can be re-activated once prices are fixed
-- ============================================================================

BEGIN;

-- Create backup before modification
CREATE TABLE IF NOT EXISTS staging.v3_dishes_backup_before_price_fix AS
SELECT * FROM staging.v3_dishes WHERE prices = '{"default": "0.00"}'::jsonb;

-- Show what we're about to fix
SELECT 
  'BEFORE FIX' as status,
  is_available,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v3_dishes WHERE prices = '{"default": "0.00"}'::jsonb), 2) || '%' as percentage
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb
GROUP BY is_available;

-- Update dishes with $0.00 price to inactive
UPDATE staging.v3_dishes
SET 
  is_available = false,
  updated_at = NOW()
WHERE prices = '{"default": "0.00"}'::jsonb
  AND is_available = true; -- Only update currently active ones

-- Show results
SELECT 
  'AFTER FIX' as status,
  is_available,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v3_dishes WHERE prices = '{"default": "0.00"}'::jsonb), 2) || '%' as percentage
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb
GROUP BY is_available;

-- Summary
SELECT 
  'SUMMARY' as report,
  'Total dishes with $0.00 price' as metric,
  COUNT(*) as value
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb

UNION ALL

SELECT 
  'SUMMARY',
  'Now marked as INACTIVE (hidden from customers)',
  COUNT(*)
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb
  AND is_available = false

UNION ALL

SELECT 
  'SUMMARY',
  'Still ACTIVE (already inactive or different reason)',
  COUNT(*)
FROM staging.v3_dishes
WHERE prices = '{"default": "0.00"}'::jsonb
  AND is_available = true

UNION ALL

SELECT 
  'SUMMARY',
  'Total ACTIVE dishes with valid prices',
  COUNT(*)
FROM staging.v3_dishes
WHERE is_available = true
  AND prices != '{"default": "0.00"}'::jsonb;

-- Verify no free food showing to customers
SELECT 
  'CUSTOMER VIEW CHECK' as check_type,
  'Active dishes with $0.00 price (should be 0)' as check_name,
  COUNT(*) as count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ PASS - No free food!'
    ELSE '❌ FAIL - Free food still visible!'
  END as status
FROM staging.v3_dishes
WHERE is_available = true
  AND prices = '{"default": "0.00"}'::jsonb;

COMMIT;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS (if needed)
-- ============================================================================
-- To undo this change:
-- 
-- UPDATE staging.v3_dishes d
-- SET is_available = b.is_available
-- FROM staging.v3_dishes_backup_before_price_fix b
-- WHERE d.id = b.id;
-- ============================================================================

