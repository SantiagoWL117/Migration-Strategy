# 🤖 Agent 1 Mission - Devices & Infrastructure Refactoring

**Entity:** Devices & Infrastructure  
**Priority:** 9 (Supporting infrastructure)  
**Status:** ⏳ READY for Santiago refactoring  
**Date:** October 17, 2025  

---

## 🎯 **YOUR MISSION:**

Refactor the Devices & Infrastructure entity to Santiago's standards with full RLS, performance optimization, and production-ready device management APIs.

---

## 📋 **CURRENT STATE:**

✅ **Data Migrated:**
- `menuca_v3.devices` - Restaurant devices (printers, tablets, POS systems)
- Device types, authentication tokens, status tracking
- Restaurant assignments

❌ **Missing Santiago Standards:**
- No RLS policies
- No `tenant_id` for multi-tenant isolation
- No API functions (device registration, status updates, etc.)
- No audit trails
- No soft delete
- No Santiago documentation

---

## 🔧 **YOUR REFACTORING WORKFLOW:**

### **STEP 1: Review Current Schema**

Use Supabase MCP to inspect:
```sql
-- Check table structure
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'devices'
ORDER BY ordinal_position;

-- Check existing indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'devices'
AND schemaname = 'menuca_v3';

-- Check RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'devices'
AND schemaname = 'menuca_v3';

-- Count rows
SELECT COUNT(*) as total_devices FROM menuca_v3.devices;

-- Check for orphaned devices (no restaurant assignment)
SELECT COUNT(*) as orphaned_devices 
FROM menuca_v3.devices 
WHERE restaurant_id IS NULL;
```

---

### **PHASE 1: Auth & Security** 🔐

**Goal:** Enable RLS and create access policies

#### **1.1 Add tenant_id (if needed):**
```sql
-- Check if tenant_id exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'devices' 
AND table_schema = 'menuca_v3'
AND column_name = 'tenant_id';

-- If missing, add it:
ALTER TABLE menuca_v3.devices 
ADD COLUMN tenant_id UUID REFERENCES menuca_v3.restaurants(id);

-- Backfill from existing restaurant_id
UPDATE menuca_v3.devices 
SET tenant_id = restaurant_id 
WHERE tenant_id IS NULL AND restaurant_id IS NOT NULL;

-- Add index
CREATE INDEX idx_devices_tenant_id ON menuca_v3.devices(tenant_id) WHERE deleted_at IS NULL;
```

#### **1.2 Enable RLS:**
```sql
ALTER TABLE menuca_v3.devices ENABLE ROW LEVEL SECURITY;
```

#### **1.3 Create RLS Policies:**

**For restaurant admins (manage their devices):**
```sql
-- Admins can view devices for their assigned restaurants
CREATE POLICY "devices_select_restaurant_admin" 
ON menuca_v3.devices FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
);

-- Admins can add devices to their restaurants
CREATE POLICY "devices_insert_restaurant_admin" 
ON menuca_v3.devices FOR INSERT 
TO authenticated 
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Admins can update devices for their restaurants
CREATE POLICY "devices_update_restaurant_admin" 
ON menuca_v3.devices FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL
)
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Admins can soft-delete devices for their restaurants
CREATE POLICY "devices_delete_restaurant_admin" 
ON menuca_v3.devices FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
);

-- Service role has full access
CREATE POLICY "devices_service_role_all" 
ON menuca_v3.devices FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);
```

#### **1.4 Validate Policies:**
```sql
-- Count policies created
SELECT COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename = 'devices';
```

#### **1.5 Create Santiago Summary:**
Create `Database/Devices & Infrastructure Entity/PHASE_1_AUTH_SECURITY_SUMMARY.md`

---

### **PHASE 2: Performance & Device Management APIs** ⚡

**Goal:** Create SQL functions for device operations

#### **2.1 Core Device Functions:**

