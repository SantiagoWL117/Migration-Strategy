-- ============================================================================
-- User Preferences Extraction: restaurant_admin_users
-- ============================================================================
-- Purpose: Extract and migrate user preferences that may not exist in new system
-- Focus: sends_statements, user_type, and other preference data
-- ============================================================================

-- Preferences 1: Statement Recipients Overview
-- ============================================================================
-- Identify who should receive financial/order statements
SELECT
    'Statement Recipients Overview' as section,
    COUNT(*) as total_admins,
    COUNT(*) FILTER (WHERE sends_statements = true) as receives_statements,
    COUNT(*) FILTER (WHERE sends_statements = false) as no_statements,
    COUNT(*) FILTER (WHERE sends_statements IS NULL) as not_set,
    ROUND(100.0 * COUNT(*) FILTER (WHERE sends_statements = true) / COUNT(*), 2) as percentage_receiving
FROM menuca_v3.restaurant_admin_users;

-- Preferences 2: Statement Recipients by Restaurant
-- ============================================================================
-- Critical data: who should receive statements for each restaurant
SELECT
    'Statement Recipients by Restaurant' as section,
    rau.restaurant_id,
    r.name as restaurant_name,
    rau.id as legacy_admin_id,
    rau.email,
    rau.first_name,
    rau.last_name,
    rau.sends_statements,
    rau.is_active,
    rau.migrated_to_admin_user_id as new_admin_id,
    au.email as new_email,
    rau.login_count,
    rau.last_login_at
FROM menuca_v3.restaurant_admin_users rau
LEFT JOIN menuca_v3.restaurants r ON rau.restaurant_id = r.id
LEFT JOIN menuca_v3.admin_users au ON rau.migrated_to_admin_user_id = au.id
WHERE rau.sends_statements = true
ORDER BY rau.restaurant_id, rau.email;

