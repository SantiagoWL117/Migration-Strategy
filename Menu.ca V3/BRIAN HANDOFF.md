# Menu.ca V3 Schema - Menu Data Structure

## Overview

The `menuca_v3` schema stores menu data for restaurants, supporting both **normal dishes** (individual menu items) and **combo dishes** (meal deals with customization options). This document explains how these structures work using real examples from **Joes Family Pizzeria** (V3 ID: 636).

---

## Core Tables Hierarchy

```
restaurants
    └── courses (categories like "Spotlight Special", "Pizzas", etc.)
            └── dishes (individual menu items)
                    ├── dish_prices (base pricing)
                    ├── modifier_groups (customization groups)
                    │       └── dish_modifiers (individual options)
                    │               └── dish_modifier_prices (option pricing)
                    ├── dish_combo_groups (links to combo configurations)
                    └── dish_availability (day-based visibility)
```

---

## Example 1: Normal Dish - "The People's Pie"

A **normal dish** is a standalone menu item with optional modifiers for customization.

### Dish Record

| Field             | Value                    |
| ----------------- | ------------------------ |
| **id**            | 173660                   |
| **name**          | The People's Pie         |
| **course_id**     | 6412 (Spotlight Special) |
| **is_combo**      | FALSE                    |
| **restaurant_id** | 636                      |

### Dish Price

| dish_id | size_variant | price  |
| ------- | ------------ | ------ |
| 173660  | Standard     | $24.99 |

### Modifier Groups

Normal dishes have **modifier_groups** attached directly to the dish:

| id    | name                          | min_selections | max_selections | free_items |
| ----- | ----------------------------- | -------------- | -------------- | ---------- |
| 40903 | Crust Type                    | 0              | 1              | 0          |
| 40904 | Pizza Toppings                | 0              | 1              | 0          |
| 40905 | BASE Sauce for PIZZA          | 0              | 1              | 0          |
| 40906 | BASE CHEESE                   | 0              | 1              | 0          |
| 40907 | EXTRA BASE Sauce for PIZZA    | 0              | 1              | 0          |
| 40908 | Stuffed Crust with Mozzarella | 0              | 1              | 0          |

### Dish Modifiers (options within groups)

Each modifier group contains individual modifier options:

| group_name | modifier_name     | modifier_type |
| ---------- | ----------------- | ------------- |
| Crust Type | Regular Crust     | bread         |
| Crust Type | Gluten Free Crust | bread         |
| Crust Type | Thick Crust       | bread         |
| Crust Type | Deep Dish Crust   | bread         |
| Crust Type | Thin Crust        | bread         |
| ...        | ...               | ...           |

### Dish Modifier Prices

Each modifier can have different prices per size:

| modifier_name            | size_variant | price  |
| ------------------------ | ------------ | ------ |
| Regular Crust            | Standard     | $0.00  |
| Gluten Free Crust        | Small        | $0.00  |
| Gluten Free Crust        | Medium       | $0.00  |
| Deep Dish Crust          | Standard     | $1.50  |
| Thick Garlic Bread Crust | Standard     | $2.99  |
| Double Cheese            | Standard     | $11.98 |
| Extra Cheese             | Standard     | $3.99  |

### Normal Dish Data Flow

```
The People's Pie (dish)
    ├── $24.99 (dish_price)
    └── Modifier Groups:
            ├── Crust Type
            │       ├── Regular Crust ($0.00)
            │       ├── Gluten Free Crust ($0.00)
            │       ├── Thick Crust ($1.00)
            │       └── Deep Dish Crust ($1.50)
            ├── Pizza Toppings
            │       ├── Pepperoni ($3.99)
            │       ├── Mushrooms ($3.99)
            │       └── ...
            └── BASE CHEESE
                    ├── Regular Mozzarella ($0.00)
                    └── Vegan Cheese ($4.99)
```

---

## Example 2: Combo Dish - "Spotlight Special Large Pizza"

A **combo dish** is a meal deal that references one or more **combo groups** for its customization options. Combo dishes do NOT have their own `modifier_groups` - they inherit customization from `combo_groups`.

### Dish Record

| Field             | Value                         |
| ----------------- | ----------------------------- |
| **id**            | 173659                        |
| **name**          | Spotlight Special Large Pizza |
| **course_id**     | 6412 (Spotlight Special)      |
| **is_combo**      | TRUE                          |
| **restaurant_id** | 636                           |

### Dish Price

| dish_id | size_variant | price  |
| ------- | ------------ | ------ |
| 173659  | Standard     | $29.99 |

### Combo Group Link (dish_combo_groups)

Combo dishes are linked to **combo_groups** via the junction table:

| dish_id | combo_group_id | combo_group_name         |
| ------- | -------------- | ------------------------ |
| 173659  | 2250           | 1 Large Pizza 5 Toppings |

### Combo Group Structure

The combo group defines the customization sections:

**combo_groups** (ID: 2250)
| Field | Value |
|-------|-------|
| name | 1 Large Pizza 5 Toppings |
| restaurant_id | 636 |
| source_id | 7562 (V1 ID) |

**combo_group_sections** (attached to combo_group 2250)

| section_type       | use_header                     | display_order | min_selection | max_selection | free_items |
| ------------------ | ------------------------------ | ------------- | ------------- | ------------- | ---------- |
| bread              | Crust type                     | 1             | 0             | 0             | 0          |
| cooking_method     | Stuffed Crust with Mozzarella? | 2             | 1             | 1             | 0          |
| dressing           | Base Sauce                     | 3             | 1             | 1             | 0          |
| extras             | Extras                         | 4             | 0             | 1             | 0          |
| side_dish          | Base Cheese                    | 5             | 1             | 1             | 0          |
| custom_ingredients | First 5 Toppings Free          | 6             | 0             | 0             | **5**      |

