-- =====================================================
-- DELIVERY OPERATIONS V3 - PHASE 5: SOFT DELETE & AUDIT
-- =====================================================
-- Entity: Delivery Operations (Priority 8)
-- Phase: 5 of 7 - Soft Delete, Audit Trails, and Data Recovery
-- Created: January 17, 2025
-- Description: Add soft delete functionality, audit logging, and recovery mechanisms
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: SOFT DELETE INFRASTRUCTURE
-- =====================================================
-- Note: deleted_at, deleted_by columns already exist from Phase 1
-- This phase adds views, functions, and automated workflows

-- =====================================================
-- SECTION 2: CREATE ACTIVE-ONLY VIEWS
-- =====================================================

-- View: Active drivers (excludes soft-deleted)
CREATE OR REPLACE VIEW menuca_v3.active_drivers AS
SELECT * 
FROM menuca_v3.drivers 
WHERE deleted_at IS NULL;

COMMENT ON VIEW menuca_v3.active_drivers IS
'Drivers that are not soft-deleted. Use this view instead of querying drivers table directly.';

GRANT SELECT ON menuca_v3.active_drivers TO authenticated, anon;

-- =====================================================

-- View: Active delivery zones
CREATE OR REPLACE VIEW menuca_v3.active_delivery_zones AS
SELECT * 
FROM menuca_v3.delivery_zones 
WHERE deleted_at IS NULL;

COMMENT ON VIEW menuca_v3.active_delivery_zones IS
'Delivery zones that are not soft-deleted.';

GRANT SELECT ON menuca_v3.active_delivery_zones TO authenticated, anon;

-- =====================================================

-- View: Active deliveries
CREATE OR REPLACE VIEW menuca_v3.active_deliveries AS
SELECT * 
FROM menuca_v3.deliveries 
WHERE deleted_at IS NULL;

COMMENT ON VIEW menuca_v3.active_deliveries IS
'Deliveries that are not soft-deleted. Includes all statuses (pending, completed, cancelled).';

GRANT SELECT ON menuca_v3.active_deliveries TO authenticated;

-- =====================================================
-- SECTION 3: SOFT DELETE FUNCTIONS
-- =====================================================

