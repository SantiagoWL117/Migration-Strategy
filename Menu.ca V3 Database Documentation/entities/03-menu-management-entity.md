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

- [📊 Tables](#-tables)
  - [Menu Structure](#menu-structure-tables) — `courses`, `dishes`
  - [Size Variant Normalization](#size-variant-normalization-tables) — `modifier_size_variants`, `dish_size_variants`
  - [Dish Pricing](#dish-pricing-tables) — `dish_prices`
  - [Modifier System](#modifier-system-tables) — `modifier_groups`, `dish_modifier_groups`, `modifier_group_details`, `modifiers`, `modifier_prices`
  - [Combo System](#combo-system-tables) — `combo_groups`, `dish_combo_groups`, `combo_group_sections`, `combo_modifier_groups`, `combo_modifiers`, `combo_modifier_prices`
  - [Availability](#availability-tables) — `dish_availability`
  - [Caching](#caching-tables) — `restaurant_menu_cache`
  - [Views](#views)
- [🔧 SQL Functions](#-sql-functions-18-total)
- [⚡ Edge Functions](#-edge-functions)
- [🎯 Size-Price Matching Logic](#-size-price-matching-logic)
- [📇 Indexes](#-indexes)
- [⚙️ Triggers](#️-triggers)
- [🔒 RLS Policies](#-rls-policies)
- [🗑️ Migration History](#️-migration-history)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)

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

**Constraint:** Unique on `(dish_id, day_of_week)` — `is_hidden = true` means dish is hidden on that day.

---

### Caching Tables

#### `restaurant_menu_cache`
**Purpose:** Pre-built JSONB menu cache per restaurant (EN and FR)  
**Row Count:** 186

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `restaurant_id` | bigint | NO | PK, FK to restaurants |
| `menu_cache_en` | jsonb | YES | Cached English menu |
| `menu_cache_fr` | jsonb | YES | Cached French menu |
| `updated_at` | timestamptz | YES | NULL = stale/needs rebuild |

**Note:** Cache is automatically invalidated by triggers on menu tables and rebuilt on next request via `get_restaurant_menu_cached()`.

---

### Views

| View | Purpose |
|------|---------|
| `active_dish_modifiers` | Active (non-deleted) dish modifiers |
| `active_dish_prices` | Active (non-deleted) dish prices |
| `v_modifiers_with_placements` | Modifiers joined with placement data |

---

## 🔧 SQL Functions (18 total)

### Menu Retrieval & Caching

| Function | Purpose |
|----------|---------|
| `get_restaurant_menu(p_restaurant_id, p_language_code, p_combo_default_only)` | Returns complete JSONB menu (courses, dishes, prices, modifiers, combos, availability). Supports `'en'`/`'fr'` with COALESCE fallback. |
| `get_restaurant_menu_cached(p_restaurant_id, p_language_code)` | Returns cached menu from `restaurant_menu_cache`. Rebuilds if stale/missing. |
| `rebuild_menu_cache(p_restaurant_id)` | Rebuilds both EN and FR cache for a restaurant |
| `rebuild_all_menu_caches()` | Rebuilds cache for all restaurants |
| `invalidate_menu_cache(p_restaurant_id)` | Marks cache as stale (sets `updated_at = NULL`) |

### Dish Management

| Function | Purpose |
|----------|---------|
| `get_dish_availability(p_dish_id)` | Returns hidden days for a dish |
| `update_dish_availability(p_dish_id, p_hidden_days)` | Updates hidden days (array of 0-6 day numbers) |
| `soft_delete_dish(p_dish_id)` | Soft delete dish (sets `deleted_at`, `is_active = false`) |
| `restore_dish(p_dish_id)` | Restore soft-deleted dish |

### Onboarding

| Function | Purpose |
|----------|---------|
| `add_menu_item_onboarding(p_restaurant_id, p_name, p_description, p_price, p_category, p_created_by)` | Add menu item during onboarding |
| `copy_franchise_menu_onboarding(p_target_restaurant_id, p_source_restaurant_id, p_created_by)` | Copy entire menu from franchise parent |

### Trigger Functions

| Function | Purpose |
|----------|---------|
| `enforce_dish_pricing()` | Warns when dishes activated without pricing |
| `notify_menu_change()` | Sends `pg_notify` on menu changes |
| `trigger_invalidate_menu_cache()` | Invalidates cache on courses/dishes/modifier_groups changes |
| `trigger_invalidate_menu_cache_via_dish()` | Invalidates cache via dish FK (prices, availability, modifier_groups) |
| `trigger_invalidate_menu_cache_via_modifier()` | Invalidates cache via modifier FK (modifier_prices) |
| `trigger_invalidate_menu_cache_via_modifier_group()` | Invalidates cache via modifier_group FK (modifiers) |
| `trigger_invalidate_menu_cache_via_combo_group()` | Invalidates cache via combo_group FK (combo_groups, sections) |

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

## ⚙️ Triggers

### Menu Cache Invalidation (automatic)

Triggers on menu tables automatically invalidate the `restaurant_menu_cache` when data changes:

| Table | Trigger Function |
|-------|-----------------|
| `courses` | `trigger_invalidate_menu_cache` |
| `dishes` | `trigger_invalidate_menu_cache` |
| `modifier_groups` | `trigger_invalidate_menu_cache` |
| `dish_prices` | `trigger_invalidate_menu_cache_via_dish` |
| `dish_availability` | `trigger_invalidate_menu_cache_via_dish` |
| `dish_combo_groups` | `trigger_invalidate_menu_cache_via_dish` |
| `dish_modifier_groups` | `trigger_invalidate_menu_cache_via_dish` |
| `modifier_group_details` | `trigger_invalidate_menu_cache_via_dish` |
| `modifier_prices` | `trigger_invalidate_menu_cache_via_modifier` |
| `modifiers` | `trigger_invalidate_menu_cache_via_modifier_group` |
| `combo_groups` | `trigger_invalidate_menu_cache_via_combo_group` |
| `combo_group_sections` | `trigger_invalidate_menu_cache_via_combo_group` |

### Other Triggers

| Table | Trigger | Function |
|-------|---------|----------|
| `courses` | `notify_courses_change` | `notify_menu_change()` — real-time notification |
| `dishes` | `notify_dishes_change` | `notify_menu_change()` — real-time notification |
| `dishes` | `check_dish_pricing` | `enforce_dish_pricing()` — warns on activation without price |
| `dishes` | `audit_dishes_changes` | `audit_trigger_func()` — audit log |
| `dish_prices` | `notify_prices_change` | `notify_menu_change()` — real-time notification |

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

## 🗑️ Migration History

> **Summary:** Major cleanup between Jan 8-12, 2026:
> - **Dropped table:** `dish_inventory` (0 rows, unused)
> - **Dropped columns:** Legacy columns from `courses` (`source_system`, `legacy_v1_id`, `legacy_v2_id`) and `dishes` (`sku`, `image_url`, `source_system`, `unavailable_until_at`, `legacy_v1_id`, `legacy_v2_id`)
> - **Dropped 16 SQL functions:** 10 broken (referenced deleted tables) + 6 unused
> - **RLS cleanup:** Removed 42 policies (33 from core tables, 9 from supporting tables); core menu tables now accessed exclusively via `get_restaurant_menu()`
> - **Bilingual support (2026-01-09):** Added `name_en`/`name_fr`/`description_en`/`description_fr` columns to all menu tables; 185/186 restaurants have French translations
> - **Size normalization (2026-01-08):** Created `modifier_size_variants` (8 tiers) and `dish_size_variants` (72 variants) for FK-based size-price matching
> - **Dish availability (2026-01-08):** Created `dish_availability` table for day-of-week visibility control

---

## 🚨 Data Integrity Issues

| Issue | Details |
|-------|---------|
| **6 backup test tables** | `courses_backup_test_234`, `courses_backup_test_35`, `courses_backup_test_726`, `dishes_backup_test_234`, `dishes_backup_test_35`, `dishes_backup_test_726` — contain 0-3 rows each. Should be dropped. |
| **10 dishes reference deleted courses** | Dish IDs referencing course_ids 3578 and 4749 (courses no longer exist). All 10 dishes are already soft-deleted, so low risk. |
| **4 orphan dish_prices** | `dish_prices` IDs 48794-48797 reference `dish_id` 138098 and 138099, which no longer exist. Should be deleted. |
| **5 empty tables — schedule for deletion** | `combo_group_translations`, `combo_modifier_placements`, `combo_steps`, `dish_modifiers`, `dish_modifier_prices` — all 0 rows. Referenced by `active_dish_modifiers` view, `v_modifiers_with_placements` view, and `calculate_order_total` function. **Action:** Drop these tables before 10 AM (before restaurants open), update `calculate_order_total` to remove `dish_modifiers`/`dish_modifier_prices` references, and drop the two dependent views first. |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| **Total Tables** | 22 (+ 3 views, + 6 backup tables to drop) |
| **Total SQL Functions** | 18 |
| **Total RLS Policies** | 11 |
| **Total Triggers** | 17 |
| **Core Tables** | |
| Courses | 2,955 |
| Dishes | 24,068 |
| Dish Prices | 41,527 |
| **Modifier System** | |
| Modifier Groups | 2,857 |
| Modifiers | 68,435 |
| Modifier Prices | 124,489 |
| **Combo System** | |
| Combo Groups | 2,182 |
| Combo Modifiers | 76,884 |
| Combo Modifier Prices | 198,905 |
| **Other** | |
| Menu Cache Entries | 186 |
| Dish Availability Restrictions | 1,232 |
| Size Variants (modifier/dish) | 8 / 72 |

---

**Last Updated:** 2026-02-17
