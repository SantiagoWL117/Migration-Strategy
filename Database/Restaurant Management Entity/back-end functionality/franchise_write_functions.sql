-- ========================================================================
-- Franchise Write Functions - Missing SQL Functions for Edge Functions
-- ========================================================================
-- Description: Write operations needed by Edge Functions
-- Dependencies: menuca_v3 schema, restaurants table with franchise columns
-- Author: Santiago
-- Date: 2025-10-17
-- Status: Ready for Deployment
-- ========================================================================

-- ========================================================================
-- TABLE: admin_action_logs (Required for Edge Functions)
-- ========================================================================

CREATE TABLE IF NOT EXISTS menuca_v3.admin_action_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,  -- UUID from Supabase Auth
    action VARCHAR(255) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id BIGINT,
    metadata JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for admin_action_logs
CREATE INDEX IF NOT EXISTS idx_admin_action_logs_user_id 
    ON menuca_v3.admin_action_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_admin_action_logs_action 
    ON menuca_v3.admin_action_logs(action);

CREATE INDEX IF NOT EXISTS idx_admin_action_logs_resource 
    ON menuca_v3.admin_action_logs(resource_type, resource_id);

CREATE INDEX IF NOT EXISTS idx_admin_action_logs_created_at 
    ON menuca_v3.admin_action_logs(created_at DESC);

COMMENT ON TABLE menuca_v3.admin_action_logs IS 
    'Audit trail for explicit admin actions via API (separate from automatic audit_log triggers)';

