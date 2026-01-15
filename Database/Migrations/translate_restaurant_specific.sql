-- SQL Migration: Translate restaurant-specific items
-- Date: 2026-01-12

BEGIN;

-- Create staging table
CREATE TEMPORARY TABLE restaurant_fixes (
    current_name_en TEXT,
    new_name_fr TEXT
);

-- Insert the translations (using \u2019 for curly apostrophe)
INSERT INTO restaurant_fixes (current_name_en, new_name_fr) VALUES
(E'Big D\u2019S Favourites', E'Favoris de Big D\u2019S'),
(E'Bobbie\u2019s Special Spaghetti', 'Spaghetti Spécial de Bobbie'),
(E'Cathay\u2019s Crispy Beef', E'Bœuf Croustillant Cathay\u2019s'),
(E'Cathay\u2019s Crispy Chicken', E'Poulet Croustillant Cathay\u2019s'),
(E'Cathay\u2019s House Special Fried Rice', E'Riz Frit Spécial Maison Cathay\u2019s'),
(E'Cathay\u2019s Spicy Noodles', E'Nouilles Épicées Cathay\u2019s'),
(E'Cathay\u2019s Spring Roll', E'Rouleau de Printemps Cathay\u2019s'),
(E'Father\u2019s Day Promo', 'Promo Fête des Pères'),
(E'General Tao\u2019s Tofu', 'Tofu Général Tao'),
(E'General Tso\u2019s Chicken', 'Poulet Général Tso'),
(E'General TSO\u2019s Chicken', 'Poulet Général TSO'),
(E'General TSO\u2019s Chicken with Shanghai Noodle', 'Poulet Général TSO avec Nouilles Shanghai'),
(E'Georgie\u2019s Club', 'Club de Georgie'),
(E'Georgie\u2019s Special Spaghetti', 'Spaghetti Spécial de Georgie'),
(E'Halal Lana\u2019s Pizza (Fajita)', 'Pizza Halal de Lana (Fajita)'),
(E'LA OKA\u2019S', E'LA OKA\u2019S'),
(E'LA OPA\u2019S', E'LA OPA\u2019S'),
(E'Melina\u2019s Famous Calzones', 'Calzones Célèbres de Melina'),
(E'Milano\u2019s Favorite', 'Favori de Milano'),
(E'Miss Mar\u2019s Honey', 'Miel de Miss Mar'),
(E'Miss Vickie\u2019s Original', E'Miss Vickie\u2019s Original'),
(E'Pizza Lover\u2019s', 'Amateurs de Pizza'),
(E'Senior Homemade Fish \u2019n\u2019 Chips', E'Fish \u2019n\u2019 Chips Maison pour Aînés'),
(E'Smokin\u2019 Hot', 'Fumant Épicé'),
(E'The Pizza Lover\u2019s Dream', 'Le Rêve des Amateurs de Pizza'),
(E'Tony\u2019s Favorite', 'Favori de Tony'),
(E'Tony\u2019s Fried Chicken Platter (3 pcs)', 'Assiette de Poulet Frit de Tony (3 mcx)'),
(E'Yorgo\u2019s Supreme', 'Suprême de Yorgo');

-- Show what we're about to update
SELECT 'Fixes to apply:' AS status, COUNT(*) AS count FROM restaurant_fixes;

-- Check how many will match
SELECT 'Dishes that will be updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes d
JOIN restaurant_fixes f ON d.name_en = f.current_name_en
WHERE d.name_fr IS NULL;

-- Update the dishes table
UPDATE menuca_v3.dishes d
SET 
    name_fr = f.new_name_fr,
    updated_at = NOW()
FROM restaurant_fixes f
WHERE d.name_en = f.current_name_en
  AND d.name_fr IS NULL;

-- Report results
SELECT 'Rows updated:' AS status, COUNT(*) AS count
FROM menuca_v3.dishes
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Drop staging table
DROP TABLE restaurant_fixes;

-- Final verification
SELECT 
    'FINAL STATUS' AS status,
    COUNT(*) AS total_dishes,
    COUNT(name_fr) AS has_french,
    COUNT(*) - COUNT(name_fr) AS needs_french,
    ROUND(100.0 * COUNT(name_fr) / COUNT(*), 1) AS percent_complete
FROM menuca_v3.dishes;

-- Show remaining untranslated
SELECT 'Remaining untranslated:' AS status;
SELECT name_en, COUNT(*) as cnt
FROM menuca_v3.dishes
WHERE name_fr IS NULL
GROUP BY name_en
ORDER BY name_en;

COMMIT;

SELECT 'Migration completed!' AS status;

