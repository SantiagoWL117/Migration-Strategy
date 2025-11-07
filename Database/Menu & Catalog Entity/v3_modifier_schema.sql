-- ============================================================
-- V3 Modifier System Schema
-- Normalized structure for dish customization (modifiers)
-- Supports V1 (multi-step combos) and V2 (grouped customization)
-- ============================================================

-- ============================================================
-- 1. MODIFIER GROUPS
-- Represents a set of related options (e.g., "Sauces", "Toppings", "Size")
-- ============================================================
CREATE TABLE IF NOT EXISTS menuca_v3.modifier_groups (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,

    -- Group identity
    name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Selection rules
    select_type VARCHAR(20) NOT NULL CHECK (select_type IN ('single', 'multi')),
    min_selections INTEGER NOT NULL DEFAULT 0,
    max_selections INTEGER, -- NULL means unlimited
    allow_quantity_per_option BOOLEAN DEFAULT FALSE,

    -- Display & behavior
    display_order INTEGER NOT NULL DEFAULT 0,
    is_required BOOLEAN DEFAULT FALSE,

    -- Multi-language support
    name_translations JSONB, -- {"en": "Sauces", "fr": "Sauces"}
    description_translations JSONB,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by INTEGER,
    is_active BOOLEAN DEFAULT TRUE,

    -- Indexes
    CONSTRAINT modifier_groups_unique_name_per_restaurant UNIQUE(restaurant_id, name)
);

CREATE INDEX idx_modifier_groups_restaurant ON menuca_v3.modifier_groups(restaurant_id) WHERE is_active = TRUE;
CREATE INDEX idx_modifier_groups_display_order ON menuca_v3.modifier_groups(restaurant_id, display_order);

COMMENT ON TABLE menuca_v3.modifier_groups IS 'Groups of related modifier options (e.g., Sauces, Toppings, Size)';
COMMENT ON COLUMN menuca_v3.modifier_groups.select_type IS 'single = radio buttons (pick one), multi = checkboxes (pick many)';
COMMENT ON COLUMN menuca_v3.modifier_groups.min_selections IS 'Minimum number of options that must be selected (0 = optional)';
COMMENT ON COLUMN menuca_v3.modifier_groups.max_selections IS 'Maximum selections allowed (NULL = unlimited for multi-select)';

-- ============================================================
-- 2. MODIFIER OPTIONS
-- Individual choices within a group (e.g., "Tzatziki", "Extra Cheese")
-- ============================================================
CREATE TABLE IF NOT EXISTS menuca_v3.modifier_options (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES menuca_v3.modifier_groups(id) ON DELETE CASCADE,

    -- Option identity
    name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Pricing
    price_delta DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- Added cost (+$2.00) or discount (-$1.00)

    -- Quantity controls (when allow_quantity_per_option = TRUE on group)
    max_quantity INTEGER DEFAULT 1, -- How many of this option can be selected

    -- Display & behavior
    display_order INTEGER NOT NULL DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE, -- Auto-selected when customization opens

    -- Multi-language support
    name_translations JSONB,
    description_translations JSONB,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,

    -- Constraints
    CONSTRAINT modifier_options_unique_name_per_group UNIQUE(group_id, name)
);

CREATE INDEX idx_modifier_options_group ON menuca_v3.modifier_options(group_id) WHERE is_active = TRUE;
CREATE INDEX idx_modifier_options_display_order ON menuca_v3.modifier_options(group_id, display_order);
CREATE INDEX idx_modifier_options_default ON menuca_v3.modifier_options(group_id) WHERE is_default = TRUE;

COMMENT ON TABLE menuca_v3.modifier_options IS 'Individual selectable options within a modifier group';
COMMENT ON COLUMN menuca_v3.modifier_options.price_delta IS 'Price adjustment when this option is selected (positive = add, negative = discount)';
COMMENT ON COLUMN menuca_v3.modifier_options.is_default IS 'Automatically selected when dish customization is opened';

