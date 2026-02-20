# 01 - Restaurant Entity

> **Core Profile & Configuration** - The central hub of the menuca_v3 schema

---

## 📋 Purpose

The Restaurant Entity represents the **core business unit** in the Menu.ca platform. It stores restaurant profiles, configuration settings, and serves as the primary reference point for all other entities in the system.

**Key Responsibilities:**
- Restaurant identity and branding
- Contact and location information
- Domain and SEO management
- Status tracking and onboarding
- Cuisine and tag categorization
- Commission and payment configuration
- Analytics integration

> **Note:** Scheduling tables (`restaurant_schedules`, `restaurant_special_schedules`) and delivery tables (`restaurant_delivery_areas`, `delivery_and_pickup_configs`, `restaurant_delivery_companies`, `restaurant_distance_based_delivery_fees`) are documented in [02-delivery-zones-entity.md](./02-delivery-zones-entity.md). Menu caching (`restaurant_menu_cache`) is documented in [03-menu-management-entity.md](./03-menu-management-entity.md).

---

## 📑 Index

- [Tables](#-tables)
  - [restaurants](#restaurants-primary-table) | [restaurant_locations](#restaurant_locations) | [restaurant_domains](#restaurant_domains) | [restaurant_subdomains](#restaurant_subdomains)
  - [restaurant_onboarding](#restaurant_onboarding) | [restaurant_status_history](#restaurant_status_history)
  - [restaurant_twilio_config](#restaurant_twilio_config) | [restaurant_analytics_configs](#restaurant_analytics_configs)
  - [restaurant_commission_configs](#restaurant_commission_configs) | [restaurant_payment_options](#restaurant_payment_options)
  - [restaurant_cuisines](#restaurant_cuisines) | [restaurant_tag_assignments](#restaurant_tag_assignments) | [restaurant_tag_associations](#restaurant_tag_associations) | [restaurant_tags](#restaurant_tags)
  - [restaurant_reviews](#restaurant_reviews) | [restaurant_ownership_groups](#restaurant_ownership_groups) | [restaurant_group_memberships](#restaurant_group_memberships)
- [Views](#️-views)
- [SQL Functions](#-sql-functions)
- [Edge Functions](#-edge-functions)
- [Indexes](#-indexes)
- [RLS Policies](#-rls-policies)
- [Triggers](#️-triggers)
- [Data Integrity Issues](#-data-integrity-issues)
- [Removed Functionalities](#️-removed-functionalities)
- [New Functionalities](#-new-functionalities)
- [Schema Fixes Applied](#-schema-fixes-applied)
- [Statistics](#-statistics)

---

## 📊 Tables

### Core Tables

#### `restaurants` (Primary Table)
**Purpose:** Main restaurant profile and identity

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | uuid_generate_v4() | External API identifier |
| `name` | varchar(255) | NO | - | Restaurant name |
| `slug` | varchar(255) | YES | generated | URL-friendly identifier (auto-generated) |
| `status` | restaurant_status | NO | 'pending' | Current status |
| `legacy_v1_id` | integer | YES | - | Migration reference from V1 |
| `legacy_v2_id` | integer | YES | - | Migration reference from V2 |
| `timezone` | varchar(50) | NO | 'America/Toronto' | Restaurant timezone |
| `activated_at` | timestamptz | YES | - | When restaurant went live |
| `suspended_at` | timestamptz | YES | - | Suspension timestamp |
| `closed_at` | timestamptz | YES | - | Permanent closure timestamp |
| `parent_restaurant_id` | bigint | YES | - | For franchise relationships |
| `is_franchise_parent` | boolean | NO | false | Is this a franchise parent? |
| `franchise_brand_name` | varchar(255) | YES | - | Franchise brand if applicable |
| `online_ordering_enabled` | boolean | NO | true | Can accept online orders |
| `online_ordering_disabled_at` | timestamptz | YES | - | When ordering was disabled |
| `online_ordering_disabled_reason` | text | YES | - | Reason for disabling |
| `meta_title` | varchar(160) | YES | - | SEO page title |
| `meta_description` | varchar(320) | YES | - | SEO meta description |
| `meta_keywords` | text | YES | - | SEO keywords |
| `search_keywords` | text | YES | - | Internal search terms |
| `search_vector` | tsvector | YES | generated | Full-text search vector |
| `verified` | boolean | YES | false | Verification status |
| `logo_url` | text | YES | - | Logo image URL |
| `banner_image_url` | text | YES | - | Banner image URL |
| `banner_is_ai_generated` | boolean | YES | false | AI-generated banner flag |
| `primary_color` | varchar(7) | YES | '#000000' | Brand primary color |
| `secondary_color` | varchar(7) | YES | '#666666' | Brand secondary color |
| `checkout_button_color` | varchar(7) | YES | - | Checkout button color |
| `price_color` | varchar(7) | YES | - | Price display color |
| `font_family` | varchar(100) | YES | 'Inter' | Brand font |
| `button_style` | varchar(20) | YES | 'rounded' | UI button style ('rounded', 'square') |
| `menu_layout` | varchar(20) | YES | 'grid' | Menu display layout ('list', 'grid', 'grid2', 'grid4', 'image_cards') |
| `logo_display_mode` | varchar(20) | YES | 'icon_text' | Logo display mode |
| `show_order_online_badge` | boolean | YES | false | Show order online badge |
| `image_card_description_lines` | varchar(1) | YES | '2' | Description lines in image cards |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | bigint | YES | - | FK to admin_users |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `updated_by` | bigint | YES | - | FK to admin_users |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | FK to admin_users |

**Check Constraints:**
- `restaurants_button_style_check`: button_style IN ('rounded', 'square')
- `restaurants_menu_layout_check`: menu_layout IN ('list', 'grid', 'grid2', 'grid4', 'image_cards')
- `restaurants_no_self_parent`: parent_restaurant_id <> id
- `restaurants_online_ordering_consistency`: Validates enabled/disabled_at consistency

---

#### `restaurant_locations`
**Purpose:** Physical addresses and geographic coordinates

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | uuid_generate_v4() | External API identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `is_primary` | boolean | NO | true | Primary location flag |
| `street_address` | varchar(255) | YES | - | Street address |
| `city_id` | integer | YES | - | FK to cities |
| `province_id` | integer | YES | - | FK to provinces |
| `postal_code` | varchar(15) | YES | - | Postal/ZIP code |
| `latitude` | numeric(13,10) | YES | - | Geographic latitude |
| `longitude` | numeric(13,10) | YES | - | Geographic longitude |
| `location_point` | geometry(Point,4326) | YES | - | PostGIS point geometry |
| `phone` | varchar(30) | YES | - | Contact phone |
| `email` | varchar(255) | YES | - | Contact email |
| `is_active` | boolean | NO | true | Active status |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `created_by` | bigint | YES | - | FK to admin_users |
| `updated_by` | bigint | YES | - | FK to admin_users |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | FK to admin_users |

---

### Domain & SEO Tables

#### `restaurant_domains`
**Purpose:** Custom domain mappings

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `domain` | varchar | NO | - | Custom domain |
| `is_primary` | boolean | NO | false | Primary domain flag |
| `ssl_status` | varchar | YES | - | SSL certificate status |
| `verified_at` | timestamptz | YES | - | Domain verification timestamp |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | FK to admin_users |

---

#### `restaurant_subdomains`
**Purpose:** Subdomain mappings (e.g., restaurant.menu.ca)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `subdomain` | varchar(63) | NO | - | Subdomain (UNIQUE) |
| `slug` | varchar(255) | NO | - | URL slug |
| `name` | varchar(255) | NO | - | Display name |
| `is_primary` | boolean | YES | false | Primary subdomain |
| `is_active` | boolean | YES | true | Subdomain active |
| `created_at` | timestamptz | YES | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |

---

### Onboarding & Status Tables

#### `restaurant_onboarding`
**Purpose:** Setup progress tracking

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants (UNIQUE) |
| `step` | varchar | NO | - | Current onboarding step |
| `completed_at` | timestamptz | YES | - | Step completion timestamp |
| `data` | jsonb | YES | - | Step-specific data |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_status_history`
**Purpose:** Status change audit trail

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `old_status` | varchar | YES | - | Previous status |
| `new_status` | varchar | NO | - | New status |
| `reason` | text | YES | - | Reason for change |
| `changed_by` | bigint | YES | - | Admin who made change |
| `changed_at` | timestamptz | NO | now() | Change timestamp |

---

### Integration Tables

#### `restaurant_twilio_config`
**Purpose:** Twilio phone/SMS integration

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants (UNIQUE) |
| `twilio_phone_number` | varchar | YES | - | Assigned Twilio number |
| `twilio_sid` | varchar | YES | - | Twilio account SID |
| `enabled` | boolean | NO | false | Integration enabled |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_analytics_configs`
**Purpose:** Google Analytics integration

> **Warning:** The `restaurant_id` column is misleadingly named — it actually references `restaurant_locations(id)` via FK, not `restaurants(id)`. See [Data Integrity Issues](#-data-integrity-issues).

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `restaurant_id` | integer | NO | - | FK to restaurant_locations (UNIQUE) — **misnamed, actually a location_id** |
| `ga_measurement_id` | text | YES | - | GA4 Measurement ID |
| `created_at` | timestamptz | YES | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |

---

### Financial Tables

#### `restaurant_commission_configs`
**Purpose:** Platform commission rates

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `commission_enabled` | boolean | NO | false | Commission active |
| `commission_rate` | numeric(5,2) | NO | 0 | Commission rate |
| `commission_type` | commission_rate_type | NO | 'percentage' | Rate type |
| `commission_base` | text | NO | 'gross' | 'gross' or 'net' |
| `effective_from` | date | NO | CURRENT_DATE | Start date |
| `effective_until` | date | YES | - | End date (NULL = ongoing) |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | bigint | YES | - | FK to admin_users |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |
| `updated_by` | bigint | YES | - | FK to admin_users |

**Unique Constraint:** (restaurant_id, effective_from)

---

#### `restaurant_payment_options`
**Purpose:** Accepted payment methods

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `payment_method` | payment_method_type | NO | - | Payment type enum |
| `is_enabled` | boolean | NO | true | Method enabled |
| `display_order` | integer | NO | 0 | Sort order |
| `english_label` | text | YES | - | English display name |
| `french_label` | text | YES | - | French display name |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |

**Unique Constraint:** (restaurant_id, payment_method)

---

### Metadata & Categorization Tables

#### `restaurant_cuisines`
**Purpose:** Cuisine type assignments

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `cuisine_type_id` | integer | NO | - | FK to cuisine_types |
| `is_primary` | boolean | NO | false | Primary cuisine flag |

**Unique Constraint:** (restaurant_id, cuisine_type_id)

---

#### `restaurant_tag_assignments`
**Purpose:** Tag linkages for categorization

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `tag_id` | bigint | NO | - | FK to restaurant_tags |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

**Unique Constraint:** (restaurant_id, tag_id)

---

#### `restaurant_tag_associations`
**Purpose:** Marketing tag associations

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `tag_id` | bigint | NO | - | FK to marketing_tags |

**Unique Constraint:** (restaurant_id, tag_id)

---

#### `restaurant_tags`
**Purpose:** Available tags for restaurants

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `name` | varchar | NO | - | Tag name (UNIQUE) |
| `slug` | varchar | NO | - | URL-friendly identifier (UNIQUE) |
| `description` | text | YES | - | Tag description |

---

### Reviews Table

#### `restaurant_reviews`
**Purpose:** Customer reviews and ratings (0 rows — not yet in use)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `user_id` | bigint | YES | - | FK to users |
| `rating` | integer | NO | - | Rating (1-5) |
| `comment` | text | YES | - | Review text |
| `is_approved` | boolean | NO | false | Moderation status |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Ownership Groups Tables (Empty — unused)

#### `restaurant_ownership_groups`
**Purpose:** Group restaurants by business owner (0 rows — never populated)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `group_name` | varchar | NO | - | Group name |
| `owner_name` | varchar | YES | - | Owner name |
| `created_at` | timestamptz | YES | - | Creation timestamp |

---

#### `restaurant_group_memberships`
**Purpose:** Link restaurants to ownership groups (0 rows — never populated)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `group_id` | integer | NO | - | FK to restaurant_ownership_groups |
| `restaurant_id` | integer | NO | - | FK to restaurants |
| `created_at` | timestamptz | YES | - | Creation timestamp |

---

## 👁️ Views

#### `restaurant_tax_info`
**Purpose:** Consolidated tax information view

| Column | Type | Description |
|--------|------|-------------|
| `restaurant_id` | bigint | Restaurant ID |
| `restaurant_uuid` | uuid | Restaurant UUID |
| `restaurant_name` | varchar(255) | Restaurant name |
| `province_id` | smallint | Province ID |
| `province_code` | char(3) | Province code |
| `province_name` | varchar(125) | Province name |
| `taxes` | jsonb | Tax details |
| `total_tax_rate` | numeric | Combined tax rate |

---

## 🔧 SQL Functions

### Restaurant Search & Retrieval

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get_restaurant_by_slug` | p_slug text | TABLE | Get restaurant by URL slug |
| `search_restaurants` | p_query text, p_city_id int, p_cuisine_type_id int | TABLE | Search restaurants |
| `find_nearby_restaurants` | location, distance | TABLE | Find restaurants near point |
| `get_restaurants_near_location` | lat, lng, radius | TABLE | Geo-based search |
| `get_restaurants_by_cuisine` | cuisine_id | TABLE | Filter by cuisine |
| `get_restaurants_by_tag` | tag_id | TABLE | Filter by tag |

### Restaurant Configuration

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get_restaurant_config` | restaurant_id | jsonb | Get full config |
| `get_restaurant_menu` | restaurant_id | jsonb | Get menu data |
| `get_restaurant_menu_cached` | restaurant_id, lang | jsonb | Get cached menu |

### Restaurant Status & Admin

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `audit_restaurant_status_change` | - | trigger | Status change trigger |
| `get_restaurant_status_stats` | - | TABLE | Status statistics |
| `get_restaurant_status_timeline` | restaurant_id | TABLE | Status history |
| `check_admin_restaurant_access` | admin_id, restaurant_id | boolean | Verify admin access |
| `get_admin_restaurants` | admin_user_id | TABLE | Get admin's restaurants |
| `assign_restaurants_to_admin` | admin_id, restaurant_ids | void | Assign restaurants |

### Restaurant Creation & Setup

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `generate_restaurant_slug` | - | trigger | Auto-generate slug |
| `create_restaurant_with_cuisine` | name, cuisine_id | bigint | Create with cuisine |
| `create_restaurant_onboarding` | restaurant_id | void | Initialize onboarding |
| `add_restaurant_location_onboarding` | restaurant_id, location_data | void | Add location step |
| `add_cuisine_to_restaurant` | restaurant_id, cuisine_id | void | Add cuisine |
| `add_tag_to_restaurant` | restaurant_id, tag_id | void | Add tag |
| `create_restaurant_tag` | name, slug | bigint | Create new tag |

### Orders & Devices

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get_restaurant_orders` | restaurant_id | TABLE | Get orders |
| `get_restaurant_devices` | restaurant_id | TABLE | Get devices |
| `get_restaurant_vendor` | restaurant_id | TABLE | Get vendor info |
| `add_restaurant_to_vendor` | restaurant_id, vendor_id | void | Add to vendor |

### User Features

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `toggle_favorite_restaurant` | user_id, restaurant_id | boolean | Toggle favorite |
| `get_favorite_restaurants` | user_id | TABLE | Get favorites |

---

## ⚡ Edge Functions

| Function Name | Endpoint | Purpose |
|--------------|----------|---------|
| `create-admin-user` | `/functions/v1/create-admin-user` | Create restaurant admin |
| `assign-admin-restaurants` | `/functions/v1/assign-admin-restaurants` | Assign admin to restaurants |

---

## 📇 Indexes

### `restaurants` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurants_pkey` | `id` | PRIMARY KEY | - |
| `restaurants_uuid_key` | `uuid` | UNIQUE | - |
| `restaurants_slug_key` | `slug` | UNIQUE | - |
| `idx_restaurants_status` | `status` | BTREE | - |
| `idx_restaurants_search_vector` | `search_vector` | GIN | - |
| `idx_restaurants_legacy` | `legacy_v1_id, legacy_v2_id` | BTREE | - |
| `idx_restaurants_id_not_deleted` | `id` | BTREE | `deleted_at IS NULL` |

### `restaurant_locations` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurant_locations_pkey` | `id` | PRIMARY KEY | - |
| `restaurant_locations_uuid_key` | `uuid` | UNIQUE | - |
| `idx_locations_restaurant` | `restaurant_id` | BTREE | - |
| `idx_locations_city_id` | `city_id` | BTREE | - |
| `idx_restaurant_locations_city` | `city_id` | BTREE | `deleted_at IS NULL` |
| `idx_restaurant_locations_deleted` | `restaurant_id` | BTREE | `deleted_at IS NULL` |
| `idx_restaurant_locations_soft_delete_active` | `restaurant_id, id` | BTREE | `deleted_at IS NULL` |
| `idx_locations_coords` | `latitude, longitude` | BTREE | - |
| `idx_restaurant_locations_point` | `location_point` | GIST | - |
| `idx_locations_active` | `restaurant_id, is_active` | BTREE | `is_active = true` |

---

## 🔒 RLS Policies

### `restaurants`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Enable public read access` | SELECT | public | Anyone can read restaurants |
| `admin_crud_own_restaurants` | ALL | authenticated | Admin can manage their own restaurants via `current_admin_restaurant_ids()` |
| `restaurants_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_locations`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_crud_own_restaurant_locations` | ALL | authenticated | Admin can manage locations for their restaurants |
| `locations_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_commission_configs`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `restaurant_commission_configs_admin_select` | SELECT | authenticated | Admin can view commissions for their restaurants |
| `restaurant_commission_configs_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_cuisines`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_crud_own_restaurant_cuisines` | ALL | authenticated | Admin can manage cuisines for their restaurants |
| `restaurant_cuisines_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_domains`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_crud_own_restaurant_domains` | ALL | authenticated | Admin can manage domains for their restaurants |
| `domains_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_subdomains`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_crud_own_restaurant_subdomains` | ALL | authenticated | Admin can manage subdomains for their restaurants |
| `restaurant_subdomains_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_onboarding`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_crud_own_restaurant_onboarding` | ALL | authenticated | Admin can manage onboarding for their restaurants |
| `restaurant_onboarding_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_payment_options`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `anyone_can_view_restaurant_payment_options` | SELECT | anon, authenticated | Anyone can view enabled payment options (for checkout) |
| `admin_crud_own_restaurant_payment_options` | ALL | authenticated | Admin can manage payment options for their restaurants |
| `restaurant_payment_options_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_analytics_configs`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_select_own_restaurant_analytics_configs` | SELECT | authenticated | Admin can view analytics config for their restaurants |
| `restaurant_analytics_configs_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_reviews`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `admin_select_own_restaurant_reviews` | SELECT | authenticated | Admin can view reviews for their restaurants |
| `restaurant_reviews_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_tags`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `authenticated_read_tags` | SELECT | authenticated | Authenticated users can read tags |
| `restaurant_tags_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_tag_associations`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_view_tag_associations` | SELECT | public | Anyone can view tag associations |
| `tag_assoc_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_twilio_config`

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `twilio_config_service_role_all` | ALL | service_role | Service role has full access |

---

## ⚙️ Triggers

### `restaurants` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `trg_restaurants_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |
| `trg_restaurant_generate_slug` | INSERT | BEFORE | `generate_restaurant_slug()` | Auto-generate slug |
| `trg_restaurant_status_change` | UPDATE | BEFORE | `audit_restaurant_status_change()` | Track status changes |
| `trg_validate_restaurant_timezone` | INSERT, UPDATE | BEFORE | `validate_timezone()` | Validate timezone |
| `audit_restaurants_changes` | INSERT, UPDATE, DELETE | AFTER | `audit_trigger_func()` | Audit log |

### `restaurant_locations` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `trg_locations_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |
| `restaurant_location_changed` | INSERT, UPDATE | AFTER | `notify_location_change()` | Location change notification |

---

## 🚨 Data Integrity Issues

> Audit date: 2026-02-17

### Misleading FK: `restaurant_analytics_configs.restaurant_id`

The column `restaurant_id` actually references `restaurant_locations(id)` via FK, **not** `restaurants(id)`. The column name is misleading. All 186 records resolve correctly through `restaurant_locations` to the parent restaurant, so there is no data loss — only a naming issue.

**Recommendation:** Rename column to `location_id` or change FK to reference `restaurants(id)` directly.

### 10 restaurants missing cuisine assignments

| ID | Name |
|----|------|
| 1009 | Econo Pizza |
| 1010 | Lemongrass Thai Cuisine |
| 1011 | Mozza Pizza Gatineau |
| 1012 | Papa Pizza Des Flandres |
| 1013 | Papa Pizza Maloney |
| 1014 | Papa Pizza Val-Des-Monts |
| 1015 | Poutinerie Québecurds Gatineau |
| 1016 | Roulas Grecque et Pizza |
| 1017 | Sushi Express Chambly |
| 1021 | JJ's Shawarma |

These are newer restaurants (IDs 1009-1021) added without completing the cuisine assignment step.

### 1 location missing coordinates and city

- **Restaurant 1010 (Lemongrass Thai Cuisine)** — location ID 5487 has street address "331 Elgin St" but `latitude`, `longitude`, and `city_id` are all NULL.

### 178 restaurants have no subdomain record

Only 8 out of 186 restaurants have entries in `restaurant_subdomains`. Most restaurants rely on custom domains only.

### Empty/unused tables

| Table | Rows | Notes |
|-------|------|-------|
| `restaurant_reviews` | 0 | Feature not yet in use |
| `restaurant_ownership_groups` | 0 | Never populated — candidate for removal |
| `restaurant_group_memberships` | 0 | Never populated — candidate for removal |

### Franchise feature defined but unused

`parent_restaurant_id` is NULL for all 186 restaurants. The franchise parent/child columns (`is_franchise_parent`, `franchise_brand_name`, `parent_restaurant_id`) and related Edge Functions (`create-franchise-parent`, `convert-restaurant-to-franchise`, `copy-franchise-menu`, `bulk-update-franchise-feature`) exist but are not in active use.

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason | Migration Notes |
|------|--------------|--------|-----------------|
| 2026-01-23 | `restaurant_contacts` table | Never implemented | Contact info stored in `restaurant_locations` |
| 2026-01-23 | `restaurant_service_configs` table | Renamed | Replaced by `delivery_and_pickup_configs` (see 02-delivery-zones-entity.md) |
| 2026-01-23 | `restaurant_delivery_config` table | Restructured | Split into delivery tables (see 02-delivery-zones-entity.md) |

---

## ✨ New Functionalities

| Date | Functionality | Status | Notes |
|------|--------------|--------|-------|
| 2026-01-23 | `restaurant_subdomains` table | ✅ Active | Subdomain mappings |
| 2026-01-23 | `restaurant_commission_configs` table | ✅ Active | Commission rates |
| 2026-01-23 | `restaurant_payment_options` table | ✅ Active | Payment methods |
| 2026-01-23 | `restaurant_menu_cache` table | ✅ Active | Menu caching |
| 2026-01-23 | `restaurant_analytics_configs` table | ✅ Active | GA integration |

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | SQL Applied | Impact |
|------|-----------------|-------------|--------|
| 2025-11-27 | Updated restaurant 949 legacy_v1_id | `UPDATE menuca_v3.restaurants SET legacy_v1_id = 1071 WHERE id = 949` | Low |
| 2025-11-27 | Merged Sushi Presse duplicates (1019→1020) | SEO metadata copied, 1019 hard deleted | Low |
| 2025-11-27 | Added location for Yorgo's - Nepean (985) | `INSERT INTO restaurant_locations...` | Low |
| 2026-01-23 | Documentation updated to match actual schema | N/A | Documentation only |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 17 |
| Total Views | 1 |
| Total RLS Policies | 26 |
| Total Records (restaurants) | 186 |
| Active Restaurants (deleted_at IS NULL) | 186 |
| With Legacy V1 ID | 165 |
| With Legacy V2 ID | 20 |
| Custom Domains | 273 |
| Subdomains | 8 |
| Twilio Configs | 15 |
| Reviews | 0 |
| SQL Functions | 25+ |

---

## 🔗 Related Entities

- **[02-delivery-zones-entity.md](./02-delivery-zones-entity.md)** - Scheduling and delivery configuration
- **[03-menu-management-entity.md](./03-menu-management-entity.md)** - Menu catalog, dishes, modifiers, combos, menu cache
- **[06-admin-entity.md](./06-admin-entity.md)** - Admin users and restaurant access

---

**Last Updated:** 2026-02-17
