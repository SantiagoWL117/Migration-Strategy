# Agent Handoff: `get_restaurant_menu` Function

> **Purpose:** Retrieve complete menu structure for public display  
> **Schema:** `menuca_v3`  
> **Test Restaurant:** Centertown Donair & Pizza (ID: 131)  
> **Last Updated:** 2025-12-12

---

## QUICK REFERENCE

### Function Call

```sql
SELECT menuca_v3.get_restaurant_menu(131);  -- Returns JSONB
```

### RPC Call (Frontend)

```typescript
const { data } = await supabase.rpc('get_restaurant_menu', {
  p_restaurant_id: 131,
  p_language_code: 'en'  // Optional, defaults to 'en'
});
```

---

## FUNCTION OVERVIEW

The `get_restaurant_menu` function returns a **complete nested JSON structure** containing:

```
Restaurant
  └── Courses[]
       └── Dishes[]
            ├── Prices[]
            └── Modifier Groups[]
                 └── Modifiers[]
                      └── Modifier Prices[]
```

### Key Filters Applied

| Table | Filter | Purpose |
|-------|--------|---------|
| `restaurants` | `status = 'active'` | Only active restaurants |
| `courses` | `is_active = true` | Hide disabled courses |
| `dishes` | `is_active = true` | Hide disabled dishes (including HIDE-suffix dishes) |
| `dish_prices` | `is_active = true` | Hide disabled price variants |
| `modifier_groups` | `deleted_at IS NULL` | Soft delete filter |
| `dish_modifiers` | `deleted_at IS NULL` | Soft delete filter |
| `dish_modifier_prices` | `is_active = true` | Hide disabled modifier prices |

---

## DATA STRUCTURE RETURNED

```json
{
  "restaurant_id": 131,
  "courses": [
    {
      "id": 2184,
      "name": "Pizza",
      "description": "",
      "display_order": 1,
      "dishes": [
        {
          "id": 133653,
          "name": "Plain",
          "description": "- With mozzarella cheese and our homemade pizza sauce.",
          "display_order": 0,
          "is_combo": false,
          "has_customization": true,
          "image_url": null,
          "prices": [...],
          "modifier_groups": [...]
        }
      ]
    }
  ]
}
```

---

## EXAMPLE 1: Plain Pizza (Full Customization)

**Dish ID:** 133653  
**Course:** Pizza (ID: 2184)

### Database Records

```
DISH: Plain (ID: 133653)
├── PRICES: 3 size variants
│   ├── Small (9")  → $11.99
│   ├── Medium (12") → $16.99
│   └── Large (15")  → $21.99
│
├── MODIFIER GROUP: "Add more toppings" (ID: 11029)
│   ├── min_selections: 0, max_selections: 0 (unlimited)
│   ├── is_required: false
│   │
│   └── MODIFIERS: 19 items
│       ├── Pepperoni → $1.25/$2.50/$2.95 (S/M/L)
│       ├── Ham → $1.25/$2.50/$2.95
│       ├── Bacon → $1.25/$2.50/$2.95
│       ├── Italian Sausage → $1.25/$2.50/$2.95
│       ├── Chicken → $1.50/$2.75/$3.75 (premium)
│       ├── Ground Beef → $1.25/$2.50/$2.95
│       ├── Donair Meat → $1.50/$2.75/$3.75 (premium)
│       ├── Mushrooms → $1.25/$2.50/$2.95
│       ├── Onions → $1.25/$2.50/$2.95
│       ├── Tomatoes → $1.25/$2.50/$2.95
│       ├── Pineapple → $1.25/$2.50/$2.95
│       ├── Green Olives → $1.25/$2.50/$2.95
│       ├── Black Olives → $1.25/$2.50/$2.95
│       ├── Hot Banana Peppers → $1.25/$2.50/$2.95
│       ├── Green Peppers → $1.25/$2.50/$2.95
│       ├── Extra Cheese → $1.50/$2.75/$3.75 (premium)
│       ├── Feta → $1.50/$2.75/$3.75 (premium)
│       ├── Mustard → $0.00 (free, Small only)
│       └── Hot Peppers → $0.00 (free, Small only)
│
└── MODIFIER GROUP: "Dips" (ID: 11030)
    ├── min_selections: 0, max_selections: 1
    ├── is_required: false
    │
    └── MODIFIERS: 9 items
        ├── Creamy Garlic → $1.00
        ├── Honey Garlic → $1.00
        ├── Hot → $1.00
        ├── B.B.Q → $1.00
        ├── Marinara → $1.00
        ├── Medium → $0.00 (free)
        ├── Mild → $0.00 (free)
        ├── Gravy → $0.00 (free)
        └── Donair Sauce → $0.00 (free)
```

