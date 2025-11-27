# Marketing & Promotions Entity - Field Mapping & Analysis

**Migration Strategy:** menuca_v1 + menuca_v2 → menuca_v3  
**Entity:** Marketing & Promotions  
**Phase:** 1 - Analysis & Mapping  
**Date:** 2025-10-07  
**Status:** 🔍 PHASE 1 - SCHEMA ANALYSIS COMPLETE

---

## 📋 Executive Summary

### Scope
Marketing & Promotions covers customer-facing promotional tools including deals, coupons, landing pages, navigation, tags, and vendor management (excluding financial/reporting aspects which belong to Accounting entity).

### Key Findings
- **BLOB Deserialization Required:** 3 V1 tables need PHP deserialization (`deals.exceptions`, `vendors.*`)
- **JSON Migration:** V2 `restaurants_deals` uses modern JSON (easy migration)
- **Non-Marketing Tables Identified:** `tablets`, `ci_sessions`, `vendor_users`, `vendors_restaurants` belong to other entities
- **Focus Tables:** Deals, Coupons, Tags, Landing Pages, Navigation

---

## 🎯 Tables In Scope

### Priority 1: Core Marketing Tables
| V1 Table | V2 Table | V3 Target | Rows (Est.) | Migration Priority |
|----------|----------|-----------|-------------|-------------------|
| `deals` | `restaurants_deals` | `promotional_deals` | ~300 | HIGH |
| `coupons` | `coupons` | `promotional_coupons` | ~1,300 | HIGH |
| `user_coupons` | - | `customer_coupons` | ~10 | MEDIUM |
| - | `restaurants_deals_splits` | (analyze - 1 row) | 1 | LOW |

### Priority 2: Navigation & Organization
| V1 Table | V2 Table | V3 Target | Rows (Est.) | Migration Priority |
|----------|----------|-----------|-------------|-------------------|
| `tags` | `tags`, `restaurants_tags` | `marketing_tags`, `restaurant_tag_associations` | ~50, varies | MEDIUM |
| - | `landing_pages`, `landing_pages_restaurants` | `landing_pages`, `landing_page_restaurants` | ~3, ~250 | LOW |
| - | `nav`, `nav_subitems` | `admin_navigation` | ~25, ~40 | LOW |
| - | `permissions_list` | `admin_permissions` | ~67 | LOW |

### ❌ Tables EXCLUDED (Other Entities)
| Table | Reason | Belongs To |
|-------|--------|------------|
| `tablets` (V1 & V2) | Device management | **Devices & Infrastructure** |
| `ci_sessions` (V1 & V2) | Session management | **Users & Access** |
| `vendors` | Franchise/vendor management | **Vendors & Franchises** |
| `vendor_users` | Vendor staff | **Vendors & Franchises** |
| `vendors_restaurants` | Vendor relationships | **Vendors & Franchises** |
| `vendor_reports` | Financial reporting | **Accounting & Reporting** |
| `autoresponders` | Email automation | (Deprecated - V1 only) |
| `banners` | (Not found in dumps) | (Deprecated) |
| `redirects` | (Not found in dumps) | (Deprecated) |

---

## 📊 Table 1: Deals / Promotional Deals

### V1 Schema: `menuca_v1.deals`
**Location:** `/Database/Schemas/menuca_v1_structure.sql:560-587`
```sql
CREATE TABLE `deals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL DEFAULT '0',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `type` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `removeValue` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ammountSpent` int NOT NULL,
  `dealPrice` float NOT NULL,
  `orderTimes` int NOT NULL,
  `active_days` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `active_dates` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `items` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `mealNo` int unsigned NOT NULL DEFAULT '0',
  `position` char(1) DEFAULT NULL,
  `order` int NOT NULL,
  `lang` enum('en','fr') NOT NULL DEFAULT 'en',
  `image` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `display` int unsigned NOT NULL,
  `showOnThankyou` enum('0','1') NOT NULL DEFAULT '0',
  `isGlobal` enum('0','1') NOT NULL DEFAULT '0',
  `active` enum('y','n') NOT NULL DEFAULT 'y',
  `exceptions` blob NOT NULL, -- ⚠️ BLOB DESERIALIZATION REQUIRED
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=265;
```

**V1 BLOB Analysis:**
- **Field:** `exceptions`
- **Format:** PHP serialized array
- **Example:** `a:1:{i:0;s:3:"884";}` = array of course/dish IDs to exclude
- **Sample Data:** Lines 60 of `/Database/Marketing & Promotions/dumps/menuca_v1_deals.sql`
  - Deal ID 22: `a:1:{i:0;s:4:"5728";}` - Single exception
  - Deal ID 31: `a:1:{i:0;s:3:"884";}` - Single exception
  - Deal ID 90: `a:2:{i:0;s:3:"976";i:1;s:3:"975";}` - Multiple exceptions

