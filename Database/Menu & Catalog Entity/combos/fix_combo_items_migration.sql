-- ============================================================================
-- MenuCA V3 - Combo Items Migration Fix
-- ============================================================================
-- Purpose: Fix orphaned combo_groups by migrating V1 combos junction table
-- Author: Brian Lapp, Santiago
-- Date: October 10, 2025
-- Problem: 8,218 out of 8,234 combo_groups have NO items linked
-- Root Cause: V1 combos table wasn't migrated to combo_items
-- ============================================================================

-- IMPORTANT: Run this AFTER creating staging tables with V1 combos data
-- Prerequisite: Load menuca_v1_combos_postgres.sql into staging schema

BEGIN;

-- ============================================================================
-- STEP 1: VERIFY PRE-CONDITIONS
-- ============================================================================

DO $$
DECLARE
  v_current_combo_items INT;
  v_combo_groups_with_items INT;
  v_orphaned_groups INT;
BEGIN
  -- Check current state
  SELECT COUNT(*) INTO v_current_combo_items FROM menuca_v3.combo_items;
  SELECT COUNT(DISTINCT combo_group_id) INTO v_combo_groups_with_items FROM menuca_v3.combo_items;
  v_orphaned_groups := (SELECT COUNT(*) FROM menuca_v3.combo_groups) - v_combo_groups_with_items;
  
  RAISE NOTICE '=== PRE-MIGRATION STATE ===';
  RAISE NOTICE 'Current combo_items: %', v_current_combo_items;
  RAISE NOTICE 'Combo groups WITH items: %', v_combo_groups_with_items;
  RAISE NOTICE 'Orphaned combo groups: %', v_orphaned_groups;
  RAISE NOTICE '===========================';
  
  IF v_orphaned_groups < 8000 THEN
    RAISE EXCEPTION 'Orphaned groups count (%) seems wrong. Expected ~8,218. Aborting.', v_orphaned_groups;
  END IF;
END $$;

-- ============================================================================
-- STEP 2: CREATE TEMPORARY STAGING TABLE FOR V1 COMBOS
-- ============================================================================

-- Drop if exists from previous runs
DROP TABLE IF EXISTS temp_v1_combos CASCADE;

-- Create temporary table to hold V1 combos data
CREATE TEMPORARY TABLE temp_v1_combos (
  v1_combo_id INT,
  v1_combo_group_id INT,
  v1_menu_id INT,
  step_order INT DEFAULT 0
);

-- ============================================================================
-- STEP 3: LOAD V1 COMBOS DATA
-- ============================================================================

-- NOTE: This assumes you have the menuca_v1_combos_postgres.sql file loaded
-- If not loaded, uncomment and run:
-- \i /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/converted/menuca_v1_combos_postgres.sql

-- Copy data from V1 combos file inserts
-- This is a sample - the full INSERT will come from the SQL file
-- Format: (combo_id, combo_group_id, menu_id, step_order)

COPY temp_v1_combos FROM PROGRAM 
'grep -oP "(?<=INSERT INTO combos VALUES )\(.*?\)" "/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/converted/menuca_v1_combos_postgres.sql" | sed "s/[()]/\n/g" | grep -v "^$"'
WITH (FORMAT csv);

-- Alternative: Parse the INSERT statements directly
-- This method extracts all VALUES from the INSERT statements
INSERT INTO temp_v1_combos (v1_combo_id, v1_combo_group_id, v1_menu_id, step_order)
SELECT 
  (regexp_matches(line, '\((\d+),(\d+),(\d+),(\d+)\)', 'g'))[1]::int,
  (regexp_matches(line, '\((\d+),(\d+),(\d+),(\d+)\)', 'g'))[2]::int,
  (regexp_matches(line, '\((\d+),(\d+),(\d+),(\d+)\)', 'g'))[3]::int,
  (regexp_matches(line, '\((\d+),(\d+),(\d+),(\d+)\)', 'g'))[4]::int
FROM (
  SELECT unnest(string_to_array(
    pg_read_file('/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/converted/menuca_v1_combos_postgres.sql'),
    E'),('
  )) AS line
) subquery
WHERE line ~ '^\d+,\d+,\d+,\d+';

-- ============================================================================
-- STEP 4: VALIDATE STAGING DATA
-- ============================================================================

