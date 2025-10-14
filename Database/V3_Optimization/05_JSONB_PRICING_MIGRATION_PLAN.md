# JSONB → Relational Pricing Migration - Step-by-Step Plan

**Date:** October 14, 2025  
**Status:** 📋 READY TO EXECUTE  
**Approach:** Incremental with validation at each step  
**Risk Level:** 🟡 MEDIUM (data transformation + FK relationships)

---

## 🎯 **What We're Doing**

**Goal:** Convert JSONB pricing arrays to proper relational tables for better querying and data integrity.

**Scope:**
- `dishes.prices` → `dish_prices` table (5,130 rows)
- `dish_modifiers.price_by_size` → `dish_modifier_prices` table (429 rows)

**Why:**
- ✅ Can query by price
- ✅ Can join and report easily
- ✅ Can add constraints
- ✅ Better for new app

---

## 📊 **Current State**

| Source | Rows with Data | JSONB Structure | Example |
|--------|----------------|-----------------|---------|
| `dishes.prices` | 5,130 (32.59%) | Array of strings | `["1.99"]` or `["1.90", "20.50"]` |
| `dish_modifiers.price_by_size` | 429 (14.68%) | Array of strings | Same structure |

---

## 🗺️ **EXECUTION PLAN**

### **✅ STEP 1: Create New Tables** (5 minutes)
**What:** Create `dish_prices` and `dish_modifier_prices` tables  
**Risk:** 🟢 ZERO (just structure, no data)  
**Validation:** Tables exist, FK constraints work  
**Rollback:** DROP tables if needed

---

### **✅ STEP 2: Test on 100 Sample Rows** (10 minutes)
**What:** Migrate 100 dishes with JSONB prices to new table  
**Risk:** 🟢 LOW (small sample)  
**Validation:** 
- Count matches (100 dishes → X price rows)
- All dish_ids are valid
- No orphans
- Prices look correct  
**Rollback:** DELETE FROM dish_prices WHERE id IN (sample)

---

### **✅ STEP 3: Validate Sample** (5 minutes)
**What:** Manual review of sample data  
**Risk:** 🟢 ZERO (just checking)  
**Validation:**
- Spot check 10 random dishes
- Verify prices match original JSONB
- Check relationships are correct  
**Decision:** GO/NO-GO for full migration

---

### **✅ STEP 4: Migrate dishes.prices** (10 minutes)
**What:** Full migration of 5,130 dishes  
**Risk:** 🟡 MEDIUM (large dataset)  
**Validation:**
- Row count matches
- All FK constraints satisfied
- No orphans
- Before/after comparison  
**Rollback:** TRUNCATE dish_prices (JSONB still exists)

---

### **✅ STEP 5: Migrate dish_modifiers.price_by_size** (5 minutes)
**What:** Migrate 429 dish modifiers  
**Risk:** 🟡 MEDIUM (FK relationships)  
**Validation:**
- Count matches
- All modifier_ids valid
- Relationships correct  
**Rollback:** TRUNCATE dish_modifier_prices

---

### **✅ STEP 6: Final Verification** (10 minutes)
**What:** Comprehensive validation  
**Risk:** 🟢 ZERO (just checking)  
**Validation:**
- Total price rows created
- All relationships valid
- Spot checks pass
- Compare sample queries JSONB vs relational  
**Decision:** Keep JSONB as backup or drop

---

### **✅ STEP 7: Documentation** (5 minutes)
**What:** Document results, update memory bank  
**Risk:** 🟢 ZERO  

---

## 📋 **STEP-BY-STEP EXECUTION GUIDE**

---

## **STEP 1: CREATE TABLES**

