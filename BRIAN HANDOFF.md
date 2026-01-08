# Size-Price Selection Logic - Frontend Implementation Guide

## Overview

The V3 schema uses a **normalized size variant system** to match dish prices with modifier/combo modifier prices. Instead of relying on exact string matching (e.g., "Medium" === "Medium"), we now use **foreign key IDs** (`modifier_size_variant_id`) for reliable matching.

---

## Key Concept: `modifier_size_variant_id`

Every price record now includes a `modifier_size_variant_id` that maps to a standardized size:

| modifier_size_variant_id | Code | English | French |
|--------------------------|------|---------|--------|
| 1 | standard | Standard | Standard |
| 2 | small | Small | Petite |
| 3 | medium | Medium | Moyenne |
| 4 | large | Large | Grande |
| 5 | x-large | X-Large | X-Grande |

---

## Data Structure in `get_restaurant_menu` Response

### 1. Dish Prices

```json
{
  "id": 172885,
  "name": "Walk-In Special (Medium Pizza)",
  "prices": [
    {
      "id": 110178,
      "price": 15.00,
      "size_variant": "Standard",
      "display_order": 0,
      "dish_size_variant_id": 3,
      "modifier_size_variant_id": 3  // ← USE THIS FOR MATCHING
    }
  ]
}
```

### 2. Regular Modifier Prices (non-combo dishes)

```json
{
  "id": 12345,
  "name": "Extra Cheese",
  "prices": [
    { "id": 1, "size_variant": "Small", "modifier_size_variant_id": 2, "price": 1.00 },
    { "id": 2, "size_variant": "Medium", "modifier_size_variant_id": 3, "price": 2.00 },
    { "id": 3, "size_variant": "Large", "modifier_size_variant_id": 4, "price": 3.00 }
  ]
}
```

### 3. Combo Modifier Prices

```json
{
  "id": 11787,
  "name": "Pizza Toppings",
  "modifiers": [
    {
      "id": 106813,
      "name": "Beef Pepperoni",
      "prices": [
        { "id": 381824, "size_variant": "Small", "modifier_size_variant_id": 2, "price": 1.00 },
        { "id": 381890, "size_variant": "Medium", "modifier_size_variant_id": 3, "price": 2.00 },
        { "id": 381956, "size_variant": "Large", "modifier_size_variant_id": 4, "price": 3.00 }
      ]
    }
  ]
}
```

---

## Matching Logic

### For Regular Dishes with Modifiers

```
1. User selects a dish price (e.g., "Medium Pizza" → dish_price.modifier_size_variant_id = 3)
2. For each modifier the user selects:
   - Find the modifier_price where modifier_price.modifier_size_variant_id === dish_price.modifier_size_variant_id
   - Use that price
```

**Example:**
- User orders "Medium Pizza" (`modifier_size_variant_id: 3`)
- User adds "Extra Cheese"
- Match: `modifier_price.modifier_size_variant_id === 3` → $2.00

### For Combo Dishes with Combo Modifiers

```
1. User selects a combo dish price (e.g., "Walk-In Special" → dish_price.modifier_size_variant_id = 3)
2. For each combo modifier the user selects:
   - Find the combo_modifier_price where combo_modifier_price.modifier_size_variant_id === dish_price.modifier_size_variant_id
   - Use that price
```

**Example:**
- User orders "Walk-In Special (Medium Pizza)" (`modifier_size_variant_id: 3`)
- User adds "Beef Pepperoni" topping
- Match: `combo_modifier_price.modifier_size_variant_id === 3` → $2.00

---

## Edge Cases

### 1. Single-Price Modifiers (No Size Variants)

When a modifier has only one price with `modifier_size_variant_id: 1` (Standard):

```json
{
  "name": "Ranch Dip",
  "prices": [
    { "modifier_size_variant_id": 1, "price": 1.50 }
  ]
}
```

**Logic:** Use the single price regardless of dish size.

### 2. No Matching Size Found

If `dish_price.modifier_size_variant_id` doesn't match any `modifier_price.modifier_size_variant_id`:

1. Check if modifier has a `modifier_size_variant_id: 1` (Standard) price → use that
2. Otherwise, use the first price in the array (fallback)

### 3. Dishes with Multiple Prices (Size Selection)

```json
{
  "name": "Pepperoni Pizza",
  "prices": [
    { "size_variant": "Small", "modifier_size_variant_id": 2, "price": 12.00 },
    { "size_variant": "Medium", "modifier_size_variant_id": 3, "price": 15.00 },
    { "size_variant": "Large", "modifier_size_variant_id": 4, "price": 18.00 }
  ]
}
```

When user selects "Medium" ($15.00), store `modifier_size_variant_id: 3` for all subsequent modifier price lookups.

### 4. Single-Price Dishes

```json
{
  "name": "Caesar Salad",
  "prices": [
    { "size_variant": "Standard", "modifier_size_variant_id": 1, "price": 9.99 }
  ]
}
```

**Logic:** Use `modifier_size_variant_id: 1` for matching. Modifiers will either:
- Have a Standard price (`modifier_size_variant_id: 1`) → use it
- Have no Standard price → use first/only price

---

## Pseudocode Implementation

```javascript
function getModifierPrice(dishPrice, modifierPrices) {
  const targetSizeId = dishPrice.modifier_size_variant_id;
  
  // 1. Try exact match
  const exactMatch = modifierPrices.find(p => p.modifier_size_variant_id === targetSizeId);
  if (exactMatch) return exactMatch.price;
  
  // 2. Fallback to Standard (id: 1)
  const standardPrice = modifierPrices.find(p => p.modifier_size_variant_id === 1);
  if (standardPrice) return standardPrice.price;
  
  // 3. Ultimate fallback: first price
  return modifierPrices[0]?.price ?? 0;
}

// Same logic works for combo modifiers
function getComboModifierPrice(dishPrice, comboModifierPrices) {
  return getModifierPrice(dishPrice, comboModifierPrices); // Identical logic
}
```

---

## Summary

| Field | Found In | Purpose |
|-------|----------|---------|
| `dish_size_variant_id` | dish_prices | Links to expanded dish size table (internal use) |
| `modifier_size_variant_id` | dish_prices, modifier_prices, combo_modifier_prices | **USE THIS** for price matching |

**The Rule:** Match `dish_price.modifier_size_variant_id` with `modifier_price.modifier_size_variant_id` (or `combo_modifier_price.modifier_size_variant_id`) to get the correct price.

---

## Test Case: Walk-In Special (Medium Pizza)

**Restaurant:** Capital Bites (ID: 973)  
**Dish:** Walk-In Special (Medium Pizza) (ID: 172885)

```sql
SELECT menuca_v3.get_restaurant_menu(973);
```

**Expected Behavior:**
- Dish price: `modifier_size_variant_id: 3` (Medium)
- Pizza Toppings (combo modifiers): Should use prices where `modifier_size_variant_id: 3`
  - Beef Pepperoni: $2.00 (not $1.00 Small, not $3.00 Large)

