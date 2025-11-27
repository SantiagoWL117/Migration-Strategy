# 01 - Restaurant Entity

> **Core Profile & Configuration** - The central hub of the menuca_v3 schema

---

## 📋 Purpose

The Restaurant Entity represents the **core business unit** in the Menu.ca platform. It stores restaurant profiles, configuration settings, and serves as the primary reference point for all other entities in the system.

**Key Responsibilities:**
- Restaurant identity and branding
- Contact and location information
- Service configuration (delivery, takeout, tips)
- Domain and SEO management
- Status tracking and onboarding

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

### Core Tables

#### `restaurants` (Primary Table)
**Purpose:** Main restaurant profile and identity

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | uuid_generate_v4() | External API identifier |
| `name` | varchar | NO | - | Restaurant name |
| `slug` | varchar | NO | - | URL-friendly identifier |
| `status` | restaurant_status | NO | 'active' | Current status |
| `legacy_v1_id` | integer | YES | - | Migration reference from V1 |
| `legacy_v2_id` | integer | YES | - | Migration reference from V2 |
| `timezone` | varchar | YES | 'America/Toronto' | Restaurant timezone |
| `activated_at` | timestamptz | YES | - | When restaurant went live |
| `suspended_at` | timestamptz | YES | - | Suspension timestamp |
| `closed_at` | timestamptz | YES | - | Permanent closure timestamp |
| `parent_restaurant_id` | bigint | YES | - | For franchise relationships |
| `is_franchise_parent` | boolean | NO | false | Is this a franchise parent? |
| `franchise_brand_name` | varchar | YES | - | Franchise brand if applicable |
| `online_ordering_enabled` | boolean | NO | true | Can accept online orders |
| `online_ordering_disabled_at` | timestamptz | YES | - | When ordering was disabled |
| `online_ordering_disabled_reason` | text | YES | - | Reason for disabling |
| `meta_title` | varchar | YES | - | SEO page title |
| `meta_description` | text | YES | - | SEO meta description |
| `meta_keywords` | text | YES | - | SEO keywords |
| `search_keywords` | text | YES | - | Internal search terms |
| `search_vector` | tsvector | YES | generated | Full-text search vector |
| `verified` | boolean | NO | false | Verification status |
| `logo_url` | varchar | YES | - | Logo image URL |
| `banner_image_url` | varchar | YES | - | Banner image URL |
| `primary_color` | varchar | YES | '#000000' | Brand primary color |
| `secondary_color` | varchar | YES | '#666666' | Brand secondary color |
| `font_family` | varchar | YES | 'Inter' | Brand font |
| `button_style` | varchar | YES | 'rounded' | UI button style |
| `menu_layout` | varchar | YES | 'grid' | Menu display layout |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | bigint | YES | - | Admin who created |
| `updated_at` | timestamptz | YES | now() | Last update timestamp |
| `updated_by` | bigint | YES | - | Admin who last updated |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

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
| `phone` | varchar(30) | YES | - | Contact phone |
| `email` | varchar(255) | YES | - | Contact email |
| `location_point` | geometry(Point,4326) | YES | - | PostGIS point geometry |
| `is_active` | boolean | NO | true | Active status |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `created_by` | bigint | YES | - | Admin who created |
| `updated_by` | bigint | YES | - | Admin who updated |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `restaurant_contacts`
**Purpose:** Additional contact information

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `contact_type` | varchar | YES | Type of contact (owner, manager, etc.) |
| `name` | varchar | YES | Contact name |
| `phone` | varchar | YES | Phone number |
| `email` | varchar | YES | Email address |
| `is_primary` | boolean | NO | Primary contact flag |
| `created_at` | timestamptz | NO | Creation timestamp |
| `deleted_at` | timestamptz | YES | Soft delete timestamp |
| `deleted_by` | bigint | YES | Admin who deleted |

---

