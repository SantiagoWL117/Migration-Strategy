# Delivery Operations Entity - V3 Refactoring Plan
## Entity-by-Entity Optimization for Enterprise-Level Food Ordering

**Entity:** Delivery Operations (Priority 8)
**Dependencies:** ✅ Restaurant Management (Complete), ✅ Users & Access (Complete), ✅ Menu & Catalog (Complete), Orders & Checkout (Required)
**Created:** January 17, 2025
**Developer:** Brian (w/ AI Assistant)
**Status:** 🚧 **IN PROGRESS**

---

## 🎯 **EXECUTIVE SUMMARY**

### **Current State Analysis**

The Delivery Operations entity handles all delivery logistics for the food ordering platform:
- Driver management and assignment
- Delivery zones and service areas
- Delivery fees and pricing
- Real-time tracking
- Driver earnings and payouts
- Fleet management

**Critical Dependencies:**
- **Orders:** Must exist before delivery assignment
- **Restaurants:** Delivery zones tied to restaurant locations
- **Users:** Drivers are special user types
- **Location & Geography:** Delivery zones require geo-fencing

---

### **Refactoring Objective**

**GOAL:** Transform Delivery Operations into an enterprise-grade delivery management system that rivals Uber Eats, DoorDash, and Skip the Dishes delivery infrastructure.

**Focus Areas:**
1. 🔒 **Auth & Security** - Driver access control, earnings protection
2. 📍 **Geospatial Features** - Zone management, distance calculations
3. 🚗 **Real-time Tracking** - Driver location, order status
4. 💰 **Financial Security** - Protected earnings, secure payouts
5. 🏗️ **Architecture** - Scalable driver assignment algorithms
6. 📱 **Real-time Features** - Live tracking, status updates

---

## 📋 **REFACTORING PHASES**

### **Phase Overview**

| Phase | Focus | Priority | Effort | Status |
|-------|-------|----------|--------|--------|
| **Phase 1** | Auth & Security (RLS) | 🔴 CRITICAL | 6-8 hours | ⏳ PENDING |
| **Phase 2** | Performance & APIs | 🔴 HIGH | 5-7 hours | ⏳ PENDING |
| **Phase 3** | Schema Optimization | 🟡 MEDIUM | 8-10 hours | ⏳ PENDING |
| **Phase 4** | Real-time Tracking | 🔴 HIGH | 6-8 hours | ⏳ PENDING |
| **Phase 5** | Soft Delete & Audit | 🟢 LOW | 3-4 hours | ⏳ PENDING |
| **Phase 6** | Multi-language Support | 🟢 LOW | 2-3 hours | ⏳ PENDING |
| **Phase 7** | Testing & Validation | 🔴 CRITICAL | 4-5 hours | ⏳ PENDING |

**Total Estimated Effort:** 34-45 hours (1-2 weeks)

---

## 🔐 **PHASE 1: AUTH & SECURITY (CRITICAL)**

**Priority:** 🔴 CRITICAL
**Duration:** 6-8 hours
**Risk:** 🟡 MEDIUM (test thoroughly, can break queries)
**Supabase MCP:** ✅ YES (use for all DDL)

---

### **1.1 Core Delivery Tables Schema**

#### **Table: drivers**
```sql
CREATE TABLE menuca_v3.drivers (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id),

    -- Personal Info
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,

    -- Driver Status
    driver_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (driver_status IN ('pending', 'approved', 'active', 'inactive', 'suspended', 'blocked')),
    availability_status VARCHAR(20) NOT NULL DEFAULT 'offline'
        CHECK (availability_status IN ('online', 'offline', 'busy', 'on_break')),

    -- Vehicle Info
    vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('car', 'bike', 'motorcycle', 'scooter', 'bicycle', 'walk')),
    vehicle_make VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_color VARCHAR(50),
    license_plate VARCHAR(20),

    -- Documents
    driver_license_number VARCHAR(50),
    driver_license_expiry DATE,
    insurance_policy_number VARCHAR(100),
    insurance_expiry DATE,
    background_check_date DATE,
    background_check_status VARCHAR(20) CHECK (background_check_status IN ('pending', 'approved', 'rejected')),

    -- Current Location (real-time)
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    current_heading INTEGER, -- 0-360 degrees
    last_location_update TIMESTAMPTZ,

    -- Ratings & Stats
    average_rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (average_rating >= 0 AND average_rating <= 5),
    total_deliveries INTEGER DEFAULT 0,
    completed_deliveries INTEGER DEFAULT 0,
    cancelled_deliveries INTEGER DEFAULT 0,
    acceptance_rate DECIMAL(5, 2) DEFAULT 100.00, -- Percentage
    completion_rate DECIMAL(5, 2) DEFAULT 100.00,
    on_time_rate DECIMAL(5, 2) DEFAULT 100.00,

    -- Financial
    earnings_total DECIMAL(10, 2) DEFAULT 0.00,
    earnings_pending DECIMAL(10, 2) DEFAULT 0.00,
    earnings_paid DECIMAL(10, 2) DEFAULT 0.00,

    -- Settings
    accepts_cash_orders BOOLEAN DEFAULT true,
    accepts_long_distance BOOLEAN DEFAULT true,
    max_delivery_distance_km DECIMAL(5, 2) DEFAULT 10.00,
    preferred_zones JSONB, -- Array of zone IDs

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by INTEGER REFERENCES menuca_v3.admin_users(id),
    updated_by INTEGER REFERENCES menuca_v3.admin_users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER REFERENCES menuca_v3.admin_users(id),

    -- Legacy tracking
    legacy_v1_id INTEGER,
    legacy_v2_id INTEGER,
    source_system VARCHAR(10),

    CONSTRAINT uq_driver_user UNIQUE (user_id),
    CONSTRAINT uq_driver_phone UNIQUE (phone),
    CONSTRAINT uq_driver_email UNIQUE (email),
    CONSTRAINT uq_driver_license UNIQUE (driver_license_number)
);

-- Indexes
CREATE INDEX idx_drivers_user ON menuca_v3.drivers(user_id);
CREATE INDEX idx_drivers_status ON menuca_v3.drivers(driver_status, availability_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_drivers_location ON menuca_v3.drivers USING GIST (
    ll_to_earth(current_latitude, current_longitude)
) WHERE availability_status = 'online' AND deleted_at IS NULL;
CREATE INDEX idx_drivers_created_at ON menuca_v3.drivers(created_at);
CREATE INDEX idx_drivers_vehicle_type ON menuca_v3.drivers(vehicle_type);

-- Comments
COMMENT ON TABLE menuca_v3.drivers IS 'Delivery drivers/fleet members with status, location, and performance tracking';
COMMENT ON COLUMN menuca_v3.drivers.driver_status IS 'Account status: pending (application), approved (can work), active (working), inactive (paused), suspended (temp ban), blocked (perm ban)';
COMMENT ON COLUMN menuca_v3.drivers.availability_status IS 'Real-time availability: online (accepting orders), offline (not working), busy (on delivery), on_break (unavailable)';
```

