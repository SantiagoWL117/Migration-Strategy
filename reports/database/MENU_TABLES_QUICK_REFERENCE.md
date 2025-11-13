# Menu Tables Quick Reference Guide

**Quick Access:** Essential tables for courses, dishes, prices, and modifiers  
**Last Updated:** 2025-11-11

---

## 📋 Quick Table Summary

| # | Table Name | Purpose | Record Count | Key Info |
|---|------------|---------|--------------|----------|
| 1 | **courses** | Menu categories/sections | 2,309 active | Groups dishes together |
| 2 | **dishes** | Menu items | 22,504 | Individual food/drink items |
| 3 | **dish_prices** | Dish pricing | 21,431 | Includes size variants |
| 4 | **dish_modifiers** | Customization options | 188,990 | Extra cheese, no onions, etc. |
| 5 | **dish_modifier_prices** | Modifier pricing | 327,436 | Price by size variant |
| 6 | **modifier_groups** | Modifier organization | 11,104 | Groups modifiers logically |

---

## 🎯 Quick Access by Use Case

### "I need to..."

#### **Display a Restaurant Menu**
```sql
Tables needed: courses → dishes → dish_prices
```

#### **Show Dish Customization Options**
```sql
Tables needed: dishes → modifier_groups → dish_modifiers → dish_modifier_prices
```

#### **Calculate Order Total**
```sql
Tables needed: 
- dishes → dish_prices (base price)
- dish_modifiers → dish_modifier_prices (add-on prices)
```

#### **Update Menu Prices**
```sql
Tables to update:
- dish_prices (base dish pricing)
- dish_modifier_prices (modifier pricing)
```

#### **Add New Dish with Modifiers**
```sql
Insert order:
1. dishes (create dish)
2. dish_prices (set pricing)
3. modifier_groups (create groups like "Size", "Toppings")
4. dish_modifiers (add individual modifiers)
5. dish_modifier_prices (set modifier prices)
```

---

## 🗺️ Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        Restaurant                            │
│                         (id: 349)                            │
└──────────────────┬───────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
  ┌─────────┐         ┌──────────────┐
  │ Courses │         │Dish Modifiers│
  │         │         │(restaurant-  │
  │ 2,309   │         │ level only)  │
  └────┬────┘         └──────────────┘
       │
       │ groups dishes into categories
       │
       ▼
  ┌─────────────────────────────────────────────────┐
  │                    Dishes                       │
  │                                                 │
  │  22,504 menu items                             │
  └───┬─────────────────────┬───────────────────┬───┘
      │                     │                   │
      │                     │                   │
      ▼                     ▼                   ▼
┌────────────┐    ┌──────────────────┐   ┌──────────────┐
│Dish Prices │    │ Modifier Groups  │   │Other Related │
│            │    │                  │   │              │
│ 21,431     │    │ 11,104           │   │- Translations│
│            │    │                  │   │- Allergens   │
│Size-based  │    │Organization +    │   │- Inventory   │
│pricing     │    │selection rules   │   │- Reviews     │
└────────────┘    └────────┬─────────┘   └──────────────┘
                           │
                           │ groups modifiers
                           │
                           ▼
                  ┌─────────────────┐
                  │ Dish Modifiers  │
                  │                 │
                  │ 188,990         │
                  │                 │
                  │Individual       │
                  │customizations   │
                  └────────┬────────┘
                           │
                           │ pricing per size
                           │
                           ▼
                  ┌──────────────────────┐
                  │Dish Modifier Prices  │
                  │                      │
                  │ 327,436              │
                  │                      │
                  │Price by size variant │
                  └──────────────────────┘
```

---

## 🔑 Primary Keys & Foreign Keys

### Courses
```
courses.id → dish.course_id (1-to-many)
```

### Dishes (Hub Table)
```
dishes.id → dish_prices.dish_id (1-to-many)
dishes.id → modifier_groups.dish_id (1-to-many)
dishes.id → dish_modifiers.dish_id (1-to-many)
dishes.id → dish_modifier_prices.dish_id (1-to-many)
```

### Modifiers (Two-Level Hierarchy)
```
modifier_groups.id → dish_modifiers.modifier_group_id (1-to-many)
dish_modifiers.id → dish_modifier_prices.dish_modifier_id (1-to-many)
```

---

## 💰 Pricing Structure Examples

### Example 1: Simple Single-Price Dish
**Dish:** Caesar Salad (dish_id: 100)

**dish_prices:**
```
id: 1, dish_id: 100, size_variant: NULL, price: 12.99
```

**Total:** $12.99

---

### Example 2: Multi-Size Pizza
**Dish:** Margherita Pizza (dish_id: 200)

**dish_prices:**
```
id: 10, dish_id: 200, size_variant: "Small 10\"",  price: 12.99
id: 11, dish_id: 200, size_variant: "Medium 12\"", price: 15.99
id: 12, dish_id: 200, size_variant: "Large 14\"",  price: 18.99
```

**modifier_groups:**
```
id: 50, dish_id: 200, name: "Extra Toppings", max_selections: 5
```

**dish_modifiers:**
```
id: 100, modifier_group_id: 50, name: "Extra Cheese"
id: 101, modifier_group_id: 50, name: "Pepperoni"
id: 102, modifier_group_id: 50, name: "Mushrooms"
```

**dish_modifier_prices:**
```
Extra Cheese (modifier_id: 100):
  Small:  $1.50
  Medium: $2.00
  Large:  $2.50

