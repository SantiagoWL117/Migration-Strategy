-- =====================================================
-- Admin Audit Log Table Migration
-- =====================================================
-- Purpose: Track all admin user management actions
-- Created: 2025-10-30
-- Related: Admin Edge Functions Enhancement
-- =====================================================

-- Create enum for audit actions
CREATE TYPE menuca_v3.admin_audit_action AS ENUM (
  'create_user',
  'update_user',
  'delete_user',
  'assign_restaurants',
  'remove_restaurants',
  'replace_restaurants',
  'update_role',
  'suspend_user',
  'activate_user',
  'failed_create',
  'failed_update',
  'failed_delete'
);

-- Create admin_audit_log table
CREATE TABLE menuca_v3.admin_audit_log (
  id BIGSERIAL PRIMARY KEY,

  -- Who performed the action
  performed_by_admin_id BIGINT NOT NULL REFERENCES menuca_v3.admin_users(id) ON DELETE CASCADE,
  performed_by_email VARCHAR(255) NOT NULL,

  -- What action was performed
  action menuca_v3.admin_audit_action NOT NULL,

  -- Who was affected
  target_admin_id BIGINT REFERENCES menuca_v3.admin_users(id) ON DELETE SET NULL,
  target_email VARCHAR(255),

  -- Details of the change
  details JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Success or failure
  success BOOLEAN NOT NULL DEFAULT true,
  error_message TEXT,

  -- IP address and user agent (for security)
  ip_address INET,
  user_agent TEXT,

  -- Timestamp
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create indexes for common queries
CREATE INDEX idx_audit_log_performed_by ON menuca_v3.admin_audit_log(performed_by_admin_id);
CREATE INDEX idx_audit_log_target_admin ON menuca_v3.admin_audit_log(target_admin_id);
CREATE INDEX idx_audit_log_action ON menuca_v3.admin_audit_log(action);
CREATE INDEX idx_audit_log_created_at ON menuca_v3.admin_audit_log(created_at DESC);
CREATE INDEX idx_audit_log_success ON menuca_v3.admin_audit_log(success);

-- Create composite index for common query patterns
CREATE INDEX idx_audit_log_performed_action_date ON menuca_v3.admin_audit_log(
  performed_by_admin_id,
  action,
  created_at DESC
);

-- Add comment to table
COMMENT ON TABLE menuca_v3.admin_audit_log IS 'Tracks all admin user management actions for security and compliance';

-- Add comments to columns
COMMENT ON COLUMN menuca_v3.admin_audit_log.performed_by_admin_id IS 'Admin who performed the action';
COMMENT ON COLUMN menuca_v3.admin_audit_log.target_admin_id IS 'Admin who was affected by the action';
COMMENT ON COLUMN menuca_v3.admin_audit_log.details IS 'JSON details of the change (before/after values, restaurant IDs, etc.)';
COMMENT ON COLUMN menuca_v3.admin_audit_log.success IS 'Whether the action succeeded or failed';

-- Grant permissions (adjust as needed for your RLS policies)
-- These permissions assume Edge Functions run with service role
GRANT SELECT, INSERT ON menuca_v3.admin_audit_log TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE menuca_v3.admin_audit_log_id_seq TO authenticated;

-- Create a helper function to log audit events
CREATE OR REPLACE FUNCTION menuca_v3.log_admin_audit(
  p_performed_by_admin_id BIGINT,
  p_performed_by_email VARCHAR(255),
  p_action menuca_v3.admin_audit_action,
  p_target_admin_id BIGINT,
  p_target_email VARCHAR(255),
  p_details JSONB DEFAULT '{}'::jsonb,
  p_success BOOLEAN DEFAULT true,
  p_error_message TEXT DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_log_id BIGINT;
BEGIN
  INSERT INTO menuca_v3.admin_audit_log (
    performed_by_admin_id,
    performed_by_email,
    action,
    target_admin_id,
    target_email,
    details,
    success,
    error_message,
    ip_address,
    user_agent
  ) VALUES (
    p_performed_by_admin_id,
    p_performed_by_email,
    p_action,
    p_target_admin_id,
    p_target_email,
    p_details,
    p_success,
    p_error_message,
    p_ip_address,
    p_user_agent
  )
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

COMMENT ON FUNCTION menuca_v3.log_admin_audit IS 'Helper function to insert audit log entries';

-- =====================================================
-- Example usage:
-- =====================================================
-- SELECT menuca_v3.log_admin_audit(
--   p_performed_by_admin_id := 932,
--   p_performed_by_email := 'santiago@worklocal.ca',
--   p_action := 'create_user',
--   p_target_admin_id := 937,
--   p_target_email := 'newadmin@worklocal.ca',
--   p_details := '{"role_id": 2, "restaurants_assigned": 3}'::jsonb,
--   p_success := true
-- );
