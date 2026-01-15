-- Migration 002: Create dish_size_variants table
-- This table provides expanded size variants for dish_prices with mappings to modifier_size_variants
-- Covers 88.9% of dish_prices with size-based variants

BEGIN;

-- Create the dish_size_variants table
CREATE TABLE IF NOT EXISTS menuca_v3.dish_size_variants (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name_en VARCHAR(50) NOT NULL,
    name_fr VARCHAR(50) NOT NULL,
    category VARCHAR(20) NOT NULL,  -- 'size', 'dimension', 'volume', 'container', 'combo', 'portion', 'protein', 'other'
    modifier_size_variant_id INT,   -- NULL for non-mappable variants (proteins, flavors, etc.)
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (modifier_size_variant_id) REFERENCES menuca_v3.modifier_size_variants(id)
);

-- Add comments for documentation
COMMENT ON TABLE menuca_v3.dish_size_variants IS 'Expanded size variants for dish pricing with mapping to modifier sizes';
COMMENT ON COLUMN menuca_v3.dish_size_variants.code IS 'Unique lowercase identifier for the size variant';
COMMENT ON COLUMN menuca_v3.dish_size_variants.category IS 'Category: size, dimension, volume, container, combo, portion, protein, other';
COMMENT ON COLUMN menuca_v3.dish_size_variants.modifier_size_variant_id IS 'FK to modifier_size_variants for size-price matching. NULL for non-size variants.';

-- Get modifier_size_variant IDs for mapping
DO $$
DECLARE
    v_standard_id INT;
    v_small_id INT;
    v_medium_id INT;
    v_large_id INT;
    v_xlarge_id INT;