#### **Table: delivery_zones**
```sql
CREATE TABLE menuca_v3.delivery_zones (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id),

    -- Zone Info
    zone_name VARCHAR(200) NOT NULL,
    zone_code VARCHAR(50) NOT NULL, -- 'ZONE_A', 'DOWNTOWN', etc.
    description TEXT,

    -- Geospatial (polygon or circle)
    zone_type VARCHAR(20) NOT NULL CHECK (zone_type IN ('polygon', 'circle', 'radius')),
    zone_geometry GEOGRAPHY(POLYGON, 4326), -- PostGIS polygon
    center_latitude DECIMAL(10, 8),
    center_longitude DECIMAL(11, 8),
    radius_km DECIMAL(5, 2), -- For circle/radius zones

    -- Pricing
    base_delivery_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    per_km_fee DECIMAL(10, 2) DEFAULT 0.00,
    minimum_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    free_delivery_threshold DECIMAL(10, 2), -- Free delivery if order > X

    -- Operational
    is_active BOOLEAN NOT NULL DEFAULT true,
    accepts_deliveries BOOLEAN NOT NULL DEFAULT true,
    estimated_delivery_time_minutes INTEGER DEFAULT 30,
    max_delivery_time_minutes INTEGER DEFAULT 60,

    -- Service Hours
    service_hours JSONB, -- {monday: [{start: '09:00', end: '22:00'}], ...}

    -- Priority
    priority INTEGER DEFAULT 1, -- Higher priority zones matched first

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by INTEGER REFERENCES menuca_v3.admin_users(id),
    updated_by INTEGER REFERENCES menuca_v3.admin_users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER REFERENCES menuca_v3.admin_users(id),

    CONSTRAINT uq_zone_code_restaurant UNIQUE (restaurant_id, zone_code)
);

-- Indexes
CREATE INDEX idx_delivery_zones_restaurant ON menuca_v3.delivery_zones(restaurant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_delivery_zones_active ON menuca_v3.delivery_zones(is_active) WHERE is_active = true AND deleted_at IS NULL;
CREATE INDEX idx_delivery_zones_geometry ON menuca_v3.delivery_zones USING GIST (zone_geometry);
CREATE INDEX idx_delivery_zones_center ON menuca_v3.delivery_zones USING GIST (
    ll_to_earth(center_latitude, center_longitude)
);

COMMENT ON TABLE menuca_v3.delivery_zones IS 'Delivery service areas with geofencing, pricing, and operational rules';
```

#### **Table: deliveries**
```sql
CREATE TABLE menuca_v3.deliveries (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES menuca_v3.orders(id),
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
    driver_id BIGINT REFERENCES menuca_v3.drivers(id),
    delivery_zone_id BIGINT REFERENCES menuca_v3.delivery_zones(id),

    -- Addresses
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    pickup_instructions TEXT,

    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10, 8) NOT NULL,
    delivery_longitude DECIMAL(11, 8) NOT NULL,
    delivery_instructions TEXT,
    delivery_unit_number VARCHAR(50),
    delivery_buzzer_code VARCHAR(50),

    -- Distance & Time
    distance_km DECIMAL(10, 2),
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,

    -- Status & Timeline
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (delivery_status IN (
            'pending', 'searching_driver', 'assigned', 'accepted',
            'picked_up', 'in_transit', 'arrived', 'delivered',
            'cancelled', 'failed'
        )),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    pickup_time TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,

    -- Fees & Earnings
    delivery_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    driver_earnings DECIMAL(10, 2) DEFAULT 0.00,
    platform_commission DECIMAL(10, 2) DEFAULT 0.00,
    tip_amount DECIMAL(10, 2) DEFAULT 0.00,

    -- Customer Info
    customer_name VARCHAR(200),
    customer_phone VARCHAR(20),

    -- Rating & Feedback
    customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5),
    customer_feedback TEXT,
    driver_rating INTEGER CHECK (driver_rating >= 1 AND driver_rating <= 5),
    driver_feedback TEXT,

    -- Special Flags
    is_contactless BOOLEAN DEFAULT false,
    is_priority BOOLEAN DEFAULT false,
    is_scheduled BOOLEAN DEFAULT false,
    scheduled_delivery_time TIMESTAMPTZ,

    -- Cancellation
    cancellation_reason VARCHAR(255),
    cancelled_by VARCHAR(50), -- 'customer', 'driver', 'restaurant', 'admin'

    -- Proof of Delivery
    delivery_photo_url TEXT,
    signature_url TEXT,
    delivery_notes TEXT,

    -- Metadata
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER REFERENCES menuca_v3.admin_users(id),

    -- Legacy tracking
    legacy_v1_id INTEGER,
    legacy_v2_id INTEGER
);

-- Indexes
CREATE INDEX idx_deliveries_order ON menuca_v3.deliveries(order_id);
CREATE INDEX idx_deliveries_driver ON menuca_v3.deliveries(driver_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_deliveries_restaurant ON menuca_v3.deliveries(restaurant_id);
CREATE INDEX idx_deliveries_status ON menuca_v3.deliveries(delivery_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_deliveries_created_at ON menuca_v3.deliveries(created_at);
CREATE INDEX idx_deliveries_assigned_at ON menuca_v3.deliveries(assigned_at) WHERE assigned_at IS NOT NULL;
CREATE INDEX idx_deliveries_pickup_location ON menuca_v3.deliveries USING GIST (
    ll_to_earth(pickup_latitude, pickup_longitude)
);
CREATE INDEX idx_deliveries_delivery_location ON menuca_v3.deliveries USING GIST (
    ll_to_earth(delivery_latitude, delivery_longitude)
);

COMMENT ON TABLE menuca_v3.deliveries IS 'Order delivery tracking with driver assignment, locations, and status timeline';
```

