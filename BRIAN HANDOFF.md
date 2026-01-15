# Combo Group Dish Selections - Frontend Integration Guide

## Overview

The `combo_group_dish_selections` table enables **combo deals where customers choose dishes from a list** (e.g., "Pick any 2 pizzas from our menu"). This is different from modifier-based combos where customers select toppings or add-ons.

---

## Database Schema

### Table: `menuca_v3.combo_group_dish_selections`

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `combo_group_id` | integer | FK → combo_groups.id |
| `dish_id` | integer | FK → dishes.id (the selectable dish) |
| `size` | smallint | Size variant (1=Small, 2=Medium, 3=Large, etc.) |
| `dish_display_name` | text | Formatted name with size (e.g., "Pepperoni Pizza Large") |
| `course_id` | integer | FK → courses.id (optional, for grouping) |
| `created_at` | timestamp | Creation timestamp |
| `deleted_at` | timestamp | Soft delete (NULL = active) |

---

## Relationship Diagram

```
┌─────────────────────┐
│       dishes        │  ← Parent dish (the combo item customer orders)
│  e.g., "2 Pizza     │
│   Combo Deal"       │
└─────────┬───────────┘
          │
          │ dish_combo_groups (link table)
          ▼
┌─────────────────────┐
│    combo_groups     │  ← Defines the selection rules
│  e.g., "Choose 2    │
│   Pizzas from Menu" │
│                     │
│  • number_of_items  │  ← How many selections required
│  • display_header   │  ← UI labels ("First Pizza;Second Pizza")
└─────────┬───────────┘
          │
          │ combo_group_dish_selections
          ▼
┌─────────────────────┐
│       dishes        │  ← Selectable dishes (the options)
│  e.g., "Pepperoni   │
│   Pizza", "Hawaiian │
│   Pizza", etc.      │
└─────────────────────┘
```

---

## API Response Structure

The `get_restaurant_menu` function returns `dish_selections` inside each `combo_group`:

```json
{
  "courses": [
    {
      "id": 123,
      "name": "Super Specials",
      "dishes": [
        {
          "id": 132348,
          "name": "Large Pizza & Wings",
          "prices": [...],
          "combo_groups": [
            {
              "id": 2022,
              "name": "1 Large Pizza from Menu",
              "number_of_items": 1,
              "display_header": "Choose Your Pizza",
              "dish_selections": [
                {
                  "id": 25,
                  "dish_id": 132351,
                  "size": 2,
                  "dish_display_name": "Cheese Pizza Large",
                  "dish_name": "Cheese Pizza",
                  "dish_is_active": true,
                  "course_id": 2018
                },
                {
                  "id": 26,
                  "dish_id": 132352,
                  "size": 2,
                  "dish_display_name": "Pepperoni Pizza Large",
                  "dish_name": "Pepperoni Pizza",
                  "dish_is_active": true,
                  "course_id": 2018
                }
                // ... more pizza options
              ],
              "sections": [...]  // modifier-based sections (toppings, etc.)
            },
            {
              "id": 2025,
              "name": "Wings Sauces",
              "dish_selections": [],  // Empty - uses modifiers instead
              "sections": [...]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Frontend Rendering Logic

### Step 1: Detect Combo Type

```typescript
interface ComboGroup {
  id: number;
  name: string;
  number_of_items: number;
  display_header: string | null;
  dish_selections: DishSelection[];
  sections: ComboSection[];
}

interface DishSelection {
  id: number;
  dish_id: number;
  size: number | null;
  dish_display_name: string | null;
  dish_name: string;
  dish_is_active: boolean;
  course_id: number | null;
}

function getComboType(comboGroup: ComboGroup): 'dish_selection' | 'modifier' | 'mixed' {
  const hasDishSelections = comboGroup.dish_selections.length > 0;
  const hasModifierSections = comboGroup.sections.length > 0;
  
  if (hasDishSelections && !hasModifierSections) return 'dish_selection';
  if (!hasDishSelections && hasModifierSections) return 'modifier';
  return 'mixed';  // Has both - re nder dish selections first, then modifiers
}
```

### Step 2: Render Dish Selection UI

For combo groups with `dish_selections`, render a dropdown or radio button list:

```tsx
function DishSelectionCombo({ comboGroup, onSelect }) {
  const { dish_selections, number_of_items, display_header } = comboGroup;
  
  // Parse display headers (semicolon-separated for multiple selections)
  const headers = display_header?.split(';') || [];
  
  // Filter to only active dishes
  const activeSelections = dish_selections.filter(s => s.dish_is_active);
  
  // For single selection (number_of_items = 1)
  if (number_of_items === 1) {
    return (
      <div className="combo-selection">
        <label>{headers[0] || comboGroup.name}</label>
        <select onChange={(e) => onSelect([e.target.value])}>
          <option value="">-- Select --</option>
          {activeSelections.map(selection => (
            <option key={selection.id} value={selection.id}>
              {selection.dish_display_name || selection.dish_name}
            </option>
          ))}
        </select>
      </div>
    );
  }
  
  // For multiple selections (number_of_items > 1)
  return (
    <div className="combo-multi-selection">
      {Array.from({ length: number_of_items }).map((_, index) => (
        <div key={index} className="selection-slot">
          <label>{headers[index] || `Selection ${index + 1}`}</label>
          <select onChange={(e) => handleMultiSelect(index, e.target.value)}>
            <option value="">-- Select --</option>
            {activeSelections.map(selection => (
              <option key={selection.id} value={selection.id}>
                {selection.dish_display_name || selection.dish_name}
              </option>
            ))}
          </select>
        </div>
      ))}
    </div>
  );
}
```

### Step 3: Handle Selection State

```typescript
interface ComboSelection {
  combo_group_id: number;
  selections: {
    slot: number;  // 0-indexed position (for multi-select)
    dish_selection_id: number;
    dish_id: number;
    dish_name: string;
  }[];
}

