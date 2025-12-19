-- Rollback Script for combo_group_dish_selections insertions
-- Date: 2024-12-17
-- Session: Special combo groups dish_selections population

-- This script deletes all combo_group_dish_selections records inserted during
-- the bulk population task. Records inserted have IDs >= 680.

-- OPTION 1: Delete by ID range (safest - only deletes what we inserted)
-- First record inserted was ID 680 (Centertown - Donair in a Pita Small)
-- Last record inserted was ID 10791

BEGIN;

-- Show what will be deleted
SELECT 
  'Records to be deleted' as action,
  COUNT(*) as count,
  MIN(id) as min_id,
  MAX(id) as max_id
FROM menuca_v3.combo_group_dish_selections
WHERE id >= 680;

-- Delete all records inserted in this session
DELETE FROM menuca_v3.combo_group_dish_selections
WHERE id >= 680;

-- Verify deletion
SELECT 
  'Records remaining' as action,
  COUNT(*) as count
FROM menuca_v3.combo_group_dish_selections;

COMMIT;

-- ============================================================
-- OPTION 2: Delete by specific combo_group_ids (more targeted)
-- Use this if you only want to rollback specific combo groups
-- ============================================================

/*
-- Centertown Donair & Pizza combo groups (35, 37, 38, 40)
DELETE FROM menuca_v3.combo_group_dish_selections
WHERE combo_group_id IN (35, 37, 38, 40)
  AND id >= 680;

-- All special combo groups we populated
DELETE FROM menuca_v3.combo_group_dish_selections
WHERE combo_group_id IN (
  SELECT DISTINCT cg.id
  FROM menuca_v3.combo_groups cg
  WHERE cg.has_special_section = true
    AND cg.special_number_of_items >= 1
    AND cg.deleted_at IS NULL
)
AND id >= 680;
*/

-- ============================================================
-- OPTION 3: Soft delete (set deleted_at instead of hard delete)
-- ============================================================

/*
BEGIN;

UPDATE menuca_v3.combo_group_dish_selections
SET deleted_at = NOW()
WHERE id >= 680
  AND deleted_at IS NULL;

COMMIT;
*/

