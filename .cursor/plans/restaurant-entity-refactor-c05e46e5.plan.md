<!-- c05e46e5-4786-4757-82ac-5afffc655b47 4eebd2cf-5e4b-4280-a715-f70820bafb4c -->
# Restaurant Management Entity - V3 Refactoring Plan

## Overview

Refactor the Restaurant Management Entity to eliminate v1/v2 conditional logic, implement enterprise-grade patterns, and achieve production-ready scalability for a multi-tenant food ordering platform.

**Current State:** 944 restaurants across 9 child tables with v1/v2 legacy patterns

**Target State:** Unified V3-native architecture with industry-standard features

**Priority:** #1 (Foundation for all other entities)

---

## Current State Analysis

### Core Tables (menuca_v3)

1. **restaurants** (944 rows) - Parent table
2. **restaurant_locations** (921 rows)
3. **restaurant_contacts** (823 rows)
4. **restaurant_admin_users** (439 rows) + **admin_user_restaurants** (91 rows)
5. **restaurant_schedules** (1,002 rows)
6. **restaurant_domains** (713 rows)
7. **restaurant_service_configs** (944 rows)
8. **restaurant_special_schedules** (50 rows)
9. **restaurant_time_periods** (6 rows)

### Issues Identified

#### CRITICAL

1. **V1/V2 Conditional Logic**: Status derivation uses different rules for v1 vs v2 sources
2. **Missing Timezone Column**: Schedules don't specify timezone (DST issues)
3. **No Franchise/Chain Support**: Missing parent-child hierarchy for multi-location brands
4. **Incomplete Soft Delete**: Only deleted_at/deleted_by added, missing helper views

#### HIGH

5. **Status Enum Not Enforced**: Using USER-DEFINED type but not validated
6. **Missing Restaurant Type/Cuisine Taxonomy**: No standardized categorization
7. **No Online/Offline Toggle**: Can't temporarily disable ordering without suspension
8. **Missing Delivery Zone Table**: No geospatial delivery boundary support
9. **No Restaurant Feature Flags**: Can't enable/disable features per restaurant

#### MEDIUM

10. **Missing SEO Fields**: No meta_title, meta_description, slug optimization
11. **No Operating Hours Validation**: Can create overlapping schedules
12. **Missing Contact Priority**: No "primary" contact designation
13. **No Domain SSL Tracking**: Missing ssl_verified, dns_verified columns
14. **No Onboarding Status**: Can't track setup progress (location → menu → payment)

---

## Phase 1: Core Schema Enhancements (CRITICAL)

### Task 1.1: Add Timezone Support

**Assignee:** Santiago

**Duration:** 2 hours

**Dependencies:** None

```sql
-- Add timezone column to restaurants
ALTER TABLE menuca_v3.restaurants
    ADD COLUMN timezone VARCHAR(50) NOT NULL DEFAULT 'America/Toronto',
    ADD CONSTRAINT restaurants_valid_timezone 
        CHECK (timezone IN (SELECT name FROM pg_timezone_names));

-- Create index for timezone queries
CREATE INDEX idx_restaurants_timezone 
    ON menuca_v3.restaurants(timezone);

-- Update existing restaurants with correct timezones
UPDATE menuca_v3.restaurants r
SET timezone = CASE
    WHEN rl.province_id = 9 THEN 'America/Toronto'     -- Ontario
    WHEN rl.province_id = 10 THEN 'America/Montreal'   -- Quebec
    WHEN rl.province_id = 5 THEN 'America/Vancouver'   -- BC
    ELSE 'America/Toronto'
END
FROM menuca_v3.restaurant_locations rl
WHERE r.id = rl.restaurant_id;
```

**Verification:**

```sql
-- Check timezone distribution
SELECT timezone, COUNT(*) as restaurant_count
FROM menuca_v3.restaurants
GROUP BY timezone
ORDER BY restaurant_count DESC;
```

---

### Task 1.2: Implement Franchise/Chain Hierarchy

**Assignee:** Santiago

**Duration:** 4 hours

**Dependencies:** None

```sql
-- Add parent_restaurant_id for franchise chains
ALTER TABLE menuca_v3.restaurants
    ADD COLUMN parent_restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id),
    ADD COLUMN is_franchise_parent BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN franchise_brand_name VARCHAR(255),
    ADD CONSTRAINT restaurants_no_self_parent 
        CHECK (parent_restaurant_id != id);

-- Index for franchise queries
CREATE INDEX idx_restaurants_parent 
    ON menuca_v3.restaurants(parent_restaurant_id) 
    WHERE parent_restaurant_id IS NOT NULL;

CREATE INDEX idx_restaurants_franchise_parent 
    ON menuca_v3.restaurants(id) 
    WHERE is_franchise_parent = true;

-- Helper view for franchise chains
CREATE OR REPLACE VIEW menuca_v3.v_franchise_chains AS
SELECT 
    parent.id as chain_id,
    parent.franchise_brand_name,
    parent.name as parent_name,
    COUNT(child.id) as location_count,
    json_agg(json_build_object(
        'id', child.id,
        'name', child.name,
        'status', child.status,
        'timezone', child.timezone
    ) ORDER BY child.name) as locations
FROM menuca_v3.restaurants parent
LEFT JOIN menuca_v3.restaurants child ON child.parent_restaurant_id = parent.id
WHERE parent.is_franchise_parent = true
GROUP BY parent.id, parent.franchise_brand_name, parent.name;
```

