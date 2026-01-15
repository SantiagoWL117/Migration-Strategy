-- SQL Migration: Translate final remaining items
-- Date: 2026-01-12

BEGIN;

-- Create staging table
CREATE TEMPORARY TABLE final_fixes (
    current_name_en TEXT,
    new_name_fr TEXT
);

-- Insert the translations
-- Using Unicode escapes: \u2018 = ', \u2019 = ', \u201d = "
INSERT INTO final_fixes (current_name_en, new_name_fr) VALUES
-- Numbered items (no special chars)
('Bun 2. Chicken, Pork , Breaded Shrimps', 'Bun 2. Poulet, Porc, Crevettes Panées'),
('Bun 5. Meatball, shrimp and spring roll', 'Bun 5. Boulette, crevette et rouleau de printemps'),
('Com 6. Beef, shrimp and meatballs', 'Com 6. Bœuf, crevettes et boulettes'),
('Com 7. Beef, chicken and spring roll', 'Com 7. Bœuf, poulet et rouleau de printemps'),
-- Size variant (curly quote for inch mark)
(E'12\u201d Garlic Bread', E'Pain à l\u2019ail 12\u201d'),
-- Already French (copy with proper apostrophe - \u2018 for left quote)
(E'Pain à l\u2018ail (12\u201d)', E'Pain à l\u2019ail (12")'),
-- Fish 'n' Chips (\u2018 and \u2019 for the 'n')
(E'Senior Homemade Fish \u2018n\u2019 Chips', E'Fish \u2019n\u2019 Chips Maison pour Aînés');

-- Show what we're about to update
SELECT 'Fixes to apply:' AS status, COUNT(*) AS count FROM final_fixes;

-- Check how many will match
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN final_fixes f ON d.name_en = f.current_name_en
WHERE d.name_fr IS NULL;

-- Update the dishes table
UPDATE menuca_v3.dishes d
SET 
    name_fr = f.new_name_fr,
    updated_at = NOW()
FROM final_fixes f
WHERE d.name_en = f.current_name_en
  AND d.name_fr IS NULL;

-- Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Drop staging table
DROP TABLE final_fixes;

-- Final verification
SELECT 
    'FINAL STATUS' AS status,
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

-- Check if any remain
SELECT 'Remaining untranslated:' AS status;
SELECT name_en, COUNT(*) as cnt
FROM menuca_v3.dishes
WHERE name_fr IS NULL
GROUP BY name_en
ORDER BY name_en;

COMMIT;

SELECT 'Migration completed!' AS status;