### **What to Run:**
```sql
BEGIN;

-- Table 1: Dish Prices
CREATE TABLE menuca_v3.dish_prices (
  id BIGSERIAL PRIMARY KEY,
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  size_variant VARCHAR(50),  -- 'default', 'small', 'medium', 'large', 'xlarge', etc.
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table 2: Dish Modifier Prices
CREATE TABLE menuca_v3.dish_modifier_prices (
  id BIGSERIAL PRIMARY KEY,
  dish_modifier_id BIGINT NOT NULL REFERENCES menuca_v3.dish_modifiers(id) ON DELETE CASCADE,
  size_variant VARCHAR(50),
  price_adjustment NUMERIC(10,2) NOT NULL,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_dish_prices_dish_id ON menuca_v3.dish_prices(dish_id);
CREATE INDEX idx_dish_prices_active ON menuca_v3.dish_prices(is_active) WHERE is_active = true;
CREATE INDEX idx_dish_modifier_prices_modifier_id ON menuca_v3.dish_modifier_prices(dish_modifier_id);

-- Comments
COMMENT ON TABLE menuca_v3.dish_prices IS 'Relational pricing table - migrated from dishes.prices JSONB';
COMMENT ON TABLE menuca_v3.dish_modifier_prices IS 'Relational pricing table - migrated from dish_modifiers.price_by_size JSONB';

COMMIT;
```

### **Validation After Step 1:**
```sql
-- Check tables exist
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'menuca_v3') as column_count
FROM information_schema.tables t
WHERE table_schema = 'menuca_v3' 
  AND table_name IN ('dish_prices', 'dish_modifier_prices');

-- Check FK constraints
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'menuca_v3'
  AND table_name IN ('dish_prices', 'dish_modifier_prices')
  AND constraint_type = 'FOREIGN KEY';

-- Check indexes
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND tablename IN ('dish_prices', 'dish_modifier_prices');
```

**Expected:** 2 tables, 2 FK constraints, 3 indexes  
**Decision:** PASS → Continue to Step 2

---

## **STEP 2: TEST ON 100 SAMPLES**

### **What to Run:**
```sql
BEGIN;

-- Migrate 100 sample dishes with prices
WITH sample_dishes AS (
  SELECT id, name, prices
  FROM menuca_v3.dishes
  WHERE prices IS NOT NULL 
    AND jsonb_array_length(prices) > 0
  LIMIT 100
),
expanded_prices AS (
  SELECT 
    id as dish_id,
    name,
    value::text as price_text,
    (row_number() OVER (PARTITION BY id ORDER BY ordinality)) - 1 as array_index,
    CASE 
      WHEN jsonb_array_length(prices) = 1 THEN 'default'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 1 THEN 'small'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 2 THEN 'large'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 3 THEN 'xlarge'
      ELSE 'size_' || (row_number() OVER (PARTITION BY id ORDER BY ordinality))
    END as size_variant
  FROM sample_dishes,
       jsonb_array_elements(prices) WITH ORDINALITY
)
INSERT INTO menuca_v3.dish_prices (dish_id, size_variant, price, display_order)
SELECT 
  dish_id,
  size_variant,
  CASE 
    WHEN price_text ~ '^[0-9]+\.?[0-9]*$' THEN price_text::numeric
    ELSE 0.00
  END as price,
  array_index as display_order
FROM expanded_prices;

COMMIT;
```

### **Validation After Step 2:**
```sql
-- Count comparison
SELECT 
  'Sample Dishes' as metric,
  (SELECT COUNT(*) FROM menuca_v3.dishes WHERE id IN (
    SELECT DISTINCT dish_id FROM menuca_v3.dish_prices
  )) as dishes_with_prices,
  (SELECT COUNT(*) FROM menuca_v3.dish_prices) as total_price_rows,
  (SELECT COUNT(*) FROM menuca_v3.dish_prices) / 
    NULLIF((SELECT COUNT(*) FROM menuca_v3.dishes WHERE id IN (
      SELECT DISTINCT dish_id FROM menuca_v3.dish_prices
    )), 0)::numeric as avg_prices_per_dish;

-- Check for orphans (should be 0)
SELECT COUNT(*) as orphaned_prices
FROM menuca_v3.dish_prices dp
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dp.dish_id);

-- Sample 10 for manual review
SELECT 
  d.id,
  d.name,
  d.prices as original_jsonb,
  json_agg(json_build_object(
    'size', dp.size_variant,
    'price', dp.price,
    'order', dp.display_order
  ) ORDER BY dp.display_order) as migrated_prices
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
GROUP BY d.id, d.name, d.prices
LIMIT 10;
```

