# Bilingual Menu System - Replit Agent Handoff

> **Last Updated:** January 22, 2026  
> **Schema:** `menuca_v3`  
> **Coverage:** 186 restaurants (100% cached)

---

## Overview

The Menu.ca platform supports **English/French bilingual menus**. All menu data (dishes, categories, modifiers, combos) has both `_en` and `_fr` columns. Menu data is fetched via SQL functions that handle language selection, caching, and data aggregation.

**Primary API:** `menuca_v3.get_restaurant_menu_cached()`

---

## Database Schema - Bilingual Columns

### Tables with Bilingual Support (8 tables)

| Table | Bilingual Columns |
|-------|-------------------|
| `courses` | `name_en`, `name_fr`, `description_en`, `description_fr` |
| `dishes` | `name_en`, `name_fr`, `description_en`, `description_fr` |
| `modifier_groups` | `name_en`, `name_fr` |
| `modifiers` | `name_en`, `name_fr` |
| `combo_groups` | `name_en`, `name_fr`, `special_display_header_en`, `special_display_header_fr` |
| `combo_group_sections` | `use_header_en`, `use_header_fr` |
| `combo_modifier_groups` | `name_en`, `name_fr` |
| `combo_modifiers` | `name_en`, `name_fr` |

---

## API Reference

### Primary Function: `get_restaurant_menu_cached()`

**Always use this function.** It's fast, pre-computed, and handles language automatically.

```sql
-- Function signature
menuca_v3.get_restaurant_menu_cached(
    p_restaurant_id bigint,        -- Required: restaurant ID
    p_language_code text DEFAULT 'en'  -- Optional: 'en' or 'fr'
) RETURNS jsonb
```

### Example Calls

```javascript
// Supabase JavaScript Client
const { data, error } = await supabase
  .rpc('get_restaurant_menu_cached', {
    p_restaurant_id: 973,
    p_language_code: 'en'  // or 'fr' for French
  });
```

```bash
# Using curl
curl -X POST "${SUPABASE_URL}/rest/v1/rpc/get_restaurant_menu_cached" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"p_restaurant_id": 973, "p_language_code": "fr"}'
```

### Fallback Function: `get_restaurant_menu()`

Use only if you need real-time data or the cache is empty:

```sql
menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint,
    p_language_code text DEFAULT 'en',
    p_combo_default_only boolean DEFAULT false
) RETURNS jsonb
```

---

## Cache System Architecture

### How It Works

```
1. Menu data changes (dish, price, modifier, etc.)
         ↓
2. Trigger fires → invalidate_menu_cache(restaurant_id)
         ↓
3. Cache entries set to NULL
         ↓
4. Next request via get_restaurant_menu_cached()
         ↓
5. Cache miss → Falls back to get_restaurant_menu() (live query)
```

### Cache Table: `restaurant_menu_cache`

| Column | Type | Description |
|--------|------|-------------|
| `restaurant_id` | bigint | PK, FK to restaurants |
| `menu_cache_en` | jsonb | Pre-computed English menu |
| `menu_cache_fr` | jsonb | Pre-computed French menu |
| `updated_at` | timestamptz | Last cache update |

### Auto-Invalidation Triggers

Cache automatically invalidates when these tables change:
- `dishes`, `dish_prices`, `dish_availability`
- `courses`
- `modifier_groups`, `modifiers`, `modifier_prices`, `modifier_group_details`
- `dish_modifier_groups`
- `combo_groups`, `combo_group_sections`, `dish_combo_groups`

### Admin Functions

```sql
-- Rebuild cache for single restaurant
SELECT menuca_v3.rebuild_menu_cache(973);

-- Rebuild ALL restaurant caches (186 restaurants, ~2-5 min)
SELECT * FROM menuca_v3.rebuild_all_menu_caches();

-- Manually invalidate cache
SELECT menuca_v3.invalidate_menu_cache(973);
```

---

## Response Structure

Both functions return the same **JSONB structure**:

