-- SQL Migration: Fix French items stored in name_en
-- These items have French text in name_en - we need to:
-- 1. Copy name_en → name_fr (preserve the French)
-- 2. Replace name_en with proper English translation
-- Date: 2026-01-12

BEGIN;

-- Create staging table with the corrections
CREATE TEMPORARY TABLE french_fixes (
    current_name_en TEXT,  -- Current value (French)
    new_name_en TEXT,      -- New English value
    new_name_fr TEXT       -- French value (same as current_name_en)
);

-- Insert the mappings using dollar quoting for special characters
INSERT INTO french_fixes (current_name_en, new_name_en, new_name_fr) VALUES
(E'L\u2019Hawaïenne', 'The Hawaiian', E'L\u2019Hawaïenne'),
(E'L\u2019Americaine', 'The American', E'L\u2019Americaine'),
(E'Rondelles d\u2019oignons', 'Onion Rings', E'Rondelles d\u2019oignons'),
(E'Pain à l\u2019ail', 'Garlic Bread', E'Pain à l\u2019ail'),
(E'Pain à l\u2019ail 12"', 'Garlic Bread 12"', E'Pain à l\u2019ail 12"'),
(E'Bouteille d\u2019eau', 'Bottle of Water', E'Bouteille d\u2019eau'),
(E'Pain à l\u2019ail (12")', 'Garlic Bread (12")', E'Pain à l\u2019ail (12")'),
(E'Pain à l\u2019ail gratiné', 'Cheese Garlic Bread', E'Pain à l\u2019ail gratiné'),
(E'Tartelette au sirop d\u2019érable du Québec', 'Quebec Maple Syrup Tart', E'Tartelette au sirop d\u2019érable du Québec'),
(E'Sauce à l\u2019ail', 'Garlic Sauce', E'Sauce à l\u2019ail'),
(E'12\u201d Pain à l\u2019ail gratiné', '12" Cheese Garlic Bread', E'12\u201d Pain à l\u2019ail gratiné'),
(E'Assiette Végétarienne Oka\u2019s', E'Oka\u2019s Vegetarian Platter', E'Assiette Végétarienne Oka\u2019s'),
(E'Brochettes D\u2019agneau', 'Lamb Skewers', E'Brochettes D\u2019agneau'),
(E'Chef\u2019s Spécial Chow Mein', E'Chef\u2019s Special Chow Mein', E'Chef\u2019s Spécial Chow Mein'),
(E'Rondelles d\u2019oignon', 'Onion Rings', E'Rondelles d\u2019oignon'),
(E'Pain à l\u2019ail Gratiné 12"', 'Cheese Garlic Bread 12"', E'Pain à l\u2019ail Gratiné 12"'),
(E'Sauce à l\u2019ail familiale', 'Family Garlic Sauce', E'Sauce à l\u2019ail familiale'),
(E'Tartelette sirop de d\u2019érable du Québec', 'Quebec Maple Syrup Tart', E'Tartelette sirop de d\u2019érable du Québec');

-- Show what we're about to update
SELECT 'Fixes to apply:' AS status, COUNT(*) AS count FROM french_fixes;

-- Check how many will match
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN french_fixes f ON d.name_en = f.current_name_en
WHERE d.name_fr IS NULL;

-- Update the dishes table
UPDATE menuca_v3.dishes d
SET 
    name_en = f.new_name_en,
    name_fr = f.new_name_fr,
    updated_at = NOW()
FROM french_fixes f
WHERE d.name_en = f.current_name_en
  AND d.name_fr IS NULL;

-- Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Drop staging table
DROP TABLE french_fixes;

-- Final verification
SELECT 
    'FINAL STATUS' AS status,
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

-- Sample the updated records
SELECT 'Sample updated records:' AS status;
SELECT name_en, name_fr
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute'
LIMIT 10;

COMMIT;

SELECT 'Migration completed!' AS status;
