# Menu Relationships

> **Menu Hierarchy & Customization** - How dishes, modifiers, and templates connect

---

## 📋 Overview

The menu system has a **hierarchical structure**:
- Restaurants have Courses (categories)
- Courses have Dishes
- Dishes have Modifier Groups
- Modifier Groups have Dish Modifiers
- Dish Modifiers have Modifier Prices (by size)

Additionally, **templates** allow reusable modifier configurations.

---

## 🏗️ Hierarchy Structure

```
Restaurant
│
├── Course (Category)
│   │
│   ├── Dish
│   │   │
│   │   ├── Dish Price (base prices by size)
│   │   │
│   │   ├── Modifier Group
│   │   │   │
│   │   │   └── Dish Modifier
│   │   │       │
│   │   │       └── Dish Modifier Price (by size)
│   │   │
│   │   └── Modifier Group (another)
│   │       └── ...
│   │
│   └── Dish (another)
│       └── ...
│
└── Course (another category)
    └── ...
```

---

## 📊 Entity Relationship Diagram

```
┌─────────────────┐
│   restaurants   │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐          ┌──────────────────────────┐
│     courses     │          │ course_modifier_templates│
│   (categories)  │◄─────────┤    (reusable configs)    │
└────────┬────────┘   1:N    └────────────┬─────────────┘
         │ 1:N                            │ 1:N
         ▼                                ▼
┌─────────────────┐          ┌──────────────────────────┐
│     dishes      │          │ course_template_modifiers│
└────────┬────────┘          └──────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌──────────────────┐
│ dish_   │ │  modifier_groups │
│ prices  │ └────────┬─────────┘
└─────────┘          │ 1:N
                     ▼
              ┌──────────────────┐
              │  dish_modifiers  │
              └────────┬─────────┘
                       │ 1:N
                       ▼
              ┌────────────────────────┐
              │  dish_modifier_prices  │
              └────────────────────────┘
```

---

## 🔑 Key Relationships

### Dish → Modifier Chain

```sql
-- Full dish with modifiers query
SELECT 
    d.id as dish_id,
    d.name as dish_name,
    dp.size_label,
    dp.price as base_price,
    mg.id as group_id,
    mg.name as group_name,
    mg.is_required,
    mg.min_selections,
    mg.max_selections,
    dm.id as modifier_id,
    dm.name as modifier_name,
    dmp.size_variant,
    dmp.price as modifier_price
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id AND mg.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id AND dm.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifier_prices dmp ON dmp.dish_modifier_id = dm.id AND dmp.deleted_at IS NULL
WHERE d.id = :dish_id
AND d.deleted_at IS NULL
ORDER BY mg.display_order, dm.display_order, dmp.display_order;
```

### Template System

Templates allow **category-level modifier definitions** that apply to all dishes in that category:

```
Course
│
├── course_modifier_templates
│   │
│   └── course_template_modifiers
│
└── Dish
    │
    └── modifier_groups (course_template_id links to template)
        │
        └── dish_modifiers (copied from template or custom)
```

**Template Usage Patterns:**

| Pattern | Description | % of Groups |
|---------|-------------|-------------|
| Template-based | `course_template_id` is set | ~61% |
| Custom | `is_custom = true` | ~39% |

---

## 📝 Modifier Types

The `modifier_type` field categorizes modifiers:

| Type | Description | Example |
|------|-------------|---------|
| `custom_ingredients` | Toppings, add-ons | Pizza toppings |
| `extras` | Extra items | Extra cheese |
| `side_dishes` | Side options | Fries, salad |
| `drinks` | Beverage options | Pop, juice |
| `sauces` | Sauce choices | Ranch, BBQ |
| `bread` | Bread/crust options | Thin crust |
| `dressing` | Salad dressings | Italian, Caesar |
| `cooking_method` | Preparation style | Grilled, fried |
| `other` | Miscellaneous | Size, spice level |

---

## 💰 Pricing Structure

### Base Prices (`dish_prices`)

```sql
-- Dish with size variants
SELECT id, dish_id, size_code, size_label, price, is_default
FROM menuca_v3.dish_prices
WHERE dish_id = :dish_id
ORDER BY display_order;

-- Example output:
-- id | dish_id | size_code | size_label | price | is_default
-- 1  | 100     | S         | Small      | 8.99  | false
-- 2  | 100     | M         | Medium     | 11.99 | true
-- 3  | 100     | L         | Large      | 14.99 | false
```

### Modifier Prices (`dish_modifier_prices`)

```sql
-- Modifier prices by size
SELECT dmp.*, dm.name as modifier_name
FROM menuca_v3.dish_modifier_prices dmp
JOIN menuca_v3.dish_modifiers dm ON dm.id = dmp.dish_modifier_id
WHERE dmp.dish_id = :dish_id
AND dmp.deleted_at IS NULL
ORDER BY dm.display_order, dmp.display_order;

-- Example output (topping prices vary by size):
-- modifier_name | size_variant | price
-- Pepperoni     | Small        | 1.50
-- Pepperoni     | Medium       | 2.00
-- Pepperoni     | Large        | 2.50
```

---

## 🔄 Order Item Storage

When orders are placed, selected modifiers are **denormalized** into the `order_items.modifiers` JSONB field:

```json
{
  "selected_modifiers": [
    {
      "modifier_id": 12345,
      "name": "Extra Cheese",
      "price": 2.50,
      "quantity": 1
    },
    {
      "modifier_id": 12346,
      "name": "Pepperoni",
      "price": 3.00,
      "quantity": 1
    }
  ],
  "size_selected": "Large",
  "total_modifier_price": 5.50
}
```

This denormalization:
- Preserves prices at order time
- Allows menu changes without affecting historical orders
- Simplifies order retrieval

---

## ⚠️ Data Integrity Rules

### Required Validations

1. **Modifier Group Constraints**
   - If `is_required = true`, at least `min_selections` must be chosen
   - Cannot exceed `max_selections`

2. **Size Consistency**
   - Modifier prices should exist for all dish sizes
   - If missing, default to base price

3. **Soft Deletion Chain**
   - Deleting a dish should soft-delete all children
   - Check `deleted_at` at all levels

### Common Orphan Scenarios

| Scenario | Impact | Detection Query |
|----------|--------|-----------------|
| Modifiers without group | Won't display | `modifier_group_id IS NULL` |
| Prices without modifier | Won't price | Join check |
| Groups without dish | Won't display | `dish_id` missing |

---

## 📈 Statistics

| Table | Record Count |
|-------|-------------|
| courses | ~2,500 |
| dishes | ~24,277 |
| dish_prices | ~25,000 |
| modifier_groups | ~22,632 |
| dish_modifiers | ~358,499 |
| dish_modifier_prices | ~606,492 |

---

**Last Updated:** 2025-11-27

