-- ============================================================================
-- Menu & Catalog Entity - Phase 3: Schema Normalization
-- ============================================================================
-- Purpose: Consolidate V1/V2 legacy pricing into normalized structure
-- Author: Brian + AI Assistant
-- Date: 2025-01-16
-- Execution Method: Supabase MCP
-- Estimated Time: 5-10 minutes
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE NORMALIZED PRICING TABLE
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 1/6] Creating dish_modifier_prices table...';
END $$;

-- Drop if exists (for idempotency)
DROP TABLE IF EXISTS menuca_v3.dish_modifier_prices CASCADE;

-- Create normalized pricing table
CREATE TABLE menuca_v3.dish_modifier_prices (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    
    -- Foreign keys
    dish_modifier_id BIGINT NOT NULL REFERENCES menuca_v3.dish_modifiers(id) ON DELETE CASCADE,
    dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
    ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
    
    -- Pricing details
    size_variant VARCHAR(10), -- NULL for flat rate, 'S'/'M'/'L' for size-specific
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    display_order INTEGER DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Multi-tenancy
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL,
    
    -- Legacy tracking
    source_system VARCHAR(20), -- 'v1', 'v2', 'v3'
    migrated_from VARCHAR(50), -- 'base_price' or 'price_by_size'
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_price_non_negative CHECK (price >= 0),
    CONSTRAINT unique_modifier_price UNIQUE (dish_modifier_id, size_variant)
);

-- Add comments
COMMENT ON TABLE menuca_v3.dish_modifier_prices IS 'Normalized pricing table for dish modifiers. Supports both flat-rate and size-based pricing.';
COMMENT ON COLUMN menuca_v3.dish_modifier_prices.size_variant IS 'NULL = flat rate, otherwise size code (S, M, L, XL, etc.)';
COMMENT ON COLUMN menuca_v3.dish_modifier_prices.price IS 'Price for this modifier (0.00 = free/included)';
COMMENT ON COLUMN menuca_v3.dish_modifier_prices.migrated_from IS 'Tracks which legacy column this data came from (base_price or price_by_size)';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 1/6] ✅ Table created successfully';
END $$;

-- ============================================================================
-- STEP 2: CREATE INDEXES
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 2/6] Creating indexes...';
END $$;

CREATE INDEX idx_dish_modifier_prices_modifier 
    ON menuca_v3.dish_modifier_prices(dish_modifier_id) WHERE is_active = true;

CREATE INDEX idx_dish_modifier_prices_dish 
    ON menuca_v3.dish_modifier_prices(dish_id) WHERE is_active = true;

CREATE INDEX idx_dish_modifier_prices_tenant 
    ON menuca_v3.dish_modifier_prices(tenant_id);

CREATE INDEX idx_dish_modifier_prices_restaurant_active 
    ON menuca_v3.dish_modifier_prices(restaurant_id, is_active) WHERE is_active = true;

DO $$ 
BEGIN
    RAISE NOTICE '[Step 2/6] ✅ Indexes created (4 indexes)';
END $$;

-- ============================================================================
-- STEP 3: ENABLE RLS AND CREATE POLICIES
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 3/6] Enabling RLS and creating policies...';
END $$;

-- Enable RLS
ALTER TABLE menuca_v3.dish_modifier_prices ENABLE ROW LEVEL SECURITY;

-- Policy 1: Public can view active prices
CREATE POLICY "public_view_active_modifier_prices" ON menuca_v3.dish_modifier_prices
    FOR SELECT
    USING (is_active = true);

-- Policy 2: Restaurant admins manage their prices
CREATE POLICY "tenant_manage_modifier_prices" ON menuca_v3.dish_modifier_prices
    FOR ALL
    USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::BIGINT)
    WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::BIGINT);

-- Policy 3: Super admins access all prices
CREATE POLICY "admin_access_modifier_prices" ON menuca_v3.dish_modifier_prices
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');

DO $$ 
BEGIN
    RAISE NOTICE '[Step 3/6] ✅ RLS enabled with 3 policies';
END $$;

-- ============================================================================
-- STEP 4: MIGRATE FLAT-RATE PRICING (base_price)
-- ============================================================================