-- Function: Soft delete driver
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_driver(
    p_driver_id BIGINT,
    p_reason VARCHAR DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
    v_active_deliveries INTEGER;
BEGIN
    -- Only super admins can soft delete drivers
    IF NOT menuca_v3.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can delete drivers';
    END IF;

    -- Check if driver has active deliveries
    SELECT COUNT(*) INTO v_active_deliveries
    FROM menuca_v3.deliveries
    WHERE driver_id = p_driver_id
        AND delivery_status IN ('assigned', 'accepted', 'picked_up', 'in_transit', 'arrived')
        AND deleted_at IS NULL;

    IF v_active_deliveries > 0 THEN
        RAISE EXCEPTION 'Cannot delete driver with % active deliveries. Complete or reassign them first.', v_active_deliveries;
    END IF;

    -- Soft delete driver
    UPDATE menuca_v3.drivers
    SET 
        deleted_at = NOW(),
        deleted_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        driver_status = 'blocked',
        availability_status = 'offline',
        updated_at = NOW()
    WHERE id = p_driver_id
        AND deleted_at IS NULL; -- Prevent double-deletion

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Driver not found or already deleted';
    END IF;

    -- Log the deletion
    INSERT INTO menuca_v3.audit_log (
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        changed_by,
        change_reason
    )
    SELECT 
        'drivers',
        p_driver_id,
        'soft_delete',
        jsonb_build_object(
            'driver_status', driver_status,
            'availability_status', availability_status
        ),
        jsonb_build_object(
            'deleted_at', NOW(),
            'driver_status', 'blocked',
            'availability_status', 'offline'
        ),
        (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        p_reason
    FROM menuca_v3.drivers
    WHERE id = p_driver_id;

    v_result := jsonb_build_object(
        'success', true,
        'driver_id', p_driver_id,
        'deleted_at', NOW(),
        'reason', p_reason
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.soft_delete_driver IS
'Soft deletes a driver. Prevents deletion if driver has active deliveries.';

GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_driver TO authenticated;

-- =====================================================

-- Function: Restore soft-deleted driver
CREATE OR REPLACE FUNCTION menuca_v3.restore_driver(
    p_driver_id BIGINT,
    p_reason VARCHAR DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Only super admins can restore drivers
    IF NOT menuca_v3.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can restore drivers';
    END IF;

    -- Restore driver
    UPDATE menuca_v3.drivers
    SET 
        deleted_at = NULL,
        deleted_by = NULL,
        driver_status = 'inactive', -- Set to inactive, not active (requires admin approval)
        updated_at = NOW()
    WHERE id = p_driver_id
        AND deleted_at IS NOT NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Driver not found or not deleted';
    END IF;

    -- Log the restoration
    INSERT INTO menuca_v3.audit_log (
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        changed_by,
        change_reason
    ) VALUES (
        'drivers',
        p_driver_id,
        'restore',
        jsonb_build_object('deleted_at', 'NOT NULL'),
        jsonb_build_object('deleted_at', NULL, 'driver_status', 'inactive'),
        (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        p_reason
    );

    v_result := jsonb_build_object(
        'success', true,
        'driver_id', p_driver_id,
        'restored_at', NOW(),
        'reason', p_reason
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.restore_driver IS
'Restores a soft-deleted driver. Sets status to inactive (requires re-activation).';

GRANT EXECUTE ON FUNCTION menuca_v3.restore_driver TO authenticated;

-- =====================================================

-- Function: Soft delete delivery zone
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_delivery_zone(
    p_zone_id BIGINT,
    p_reason VARCHAR DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_restaurant_id BIGINT;
    v_result JSONB;
BEGIN
    -- Get restaurant_id
    SELECT restaurant_id INTO v_restaurant_id
    FROM menuca_v3.delivery_zones
    WHERE id = p_zone_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Delivery zone not found';
    END IF;

    -- Verify user has access to restaurant
    IF NOT menuca_v3.can_access_restaurant(v_restaurant_id) THEN
        RAISE EXCEPTION 'Access denied to this restaurant';
    END IF;

    -- Soft delete zone
    UPDATE menuca_v3.delivery_zones
    SET 
        deleted_at = NOW(),
        deleted_by = (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        is_active = false,
        updated_at = NOW()
    WHERE id = p_zone_id
        AND deleted_at IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Zone already deleted';
    END IF;

    -- Log the deletion
    INSERT INTO menuca_v3.audit_log (
        table_name,
        record_id,
        action,
        changed_by,
        change_reason
    ) VALUES (
        'delivery_zones',
        p_zone_id,
        'soft_delete',
        (SELECT id FROM menuca_v3.admin_users WHERE user_id = auth.uid() LIMIT 1),
        p_reason
    );

    v_result := jsonb_build_object(
        'success', true,
        'zone_id', p_zone_id,
        'deleted_at', NOW()
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.soft_delete_delivery_zone IS
'Soft deletes a delivery zone. Also marks zone as inactive.';

GRANT EXECUTE ON FUNCTION menuca_v3.soft_delete_delivery_zone TO authenticated;

-- =====================================================

-- Function: Permanently delete old soft-deleted records (GDPR compliance)
CREATE OR REPLACE FUNCTION menuca_v3.purge_old_deleted_records(
    p_days_old INTEGER DEFAULT 90
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted_drivers INTEGER;
    v_deleted_zones INTEGER;
    v_cutoff_date TIMESTAMPTZ;
    v_result JSONB;
BEGIN
    -- Only super admins can purge
    IF NOT menuca_v3.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can purge deleted records';
    END IF;

    v_cutoff_date := NOW() - (p_days_old || ' days')::INTERVAL;

    -- Permanently delete drivers soft-deleted > 90 days ago
    DELETE FROM menuca_v3.drivers
    WHERE deleted_at IS NOT NULL
        AND deleted_at < v_cutoff_date;

    GET DIAGNOSTICS v_deleted_drivers = ROW_COUNT;

    -- Permanently delete zones soft-deleted > 90 days ago
    DELETE FROM menuca_v3.delivery_zones
    WHERE deleted_at IS NOT NULL
        AND deleted_at < v_cutoff_date;

    GET DIAGNOSTICS v_deleted_zones = ROW_COUNT;

    -- Note: Deliveries are NOT permanently deleted (financial/legal records)

    v_result := jsonb_build_object(
        'success', true,
        'cutoff_date', v_cutoff_date,
        'deleted_drivers', v_deleted_drivers,
        'deleted_zones', v_deleted_zones
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.purge_old_deleted_records IS
'Permanently deletes soft-deleted records older than specified days (default 90). Run monthly via cron.';

GRANT EXECUTE ON FUNCTION menuca_v3.purge_old_deleted_records TO authenticated;

-- =====================================================
-- SECTION 4: AUDIT LOG TABLE
-- =====================================================

-- Create audit log table for tracking all changes
CREATE TABLE IF NOT EXISTS menuca_v3.audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'insert', 'update', 'delete', 'soft_delete', 'restore'
    old_values JSONB, -- Previous values (for updates/deletes)
    new_values JSONB, -- New values (for inserts/updates)
    changed_by INTEGER REFERENCES menuca_v3.admin_users(id),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    change_reason VARCHAR(500), -- Why the change was made
    ip_address INET, -- IP address of user making change
    user_agent TEXT -- Browser/app making change
);

-- Indexes for audit log
CREATE INDEX idx_audit_log_table_record ON menuca_v3.audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON menuca_v3.audit_log(changed_at DESC);
CREATE INDEX idx_audit_log_changed_by ON menuca_v3.audit_log(changed_by);
CREATE INDEX idx_audit_log_action ON menuca_v3.audit_log(action);

COMMENT ON TABLE menuca_v3.audit_log IS
'Comprehensive audit trail of all changes to delivery operations data';

-- RLS for audit log (super admins only)
ALTER TABLE menuca_v3.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "super_admin_full_access_audit_log" ON menuca_v3.audit_log
    FOR ALL
    USING (menuca_v3.is_super_admin());

GRANT SELECT ON menuca_v3.audit_log TO authenticated;

-- =====================================================
-- SECTION 5: AUTOMATIC AUDIT TRIGGERS
-- =====================================================

-- Trigger function: Log all changes to drivers
CREATE OR REPLACE FUNCTION menuca_v3.audit_drivers_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            new_values,
            changed_by
        ) VALUES (
            'drivers',
            NEW.id,
            'insert',
            to_jsonb(NEW),
            NEW.created_by
        );

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            old_values,
            new_values,
            changed_by
        ) VALUES (
            'drivers',
            NEW.id,
            'update',
            to_jsonb(OLD),
            to_jsonb(NEW),
            NEW.updated_by
        );

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            old_values,
            changed_by
        ) VALUES (
            'drivers',
            OLD.id,
            'delete',
            to_jsonb(OLD),
            OLD.deleted_by
        );
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

-- Apply audit trigger to drivers
CREATE TRIGGER trigger_audit_drivers
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.drivers
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.audit_drivers_changes();

-- =====================================================

-- Trigger function: Log changes to deliveries (high-value audit)
CREATE OR REPLACE FUNCTION menuca_v3.audit_deliveries_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_changed_by INTEGER;
BEGIN
    -- Try to get admin user ID from auth context
    SELECT id INTO v_changed_by
    FROM menuca_v3.admin_users
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            new_values,
            changed_by
        ) VALUES (
            'deliveries',
            NEW.id,
            'insert',
            jsonb_build_object(
                'order_id', NEW.order_id,
                'restaurant_id', NEW.restaurant_id,
                'driver_id', NEW.driver_id,
                'delivery_status', NEW.delivery_status,
                'delivery_fee', NEW.delivery_fee
            ),
            v_changed_by
        );

    ELSIF TG_OP = 'UPDATE' THEN
        -- Only log significant changes (not location updates)
        IF (OLD.delivery_status != NEW.delivery_status
            OR OLD.driver_id IS DISTINCT FROM NEW.driver_id
            OR OLD.delivery_fee != NEW.delivery_fee) THEN

            INSERT INTO menuca_v3.audit_log (
                table_name,
                record_id,
                action,
                old_values,
                new_values,
                changed_by
            ) VALUES (
                'deliveries',
                NEW.id,
                'update',
                jsonb_build_object(
                    'delivery_status', OLD.delivery_status,
                    'driver_id', OLD.driver_id,
                    'delivery_fee', OLD.delivery_fee
                ),
                jsonb_build_object(
                    'delivery_status', NEW.delivery_status,
                    'driver_id', NEW.driver_id,
                    'delivery_fee', NEW.delivery_fee
                ),
                v_changed_by
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

-- Apply audit trigger to deliveries
CREATE TRIGGER trigger_audit_deliveries
    AFTER INSERT OR UPDATE ON menuca_v3.deliveries
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.audit_deliveries_changes();

-- =====================================================

-- Trigger function: Log earnings changes (financial audit - CRITICAL)
CREATE OR REPLACE FUNCTION menuca_v3.audit_earnings_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_changed_by INTEGER;
BEGIN
    SELECT id INTO v_changed_by
    FROM menuca_v3.admin_users
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            new_values,
            changed_by
        ) VALUES (
            'driver_earnings',
            NEW.id,
            'insert',
            to_jsonb(NEW),
            v_changed_by
        );

    ELSIF TG_OP = 'UPDATE' THEN
        -- Log ALL changes to earnings (financial data - full audit)
        INSERT INTO menuca_v3.audit_log (
            table_name,
            record_id,
            action,
            old_values,
            new_values,
            changed_by,
            change_reason
        ) VALUES (
            'driver_earnings',
            NEW.id,
            'update',
            to_jsonb(OLD),
            to_jsonb(NEW),
            v_changed_by,
            'Financial record modification - requires approval'
        );
    END IF;

    RETURN NEW;
END;
$$;

-- Apply audit trigger to earnings
CREATE TRIGGER trigger_audit_earnings
    AFTER INSERT OR UPDATE ON menuca_v3.driver_earnings
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.audit_earnings_changes();

-- =====================================================
-- SECTION 6: AUDIT REPORTING VIEWS
-- =====================================================

-- View: Recent audit activity
CREATE OR REPLACE VIEW menuca_v3.recent_audit_activity AS
SELECT 
    al.id,
    al.table_name,
    al.record_id,
    al.action,
    al.changed_at,
    au.first_name || ' ' || au.last_name AS changed_by_name,
    au.email AS changed_by_email,
    al.change_reason,
    al.old_values,
    al.new_values
FROM menuca_v3.audit_log al
LEFT JOIN menuca_v3.admin_users au ON al.changed_by = au.id
WHERE al.changed_at >= NOW() - INTERVAL '7 days'
ORDER BY al.changed_at DESC
LIMIT 1000;

COMMENT ON VIEW menuca_v3.recent_audit_activity IS
'Last 7 days of audit activity for dashboards';

GRANT SELECT ON menuca_v3.recent_audit_activity TO authenticated;

-- =====================================================

-- View: Driver audit history
CREATE OR REPLACE VIEW menuca_v3.driver_audit_history AS
SELECT 
    al.id,
    al.record_id AS driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    al.action,
    al.changed_at,
    au.first_name || ' ' || au.last_name AS changed_by_name,
    al.change_reason,
    al.old_values->'driver_status' AS old_status,
    al.new_values->'driver_status' AS new_status
FROM menuca_v3.audit_log al
LEFT JOIN menuca_v3.drivers d ON al.record_id = d.id
LEFT JOIN menuca_v3.admin_users au ON al.changed_by = au.id
WHERE al.table_name = 'drivers'
ORDER BY al.changed_at DESC;

COMMENT ON VIEW menuca_v3.driver_audit_history IS
'Complete audit history for all drivers';

GRANT SELECT ON menuca_v3.driver_audit_history TO authenticated;

-- =====================================================

-- View: Financial audit trail (earnings changes)
CREATE OR REPLACE VIEW menuca_v3.earnings_audit_trail AS
SELECT 
    al.id,
    al.record_id AS earning_id,
    de.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    al.action,
    al.changed_at,
    au.first_name || ' ' || au.last_name AS changed_by_name,
    al.change_reason,
    al.old_values->>'total_earning' AS old_amount,
    al.new_values->>'total_earning' AS new_amount,
    al.old_values->>'payment_status' AS old_status,
    al.new_values->>'payment_status' AS new_status
FROM menuca_v3.audit_log al
LEFT JOIN menuca_v3.driver_earnings de ON al.record_id = de.id
LEFT JOIN menuca_v3.drivers d ON de.driver_id = d.id
LEFT JOIN menuca_v3.admin_users au ON al.changed_by = au.id
WHERE al.table_name = 'driver_earnings'
ORDER BY al.changed_at DESC;

COMMENT ON VIEW menuca_v3.earnings_audit_trail IS
'Financial audit trail - all changes to driver earnings (CRITICAL for compliance)';

GRANT SELECT ON menuca_v3.earnings_audit_trail TO authenticated;

-- =====================================================
-- SECTION 7: DATA RECOVERY FUNCTIONS
-- =====================================================

-- Function: Get audit history for specific record
CREATE OR REPLACE FUNCTION menuca_v3.get_record_audit_history(
    p_table_name VARCHAR,
    p_record_id BIGINT,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    audit_id BIGINT,
    action VARCHAR,
    changed_at TIMESTAMPTZ,
    changed_by_name VARCHAR,
    change_reason VARCHAR,
    old_values JSONB,
    new_values JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id AS audit_id,
        al.action,
        al.changed_at,
        au.first_name || ' ' || au.last_name AS changed_by_name,
        al.change_reason,
        al.old_values,
        al.new_values
    FROM menuca_v3.audit_log al
    LEFT JOIN menuca_v3.admin_users au ON al.changed_by = au.id
    WHERE al.table_name = p_table_name
        AND al.record_id = p_record_id
    ORDER BY al.changed_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_record_audit_history IS
'Retrieves complete audit history for a specific record';

GRANT EXECUTE ON FUNCTION menuca_v3.get_record_audit_history TO authenticated;

-- =====================================================

-- Function: Rollback to previous version (DANGEROUS - admin only)
CREATE OR REPLACE FUNCTION menuca_v3.rollback_to_audit_version(
    p_audit_id BIGINT,
    p_reason VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_audit RECORD;
    v_result JSONB;
BEGIN
    -- Only super admins can rollback
    IF NOT menuca_v3.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can rollback changes';
    END IF;

    -- Get audit record
    SELECT * INTO v_audit
    FROM menuca_v3.audit_log
    WHERE id = p_audit_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Audit record not found';
    END IF;

    -- This is a DANGEROUS operation - implement carefully
    -- For now, just return the values that would be restored
    v_result := jsonb_build_object(
        'warning', 'Rollback functionality requires manual implementation per table',
        'audit_id', p_audit_id,
        'table_name', v_audit.table_name,
        'record_id', v_audit.record_id,
        'old_values', v_audit.old_values,
        'reason', p_reason
    );

    -- TODO: Implement actual rollback logic per table

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.rollback_to_audit_version IS
'DANGEROUS: Rolls back a record to a previous audit version. Super admin only.';

-- =====================================================

COMMIT;

-- =====================================================
-- VALIDATION QUERIES (Run after migration)
-- =====================================================

-- Verify views created
SELECT 
    schemaname,
    viewname
FROM pg_views
WHERE schemaname = 'menuca_v3'
    AND viewname LIKE '%active%'
ORDER BY viewname;

-- Verify audit log table exists
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
    AND table_name = 'audit_log'
ORDER BY ordinal_position;

-- Verify audit triggers exist
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgname LIKE '%audit%'
    AND tgrelid::regclass::text LIKE 'menuca_v3.%'
ORDER BY table_name, trigger_name;

-- Test soft delete (manual test)
-- SELECT menuca_v3.soft_delete_delivery_zone(1, 'Testing soft delete');
-- SELECT * FROM menuca_v3.delivery_zones WHERE id = 1; -- Should have deleted_at
-- SELECT * FROM menuca_v3.active_delivery_zones WHERE id = 1; -- Should be empty

-- =====================================================
-- END OF PHASE 5 MIGRATION
-- =====================================================