-- Preferences 3: Create Preference Mapping Table
-- ============================================================================
-- Permanent table to store legacy preferences for new system reference
CREATE TABLE IF NOT EXISTS menuca_v3.admin_user_preferences (
    id bigserial PRIMARY KEY,
    admin_user_id bigint REFERENCES menuca_v3.admin_users(id) ON DELETE CASCADE,
    restaurant_id bigint REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    receives_statements boolean DEFAULT false,
    legacy_user_type character varying(10),
    legacy_admin_id bigint,
    migrated_from_email character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT unique_admin_restaurant_prefs UNIQUE (admin_user_id, restaurant_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_admin_prefs_admin_user ON menuca_v3.admin_user_preferences(admin_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_prefs_restaurant ON menuca_v3.admin_user_preferences(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_admin_prefs_statements ON menuca_v3.admin_user_preferences(receives_statements) WHERE receives_statements = true;

-- Add comment
COMMENT ON TABLE menuca_v3.admin_user_preferences IS
'Stores admin user preferences per restaurant. Migrated from restaurant_admin_users.sends_statements and other legacy preferences.';

-- Preferences 4: Migrate Preference Data
-- ============================================================================
-- Insert preference data into new permanent table
INSERT INTO menuca_v3.admin_user_preferences (
    admin_user_id,
    restaurant_id,
    receives_statements,
    legacy_user_type,
    legacy_admin_id,
    migrated_from_email
)
SELECT
    rau.migrated_to_admin_user_id,
    rau.restaurant_id,
    COALESCE(rau.sends_statements, false) as receives_statements,
    rau.user_type,
    rau.id,
    rau.email
FROM menuca_v3.restaurant_admin_users rau
WHERE rau.migrated_to_admin_user_id IS NOT NULL
ON CONFLICT (admin_user_id, restaurant_id) DO UPDATE SET
    receives_statements = EXCLUDED.receives_statements,
    legacy_user_type = EXCLUDED.legacy_user_type,
    updated_at = now();

-- Preferences 5: Verify Preference Migration
-- ============================================================================
SELECT
    'Preference Migration Verification' as section,
    COUNT(*) as total_preferences_migrated,
    COUNT(*) FILTER (WHERE receives_statements = true) as statement_recipients,
    COUNT(DISTINCT admin_user_id) as unique_admins,
    COUNT(DISTINCT restaurant_id) as unique_restaurants
FROM menuca_v3.admin_user_preferences;

-- Preferences 6: Statement Recipients Report
-- ============================================================================
-- Generate report of who should receive statements (for email configuration)
SELECT
    'Statement Recipients Report' as section,
    r.id as restaurant_id,
    r.name as restaurant_name,
    r.slug as restaurant_slug,
    au.id as admin_id,
    au.email as admin_email,
    CONCAT_WS(' ', au.first_name, au.last_name) as admin_name,
    aup.receives_statements,
    au.is_active as admin_active,
    au.status as admin_status,
    r.deleted_at IS NULL as restaurant_active
FROM menuca_v3.admin_user_preferences aup
JOIN menuca_v3.admin_users au ON aup.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON aup.restaurant_id = r.id
WHERE aup.receives_statements = true
    AND au.deleted_at IS NULL
    AND au.status = 'active'
    AND r.deleted_at IS NULL
ORDER BY r.name, au.email;

-- Preferences 7: User Type Distribution
-- ============================================================================
SELECT
    'User Type Distribution' as section,
    legacy_user_type,
    COUNT(*) as count,
    COUNT(*) FILTER (WHERE receives_statements = true) as statement_recipients,
    array_agg(DISTINCT admin_user_id) as admin_user_ids
FROM menuca_v3.admin_user_preferences
GROUP BY legacy_user_type
ORDER BY count DESC;

-- Preferences 8: Multi-Restaurant Statement Recipients
-- ============================================================================
-- Admins who receive statements for multiple restaurants
SELECT
    'Multi-Restaurant Statement Recipients' as section,
    au.id as admin_id,
    au.email,
    CONCAT_WS(' ', au.first_name, au.last_name) as name,
    COUNT(*) as restaurant_count,
    array_agg(r.name ORDER BY r.name) as restaurant_names,
    array_agg(aup.restaurant_id ORDER BY r.name) as restaurant_ids
FROM menuca_v3.admin_user_preferences aup
JOIN menuca_v3.admin_users au ON aup.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON aup.restaurant_id = r.id
WHERE aup.receives_statements = true
GROUP BY au.id, au.email, au.first_name, au.last_name
HAVING COUNT(*) > 1
ORDER BY restaurant_count DESC, au.email;

-- Preferences 9: Orphaned Preferences Check
-- ============================================================================
-- Check for preferences without valid admin or restaurant
SELECT
    'Orphaned Preferences Check' as section,
    COUNT(*) FILTER (WHERE au.id IS NULL) as invalid_admin_user,
    COUNT(*) FILTER (WHERE r.id IS NULL) as invalid_restaurant,
    COUNT(*) FILTER (WHERE au.deleted_at IS NOT NULL) as deleted_admin,
    COUNT(*) FILTER (WHERE r.deleted_at IS NOT NULL) as deleted_restaurant
FROM menuca_v3.admin_user_preferences aup
LEFT JOIN menuca_v3.admin_users au ON aup.admin_user_id = au.id
LEFT JOIN menuca_v3.restaurants r ON aup.restaurant_id = r.id;

-- Preferences 10: Export Statement Recipients for Email System
-- ============================================================================
-- Format for easy import into email notification system
SELECT
    'Email System Export' as export_type,
    json_build_object(
        'restaurant_id', r.id,
        'restaurant_name', r.name,
        'restaurant_slug', r.slug,
        'statement_recipients', json_agg(
            json_build_object(
                'admin_id', au.id,
                'email', au.email,
                'name', CONCAT_WS(' ', au.first_name, au.last_name),
                'legacy_admin_id', aup.legacy_admin_id
            ) ORDER BY au.email
        )
    ) as restaurant_statement_config
FROM menuca_v3.admin_user_preferences aup
JOIN menuca_v3.admin_users au ON aup.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON aup.restaurant_id = r.id
WHERE aup.receives_statements = true
    AND au.deleted_at IS NULL
    AND au.status = 'active'
    AND r.deleted_at IS NULL
GROUP BY r.id, r.name, r.slug
ORDER BY r.name;

-- ============================================================================
-- User Preferences Extraction Complete
-- ============================================================================
-- Next Steps:
-- 1. Review statement recipients report
-- 2. Update email notification configuration
-- 3. Verify admin_user_preferences table is being used by application
-- 4. Test statement delivery with new system
-- ============================================================================
