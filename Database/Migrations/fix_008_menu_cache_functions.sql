-- FIX #8: Menu Cache Rebuild Functions
-- 
-- Creates functions to rebuild the menu cache for a restaurant.
-- The cache is automatically invalidated when menu data changes.

-- Function to rebuild cache for a single restaurant
CREATE OR REPLACE FUNCTION menuca_v3.rebuild_menu_cache(p_restaurant_id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE menuca_v3.restaurants
  SET 
    menu_cache_en = menuca_v3.get_restaurant_menu(p_restaurant_id, 'en', true),
    menu_cache_fr = menuca_v3.get_restaurant_menu(p_restaurant_id, 'fr', true),
    menu_cache_updated_at = NOW()
  WHERE id = p_restaurant_id
    AND status = 'active'
    AND deleted_at IS NULL;
END;
$$;

-- Function to rebuild cache for ALL active restaurants (for initial population)
CREATE OR REPLACE FUNCTION menuca_v3.rebuild_all_menu_caches()
RETURNS TABLE(restaurant_id bigint, restaurant_name text, rebuild_status text)
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant RECORD;
  v_count int := 0;
BEGIN
  FOR v_restaurant IN 
    SELECT r.id, r.name 
    FROM menuca_v3.restaurants r
    WHERE r.status = 'active' AND r.deleted_at IS NULL
    ORDER BY r.id
  LOOP
    BEGIN
      PERFORM menuca_v3.rebuild_menu_cache(v_restaurant.id);
      v_count := v_count + 1;
      
      restaurant_id := v_restaurant.id;
      restaurant_name := v_restaurant.name;
      rebuild_status := 'OK';
      RETURN NEXT;
      
    EXCEPTION WHEN OTHERS THEN
      restaurant_id := v_restaurant.id;
      restaurant_name := v_restaurant.name;
      rebuild_status := 'ERROR: ' || SQLERRM;
      RETURN NEXT;
    END;
  END LOOP;
  
  RAISE NOTICE 'Rebuilt cache for % restaurants', v_count;
END;
$$;

-- Function to get menu from cache (with fallback to live query)
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu_cached(
  p_restaurant_id bigint,
  p_language_code text DEFAULT 'en'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_result jsonb;
BEGIN
  -- Validate language code
  IF p_language_code NOT IN ('en', 'fr') THEN
    RAISE EXCEPTION 'Invalid language code: %. Supported values are ''en'' or ''fr''', p_language_code;
  END IF;

  -- Try to get from cache first
  IF p_language_code = 'en' THEN
    SELECT menu_cache_en INTO v_result
    FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL;
  ELSE
    SELECT menu_cache_fr INTO v_result
    FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL;
  END IF;

  -- If cache miss, fall back to live query
  IF v_result IS NULL THEN
    v_result := menuca_v3.get_restaurant_menu(p_restaurant_id, p_language_code, true);
  END IF;

  RETURN v_result;
END;
$$;

-- Function to invalidate cache (marks as stale by setting to NULL)
CREATE OR REPLACE FUNCTION menuca_v3.invalidate_menu_cache(p_restaurant_id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE menuca_v3.restaurants
  SET 
    menu_cache_en = NULL,
    menu_cache_fr = NULL,
    menu_cache_updated_at = NULL
  WHERE id = p_restaurant_id;
END;
$$;