#### **Table: driver_locations (Real-time tracking)**
```sql
CREATE TABLE menuca_v3.driver_locations (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL REFERENCES menuca_v3.drivers(id),
    delivery_id BIGINT REFERENCES menuca_v3.deliveries(id),

    -- Location
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy_meters DECIMAL(6, 2),
    heading INTEGER, -- 0-360 degrees
    speed_kmh DECIMAL(5, 2),

    -- Context
    location_source VARCHAR(20) DEFAULT 'gps' CHECK (location_source IN ('gps', 'network', 'manual')),

    -- Timestamp
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Metadata (minimal - high write volume)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (optimized for writes and recent queries)
CREATE INDEX idx_driver_locations_driver_time ON menuca_v3.driver_locations(driver_id, recorded_at DESC);
CREATE INDEX idx_driver_locations_delivery ON menuca_v3.driver_locations(delivery_id) WHERE delivery_id IS NOT NULL;
CREATE INDEX idx_driver_locations_recorded_at ON menuca_v3.driver_locations(recorded_at);

-- Partition by date (for scalability)
-- CREATE TABLE menuca_v3.driver_locations PARTITION BY RANGE (recorded_at);

COMMENT ON TABLE menuca_v3.driver_locations IS 'Real-time GPS tracking history for drivers (high-volume write table)';
```

#### **Table: driver_earnings**
```sql
CREATE TABLE menuca_v3.driver_earnings (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL REFERENCES menuca_v3.drivers(id),
    delivery_id BIGINT REFERENCES menuca_v3.deliveries(id),

    -- Earning Components
    base_earning DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    distance_earning DECIMAL(10, 2) DEFAULT 0.00,
    time_bonus DECIMAL(10, 2) DEFAULT 0.00,
    tip_amount DECIMAL(10, 2) DEFAULT 0.00,
    surge_bonus DECIMAL(10, 2) DEFAULT 0.00,
    total_earning DECIMAL(10, 2) NOT NULL,

    -- Platform Fees
    platform_commission DECIMAL(10, 2) DEFAULT 0.00,
    net_earning DECIMAL(10, 2) NOT NULL,

    -- Status
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'approved', 'paid', 'disputed', 'refunded')),

    -- Payout Info
    payout_batch_id BIGINT,
    paid_at TIMESTAMPTZ,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),

    -- Metadata
    earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,

    CONSTRAINT fk_driver_earnings_driver FOREIGN KEY (driver_id) REFERENCES menuca_v3.drivers(id)
);

-- Indexes
CREATE INDEX idx_driver_earnings_driver ON menuca_v3.driver_earnings(driver_id);
CREATE INDEX idx_driver_earnings_delivery ON menuca_v3.driver_earnings(delivery_id);
CREATE INDEX idx_driver_earnings_status ON menuca_v3.driver_earnings(payment_status, earned_at);
CREATE INDEX idx_driver_earnings_payout_batch ON menuca_v3.driver_earnings(payout_batch_id) WHERE payout_batch_id IS NOT NULL;
CREATE INDEX idx_driver_earnings_earned_at ON menuca_v3.driver_earnings(earned_at);

COMMENT ON TABLE menuca_v3.driver_earnings IS 'Driver payment records with earning breakdowns and payout tracking';
```

---

### **1.2 Enable Row-Level Security (RLS)**

#### **Step 1.2.1: Enable RLS on All Delivery Tables**

```sql
-- Enable RLS
ALTER TABLE menuca_v3.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.driver_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.driver_earnings ENABLE ROW LEVEL SECURITY;
```

#### **Step 1.2.2: Create RLS Helper Functions**

```sql
-- Check if user is a driver
CREATE OR REPLACE FUNCTION menuca_v3.is_driver()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM menuca_v3.drivers
        WHERE user_id = auth.uid()
        AND deleted_at IS NULL
    );
$$;

-- Get current driver ID
CREATE OR REPLACE FUNCTION menuca_v3.get_current_driver_id()
RETURNS BIGINT
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT id FROM menuca_v3.drivers
    WHERE user_id = auth.uid()
    AND deleted_at IS NULL
    LIMIT 1;
$$;

-- Check if user can access delivery
CREATE OR REPLACE FUNCTION menuca_v3.can_access_delivery(p_delivery_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
    v_driver_id BIGINT;
    v_restaurant_id BIGINT;
BEGIN
    -- Super admin can access all
    IF menuca_v3.is_super_admin() THEN
        RETURN true;
    END IF;

    -- Get delivery info
    SELECT driver_id, restaurant_id
    INTO v_driver_id, v_restaurant_id
    FROM menuca_v3.deliveries
    WHERE id = p_delivery_id;

    -- Driver can access their own deliveries
    IF v_driver_id = menuca_v3.get_current_driver_id() THEN
        RETURN true;
    END IF;

    -- Restaurant admin can access their deliveries
    IF menuca_v3.can_access_restaurant(v_restaurant_id) THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$;
```

#### **Step 1.2.3: Create RLS Policies**