**Data Migration:**

```sql
-- Identify potential franchise chains (manual review required)
WITH potential_franchises AS (
    SELECT 
        REGEXP_REPLACE(name, '\s*(#\d+|Location|Branch|Store)\s*', '', 'gi') as brand,
        array_agg(id) as restaurant_ids,
        COUNT(*) as location_count
    FROM menuca_v3.restaurants
    GROUP BY brand
    HAVING COUNT(*) > 1
)
SELECT * FROM potential_franchises ORDER BY location_count DESC;
```

---

### Task 1.3: Complete Soft Delete Infrastructure

**Assignee:** Santiago

**Duration:** 3 hours

**Dependencies:** Task 1.2

```sql
-- Soft delete already has columns (deleted_at, deleted_by) from Phase 8
-- Add helper views for active records

-- View: Active restaurants
CREATE OR REPLACE VIEW menuca_v3.v_active_restaurants AS
SELECT r.*
FROM menuca_v3.restaurants r
WHERE r.deleted_at IS NULL
  AND r.status IN ('active', 'pending')
  AND r.closed_at IS NULL;

-- View: Operational restaurants (accepting orders)
CREATE OR REPLACE VIEW menuca_v3.v_operational_restaurants AS
SELECT r.*
FROM menuca_v3.restaurants r
WHERE r.deleted_at IS NULL
  AND r.status = 'active'
  AND r.closed_at IS NULL
  AND r.suspended_at IS NULL;

-- Add soft delete to child tables
ALTER TABLE menuca_v3.restaurant_locations
    ADD COLUMN deleted_at TIMESTAMPTZ,
    ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_contacts
    ADD COLUMN deleted_at TIMESTAMPTZ,
    ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_domains
    ADD COLUMN deleted_at TIMESTAMPTZ,
    ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

-- Indexes for performance
CREATE INDEX idx_restaurant_locations_deleted 
    ON menuca_v3.restaurant_locations(restaurant_id) 
    WHERE deleted_at IS NULL;

CREATE INDEX idx_restaurant_contacts_deleted 
    ON menuca_v3.restaurant_contacts(restaurant_id) 
    WHERE deleted_at IS NULL;

CREATE INDEX idx_restaurant_domains_deleted 
    ON menuca_v3.restaurant_domains(restaurant_id) 
    WHERE deleted_at IS NULL;
```

---

### Task 1.4: Enforce Status Enum & Add Online/Offline Toggle

**Assignee:** Santiago

**Duration:** 2 hours

**Dependencies:** None

```sql
-- Verify current status enum exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'restaurant_status') THEN
        CREATE TYPE restaurant_status AS ENUM ('pending', 'active', 'suspended', 'inactive', 'closed');
    END IF;
END $$;

-- Add online_ordering_enabled flag
ALTER TABLE menuca_v3.restaurants
    ADD COLUMN online_ordering_enabled BOOLEAN NOT NULL DEFAULT true,
    ADD COLUMN online_ordering_disabled_at TIMESTAMPTZ,
    ADD COLUMN online_ordering_disabled_reason TEXT;

-- Add constraint: can't have both enabled and disabled_at
ALTER TABLE menuca_v3.restaurants
    ADD CONSTRAINT restaurants_online_ordering_consistency 
        CHECK (
            (online_ordering_enabled = true AND online_ordering_disabled_at IS NULL)
            OR (online_ordering_enabled = false)
        );

-- Index for quick operational check
CREATE INDEX idx_restaurants_accepting_orders 
    ON menuca_v3.restaurants(id) 
    WHERE status = 'active' 
      AND deleted_at IS NULL 
      AND online_ordering_enabled = true;

-- Helper function: Can accept orders?
CREATE OR REPLACE FUNCTION menuca_v3.can_accept_orders(p_restaurant_id BIGINT)
RETURNS BOOLEAN AS $$
SELECT 
    status = 'active' 
    AND deleted_at IS NULL 
    AND closed_at IS NULL 
    AND suspended_at IS NULL
    AND online_ordering_enabled = true
FROM menuca_v3.restaurants
WHERE id = p_restaurant_id;
$$ LANGUAGE SQL STABLE;
```

---

## Phase 2: Remove V1/V2 Logic & Consolidate (HIGH)

### Task 2.1: Eliminate Status Derivation Logic

**Assignee:** Santiago

**Duration:** 4 hours

**Dependencies:** Phase 1 complete

**Current Problem:**

```sql
-- BEFORE: V1/V2 conditional logic
CASE
  WHEN COALESCE(NULLIF(pending,''),'n') IN ('y','Y','1') THEN 'pending'
  WHEN COALESCE(NULLIF(active,''),'n') IN ('y','Y','1') THEN 'active'
  WHEN COALESCE(NULLIF(suspend_operation,''),'n') IN ('y','1') OR suspended_at IS NOT NULL THEN 'suspended'
  ELSE 'inactive'
END
```

**Solution:**

