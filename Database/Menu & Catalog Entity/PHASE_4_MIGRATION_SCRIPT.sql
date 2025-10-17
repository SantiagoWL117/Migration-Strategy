-- ============================================================================
-- Menu & Catalog Entity - Phase 4: Real-time & Inventory
-- ============================================================================
-- Purpose: Add real-time inventory tracking and availability management
-- Author: Brian + AI Assistant
-- Date: 2025-01-16
-- Execution Method: Supabase MCP
-- Estimated Time: 5-10 minutes
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE DISH_INVENTORY TABLE
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 1/7] Creating dish_inventory table...';
END $$;

CREATE TABLE IF NOT EXISTS menuca_v3.dish_inventory (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    
    -- Foreign keys
    dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    
    -- Date tracking
    inventory_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Inventory tracking
    available_quantity INTEGER,  -- NULL = unlimited, 0 = out of stock
    is_available BOOLEAN NOT NULL DEFAULT true,
    availability_reason VARCHAR(255),
    
    -- Time-based availability
    available_from TIME,
    available_until TIME,
    
    -- Multi-tenancy
    tenant_id UUID NOT NULL,
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by BIGINT,
    
    -- Constraints
    CONSTRAINT uq_dish_inventory_daily UNIQUE (dish_id, inventory_date),
    CONSTRAINT check_quantity_non_negative CHECK (available_quantity IS NULL OR available_quantity >= 0)
);

-- Comments
COMMENT ON TABLE menuca_v3.dish_inventory IS 'Real-time inventory tracking for dishes. Tracks daily availability, quantities, and time-based restrictions.';
COMMENT ON COLUMN menuca_v3.dish_inventory.available_quantity IS 'NULL = unlimited inventory, 0 = out of stock, N = specific quantity available';
COMMENT ON COLUMN menuca_v3.dish_inventory.is_available IS 'Overall availability flag. False = dish cannot be ordered regardless of quantity.';
COMMENT ON COLUMN menuca_v3.dish_inventory.availability_reason IS 'Reason for unavailability: out_of_stock, seasonal, discontinued, prep_time, etc.';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 1/7] ✅ Table created successfully';
END $$;

-- ============================================================================
-- STEP 2: CREATE INDEXES
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 2/7] Creating indexes...';
END $$;

-- Primary lookup indexes
CREATE INDEX IF NOT EXISTS idx_dish_inventory_dish 
    ON menuca_v3.dish_inventory(dish_id);

CREATE INDEX IF NOT EXISTS idx_dish_inventory_restaurant_date 
    ON menuca_v3.dish_inventory(restaurant_id, inventory_date);

-- Partial index for unavailable items
CREATE INDEX IF NOT EXISTS idx_dish_inventory_unavailable 
    ON menuca_v3.dish_inventory(dish_id, is_available) 
    WHERE is_available = false;

-- Tenant isolation
CREATE INDEX IF NOT EXISTS idx_dish_inventory_tenant 
    ON menuca_v3.dish_inventory(tenant_id);

-- Date-based lookups
CREATE INDEX IF NOT EXISTS idx_dish_inventory_date 
    ON menuca_v3.dish_inventory(inventory_date DESC);

DO $$ 
BEGIN
    RAISE NOTICE '[Step 2/7] ✅ Indexes created (5 indexes)';
END $$;

-- ============================================================================
-- STEP 3: ENABLE RLS AND CREATE POLICIES
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 3/7] Enabling RLS and creating policies...';
END $$;

-- Enable RLS
ALTER TABLE menuca_v3.dish_inventory ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "public_read_available_inventory" ON menuca_v3.dish_inventory;
DROP POLICY IF EXISTS "tenant_manage_inventory" ON menuca_v3.dish_inventory;
DROP POLICY IF EXISTS "admin_access_inventory" ON menuca_v3.dish_inventory;

-- Policy 1: Public can read available inventory
CREATE POLICY "public_read_available_inventory" ON menuca_v3.dish_inventory
    FOR SELECT
    USING (is_available = true);

-- Policy 2: Restaurant admins manage their inventory
CREATE POLICY "tenant_manage_inventory" ON menuca_v3.dish_inventory
    FOR ALL
    USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::BIGINT)
    WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::BIGINT);

-- Policy 3: Super admins access all inventory
CREATE POLICY "admin_access_inventory" ON menuca_v3.dish_inventory
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');

DO $$ 
BEGIN
    RAISE NOTICE '[Step 3/7] ✅ RLS enabled with 3 policies';