**Policy 1: Drivers Table (Drivers see only their own profile)**
```sql
-- Drivers can view their own profile
CREATE POLICY "drivers_view_own_profile" ON menuca_v3.drivers
    FOR SELECT
    USING (user_id = auth.uid() OR menuca_v3.is_super_admin());

-- Drivers can update their own profile (limited fields)
CREATE POLICY "drivers_update_own_profile" ON menuca_v3.drivers
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Super admins can do everything
CREATE POLICY "super_admin_full_access_drivers" ON menuca_v3.drivers
    FOR ALL
    USING (menuca_v3.is_super_admin());

-- Restaurant admins can view drivers (for delivery tracking)
CREATE POLICY "restaurant_admin_view_drivers" ON menuca_v3.drivers
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM menuca_v3.admin_user_restaurants
            WHERE user_id = auth.uid()
        )
    );
```

**Policy 2: Delivery Zones (Restaurant-specific)**
```sql
-- Public can read active zones (for delivery cost calculation)
CREATE POLICY "public_read_delivery_zones" ON menuca_v3.delivery_zones
    FOR SELECT
    USING (is_active = true AND deleted_at IS NULL);

-- Restaurant admins manage their zones
CREATE POLICY "restaurant_admin_manage_zones" ON menuca_v3.delivery_zones
    FOR ALL
    USING (menuca_v3.can_access_restaurant(restaurant_id))
    WITH CHECK (menuca_v3.can_access_restaurant(restaurant_id));

-- Super admin full access
CREATE POLICY "super_admin_full_access_zones" ON menuca_v3.delivery_zones
    FOR ALL
    USING (menuca_v3.is_super_admin());
```

**Policy 3: Deliveries (Multi-party access)**
```sql
-- Drivers can view their assigned/accepted deliveries
CREATE POLICY "drivers_view_own_deliveries" ON menuca_v3.deliveries
    FOR SELECT
    USING (
        driver_id = menuca_v3.get_current_driver_id()
        OR delivery_status = 'searching_driver' -- See available deliveries
        OR menuca_v3.is_super_admin()
    );

-- Drivers can update their delivery status
CREATE POLICY "drivers_update_own_deliveries" ON menuca_v3.deliveries
    FOR UPDATE
    USING (driver_id = menuca_v3.get_current_driver_id())
    WITH CHECK (driver_id = menuca_v3.get_current_driver_id());

-- Restaurant admins can view their restaurant's deliveries
CREATE POLICY "restaurant_admin_view_deliveries" ON menuca_v3.deliveries
    FOR SELECT
    USING (menuca_v3.can_access_restaurant(restaurant_id));

-- Super admin full access
CREATE POLICY "super_admin_full_access_deliveries" ON menuca_v3.deliveries
    FOR ALL
    USING (menuca_v3.is_super_admin());

-- System can create deliveries (order creation)
CREATE POLICY "authenticated_create_deliveries" ON menuca_v3.deliveries
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');
```

**Policy 4: Driver Locations (Privacy protection)**
```sql
-- Drivers can insert their own locations
CREATE POLICY "drivers_insert_own_locations" ON menuca_v3.driver_locations
    FOR INSERT
    WITH CHECK (driver_id = menuca_v3.get_current_driver_id());

-- Drivers can view their own location history
CREATE POLICY "drivers_view_own_locations" ON menuca_v3.driver_locations
    FOR SELECT
    USING (
        driver_id = menuca_v3.get_current_driver_id()
        OR menuca_v3.is_super_admin()
    );

-- Restaurant admins can view locations for active deliveries
CREATE POLICY "restaurant_admin_view_active_delivery_locations" ON menuca_v3.driver_locations
    FOR SELECT
    USING (
        delivery_id IN (
            SELECT id FROM menuca_v3.deliveries
            WHERE restaurant_id IN (
                SELECT restaurant_id
                FROM menuca_v3.admin_user_restaurants
                WHERE user_id = auth.uid()
            )
            AND delivery_status IN ('accepted', 'picked_up', 'in_transit', 'arrived')
        )
    );

-- Super admin full access
CREATE POLICY "super_admin_full_access_locations" ON menuca_v3.driver_locations
    FOR ALL
    USING (menuca_v3.is_super_admin());
```

**Policy 5: Driver Earnings (Financial security - CRITICAL)**
```sql
-- Drivers can ONLY view their own earnings (NO UPDATE/DELETE)
CREATE POLICY "drivers_view_own_earnings" ON menuca_v3.driver_earnings
    FOR SELECT
    USING (
        driver_id = menuca_v3.get_current_driver_id()
        OR menuca_v3.is_super_admin()
    );

-- ONLY super admins and finance team can modify earnings
CREATE POLICY "super_admin_manage_earnings" ON menuca_v3.driver_earnings
    FOR ALL
    USING (menuca_v3.is_super_admin());

-- System can insert earnings (automated)
CREATE POLICY "system_insert_earnings" ON menuca_v3.driver_earnings
    FOR INSERT
    WITH CHECK (auth.role() = 'service_role' OR menuca_v3.is_super_admin());
```

---

### **1.3 Grant Permissions**

```sql
-- Grant table access
GRANT SELECT ON menuca_v3.drivers TO authenticated, anon;
GRANT SELECT ON menuca_v3.delivery_zones TO authenticated, anon;
GRANT SELECT ON menuca_v3.deliveries TO authenticated;
GRANT SELECT ON menuca_v3.driver_locations TO authenticated;
GRANT SELECT ON menuca_v3.driver_earnings TO authenticated;

-- Grant function access
GRANT EXECUTE ON FUNCTION menuca_v3.is_driver TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.get_current_driver_id TO authenticated;
GRANT EXECUTE ON FUNCTION menuca_v3.can_access_delivery TO authenticated;
```

---

## 📊 **PHASE 2: PERFORMANCE & APIS (HIGH PRIORITY)**

**Priority:** 🔴 HIGH
**Duration:** 5-7 hours
**Risk:** 🟢 LOW (additive only)

