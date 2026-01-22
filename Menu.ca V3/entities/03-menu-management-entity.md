# 03 - Menu Management Entity

> **Product Catalog** - Dishes, categories, modifiers, combos, and pricing

---

## 📋 Purpose

The Menu Management Entity is the **largest entity by data volume** (~450 MB), managing all aspects of restaurant menus:
- **Menu Structure** - Categories (courses) and dishes
- **Pricing** - Base prices with normalized size variants
- **Customization** - Shared modifier groups with size-based pricing
- **Combos** - Combo meals with sections, modifier groups, and modifiers
- **Availability** - Day-of-week visibility restrictions
- **Templates** - Reusable modifier configurations

**Key Responsibilities:**
- Product catalog management
- Shared modifier/customization system
- Two-tier size-price matching (dish → modifier)
- Combo meal configuration with V1/V2 migration support
- Day-of-week dish availability

---

## 📑 Index

- [Tables](#tables)
  - [Menu Structure](#menu-structure-tables)
  - [Size Variant Normalization](#size-variant-normalization-tables)
  - [Dish Pricing](#dish-pricing-tables)
  - [Modifier System](#modifier-system-tables)
  - [Combo System](#combo-system-tables)
  - [Availability](#availability-tables)
- [SQL Functions](#sql-functions)
- [Size-Price Matching Logic](#size-price-matching-logic)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Schema Fixes Applied](#schema-fixes-applied)

---

## 📊 Tables

### Menu Structure Tables

#### `courses` (Categories)
**Purpose:** Menu categories/sections (e.g., "Appetizers", "Main Course")

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `name_en` | varchar(255) | NO | - | Category name (English) |
| `name_fr` | varchar(255) | YES | - | Category name (French) |
| `description_en` | text | YES | - | Category description (English) |
| `description_fr` | text | YES | - | Category description (French) |
| `display_order` | integer | YES | 0 | Sort order |
| `is_active` | boolean | YES | true | Active status |
| `source_id` | bigint | YES | - | Original V1/V2 system ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | User who deleted |

---

#### `dishes`
**Purpose:** Individual menu items/products

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `course_id` | bigint | YES | - | FK to courses |
| `name_en` | varchar(255) | NO | - | Dish name (English) |
| `name_fr` | varchar(255) | YES | - | Dish name (French) |
| `description_en` | text | YES | - | Dish description (English) |
| `description_fr` | text | YES | - | Dish description (French) |
| `display_order` | integer | YES | 0 | Sort order |
| `is_combo` | boolean | YES | false | Is combo meal |
| `has_customization` | boolean | YES | false | Has modifiers |
| `is_upsell` | boolean | YES | false | Upsell item |
| `is_active` | boolean | YES | true | Active status |
| `is_featured` | boolean | NO | false | Featured dish |
| `hide_option_enabled` | boolean | NO | false | Hide option flag |
| `source_id` | bigint | YES | - | Original V1/V2 system ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | User who deleted |

---

### Size Variant Normalization Tables

> **Two-Tier System:** Standardized size matching between dish prices and modifier prices using foreign key IDs instead of string matching.

#### `modifier_size_variants`
**Purpose:** Global standardized sizes for modifiers (8 tiers)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | SERIAL | NO | - | Primary key |
| `code` | varchar(20) | NO | - | Unique code (e.g., 'small', 'medium') |
| `name_en` | varchar(50) | NO | - | English name |
| `name_fr` | varchar(50) | NO | - | French name |
| `display_order` | int | NO | 0 | Sort order |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

**Standard Values:**

| id | code | name_en | name_fr |
|----|------|---------|---------|
| 1 | standard | Standard | Standard |
| 2 | small | Small | Petite |
| 3 | medium | Medium | Moyenne |
| 4 | large | Large | Grande |
| 5 | x-large | X-Large | X-Grande |
| 6 | size-5 | Size 5 | Taille 5 |
| 7 | size-6 | Size 6 | Taille 6 |
| 8 | size-7 | Size 7 | Taille 7 |

---

#### `dish_size_variants`
**Purpose:** Expanded dish sizes (~50 variants) with FK mapping to modifier sizes

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | SERIAL | NO | - | Primary key |
| `code` | varchar(30) | NO | - | Unique code |
| `name_en` | varchar(50) | NO | - | English name |
| `name_fr` | varchar(50) | NO | - | French name |
| `category` | varchar(20) | NO | - | Category: size, dimension, volume, container, combo, portion |
| `modifier_size_variant_id` | int | YES | - | FK to modifier_size_variants (NULL for non-mappable) |
| `display_order` | int | NO | 0 | Sort order |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

**Example Mappings:**

| Dish Size | Category | Maps To (modifier_size_variant_id) |
|-----------|----------|-----------------------------------|
| 10" | dimension | 2 (Small) |
| 12" | dimension | 3 (Medium) |
| 14" | dimension | 4 (Large) |
| 591ml | volume | 3 (Medium) |
| 1L | volume | 4 (Large) |
| 6 pcs | portion | 2 (Small) |
| 12 pcs | portion | 3 (Medium) |
| Chicken | protein | NULL (no mapping) |
| Ranch | flavor | NULL (no mapping) |

---

### Dish Pricing Tables

#### `dish_prices`
**Purpose:** Base dish pricing with size variant FK

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `size_variant` | varchar(50) | YES | - | Display name (legacy) |
| `dish_size_variant_id` | int | YES | - | FK to dish_size_variants |
| `price` | numeric(10,2) | NO | - | Price amount |
| `display_order` | integer | YES | 0 | Sort order |
| `is_active` | boolean | YES | true | Active status |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

**Size Matching:** The `dish_size_variant_id` links to `dish_size_variants.modifier_size_variant_id` for matching with modifier prices.

---

### Modifier System Tables

> **Shared Modifier Groups:** Modifier groups are defined at the restaurant level and linked to dishes via `dish_modifier_groups`. This allows the same modifier group (e.g., "Pizza Toppings") to be reused across multiple dishes.

#### `modifier_groups`
**Purpose:** Restaurant-level shared modifier groups

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `name_en` | varchar(255) | NO | - | Group name (English) |
| `name_fr` | varchar(255) | YES | - | Group name (French) |
| `category` | varchar(50) | YES | - | Category type |
| `source_id` | bigint | YES | - | V1/V2 source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

#### `dish_modifier_groups`
**Purpose:** Links dishes to modifier groups (many-to-many)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `modifier_group_id` | bigint | NO | - | FK to modifier_groups |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

#### `modifier_group_details`
**Purpose:** Per-dish configuration for modifier groups

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_modifier_group_id` | bigint | NO | - | FK to dish_modifier_groups |
| `name_en` | varchar(100) | YES | - | Display name override (English) |
| `name_fr` | varchar(100) | YES | - | Display name override (French) |
| `min_selections` | int | YES | 0 | Minimum required |
| `max_selections` | int | YES | 1 | Maximum allowed |
| `free_items` | int | YES | 0 | Free items allowed |
| `display_order` | int | YES | 0 | Sort order |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

#### `modifiers`
**Purpose:** Individual modifier options within a group

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `modifier_group_id` | bigint | NO | - | FK to modifier_groups |
| `name_en` | varchar(255) | NO | - | Modifier name (English) |
| `name_fr` | varchar(255) | YES | - | Modifier name (French) |
| `display_order` | integer | YES | 0 | Sort order |
| `is_active` | boolean | YES | true | Active status |
| `source_id` | bigint | YES | - | V1/V2 source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

#### `modifier_prices`
**Purpose:** Modifier pricing with size variant FK

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `modifier_id` | bigint | NO | - | FK to modifiers |
| `size_variant` | varchar(50) | YES | - | Display name (legacy) |
| `modifier_size_variant_id` | int | YES | - | FK to modifier_size_variants |
| `price` | numeric(10,2) | NO | 0.00 | Price amount |
| `display_order` | integer | YES | 0 | Sort order |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

### Combo System Tables

> **Combo Architecture:** Combos are structured as: `dishes` → `dish_combo_groups` → `combo_groups` → `combo_group_sections` → `combo_modifier_groups` → `combo_modifiers` → `combo_modifier_prices`

#### `combo_groups`
**Purpose:** Combo meal configurations

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `name_en` | text | NO | - | Combo group name (English) |
| `name_fr` | text | YES | - | Combo group name (French) |
| `special_number_of_items` | int | YES | - | Number of items in combo |
| `special_display_header_en` | varchar(255) | YES | - | Display header (English) |
| `special_display_header_fr` | varchar(255) | YES | - | Display header (French) |
| `source_id` | bigint | YES | - | V1/V2 source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |

---

#### `dish_combo_groups`
**Purpose:** Links dishes to combo groups (many-to-many)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `combo_group_id` | bigint | NO | - | FK to combo_groups |
| `is_active` | boolean | YES | true | Active status |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `combo_group_sections`
**Purpose:** Sections within a combo group (e.g., "Crust Type", "Toppings", "Drinks")

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `combo_group_id` | bigint | NO | - | FK to combo_groups |
| `section_type` | varchar(50) | NO | - | Type: crust, custom_ingredients, dip, drinks, etc. |
| `use_header_en` | varchar(255) | YES | - | Display header (English) |
| `use_header_fr` | varchar(255) | YES | - | Display header (French) |
| `display_order` | int | YES | 0 | Sort order |
| `free_items` | int | YES | 0 | Free items allowed |
| `min_selection` | int | YES | 0 | Minimum required |
| `max_selection` | int | YES | 0 | Maximum allowed |
| `is_active` | boolean | YES | true | Active status |
| `source_id` | bigint | YES | - | V1/V2 source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

**Section Types:**
- `crust` - Crust/bread selection
- `custom_ingredients` - Toppings, add-ons
- `dip` - Dipping sauces
- `drinks` - Beverage selection
- `side` - Side dishes
- `size` - Size selection

---

#### `combo_modifier_groups`
**Purpose:** Modifier groups within a combo section

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `combo_group_section_id` | bigint | NO | - | FK to combo_group_sections |
| `name_en` | text | NO | - | Group name (English) |
| `name_fr` | text | YES | - | Group name (French) |
| `type_code` | varchar(50) | YES | - | Type: CI, RADIO, etc. |
| `is_selected` | boolean | YES | false | Default selected group |
| `source_id` | bigint | YES | - | V1/V2 modifier group source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

**Note:** `is_selected = true` indicates this is the default modifier group for the section.

---

#### `combo_modifiers`
**Purpose:** Individual modifiers within a combo modifier group

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `combo_modifier_group_id` | bigint | NO | - | FK to combo_modifier_groups |
| `name_en` | text | NO | - | Modifier name (English) |
| `name_fr` | text | YES | - | Modifier name (French) |
| `display_order` | int | YES | 0 | Sort order |
| `source_id` | bigint | YES | - | V1/V2 modifier source ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `combo_modifier_prices`
**Purpose:** Pricing for combo modifiers with size variant FK

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `combo_modifier_id` | bigint | NO | - | FK to combo_modifiers |
| `size_variant` | varchar(50) | YES | - | Display name (legacy) |
| `modifier_size_variant_id` | int | YES | - | FK to modifier_size_variants |
| `price` | numeric(10,2) | NO | 0.00 | Price amount |
| `display_order` | int | YES | 0 | Sort order |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Availability Tables

#### `dish_availability`
**Purpose:** Day-of-week visibility restrictions for dishes

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | SERIAL | NO | - | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `day_of_week` | smallint | NO | - | 0=Sunday, 1=Monday, ..., 6=Saturday |
| `is_hidden` | boolean | NO | true | true = dish is hidden on this day |

**Constraint:** Unique on `(dish_id, day_of_week)`

**Example:**
- Dish hidden on Saturday & Sunday: `[(dish_id, 0, true), (dish_id, 6, true)]`
- Dish visible only on Monday: `[(dish_id, 0, true), (dish_id, 2, true), (dish_id, 3, true), (dish_id, 4, true), (dish_id, 5, true), (dish_id, 6, true)]`

---

---

## 🔧 SQL Functions

### Overview (9 functions)

| Category | Function | Purpose |
|----------|----------|---------|
| **Menu Retrieval** | `get_restaurant_menu` | Returns complete menu with courses, dishes, prices, modifiers, combos |
| **Availability** | `get_dish_availability` | Get hidden days for a dish |
| **Availability** | `update_dish_availability` | Update hidden days for a dish |
| **Dish CRUD** | `soft_delete_dish` | Soft delete a dish |
| **Dish CRUD** | `restore_dish` | Restore a soft-deleted dish |
| **Onboarding** | `add_menu_item_onboarding` | Add menu item during restaurant onboarding |
| **Onboarding** | `copy_franchise_menu_onboarding` | Copy menu from franchise parent |
| **Triggers** | `enforce_dish_pricing` | Warn if dish activated without pricing |
| **Triggers** | `notify_menu_change` | Send pg_notify on menu changes |

---

### Menu Retrieval

#### `get_restaurant_menu(p_restaurant_id, p_language_code, p_combo_default_only)`

Returns the complete menu structure with all pricing, modifiers, combos, and availability. **Supports bilingual output (English/French).**

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `p_restaurant_id` | bigint | - | Restaurant ID |
| `p_language_code` | text | `'en'` | Language: `'en'` or `'fr'` |
| `p_combo_default_only` | boolean | `false` | Only selected combo modifier groups |

```sql
SELECT menuca_v3.get_restaurant_menu(973);              -- English menu (default)
SELECT menuca_v3.get_restaurant_menu(973, 'fr');        -- French menu
SELECT menuca_v3.get_restaurant_menu(973, 'en', true);  -- English, selected combos only
```

**Language Fallback:** If the requested language is NULL, falls back to the other language using COALESCE.

**Returns:** JSONB with structure:
```json
{
  "restaurant_id": 973,
  "courses": [
    {
      "id": 123,
      "name": "Pizzas",
      "dishes": [
        {
          "id": 172885,
          "name": "Walk-In Special (Medium Pizza)",
          "hidden_days": null,
          "prices": [
            {
              "id": 110178,
              "size_variant": "Standard",
              "dish_size_variant_id": 3,
              "modifier_size_variant_id": 3,
              "price": 15.00
            }
          ],
          "modifier_groups": [...],
          "combo_groups": [...]
        }
      ]
    }
  ]
}
```

---

### Dish Availability

#### `get_dish_availability(p_dish_id)`

Returns current hidden days for a dish.

```sql
SELECT menuca_v3.get_dish_availability(172885);
```

**Returns:**
```json
{
  "success": true,
  "dish_id": 172885,
  "dish_name": "Walk-In Special (Medium Pizza)",
  "hidden_days": []
}
```

---

#### `update_dish_availability(p_dish_id, p_hidden_days)`

Updates hidden days for a dish.

```sql
-- Hide on weekends
SELECT menuca_v3.update_dish_availability(172885, ARRAY[0, 6]);

-- Remove all restrictions
SELECT menuca_v3.update_dish_availability(172885, ARRAY[]::INT[]);
```

**Returns:**
```json
{
  "success": true,
  "dish_id": 172885,
  "hidden_days": [0, 6],
  "message": "Availability updated",
  "deleted_count": 0,
  "inserted_count": 2
}
```

---

### Dish CRUD

#### `soft_delete_dish(p_dish_id)`

Soft delete a dish by setting `deleted_at` timestamp and marking as inactive.

```sql
SELECT menuca_v3.soft_delete_dish(172885);
```

**Returns:**
```json
{
  "success": true,
  "dish_id": 172885,
  "restaurant_id": 973,
  "deleted_at": "2026-01-12T...",
  "message": "Dish soft deleted successfully"
}
```

---

#### `restore_dish(p_dish_id)`

Restore a soft-deleted dish by clearing `deleted_at` and marking as active.

```sql
SELECT menuca_v3.restore_dish(172885);
```

**Returns:**
```json
{
  "success": true,
  "dish_id": 172885,
  "restaurant_id": 973,
  "restored_at": "2026-01-12T...",
  "message": "Dish restored successfully"
}
```

---

### Onboarding Functions

#### `add_menu_item_onboarding(p_restaurant_id, p_name, p_description, p_price, p_category, p_created_by)`

Add a menu item during restaurant onboarding. Marks menu step complete when first item is added.

```sql
SELECT * FROM menuca_v3.add_menu_item_onboarding(123, 'Pepperoni Pizza', 'Classic pizza', 14.99);
```

---

#### `copy_franchise_menu_onboarding(p_target_restaurant_id, p_source_restaurant_id, p_created_by)`

Copy entire menu from franchise parent restaurant to a new location.

```sql
SELECT * FROM menuca_v3.copy_franchise_menu_onboarding(124, 123);  -- Copy from 123 to 124
```

---

### Trigger Functions

#### `enforce_dish_pricing()`

Trigger function that warns when dishes are activated without pricing.

#### `notify_menu_change()`

Trigger function that sends `pg_notify` events when menu data changes.

---

## 🌐 Edge Functions

| Edge Function | SQL Function Called | Purpose |
|---------------|---------------------|---------|
| `copy-franchise-menu` | `copy_franchise_menu_onboarding` | Copy menu between franchise locations |
| `check-restaurant-availability` | `get_restaurant_availability` | Check if restaurant can accept orders |

---

## 🎯 Size-Price Matching Logic

### How It Works

The system uses `modifier_size_variant_id` to match dish prices with modifier/combo modifier prices:

```
dish_prices.dish_size_variant_id 
    → dish_size_variants.modifier_size_variant_id 
    → modifier_prices.modifier_size_variant_id (MATCH!)
```

### Frontend Implementation

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
```

### Example

**Dish:** "Walk-In Special (Medium Pizza)"
- `dish_price.modifier_size_variant_id = 3` (Medium)

**Combo Modifier:** "Beef Pepperoni"
- Small: `modifier_size_variant_id: 2` → $1.00
- **Medium: `modifier_size_variant_id: 3` → $2.00** ← MATCH!
- Large: `modifier_size_variant_id: 4` → $3.00

**Result:** Frontend uses $2.00 for this topping.

---

## 📇 Indexes

### Key Indexes

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| `dishes` | `idx_dishes_restaurant` | `restaurant_id` | Restaurant lookup |
| `dishes` | `idx_dishes_course` | `course_id` | Category lookup |
| `dish_prices` | `idx_dish_prices_dish` | `dish_id` | Price lookup |
| `modifier_prices` | `idx_modifier_prices_modifier` | `modifier_id` | Price lookup |
| `combo_modifier_prices` | `idx_combo_modifier_prices_modifier` | `combo_modifier_id` | Price lookup |
| `dish_availability` | `idx_dish_availability_dish` | `dish_id` | Availability lookup |

---

## 🔒 RLS Policies

### Overview

**Major RLS Cleanup (2026-01-12):** Removed 33 policies from core menu tables (`courses`, `dishes`, `dish_prices`, `modifier_group_details`) because menu data is accessed exclusively via `get_restaurant_menu()` function (SECURITY DEFINER, bypasses RLS).

### RLS Status by Table Group

| Table Group | RLS Status | Reason |
|------------|-----------|---------|
| **Core Menu Tables** | ❌ **Disabled** | All access via `get_restaurant_menu()` |
| `courses` | No RLS | Function-based access only |
| `dishes` | No RLS | Function-based access only |
| `dish_prices` | No RLS | Function-based access only |
| `modifier_group_details` | No RLS | Function-based access only |
| **Supporting Tables** | ✅ **Enabled** | Direct queries allowed |
| `modifier_size_variants` | Public SELECT | Global reference data |
| `dish_size_variants` | Public SELECT | Global reference data |
| `dish_modifiers` | Public SELECT + Service Role | Direct customer queries |
| `dish_modifier_prices` | Public SELECT + Service Role | Price lookups |
| `combo_*` tables | Public SELECT + Service Role | Combo configuration |
| `course_*` templates | Public SELECT + Service Role | Modifier templates |

### Remaining Policies (11 total)

| Table | Policy | Roles | Command | Purpose |
|-------|--------|-------|---------|---------|
| **combo_group_modifier_pricing** | `public_view_combo_modifier_pricing` | public | SELECT | Customer access |
| | `combo_modifier_pricing_service_role_all` | service_role | ALL | Super admin bypass |
| **combo_group_translations** | `combo_group_translations_service_role` | service_role | ALL | Super admin bypass |
| **combo_steps** | `public_view_combo_steps` | public | SELECT | Customer access |
| | `combo_steps_service_role_all` | service_role | ALL | Super admin bypass |
| **course_modifier_templates** | `public_read_category_modifier_groups` | anon, authenticated | SELECT | Template access |
| **course_template_modifiers** | `public_read_modifier_options` | anon, authenticated | SELECT | Template access |
| **dish_modifier_prices** | `public_view_active_modifier_prices` | public | SELECT | Customer access |
| | `dish_modifier_prices_service_role_all` | service_role | ALL | Super admin bypass |
| **dish_modifiers** | `public_view_dish_modifiers` | public | SELECT | Customer access |
| | `dish_modifiers_service_role_all` | service_role | ALL | Super admin bypass |

### Policies Deleted (33 total - 2026-01-12)

**Core Menu Tables (24 policies)**:
- `courses`: 6 policies (2 public + 4 admin)
- `dishes`: 6 policies (2 public + 4 admin)
- `dish_prices`: 6 policies (2 public + 4 admin)
- `modifier_group_details`: 6 policies (2 public + 4 admin)

**Supporting Tables (9 policies)**:
- `course_modifier_templates`: 1 admin policy
- `course_template_modifiers`: 1 admin policy
- `dish_modifier_prices`: 2 admin policies
- `dish_modifiers`: 5 admin/authenticated policies

**Rationale**: No admin portal exists; all CRUD operations performed by super admins via psql/Supabase CLI

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | Impact |
|------|-----------------|--------|
| 2026-01-12 | Removed `source_system`, `legacy_v1_id`, `legacy_v2_id` from `courses` | Schema cleanup |
| 2026-01-12 | Removed `sku`, `image_url`, `source_system`, `unavailable_until_at`, `legacy_v1_id`, `legacy_v2_id` from `dishes` | Schema cleanup |
| 2026-01-12 | Dropped `dish_inventory` table (0 rows) | Removed unused table |
| 2026-01-12 | Dropped 10 broken SQL functions referencing deleted tables/columns | Function cleanup |
| 2026-01-12 | Dropped 6 unused menu functions (templates, franchise coverage, utilities) | Function cleanup |
| 2026-01-12 | Fixed `add_menu_item_onboarding` and `copy_franchise_menu_onboarding` | Updated to use correct column names |
| 2026-01-12 | **RLS Cleanup:** Removed 33 policies from menu tables | Disabled RLS on `courses`, `dishes`, `dish_prices`, `modifier_group_details` |
| 2026-01-12 | **RLS Cleanup:** Removed 9 admin policies from supporting tables | Deleted unused admin/authenticated policies |
| 2026-01-09 | Added bilingual columns (`name_en`, `name_fr`, `description_en`, `description_fr`) | French/English menu support |
| 2026-01-09 | Updated `get_restaurant_menu()` with `p_language_code` parameter | Language selection with fallback |
| 2026-01-09 | Migrated French restaurant data to `name_fr` columns | 19 French restaurants (1,729 dishes) |
| 2026-01-08 | Created `modifier_size_variants` table (8 standard sizes) | Standardized size matching |
| 2026-01-08 | Created `dish_size_variants` table (~50 expanded sizes) | Dish → Modifier size mapping |
| 2026-01-08 | Added `modifier_size_variant_id` FK to `modifier_prices` | 100% coverage |
| 2026-01-08 | Added `modifier_size_variant_id` FK to `combo_modifier_prices` | 100% coverage |
| 2026-01-08 | Added `dish_size_variant_id` FK to `dish_prices` | 87% coverage (non-size variants NULL) |
| 2026-01-08 | Created `dish_availability` table | Day-of-week visibility |
| 2026-01-08 | Updated V2 combo dish prices with `use_price` mapping | 42 dishes fixed |
| 2026-01-08 | Added `hidden_days` to `get_restaurant_menu()` | Frontend visibility control |
| 2026-01-08 | Created `get_dish_availability()` RPC | Read availability |
| 2026-01-08 | Created `update_dish_availability()` RPC | Update availability |

### Functions Dropped (2026-01-12)

The following functions were removed because they referenced deleted tables/columns:

| Function | Reason |
|----------|--------|
| `auto_expire_unavailable_dishes()` | Referenced `dish_inventory` |
| `check_cart_availability(jsonb)` | Referenced `dish_inventory` |
| `decrement_dish_inventory(bigint, integer)` | Referenced `dish_inventory` |
| `is_dish_available_now(bigint, timestamptz)` | Referenced `dish_inventory`, `unavailable_until_at` |
| `update_dish_availability(bigint, boolean, ...)` | Referenced `dish_inventory` (inventory version) |
| `calculate_combo_price(bigint, jsonb)` | Referenced non-existent `combo_price`, `combo_rules` |
| `validate_combo_configuration(bigint)` | Referenced non-existent `combo_items`, `combo_price` |
| `validate_dish_modifiers(bigint, jsonb)` | Referenced non-existent `base_price` |
| `get_dish_size_options(bigint)` | Referenced non-existent `dish_size_options` |
| `calculate_order_total(jsonb, bigint, ...)` | Referenced non-existent `base_price` |
| `get_franchise_menu_coverage(bigint)` | Unused - removed |
| `apply_template_to_dish(integer, integer)` | Unused - removed |
| `apply_all_templates_to_dish(integer)` | Unused - removed |
| `break_modifier_inheritance(integer)` | Unused - removed |
| `refresh_menu_summary()` | Unused - removed |
| `validate_order_dishes(integer[], integer)` | Unused - removed |

---

## 🌐 Bilingual Functionality

### Overview

The Menu Management Entity supports **English/French bilingual menus** with excellent coverage across all menu tables.

### Bilingual Columns by Table

| Table | Name Columns | Description Columns |
|-------|--------------|---------------------|
| `courses` | `name_en`, `name_fr` | `description_en`, `description_fr` |
| `dishes` | `name_en`, `name_fr` | `description_en`, `description_fr` |
| `modifier_groups` | `name_en`, `name_fr` | - |
| `modifiers` | `name_en`, `name_fr` | - |
| `combo_groups` | `name_en`, `name_fr` | `special_display_header_en`, `special_display_header_fr` |
| `combo_group_sections` | `use_header_en`, `use_header_fr` | - |
| `combo_modifier_groups` | `name_en`, `name_fr` | - |
| `combo_modifiers` | `name_en`, `name_fr` | - |

### Translation Coverage (Verified 2026-01-22)

| Table | Total Records | Has Both Languages | Actually Translated | % Translated |
|-------|---------------|--------------------|--------------------|--------------|
| `dishes` | 24,037 | 24,036 (99.9%) | 18,681 | **77.7%** |
| `courses` | 2,954 | 2,954 (100%) | 2,359 | **79.9%** |
| `modifier_groups` | 2,873 | 2,873 (100%) | 2,638 | **91.8%** |
| `modifiers` | 68,895 | 68,895 (100%) | 55,127 | **80.0%** |
| `combo_groups` | 2,182 | 2,182 (100%) | TBD | TBD |
| `combo_modifiers` | 76,885 | 76,885 (100%) | TBD | TBD |

**Note:** "Actually Translated" = records where `name_en != name_fr` (not just copied)

### Restaurant Translation Status

- **185 of 186 restaurants** (99.5%) have French translations
- Top translated restaurants: Supreme Pizzeria (98.4%), Number One Chinese (96.7%), Milano locations (93-96%)
- Bilingual data populated during V1/V2 migration (2026-01-09)

### Language Selection in `get_restaurant_menu()`

```sql
-- English menu (default)
SELECT menuca_v3.get_restaurant_menu(973);

-- French menu
SELECT menuca_v3.get_restaurant_menu(973, 'fr');
```

**Fallback Logic:** If requested language column is NULL, falls back to the other language using COALESCE.

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| **Core Tables** | |
| Total Dishes | 24,037 |
| Total Courses | 2,954 |
| Total Dish Prices | 41,525 |
| **Modifier System** | |
| Total Modifier Groups | 2,873 |
| Total Modifiers | 68,895 |
| Total Modifier Prices | 125,258 |
| **Combo System** | |
| Total Combo Groups | 2,182 |
| Total Combo Modifiers | 76,885 |
| Total Combo Modifier Prices | 198,906 |
| **Size Normalization** | |
| Modifier Size Variants | 8 |
| Dish Size Variants | 72 |
| **Other** | |
| Dishes with Availability Restrictions | 1,232 |
| SQL Functions (Menu) | 9 active |
| Restaurants with French Translations | 185/186 (99.5%) |

---

**Last Updated:** 2026-01-22