END $$;

-- ============================================================================
-- STEP 4: CREATE INVENTORY MANAGEMENT FUNCTIONS
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 4/7] Creating inventory management functions...';
END $$;

-- Function 1: Update dish availability
CREATE OR REPLACE FUNCTION menuca_v3.update_dish_availability(
    p_dish_id BIGINT,
    p_is_available BOOLEAN,
    p_reason VARCHAR DEFAULT NULL,
    p_quantity INTEGER DEFAULT NULL,
    p_available_from TIME DEFAULT NULL,
    p_available_until TIME DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_tenant_id UUID;
    v_result JSONB;
BEGIN
    -- Get restaurant_id and tenant_id
    SELECT restaurant_id, tenant_id 
    INTO v_restaurant_id, v_tenant_id
    FROM menuca_v3.dishes
    WHERE id = p_dish_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Dish ID % not found', p_dish_id;
    END IF;
    
    -- Upsert inventory
    INSERT INTO menuca_v3.dish_inventory (
        dish_id, restaurant_id, tenant_id, inventory_date,
        is_available, availability_reason, available_quantity,
        available_from, available_until, last_updated_at
    )
    VALUES (
        p_dish_id, v_restaurant_id, v_tenant_id, CURRENT_DATE,
        p_is_available, p_reason, p_quantity,
        p_available_from, p_available_until, NOW()
    )
    ON CONFLICT (dish_id, inventory_date)
    DO UPDATE SET
        is_available = EXCLUDED.is_available,
        availability_reason = EXCLUDED.availability_reason,
        available_quantity = EXCLUDED.available_quantity,
        available_from = EXCLUDED.available_from,
        available_until = EXCLUDED.available_until,
        last_updated_at = NOW();
    
    -- Build result
    v_result = jsonb_build_object(
        'success', true,
        'dish_id', p_dish_id,
        'restaurant_id', v_restaurant_id,
        'is_available', p_is_available,
        'reason', p_reason,
        'quantity', p_quantity,
        'timestamp', NOW()
    );
    
    -- Send notification
    PERFORM pg_notify('dish_availability_changed', v_result::text);
    
    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.update_dish_availability TO authenticated, anon;

COMMENT ON FUNCTION menuca_v3.update_dish_availability IS 
    'Update dish availability in real-time. Used by restaurant admins to mark dishes as available/unavailable, set quantities, and define time windows.';

-- Function 2: Decrement dish inventory
CREATE OR REPLACE FUNCTION menuca_v3.decrement_dish_inventory(
    p_dish_id BIGINT,
    p_quantity INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_tenant_id UUID;
    v_current_quantity INTEGER;
    v_new_quantity INTEGER;
    v_result JSONB;
BEGIN
    -- Get current quantity
    SELECT 
        d.restaurant_id,
        d.tenant_id,
        di.available_quantity
    INTO v_restaurant_id, v_tenant_id, v_current_quantity
    FROM menuca_v3.dishes d
    LEFT JOIN menuca_v3.dish_inventory di 
        ON d.id = di.dish_id 
        AND di.inventory_date = CURRENT_DATE
    WHERE d.id = p_dish_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Dish ID % not found', p_dish_id;
    END IF;
    
    -- If no inventory tracking, return unlimited
    IF v_current_quantity IS NULL THEN
        RETURN jsonb_build_object(
            'success', true,
            'dish_id', p_dish_id,
            'unlimited', true,
            'message', 'No inventory tracking - unlimited availability'
        );
    END IF;
    
    -- Calculate new quantity
    v_new_quantity = GREATEST(0, v_current_quantity - p_quantity);
    
    -- If quantity reaches 0, mark as out of stock
    IF v_new_quantity = 0 THEN
        UPDATE menuca_v3.dish_inventory
        SET 
            available_quantity = 0,
            is_available = false,
            availability_reason = 'out_of_stock',
            last_updated_at = NOW()
        WHERE dish_id = p_dish_id
            AND inventory_date = CURRENT_DATE;
        
        -- Notify out of stock
        PERFORM pg_notify('dish_out_of_stock', jsonb_build_object(
            'dish_id', p_dish_id,
            'restaurant_id', v_restaurant_id,
            'timestamp', NOW()
        )::text);
        
        v_result = jsonb_build_object(
            'success', true,
            'dish_id', p_dish_id,
            'restaurant_id', v_restaurant_id,
            'previous_quantity', v_current_quantity,
            'new_quantity', 0,
            'out_of_stock', true,
            'message', 'Dish marked as out of stock'
        );
    ELSE
        -- Decrement quantity
        UPDATE menuca_v3.dish_inventory
        SET 
            available_quantity = v_new_quantity,
            last_updated_at = NOW()
        WHERE dish_id = p_dish_id
            AND inventory_date = CURRENT_DATE;
        
        v_result = jsonb_build_object(
            'success', true,
            'dish_id', p_dish_id,
            'restaurant_id', v_restaurant_id,
            'previous_quantity', v_current_quantity,
            'new_quantity', v_new_quantity,
            'out_of_stock', false
        );
    END IF;
    
    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.decrement_dish_inventory TO authenticated;

COMMENT ON FUNCTION menuca_v3.decrement_dish_inventory IS 
    'Decrement dish inventory when an order is placed. Automatically marks dish as out of stock when quantity reaches 0.';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 4/7] ✅ Inventory functions created (2 functions)';
END $$;

-- ============================================================================
-- STEP 5: CREATE TIME-BASED AVAILABILITY FUNCTION
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 5/7] Creating time-based availability function...';
END $$;

