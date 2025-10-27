-- ============================================================================
-- MASTER EXECUTION SCRIPT
-- Restaurant Admin Users Archive & Extraction
-- ============================================================================
--
-- Purpose: Complete archive and extraction of restaurant_admin_users table
-- Before: Deprecating/deleting the legacy table
-- After: All data preserved, analyzed, and migrated
--
-- ⚠️  IMPORTANT: Review output of each section before proceeding to deletion
--
-- Execution Time: ~2-5 minutes depending on data volume
-- ============================================================================

\echo '============================================================================'
\echo 'RESTAURANT ADMIN USERS ARCHIVE & EXTRACTION'
\echo '============================================================================'
\echo ''
\echo 'This script will:'
\echo '  1. Create archive backup table'
\echo '  2. Run migration audit reports'
\echo '  3. Extract historical analytics'
\echo '  4. Migrate user preferences'
\echo ''
\echo 'Starting in 3 seconds...'
\echo ''

-- Set display settings for better output
\timing on
\x auto

-- ============================================================================
-- PHASE 1: CREATE ARCHIVE BACKUP
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'PHASE 1: Creating Archive Backup'
\echo '============================================================================'
\echo ''
\i '01-create-archive-backup.sql'

\echo ''
\echo '✓ Phase 1 Complete: Archive table created'
\echo ''
\prompt 'Press Enter to continue to Phase 2 (Migration Audit)...' continue

-- ============================================================================
-- PHASE 2: MIGRATION AUDIT REPORT
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'PHASE 2: Running Migration Audit Reports'
\echo '============================================================================'
\echo ''
\i '02-migration-audit-report.sql'

\echo ''
\echo '✓ Phase 2 Complete: Audit reports generated'
\echo ''
\prompt 'Press Enter to continue to Phase 3 (Historical Analytics)...' continue

-- ============================================================================
-- PHASE 3: HISTORICAL ANALYTICS
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'PHASE 3: Extracting Historical Analytics'
\echo '============================================================================'
\echo ''
\i '03-historical-analytics.sql'

\echo ''
\echo '✓ Phase 3 Complete: Analytics extracted and saved'
\echo ''
\prompt 'Press Enter to continue to Phase 4 (User Preferences)...' continue

-- ============================================================================
-- PHASE 4: USER PREFERENCES EXTRACTION
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'PHASE 4: Extracting and Migrating User Preferences'
\echo '============================================================================'
\echo ''
\i '04-user-preferences-extraction.sql'

\echo ''
\echo '✓ Phase 4 Complete: Preferences migrated to new table'
\echo ''

-- ============================================================================
-- FINAL VERIFICATION
-- ============================================================================
\echo ''
\echo '============================================================================'
\echo 'FINAL VERIFICATION'
\echo '============================================================================'
\echo ''

SELECT
    '✓ Archive Table' as verification_item,
    COUNT(*) as record_count,
    'restaurant_admin_users_archive' as table_name
FROM menuca_v3.restaurant_admin_users_archive
UNION ALL
SELECT
    '✓ Analytics Snapshot' as verification_item,
    COUNT(*) as record_count,
    'restaurant_admin_users_analytics' as table_name
FROM menuca_v3.restaurant_admin_users_analytics
UNION ALL
SELECT
    '✓ User Preferences' as verification_item,
    COUNT(*) as record_count,
    'admin_user_preferences' as table_name
FROM menuca_v3.admin_user_preferences
UNION ALL
SELECT
    '✓ Original Table' as verification_item,
    COUNT(*) as record_count,
    'restaurant_admin_users' as table_name
FROM menuca_v3.restaurant_admin_users;

\echo ''
\echo '============================================================================'
\echo 'ARCHIVE & EXTRACTION COMPLETE'
\echo '============================================================================'
\echo ''
\echo 'Summary of Created Tables:'
\echo '  • restaurant_admin_users_archive    - Complete backup'
\echo '  • restaurant_admin_users_analytics  - Historical metrics snapshot'
\echo '  • admin_user_preferences            - Migrated preference data'
\echo ''
\echo 'Review the output above for any issues or warnings.'
\echo ''
\echo '============================================================================'
\echo 'NEXT STEPS'
\echo '============================================================================'
\echo ''
\echo '1. Review all audit reports for migration issues'
\echo '2. Verify statement recipients are correctly migrated'
\echo '3. Update application to use admin_user_preferences table'
\echo '4. Test email notifications with new preference system'
\echo '5. WAIT 1-3 months to ensure no issues'
\echo ''
\echo 'After verification period:'
\echo '  • Run: 05-deprecate-table.sql     (rename table)'
\echo '  • Run: 06-final-deletion.sql      (after 6+ months)'
\echo ''
\echo '⚠️  DO NOT delete restaurant_admin_users yet!'
\echo '   Keep it for at least 1-3 months as safety backup.'
\echo ''
\echo '============================================================================'

\timing off
