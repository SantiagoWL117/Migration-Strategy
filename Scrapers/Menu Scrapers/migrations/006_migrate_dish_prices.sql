-- Migration 006: Populate dish_prices.dish_size_variant_id
-- Maps existing size_variant strings to normalized dish_size_variant_id
-- Expected coverage: ~88.9%

BEGIN;

-- Show counts before migration
DO $$
DECLARE
    total_count INT;
    null_count INT;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.dish_prices WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO null_count FROM menuca_v3.dish_prices WHERE deleted_at IS NULL AND dish_size_variant_id IS NULL;
    RAISE NOTICE 'BEFORE: dish_prices total=%, unmapped=%', total_count, null_count;
END $$;

-- Map by exact match on code (case-insensitive)
-- This handles: Standard, Small, Medium, Large, X-Large, Regular, etc.
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE LOWER(dp.size_variant) = dsv.code
  AND dp.deleted_at IS NULL
  AND dp.dish_size_variant_id IS NULL;

-- Map X-large (with lowercase l) to x-large
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'x-large'
  AND LOWER(dp.size_variant) = 'x-large'
  AND dp.deleted_at IS NULL
  AND dp.dish_size_variant_id IS NULL;

-- Map dimensional sizes: 6", 7", 8", 9", 12", 13", 14", 16", 18"
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '6-inch' AND dp.size_variant = '6"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '7-inch' AND dp.size_variant = '7"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '8-inch' AND dp.size_variant = '8"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '9-inch' AND dp.size_variant = '9"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '12-inch' AND dp.size_variant = '12"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '13-inch' AND dp.size_variant = '13"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '14-inch' AND dp.size_variant = '14"'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '16-inch' AND dp.size_variant IN ('16"', '16''''')
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '18-inch' AND dp.size_variant IN ('18"', '18''''')
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map descriptive sizes: Small (9"), Medium (12"), Medium (13"), Large (15")
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'small-9' AND dp.size_variant = 'Small (9")'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'medium-12' AND dp.size_variant = 'Medium (12")'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'medium-13' AND dp.size_variant = 'Medium (13")'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'large-15' AND dp.size_variant = 'Large (15")'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map 2x combo sizes (English)
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-small' AND dp.size_variant = '2 x Small'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-medium' AND dp.size_variant = '2 x Medium'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-large' AND dp.size_variant = '2 x Large'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-x-large' AND dp.size_variant = '2 x X-Large'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map 2x combo sizes (French)
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-petit' AND dp.size_variant = '2 x Petit'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-petite' AND dp.size_variant = '2 x Petite'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-moyenne' AND dp.size_variant = '2 x Moyenne'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-grande' AND dp.size_variant = '2 x Grande'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-x-grande' AND dp.size_variant = '2 x X-Grande'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2x-xgrande' AND dp.size_variant = '2 x XGrande'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map container sizes
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'can' AND LOWER(dp.size_variant) = 'can'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'canette' AND LOWER(dp.size_variant) = 'canette'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map volume sizes
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '591ml' AND dp.size_variant IN ('591ml', '591ml.')
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '591-ml' AND dp.size_variant = '591 ml'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2l' AND dp.size_variant = '2L'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '2-l' AND dp.size_variant = '2 L'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map portion sizes
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'jumbo' AND LOWER(dp.size_variant) = 'jumbo'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'bambino' AND LOWER(dp.size_variant) = 'bambino'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'personal' AND LOWER(dp.size_variant) = 'personal'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'familiale' AND LOWER(dp.size_variant) = 'familiale'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'platter' AND LOWER(dp.size_variant) = 'platter'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'sandwich' AND LOWER(dp.size_variant) = 'sandwich'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'wrap' AND LOWER(dp.size_variant) = 'wrap'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'single' AND LOWER(dp.size_variant) = 'single'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map weight sizes
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = '1lb' AND dp.size_variant IN ('1 Lb', '1Lb', '1 lb', '1lb')
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'half-lb' AND dp.size_variant IN ('1/2 Lb', '1/2 lb', '1/2Lb')
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Map protein types (these have NULL modifier_size_variant_id)
UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'chicken' AND LOWER(dp.size_variant) = 'chicken'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'poulet' AND LOWER(dp.size_variant) = 'poulet'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'beef' AND LOWER(dp.size_variant) = 'beef'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'boeuf' AND LOWER(dp.size_variant) = 'boeuf'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'shrimp' AND LOWER(dp.size_variant) = 'shrimp'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'pork' AND LOWER(dp.size_variant) = 'pork'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'lamb' AND LOWER(dp.size_variant) = 'lamb'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'tofu' AND LOWER(dp.size_variant) = 'tofu'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'vegetable' AND LOWER(dp.size_variant) = 'vegetable'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'veggie' AND LOWER(dp.size_variant) = 'veggie'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

UPDATE menuca_v3.dish_prices dp
SET dish_size_variant_id = dsv.id
FROM menuca_v3.dish_size_variants dsv
WHERE dsv.code = 'mixte' AND LOWER(dp.size_variant) = 'mixte'
  AND dp.deleted_at IS NULL AND dp.dish_size_variant_id IS NULL;

-- Show counts after migration
DO $$
DECLARE
    total_count INT;
    mapped_count INT;
    unmapped_count INT;
    coverage NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_count FROM menuca_v3.dish_prices WHERE deleted_at IS NULL;
    SELECT COUNT(*) INTO mapped_count FROM menuca_v3.dish_prices WHERE deleted_at IS NULL AND dish_size_variant_id IS NOT NULL;
    SELECT COUNT(*) INTO unmapped_count FROM menuca_v3.dish_prices WHERE deleted_at IS NULL AND dish_size_variant_id IS NULL;
    coverage := ROUND(mapped_count::NUMERIC / total_count * 100, 1);
    
    RAISE NOTICE 'AFTER: dish_prices total=%, mapped=%, unmapped=%, coverage=%', 
        total_count, mapped_count, unmapped_count, coverage || '%';
END $$;

-- Show top unmapped variants for debugging
SELECT 'Top 20 unmapped size_variants:' as info;
SELECT size_variant, COUNT(*) as count
FROM menuca_v3.dish_prices
WHERE deleted_at IS NULL AND dish_size_variant_id IS NULL
GROUP BY size_variant
ORDER BY count DESC
LIMIT 20;

COMMIT;







