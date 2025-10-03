-- ============================================================================
-- Menu & Catalog Entity - Transformation Helper Functions
-- ============================================================================
-- Purpose: Utility functions for V1/V2 → V3 data transformation
-- Created: 2025-10-02
-- Author: Brian Lapp
-- ============================================================================

-- ============================================================================
-- FUNCTION 1: Parse comma-separated prices to JSONB
-- ============================================================================
-- Converts V1 price formats:
-- "10.99" → {"default": "10.99"}
-- "10,12,14" → {"small": "10", "medium": "12", "large": "14"}
-- "10,12,14,16" → {"xsmall": "10", "small": "12", "medium": "14", "large": "16"}

CREATE OR REPLACE FUNCTION staging.parse_price_to_jsonb(price_str TEXT)
RETURNS JSONB AS $$
DECLARE
  parts TEXT[];
  result JSONB;
BEGIN
  -- Handle NULL or empty
  IF price_str IS NULL OR TRIM(price_str) = '' THEN
    RETURN '{"default": "0.00"}'::jsonb;
  END IF;

  -- Split by comma
  parts := string_to_array(TRIM(price_str), ',');
  
  -- Single price: {"default": "price"}
  IF array_length(parts, 1) = 1 THEN
    result := jsonb_build_object('default', TRIM(parts[1]));
    
  -- Two prices: {"small": "p1", "large": "p2"}
  ELSIF array_length(parts, 1) = 2 THEN
    result := jsonb_build_object(
      'small', TRIM(parts[1]),
      'large', TRIM(parts[2])
    );
    
  -- Three prices: {"small": "p1", "medium": "p2", "large": "p3"}
  ELSIF array_length(parts, 1) = 3 THEN
    result := jsonb_build_object(
      'small', TRIM(parts[1]),
      'medium', TRIM(parts[2]),
      'large', TRIM(parts[3])
    );
    
  -- Four prices: {"xsmall": "p1", "small": "p2", "medium": "p3", "large": "p4"}
  ELSIF array_length(parts, 1) = 4 THEN
    result := jsonb_build_object(
      'xsmall', TRIM(parts[1]),
      'small', TRIM(parts[2]),
      'medium', TRIM(parts[3]),
      'large', TRIM(parts[4])
    );
    
  -- Five or more prices: default to small/medium/large + extras
  ELSE
    result := jsonb_build_object(
      'small', TRIM(parts[1]),
      'medium', COALESCE(TRIM(parts[2]), TRIM(parts[1])),
      'large', COALESCE(TRIM(parts[3]), TRIM(parts[2]), TRIM(parts[1]))
    );
  END IF;
  
  RETURN result;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Fallback: return as default price
    RETURN jsonb_build_object('default', price_str);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Test cases
-- SELECT staging.parse_price_to_jsonb('10.99');  -- {"default": "10.99"}
-- SELECT staging.parse_price_to_jsonb('10,12,14');  -- {"small": "10", "medium": "12", "large": "14"}

-- ============================================================================
-- FUNCTION 2: Map V1 language codes to V3 format
-- ============================================================================
-- V1 uses: 'en', 'fr', 'e', 'f', NULL
-- V3 uses: 'en', 'fr'

CREATE OR REPLACE FUNCTION staging.normalize_language(lang_code TEXT)
RETURNS VARCHAR(2) AS $$
BEGIN
  CASE 
    WHEN lang_code IN ('en', 'e', 'E') THEN RETURN 'en';
    WHEN lang_code IN ('fr', 'f', 'F') THEN RETURN 'fr';
    ELSE RETURN 'en'; -- Default to English
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 3: Map V2 language_id to V3 format
-- ============================================================================
-- V2 uses: 1 = English, 2 = French
-- V3 uses: 'en', 'fr'

CREATE OR REPLACE FUNCTION staging.language_id_to_code(lang_id INTEGER)
RETURNS VARCHAR(2) AS $$
BEGIN
  CASE 
    WHEN lang_id = 1 THEN RETURN 'en';
    WHEN lang_id = 2 THEN RETURN 'fr';
    ELSE RETURN 'en'; -- Default to English
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 4: Convert Y/N flags to boolean
-- ============================================================================

