-- SQL Migration: Copy name_en to name_fr for French dishes and numbered items
-- Date: 2026-01-12

BEGIN;

-- 2a. Copy French dishes from name_en to name_fr
-- (dishes where name_en already contains French text)
UPDATE menuca_v3.dishes
SET name_fr = name_en,
    updated_at = NOW()
WHERE name_fr IS NULL
  AND (
    name_en LIKE '% et %'
    OR name_en LIKE '% avec %'
    OR name_en LIKE 'Le %'
    OR name_en LIKE 'La %'
    OR name_en LIKE 'Les %'
    OR name_en ILIKE '%Poutine%'
    OR name_en ILIKE '%Beignet%'
    OR name_en ILIKE '%Ailes%'
    OR name_en ILIKE '%Garni%'
    OR name_en LIKE '%mcx%'
    OR name_en ILIKE '%Poulet%'
    OR name_en ILIKE '%Boeuf%'
    OR name_en ILIKE '%Porc%'
    OR name_en ILIKE '%Grande%'
    OR name_en ILIKE '%Moyenne%'
    OR name_en ILIKE '%Petite%'
    OR name_en ILIKE '%Fromage%'
    OR name_en ILIKE '%Salade%'
    OR name_en LIKE '%Sous Marin%'
    OR name_en ILIKE '%morceaux%'
    OR name_en ILIKE '%Frites%'
  );

SELECT 'French dishes updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute'
  AND name_fr = name_en;

-- 2b. Copy numbered items from name_en to name_fr
-- (dishes starting with numbers like "01.", "12.", or letters like "A1.")
UPDATE menuca_v3.dishes
SET name_fr = name_en,
    updated_at = NOW()
WHERE name_fr IS NULL
  AND (
    name_en ~ '^[0-9]+[\.)]'
    OR name_en ~ '^[A-Z][0-9]*[\.)]'
  );

SELECT 'Numbered items updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute'
  AND name_fr = name_en
  AND (name_en ~ '^[0-9]+[\.)]' OR name_en ~ '^[A-Z][0-9]*[\.)]');

-- Verify final state
SELECT 
    'FINAL STATUS' AS status,
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

COMMIT;

SELECT 'Migration completed!' AS status;

