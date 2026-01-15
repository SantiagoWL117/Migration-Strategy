-- Update cache functions to use separate restaurant_menu_cache table
-- Date: January 15, 2026
-- Context: Resolving IO crisis - moving cache to separate table

-- 1. Update rebuild_menu_cache to use new table
CREATE OR REPLACE FUNCTION menuca_v3.rebuild_menu_cache(p_restaurant_id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO menuca_v3.restaurant_menu_cache (restaurant_id, menu_cache_en, menu_cache_fr, updated_at)
  SELECT 
    p_restaurant_id,
    menuca_v3.get_restaurant_menu(p_restaurant_id, 'en', true),
    menuca_v3.get_restaurant_menu(p_restaurant_id, 'fr', true),
    NOW()
  WHERE EXISTS (
    SELECT 1 FROM menuca_v3.restaurants 
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL
  )
  ON CONFLICT (restaurant_id) DO UPDATE SET
    menu_cache_en = EXCLUDED.menu_cache_en,
    menu_cache_fr = EXCLUDED.menu_cache_fr,
    updated_at = EXCLUDED.updated_at;
END;
$$;

-- 2. Update invalidate_menu_cache to use new table
CREATE OR REPLACE FUNCTION menuca_v3.invalidate_menu_cache(p_restaurant_id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE menuca_v3.restaurant_menu_cache
  SET 
    menu_cache_en = NULL,
    menu_cache_fr = NULL,
    updated_at = NOW()
  WHERE restaurant_id = p_restaurant_id;
END;
$$;

-- 3. Update get_restaurant_menu_cached to use new table
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu_cached(p_restaurant_id bigint, p_language_code text DEFAULT 'en'::text)
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

  -- Check restaurant exists and is active
  IF NOT EXISTS (
    SELECT 1 FROM menuca_v3.restaurants 
    WHERE id = p_restaurant_id AND status = 'active' AND deleted_at IS NULL
  ) THEN
    RETURN NULL;
  END IF;

  -- Try to get from cache table first
  IF p_language_code = 'en' THEN
    SELECT menu_cache_en INTO v_result
    FROM menuca_v3.restaurant_menu_cache
    WHERE restaurant_id = p_restaurant_id;
  ELSE
    SELECT menu_cache_fr INTO v_result
    FROM menuca_v3.restaurant_menu_cache
    WHERE restaurant_id = p_restaurant_id;
  END IF;

  -- If cache miss, fall back to live query
  IF v_result IS NULL THEN
    v_result := menuca_v3.get_restaurant_menu(p_restaurant_id, p_language_code, true);
  END IF;

  RETURN v_result;
END;
$$;

-- 4. Update rebuild_all_menu_caches to use new table
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