#### `restaurant_service_configs`
**Purpose:** Service settings (delivery, takeout, tips)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | uuid_generate_v4() | External API identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `has_delivery_enabled` | boolean | NO | false | Delivery service enabled |
| `delivery_time_minutes` | integer | YES | - | Estimated delivery time |
| `delivery_min_order` | numeric(10,2) | YES | - | Minimum order for delivery |
| `delivery_max_distance_km` | numeric(6,2) | YES | - | Max delivery distance |
| `takeout_enabled` | boolean | NO | false | Takeout service enabled |
| `takeout_time_minutes` | integer | YES | - | Estimated takeout prep time |
| `takeout_discount_enabled` | boolean | YES | false | Takeout discount active |
| `takeout_discount_type` | varchar(20) | YES | - | 'percentage' or 'fixed' |
| `takeout_discount_value` | numeric(10,2) | YES | - | Discount amount |
| `allows_preorders` | boolean | YES | false | Pre-orders accepted |
| `preorder_time_frame_hours` | integer | YES | - | How far ahead can order |
| `is_bilingual` | boolean | YES | false | Bilingual menu support |
| `default_language` | varchar(5) | YES | 'en' | Default language (en/fr/es) |
| `accepts_tips` | boolean | YES | true | Tips enabled |
| `requires_phone` | boolean | YES | true | Phone required for orders |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `restaurant_delivery_config`
**Purpose:** Advanced delivery configuration

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `uuid` | uuid | NO | External API identifier |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `use_multiple_areas` | boolean | NO | Use multiple delivery areas |
| `max_delivery_distance_km` | numeric | YES | Maximum delivery distance |
| `active_partners` | jsonb | YES | Active delivery partners |
| `partner_credentials` | jsonb | YES | Partner API credentials |
| `disable_delivery_until` | timestamptz | YES | Temporary delivery disable |
| `legacy_v1_send_to_delivery` | boolean | YES | V1 migration flag |
| `legacy_v1_twilio_call` | boolean | YES | V1 Twilio integration |
| `restaurant_delivery_charge` | numeric | YES | Restaurant's delivery charge |
| `delivery_service_extra` | numeric | YES | Extra service charge |
| `created_at` | timestamptz | NO | Creation timestamp |

---

#### `restaurant_domains`
**Purpose:** Custom domain mappings

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `domain` | varchar | NO | Custom domain |
| `is_primary` | boolean | NO | Primary domain flag |
| `ssl_status` | varchar | YES | SSL certificate status |
| `verified_at` | timestamptz | YES | Domain verification timestamp |
| `created_at` | timestamptz | NO | Creation timestamp |
| `deleted_at` | timestamptz | YES | Soft delete timestamp |
| `deleted_by` | bigint | YES | Admin who deleted |

---

#### `restaurant_onboarding`
**Purpose:** Setup progress tracking

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `step` | varchar | NO | Current onboarding step |
| `completed_at` | timestamptz | YES | Step completion timestamp |
| `data` | jsonb | YES | Step-specific data |
| `created_at` | timestamptz | NO | Creation timestamp |

---

#### `restaurant_status_history`
**Purpose:** Status change audit trail

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `old_status` | varchar | YES | Previous status |
| `new_status` | varchar | NO | New status |
| `reason` | text | YES | Reason for change |
| `changed_by` | bigint | YES | Admin who made change |
| `changed_at` | timestamptz | NO | Change timestamp |

---

#### `restaurant_twilio_config`
**Purpose:** Twilio phone/SMS integration

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `twilio_phone_number` | varchar | YES | Assigned Twilio number |
| `twilio_sid` | varchar | YES | Twilio account SID |
| `enabled` | boolean | NO | Integration enabled |
| `created_at` | timestamptz | NO | Creation timestamp |

---

#### `restaurant_reviews`
**Purpose:** Customer reviews

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `user_id` | bigint | YES | FK to users |
| `rating` | integer | NO | Rating (1-5) |
| `comment` | text | YES | Review text |
| `is_approved` | boolean | NO | Moderation status |
| `created_at` | timestamptz | NO | Creation timestamp |

---

### Metadata & Categorization Tables

#### `restaurant_cuisines`
**Purpose:** Cuisine type assignments

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `cuisine_type_id` | integer | NO | FK to cuisine_types |
| `is_primary` | boolean | NO | Primary cuisine flag |

---

#### `restaurant_tag_assignments`
**Purpose:** Tag linkages for categorization

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `tag_id` | bigint | NO | FK to restaurant_tags |
| `created_at` | timestamptz | NO | Creation timestamp |

---

#### `restaurant_tag_associations`
**Purpose:** Marketing tag associations

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `tag_id` | bigint | NO | FK to marketing_tags |

---

#### `restaurant_tags`
**Purpose:** Available tags for restaurants

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `name` | varchar | NO | Tag name |
| `slug` | varchar | NO | URL-friendly identifier |
| `description` | text | YES | Tag description |

---

## 🔧 SQL Functions

### Restaurant Search & Retrieval

```sql
-- Function: Get restaurant by slug
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_by_slug(p_slug text)
RETURNS TABLE(...)
```

```sql
-- Function: Search restaurants by name/cuisine
CREATE OR REPLACE FUNCTION menuca_v3.search_restaurants(
    p_query text,
    p_city_id integer DEFAULT NULL,
    p_cuisine_type_id integer DEFAULT NULL
)
RETURNS TABLE(...)
```