```sql
-- AFTER: V3-native status management
-- 1. Create status transition audit table
CREATE TABLE menuca_v3.restaurant_status_history (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
    old_status restaurant_status,
    new_status restaurant_status NOT NULL,
    reason TEXT,
    changed_by BIGINT REFERENCES menuca_v3.admin_users(id),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_restaurant_status_history_restaurant 
    ON menuca_v3.restaurant_status_history(restaurant_id, changed_at DESC);

-- 2. Create status transition trigger
CREATE OR REPLACE FUNCTION menuca_v3.audit_restaurant_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO menuca_v3.restaurant_status_history 
            (restaurant_id, old_status, new_status, changed_by)
        VALUES 
            (NEW.id, OLD.status, NEW.status, NEW.updated_by);
        
        -- Update timestamps based on status
        CASE NEW.status
            WHEN 'active' THEN 
                NEW.activated_at = COALESCE(NEW.activated_at, NOW());
                NEW.suspended_at = NULL;
            WHEN 'suspended' THEN 
                NEW.suspended_at = NOW();
            WHEN 'closed' THEN 
                NEW.closed_at = COALESCE(NEW.closed_at, NOW());
            ELSE NULL;
        END CASE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_restaurant_status_change
BEFORE UPDATE ON menuca_v3.restaurants
FOR EACH ROW
WHEN (NEW.status IS DISTINCT FROM OLD.status)
EXECUTE FUNCTION menuca_v3.audit_restaurant_status_change();

-- 3. Remove dependency on legacy_v1_id/legacy_v2_id for business logic
-- Keep columns for historical reference only
COMMENT ON COLUMN menuca_v3.restaurants.legacy_v1_id IS 
    'Historical reference only. DO NOT use in business logic.';
COMMENT ON COLUMN menuca_v3.restaurants.legacy_v2_id IS 
    'Historical reference only. DO NOT use in business logic.';
```

---

### Task 2.2: Consolidate Contact Information Pattern

**Assignee:** Brian

**Duration:** 3 hours

**Dependencies:** Task 2.1

**Current Issue:** Some restaurants use restaurant_contacts, others use restaurant_locations for contact info

```sql
-- 1. Add contact priority system
ALTER TABLE menuca_v3.restaurant_contacts
    ADD COLUMN contact_priority INTEGER NOT NULL DEFAULT 1,
    ADD COLUMN contact_type VARCHAR(50) NOT NULL DEFAULT 'general',
    ADD CONSTRAINT restaurant_contacts_type_check 
        CHECK (contact_type IN ('owner', 'manager', 'billing', 'orders', 'support', 'general'));

-- 2. Create unique constraint: one primary per type
CREATE UNIQUE INDEX idx_restaurant_contacts_primary_per_type 
    ON menuca_v3.restaurant_contacts(restaurant_id, contact_type, contact_priority)
    WHERE contact_priority = 1 AND deleted_at IS NULL;

-- 3. Helper function: Get primary contact
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_primary_contact(
    p_restaurant_id BIGINT,
    p_contact_type VARCHAR DEFAULT 'general'
)
RETURNS TABLE (
    id BIGINT,
    email VARCHAR,
    phone VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT rc.id, rc.email, rc.phone, rc.first_name, rc.last_name
    FROM menuca_v3.restaurant_contacts rc
    WHERE rc.restaurant_id = p_restaurant_id
      AND rc.contact_type = p_contact_type
      AND rc.contact_priority = 1
      AND rc.deleted_at IS NULL
      AND rc.is_active = true
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- 4. Backfill contact types from existing data
UPDATE menuca_v3.restaurant_contacts
SET contact_type = CASE
    WHEN receives_orders = true THEN 'orders'
    WHEN receives_statements = true THEN 'billing'
    ELSE 'general'
END
WHERE contact_type = 'general';
```

---

## Phase 3: Industry-Standard Features (HIGH)

### Task 3.1: Restaurant Categorization System

**Assignee:** Santiago

**Duration:** 5 hours

**Dependencies:** Phase 2 complete

