# 03 - Menu Management Entity

> **Product Catalog** - Dishes, categories, modifiers, and pricing

---

## 📋 Purpose

The Menu Management Entity is the **largest entity by data volume** (~450 MB), managing all aspects of restaurant menus:
- **Menu Structure** - Categories (courses) and dishes
- **Pricing** - Base prices and size variants
- **Customization** - Modifiers, toppings, and options
- **Templates** - Reusable modifier configurations
- **Inventory** - Stock tracking and availability

**Key Responsibilities:**
- Product catalog management
- Modifier/customization system
- Multi-size pricing
- Combo meal configuration
- Category templates for efficiency

---

## 📑 Index

- [Tables](#tables)
- [SQL Functions](#sql-functions)
- [Edge Functions](#edge-functions)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Triggers](#triggers)
- [Removed Functionalities](#removed-functionalities)
- [New Functionalities](#new-functionalities)
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
| `name` | varchar(255) | NO | - | Category name |
| `description` | text | YES | - | Category description |
| `display_order` | integer | YES | 0 | Sort order |
| `is_active` | boolean | YES | true | Active status |
| `image_url` | varchar(500) | YES | - | Category image |
| `parent_course_id` | bigint | YES | - | For subcategories |
| `source_system` | varchar(10) | YES | - | v1 or v2 |
| `source_id` | bigint | YES | - | Original system ID |
| `legacy_v1_id` | integer | YES | - | V1 migration reference |
| `legacy_v2_id` | integer | YES | - | V2 migration reference |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `dishes` (38 MB - LARGEST TABLE)
**Purpose:** Individual menu items/products

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `course_id` | bigint | YES | - | FK to courses |
| `name` | varchar(255) | NO | - | Dish name |
| `description` | text | YES | - | Dish description |
| `ingredients` | text | YES | - | Ingredient list |
| `sku` | varchar(50) | YES | - | Stock keeping unit |
| `display_order` | integer | YES | 0 | Sort order |
| `image_url` | varchar(500) | YES | - | Dish image |
| `is_combo` | boolean | YES | false | Is combo meal |
| `has_customization` | boolean | YES | false | Has modifiers |
| `quantity` | varchar(255) | YES | - | Quantity description |
| `is_upsell` | boolean | YES | false | Upsell item |
| `is_active` | boolean | YES | true | Active status |
| `source_system` | varchar(10) | YES | - | v1 or v2 |
| `source_id` | bigint | YES | - | Original system ID |
| `legacy_v1_id` | integer | YES | - | V1 migration reference |
| `legacy_v2_id` | integer | YES | - | V2 migration reference |
| `notes` | text | YES | - | Internal notes |
| `allergen_info` | jsonb | YES | - | Allergen data |
| `nutritional_info` | jsonb | YES | - | Nutrition data |
| `search_vector` | tsvector | YES | generated | Full-text search |
| `unavailable_until_at` | timestamptz | YES | - | Temporary unavailability |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `combo_steps`
**Purpose:** Combo meal step configurations

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes (combo) |
| `step_number` | integer | NO | - | Step order |
| `step_name` | varchar | NO | - | Step display name |
| `min_selections` | integer | NO | 0 | Minimum required |
| `max_selections` | integer | NO | 1 | Maximum allowed |
| `available_items` | jsonb | YES | - | Items available in step |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Pricing Tables

#### `dish_prices`
**Purpose:** Base dish pricing with size variants

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `size_code` | varchar(50) | YES | - | Size identifier |
| `size_label` | varchar(100) | YES | - | Size display name |
| `price` | numeric(10,2) | NO | - | Price amount |
| `is_default` | boolean | NO | false | Default size |
| `display_order` | integer | YES | 0 | Sort order |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |

---

#### `dish_modifier_prices` (181 MB - LARGEST)
**Purpose:** Modifier pricing with size variants

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `dish_modifier_id` | bigint | NO | - | FK to dish_modifiers |
| `dish_id` | bigint | NO | - | FK to dishes |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `size_variant` | varchar(50) | YES | - | Size (Small/Medium/Large) |
| `price` | numeric(10,2) | NO | 0.00 | Price amount |
| `display_order` | integer | YES | 1 | Sort order |
| `is_active` | boolean | NO | true | Active status |
| `source_system` | varchar(20) | YES | - | v1 or v2 |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `combo_group_modifier_pricing`
**Purpose:** Combo-specific modifier pricing

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `combo_step_id` | bigint | NO | - | FK to combo_steps |
| `modifier_id` | bigint | NO | - | FK to dish_modifiers |
| `price_adjustment` | numeric(10,2) | NO | 0 | Price change |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Customization System Tables

#### `modifier_groups`
**Purpose:** Groups of related modifiers (e.g., "Size", "Toppings")

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `name` | varchar(100) | NO | - | Group name |
| `is_required` | boolean | NO | false | Selection required |
| `min_selections` | integer | NO | 0 | Minimum selections |
| `max_selections` | integer | NO | 1 | Maximum selections |
| `display_order` | integer | NO | 0 | Sort order |
| `parent_modifier_id` | bigint | YES | - | For nested groups |
| `instructions` | text | YES | - | User instructions |
| `course_template_id` | integer | YES | - | FK to template |
| `is_custom` | boolean | YES | true | Custom or template |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |
| `deleted_at` | timestamp | YES | - | Soft delete timestamp |

---

#### `dish_modifiers` (216 MB - 2ND LARGEST)
**Purpose:** Individual modifier options

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `dish_id` | bigint | NO | - | FK to dishes |
| `modifier_group_id` | bigint | YES | - | FK to modifier_groups |
| `name` | varchar(100) | YES | - | Modifier name |
| `modifier_type` | varchar(50) | YES | - | Type classification |
| `display_order` | integer | YES | - | Sort order |
| `is_default` | boolean | NO | false | Pre-selected |
| `is_included` | boolean | YES | false | Included in base price |
| `source_system` | varchar(10) | YES | - | v1 or v2 |
| `source_id` | bigint | YES | - | Original system ID |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

**Modifier Types:**
- `custom_ingredients` - Toppings, add-ons
- `extras` - Extra items
- `side_dishes` - Side options
- `drinks` - Beverage options
- `sauces` - Sauce choices
- `bread` - Bread/crust options
- `dressing` - Salad dressings
- `cooking_method` - Preparation style
- `other` - Miscellaneous

---

### Template System Tables

#### `course_modifier_templates`
**Purpose:** Reusable modifier group configurations

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `course_id` | bigint | NO | - | FK to courses |
| `name` | varchar(100) | NO | - | Template name |
| `is_required` | boolean | NO | false | Selection required |
| `min_selections` | integer | NO | 0 | Minimum selections |
| `max_selections` | integer | NO | 1 | Maximum selections |
| `display_order` | integer | YES | 0 | Sort order |
| `library_template_id` | bigint | YES | - | Parent library template |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `course_template_modifiers`
**Purpose:** Modifiers within a template

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `template_id` | bigint | NO | - | FK to course_modifier_templates |
| `name` | varchar(100) | NO | - | Modifier name |
| `price` | numeric(10,2) | YES | 0 | Price amount |
| `display_order` | integer | YES | 0 | Sort order |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Inventory Tables

#### `dish_inventory`
**Purpose:** Stock tracking and availability

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `dish_id` | bigint | NO | - | FK to dishes |
| `quantity_available` | integer | YES | - | Stock count |
| `is_available` | boolean | NO | true | Availability flag |
| `unavailable_reason` | text | YES | - | Reason if unavailable |
| `marked_unavailable_by` | bigint | YES | - | Admin who marked |
| `marked_unavailable_at` | timestamptz | YES | - | When marked |
| `auto_restore_at` | timestamptz | YES | - | Auto-restore time |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |

---

## 🔧 SQL Functions

### Menu Retrieval

```sql
-- Function: Get full menu for restaurant
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_menu(
    p_restaurant_id bigint
)
RETURNS jsonb
```

```sql
-- Function: Search dishes
CREATE OR REPLACE FUNCTION menuca_v3.search_dishes(
    p_restaurant_id bigint,
    p_query text
)
RETURNS TABLE(...)
```

### Modifier Management

```sql
-- Function: Get dish with all modifiers
CREATE OR REPLACE FUNCTION menuca_v3.get_dish_with_modifiers(
    p_dish_id bigint
)
RETURNS jsonb
```

**TODO:** Document all SQL functions after database query

---

## ⚡ Edge Functions

| Function Name | Endpoint | Purpose |
|--------------|----------|---------|
| - | - | No dedicated Edge Functions yet |

---

## 📇 Indexes

### `dishes` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `dishes_pkey` | `id` | PRIMARY KEY | - |
| `dishes_uuid_key` | `uuid` | UNIQUE | - |
| `idx_dishes_restaurant` | `restaurant_id` | BTREE | - |
| `idx_dishes_course` | `course_id` | BTREE | - |
| `idx_dishes_active` | `is_active` | BTREE | `is_active = true` |
| `idx_dishes_search` | `search_vector` | GIN | - |
| `idx_dishes_legacy_v1` | `legacy_v1_id` | BTREE | `legacy_v1_id IS NOT NULL` |
| `idx_dishes_legacy_v2` | `legacy_v2_id` | BTREE | `legacy_v2_id IS NOT NULL` |

### `dish_modifiers` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `dish_modifiers_pkey` | `id` | PRIMARY KEY | - |
| `idx_dish_modifiers_dish` | `dish_id` | BTREE | - |
| `idx_dish_modifiers_group` | `modifier_group_id` | BTREE | `deleted_at IS NULL` |
| `idx_dish_modifiers_restaurant` | `restaurant_id` | BTREE | - |

---

## 🔒 RLS Policies

### `dishes` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `dishes_public_read` | SELECT | anon, authenticated | Read active dishes |
| `dishes_select_restaurant_admin` | SELECT | authenticated | Admin reads their dishes |
| `dishes_insert_restaurant_admin` | INSERT | authenticated | Admin creates dishes |
| `dishes_update_restaurant_admin` | UPDATE | authenticated | Admin updates dishes |
| `dishes_delete_restaurant_admin` | DELETE | authenticated | Admin soft-deletes dishes |
| `dishes_service_role_all` | ALL | service_role | Full access |

### `dish_modifiers` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `dish_modifiers_public_read` | SELECT | anon, authenticated | Read active modifiers |
| `dish_modifiers_select_restaurant_admin` | SELECT | authenticated | Admin reads modifiers |
| `dish_modifiers_insert_restaurant_admin` | INSERT | authenticated | Admin creates modifiers |
| `dish_modifiers_update_restaurant_admin` | UPDATE | authenticated | Admin updates modifiers |
| `dish_modifiers_delete_restaurant_admin` | DELETE | authenticated | Admin deletes modifiers |
| `dish_modifiers_service_role_all` | ALL | service_role | Full access |

---

## ⚙️ Triggers

### `dishes` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `audit_dishes_changes` | INSERT, UPDATE, DELETE | AFTER | `audit_trigger_func()` | Audit logging |
| `check_dish_pricing` | INSERT, UPDATE | BEFORE | `enforce_dish_pricing()` | Validate pricing |
| `notify_dishes_change` | INSERT, UPDATE, DELETE | AFTER | `notify_menu_change()` | Real-time updates |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason | Migration Notes |
|------|--------------|--------|-----------------|
| - | - | - | No removed functionalities yet |

---

## ✨ New Functionalities

| Date | Functionality | Status | Notes |
|------|--------------|--------|-------|
| - | Template-based modifiers | Complete | 61% of groups use templates |

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | SQL Applied | Impact |
|------|-----------------|-------------|--------|
| - | - | - | No fixes applied yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 12 |
| Total Dishes | ~24,277 |
| Total Courses | ~2,500 |
| Total Modifier Groups | ~22,632 |
| Total Dish Modifiers | ~358,499 |
| Total Modifier Prices | ~606,492 |
| Entity Size | ~450 MB (60% of database) |

---

**Last Updated:** 2025-11-27

