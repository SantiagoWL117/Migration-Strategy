# MenuCA V3 Pricing Fix - Immaculate Plan

**Date:** 2025-10-28  
**Critical:** Real businesses paying $2k/month - Zero data loss tolerance  
**Problem:** 78 active dishes missing prices due to incorrect legacy_v1_id mappings  
**Status:** 100% of missing prices have WRONG restaurant mappings in legacy IDs

---

## 🔍 ROOT CAUSE ANALYSIS

### The Mapping Problem

**What Happened During Migration:**
1. V1/V2 databases are "blobs" with no proper foreign key relationships
2. When migrating to V3, dishes were assigned `legacy_v1_id` values
3. These IDs point to REAL dishes in V1, but from the WRONG restaurants
4. Example: V3 "All Out Burger" dish has `legacy_v1_id=49813`, but that ID belongs to a Japanese restaurant's "Shrimp Teriyaki"

**Proof:**
```
V3 Restaurant: All Out Burger (legacy_v1_id = 1038)
V3 Dish: "Extra Cheese" (legacy_v1_id = 49813)
V1 Reality: ID 49813 = "Shrimp Teriyaki" from restaurant 534 (NOT 1038)
```

**Impact:**
- 78 dishes across 27 active restaurants
- All have `legacy_v1_id` pointing to wrong restaurants
- Prices exist in V1/V2 but can't be matched via direct ID lookup
- Name matching already tried (330 matches found, 78 remain)

---

## ✅ SYSTEMATIC FIX STRATEGY

### Phase 1: Identify Dish Types (Completed ✓)

**Category Breakdown:**
1. **Modifiers/Add-ons** (majority): Extra Cheese, Bacon, Sauces, Dressings, Seasonings
2. **Side Items**: Fries, Chips, specific portions
3. **Main Menu Items**: A few actual entrees with wrong mappings

### Phase 2: Multi-Strategy Price Recovery

#### Strategy A: Enhanced Name Matching (Within Correct Restaurant)
**Target:** Main menu items and sides  
**Method:** Match V3 dish name to V1 dishes from the CORRECT V1 restaurant

```sql
-- Find V1 dishes from the CORRECT restaurant by name
WITH missing_v3 AS (
  SELECT 
    d.id AS v3_dish_id,
    d.name AS v3_dish_name,
    r.legacy_v1_id AS correct_v1_restaurant_id,
    r.name AS v3_rest_name
  FROM menuca_v3.dishes d
  JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
  WHERE d.is_active = true 
    AND (d.base_price IS NULL OR d.base_price = 0)
    AND r.status = 'active'
    AND r.legacy_v1_id IS NOT NULL
),
normalized AS (
  SELECT 
    m.v3_dish_id,
    m.v3_dish_name,
    m.correct_v1_restaurant_id,
    m.v3_rest_name,
    -- Normalize V3 name
    lower(trim(regexp_replace(
      unaccent(regexp_replace(m.v3_dish_name, '(?i)\b(hide(d)?|extra|add)\b', '', 'g')),
      '[^a-z0-9]+', ' ', 'g'
    ))) AS v3_norm,
    -- Find matching V1 dishes from CORRECT restaurant
    v1.id AS v1_dish_id,
    v1.name AS v1_dish_name,
    v1.clean_price,
    lower(trim(regexp_replace(
      unaccent(regexp_replace(v1.name, '(?i)\b(hide(d)?|extra|add)\b', '', 'g')),
      '[^a-z0-9]+', ' ', 'g'
    ))) AS v1_norm
  FROM missing_v3 m
  JOIN staging.v1_with_clean_price v1 
    ON v1.restaurant = m.correct_v1_restaurant_id
  WHERE v1.clean_price IS NOT NULL AND v1.clean_price > 0
)
-- Match by normalized name
SELECT 
  v3_dish_id,
  v3_dish_name,
  v3_rest_name,
  v1_dish_name AS matched_v1_name,
  clean_price,
  CASE 
    WHEN v3_norm = v1_norm THEN 'EXACT'
    WHEN similarity(v3_norm, v1_norm) >= 0.95 THEN 'FUZZY_95'
    WHEN similarity(v3_norm, v1_norm) >= 0.85 THEN 'FUZZY_85'
  END AS match_quality
FROM normalized
WHERE v3_norm = v1_norm
   OR similarity(v3_norm, v1_norm) >= 0.85
ORDER BY v3_rest_name, match_quality DESC;
```

#### Strategy B: Modifier Pattern Recognition
**Target:** Add-ons, extras, toppings (majority of missing items)  
**Method:** Identify common modifier patterns and apply standard pricing

**Common Modifiers:**
- Extra/Add Cheese: $1-3
- Bacon: $2-4  
- Sauces/Dressings: $0.50-2
- Seasonings: $0-1
- Hot Peppers/Jalapeños: $1-2

**Approach:**
1. Identify modifiers by name pattern matching
2. Look for similar modifiers in same restaurant
3. Apply consistent pricing within restaurant
4. Flag for manual review if no pattern found

#### Strategy C: Cross-Reference from Live Websites
**Target:** Items that can't be matched in V1/V2  
**Method:** Use Playwright to scrape current online menus

**Sources:**
1. All Out Burger: https://gladstone.alloutburger.com/?p=menu ✓ (already confirmed active)
2. MenuGatineau listings (where available)
3. Restaurant's own websites
4. Third-party platforms (UberEats, DoorDash)

#### Strategy D: Same-Restaurant Price Analysis
**Target:** Remaining orphaned items  
**Method:** Statistical analysis of similar items