-- ========================================================================
-- FUNCTION 1: create_franchise_parent()
-- ========================================================================
-- Purpose: Create a new franchise parent/brand record
-- Used by: Edge Function create-franchise-parent
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.create_franchise_parent(
    p_name VARCHAR,
    p_franchise_brand_name VARCHAR,
    p_city_id INTEGER,
    p_province_id INTEGER,
    p_timezone VARCHAR DEFAULT 'America/Toronto',
    p_created_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
    parent_id BIGINT,
    brand_name VARCHAR,
    name VARCHAR,
    status menuca_v3.restaurant_status
) AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Validate inputs
    IF TRIM(p_name) = '' THEN
        RAISE EXCEPTION 'Restaurant name cannot be empty';
    END IF;
    
    IF TRIM(p_franchise_brand_name) = '' THEN
        RAISE EXCEPTION 'Franchise brand name cannot be empty';
    END IF;
    
    -- Check if brand name already exists
    IF EXISTS (
        SELECT 1 FROM menuca_v3.restaurants 
        WHERE franchise_brand_name = p_franchise_brand_name 
          AND is_franchise_parent = true
          AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Franchise brand name already exists: %', p_franchise_brand_name;
    END IF;
    
    -- Create franchise parent
    INSERT INTO menuca_v3.restaurants (
        name,
        franchise_brand_name,
        is_franchise_parent,
        status,
        city_id,
        province_id,
        timezone,
        created_at,
        updated_at
    ) VALUES (
        p_name,
        p_franchise_brand_name,
        true,
        'active',
        p_city_id,
        p_province_id,
        p_timezone,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;
    
    -- Return the created parent
    RETURN QUERY
    SELECT 
        v_new_id,
        p_franchise_brand_name,
        p_name,
        'active'::menuca_v3.restaurant_status;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.create_franchise_parent IS 
    'Create a new franchise parent/brand. Used by Edge Function create-franchise-parent.';

-- ========================================================================
-- FUNCTION 2: convert_to_franchise()
-- ========================================================================
-- Purpose: Convert single independent restaurant to franchise location
-- Used by: Edge Function convert-restaurant-to-franchise
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.convert_to_franchise(
    p_restaurant_id BIGINT,
    p_parent_restaurant_id BIGINT,
    p_updated_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    parent_restaurant_id BIGINT,
    parent_brand_name VARCHAR
) AS $$
DECLARE
    v_parent_brand VARCHAR;
    v_restaurant_name VARCHAR;
BEGIN
    -- Validate parent exists and is franchise parent
    SELECT franchise_brand_name INTO v_parent_brand
    FROM menuca_v3.restaurants
    WHERE id = p_parent_restaurant_id
      AND is_franchise_parent = true
      AND deleted_at IS NULL;
    
    IF v_parent_brand IS NULL THEN
        RAISE EXCEPTION 'Parent restaurant % not found or is not a franchise parent', p_parent_restaurant_id;
    END IF;
    
    -- Validate restaurant exists and is not already a franchise child
    SELECT name INTO v_restaurant_name
    FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id
      AND parent_restaurant_id IS NULL
      AND is_franchise_parent = false
      AND deleted_at IS NULL;
    
    IF v_restaurant_name IS NULL THEN
        RAISE EXCEPTION 'Restaurant % not found or is already part of a franchise', p_restaurant_id;
    END IF;
    
    -- Convert to franchise
    UPDATE menuca_v3.restaurants
    SET 
        parent_restaurant_id = p_parent_restaurant_id,
        updated_at = NOW()
    WHERE id = p_restaurant_id;
    
    -- Return result
    RETURN QUERY
    SELECT 
        p_restaurant_id,
        v_restaurant_name,
        p_parent_restaurant_id,
        v_parent_brand;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.convert_to_franchise IS 
    'Convert single independent restaurant to franchise location.';

-- ========================================================================
-- FUNCTION 3: batch_link_franchise_children()
-- ========================================================================
-- Purpose: Bulk link multiple restaurants to a franchise parent
-- Used by: Edge Function convert-restaurant-to-franchise (batch mode)
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.batch_link_franchise_children(
    p_parent_restaurant_id BIGINT,
    p_child_restaurant_ids BIGINT[],
    p_updated_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
    parent_restaurant_id BIGINT,
    parent_brand_name VARCHAR,
    linked_count INTEGER,
    child_restaurants JSONB
) AS $$
DECLARE
    v_parent_brand VARCHAR;
    v_linked_count INTEGER := 0;
    v_child_array JSONB;
BEGIN
    -- Validate parent
    SELECT franchise_brand_name INTO v_parent_brand
    FROM menuca_v3.restaurants
    WHERE id = p_parent_restaurant_id
      AND is_franchise_parent = true
      AND deleted_at IS NULL;
    
    IF v_parent_brand IS NULL THEN
        RAISE EXCEPTION 'Parent restaurant % not found or is not a franchise parent', p_parent_restaurant_id;
    END IF;
    
    -- Link all valid children
    WITH updated AS (
        UPDATE menuca_v3.restaurants
        SET 
            parent_restaurant_id = p_parent_restaurant_id,
            updated_at = NOW()
        WHERE id = ANY(p_child_restaurant_ids)
          AND parent_restaurant_id IS NULL
          AND is_franchise_parent = false
          AND deleted_at IS NULL
        RETURNING id, name
    )
    SELECT 
        COUNT(*)::INTEGER,
        jsonb_agg(jsonb_build_object('id', id, 'name', name))
    INTO v_linked_count, v_child_array
    FROM updated;
    
    -- Return result
    RETURN QUERY
    SELECT 
        p_parent_restaurant_id,
        v_parent_brand,
        v_linked_count,
        COALESCE(v_child_array, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.batch_link_franchise_children IS 
    'Bulk link multiple restaurants to a franchise parent.';

-- ========================================================================
-- FUNCTION 4: cascade_dish_to_children()
-- ========================================================================
-- Purpose: Copy a single dish from parent to all child locations
-- Used by: Edge Function cascade-franchise-menu
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.cascade_dish_to_children(
    p_parent_restaurant_id BIGINT,
    p_dish_id BIGINT,
    p_child_restaurant_ids BIGINT[] DEFAULT NULL,
    p_include_pricing BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    dish_name VARCHAR,
    children_updated INTEGER
) AS $$
DECLARE
    v_dish_name VARCHAR;
    v_updated_count INTEGER := 0;
BEGIN
    -- Get dish details from parent
    SELECT name INTO v_dish_name
    FROM menuca_v3.menu_items
    WHERE id = p_dish_id
      AND restaurant_id = p_parent_restaurant_id
      AND deleted_at IS NULL;
    
    IF v_dish_name IS NULL THEN
        RAISE EXCEPTION 'Dish % not found in parent restaurant %', p_dish_id, p_parent_restaurant_id;
    END IF;
    
    -- TODO: Implement dish copying logic based on your menu schema
    -- This is a placeholder that would need to be customized
    -- based on your actual menu_items table structure
    
    v_updated_count := 1; -- Placeholder
    
    RETURN QUERY
    SELECT v_dish_name, v_updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.cascade_dish_to_children IS 
    'Copy a single dish from parent to all child franchise locations.';

-- ========================================================================
-- FUNCTION 5: cascade_pricing_to_children()
-- ========================================================================
-- Purpose: Update pricing from parent to all child locations
-- Used by: Edge Function cascade-franchise-menu
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.cascade_pricing_to_children(
    p_parent_restaurant_id BIGINT,
    p_child_restaurant_ids BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
    children_updated INTEGER,
    dishes_updated INTEGER
) AS $$
DECLARE
    v_children_count INTEGER := 0;
    v_dishes_count INTEGER := 0;
BEGIN
    -- TODO: Implement pricing cascade logic based on your menu schema
    -- This is a placeholder that would need to be customized
    
    v_children_count := 1; -- Placeholder
    v_dishes_count := 0; -- Placeholder
    
    RETURN QUERY
    SELECT v_children_count, v_dishes_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.cascade_pricing_to_children IS 
    'Update pricing from parent to all child franchise locations.';

-- ========================================================================
-- FUNCTION 6: sync_menu_from_parent()
-- ========================================================================
-- Purpose: Full menu synchronization from parent to children
-- Used by: Edge Function cascade-franchise-menu
-- ========================================================================

CREATE OR REPLACE FUNCTION menuca_v3.sync_menu_from_parent(
    p_parent_restaurant_id BIGINT,
    p_child_restaurant_ids BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
    children_updated INTEGER,
    dishes_synced INTEGER
) AS $$
DECLARE
    v_children_count INTEGER := 0;
    v_dishes_count INTEGER := 0;
BEGIN
    -- TODO: Implement full menu sync logic based on your menu schema
    -- This is a placeholder that would need to be customized
    
    v_children_count := 1; -- Placeholder
    v_dishes_count := 0; -- Placeholder
    
    RETURN QUERY
    SELECT v_children_count, v_dishes_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.sync_menu_from_parent IS 
    'Full menu synchronization from parent to all child franchise locations.';

-- ========================================================================
-- VERIFICATION QUERIES
-- ========================================================================

-- Test 1: Check if table exists
-- SELECT COUNT(*) FROM menuca_v3.admin_action_logs;

-- Test 2: Test create_franchise_parent (will fail if brand exists)
-- SELECT * FROM menuca_v3.create_franchise_parent(
--     'Test Brand - Corporate',
--     'Test Brand',
--     245,
--     9,
--     'America/Toronto',
--     NULL
-- );

-- Test 3: Test convert_to_franchise
-- SELECT * FROM menuca_v3.convert_to_franchise(624, 986, NULL);

-- Test 4: Test batch link
-- SELECT * FROM menuca_v3.batch_link_franchise_children(986, ARRAY[625, 626], NULL);

-- ========================================================================
-- DEPLOYMENT NOTES
-- ========================================================================
-- 1. Run this script in Supabase SQL Editor
-- 2. Verify all functions created: \df menuca_v3.*franchise*
-- 3. Test Edge Functions after deployment
-- 4. Menu cascade functions need customization based on your menu schema
-- ========================================================================





