-- Migration 004: Populate modifier_prices.modifier_size_variant_id
-- Maps existing size_variant strings to normalized modifier_size_variant_id
-- Expected coverage: 99.5%

BEGIN;

-- Show counts before migration
DO $$
DECLARE
    total_count INT;
    null_count INT;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.modifier_prices WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO null_count FROM menuca_v3.modifier_prices WHERE deleted_at IS NULL AND modifier_size_variant_id IS NULL;
    RAISE NOTICE 'BEFORE: modifier_prices total=%, unmapped=%', total_count, null_count;
END $$;

-- Map 'small' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'small'
  AND LOWER(mp.size_variant) IN ('small', 'petite', 'petit')
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'medium' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'medium'
  AND LOWER(mp.size_variant) IN ('medium', 'moyenne')
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'large' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'large'
  AND LOWER(mp.size_variant) IN ('large', 'grande', 'grand')
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'x-large' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'x-large'
  AND LOWER(mp.size_variant) IN ('x-large', 'x-grande', 'xl', 'x-grand', 'xgrande')
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'standard' variants (empty, none, null, standard)
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'standard'
  AND (
    LOWER(COALESCE(mp.size_variant, '')) IN ('standard', '', 'none', 'null')
    OR mp.size_variant IS NULL
  )
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'size-5' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'size-5'
  AND mp.size_variant = 'Size 5'
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'size-6' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'size-6'
  AND mp.size_variant = 'Size 6'
  AND mp.modifier_size_variant_id IS NULL;

-- Map 'size-7' variants
UPDATE menuca_v3.modifier_prices mp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'size-7'
  AND mp.size_variant = 'Size 7'
  AND mp.modifier_size_variant_id IS NULL;

-- Show counts after migration
DO $$
DECLARE
    total_count INT;
    mapped_count INT;
    unmapped_count INT;
    coverage NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.modifier_prices WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO mapped_count FROM menuca_v3.modifier_prices WHERE deleted_at IS NULL AND modifier_size_variant_id IS NOT NULL;
    SELECT COUNT(*) INTO unmapped_count FROM menuca_v3.modifier_prices WHERE deleted_at IS NULL AND modifier_size_variant_id IS NULL;
    coverage := ROUND(mapped_count::NUMERIC / total_count * 100, 1);
    
    RAISE NOTICE 'AFTER: modifier_prices total=%, mapped=%, unmapped=%, coverage=%', 
        total_count, mapped_count, unmapped_count, coverage || '%';
    
    -- Show unmapped variants if any
    IF unmapped_count > 0 THEN
        RAISE NOTICE 'Unmapped size_variants (top 10):';
    END IF;
END $$;

-- Show unmapped variants for debugging
SELECT size_variant, COUNT(*) as count
FROM menuca_v3.modifier_prices
WHERE deleted_at IS NULL AND modifier_size_variant_id IS NULL
GROUP BY size_variant
ORDER BY count DESC
LIMIT 10;

COMMIT;







