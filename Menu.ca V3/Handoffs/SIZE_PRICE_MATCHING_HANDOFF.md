# Size-Price Matching System - Replit Agent Handoff

> **Last Updated:** January 22, 2026  
> **Schema:** `menuca_v3`  
> **Coverage:** 88% of dish prices mapped

---

## Overview

Menu.ca uses a **two-tier size mapping system** that allows different dish sizes (7", 12", Small, Petit, etc.) to be normalized to standardized modifier price tiers. This enables the frontend to automatically match the correct modifier/topping price when a customer selects a dish size.

**Key Concept:** When a customer orders a "12-inch Pepperoni Pizza" and adds "Mushrooms", the system must know to charge the "Medium" topping price ($3.25), not the "Small" price ($1.65).

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SIZE-PRICE MATCHING FLOW                             │
└─────────────────────────────────────────────────────────────────────────────┘

  DISH LEVEL                    MAPPING LAYER                 MODIFIER LEVEL
  ══════════                    ═════════════                 ══════════════

┌──────────────┐           ┌─────────────────────┐        ┌─────────────────┐
│ dish_prices  │           │ dish_size_variants  │        │ modifier_prices │
│              │           │                     │        │                 │
│ • 7"  → $8   ├──────────►│ 7"  → Small (2)    ├───────►│ Small:  $1.65   │
│ • 12" → $15  ├──────────►│ 12" → Medium (3)   ├───────►│ Medium: $3.25   │
│ • 15" → $18  ├──────────►│ 15" → Large (4)    ├───────►│ Large:  $4.05   │
│              │           │                     │        │                 │
│ dish_size_   │           │ modifier_size_      │        │ modifier_size_  │
│ variant_id   │           │ variant_id          │        │ variant_id      │
└──────────────┘           └─────────────────────┘        └─────────────────┘
```

---

## Core Tables

### 1. `modifier_size_variants` (8 Standard Tiers)

The **canonical reference** for all size-based pricing. Only 8 tiers exist.

| ID | Code | English | French | Usage Count |
|----|------|---------|--------|-------------|
| 1 | standard | Standard | Standard | 45,575 |
| 2 | small | Small | Petite | 23,320 |
| 3 | medium | Medium | Moyenne | 23,021 |
| 4 | large | Large | Grande | 17,160 |
| 5 | x-large | X-Large | X-Grande | 15,583 |
| 6 | size-5 | Size 5 | Taille 5 | 490 |
| 7 | size-6 | Size 6 | Taille 6 | 56 |
| 8 | size-7 | Size 7 | Taille 7 | 53 |

**Most common:** Standard (1), Small (2), Medium (3), Large (4), X-Large (5)

### 2. `dish_size_variants` (72 Aliases)

Maps restaurant-specific size names to the 8 standard tiers.

| Category | Examples | Maps To Tier |
|----------|----------|--------------|
| **size** | Small, Medium, Large, Petit, Grande | 1-5 |
| **dimension** | 7", 9", 12", 14", 16", 18" | 2-5 |
| **combo** | 2 x Small, 2 x Medium, 2 x Large | 2-5 |
| **container** | Can, Canette, Bottle | 1 (Standard) |
| **volume** | 591ml, 2L | 1 (Standard) |
| **portion** | Bambino, Personal, Family, Platter | 2-4 |
| **protein** | Chicken, Beef, Shrimp, Tofu | 1 (Standard) |

### 3. `dish_prices`

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `dish_id` | bigint | FK to dishes |
| `size_variant` | varchar | Display name (e.g., "12\"", "Medium") |
| `price` | numeric | Dish price |
| `dish_size_variant_id` | integer | FK to dish_size_variants |
| `display_order` | integer | Sort order |

### 4. `modifier_prices`

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `modifier_id` | bigint | FK to modifiers |
| `size_variant` | varchar | Display name |
| `price` | numeric | Modifier price |
| `modifier_size_variant_id` | integer | FK to modifier_size_variants |
| `display_order` | integer | Sort order |

---

## Real Example: Pepperoni Pizza at Imilio's

### Dish Prices

| Display Size | Price | `dish_size_variant_id` | Maps to `modifier_size_variant_id` |
|--------------|-------|------------------------|-----------------------------------|
| 7" | $8.30 | 16 (7-inch) | **2 (Small)** |
| 12" | $14.60 | 20 (12-inch) | **3 (Medium)** |

### Modifier Prices (Mushrooms Topping)

| Display Size | Price | `modifier_size_variant_id` |
|--------------|-------|---------------------------|
| Small | $1.65 | **2** ← matches 7" pizza |
| Medium | $3.25 | **3** ← matches 12" pizza |
| Large | $4.05 | 4 |
| XL | $5.05 | 5 |

### Matching Flow

```
Customer selects: 12" Pepperoni Pizza ($14.60)
                         │
                         ▼
