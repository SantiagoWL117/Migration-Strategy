-- Marketing & Promotions: V3 Target Tables in Staging Schema
-- Phase 3: Create transformed/merged V3-ready tables
-- These tables will hold the final transformed data before production load

-- =======================
-- 1. Promotional Deals
-- =======================
DROP TABLE IF EXISTS staging.promotional_deals CASCADE;
CREATE TABLE staging.promotional_deals (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL, -- FK to menuca_v3.restaurants (resolve in Phase 4)
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
  deal_type VARCHAR(50) NOT NULL, -- 'percent', 'value', 'freeItem', etc.
  discount_percent NUMERIC(5,2),
  discount_amount NUMERIC(8,2),
  minimum_purchase NUMERIC(8,2),
  order_count_required INTEGER,
  
  -- Item Selection
  included_items JSONB, -- ["dish:230:modifier:4", "dish:125"]
  required_items JSONB,
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
  
  -- Legacy Fields (for reference/debugging)
  v1_deal_id INTEGER,
  v2_deal_id INTEGER,
  v1_meal_number INTEGER,
  v1_position VARCHAR(1),
  v1_is_global BOOLEAN,
  
  -- Source tracking
  source_table VARCHAR(20), -- 'v1_deals' or 'v2_restaurants_deals'
  
  -- Audit
  created_by INTEGER, -- FK to admin_users (resolve in Phase 4)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  disabled_by INTEGER,
  disabled_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_staging_promotional_deals_restaurant ON staging.promotional_deals(restaurant_id);
CREATE INDEX idx_staging_promotional_deals_promo_code ON staging.promotional_deals(promo_code) WHERE promo_code IS NOT NULL;
CREATE INDEX idx_staging_promotional_deals_enabled ON staging.promotional_deals(is_enabled);
CREATE INDEX idx_staging_promotional_deals_source ON staging.promotional_deals(source_table);

-- =======================
-- 2. Promotional Coupons
-- =======================
DROP TABLE IF EXISTS staging.promotional_coupons CASCADE;
CREATE TABLE staging.promotional_coupons (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL, -- FK to menuca_v3.restaurants
  
  -- Coupon Details
  name VARCHAR(125) NOT NULL,
  description TEXT,
  code VARCHAR(255) NOT NULL, -- Will be UNIQUE in production, but staging may have duplicates from V1/V2
  
  -- Validity Period
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  
  -- Discount Configuration
  discount_type VARCHAR(20) NOT NULL, -- 'percent', 'value', 'freeItem', 'delivery'
  discount_amount NUMERIC(8,2),
  minimum_purchase NUMERIC(8,2),
  
  -- Restrictions
  applies_to_items JSONB, -- Product/dish IDs
  item_count INTEGER,
  max_redemptions INTEGER DEFAULT 1,
  redeem_value_limit NUMERIC(8,2),
  
  -- Type & Usage
  coupon_scope VARCHAR(20) DEFAULT 'restaurant', -- 'restaurant', 'global'
  is_one_time_use BOOLEAN DEFAULT TRUE,
  is_reorder_coupon BOOLEAN DEFAULT FALSE,
  
  -- Email Marketing
  add_to_email BOOLEAN DEFAULT FALSE,
  email_text TEXT,
  
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_used BOOLEAN DEFAULT FALSE,
  language_code VARCHAR(2) DEFAULT 'en',
  
  -- Legacy
  v1_coupon_id INTEGER,
  v2_coupon_id INTEGER,
  source_table VARCHAR(20), -- 'v1_coupons' or 'v2_coupons'
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_staging_promotional_coupons_code ON staging.promotional_coupons(code);
CREATE INDEX idx_staging_promotional_coupons_restaurant ON staging.promotional_coupons(restaurant_id);
CREATE INDEX idx_staging_promotional_coupons_active ON staging.promotional_coupons(is_active);
CREATE INDEX idx_staging_promotional_coupons_source ON staging.promotional_coupons(source_table);

-- =======================
-- 3. Customer Coupons (User Coupon Assignments)
-- =======================
DROP TABLE IF EXISTS staging.customer_coupons CASCADE;
CREATE TABLE staging.customer_coupons (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL, -- FK to menuca_v3.customers
  coupon_id INTEGER, -- Will reference staging.promotional_coupons.id during migration
  
  -- Original coupon reference (before FK resolution)
  v1_coupon_id INTEGER, -- Original V1 coupons.id
  
  -- Usage Tracking
  added_at TIMESTAMPTZ DEFAULT NOW(),
  is_used BOOLEAN NOT NULL DEFAULT FALSE,
  used_at TIMESTAMPTZ,
  order_id INTEGER, -- FK to orders (resolve in Phase 4)
  
  -- Legacy
  v1_user_coupon_id INTEGER,
  
  -- Source tracking
  source_table VARCHAR(20) DEFAULT 'v1_user_coupons'
);

CREATE INDEX idx_staging_customer_coupons_customer ON staging.customer_coupons(customer_id);
CREATE INDEX idx_staging_customer_coupons_coupon ON staging.customer_coupons(coupon_id);

-- =======================
-- 4. Marketing Tags
-- =======================
DROP TABLE IF EXISTS staging.marketing_tags CASCADE;
CREATE TABLE staging.marketing_tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(125) NOT NULL,
  slug VARCHAR(125) NOT NULL,
  description TEXT,
  
  -- Legacy
  v1_tag_id INTEGER,
  v2_tag_id INTEGER,
  source_table VARCHAR(20), -- 'v1_tags' or 'v2_tags'
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_staging_marketing_tags_slug ON staging.marketing_tags(slug);
CREATE INDEX idx_staging_marketing_tags_source ON staging.marketing_tags(source_table);

-- =======================
-- 5. Restaurant Tag Associations
-- =======================
DROP TABLE IF EXISTS staging.restaurant_tag_associations CASCADE;
CREATE TABLE staging.restaurant_tag_associations (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL, -- FK to menuca_v3.restaurants
  tag_id INTEGER NOT NULL, -- Will reference staging.marketing_tags.id
  
  -- Original tag reference (before FK resolution)
  v2_tag_id INTEGER, -- Original V2 tags.id
  v2_restaurants_tags_id INTEGER, -- Original V2 restaurants_tags.id
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_staging_restaurant_tags_restaurant ON staging.restaurant_tag_associations(restaurant_id);
CREATE INDEX idx_staging_restaurant_tags_tag ON staging.restaurant_tag_associations(tag_id);

-- =======================
-- 6. Landing Pages
-- =======================
DROP TABLE IF EXISTS staging.landing_pages CASCADE;
CREATE TABLE staging.landing_pages (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  domain VARCHAR(255) NOT NULL,
  logo_url VARCHAR(255),
  background_url VARCHAR(255),
  coordinates JSONB,
  settings JSONB,
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Legacy
  v2_landing_page_id INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =======================
-- 7. Landing Page Restaurants
-- =======================
DROP TABLE IF EXISTS staging.landing_page_restaurants CASCADE;
CREATE TABLE staging.landing_page_restaurants (
  id SERIAL PRIMARY KEY,
  landing_page_id INTEGER NOT NULL, -- Will reference staging.landing_pages.id
  restaurant_id INTEGER NOT NULL, -- FK to menuca_v3.restaurants
  display_order INTEGER,
  
  -- Original references
  v2_landing_pages_restaurants_id INTEGER,
  
  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_staging_landing_page_restaurants_page ON staging.landing_page_restaurants(landing_page_id);
CREATE INDEX idx_staging_landing_page_restaurants_restaurant ON staging.landing_page_restaurants(restaurant_id);

-- =======================
-- Summary
-- =======================
-- Tables created:
-- 1. staging.promotional_deals (V1 deals + V2 restaurants_deals merged)
-- 2. staging.promotional_coupons (V1 coupons + V2 coupons merged)
-- 3. staging.customer_coupons (V1 user_coupons)
-- 4. staging.marketing_tags (V1 tags + V2 tags merged)
-- 5. staging.restaurant_tag_associations (V2 restaurants_tags)
-- 6. staging.landing_pages (V2 landing_pages)
-- 7. staging.landing_page_restaurants (V2 landing_pages_restaurants)

-- Next Phase: Transform and load data from raw staging tables (v1_*, v2_*) into these V3 tables