### JSON Output (Abbreviated)

```json
{
  "id": 133653,
  "name": "Plain",
  "description": "- With mozzarella cheese and our homemade pizza sauce.",
  "display_order": 0,
  "is_combo": false,
  "has_customization": true,
  "prices": [
    {"id": 49979, "size_variant": "Small (9\")", "price": 11.99, "display_order": 0},
    {"id": 49980, "size_variant": "Medium (12\")", "price": 16.99, "display_order": 1},
    {"id": 49981, "size_variant": "Large (15\")", "price": 21.99, "display_order": 2}
  ],
  "modifier_groups": [
    {
      "id": 11029,
      "name": "Add more toppings",
      "is_required": false,
      "min_selections": 0,
      "max_selections": 0,
      "display_order": 2,
      "modifiers": [
        {
          "id": 530897,
          "name": "Pepperoni",
          "modifier_type": "custom_ingredients",
          "is_default": false,
          "is_included": false,
          "display_order": 0,
          "prices": [
            {"id": 159237, "size_variant": "Small (9\")", "price": 1.25, "display_order": 0},
            {"id": 159238, "size_variant": "Medium (12\")", "price": 2.50, "display_order": 1},
            {"id": 159239, "size_variant": "Large (15\")", "price": 2.95, "display_order": 2}
          ]
        }
        // ... 18 more modifiers
      ]
    },
    {
      "id": 11030,
      "name": "Dips",
      "is_required": false,
      "min_selections": 0,
      "max_selections": 1,
      "display_order": 4,
      "modifiers": [/* 9 dip options */]
    }
  ]
}
```

### Counts Summary

| Entity | Count |
|--------|-------|
| Dish Prices | 3 |
| Modifier Groups | 2 |
| Total Modifiers | 28 |
| Total Modifier Prices | 62 |

---

## EXAMPLE 2: 10 Wings (Single Modifier Group)

**Dish ID:** 133672  
**Course:** Wings (ID: 2186)

### Database Records

```
DISH: 10 Wings (ID: 133672)
├── PRICES: 1 variant
│   └── standard → $14.99
│
└── MODIFIER GROUP: "Wings Sauce" (ID: 11052)
    ├── min_selections: 0, max_selections: 1
    ├── is_required: false
    │
    └── MODIFIERS: 9 sauces
        ├── Creamy Garlic → $1.00
        ├── Honey Garlic → $1.00
        ├── Hot → $1.00
        ├── B.B.Q → $1.00
        ├── Marinara → $1.00
        ├── Medium → $0.00 (free, default)
        ├── Mild → $0.00 (free)
        ├── Gravy → $0.00 (free)
        └── Donair Sauce → $0.00 (free)
```

### JSON Output (Abbreviated)

```json
{
  "id": 133672,
  "name": "10 Wings",
  "description": "-",
  "display_order": 0,
  "is_combo": false,
  "has_customization": true,
  "prices": [
    {"id": 50021, "size_variant": "standard", "price": 14.99, "display_order": 0}
  ],
  "modifier_groups": [
    {
      "id": 11052,
      "name": "Wings Sauce",
      "is_required": false,
      "min_selections": 0,
      "max_selections": 1,
      "display_order": 4,
      "modifiers": [
        {
          "id": 531207,
          "name": "Creamy Garlic",
          "modifier_type": "sauces",
          "is_default": false,
          "is_included": false,
          "display_order": 0,
          "prices": [
            {"id": 159921, "size_variant": "standard", "price": 1.00, "display_order": 0}
          ]
        }
        // ... 8 more sauces
      ]
    }
  ]
}
```

### Counts Summary

| Entity | Count |
|--------|-------|
| Dish Prices | 1 |
| Modifier Groups | 1 |
| Total Modifiers | 9 |
| Total Modifier Prices | 9 |

---

## EXAMPLE 3: Pepperoni Sub (No Modifiers)

**Dish ID:** 133675  
**Course:** Subs (ID: 2187)

### Database Records

```
DISH: Pepperoni Sub (ID: 133675)
├── PRICES: 1 variant
│   └── standard → $10.99
│
└── MODIFIER GROUPS: None
```

### JSON Output

```json
{
  "id": 133675,
  "name": "Pepperoni Sub",
  "description": "- Pepperoni, mushrooms, peppers, onions and mayonnaise.",
  "display_order": 0,
  "is_combo": false,
  "has_customization": false,
  "prices": [
    {"id": 50024, "size_variant": "standard", "price": 10.99, "display_order": 0}
  ],
  "modifier_groups": []
}
```

### Counts Summary

| Entity | Count |
|--------|-------|
| Dish Prices | 1 |
| Modifier Groups | 0 |
| Total Modifiers | 0 |
| Total Modifier Prices | 0 |