---

### **2.1 Geospatial Indexes & Functions**

#### **Step 2.1.1: Enable PostGIS Extension**

```sql
-- Enable PostGIS for advanced geospatial features
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;
```

#### **Step 2.1.2: Create Geospatial Helper Functions**

```sql
-- Calculate distance between two points (Haversine formula)
CREATE OR REPLACE FUNCTION menuca_v3.calculate_distance_km(
    lat1 DECIMAL, lon1 DECIMAL,
    lat2 DECIMAL, lon2 DECIMAL
)
RETURNS DECIMAL
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN (
        earth_distance(
            ll_to_earth(lat1, lon1),
            ll_to_earth(lat2, lon2)
        ) / 1000
    )::DECIMAL(10, 2); -- Convert meters to km
END;
$$;

-- Find nearest available drivers
CREATE OR REPLACE FUNCTION menuca_v3.find_nearby_drivers(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_max_distance_km DECIMAL DEFAULT 5.0,
    p_vehicle_type VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    driver_id BIGINT,
    driver_name VARCHAR,
    vehicle_type VARCHAR,
    distance_km DECIMAL,
    average_rating DECIMAL,
    current_latitude DECIMAL,
    current_longitude DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.first_name || ' ' || d.last_name AS driver_name,
        d.vehicle_type,
        menuca_v3.calculate_distance_km(
            p_latitude, p_longitude,
            d.current_latitude, d.current_longitude
        ) AS distance_km,
        d.average_rating,
        d.current_latitude,
        d.current_longitude
    FROM menuca_v3.drivers d
    WHERE d.availability_status = 'online'
        AND d.driver_status = 'active'
        AND d.deleted_at IS NULL
        AND d.current_latitude IS NOT NULL
        AND d.current_longitude IS NOT NULL
        AND (p_vehicle_type IS NULL OR d.vehicle_type = p_vehicle_type)
        AND menuca_v3.calculate_distance_km(
            p_latitude, p_longitude,
            d.current_latitude, d.current_longitude
        ) <= p_max_distance_km
    ORDER BY distance_km ASC, d.average_rating DESC
    LIMIT p_limit;
END;
$$;

-- Check if location is in delivery zone
CREATE OR REPLACE FUNCTION menuca_v3.is_location_in_zone(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_zone_id BIGINT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_zone_type VARCHAR(20);
    v_radius_km DECIMAL;
    v_center_lat DECIMAL;
    v_center_lon DECIMAL;
    v_distance DECIMAL;
BEGIN
    -- Get zone info
    SELECT zone_type, radius_km, center_latitude, center_longitude
    INTO v_zone_type, v_radius_km, v_center_lat, v_center_lon
    FROM menuca_v3.delivery_zones
    WHERE id = p_zone_id
        AND is_active = true
        AND deleted_at IS NULL;

    IF NOT FOUND THEN
        RETURN false;
    END IF;

    -- Check based on zone type
    IF v_zone_type IN ('circle', 'radius') THEN
        v_distance := menuca_v3.calculate_distance_km(
            p_latitude, p_longitude,
            v_center_lat, v_center_lon
        );
        RETURN v_distance <= v_radius_km;
    ELSIF v_zone_type = 'polygon' THEN
        -- PostGIS polygon check (requires zone_geometry populated)
        RETURN EXISTS (
            SELECT 1 FROM menuca_v3.delivery_zones
            WHERE id = p_zone_id
            AND ST_Contains(
                zone_geometry::geometry,
                ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)
            )
        );
    END IF;

    RETURN false;
END;
$$;

-- Find matching delivery zone for address
CREATE OR REPLACE FUNCTION menuca_v3.find_delivery_zone(
    p_restaurant_id BIGINT,
    p_latitude DECIMAL,
    p_longitude DECIMAL
)
RETURNS TABLE (
    zone_id BIGINT,
    zone_name VARCHAR,
    delivery_fee DECIMAL,
    estimated_time INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        dz.id,
        dz.zone_name,
        dz.base_delivery_fee,
        dz.estimated_delivery_time_minutes
    FROM menuca_v3.delivery_zones dz
    WHERE dz.restaurant_id = p_restaurant_id
        AND dz.is_active = true
        AND dz.accepts_deliveries = true
        AND dz.deleted_at IS NULL
        AND menuca_v3.is_location_in_zone(p_latitude, p_longitude, dz.id)
    ORDER BY dz.priority DESC
    LIMIT 1;
END;
$$;
```

---

### **2.2 Driver Assignment Algorithm**

```sql
-- Smart driver assignment (closest + best rating + availability)
CREATE OR REPLACE FUNCTION menuca_v3.assign_driver_to_delivery(
    p_delivery_id BIGINT,
    p_auto_assign BOOLEAN DEFAULT false
)
RETURNS BIGINT -- Returns assigned driver_id
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_pickup_lat DECIMAL;
    v_pickup_lon DECIMAL;
    v_restaurant_id BIGINT;
    v_assigned_driver_id BIGINT;
    v_distance_km DECIMAL;
BEGIN
    -- Get delivery info
    SELECT pickup_latitude, pickup_longitude, restaurant_id
    INTO v_pickup_lat, v_pickup_lon, v_restaurant_id
    FROM menuca_v3.deliveries
    WHERE id = p_delivery_id
        AND delivery_status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Delivery not found or not in pending status';
    END IF;

    -- Find best available driver
    SELECT driver_id, distance_km
    INTO v_assigned_driver_id, v_distance_km
    FROM menuca_v3.find_nearby_drivers(
        v_pickup_lat, v_pickup_lon,
        10.0, -- Max 10km radius
        NULL, -- Any vehicle type
        1     -- Get only 1 driver
    )
    LIMIT 1;

    IF v_assigned_driver_id IS NULL THEN
        -- No driver available
        UPDATE menuca_v3.deliveries
        SET delivery_status = 'searching_driver',
            updated_at = NOW()
        WHERE id = p_delivery_id;

        RETURN NULL;
    END IF;

    -- Assign driver
    UPDATE menuca_v3.deliveries
    SET
        driver_id = v_assigned_driver_id,
        delivery_status = CASE
            WHEN p_auto_assign THEN 'assigned'
            ELSE 'searching_driver'
        END,
        assigned_at = NOW(),
        distance_km = v_distance_km,
        updated_at = NOW()
    WHERE id = p_delivery_id;

    -- Update driver stats
    UPDATE menuca_v3.drivers
    SET
        availability_status = CASE
            WHEN p_auto_assign THEN 'busy'
            ELSE availability_status
        END,
        total_deliveries = total_deliveries + 1,
        updated_at = NOW()
    WHERE id = v_assigned_driver_id;

    -- Notify driver (via pg_notify)
    PERFORM pg_notify('driver_new_delivery', json_build_object(
        'driver_id', v_assigned_driver_id,
        'delivery_id', p_delivery_id,
        'restaurant_id', v_restaurant_id,
        'distance_km', v_distance_km
    )::text);

    RETURN v_assigned_driver_id;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.assign_driver_to_delivery TO authenticated, service_role;
```