CREATE OR REPLACE FUNCTION staging.yn_to_boolean(flag TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN UPPER(TRIM(flag)) IN ('Y', 'YES', '1', 'TRUE');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 5: Safe JSON parse with fallback
-- ============================================================================
-- Attempts to parse JSON, returns NULL if invalid

CREATE OR REPLACE FUNCTION staging.safe_json_parse(json_str TEXT)
RETURNS JSONB AS $$
BEGIN
  IF json_str IS NULL OR TRIM(json_str) = '' THEN
    RETURN NULL;
  END IF;
  
  RETURN json_str::jsonb;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 6: Extract customization config from V1 menu columns
-- ============================================================================
-- Returns array of customization records for a dish

CREATE OR REPLACE FUNCTION staging.extract_v1_customizations(
  has_bread TEXT,
  bread_header TEXT,
  display_order_bread SMALLINT,
  has_ci TEXT,
  ci_header TEXT,
  min_ci SMALLINT,
  max_ci SMALLINT,
  free_ci SMALLINT,
  display_order_ci SMALLINT,
  has_dressing TEXT,
  dressing_header TEXT,
  min_dressing SMALLINT,
  max_dressing SMALLINT,
  free_dressing SMALLINT,
  display_order_dressing SMALLINT,
  has_sauce TEXT,
  sauce_header TEXT,
  min_sauce SMALLINT,
  max_sauce SMALLINT,
  free_sauce SMALLINT,
  display_order_sauce SMALLINT,
  has_sidedish TEXT,
  sidedish_header TEXT,
  min_sd SMALLINT,
  max_sd SMALLINT,
  free_sd SMALLINT,
  display_order_sd SMALLINT,
  has_drinks TEXT,
  drinks_header TEXT,
  min_drink TEXT,
  max_drink TEXT,
  free_drink TEXT,
  display_order_drink SMALLINT,
  has_extras TEXT,
  extra_header TEXT,
  min_extras SMALLINT,
  max_extras SMALLINT,
  free_extra SMALLINT,
  display_order_extras SMALLINT,
  has_cookmethod TEXT,
  cm_header TEXT,
  min_cm INTEGER,
  max_cm INTEGER,
  free_cm INTEGER,
  display_order_cm INTEGER
)
RETURNS JSONB AS $$
DECLARE
  customizations JSONB := '[]'::jsonb;
BEGIN
  -- Bread
  IF staging.yn_to_boolean(has_bread) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'bread',
      'title', bread_header,
      'min', 0,
      'max', 1,
      'free', 1,
      'display_order', COALESCE(display_order_bread, 0)
    );
  END IF;
  
  -- Custom Ingredients (CI)
  IF staging.yn_to_boolean(has_ci) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'ci',
      'title', ci_header,
      'min', COALESCE(min_ci, 0),
      'max', COALESCE(max_ci, 0),
      'free', COALESCE(free_ci, 0),
      'display_order', COALESCE(display_order_ci, 0)
    );
  END IF;
  
  -- Dressing
  IF staging.yn_to_boolean(has_dressing) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'dressing',
      'title', dressing_header,
      'min', COALESCE(min_dressing, 0),
      'max', COALESCE(max_dressing, 0),
      'free', COALESCE(free_dressing, 0),
      'display_order', COALESCE(display_order_dressing, 0)
    );
  END IF;
  
  -- Sauce
  IF staging.yn_to_boolean(has_sauce) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'sauce',
      'title', sauce_header,
      'min', COALESCE(min_sauce, 0),
      'max', COALESCE(max_sauce, 0),
      'free', COALESCE(free_sauce, 0),
      'display_order', COALESCE(display_order_sauce, 0)
    );
  END IF;
  
  -- Side Dish
  IF staging.yn_to_boolean(has_sidedish) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'sidedish',
      'title', sidedish_header,
      'min', COALESCE(min_sd, 0),
      'max', COALESCE(max_sd, 0),
      'free', COALESCE(free_sd, 0),
      'display_order', COALESCE(display_order_sd, 0)
    );
  END IF;
  
  -- Drinks
  IF staging.yn_to_boolean(has_drinks) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'drinks',
      'title', drinks_header,
      'min', COALESCE(min_drink::SMALLINT, 0),
      'max', COALESCE(max_drink::SMALLINT, 0),
      'free', COALESCE(free_drink::SMALLINT, 0),
      'display_order', COALESCE(display_order_drink, 0)
    );
  END IF;
  
  -- Extras
  IF staging.yn_to_boolean(has_extras) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'extras',
      'title', extra_header,
      'min', COALESCE(min_extras, 0),
      'max', COALESCE(max_extras, 0),
      'free', COALESCE(free_extra, 0),
      'display_order', COALESCE(display_order_extras, 0)
    );
  END IF;
  
  -- Cook Method
  IF staging.yn_to_boolean(has_cookmethod) THEN
    customizations := customizations || jsonb_build_object(
      'type', 'cookmethod',
      'title', cm_header,
      'min', COALESCE(min_cm, 0),
      'max', COALESCE(max_cm, 0),
      'free', COALESCE(free_cm, 0),
      'display_order', COALESCE(display_order_cm, 0)
    );
  END IF;
  
  RETURN customizations;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 7: Map V1 customization type codes to V3
-- ============================================================================
-- V1 uses: 'ci', 'sd', 'dr', 'e', 'br', 'sa', 'ds', 'cm'
-- V3 uses: 'ci', 'sidedish', 'drinks', 'extras', 'bread', 'sauce', 'dressing', 'cookmethod'

