# Combo Modifier Groups - Replit Agent Handoff

> **Last Updated:** January 20, 2026  
> **Restaurant:** Centertown Donair & Pizza (ID: 131)  
> **Schema:** `menuca_v3`

---

## Overview

This document explains how **combo dishes** with **modifier groups** (like drinks) are structured in the database. Understanding this structure is critical for rendering combo customization options in the frontend.

---

## Target Dishes (Specials Course)

| Dish ID | Dish Name | Price | Combo Group |
|---------|-----------|-------|-------------|
| 133645 | Medium Pizza and Donairs | $37.40 | 35 (2 Small Donairs) |
| 133649 | 2 Small Donairs and Garlic Fingers | $37.40 | 35 (2 Small Donairs) |
| 133650 | 2 Small Halifax Donairs | $32.05 | 35 (2 Small Donairs) |
| 133651 | 2 Small Donairs and Wings | $35.15 | 35 (2 Small Donairs) |
| 133652 | Large Pizza and Donair Special | $42.15 | 34 (Extras Small Donair) |

---

## Database Schema Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TABLE RELATIONSHIPS                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌───────────────────┐      ┌──────────────────┐
│   dishes     │──1:N─│ dish_combo_groups │──N:1─│   combo_groups   │
│              │      │   (junction)      │      │                  │
│  id          │      │  dish_id          │      │  id              │
│  name_en     │      │  combo_group_id   │      │  name_en         │
│  is_combo    │      │  is_active        │      │  restaurant_id   │
└──────────────┘      └───────────────────┘      └────────┬─────────┘
                                                          │
                                                         1:N
                                                          │
                                                          ▼
                                               ┌─────────────────────────┐
                                               │  combo_group_sections   │
                                               │                         │
                                               │  id                     │
                                               │  combo_group_id         │
                                               │  section_type           │
                                               │  use_header_en          │
                                               │  min_selection          │
                                               │  max_selection          │
                                               │  free_items             │
                                               └───────────┬─────────────┘
                                                           │
                                                          1:N
                                                           │
                                                           ▼
                                               ┌─────────────────────────┐
                                               │  combo_modifier_groups  │
                                               │                         │
                                               │  id                     │
                                               │  combo_group_section_id │
                                               │  name_en                │
                                               │  type_code              │
                                               │  is_selected            │
                                               └───────────┬─────────────┘
                                                           │
                                                          1:N
                                                           │
                                                           ▼
                                               ┌─────────────────────────┐
                                               │    combo_modifiers      │
                                               │                         │
                                               │  id                     │
                                               │  combo_modifier_group_id│
                                               │  name_en                │
                                               │  display_order          │
                                               └───────────┬─────────────┘
                                                           │
                                                          1:N
                                                           │
                                                           ▼
                                               ┌─────────────────────────┐
                                               │  combo_modifier_prices  │
                                               │                         │
                                               │  id                     │
                                               │  combo_modifier_id      │
                                               │  size_variant           │
                                               │  price                  │
                                               └─────────────────────────┘
```

---

## Table Definitions

### 1. `dishes`
The main dish table. Combo dishes have `is_combo = true`.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name_en` | varchar | English name |
| `name_fr` | varchar | French name |
| `is_combo` | boolean | True if dish has combo options |
| `has_customization` | boolean | True if dish has modifier groups |

### 2. `dish_combo_groups`
Junction table linking dishes to their combo groups.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `dish_id` | bigint | FK to dishes |
| `combo_group_id` | bigint | FK to combo_groups |
| `is_active` | boolean | Whether this link is active |

### 3. `combo_groups`
Defines a combo configuration that can be shared across multiple dishes.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `restaurant_id` | bigint | FK to restaurants |
| `name_en` | varchar | English name (e.g., "2 Small Donairs") |
| `has_special_section` | boolean | If true, uses special headers |
| `special_number_of_items` | int | Number of items to select |
| `special_display_header_en` | varchar | Semicolon-separated headers |

### 4. `combo_group_sections`
Sections within a combo group (e.g., "drinks", "extras").

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `combo_group_id` | bigint | FK to combo_groups |
| `section_type` | varchar | Type: 'drinks', 'extras', etc. |
| `use_header_en` | varchar | Display header (e.g., "Drinks") |
| `min_selection` | int | Minimum items to select |
| `max_selection` | int | Maximum items to select (0 = unlimited) |
| `free_items` | int | Number of free items included |
| `display_order` | int | Sort order |

### 5. `combo_modifier_groups`
Groups of modifiers within a section.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `combo_group_section_id` | bigint | FK to combo_group_sections |
| `name_en` | varchar | English name (e.g., "Drinks") |
| `type_code` | char(1) | 'D' = Drinks, 'E' = Extras |
| `is_selected` | boolean | If true, this group is active for the combo |