**Expected:** 
- 100 dishes → 100-200 price rows (avg 1-2 prices per dish)
- 0 orphans
- Sample looks correct

**Decision:** PASS → Continue to Step 3 | FAIL → Fix and retry

---

## **STEP 3: VALIDATE SAMPLE**

### **Manual Checks:**
1. Review the 10 sample dishes from Step 2
2. Compare `original_jsonb` with `migrated_prices`
3. Verify:
   - ✅ All prices present
   - ✅ Size variants make sense
   - ✅ Order is correct
   - ✅ No data loss

### **Spot Check Query:**
```sql
-- Compare a specific dish
SELECT 
  d.id,
  d.name,
  d.prices as jsonb_version,
  (SELECT json_agg(dp.price ORDER BY dp.display_order) 
   FROM menuca_v3.dish_prices dp 
   WHERE dp.dish_id = d.id) as relational_version
FROM menuca_v3.dishes d
WHERE d.id = (SELECT dish_id FROM menuca_v3.dish_prices LIMIT 1);
```

**Decision Point:**
- ✅ **PASS:** Looks good → Continue to Step 4 (full migration)
- ❌ **FAIL:** Issues found → Fix parsing logic and retry Step 2

---

## **STEP 4: FULL DISHES.PRICES MIGRATION**

### **What to Run:**
```sql
BEGIN;

-- Clear any test data first
TRUNCATE menuca_v3.dish_prices;

-- Full migration of all 5,130 dishes
WITH all_dishes AS (
  SELECT id, name, prices
  FROM menuca_v3.dishes
  WHERE prices IS NOT NULL 
    AND jsonb_array_length(prices) > 0
),
expanded_prices AS (
  SELECT 
    id as dish_id,
    value::text as price_text,
    (row_number() OVER (PARTITION BY id ORDER BY ordinality)) - 1 as array_index,
    jsonb_array_length(prices) as total_prices,
    CASE 
      WHEN jsonb_array_length(prices) = 1 THEN 'default'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 1 THEN 'small'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 2 THEN 'large'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 3 THEN 'xlarge'
      ELSE 'size_' || (row_number() OVER (PARTITION BY id ORDER BY ordinality))
    END as size_variant
  FROM all_dishes,
       jsonb_array_elements(prices) WITH ORDINALITY
)
INSERT INTO menuca_v3.dish_prices (dish_id, size_variant, price, display_order)
SELECT 
  dish_id,
  size_variant,
  CASE 
    WHEN price_text ~ '^[0-9]+\.?[0-9]*$' THEN price_text::numeric
    ELSE 0.00
  END as price,
  array_index as display_order
FROM expanded_prices;

-- Get stats
DO $$
DECLARE
  v_dishes_migrated INTEGER;
  v_price_rows_created INTEGER;
BEGIN
  SELECT COUNT(DISTINCT dish_id) INTO v_dishes_migrated FROM menuca_v3.dish_prices;
  SELECT COUNT(*) INTO v_price_rows_created FROM menuca_v3.dish_prices;
  
  RAISE NOTICE '========== STEP 4 COMPLETE ==========';
  RAISE NOTICE 'Dishes migrated: %', v_dishes_migrated;
  RAISE NOTICE 'Price rows created: %', v_price_rows_created;
  RAISE NOTICE 'Avg prices per dish: %', ROUND(v_price_rows_created::numeric / v_dishes_migrated, 2);
  RAISE NOTICE '====================================';
END $$;

COMMIT;
```