-- ============================================================
-- 3. MODIFIER GROUP ASSIGNMENTS
-- Links modifier groups to dishes, courses, or restaurant-wide
-- Supports inheritance: dish-level overrides course-level overrides restaurant-level
-- ============================================================
CREATE TABLE IF NOT EXISTS menuca_v3.modifier_group_assignments (
    id BIGSERIAL PRIMARY KEY,

    -- What does this group apply to?
    restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    group_id BIGINT NOT NULL REFERENCES menuca_v3.modifier_groups(id) ON DELETE CASCADE,
    dish_id BIGINT REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE, -- Specific dish
    course_id BIGINT REFERENCES menuca_v3.courses(id) ON DELETE CASCADE, -- All dishes in course
    -- If both dish_id and course_id are NULL, this is a restaurant-wide group

    -- Assignment-level overrides (can override group defaults)
    is_required BOOLEAN, -- NULL = inherit from group, TRUE/FALSE = override
    min_selections INTEGER, -- NULL = inherit from group
    max_selections INTEGER, -- NULL = inherit from group

    -- Multi-step wizard support (for V1-style sequential modifiers)
    step_order INTEGER, -- NULL = single-page, 1,2,3... = multi-step wizard

    -- Display
    display_order INTEGER NOT NULL DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,

    -- Constraints
    CONSTRAINT modifier_assignments_scope_check CHECK (
        (dish_id IS NOT NULL AND course_id IS NULL) OR -- Dish-specific
        (dish_id IS NULL AND course_id IS NOT NULL) OR -- Course-wide
        (dish_id IS NULL AND course_id IS NULL)        -- Restaurant-wide
    ),
    CONSTRAINT modifier_assignments_unique_per_scope UNIQUE(group_id, restaurant_id, dish_id, course_id)
);

CREATE INDEX idx_modifier_assignments_restaurant ON menuca_v3.modifier_group_assignments(restaurant_id) WHERE is_active = TRUE;
CREATE INDEX idx_modifier_assignments_dish ON menuca_v3.modifier_group_assignments(dish_id) WHERE is_active = TRUE AND dish_id IS NOT NULL;
CREATE INDEX idx_modifier_assignments_course ON menuca_v3.modifier_group_assignments(course_id) WHERE is_active = TRUE AND course_id IS NOT NULL;
CREATE INDEX idx_modifier_assignments_group ON menuca_v3.modifier_group_assignments(group_id) WHERE is_active = TRUE;
CREATE INDEX idx_modifier_assignments_step_order ON menuca_v3.modifier_group_assignments(dish_id, step_order) WHERE step_order IS NOT NULL;

COMMENT ON TABLE menuca_v3.modifier_group_assignments IS 'Links modifier groups to dishes, courses, or restaurants (supports inheritance)';
COMMENT ON COLUMN menuca_v3.modifier_group_assignments.dish_id IS 'Applies to specific dish (highest precedence)';
COMMENT ON COLUMN menuca_v3.modifier_group_assignments.course_id IS 'Applies to all dishes in this course (medium precedence)';
COMMENT ON COLUMN menuca_v3.modifier_group_assignments.step_order IS 'For multi-step UX (V1): 1, 2, 3... NULL = single-page (V2)';

-- ============================================================
-- 4. DISH CONFIGURATIONS (Cart line items with selected modifiers)
-- ============================================================
CREATE TABLE IF NOT EXISTS menuca_v3.dish_configurations (
    id BIGSERIAL PRIMARY KEY,
    dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,

    -- Snapshots at time of configuration (for price stability)
    base_price_snapshot DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL, -- base + sum of modifier price deltas

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Optional: Link to order/cart (future)
    order_id BIGINT, -- REFERENCES menuca_v3.orders(id)
    cart_session_id VARCHAR(255)
);

CREATE INDEX idx_dish_configurations_dish ON menuca_v3.dish_configurations(dish_id);
CREATE INDEX idx_dish_configurations_order ON menuca_v3.dish_configurations(order_id) WHERE order_id IS NOT NULL;
CREATE INDEX idx_dish_configurations_cart ON menuca_v3.dish_configurations(cart_session_id) WHERE cart_session_id IS NOT NULL;

COMMENT ON TABLE menuca_v3.dish_configurations IS 'Snapshot of a dish with selected modifiers (cart line item or saved order)';

-- ============================================================
-- 5. DISH CONFIGURATION OPTIONS (Many-to-many: configs to options)
-- ============================================================
CREATE TABLE IF NOT EXISTS menuca_v3.dish_configuration_options (
    id BIGSERIAL PRIMARY KEY,
    configuration_id BIGINT NOT NULL REFERENCES menuca_v3.dish_configurations(id) ON DELETE CASCADE,
    option_id BIGINT NOT NULL REFERENCES menuca_v3.modifier_options(id) ON DELETE RESTRICT,

    -- Quantity (for options that allow multiples)
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),

    -- Snapshot of price delta at time of selection (for price stability)
    price_delta_snapshot DECIMAL(10,2) NOT NULL,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_config_options_configuration ON menuca_v3.dish_configuration_options(configuration_id);
CREATE INDEX idx_config_options_option ON menuca_v3.dish_configuration_options(option_id);

COMMENT ON TABLE menuca_v3.dish_configuration_options IS 'Selected modifier options for a specific dish configuration';

