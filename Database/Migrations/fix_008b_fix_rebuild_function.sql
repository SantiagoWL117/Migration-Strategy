-- Fix the ambiguous column reference in rebuild_all_menu_caches

DROP FUNCTION IF EXISTS menuca_v3.rebuild_all_menu_caches();

CREATE OR REPLACE FUNCTION menuca_v3.rebuild_all_menu_caches()
RETURNS TABLE(restaurant_id bigint, restaurant_name text, rebuild_status text)
LANGUAGE plpgsql
AS $func$
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
$func$;
