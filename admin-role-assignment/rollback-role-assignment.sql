-- ============================================================================
-- ROLLBACK SCRIPT: Admin Role Assignment
-- ============================================================================
-- Purpose: Restore admin_users.role_id to NULL if needed
-- Date: 2025-10-27
-- Action: Assigned role_id = 5 (Restaurant Manager) to 516 admins
-- ============================================================================

-- ROLLBACK: Set role_id back to NULL for affected admins
-- (Excludes brian+1@worklocal.ca who should keep Super Admin role)

UPDATE menuca_v3.admin_users
SET role_id = NULL
WHERE role_id = 5  -- Restaurant Manager
AND email != 'brian+1@worklocal.ca'  -- Don't affect Super Admin
AND deleted_at IS NULL;

-- Verify rollback
SELECT
    'Rollback Complete' as status,
    COUNT(*) FILTER (WHERE role_id IS NULL) as nulled_roles,
    COUNT(*) FILTER (WHERE role_id = 5) as still_has_role_5,
    COUNT(*) FILTER (WHERE role_id = 1) as super_admin_count
FROM menuca_v3.admin_users
WHERE deleted_at IS NULL;

-- ============================================================================
-- End Rollback Script
-- ============================================================================
