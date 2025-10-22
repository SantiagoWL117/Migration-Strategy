# 🤖 Agent 2 Mission - Vendors & Franchises Refactoring

**Entity:** Vendors & Franchises  
**Priority:** 10 (Multi-location chains)  
**Status:** ⏳ READY for Santiago refactoring  
**Date:** October 17, 2025  

---

## 🎯 **YOUR MISSION:**

Refactor the Vendors & Franchises entity to Santiago's standards with full RLS, performance optimization, and production-ready franchise/chain management APIs.

---

## 📋 **CURRENT STATE:**

✅ **Data Migrated:**
- `menuca_v3.vendors` - Parent companies/franchisors
- `menuca_v3.franchise_relationships` - Vendor-restaurant relationships
- Multi-location chain management

❌ **Missing Santiago Standards:**
- No RLS policies
- No `tenant_id` for multi-tenant isolation
- No API functions (vendor management, franchise listings, etc.)
- No audit trails
- No soft delete
- No Santiago documentation

---

## 🔧 **YOUR REFACTORING WORKFLOW:**

### **STEP 1: Review Current Schema**

Use Supabase MCP to inspect:
```sql
-- Check vendors table structure
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name IN ('vendors', 'franchise_relationships')
ORDER BY table_name, ordinal_position;

-- Check existing indexes
SELECT tablename, indexname, indexdef 
FROM pg_indexes 
WHERE tablename IN ('vendors', 'franchise_relationships')
AND schemaname = 'menuca_v3';

-- Check RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('vendors', 'franchise_relationships')
AND schemaname = 'menuca_v3';

-- Count rows
SELECT 
  (SELECT COUNT(*) FROM menuca_v3.vendors) as total_vendors,
  (SELECT COUNT(*) FROM menuca_v3.franchise_relationships) as total_franchises;

-- Find multi-location chains
SELECT 
  v.name,
  COUNT(fr.restaurant_id) as location_count
FROM menuca_v3.vendors v
LEFT JOIN menuca_v3.franchise_relationships fr ON fr.vendor_id = v.id
GROUP BY v.id, v.name
HAVING COUNT(fr.restaurant_id) > 1
ORDER BY location_count DESC;
```

---

### **PHASE 1: Auth & Security** 🔐

**Goal:** Enable RLS and create access policies

#### **1.1 Add tenant_id to vendors (if needed):**
```sql
-- Vendors are platform-level entities, but can be owned by specific admins
-- Check if owner_id or similar exists
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'vendors' 
AND table_schema = 'menuca_v3';

-- Add soft delete if missing
ALTER TABLE menuca_v3.vendors 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT;

ALTER TABLE menuca_v3.franchise_relationships
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT;
```

#### **1.2 Enable RLS:**
```sql
ALTER TABLE menuca_v3.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.franchise_relationships ENABLE ROW LEVEL SECURITY;
```

#### **1.3 Create RLS Policies:**

**For vendors table:**
```sql
-- Platform admins can view all vendors
CREATE POLICY "vendors_select_platform_admin" 
ON menuca_v3.vendors FOR SELECT 
TO authenticated 
USING (
  -- Check if user is platform admin (you'll need to define this)
  -- For now, allow all authenticated admins to view
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
);

-- Public can view basic vendor info (for branding)
CREATE POLICY "vendors_select_public" 
ON menuca_v3.vendors FOR SELECT 
TO anon 
USING (deleted_at IS NULL);

-- Platform admins can create vendors
CREATE POLICY "vendors_insert_platform_admin" 
ON menuca_v3.vendors FOR INSERT 
TO authenticated 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Platform admins can update vendors
CREATE POLICY "vendors_update_platform_admin" 
ON menuca_v3.vendors FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
);

-- Service role has full access
CREATE POLICY "vendors_service_role_all" 
ON menuca_v3.vendors FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

**For franchise_relationships table:**
```sql
-- Restaurant admins can view their franchise relationships
CREATE POLICY "franchise_select_restaurant_admin" 
ON menuca_v3.franchise_relationships FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = franchise_relationships.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
);