### 6. `combo_modifiers`
Individual modifier options.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `combo_modifier_group_id` | bigint | FK to combo_modifier_groups |
| `name_en` | varchar | English name (e.g., "Pepsi") |
| `name_fr` | varchar | French name |
| `display_order` | int | Sort order |

### 7. `combo_modifier_prices`
Prices for each modifier option.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `combo_modifier_id` | bigint | FK to combo_modifiers |
| `size_variant` | varchar | Size (usually "Standard") |
| `price` | numeric | Price (0.00 if included) |

---

## Live Data Example

### Dish: "2 Small Donairs and Garlic Fingers" (ID: 133649)

```sql
-- Get complete combo modifier structure for a dish
SELECT 
  d.id AS dish_id,
  d.name_en AS dish_name,
  cg.id AS combo_group_id,
  cg.name_en AS combo_group_name,
  cgs.id AS section_id,
  cgs.section_type,
  cgs.use_header_en AS section_header,
  cgs.min_selection,
  cgs.max_selection,
  cmg.id AS modifier_group_id,
  cmg.name_en AS modifier_group_name,
  cm.id AS modifier_id,
  cm.name_en AS modifier_name,
  cmp.price
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_combo_groups dcg ON dcg.dish_id = d.id
JOIN menuca_v3.combo_groups cg ON cg.id = dcg.combo_group_id
JOIN menuca_v3.combo_group_sections cgs ON cgs.combo_group_id = cg.id
JOIN menuca_v3.combo_modifier_groups cmg ON cmg.combo_group_section_id = cgs.id
JOIN menuca_v3.combo_modifiers cm ON cm.combo_modifier_group_id = cmg.id
JOIN menuca_v3.combo_modifier_prices cmp ON cmp.combo_modifier_id = cm.id
WHERE d.id = 133649 
  AND cgs.section_type = 'drinks'
ORDER BY cm.display_order;
```

### Query Result

| dish_id | dish_name | combo_group_id | section_id | section_type | section_header | min | max | modifier_group_id | modifier_name | price |
|---------|-----------|----------------|------------|--------------|----------------|-----|-----|-------------------|---------------|-------|
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Pepsi | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Coke | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Diet Pepsi | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Diet Coke | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Ginger Ale | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Sprite | 0.00 |
| 133649 | 2 Small Donairs and Garlic Fingers | 35 | 4064 | drinks | Drinks | 2 | 2 | 11788 | Iced Tea | 0.00 |

---

## Drinks Configuration

### Combo Group 35 (Used by dishes 133645, 133649, 133650, 133651)

| Component | ID | Value |
|-----------|-----|-------|
| **Section** | 4064 | type: drinks, header: "Drinks" |
| **Min Selection** | - | 2 |
| **Max Selection** | - | 2 |
| **Free Items** | - | 0 |
| **Modifier Group** | 11788 | name: "Drinks", is_selected: true |

### Combo Group 34 (Used by dish 133652)

| Component | ID | Value |
|-----------|-----|-------|
| **Section** | 4065 | type: drinks, header: "Drinks" |
| **Min Selection** | - | 2 |
| **Max Selection** | - | 2 |
| **Free Items** | - | 0 |
| **Modifier Group** | 11789 | name: "Drinks", is_selected: true |

### Available Drinks (Both Groups)

| Modifier ID (Group 35) | Modifier ID (Group 34) | Drink | Price |
|------------------------|------------------------|-------|-------|
| 107001 | 107008 | Pepsi | $0.00 |
| 107002 | 107009 | Coke | $0.00 |
| 107003 | 107010 | Diet Pepsi | $0.00 |
| 107004 | 107011 | Diet Coke | $0.00 |
| 107005 | 107012 | Ginger Ale | $0.00 |
| 107006 | 107013 | Sprite | $0.00 |
| 107007 | 107014 | Iced Tea | $0.00 |

---

## Frontend Implementation Guide

### 1. Fetching Combo Data

When a user selects a combo dish, fetch all combo groups and their sections:

```javascript
// Pseudocode for fetching combo data
async function getComboOptions(dishId) {
  const { data } = await supabase
    .from('dish_combo_groups')
    .select(`
      combo_group_id,
      combo_groups (
        id,
        name_en,
        combo_group_sections (
          id,
          section_type,
          use_header_en,
          min_selection,
          max_selection,
          free_items,
          combo_modifier_groups (
            id,
            name_en,
            is_selected,
            combo_modifiers (
              id,
              name_en,
              display_order,
              combo_modifier_prices (
                price,
                size_variant
              )
            )
          )
        )
      )
    `)
    .eq('dish_id', dishId)
    .eq('is_active', true);
  
  return data;
}
```

### 2. Rendering Drinks Section