DO $$
DECLARE
  v_staged_combos INT;
BEGIN
  SELECT COUNT(*) INTO v_staged_combos FROM temp_v1_combos;
  
  RAISE NOTICE '=== STAGING VALIDATION ===';
  RAISE NOTICE 'V1 combos loaded: %', v_staged_combos;
  
  IF v_staged_combos < 1000 THEN
    RAISE WARNING 'Only % V1 combos loaded. Expected ~110,000+. Check data load.', v_staged_combos;
  END IF;
END $$;

-- ============================================================================
-- STEP 5: MAP V1 IDS TO V3 IDS
-- ============================================================================

-- Create mapping table
DROP TABLE IF EXISTS temp_combo_mapping CASCADE;

CREATE TEMPORARY TABLE temp_combo_mapping AS
SELECT DISTINCT
  vc.v1_combo_id,
  vc.v1_combo_group_id,
  vc.v1_menu_id,
  vc.step_order,
  cg.id AS v3_combo_group_id,
  d.id AS v3_dish_id
FROM temp_v1_combos vc
-- Map V1 combo_group_id to V3 combo_group_id
JOIN menuca_v3.combo_groups cg ON cg.legacy_v1_id = vc.v1_combo_group_id
-- Map V1 menu_id to V3 dish_id
JOIN menuca_v3.dishes d ON d.legacy_v1_id = vc.v1_menu_id
WHERE cg.id IS NOT NULL 
  AND d.id IS NOT NULL;

-- Validate mapping
DO $$
DECLARE
  v_mapped_count INT;
  v_unmapped_groups INT;
  v_unmapped_dishes INT;
BEGIN
  SELECT COUNT(*) INTO v_mapped_count FROM temp_combo_mapping;
  
  SELECT COUNT(DISTINCT v1_combo_group_id) INTO v_unmapped_groups
  FROM temp_v1_combos vc
  WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v3.combo_groups cg 
    WHERE cg.legacy_v1_id = vc.v1_combo_group_id
  );
  
  SELECT COUNT(DISTINCT v1_menu_id) INTO v_unmapped_dishes
  FROM temp_v1_combos vc
  WHERE NOT EXISTS (
    SELECT 1 FROM menuca_v3.dishes d 
    WHERE d.legacy_v1_id = vc.v1_menu_id
  );
  
  RAISE NOTICE '=== MAPPING RESULTS ===';
  RAISE NOTICE 'Successfully mapped: %', v_mapped_count;
  RAISE NOTICE 'Unmapped combo groups: %', v_unmapped_groups;
  RAISE NOTICE 'Unmapped dishes: %', v_unmapped_dishes;
  RAISE NOTICE '=======================';
  
  IF v_mapped_count < 1000 THEN
    RAISE EXCEPTION 'Only % combos mapped. Expected many more. Check legacy_v1_id columns.', v_mapped_count;
  END IF;
END $$;

-- ============================================================================
-- STEP 6: INSERT INTO COMBO_ITEMS
-- ============================================================================

-- Insert new combo items (avoiding duplicates if running multiple times)
INSERT INTO menuca_v3.combo_items (
  combo_group_id,
  dish_id,
  quantity,
  is_required,
  display_order,
  source_system,
  source_id,
  created_at
)
SELECT DISTINCT
  cm.v3_combo_group_id,
  cm.v3_dish_id,
  1 AS quantity,  -- Default to 1
  true AS is_required,  -- Default to required
  cm.step_order AS display_order,
  'v1' AS source_system,
  cm.v1_combo_id AS source_id,
  NOW() AS created_at
FROM temp_combo_mapping cm
-- Avoid inserting duplicates
WHERE NOT EXISTS (
  SELECT 1 
  FROM menuca_v3.combo_items existing 
  WHERE existing.combo_group_id = cm.v3_combo_group_id 
    AND existing.dish_id = cm.v3_dish_id
)
ORDER BY cm.v3_combo_group_id, cm.step_order;

-- Get insert count
DO $$
DECLARE
  v_inserted_count INT;
BEGIN
  GET DIAGNOSTICS v_inserted_count = ROW_COUNT;
  RAISE NOTICE '=== INSERTION COMPLETE ===';
  RAISE NOTICE 'New combo_items inserted: %', v_inserted_count;
  RAISE NOTICE '==========================';
END $$;