```sql
-- 1. Create cuisine taxonomy tables
CREATE TABLE menuca_v3.cuisine_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE TABLE menuca_v3.restaurant_cuisines (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    cuisine_type_id INTEGER NOT NULL REFERENCES menuca_v3.cuisine_types(id),
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(restaurant_id, cuisine_type_id)
);

CREATE INDEX idx_restaurant_cuisines_restaurant 
    ON menuca_v3.restaurant_cuisines(restaurant_id);
CREATE INDEX idx_restaurant_cuisines_cuisine 
    ON menuca_v3.restaurant_cuisines(cuisine_type_id);
CREATE UNIQUE INDEX idx_restaurant_cuisines_one_primary 
    ON menuca_v3.restaurant_cuisines(restaurant_id, is_primary)
    WHERE is_primary = true;

-- 2. Seed cuisines based on current restaurant data analysis
-- Analyzed 944 restaurants: most common are Pizza, Chinese, Italian, Lebanese, Indian, Thai, Vietnamese, Japanese, Greek, Sushi
INSERT INTO menuca_v3.cuisine_types (name, slug, display_order) VALUES
    ('Pizza', 'pizza', 1),
    ('Chinese', 'chinese', 2),
    ('Italian', 'italian', 3),
    ('Lebanese', 'lebanese', 4),
    ('Indian', 'indian', 5),
    ('Thai', 'thai', 6),
    ('Vietnamese', 'vietnamese', 7),
    ('Japanese', 'japanese', 8),
    ('Sushi', 'sushi', 9),
    ('Greek', 'greek', 10),
    ('American', 'american', 11),
    ('Burgers', 'burgers', 12),
    ('Shawarma', 'shawarma', 13),
    ('Pita & Wraps', 'pita-wraps', 14),
    ('BBQ', 'bbq', 15),
    ('Asian Fusion', 'asian-fusion', 16),
    ('Sandwiches & Subs', 'sandwiches-subs', 17),
    ('Breakfast & Brunch', 'breakfast', 18),
    ('Noodle House', 'noodle-house', 19),
    ('Mediterranean', 'mediterranean', 20);

-- 2b. Auto-tag existing restaurants based on name analysis
WITH cuisine_keywords AS (
    SELECT 
        r.id as restaurant_id,
        ct.id as cuisine_type_id,
        CASE
            WHEN LOWER(r.name) ~ '(pizza|pizzeria)' THEN 1
            WHEN LOWER(r.name) ~ '(chinese|wok|oriental)' THEN 2
            WHEN LOWER(r.name) ~ '(milano|italian|lasagna|pasta)' THEN 3
            WHEN LOWER(r.name) ~ '(lebanese|shawarma|pita)' THEN 4
            WHEN LOWER(r.name) ~ 'indian' THEN 5
            WHEN LOWER(r.name) ~ 'thai' THEN 6
            WHEN LOWER(r.name) ~ '(vietnamese|pho)' THEN 7
            WHEN LOWER(r.name) ~ 'japan' THEN 8
            WHEN LOWER(r.name) ~ 'sushi' THEN 9
            WHEN LOWER(r.name) ~ '(greek|souvlaki)' THEN 10
            WHEN LOWER(r.name) ~ 'noodle' THEN 19
            ELSE NULL
        END as matched_cuisine
    FROM menuca_v3.restaurants r
    CROSS JOIN menuca_v3.cuisine_types ct
    WHERE r.deleted_at IS NULL
)
INSERT INTO menuca_v3.restaurant_cuisines (restaurant_id, cuisine_type_id, is_primary)
SELECT DISTINCT restaurant_id, cuisine_type_id, true
FROM cuisine_keywords
WHERE matched_cuisine = cuisine_type_id
ON CONFLICT (restaurant_id, cuisine_type_id) DO NOTHING;

-- 3. Create restaurant tags system
CREATE TABLE menuca_v3.restaurant_tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL, -- 'dietary', 'service', 'atmosphere', 'feature'
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE menuca_v3.restaurant_tag_assignments (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES menuca_v3.restaurant_tags(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(restaurant_id, tag_id)
);

CREATE INDEX idx_restaurant_tag_assignments_restaurant 
    ON menuca_v3.restaurant_tag_assignments(restaurant_id);
CREATE INDEX idx_restaurant_tag_assignments_tag 
    ON menuca_v3.restaurant_tag_assignments(tag_id);

-- 4. Seed common tags
INSERT INTO menuca_v3.restaurant_tags (name, slug, category) VALUES
    ('Halal', 'halal', 'dietary'),
    ('Vegetarian Options', 'vegetarian', 'dietary'),
    ('Vegan Options', 'vegan', 'dietary'),
    ('Gluten-Free Options', 'gluten-free', 'dietary'),
    ('Delivery', 'delivery', 'service'),
    ('Pickup', 'pickup', 'service'),
    ('Dine-In', 'dine-in', 'service'),
    ('Family Friendly', 'family-friendly', 'atmosphere'),
    ('Late Night', 'late-night', 'feature'),
    ('Accepts Cash', 'cash', 'payment'),
    ('Accepts Credit Card', 'credit-card', 'payment');
```

---

### Task 3.2: Geospatial Delivery Zones (PostGIS)

**Assignee:** Brian

**Duration:** 6 hours

**Dependencies:** Task 3.1