---

### **2.3 Performance Indexes**

```sql
-- Composite indexes for common queries
CREATE INDEX idx_drivers_availability_rating ON menuca_v3.drivers(
    availability_status, average_rating DESC
) WHERE driver_status = 'active' AND deleted_at IS NULL;

CREATE INDEX idx_deliveries_driver_status ON menuca_v3.deliveries(
    driver_id, delivery_status, created_at DESC
);

CREATE INDEX idx_deliveries_restaurant_status ON menuca_v3.deliveries(
    restaurant_id, delivery_status, created_at DESC
);

CREATE INDEX idx_driver_earnings_driver_date ON menuca_v3.driver_earnings(
    driver_id, earned_at DESC
);

CREATE INDEX idx_driver_earnings_pending_payout ON menuca_v3.driver_earnings(
    payment_status, earned_at
) WHERE payment_status = 'pending';
```

---

## 🏗️ **PHASE 3: SCHEMA OPTIMIZATION (MEDIUM PRIORITY)**

**Priority:** 🟡 MEDIUM
**Duration:** 8-10 hours
**Risk:** 🟡 MEDIUM (data migration required)

### **3.1 Add Missing Constraints & Validations**

```sql
-- Add check constraints
ALTER TABLE menuca_v3.drivers
    ADD CONSTRAINT chk_drivers_rating_range
        CHECK (average_rating >= 0 AND average_rating <= 5);

ALTER TABLE menuca_v3.drivers
    ADD CONSTRAINT chk_drivers_rates_valid
        CHECK (acceptance_rate >= 0 AND acceptance_rate <= 100);

ALTER TABLE menuca_v3.deliveries
    ADD CONSTRAINT chk_deliveries_ratings
        CHECK (
            (customer_rating IS NULL OR (customer_rating >= 1 AND customer_rating <= 5))
            AND (driver_rating IS NULL OR (driver_rating >= 1 AND driver_rating <= 5))
        );

ALTER TABLE menuca_v3.driver_earnings
    ADD CONSTRAINT chk_earnings_positive
        CHECK (total_earning >= 0 AND net_earning >= 0);
```

### **3.2 Create Enum Types**

```sql
-- Driver status enum
CREATE TYPE menuca_v3.driver_status_type AS ENUM (
    'pending', 'approved', 'active', 'inactive', 'suspended', 'blocked'
);

-- Availability enum
CREATE TYPE menuca_v3.availability_status_type AS ENUM (
    'online', 'offline', 'busy', 'on_break'
);

-- Delivery status enum
CREATE TYPE menuca_v3.delivery_status_type AS ENUM (
    'pending', 'searching_driver', 'assigned', 'accepted',
    'picked_up', 'in_transit', 'arrived', 'delivered',
    'cancelled', 'failed'
);

-- Vehicle type enum
CREATE TYPE menuca_v3.vehicle_type_enum AS ENUM (
    'car', 'bike', 'motorcycle', 'scooter', 'bicycle', 'walk'
);

-- Apply enums to tables (requires data migration)
-- ALTER TABLE menuca_v3.drivers ALTER COLUMN driver_status TYPE menuca_v3.driver_status_type USING driver_status::menuca_v3.driver_status_type;
```

---

## 🚀 **PHASE 4: REAL-TIME TRACKING (HIGH PRIORITY)**

**Priority:** 🔴 HIGH
**Duration:** 6-8 hours
**Risk:** 🟢 LOW (additive features)

### **4.1 Enable Realtime on Delivery Tables**

```sql
-- Enable realtime subscriptions
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.driver_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.drivers;
```

### **4.2 Create Real-time Triggers**

```sql
-- Trigger: Notify on delivery status change
CREATE OR REPLACE FUNCTION menuca_v3.notify_delivery_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only notify on status change
    IF (TG_OP = 'UPDATE' AND OLD.delivery_status != NEW.delivery_status)
       OR TG_OP = 'INSERT' THEN

        PERFORM pg_notify('delivery_status_changed', json_build_object(
            'delivery_id', NEW.id,
            'order_id', NEW.order_id,
            'driver_id', NEW.driver_id,
            'restaurant_id', NEW.restaurant_id,
            'old_status', OLD.delivery_status,
            'new_status', NEW.delivery_status,
            'timestamp', NOW()
        )::text);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_notify_delivery_status_change
    AFTER INSERT OR UPDATE ON menuca_v3.deliveries
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_delivery_status_change();

-- Trigger: Update driver location in drivers table
CREATE OR REPLACE FUNCTION menuca_v3.update_driver_current_location()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE menuca_v3.drivers
    SET
        current_latitude = NEW.latitude,
        current_longitude = NEW.longitude,
        current_heading = NEW.heading,
        last_location_update = NEW.recorded_at
    WHERE id = NEW.driver_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_driver_current_location
    AFTER INSERT ON menuca_v3.driver_locations
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.update_driver_current_location();
```