**V1 Additional Fields (PHP Serialized Text):**
- **`active_days`:** PHP serialized day of week array
  - Example: `a:7:{i:0;s:1:"1";i:1;s:1:"2";...i:6;s:1:"7";}` = All 7 days
- **`active_dates`:** Comma-separated date strings
  - Example: `10/17,10/19,10/25,10/27,...`
- **`items`:** PHP serialized item array
  - Example: `a:1:{i:0;s:4:"5728";}` = dish ID 5728

### V2 Schema: `menuca_v2.restaurants_deals`
**Location:** `/Database/Schemas/menuca_v2_structure.sql:1353-1404`
```sql
CREATE TABLE `restaurants_deals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `type` enum('r','a') DEFAULT NULL COMMENT 'r - restaurant, a - aggregator',
  `repeatable` enum('y','n') DEFAULT 'n' COMMENT 'can deal be taken multiple times',
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `days` json DEFAULT NULL,  -- ✅ Modern JSON
  `date_start` date DEFAULT NULL,
  `date_stop` date DEFAULT NULL,
  `time_start` time DEFAULT NULL,
  `time_stop` time DEFAULT NULL,
  `deal_type` varchar(25) DEFAULT NULL,
  `remove` float DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `times` tinyint DEFAULT NULL,
  `item` json DEFAULT NULL,  -- ✅ Modern JSON
  `item_buy` json DEFAULT NULL COMMENT 'items to buy to qualify for the deal',  -- ✅ Modern JSON
  `item_count_buy` tinyint DEFAULT NULL,
  `item_count` tinyint DEFAULT NULL,
  `image` varchar(45) DEFAULT NULL,
  `promo_code` varchar(125) DEFAULT NULL,
  `customize` enum('y','n') DEFAULT 'n',
  `dates` json DEFAULT NULL,  -- ✅ Modern JSON
  `extempted_courses` json DEFAULT NULL,  -- ✅ Modern JSON (typo: should be "exempted")
  `available` json DEFAULT NULL COMMENT 'when deal is available - takeout, delivery',  -- ✅ Modern JSON
  `split_deal` enum('y','n') DEFAULT 'n',
  `first_order` enum('y','n') DEFAULT 'n' COMMENT 'coupon / deal available on first order only',
  `mailCoupon` enum('y','n') DEFAULT 'n' COMMENT 'send this coupon to accept order email',
  `mailBody` text,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40;
```

**V2 JSON Fields (Native MySQL JSON):**
- **`days`:** `["mon", "tue", "wed", "thu", "fri", "sat", "sun"]`
- **`dates`:** `["2017-06-21", "2017-06-19"]` - Specific dates
- **`item`:** `["230|4", "125", "126", "122|s"]` - Item IDs with optional modifiers
- **`item_buy`:** `["125", "126"]` - Items needed to qualify
- **`extempted_courses`:** `["102", "126", "127"]` - Course IDs to exclude (note typo)
- **`available`:** `["t", "d"]` - Availability types (t=takeout, d=delivery)

### V3 Target: `menuca_v3.promotional_deals`
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.promotional_deals (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL DEFAULT 'restaurant', -- 'restaurant', 'aggregator'
  is_repeatable BOOLEAN NOT NULL DEFAULT FALSE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Schedule
  active_days JSONB, -- ["mon", "tue", "wed", ...]
  date_start DATE,
  date_stop DATE,
  time_start TIME,
  time_stop TIME,
  specific_dates JSONB, -- ["2024-06-21", "2024-06-19"]
  
  -- Deal Configuration
  deal_type VARCHAR(50) NOT NULL, -- 'percent', 'value', 'freeItem', 'percentTotal', 'timesOrder', etc.
  discount_percent NUMERIC(5,2),
  discount_amount NUMERIC(8,2),
  minimum_purchase NUMERIC(8,2),
  order_count_required INTEGER, -- For "order X times" deals
  
  -- Item Selection
  included_items JSONB, -- ["dish:230:modifier:4", "dish:125"]
  required_items JSONB, -- Items needed to qualify
  required_item_count INTEGER,
  free_item_count INTEGER,
  exempted_courses JSONB, -- Course IDs excluded from deal
  
  -- Availability & Display
  availability_types JSONB, -- ["takeout", "delivery"]
  image_url VARCHAR(255),
  promo_code VARCHAR(125),
  display_order INTEGER,
  is_customizable BOOLEAN DEFAULT FALSE,
  is_split_deal BOOLEAN DEFAULT FALSE,
  first_order_only BOOLEAN DEFAULT FALSE,
  show_on_thankyou BOOLEAN DEFAULT FALSE,
  
  -- Email Marketing
  send_in_email BOOLEAN DEFAULT FALSE,
  email_body_html TEXT,
  
  -- Status & Audit
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  language_code VARCHAR(2) DEFAULT 'en',
  
  -- V1 Legacy Fields
  v1_deal_id INTEGER,
  v1_meal_number INTEGER,
  v1_position VARCHAR(1),
  v1_is_global BOOLEAN,
  
  -- Audit
  created_by INTEGER REFERENCES menuca_v3.admin_users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  disabled_by INTEGER REFERENCES menuca_v3.admin_users(id),
  disabled_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_promotional_deals_restaurant ON menuca_v3.promotional_deals(restaurant_id);
CREATE INDEX idx_promotional_deals_promo_code ON menuca_v3.promotional_deals(promo_code) WHERE promo_code IS NOT NULL;
CREATE INDEX idx_promotional_deals_enabled ON menuca_v3.promotional_deals(is_enabled) WHERE is_enabled = TRUE;
CREATE INDEX idx_promotional_deals_dates ON menuca_v3.promotional_deals(date_start, date_stop);
```

