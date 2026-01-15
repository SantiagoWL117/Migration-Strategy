-- ============================================
-- PHASE 3A: Additional Compound Terms
-- ============================================

-- Combo meal terms
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Combo', 'Combo', 'compound'),
('Meal', 'Repas', 'compound'),
('Combo Meal', 'Repas combo', 'compound'),
('Value Meal', 'Repas valeur', 'compound'),
('Family Combo', 'Combo familial', 'compound'),
('Party Pack', 'Forfait fete', 'compound'),
('Deal', 'Aubaine', 'compound');

-- Pizza descriptors
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Topping', 'Garniture', 'compound'),
('1 Topping', '1 garniture', 'compound'),
('2 Topping', '2 garnitures', 'compound'),
('3 Topping', '3 garnitures', 'compound'),
('2 Toppings', '2 garnitures', 'compound'),
('3 Toppings', '3 garnitures', 'compound'),
('4 Toppings', '4 garnitures', 'compound'),
('5 Toppings', '5 garnitures', 'compound');

-- Sizes in inches
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('10 inch', '10 pouces', 'compound'),
('12 inch', '12 pouces', 'compound'),
('14 inch', '14 pouces', 'compound'),
('16 inch', '16 pouces', 'compound'),
('18 inch', '18 pouces', 'compound');

-- Pieces
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('pcs', 'mcx', 'compound'),
('pieces', 'morceaux', 'compound'),
('piece', 'morceau', 'compound'),
('6 pcs', '6 mcx', 'compound'),
('8 pcs', '8 mcx', 'compound'),
('10 pcs', '10 mcx', 'compound'),
('12 pcs', '12 mcx', 'compound'),
('15 pcs', '15 mcx', 'compound'),
('20 pcs', '20 mcx', 'compound'),
('24 pcs', '24 mcx', 'compound'),
('30 pcs', '30 mcx', 'compound'),
('50 pcs', '50 mcx', 'compound');

-- Common modifiers
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Add Cheese', 'Ajouter fromage', 'compound'),
('Add Bacon', 'Ajouter bacon', 'compound'),
('Add Chicken', 'Ajouter poulet', 'compound'),
('Add Meat', 'Ajouter viande', 'compound'),
('No Onions', 'Sans oignons', 'compound'),
('No Tomato', 'Sans tomate', 'compound'),
('No Lettuce', 'Sans laitue', 'compound'),
('No Pickles', 'Sans cornichons', 'compound'),
('No Mayo', 'Sans mayo', 'compound'),
('Extra Meat', 'Viande supplementaire', 'compound'),
('Extra Bacon', 'Bacon supplementaire', 'compound'),
('Extra Chicken', 'Poulet supplementaire', 'compound'),
('Double Meat', 'Double viande', 'compound');

-- Cooking styles
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Deep Fried', 'Frit', 'compound'),
('Pan Fried', 'Poele', 'compound'),
('Oven Baked', 'Cuit au four', 'compound'),
('Charbroiled', 'Grille au charbon', 'compound'),
('Char Grilled', 'Grille au charbon', 'compound');

-- Common descriptors
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Homestyle', 'Maison', 'compound'),
('Home Made', 'Fait maison', 'compound'),
('Homemade', 'Fait maison', 'compound'),
('Fresh Made', 'Frais du jour', 'compound'),
('Hand Made', 'Fait a la main', 'compound'),
('Gourmet', 'Gourmet', 'compound');

-- Modifier group names
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Choose Your Toppings', 'Choisissez vos garnitures', 'compound'),
('Select Toppings', 'Selectionnez les garnitures', 'compound'),
('Select Your Size', 'Selectionnez votre taille', 'compound'),
('Choose Size', 'Choisissez la taille', 'compound'),
('Choose a Drink', 'Choisissez une boisson', 'compound'),
('Select Drink', 'Selectionnez une boisson', 'compound'),
('Choose Sauce', 'Choisissez une sauce', 'compound'),
('Select Sauce', 'Selectionnez une sauce', 'compound'),
('Add Ons', 'Supplements', 'compound'),
('Add-Ons', 'Supplements', 'compound'),
('Extras', 'Supplements', 'compound'),
('Dipping Sauces', 'Sauces pour tremper', 'compound'),
('Dipping Sauce', 'Sauce pour tremper', 'compound'),
('Choose Crust', 'Choisissez la croute', 'compound'),
('Select Crust', 'Selectionnez la croute', 'compound'),
('Pizza Toppings', 'Garnitures de pizza', 'compound'),
('Salad Dressing', 'Vinaigrette', 'compound'),
('Choose Dressing', 'Choisissez la vinaigrette', 'compound');

-- More common items
INSERT INTO menuca_v3.translation_lookup (term_en, term_fr, category) VALUES
('Combination', 'Combinaison', 'compound'),
('Assorted', 'Assorti', 'compound'),
('Mixed', 'Mixte', 'compound'),
('The Italian Job', 'L Italien', 'compound'),
('The Windsor Pizza', 'La Pizza Windsor', 'compound'),
('Fried Rice', 'Riz frit', 'compound'),
('Steamed Rice', 'Riz vapeur', 'compound'),
('White Rice', 'Riz blanc', 'compound'),
('Brown Rice', 'Riz brun', 'compound'),
('Egg Fried Rice', 'Riz frit aux oeufs', 'compound'),
('Vegetable Fried Rice', 'Riz frit aux legumes', 'compound'),
('Chicken Fried Rice', 'Riz frit au poulet', 'compound'),
('Beef Fried Rice', 'Riz frit au boeuf', 'compound'),
('Noodles', 'Nouilles', 'compound'),
('Chow Mein', 'Chow Mein', 'compound'),
('Lo Mein', 'Lo Mein', 'compound'),
('Pad Thai', 'Pad Thai', 'compound'),
('Spring Roll', 'Rouleau de printemps', 'compound'),
('Egg Roll', 'Rouleau imperial', 'compound'),
('Wonton Soup', 'Soupe wonton', 'compound'),
('Hot and Sour Soup', 'Soupe aigre-piquante', 'compound'),
('Egg Drop Soup', 'Soupe aux oeufs', 'compound'),
('Sweet and Sour', 'Aigre-doux', 'compound'),
('General Tao', 'General Tao', 'compound'),
('Kung Pao', 'Kung Pao', 'compound'),
('Szechuan', 'Sichuan', 'compound'),
('Orange Chicken', 'Poulet a l orange', 'compound'),
('Lemon Chicken', 'Poulet au citron', 'compound'),
('Sesame Chicken', 'Poulet au sesame', 'compound'),
('Cashew Chicken', 'Poulet aux noix de cajou', 'compound'),
('Almond Chicken', 'Poulet aux amandes', 'compound'),
('Butter Chicken', 'Poulet au beurre', 'compound'),
('Tandoori Chicken', 'Poulet tandoori', 'compound'),
('Chicken Tikka', 'Poulet tikka', 'compound'),
('Chicken Korma', 'Poulet korma', 'compound'),
('Chicken Vindaloo', 'Poulet vindaloo', 'compound'),
('Lamb Curry', 'Cari d agneau', 'compound'),
('Beef Curry', 'Cari de boeuf', 'compound'),
('Vegetable Curry', 'Cari de legumes', 'compound'),
('Chicken Curry', 'Cari de poulet', 'compound'),
('Shrimp Curry', 'Cari de crevettes', 'compound');

SELECT 'Phase 3A compound terms loaded' as status;