### **4.3 Real-time Location Tracking API**

```sql
-- Function: Update driver location (called from mobile app)
CREATE OR REPLACE FUNCTION menuca_v3.update_driver_location(
    p_latitude DECIMAL,
    p_longitude DECIMAL,
    p_accuracy DECIMAL DEFAULT NULL,
    p_heading INTEGER DEFAULT NULL,
    p_speed DECIMAL DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_driver_id BIGINT;
    v_active_delivery_id BIGINT;
BEGIN
    -- Get current driver
    v_driver_id := menuca_v3.get_current_driver_id();

    IF v_driver_id IS NULL THEN
        RAISE EXCEPTION 'Not a driver or driver not found';
    END IF;

    -- Get active delivery (if any)
    SELECT id INTO v_active_delivery_id
    FROM menuca_v3.deliveries
    WHERE driver_id = v_driver_id
        AND delivery_status IN ('accepted', 'picked_up', 'in_transit')
    ORDER BY accepted_at DESC
    LIMIT 1;

    -- Insert location record
    INSERT INTO menuca_v3.driver_locations (
        driver_id,
        delivery_id,
        latitude,
        longitude,
        accuracy_meters,
        heading,
        speed_kmh,
        recorded_at
    ) VALUES (
        v_driver_id,
        v_active_delivery_id,
        p_latitude,
        p_longitude,
        p_accuracy,
        p_heading,
        p_speed,
        NOW()
    );

    -- Notify subscribers (real-time tracking)
    IF v_active_delivery_id IS NOT NULL THEN
        PERFORM pg_notify('driver_location_updated', json_build_object(
            'driver_id', v_driver_id,
            'delivery_id', v_active_delivery_id,
            'latitude', p_latitude,
            'longitude', p_longitude,
            'heading', p_heading,
            'timestamp', NOW()
        )::text);
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.update_driver_location TO authenticated;
```

---

## 🔄 **PHASE 5: SOFT DELETE & AUDIT (LOW PRIORITY)**

**Priority:** 🟢 LOW
**Duration:** 3-4 hours

### **5.1 Soft Delete Functions**

```sql
-- Soft delete driver
CREATE OR REPLACE FUNCTION menuca_v3.soft_delete_driver(p_driver_id BIGINT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT menuca_v3.is_super_admin() THEN
        RAISE EXCEPTION 'Only super admins can delete drivers';
    END IF;

    UPDATE menuca_v3.drivers
    SET
        deleted_at = NOW(),
        deleted_by = (auth.uid())::INTEGER,
        driver_status = 'blocked',
        availability_status = 'offline'
    WHERE id = p_driver_id;
END;
$$;

-- Create active-only views
CREATE OR REPLACE VIEW menuca_v3.active_drivers AS
SELECT * FROM menuca_v3.drivers WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW menuca_v3.active_delivery_zones AS
SELECT * FROM menuca_v3.delivery_zones WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW menuca_v3.active_deliveries AS
SELECT * FROM menuca_v3.deliveries WHERE deleted_at IS NULL;

GRANT SELECT ON menuca_v3.active_drivers TO authenticated;
GRANT SELECT ON menuca_v3.active_delivery_zones TO authenticated, anon;
GRANT SELECT ON menuca_v3.active_deliveries TO authenticated;
```

---

## 🌍 **PHASE 6: MULTI-LANGUAGE SUPPORT (LOW PRIORITY)**

**Priority:** 🟢 LOW
**Duration:** 2-3 hours

### **6.1 Translation Tables**

```sql
-- Delivery zone translations
CREATE TABLE menuca_v3.delivery_zone_translations (
    id BIGSERIAL PRIMARY KEY,
    delivery_zone_id BIGINT NOT NULL REFERENCES menuca_v3.delivery_zones(id) ON DELETE CASCADE,
    language_code VARCHAR(5) NOT NULL CHECK (language_code IN ('en', 'fr', 'es')),

    zone_name VARCHAR(200) NOT NULL,
    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,

    CONSTRAINT uq_zone_translation UNIQUE (delivery_zone_id, language_code)
);

CREATE INDEX idx_zone_translations_zone ON menuca_v3.delivery_zone_translations(delivery_zone_id);
CREATE INDEX idx_zone_translations_language ON menuca_v3.delivery_zone_translations(language_code);

ALTER TABLE menuca_v3.delivery_zone_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_zone_translations" ON menuca_v3.delivery_zone_translations
    FOR SELECT
    USING (true);

GRANT SELECT ON menuca_v3.delivery_zone_translations TO anon, authenticated;
```

---

## ✅ **PHASE 7: TESTING & VALIDATION (CRITICAL)**

**Priority:** 🔴 CRITICAL
**Duration:** 4-5 hours

### **7.1 RLS Policy Tests**

```sql
-- Test 1: Driver can only see own profile
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = '<driver_user_uuid>';
SELECT * FROM menuca_v3.drivers; -- Should return only 1 row (their profile)

-- Test 2: Driver cannot see other driver earnings
SELECT * FROM menuca_v3.driver_earnings WHERE driver_id != menuca_v3.get_current_driver_id();
-- Should return 0 rows

-- Test 3: Restaurant admin can view their deliveries
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = '<restaurant_admin_uuid>';
SELECT COUNT(*) FROM menuca_v3.deliveries WHERE restaurant_id = <their_restaurant_id>;
-- Should return their deliveries

-- Test 4: Driver assignment works
SELECT menuca_v3.assign_driver_to_delivery(123, false);
-- Should return driver_id or NULL
```

### **7.2 Performance Benchmarks**

```sql
-- Benchmark 1: Find nearby drivers (target < 100ms)
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.find_nearby_drivers(45.5017, -73.5673, 5.0, NULL, 10);

-- Benchmark 2: Check zone coverage (target < 50ms)
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.find_delivery_zone(123, 45.5017, -73.5673);

-- Benchmark 3: Driver location insert (target < 20ms - HIGH VOLUME)
EXPLAIN ANALYZE
INSERT INTO menuca_v3.driver_locations (driver_id, latitude, longitude)
VALUES (1, 45.5017, -73.5673);
```

