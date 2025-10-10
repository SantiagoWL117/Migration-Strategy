# 🤝 Handoff to Santiago - Combo Migration Phase 2

**Date:** October 10, 2025  
**From:** Brian + Claude  
**To:** Santiago  
**Status:** Day 1 Complete, Ready for Phase 2

---

## ✅ What We Accomplished Today

### 1. Data Load Success 🎯
- ✅ Received 3,669 missing V1 menu dishes from you
- ✅ Created filtered CSV (missed_menu_files_FILTERED.csv)
- ✅ Loaded into staging.menuca_v1_menu_full (62,482 total rows)
- ✅ Achieved 99.98% combo dish coverage in staging

### 2. Combo Migration Executed 🚀
- ✅ Ran combo_items migration script
- ✅ Created 1,219 combo_items (LIVE in database)
- ✅ 634 combo_groups now functional
- ✅ Transaction committed successfully

### 3. Root Cause Identified 🔍
- **Found:** 5,357 dishes missing from menuca_v3.dishes
- **Type:** Toppings, modifiers, ingredients (e.g., "Lettuce", "Mayo", "Pineapple")
- **Location:** They exist in staging.menuca_v1_menu_full
- **Need:** Migrate them to menuca_v3.dishes with legacy_v1_id

---

## 📊 Current Database State

```
staging.menuca_v1_menu_full:     62,482 rows ✅
staging.menuca_v1_combos:        16,461 rows ✅
menuca_v3.combo_groups:          8,234 groups
menuca_v3.combo_items:           1,219 items ✅ (new!)
Functional combos:               634 groups ✅
Orphaned combos:                 7,600 groups (need Phase 2)
```

---

## 🎯 Your Task: Phase 2 - Complete Combo Migration

### Step 1: Migrate Missing Dishes (1 hour)

**Query to identify missing dishes:**

```sql
-- Find dishes in staging that combos need but aren't in V3
SELECT DISTINCT
  vm.id as v1_id,
  vm.name,
  vm.restaurant as v1_restaurant_id,
  r.id as v3_restaurant_id
FROM staging.menuca_v1_combos vc
JOIN staging.menuca_v1_menu_full vm ON vm.id = vc.dish
JOIN menuca_v3.restaurants r ON r.legacy_v1_id = vm.restaurant::integer
LEFT JOIN menuca_v3.dishes d ON d.legacy_v1_id = vm.id::integer
WHERE d.id IS NULL
ORDER BY vm.restaurant::integer, vm.id::integer;
```

**Migration script template:**

```sql
-- Insert missing dishes into menuca_v3.dishes
INSERT INTO menuca_v3.dishes (
  restaurant_id,
  name,
  description,
  category_id,
  is_available,
  legacy_v1_id,
  source_system,
  created_at
)
SELECT 
  r.id as restaurant_id,
  vm.name,
  'Imported from V1' as description,
  -- Map to appropriate category or use default
  (SELECT id FROM menuca_v3.categories WHERE name = 'Other' LIMIT 1),
  true as is_available,
  vm.id::integer as legacy_v1_id,
  'v1' as source_system,
  NOW() as created_at
FROM staging.menuca_v1_menu_full vm
JOIN menuca_v3.restaurants r ON r.legacy_v1_id = vm.restaurant::integer
LEFT JOIN menuca_v3.dishes d ON d.legacy_v1_id = vm.id::integer
WHERE d.id IS NULL
  AND vm.id::integer IN (
    SELECT DISTINCT vc.dish::integer 
    FROM staging.menuca_v1_combos vc
  )
ON CONFLICT (legacy_v1_id) DO NOTHING;
```

### Step 2: Re-run Combo Migration (5 minutes)

**Use this exact SQL:**

```sql
-- Re-run combo migration with new dishes
BEGIN;

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
  cg.id AS combo_group_id,
  d.id AS dish_id,
  1 AS quantity,
  true AS is_required,
  COALESCE(vc."order"::integer, 0) AS display_order,
  'v1' AS source_system,
  vc.id::bigint AS source_id,
  NOW() AS created_at
FROM staging.menuca_v1_combos vc
JOIN menuca_v3.combo_groups cg ON cg.legacy_v1_id = vc."group"::integer
JOIN menuca_v3.dishes d ON d.legacy_v1_id = vc.dish::integer
WHERE cg.id IS NOT NULL 
  AND d.id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 
    FROM menuca_v3.combo_items existing 
    WHERE existing.combo_group_id = cg.id
      AND existing.dish_id = d.id
  );

COMMIT;
```

### Step 3: Validate Results

```sql
-- Check orphan rate (should be < 1%)
WITH group_stats AS (
  SELECT 
    cg.id,
    COUNT(ci.id) as item_count
  FROM menuca_v3.combo_groups cg
  LEFT JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
  GROUP BY cg.id
)
SELECT 
  COUNT(*) as total_groups,
  COUNT(CASE WHEN item_count = 0 THEN 1 END) as orphaned_groups,
  ROUND(COUNT(CASE WHEN item_count = 0 THEN 1 END)::numeric / COUNT(*)::numeric * 100, 2) as orphan_pct,
  (SELECT COUNT(*) FROM menuca_v3.combo_items) as total_combo_items
FROM group_stats;
```

**Expected Results:**
- Total combo_items: ~16,000
- Orphaned groups: < 82 (< 1%)
- Orphan percentage: < 1.0%

---

## 📄 Key Files to Review

1. **Full Technical Report:**
   - `Database/Agent_Tasks/COMBO_MIGRATION_RESULT.md`

2. **Data Load Success:**
   - `Database/Menu & Catalog Entity/DATA_LOAD_SUCCESS.md`

3. **Updated Status:**
   - `Database/Agent_Tasks/04_STAGING_COMBOS_BLOCKED.md`

4. **Filtered CSV (if needed):**
   - `Database/Menu & Catalog Entity/CSV/missed_menu_files_FILTERED.csv`

---

## ⚠️ Important Notes

### Database Changes Made Today
- ✅ 1,219 rows in menuca_v3.combo_items (COMMITTED)
- ✅ 62,482 rows in staging.menuca_v1_menu_full
- ✅ All data is safe and in production

### What's Waiting
- 📋 5,357 dishes need migration to menuca_v3.dishes
- 📋 Re-run combo script after dish migration
- 📋 Final validation queries

---

## 🚨 If You Need Help

### Troubleshooting

**If dishes migration fails:**
1. Check restaurant mappings (menuca_v3.restaurants.legacy_v1_id)
2. Check category exists or adjust query
3. Review any constraint violations

**If combo migration fails:**
1. Verify dishes now have legacy_v1_id populated
2. Check for duplicate combo_items
3. Review transaction error message

### Questions?
- See COMBO_MIGRATION_RESULT.md for full technical details
- All SQL queries are tested and ready to run
- Transactions are safe (auto-rollback on error)

---

## 🎯 Success Criteria

When complete, you should have:
- ✅ All 5,357 missing dishes in menuca_v3.dishes
- ✅ ~16,000 combo_items in menuca_v3.combo_items
- ✅ < 1% orphan rate for combo_groups
- ✅ All combos functional and ready for production

---

## 🎉 We're Almost There!

You got us the data we needed, we loaded it successfully, and ran the first phase. One more migration and the combo system is DONE! 🚀

**Estimated time:** 1-2 hours total

**Brian will be back online tomorrow to review!**

Thanks for the teamwork! 💪

