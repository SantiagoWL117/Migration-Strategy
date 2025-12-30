# Frontend Handoff: Modifier Groups Integration

**Date:** December 28, 2024  
**For:** Brian (Frontend Developer)  
**From:** Santiago (Database Migration)

---

## Overview

The modifier groups system has been migrated to V3 with a **shared architecture**. Modifier groups are now defined at the **restaurant level** and linked to individual dishes, with per-dish configuration for display settings.

---

## 1. Database Schema

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              MODIFIER GROUPS SCHEMA (V3)                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

        RESTAURANT LEVEL                              DISH LEVEL
      (Shared within restaurant)                   (Dish-specific)
    ════════════════════════════                ════════════════════════════

┌───────────────────────────┐                  ┌─────────────────────────────────┐
│     modifier_groups       │                  │         dishes                  │
│  (Shared at restaurant)   │                  ├─────────────────────────────────┤
├───────────────────────────┤                  │ id                              │
│ id            PK          │                  │ name                            │
│ restaurant_id FK          │                  │ has_customization               │
│ name          (internal)  │                  └────────────────┬────────────────┘
│ category      (type code) │                                   │
└───────────┬───────────────┘                                   │
            │                                                   │
            │ 1:N                                               │
            ▼                                                   ▼
┌───────────────────────────┐                  ┌─────────────────────────────────┐
│       modifiers           │                  │     dish_modifier_groups        │
│  (Shared options)         │                  │  (Link: dish ↔ modifier_group)  │
├───────────────────────────┤                  ├─────────────────────────────────┤
│ id            PK          │                  │ id              PK              │
│ modifier_group_id FK      │                  │ dish_id         FK              │
│ name                      │                  │ modifier_group_id FK            │
│ display_order             │                  └────────────────┬────────────────┘
│ is_active                 │                                   │
└───────────┬───────────────┘                                   │ 1:1
            │                                                   ▼
            │ 1:N                              ┌─────────────────────────────────┐
            ▼                                  │   modifier_group_details        │
┌───────────────────────────┐                  │  (Per-dish display settings)    │
│    modifier_prices        │                  ├─────────────────────────────────┤
│  (Size-based pricing)     │                  │ id              PK              │
├───────────────────────────┤                  │ dish_modifier_group_id FK       │
│ id            PK          │                  │ name            (display name)  │
│ modifier_id   FK          │                  │ min_selections                  │
│ size_variant              │                  │ max_selections                  │
│ price                     │                  │ free_items                      │
│ display_order             │                  │ display_order                   │
└───────────────────────────┘                  └─────────────────────────────────┘
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **modifier_groups** | Shared groups at restaurant level (e.g., "Pizza Toppings", "Sauces") |
| **modifiers** | Individual options within a group (e.g., "Pepperoni", "Mushrooms") |
| **modifier_prices** | Size-based pricing for modifiers |
| **dish_modifier_groups** | Links a dish to a modifier group |
| **modifier_group_details** | Per-dish config: display name, min/max selections, free items |

---

## 2. API Function: `get_restaurant_menu`

### Function Signature

```sql
menuca_v3.get_restaurant_menu(
  p_restaurant_id bigint,           -- Required: Restaurant ID
  p_language_code text DEFAULT 'en', -- Optional: Language (future use)
  p_combo_default_only boolean DEFAULT false  -- Optional: Filter combo groups
)
RETURNS jsonb
```

### How to Call (Supabase RPC)

```typescript
// TypeScript/JavaScript
const { data, error } = await supabase
  .rpc('get_restaurant_menu', { 
    p_restaurant_id: 735  // Amicci Pizza
  })

// With combo filter
const { data, error } = await supabase
  .rpc('get_restaurant_menu', { 
    p_restaurant_id: 735,
    p_combo_default_only: true  // Only return selected combo options
  })
```

---

## 3. Response Structure