CREATE OR REPLACE FUNCTION menuca_v3.is_dish_available_now(
    p_dish_id BIGINT,
    p_check_time TIMESTAMPTZ DEFAULT NOW()
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_is_active BOOLEAN;
    v_inventory_available BOOLEAN;
    v_available_from TIME;
    v_available_until TIME;
    v_current_time TIME;
BEGIN
    -- Get dish availability
    SELECT 
        d.is_active,
        COALESCE(di.is_available, true),
        di.available_from,
        di.available_until
    INTO v_is_active, v_inventory_available, v_available_from, v_available_until
    FROM menuca_v3.dishes d
    LEFT JOIN menuca_v3.dish_inventory di 
        ON d.id = di.dish_id 
        AND di.inventory_date = p_check_time::DATE
    WHERE d.id = p_dish_id;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Check base availability
    IF NOT v_is_active OR NOT v_inventory_available THEN
        RETURN false;
    END IF;
    
    -- Check time-based availability
    IF v_available_from IS NOT NULL AND v_available_until IS NOT NULL THEN
        v_current_time = p_check_time::TIME;
        
        -- Handle time ranges that cross midnight
        IF v_available_from <= v_available_until THEN
            IF v_current_time NOT BETWEEN v_available_from AND v_available_until THEN
                RETURN false;
            END IF;
        ELSE
            IF v_current_time < v_available_from AND v_current_time > v_available_until THEN
                RETURN false;
            END IF;
        END IF;
    END IF;
    
    RETURN true;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.is_dish_available_now TO authenticated, anon;

COMMENT ON FUNCTION menuca_v3.is_dish_available_now IS 
    'Check if a dish is available at a specific time. Considers active flag, inventory status, and time restrictions.';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 5/7] ✅ Time-based availability function created';
END $$;

-- ============================================================================
-- STEP 6: ENABLE SUPABASE REALTIME AND CREATE TRIGGERS
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 6/7] Enabling Realtime and creating triggers...';
END $$;

-- Enable Realtime on tables
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.dishes;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.courses;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.dish_inventory;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.dish_prices;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.ingredients;

-- Create notification trigger function
CREATE OR REPLACE FUNCTION menuca_v3.notify_menu_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_payload JSONB;
BEGIN
    v_payload = jsonb_build_object(
        'table', TG_TABLE_NAME,
        'action', TG_OP,
        'restaurant_id', COALESCE(NEW.restaurant_id, OLD.restaurant_id),
        'record_id', COALESCE(NEW.id, OLD.id),
        'timestamp', NOW()
    );
    
    PERFORM pg_notify('menu_changed', v_payload::text);
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

-- Drop existing triggers
DROP TRIGGER IF EXISTS notify_dishes_change ON menuca_v3.dishes;
DROP TRIGGER IF EXISTS notify_courses_change ON menuca_v3.courses;
DROP TRIGGER IF EXISTS notify_inventory_change ON menuca_v3.dish_inventory;
DROP TRIGGER IF EXISTS notify_prices_change ON menuca_v3.dish_prices;

-- Apply triggers
CREATE TRIGGER notify_dishes_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dishes
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_menu_change();

CREATE TRIGGER notify_courses_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.courses
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_menu_change();

CREATE TRIGGER notify_inventory_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_inventory
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_menu_change();

CREATE TRIGGER notify_prices_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_prices
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_menu_change();

