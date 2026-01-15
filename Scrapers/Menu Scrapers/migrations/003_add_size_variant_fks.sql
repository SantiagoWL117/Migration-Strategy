-- Migration 003: Add size_variant_id foreign key columns to price tables
-- These columns enable size-price matching via integer FKs instead of string comparison

BEGIN;

-- Add modifier_size_variant_id to modifier_prices
ALTER TABLE menuca_v3.modifier_prices 
    ADD COLUMN IF NOT EXISTS modifier_size_variant_id INT 
    REFERENCES menuca_v3.modifier_size_variants(id);

COMMENT ON COLUMN menuca_v3.modifier_prices.modifier_size_variant_id IS 'FK to modifier_size_variants for normalized size-price matching';

-- Add modifier_size_variant_id to combo_modifier_prices
ALTER TABLE menuca_v3.combo_modifier_prices 
    ADD COLUMN IF NOT EXISTS modifier_size_variant_id INT 
    REFERENCES menuca_v3.modifier_size_variants(id);

COMMENT ON COLUMN menuca_v3.combo_modifier_prices.modifier_size_variant_id IS 'FK to modifier_size_variants for normalized size-price matching';

-- Add dish_size_variant_id to dish_prices
ALTER TABLE menuca_v3.dish_prices 
    ADD COLUMN IF NOT EXISTS dish_size_variant_id INT 
    REFERENCES menuca_v3.dish_size_variants(id);

COMMENT ON COLUMN menuca_v3.dish_prices.dish_size_variant_id IS 'FK to dish_size_variants for normalized size-price matching';

-- Create indexes for the new FK columns
CREATE INDEX IF NOT EXISTS idx_modifier_prices_size_variant ON menuca_v3.modifier_prices(modifier_size_variant_id);
CREATE INDEX IF NOT EXISTS idx_combo_modifier_prices_size_variant ON menuca_v3.combo_modifier_prices(modifier_size_variant_id);
CREATE INDEX IF NOT EXISTS idx_dish_prices_size_variant ON menuca_v3.dish_prices(dish_size_variant_id);

-- Verify columns were added
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'menuca_v3' AND table_name = 'modifier_prices' AND column_name = 'modifier_size_variant_id'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'menuca_v3' AND table_name = 'combo_modifier_prices' AND column_name = 'modifier_size_variant_id'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'menuca_v3' AND table_name = 'dish_prices' AND column_name = 'dish_size_variant_id'
    ) THEN
        RAISE NOTICE 'Successfully added size_variant_id columns to all price tables';
    ELSE
        RAISE EXCEPTION 'Failed to add one or more size_variant_id columns';
    END IF;
END $$;

COMMIT;