Pepperoni (modifier_id: 101):
  Small:  $2.00
  Medium: $2.50
  Large:  $3.00

Mushrooms (modifier_id: 102):
  Small:  $1.00
  Medium: $1.50
  Large:  $2.00
```

**Order Calculation:**
```
Medium Pizza: $15.99
+ Extra Cheese (Medium): $2.00
+ Pepperoni (Medium): $2.50
= Total: $20.49
```

---

### Example 3: Free Modifiers (Preferences)
**Dish:** Burger (dish_id: 300)

**dish_prices:**
```
id: 20, dish_id: 300, size_variant: NULL, price: 10.99
```

**modifier_groups:**
```
id: 60, dish_id: 300, name: "Preferences", is_required: false
```

**dish_modifiers:**
```
id: 200, modifier_group_id: 60, name: "No Onions"
id: 201, modifier_group_id: 60, name: "No Pickles"
id: 202, modifier_group_id: 60, name: "Extra Lettuce"
```

**dish_modifier_prices:**
```
All preferences: price: $0.00 (free)
```

**Total:** $10.99 (same regardless of selections)

---

## 📊 Field Reference

### Most Important Fields

#### courses
- `restaurant_id` - Which restaurant
- `name` - Category name
- `display_order` - Sort order
- `is_active` - Show/hide
- `deleted_at` - Soft delete

#### dishes
- `restaurant_id` - Which restaurant
- `course_id` - Which category
- `name` - Dish name
- `description` - Description
- `display_order` - Sort order
- `is_active` - Available?
- `has_customization` - Has modifiers?
- `deleted_at` - Soft delete

#### dish_prices
- `dish_id` - Which dish
- `size_variant` - Size name (or NULL)
- `price` - Price amount
- `display_order` - Sort order
- `is_active` - Available?

#### modifier_groups
- `dish_id` - Which dish
- `name` - Group name
- `is_required` - Must select?
- `min_selections` - Minimum picks
- `max_selections` - Maximum picks
- `display_order` - Sort order

#### dish_modifiers
- `dish_id` - Which dish
- `modifier_group_id` - Which group
- `name` - Modifier name
- `modifier_type` - Category
- `is_default` - Pre-selected?
- `display_order` - Sort order

#### dish_modifier_prices
- `dish_modifier_id` - Which modifier
- `dish_id` - Which dish
- `size_variant` - Size (matches dish_prices)
- `price` - Price amount (0.00 = free)
- `is_active` - Available?

---

## 🔍 Common Queries

### Get all dishes in a course
```sql
SELECT d.* 
FROM menuca_v3.dishes d
WHERE d.course_id = 123
  AND d.is_active = true
  AND d.deleted_at IS NULL
ORDER BY d.display_order;
```

### Get all prices for a dish
```sql
SELECT dp.* 
FROM menuca_v3.dish_prices dp
WHERE dp.dish_id = 456
  AND dp.is_active = true
  AND dp.deleted_at IS NULL
ORDER BY dp.display_order;
```

### Get all modifier groups for a dish
```sql
SELECT mg.* 
FROM menuca_v3.modifier_groups mg
WHERE mg.dish_id = 789
ORDER BY mg.display_order;
```

### Get all modifiers in a group
```sql
SELECT dm.* 
FROM menuca_v3.dish_modifiers dm
WHERE dm.modifier_group_id = 50
  AND dm.deleted_at IS NULL
ORDER BY dm.display_order;
```

### Get modifier prices for a specific size
```sql
SELECT dm.name, dmp.price
FROM menuca_v3.dish_modifiers dm
JOIN menuca_v3.dish_modifier_prices dmp ON dm.id = dmp.dish_modifier_id
WHERE dm.dish_id = 200
  AND dmp.size_variant = 'Medium 12"'
  AND dm.deleted_at IS NULL
  AND dmp.is_active = true
ORDER BY dm.display_order;
```

---

## ⚠️ Important Rules

### Soft Deletes
✅ **DO:** Use `UPDATE table SET deleted_at = NOW() WHERE id = X`  
❌ **DON'T:** Use `DELETE FROM table WHERE id = X`

### Querying Active Records
✅ **DO:** Always include:
```sql
WHERE is_active = true 
  AND deleted_at IS NULL
```

### Size Variants
- NULL = single-size dish
- String value = specific size (e.g., "Medium 12\"")
- **Must match** between `dish_prices.size_variant` and `dish_modifier_prices.size_variant`

### Modifier Selection Rules
- `min_selections = 0, max_selections = 0` → Read-only display
- `min_selections = 0, max_selections = 1` → Optional single choice
- `min_selections = 1, max_selections = 1` → Required single choice
- `min_selections = 0, max_selections = N` → Optional multi-select (up to N)
- `min_selections = N, max_selections = M` → Required multi-select (N to M)

### Display Order
- Lower numbers appear first
- Default: 0
- Gaps are OK (allows re-ordering without renumbering all records)

---

## 🛠️ Testing Connection

```bash
# Windows (PowerShell)
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT COUNT(*) FROM menuca_v3.dishes;"
```

---

## 📚 Related Documentation

- **Full Schema Details:** `MENU_DATA_TABLES_STRUCTURE.md`
- **Database Connection:** `.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`
- **V3 Schema Overview:** `Database/V3_MERMAID_SCHEMA.md`

---

*Quick reference for developers working with Menu.ca V3 database*

