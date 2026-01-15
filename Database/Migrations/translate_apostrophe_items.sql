-- SQL Migration: Translate high-frequency apostrophe items
-- Date: 2026-01-12

BEGIN;

-- Create staging table
CREATE TEMPORARY TABLE apostrophe_fixes (
    current_name_en TEXT,
    new_name_fr TEXT
);

-- Insert the translations (using \u2019 for curly apostrophe)
INSERT INTO apostrophe_fixes (current_name_en, new_name_fr) VALUES
(E'Vegan\u2019s Delight Pizza (V)', 'Pizza Délice Végane (V)'),
(E'General Tao\u2019s Chicken', 'Poulet Général Tao'),
(E'Keith\u2019s Red Amber 473 ml Beer (5% ABV)', E'Bière Keith\u2019s Red Amber 473 ml (5% ABV)'),
(E'Buddha\u2019s Delight', 'Délice de Bouddha'),
(E'VEGAN Vegan\u2019s Delight Pizza (V)', 'VÉGANE Pizza Délice Végane (V)'),
(E'Meat Lover\u2019s', 'Amateurs de Viande'),
(E'General Tao\u2019s Tofu', 'Tofu Général Tao');

-- Show what we're about to update
SELECT 'Fixes to apply:' AS status, COUNT(*) AS count FROM apostrophe_fixes;

-- Check how many will match
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN apostrophe_fixes f ON d.name_en = f.current_name_en
WHERE d.name_fr IS NULL;

-- Update the dishes table
UPDATE menuca_v3.dishes d
SET 
    name_fr = f.new_name_fr,
    updated_at = NOW()
FROM apostrophe_fixes f
WHERE d.name_en = f.current_name_en
  AND d.name_fr IS NULL;

-- Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Drop staging table
DROP TABLE apostrophe_fixes;

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