```typescript
interface MenuResponse {
  restaurant_id: number;
  combo_default_only: boolean;
  courses: Course[];
}

interface Course {
  id: number;
  name: string;
  description: string | null;
  display_order: number;
  dishes: Dish[];
}

interface Dish {
  id: number;
  name: string;
  description: string | null;
  display_order: number;
  is_combo: boolean;
  has_customization: boolean;
  image_url: string | null;
  prices: DishPrice[];
  modifier_groups: ModifierGroup[];  // ← REGULAR MODIFIERS
  combo_groups: ComboGroup[];        // ← COMBO-SPECIFIC MODIFIERS
}

interface DishPrice {
  id: number;
  size_variant: string | null;
  price: number;
  display_order: number;
}

// ═══════════════════════════════════════════════════════════════
// MODIFIER GROUPS (for regular customization like toppings, sauces)
// ═══════════════════════════════════════════════════════════════

interface ModifierGroup {
  id: number;
  name: string;           // Display name (from modifier_group_details)
  category: string;       // Category code (see table below)
  min_selections: number; // Minimum required selections
  max_selections: number; // Maximum allowed selections (0 = unlimited)
  free_items: number;     // Number of free items before charging
  display_order: number;
  modifiers: Modifier[];
}

interface Modifier {
  id: number;
  name: string;
  display_order: number;
  is_active: boolean;     // Whether this option is currently available
  prices: ModifierPrice[];
}

interface ModifierPrice {
  id: number;
  size_variant: string | null;  // Matches dish size_variant
  price: number;
  display_order: number;
}

// ═══════════════════════════════════════════════════════════════
// COMBO GROUPS (for combo meals with multiple sections)
// ═══════════════════════════════════════════════════════════════

interface ComboGroup {
  id: number;
  name: string;
  number_of_items: number | null;
  display_header: string | null;
  sections: ComboSection[];
}

interface ComboSection {
  id: number;
  section_type: string;
  use_header: boolean;
  display_order: number;
  free_items: number;
  min_selection: number;
  max_selection: number;
  is_active: boolean;
  modifier_groups: ComboModifierGroup[];
}

interface ComboModifierGroup {
  id: number;
  name: string;
  type_code: string;
  is_selected: boolean;   // Default selection state
  modifiers: ComboModifier[];
}

interface ComboModifier {
  id: number;
  name: string;
  display_order: number;
  prices: ComboModifierPrice[];
}

interface ComboModifierPrice {
  id: number;
  size_variant: string | null;
  price: number;
}
```

---

## 4. Category Codes

| Code | Category | Description |
|------|----------|-------------|
| `ci` | Custom Ingredients | Toppings, add-ons (e.g., "Add more toppings") |
| `sa` | Sauces | Sauce selections (e.g., "Dips", "Sauces") |
| `sd` | Side Dishes | Side dish selections (e.g., "Side Dish", "Plat d'accompagnement") |
| `e` | Extras | Extra items (e.g., "Extras", "Extra Cheese") |

---

## 5. Example Response

### English Restaurant (Amicci Pizza - ID: 735)

```json
{
  "restaurant_id": 735,
  "combo_default_only": false,
  "courses": [
    {
      "id": 1234,
      "name": "Pizzas",
      "display_order": 0,
      "dishes": [
        {
          "id": 132351,
          "name": "Cheese Pizza",
          "is_combo": false,
          "has_customization": true,
          "prices": [
            { "id": 56001, "size_variant": "Small", "price": 12.99, "display_order": 0 },
            { "id": 56002, "size_variant": "Medium", "price": 15.99, "display_order": 1 },
            { "id": 56003, "size_variant": "Large", "price": 18.99, "display_order": 2 }
          ],
          "modifier_groups": [
            {
              "id": 28,
              "name": "Add more toppings",
              "category": "ci",
              "min_selections": 0,
              "max_selections": 0,
              "free_items": 0,
              "display_order": 2,
              "modifiers": [
                {
                  "id": 64774,
                  "name": "Pepperoni",
                  "display_order": 0,
                  "is_active": true,
                  "prices": [
                    { "id": 96623, "size_variant": "Small", "price": 1.50, "display_order": 0 },
                    { "id": 96624, "size_variant": "Medium", "price": 2.00, "display_order": 1 },
                    { "id": 96625, "size_variant": "Large", "price": 2.50, "display_order": 2 }
                  ]
                },
                {
                  "id": 64775,
                  "name": "Mushrooms",
                  "display_order": 1,
                  "is_active": true,
                  "prices": [
                    { "id": 96626, "size_variant": "Small", "price": 1.50, "display_order": 0 },
                    { "id": 96627, "size_variant": "Medium", "price": 2.00, "display_order": 1 },
                    { "id": 96628, "size_variant": "Large", "price": 2.50, "display_order": 2 }
                  ]
                }
              ]
            },
            {
              "id": 29,
              "name": "Dips",
              "category": "sa",
              "min_selections": 0,
              "max_selections": 0,
              "free_items": 0,
              "display_order": 3,
              "modifiers": [
                {
                  "id": 64800,
                  "name": "Garlic Dip",
                  "display_order": 0,
                  "is_active": true,
                  "prices": [
                    { "id": 96700, "size_variant": null, "price": 1.25, "display_order": 0 }
                  ]
                }
              ]
            }
          ],
          "combo_groups": []
        }
      ]
    }
  ]
}
```

