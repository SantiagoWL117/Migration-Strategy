-- ============================================================
-- DISH AVAILABILITY MANAGEMENT FUNCTION
-- Allows frontend to update hidden days for any dish
-- 
-- Usage from Supabase/Frontend:
--   SELECT menuca_v3.update_dish_availability(172885, ARRAY[0, 6]);  -- Hide on Sun, Sat
--   SELECT menuca_v3.update_dish_availability(172885, ARRAY[]::int[]);  -- Remove all restrictions
--   SELECT menuca_v3.update_dish_availability(172885, NULL);  -- Remove all restrictions
--
-- Created: 2026-01-08
-- ============================================================

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS menuca_v3.update_dish_availability(BIGINT, INT[]);

CREATE OR REPLACE FUNCTION menuca_v3.update_dish_availability(
    p_dish_id BIGINT,
    p_hidden_days INT[] DEFAULT ARRAY[]::INT[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_dish_exists BOOLEAN;
    v_deleted_count INT;
    v_inserted_count INT;
    v_day INT;
BEGIN
    -- Validate dish exists
    SELECT EXISTS(
        SELECT 1 FROM menuca_v3.dishes 
        WHERE id = p_dish_id AND deleted_at IS NULL
    ) INTO v_dish_exists;
    
    IF NOT v_dish_exists THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Dish not found',
            'dish_id', p_dish_id
        );
    END IF;
    
    -- Delete all existing availability records for this dish
    DELETE FROM menuca_v3.dish_availability 
    WHERE dish_id = p_dish_id;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    -- If hidden_days is NULL or empty, just return (all restrictions removed)
    IF p_hidden_days IS NULL OR array_length(p_hidden_days, 1) IS NULL THEN
        RETURN jsonb_build_object(
            'success', true,
            'dish_id', p_dish_id,
            'hidden_days', '[]'::jsonb,
            'message', 'All restrictions removed',
            'deleted_count', v_deleted_count,
            'inserted_count', 0
        );
    END IF;
    
    -- Validate day values (must be 0-6)
    FOREACH v_day IN ARRAY p_hidden_days
    LOOP
        IF v_day < 0 OR v_day > 6 THEN
            RETURN jsonb_build_object(
                'success', false,
                'error', 'Invalid day value. Must be 0-6 (0=Sunday, 6=Saturday)',
                'invalid_day', v_day
            );
        END IF;
    END LOOP;
    
    -- Insert new availability records
    INSERT INTO menuca_v3.dish_availability (dish_id, day_of_week, is_hidden)
    SELECT p_dish_id, unnest(p_hidden_days), true
    ON CONFLICT (dish_id, day_of_week) DO NOTHING;
    
    GET DIAGNOSTICS v_inserted_count = ROW_COUNT;
    
    -- Return success with the new hidden_days
    RETURN jsonb_build_object(
        'success', true,
        'dish_id', p_dish_id,
        'hidden_days', to_jsonb(p_hidden_days),
        'message', 'Availability updated',
        'deleted_count', v_deleted_count,
        'inserted_count', v_inserted_count
    );
END;
$$;

-- Grant execute permission for authenticated users (Supabase)
GRANT EXECUTE ON FUNCTION menuca_v3.update_dish_availability(BIGINT, INT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.update_dish_availability(BIGINT, INT[]) TO service_role;

-- ============================================================
-- GET DISH AVAILABILITY FUNCTION
-- Returns current hidden days for a dish
-- ============================================================

CREATE OR REPLACE FUNCTION menuca_v3.get_dish_availability(
    p_dish_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_dish_exists BOOLEAN;
    v_hidden_days INT[];
    v_dish_name TEXT;
BEGIN
    -- Get dish info
    SELECT 
        true,
        name
    INTO v_dish_exists, v_dish_name
    FROM menuca_v3.dishes 
    WHERE id = p_dish_id AND deleted_at IS NULL;
    
    IF NOT v_dish_exists THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Dish not found',
            'dish_id', p_dish_id
        );
    END IF;
    
    -- Get hidden days
    SELECT array_agg(day_of_week ORDER BY day_of_week)
    INTO v_hidden_days
    FROM menuca_v3.dish_availability
    WHERE dish_id = p_dish_id AND is_hidden = true;
    
    RETURN jsonb_build_object(
        'success', true,
        'dish_id', p_dish_id,
        'dish_name', v_dish_name,
        'hidden_days', COALESCE(to_jsonb(v_hidden_days), '[]'::jsonb)
    );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION menuca_v3.get_dish_availability(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_dish_availability(BIGINT) TO service_role;

COMMENT ON FUNCTION menuca_v3.update_dish_availability IS 
'Updates the day-of-week visibility restrictions for a dish.
Parameters:
  - p_dish_id: The dish ID
  - p_hidden_days: Array of days (0=Sun, 1=Mon, ..., 6=Sat) when dish should be hidden
    Pass NULL or empty array to remove all restrictions.
Returns: JSONB with success status and updated hidden_days';

COMMENT ON FUNCTION menuca_v3.get_dish_availability IS 
'Gets the current day-of-week visibility restrictions for a dish.
Parameters:
  - p_dish_id: The dish ID
Returns: JSONB with dish info and hidden_days array';