### Restaurant Status Management

```sql
-- Function: Update restaurant status
CREATE OR REPLACE FUNCTION menuca_v3.update_restaurant_status(
    p_restaurant_id bigint,
    p_new_status restaurant_status,
    p_reason text DEFAULT NULL
)
RETURNS void
```

**TODO:** Document all SQL functions after database query

---

## ⚡ Edge Functions

| Function Name | Endpoint | Purpose |
|--------------|----------|---------|
| `create-admin-user` | `/functions/v1/create-admin-user` | Create restaurant admin |
| `assign-admin-restaurants` | `/functions/v1/assign-admin-restaurants` | Assign admin to restaurants |

**TODO:** Document all Edge Functions from Supabase

---

## 📇 Indexes

### `restaurants` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurants_pkey` | `id` | PRIMARY KEY | - |
| `restaurants_uuid_key` | `uuid` | UNIQUE | - |
| `restaurants_slug_key` | `slug` | UNIQUE | `deleted_at IS NULL` |
| `idx_restaurants_status` | `status` | BTREE | - |
| `idx_restaurants_search` | `search_vector` | GIN | - |
| `idx_restaurants_legacy_v1` | `legacy_v1_id` | BTREE | `legacy_v1_id IS NOT NULL` |
| `idx_restaurants_legacy_v2` | `legacy_v2_id` | BTREE | `legacy_v2_id IS NOT NULL` |

### `restaurant_locations` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurant_locations_pkey` | `id` | PRIMARY KEY | - |
| `idx_locations_restaurant` | `restaurant_id` | BTREE | - |
| `idx_locations_city` | `city_id` | BTREE | `deleted_at IS NULL` |
| `idx_locations_coords` | `latitude, longitude` | BTREE | - |
| `idx_locations_point` | `location_point` | GIST | - |

---

## 🔒 RLS Policies

### `restaurants` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_read_active_restaurants` | SELECT | anon, authenticated | Read active restaurants |
| `restaurants_select_restaurant_admin` | SELECT | authenticated | Admin can select their restaurants |
| `restaurants_insert_restaurant_admin` | INSERT | authenticated | Admin can insert restaurants |
| `restaurants_update_restaurant_admin` | UPDATE | authenticated | Admin can update their restaurants |
| `restaurants_delete_restaurant_admin` | DELETE | authenticated | Admin can soft-delete their restaurants |
| `restaurants_service_role_all` | ALL | service_role | Service role has full access |

### `restaurant_service_configs` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_read_service_configs` | SELECT | anon, authenticated | Read configs for active restaurants |
| `service_configs_select_restaurant_admin` | SELECT | authenticated | Admin can select their configs |
| `service_configs_insert_restaurant_admin` | INSERT | authenticated | Admin can create configs |
| `service_configs_update_restaurant_admin` | UPDATE | authenticated | Admin can update configs |
| `service_configs_delete_restaurant_admin` | DELETE | authenticated | Admin can delete configs |
| `service_configs_service_role_all` | ALL | service_role | Service role has full access |

---

## ⚙️ Triggers

### `restaurants` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `set_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update `updated_at` timestamp |
| `audit_restaurants_changes` | INSERT, UPDATE, DELETE | AFTER | `audit_trigger_func()` | Log changes to audit table |

### `restaurant_service_configs` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `trg_service_configs_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |
| `notify_service_configs_change` | INSERT, UPDATE, DELETE | AFTER | `notify_schedule_change()` | Real-time notification |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason | Migration Notes |
|------|--------------|--------|-----------------|
| - | - | - | No removed functionalities yet |

---

## ✨ New Functionalities

| Date | Functionality | Status | Notes |
|------|--------------|--------|-------|
| - | - | - | No new functionalities documented yet |

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | SQL Applied | Impact |
|------|-----------------|-------------|--------|
| 2025-11-27 | Updated restaurant 949 legacy_v1_id | `UPDATE menuca_v3.restaurants SET legacy_v1_id = 1071 WHERE id = 949` | Low |
| 2025-11-27 | Merged Sushi Presse duplicates (1019→1020) | SEO metadata copied, 1019 hard deleted | Low |
| 2025-11-27 | Added location for Yorgo's - Nepean (985) | `INSERT INTO restaurant_locations...` | Low |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 15 |
| Total Records (restaurants) | ~1,020 |
| Active Restaurants | ~250 |
| With Legacy V1 ID | ~165 |
| With Legacy V2 ID | ~94 |

---

**Last Updated:** 2025-11-27