-- ============================================================================
-- STEP 7: VALIDATE POST-MIGRATION STATE
-- ============================================================================

DO $$
DECLARE
  v_total_combo_items INT;
  v_groups_with_items INT;
  v_orphaned_groups INT;
  v_total_groups INT;
  v_orphan_pct NUMERIC;
BEGIN
  SELECT COUNT(*) INTO v_total_groups FROM menuca_v3.combo_groups;
  SELECT COUNT(*) INTO v_total_combo_items FROM menuca_v3.combo_items;
  SELECT COUNT(DISTINCT combo_group_id) INTO v_groups_with_items FROM menuca_v3.combo_items;
  v_orphaned_groups := v_total_groups - v_groups_with_items;
  v_orphan_pct := (v_orphaned_groups::NUMERIC / v_total_groups::NUMERIC) * 100;
  
  RAISE NOTICE '=== POST-MIGRATION STATE ===';
  RAISE NOTICE 'Total combo_items: %', v_total_combo_items;
  RAISE NOTICE 'Combo groups WITH items: %', v_groups_with_items;
  RAISE NOTICE 'Orphaned combo groups: % (%.2f%%)', v_orphaned_groups, v_orphan_pct;
  RAISE NOTICE '============================';
  
  IF v_orphan_pct > 5.0 THEN
    RAISE WARNING 'Still have %.2f%% orphaned groups! Expected < 5%%. Migration may be incomplete.', v_orphan_pct;
  ELSE
    RAISE NOTICE 'SUCCESS! Orphan rate acceptable: %.2f%%', v_orphan_pct;
  END IF;
END $$;

-- ============================================================================
-- STEP 8: SHOW SAMPLE RESULTS
-- ============================================================================

-- Show some examples of newly created combo items
SELECT 
  cg.id AS combo_group_id,
  cg.name AS combo_name,
  cg.legacy_v1_id,
  COUNT(ci.id) AS item_count,
  string_agg(d.name, ', ' ORDER BY ci.display_order) AS dishes
FROM menuca_v3.combo_groups cg
JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
JOIN menuca_v3.dishes d ON ci.dish_id = d.id
WHERE ci.created_at >= NOW() - INTERVAL '1 minute'  -- Only show newly created
GROUP BY cg.id, cg.name, cg.legacy_v1_id
ORDER BY item_count DESC
LIMIT 10;

-- ============================================================================
-- CLEANUP
-- ============================================================================

DROP TABLE IF EXISTS temp_v1_combos;
DROP TABLE IF EXISTS temp_combo_mapping;

COMMIT;

-- ============================================================================
-- POST-MIGRATION TASKS
-- ============================================================================

-- Update statistics
ANALYZE menuca_v3.combo_items;
ANALYZE menuca_v3.combo_groups;

-- ============================================================================
-- VERIFICATION QUERIES (Run these separately to confirm success)
-- ============================================================================

/*
-- 1. Check orphan rate
SELECT 
  COUNT(*) as total_groups,
  COUNT(DISTINCT ci.combo_group_id) as groups_with_items,
  COUNT(*) - COUNT(DISTINCT ci.combo_group_id) as orphaned_groups,
  ROUND((COUNT(*) - COUNT(DISTINCT ci.combo_group_id))::numeric / COUNT(*)::numeric * 100, 2) as orphan_pct
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id;

-- 2. Check expected item counts match actual
SELECT 
  cg.id,
  cg.name,
  cg.combo_rules->>'item_count' as expected,
  COUNT(ci.id) as actual,
  CASE 
    WHEN cg.combo_rules->>'item_count' = COUNT(ci.id)::text THEN 'MATCH'
    ELSE 'MISMATCH'
  END as status
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
WHERE cg.combo_rules->>'item_count' IS NOT NULL
GROUP BY cg.id, cg.name, cg.combo_rules
HAVING cg.combo_rules->>'item_count' != COUNT(ci.id)::text
  OR COUNT(ci.id) = 0
LIMIT 20;

-- 3. Show distribution of items per combo
SELECT 
  item_count,
  COUNT(*) as combo_groups_with_this_count
FROM (
  SELECT 
    cg.id,
    COUNT(ci.id) as item_count
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
  GROUP BY cg.id
) subquery
GROUP BY item_count
ORDER BY item_count;
*/

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

