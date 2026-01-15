-- Add indexes to audit log partitions for better query performance
-- Date: January 15, 2026
-- Context: Resolving IO crisis from sequential scans on audit logs

-- 2025_11 partition
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2025_11_created 
ON menuca_v3.audit_log_2025_11 (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2025_11_table_id 
ON menuca_v3.audit_log_2025_11 (table_name, record_id);

-- 2025_12 partition
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2025_12_created 
ON menuca_v3.audit_log_2025_12 (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2025_12_table_id 
ON menuca_v3.audit_log_2025_12 (table_name, record_id);

-- 2026_01 partition (current month - most important)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_01_created 
ON menuca_v3.audit_log_2026_01 (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_01_table_id 
ON menuca_v3.audit_log_2026_01 (table_name, record_id);

-- 2026_02 partition
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_02_created 
ON menuca_v3.audit_log_2026_02 (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_02_table_id 
ON menuca_v3.audit_log_2026_02 (table_name, record_id);

-- 2026_03 partition
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_03_created 
ON menuca_v3.audit_log_2026_03 (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_log_2026_03_table_id 
ON menuca_v3.audit_log_2026_03 (table_name, record_id);
