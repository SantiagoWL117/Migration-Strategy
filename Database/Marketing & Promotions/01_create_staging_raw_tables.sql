-- ============================================================================
-- MARKETING & PROMOTIONS - STAGING TABLES FOR RAW DUMPS
-- ============================================================================
-- Purpose: Create staging tables matching exact V1/V2 structure to load dumps
-- Phase: 2 - Extract & Load Raw Data
-- Schema: staging
-- Date: 2025-10-07
-- ============================================================================

-- Ensure staging schema exists
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- PRIORITY 1: CORE MARKETING TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- V1 Deals (with BLOBs for deserialization)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v1_deals CASCADE;
CREATE TABLE staging.v1_deals (
  id INTEGER PRIMARY KEY,
  restaurant INTEGER NOT NULL,
  name VARCHAR(50),
  description TEXT,
  type VARCHAR(35),
  removeValue VARCHAR(20),
  ammountSpent INTEGER NOT NULL,
  dealPrice FLOAT NOT NULL,
  orderTimes INTEGER NOT NULL,
  active_days VARCHAR(255), -- PHP serialized
  active_dates TEXT, -- CSV dates
  items TEXT, -- PHP serialized
  mealNo INTEGER NOT NULL,
  position CHAR(1),
  "order" INTEGER NOT NULL,
  lang VARCHAR(2) NOT NULL DEFAULT 'en',
  image VARCHAR(45),
  display INTEGER NOT NULL,
  showOnThankyou VARCHAR(1) NOT NULL DEFAULT '0',
  isGlobal VARCHAR(1) NOT NULL DEFAULT '0',
  active VARCHAR(1) NOT NULL DEFAULT 'y',
  exceptions TEXT -- BLOB converted to TEXT for import
);

COMMENT ON TABLE staging.v1_deals IS 'Raw V1 deals data with PHP serialized fields';
COMMENT ON COLUMN staging.v1_deals.exceptions IS 'PHP serialized array - needs deserialization';
COMMENT ON COLUMN staging.v1_deals.active_days IS 'PHP serialized day array - needs deserialization';
COMMENT ON COLUMN staging.v1_deals.items IS 'PHP serialized item array - needs deserialization';

-- ----------------------------------------------------------------------------
-- V1 Coupons
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v1_coupons CASCADE;
CREATE TABLE staging.v1_coupons (
  id INTEGER PRIMARY KEY,
  name VARCHAR(45),
  description VARCHAR(255),
  code VARCHAR(255),
  start INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  stop INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  reduceType VARCHAR(10),
  restaurant INTEGER NOT NULL DEFAULT 0,
  product TEXT,
  ammount FLOAT NOT NULL DEFAULT 0,
  couponType VARCHAR(1) NOT NULL DEFAULT 'r',
  redeem FLOAT NOT NULL DEFAULT 0,
  active VARCHAR(1) NOT NULL DEFAULT 'Y',
  itemCount INTEGER NOT NULL DEFAULT 0,
  lang VARCHAR(2),
  for_reorder VARCHAR(1) DEFAULT '0',
  one_time_only VARCHAR(1) DEFAULT 'n',
  used VARCHAR(1) DEFAULT 'n',
  addToMail VARCHAR(1) DEFAULT 'n',
  mailText VARCHAR(255)
);

COMMENT ON TABLE staging.v1_coupons IS 'Raw V1 coupons data';

-- ----------------------------------------------------------------------------
-- V1 User Coupons (Customer Coupon Usage)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v1_user_coupons CASCADE;
CREATE TABLE staging.v1_user_coupons (
  id INTEGER PRIMARY KEY,
  owner INTEGER NOT NULL DEFAULT 0, -- User ID
  dateAdded INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  used VARCHAR(1) NOT NULL DEFAULT 'N',
  dateUsed INTEGER NOT NULL DEFAULT 0, -- Unix timestamp
  coupon INTEGER NOT NULL DEFAULT 0 -- Coupon ID
);

COMMENT ON TABLE staging.v1_user_coupons IS 'Raw V1 user coupon usage tracking';

-- ----------------------------------------------------------------------------
-- V2 Restaurants Deals (with native JSON)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_restaurants_deals CASCADE;
CREATE TABLE staging.v2_restaurants_deals (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  type VARCHAR(1), -- 'r' or 'a'
  repeatable VARCHAR(1) DEFAULT 'n',
  name VARCHAR(255),
  description TEXT,
  days JSONB, -- Native JSON: ["mon", "tue", ...]
  date_start DATE,
  date_stop DATE,
  time_start TIME,
  time_stop TIME,
  deal_type VARCHAR(25),
  remove FLOAT,
  amount FLOAT,
  times SMALLINT,
  item JSONB, -- Native JSON: ["230|4", "125"]
  item_buy JSONB, -- Native JSON
  item_count_buy SMALLINT,
  item_count SMALLINT,
  image VARCHAR(45),
  promo_code VARCHAR(125),
  customize VARCHAR(1) DEFAULT 'n',
  dates JSONB, -- Native JSON: ["2017-06-21"]
  extempted_courses JSONB, -- Native JSON (typo in V2)
  available JSONB, -- Native JSON: ["t", "d"]
  split_deal VARCHAR(1) DEFAULT 'n',
  first_order VARCHAR(1) DEFAULT 'n',
  mailCoupon VARCHAR(1) DEFAULT 'n',
  mailBody TEXT,
  enabled VARCHAR(1) DEFAULT 'y',
  added_by INTEGER,
  added_at TIMESTAMP,
  disabled_by INTEGER,
  disabled_at TIMESTAMP
);