```sql
-- Get devices for admin's restaurants
CREATE OR REPLACE FUNCTION menuca_v3.get_admin_devices()
RETURNS TABLE (
  device_id BIGINT,
  device_name VARCHAR,
  device_type VARCHAR,
  restaurant_id BIGINT,
  restaurant_name VARCHAR,
  status VARCHAR,
  last_seen_at TIMESTAMPTZ
)
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id AS device_id,
    d.name AS device_name,
    d.device_type,
    d.restaurant_id,
    r.name AS restaurant_name,
    d.status,
    d.last_seen_at
  FROM menuca_v3.devices d
  JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
  JOIN menuca_v3.admin_user_restaurants aur ON aur.restaurant_id = d.restaurant_id
  JOIN menuca_v3.admin_users au ON au.id = aur.admin_user_id
  WHERE au.auth_user_id = auth.uid()
  AND au.status = 'active'
  AND au.deleted_at IS NULL
  AND d.deleted_at IS NULL
  ORDER BY r.name, d.name;
END;
$$ LANGUAGE plpgsql;

-- Register new device
CREATE OR REPLACE FUNCTION menuca_v3.register_device(
  p_restaurant_id BIGINT,
  p_device_name VARCHAR,
  p_device_type VARCHAR,
  p_auth_token VARCHAR
)
RETURNS BIGINT
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
DECLARE
  v_device_id BIGINT;
BEGIN
  -- Verify admin has access to restaurant
  IF NOT EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = p_restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Access denied to restaurant';
  END IF;

  -- Insert device
  INSERT INTO menuca_v3.devices (
    restaurant_id,
    name,
    device_type,
    auth_token,
    status,
    tenant_id
  ) VALUES (
    p_restaurant_id,
    p_device_name,
    p_device_type,
    p_auth_token,
    'active',
    p_restaurant_id
  )
  RETURNING id INTO v_device_id;

  RETURN v_device_id;
END;
$$ LANGUAGE plpgsql;

-- Update device status
CREATE OR REPLACE FUNCTION menuca_v3.update_device_status(
  p_device_id BIGINT,
  p_status VARCHAR
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  UPDATE menuca_v3.devices
  SET 
    status = p_status,
    last_seen_at = NOW(),
    updated_at = NOW()
  WHERE id = p_device_id
  AND EXISTS (
    SELECT 1 
    FROM menuca_v3.admin_user_restaurants aur
    JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
    WHERE aur.restaurant_id = devices.restaurant_id
    AND au.auth_user_id = auth.uid()
    AND au.status = 'active'
    AND au.deleted_at IS NULL
  )
  AND deleted_at IS NULL;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Get device by auth token (for device authentication)
CREATE OR REPLACE FUNCTION menuca_v3.authenticate_device(
  p_auth_token VARCHAR
)
RETURNS TABLE (
  device_id BIGINT,
  device_name VARCHAR,
  restaurant_id BIGINT,
  restaurant_name VARCHAR,
  device_type VARCHAR
)
SECURITY DEFINER
SET search_path = menuca_v3, public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id AS device_id,
    d.name AS device_name,
    d.restaurant_id,
    r.name AS restaurant_name,
    d.device_type
  FROM menuca_v3.devices d
  JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
  WHERE d.auth_token = p_auth_token
  AND d.status = 'active'
  AND d.deleted_at IS NULL
  AND r.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;
```

#### **2.2 Performance Indexes:**

```sql
-- Device lookups by restaurant
CREATE INDEX idx_devices_restaurant_id ON menuca_v3.devices(restaurant_id) WHERE deleted_at IS NULL;

-- Device type filtering
CREATE INDEX idx_devices_type ON menuca_v3.devices(device_type) WHERE deleted_at IS NULL;

-- Status filtering
CREATE INDEX idx_devices_status ON menuca_v3.devices(status) WHERE deleted_at IS NULL;

-- Auth token lookups (for device authentication)
CREATE UNIQUE INDEX idx_devices_auth_token ON menuca_v3.devices(auth_token) WHERE deleted_at IS NULL;

-- Last seen tracking
CREATE INDEX idx_devices_last_seen ON menuca_v3.devices(last_seen_at DESC) WHERE deleted_at IS NULL;
```

#### **2.3 Create Santiago Summary:**
Create `Database/Devices & Infrastructure Entity/PHASE_2_PERFORMANCE_APIS_SUMMARY.md`

---

### **PHASE 3-7: Rapid Completion**

Create condensed summary covering:
- **Phase 3:** Schema optimization (soft delete, audit trails)
- **Phase 4:** Real-time updates (device status notifications)
- **Phase 5:** Multi-language (device type names)
- **Phase 6:** Advanced features (device health monitoring)
- **Phase 7:** Testing & validation

Create `Database/Devices & Infrastructure Entity/PHASE_3_7_COMPLETION_SUMMARY.md`

---

### **PHASE 8: Santiago Backend Integration Guide** 📚

**Goal:** Create master documentation

Create comprehensive guide at:
`documentation/Devices & Infrastructure/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

Include:
- **Business Problem:** Need for device management, authentication, status tracking
- **Solution:** RLS-secured device registry with auth tokens
- **Gained Business Logic:** Device registration, status updates, authentication
- **Backend APIs:** Device management endpoints
- **Schema Modifications:** All tables, indexes, functions

---

## 🎯 **SUCCESS CRITERIA:**

✅ RLS enabled on devices table  
✅ 5+ RLS policies created  
✅ 4+ SQL functions for device management  
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

## 🚀 **LET'S FINISH THIS!**

You've got the pattern down. Follow the same approach as Users & Access. Let's hit 90%! 🎯

