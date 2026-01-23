# 07 - Marketing Entity

> **Promotions & Coupons** - Deals, discount codes, campaigns, and marketing tags

---

## 📋 Purpose

The Marketing Entity manages **promotional activities and customer incentives**:

- **Deals** - Restaurant promotional offers (% off, BOGO, free items)
- **Coupons** - Discount codes for specific restaurants
- **Campaigns** - Advanced promotion system with targeting and tiers
- **Marketing Tags** - Restaurant categorization for discovery
- **Redemption Tracking** - Usage analytics and limits

**Key Responsibilities:**
- Promotional deal configuration and scheduling
- Coupon code validation and redemption
- Campaign management with item targeting
- Bilingual support (EN/FR translations)
- Usage tracking and analytics

---

## 📑 Index

- [Tables](#tables)
  - [Legacy Promotion Tables](#legacy-promotion-tables)
  - [Campaign System Tables](#campaign-system-tables)
  - [Marketing Tags](#marketing-tags-tables)
  - [Translation Tables](#translation-tables)
- [Views](#views)
- [SQL Functions](#sql-functions)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Triggers](#triggers)
- [Removed Functionalities](#removed-functionalities)
- [New Functionalities](#new-functionalities)
- [Schema Fixes Applied](#schema-fixes-applied)

---

## 📊 Tables

### Legacy Promotion Tables

#### `promotional_deals`
**Purpose:** Restaurant promotional offers (migrated from V1/V2)  
**Row Count:** 53

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `restaurant_id` | integer | NO | - | FK to restaurants |
| `type` | varchar(20) | NO | 'restaurant' | Deal type |
| `is_repeatable` | boolean | NO | false | Can be used multiple times |
| `name` | varchar(255) | NO | - | Deal name |
| `description` | text | YES | - | Deal description |
| `active_days` | jsonb | YES | - | Days of week active |
| `date_start` | date | YES | - | Start date |
| `date_stop` | date | YES | - | End date |
| `time_start` | time | YES | - | Daily start time |
| `time_stop` | time | YES | - | Daily end time |
| `specific_dates` | jsonb | YES | - | Specific dates only |
| `deal_type` | varchar(50) | NO | - | percent_off, amount_off, bogo, free_item |
| `discount_percent` | numeric(5,2) | YES | - | Percentage discount |
| `discount_amount` | numeric(8,2) | YES | - | Fixed amount discount |
| `minimum_purchase` | numeric(8,2) | YES | - | Minimum order required |
| `order_count_required` | integer | YES | - | Orders needed to qualify |
| `included_items` | jsonb | YES | - | Items included in deal |
| `required_items` | jsonb | YES | - | Items required to activate |
| `required_item_count` | integer | YES | - | Count of required items |
| `free_item_count` | integer | YES | - | Number of free items |
| `exempted_courses` | jsonb | YES | - | Categories excluded |
| `availability_types` | jsonb | YES | - | delivery/takeout/dine_in |
| `image_url` | varchar(255) | YES | - | Promotional image |
| `promo_code` | varchar(125) | YES | - | Optional code required |
| `display_order` | integer | YES | - | Sort order |
| `is_customizable` | boolean | YES | false | Customer can customize |
| `is_split_deal` | boolean | YES | false | Split across items |
| `is_first_order_only` | boolean | YES | false | New customers only |
| `shows_on_thankyou` | boolean | YES | false | Show on thank you page |
| `sends_in_email` | boolean | YES | false | Include in emails |
| `email_body_html` | text | YES | - | Email HTML content |
| `is_enabled` | boolean | NO | true | Deal active |
| `language_code` | varchar(2) | YES | 'en' | Primary language |
| `v1_deal_id` | integer | YES | - | Legacy V1 ID |
| `v1_meal_number` | integer | YES | - | V1 meal number |
| `v1_position` | varchar(1) | YES | - | V1 position |
| `v1_is_global` | boolean | YES | - | V1 global flag |
| `v2_deal_id` | integer | YES | - | Legacy V2 ID |
| `created_by` | integer | YES | - | Admin who created |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `disabled_by` | integer | YES | - | Admin who disabled |
| `disabled_at` | timestamptz | YES | - | Disable timestamp |
| `updated_at` | timestamptz | YES | now() | Last update |

---

#### `promotional_coupons`
**Purpose:** Discount codes for restaurants  
**Row Count:** 456

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `restaurant_id` | integer | NO | - | FK to restaurants |
| `name` | varchar(125) | NO | - | Coupon name |
| `description` | text | YES | - | Description |
| `code` | varchar(255) | NO | - | Coupon code |
| `valid_from_at` | timestamptz | YES | - | Valid from date |
| `valid_until_at` | timestamptz | YES | - | Expiration date |
| `discount_type` | varchar(20) | NO | - | percent, amount, free_item |
| `discount_amount` | numeric(8,2) | YES | - | Discount value |
| `minimum_purchase` | numeric(8,2) | YES | - | Minimum order required |
| `applies_to_items` | jsonb | YES | - | Specific items only |
| `item_count` | integer | YES | - | Items for discount |
| `max_redemptions` | integer | YES | - | Total usage limit |
| `redeem_value_limit` | numeric(8,2) | YES | - | Max discount per use |
| `coupon_scope` | varchar(20) | YES | 'restaurant' | Scope of coupon |
| `is_one_time_use` | boolean | YES | false | Single use per customer |
| `is_reorder_coupon` | boolean | YES | false | Reorder incentive |
| `includes_in_email` | boolean | YES | false | Include in emails |
| `email_text` | text | YES | - | Email text |
| `is_active` | boolean | NO | true | Coupon active |
| `is_used` | boolean | YES | false | Has been used |
| `language_code` | varchar(2) | YES | 'en' | Primary language |
| `v1_coupon_id` | integer | YES | - | Legacy V1 ID |
| `v2_coupon_id` | integer | YES | - | Legacy V2 ID |
| `source_table` | varchar(50) | YES | - | Migration source |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | FK to admin_users |

---

#### `coupon_usage_log`
**Purpose:** Tracks coupon redemptions  
**Row Count:** 1

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `coupon_id` | bigint | NO | - | FK to promotional_coupons |
| `order_id` | bigint | YES | - | FK to orders |
| `user_id` | bigint | NO | - | FK to users |
| `discount_applied` | numeric(10,2) | NO | - | Discount amount used |
| `used_at` | timestamptz | NO | now() | Redemption timestamp |
| `ip_address` | inet | YES | - | Client IP |
| `user_agent` | text | YES | - | Browser user agent |

**Unique Constraint:** (coupon_id, order_id)

---

### Campaign System Tables

#### `promotion_campaigns`
**Purpose:** Advanced promotion campaigns with targeting  
**Row Count:** 0 (new system)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | YES | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `name` | varchar(255) | NO | - | Campaign name |
| `internal_name` | varchar(255) | YES | - | Internal reference |
| `description` | text | YES | - | Description |
| `campaign_type` | campaign_type | NO | - | first_order, loyalty, flash_sale, etc. |
| `trigger_type` | trigger_type | NO | - | automatic, code_required, etc. |
| `discount_type` | discount_type | NO | - | percent_off, amount_off, bogo, etc. |
| `discount_value` | numeric(10,2) | YES | - | Discount amount/percent |
| `discount_max_value` | numeric(10,2) | YES | - | Maximum discount |
| `bogo_buy_quantity` | integer | YES | 1 | BOGO: buy X |
| `bogo_get_quantity` | integer | YES | 1 | BOGO: get Y |
| `bogo_get_discount_percent` | numeric(5,2) | YES | 100 | BOGO: discount on Y |
| `minimum_order_value` | numeric(10,2) | YES | - | Minimum order required |
| `minimum_item_quantity` | integer | YES | - | Minimum items required |
| `maximum_discount_amount` | numeric(10,2) | YES | - | Cap on discount |
| `starts_at` | timestamptz | YES | - | Campaign start |
| `ends_at` | timestamptz | YES | - | Campaign end |
| `schedule_type` | schedule_type | YES | 'always' | always, recurring, specific_dates |
| `recurring_schedule` | jsonb | YES | - | Recurring schedule config |
| `total_usage_limit` | integer | YES | - | Total redemptions allowed |
| `per_customer_limit` | integer | YES | - | Per customer limit |
| `daily_limit` | integer | YES | - | Daily redemption limit |
| `quantity_available` | integer | YES | - | Available quantity |
| `applies_to_delivery` | boolean | YES | true | Valid for delivery |
| `applies_to_takeout` | boolean | YES | true | Valid for takeout |
| `applies_to_dine_in` | boolean | YES | true | Valid for dine-in |
| `status` | campaign_status | YES | 'draft' | draft, active, paused, ended |
| `is_featured` | boolean | YES | false | Featured promotion |
| `display_order` | integer | YES | 0 | Sort order |
| `customer_display_name` | varchar(255) | YES | - | Customer-facing name |
| `customer_description` | text | YES | - | Customer-facing description |
| `badge_text` | varchar(50) | YES | - | Badge/label text |
| `image_url` | text | YES | - | Promotional image |
| `terms_and_conditions` | text | YES | - | T&C text |
| `created_at` | timestamptz | YES | now() | Creation timestamp |
| `created_by` | bigint | YES | - | FK to admin_users |
| `updated_at` | timestamptz | YES | now() | Last update |
| `updated_by` | bigint | YES | - | FK to admin_users |
| `deleted_at` | timestamptz | YES | - | Soft delete |
| `deleted_by` | bigint | YES | - | FK to admin_users |

---

#### `promotion_codes`
**Purpose:** Discount codes for campaigns  
**Row Count:** 0

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | YES | gen_random_uuid() | External identifier |
| `campaign_id` | bigint | NO | - | FK to promotion_campaigns |
| `code` | varchar(50) | NO | - | Promo code |
| `code_type` | varchar(50) | YES | 'standard' | standard, unique, referral, influencer |
| `generated_for_user_id` | bigint | YES | - | FK to users (unique codes) |
| `referrer_user_id` | bigint | YES | - | FK to users (referral codes) |
| `usage_count` | integer | YES | 0 | Times used |
| `usage_limit` | integer | YES | - | Max uses for this code |
| `is_active` | boolean | YES | true | Code active |
| `expires_at` | timestamptz | YES | - | Expiration |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

**Unique Constraint:** (campaign_id, code)

---

#### `promotion_targets`
**Purpose:** Items/categories targeted by campaigns  
**Row Count:** 0

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `campaign_id` | bigint | NO | - | FK to promotion_campaigns |
| `target_type` | varchar(50) | NO | - | all_items, category, item, item_tag, exclude_* |
| `course_id` | bigint | YES | - | FK to courses |
| `dish_id` | bigint | YES | - | FK to dishes |
| `tag_name` | varchar(100) | YES | - | Item tag name |
| `is_qualifying_item` | boolean | YES | true | Qualifies for promo |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

**Target Types:** `all_items`, `category`, `item`, `item_tag`, `exclude_category`, `exclude_item`

---

#### `promotion_tiers`
**Purpose:** Tiered discount levels for campaigns  
**Row Count:** 0

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `campaign_id` | bigint | NO | - | FK to promotion_campaigns |
| `tier_order` | integer | NO | - | Tier sequence |
| `threshold_amount` | numeric(10,2) | NO | - | Minimum to qualify |
| `discount_type` | varchar(50) | NO | - | percent_off, amount_off, free_item |
| `discount_value` | numeric(10,2) | YES | - | Discount amount |
| `free_item_dish_id` | bigint | YES | - | FK to dishes (free item) |
| `description` | varchar(255) | YES | - | Tier description |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

---

#### `promotion_redemptions`
**Purpose:** Campaign redemption tracking  
**Row Count:** 0

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | YES | gen_random_uuid() | External identifier |
| `campaign_id` | bigint | NO | - | FK to promotion_campaigns |
| `promotion_code_id` | bigint | YES | - | FK to promotion_codes |
| `order_id` | bigint | YES | - | FK to orders |
| `order_created_at` | timestamptz | YES | - | Order timestamp |
| `user_id` | bigint | YES | - | FK to users |
| `discount_type` | varchar(50) | NO | - | Type of discount |
| `discount_amount` | numeric(10,2) | NO | - | Amount discounted |
| `order_subtotal` | numeric(10,2) | YES | - | Order subtotal |
| `order_total` | numeric(10,2) | YES | - | Order total |
| `is_first_order` | boolean | YES | false | Customer's first order |
| `redemption_source` | varchar(50) | YES | - | web, app, pos |
| `redeemed_at` | timestamptz | YES | now() | Redemption timestamp |
| `session_id` | uuid | YES | - | Session identifier |
| `ip_address` | inet | YES | - | Client IP |
| `user_agent` | text | YES | - | Browser user agent |

---

#### `promotion_templates`
**Purpose:** Pre-built promotion configurations  
**Row Count:** 8

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `name` | varchar(255) | NO | - | Template name |
| `description` | text | YES | - | Description |
| `category` | varchar(50) | YES | - | Template category |
| `template_config` | jsonb | NO | - | Full configuration |
| `icon` | varchar(50) | YES | - | Icon identifier |
| `preview_image_url` | text | YES | - | Preview image |
| `popularity_score` | integer | YES | 0 | Usage popularity |
| `is_active` | boolean | YES | true | Template available |
| `display_order` | integer | YES | 0 | Sort order |
| `created_at` | timestamptz | YES | now() | Creation timestamp |

**Categories:** `new_customer`, `loyalty`, `seasonal`, `time_based`, `bundle`, `flash_sale`, `referral`, `event`

---

### Marketing Tags Tables

#### `marketing_tags`
**Purpose:** Tags for restaurant categorization and discovery  
**Row Count:** 36

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | integer | NO | identity | Primary key |
| `name` | varchar(255) | NO | - | Tag name |
| `slug` | varchar(255) | NO | - | URL-friendly slug (UNIQUE) |
| `description` | text | YES | - | Tag description |
| `v1_tag_id` | integer | YES | - | Legacy V1 ID |
| `v2_tag_id` | integer | YES | - | Legacy V2 ID |
| `source_table` | varchar(50) | YES | - | Migration source |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | now() | Last update |

**Referenced by:** `restaurant_tag_associations`

---

### Translation Tables

#### `promotional_deals_translations`
**Purpose:** French translations for deals

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `deal_id` | integer | NO | FK to promotional_deals |
| `language_code` | varchar(2) | NO | 'fr' |
| `name` | varchar(255) | YES | Translated name |
| `description` | text | YES | Translated description |

---

#### `promotional_coupons_translations`
**Purpose:** French translations for coupons

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `coupon_id` | integer | NO | FK to promotional_coupons |
| `language_code` | varchar(2) | NO | 'fr' |
| `name` | varchar(125) | YES | Translated name |
| `description` | text | YES | Translated description |

---

#### `marketing_tags_translations`
**Purpose:** French translations for marketing tags

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `tag_id` | integer | NO | FK to marketing_tags |
| `language_code` | varchar(2) | NO | 'fr' |
| `name` | varchar(255) | YES | Translated name |
| `description` | text | YES | Translated description |

---

## 👁️ Views

#### `active_promotional_coupons`
**Purpose:** Filters active, unused coupons

Returns all columns from `promotional_coupons` where `is_active = true` and `is_used = false`.

---

## 🔧 SQL Functions

### Coupon Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `validate_coupon` | code, restaurant_id, order_total | jsonb | Validate coupon eligibility |
| `apply_coupon_to_order` | coupon_id, order_id, user_id | jsonb | Apply coupon and log usage |
| `redeem_coupon` | coupon_id, order_id, user_id, amount | jsonb | Process redemption |
| `check_coupon_usage_limit` | coupon_id, user_id | boolean | Check if user can use coupon |
| `get_coupon_redemption_rate` | coupon_id | numeric | Calculate redemption rate |
| `get_coupon_with_translation` | coupon_id, lang | jsonb | Get coupon with i18n |
| `get_coupons_i18n` | restaurant_id, lang | TABLE | Get all coupons with translations |
| `soft_delete_coupon` | coupon_id | jsonb | Soft delete coupon |
| `restore_coupon` | coupon_id | jsonb | Restore deleted coupon |

### Deal Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get_active_deals` | restaurant_id | TABLE | Get currently active deals |
| `is_deal_active_now` | deal_id | boolean | Check if deal is currently active |
| `calculate_deal_discount` | deal_id, order_items | numeric | Calculate deal discount |
| `auto_apply_best_deal` | restaurant_id, order_items | jsonb | Auto-select best applicable deal |
| `validate_deal_eligibility` | deal_id, order_data | jsonb | Check if order qualifies |
| `get_deal_usage_stats` | deal_id | jsonb | Get deal usage statistics |
| `get_popular_deals` | limit | TABLE | Get most popular deals |
| `get_deal_with_translation` | deal_id, lang | jsonb | Get deal with i18n |
| `get_deals_i18n` | restaurant_id, lang | TABLE | Get all deals with translations |
| `clone_deal` | deal_id, new_restaurant_id | bigint | Clone deal to another restaurant |
| `soft_delete_deal` | deal_id | jsonb | Soft delete deal |
| `restore_deal` | deal_id | jsonb | Restore deleted deal |
| `toggle_deal_status` | deal_id, enabled | jsonb | Enable/disable deal |
| `bulk_enable_deals` | deal_ids[] | jsonb | Bulk enable deals |
| `bulk_disable_deals` | deal_ids[] | jsonb | Bulk disable deals |

### Campaign Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `get_promotion_analytics` | campaign_id | jsonb | Get campaign performance |
| `update_promotion_updated_at` | - | trigger | Auto-update timestamp |

### Marketing Tag Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `translate_marketing_tag` | tag_id, lang | jsonb | Get tag with translation |

---

## 📇 Indexes

### `promotional_deals` Table Indexes (9)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotional_deals_pkey` | `id` | PRIMARY KEY | - |
| `idx_deals_restaurant` | `restaurant_id` | BTREE | - |
| `idx_deals_active` | `restaurant_id, is_enabled, date_start, date_stop` | BTREE | - |
| `idx_deals_active_lookup` | `restaurant_id, is_enabled, date_start, date_stop, time_start, time_stop` | BTREE | `is_enabled = true` |
| `idx_promotional_deals_enabled` | `is_enabled` | BTREE | `is_enabled = true` |
| `idx_promotional_deals_promo_code` | `promo_code` | BTREE | `promo_code IS NOT NULL` |
| `idx_promotional_deals_updated_at` | `updated_at DESC` | BTREE | - |
| `idx_promotional_deals_v1_id` | `v1_deal_id` | BTREE | `v1_deal_id IS NOT NULL` |
| `idx_promotional_deals_v2_id` | `v2_deal_id` | BTREE | `v2_deal_id IS NOT NULL` |

### `promotional_coupons` Table Indexes (7)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotional_coupons_pkey` | `id` | PRIMARY KEY | - |
| `idx_coupons_restaurant` | `restaurant_id` | BTREE | - |
| `idx_coupons_code` | `code` | BTREE | `is_active = true` |
| `idx_promotional_coupons_active` | `is_active` | BTREE | `is_active = true` |
| `idx_promotional_coupons_deleted_at` | `deleted_at` | BTREE | `deleted_at IS NULL` |
| `idx_promotional_coupons_updated_at` | `updated_at DESC` | BTREE | - |
| `idx_promotional_coupons_v1_id` | `v1_coupon_id` | BTREE | `v1_coupon_id IS NOT NULL` |

### `promotion_campaigns` Table Indexes (7)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_campaigns_pkey` | `id` | PRIMARY KEY | - |
| `promotion_campaigns_uuid_key` | `uuid` | UNIQUE | - |
| `idx_promo_campaigns_restaurant` | `restaurant_id` | BTREE | - |
| `idx_promo_campaigns_status` | `status` | BTREE | - |
| `idx_promo_campaigns_type` | `campaign_type, trigger_type` | BTREE | - |
| `idx_promo_campaigns_dates` | `starts_at, ends_at` | BTREE | - |
| `idx_promo_campaigns_deleted` | `deleted_at` | BTREE | `deleted_at IS NULL` |

### `coupon_usage_log` Table Indexes (5)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `coupon_usage_log_pkey` | `id` | PRIMARY KEY | - |
| `coupon_usage_log_coupon_id_order_id_key` | `coupon_id, order_id` | UNIQUE | - |
| `idx_coupon_usage_coupon` | `coupon_id, used_at DESC` | BTREE | - |
| `idx_coupon_usage_user` | `user_id, used_at DESC` | BTREE | - |
| `idx_coupon_usage_order` | `order_id` | BTREE | `order_id IS NOT NULL` |

### `marketing_tags` Table Indexes (5)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `marketing_tags_pkey` | `id` | PRIMARY KEY | - |
| `marketing_tags_slug_key` | `slug` | UNIQUE | - |
| `idx_marketing_tags_slug` | `slug` | BTREE | - |
| `idx_marketing_tags_v1_id` | `v1_tag_id` | BTREE | `v1_tag_id IS NOT NULL` |
| `idx_marketing_tags_v2_id` | `v2_tag_id` | BTREE | `v2_tag_id IS NOT NULL` |

### `promotion_codes` Table Indexes (6)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_codes_pkey` | `id` | PRIMARY KEY | - |
| `promotion_codes_uuid_key` | `uuid` | UNIQUE | - |
| `promotion_codes_campaign_id_code_key` | `campaign_id, code` | UNIQUE | - |
| `idx_promo_codes_campaign` | `campaign_id` | BTREE | - |
| `idx_promo_codes_code` | `code` | BTREE | - |
| `idx_promo_codes_active` | `is_active` | BTREE | `is_active = true` |

### `promotion_redemptions` Table Indexes (6)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_redemptions_pkey` | `id` | PRIMARY KEY | - |
| `promotion_redemptions_uuid_key` | `uuid` | UNIQUE | - |
| `idx_promo_redemptions_campaign` | `campaign_id` | BTREE | - |
| `idx_promo_redemptions_user` | `user_id` | BTREE | - |
| `idx_promo_redemptions_order` | `order_id` | BTREE | - |
| `idx_promo_redemptions_date` | `redeemed_at` | BTREE | - |

### `promotion_targets` Table Indexes (4)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_targets_pkey` | `id` | PRIMARY KEY | - |
| `idx_promo_targets_campaign` | `campaign_id` | BTREE | - |
| `idx_promo_targets_course` | `course_id` | BTREE | `course_id IS NOT NULL` |
| `idx_promo_targets_dish` | `dish_id` | BTREE | `dish_id IS NOT NULL` |

### `promotion_tiers` Table Indexes (2)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_tiers_pkey` | `id` | PRIMARY KEY | - |
| `idx_promo_tiers_campaign` | `campaign_id` | BTREE | - |

### `promotion_templates` Table Indexes (1)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotion_templates_pkey` | `id` | PRIMARY KEY | - |

### Translation Table Indexes

#### `promotional_deals_translations` (4)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotional_deals_translations_pkey` | `id` | PRIMARY KEY | - |
| `unique_deal_translation` | `deal_id, language_code` | UNIQUE | - |
| `idx_deals_translations_lookup` | `deal_id, language_code` | BTREE | - |
| `idx_deals_translations_language` | `language_code` | BTREE | - |

#### `promotional_coupons_translations` (4)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `promotional_coupons_translations_pkey` | `id` | PRIMARY KEY | - |
| `unique_coupon_translation` | `coupon_id, language_code` | UNIQUE | - |
| `idx_coupons_translations_lookup` | `coupon_id, language_code` | BTREE | - |
| `idx_coupons_translations_language` | `language_code` | BTREE | - |

#### `marketing_tags_translations` (4)

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `marketing_tags_translations_pkey` | `id` | PRIMARY KEY | - |
| `unique_tag_translation` | `tag_id, language_code` | UNIQUE | - |
| `idx_tags_translations_lookup` | `tag_id, language_code` | BTREE | - |
| `idx_tags_translations_language` | `language_code` | BTREE | - |

---

## 🔒 RLS Policies

### `promotional_deals` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_view_active_deals` | SELECT | public | View active deals within date range |
| `deals_service_role_all` | ALL | service_role | Full access |

### `promotional_coupons` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_view_active_coupons` | SELECT | public | View active, unused coupons |
| `coupons_service_role_all` | ALL | service_role | Full access |

### `coupon_usage_log` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `usage_log_select_own_user` | SELECT | authenticated | User can view own usage |
| `system_insert_usage` | INSERT | service_role | System can log usage |

### `promotion_campaigns` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Service role full access to promotion_campaigns` | ALL | service_role | Full access |

### `promotion_codes` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Service role full access to promotion_codes` | ALL | service_role | Full access |

### `promotion_redemptions` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Service role full access to promotion_redemptions` | ALL | service_role | Full access |

### `promotion_targets` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Service role full access to promotion_targets` | ALL | service_role | Full access |

### `promotion_tiers` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `Service role full access to promotion_tiers` | ALL | service_role | Full access |

### `marketing_tags` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `public_read_tags` | SELECT | public | Public can read tags |
| `tags_service_role_all` | ALL | service_role | Full access |

### Translation Table Policies

| Table | Policy Name | Operation | Roles | Description |
|-------|-------------|-----------|-------|-------------|
| `promotional_deals_translations` | `public_read_deal_translations` | SELECT | public | Public can read translations |
| `promotional_coupons_translations` | `public_read_coupon_translations` | SELECT | public | Public can read translations |
| `marketing_tags_translations` | `public_read_tag_translations` | SELECT | public | Public can read translations |

---

## ⚙️ Triggers

| Trigger Name | Table | Event | Timing | Function | Description |
|--------------|-------|-------|--------|----------|-------------|
| `audit_promotional_deals_changes` | promotional_deals | INSERT, UPDATE, DELETE | AFTER | `audit_trigger_func()` | Audit trail |
| `audit_promotional_coupons_changes` | promotional_coupons | INSERT, UPDATE, DELETE | AFTER | `audit_trigger_func()` | Audit trail |
| `update_promotion_campaigns_updated_at` | promotion_campaigns | UPDATE | BEFORE | `update_promotion_updated_at()` | Auto-timestamp |
| `set_updated_at_deals_translations` | promotional_deals_translations | UPDATE | BEFORE | `set_updated_at()` | Auto-timestamp |
| `set_updated_at_coupons_translations` | promotional_coupons_translations | UPDATE | BEFORE | `set_updated_at()` | Auto-timestamp |
| `set_updated_at_tags_translations` | marketing_tags_translations | UPDATE | BEFORE | `set_updated_at()` | Auto-timestamp |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason | Migration Notes |
|------|--------------|--------|-----------------|
| - | - | None yet | - |

---

## ✨ New Functionalities

| Date | Functionality | Status | Notes |
|------|--------------|--------|-------|
| 2025-11 | V1/V2 Deal Migration | ✅ Complete | 53 deals migrated |
| 2025-11 | V1/V2 Coupon Migration | ✅ Complete | 456 coupons migrated |
| 2025-11 | Bilingual Translations | ✅ Complete | FR translations for deals/coupons/tags |
| 2025-12 | Campaign System | ✅ Ready | New promotion_campaigns architecture |
| 2025-12 | Promotion Templates | ✅ Ready | 8 pre-built templates |

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | Impact |
|------|-----------------|--------|
| 2026-01-23 | Documentation completely rewritten | All 14 tables now documented |
| 2026-01-23 | Added missing indexes for campaign tables | 23 additional indexes documented |
| 2026-01-23 | Added translation table indexes | 12 indexes documented |
| 2026-01-23 | Added translation table RLS policies | 3 policies documented |
| 2026-01-23 | Added translation table triggers | 3 triggers documented |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| **Tables** | 14 |
| **Views** | 1 |
| **SQL Functions** | 28 |
| **Indexes** | 64 |
| **RLS Policies** | 16 |
| **Triggers** | 6 |

### Data Counts

| Table | Rows |
|-------|------|
| `promotional_deals` | 53 |
| `promotional_coupons` | 456 |
| `coupon_usage_log` | 1 |
| `marketing_tags` | 36 |
| `promotion_templates` | 8 |
| `promotion_campaigns` | 0 |
| `promotion_codes` | 0 |
| `promotion_redemptions` | 0 |
| `promotion_targets` | 0 |
| `promotion_tiers` | 0 |

---

## 🔗 Related Entities

- **[01-restaurant-entity.md](./01-restaurant-entity.md)** - Restaurant profiles (FK from deals/coupons)
- **[04-order-management-entity.md](./04-order-management-entity.md)** - Orders (FK from redemptions)
- **[05-user-entity.md](./05-user-entity.md)** - Users (FK from usage logs)
- **[03-menu-management-entity.md](./03-menu-management-entity.md)** - Dishes/courses (FK from targets)

---

**Last Updated:** 2026-01-23