COMMENT ON TABLE staging.v2_restaurants_deals IS 'Raw V2 restaurants deals with native JSON fields';

-- ----------------------------------------------------------------------------
-- V2 Coupons
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_coupons CASCADE;
CREATE TABLE staging.v2_coupons (
  id INTEGER PRIMARY KEY,
  name VARCHAR(45),
  description VARCHAR(255),
  code VARCHAR(255),
  start INTEGER NOT NULL DEFAULT 0,
  stop INTEGER NOT NULL DEFAULT 0,
  reduceType VARCHAR(10),
  restaurant INTEGER NOT NULL DEFAULT 0,
  product TEXT,
  ammount FLOAT NOT NULL DEFAULT 0,
  couponType VARCHAR(1) NOT NULL DEFAULT 'r',
  redeem FLOAT NOT NULL DEFAULT 0,
  active VARCHAR(1) NOT NULL DEFAULT 'Y',
  itemCount INTEGER NOT NULL DEFAULT 0,
  lang VARCHAR(2)
);

COMMENT ON TABLE staging.v2_coupons IS 'Raw V2 coupons data (missing V1 email fields)';

-- ============================================================================
-- PRIORITY 2: NAVIGATION & ORGANIZATION TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- V1 Tags
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v1_tags CASCADE;
CREATE TABLE staging.v1_tags (
  id INTEGER PRIMARY KEY,
  name VARCHAR(45)
);

COMMENT ON TABLE staging.v1_tags IS 'Raw V1 marketing tags';

-- ----------------------------------------------------------------------------
-- V2 Tags
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_tags CASCADE;
CREATE TABLE staging.v2_tags (
  id INTEGER PRIMARY KEY,
  name VARCHAR(45)
);

COMMENT ON TABLE staging.v2_tags IS 'Raw V2 marketing tags';

-- ----------------------------------------------------------------------------
-- V2 Restaurants Tags (Association)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_restaurants_tags CASCADE;
CREATE TABLE staging.v2_restaurants_tags (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  tag_id INTEGER
);

COMMENT ON TABLE staging.v2_restaurants_tags IS 'Raw V2 restaurant-tag associations';

-- ----------------------------------------------------------------------------
-- V2 Landing Pages
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_landing_pages CASCADE;
CREATE TABLE staging.v2_landing_pages (
  id INTEGER PRIMARY KEY,
  name VARCHAR(125),
  domain VARCHAR(125),
  logo VARCHAR(125),
  background VARCHAR(125),
  coords JSONB, -- Native JSON
  settings JSONB -- Native JSON
);

COMMENT ON TABLE staging.v2_landing_pages IS 'Raw V2 landing page configurations';

-- ----------------------------------------------------------------------------
-- V2 Landing Pages Restaurants (Association)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_landing_pages_restaurants CASCADE;
CREATE TABLE staging.v2_landing_pages_restaurants (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  landing_page_id INTEGER
);

COMMENT ON TABLE staging.v2_landing_pages_restaurants IS 'Raw V2 landing page-restaurant associations';

-- ----------------------------------------------------------------------------
-- V2 Restaurants Deals Splits (Special - 1 row)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS staging.v2_restaurants_deals_splits CASCADE;
CREATE TABLE staging.v2_restaurants_deals_splits (
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  content JSONB
);

COMMENT ON TABLE staging.v2_restaurants_deals_splits IS 'Raw V2 deal splits config (single row)';

-- ============================================================================
-- INDEXES FOR STAGING (Lookup Performance)
-- ============================================================================

CREATE INDEX idx_v1_deals_restaurant ON staging.v1_deals(restaurant);
CREATE INDEX idx_v1_coupons_restaurant ON staging.v1_coupons(restaurant);
CREATE INDEX idx_v1_user_coupons_owner ON staging.v1_user_coupons(owner);
CREATE INDEX idx_v1_user_coupons_coupon ON staging.v1_user_coupons(coupon);

CREATE INDEX idx_v2_restaurants_deals_restaurant ON staging.v2_restaurants_deals(restaurant_id);
CREATE INDEX idx_v2_coupons_restaurant ON staging.v2_coupons(restaurant);
CREATE INDEX idx_v2_restaurants_tags_restaurant ON staging.v2_restaurants_tags(restaurant_id);
CREATE INDEX idx_v2_restaurants_tags_tag ON staging.v2_restaurants_tags(tag_id);
CREATE INDEX idx_v2_landing_pages_restaurants_page ON staging.v2_landing_pages_restaurants(landing_page_id);
CREATE INDEX idx_v2_landing_pages_restaurants_restaurant ON staging.v2_landing_pages_restaurants(restaurant_id);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check table creation
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'staging'
  AND tablename LIKE '%deals%' 
  OR tablename LIKE '%coupon%'
  OR tablename LIKE '%tag%'
  OR tablename LIKE '%landing%'
ORDER BY tablename;

-- ============================================================================
-- READY FOR DUMP LOADING
-- ============================================================================
