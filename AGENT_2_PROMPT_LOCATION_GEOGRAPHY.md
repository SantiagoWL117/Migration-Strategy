# 🤖 Agent 2 Mission - Location & Geography Refactoring

**Entity:** Location & Geography  
**Priority:** 5 (Foundation for delivery zones, search, maps)  
**Status:** ⚠️ MIGRATED (needs Santiago refactoring)  
**Date:** October 17, 2025  

---

## 🎯 **YOUR MISSION:**

Refactor the Location & Geography entity to Santiago's standards with full RLS, performance optimization, and production-ready geospatial APIs.

---

## 📋 **CURRENT STATE:**

✅ **Data Migrated:**
- `menuca_v3.provinces` - Canadian provinces
- `menuca_v3.cities` - Cities in provinces
- `menuca_v3.restaurant_locations` - Restaurant physical locations with lat/lng

❌ **Missing Santiago Standards:**
- No RLS policies
- No tenant_id for multi-tenant isolation
- No API functions (search by city, distance calc, etc.)
- No audit trails
- No soft delete
- No multi-language support (city names in EN/FR)
- No Santiago documentation

---

## 🔧 **YOUR REFACTORING WORKFLOW:**

### **STEP 1: Review Current Schema**

Use Supabase MCP to inspect:
```sql
-- Check table structures
SELECT * FROM menuca_v3.provinces LIMIT 5;
SELECT * FROM menuca_v3.cities LIMIT 5;
SELECT * FROM menuca_v3.restaurant_locations LIMIT 5;

-- Check existing indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename IN ('provinces', 'cities', 'restaurant_locations');

-- Check RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('provinces', 'cities', 'restaurant_locations');
```

---

### **PHASE 1: Auth & Security** 🔐

**Goal:** Enable RLS and create access policies

#### **1.1 Add tenant_id (if needed for restaurant_locations):**
```sql
-- Check if tenant_id exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'restaurant_locations' 
AND table_schema = 'menuca_v3';

-- If missing, add it:
ALTER TABLE menuca_v3.restaurant_locations 
ADD COLUMN tenant_id UUID REFERENCES menuca_v3.restaurants(id);

-- Backfill from existing restaurant_id
UPDATE menuca_v3.restaurant_locations 
SET tenant_id = restaurant_id 
WHERE tenant_id IS NULL;
```

#### **1.2 Enable RLS:**
```sql
ALTER TABLE menuca_v3.provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_locations ENABLE ROW LEVEL SECURITY;
```

#### **1.3 Create RLS Policies:**

**For `provinces` (Public data):**
```sql
-- Everyone can read provinces
CREATE POLICY "provinces_select_all" 
ON menuca_v3.provinces FOR SELECT 
TO authenticated, anon 
USING (true);

-- Service role can manage
CREATE POLICY "provinces_service_role_all" 
ON menuca_v3.provinces FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

**For `cities` (Public data):**
```sql
-- Everyone can read cities
CREATE POLICY "cities_select_all" 
ON menuca_v3.cities FOR SELECT 
TO authenticated, anon 
USING (true);

-- Service role can manage
CREATE POLICY "cities_service_role_all" 
ON menuca_v3.cities FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

**For `restaurant_locations` (Multi-tenant):**
```sql
-- Public can view all active restaurant locations
CREATE POLICY "locations_select_all" 
ON menuca_v3.restaurant_locations FOR SELECT 
TO authenticated, anon 
USING (deleted_at IS NULL);

-- Restaurant admins can manage their locations
CREATE POLICY "locations_manage_restaurant_admin" 
ON menuca_v3.restaurant_locations FOR ALL 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = restaurant_locations.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = restaurant_locations.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Service role has full access
CREATE POLICY "locations_service_role_all" 
ON menuca_v3.restaurant_locations FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

#### **1.4 Validate Policies:**
```sql
-- Count policies created
SELECT schemaname, tablename, policyname, cmd, roles 
FROM pg_policies 
WHERE tablename IN ('provinces', 'cities', 'restaurant_locations');
```

#### **1.5 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_1_AUTH_SECURITY_SUMMARY.md` with:
- Business problem
- Solution
- Gained business logic
- Backend requirements
- Schema modifications

---

### **PHASE 2: Performance & Geospatial APIs** ⚡

**Goal:** Create SQL functions for location-based features

#### **2.1 Core Geospatial Functions:**