-- Platform admins can view all franchise relationships
CREATE POLICY "franchise_select_platform_admin" 
ON menuca_v3.franchise_relationships FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
);

-- Platform admins can manage franchise relationships
CREATE POLICY "franchise_manage_platform_admin" 
ON menuca_v3.franchise_relationships FOR ALL 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Service role has full access
CREATE POLICY "franchise_service_role_all" 
ON menuca_v3.franchise_relationships FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

#### **1.4 Validate Policies:**
```sql
-- Count policies created
SELECT tablename, COUNT(*) as policy_count
FROM pg_policies 
WHERE tablename IN ('vendors', 'franchise_relationships')
GROUP BY tablename;
```

#### **1.5 Create Santiago Summary:**
Create `Database/Vendors & Franchises/PHASE_1_AUTH_SECURITY_SUMMARY.md`

---

### **PHASE 2: Performance & Franchise Management APIs** ⚡

**Goal:** Create SQL functions for vendor/franchise operations

#### **2.1 Core Vendor Functions:**

```sql
-- Get all vendors
CREATE OR REPLACE FUNCTION menuca_v3.get_all_vendors()
RETURNS TABLE (
  vendor_id BIGINT,
  vendor_name VARCHAR,
  logo_url VARCHAR,
  location_count INTEGER
)
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    v.id AS vendor_id,
    v.name AS vendor_name,
    v.logo_url,
    COUNT(fr.restaurant_id)::INTEGER AS location_count
  FROM menuca_v3.vendors v
  LEFT JOIN menuca_v3.franchise_relationships fr ON fr.vendor_id = v.id AND fr.deleted_at IS NULL
  WHERE v.deleted_at IS NULL
  GROUP BY v.id, v.name, v.logo_url
  ORDER BY v.name;
END;
$$ LANGUAGE plpgsql;

-- Get vendor locations (all restaurants in a franchise/chain)
CREATE OR REPLACE FUNCTION menuca_v3.get_vendor_locations(
  p_vendor_id BIGINT
)
RETURNS TABLE (
  restaurant_id BIGINT,
  restaurant_name VARCHAR,
  restaurant_slug VARCHAR,
  address VARCHAR,
  city VARCHAR,
  province VARCHAR
)
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    r.slug AS restaurant_slug,
    rl.address,
    c.name AS city,
    p.name AS province
  FROM menuca_v3.franchise_relationships fr
  JOIN menuca_v3.restaurants r ON r.id = fr.restaurant_id
  LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
  LEFT JOIN menuca_v3.cities c ON c.id = rl.city_id
  LEFT JOIN menuca_v3.provinces p ON p.id = c.province_id
  WHERE fr.vendor_id = p_vendor_id
  AND fr.deleted_at IS NULL
  AND r.deleted_at IS NULL
  ORDER BY p.name, c.name, r.name;
END;
$$ LANGUAGE plpgsql;

-- Get restaurant's vendor (if part of a chain)
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_vendor(
  p_restaurant_id BIGINT
)
RETURNS TABLE (
  vendor_id BIGINT,
  vendor_name VARCHAR,
  logo_url VARCHAR,
  relationship_type VARCHAR
)
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    v.id AS vendor_id,
    v.name AS vendor_name,
    v.logo_url,
    fr.relationship_type
  FROM menuca_v3.franchise_relationships fr
  JOIN menuca_v3.vendors v ON v.id = fr.vendor_id
  WHERE fr.restaurant_id = p_restaurant_id
  AND fr.deleted_at IS NULL
  AND v.deleted_at IS NULL
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Create vendor (platform admin only)
CREATE OR REPLACE FUNCTION menuca_v3.create_vendor(
  p_vendor_name VARCHAR,
  p_logo_url VARCHAR DEFAULT NULL,
  p_website VARCHAR DEFAULT NULL
)
RETURNS BIGINT
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
  v_vendor_id BIGINT;
BEGIN
  -- Verify user is platform admin (simplified check)
  IF NOT EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Access denied - platform admin required';
  END IF;

  -- Insert vendor
  INSERT INTO menuca_v3.vendors (name, logo_url, website)
  VALUES (p_vendor_name, p_logo_url, p_website)
  RETURNING id INTO v_vendor_id;

  RETURN v_vendor_id;
END;
$$ LANGUAGE plpgsql;

-- Add restaurant to franchise
CREATE OR REPLACE FUNCTION menuca_v3.add_franchise_location(
  p_vendor_id BIGINT,
  p_restaurant_id BIGINT,
  p_relationship_type VARCHAR DEFAULT 'franchise'
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  -- Verify platform admin
  IF NOT EXISTS (
    SELECT 1 FROM menuca_v3.admin_users au
    WHERE au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Access denied - platform admin required';
  END IF;

  -- Insert franchise relationship
  INSERT INTO menuca_v3.franchise_relationships (
    vendor_id,
    restaurant_id,
    relationship_type
  ) VALUES (
    p_vendor_id,
    p_restaurant_id,
    p_relationship_type
  )
  ON CONFLICT DO NOTHING;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

#### **2.2 Performance Indexes:**

```sql
-- Vendor lookups
CREATE INDEX idx_vendors_name ON menuca_v3.vendors(name) WHERE deleted_at IS NULL;

