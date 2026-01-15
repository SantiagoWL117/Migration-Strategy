-- FIX #9: Menu Cache Invalidation Triggers
-- 
-- These triggers invalidate the menu cache when menu-related data changes.
-- The cache is NOT automatically rebuilt - it's invalidated (set to NULL).
-- On next read, get_restaurant_menu_cached() will detect NULL and rebuild.
--
-- This "lazy invalidation" approach prevents cascade of rebuilds during bulk updates.

-- Generic trigger function that invalidates cache based on restaurant_id
CREATE OR REPLACE FUNCTION menuca_v3.trigger_invalidate_menu_cache()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant_id bigint;
BEGIN
  -- Get restaurant_id from the affected row
  v_restaurant_id := COALESCE(
    CASE 
      WHEN TG_OP = 'DELETE' THEN OLD.restaurant_id
      ELSE NEW.restaurant_id
    END,
    NULL
  );

  -- If we have a restaurant_id, invalidate its cache
  IF v_restaurant_id IS NOT NULL THEN
    PERFORM menuca_v3.invalidate_menu_cache(v_restaurant_id);
  END IF;

  -- Return appropriate row
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

-- Trigger function for tables that reference restaurant via dish
CREATE OR REPLACE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant_id bigint;
  v_dish_id bigint;
BEGIN
  -- Get dish_id from the affected row
  v_dish_id := COALESCE(
    CASE 
      WHEN TG_OP = 'DELETE' THEN OLD.dish_id
      ELSE NEW.dish_id
    END,
    NULL
  );

  -- Look up restaurant_id from dish
  IF v_dish_id IS NOT NULL THEN
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.dishes
    WHERE id = v_dish_id;

    IF v_restaurant_id IS NOT NULL THEN
      PERFORM menuca_v3.invalidate_menu_cache(v_restaurant_id);
    END IF;
  END IF;

  -- Return appropriate row
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

-- Trigger function for tables that reference restaurant via modifier_group
CREATE OR REPLACE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_modifier_group()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant_id bigint;
  v_modifier_group_id bigint;
BEGIN
  -- Get modifier_group_id from the affected row
  v_modifier_group_id := COALESCE(
    CASE 
      WHEN TG_OP = 'DELETE' THEN OLD.modifier_group_id
      ELSE NEW.modifier_group_id
    END,
    NULL
  );

  -- Look up restaurant_id from modifier_group
  IF v_modifier_group_id IS NOT NULL THEN
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.modifier_groups
    WHERE id = v_modifier_group_id;

    IF v_restaurant_id IS NOT NULL THEN
      PERFORM menuca_v3.invalidate_menu_cache(v_restaurant_id);
    END IF;
  END IF;

  -- Return appropriate row
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

-- Trigger function for modifier_prices (via modifier -> modifier_group)
CREATE OR REPLACE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_modifier()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant_id bigint;
  v_modifier_id bigint;
BEGIN
  -- Get modifier_id from the affected row
  v_modifier_id := COALESCE(
    CASE 
      WHEN TG_OP = 'DELETE' THEN OLD.modifier_id
      ELSE NEW.modifier_id
    END,
    NULL
  );

  -- Look up restaurant_id via modifier -> modifier_group
  IF v_modifier_id IS NOT NULL THEN
    SELECT mg.restaurant_id INTO v_restaurant_id
    FROM menuca_v3.modifiers m
    JOIN menuca_v3.modifier_groups mg ON mg.id = m.modifier_group_id
    WHERE m.id = v_modifier_id;

    IF v_restaurant_id IS NOT NULL THEN
      PERFORM menuca_v3.invalidate_menu_cache(v_restaurant_id);
    END IF;
  END IF;

  -- Return appropriate row
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

-- Trigger function for combo_groups
CREATE OR REPLACE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_combo_group()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_restaurant_id bigint;
  v_combo_group_id bigint;
BEGIN
  -- For combo_groups table, restaurant_id is direct
  IF TG_TABLE_NAME = 'combo_groups' THEN
    v_restaurant_id := COALESCE(
      CASE WHEN TG_OP = 'DELETE' THEN OLD.restaurant_id ELSE NEW.restaurant_id END,
      NULL
    );
  ELSE
    -- For combo_group_sections, look up via combo_group_id
    v_combo_group_id := COALESCE(
      CASE WHEN TG_OP = 'DELETE' THEN OLD.combo_group_id ELSE NEW.combo_group_id END,
      NULL
    );
    
    IF v_combo_group_id IS NOT NULL THEN
      SELECT restaurant_id INTO v_restaurant_id
      FROM menuca_v3.combo_groups
      WHERE id = v_combo_group_id;
    END IF;
  END IF;

  IF v_restaurant_id IS NOT NULL THEN
    PERFORM menuca_v3.invalidate_menu_cache(v_restaurant_id);
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

-------------------------------------------------------------------
-- CREATE TRIGGERS ON MENU-RELATED TABLES
-------------------------------------------------------------------

-- 1. COURSES - has direct restaurant_id
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.courses;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.courses
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache();

-- 2. DISHES - has direct restaurant_id
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.dishes;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dishes
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache();

-- 3. DISH_PRICES - references dish
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.dish_prices;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_prices
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish();

-- 4. DISH_AVAILABILITY - references dish
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.dish_availability;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_availability
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish();

-- 5. MODIFIER_GROUPS - has direct restaurant_id
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.modifier_groups;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.modifier_groups
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache();

-- 6. MODIFIERS - references modifier_group
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.modifiers;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.modifiers
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_modifier_group();

-- 7. MODIFIER_PRICES - references modifier
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.modifier_prices;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.modifier_prices
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_modifier();

-- 8. MODIFIER_GROUP_DETAILS - references dish (via dish_modifier_group)
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.modifier_group_details;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.modifier_group_details
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish();

-- 9. DISH_MODIFIER_GROUPS - references dish
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.dish_modifier_groups;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_modifier_groups
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish();

-- 10. COMBO_GROUPS - has direct restaurant_id
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.combo_groups;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.combo_groups
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_combo_group();

-- 11. COMBO_GROUP_SECTIONS - references combo_group
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.combo_group_sections;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.combo_group_sections
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_combo_group();

-- 12. DISH_COMBO_GROUPS - references dish
DROP TRIGGER IF EXISTS trg_invalidate_menu_cache ON menuca_v3.dish_combo_groups;
CREATE TRIGGER trg_invalidate_menu_cache
AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.dish_combo_groups
FOR EACH ROW EXECUTE FUNCTION menuca_v3.trigger_invalidate_menu_cache_via_dish();