```sql
-- Get restaurants near coordinates
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurants_near_location(
  p_latitude DECIMAL(10,8),
  p_longitude DECIMAL(11,8),
  p_radius_km INTEGER DEFAULT 10,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  restaurant_id UUID,
  restaurant_name TEXT,
  address TEXT,
  distance_km DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    rl.restaurant_id,
    r.name,
    rl.address,
    -- Haversine formula for distance
    (
      6371 * acos(
        cos(radians(p_latitude)) * 
        cos(radians(rl.latitude)) * 
        cos(radians(rl.longitude) - radians(p_longitude)) + 
        sin(radians(p_latitude)) * 
        sin(radians(rl.latitude))
      )
    ) AS distance_km
  FROM menuca_v3.restaurant_locations rl
  JOIN menuca_v3.restaurants r ON r.id = rl.restaurant_id
  WHERE rl.deleted_at IS NULL
  AND r.deleted_at IS NULL
  ORDER BY distance_km
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get cities in a province
CREATE OR REPLACE FUNCTION menuca_v3.get_cities_by_province(
  p_province_id UUID
)
RETURNS TABLE (
  city_id UUID,
  city_name TEXT,
  city_name_fr TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.name_fr
  FROM menuca_v3.cities c
  WHERE c.province_id = p_province_id
  ORDER BY c.name;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get all provinces
CREATE OR REPLACE FUNCTION menuca_v3.get_all_provinces()
RETURNS TABLE (
  province_id UUID,
  province_name TEXT,
  province_code TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    p.code
  FROM menuca_v3.provinces p
  ORDER BY p.name;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Search cities by name
CREATE OR REPLACE FUNCTION menuca_v3.search_cities(
  p_search_term TEXT,
  p_language TEXT DEFAULT 'en'
)
RETURNS TABLE (
  city_id UUID,
  city_name TEXT,
  province_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    CASE 
      WHEN p_language = 'fr' THEN COALESCE(c.name_fr, c.name)
      ELSE c.name
    END AS city_name,
    p.name AS province_name
  FROM menuca_v3.cities c
  JOIN menuca_v3.provinces p ON p.id = c.province_id
  WHERE 
    (p_language = 'en' AND c.name ILIKE '%' || p_search_term || '%')
    OR (p_language = 'fr' AND c.name_fr ILIKE '%' || p_search_term || '%')
  ORDER BY city_name
  LIMIT 50;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

#### **2.2 Performance Indexes:**

```sql
-- Cities by province lookup
CREATE INDEX idx_cities_province_id ON menuca_v3.cities(province_id);

-- City name searches
CREATE INDEX idx_cities_name_trgm ON menuca_v3.cities USING gin(name gin_trgm_ops);
CREATE INDEX idx_cities_name_fr_trgm ON menuca_v3.cities USING gin(name_fr gin_trgm_ops);

-- Province lookups
CREATE INDEX idx_provinces_code ON menuca_v3.provinces(code);

-- Geospatial indexes for restaurant_locations
CREATE INDEX idx_restaurant_locations_coordinates ON menuca_v3.restaurant_locations(latitude, longitude);
CREATE INDEX idx_restaurant_locations_restaurant ON menuca_v3.restaurant_locations(restaurant_id) WHERE deleted_at IS NULL;
```

#### **2.3 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_2_PERFORMANCE_APIS_SUMMARY.md`

---

### **PHASE 3: Schema Optimization** 📝

**Goal:** Add audit trails and soft delete

#### **3.1 Add audit columns (if missing):**
```sql
-- Check current columns first, then add if needed:
-- created_at, updated_at, created_by, updated_by, deleted_at, deleted_by
```

#### **3.2 Create active-only views:**
```sql
CREATE VIEW menuca_v3.active_restaurant_locations AS
SELECT * FROM menuca_v3.restaurant_locations
WHERE deleted_at IS NULL;
```

#### **3.3 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_3_SCHEMA_OPTIMIZATION_SUMMARY.md`

---

### **PHASE 4: Real-Time Updates** 🔔

**Goal:** Enable real-time location updates

#### **4.1 Enable Realtime:**
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.restaurant_locations;
```

#### **4.2 Create notification triggers:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.notify_location_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'restaurant_location_changed',
    json_build_object(
      'restaurant_id', NEW.restaurant_id,
      'action', TG_OP
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER restaurant_location_changed
AFTER INSERT OR UPDATE ON menuca_v3.restaurant_locations
FOR EACH ROW EXECUTE FUNCTION menuca_v3.notify_location_change();
```

#### **4.3 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_4_REALTIME_SUMMARY.md`

---

### **PHASE 5: Multi-Language Support** 🌍

**Goal:** Support EN/FR for Canadian bilingualism

#### **5.1 Add French translations for cities (if missing):**
```sql
-- Check if name_fr exists
-- Add translation data if needed
```

#### **5.2 Create language-aware functions:**
```sql
-- Already done in Phase 2 (search_cities with p_language parameter)
```

#### **5.3 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_5_MULTILANG_SUMMARY.md`

---

### **PHASE 6: Advanced Geospatial Features** 🗺️