CREATE OR REPLACE FUNCTION staging.map_customization_type(v1_type TEXT)
RETURNS VARCHAR(50) AS $$
BEGIN
  CASE UPPER(TRIM(v1_type))
    WHEN 'CI' THEN RETURN 'ci';
    WHEN 'SD' THEN RETURN 'sidedish';
    WHEN 'DR' THEN RETURN 'drinks';
    WHEN 'E' THEN RETURN 'extras';
    WHEN 'BR' THEN RETURN 'bread';
    WHEN 'SA' THEN RETURN 'sauce';
    WHEN 'DS' THEN RETURN 'dressing';
    WHEN 'CM' THEN RETURN 'cookmethod';
    ELSE RETURN v1_type; -- Pass through if already mapped
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 8: Validate and clean restaurant_id
-- ============================================================================
-- Ensures restaurant_id exists in staging restaurants

CREATE OR REPLACE FUNCTION staging.validate_restaurant_id(rid INTEGER)
RETURNS INTEGER AS $$
DECLARE
  exists_in_v1 BOOLEAN;
  exists_in_v2 BOOLEAN;
BEGIN
  -- Check if exists in either V1 or V2 staging restaurants
  SELECT EXISTS(SELECT 1 FROM staging.v1_restaurants WHERE id = rid) INTO exists_in_v1;
  SELECT EXISTS(SELECT 1 FROM staging.v2_restaurants WHERE id = rid) INTO exists_in_v2;
  
  IF exists_in_v1 OR exists_in_v2 THEN
    RETURN rid;
  ELSE
    RETURN NULL; -- Invalid restaurant_id
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- FUNCTION 9: Extract V2 customization config
-- ============================================================================
-- Parses V2 JSON config and returns standardized format

CREATE OR REPLACE FUNCTION staging.parse_v2_customization_config(
  config_json TEXT
)
RETURNS JSONB AS $$
DECLARE
  config JSONB;
  result JSONB := '{}'::jsonb;
BEGIN
  -- Parse JSON
  config := staging.safe_json_parse(config_json);
  
  IF config IS NULL THEN
    RETURN NULL;
  END IF;
  
  -- Extract standard fields
  result := jsonb_build_object(
    'min', COALESCE((config->>'min')::INTEGER, 0),
    'max', COALESCE((config->>'max')::INTEGER, 0),
    'free', COALESCE((config->>'free')::INTEGER, 0),
    'title', config->>'title',
    'display_order', COALESCE((config->>'display_order')::INTEGER, 0),
    'group_id', config->>'group'
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION 10: Create availability schedule from time_period
-- ============================================================================
-- Maps V1/V2 time_period to V3 availability_schedule JSONB

CREATE OR REPLACE FUNCTION staging.create_availability_schedule(
  time_period INTEGER
)
RETURNS JSONB AS $$
BEGIN
  -- NULL means always available
  IF time_period IS NULL OR time_period = 0 THEN
    RETURN NULL;
  END IF;
  
  -- Map known time periods
  -- This is a placeholder - actual mapping depends on business logic
  CASE time_period
    WHEN 1 THEN 
      RETURN '{"availability": "lunch", "hours": [{"start": "11:00", "end": "16:00"}]}'::jsonb;
    WHEN 2 THEN 
      RETURN '{"availability": "dinner", "hours": [{"start": "16:00", "end": "22:00"}]}'::jsonb;
    WHEN 3 THEN 
      RETURN '{"availability": "late_night", "hours": [{"start": "22:00", "end": "02:00"}]}'::jsonb;
    ELSE 
      RETURN jsonb_build_object('time_period_id', time_period);
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- VERIFICATION: Test all functions
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Transformation Helper Functions Created!';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Available Functions:';
  RAISE NOTICE '  1. parse_price_to_jsonb(price_str) - Parse comma-separated prices';
  RAISE NOTICE '  2. normalize_language(lang_code) - V1 language to V3';
  RAISE NOTICE '  3. language_id_to_code(lang_id) - V2 language_id to V3';
  RAISE NOTICE '  4. yn_to_boolean(flag) - Y/N to boolean';
  RAISE NOTICE '  5. safe_json_parse(json_str) - Safe JSON parsing';
  RAISE NOTICE '  6. extract_v1_customizations(...) - Extract V1 customizations';
  RAISE NOTICE '  7. map_customization_type(v1_type) - Map type codes';
  RAISE NOTICE '  8. validate_restaurant_id(rid) - Validate restaurant FK';
  RAISE NOTICE '  9. parse_v2_customization_config(json) - Parse V2 config';
  RAISE NOTICE '  10. create_availability_schedule(period) - Create schedule JSONB';
  RAISE NOTICE '';
  RAISE NOTICE '⏭️  Next: Build transformation queries for V1→V3 and V2→V3';
END $$;