DO $$ 
BEGIN
    RAISE NOTICE '[Step 6/7] ✅ Realtime enabled and triggers created';
END $$;

-- ============================================================================
-- STEP 7: UPDATE get_restaurant_menu() FUNCTION
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '[Step 7/7] Updating get_restaurant_menu() function...';
END $$;

-- Drop and recreate with new signature
DROP FUNCTION IF EXISTS menuca_v3.get_restaurant_menu(BIGINT);

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
    modifiers JSONB,
    availability JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM menuca_v3.restaurants 
        WHERE id = p_restaurant_id AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Restaurant not found or inactive';
    END IF;

    RETURN QUERY
    SELECT 
        c.id::BIGINT,
        c.name,
        c.display_order,
        d.id::BIGINT,
        d.name,
        d.description,
        d.display_order,
        dp.pricing,
        dm.modifiers,
        jsonb_build_object(
            'is_available', menuca_v3.is_dish_available_now(d.id),
            'is_active', d.is_active,
            'inventory', (
                SELECT jsonb_build_object(
                    'quantity', di2.available_quantity,
                    'is_available', di2.is_available,
                    'reason', di2.availability_reason,
                    'available_from', di2.available_from,
                    'available_until', di2.available_until,
                    'last_updated', di2.last_updated_at
                )
                FROM menuca_v3.dish_inventory di2
                WHERE di2.dish_id = d.id AND di2.inventory_date = CURRENT_DATE
            )
        )
    FROM menuca_v3.dishes d
    LEFT JOIN menuca_v3.courses c ON d.course_id = c.id
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
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'ingredient_id', i.id,
                'name', i.name,
                'pricing', (
                    SELECT jsonb_agg(
                        jsonb_build_object('size', dmp.size_variant, 'price', dmp.price)
                        ORDER BY CASE dmp.size_variant WHEN 'S' THEN 1 WHEN 'M' THEN 2 WHEN 'L' THEN 3 ELSE 5 END
                    )
                    FROM menuca_v3.dish_modifier_prices dmp
                    WHERE dmp.dish_modifier_id = dm2.id AND dmp.is_active = true
                )
            )
        ) AS modifiers
        FROM menuca_v3.dish_modifiers dm2
        JOIN menuca_v3.ingredients i ON dm2.ingredient_id = i.id
        WHERE dm2.dish_id = d.id
    ) dm ON true
    WHERE d.restaurant_id = p_restaurant_id AND d.is_active = true
    ORDER BY c.display_order NULLS LAST, d.display_order;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.get_restaurant_menu(BIGINT) TO anon, authenticated;

COMMENT ON FUNCTION menuca_v3.get_restaurant_menu IS 
    'Returns complete menu with normalized pricing, modifiers, and real-time availability.';

DO $$ 
BEGIN
    RAISE NOTICE '[Step 7/7] ✅ Function updated successfully';
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

-- Verify table exists
SELECT 
    'dish_inventory' as table_name,
    COUNT(*) as columns
FROM information_schema.columns
WHERE table_schema = 'menuca_v3' AND table_name = 'dish_inventory';

-- Verify indexes
SELECT 
    COUNT(*) as index_count,
    'dish_inventory indexes' as description
FROM pg_indexes
WHERE schemaname = 'menuca_v3' AND tablename = 'dish_inventory';

-- Verify RLS
SELECT 
    tablename,
    CASE WHEN rowsecurity THEN '✅ Enabled' ELSE '❌ Disabled' END as rls_status
FROM pg_tables
WHERE schemaname = 'menuca_v3' AND tablename = 'dish_inventory';

-- Verify functions
SELECT 
    proname as function_name,
    '✅ Created' as status
FROM pg_proc
WHERE proname IN (
    'update_dish_availability',
    'decrement_dish_inventory',
    'is_dish_available_now',
    'notify_menu_change'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'menuca_v3')
ORDER BY proname;

-- Verify triggers
SELECT 
    COUNT(*) as trigger_count,
    'Notification triggers' as description
FROM information_schema.triggers
WHERE trigger_schema = 'menuca_v3' AND trigger_name LIKE '%notify%';

DO $$ 
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '✅ Phase 4 Migration Complete!';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '1. Test inventory functions with real restaurants';
    RAISE NOTICE '2. Subscribe to Realtime changes in client apps';
    RAISE NOTICE '3. Monitor pg_notify channels for custom events';
    RAISE NOTICE '4. Review Phase 4 documentation';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

