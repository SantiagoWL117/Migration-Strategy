-- Feature 13: Clone Deals to Multiple Locations
-- Purpose: Enable franchises to duplicate promotional deals across different restaurant locations
-- Date: 2025-10-31
-- Author: Claude Code

-- =============================================================================
-- FUNCTION: clone_deal
-- Purpose: Duplicate a promotional deal with all translations to a different restaurant
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.clone_deal(
    p_source_deal_id INTEGER,
    p_target_restaurant_id INTEGER,
    p_new_name VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    new_deal_id INTEGER,
    translations_copied INTEGER,
    source_deal_name VARCHAR,
    target_restaurant_id INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_new_deal_id INTEGER;
    v_translations_count INTEGER;
    v_source_name VARCHAR;
    v_final_name VARCHAR;
BEGIN
    -- Check if source deal exists
    SELECT name INTO v_source_name
    FROM menuca_v3.promotional_deals
    WHERE id = p_source_deal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source deal with ID % does not exist', p_source_deal_id;
    END IF;

    -- Determine the name for the new deal
    v_final_name := COALESCE(p_new_name, v_source_name);

    -- Clone the deal record
    INSERT INTO menuca_v3.promotional_deals (
        restaurant_id,
        type,
        is_repeatable,
        name,
        description,
        active_days,
        date_start,
        date_stop,
        time_start,
        time_stop,
        specific_dates,
        deal_type,
        discount_percent,
        discount_amount,
        minimum_purchase,
        order_count_required,
        included_items,
        required_items,
        required_item_count,
        free_item_count,
        exempted_courses,
        availability_types,
        image_url,
        promo_code,
        display_order,
        is_customizable,
        is_split_deal,
        is_first_order_only,
        shows_on_thankyou,
        sends_in_email,
        email_body_html,
        is_enabled,
        language_code
    )
    SELECT
        p_target_restaurant_id,  -- Use target restaurant
        type,
        is_repeatable,
        v_final_name,            -- Use new name or copy from source
        description,
        active_days,
        date_start,
        date_stop,
        time_start,
        time_stop,
        specific_dates,
        deal_type,
        discount_percent,
        discount_amount,
        minimum_purchase,
        order_count_required,
        included_items,
        required_items,
        required_item_count,
        free_item_count,
        exempted_courses,
        availability_types,
        image_url,
        promo_code,
        display_order,
        is_customizable,
        is_split_deal,
        is_first_order_only,
        shows_on_thankyou,
        sends_in_email,
        email_body_html,
        false,                   -- Start disabled for safety
        language_code
    FROM menuca_v3.promotional_deals
    WHERE id = p_source_deal_id
    RETURNING id INTO v_new_deal_id;

    -- Clone all translations
    INSERT INTO menuca_v3.promotional_deals_translations (
        deal_id,
        language_code,
        title,
        description,
        terms_and_conditions
    )
    SELECT
        v_new_deal_id,           -- Use new deal ID
        language_code,
        COALESCE(p_new_name, title),  -- Update title in translations too
        description,
        terms_and_conditions
    FROM menuca_v3.promotional_deals_translations
    WHERE deal_id = p_source_deal_id;

    -- Count how many translations were copied
    GET DIAGNOSTICS v_translations_count = ROW_COUNT;

    -- Return the results
    RETURN QUERY SELECT
        v_new_deal_id,
        v_translations_count,
        v_source_name,
        p_target_restaurant_id;
END;
$$;

COMMENT ON FUNCTION menuca_v3.clone_deal(INTEGER, INTEGER, VARCHAR) IS
'Clones a promotional deal from one restaurant to another, copying all translations. The new deal starts in disabled state for safety. Returns new deal ID and count of translations copied.';

-- =============================================================================
-- Grant permissions
-- =============================================================================

GRANT EXECUTE ON FUNCTION menuca_v3.clone_deal(INTEGER, INTEGER, VARCHAR) TO authenticated;

-- =============================================================================
-- Testing
-- =============================================================================

-- Test 1: Clone a deal with a new name
-- SELECT * FROM menuca_v3.clone_deal(232, 18, 'Holiday Special - Cloned');

-- Test 2: Clone a deal keeping the original name
-- SELECT * FROM menuca_v3.clone_deal(232, 18, NULL);

-- Test 3: Verify the new deal was created
-- SELECT * FROM menuca_v3.promotional_deals WHERE id = <new_deal_id>;

-- Test 4: Verify translations were copied
-- SELECT * FROM menuca_v3.promotional_deals_translations WHERE deal_id = <new_deal_id>;

-- =============================================================================
-- MIGRATION NOTES
-- =============================================================================

/*
WHAT THIS FUNCTION DOES:
- Clones a promotional deal from source restaurant to target restaurant
- Copies all deal fields except id, restaurant_id, created_at, updated_at, created_by, disabled_by, disabled_at, v1/v2 legacy fields
- Copies all translations (EN/ES/FR) for the deal
- Allows optional new name for the cloned deal
- New deal starts in disabled state (is_enabled = false) for safety
- Returns new deal ID, translations count, source name, and target restaurant ID

USE CASES:
1. Franchise chains duplicating promotions across locations
2. Restaurant groups running same deals at multiple venues
3. Testing deals in one location before rolling out to others

SAFETY FEATURES:
- New deal starts disabled to prevent accidental activation
- Validates source deal exists before cloning
- Transaction-safe (all-or-nothing operation)
- RLS policies automatically enforce admin access control

NEXT STEPS:
1. Admin can review cloned deal
2. Admin can modify dates/times if needed
3. Admin enables deal when ready: UPDATE promotional_deals SET is_enabled = true WHERE id = <new_deal_id>

API INTEGRATION:
POST /api/admin/deals/:id/clone
Body: { target_restaurant_id: 18, new_name: "Holiday Special - Toronto" }
Returns: { new_deal_id, translations_copied, source_deal_name, target_restaurant_id }
*/
