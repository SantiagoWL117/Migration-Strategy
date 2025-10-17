-- ================================================================
-- Task 1.1: Add Supabase Auth Integration Columns to users
-- ================================================================
-- Duration: 4 hours
-- Purpose: Prepare menuca_v3.users table for Supabase Auth integration
-- ================================================================

BEGIN;

-- Step 1: Add auth_user_id column to link to Supabase Auth
ALTER TABLE menuca_v3.users
    ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(50) DEFAULT 'email',
    ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMPTZ;

-- Step 2: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_auth_user_id 
    ON menuca_v3.users(auth_user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_auth_user_unique 
    ON menuca_v3.users(auth_user_id) 
    WHERE auth_user_id IS NOT NULL;

-- Step 3: Backfill email_verified_at based on existing has_email_verified flag
UPDATE menuca_v3.users
SET email_verified_at = CASE 
    WHEN has_email_verified = true THEN created_at
    ELSE NULL
END
WHERE email_verified_at IS NULL;

-- Step 4: Add helpful comments
COMMENT ON COLUMN menuca_v3.users.auth_user_id IS 
    'Link to auth.users for Supabase Auth integration. NULL only for pre-migration users.';

COMMENT ON COLUMN menuca_v3.users.auth_provider IS 
    'Authentication provider: email, google, apple, facebook';

COMMENT ON COLUMN menuca_v3.users.email_verified_at IS 
    'Timestamp when email was verified. Synced from auth.users.email_confirmed_at';

COMMIT;

-- Verification Query
SELECT 
    'users_table_updated' as status,
    COUNT(*) as total_users,
    COUNT(auth_user_id) as users_with_auth_link,
    COUNT(*) - COUNT(auth_user_id) as users_pending_migration,
    COUNT(email_verified_at) as email_verified_count
FROM menuca_v3.users;