dish_prices.dish_size_variant_id = 20 (12-inch)
                         │
                         ▼
dish_size_variants[20].modifier_size_variant_id = 3 (Medium)
                         │
                         ▼
Find modifier_prices WHERE modifier_size_variant_id = 3
                         │
                         ▼
Mushrooms Medium price = $3.25 ✅
```

---

## JSON Response Structure

The `get_restaurant_menu_cached()` function includes all necessary IDs:

```json
{
  "courses": [
    {
      "dishes": [
        {
          "id": 135998,
          "name": "Pepperoni",
          "prices": [
            {
              "id": 41735,
              "size_variant": "7\"",
              "price": 8.30,
              "dish_size_variant_id": 16,
              "modifier_size_variant_id": 2
            },
            {
              "id": 41736,
              "size_variant": "12\"",
              "price": 14.60,
              "dish_size_variant_id": 20,
              "modifier_size_variant_id": 3
            }
          ],
          "modifier_groups": [
            {
              "name": "Pizza Toppings",
              "modifiers": [
                {
                  "name": "Mushrooms",
                  "prices": [
                    {
                      "modifier_size_variant_id": 2,
                      "price": 1.65
                    },
                    {
                      "modifier_size_variant_id": 3,
                      "price": 3.25
                    },
                    {
                      "modifier_size_variant_id": 4,
                      "price": 4.05
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

**Key fields for matching:**
- `dish_prices[].modifier_size_variant_id` - The tier to match
- `modifier_prices[].modifier_size_variant_id` - Find matching tier

---

## Frontend Implementation

### JavaScript: Get Correct Modifier Price

```javascript
/**
 * Get the correct modifier price based on selected dish size
 * 
 * @param {Object} selectedDishPrice - The price object from dish.prices[]
 * @param {Array} modifierPrices - The prices array from modifier.prices[]
 * @returns {number} The price to charge
 */
function getModifierPrice(selectedDishPrice, modifierPrices) {
  const targetSizeId = selectedDishPrice.modifier_size_variant_id;
  
  // 1. Try exact match with dish's modifier size tier
  const exactMatch = modifierPrices.find(
    p => p.modifier_size_variant_id === targetSizeId
  );
  if (exactMatch) return exactMatch.price;
  
  // 2. Fallback to Standard (id: 1)
  const standardPrice = modifierPrices.find(
    p => p.modifier_size_variant_id === 1
  );
  if (standardPrice) return standardPrice.price;
  
  // 3. Ultimate fallback: first available price
  return modifierPrices[0]?.price ?? 0;
}
```

### React Component Example

```jsx
function DishCustomizer({ dish }) {
  const [selectedPriceIndex, setSelectedPriceIndex] = useState(0);
  const selectedPrice = dish.prices[selectedPriceIndex];
  
  return (
    <div>
      {/* Size Selection */}
      <div className="size-selector">
        {dish.prices.map((price, idx) => (
          <button 
            key={price.id}
            onClick={() => setSelectedPriceIndex(idx)}
            className={idx === selectedPriceIndex ? 'selected' : ''}
          >
            {price.size_variant} - ${price.price.toFixed(2)}
          </button>
        ))}
      </div>
      
      {/* Modifier Groups */}
      {dish.modifier_groups.map(group => (
        <ModifierGroup 
          key={group.id}
          group={group}
          selectedDishPrice={selectedPrice}
        />
      ))}
    </div>
  );
}

function ModifierGroup({ group, selectedDishPrice }) {
  return (
    <div className="modifier-group">
      <h4>{group.name}</h4>
      {group.modifiers.map(modifier => {
        // Get correct price for selected dish size
        const price = getModifierPrice(selectedDishPrice, modifier.prices);
        
        return (
          <label key={modifier.id}>
            <input type="checkbox" />
            {modifier.name}
            {price > 0 && <span> (+${price.toFixed(2)})</span>}
          </label>
        );
      })}
    </div>
  );
}
```

### Order Calculation Example

```javascript
function calculateOrderTotal(dish, selectedPriceIndex, selectedModifiers) {
  const selectedDishPrice = dish.prices[selectedPriceIndex];
  let total = selectedDishPrice.price;
  
  // Add modifier prices
  for (const modifier of selectedModifiers) {
    const modifierPrice = getModifierPrice(selectedDishPrice, modifier.prices);
    total += modifierPrice;
  }
  
  return total;
}

// Example usage:
// Customer orders 12" Pepperoni with Mushrooms and Pepperoni toppings
const dish = menuData.courses[0].dishes[0]; // Pepperoni pizza
const selectedPriceIndex = 1; // 12" ($14.60)
const selectedModifiers = [
  dish.modifier_groups[0].modifiers[0], // Mushrooms
  dish.modifier_groups[0].modifiers[1], // Pepperoni
];

const total = calculateOrderTotal(dish, selectedPriceIndex, selectedModifiers);
// $14.60 + $3.25 + $3.25 = $21.10
```

---

## Common Size Mappings Reference

### Pizza Dimensions → Modifier Tiers

| Dimension | Typical Name | modifier_size_variant_id |
|-----------|--------------|--------------------------|
| 6" - 9" | Small / Personal | 2 (Small) |
| 10" - 13" | Medium | 3 (Medium) |
| 14" - 16" | Large | 4 (Large) |
| 17" - 18" | X-Large / Jumbo | 5 (X-Large) |

### Named Sizes → Modifier Tiers

| English | French | modifier_size_variant_id |
|---------|--------|--------------------------|
| Small | Petit / Petite | 2 |
| Medium | Moyen / Moyenne | 3 |
| Large | Grand / Grande | 4 |
| X-Large | X-Grand / X-Grande | 5 |

### Special Cases

| Variant Type | Maps To | Reason |
|--------------|---------|--------|
| Protein (Chicken, Beef, etc.) | Standard (1) | Price same regardless of protein |
| Can / Bottle | Standard (1) | Single-serve drinks |
| 2 x Small | Small (2) | Combo deals follow base size |
| Personal / Bambino | Small (2) | Individual portions |
| Family / Platter | Large (4) | Sharing portions |

---

## Edge Cases & Fallbacks

### 1. Dish has NULL modifier_size_variant_id

**Cause:** Non-size variants (quantities, flavors, etc.)  
**Solution:** Use Standard (1) price or first available price

```javascript
if (!selectedDishPrice.modifier_size_variant_id) {
  // Fallback to Standard or first price
  return modifierPrices.find(p => p.modifier_size_variant_id === 1)?.price 
      ?? modifierPrices[0]?.price 
      ?? 0;
}
```

### 2. Modifier has no matching size tier

**Cause:** Modifier only has Standard pricing  
**Solution:** Use Standard price

```javascript
// If exact match fails, always check for Standard (1)
const price = modifierPrices.find(p => p.modifier_size_variant_id === 1);
```

### 3. Dish with single price (no size variants)

**Cause:** Fixed-price items (drinks, sides)  
**Solution:** Use that single price; modifiers will be Standard

---

## Data Quality Statistics

| Metric | Value |
|--------|-------|
| Total dish_prices | 41,526 |
| With size mapping | 36,528 (88.0%) |
| Without mapping | 4,998 (12.0%) |
| modifier_prices coverage | 125,258 (100%) |

### Unmapped dish_prices (intentional)

These 4,998 records don't need size mapping:
- **Quantities:** 1 pc, 10 pcs, 20 wings (~1,200)
- **Flavors:** Cinnamon Sugar, Oreo (~500)
- **Drinks:** Pepsi, Coke, Ginger Ale (~400)
- **Heat levels:** Hot, Mild, Spicy (~150)
- **Sauces:** Ranch, BBQ (~300)
- **Other:** Sushi styles, packages (~2,400)

---

## SQL Queries for Reference

### Get dish with all size info

```sql
SELECT 
    d.name_en AS dish,
    dp.size_variant AS display_size,
    dp.price,
    dp.dish_size_variant_id,
    dsv.name_en AS size_name,
    dsv.modifier_size_variant_id,
    msv.name_en AS modifier_tier
FROM menuca_v3.dish_prices dp
JOIN menuca_v3.dishes d ON d.id = dp.dish_id
LEFT JOIN menuca_v3.dish_size_variants dsv ON dsv.id = dp.dish_size_variant_id
LEFT JOIN menuca_v3.modifier_size_variants msv ON msv.id = dsv.modifier_size_variant_id
WHERE d.id = 135998  -- Pepperoni pizza
AND dp.deleted_at IS NULL
ORDER BY dp.display_order;
```

### Get modifier prices with size tiers

```sql
SELECT 
    m.name_en AS modifier,
    mp.size_variant AS display_size,
    mp.price,
    mp.modifier_size_variant_id,
    msv.name_en AS tier_name
FROM menuca_v3.modifier_prices mp
JOIN menuca_v3.modifiers m ON m.id = mp.modifier_id
JOIN menuca_v3.modifier_size_variants msv ON msv.id = mp.modifier_size_variant_id
WHERE m.modifier_group_id = 467  -- Pizza Toppings group
AND m.name_en = 'Mushrooms'
AND mp.deleted_at IS NULL
ORDER BY mp.modifier_size_variant_id;
```

### Find dishes missing size mapping

```sql
SELECT 
    dp.size_variant,
    COUNT(*) AS count,
    COUNT(DISTINCT d.restaurant_id) AS restaurants
FROM menuca_v3.dish_prices dp
JOIN menuca_v3.dishes d ON d.id = dp.dish_id
WHERE dp.deleted_at IS NULL
AND dp.dish_size_variant_id IS NULL
GROUP BY dp.size_variant
ORDER BY count DESC
LIMIT 20;
```

---

## Common Pitfalls

### 1. Ignoring modifier_size_variant_id

❌ **Wrong:**
```javascript
const toppingPrice = modifier.prices[0].price; // Always first price
```

✅ **Correct:**
```javascript
const toppingPrice = getModifierPrice(selectedDishPrice, modifier.prices);
```

### 2. Hardcoding size tiers

❌ **Wrong:**
```javascript
if (selectedSize === 'Large') {
  return modifier.prices.find(p => p.size_variant === 'Large')?.price;
}
```

✅ **Correct:**
```javascript
// Use modifier_size_variant_id, not display names
const price = modifier.prices.find(
  p => p.modifier_size_variant_id === selectedDishPrice.modifier_size_variant_id
)?.price;
```

### 3. Forgetting fallbacks

❌ **Wrong:**
```javascript
return modifier.prices.find(p => p.modifier_size_variant_id === targetId).price;
// Crashes if no match!
```

✅ **Correct:**
```javascript
const match = modifier.prices.find(p => p.modifier_size_variant_id === targetId);
return match?.price ?? modifier.prices[0]?.price ?? 0;
```

---

## Implementation Checklist

- [ ] Fetch menu via `get_restaurant_menu_cached()`
- [ ] Store selected `dish_price` object (not just the price value)
- [ ] Use `dish_price.modifier_size_variant_id` for matching
- [ ] Implement `getModifierPrice()` with fallback logic
- [ ] Handle dishes with NULL `modifier_size_variant_id`
- [ ] Test with multi-size pizzas (most common case)
- [ ] Test with single-price items
- [ ] Test with combo meals

---

## Related Documentation

| Document | Description |
|----------|-------------|
| `BILINGUAL_MENU_HANDOFF.md` | Menu fetching, caching, language support |
| `COMBO_MODIFIER_GROUPS_HANDOFF.md` | Combo meal structure |
| `../entities/03-menu-management-entity.md` | Full schema documentation |

---

**Document Created:** January 22, 2026