### French Restaurant (Papa Grecque Cantley - ID: 810)

```json
{
  "restaurant_id": 810,
  "combo_default_only": false,
  "courses": [
    {
      "id": 5678,
      "name": "Gyros",
      "display_order": 2,
      "dishes": [
        {
          "id": 153025,
          "name": "1a. Souvlaki Combo",
          "is_combo": false,
          "has_customization": true,
          "prices": [
            { "id": 67008, "size_variant": "Poulet", "price": 18.85, "display_order": 0 },
            { "id": 67009, "size_variant": "Porc", "price": 18.85, "display_order": 1 }
          ],
          "modifier_groups": [
            {
              "id": 2577,
              "name": "Plat d'accompagnement",
              "category": "sd",
              "min_selections": 1,
              "max_selections": 1,
              "free_items": 0,
              "display_order": 5,
              "modifiers": [
                {
                  "id": 133184,
                  "name": "Salade",
                  "display_order": 0,
                  "is_active": true,
                  "prices": [
                    { "id": 219920, "size_variant": null, "price": 0.00, "display_order": 0 }
                  ]
                },
                {
                  "id": 133185,
                  "name": "Patates",
                  "display_order": 1,
                  "is_active": true,
                  "prices": [
                    { "id": 219921, "size_variant": null, "price": 0.00, "display_order": 0 }
                  ]
                }
              ]
            }
          ],
          "combo_groups": []
        }
      ]
    }
  ]
}
```

---

## 6. Frontend Implementation Notes

### Determining if a Dish Has Customization

```typescript
// A dish has customization if:
const hasCustomization = dish.has_customization || 
                         dish.modifier_groups.length > 0 || 
                         dish.combo_groups.length > 0;
```

### Handling Required Selections

```typescript
// Check if modifier group is required
const isRequired = modifierGroup.min_selections > 0;

// Validate selection count
const isValidSelection = (selectedCount: number, group: ModifierGroup) => {
  const meetsMin = selectedCount >= group.min_selections;
  const meetsMax = group.max_selections === 0 || selectedCount <= group.max_selections;
  return meetsMin && meetsMax;
};
```

### Matching Modifier Prices to Dish Size

```typescript
// When user selects a dish size, find matching modifier price
const getModifierPrice = (modifier: Modifier, selectedSizeVariant: string | null) => {
  // Try to find price matching the dish size
  const matchingPrice = modifier.prices.find(p => p.size_variant === selectedSizeVariant);
  
  // Fallback to null size_variant (universal price)
  const fallbackPrice = modifier.prices.find(p => p.size_variant === null);
  
  return matchingPrice || fallbackPrice || modifier.prices[0];
};
```

### Calculating Free Items

```typescript
// If free_items > 0, first N selections are free
const calculateModifierTotal = (
  selectedModifiers: Modifier[], 
  group: ModifierGroup,
  selectedSizeVariant: string | null
) => {
  let total = 0;
  selectedModifiers.forEach((modifier, index) => {
    if (index >= group.free_items) {
      const price = getModifierPrice(modifier, selectedSizeVariant);
      total += price?.price || 0;
    }
  });
  return total;
};
```

---

## 7. Quick Reference

| Field | Type | Description |
|-------|------|-------------|
| `modifier_groups[].name` | string | **Display name** shown to customers |
| `modifier_groups[].category` | string | Type code: `ci`, `sa`, `sd`, `e` |
| `modifier_groups[].min_selections` | number | Minimum required (0 = optional) |
| `modifier_groups[].max_selections` | number | Maximum allowed (0 = unlimited) |
| `modifier_groups[].free_items` | number | Free selections before charging |
| `modifiers[].is_active` | boolean | Whether option is available |
| `modifier_prices[].size_variant` | string \| null | Matches dish size, null = all sizes |

---

## 8. Testing

Test with these restaurants:

| Restaurant | ID | Notes |
|------------|-----|-------|
| Amicci Pizza | 735 | English, many modifier groups |
| Papa Grecque Cantley | 810 | French, simple modifiers |
| Aahar | 561 | English, various categories |

```sql
-- Test query in Supabase SQL Editor
SELECT menuca_v3.get_restaurant_menu(735);
```

---

**Questions?** Contact Santiago for database/schema questions.