-- Franchise relationship lookups
CREATE INDEX idx_franchise_vendor ON menuca_v3.franchise_relationships(vendor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_franchise_restaurant ON menuca_v3.franchise_relationships(restaurant_id) WHERE deleted_at IS NULL;

-- Relationship type filtering
CREATE INDEX idx_franchise_type ON menuca_v3.franchise_relationships(relationship_type) WHERE deleted_at IS NULL;
```

#### **2.3 Create Santiago Summary:**
Create `Database/Vendors & Franchises/PHASE_2_PERFORMANCE_APIS_SUMMARY.md`

---

### **PHASE 3-7: Rapid Completion**

Create condensed summary covering:
- **Phase 3:** Schema optimization (soft delete, audit trails)
- **Phase 4:** Real-time updates (vendor/franchise notifications)
- **Phase 5:** Multi-language (vendor names internationalization)
- **Phase 6:** Advanced features (franchise analytics)
- **Phase 7:** Testing & validation

Create `Database/Vendors & Franchises/PHASE_3_7_COMPLETION_SUMMARY.md`

---

### **PHASE 8: Santiago Backend Integration Guide** 📚

**Goal:** Create master documentation

Create comprehensive guide at:
`documentation/Vendors & Franchises/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

Include:
- **Business Problem:** Need for multi-location chain management, franchise branding
- **Solution:** RLS-secured vendor registry with franchise relationships
- **Gained Business Logic:** Vendor management, franchise locations, chain analytics
- **Backend APIs:** Vendor/franchise management endpoints
- **Schema Modifications:** All tables, indexes, functions

---

## 🎯 **SUCCESS CRITERIA:**

✅ RLS enabled on 2 tables (vendors, franchise_relationships)  
✅ 10+ RLS policies created  
✅ 5+ SQL functions for vendor/franchise management  
✅ Performance indexes in place  
✅ Audit trails complete  
✅ Real-time updates enabled  
✅ All phase summaries created  
✅ Santiago Backend Integration Guide complete  
✅ Updated SANTIAGO_MASTER_INDEX.md  

---

## 📊 **YOUR WORKFLOW:**

1. **Read schema** - Use Supabase MCP
2. **Execute Phase 1** - RLS & policies
3. **Create Phase 1 Summary**
4. **Execute Phase 2** - Functions & indexes
5. **Create Phase 2 Summary**
6. **Execute Phases 3-7** - Remaining features
7. **Create Phases 3-7 Summary**
8. **Create Santiago Guide**
9. **Commit & Push**
10. **Update master index**

---

## 🚀 **LET'S HIT 100%!**

You crushed Location & Geography. Now finish with Vendors & Franchises! This is the final entity! 🏁

