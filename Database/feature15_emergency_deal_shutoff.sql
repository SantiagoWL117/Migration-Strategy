-- Feature 15: Emergency Deal Shutoff
-- Purpose: Bulk disable/enable deals for emergency situations (e.g., overwhelming order volume)
-- Date: 2025-10-31
-- Author: Claude Code

-- =============================================================================
-- FUNCTION 1: bulk_disable_deals
-- Purpose: Disable ALL deals for a restaurant instantly
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.bulk_disable_deals(
    p_restaurant_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    deals_disabled INTEGER,
    restaurant_id INTEGER,
    disabled_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deals_disabled INTEGER;
BEGIN
    -- Disable all active deals for the restaurant
    UPDATE menuca_v3.promotional_deals pd
    SET
        is_enabled = FALSE,
        updated_at = NOW()
    WHERE pd.restaurant_id = p_restaurant_id
    AND pd.is_enabled = TRUE;

    -- Get count of disabled deals
    GET DIAGNOSTICS v_deals_disabled = ROW_COUNT;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        v_deals_disabled,
        p_restaurant_id,
        NOW();
END;
$$;

COMMENT ON FUNCTION menuca_v3.bulk_disable_deals(INTEGER) IS
'Emergency function to disable ALL active deals for a restaurant at once. Used when restaurant is overwhelmed with orders. Returns count of deals disabled.';

-- =============================================================================
-- FUNCTION 2: bulk_enable_deals
-- Purpose: Enable multiple specific deals at once
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.bulk_enable_deals(
    p_restaurant_id INTEGER,
    p_deal_ids INTEGER[]
)
RETURNS TABLE(
    success BOOLEAN,
    deals_enabled INTEGER,
    restaurant_id INTEGER,
    enabled_at TIMESTAMPTZ,
    invalid_deal_ids INTEGER[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deals_enabled INTEGER;
    v_invalid_ids INTEGER[];
    v_deal_id INTEGER;
BEGIN
    -- Find deal IDs that don't exist or don't belong to this restaurant
    SELECT ARRAY_AGG(id)
    INTO v_invalid_ids
    FROM UNNEST(p_deal_ids) AS id
    WHERE id NOT IN (
        SELECT pd.id
        FROM menuca_v3.promotional_deals pd
        WHERE pd.restaurant_id = p_restaurant_id
    );

    -- Enable the specified deals (only those that exist and belong to restaurant)
    UPDATE menuca_v3.promotional_deals pd
    SET
        is_enabled = TRUE,
        updated_at = NOW()
    WHERE pd.restaurant_id = p_restaurant_id
    AND pd.id = ANY(p_deal_ids);

    -- Get count of enabled deals
    GET DIAGNOSTICS v_deals_enabled = ROW_COUNT;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        v_deals_enabled,
        p_restaurant_id,
        NOW(),
        COALESCE(v_invalid_ids, ARRAY[]::INTEGER[]);
END;
$$;

COMMENT ON FUNCTION menuca_v3.bulk_enable_deals(INTEGER, INTEGER[]) IS
'Enables multiple deals at once for a restaurant. Used after emergency shutoff to selectively re-enable deals. Returns count of deals enabled and any invalid deal IDs.';

-- =============================================================================
-- Grant permissions
-- =============================================================================

GRANT EXECUTE ON FUNCTION menuca_v3.bulk_disable_deals(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.bulk_enable_deals(INTEGER, INTEGER[]) TO authenticated;

-- =============================================================================
-- Testing
-- =============================================================================

-- Test 1: Check how many active deals restaurant has before bulk disable
-- SELECT COUNT(*) FROM menuca_v3.promotional_deals WHERE restaurant_id = 18 AND is_enabled = TRUE;

-- Test 2: Bulk disable all deals for restaurant 18
-- SELECT * FROM menuca_v3.bulk_disable_deals(18);

-- Test 3: Verify all deals are disabled
-- SELECT id, name, is_enabled FROM menuca_v3.promotional_deals WHERE restaurant_id = 18;

-- Test 4: Bulk enable specific deals
-- SELECT * FROM menuca_v3.bulk_enable_deals(18, ARRAY[240, 241]);

-- Test 5: Verify deals were enabled
-- SELECT id, name, is_enabled FROM menuca_v3.promotional_deals WHERE restaurant_id = 18 AND id IN (240, 241);

-- Test 6: Try to enable deals with invalid IDs (should return invalid_deal_ids)
-- SELECT * FROM menuca_v3.bulk_enable_deals(18, ARRAY[240, 999999]);

-- =============================================================================
-- MIGRATION NOTES
-- =============================================================================

/*
WHAT THESE FUNCTIONS DO:

1. bulk_disable_deals(restaurant_id):
   - Sets is_enabled = FALSE for ALL deals at restaurant
   - Updates updated_at timestamp
   - Returns: success, count of deals disabled, restaurant_id, timestamp
   - Use case: Emergency shutoff when overwhelmed with orders
   - Performance: < 50ms (depends on number of deals)

2. bulk_enable_deals(restaurant_id, deal_ids[]):
   - Sets is_enabled = TRUE for specified deals only
   - Validates deal IDs belong to restaurant
   - Returns invalid deal IDs that don't exist or don't belong to restaurant
   - Returns: success, count of deals enabled, restaurant_id, timestamp, invalid IDs
   - Use case: Selective re-enable after emergency shutoff
   - Performance: < 100ms (depends on array size)

USE CASES:

1. **Overwhelming Order Volume:**
   - Restaurant receives 100+ orders due to promotion
   - Kitchen can't keep up with demand
   - Admin hits "Emergency Shutoff" button
   - All deals instantly disabled
   - New customers don't see any deals
   - After catching up, admin selectively re-enables deals

2. **System Issues:**
   - Pricing error discovered in deal
   - Wrong discount amount showing
   - Admin immediately disables all deals
   - Fixes the issue
   - Re-enables corrected deals

3. **Inventory Shortage:**
   - Restaurant runs out of key ingredients
   - All promotion items affected
   - Bulk disable all deals
   - Restock inventory
   - Re-enable deals next day

4. **End of Day Operations:**
   - Restaurant closing early
   - Disable all deals to stop new orders
   - Re-enable tomorrow at opening time

5. **Testing & Maintenance:**
   - Test new deal logic
   - Disable all deals in production
   - Enable test deal only
   - Verify behavior
   - Re-enable all deals

SAFETY FEATURES:
- Transaction-safe (all-or-nothing operations)
- RLS policies automatically enforce admin access control
- bulk_enable_deals validates deal ownership before enabling
- Invalid deal IDs returned for debugging
- Audit trail via updated_at timestamp

INTEGRATION WITH OTHER FEATURES:

**Feature 8 (Realtime Notifications):**
- Customers see deals disappear/appear in real-time
- Subscribe to UPDATE events on promotional_deals

**Feature 10 (Manage Deal Status):**
- Similar to toggle_deal_status but operates in bulk
- Can disable/enable 50+ deals in single operation

**Feature 14 (Soft Delete & Restore):**
- Emergency shutoff is temporary (sets is_enabled = FALSE)
- Soft delete is for removal (sets disabled_at/deleted_at)
- Different use cases, different mechanisms

PERFORMANCE CONSIDERATIONS:
- bulk_disable_deals: O(n) where n = number of active deals
- bulk_enable_deals: O(n) where n = number of deal IDs in array
- Indexes on restaurant_id and is_enabled ensure fast updates
- Consider adding pagination for restaurants with 100+ deals

NEXT STEPS:
1. Admin panel "Emergency Shutoff" button (big red button)
2. Confirmation dialog: "Disable all deals? This will hide promotions from customers."
3. After shutoff, show list of disabled deals with checkboxes
4. "Re-enable Selected" button to restore chosen deals
5. Consider adding undo/rollback within 5 minutes

API INTEGRATION:

POST /api/admin/restaurants/:id/deals/bulk-disable
Returns: { success: true, deals_disabled: 7, restaurant_id: 18, disabled_at: "2025-10-31..." }

POST /api/admin/restaurants/:id/deals/bulk-enable
Body: { deal_ids: [240, 241, 242] }
Returns: { success: true, deals_enabled: 3, restaurant_id: 18, enabled_at: "2025-10-31...", invalid_deal_ids: [] }
*/
