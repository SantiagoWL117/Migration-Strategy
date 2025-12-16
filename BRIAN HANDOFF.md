# Agent Handoff: Special Combo Selections

> **Purpose:** Document how special combo dish selections work in `menuca_v3`  
> **Function:** `get_restaurant_menu`  
> **Last Updated:** 2025-12-15

---

## WHAT ARE SPECIAL COMBO SELECTIONS?

Some combo dishes allow customers to **choose from a list of existing dishes** as part of their combo. For example:

- **"Small Nachos with Donuts and Drink"** → Customer picks 1 of 12 nacho varieties
- **"Any 3 Burgers Special"** → Customer picks 3 burgers from the menu
- **"Family Special Meal Deal"** → Customer picks 1 salad from 3 options

This is different from regular combo modifier groups (like pizza toppings), where customers select individual modifiers. With special sections, they're selecting **entire dishes**.

---

## DATABASE SCHEMA

### Key Tables

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    SPECIAL COMBO SELECTION HIERARCHY                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  dishes (is_combo = true)                                                    │
│       │                                                                      │
│       │ via dish_combo_groups                                                │
│       ▼                                                                      │
│  combo_groups ─────────────────────────────────────────────┐                 │
│  (has_special_section = TRUE)                              │                 │
│       │                                                    │                 │
│       │ 1:N                                                │                 │
│       ▼                                                    │                 │
│  combo_group_dish_selections ──────────────────────────────┤                 │
│  (The dishes customer can choose from)                     │                 │
│       │                                                    │                 │
│       │ FK                                                 │                 │
│       ▼                                                    │                 │
│  dishes (the selectable dishes)                            │                 │
│  courses (for grouping/display)                            │                 │
│                                                            │                 │
│  NOTE: combo_groups also have combo_group_sections with    │                 │
│  combo_modifier_groups for additional customizations       │                 │
│  (e.g., donut dips, burger toppings)                       │                 │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### `combo_groups` Table (Relevant Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `restaurant_id` | bigint | FK to restaurants |
| `name` | text | Group name (e.g., "Small Nacho Selection with Donuts") |
| `has_special_section` | boolean | **TRUE** if this combo has dish selections |
| `special_number_of_items` | integer | How many dishes customer must select (e.g., 1, 2, 3) |
| `special_display_header` | varchar | UI header (e.g., "Choose your Nacho" or "First Burger;Second Burger") |
| `deleted_at` | timestamp | Soft delete |

### `combo_group_dish_selections` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `combo_group_id` | integer | FK to combo_groups |
| `dish_id` | integer | FK to dishes (the selectable dish) |
| `size` | smallint | Size variant: 0=Small, 1=Medium, 2=Large, 3=X-Large, NULL=no size |
| `course_id` | integer | FK to courses (for UI grouping) |
| `dish_display_name` | text | Optional override (e.g., "Caesar Salad Large" instead of "Caesar Salad") |
| `deleted_at` | timestamp | Soft delete |

### Size Mapping

| Value | Size |
|-------|------|
| `NULL` | No size variants |
| `0` | Small |
| `1` | Medium |
| `2` | Large |
| `3` | X-Large |

### Size Distribution in Dish Selections

