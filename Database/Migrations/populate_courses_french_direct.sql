-- SQL Migration: Populate courses.name_fr with French translations
-- Date: 2026-01-12
-- Method: Direct SQL UPDATEs with embedded translations (batch 1 of 8)

BEGIN;

-- Temporary table for translations
CREATE TEMPORARY TABLE course_trans (name_en TEXT, name_fr TEXT);

-- Batch 1: Lines 1-100
INSERT INTO course_trans (name_en, name_fr) VALUES
('Platters', 'Assiettes'),
('Shepherds Of Good Hope', 'Shepherds Of Good Hope'),
('Bruyère DONATION', 'Don Bruyère'),
('VEGAN VEGAN VEGAN', 'VÉGANE VÉGANE VÉGANE'),
('Cold Subs', 'Sous-Marins Froids'),
('PIZZAS WITH FANTINO MONDELLO PANCETTA', 'PIZZAS AVEC PANCETTA FANTINO MONDELLO'),
('Southern Fried Chicken', 'Poulet Frit du Sud'),
('Mini Donuts Hot and Fresh Made', 'Mini Beignes Chauds et Frais'),
('UNLISTED DISHES', 'PLATS NON LISTÉS'),
('Features Of The Month', 'Promotions du Mois'),
('Hot Subs', 'Sous-Marins Chauds'),
('Super Bowl Special', 'Spécial Super Bowl'),
('Gourmet Pizza', 'Pizza Gastronomique'),
('Donairs', 'Donairs'),
('12 Chefs 12 Months 12 Charities', '12 Chefs 12 Mois 12 Organismes'),
('Egg Foo Young', 'Egg Foo Young'),
('Unlisted Dishes', 'Plats Non Listés'),
('Lunch Special', 'Spécial du Midi'),
('Pastas', 'Pâtes'),
('Submarines', 'Sous-Marins'),
('Combination Plates', 'Assiettes Combinées'),
('2 Pizza and Two Free 591ml Drinks', '2 Pizzas et Deux Boissons 591ml Gratuites'),
('2 Pizza and 2 free 591ml Drinks', '2 Pizzas et 2 Boissons 591ml Gratuites'),
('Burgers - Sandwiches - Platters', 'Burgers - Sandwichs - Assiettes'),
('Every Day Special', 'Spécial Chaque Jour'),
('Chop Suey', 'Chop Suey'),
('Daily Special', 'Spécial du Jour'),
('Hot Sandwiches', 'Sandwichs Chauds'),
('Two Pizza Deal', 'Offre Deux Pizzas'),
('Feature Of The Month', 'Promotion du Mois'),
('Les Salades', 'Les Salades'),
('Pita Wraps', 'Wraps Pita'),
('Salades', 'Salades'),
('Everyday Specials', 'Spéciaux Quotidiens'),
('Boissons', 'Boissons'),
('Southern Style Fried Chicken', 'Poulet Frit Style du Sud'),
('Ailes de Poulet', 'Ailes de Poulet'),
('Italian Dishes', 'Plats Italiens'),
('Alcoholic Beverages', 'Boissons Alcoolisées'),
('Breuvages', 'Breuvages'),
('Miscellaneous', 'Divers'),
('Beef Donairs and Chicken Shawarma Wraps', 'Donairs au Bœuf et Wraps Shawarma au Poulet'),
('Plats De Spécialités', 'Plats De Spécialités'),
('Rice', 'Riz'),
('Our New Creations SOLO', 'Nos Nouvelles Créations SOLO'),
('Twin Pizzas', 'Pizzas Jumelles'),
('Spécial Familial', 'Spécial Familial'),
('Deals', 'Offres'),
('Hot Dogs', 'Hot Dogs'),
('Cake by Slice', 'Gâteau à la Pointe'),
('Burger COMBOS', 'COMBOS Burger'),
('Our New Creations COMBO', 'Nos Nouvelles Créations COMBO'),
('Burgers SOLO', 'Burgers SOLO'),
('Curries', 'Caris'),
('Poutines', 'Poutines'),
('Fresh Salads', 'Salades Fraîches'),
('Nos Fameuses Pâtes Cuites au Four', 'Nos Fameuses Pâtes Cuites au Four'),
('Sandwiches and Platters', 'Sandwichs et Assiettes'),
('Vermicelli', 'Vermicelles'),
('Everyday Special', 'Spécial Quotidien'),
('Sandwich Platters', 'Assiettes Sandwich'),
('Vegetable Dishes', 'Plats de Légumes'),
('Traditional Pizza', 'Pizza Traditionnelle'),
('Platters and Hot Sandwiches', 'Assiettes et Sandwichs Chauds'),
('Breuvage', 'Breuvage'),
('Italian Food', 'Cuisine Italienne'),
('Futomakis', 'Futomakis'),
('Gluten Free Pizza', 'Pizza Sans Gluten'),
('Souvlaki Platters', 'Assiettes Souvlaki'),
('Entrées', 'Entrées'),
('Munchies', 'Grignotines'),
('Family Dinners', 'Soupers Familiaux'),
('Special Family Dinners', 'Soupers Familiaux Spéciaux'),
('Pizza et Canette', 'Pizza et Canette'),
('Chop Suey / Chow Mein', 'Chop Suey / Chow Mein'),
('Familiale No 1', 'Familiale No 1'),
('Pizza Poutine Combo', 'Combo Pizza Poutine'),
('Build Your Own Pizza', 'Créez Votre Pizza'),
('Special Sportif', 'Spécial Sportif'),
('Hosomaki', 'Hosomaki'),
('Chicken Tenders', 'Filets de Poulet'),
('Gyros Combos', 'Combos Gyros'),
('2  Pizza and 2 free 591ml Drinks', '2 Pizzas et 2 Boissons 591ml Gratuites'),
('Rice Dishes', 'Plats de Riz'),
('Donairs and Shawarma', 'Donairs et Shawarma'),
('Two for One Deals Of The Month', 'Offres Deux Pour Un du Mois'),
('Pour Grignoter', 'Pour Grignoter'),
('Assiette Hamburger', 'Assiette Hamburger'),
('Fried Noodles', 'Nouilles Frites'),
('Les Grignotines', 'Les Grignotines'),
('Familiale No 2', 'Familiale No 2'),
('Canadian Dishes', 'Plats Canadiens'),
('Dips', 'Trempettes'),
('Beer', 'Bière'),
('Hosomakis', 'Hosomakis'),
('Pizza and Free 591ml Beverage', 'Pizza et Boisson 591ml Gratuite'),
('Les Papa Burgers', 'Les Papa Burgers'),
('Familiale No 3', 'Familiale No 3'),
('Midi Express', 'Midi Express');

-- Apply updates for batch 1
UPDATE menuca_v3.courses c
SET name_fr = t.name_fr, updated_at = NOW()
FROM course_trans t
WHERE c.name_en = t.name_en
  AND (c.name_fr IS NULL OR TRIM(c.name_fr) = '');

SELECT 'Batch 1 complete:' AS status, COUNT(*) AS updated
FROM menuca_v3.courses
WHERE updated_at >= NOW() - INTERVAL '1 minute';

-- Clear for next batch
TRUNCATE course_trans;

COMMIT;