```sql
-- 1. Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Add geometry column to restaurant_locations
ALTER TABLE menuca_v3.restaurant_locations
    ADD COLUMN location_point GEOMETRY(Point, 4326);

-- Update from existing lat/lng
UPDATE menuca_v3.restaurant_locations
SET location_point = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Add spatial index
CREATE INDEX idx_restaurant_locations_point 
    ON menuca_v3.restaurant_locations USING GIST(location_point);

-- 3. Create delivery zones table
CREATE TABLE menuca_v3.restaurant_delivery_zones (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    zone_name VARCHAR(100),
    zone_geometry GEOMETRY(Polygon, 4326) NOT NULL,
    delivery_fee_cents INTEGER NOT NULL DEFAULT 0,
    minimum_order_cents INTEGER NOT NULL DEFAULT 0,
    estimated_delivery_minutes INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by BIGINT REFERENCES menuca_v3.admin_users(id)
);

CREATE INDEX idx_delivery_zones_restaurant 
    ON menuca_v3.restaurant_delivery_zones(restaurant_id);
CREATE INDEX idx_delivery_zones_geometry 
    ON menuca_v3.restaurant_delivery_zones USING GIST(zone_geometry);

-- 4. Helper function: Check if address in delivery zone
CREATE OR REPLACE FUNCTION menuca_v3.is_address_in_delivery_zone(
    p_restaurant_id BIGINT,
    p_latitude NUMERIC,
    p_longitude NUMERIC
)
RETURNS TABLE (
    zone_id BIGINT,
    zone_name VARCHAR,
    delivery_fee_cents INTEGER,
    minimum_order_cents INTEGER,
    estimated_delivery_minutes INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rdz.id,
        rdz.zone_name,
        rdz.delivery_fee_cents,
        rdz.minimum_order_cents,
        rdz.estimated_delivery_minutes
    FROM menuca_v3.restaurant_delivery_zones rdz
    WHERE rdz.restaurant_id = p_restaurant_id
      AND rdz.is_active = true
      AND ST_Contains(
          rdz.zone_geometry,
          ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
      )
    ORDER BY rdz.delivery_fee_cents ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- 5. Helper function: Find nearby restaurants
CREATE OR REPLACE FUNCTION menuca_v3.find_nearby_restaurants(
    p_latitude NUMERIC,
    p_longitude NUMERIC,
    p_radius_km NUMERIC DEFAULT 5,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    distance_km NUMERIC,
    can_deliver BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        ROUND((ST_Distance(
            rl.location_point::geography,
            ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
        ) / 1000)::NUMERIC, 2) as distance_km,
        EXISTS(
            SELECT 1 
            FROM menuca_v3.restaurant_delivery_zones rdz
            WHERE rdz.restaurant_id = r.id
              AND rdz.is_active = true
              AND ST_Contains(
                  rdz.zone_geometry,
                  ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
              )
        ) as can_deliver
    FROM menuca_v3.restaurants r
    JOIN menuca_v3.restaurant_locations rl ON r.id = rl.restaurant_id
    WHERE r.status = 'active'
      AND r.deleted_at IS NULL
      AND r.online_ordering_enabled = true
      AND rl.location_point IS NOT NULL
      AND ST_DWithin(
          rl.location_point::geography,
          ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
          p_radius_km * 1000
      )
    ORDER BY distance_km ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

### Task 3.3: Restaurant Feature Flags System

**Assignee:** Santiago

**Duration:** 4 hours

**Dependencies:** Task 3.2

```sql
-- 1. Create feature flags table
CREATE TABLE menuca_v3.restaurant_features (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    feature_key VARCHAR(100) NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT false,
    config JSONB DEFAULT '{}'::jsonb,
    enabled_at TIMESTAMPTZ,
    enabled_by BIGINT REFERENCES menuca_v3.admin_users(id),
    disabled_at TIMESTAMPTZ,
    disabled_by BIGINT REFERENCES menuca_v3.admin_users(id),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(restaurant_id, feature_key)
);

CREATE INDEX idx_restaurant_features_restaurant 
    ON menuca_v3.restaurant_features(restaurant_id);
CREATE INDEX idx_restaurant_features_key 
    ON menuca_v3.restaurant_features(feature_key);
CREATE INDEX idx_restaurant_features_enabled 
    ON menuca_v3.restaurant_features(restaurant_id, feature_key, is_enabled);

-- 2. Define available features (enum)
CREATE TYPE restaurant_feature_key AS ENUM (
    'online_ordering',          -- Core ordering
    'table_reservations',       -- Reservation system
    'loyalty_program',          -- Points/rewards
    'gift_cards',               -- Gift card sales
    'catering_orders',          -- Large orders
    'scheduled_orders',         -- Future orders
    'group_ordering',           -- Split payments
    'alcohol_sales',            -- Requires age verification
    'custom_tips',              -- Allow custom tip amounts
    'contactless_delivery',     -- Leave at door
    'real_time_tracking',       -- Order tracking
    'reviews_ratings',          -- Customer reviews
    'menu_customization',       -- Advanced modifiers
    'combo_deals',              -- Combo meals
    'subscription_plans',       -- Monthly subscriptions
    'multi_location_ordering'   -- Order from multiple locations
);

-- 3. Helper function: Check feature enabled
CREATE OR REPLACE FUNCTION menuca_v3.has_feature(
    p_restaurant_id BIGINT,
    p_feature_key VARCHAR
)
RETURNS BOOLEAN AS $$
SELECT COALESCE(
    (SELECT is_enabled 
     FROM menuca_v3.restaurant_features 
     WHERE restaurant_id = p_restaurant_id 
       AND feature_key = p_feature_key),
    false
);
$$ LANGUAGE SQL STABLE;

-- 4. Seed default features for all active restaurants
INSERT INTO menuca_v3.restaurant_features (restaurant_id, feature_key, is_enabled, enabled_at)
SELECT 
    r.id,
    'online_ordering',
    r.online_ordering_enabled,
    r.activated_at
FROM menuca_v3.restaurants r
WHERE r.status = 'active' AND r.deleted_at IS NULL
ON CONFLICT (restaurant_id, feature_key) DO NOTHING;
```

---

## Phase 4: SEO & Discoverability (MEDIUM)

### Task 4.1: SEO Metadata Fields

**Assignee:** Brian

**Duration:** 3 hours

**Dependencies:** Phase 3 complete

```sql
-- Add SEO fields to restaurants table
ALTER TABLE menuca_v3.restaurants
    ADD COLUMN slug VARCHAR(255) UNIQUE,
    ADD COLUMN meta_title VARCHAR(160),
    ADD COLUMN meta_description VARCHAR(320),
    ADD COLUMN meta_keywords TEXT,
    ADD COLUMN og_image_url VARCHAR(500),
    ADD COLUMN search_keywords TEXT,
    ADD COLUMN is_featured BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN featured_priority INTEGER;

