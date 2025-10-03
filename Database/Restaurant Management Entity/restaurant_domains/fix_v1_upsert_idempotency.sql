-- ============================================================================
-- Fix V1 Upsert Logic for Idempotency (Issue 6.1)
-- ============================================================================
-- Purpose: Prevent V1 from overwriting V2's is_enabled=FALSE status
-- Date: 2025-10-02
-- Target: V1 → V3 migration step
-- Issue: V1 always sets is_enabled=TRUE, which could re-enable disabled V2 domains
-- Fix: Preserve existing is_enabled value if already set
-- ============================================================================

-- This is the CORRECTED V1 migration step
-- Replace the original V1 migration (lines 103-151) with this version

BEGIN;

-- V1 → v3 (CORRECTED VERSION)
WITH v1_norm AS (
  SELECT
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\.|/$', '', 'i'
      )
    ) AS domain_norm,
    ROW_NUMBER() OVER (
      PARTITION BY r.id,
        lower(
          regexp_replace(
            regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
            '^www\.|/$', '', 'i'
          )
        )
      ORDER BY d.id
    ) AS rn
  FROM staging.v1_restaurant_domains d
  JOIN menuca_v3.restaurants r ON r.legacy_v1_id = d.restaurant
  WHERE COALESCE(trim(d.domain),'') <> ''
)
INSERT INTO menuca_v3.restaurant_domains (
  restaurant_id, domain, domain_type, is_enabled, added_by, created_at, disabled_by, disabled_at, updated_at
)
SELECT v3_restaurant_id,
       domain_norm,
       NULL::text              AS domain_type,
       true                    AS is_enabled,
       NULL::integer           AS added_by,
       now()                   AS created_at,
       NULL::integer           AS disabled_by,
       NULL::timestamptz       AS disabled_at,
       NULL::timestamptz       AS updated_at
FROM v1_norm
WHERE rn = 1
ON CONFLICT (restaurant_id, lower(domain)) DO UPDATE
SET 
    -- ✅ FIX: Preserve existing is_enabled if already set (don't overwrite V2's FALSE)
    is_enabled  = COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled),
    
    -- Keep existing logic for other fields
    domain_type = COALESCE(menuca_v3.restaurant_domains.domain_type, EXCLUDED.domain_type),
    added_by    = COALESCE(menuca_v3.restaurant_domains.added_by, EXCLUDED.added_by),
    disabled_by = COALESCE(EXCLUDED.disabled_by, menuca_v3.restaurant_domains.disabled_by),
    disabled_at = COALESCE(EXCLUDED.disabled_at, menuca_v3.restaurant_domains.disabled_at),
    updated_at  = COALESCE(EXCLUDED.updated_at, menuca_v3.restaurant_domains.updated_at)
WHERE 
    -- Only update if values are actually different
    menuca_v3.restaurant_domains.is_enabled  IS DISTINCT FROM COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled)
   OR menuca_v3.restaurant_domains.domain_type IS DISTINCT FROM EXCLUDED.domain_type
   OR menuca_v3.restaurant_domains.added_by    IS DISTINCT FROM EXCLUDED.added_by
   OR menuca_v3.restaurant_domains.disabled_at IS DISTINCT FROM EXCLUDED.disabled_at
   OR menuca_v3.restaurant_domains.updated_at  IS DISTINCT FROM EXCLUDED.updated_at;

COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================

-- Verify no disabled V2 domains were re-enabled by V1
WITH v2_disabled AS (
  SELECT 
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\.|/$', '', 'i'
      )
    ) AS domain_norm
  FROM staging.v2_restaurants_domain d
  JOIN menuca_v3.restaurants r ON r.legacy_v2_id = d.restaurant_id
  WHERE COALESCE(trim(d.domain),'') <> ''
    AND lower(d.enabled) = 'n'
)
SELECT COUNT(*) AS v2_disabled_incorrectly_enabled
FROM v2_disabled v2
JOIN menuca_v3.restaurant_domains v3 
  ON v3.restaurant_id = v2.v3_restaurant_id 
  AND lower(v3.domain) = v2.domain_norm
WHERE v3.is_enabled IS NOT FALSE;

-- Expected: 0 rows

-- ============================================================================
-- KEY CHANGES SUMMARY
-- ============================================================================
-- 
-- BEFORE (Line 141):
--   SET is_enabled = EXCLUDED.is_enabled,
-- 
-- AFTER (Line 49):
--   SET is_enabled = COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled),
-- 
-- IMPACT:
-- - If domain already exists with is_enabled=FALSE (from V2), preserve FALSE
-- - If domain doesn't exist, insert with is_enabled=TRUE (from V1)
-- - Prevents V1 from re-enabling disabled V2 domains on re-run
-- 
-- ============================================================================
-- END OF FIX SCRIPT
-- ============================================================================

