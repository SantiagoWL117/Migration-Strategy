-- Migration 005: Populate combo_modifier_prices.modifier_size_variant_id
-- Maps existing size_variant strings to normalized modifier_size_variant_id
-- Expected coverage: 100%

BEGIN;

-- Show counts before migration
DO $$
DECLARE
    total_count INT;
    null_count INT;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.combo_modifier_prices;
    SELECT COUNT(*) INTO null_count FROM menuca_v3.combo_modifier_prices WHERE modifier_size_variant_id IS NULL;
    RAISE NOTICE 'BEFORE: combo_modifier_prices total=%, unmapped=%', total_count, null_count;
END $$;

-- Map 'small' variants
UPDATE menuca_v3.combo_modifier_prices cmp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'small'
  AND LOWER(cmp.size_variant) = 'small'
  AND cmp.modifier_size_variant_id IS NULL;

-- Map 'medium' variants
UPDATE menuca_v3.combo_modifier_prices cmp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'medium'
  AND LOWER(cmp.size_variant) = 'medium'
  AND cmp.modifier_size_variant_id IS NULL;

-- Map 'large' variants
UPDATE menuca_v3.combo_modifier_prices cmp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'large'
  AND LOWER(cmp.size_variant) = 'large'
  AND cmp.modifier_size_variant_id IS NULL;

-- Map 'x-large' variants
UPDATE menuca_v3.combo_modifier_prices cmp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'x-large'
  AND LOWER(cmp.size_variant) = 'x-large'
  AND cmp.modifier_size_variant_id IS NULL;

-- Map 'standard' variants
UPDATE menuca_v3.combo_modifier_prices cmp
SET modifier_size_variant_id = msv.id
FROM menuca_v3.modifier_size_variants msv
WHERE msv.code = 'standard'
  AND LOWER(cmp.size_variant) = 'standard'
  AND cmp.modifier_size_variant_id IS NULL;

-- Show counts after migration
DO $$
DECLARE
    total_count INT;
    mapped_count INT;
    unmapped_count INT;
    coverage NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.combo_modifier_prices;
    SELECT COUNT(*) INTO mapped_count FROM menuca_v3.combo_modifier_prices WHERE modifier_size_variant_id IS NOT NULL;
    SELECT COUNT(*) INTO unmapped_count FROM menuca_v3.combo_modifier_prices WHERE modifier_size_variant_id IS NULL;
    coverage := ROUND(mapped_count::NUMERIC / total_count * 100, 1);
    
    RAISE NOTICE 'AFTER: combo_modifier_prices total=%, mapped=%, unmapped=%, coverage=%', 
        total_count, mapped_count, unmapped_count, coverage || '%';
END $$;

-- Show unmapped variants for debugging (if any)
SELECT size_variant, COUNT(*) as count
FROM menuca_v3.combo_modifier_prices
WHERE modifier_size_variant_id IS NULL
GROUP BY size_variant
ORDER BY count DESC
LIMIT 10;

COMMIT;