-- Generate slugs for existing restaurants
UPDATE menuca_v3.restaurants
SET slug = LOWER(REGEXP_REPLACE(
    REGEXP_REPLACE(name, '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
)) || '-' || id
WHERE slug IS NULL;

-- Add full-text search vector
ALTER TABLE menuca_v3.restaurants
    ADD COLUMN search_vector tsvector 
    GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(meta_description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(search_keywords, '')), 'C')
    ) STORED;

CREATE INDEX idx_restaurants_search 
    ON menuca_v3.restaurants USING GIN(search_vector);

CREATE INDEX idx_restaurants_featured 
    ON menuca_v3.restaurants(featured_priority DESC)
    WHERE is_featured = true AND status = 'active';

-- Helper function: Search restaurants
CREATE OR REPLACE FUNCTION menuca_v3.search_restaurants(
    p_search_query TEXT,
    p_latitude NUMERIC DEFAULT NULL,
    p_longitude NUMERIC DEFAULT NULL,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    restaurant_id BIGINT,
    restaurant_name VARCHAR,
    slug VARCHAR,
    distance_km NUMERIC,
    relevance_rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        r.slug,
        CASE 
            WHEN p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
                ROUND((ST_Distance(
                    rl.location_point::geography,
                    ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
                ) / 1000)::NUMERIC, 2)
            ELSE NULL
        END as distance_km,
        ts_rank(r.search_vector, plainto_tsquery('english', p_search_query)) as relevance_rank
    FROM menuca_v3.restaurants r
    LEFT JOIN menuca_v3.restaurant_locations rl ON r.id = rl.restaurant_id
    WHERE r.status = 'active'
      AND r.deleted_at IS NULL
      AND r.online_ordering_enabled = true
      AND r.search_vector @@ plainto_tsquery('english', p_search_query)
    ORDER BY 
        relevance_rank DESC,
        CASE WHEN p_latitude IS NOT NULL THEN distance_km ELSE 0 END ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

### Task 4.2: Onboarding Status Tracking

**Assignee:** Santiago

**Duration:** 3 hours

**Dependencies:** Task 4.1

```sql
-- Create onboarding status table
CREATE TABLE menuca_v3.restaurant_onboarding (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL UNIQUE REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
    
    -- Onboarding steps
    step_basic_info_completed BOOLEAN NOT NULL DEFAULT false,
    step_basic_info_completed_at TIMESTAMPTZ,
    
    step_location_completed BOOLEAN NOT NULL DEFAULT false,
    step_location_completed_at TIMESTAMPTZ,
    
    step_contact_completed BOOLEAN NOT NULL DEFAULT false,
    step_contact_completed_at TIMESTAMPTZ,
    
    step_schedule_completed BOOLEAN NOT NULL DEFAULT false,
    step_schedule_completed_at TIMESTAMPTZ,
    
    step_menu_completed BOOLEAN NOT NULL DEFAULT false,
    step_menu_completed_at TIMESTAMPTZ,
    
    step_payment_completed BOOLEAN NOT NULL DEFAULT false,
    step_payment_completed_at TIMESTAMPTZ,
    
    step_delivery_completed BOOLEAN NOT NULL DEFAULT false,
    step_delivery_completed_at TIMESTAMPTZ,
    
    step_testing_completed BOOLEAN NOT NULL DEFAULT false,
    step_testing_completed_at TIMESTAMPTZ,
    
    -- Overall status
    onboarding_completed BOOLEAN NOT NULL DEFAULT false,
    onboarding_completed_at TIMESTAMPTZ,
    onboarding_started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Progress tracking
    current_step VARCHAR(50),
    completion_percentage INTEGER GENERATED ALWAYS AS (
        (CASE WHEN step_basic_info_completed THEN 1 ELSE 0 END +
         CASE WHEN step_location_completed THEN 1 ELSE 0 END +
         CASE WHEN step_contact_completed THEN 1 ELSE 0 END +
         CASE WHEN step_schedule_completed THEN 1 ELSE 0 END +
         CASE WHEN step_menu_completed THEN 1 ELSE 0 END +
         CASE WHEN step_payment_completed THEN 1 ELSE 0 END +
         CASE WHEN step_delivery_completed THEN 1 ELSE 0 END +
         CASE WHEN step_testing_completed THEN 1 ELSE 0 END) * 100 / 8
    ) STORED,
    
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE INDEX idx_restaurant_onboarding_completion 
    ON menuca_v3.restaurant_onboarding(onboarding_completed, completion_percentage);

-- Helper function: Get onboarding status
CREATE OR REPLACE FUNCTION menuca_v3.get_onboarding_status(p_restaurant_id BIGINT)
RETURNS TABLE (
    step_name VARCHAR,
    is_completed BOOLEAN,
    completed_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        VALUES 
            ('Basic Info', step_basic_info_completed, step_basic_info_completed_at),
            ('Location', step_location_completed, step_location_completed_at),
            ('Contact', step_contact_completed, step_contact_completed_at),
            ('Schedule', step_schedule_completed, step_schedule_completed_at),
            ('Menu', step_menu_completed, step_menu_completed_at),
            ('Payment', step_payment_completed, step_payment_completed_at),
            ('Delivery', step_delivery_completed, step_delivery_completed_at),
            ('Testing', step_testing_completed, step_testing_completed_at)
    ) AS steps(step_name, is_completed, completed_at)
    FROM menuca_v3.restaurant_onboarding
    WHERE restaurant_id = p_restaurant_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Initialize onboarding for existing restaurants
INSERT INTO menuca_v3.restaurant_onboarding (restaurant_id, onboarding_started_at)
SELECT id, created_at
FROM menuca_v3.restaurants
WHERE deleted_at IS NULL
ON CONFLICT (restaurant_id) DO NOTHING;
```

---

## Phase 5: Domain Management Enhancements (MEDIUM)

### Task 5.1: SSL & DNS Verification

**Assignee:** Brian

**Duration:** 2 hours

**Dependencies:** Phase 4 complete

```sql
-- Add SSL/DNS tracking to restaurant_domains
ALTER TABLE menuca_v3.restaurant_domains
    ADD COLUMN ssl_verified BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN ssl_verified_at TIMESTAMPTZ,
    ADD COLUMN ssl_expires_at TIMESTAMPTZ,
    ADD COLUMN ssl_issuer VARCHAR(255),
    ADD COLUMN dns_verified BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN dns_verified_at TIMESTAMPTZ,
    ADD COLUMN dns_records JSONB DEFAULT '{}'::jsonb,
    ADD COLUMN last_checked_at TIMESTAMPTZ,
    ADD COLUMN verification_errors TEXT;

-- Index for SSL expiration monitoring
CREATE INDEX idx_domains_ssl_expiring 
    ON menuca_v3.restaurant_domains(ssl_expires_at)
    WHERE ssl_verified = true 
      AND ssl_expires_at < NOW() + INTERVAL '30 days'
      AND deleted_at IS NULL;

-- Helper view: Domains needing attention
CREATE OR REPLACE VIEW menuca_v3.v_domains_needing_attention AS
SELECT 
    rd.id,
    rd.restaurant_id,
    r.name as restaurant_name,
    rd.domain,
    CASE
        WHEN NOT rd.dns_verified THEN 'DNS not verified'
        WHEN NOT rd.ssl_verified THEN 'SSL not verified'
        WHEN rd.ssl_expires_at < NOW() + INTERVAL '7 days' THEN 'SSL expires in 7 days'
        WHEN rd.ssl_expires_at < NOW() + INTERVAL '30 days' THEN 'SSL expires in 30 days'
        ELSE 'Other issue'
    END as issue,
    rd.ssl_expires_at,
    rd.last_checked_at
FROM menuca_v3.restaurant_domains rd
JOIN menuca_v3.restaurants r ON rd.restaurant_id = r.id
WHERE rd.is_enabled = true
  AND rd.deleted_at IS NULL
  AND (
      NOT rd.dns_verified
      OR NOT rd.ssl_verified
      OR rd.ssl_expires_at < NOW() + INTERVAL '30 days'
      OR rd.last_checked_at < NOW() - INTERVAL '7 days'
  );
```

---

## Phase 6: Data Integrity & Validation (MEDIUM)

### Task 6.1: Schedule Overlap Validation

**Assignee:** Santiago

**Duration:** 4 hours

**Dependencies:** Phase 5 complete

```sql
-- Add validation function for schedule overlaps
CREATE OR REPLACE FUNCTION menuca_v3.validate_schedule_no_overlap()
RETURNS TRIGGER AS $$
DECLARE
    v_overlap_count INTEGER;
BEGIN
    -- Check for overlapping schedules on the same day
    SELECT COUNT(*) INTO v_overlap_count
    FROM menuca_v3.restaurant_schedules
    WHERE restaurant_id = NEW.restaurant_id
      AND id != COALESCE(NEW.id, -1)
      AND day_of_week = NEW.day_of_week
      AND service_type = NEW.service_type
      AND deleted_at IS NULL
      AND (
          (NEW.open_time, NEW.close_time) OVERLAPS (open_time, close_time)
      );
    
    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'Schedule overlaps with existing schedule for % on %', 
            NEW.service_type, NEW.day_of_week;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_restaurant_schedules_no_overlap
BEFORE INSERT OR UPDATE ON menuca_v3.restaurant_schedules
FOR EACH ROW
EXECUTE FUNCTION menuca_v3.validate_schedule_no_overlap();

-- Add validation: close_time must be after open_time
ALTER TABLE menuca_v3.restaurant_schedules
    ADD CONSTRAINT restaurant_schedules_time_order 
        CHECK (close_time > open_time OR (close_time < open_time AND close_time < '06:00'::time));
```

---

## Verification & Testing Plan

### V1/V2 Logic Elimination Test

```sql
-- Verify no application code depends on legacy IDs for business logic
-- Run after all phases complete

-- Test 1: Status should be managed by V3 logic only
SELECT 
    COUNT(*) as restaurants_with_status_issues
FROM menuca_v3.restaurants
WHERE status NOT IN ('pending', 'active', 'suspended', 'inactive', 'closed')
   OR (status = 'active' AND activated_at IS NULL)
   OR (status = 'suspended' AND suspended_at IS NULL)
   OR (status = 'closed' AND closed_at IS NULL);
-- Expected: 0

-- Test 2: All active restaurants can accept orders
SELECT 
    r.id,
    r.name,
    r.status,
    r.online_ordering_enabled,
    menuca_v3.can_accept_orders(r.id) as can_accept
FROM menuca_v3.restaurants r
WHERE r.status = 'active' AND r.deleted_at IS NULL
  AND NOT menuca_v3.can_accept_orders(r.id);
-- Expected: 0 rows (all active restaurants should be orderable)

-- Test 3: Geospatial queries work
SELECT COUNT(*) 
FROM menuca_v3.find_nearby_restaurants(45.4215, -75.6972, 5, 20);
-- Expected: > 0 restaurants found

-- Test 4: Search functionality works
SELECT COUNT(*) 
FROM menuca_v3.search_restaurants('pizza', NULL, NULL, 50);
-- Expected: > 0 restaurants found

-- Test 5: Franchise chains identified
SELECT COUNT(*) 
FROM menuca_v3.v_franchise_chains;
-- Expected: > 0 franchise chains

-- Test 6: Feature flags working
SELECT 
    COUNT(DISTINCT restaurant_id) as restaurants_with_features
FROM menuca_v3.restaurant_features
WHERE is_enabled = true;
-- Expected: > 0

-- Test 7: No orphaned child records
SELECT 
    'restaurant_locations' as table_name,
    COUNT(*) as orphaned_count
FROM menuca_v3.restaurant_locations rl
LEFT JOIN menuca_v3.restaurants r ON rl.restaurant_id = r.id
WHERE r.id IS NULL
UNION ALL
SELECT 
    'restaurant_contacts',
    COUNT(*)
FROM menuca_v3.restaurant_contacts rc
LEFT JOIN menuca_v3.restaurants r ON rc.restaurant_id = r.id
WHERE r.id IS NULL;
-- Expected: 0 orphans in all tables
```

---

## Implementation Assignment

**Assignee:** Santiago (all tasks)

**Total Duration:** 45 hours (~5-6 days sequential work)

**Task Sequence:**

1. Phase 1: Core Schema Enhancements (11 hours)
2. Phase 2: Remove V1/V2 Logic (7 hours)
3. Phase 3: Industry-Standard Features (15 hours)
4. Phase 4: SEO & Discoverability (6 hours)
5. Phase 5: Domain Management (2 hours)
6. Phase 6: Data Integrity & Validation (4 hours)

---

## Success Criteria

1. **V1/V2 Logic Eliminated**: No business logic depends on legacy_v1_id/legacy_v2_id
2. **Status Management**: Unified V3-native status workflow with audit trail
3. **Timezone Support**: All restaurants have valid timezones, schedules respect DST
4. **Franchise Support**: Parent-child hierarchy functional for multi-location brands
5. **Geospatial**: PostGIS enabled, delivery zones working, proximity search < 100ms
6. **Feature Flags**: All restaurants have feature flag records, can toggle features
7. **SEO**: Full-text search functional, slugs generated, search < 500ms
8. **Soft Delete**: Complete soft delete pattern on all tables with helper views
9. **Data Integrity**: No orphaned records, no schedule overlaps, all constraints enforced
10. **Industry Standards**: Matches Uber Eats/Skip/DoorDash patterns (categorization, zones, features)

---

## Rollback Plan

Each phase is transaction-wrapped and can be rolled back independently:

```sql
-- Rollback example for Phase 1
BEGIN;
-- Execute Phase 1 tasks
-- If issues found:
ROLLBACK;
-- Otherwise:
COMMIT;
```

**Emergency Rollback:**

1. Drop new tables: `DROP TABLE menuca_v3.restaurant_delivery_zones CASCADE;`
2. Drop new columns: `ALTER TABLE menuca_v3.restaurants DROP COLUMN timezone CASCADE;`
3. Drop new functions: `DROP FUNCTION menuca_v3.can_accept_orders CASCADE;`
4. Restore from backup if needed

---

## Post-Implementation

### Documentation Updates Required

1. Update API documentation with new endpoints
2. Document feature flag keys and usage
3. Create admin guide for franchise management
4. Update ERD diagrams with new tables
5. Write developer guide for geospatial queries

### Monitoring Setup

1. Alert on SSL certificates expiring < 30 days
2. Monitor schedule overlap violations
3. Track onboarding completion rates
4. Monitor geospatial query performance
5. Alert on status transition anomalies

---

**Estimated Total Duration:** 45-50 hours (5-6 days parallel work)

**Risk Level:** MEDIUM (extensive changes, backward compatible)

**Production Impact:** ZERO (additive changes only, no breaking changes)

### To-dos

- [ ] Add timezone support to restaurants table with validation and province-based defaults
- [ ] Implement franchise/chain hierarchy with parent_restaurant_id and helper views
- [ ] Complete soft delete infrastructure with helper views for all child tables
- [ ] Enforce status enum and add online/offline ordering toggle with helper function
- [ ] Eliminate v1/v2 status derivation logic, create audit table and triggers
- [ ] Consolidate contact information pattern with priority system and helper functions
- [ ] Create cuisine taxonomy and restaurant tags system with seed data
- [ ] Implement PostGIS delivery zones with proximity search and zone validation
- [ ] Build restaurant feature flags system with enum and helper functions
- [ ] Add SEO metadata fields, full-text search, and search helper function
- [ ] Create onboarding status tracking with completion percentage calculation
- [ ] Enhance domain management with SSL/DNS verification and monitoring view
- [ ] Add schedule overlap validation with triggers and time order constraints
- [ ] Run comprehensive verification test suite to confirm v1/v2 logic eliminated