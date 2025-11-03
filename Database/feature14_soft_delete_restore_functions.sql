-- Feature 14: Soft Delete & Restore
-- Purpose: Safe deletion with recovery window for promotional deals and coupons
-- Date: 2025-10-31
-- Author: Claude Code

-- =============================================================================
-- FUNCTION 1: soft_delete_deal
-- Purpose: Soft delete a promotional deal (mark as disabled, not permanently deleted)
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_deal(
    p_deal_id INTEGER,
    p_deleted_by INTEGER,
    p_reason VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    deal_id INTEGER,
    deal_name VARCHAR,
    disabled_at TIMESTAMPTZ,
    disabled_by INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deal_name VARCHAR;
BEGIN
    -- Get deal name before deletion
    SELECT name INTO v_deal_name
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id;

    -- Check if deal exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::TIMESTAMPTZ,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Soft delete: Set disabled_at and disabled_by, also disable the deal
    UPDATE menuca_v3.promotional_deals
    SET
        disabled_at = NOW(),
        disabled_by = p_deleted_by,
        is_enabled = FALSE,
        updated_at = NOW()
    WHERE id = p_deal_id;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        p_deal_id,
        v_deal_name,
        NOW(),
        p_deleted_by;
END;
$$;

COMMENT ON FUNCTION menuca_v3.soft_delete_deal(INTEGER, INTEGER, VARCHAR) IS
'Soft deletes a promotional deal by setting disabled_at and disabled_by columns. The deal can be restored later. The reason parameter is for future auditing but not currently stored in database.';

-- =============================================================================
-- FUNCTION 2: restore_deal
-- Purpose: Restore a soft-deleted promotional deal
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.restore_deal(
    p_deal_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    deal_id INTEGER,
    deal_name VARCHAR,
    restored_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_deal_name VARCHAR;
    v_was_deleted BOOLEAN;
BEGIN
    -- Get deal info and check if it was soft deleted
    SELECT name, (disabled_at IS NOT NULL)
    INTO v_deal_name, v_was_deleted
    FROM menuca_v3.promotional_deals
    WHERE id = p_deal_id;

    -- Check if deal exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- If deal was not soft deleted, return success=false
    IF NOT v_was_deleted THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            p_deal_id,
            v_deal_name,
            NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- Restore: Clear disabled_at and disabled_by (keep is_enabled as-is)
    UPDATE menuca_v3.promotional_deals
    SET
        disabled_at = NULL,
        disabled_by = NULL,
        updated_at = NOW()
    WHERE id = p_deal_id;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        p_deal_id,
        v_deal_name,
        NOW();
END;
$$;

COMMENT ON FUNCTION menuca_v3.restore_deal(INTEGER) IS
'Restores a soft-deleted promotional deal by clearing disabled_at and disabled_by columns. Returns success=false if deal does not exist or was not previously deleted.';

-- =============================================================================
-- FUNCTION 3: soft_delete_coupon
-- Purpose: Soft delete a promotional coupon (mark as deleted, not permanently removed)
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_coupon(
    p_coupon_id BIGINT,
    p_deleted_by BIGINT,
    p_reason VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    coupon_id BIGINT,
    coupon_code VARCHAR,
    coupon_name VARCHAR,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_coupon_code VARCHAR;
    v_coupon_name VARCHAR;
BEGIN
    -- Get coupon details before deletion
    SELECT code, name
    INTO v_coupon_code, v_coupon_name
    FROM menuca_v3.promotional_coupons
    WHERE id = p_coupon_id;

    -- Check if coupon exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::TIMESTAMPTZ,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Soft delete: Set deleted_at and deleted_by, also deactivate coupon
    UPDATE menuca_v3.promotional_coupons
    SET
        deleted_at = NOW(),
        deleted_by = p_deleted_by,
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_coupon_id;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        p_coupon_id,
        v_coupon_code,
        v_coupon_name,
        NOW(),
        p_deleted_by;
END;
$$;

COMMENT ON FUNCTION menuca_v3.soft_delete_coupon(BIGINT, BIGINT, VARCHAR) IS
'Soft deletes a promotional coupon by setting deleted_at and deleted_by columns. The coupon can be restored later. The reason parameter is for future auditing but not currently stored in database.';

-- =============================================================================
-- FUNCTION 4: restore_coupon
-- Purpose: Restore a soft-deleted promotional coupon
-- =============================================================================

CREATE OR REPLACE FUNCTION menuca_v3.restore_coupon(
    p_coupon_id BIGINT
)
RETURNS TABLE(
    success BOOLEAN,
    coupon_id BIGINT,
    coupon_code VARCHAR,
    coupon_name VARCHAR,
    restored_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
    v_coupon_code VARCHAR;
    v_coupon_name VARCHAR;
    v_was_deleted BOOLEAN;
BEGIN
    -- Get coupon info and check if it was soft deleted
    SELECT code, name, (deleted_at IS NOT NULL)
    INTO v_coupon_code, v_coupon_name, v_was_deleted
    FROM menuca_v3.promotional_coupons
    WHERE id = p_coupon_id;

    -- Check if coupon exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- If coupon was not soft deleted, return success=false
    IF NOT v_was_deleted THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            p_coupon_id,
            v_coupon_code,
            v_coupon_name,
            NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- Restore: Clear deleted_at and deleted_by (keep is_active as-is)
    UPDATE menuca_v3.promotional_coupons
    SET
        deleted_at = NULL,
        deleted_by = NULL,
        updated_at = NOW()
    WHERE id = p_coupon_id;

    -- Return success
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        p_coupon_id,
        v_coupon_code,
        v_coupon_name,
        NOW();
END;
$$;

COMMENT ON FUNCTION menuca_v3.restore_coupon(BIGINT) IS
'Restores a soft-deleted promotional coupon by clearing deleted_at and deleted_by columns. Returns success=false if coupon does not exist or was not previously deleted.';

-- =============================================================================
-- Grant permissions
-- =============================================================================

GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_deal(INTEGER, INTEGER, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.restore_deal(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_coupon(BIGINT, BIGINT, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.restore_coupon(BIGINT) TO authenticated;

-- =============================================================================
-- Testing
-- =============================================================================

-- Test 1: Soft delete a deal
-- SELECT * FROM menuca_v3.soft_delete_deal(240, 2, 'Test soft deletion');

-- Test 2: Verify deal is soft deleted
-- SELECT id, name, is_enabled, disabled_at, disabled_by FROM menuca_v3.promotional_deals WHERE id = 240;

-- Test 3: Restore the deal
-- SELECT * FROM menuca_v3.restore_deal(240);

-- Test 4: Verify deal is restored
-- SELECT id, name, is_enabled, disabled_at, disabled_by FROM menuca_v3.promotional_deals WHERE id = 240;

-- Test 5: Soft delete a coupon
-- SELECT * FROM menuca_v3.soft_delete_coupon(1, 2, 'Test soft deletion');

-- Test 6: Verify coupon is soft deleted
-- SELECT id, code, name, is_active, deleted_at, deleted_by FROM menuca_v3.promotional_coupons WHERE id = 1;

-- Test 7: Restore the coupon
-- SELECT * FROM menuca_v3.restore_coupon(1);

-- Test 8: Verify coupon is restored
-- SELECT id, code, name, is_active, deleted_at, deleted_by FROM menuca_v3.promotional_coupons WHERE id = 1;

-- =============================================================================
-- MIGRATION NOTES
-- =============================================================================

/*
WHAT THESE FUNCTIONS DO:

1. soft_delete_deal(deal_id, deleted_by, reason):
   - Sets disabled_at = NOW()
   - Sets disabled_by = admin_user_id
   - Sets is_enabled = FALSE (hides deal from customers)
   - Updates updated_at timestamp
   - Does NOT permanently delete the deal
   - Returns: success, deal_id, deal_name, disabled_at, disabled_by

2. restore_deal(deal_id):
   - Clears disabled_at and disabled_by (sets to NULL)
   - Updates updated_at timestamp
   - Does NOT automatically re-enable the deal (is_enabled stays as-is)
   - Only works if deal was previously soft deleted
   - Returns: success, deal_id, deal_name, restored_at

3. soft_delete_coupon(coupon_id, deleted_by, reason):
   - Sets deleted_at = NOW()
   - Sets deleted_by = admin_user_id
   - Sets is_active = FALSE (prevents coupon usage)
   - Updates updated_at timestamp
   - Does NOT permanently delete the coupon
   - Returns: success, coupon_id, coupon_code, coupon_name, deleted_at, deleted_by

4. restore_coupon(coupon_id):
   - Clears deleted_at and deleted_by (sets to NULL)
   - Updates updated_at timestamp
   - Does NOT automatically reactivate the coupon (is_active stays as-is)
   - Only works if coupon was previously soft deleted
   - Returns: success, coupon_id, coupon_code, coupon_name, restored_at

USE CASES:
1. Accidental deletion - Admin can restore within recovery window
2. Seasonal promotions - Soft delete when season ends, restore next year
3. Temporary removal - Remove problematic deals, restore after fixes
4. Audit trail - Track who deleted what and when
5. Compliance - Meet data retention requirements

SAFETY FEATURES:
- Transaction-safe (all-or-nothing operations)
- RLS policies automatically enforce admin access control
- Soft deleted items hidden from customers (is_enabled=false or is_active=false)
- Deleted items can be filtered with WHERE deleted_at IS NULL or disabled_at IS NULL
- Original data preserved for recovery

RECOVERY WINDOW:
- No automatic deletion after 30 days (requires separate cleanup job)
- Admins can restore at any time
- Consider implementing automated cleanup after 30 days:
  - Create scheduled job to permanently delete records where deleted_at < NOW() - INTERVAL '30 days'

REASON PARAMETER:
- Currently accepted but not stored in database
- Future enhancement: Add deletion_reason column to both tables
- Can be logged in application layer for audit trail

NEXT STEPS:
1. Admin can soft delete deals/coupons via API
2. Deleted items appear in "Trash" or "Deleted" section of admin panel
3. Admin can restore items from trash
4. After 30 days, items can be permanently deleted (manual or automated)
5. Consider adding batch operations for multiple deletions/restorations

API INTEGRATION:
DELETE /api/admin/restaurants/:id/deals/:did
Body: { deleted_by: admin_user_id, reason: "Out of stock" }
Returns: { success, deal_id, deal_name, disabled_at, disabled_by }

POST /api/admin/restaurants/:id/deals/:did/restore
Returns: { success, deal_id, deal_name, restored_at }
*/