### **Validation After Step 4:**
```sql
-- Comprehensive validation
SELECT 
  'Dish Prices Migration' as check_name,
  (SELECT COUNT(*) FROM menuca_v3.dishes WHERE prices IS NOT NULL AND jsonb_array_length(prices) > 0) as source_dishes_with_pricing,
  (SELECT COUNT(DISTINCT dish_id) FROM menuca_v3.dish_prices) as dishes_migrated,
  (SELECT COUNT(*) FROM menuca_v3.dish_prices) as total_price_rows,
  (SELECT COUNT(*) FROM menuca_v3.dish_prices WHERE price <= 0) as zero_or_negative_prices,
  (SELECT COUNT(*) FROM menuca_v3.dish_prices dp WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dp.dish_id)) as orphaned_prices;

-- Price distribution
SELECT 
  CASE 
    WHEN price < 5 THEN 'Under $5'
    WHEN price < 10 THEN '$5-$10'
    WHEN price < 20 THEN '$10-$20'
    WHEN price < 50 THEN '$20-$50'
    ELSE 'Over $50'
  END as price_range,
  COUNT(*) as count
FROM menuca_v3.dish_prices
GROUP BY price_range
ORDER BY MIN(price);
```

**Expected:**
- 5,130 dishes migrated
- 0 orphans
- Prices look reasonable

**Decision:** PASS → Continue to Step 5 | FAIL → ROLLBACK and investigate

---

## **STEP 5: MIGRATE DISH_MODIFIERS.PRICE_BY_SIZE**

### **What to Run:**
```sql
BEGIN;

-- Migrate dish modifiers (429 rows)
WITH all_modifiers AS (
  SELECT id, price_by_size
  FROM menuca_v3.dish_modifiers
  WHERE price_by_size IS NOT NULL 
    AND jsonb_array_length(price_by_size) > 0
),
expanded_prices AS (
  SELECT 
    id as dish_modifier_id,
    value::text as price_text,
    (row_number() OVER (PARTITION BY id ORDER BY ordinality)) - 1 as array_index,
    CASE 
      WHEN jsonb_array_length(price_by_size) = 1 THEN 'default'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 1 THEN 'small'
      WHEN (row_number() OVER (PARTITION BY id ORDER BY ordinality)) = 2 THEN 'large'
      ELSE 'size_' || (row_number() OVER (PARTITION BY id ORDER BY ordinality))
    END as size_variant
  FROM all_modifiers,
       jsonb_array_elements(price_by_size) WITH ORDINALITY
)
INSERT INTO menuca_v3.dish_modifier_prices (dish_modifier_id, size_variant, price_adjustment, display_order)
SELECT 
  dish_modifier_id,
  size_variant,
  CASE 
    WHEN price_text ~ '^-?[0-9]+\.?[0-9]*$' THEN price_text::numeric
    ELSE 0.00
  END as price_adjustment,
  array_index as display_order
FROM expanded_prices;

-- Stats
DO $$
DECLARE
  v_modifiers_migrated INTEGER;
  v_price_rows_created INTEGER;
BEGIN
  SELECT COUNT(DISTINCT dish_modifier_id) INTO v_modifiers_migrated FROM menuca_v3.dish_modifier_prices;
  SELECT COUNT(*) INTO v_price_rows_created FROM menuca_v3.dish_modifier_prices;
  
  RAISE NOTICE '========== STEP 5 COMPLETE ==========';
  RAISE NOTICE 'Modifiers migrated: %', v_modifiers_migrated;
  RAISE NOTICE 'Price rows created: %', v_price_rows_created;
  RAISE NOTICE '====================================';
END $$;

COMMIT;
```