### **7.3 Data Integrity Validation**

```sql
-- Validation 1: All deliveries have valid orders
SELECT COUNT(*) FROM menuca_v3.deliveries d
LEFT JOIN menuca_v3.orders o ON d.order_id = o.id
WHERE o.id IS NULL;
-- Expected: 0

-- Validation 2: All active deliveries have valid drivers
SELECT COUNT(*) FROM menuca_v3.deliveries d
LEFT JOIN menuca_v3.drivers dr ON d.driver_id = dr.id
WHERE d.delivery_status IN ('assigned', 'accepted', 'picked_up', 'in_transit')
    AND dr.id IS NULL;
-- Expected: 0

-- Validation 3: All earnings match deliveries
SELECT COUNT(*) FROM menuca_v3.driver_earnings e
LEFT JOIN menuca_v3.deliveries d ON e.delivery_id = d.id
WHERE e.delivery_id IS NOT NULL AND d.id IS NULL;
-- Expected: 0
```

---

## 📊 **SUCCESS CRITERIA**

### **Phase 1: Auth & Security**
- [x] 5 core tables created (drivers, delivery_zones, deliveries, driver_locations, driver_earnings)
- [ ] RLS enabled on all tables
- [ ] 20+ RLS policies created
- [ ] Financial data protected (earnings table secured)
- [ ] Multi-party access working (drivers, restaurants, admins)

### **Phase 2: Performance & APIs**
- [ ] PostGIS enabled
- [ ] Geospatial functions created (distance calculation, zone matching)
- [ ] Driver assignment algorithm implemented
- [ ] Performance indexes created (10+ indexes)
- [ ] Nearby driver search < 100ms

### **Phase 3: Schema Optimization**
- [ ] Constraints added (ratings, earnings validation)
- [ ] Enum types created (status enums)
- [ ] Data integrity enforced

### **Phase 4: Real-time Tracking**
- [ ] Realtime enabled on 3 tables
- [ ] Location update triggers created
- [ ] pg_notify for status changes
- [ ] Driver location API function created

### **Phase 5: Soft Delete & Audit**
- [ ] Soft delete columns on all tables
- [ ] Active-only views created
- [ ] Soft delete functions

### **Phase 6: Multi-language**
- [ ] Translation table for zones
- [ ] RLS policies for translations

### **Phase 7: Testing**
- [ ] All RLS tests passing
- [ ] Performance benchmarks met
- [ ] Data integrity validated

---

## 📁 **DELIVERABLES**

### **SQL Scripts**
1. `phase1_auth_security.sql` - Tables, RLS, policies
2. `phase2_performance_apis.sql` - Geospatial functions, indexes
3. `phase3_schema_optimization.sql` - Constraints, enums
4. `phase4_realtime_tracking.sql` - Triggers, notifications
5. `phase5_soft_delete.sql` - Soft delete, views
6. `phase6_multilanguage.sql` - Translation tables
7. `phase7_testing_validation.sql` - Test queries

### **Backend Documentation (After EACH Phase)**
1. `PHASE_1_BACKEND_DOCUMENTATION.md` - Auth & security guide for Santiago
2. `PHASE_2_BACKEND_DOCUMENTATION.md` - API endpoints, geospatial usage
3. `PHASE_3_BACKEND_DOCUMENTATION.md` - Schema reference
4. `PHASE_4_BACKEND_DOCUMENTATION.md` - Real-time integration guide
5. `PHASE_5_BACKEND_DOCUMENTATION.md` - Soft delete patterns
6. `PHASE_6_BACKEND_DOCUMENTATION.md` - Translation API
7. `PHASE_7_BACKEND_DOCUMENTATION.md` - Testing checklist

---

## ⚠️ **CRITICAL DEPENDENCIES**

### **BLOCKER: Orders Table Required**
Delivery Operations **cannot be fully implemented** without the Orders table existing first.

**Temporary Solution for Development:**
```sql
-- Stub orders table for development (REMOVE when real orders table exists)
CREATE TABLE IF NOT EXISTS menuca_v3.orders (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    customer_id BIGINT,
    order_status VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Coordination with Santiago:**
- Wait for Orders & Checkout entity (Priority 7) to be completed
- Or implement orders table stub for parallel development
- Ensure FK constraints added when orders table ready

---

## 🚀 **EXECUTION PLAN**

**START DATE:** January 17, 2025
**TARGET COMPLETION:** January 24-31, 2025 (1-2 weeks)

### **Day 1-2: Phase 1 (Auth & Security)** ✅ READY TO START
- Create all 5 core tables
- Enable RLS
- Create RLS policies
- Test multi-party access
- **DELIVERABLE:** Phase 1 Backend Documentation for Santiago

### **Day 3: Phase 2 (Performance & APIs)**
- Enable PostGIS
- Create geospatial functions
- Implement driver assignment
- Add performance indexes
- **DELIVERABLE:** Phase 2 Backend Documentation

### **Day 4: Phase 3 (Schema Optimization)**
- Add constraints
- Create enums
- Data validation
- **DELIVERABLE:** Phase 3 Backend Documentation

### **Day 5: Phase 4 (Real-time Tracking)**
- Enable Realtime
- Create triggers
- Location tracking API
- **DELIVERABLE:** Phase 4 Backend Documentation

### **Day 6: Phase 5-6 (Soft Delete & Multi-language)**
- Soft delete implementation
- Translation tables
- **DELIVERABLE:** Phase 5 & 6 Backend Documentation

### **Day 7: Phase 7 (Testing & Validation)**
- RLS tests
- Performance benchmarks
- Data integrity checks
- **DELIVERABLE:** Final testing documentation

---

**Ready to start Phase 1: Auth & Security!** 🚀