---

## RESTAURANT SUMMARY: CENTERTOWN DONAIR & PIZZA

### Courses & Dishes

| Course | Course ID | Active Dishes | Inactive Dishes |
|--------|-----------|---------------|-----------------|
| Specials | 2183 | 6 | 2 |
| Pizza | 2184 | 10 | 8 |
| Twins Pizza Special | 2185 | 3 | 0 |
| Wings | 2186 | 2 | 1 |
| Subs | 2187 | 2 | 0 |
| Halifax Donair | 2188 | 7 | 0 |
| Salads | 2189 | 2 | 1 |
| Platters | 2190 | 0 | 3 |
| Side Orders | 2191 | 9 | 0 |
| Desserts | 2192 | 1 | 1 |
| Drinks | 2193 | 10 | 2 |
| **TOTAL** | - | **52** | **16** |

### Why 16 Dishes Are Inactive

These dishes were previously marked with a "HIDE" suffix in the legacy CRM (e.g., "Greek Pizza HIDE"). 

On **2025-12-12**, we ran a cleanup that:
1. Set `is_active = FALSE` for all 3,540 dishes with "HIDE" in the name
2. Removed the "HIDE" suffix from the name

This ensures the `get_restaurant_menu` function correctly excludes them.

---

## TABLE RELATIONSHIPS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MENU DATA HIERARCHY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  restaurants (ID: 131)                                                      │
│       │                                                                     │
│       │ 1:N                                                                 │
│       ▼                                                                     │
│  courses ─────────────────────────────────────────┐                         │
│  (is_active = true, deleted_at IS NULL)           │                         │
│       │                                           │                         │
│       │ 1:N                                       │                         │
│       ▼                                           │                         │
│  dishes ──────────────────────────────────────────┤                         │
│  (is_active = true, deleted_at IS NULL)           │ All join on             │
│       │                                           │ restaurant_id           │
│       ├──────────────────┐                        │                         │
│       │ 1:N              │ 1:N                    │                         │
│       ▼                  ▼                        │                         │
│  dish_prices      modifier_groups ────────────────┘                         │
│  (is_active=true) (deleted_at IS NULL)                                      │
│                          │                                                  │
│                          │ 1:N                                              │
│                          ▼                                                  │
│                   dish_modifiers                                            │
│                   (deleted_at IS NULL)                                      │
│                          │                                                  │
│                          │ 1:N                                              │
│                          ▼                                                  │
│                   dish_modifier_prices                                      │
│                   (is_active = true, deleted_at IS NULL)                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## VERIFICATION QUERIES

### Check Function Output Matches Database

```sql
-- Count dishes in function output vs database
WITH menu_data AS (
    SELECT menuca_v3.get_restaurant_menu(131) as menu
)
SELECT 
    (SELECT COUNT(*) FROM jsonb_array_elements(menu->'courses') c, 
                          jsonb_array_elements(c->'dishes')) as function_dishes,
    (SELECT COUNT(*) FROM menuca_v3.dishes 
     WHERE restaurant_id = 131 AND is_active = true AND deleted_at IS NULL) as db_dishes
FROM menu_data;
-- Expected: 52 | 52
```

### Verify Modifier Counts Match

```sql
-- For a specific dish (Plain Pizza)
SELECT 
    d.name,
    COUNT(DISTINCT mg.id) as modifier_groups,
    COUNT(DISTINCT dm.id) as modifiers,
    COUNT(DISTINCT dmp.id) as modifier_prices
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id AND mg.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id AND dm.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifier_prices dmp ON dmp.dish_modifier_id = dm.id 
    AND dmp.is_active = true AND dmp.deleted_at IS NULL
WHERE d.id = 133653
GROUP BY d.name;
-- Expected: Plain | 2 | 28 | 62
```

---

## IMPORTANT NOTES FOR AGENTS

1. **No `is_active` on `modifier_groups` or `dish_modifiers`**
   - These tables only use `deleted_at` for soft delete
   - The function correctly checks `deleted_at IS NULL`

2. **Dishes with `is_active = FALSE` are excluded**
   - This includes all former "HIDE" suffix dishes
   - 3,540 dishes system-wide were set to inactive on 2025-12-12

3. **Modifier prices are size-aware**
   - Pizza toppings have 3 prices (Small/Medium/Large)
   - Wings sauces have 1 price (standard)
   - Match `size_variant` between `dish_prices` and `dish_modifier_prices`

4. **Empty modifier groups return `[]`**
   - Dishes like "Pepperoni Sub" return `"modifier_groups": []`
   - Frontend should handle this gracefully

5. **Combo dishes exist but are handled separately**
   - `is_combo = true` dishes use the `combo_groups` table structure
   - See combo documentation for those details