### Field Mapping: Deals

| V1 Field | V2 Field | V3 Field | Transform | Notes |
|----------|----------|----------|-----------|-------|
| `id` | `id` | `v1_deal_id` / `id` | New SERIAL | V1/V2 IDs stored as legacy reference |
| `restaurant` | `restaurant_id` | `restaurant_id` | FK Lookup | V1/V2 ID → V3 restaurants.id |
| - | `type` | `type` | Map: r→restaurant, a→aggregator | V2 only |
| - | `repeatable` | `is_repeatable` | Map: y→TRUE, n→FALSE | V2 only |
| `name` | `name` | `name` | Direct | - |
| `description` | `description` | `description` | Direct | - |
| `active_days` | `days` | `active_days` | **PHP Deserialize** (V1) → JSONB | V1: `a:7:{...}`, V2: `["mon", "tue"]` |
| `active_dates` | `dates` | `specific_dates` | **Parse CSV** (V1) → JSONB | V1: `"10/17,10/19"`, V2: `["2017-06-21"]` |
| - | `date_start` | `date_start` | Direct | V2 only |
| - | `date_stop` | `date_stop` | Direct | V2 only |
| - | `time_start` | `time_start` | Direct | V2 only |
| - | `time_stop` | `time_stop` | Direct | V2 only |
| `type` | `deal_type` | `deal_type` | Direct | Deal type string |
| `removeValue` | `remove` | `discount_percent` | Parse | V1: varchar, V2: float |
| `ammountSpent` | `amount` | `minimum_purchase` | Direct | Minimum spend |
| `dealPrice` | - | `discount_amount` | Direct | V1 only - fixed price deals |
| `orderTimes` | `times` | `order_count_required` | Direct | Order X times for reward |
| `items` | `item` | `included_items` | **PHP Deserialize** (V1) → JSONB | V1: `a:1:{i:0;s:4:"5728";}`, V2: `["230|4"]` |
| - | `item_buy` | `required_items` | Direct JSONB | V2 only |
| - | `item_count_buy` | `required_item_count` | Direct | V2 only |
| `mealNo` | `item_count` | `free_item_count` | Direct | V1: mealNo, V2: item_count |
| `exceptions` | `extempted_courses` | `exempted_courses` | **PHP Deserialize** (V1) → JSONB | V1: BLOB, V2: JSON |
| - | `available` | `availability_types` | Map: t→takeout, d→delivery | V2 only |
| `image` | `image` | `image_url` | Direct | - |
| - | `promo_code` | `promo_code` | Direct | V2 only |
| `position` | - | `v1_position` | Legacy only | V1 only: 'l' or 'b' |
| `order` | - | `display_order` | Direct | V1: order, V2: inferred |
| `lang` | - | `language_code` | Direct | V1 only |
| `display` | - | `display_order` | Direct | V1 only |
| `showOnThankyou` | - | `show_on_thankyou` | Map: 0→FALSE, 1→TRUE | V1 only |
| `isGlobal` | - | `v1_is_global` | Map: 0→FALSE, 1→TRUE | V1 only, legacy |
| `active` | `enabled` | `is_enabled` | Map: y→TRUE, n→FALSE | - |
| - | `customize` | `is_customizable` | Map: y→TRUE, n→FALSE | V2 only |
| - | `split_deal` | `is_split_deal` | Map: y→TRUE, n→FALSE | V2 only |
| - | `first_order` | `first_order_only` | Map: y→TRUE, n→FALSE | V2 only |
| - | `mailCoupon` | `send_in_email` | Map: y→TRUE, n→FALSE | V2 only |
| - | `mailBody` | `email_body_html` | Direct | V2 only |
| - | `added_by` | `created_by` | FK Lookup | V2: admin_users.id |
| - | `added_at` | `created_at` | Direct | V2 only |
| - | `disabled_by` | `disabled_by` | FK Lookup | V2 only |
| - | `disabled_at` | `disabled_at` | Direct | V2 only |

