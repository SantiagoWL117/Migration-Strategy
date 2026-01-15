-- Migration 001: Create modifier_size_variants table
-- This table provides a global, standardized set of size variants for modifier_prices and combo_modifier_prices
-- Covers 99.5% of modifier_prices and 100% of combo_modifier_prices

BEGIN;

-- Create the modifier_size_variants table
CREATE TABLE IF NOT EXISTS menuca_v3.modifier_size_variants (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_en VARCHAR(50) NOT NULL,
    name_fr VARCHAR(50) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment for documentation
COMMENT ON TABLE menuca_v3.modifier_size_variants IS 'Global standardized size variants for modifier pricing. Used by modifier_prices and combo_modifier_prices tables.';
COMMENT ON COLUMN menuca_v3.modifier_size_variants.code IS 'Unique lowercase identifier for the size variant';
COMMENT ON COLUMN menuca_v3.modifier_size_variants.name_en IS 'English display name';
COMMENT ON COLUMN menuca_v3.modifier_size_variants.name_fr IS 'French display name';
COMMENT ON COLUMN menuca_v3.modifier_size_variants.display_order IS 'Order for display (0=standard, 1=small, 2=medium, 3=large, 4=x-large)';

-- Seed the standard size variants
INSERT INTO menuca_v3.modifier_size_variants (code, name_en, name_fr, display_order) VALUES
    ('standard', 'Standard', 'Standard', 0),
    ('small', 'Small', 'Petite', 1),
    ('medium', 'Medium', 'Moyenne', 2),
    ('large', 'Large', 'Grande', 3),
    ('x-large', 'X-Large', 'X-Grande', 4),
    ('size-5', 'Size 5', 'Taille 5', 5),
    ('size-6', 'Size 6', 'Taille 6', 6),
    ('size-7', 'Size 7', 'Taille 7', 7)
ON CONFLICT (code) DO NOTHING;

-- Verify the seed data
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM menuca_v3.modifier_size_variants;
    IF row_count != 8 THEN
        RAISE EXCEPTION 'Expected 8 rows in modifier_size_variants, found %', row_count;
    END IF;
    RAISE NOTICE 'Successfully created modifier_size_variants with % rows', row_count;
END $$;

COMMIT;