```json
{
  "restaurant_id": 973,
  "courses": [
    {
      "id": 12345,
      "uuid": "abc-123-...",
      "name": "Pizzas",
      "description": "Our delicious pizzas",
      "display_order": 1,
      "dishes": [
        {
          "id": 172885,
          "uuid": "def-456-...",
          "name": "Pepperoni Pizza",
          "description": "Classic pepperoni with mozzarella",
          "display_order": 1,
          "is_combo": false,
          "has_customization": true,
          "is_featured": false,
          "hidden_days": null,
          "prices": [
            {
              "id": 110178,
              "size_variant": "Small",
              "dish_size_variant_id": 2,
              "modifier_size_variant_id": 2,
              "price": 12.99,
              "display_order": 1
            },
            {
              "id": 110179,
              "size_variant": "Medium",
              "dish_size_variant_id": 3,
              "modifier_size_variant_id": 3,
              "price": 15.99,
              "display_order": 2
            }
          ],
          "modifier_groups": [
            {
              "id": 5678,
              "name": "Extra Toppings",
              "min_selections": 0,
              "max_selections": 10,
              "free_items": 0,
              "display_order": 1,
              "modifiers": [
                {
                  "id": 9012,
                  "name": "Mushrooms",
                  "display_order": 1,
                  "prices": [
                    {
                      "id": 3456,
                      "size_variant": "Small",
                      "modifier_size_variant_id": 2,
                      "price": 1.50
                    },
                    {
                      "id": 3457,
                      "size_variant": "Medium",
                      "modifier_size_variant_id": 3,
                      "price": 2.00
                    }
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

## Language Behavior

### What Changes Between Languages

| Field | English (`'en'`) | French (`'fr'`) |
|-------|------------------|-----------------|
| `courses[].name` | "Pizzas" | "Pizzas" |
| `courses[].description` | "Our delicious pizzas" | "Nos délicieuses pizzas" |
| `dishes[].name` | "Pepperoni Pizza" | "Pizza Pepperoni" |
| `dishes[].description` | "Classic pepperoni..." | "Pepperoni classique..." |
| `modifier_groups[].name` | "Extra Toppings" | "Garnitures supplémentaires" |
| `modifiers[].name` | "Mushrooms" | "Champignons" |

### What Does NOT Change

- All IDs (`id`, `uuid`)
- All prices (`price`)
- All numeric fields (`display_order`, `min_selections`, `max_selections`)
- Size variant IDs (`dish_size_variant_id`, `modifier_size_variant_id`)
- Boolean flags (`is_combo`, `has_customization`, `is_featured`)
- `hidden_days` array

### Automatic Fallback

If a French translation is missing, the function automatically falls back to English:

```sql
-- Internal logic
COALESCE(name_fr, name_en) as name
```

**You will NEVER get NULL for name/description fields.**

---

## Size-Price Matching (Critical!)

### The Problem

When a customer selects a "Medium" pizza, modifier prices (toppings) must match the "Medium" size tier.

### The Solution: `modifier_size_variant_id`

Every price record includes `modifier_size_variant_id` linking dish sizes to modifier sizes:

```
Dish Price:     modifier_size_variant_id = 3 (Medium)
                         ↓
Modifier Price: modifier_size_variant_id = 3 (Medium) ← MATCH!
```

### Standard Size Tiers

| modifier_size_variant_id | Code | English | French |
|--------------------------|------|---------|--------|
| 1 | standard | Standard | Standard |
| 2 | small | Small | Petite |
| 3 | medium | Medium | Moyenne |
| 4 | large | Large | Grande |
| 5 | x-large | X-Large | X-Grande |
| 6 | size-5 | Size 5 | Taille 5 |
| 7 | size-6 | Size 6 | Taille 6 |
| 8 | size-7 | Size 7 | Taille 7 |

### Frontend Implementation

```javascript
/**
 * Get the correct modifier price based on selected dish size
 */