// Track selections in cart/order state
const [comboSelections, setComboSelections] = useState<ComboSelection[]>([]);
```

---

## Key Display Rules

### 1. Use `dish_display_name` When Available
```typescript
// Preferred: "Pepperoni Pizza Large" (includes size context)
const displayName = selection.dish_display_name || selection.dish_name;
```

### 2. Filter Inactive Dishes
```typescript
// Never show inactive dishes to customers
const visibleSelections = dish_selections.filter(s => s.dish_is_active);
```

### 3. Parse `display_header` for Labels
```typescript
// "First Pizza;Second Pizza" → ["First Pizza", "Second Pizza"]
const labels = comboGroup.display_header?.split(';') || [];
```

### 4. Validate `number_of_items`
```typescript
// Ensure customer selects the required number
const isComplete = selectedCount === comboGroup.number_of_items;
```

---

## Real Examples

### Example 1: Single Pizza Selection
**Dish**: "Large Pizza & Wings" (ID: 132348)
**Combo Group**: "1 Large Pizza from Menu" (ID: 2022)

```json
{
  "number_of_items": 1,
  "display_header": "Choose Your Pizza",
  "dish_selections": [
    {"dish_display_name": "Cheese Pizza Large", "dish_id": 132351},
    {"dish_display_name": "Pepperoni Pizza Large", "dish_id": 132352},
    {"dish_display_name": "Hawaiian Pizza Large", "dish_id": 132354}
    // ... 12 total options
  ]
}
```

**UI**: Single dropdown with 12 pizza options.

---

### Example 2: Multiple Sandwich Selection
**Dish**: "2 Sandwich Combos" (ID: 141128)
**Combo Group**: "2 Sandwich Combo" (ID: 1954)

```json
{
  "number_of_items": 2,
  "display_header": "First Item;Second Item",
  "dish_selections": [
    {"dish_display_name": "Small Philly Steak Sub", "dish_id": 141081},
    {"dish_display_name": "Small Pizza Sub", "dish_id": 141082},
    {"dish_display_name": "Crispy Chicken Wrap", "dish_id": 141085}
    // ... 7 total options
  ]
}
```

**UI**: Two dropdowns labeled "First Item" and "Second Item", each with 7 options.

---

### Example 3: Mixed Combo (Dish Selections + Modifiers)
**Dish**: "Family Pizza Deal"
**Combo Groups**:
1. "Choose 2 Pizzas" → `dish_selections` (pizza choices)
2. "Premium Toppings" → `sections` with modifiers (extra toppings)
3. "Dipping Sauces" → `sections` with modifiers

**UI**: Render dish selection dropdowns first, then modifier checkboxes/buttons.

---

## Testing Restaurants

| Restaurant ID | Restaurant Name | Combo Type | Notes |
|---------------|-----------------|------------|-------|
| 735 | Amicci Pizza | Dish Selection | Super Special course has pizza combos with 12 options each |
| 680 | Milano | Dish Selection | "2 Sandwich Combos" with 7 sandwich options |
| 83 | Season's Pizza | Dish Selection | "2 For 1 Toppings" with 18 pizza options |

---

## Common Issues & Solutions

### Issue: Empty `dish_selections` array
**Cause**: Combo group uses modifiers instead of dish selections.
**Solution**: Check `sections` array for modifier-based options.

### Issue: `dish_is_active` is false
**Cause**: Referenced dish was deactivated.
**Solution**: Filter out inactive dishes in frontend.

### Issue: `dish_display_name` is null
**Cause**: Display name wasn't set during data migration.
**Solution**: Fall back to `dish_name`.

---

## Summary

1. **Check `dish_selections` array** in each `combo_group`
2. **Use `number_of_items`** to determine how many selections required
3. **Parse `display_header`** (semicolon-separated) for slot labels
4. **Display `dish_display_name`** (with size) or fall back to `dish_name`
5. **Filter by `dish_is_active`** to hide deactivated options
6. **Combine with `sections`** if combo has both dish selections and modifiers