---

## 📊 Table 2: Coupons

### V1 Schema: `menuca_v1.coupons`
**Location:** `/Database/Schemas/menuca_v1_structure.sql:472-495`
```sql
CREATE TABLE `coupons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `start` int unsigned NOT NULL DEFAULT '0',
  `stop` int unsigned NOT NULL DEFAULT '0',
  `reduceType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `product` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `ammount` float NOT NULL DEFAULT '0',
  `couponType` enum('r','g') NOT NULL DEFAULT 'r',
  `redeem` float NOT NULL DEFAULT '0',
  `active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `itemCount` int unsigned NOT NULL DEFAULT '0',
  `lang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `for_reorder` enum('1','0') DEFAULT '0' COMMENT 'used to determine which coupons are sent in mail, from autoresponders',
  `one_time_only` enum('y','n') DEFAULT 'n',
  `used` enum('y','n') DEFAULT 'n',
  `addToMail` enum('y','n') DEFAULT 'n',
  `mailText` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1283;
```

### V2 Schema: `menuca_v2.coupons`
**Location:** `/Database/Schemas/menuca_v2_structure.sql:319-337`
```sql
CREATE TABLE `coupons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `start` int unsigned NOT NULL DEFAULT '0',
  `stop` int unsigned NOT NULL DEFAULT '0',
  `reduceType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `product` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `ammount` float NOT NULL DEFAULT '0',
  `couponType` enum('r','g') NOT NULL DEFAULT 'r',
  `redeem` float NOT NULL DEFAULT '0',
  `active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `itemCount` int unsigned NOT NULL DEFAULT '0',
  `lang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
```

**Note:** V2 `coupons` table is identical to V1 but missing the email-related fields (`for_reorder`, `one_time_only`, `used`, `addToMail`, `mailText`). V2 deals table absorbed coupon functionality with `promo_code` field.