function getModifierPrice(selectedDishPrice, modifierPrices) {
  const targetSizeId = selectedDishPrice.modifier_size_variant_id;
  
  // 1. Try exact match
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

---

## Dish Availability (hidden_days)

Some dishes are only available on certain days of the week.

### Format

```json
{
  "hidden_days": [0, 6]  // Hidden on Sunday (0) and Saturday (6)
}
```

Or `null` if dish is available every day.

### Day Mapping

| Value | Day |
|-------|-----|
| 0 | Sunday |
| 1 | Monday |
| 2 | Tuesday |
| 3 | Wednesday |
| 4 | Thursday |
| 5 | Friday |
| 6 | Saturday |

### Frontend Implementation

```javascript
function isDishAvailableToday(dish) {
  if (!dish.hidden_days || dish.hidden_days.length === 0) {
    return true;
  }
  const today = new Date().getDay(); // 0-6
  return !dish.hidden_days.includes(today);
}
```

---

## Combo Meals

Combo dishes have `is_combo: true` and include `combo_groups` array.

### Structure

```json
{
  "id": 172900,
  "name": "Family Combo",
  "is_combo": true,
  "combo_groups": [
    {
      "id": 500,
      "name": "Family Combo",
      "special_number_of_items": 2,
      "special_display_header": "Choose 2 Pizzas",
      "sections": [
        {
          "id": 1001,
          "section_type": "size",
          "header": "Select Size",
          "min_selection": 1,
          "max_selection": 1,
          "free_items": 0,
          "modifier_groups": [...]
        }
      ]
    }
  ]
}
```

### Section Types

| section_type | Purpose |
|--------------|---------|
| `size` | Size selection (Small/Medium/Large) |
| `crust` | Crust/bread type |
| `custom_ingredients` | Toppings, add-ons |
| `dip` | Dipping sauces |
| `drinks` | Beverage selection |
| `side` | Side dishes |

> **See also:** `COMBO_MODIFIER_GROUPS_HANDOFF.md` for detailed combo documentation.

---

## Translation Quality Statistics

| Metric | Value |
|--------|-------|
| **Total Restaurants** | 186 |
| **Cached Restaurants** | 186 (100%) |
| **Total Cache Size** | ~28 MB |
| **Restaurants with French translations** | 185/186 (99.5%) |

### Actual Translation Rates

| Table | Total Records | Actually Different French | % Real Translations |
|-------|--------------|---------------------------|---------------------|
| `dishes` | 24,036 | 18,681 | **77.7%** |
| `courses` | 2,954 | 2,359 | **79.9%** |
| `modifier_groups` | 2,873 | 2,638 | **91.8%** |
| `modifiers` | 68,895 | 55,127 | **80.0%** |
| `combo_groups` | 2,182 | 1,745 | **80.0%** |
| `combo_modifiers` | 76,885 | 61,508 | **80.0%** |

**Note:** 100% of records have both `_en` and `_fr` columns populated. The percentages above show records where French text actually differs from English (real translations vs. copied text).

---

## Common Pitfalls

### 1. Use Cached Function for Production

❌ **Wrong:**
```javascript
const { data } = await supabase.rpc('get_restaurant_menu', { p_restaurant_id: 973 });
```

✅ **Correct:**
```javascript
const { data } = await supabase.rpc('get_restaurant_menu_cached', { p_restaurant_id: 973 });
```

### 2. Don't Fetch Tables Directly

❌ **Wrong:**
```javascript
const { data } = await supabase.from('dishes').select('*');
```

✅ **Correct:**
```javascript
const { data } = await supabase.rpc('get_restaurant_menu_cached', { p_restaurant_id: 973 });
```

### 3. Always Handle Size Matching

❌ **Wrong:**
```javascript
const toppingPrice = modifier.prices[0].price; // Always uses first price
```

✅ **Correct:**
```javascript
const toppingPrice = getModifierPrice(selectedDishPrice, modifier.prices);
```

### 4. Check for Combo vs Regular Dish

```javascript
if (dish.is_combo) {
  renderComboSelector(dish.combo_groups);
} else if (dish.has_customization) {
  renderModifierSelector(dish.modifier_groups);
} else {
  renderPriceSelector(dish.prices);
}
```

### 5. Handle hidden_days for Availability

```javascript
const availableDishes = course.dishes.filter(isDishAvailableToday);
```

---

## Testing Queries

### Test Cached English Menu
```javascript
const { data, error } = await supabase.rpc('get_restaurant_menu_cached', { 
  p_restaurant_id: 973 
});
console.log('English menu:', data);
```

### Test Cached French Menu
```javascript
const { data, error } = await supabase.rpc('get_restaurant_menu_cached', { 
  p_restaurant_id: 973,
  p_language_code: 'fr'
});
console.log('French menu:', data);
```

### Verify Language Difference
```javascript
const [en, fr] = await Promise.all([
  supabase.rpc('get_restaurant_menu_cached', { p_restaurant_id: 7 }),
  supabase.rpc('get_restaurant_menu_cached', { p_restaurant_id: 7, p_language_code: 'fr' })
]);

console.log('EN:', en.data.courses[0].dishes[0].name);
console.log('FR:', fr.data.courses[0].dishes[0].name);
// EN: "Baked Lasagna"
// FR: "Lasagne au four"
```

### SQL: Check Cache Status
```sql
SELECT 
  COUNT(*) as total_cached,
  COUNT(menu_cache_en) as valid_en,
  COUNT(menu_cache_fr) as valid_fr
FROM menuca_v3.restaurant_menu_cache;
```

---

## Performance Notes

| Operation | Expected Time |
|-----------|---------------|
| Cached menu fetch | **< 50ms** |
| Live menu fetch | 200-500ms |
| Cache rebuild (single) | 1-3 seconds |
| Cache rebuild (all 186) | 2-5 minutes |

---

## Implementation Checklist

- [ ] Use `get_restaurant_menu_cached()` for all menu fetches
- [ ] Pass `p_language_code` based on user preference ('en' or 'fr')
- [ ] Use `modifier_size_variant_id` for price matching
- [ ] Filter dishes by `hidden_days` for current day
- [ ] Handle `is_combo` dishes differently from regular dishes
- [ ] Show proper modifier selection UI with min/max constraints
- [ ] Calculate combo free items correctly

---

## Related Documentation

| Document | Description |
|----------|-------------|
| `COMBO_MODIFIER_GROUPS_HANDOFF.md` | Detailed combo/modifier structure |
| `DISTANCE_BASED_RESTAURANTS_HANDOFF.md` | Delivery fee calculation |
| `../entities/03-menu-management-entity.md` | Full menu entity documentation |

---

**Document Created:** January 22, 2026