-- ============================================================
-- 6. HELPER VIEW: Effective Modifier Groups per Dish
-- Resolves inheritance: dish > course > restaurant
-- ============================================================
CREATE OR REPLACE VIEW menuca_v3.vw_dish_modifier_groups AS
SELECT DISTINCT ON (d.id, mga.group_id)
    d.id AS dish_id,
    d.name AS dish_name,
    d.restaurant_id,
    mga.group_id,
    mg.name AS group_name,
    mg.select_type,

    -- Effective values (assignment overrides or group defaults)
    COALESCE(mga.is_required, mg.is_required) AS is_required,
    COALESCE(mga.min_selections, mg.min_selections) AS min_selections,
    COALESCE(mga.max_selections, mg.max_selections) AS max_selections,

    mga.step_order,
    COALESCE(mga.display_order, mg.display_order, 0) AS display_order,

    -- Scope of assignment
    CASE
        WHEN mga.dish_id IS NOT NULL THEN 'dish'
        WHEN mga.course_id IS NOT NULL THEN 'course'
        ELSE 'restaurant'
    END AS assignment_scope

FROM menuca_v3.dishes d
JOIN menuca_v3.modifier_group_assignments mga ON (
    (mga.dish_id = d.id) OR
    (mga.course_id = d.course_id AND mga.dish_id IS NULL) OR
    (mga.restaurant_id = d.restaurant_id AND mga.course_id IS NULL AND mga.dish_id IS NULL)
)
JOIN menuca_v3.modifier_groups mg ON mga.group_id = mg.id

WHERE d.is_active = TRUE
  AND mga.is_active = TRUE
  AND mg.is_active = TRUE

ORDER BY
    d.id,
    mga.group_id,
    -- Precedence: dish > course > restaurant
    CASE
        WHEN mga.dish_id IS NOT NULL THEN 1
        WHEN mga.course_id IS NOT NULL THEN 2
        ELSE 3
    END;

COMMENT ON VIEW menuca_v3.vw_dish_modifier_groups IS 'Resolved modifier groups per dish (handles inheritance precedence)';

-- ============================================================
-- 7. VALIDATION FUNCTION: Check if configuration is valid
-- ============================================================
CREATE OR REPLACE FUNCTION menuca_v3.validate_dish_configuration(
    p_dish_id BIGINT,
    p_selected_options JSONB -- Format: [{"group_id": 1, "option_ids": [2, 3]}, ...]
) RETURNS TABLE(is_valid BOOLEAN, errors JSONB) AS $$
DECLARE
    v_group RECORD;
    v_group_selection JSONB;
    v_selected_count INTEGER;
    v_errors JSONB := '[]'::JSONB;
BEGIN
    -- Check each required group
    FOR v_group IN
        SELECT * FROM menuca_v3.vw_dish_modifier_groups
        WHERE dish_id = p_dish_id
    LOOP
        -- Find this group's selection in input
        SELECT value INTO v_group_selection
        FROM jsonb_array_elements(p_selected_options)
        WHERE value->>'group_id' = v_group.group_id::TEXT;

        IF v_group_selection IS NULL THEN
            v_selected_count := 0;
        ELSE
            v_selected_count := jsonb_array_length(v_group_selection->'option_ids');
        END IF;

        -- Validate min selections
        IF v_selected_count < v_group.min_selections THEN
            v_errors := v_errors || jsonb_build_object(
                'group_id', v_group.group_id,
                'group_name', v_group.group_name,
                'error', format('Must select at least %s option(s)', v_group.min_selections)
            );
        END IF;

        -- Validate max selections
        IF v_group.max_selections IS NOT NULL AND v_selected_count > v_group.max_selections THEN
            v_errors := v_errors || jsonb_build_object(
                'group_id', v_group.group_id,
                'group_name', v_group.group_name,
                'error', format('Cannot select more than %s option(s)', v_group.max_selections)
            );
        END IF;
    END LOOP;

    RETURN QUERY SELECT (jsonb_array_length(v_errors) = 0), v_errors;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION menuca_v3.validate_dish_configuration IS 'Validates a set of selected modifier options against group rules';

-- ============================================================
-- 8. AUDIT TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION menuca_v3.update_modifier_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_modifier_groups_updated_at
    BEFORE UPDATE ON menuca_v3.modifier_groups
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_modifier_timestamp();

CREATE TRIGGER trg_modifier_options_updated_at
    BEFORE UPDATE ON menuca_v3.modifier_options
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_modifier_timestamp();

CREATE TRIGGER trg_modifier_assignments_updated_at
    BEFORE UPDATE ON menuca_v3.modifier_group_assignments
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_modifier_timestamp();

-- ============================================================
-- 9. GRANT PERMISSIONS (adjust as needed)
-- ============================================================
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA menuca_v3 TO authenticated;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA menuca_v3 TO authenticated;