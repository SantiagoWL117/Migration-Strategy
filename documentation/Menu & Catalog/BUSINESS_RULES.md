# Menu & Catalog Entity - Business Rules & Logic

**Schema**: `menuca_v3`  
**Purpose**: Guide for developers and AI models to understand Menu & Catalog business rules  
**Last Updated**: January 9, 2025

---

## Table of Contents

1. [Entity Overview](#entity-overview)
2. [Core Data Model](#core-data-model)
3. [Dishes & Availability](#dishes--availability)
4. [Dish Modifiers System](#dish-modifiers-system)
5. [Ingredient Groups System](#ingredient-groups-system)
6. [Combo Groups System](#combo-groups-system)
7. [Pricing Model](#pricing-model)
8. [Data Relationships](#data-relationships)
9. [Query Patterns](#query-patterns)
10. [Business Constraints](#business-constraints)

---

## Entity Overview

The Menu & Catalog entity manages restaurant menu structures, including:

- **Courses**: Menu categories (Appetizers, Entrees, Desserts, etc.)
- **Dishes**: Individual menu items with pricing
- **Ingredients**: Individual food components
- **Ingredient Groups**: Collections of related ingredients
- **Dish Modifiers**: Customization options for dishes
- **Combo Groups**: Meal deals and multi-item packages (staged for future)

**Key Principle**: Flexible, contextual pricing where the same ingredient can have different prices depending on the dish, size, or combo it's part of.

---

## Core Data Model

### Schema Structure

```
menuca_v3.restaurants (944 restaurants)
├── menuca_v3.courses (150 courses)
│   └── menuca_v3.dishes (5,417 dishes)
│       └── menuca_v3.dish_modifiers (2,922 modifiers)
│           ├── FK → dishes
│           ├── FK → ingredients
│           └── FK → ingredient_groups
│
├── menuca_v3.ingredient_groups (9,169 groups)
│   └── menuca_v3.ingredient_group_items (37,684 items)
│       ├── FK → ingredient_groups
│       └── FK → ingredients
│
├── menuca_v3.ingredients (31,542 ingredients)
│
└── menuca_v3.combo_groups (staged for future)
```

### Source Tracking

All records have source tracking fields:

- `source_system`: 'v1' or 'v2' (legacy system origin)
- `source_id`: Original ID from legacy system
- `legacy_v1_id`: V1 ID for cross-reference
- `legacy_v2_id`: V2 ID for cross-reference

**Usage**: Always include source tracking when migrating or syncing data.

---

## Dishes & Availability

### Dish Structure

**Table**: `menuca_v3.dishes`

**Core Fields**:
- `id`: V3 primary key (BIGSERIAL)
- `restaurant_id`: FK to restaurants (REQUIRED)
- `course_id`: FK to courses (OPTIONAL - some dishes have no course)
- `name`: Dish name (VARCHAR 500, REQUIRED)
- `description`: Dish description (TEXT, OPTIONAL)
- `base_price`: Single price (DECIMAL 10,2, OPTIONAL)
- `price_by_size`: Multi-size pricing (JSONB, OPTIONAL)
- `is_active`: Availability flag (BOOLEAN, default true)

### Pricing Rules

**Rule 1: Optional Pricing**
- Dishes do NOT require pricing at the base level
- Pricing can be contextual (defined in modifiers, combos, or size variations)
- `base_price` OR `price_by_size` can be NULL

**Rule 2: Multi-Size Pricing**
- Stored in `price_by_size` as JSONB
- Standard size codes: S, M, L, XL, XXL
- Format: `{"S": 12.99, "M": 15.99, "L": 18.99}`

**Example**:
```json
{
  "S": 12.99,
  "M": 15.99,
  "L": 18.99,
  "XL": 21.99
}
```

**Query Pattern**:
```sql
-- Get small size price:
SELECT price_by_size->>'S' AS small_price FROM dishes WHERE id = 123;

-- Get all available sizes:
SELECT jsonb_object_keys(price_by_size) AS size_code FROM dishes WHERE id = 123;
```

---

## Dish Modifiers System

**Table**: `menuca_v3.dish_modifiers`

**Purpose**: Dish-specific customization options with pricing overrides

### Business Logic

**Core Concept**: The same ingredient can have different prices on different dishes.

**Example**:
- "Extra Cheese" costs $0.25 on Pizza A
- "Extra Cheese" costs $0.50 on Pizza B
- "Extra Cheese" is FREE on Pizza C (included)

### Modifier Structure

**Fields**:
- `dish_id`: FK to dishes (REQUIRED)
- `ingredient_id`: FK to ingredients (REQUIRED)
- `ingredient_group_id`: FK to ingredient_groups (OPTIONAL - the group this modifier belongs to)
- `modifier_type`: Category code (VARCHAR 50)
- `base_price`: Single price (DECIMAL 10,2, OPTIONAL)
- `price_by_size`: Multi-size pricing (JSONB, OPTIONAL)
- `is_included`: Free topping flag (BOOLEAN)
- `display_order`: UI ordering (INTEGER)

### Modifier Types

**Standard Modifier Types** (stored as full words):

| Type | Full Name | Example |
|------|-----------|---------|
| `custom_ingredients` | Custom Ingredients | Pizza toppings, burger add-ons |
| `extras` | Extras | Extra cheese, double meat |
| `side_dishes` | Side Dishes | French fries, coleslaw |
| `drinks` | Drinks | Soft drinks, juices |
| `sauces` | Sauces | Dipping sauces, dressings |
| `bread` | Bread/Crust | Thin crust, garlic bread |
| `dressing` | Dressings | Ranch, Italian, Caesar |
| `cooking_method` | Cooking Method | Well done, rare, grilled |

**Usage**: Always store full words, not abbreviations (e.g., 'custom_ingredients', NOT 'ci')

---

### Pricing Logic

**Rule 1: Base Price (Single Price)**
- Used for uniform pricing across all sizes
- Example: "Extra Cheese" = $0.25 (any size)
- Stored in `base_price`

**Rule 2: Multi-Size Pricing**
- Used when modifier price varies by dish size
- Example: "Extra Cheese" on Small Pizza = $1.00, Large = $2.00
- Stored in `price_by_size` JSONB

**Example**:
```json
{
  "S": 1.00,
  "M": 1.50,
  "L": 2.00,
  "XL": 3.00
}
```

**Rule 3: Included Modifiers**
- `is_included = true` means the modifier is FREE
- Used for base toppings, included sides, etc.
- `base_price = 0.00` AND `is_included = true`

**Rule 4: Pricing Priority**
1. Check `base_price` first (single price)
2. If NULL, check `price_by_size` (size-based price)
3. Both can be NULL (price defined elsewhere, e.g., combo pricing)

---

### Query Patterns

**Get all modifiers for a dish**:
```sql
SELECT 
  dm.*,
  i.name AS ingredient_name,
  ig.name AS group_name
FROM dish_modifiers dm
LEFT JOIN ingredients i ON i.id = dm.ingredient_id
LEFT JOIN ingredient_groups ig ON ig.id = dm.ingredient_group_id
WHERE dm.dish_id = 123
ORDER BY dm.ingredient_group_id, dm.display_order;
```

**Get modifiers with pricing for medium size**:
```sql
SELECT 
  dm.ingredient_id,
  i.name,
  COALESCE(
    dm.base_price,
    (dm.price_by_size->>'M')::DECIMAL(10,2)
  ) AS price_for_medium
FROM dish_modifiers dm
JOIN ingredients i ON i.id = dm.ingredient_id
WHERE dm.dish_id = 123;
```

**Get free included modifiers**:
```sql
SELECT i.name
FROM dish_modifiers dm
JOIN ingredients i ON i.id = dm.ingredient_id
WHERE dm.dish_id = 123 AND dm.is_included = true;
```

---

### Real-World Examples

**Example 1: Pizza Toppings**
```
Dish: "Large Pepperoni Pizza" (ID: 456)

Modifiers:
- Pepperoni (INCLUDED, base_price = 0.00, is_included = true)
- Extra Cheese (base_price = 2.00)
- Mushrooms (price_by_size = {"S": 1.00, "M": 1.50, "L": 2.00})
- Olives (price_by_size = {"S": 1.00, "M": 1.50, "L": 2.00})
```

**Example 2: Burger Add-Ons**
```
Dish: "Classic Burger" (ID: 789)

Modifiers:
- Lettuce (INCLUDED, base_price = 0.00, is_included = true)
- Tomato (INCLUDED, base_price = 0.00, is_included = true)
- Cheese (base_price = 0.50)
- Bacon (base_price = 1.00)
- Avocado (base_price = 1.50)
```

---

## Ingredient Groups System

**Tables**: 
- `menuca_v3.ingredient_groups` (9,169 groups)
- `menuca_v3.ingredient_group_items` (37,684 items)

**Purpose**: Organize related ingredients for UI and business logic

### Business Logic

**Core Concept**: Ingredient groups create reusable sets of ingredients with their pricing.

**Example**:
- "Cheese Options" group contains: {Mozzarella, Cheddar, Parmesan, Feta}
- "Protein Options" group contains: {Chicken, Beef, Shrimp, Tofu}
- "Dipping Sauces" group contains: {Ranch, BBQ, Honey Mustard, Blue Cheese}

### Group Types

**Field**: `ingredient_groups.group_type` (VARCHAR 10)

**Common Types**:
- `e` = Extras (additional paid toppings)
- `ci` = Custom Ingredients (pizza toppings, burger add-ons)
- `sd` = Side Dishes (fries, coleslaw, salad)
- `d` = Drinks (soft drinks, juices)
- `sa` = Sauces (dipping sauces)
- `br` = Bread (bread types, crust options)
- `dr` = Dressings (salad dressings)
- `cm` = Cooking Method (rare, medium, well done)

**Note**: These are legacy codes from V1. Use `modifier_type` in `dish_modifiers` for clarity.

---

### Junction Table: ingredient_group_items

**Purpose**: Links ingredients to groups (many-to-many)

**Fields**:
- `ingredient_group_id`: FK to ingredient_groups (REQUIRED)
- `ingredient_id`: FK to ingredients (REQUIRED)
- `base_price`: Single price (DECIMAL 10,2, OPTIONAL)
- `price_by_size`: Multi-size pricing (JSONB, OPTIONAL)
- `is_included`: Free item flag (BOOLEAN)
- `display_order`: UI ordering (INTEGER)

**Business Rules**:

1. **Group-Level Default Pricing**
   - Pricing here serves as the DEFAULT for all dishes using this group
   - Can be overridden in `dish_modifiers` for specific dishes

2. **Pricing Hierarchy**
   ```
   dish_modifiers.base_price (highest priority - dish-specific)
   ↓
   ingredient_group_items.base_price (default for group)
   ↓
   NULL (no pricing defined)
   ```

3. **Display Order**
   - Preserves original array order from legacy BLOB
   - Used for consistent UI display across all dishes using this group

---

### Query Patterns

**Get all ingredients in a group**:
```sql
SELECT 
  i.id,
  i.name,
  igi.base_price,
  igi.price_by_size,
  igi.is_included,
  igi.display_order
FROM ingredient_group_items igi
JOIN ingredients i ON i.id = igi.ingredient_id
WHERE igi.ingredient_group_id = 123
ORDER BY igi.display_order;
```

**Get all groups containing a specific ingredient**:
```sql
SELECT 
  ig.id,
  ig.name,
  ig.group_type
FROM ingredient_groups ig
JOIN ingredient_group_items igi ON igi.ingredient_group_id = ig.id
WHERE igi.ingredient_id = 456;
```

**Get group with pricing for large size**:
```sql
SELECT 
  i.name,
  COALESCE(
    igi.base_price,
    (igi.price_by_size->>'L')::DECIMAL(10,2)
  ) AS price_for_large
FROM ingredient_group_items igi
JOIN ingredients i ON i.id = igi.ingredient_id
WHERE igi.ingredient_group_id = 123
ORDER BY igi.display_order;
```

---

### Real-World Examples

**Example 1: Pizza Cheese Options**
```
Group: "Cheese Options" (ID: 100, type: 'ci')

Items:
- Mozzarella (base_price = 0.00, is_included = true, display_order = 0)
- Cheddar (base_price = 0.50, display_order = 1)
- Parmesan (base_price = 0.75, display_order = 2)
- Feta (price_by_size = {"S": 0.50, "M": 0.75, "L": 1.00}, display_order = 3)
```

**Example 2: Burger Protein Options**
```
Group: "Protein Choices" (ID: 200, type: 'ci')

Items:
- Beef Patty (base_price = 0.00, is_included = true, display_order = 0)
- Chicken (base_price = 0.50, display_order = 1)
- Turkey (base_price = 0.75, display_order = 2)
- Veggie Patty (base_price = 1.00, display_order = 3)
```

---

### How Ingredient Groups Work with Dish Modifiers

**Relationship**:
```
ingredient_groups (container)
  ↓
ingredient_group_items (default pricing)
  ↓
dish_modifiers (dish-specific pricing override)
```

**Example Flow**:

1. **Restaurant creates group**: "Cheese Options" with 4 cheeses, default pricing
2. **Group applied to Pizza A**: Uses default pricing from group
3. **Group applied to Pizza B**: Override pricing in `dish_modifiers` (e.g., Extra Cheese costs more on specialty pizza)

**Query to get effective pricing**:
```sql
-- Get effective modifier pricing for a dish
-- (dish_modifiers takes precedence over ingredient_group_items)
SELECT 
  i.name,
  ig.name AS group_name,
  COALESCE(dm.base_price, igi.base_price) AS effective_base_price,
  COALESCE(dm.price_by_size, igi.price_by_size) AS effective_price_by_size,
  COALESCE(dm.is_included, igi.is_included, false) AS is_included
FROM ingredient_group_items igi
JOIN ingredients i ON i.id = igi.ingredient_id
JOIN ingredient_groups ig ON ig.id = igi.ingredient_group_id
LEFT JOIN dish_modifiers dm 
  ON dm.dish_id = :dish_id 
  AND dm.ingredient_id = igi.ingredient_id
  AND dm.ingredient_group_id = igi.ingredient_group_id
WHERE igi.ingredient_group_id = :group_id;
```

---

## Combo Groups System

**Status**: ⏳ **Staged for Future Implementation**

**Tables** (staged in `staging` schema):
- `staging.v1_combo_items_parsed` (4,439 rows)
- `staging.v1_combo_rules_parsed` (10,764 rows)
- `staging.v1_combo_group_modifier_pricing_parsed` (12,752 rows)

### Business Logic (Planned)

**Purpose**: Multi-item meal deals with special pricing and customization rules

**Example Combos**:
1. **"Pick 2 Pizzas" Deal**
   - Choose any 2 medium pizzas
   - $24.99 total (vs $15.99 each = $31.98)
   - Customize each pizza independently
   - Shared modifier pricing (toppings cost same on both)

2. **"Family Meal" Combo**
   - 1 Large Pizza + 10 Wings + 2 Liter Soda
   - Fixed items, customizable pizza
   - $29.99 bundle price

3. **"Build Your Own" Combo**
   - Choose: 1 Entrée + 1 Side + 1 Drink
   - Fixed price regardless of choices
   - $12.99

### Combo Components (Planned Schema)

**Component 1: combo_items** (Which dishes are in the combo)
- Links combo_group to specific dishes
- Example: "Family Meal" includes Dish IDs: 123 (Pizza), 456 (Wings), 789 (Soda)

**Component 2: combo_rules** (Configuration & constraints)
- Stored as JSONB
- Defines: item count, min/max selections, free modifiers, display settings
- Example:
  ```json
  {
    "item_count": 2,
    "modifier_rules": {
      "custom_ingredients": {
        "enabled": true,
        "min": 0,
        "max": 5,
        "free_quantity": 2
      }
    }
  }
  ```

**Component 3: combo_group_modifier_pricing** (Special combo pricing for modifiers)
- Ingredient group pricing specific to this combo
- Example: "Extra Cheese" costs $1.00 on regular pizza, but only $0.50 in this combo

### Implementation Notes (For Future)

1. **Load Data**: Import 3 staged tables to production
2. **FK Validation**: Ensure all dish_ids, ingredient_ids, ingredient_group_ids exist
3. **Pricing Logic**: Implement combo price calculations
4. **UI Flow**: Multi-step combo wizard (size → toppings → sides → drinks)

**Note**: Combo system is fully deserialized and ready, but not loaded to production yet.

---

## Pricing Model

### Core Pricing Principles

**1. Contextual Pricing**
- Same ingredient can have different prices in different contexts
- Dish → Modifier → Combo (each level can override pricing)

**2. Optional Base Pricing**
- Tables do NOT require base_price to be set
- Pricing can be defined at relationship level only
- CHECK constraints removed to support this model

**3. Multi-Size Support**
- All pricing fields support `price_by_size` JSONB
- Standard sizes: S, M, L, XL, XXL
- Fallback to base_price if size not specified

### Pricing Hierarchy (Highest to Lowest Priority)

```
1. combo_group_modifier_pricing.pricing_rules
   ↓ (if not in combo)
2. dish_modifiers.base_price or dish_modifiers.price_by_size
   ↓ (if no dish-specific override)
3. ingredient_group_items.base_price or ingredient_group_items.price_by_size
   ↓ (if no group default)
4. No pricing (modifier not available or price TBD)
```

### Implementation Examples

**Scenario 1: Uniform Pricing**
```sql
-- "Extra Bacon" costs $1.50 on every dish
INSERT INTO dish_modifiers (dish_id, ingredient_id, base_price)
VALUES (123, 456, 1.50);
```

**Scenario 2: Size-Based Pricing**
```sql
-- "Extra Cheese" varies by pizza size
INSERT INTO dish_modifiers (dish_id, ingredient_id, price_by_size)
VALUES (123, 789, '{"S": 1.00, "M": 1.50, "L": 2.00, "XL": 3.00}');
```

**Scenario 3: Included Modifier (Free)**
```sql
-- "Lettuce" is included for free
INSERT INTO dish_modifiers (dish_id, ingredient_id, base_price, is_included)
VALUES (123, 999, 0.00, true);
```

**Scenario 4: Group Default Pricing**
```sql
-- Set default price for "Cheddar" in "Cheese Options" group
INSERT INTO ingredient_group_items (ingredient_group_id, ingredient_id, base_price)
VALUES (100, 456, 0.50);

-- Then link to dishes using this group (inherits 0.50 default)
-- Override for specific dish if needed
INSERT INTO dish_modifiers (dish_id, ingredient_id, ingredient_group_id, base_price)
VALUES (789, 456, 100, 0.75);  -- Costs more on specialty pizza
```

---

## Data Relationships

### Entity Relationship Diagram

```
restaurants
├── courses
│   └── dishes
│       └── dish_modifiers
│           ├── → ingredients
│           └── → ingredient_groups
│
├── ingredient_groups
│   └── ingredient_group_items
│       └── → ingredients
│
└── ingredients (no parent - can be restaurant-specific or global)
```

### Foreign Key Rules

**restaurants (Parent of Everything)**
- `courses.restaurant_id` → `restaurants.id` (CASCADE DELETE)
- `dishes.restaurant_id` → `restaurants.id` (CASCADE DELETE)
- `ingredient_groups.restaurant_id` → `restaurants.id` (CASCADE DELETE)
- `ingredients.restaurant_id` → `restaurants.id` (CASCADE DELETE) - if restaurant-specific

**courses (Parent of dishes)**
- `dishes.course_id` → `courses.id` (SET NULL)
  - NULL allowed: some dishes have no course

**dishes (Parent of dish_modifiers)**
- `dish_modifiers.dish_id` → `dishes.id` (CASCADE DELETE)
  - Delete dish → all modifiers deleted

**ingredients (Referenced by many)**
- `dish_modifiers.ingredient_id` → `ingredients.id` (CASCADE DELETE)
- `ingredient_group_items.ingredient_id` → `ingredients.id` (CASCADE DELETE)

**ingredient_groups (Parent of ingredient_group_items)**
- `ingredient_group_items.ingredient_group_id` → `ingredient_groups.id` (CASCADE DELETE)
- `dish_modifiers.ingredient_group_id` → `ingredient_groups.id` (SET NULL)

---

## Query Patterns

### Common Use Cases

**1. Get Complete Menu for Restaurant**
```sql
SELECT 
  c.name AS course_name,
  d.name AS dish_name,
  d.base_price,
  d.price_by_size,
  d.is_active,
  d.availability_schedule
FROM courses c
LEFT JOIN dishes d ON d.course_id = c.id
WHERE c.restaurant_id = :restaurant_id
  AND c.is_active = true
  AND d.is_active = true
ORDER BY c.display_order, d.display_order;
```

**2. Get Dish with All Modifiers**
```sql
SELECT 
  d.name AS dish_name,
  i.name AS modifier_name,
  ig.name AS group_name,
  dm.modifier_type,
  dm.base_price,
  dm.price_by_size,
  dm.is_included,
  dm.display_order
FROM dishes d
JOIN dish_modifiers dm ON dm.dish_id = d.id
LEFT JOIN ingredients i ON i.id = dm.ingredient_id
LEFT JOIN ingredient_groups ig ON ig.id = dm.ingredient_group_id
WHERE d.id = :dish_id
ORDER BY ig.name, dm.display_order;
```

**3. Check Dish Availability**
```sql
-- Check if dish is active
SELECT d.*
FROM dishes d
WHERE d.id = :dish_id
  AND d.is_active = true;
```

**4. Get Effective Modifier Price**
```sql
-- Get price for modifier on specific dish (dish override or group default)
SELECT 
  i.name,
  COALESCE(
    dm.base_price,
    igi.base_price,
    0.00
  ) AS effective_price
FROM ingredients i
LEFT JOIN dish_modifiers dm 
  ON dm.ingredient_id = i.id 
  AND dm.dish_id = :dish_id
LEFT JOIN ingredient_group_items igi 
  ON igi.ingredient_id = i.id
  AND igi.ingredient_group_id = :group_id
WHERE i.id = :ingredient_id;
```

**5. Get Multi-Size Price**
```sql
-- Get price for specific size
SELECT 
  name,
  COALESCE(
    (price_by_size->>:size_code)::DECIMAL(10,2),
    base_price,
    0.00
  ) AS price_for_size
FROM dishes
WHERE id = :dish_id;
```

---

## Business Constraints

### Data Integrity Rules

**1. Restaurant Ownership**
- Every menu item MUST belong to exactly one restaurant
- No global dishes (all restaurant-specific)
- Exception: Ingredients CAN be global (ingredient_groups handle restaurant-specific grouping)

**2. Pricing Flexibility**
- Base pricing is OPTIONAL at all levels
- `base_price` and `price_by_size` can both be NULL
- Pricing is contextual (defined at relationship level)

**3. Modifier Relationships**
- `dish_modifiers` MUST reference a valid dish
- `dish_modifiers` MUST reference a valid ingredient
- `dish_modifiers.ingredient_group_id` is OPTIONAL (can be NULL)

**4. Group Membership**
- Ingredients can belong to multiple groups
- Junction table enforces UNIQUE(ingredient_group_id, ingredient_id)
- No duplicate ingredient in same group

**5. Availability**
- `is_active = false` completely hides item from menu

### Business Validation Rules

**1. Price Validation**
- Prices MUST be >= 0.00
- Prices SHOULD be <= 50.00 (reasonable upper limit)
- Multi-size prices MUST use valid size codes (S, M, L, XL, XXL)

**2. Name Validation**
- Names MUST NOT be blank/empty
- Names SHOULD be <= 500 characters
- Blank-name records were excluded during migration

**3. Display Order**
- Display order SHOULD be unique within a group
- Display order MUST be >= 0
- Used for consistent UI ordering

**4. Source Tracking**
- All records MUST have `source_system` ('v1' or 'v2')
- All records MUST have `source_id` (original legacy ID)
- Used for auditing and troubleshooting

---

## Migration Notes

### Data Quality Decisions

**Exclusions During Migration**:
1. ❌ Blank-name records (26.6% of source data)
2. ❌ Test restaurant data (5 restaurants)
3. ❌ V1 hidden records (no audit trail, mostly junk)
4. ✅ V2 disabled records (migrated as `is_active = false`)
5. ❌ Orphaned records (invalid FK references)

**Result**: 87,828 high-quality records in production (100% FK integrity)

### Schema Evolution

**Changes from Legacy V1/V2**:
1. ✅ BLOB columns deserialized to JSONB/relational
2. ✅ CHECK constraints removed (contextual pricing)
3. ✅ Junction tables added (many-to-many relationships)
4. ✅ Source tracking added (audit trail)
5. ✅ Flexible pricing model (base_price OR price_by_size OR both NULL)

---

## Future Enhancements

### Planned Features

1. **Combo System** (Ready to Load)
   - 27,955 records staged
   - Full BLOB deserialization complete
   - Awaiting business testing

2. **V2 Menu Data** (Low Priority)
   - V2 restaurant-specific courses, dishes, ingredients
   - Can be merged with V1 data using source tracking

3. **Dish Images**
   - `image_url` column exists but not populated
   - Requires CDN migration

4. **Nutritional Information**
   - New feature for V3
   - Schema enhancement needed

5. **Allergen Tracking**
   - Health & safety requirement
   - Schema enhancement needed

---

## Quick Reference

### Key Tables
- `restaurants`: 944 restaurants
- `courses`: 150 courses
- `dishes`: 5,417 dishes
- `ingredients`: 31,542 ingredients
- `ingredient_groups`: 9,169 groups
- `ingredient_group_items`: 37,684 items
- `dish_modifiers`: 2,922 modifiers

### Key JSONB Fields
- `dishes.price_by_size`: Multi-size pricing
- `dish_modifiers.price_by_size`: Modifier multi-size pricing
- `ingredient_group_items.price_by_size`: Group default multi-size pricing

### Key Source Tracking
- `source_system`: 'v1' or 'v2'
- `source_id`: Original legacy ID
- `legacy_v1_id`: Cross-reference to V1
- `legacy_v2_id`: Cross-reference to V2

---

**For migration details, see**: `MIGRATION_SUMMARY.md`  
**For BLOB solutions, see**: `BLOB_DESERIALIZATION_SOLUTIONS.md`

**Last Updated**: January 9, 2025  
**Schema Version**: menuca_v3 (production)