> Note: `free_items = 5` in custom_ingredients means the first 5 toppings are included free!

### Combo Data Flow

```
Spotlight Special Large Pizza (dish, is_combo=TRUE)
    ├── $29.99 (dish_price)
    └── dish_combo_groups → links to:
            └── Combo Group: "1 Large Pizza 5 Toppings"
                    └── combo_group_sections:
                            ├── bread: "Crust type"
                            │       └── combo_modifier_groups
                            │               └── combo_modifiers
                            │                       └── combo_modifier_prices
                            ├── cooking_method: "Stuffed Crust with Mozzarella?"
                            ├── dressing: "Base Sauce"
                            ├── extras: "Extras"
                            ├── side_dish: "Base Cheese"
                            └── custom_ingredients: "First 5 Toppings Free" (5 free!)
```

---

## Key Differences: Normal vs Combo Dishes

| Aspect                    | Normal Dish                          | Combo Dish                                                                            |
| ------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------- |
| **is_combo**              | FALSE                                | TRUE                                                                                  |
| **Customization Source**  | `modifier_groups` → `dish_modifiers` | `combo_groups` → `combo_group_sections` → `combo_modifier_groups` → `combo_modifiers` |
| **Modifier Prices Table** | `dish_modifier_prices`               | `combo_modifier_prices`                                                               |
| **Reusability**           | Modifiers are dish-specific          | Combo groups can be shared across multiple dishes                                     |

---

## Section Type Mapping

The `section_type` in `combo_group_sections` maps to specific customization categories:

| section_type            | Description         | Example                           |
| ----------------------- | ------------------- | --------------------------------- |
| bread                   | Crust/bread options | Regular, Thin, Thick, Gluten Free |
| custom_ingredients      | Toppings            | Pepperoni, Mushrooms, Onions      |
| dressing                | Sauces for base     | Marinara, BBQ, Alfredo            |
| sauces                  | Dipping sauces      | Ranch, Garlic Butter              |
| side_dish / side_dishes | Side options        | Cheese types                      |
| extras                  | Add-ons             | Extra toppings, premium items     |
| cooking_method          | Preparation style   | Stuffed crust, well-done          |
| drinks                  | Beverage options    | Pepsi, Coke, Sprite               |

---

## Hide on Days Functionality

Dishes can be hidden on specific days using:

1. **dishes.hide_option_enabled** = TRUE
2. **dish_availability** table entries

### Example: "WILD Wednesdays HIDE"

This dish is only visible on Wednesday:

**dishes table:**
| id | name | hide_option_enabled |
|----|------|---------------------|
| 173664 | WILD Wednesdays HIDE | TRUE |

**dish_availability table:**
| dish_id | day_of_week | is_hidden |
|---------|-------------|-----------|
| 173664 | 0 (Sunday) | TRUE |
| 173664 | 1 (Monday) | TRUE |
| 173664 | 2 (Tuesday) | TRUE |
| 173664 | 4 (Thursday) | TRUE |
| 173664 | 5 (Friday) | TRUE |
| 173664 | 6 (Saturday) | TRUE |

> **Result:** Hidden every day except Wednesday (day 3)

---

## SQL Query Examples

### Get all dishes for a restaurant with prices

```sql
SELECT d.id, d.name, d.is_combo, dp.price, c.name as category
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON d.course_id = c.id
LEFT JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id
WHERE d.restaurant_id = 636 AND d.deleted_at IS NULL
ORDER BY c.display_order, d.display_order;
```

### Get combo groups for a combo dish

```sql
SELECT d.name as dish_name, cg.name as combo_group_name
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_combo_groups dcg ON dcg.dish_id = d.id
JOIN menuca_v3.combo_groups cg ON dcg.combo_group_id = cg.id
WHERE d.id = 173659 AND cg.deleted_at IS NULL;
```

### Get modifier options for a normal dish

```sql
SELECT mg.name as group_name, dm.name as modifier_name, dmp.price
FROM menuca_v3.modifier_groups mg
JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
JOIN menuca_v3.dish_modifier_prices dmp ON dmp.dish_modifier_id = dm.id
WHERE mg.dish_id = 173660
  AND mg.deleted_at IS NULL
  AND dm.deleted_at IS NULL
ORDER BY mg.display_order, dm.display_order;
```

### Get visible dishes for current day

```sql
SELECT d.* FROM menuca_v3.dishes d
WHERE d.restaurant_id = 636
  AND d.is_active = TRUE
  AND d.deleted_at IS NULL
  AND (
      d.hide_option_enabled = FALSE
      OR NOT EXISTS (
          SELECT 1 FROM menuca_v3.dish_availability da
          WHERE da.dish_id = d.id
            AND da.day_of_week = EXTRACT(DOW FROM CURRENT_TIMESTAMP)
            AND da.is_hidden = TRUE
      )
  );
```

---

## Summary Statistics for Joes Family Pizzeria

| Table                          | Count |
| ------------------------------ | ----- |
| Courses                        | 37    |
| Dishes (total)                 | 374   |
| - Combo dishes                 | 73    |
| - Normal dishes                | 301   |
| Dish Prices                    | 651   |
| Combo Groups                   | 80    |
| Combo Group Sections           | 242   |
| Dish Combo Group Links         | 171   |
| Modifier Groups                | 343   |
| Dish Modifiers                 | 3,394 |
| Dish Modifier Prices           | 7,174 |
| Dish Availability (hide rules) | 148   |
