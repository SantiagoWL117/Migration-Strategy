-- Migration: Add promotional_deal_id column to orders table
-- Purpose: Enable tracking of which promotional deal was applied to each order
-- Feature: Marketing & Promotions - Feature 11 (View Deal Performance)
-- Date: 2025-10-30
-- Author: Claude Code

-- =============================================================================
-- STEP 1: Add promotional_deal_id column to orders table
-- =============================================================================

ALTER TABLE menuca_v3.orders
ADD COLUMN promotional_deal_id BIGINT;

-- Add comment
COMMENT ON COLUMN menuca_v3.orders.promotional_deal_id IS
'Foreign key to promotional_deals.id. Tracks which promotional deal was applied to this order. NULL if no deal was used or if a coupon was used instead. If the referenced deal is deleted, this is automatically set to NULL to preserve order history.';

-- =============================================================================
-- STEP 2: Add foreign key constraint with ON DELETE SET NULL
-- =============================================================================

ALTER TABLE menuca_v3.orders
ADD CONSTRAINT fk_orders_promotional_deal_id
FOREIGN KEY (promotional_deal_id)
REFERENCES menuca_v3.promotional_deals(id)
ON DELETE SET NULL;

-- =============================================================================
-- STEP 3: Create index for query performance
-- =============================================================================

CREATE INDEX idx_orders_promotional_deal_id
ON menuca_v3.orders(promotional_deal_id)
WHERE promotional_deal_id IS NOT NULL;  -- Partial index (only non-NULL values)

-- =============================================================================
-- STEP 4: Verify migration
-- =============================================================================

-- Check column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'orders'
AND column_name = 'promotional_deal_id';

-- Check foreign key constraint was created
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
    ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'menuca_v3'
AND tc.table_name = 'orders'
AND kcu.column_name = 'promotional_deal_id';

-- Check index was created
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
AND tablename = 'orders'
AND indexname = 'idx_orders_promotional_deal_id';

-- =============================================================================
-- MIGRATION NOTES
-- =============================================================================

/*
WHAT THIS MIGRATION DOES:
- Adds promotional_deal_id column to orders table (nullable, default NULL)
- Creates FK constraint to promotional_deals(id) with ON DELETE SET NULL
- Creates partial index on promotional_deal_id for query performance
- Preserves all existing orders (new column is NULL for historical orders)

IMPACT:
- Zero downtime: Column is nullable, existing orders unaffected
- Existing orders will have promotional_deal_id = NULL (historical data)
- New orders can track which deal was applied
- If a deal is deleted, orders preserve history but promotional_deal_id becomes NULL

ROLLBACK (if needed):
  DROP INDEX IF EXISTS menuca_v3.idx_orders_promotional_deal_id;
  ALTER TABLE menuca_v3.orders DROP CONSTRAINT IF EXISTS fk_orders_promotional_deal_id;
  ALTER TABLE menuca_v3.orders DROP COLUMN IF EXISTS promotional_deal_id;

NEXT STEPS:
1. Update frontend checkout flow to set promotional_deal_id when creating orders
2. Update get_deal_usage_stats() function to query this column for regular deals
3. Update admin dashboard to display deal performance for all deal types
*/