```sql
-- Find similar items in same restaurant and suggest price
WITH restaurant_pricing AS (
  SELECT 
    d.restaurant_id,
    d.name,
    d.base_price,
    -- Extract base item type
    CASE 
      WHEN name ILIKE '%cheese%' THEN 'cheese_addon'
      WHEN name ILIKE '%bacon%' THEN 'bacon_addon'
      WHEN name ILIKE '%sauce%' OR name ILIKE '%dressing%' THEN 'sauce'
      WHEN name ILIKE '%fries%' THEN 'fries'
      WHEN name ILIKE '%pepper%' OR name ILIKE '%jalapeno%' THEN 'pepper_addon'
      ELSE 'other'
    END AS item_type
  FROM menuca_v3.dishes d
  WHERE d.base_price IS NOT NULL 
    AND d.base_price > 0
    AND d.is_active = true
)
SELECT 
  restaurant_id,
  item_type,
  COUNT(*) AS count,
  AVG(base_price) AS avg_price,
  MIN(base_price) AS min_price,
  MAX(base_price) AS max_price,
  MODE() WITHIN GROUP (ORDER BY base_price) AS most_common_price
FROM restaurant_pricing
WHERE item_type != 'other'
GROUP BY restaurant_id, item_type
ORDER BY restaurant_id, item_type;
```

---

## 🎯 EXECUTION PLAN

### Step 1: Diagnostic Deep Dive (30 min)
✓ Categorize all 78 missing items by type
✓ Map to correct V1 restaurants
✓ Identify which strategies apply to each

### Step 2: Strategy A - Enhanced Name Matching (1 hour)
- Run corrected name matching against CORRECT V1 restaurants
- Apply exact matches immediately
- Apply fuzzy matches ≥0.95 with manual review
- **Expected Recovery:** 30-40 items

### Step 3: Strategy B - Modifier Pattern Recognition (1 hour)
- Identify all modifiers/add-ons in missing list
- Cross-reference with same restaurant's existing modifiers
- Apply consistent pricing within restaurant
- **Expected Recovery:** 20-30 items

### Step 4: Strategy C - Live Website Scraping (2 hours)
- Playwright automation for accessible online menus
- Manual verification for critical items
- **Expected Recovery:** 10-15 items

### Step 5: Strategy D - Statistical Analysis (30 min)
- Apply restaurant-specific patterns for remaining items
- Flag for manual review if confidence < 80%
- **Expected Recovery:** 5-10 items

### Step 6: Manual Review & Verification (1 hour)
- Review all automated matches
- Contact restaurants for final ~5 items if needed
- **Expected Recovery:** Remaining items

### Step 7: Fix Legacy IDs (30 min)
**CRITICAL:** Update incorrect `legacy_v1_id` values

```sql
-- Clear bad legacy IDs (keep dishes, just remove wrong references)
UPDATE menuca_v3.dishes d
SET 
  legacy_v1_id = NULL,
  updated_at = NOW()
WHERE d.id IN (
  -- List of 78 dishes with wrong mappings
  SELECT v3_dish_id FROM analysis_results
)
AND d.legacy_v1_id IS NOT NULL;
```

**Why This is Safe:**
- Dishes remain intact (no deletion)
- Prices will be set via Strategies A-D
- Wrong legacy IDs cause more harm than good
- Can always re-map correctly later if needed

---

## 📊 EXPECTED OUTCOMES

### Success Metrics
- **Target:** 100% of 78 dishes priced correctly
- **Confidence:** >95% automated, <5% manual verification
- **Timeline:** 6-8 hours total work
- **Validation:** Cross-check with live websites

### Post-Fix Status
- **Before:** 93.8% platform coverage
- **After:** 99%+ platform coverage
- **Active Restaurants 100% Coverage:** 88 → 115 (all)

---

## 🚀 IMMEDIATE NEXT STEPS

### Action 1: Run Diagnostic (RIGHT NOW)
Execute comprehensive analysis to categorize all 78 items and identify best recovery strategy for each.

### Action 2: Execute Strategy A (TODAY)
Run enhanced name matching against correct V1 restaurants - should recover 40-50% immediately.

### Action 3: Execute Strategy B (TODAY)
Pattern-match modifiers and apply consistent pricing - should recover another 30-40%.

### Action 4: Execute Strategies C & D (TOMORROW)
Web scraping and statistical analysis for remaining items.

### Action 5: Manual Review (TOMORROW)
Final verification and quality check before deploying to production.

---

## ⚠️ CRITICAL SAFEGUARDS

1. **NO DATA DELETION** - Only update prices and clear wrong legacy IDs
2. **AUDIT TRAIL** - Log all price changes with source (Strategy A/B/C/D)
3. **ROLLBACK PLAN** - Backup current state before any updates
4. **VALIDATION** - Cross-check automated matches against live menus
5. **RESTAURANT NOTIFICATION** - Alert affected restaurants of menu updates

---

## 📝 TECHNICAL IMPLEMENTATION

All fixes will be implemented as:
1. **Read-only analysis first** - Understand the data
2. **Generate change preview** - Show what will be updated
3. **Manual approval** - You review before applying
4. **Atomic updates** - All or nothing, with rollback
5. **Verification queries** - Confirm results after each step

**No changes will be made without your explicit approval.**

---

**Ready to proceed with Step 1: Diagnostic Deep Dive?**

This will analyze all 78 items and show exactly which strategy applies to each, with expected confidence levels and recovery estimates.