### V3 Target: `menuca_v3.promotional_coupons`
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.promotional_coupons (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  
  -- Coupon Details
  name VARCHAR(125) NOT NULL,
  description TEXT,
  code VARCHAR(255) NOT NULL UNIQUE,
  
  -- Validity Period
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  
  -- Discount Configuration
  discount_type VARCHAR(20) NOT NULL, -- 'percent', 'value', 'freeItem'
  discount_amount NUMERIC(8,2),
  minimum_purchase NUMERIC(8,2),
  
  -- Restrictions
  applies_to_items JSONB, -- Product/dish IDs
  item_count INTEGER,
  max_redemptions INTEGER DEFAULT 1,
  redeem_value_limit NUMERIC(8,2), -- Max value that can be redeemed
  
  -- Type & Usage
  coupon_scope VARCHAR(20) DEFAULT 'restaurant', -- 'restaurant', 'global'
  is_one_time_use BOOLEAN DEFAULT TRUE,
  is_reorder_coupon BOOLEAN DEFAULT FALSE, -- Send in repeat order emails
  
  -- Email Marketing
  add_to_email BOOLEAN DEFAULT FALSE,
  email_text TEXT,
  
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_used BOOLEAN DEFAULT FALSE, -- If one-time coupon
  language_code VARCHAR(2) DEFAULT 'en',
  
  -- Legacy
  v1_coupon_id INTEGER,
  v2_coupon_id INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_promotional_coupons_code ON menuca_v3.promotional_coupons(code);
CREATE INDEX idx_promotional_coupons_restaurant ON menuca_v3.promotional_coupons(restaurant_id);
CREATE INDEX idx_promotional_coupons_active ON menuca_v3.promotional_coupons(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_promotional_coupons_validity ON menuca_v3.promotional_coupons(valid_from, valid_until);
```

### Field Mapping: Coupons

| V1/V2 Field | V3 Field | Transform | Notes |
|-------------|----------|-----------|-------|
| `id` | `v1_coupon_id` / `v2_coupon_id` | Legacy reference | Separate fields for V1/V2 |
| `name` | `name` | Direct | - |
| `description` | `description` | Direct | - |
| `code` | `code` | Direct, UNIQUE | Coupon redemption code |
| `start` | `valid_from` | Unix timestamp → TIMESTAMPTZ | - |
| `stop` | `valid_until` | Unix timestamp → TIMESTAMPTZ | - |
| `reduceType` | `discount_type` | Direct | - |
| `restaurant` | `restaurant_id` | FK Lookup | V1/V2 ID → V3 restaurants.id |
| `product` | `applies_to_items` | Parse text → JSONB array | - |
| `ammount` | `discount_amount` | Direct | V1 typo: "ammount" |
| `couponType` | `coupon_scope` | Map: r→restaurant, g→global | - |
| `redeem` | `redeem_value_limit` | Direct | Max redeemable value |
| `active` | `is_active` | Map: Y→TRUE, N→FALSE | - |
| `itemCount` | `item_count` | Direct | - |
| `lang` | `language_code` | Direct | - |
| `for_reorder` | `is_reorder_coupon` | Map: 1→TRUE, 0→FALSE | V1 only |
| `one_time_only` | `is_one_time_use` | Map: y→TRUE, n→FALSE | V1 only |
| `used` | `is_used` | Map: y→TRUE, n→FALSE | V1 only |
| `addToMail` | `add_to_email` | Map: y→TRUE, n→FALSE | V1 only |
| `mailText` | `email_text` | Direct | V1 only |

---

## 📊 Table 3: User Coupons (Customer Coupon Usage)

### V1 Schema: `menuca_v1.user_coupons`
**Location:** `/Database/Schemas/menuca_v1_structure.sql:2213-2222`
```sql
CREATE TABLE `user_coupons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `owner` int unsigned NOT NULL DEFAULT '0',
  `dateAdded` int unsigned NOT NULL DEFAULT '0',
  `used` enum('Y','N') NOT NULL DEFAULT 'N',
  `dateUsed` int unsigned NOT NULL DEFAULT '0',
  `coupon` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10;
```

### V3 Target: `menuca_v3.customer_coupons`
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.customer_coupons (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES menuca_v3.customers(id) ON DELETE CASCADE,
  coupon_id INTEGER NOT NULL REFERENCES menuca_v3.promotional_coupons(id) ON DELETE CASCADE,
  
  -- Usage Tracking
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_used BOOLEAN NOT NULL DEFAULT FALSE,
  used_at TIMESTAMPTZ,
  order_id INTEGER REFERENCES menuca_v3.orders(id),
  
  -- Legacy
  v1_user_coupon_id INTEGER,
  
  UNIQUE(customer_id, coupon_id)
);

CREATE INDEX idx_customer_coupons_customer ON menuca_v3.customer_coupons(customer_id);
CREATE INDEX idx_customer_coupons_coupon ON menuca_v3.customer_coupons(coupon_id);
CREATE INDEX idx_customer_coupons_unused ON menuca_v3.customer_coupons(customer_id) WHERE is_used = FALSE;
```

### Field Mapping: User Coupons

| V1 Field | V3 Field | Transform | Notes |
|----------|----------|-----------|-------|
| `id` | `v1_user_coupon_id` | Legacy reference | - |
| `owner` | `customer_id` | FK Lookup | V1 users.id → V3 customers.id |
| `coupon` | `coupon_id` | FK Lookup | V1 coupons.id → V3 promotional_coupons.id |
| `dateAdded` | `added_at` | Unix timestamp → TIMESTAMPTZ | - |
| `used` | `is_used` | Map: Y→TRUE, N→FALSE | - |
| `dateUsed` | `used_at` | Unix timestamp → TIMESTAMPTZ | - |

---

## 📊 Table 4: Tags

### V1 Schema: `menuca_v1.tags`
**Location:** `/Database/Schemas/menuca_v1_structure.sql:1954-1959`
```sql
CREATE TABLE `tags` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53;
```

### V2 Schemas
**`menuca_v2.tags`:**
```sql
CREATE TABLE `tags` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53;
```

**`menuca_v2.restaurants_tags`:**
```sql
CREATE TABLE `restaurants_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `tag_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=XX;
```

### V3 Target
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.marketing_tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(125) NOT NULL UNIQUE,
  slug VARCHAR(125) NOT NULL UNIQUE,
  description TEXT,
  
  -- Legacy
  v1_tag_id INTEGER,
  v2_tag_id INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_tag_associations (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES menuca_v3.marketing_tags(id) ON DELETE CASCADE,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(restaurant_id, tag_id)
);

CREATE INDEX idx_restaurant_tags_restaurant ON menuca_v3.restaurant_tag_associations(restaurant_id);
CREATE INDEX idx_restaurant_tags_tag ON menuca_v3.restaurant_tag_associations(tag_id);
```

### Field Mapping: Tags

| V1/V2 Field | V3 Field | Transform | Notes |
|-------------|----------|-----------|-------|
| `id` | `v1_tag_id` / `v2_tag_id` | Legacy reference | - |
| `name` | `name`, `slug` | Direct, generate slug | Slug: lowercase, hyphenated |

**Restaurant Tags:**
| V2 Field | V3 Field | Transform | Notes |
|----------|----------|-----------|-------|
| `id` | - | Not migrated | New serial ID |
| `restaurant_id` | `restaurant_id` | FK Lookup | V2 → V3 restaurants.id |
| `tag_id` | `tag_id` | FK Lookup | V2 tags.id → V3 marketing_tags.id |

---

## 📊 Table 5: Landing Pages (V2 Only)

### V2 Schemas
**`menuca_v2.landing_pages`:**
```sql
CREATE TABLE `landing_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL COMMENT 'internal name of the landing page',
  `domain` varchar(125) DEFAULT NULL COMMENT 'domain of the page',
  `logo` varchar(125) DEFAULT NULL,
  `background` varchar(125) DEFAULT NULL,
  `coords` json DEFAULT NULL,
  `settings` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3;
```

**`menuca_v2.landing_pages_restaurants`:**
```sql
CREATE TABLE `landing_pages_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `landing_page_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=254;
```

### V3 Target
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.landing_pages (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  domain VARCHAR(255) NOT NULL UNIQUE,
  logo_url VARCHAR(255),
  background_url VARCHAR(255),
  coordinates JSONB, -- Map coordinates config
  settings JSONB,
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Legacy
  v2_landing_page_id INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menuca_v3.landing_page_restaurants (
  id SERIAL PRIMARY KEY,
  landing_page_id INTEGER NOT NULL REFERENCES menuca_v3.landing_pages(id) ON DELETE CASCADE,
  restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  display_order INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(landing_page_id, restaurant_id)
);

CREATE INDEX idx_landing_page_restaurants_page ON menuca_v3.landing_page_restaurants(landing_page_id);
CREATE INDEX idx_landing_page_restaurants_restaurant ON menuca_v3.landing_page_restaurants(restaurant_id);
```

### Field Mapping: Landing Pages

**Main Table:**
| V2 Field | V3 Field | Transform | Notes |
|----------|----------|-----------|-------|
| `id` | `v2_landing_page_id` | Legacy reference | - |
| `name` | `name` | Direct | Internal name |
| `domain` | `domain` | Direct, UNIQUE | - |
| `logo` | `logo_url` | Direct | - |
| `background` | `background_url` | Direct | - |
| `coords` | `coordinates` | Direct JSONB | Native MySQL JSON |
| `settings` | `settings` | Direct JSONB | Native MySQL JSON |

**Association Table:**
| V2 Field | V3 Field | Transform | Notes |
|----------|----------|-----------|-------|
| `id` | - | Not migrated | New serial ID |
| `landing_page_id` | `landing_page_id` | FK Lookup | V2 → V3 landing_pages.id |
| `restaurant_id` | `restaurant_id` | FK Lookup | V2 → V3 restaurants.id |

---

## 📊 Table 6: Navigation & Permissions (V2 Only - Admin UI)

### V2 Schemas

**`menuca_v2.nav`:**
```sql
CREATE TABLE `nav` (
  `id` int NOT NULL AUTO_INCREMENT,
  `permission_required` json DEFAULT NULL,
  `groups_allowed` json DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `url` varchar(125) DEFAULT '/',
  `available_for` int DEFAULT NULL,
  `display_order` smallint DEFAULT NULL,
  `class` varchar(125) NOT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `available_for` (`available_for`)
) ENGINE=InnoDB AUTO_INCREMENT=25;
```

**`menuca_v2.nav_subitems`:**
```sql
CREATE TABLE `nav_subitems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `permission_required` tinyint DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `url` varchar(125) DEFAULT '/',
  `display_order` smallint DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40;
```

**`menuca_v2.permissions_list`:**
```sql
CREATE TABLE `permissions_list` (
  `id` int NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `keywords` json DEFAULT NULL,
  `subnav_item` smallint unsigned DEFAULT NULL,
  `display_order` smallint DEFAULT NULL,
  `uri` json DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67;
```

**Note:** These are admin interface configuration tables. Consider if they should be migrated to V3 or if V3 uses a different admin UI system (e.g., Next.js with RBAC).

### Migration Decision: 🤔 TO BE DETERMINED
- **Option 1:** Migrate to V3 for backward compatibility
- **Option 2:** Exclude - V3 uses modern frontend framework with different navigation system
- **Recommendation:** Exclude from migration; capture data for reference only

---

## 📊 Special Table: restaurants_deals_splits (V2 - 1 row)

### V2 Schema
```sql
CREATE TABLE `restaurants_deals_splits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `content` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2;
```

**Analysis:** Only 1 row exists. Likely experimental or restaurant-specific split-test configuration. 

**Migration Decision:** 🔍 **ANALYZE DATA FIRST**
- If contains active configuration → Migrate or document
- If deprecated/test data → Exclude

---

## 🧪 BLOB Deserialization Requirements

### Summary Table

| Table | Field | Format | Deserialize Method | Complexity |
|-------|-------|--------|-------------------|------------|
| `menuca_v1.deals` | `exceptions` | PHP serialized array | Python `phpserialize` | 🟢 LOW |
| `menuca_v1.deals` | `active_days` | PHP serialized array | Python `phpserialize` | 🟢 LOW |
| `menuca_v1.deals` | `items` | PHP serialized array | Python `phpserialize` | 🟢 LOW |
| `menuca_v1.vendors` | `restaurants` | PHP serialized array | Python `phpserialize` | 🟡 MEDIUM |
| `menuca_v1.vendors` | `phone` | PHP serialized array | Python `phpserialize` | 🟡 MEDIUM |
| `menuca_v1.vendors` | `website` | PHP serialized array | Python `phpserialize` | 🟡 MEDIUM |
| `menuca_v1.vendors` | `contacts` | PHP serialized array | Python `phpserialize` | 🟡 MEDIUM |

**Note:** `tablets.key` is VARBINARY (binary encryption keys) - NOT for deserialization, migrate as binary if needed (but belongs to Devices entity).

### Deserialization Strategy
Following proven pattern from Menu & Catalog entity:
1. Export V1 tables to CSV
2. Python script with `phpserialize` library
3. Convert PHP arrays → JSON
4. Load JSON into PostgreSQL JSONB columns
5. Verification: Compare row counts, sample random records

**Success Rate Target:** 98%+ (based on Menu entity experience)

---

## 📦 Data Quality Checks

### Required Validations

**Deals:**
- [ ] All `restaurant` IDs exist in V3 `restaurants` table
- [ ] PHP BLOB deserialization success rate > 98%
- [ ] V1 `active_days` arrays contain valid day numbers (1-7)
- [ ] V2 `days` JSON contains valid day names
- [ ] `deal_type` values are recognized types
- [ ] `image` URLs are valid (if not NULL)
- [ ] Date ranges are logical (start < stop)

**Coupons:**
- [ ] All `restaurant` IDs exist in V3 `restaurants` table
- [ ] `code` values are unique across all coupons
- [ ] Unix timestamps are valid (not 0 for active coupons)
- [ ] `discount_type` values are recognized types

**Tags:**
- [ ] No duplicate tag names
- [ ] All `restaurant_id` references valid in V2 `restaurants_tags`

**Landing Pages:**
- [ ] Domain names are unique
- [ ] JSON fields are valid JSON
- [ ] All `restaurant_id` references exist

---

## 🚨 Data Issues & Edge Cases

### Known Issues

1. **V1 Deals - Active Days Format:**
   - V1 uses PHP array: `a:7:{i:0;s:1:"1";...}`
   - Represents days as numbers 1-7 (Mon-Sun)
   - Need mapping: 1→mon, 2→tue, ..., 7→sun

2. **V1 Deals - Active Dates Format:**
   - CSV string: `"10/17,10/19,10/25"`
   - No year specified (assumes current/next year)
   - Need date parsing logic

3. **V2 Deals - Typo in Field Name:**
   - `extempted_courses` should be `exempted_courses`
   - Migrate with correct spelling

4. **Coupon Type Ambiguity:**
   - V1/V2 have separate `coupons` table
   - V2 `restaurants_deals` absorbed coupon functionality via `promo_code`
   - Decision: Migrate both, but V2 deals with promo codes might duplicate

5. **Vendor Tables:**
   - User indicated vendors belong to "Vendors & Franchises" entity
   - Exclude from Marketing migration
   - Document exclusion reason

---

## 📋 Migration Execution Order

### Phase 1: Schema & Dependencies ✅ (Current)
- [x] Analyze V1/V2 schemas
- [x] Design V3 schema
- [x] Create field mappings
- [x] Identify BLOB fields
- [ ] Review with stakeholders

### Phase 2: Data Extraction (Next)
User will provide:
- [ ] CSV exports from V1 tables (deals, coupons, user_coupons, tags)
- [ ] CSV exports from V2 tables (restaurants_deals, coupons, tags, restaurants_tags, landing_pages, landing_pages_restaurants)
- [ ] Analysis of `restaurants_deals_splits` single row

### Phase 3: BLOB Deserialization
- [ ] Create Python deserialization scripts for V1 deals BLOBs
- [ ] Test on sample data (10 rows)
- [ ] Run full deserialization
- [ ] Verify success rate > 98%

### Phase 4: Transformation & Load
- [ ] Create staging tables in `staging` schema
- [ ] Load CSV data
- [ ] Transform V1/V2 data to V3 format
- [ ] FK resolution (restaurants, admin_users)
- [ ] Upsert to V3 tables with ON CONFLICT handling

### Phase 5: Verification
- [ ] Row count validation
- [ ] FK integrity checks
- [ ] Sample data review
- [ ] Duplicate detection
- [ ] NULL value checks for required fields

---

## 📊 Estimated Data Volumes

| Entity | V1 Rows | V2 Rows | V3 Target Rows | Priority |
|--------|---------|---------|---------------|----------|
| Deals | ~265 | ~40 | ~300 | HIGH |
| Coupons | ~1,283 | ~0 (V2 structure changed) | ~1,300 | HIGH |
| User Coupons | ~10 | - | ~10 | MEDIUM |
| Tags | ~53 | ~53 | ~53 | MEDIUM |
| Restaurant Tags | - | ~varies | ~varies | MEDIUM |
| Landing Pages | - | ~3 | ~3 | LOW |
| Landing Page Restaurants | - | ~254 | ~254 | LOW |

**Total Estimated Rows:** ~2,200

---

## ✅ Phase 1 Completion Checklist

- [x] All V1 tables identified and categorized
- [x] All V2 tables identified and categorized
- [x] Tables excluded from scope documented with reasons
- [x] V3 schema designed for all target tables
- [x] Field mappings completed for all tables
- [x] BLOB columns identified (3 fields in 1 table)
- [x] JSON fields catalogued (V2 deals - 6 JSON fields)
- [x] Data quality checks defined
- [x] Known issues documented
- [x] Migration execution order planned
- [ ] **PENDING:** Stakeholder review and approval
- [ ] **PENDING:** Santiago to provide CSV exports

---

## 📝 Notes for Phase 2

**Data Needed from Santiago:**

### V1 CSV Exports:
```sql
-- menuca_v1.deals
SELECT * FROM menuca_v1.deals ORDER BY id;

-- menuca_v1.coupons
SELECT * FROM menuca_v1.coupons ORDER BY id;

-- menuca_v1.user_coupons
SELECT * FROM menuca_v1.user_coupons ORDER BY id;

-- menuca_v1.tags
SELECT * FROM menuca_v1.tags ORDER BY id;
```

### V2 CSV Exports:
```sql
-- menuca_v2.restaurants_deals
SELECT * FROM menuca_v2.restaurants_deals ORDER BY id;

-- menuca_v2.coupons (if exists)
SELECT * FROM menuca_v2.coupons ORDER BY id;

-- menuca_v2.tags
SELECT * FROM menuca_v2.tags ORDER BY id;

-- menuca_v2.restaurants_tags
SELECT * FROM menuca_v2.restaurants_tags ORDER BY id;

-- menuca_v2.landing_pages
SELECT * FROM menuca_v2.landing_pages ORDER BY id;

-- menuca_v2.landing_pages_restaurants
SELECT * FROM menuca_v2.landing_pages_restaurants ORDER BY id;

-- menuca_v2.restaurants_deals_splits (ANALYZE THIS)
SELECT * FROM menuca_v2.restaurants_deals_splits;
```

---

**Phase 1 Status:** ✅ **COMPLETE - Ready for Review**
**Next Step:** User review → Phase 2 CSV extraction
**Estimated Phase 2-5 Duration:** 4-6 days (based on Menu entity experience)