| Size | Count | Percentage |
|------|-------|------------|
| Medium (12") | 277 | 40.8% |
| Small (9") | 215 | 31.7% |
| Large (15") | 110 | 16.2% |
| No size variant | 55 | 8.1% |
| X-Large | 22 | 3.2% |
| **Total** | **679** | **100%** |

> **Note:** Medium is the most common size for combo dish selections, followed by Small.

---

## STATISTICS

| Metric | Count |
|--------|-------|
| Total combo groups | 2,067 |
| Combo groups with special sections | 48 |
| Total dish selections | 679 |
| Restaurants with special sections | 12 |

### Restaurants with Special Combo Sections

| Restaurant | V3 ID | Special Combo Groups | Total Dish Selections |
|------------|-------|---------------------|----------------------|
| Milano | 680 | 21 | 349 |
| Aroy Thai | 607 | 4 | 116 |
| Amicci Pizza | 735 | 5 | 60 |
| Nachos Loco Gatineau | 801 | 3 | 36 |
| Nachos Loco Hull | 790 | 3 | 36 |
| Dumpling Bowl | 792 | 1 | 22 |
| Mano City Pizza | 118 | 3 | 19 |
| All Out Burger | 833 | 1 | 12 |
| Little Gyros Greek Grill | 756 | 2 | 10 |
| Orchid Sushi | 245 | 1 | 8 |
| Milano | 350 | 2 | 7 |
| Milano | 123 | 2 | 4 |

---

## `get_restaurant_menu` FUNCTION

### Function Signature

```sql
menuca_v3.get_restaurant_menu(
  p_restaurant_id bigint,
  p_language_code text DEFAULT 'en',
  p_combo_default_only boolean DEFAULT false
) RETURNS jsonb
```

### How Special Sections Are Returned

When a combo group has `has_special_section = true`, the function returns:

```json
{
  "id": 2115,
  "name": "Small Nacho Selection with Donuts",
  "has_special_section": true,
  "number_of_items": 1,
  "display_header": "Choose your Nacho",
  "dish_selections": [
    {
      "id": 632,
      "dish_id": 145258,
      "dish_name": "Regular Nachos",
      "dish_display_name": "Regular Nachos 9\"",
      "size": 0,
      "course_id": 3617,
      "course_name": "Nachos"
    },
    {
      "id": 633,
      "dish_id": 145259,
      "dish_name": "Cuatro Queso",
      "dish_display_name": "Cuatro Queso 9\"",
      "size": 0,
      "course_id": 3617,
      "course_name": "Nachos"
    }
    // ... more dish selections
  ],
  "sections": [
    // Regular combo sections with modifier groups (e.g., donut dips)
  ]
}
```

### Key Fields for Frontend

| Field | Purpose |
|-------|---------|
| `has_special_section` | **Check this first** - if `true`, render dish selection UI |
| `number_of_items` | How many dishes customer must select |
| `display_header` | Header text for UI. If contains `;`, split for multiple selections (e.g., "First Burger;Second Burger") |
| `dish_selections[]` | Array of dishes customer can choose from |
| `dish_selections[].dish_display_name` | Use this for display (falls back to `dish_name` if null) |
| `dish_selections[].size` | Size variant of this selection |
| `dish_selections[].course_name` | For grouping dishes by category in UI |

### Soft Delete Handling

The function filters out deleted dish selections:

```sql
WHERE cgds.deleted_at IS NULL
```

---

## COMPLETE EXAMPLE: Nachos Loco Gatineau

### Dish: "Small Nachos with Donuts and Drink" (ID: 145242)

**Price:** $19.95  
**Description:** 1 small nachos and 6 mini donuts

### JSON Output Structure

```json
{
  "id": 145242,
  "name": "Small Nachos with Donuts and Drink",
  "is_combo": true,
  "prices": [
    {"id": 74561, "price": 19.95, "size_variant": "standard"}
  ],
  "modifier_groups": [
    {
      "id": 21667,
      "name": "First two 591ml Drinks Free",
      "modifiers": [/* 12 drink options */]
    },
    {
      "id": 40861,
      "name": "Drinks",
      "modifiers": [/* 12 drink options */]
    }
  ],
  "combo_groups": [
    {
      "id": 2115,
      "name": "Small Nacho Selection with Donuts",
      "has_special_section": true,
      "number_of_items": 1,
      "display_header": "Choose your Nacho",
      "dish_selections": [
        {"id": 632, "dish_id": 145258, "dish_name": "Regular Nachos", "dish_display_name": "Regular Nachos 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 633, "dish_id": 145259, "dish_name": "Cuatro Queso", "dish_display_name": "Cuatro Queso 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 634, "dish_id": 145260, "dish_name": "El Vegetariano", "dish_display_name": "El Vegetariano 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 635, "dish_id": 145261, "dish_name": "El Griego", "dish_display_name": "El Griego 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 636, "dish_id": 145262, "dish_name": "Filet de Queso Philly", "dish_display_name": "Filet de Queso Philly 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 637, "dish_id": 145263, "dish_name": "Amante de la Carne", "dish_display_name": "Amante de la Carne 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 638, "dish_id": 145264, "dish_name": "El Pollo", "dish_display_name": "El Pollo 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 639, "dish_id": 145265, "dish_name": "El Chico", "dish_display_name": "El Chico 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 640, "dish_id": 145266, "dish_name": "Loco Especial", "dish_display_name": "Loco Especial 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 641, "dish_id": 145267, "dish_name": "Loco Piquante", "dish_display_name": "Loco Piquante 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 642, "dish_id": 145268, "dish_name": "Loco Amigos", "dish_display_name": "Loco Amigos 9\"", "size": 0, "course_name": "Nachos"},
        {"id": 643, "dish_id": 145269, "dish_name": "El Cactus", "dish_display_name": "El Cactus 9\"", "size": 0, "course_name": "Nachos"}
      ],
      "sections": [
        {
          "id": 2805,
          "section_type": "sauce",
          "use_header": "Donuts Dips",
          "modifier_groups": [
            {
              "id": 4210,
              "name": "Mini Donuts Dips",
              "is_selected": true,
              "modifiers": [
                {"name": "Birthday Dip", "prices": [{"price": 2.00}]},
                {"name": "Salted Caramel Dip", "prices": [{"price": 2.00}]},
                {"name": "Cookies and Cream Dip", "prices": [{"price": 2.00}]},
                {"name": "Chocolat Fudge Dip", "prices": [{"price": 2.00}]},
                {"name": "Honey Glaze Dip", "prices": [{"price": 2.00}]},
                {"name": "Strawberry Dip", "prices": [{"price": 2.00}]}
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Visual Structure

```
📦 Small Nachos with Donuts and Drink ($19.95)
│
├── 🥤 Regular Modifier Groups (for drinks)
│   ├── First two 591ml Drinks Free (12 options)
│   └── Drinks (12 options)
│
└── 📦 Combo Group: "Small Nacho Selection with Donuts"
    │   has_special_section: TRUE
    │   number_of_items: 1
    │   display_header: "Choose your Nacho"
    │
    ├── 🌮 Dish Selections (12 nachos - size 0 = Small/9")
    │   ├── Regular Nachos 9"
    │   ├── Cuatro Queso 9"
    │   ├── El Vegetariano 9"
    │   ├── El Griego 9"
    │   ├── Filet de Queso Philly 9"
    │   ├── Amante de la Carne 9"
    │   ├── El Pollo 9"
    │   ├── El Chico 9"
    │   ├── Loco Especial 9"
    │   ├── Loco Piquante 9"
    │   ├── Loco Amigos 9"
    │   └── El Cactus 9"
    │
    └── 📑 Section: "Donuts Dips"
        └── Mini Donuts Dips (6 dip options @ $2.00 each)
```

---

## FRONTEND IMPLEMENTATION GUIDE

### Step 1: Check for Special Section

```typescript
const comboGroup = dish.combo_groups[0];

if (comboGroup.has_special_section) {
  // Render dish selection UI
  renderDishSelectionUI(comboGroup);
} else {
  // Render regular combo modifier UI
  renderComboModifierUI(comboGroup);
}
```

### Step 2: Parse Display Header

```typescript
// Single selection: "Choose your Nacho"
// Multiple selections: "First Burger;Second Burger;Third Burger"

const headers = comboGroup.display_header.split(';');
const numberOfItems = comboGroup.number_of_items;

// headers.length should equal numberOfItems
```

### Step 3: Group Dishes by Course

```typescript
const dishesByCourse = comboGroup.dish_selections.reduce((acc, dish) => {
  const courseName = dish.course_name || 'Other';
  if (!acc[courseName]) acc[courseName] = [];
  acc[courseName].push(dish);
  return acc;
}, {});
```

### Step 4: Display Dish Name

```typescript
// Use dish_display_name if available, otherwise dish_name
const displayName = dish.dish_display_name || dish.dish_name;
```

---

## VERIFICATION QUERIES

### Check Special Combo Groups for a Restaurant

```sql
SELECT 
    cg.id,
    cg.name,
    cg.has_special_section,
    cg.special_number_of_items,
    cg.special_display_header,
    COUNT(cgds.id) as dish_selection_count
FROM menuca_v3.combo_groups cg
LEFT JOIN menuca_v3.combo_group_dish_selections cgds 
    ON cgds.combo_group_id = cg.id AND cgds.deleted_at IS NULL
WHERE cg.restaurant_id = 801  -- Nachos Loco Gatineau
  AND cg.has_special_section = true
  AND cg.deleted_at IS NULL
GROUP BY cg.id, cg.name, cg.has_special_section, 
         cg.special_number_of_items, cg.special_display_header;
```

### Get Dish Selections for a Combo Group

```sql
SELECT 
    cgds.id,
    cgds.dish_id,
    d.name as dish_name,
    cgds.dish_display_name,
    cgds.size,
    c.name as course_name
FROM menuca_v3.combo_group_dish_selections cgds
JOIN menuca_v3.dishes d ON d.id = cgds.dish_id
LEFT JOIN menuca_v3.courses c ON c.id = cgds.course_id
WHERE cgds.combo_group_id = 2115  -- Small Nacho Selection with Donuts
  AND cgds.deleted_at IS NULL
ORDER BY c.display_order, d.name;
```

### Test get_restaurant_menu for Special Sections

```sql
WITH menu AS (
    SELECT menuca_v3.get_restaurant_menu(801::bigint, 'en', false) as data
),
dish_data AS (
    SELECT dish
    FROM menu,
         jsonb_array_elements(data->'courses') course,
         jsonb_array_elements(course->'dishes') dish
    WHERE dish->>'is_combo' = 'true'
)
SELECT 
    dish->>'name' as dish_name,
    cg->>'name' as combo_group_name,
    cg->>'has_special_section' as has_special_section,
    jsonb_array_length(cg->'dish_selections') as dish_selection_count
FROM dish_data,
     jsonb_array_elements(dish->'combo_groups') cg
WHERE cg->>'has_special_section' = 'true';
```

---

## IMPORTANT NOTES

1. **Not all combo groups have special sections**
   - Only 48 out of 2,067 combo groups have `has_special_section = true`
   - Always check this flag before trying to render dish selections

2. **Dish selections are soft-deleted**
   - Filter by `deleted_at IS NULL` when querying directly
   - `get_restaurant_menu` handles this automatically

3. **Size matters for dish selections**
   - The `size` field indicates which size variant is included in the combo
   - Size 0 (Small) is most common for combo selections

4. **Display name may differ from dish name**
   - `dish_display_name` often includes size (e.g., "Caesar Salad Large")
   - Use this for display, fall back to `dish_name` if null

5. **Combo groups can have BOTH dish selections AND modifier sections**
   - The Nachos example has both dish selections (12 nachos) AND a modifier section (donut dips)
   - Process both `dish_selections` and `sections` arrays

6. **Multiple selections use semicolon-separated headers**
   - "First Burger;Second Burger;Third Burger" means 3 separate selections
   - Split by `;` to get individual headers for each selection step