### **Validation After Step 5:**
```sql
-- Validation
SELECT 
  'Modifier Prices Migration' as check_name,
  (SELECT COUNT(*) FROM menuca_v3.dish_modifiers WHERE price_by_size IS NOT NULL) as source_modifiers,
  (SELECT COUNT(DISTINCT dish_modifier_id) FROM menuca_v3.dish_modifier_prices) as modifiers_migrated,
  (SELECT COUNT(*) FROM menuca_v3.dish_modifier_prices) as total_price_rows,
  (SELECT COUNT(*) FROM menuca_v3.dish_modifier_prices dmp WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.dish_modifiers dm WHERE dm.id = dmp.dish_modifier_id)) as orphans;
```

**Expected:** 429 modifiers → price rows, 0 orphans  
**Decision:** PASS → Continue to Step 6

---

## **STEP 6: FINAL VERIFICATION**

### **Comprehensive Checks:**
```sql
-- Summary stats
SELECT 
  'dish_prices' as table_name,
  COUNT(DISTINCT dish_id) as unique_parents,
  COUNT(*) as total_rows,
  MIN(price) as min_price,
  MAX(price) as max_price,
  AVG(price) as avg_price
FROM menuca_v3.dish_prices
UNION ALL
SELECT 
  'dish_modifier_prices',
  COUNT(DISTINCT dish_modifier_id),
  COUNT(*),
  MIN(price_adjustment),
  MAX(price_adjustment),
  AVG(price_adjustment)
FROM menuca_v3.dish_modifier_prices;

-- Test queries (these should work now!)
-- Query 1: All dishes under $10
SELECT COUNT(*) as dishes_under_10
FROM menuca_v3.dish_prices
WHERE price < 10;

-- Query 2: Average price by size
SELECT size_variant, 
       COUNT(*) as count,
       AVG(price) as avg_price
FROM menuca_v3.dish_prices
GROUP BY size_variant
ORDER BY avg_price;

-- Query 3: Most expensive dishes
SELECT d.name, dp.size_variant, dp.price
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
ORDER BY dp.price DESC
LIMIT 10;
```

**Decision:** 
- ✅ **PASS:** All looks good → Document and celebrate!
- ❌ **FAIL:** Issues found → Investigate and fix

---

## **STEP 7: DOCUMENTATION**

### **What to Document:**
- [x] Tables created
- [x] Rows migrated
- [x] Validation passed
- [x] JSONB columns kept as backup
- [x] New query capabilities

---

## 🚨 **ROLLBACK PROCEDURES**

### **If Issues Found in Step 2-3 (Sample):**
```sql
DELETE FROM menuca_v3.dish_prices;
-- Fix issue, retry
```

### **If Issues Found in Step 4-5 (Full):**
```sql
TRUNCATE menuca_v3.dish_prices;
TRUNCATE menuca_v3.dish_modifier_prices;
-- Investigate, fix, retry
```

### **If Need to Completely Undo:**
```sql
DROP TABLE menuca_v3.dish_prices;
DROP TABLE menuca_v3.dish_modifier_prices;
-- Original JSONB columns still exist!
```

---

## ✅ **SUCCESS CRITERIA**

- [x] Tables created with proper FK constraints
- [x] 5,130 dishes migrated to dish_prices
- [x] 429 modifiers migrated to dish_modifier_prices
- [x] 0 orphaned prices
- [x] 0 invalid relationships
- [x] Sample queries work correctly
- [x] Original JSONB preserved as backup

---

## 📊 **Expected Outcomes**

| Metric | Expected Value |
|--------|----------------|
| **dish_prices rows** | 5,130 - 10,260 (1-2 prices per dish avg) |
| **dish_modifier_prices rows** | 429 - 858 (1-2 prices per modifier avg) |
| **Execution time** | 30-45 minutes total |
| **Data loss** | 0% (JSONB backup remains) |
| **Orphaned records** | 0 |

---

**Status:** 📋 PLAN READY - Execute step-by-step with validation!  
**Next:** Start with Step 1 when ready  
**Approach:** Validate → Execute → Validate → Next step

