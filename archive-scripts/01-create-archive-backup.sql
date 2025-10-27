-- ============================================================================
-- Archive Backup: restaurant_admin_users
-- ============================================================================
-- Purpose: Create a complete backup of the legacy restaurant_admin_users table
-- Before: Deleting the original table
-- After: This archive table can be used for audits and rollback if needed
-- ============================================================================

-- Step 1: Create archive table with all data
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_admin_users_archive (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    restaurant_id bigint NOT NULL,
    user_type character varying(1),
    first_name character varying(50),
    last_name character varying(50),
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    last_login_at timestamp with time zone,
    login_count integer,
    is_active boolean NOT NULL,
    sends_statements boolean,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone,
    migrated_to_admin_user_id bigint,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT restaurant_admin_users_archive_pkey PRIMARY KEY (id)
);

-- Step 2: Copy all data from original table
INSERT INTO menuca_v3.restaurant_admin_users_archive
SELECT
    id,
    uuid,
    restaurant_id,
    user_type,
    first_name,
    last_name,
    email,
    password_hash,
    last_login_at,
    login_count,
    is_active,
    sends_statements,
    created_at,
    updated_at,
    migrated_to_admin_user_id,
    now() as archived_at
FROM menuca_v3.restaurant_admin_users
ON CONFLICT (id) DO NOTHING;

-- Step 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_rau_archive_email ON menuca_v3.restaurant_admin_users_archive(email);
CREATE INDEX IF NOT EXISTS idx_rau_archive_restaurant ON menuca_v3.restaurant_admin_users_archive(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_rau_archive_migrated ON menuca_v3.restaurant_admin_users_archive(migrated_to_admin_user_id);

-- Step 4: Add comment to table
COMMENT ON TABLE menuca_v3.restaurant_admin_users_archive IS
'Archive of legacy restaurant_admin_users table. Created before deprecation/deletion. Contains historical login data and migration audit trail.';

-- Step 5: Verify backup
SELECT
    'Archive Complete' as status,
    COUNT(*) as total_archived_records,
    COUNT(DISTINCT email) as unique_emails,
    COUNT(DISTINCT restaurant_id) as unique_restaurants,
    COUNT(migrated_to_admin_user_id) as migrated_count,
    MIN(created_at) as oldest_account,
    MAX(last_login_at) as most_recent_login
FROM menuca_v3.restaurant_admin_users_archive;

-- ============================================================================
-- Archive Created Successfully
-- ============================================================================