```jsx
// React component example
function DrinksSection({ section }) {
  const [selectedDrinks, setSelectedDrinks] = useState([]);
  
  const handleSelect = (modifierId) => {
    if (selectedDrinks.length < section.max_selection) {
      setSelectedDrinks([...selectedDrinks, modifierId]);
    }
  };
  
  return (
    <div className="drinks-section">
      <h3>{section.use_header_en}</h3>
      <p>Select {section.min_selection} drinks</p>
      
      {section.combo_modifier_groups
        .filter(g => g.is_selected)
        .map(group => (
          <div key={group.id}>
            {group.combo_modifiers.map(modifier => (
              <button
                key={modifier.id}
                onClick={() => handleSelect(modifier.id)}
                disabled={selectedDrinks.length >= section.max_selection}
              >
                {modifier.name_en}
                {modifier.combo_modifier_prices[0]?.price > 0 && 
                  ` (+$${modifier.combo_modifier_prices[0].price})`
                }
              </button>
            ))}
          </div>
        ))
      }
      
      <p>Selected: {selectedDrinks.length} / {section.max_selection}</p>
    </div>
  );
}
```

### 3. Validation Rules

| Rule | Description |
|------|-------------|
| **Min Selection** | User MUST select at least `min_selection` items |
| **Max Selection** | User CANNOT select more than `max_selection` items |
| **Free Items** | First `free_items` selections are free (0 in our case) |
| **Price Calculation** | Add modifier price only if selection exceeds `free_items` |

### 4. Order Payload Structure

When submitting an order with combo selections:

```json
{
  "dish_id": 133649,
  "quantity": 1,
  "combo_selections": [
    {
      "combo_group_id": 35,
      "sections": [
        {
          "section_id": 4064,
          "section_type": "drinks",
          "modifiers": [
            { "modifier_id": 107001, "name": "Pepsi", "price": 0.00 },
            { "modifier_id": 107004, "name": "Diet Coke", "price": 0.00 }
          ]
        }
      ]
    }
  ]
}
```

---

## Key Relationships Summary

```
Dish 133649 (2 Small Donairs and Garlic Fingers)
    │
    └── dish_combo_groups.id = 14
        │
        └── combo_group.id = 35 (2 Small Donairs)
            │
            ├── combo_group_sections.id = 4064 (drinks)
            │   │   min_selection: 2
            │   │   max_selection: 2
            │   │
            │   └── combo_modifier_groups.id = 11788 (Drinks)
            │       │   is_selected: true
            │       │
            │       └── combo_modifiers (7 drinks)
            │           ├── 107001: Pepsi ($0.00)
            │           ├── 107002: Coke ($0.00)
            │           ├── 107003: Diet Pepsi ($0.00)
            │           ├── 107004: Diet Coke ($0.00)
            │           ├── 107005: Ginger Ale ($0.00)
            │           ├── 107006: Sprite ($0.00)
            │           └── 107007: Iced Tea ($0.00)
            │
            └── combo_group_sections.id = 53 (extras)
                    use_header_en: "Extras Donair"
                    │
                    └── combo_modifier_groups.id = 479 (Donair extra)
                            is_selected: true
                            │
                            └── combo_modifiers
                                ├── 3446: Cheese ($1.00)
                                └── 3448: Meat ($1.50)
```

---

## Testing Queries

### Get all sections for a combo group
```sql
SELECT * FROM menuca_v3.combo_group_sections 
WHERE combo_group_id = 35;
```

### Get all modifiers for a section
```sql
SELECT cm.*, cmp.price
FROM menuca_v3.combo_modifiers cm
JOIN menuca_v3.combo_modifier_prices cmp ON cmp.combo_modifier_id = cm.id
JOIN menuca_v3.combo_modifier_groups cmg ON cmg.id = cm.combo_modifier_group_id
WHERE cmg.combo_group_section_id = 4064
ORDER BY cm.display_order;
```

### Verify dish has drinks section
```sql
SELECT d.id, d.name_en, cgs.section_type, cgs.use_header_en
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_combo_groups dcg ON dcg.dish_id = d.id
JOIN menuca_v3.combo_group_sections cgs ON cgs.combo_group_id = dcg.combo_group_id
WHERE d.id = 133649 AND cgs.section_type = 'drinks';
```

---

## Important Notes

1. **is_selected flag**: Only render `combo_modifier_groups` where `is_selected = true`
2. **Shared combo groups**: Multiple dishes can share the same combo_group (e.g., group 35 is used by 4 dishes)
3. **Section types**: Common types are 'drinks', 'extras', 'toppings'
4. **Price = 0**: Means the modifier is included in the combo price
5. **Bilingual support**: Always use `name_en` for English, `name_fr` for French based on user preference