BEGIN
    -- Get the IDs from modifier_size_variants
    SELECT id INTO v_standard_id FROM menuca_v3.modifier_size_variants WHERE code = 'standard';
    SELECT id INTO v_small_id FROM menuca_v3.modifier_size_variants WHERE code = 'small';
    SELECT id INTO v_medium_id FROM menuca_v3.modifier_size_variants WHERE code = 'medium';
    SELECT id INTO v_large_id FROM menuca_v3.modifier_size_variants WHERE code = 'large';
    SELECT id INTO v_xlarge_id FROM menuca_v3.modifier_size_variants WHERE code = 'x-large';
    
    -- Seed: Standard sizes (English)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('standard', 'Standard', 'Standard', 'size', v_standard_id, 0),
        ('small', 'Small', 'Petite', 'size', v_small_id, 1),
        ('medium', 'Medium', 'Moyenne', 'size', v_medium_id, 2),
        ('large', 'Large', 'Grande', 'size', v_large_id, 3),
        ('x-large', 'X-Large', 'X-Grande', 'size', v_xlarge_id, 4),
        ('regular', 'Regular', 'Régulier', 'size', v_standard_id, 0)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Standard sizes (French)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('petite', 'Petite', 'Petite', 'size', v_small_id, 1),
        ('petit', 'Petit', 'Petit', 'size', v_small_id, 1),
        ('moyenne', 'Moyenne', 'Moyenne', 'size', v_medium_id, 2),
        ('grande', 'Grande', 'Grande', 'size', v_large_id, 3),
        ('grand', 'Grand', 'Grand', 'size', v_large_id, 3),
        ('x-grande', 'X-Grande', 'X-Grande', 'size', v_xlarge_id, 4),
        ('x-grand', 'X-Grand', 'X-Grand', 'size', v_xlarge_id, 4),
        ('xgrande', 'XGrande', 'XGrande', 'size', v_xlarge_id, 4)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Dimensional sizes (inches)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('6-inch', '6"', '6"', 'dimension', v_small_id, 1),
        ('7-inch', '7"', '7"', 'dimension', v_small_id, 1),
        ('8-inch', '8"', '8"', 'dimension', v_small_id, 1),
        ('9-inch', '9"', '9"', 'dimension', v_small_id, 1),
        ('small-9', 'Small (9")', 'Petite (9")', 'dimension', v_small_id, 1),
        ('12-inch', '12"', '12"', 'dimension', v_medium_id, 2),
        ('medium-12', 'Medium (12")', 'Moyenne (12")', 'dimension', v_medium_id, 2),
        ('13-inch', '13"', '13"', 'dimension', v_medium_id, 2),
        ('medium-13', 'Medium (13")', 'Moyenne (13")', 'dimension', v_medium_id, 2),
        ('14-inch', '14"', '14"', 'dimension', v_large_id, 3),
        ('large-15', 'Large (15")', 'Grande (15")', 'dimension', v_large_id, 3),
        ('16-inch', '16"', '16"', 'dimension', v_large_id, 3),
        ('18-inch', '18"', '18"', 'dimension', v_xlarge_id, 4)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: 2x Combo sizes (English)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('2x-small', '2 x Small', '2 x Petit', 'combo', v_small_id, 1),
        ('2x-medium', '2 x Medium', '2 x Moyenne', 'combo', v_medium_id, 2),
        ('2x-large', '2 x Large', '2 x Grande', 'combo', v_large_id, 3),
        ('2x-x-large', '2 x X-Large', '2 x X-Grande', 'combo', v_xlarge_id, 4)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: 2x Combo sizes (French)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('2x-petit', '2 x Petit', '2 x Petit', 'combo', v_small_id, 1),
        ('2x-petite', '2 x Petite', '2 x Petite', 'combo', v_small_id, 1),
        ('2x-moyenne', '2 x Moyenne', '2 x Moyenne', 'combo', v_medium_id, 2),
        ('2x-grande', '2 x Grande', '2 x Grande', 'combo', v_large_id, 3),
        ('2x-x-grande', '2 x X-Grande', '2 x X-Grande', 'combo', v_xlarge_id, 4),
        ('2x-xgrande', '2 x XGrande', '2 x XGrande', 'combo', v_xlarge_id, 4)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Container sizes
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('can', 'Can', 'Canette', 'container', v_standard_id, 0),
        ('canette', 'Canette', 'Canette', 'container', v_standard_id, 0),
        ('bottle', 'Bottle', 'Bouteille', 'container', v_standard_id, 0),
        ('bouteille', 'Bouteille', 'Bouteille', 'container', v_standard_id, 0)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Volume sizes
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('591ml', '591ml', '591ml', 'volume', v_standard_id, 0),
        ('591-ml', '591 ml', '591 ml', 'volume', v_standard_id, 0),
        ('2l', '2L', '2L', 'volume', v_standard_id, 0),
        ('2-l', '2 L', '2 L', 'volume', v_standard_id, 0)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Portion sizes
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('jumbo', 'Jumbo', 'Jumbo', 'portion', v_xlarge_id, 4),
        ('bambino', 'Bambino', 'Bambino', 'portion', v_small_id, 1),
        ('personal', 'Personal', 'Personnel', 'portion', v_small_id, 1),
        ('familiale', 'Familiale', 'Familiale', 'portion', v_large_id, 3),
        ('family', 'Family', 'Famille', 'portion', v_large_id, 3),
        ('platter', 'Platter', 'Plateau', 'portion', v_large_id, 3),
        ('sandwich', 'Sandwich', 'Sandwich', 'portion', v_standard_id, 0),
        ('wrap', 'Wrap', 'Wrap', 'portion', v_standard_id, 0),
        ('single', 'Single', 'Simple', 'portion', v_standard_id, 0)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Protein types (NO mapping - these are item variants, not sizes)
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('chicken', 'Chicken', 'Poulet', 'protein', NULL, 0),
        ('poulet', 'Poulet', 'Poulet', 'protein', NULL, 0),
        ('beef', 'Beef', 'Boeuf', 'protein', NULL, 0),
        ('boeuf', 'Boeuf', 'Boeuf', 'protein', NULL, 0),
        ('shrimp', 'Shrimp', 'Crevettes', 'protein', NULL, 0),
        ('pork', 'Pork', 'Porc', 'protein', NULL, 0),
        ('lamb', 'Lamb', 'Agneau', 'protein', NULL, 0),
        ('tofu', 'Tofu', 'Tofu', 'protein', NULL, 0),
        ('vegetable', 'Vegetable', 'Légumes', 'protein', NULL, 0),
        ('veggie', 'Veggie', 'Végé', 'protein', NULL, 0),
        ('mixte', 'Mixte', 'Mixte', 'protein', NULL, 0),
        ('squid', 'Squid', 'Calmar', 'protein', NULL, 0),
        ('scallop', 'Scallop', 'Pétoncle', 'protein', NULL, 0)
    ON CONFLICT (code) DO NOTHING;
    
    -- Seed: Weight-based sizes
    INSERT INTO menuca_v3.dish_size_variants (code, name_en, name_fr, category, modifier_size_variant_id, display_order) VALUES
        ('1lb', '1 Lb', '1 lb', 'portion', v_large_id, 3),
        ('half-lb', '1/2 Lb', '1/2 lb', 'portion', v_medium_id, 2)
    ON CONFLICT (code) DO NOTHING;

    RAISE NOTICE 'Successfully seeded dish_size_variants table';
END $$;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_dish_size_variants_modifier_size ON menuca_v3.dish_size_variants(modifier_size_variant_id);
CREATE INDEX IF NOT EXISTS idx_dish_size_variants_category ON menuca_v3.dish_size_variants(category);

-- Verify the seed data
DO $$
DECLARE
    row_count INT;
    mapped_count INT;
    unmapped_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM menuca_v3.dish_size_variants;
    SELECT COUNT(*) INTO mapped_count FROM menuca_v3.dish_size_variants WHERE modifier_size_variant_id IS NOT NULL;
    SELECT COUNT(*) INTO unmapped_count FROM menuca_v3.dish_size_variants WHERE modifier_size_variant_id IS NULL;
    
    RAISE NOTICE 'dish_size_variants: % total rows, % mapped to modifier sizes, % unmapped (proteins/other)', 
        row_count, mapped_count, unmapped_count;
END $$;

COMMIT;







