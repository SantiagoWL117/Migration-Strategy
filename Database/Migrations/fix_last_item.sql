-- Fix the last remaining duplicate
BEGIN;

UPDATE menuca_v3.dishes
SET name_fr = E'9. Poulet Général Tao (piquant et épicé), bœuf et brocoli.',
    updated_at = NOW()
WHERE name_en LIKE '9. General Tao%Beef and Broccoli%'
  AND name_en = name_fr;

-- Verify
SELECT 'Final check - remaining duplicates with English phrases:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE name_en = name_fr 
  AND (name_en ILIKE '%with %' OR name_en ILIKE '% and %');

COMMIT;

