# BLOB Deserialization Solutions - Menu & Catalog Entity

**Date**: 2025-01-08  
**Purpose**: Comprehensive analysis and solutions for all BLOB columns requiring deserialization  
**Status**: 🔄 **IN PROGRESS** (3/4 approved)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [BLOB Case #1: menu.hideOnDays](#blob-case-1-menuhideondays)
3. [BLOB Case #2: menuothers.content](#blob-case-2-menuotherscontent)
4. [BLOB Case #3: ingredient_groups.item](#blob-case-3-ingredient_groupsitem)
5. [BLOB Case #4: combo_groups (3 BLOB columns)](#blob-case-4-combo_groups-3-blob-columns)
6. [Schema Design Summary](#schema-design-summary)
7. [Implementation Roadmap](#implementation-roadmap)

---

## Executive Summary

### Overview

This document addresses **4 critical BLOB columns** across 3 V1 tables, containing **95,244 BLOB records** that must be deserialized and normalized into `menuca_v3` schema.

### Core Principles

1. ✅ **Preserve ALL relevant data** - No data loss
2. ✅ **Normalize relationships** - Eliminate embedded data structures
3. ✅ **Use junction tables** - For many-to-many relationships
4. ✅ **Use JSONB for configs** - For flexible configuration data
5. ✅ **Maintain referential integrity** - All foreign keys enforced

### Summary Table

| BLOB Column | Rows | Complexity | Solution | New Tables Required | Status |
|-------------|------|------------|----------|---------------------|--------|
| `menu.hideOnDays` | 865 | 🟢 Low | Add JSONB column | 0 (modify existing) | ✅ **APPROVED** |
| `menuothers.content` | 70,363 | 🔴 High | Enhance dish_modifiers table | 0 (recreate existing) | ✅ **APPROVED** |
| `ingredient_groups.item + price` | 13,252 | 🟡 Medium | Junction table with pricing | 1 (`ingredient_group_items`) | ✅ **APPROVED** |
| `combo_groups.dish` | 10,764 | 🟡 Medium | Normalize to junction table | 0 (use existing `combo_items`) | ✅ **APPROVED** |
| `combo_groups.options` | 10,764 | 🔴 High | Store as JSONB | 0 (modify existing `combo_groups`) | ✅ **APPROVED** |
| `combo_groups.group` | 10,764 | 🔴 High | Junction table + JSONB | 1 (`combo_group_modifier_pricing`) | ✅ **APPROVED** |

**Total New Tables Required**: **2**

---

## BLOB Case #1: menu.hideOnDays

### 📊 Problem Statement

**Source Table**: `menuca_v1.menu`  
**BLOB Column**: `hideOnDays`  
**Affected Rows**: 865 dishes (out of 117,666)  
**Complexity**: 🟢 **LOW**

**Example Data**:
```php
a:5:{i:0;s:3:"wed";i:1;s:3:"thu";i:2;s:3:"fri";i:3;s:3:"sat";i:4;s:3:"sun";}
// Dish is hidden on Wednesday, Thursday, Friday, Saturday, Sunday
```

**Business Logic**:
- Restaurants want certain dishes available only on specific days
- Example: "Taco Tuesday Special" only shows on Tuesdays
- "Weekend Brunch Menu" only shows Saturday-Sunday

### 🎯 Approved Solution

**✅ DECISION APPROVED: JSONB Column**

Add a `availability_schedule` JSONB column to `menuca_v3.dishes`:

```sql
ALTER TABLE menuca_v3.dishes
ADD COLUMN availability_schedule JSONB DEFAULT NULL;

-- Example values:
-- Hide on specific days:
{
  "hide_on_days": ["wed", "thu", "fri", "sat", "sun"]
}

-- Or show only on specific days (future enhancement):
{
  "show_on_days": ["tue"]
}

-- NULL = available every day (default behavior)
```

**Why JSONB?**
- ✅ Flexible for future enhancements (time ranges, date ranges, holidays)
- ✅ Searchable with GIN indexes
- ✅ No additional tables needed
- ✅ Direct relationship to dish (1:1)
- ✅ Simple implementation
- ✅ Better query performance than normalized alternative
- ✅ Standard pattern for configuration data

**Migration Steps**:
1. Parse PHP serialized `hideOnDays` BLOB
2. Convert to array: `["wed", "thu", "fri", "sat", "sun"]`
3. Store as JSON: `{"hide_on_days": ["wed", "thu", "fri", "sat", "sun"]}`
4. Index for performance: `CREATE INDEX idx_dishes_availability ON dishes USING GIN (availability_schedule);`

**Expected Results**:
- Input: 865 dishes with `hideOnDays` BLOB data
- Output: 865 dishes with `availability_schedule` JSONB populated
- Remaining: 116,801 dishes with `availability_schedule = NULL` (always available)

---

## BLOB Case #2: menuothers.content

### 📊 Problem Statement

**Source Table**: `menuca_v1.menuothers`  
**BLOB Column**: `content`  
**Affected Rows**: 70,363 rows  
**Complexity**: 🔴 **HIGH**

**Table Structure**:
```sql
menuca_v1.menuothers (
  id INT,
  restaurant INT,
  dishId INT,          -- Parent dish
  content BLOB,        -- PHP serialized pricing data
  type CHAR(2),        -- 'ci', 'e', 'sd', 'd', 'sa', 'br'
  groupId INT          -- Ingredient group ID
)
```

**Example Data**:
```php
// Single price for one ingredient:
a:2:{
  s:7:"content";
  a:1:{
    i:1183;       // ingredient_id
    s:4:"0.25";   // price
  }
  s:5:"radio";
  s:3:"140";      // ingredient_group_id
}

// Multi-size pricing (S, M, L, XL):
a:2:{
  s:7:"content";
  a:1:{
    i:17073;
    s:19:"1.00,1.50,2.00,3.00";  // Size-based prices
  }
  s:5:"radio";
  s:4:"3548";
}

// Multiple ingredients (free included toppings):
a:2:{
  s:7:"content";
  a:3:{
    i:10183;s:4:"0.00";
    i:10184;s:4:"0.00";
    i:10185;s:4:"0.00";
  }
  s:5:"radio";
  s:4:"2263";
}
```

**Business Logic**:
- Each row represents dish-specific modifier pricing
- A dish can have different prices for the same ingredient
- Example: "Extra Cheese" costs $0.25 on Pizza A, but $0.50 on Pizza B
- Multi-size dishes have size-based modifier pricing
- Type codes indicate modifier category

### 🎯 Approved Solution

**Status**: ✅ **DECISION APPROVED** - Enhanced dish_modifiers Table

**Use existing `menuca_v3.dish_modifiers` table** with enhancements:

**Current Schema** (check if modifications needed):
```sql
-- Existing table:
CREATE TABLE menuca_v3.dish_modifiers (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid(),
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
  price_adjustment DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Proposed Enhanced Schema**:
```sql
-- Drop and recreate with enhancements:
DROP TABLE IF EXISTS menuca_v3.dish_modifiers CASCADE;

CREATE TABLE menuca_v3.dish_modifiers (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
  ingredient_group_id BIGINT REFERENCES menuca_v3.ingredient_groups(id) ON DELETE SET NULL,
  
  -- Pricing (supports both single price and multi-size)
  base_price DECIMAL(10,2) DEFAULT 0.00,  -- Single price or NULL if size-based
  price_by_size JSONB,  -- {"S": 1.00, "M": 1.50, "L": 2.00, "XL": 3.00}
  
  -- Metadata
  modifier_type VARCHAR(10),  -- 'ci', 'e', 'sd', 'd', 'sa', 'br', 'dr', 'cm'
  is_included BOOLEAN DEFAULT false,  -- true if price is 0.00 (free topping)
  display_order INT,
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(dish_id, ingredient_id, ingredient_group_id),  -- Prevent duplicates
  CHECK (base_price IS NOT NULL OR price_by_size IS NOT NULL)  -- Must have one pricing method
);

-- Indexes
CREATE INDEX idx_dish_modifiers_dish ON menuca_v3.dish_modifiers(dish_id);
CREATE INDEX idx_dish_modifiers_ingredient ON menuca_v3.dish_modifiers(ingredient_id);
CREATE INDEX idx_dish_modifiers_group ON menuca_v3.dish_modifiers(ingredient_group_id);
CREATE INDEX idx_dish_modifiers_type ON menuca_v3.dish_modifiers(modifier_type);
CREATE INDEX idx_dish_modifiers_price_jsonb ON menuca_v3.dish_modifiers USING GIN (price_by_size);
```

**New Columns Explained**:
- `ingredient_group_id`: Links to the group this modifier belongs to (from `radio` in BLOB)
- `base_price`: For single-price modifiers ($0.25)
- `price_by_size`: For multi-size pricing (JSONB: `{"S": 1.00, "M": 1.50, ...}`)
- `modifier_type`: Category code from `menuothers.type`
- `is_included`: Flag for free modifiers (price = 0.00)
- `display_order`: For UI ordering

**Data Transformation Logic**:

```python
def parse_menuothers_content(blob_content, dish_id, restaurant_id, modifier_type, group_id):
    """
    Parse PHP serialized content and create dish_modifier records.
    
    Returns: List of dish_modifier records to insert
    """
    import phpserialize
    
    try:
        data = phpserialize.loads(blob_content)
        content = data.get(b'content', {})
        radio_group = data.get(b'radio', group_id)
        
        records = []
        
        for ingredient_id, price_str in content.items():
            price_str = price_str.decode('utf-8') if isinstance(price_str, bytes) else price_str
            
            # Check if multi-size pricing (comma-separated)
            if ',' in price_str:
                prices = price_str.split(',')
                # Assuming order: S, M, L, XL, XXL (depends on restaurant)
                size_names = ['S', 'M', 'L', 'XL', 'XXL']
                price_by_size = {size_names[i]: float(p) for i, p in enumerate(prices) if p.strip()}
                
                record = {
                    'dish_id': dish_id,
                    'ingredient_id': int(ingredient_id),
                    'ingredient_group_id': int(radio_group) if radio_group else None,
                    'base_price': None,
                    'price_by_size': json.dumps(price_by_size),
                    'modifier_type': modifier_type,
                    'is_included': False
                }
            else:
                # Single price
                price = float(price_str)
                record = {
                    'dish_id': dish_id,
                    'ingredient_id': int(ingredient_id),
                    'ingredient_group_id': int(radio_group) if radio_group else None,
                    'base_price': price,
                    'price_by_size': None,
                    'modifier_type': modifier_type,
                    'is_included': (price == 0.00)
                }
            
            records.append(record)
        
        return records
    
    except Exception as e:
        # Log error for manual review
        log_blob_error(dish_id, restaurant_id, str(e))
        return []
```

**Expected Output**:
- Input: 70,363 `menuothers` rows
- Output: 100,000-350,000 `dish_modifiers` rows (1 menuothers row can contain multiple ingredients)

### ✅ USER DECISIONS

**1. Schema Changes**: ✅ Approved - Drop and recreate `dish_modifiers` (safe - only 8 rows currently)

**2. Multi-Size Pricing**: ✅ Assume standard size order (S, M, L, XL, XXL)

**3. Orphaned Records**: ✅ Skip orphaned ingredients/dishes, generate exclusion report
- Skip records where dish_id doesn't exist in menuca_v3.dishes
- Skip records where ingredient_id doesn't exist in menuca_v3.ingredients
- Generate report: `orphaned_modifiers_report.txt` with counts and IDs

**4. Price Validation**: ✅ Enforce min/max price constraints
- Minimum: $0.00 (free/included modifiers)
- Maximum: $50.00 (reasonable upper limit)
- Log prices outside range for review

**5. Testing Strategy**: ✅ No test migration needed - Process all 70,363 rows

**6. Rollback Plan**: ✅ Keep `staging.v1_menuothers_parsed` table for quick rollback/re-run

### ✅ IMPLEMENTATION APPROVED

**Enhance existing `dish_modifiers` table** with:
1. `ingredient_group_id` (FK to ingredient_groups)
2. `price_by_size` (JSONB for multi-size pricing)
3. `modifier_type` (category code)
4. `is_included` (free topping flag)
5. `display_order` (UI ordering)
6. Price validation constraints

---

## BLOB Case #3: ingredient_groups.item & ingredient_groups.price

### 📊 Problem Statement

**Source Table**: `menuca_v1.ingredient_groups`  
**BLOB Columns**: `item` AND `price` (dual BLOBs)  
**Affected Rows**: 13,252 ingredient groups  
**Complexity**: 🟡 **MEDIUM** (revised from LOW due to dual BLOBs with pricing)

**Status**: ✅ **SOLUTION APPROVED** - Junction Table with Pricing

**Example Data**:
```php
a:3:{i:0;i:156;i:1;i:157;i:2;i:158;}
// Group contains ingredients: 156, 157, 158

a:20:{i:0;i:278;i:1;i:281;i:2;i:282;i:3;i:283;...;i:19;i:297;}
// Group with 20 ingredients
```

**Business Logic**:
- Ingredient groups organize related ingredients
- Example: "Cheese Options" group contains {Mozzarella, Cheddar, Parmesan, Feta}
- Used for UI organization and modifier rules
- Many-to-many relationship: ingredients can belong to multiple groups

### 🎯 Proposed Solution

**Create NEW junction table**: `menuca_v3.ingredient_group_items`

```sql
CREATE TABLE menuca_v3.ingredient_group_items (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  ingredient_group_id BIGINT NOT NULL REFERENCES menuca_v3.ingredient_groups(id) ON DELETE CASCADE,
  ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
  display_order INT,  -- Preserve original array order (0, 1, 2, ...)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate linkages
  UNIQUE(ingredient_group_id, ingredient_id)
);

-- Indexes
CREATE INDEX idx_ig_items_group ON menuca_v3.ingredient_group_items(ingredient_group_id);
CREATE INDEX idx_ig_items_ingredient ON menuca_v3.ingredient_group_items(ingredient_id);
CREATE INDEX idx_ig_items_order ON menuca_v3.ingredient_group_items(ingredient_group_id, display_order);
```

**Why Junction Table?**
- ✅ Proper normalization (3NF)
- ✅ Many-to-many relationship support
- ✅ Easy to query: "Get all ingredients in group X"
- ✅ Easy to query: "Get all groups containing ingredient Y"
- ✅ Preserves original order with `display_order`

**Data Transformation Logic**:

```python
def parse_ingredient_group_items(blob_item, group_id):
    """
    Parse PHP serialized item BLOB and create junction records.
    """
    import phpserialize
    
    try:
        data = phpserialize.loads(blob_item)
        
        records = []
        for order, ingredient_id in data.items():
            record = {
                'ingredient_group_id': group_id,
                'ingredient_id': int(ingredient_id),
                'display_order': int(order)  # Preserve array index
            }
            records.append(record)
        
        return records
    
    except Exception as e:
        log_blob_error(group_id, str(e))
        return []
```

**Expected Output**:
- Input: 13,252 `ingredient_groups` rows with dual BLOB data
- Output: 50,000-150,000 `ingredient_group_items` rows (avg 4-11 ingredients per group)

### ✅ USER DECISIONS

**1. Pricing Strategy**: ✅ **Option A** - Store in both places (redundancy but flexibility)
- Store pricing in `ingredient_group_items` (from `price` BLOB)
- Also store pricing in `dish_modifiers` (dish-specific overrides)
- This allows group-level default pricing + dish-specific customization

**2. Orphaned Ingredients**: ✅ Same approach as BLOB Case #2 (skip and report)
- Skip records where ingredient_id doesn't exist in menuca_v3.ingredients
- Generate exclusion report: `orphaned_ingredient_group_items_report.txt`

**3. Price Fallback**: ✅ Skip entire group if price BLOB is missing/corrupt
- If `price` BLOB cannot be parsed, skip all ingredients in that group
- Log group_id for manual review
- Prevents inconsistent pricing data

**4. Multi-Size Pricing**: ✅ Cross-reference with dish sizes, fallback to standard order
- Primary: Look up actual size names from dish configuration
- Fallback: Use standard order (S, M, L, XL, XXL) if no match
- Validate array length matches expected sizes

**5. Testing Strategy**: ✅ No test migration needed - Process all 13,252 groups

### ✅ IMPLEMENTATION APPROVED

**Create `ingredient_group_items` junction table** with:
1. FK to `ingredient_groups`
2. FK to `ingredients`  
3. Pricing columns (`base_price`, `price_by_size`)
4. `is_included` flag (free ingredients)
5. `display_order` (UI ordering from array index)
6. UNIQUE constraint to prevent duplicates

---

## BLOB Case #4: combo_groups (3 BLOB columns)

### 📊 Problem Statement

**Source Table**: `menuca_v1.combo_groups`  
**THREE BLOB Columns**: `dish`, `options`, `group`  
**Affected Rows**: 62,344 combo groups total  
- 10,764 with names and BLOB data (TO MIGRATE)
- 51,580 with blank names (EXCLUDED - duplicates)
**Complexity**: 🔴 **CRITICAL - MOST COMPLEX**  
**Status**: ✅ **SOLUTION APPROVED**

**Table Structure**:
```sql
menuca_v1.combo_groups (
  id INT,
  name VARCHAR(255),
  dish BLOB,        -- Array of dish IDs in combo
  options BLOB,     -- Combo configuration rules
  group BLOB,       -- Ingredient group pricing per modifier type
  restaurant INT,
  language VARCHAR(2)
)
```

### Sub-Problem 4A: `combo_groups.dish` BLOB

**Example Data**:
```php
// Empty combo (no specific dishes):
N;

// Single dish combo:
a:1:{i:0;s:3:"827";}

// Multi-dish combo (specialty pizzas for "Pick 2" deal):
a:11:{
  i:0;s:6:"110560";
  i:1;s:6:"110561";
  i:2;s:6:"110562";
  i:3;s:6:"110563";
  i:4;s:6:"110564";
  i:5;s:6:"110565";
  i:6;s:6:"110566";
  i:7;s:6:"110568";
  i:8;s:6:"110569";
  i:9;s:6:"110570";
  i:10;s:6:"110571";
}
```

**Business Logic**:
- Some combos are "open" (customer picks any dish)
- Some combos are "fixed" (only specific dishes allowed)
- Example: "Pick any 2 Specialty Pizzas" - lists 11 specific specialty pizza IDs

### 🎯 Solution 4A: Use existing `combo_items` table

```sql
-- Existing table (verify schema):
CREATE TABLE menuca_v3.combo_items (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid(),
  combo_group_id BIGINT NOT NULL REFERENCES menuca_v3.combo_groups(id) ON DELETE CASCADE,
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  quantity INT DEFAULT 1,
  is_required BOOLEAN DEFAULT true,
  display_order INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**If NULL/empty BLOB**: No combo_items records (customer can pick any dish)
**If BLOB has dish IDs**: Create one `combo_items` row per dish ID

---

### Sub-Problem 4B: `combo_groups.options` BLOB

**Example Data**:
```php
// Complex combo configuration:
a:5:{
  s:9:"itemcount";       // Number of items in combo
  s:1:"2";               // 2 items
  
  s:14:"showPizzaIcons"; // UI setting
  s:1:"Y";
  
  s:13:"displayHeader";  // UI label for multi-item combos
  s:24:"First Pizza;Second Pizza";
  
  s:5:"bread";           // Bread/crust modifier settings
  a:3:{
    s:3:"has";s:1:"Y";           // Has bread modifiers
    s:5:"order";s:1:"1";         // Display order
    s:6:"header";s:10:"Crust type";  // UI label
  }
  
  s:2:"ci";             // Custom ingredients settings
  a:6:{
    s:3:"has";s:1:"Y";           // Has custom ingredients
    s:3:"min";s:1:"1";           // Min required
    s:3:"max";s:1:"0";           // Max allowed (0 = unlimited)
    s:4:"free";s:1:"2";          // First 2 free
    s:5:"order";s:1:"2";         // Display order
    s:6:"header";s:21:"First 2 toppings free";  // UI label
  }
}
```

**Business Logic**:
- Defines how many items in the combo
- Configuration for each modifier type (bread, custom ingredients, extras, sauces, drinks, sides)
- Min/max selection rules
- Free modifier quantities
- UI display settings

### 🎯 Solution 4B: Store as JSONB in `combo_groups.combo_rules`

**Modify existing `combo_groups` table**:

```sql
-- Check current schema and enhance if needed:
ALTER TABLE menuca_v3.combo_groups
ADD COLUMN IF NOT EXISTS combo_rules JSONB;

-- Add GIN index for querying:
CREATE INDEX IF NOT EXISTS idx_combo_groups_rules ON menuca_v3.combo_groups USING GIN (combo_rules);
```

**Transformed JSON Structure**:
```json
{
  "item_count": 2,
  "show_pizza_icons": true,
  "display_header": "First Pizza;Second Pizza",
  "modifier_rules": {
    "bread": {
      "enabled": true,
      "min": 0,
      "max": 1,
      "free_quantity": 1,
      "display_order": 1,
      "display_header": "Crust type"
    },
    "custom_ingredients": {
      "enabled": true,
      "min": 1,
      "max": 0,
      "free_quantity": 2,
      "display_order": 2,
      "display_header": "First 2 toppings free"
    },
    "extras": {
      "enabled": false
    }
  }
}
```

**Why JSONB?**
- ✅ Flexible structure (each restaurant has different rules)
- ✅ Complex nested configuration
- ✅ Searchable with GIN indexes
- ✅ No additional tables needed
- ✅ Easy to extend without schema changes

---

### Sub-Problem 4C: `combo_groups.group` BLOB

**Example Data**:
```php
// Ingredient group pricing per modifier type:
a:3:{
  s:2:"ci";         // Custom ingredients pricing
  a:1:{
    i:7;           // Ingredient group ID 7
    a:20:{         // 20 ingredients with their prices
      i:278;s:5:"2,3,4";           // Ingredient 278: $2(S), $3(M), $4(L)
      i:281;s:5:"2,3,4";
      i:282;s:5:"2,3,4";
      ...
    }
  }
  
  s:2:"br";         // Bread pricing
  a:1:{
    i:1841;
    a:3:{
      i:8391;s:4:"0.00";  // Free bread options
      i:8392;s:4:"0.00";
      i:8393;s:4:"0.00";
    }
  }
  
  s:1:"e";          // Extras pricing
  a:1:{
    i:123;
    a:5:{
      i:456;s:4:"1.50";
      i:457;s:4:"1.50";
      ...
    }
  }
}
```

**Business Logic**:
- Combo-specific modifier pricing (can differ from regular dish pricing)
- Organized by modifier type (ci, br, e, sa, sd, d)
- Each type has ingredient groups with pricing
- Example: "Extra cheese costs $2 on regular pizza, but only $1 on this combo deal"

### 🎯 Solution 4C: NEW junction table + JSONB

**Create**: `menuca_v3.combo_group_modifier_pricing`

```sql
CREATE TABLE menuca_v3.combo_group_modifier_pricing (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  combo_group_id BIGINT NOT NULL REFERENCES menuca_v3.combo_groups(id) ON DELETE CASCADE,
  ingredient_group_id BIGINT NOT NULL REFERENCES menuca_v3.ingredient_groups(id) ON DELETE CASCADE,
  modifier_type VARCHAR(50) NOT NULL,  -- Full words: 'custom_ingredients', 'extras', 'side_dishes', 'drinks', 'sauces', 'bread', 'dressing', 'cooking_method'
  
  -- Pricing per ingredient in this group (for this combo)
  pricing_rules JSONB NOT NULL,  -- {"ingredient_id": price} or {"ingredient_id": {"S": 2.00, "M": 3.00, ...}}
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicates
  UNIQUE(combo_group_id, ingredient_group_id, modifier_type),
  
  -- Enforce valid modifier types (full words for clarity)
  CHECK (
    modifier_type IN (
      'custom_ingredients', 'extras', 'side_dishes', 'drinks', 
      'sauces', 'bread', 'dressing', 'cooking_method'
    )
  )
);

-- Indexes
CREATE INDEX idx_cgmp_combo ON menuca_v3.combo_group_modifier_pricing(combo_group_id);
CREATE INDEX idx_cgmp_group ON menuca_v3.combo_group_modifier_pricing(ingredient_group_id);
CREATE INDEX idx_cgmp_type ON menuca_v3.combo_group_modifier_pricing(modifier_type);
CREATE INDEX idx_cgmp_pricing_jsonb ON menuca_v3.combo_group_modifier_pricing USING GIN (pricing_rules);
```

**Example JSONB `pricing_rules` value**:
```json
{
  "278": {"S": 2.00, "M": 3.00, "L": 4.00},
  "281": {"S": 2.00, "M": 3.00, "L": 4.00},
  "282": {"S": 2.00, "M": 3.00, "L": 4.00}
}
```

**Why Junction Table + JSONB?**
- ✅ Normalizes the combo → ingredient_group relationship
- ✅ JSONB handles variable ingredient pricing structures
- ✅ Easy to query: "Get all modifier pricing for combo X"
- ✅ FK integrity ensures referenced groups exist

**Alternative (NOT RECOMMENDED)**: Store entire `group` BLOB as single JSONB
- ❌ Loses normalization
- ❌ Can't enforce FK to ingredient_groups
- ❌ Harder to query

---

## Schema Design Summary

### New Tables Required

#### 1. `menuca_v3.ingredient_group_items` (Junction Table)
**Purpose**: Many-to-many relationship between ingredient_groups and ingredients  
**Source**: `ingredient_groups.item` BLOB (13,252 rows)  
**Expected Rows**: ~50,000-150,000

```sql
CREATE TABLE menuca_v3.ingredient_group_items (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  ingredient_group_id BIGINT NOT NULL REFERENCES menuca_v3.ingredient_groups(id) ON DELETE CASCADE,
  ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
  display_order INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(ingredient_group_id, ingredient_id)
);
```

---

#### 2. `menuca_v3.combo_group_modifier_pricing` (Junction + JSONB)
**Purpose**: Combo-specific modifier pricing rules  
**Source**: `combo_groups.group` BLOB (10,764 rows)  
**Expected Rows**: ~30,000-50,000

```sql
CREATE TABLE menuca_v3.combo_group_modifier_pricing (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  combo_group_id BIGINT NOT NULL REFERENCES menuca_v3.combo_groups(id) ON DELETE CASCADE,
  ingredient_group_id BIGINT NOT NULL REFERENCES menuca_v3.ingredient_groups(id) ON DELETE CASCADE,
  modifier_type VARCHAR(10) NOT NULL,
  pricing_rules JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(combo_group_id, ingredient_group_id, modifier_type)
);
```

---

### Modified Existing Tables

#### 1. `menuca_v3.dishes` - Add column
```sql
ALTER TABLE menuca_v3.dishes
ADD COLUMN availability_schedule JSONB DEFAULT NULL;

CREATE INDEX idx_dishes_availability ON menuca_v3.dishes USING GIN (availability_schedule);
```

---

#### 2. `menuca_v3.dish_modifiers` - Enhance schema
```sql
-- Recreate with enhanced columns:
DROP TABLE IF EXISTS menuca_v3.dish_modifiers CASCADE;

CREATE TABLE menuca_v3.dish_modifiers (
  id BIGSERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  dish_id BIGINT NOT NULL REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  ingredient_id BIGINT NOT NULL REFERENCES menuca_v3.ingredients(id) ON DELETE CASCADE,
  ingredient_group_id BIGINT REFERENCES menuca_v3.ingredient_groups(id) ON DELETE SET NULL,
  base_price DECIMAL(10,2) DEFAULT 0.00,
  price_by_size JSONB,
  modifier_type VARCHAR(10),
  is_included BOOLEAN DEFAULT false,
  display_order INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(dish_id, ingredient_id, ingredient_group_id),
  CHECK (base_price IS NOT NULL OR price_by_size IS NOT NULL)
);
```

---

#### 3. `menuca_v3.combo_groups` - Verify/add column
```sql
-- Check if combo_rules already exists, if not add it:
ALTER TABLE menuca_v3.combo_groups
ADD COLUMN IF NOT EXISTS combo_rules JSONB;

CREATE INDEX IF NOT EXISTS idx_combo_groups_rules 
ON menuca_v3.combo_groups USING GIN (combo_rules);
```

---

#### 4. `menuca_v3.combo_items` - Use as-is
No changes needed. Use existing table to store dishes from `combo_groups.dish` BLOB.

---

## Implementation Roadmap

### Phase 3: BLOB Deserialization (4-5 days)

#### Sub-Phase 3.1: `menu.hideOnDays` (Simple)
**Duration**: 0.5 day  
**Priority**: 🟡 Medium (only 865 rows affected)

**Tasks**:
1. Add `availability_schedule` column to `dishes` table
2. Create Python parser for PHP serialized day arrays
3. Transform to JSON: `{"hide_on_days": ["wed", "thu", ...]}`
4. Load to staging table for verification
5. Update `dishes` rows with availability data

**Success Criteria**:
- ✅ All 865 BLOB values parsed
- ✅ JSON structure validated
- ✅ Spot-check 10 samples for accuracy

---

#### Sub-Phase 3.2: `ingredient_groups.item` (Simple)
**Duration**: 1 day  
**Priority**: 🔴 High (required for ingredient group functionality)

**Tasks**:
1. Create `ingredient_group_items` junction table
2. Create Python parser for PHP serialized ingredient arrays
3. Generate junction records with display_order
4. Load to staging for verification
5. Insert into `ingredient_group_items`

**Success Criteria**:
- ✅ All 13,252 BLOB values parsed
- ✅ 50K-150K junction records created
- ✅ All ingredient_ids valid (exist in ingredients table)
- ✅ Display order preserved

---

#### Sub-Phase 3.3: `menuothers.content` (Complex)
**Duration**: 2 days  
**Priority**: 🔴 **CRITICAL** (70,363 rows, core functionality)

**Tasks**:
1. Enhance `dish_modifiers` table schema
2. Create robust Python parser for nested PHP structures
3. Handle multi-size pricing (comma-separated values)
4. Handle multiple ingredients per row
5. Validate dish_id and ingredient_id exist in V3
6. Generate 100K-350K modifier records
7. Load to staging for verification
8. Bulk insert into `dish_modifiers`

**Success Criteria**:
- ✅ All 70,363 BLOB values parsed
- ✅ 100K-350K modifier records created
- ✅ Multi-size pricing correctly stored in JSONB
- ✅ All FKs valid
- ✅ Spot-check 20 samples for price accuracy

---

#### Sub-Phase 3.4: `combo_groups` (3 BLOBs - Most Complex)
**Duration**: 2 days  
**Priority**: 🔴 High (complex business logic)

**Tasks**:
1. Create `combo_group_modifier_pricing` table
2. Create Python parsers for all 3 BLOB types:
   - `dish` BLOB → `combo_items` records
   - `options` BLOB → `combo_rules` JSONB
   - `group` BLOB → `combo_group_modifier_pricing` records
3. Handle nested structures and multiple modifier types
4. Load to staging for verification
5. Insert into respective tables

**Success Criteria**:
- ✅ All 10,764 non-empty BLOBs parsed
- ✅ `combo_items` populated from `dish` BLOB
- ✅ `combo_rules` JSONB structured correctly
- ✅ `combo_group_modifier_pricing` with valid FKs
- ✅ Spot-check 15 complex combo configurations

---

### Verification Checklist

After all BLOB deserialization:

```sql
-- 1. Verify dish availability
SELECT COUNT(*) FROM menuca_v3.dishes WHERE availability_schedule IS NOT NULL;
-- Expected: 865

-- 2. Verify ingredient group items
SELECT COUNT(*) FROM menuca_v3.ingredient_group_items;
-- Expected: 50,000-150,000

-- 3. Verify dish modifiers
SELECT COUNT(*) FROM menuca_v3.dish_modifiers;
-- Expected: 100,000-350,000

-- 4. Verify combo items
SELECT COUNT(*) FROM menuca_v3.combo_items WHERE combo_group_id IN (
  SELECT id FROM menuca_v3.combo_groups WHERE restaurant_id NOT IN (test_restaurant_ids)
);
-- Expected: Check against source

-- 5. Verify combo rules
SELECT COUNT(*) FROM menuca_v3.combo_groups WHERE combo_rules IS NOT NULL;
-- Expected: ~10,764

-- 6. Verify combo modifier pricing
SELECT COUNT(*) FROM menuca_v3.combo_group_modifier_pricing;
-- Expected: 30,000-50,000

-- 7. Check for orphaned records (should be 0)
SELECT COUNT(*) FROM menuca_v3.dish_modifiers dm
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.dishes d WHERE d.id = dm.dish_id);

SELECT COUNT(*) FROM menuca_v3.ingredient_group_items igi
WHERE NOT EXISTS (SELECT 1 FROM menuca_v3.ingredients i WHERE i.id = igi.ingredient_id);

-- 8. Check for invalid JSONB (should be 0)
SELECT COUNT(*) FROM menuca_v3.dishes WHERE availability_schedule IS NOT NULL 
AND NOT jsonb_typeof(availability_schedule) = 'object';

SELECT COUNT(*) FROM menuca_v3.combo_groups WHERE combo_rules IS NOT NULL 
AND NOT jsonb_typeof(combo_rules) = 'object';
```

---

## Risk Assessment

### High Risks 🔴

1. **Multi-size pricing complexity** (`menuothers.content`)
   - Risk: Price order doesn't match size order
   - Mitigation: Cross-reference with dish size configurations

2. **FK validation failures** (All BLOBs)
   - Risk: Referenced ingredient/dish IDs don't exist in V3
   - Mitigation: Load restaurants/dishes/ingredients FIRST, then BLOBs

3. **BLOB corruption** (All BLOBs)
   - Risk: Malformed PHP serialized data
   - Mitigation: Try-catch with error logging, continue processing

### Medium Risks 🟡

4. **Data type mismatches** (`combo_groups.group`)
   - Risk: Prices stored as strings, not decimals
   - Mitigation: Robust type casting with validation

5. **Empty/NULL BLOB handling**
   - Risk: Treats empty BLOB as error
   - Mitigation: Check for NULL/empty before parsing

---

## Next Steps

### 🎯 Immediate Actions

1. **User Review & Approval**
   - Review proposed schema changes
   - Approve new tables
   - Approve JSONB column additions
   - Approve `dish_modifiers` enhancements

2. **Phase 1 Prerequisite: Schema Creation**
   - Create 2 new tables
   - Modify 3 existing tables
   - Run migration scripts with Supabase MCP

3. **Proceed to Phase 2: Staging**
   - Load dump data (BLOB columns as TEXT)
   - Prepare for Phase 3 deserialization

---

## Decision Status

**User Decisions**:

1. ✅ **APPROVED** - Create `ingredient_group_items` junction table with pricing
2. ✅ **APPROVED** - Create `combo_group_modifier_pricing` junction table (with full-word modifier types)
3. ✅ **APPROVED** - Add `availability_schedule` JSONB column to `dishes`
4. ✅ **APPROVED** - Enhance `dish_modifiers` table schema (drop & recreate)
5. ✅ **APPROVED** - Add `combo_rules` JSONB column to `combo_groups`
6. ✅ **APPROVED** - Proceed with overall BLOB deserialization approach
7. ✅ **APPROVED** - Exclude 51,580 blank-name combo groups (migrate only 10,764 named combos)
8. ✅ **APPROVED** - Skip orphaned dish/ingredient IDs, generate exclusion reports
9. ✅ **APPROVED** - Skip missing/corrupt pricing BLOBs for modifier types
10. ✅ **APPROVED** - Use standard size order fallback (S, M, L, XL, XXL)
11. ✅ **APPROVED** - No test migration - process all data at once

**Status**: 🎉 **ALL 4 BLOB CASES APPROVED - READY FOR IMPLEMENTATION**

**Completed**: 
- BLOB Case #1 (menu.hideOnDays) 
- BLOB Case #2 (menuothers.content) 
- BLOB Case #3 (ingredient_groups.item + price)
- BLOB Case #4 (combo_groups.dish + options + group - 3 BLOBs)

**Next**: Proceed to Phase 1 - Schema Creation in MENU_CATALOG_MIGRATION_GUIDE.md

---

**END OF DOCUMENT**