**Goal:** Add PostGIS and advanced features

#### **6.1 Enable PostGIS (if not enabled):**
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

#### **6.2 Add geometry columns:**
```sql
ALTER TABLE menuca_v3.restaurant_locations 
ADD COLUMN location GEOGRAPHY(POINT, 4326);

-- Backfill from lat/lng
UPDATE menuca_v3.restaurant_locations 
SET location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
WHERE location IS NULL AND latitude IS NOT NULL AND longitude IS NOT NULL;
```

#### **6.3 Create spatial indexes:**
```sql
CREATE INDEX idx_restaurant_locations_geog ON menuca_v3.restaurant_locations USING GIST(location);
```

#### **6.4 Create optimized distance function:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurants_near_location_optimized(
  p_latitude DECIMAL(10,8),
  p_longitude DECIMAL(11,8),
  p_radius_km INTEGER DEFAULT 10
)
RETURNS TABLE (
  restaurant_id UUID,
  restaurant_name TEXT,
  distance_meters DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    rl.restaurant_id,
    r.name,
    ST_Distance(
      rl.location,
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
    ) AS distance_meters
  FROM menuca_v3.restaurant_locations rl
  JOIN menuca_v3.restaurants r ON r.id = rl.restaurant_id
  WHERE rl.deleted_at IS NULL
  AND r.deleted_at IS NULL
  AND ST_DWithin(
    rl.location,
    ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
    p_radius_km * 1000
  )
  ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

#### **6.5 Create Santiago Summary:**
Create `Database/Location & Geography Entity/PHASE_6_ADVANCED_GEOSPATIAL_SUMMARY.md`

---

### **PHASE 7: Testing & Validation** ✅

**Goal:** Validate all functionality

#### **7.1 Test RLS policies:**
```sql
-- Test public can read provinces/cities
-- Test restaurant admins can manage their locations
-- Test cross-tenant isolation
```

#### **7.2 Test all functions:**
```sql
-- Test get_restaurants_near_location
-- Test search_cities
-- Test get_cities_by_province
-- Test PostGIS functions
```

#### **7.3 Performance validation:**
```sql
-- All queries < 100ms
-- Verify index usage with EXPLAIN ANALYZE
```

#### **7.4 Create Final Report:**
Create `Database/Location & Geography Entity/LOCATION_GEOGRAPHY_COMPLETION_REPORT.md`

---

### **PHASE 8: Santiago Backend Integration Guide** 📚

**Goal:** Create master documentation

#### **8.1 Create comprehensive guide:**
Create `documentation/Location & Geography/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

Include:
- **Business Problem:** Need for location-based search, delivery zones, distance calculations
- **Solution:** PostGIS-powered geospatial database with RLS
- **Gained Business Logic:** Distance search, city/province hierarchy, bilingual support
- **Backend APIs:** 10+ endpoints for location features
- **Schema Modifications:** All tables, indexes, functions
- Links to all phase documentation

---

## 🎯 **SUCCESS CRITERIA:**

✅ All 3 tables have RLS enabled  
✅ 8+ RLS policies created  
✅ 6+ SQL functions for geospatial APIs  
✅ PostGIS integration complete  
✅ Performance indexes in place (spatial + text search)  
✅ Audit trails complete  
✅ Real-time updates enabled  
✅ Bilingual support (EN/FR)  
✅ All phase summaries created (8 summaries)  
✅ Santiago Backend Integration Guide complete  
✅ Updated SANTIAGO_MASTER_INDEX.md  

---

## 📊 **YOUR WORKFLOW (IMPORTANT!):**

1. **Read schema using Supabase MCP** - Don't ask for migration scripts, just query the DB
2. **Execute Phase 1** - Use `mcp_supabase_execute_sql` for each SQL statement
3. **Self-verify** - Query the database to confirm policies/functions were created
4. **Create Phase 1 Summary** - Santiago style markdown
5. **Repeat for Phases 2-8** - One phase at a time
6. **Commit & Push** - After each phase completion
7. **Update SANTIAGO_MASTER_INDEX.md** - When entity 100% complete

---

## ⚠️ **IMPORTANT NOTES:**

- **DO NOT ask for migration scripts** - Data is already migrated
- **USE Supabase MCP tools** - You have database access, use it!
- **Self-verify everything** - Query DB after each change
- **Follow Agent 1's pattern** - Check Marketing & Promotions phases for reference
- **Create Santiago summaries** - After every phase
- **Stay organized** - Work systematically through phases 1-8

---

## 🚀 **READY TO START!**

You've got this! Follow the phase structure, use Supabase MCP tools, and create Santiago-standard documentation at each step.

Agent 1 is working on Users & Access in parallel. Let's race to 100% completion! 🏁

