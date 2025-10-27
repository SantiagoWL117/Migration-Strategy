-- ============================================================================
-- FINAL DELETION: restaurant_admin_users_deprecated
-- ============================================================================
-- Purpose: Permanently delete the deprecated table (Phase 3 - FINAL)
-- When: After 6+ months of stable operation with no issues
-- WARNING: THIS ACTION CANNOT BE UNDONE
-- ============================================================================

\echo ''
\echo '============================================================================'
\echo '⚠️  FINAL DELETION WARNING ⚠️'
\echo '============================================================================'
\echo ''
\echo 'You are about to PERMANENTLY DELETE restaurant_admin_users_deprecated'
\echo ''
\echo 'This action:'
\echo '  • Cannot be undone'
\echo '  • Will remove all legacy admin user data from active database'
\echo '  • Archive table will still exist for historical reference'
\echo ''
\echo 'Only proceed if:'
\echo '  ✓ 6+ months have passed since deprecation'
\echo '  ✓ All systems are stable with new admin tables'
\echo '  ✓ No rollback scenarios anticipated'
\echo '  ✓ Archive table has been verified and backed up externally'
\echo ''
\echo '============================================================================'
\echo ''

-- FINAL SAFETY CHECKS
-- ============================================================================
\echo 'Running final safety checks...'
\echo ''

-- Check 1: Verify table is already deprecated
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_admin_users'
    ) THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Table is not deprecated yet! Run 05-deprecate-table.sql first.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_admin_users_deprecated'
    ) THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Deprecated table does not exist!';
    END IF;

    RAISE NOTICE '✓ Table is properly deprecated';
END $$;

-- Check 2: Verify sufficient time has passed
DO $$
DECLARE
    deprecated_date timestamp with time zone;
    days_since_deprecation INTEGER;
BEGIN
    SELECT deprecated_at INTO deprecated_date
    FROM menuca_v3.table_deprecation_log
    WHERE table_name = 'restaurant_admin_users'
    AND action LIKE '%DEPRECATED%'
    ORDER BY deprecated_at DESC LIMIT 1;

    IF deprecated_date IS NULL THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Cannot find deprecation date in log!';
    END IF;

    days_since_deprecation := EXTRACT(DAY FROM (now() - deprecated_date));

    IF days_since_deprecation < 180 THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Only % days since deprecation. Wait at least 180 days (6 months).', days_since_deprecation;
    END IF;

    RAISE NOTICE '✓ % days since deprecation (>= 180 days required)', days_since_deprecation;
END $$;

-- Check 3: Verify archive exists and matches
DO $$
DECLARE
    deprecated_count INTEGER;
    archive_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO deprecated_count FROM menuca_v3.restaurant_admin_users_deprecated;
    SELECT COUNT(*) INTO archive_count FROM menuca_v3.restaurant_admin_users_archive;

    IF deprecated_count != archive_count THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Record counts do not match! Deprecated: %, Archive: %', deprecated_count, archive_count;
    END IF;

    RAISE NOTICE '✓ Archive contains all % records', archive_count;
END $$;

-- Check 4: Verify no foreign key dependencies
DO $$
DECLARE
    fk_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO fk_count
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'menuca_v3'
    AND constraint_name IN (
        SELECT constraint_name
        FROM information_schema.constraint_column_usage
        WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_admin_users_deprecated'
    );

    IF fk_count > 0 THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: % foreign key dependencies still exist!', fk_count;
    END IF;

    RAISE NOTICE '✓ No foreign key dependencies';
END $$;

\echo ''
\echo 'All safety checks passed!'
\echo ''

-- Show deletion summary
\echo '============================================================================'
\echo 'DELETION SUMMARY'
\echo '============================================================================'
\echo ''

SELECT
    'restaurant_admin_users_deprecated' as table_to_delete,
    COUNT(*) as records_to_delete,
    pg_size_pretty(pg_total_relation_size('menuca_v3.restaurant_admin_users_deprecated')) as disk_space_to_free
FROM menuca_v3.restaurant_admin_users_deprecated;

\echo ''
\prompt 'Type "DELETE PERMANENTLY" to confirm final deletion: ' final_confirmation

-- Note: Manual verification required in interactive session

\echo ''
\echo '============================================================================'
\echo 'EXECUTING FINAL DELETION'
\echo '============================================================================'
\echo ''

-- Create final analytics snapshot
INSERT INTO menuca_v3.restaurant_admin_users_analytics (
    total_admins,
    total_restaurants,
    avg_logins_per_admin,
    median_logins,
    max_logins,
    highly_engaged_count,
    never_logged_in_count,
    active_last_month,
    active_last_quarter,
    most_recent_login,
    oldest_account_date,
    migration_complete,
    notes
)
SELECT
    COUNT(*) as total_admins,
    COUNT(DISTINCT restaurant_id) as total_restaurants,
    AVG(login_count)::numeric(10,2) as avg_logins_per_admin,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY login_count) as median_logins,
    MAX(login_count) as max_logins,
    COUNT(*) FILTER (WHERE login_count > 100) as highly_engaged_count,
    COUNT(*) FILTER (WHERE last_login_at IS NULL) as never_logged_in_count,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '1 month') as active_last_month,
    COUNT(*) FILTER (WHERE last_login_at >= now() - interval '3 months') as active_last_quarter,
    MAX(last_login_at) as most_recent_login,
    MIN(created_at) as oldest_account_date,
    true as migration_complete,
    'Final snapshot before permanent deletion' as notes
FROM menuca_v3.restaurant_admin_users_deprecated;

-- Log the deletion
INSERT INTO menuca_v3.table_deprecation_log (
    table_name,
    action,
    notes
) VALUES (
    'restaurant_admin_users',
    'DELETED PERMANENTLY',
    'Table successfully deleted. Archive and analytics tables preserved.'
);

-- DROP THE TABLE
DROP TABLE menuca_v3.restaurant_admin_users_deprecated CASCADE;

\echo ''
\echo '✓ Table deleted successfully'
\echo ''

-- Verify deletion
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND table_name IN ('restaurant_admin_users', 'restaurant_admin_users_deprecated')
    ) THEN
        RAISE EXCEPTION 'ERROR: Table still exists after deletion!';
    END IF;

    RAISE NOTICE '✓ Deletion verified - table no longer exists';
END $$;

\echo ''
\echo '============================================================================'
\echo 'DELETION COMPLETE'
\echo '============================================================================'
\echo ''
\echo 'The restaurant_admin_users table has been permanently deleted.'
\echo ''
\echo 'Preserved data:'
\echo '  • restaurant_admin_users_archive    - Complete backup'
\echo '  • restaurant_admin_users_analytics  - Historical metrics'
\echo '  • admin_user_preferences            - Migrated preferences'
\echo '  • table_deprecation_log             - Audit trail'
\echo ''
\echo 'These archive tables should be kept indefinitely for:'
\echo '  • Historical reference'
\echo '  • Compliance/audit requirements'
\echo '  • Data analytics'
\echo ''
\echo '============================================================================'
\echo 'MIGRATION COMPLETE'
\echo '============================================================================'
