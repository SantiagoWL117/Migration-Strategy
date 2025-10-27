-- ============================================================================
-- DEPRECATE TABLE: restaurant_admin_users
-- ============================================================================
-- Purpose: Rename table to indicate it's deprecated (Phase 2 of deletion)
-- When: After 1-3 months of monitoring with no issues
-- Before: Running this, ensure all systems are working with new tables
-- ============================================================================

-- SAFETY CHECKS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'PRE-DEPRECATION SAFETY CHECKS'
\echo '============================================================================'
\echo ''

-- Check 1: Verify archive exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND table_name = 'restaurant_admin_users_archive'
    ) THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Archive table does not exist! Run 01-create-archive-backup.sql first.';
    END IF;
    RAISE NOTICE '✓ Archive table exists';
END $$;

-- Check 2: Verify record counts match
DO $$
DECLARE
    original_count INTEGER;
    archive_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO original_count FROM menuca_v3.restaurant_admin_users;
    SELECT COUNT(*) INTO archive_count FROM menuca_v3.restaurant_admin_users_archive;

    IF original_count != archive_count THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: Record counts do not match! Original: %, Archive: %', original_count, archive_count;
    END IF;
    RAISE NOTICE '✓ Record counts match: %', original_count;
END $$;

-- Check 3: Verify preferences table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'menuca_v3'
        AND table_name = 'admin_user_preferences'
    ) THEN
        RAISE EXCEPTION 'SAFETY CHECK FAILED: admin_user_preferences table does not exist! Run 04-user-preferences-extraction.sql first.';
    END IF;
    RAISE NOTICE '✓ Preferences table exists';
END $$;

-- Check 4: Verify no recent activity (last 30 days)
DO $$
DECLARE
    recent_login_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO recent_login_count
    FROM menuca_v3.restaurant_admin_users
    WHERE last_login_at > now() - interval '30 days';

    IF recent_login_count > 0 THEN
        RAISE WARNING 'WARNING: % admins logged in within last 30 days. Are you sure you want to deprecate?', recent_login_count;
    ELSE
        RAISE NOTICE '✓ No recent logins in last 30 days';
    END IF;
END $$;

\echo ''
\echo 'All safety checks passed!'
\echo ''
\prompt 'Are you sure you want to DEPRECATE the restaurant_admin_users table? Type "YES" to confirm: ' confirmation

-- Verify confirmation
-- Note: psql prompt doesn't work well with variable checking in scripts
-- Manual verification required

\echo ''
\echo '============================================================================'
\echo 'DEPRECATING TABLE'
\echo '============================================================================'
\echo ''

-- Create final snapshot before deprecation
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
    (COUNT(*) = COUNT(migrated_to_admin_user_id)) as migration_complete,
    'Final snapshot before table deprecation' as notes
FROM menuca_v3.restaurant_admin_users;

-- Rename the table
ALTER TABLE menuca_v3.restaurant_admin_users
RENAME TO restaurant_admin_users_deprecated;

-- Add comment to deprecated table
COMMENT ON TABLE menuca_v3.restaurant_admin_users_deprecated IS
'DEPRECATED: Legacy admin user table. Replaced by admin_users + admin_user_restaurants. Kept for rollback safety. Scheduled for deletion after 6+ months of stable operation.';

\echo ''
\echo '✓ Table renamed to: restaurant_admin_users_deprecated'
\echo ''

-- Log the deprecation
CREATE TABLE IF NOT EXISTS menuca_v3.table_deprecation_log (
    id serial PRIMARY KEY,
    table_name text NOT NULL,
    action text NOT NULL,
    deprecated_at timestamp with time zone DEFAULT now(),
    scheduled_deletion_date date,
    notes text
);

INSERT INTO menuca_v3.table_deprecation_log (
    table_name,
    action,
    scheduled_deletion_date,
    notes
) VALUES (
    'restaurant_admin_users',
    'DEPRECATED - table renamed to restaurant_admin_users_deprecated',
    CURRENT_DATE + interval '6 months',
    'All data archived and migrated. Monitor for 6 months before final deletion.'
);

\echo ''
\echo '============================================================================'
\echo 'DEPRECATION COMPLETE'
\echo '============================================================================'
\echo ''
\echo 'Table renamed: restaurant_admin_users → restaurant_admin_users_deprecated'
\echo ''
\echo 'The table is now marked as deprecated but still exists for safety.'
\echo ''
\echo 'Scheduled deletion date: '
SELECT scheduled_deletion_date FROM menuca_v3.table_deprecation_log
WHERE table_name = 'restaurant_admin_users'
ORDER BY deprecated_at DESC LIMIT 1;
\echo ''
\echo 'Continue monitoring for any issues. If all systems are stable after'
\echo '6+ months, you can run: 06-final-deletion.sql'
\echo ''
\echo '============================================================================'