DO $$ 
DECLARE
    v_migrated_count INTEGER;
BEGIN
    RAISE NOTICE '[Step 4/6] Migrating flat-rate pricing from base_price column...';
    
    INSERT INTO menuca_v3.dish_modifier_prices (
        dish_modifier_id,
        dish_id,
        ingredient_id,
        size_variant, -- NULL for flat rate
        price,
        display_order,
        is_active,
        restaurant_id,
        tenant_id,
        source_system,
        migrated_from,
        created_at,
        updated_at
    )
    SELECT 
        dm.id as dish_modifier_id,
        dm.dish_id,
        dm.ingredient_id,
        NULL as size_variant, -- Flat rate
        dm.base_price as price,
        COALESCE(dm.display_order, 1) as display_order,
        true as is_active,
        dm.restaurant_id,
        dm.tenant_id,
        COALESCE(dm.source_system, 'v3') as source_system,
        'base_price' as migrated_from,
        dm.created_at,
        dm.updated_at
    FROM menuca_v3.dish_modifiers dm
    WHERE dm.base_price IS NOT NULL 
        AND dm.base_price > 0
        AND (dm.price_by_size IS NULL OR dm.price_by_size = 'null'::jsonb);
    
    GET DIAGNOSTICS v_migrated_count = ROW_COUNT;
    RAISE NOTICE '[Step 4/6] ✅ Migrated % flat-rate price records', v_migrated_count;
END $$;

-- ============================================================================
-- STEP 5: MIGRATE SIZE-BASED PRICING (price_by_size JSONB)
-- ============================================================================

DO $$ 
DECLARE
    v_migrated_count INTEGER;
BEGIN
    RAISE NOTICE '[Step 5/6] Migrating size-based pricing from price_by_size column...';
    
    INSERT INTO menuca_v3.dish_modifier_prices (
        dish_modifier_id,
        dish_id,
        ingredient_id,
        size_variant,
        price,
        display_order,
        is_active,
        restaurant_id,
        tenant_id,
        source_system,
        migrated_from,
        created_at,
        updated_at
    )
    SELECT 
        dm.id as dish_modifier_id,
        dm.dish_id,
        dm.ingredient_id,
        size_entry.key as size_variant, -- S, M, L, etc.
        (size_entry.value::text)::numeric as price,
        COALESCE(dm.display_order, 1) as display_order,
        true as is_active,
        dm.restaurant_id,
        dm.tenant_id,
        COALESCE(dm.source_system, 'v3') as source_system,
        'price_by_size' as migrated_from,
        dm.created_at,
        dm.updated_at
    FROM menuca_v3.dish_modifiers dm
    CROSS JOIN LATERAL jsonb_each(dm.price_by_size) as size_entry
    WHERE dm.price_by_size IS NOT NULL 
        AND dm.price_by_size != 'null'::jsonb
        AND jsonb_typeof(dm.price_by_size) = 'object';
    
    GET DIAGNOSTICS v_migrated_count = ROW_COUNT;
    RAISE NOTICE '[Step 5/6] ✅ Migrated % size-based price records', v_migrated_count;
END $$;

-- ============================================================================
-- STEP 6: UPDATE API FUNCTION
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 6/6] Updating get_restaurant_menu() function...';
END $$;

CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(p_restaurant_id BIGINT)
RETURNS TABLE (
    course_id BIGINT,
    course_name VARCHAR,
    course_display_order INTEGER,
    dish_id BIGINT,
    dish_name VARCHAR,
    dish_description TEXT,
    dish_display_order INTEGER,
    pricing JSONB,
    modifiers JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    -- Validate restaurant is active
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurants 
        WHERE id = p_restaurant_id 
            AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Restaurant not found or inactive';
    END IF;

    -- Return menu with normalized pricing
    RETURN QUERY
    SELECT 
        c.id::BIGINT AS course_id,
        c.name AS course_name,
        c.display_order AS course_display_order,
        d.id::BIGINT AS dish_id,
        d.name AS dish_name,
        d.description AS dish_description,
        d.display_order AS dish_display_order,
        dp.pricing,
        dm.modifiers
    FROM menuca_v3.dishes d
    LEFT JOIN menuca_v3.courses c ON d.course_id = c.id
    -- Get dish pricing (already normalized)
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'size', dp2.size_variant,
                'price', dp2.price,
                'display_order', dp2.display_order
            ) ORDER BY dp2.display_order
        ) AS pricing
        FROM menuca_v3.dish_prices dp2
        WHERE dp2.dish_id = d.id AND dp2.is_active = true
    ) dp ON true
    -- Get dish modifiers with normalized pricing
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'ingredient_id', i.id,
                'name', i.name,
                'pricing', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'size', dmp.size_variant,
                            'price', dmp.price
                        ) ORDER BY 
                            CASE dmp.size_variant
                                WHEN 'S' THEN 1
                                WHEN 'M' THEN 2
                                WHEN 'L' THEN 3
                                WHEN 'XL' THEN 4
                                ELSE 5
                            END
                    )
                    FROM menuca_v3.dish_modifier_prices dmp
                    WHERE dmp.dish_modifier_id = dm2.id
                        AND dmp.is_active = true
                )
            )
        ) AS modifiers
        FROM menuca_v3.dish_modifiers dm2
        JOIN menuca_v3.ingredients i ON dm2.ingredient_id = i.id
        WHERE dm2.dish_id = d.id
    ) dm ON true
    WHERE d.restaurant_id = p_restaurant_id
      AND d.is_active = true
    ORDER BY c.display_order NULLS LAST, d.display_order;
END;
$$;

-- Update function comment
COMMENT ON FUNCTION menuca_v3.get_restaurant_menu IS 
    'Returns complete menu for a restaurant with normalized pricing and modifiers. Uses dish_modifier_prices table for proper pricing structure. Only returns active dishes and validates restaurant is active.';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 6/6] ✅ Function updated successfully';
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=============================================================';
    RAISE NOTICE 'MIGRATION VERIFICATION';
    RAISE NOTICE '=============================================================';
END $$;

-- Check migration counts
SELECT 
    migrated_from,
    COUNT(*) as row_count,
    COUNT(DISTINCT dish_modifier_id) as unique_modifiers
FROM menuca_v3.dish_modifier_prices
GROUP BY migrated_from
ORDER BY row_count DESC;

-- Verify RLS is enabled
SELECT 
    tablename,
    CASE WHEN rowsecurity THEN '✅ Enabled' ELSE '❌ Disabled' END as rls_status
FROM pg_tables
WHERE schemaname = 'menuca_v3' 
    AND tablename = 'dish_modifier_prices';

-- Verify indexes
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
    AND tablename = 'dish_modifier_prices'
ORDER BY indexname;

-- Test function (replace 72 with valid restaurant_id)
-- SELECT * FROM menuca_v3.get_restaurant_menu(72) LIMIT 5;

DO $$ 
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '✅ Phase 3 Migration Complete!';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '1. Test get_restaurant_menu() function';
    RAISE NOTICE '2. Verify pricing data in application';
    RAISE NOTICE '3. Monitor performance for 48 hours';
    RAISE NOTICE '4. Drop legacy columns if satisfied:';
    RAISE NOTICE '   ALTER TABLE menuca_v3.dish_modifiers DROP COLUMN base_price, DROP COLUMN price_by_size;';
END $$;

-- ============================================================================
-- OPTIONAL: DROP LEGACY COLUMNS (DESTRUCTIVE - USE WITH CAUTION)
-- ============================================================================

-- Uncomment to drop legacy columns after verification
-- WARNING: This is a destructive operation and cannot be easily undone

/*
DO $$ 
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Dropping legacy pricing columns...';
END $$;

ALTER TABLE menuca_v3.dish_modifiers 
    DROP COLUMN IF EXISTS base_price,
    DROP COLUMN IF EXISTS price_by_size;

COMMENT ON TABLE menuca_v3.dish_modifiers IS 
    'Junction table for dish-ingredient relationships. Pricing moved to dish_modifier_prices table (normalized). Legacy columns base_price and price_by_size removed on 2025-01-16.';

DO $$ 
BEGIN
    RAISE NOTICE '✅ Legacy columns dropped successfully';
END $$;
*/

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

