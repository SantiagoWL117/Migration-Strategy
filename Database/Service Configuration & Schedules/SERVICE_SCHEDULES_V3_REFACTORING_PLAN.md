# Service Configuration & Schedules - V3 Enterprise Refactoring Plan

**Entity:** Service Configuration & Schedules (Priority 4)  
**Dependencies:** ✅ Restaurant Management (Complete)  
**Created:** January 16, 2025  
**Developer:** Brian + AI Assistant  
**Status:** 🔄 **READY TO START**

---

## 🎉 **EXECUTIVE SUMMARY**

### **Current State** (Post-Migration)
The Service Configuration & Schedules entity was successfully migrated:
- ✅ **Data migrated** from V1/V2
- ✅ **V3 schema created** (4 tables)
- ❌ **NO RLS** - Major security issue
- ❌ **NO enterprise features** - No soft delete, audit, real-time

**Tables in menuca_v3:**
1. `restaurant_schedules` - Regular delivery/takeout hours
2. `restaurant_special_schedules` - Holiday/vacation schedules
3. `restaurant_service_configs` - Service capabilities
4. `restaurant_time_periods` - Named time windows (Lunch, Dinner)

---

### **Refactoring Objective**

**GOAL:** Transform Service Configuration & Schedules from "functional migration" to "enterprise-grade restaurant operations platform" matching industry standards (OpenTable, Resy, Toast).

**Focus Areas:**
1. 🔒 **Auth & Security** - RLS policies, role-based access, data isolation
2. 📊 **Performance & APIs** - Fast schedule queries, restaurant hours API
3. 🏗️ **Architecture** - Break V1/V2 logic, standardize patterns
4. 🚀 **Real-time Features** - Live schedule updates, holiday notifications
5. 🗑️ **Data Safety** - Soft delete, audit trails, recovery
6. 🌍 **Multi-language** - Translated schedule labels

**Why This Matters:**
- **Security:** Currently NO RLS - any user can modify any restaurant's hours
- **Santiago's Backend:** Needs APIs to check if restaurant is open/closed
- **Customer Experience:** Real-time updates when restaurants change hours
- **Zero Risk:** Data already migrated, only adding enterprise features

---

## 📋 **REFACTORING PHASES**

### **Phase Overview**

| Phase | Focus | Priority | Effort | Status |
|-------|-------|----------|--------|--------|
| **Phase 1** | Auth & Security (RLS) | 🔴 CRITICAL | 4-6 hours | ⏸️ READY TO START |
| **Phase 2** | Performance & Schedule APIs | 🔴 HIGH | 4-6 hours | ⏳ PENDING |
| **Phase 3** | Schema Optimization | 🟡 MEDIUM | 3-4 hours | ⏳ PENDING |
| **Phase 4** | Real-time Schedule Updates | 🟡 MEDIUM | 3-4 hours | ⏳ PENDING |
| **Phase 5** | Soft Delete & Audit | 🟢 LOW | 2-3 hours | ⏳ PENDING |
| **Phase 6** | Multi-language Support | 🟢 LOW | 2-3 hours | ⏳ PENDING |
| **Phase 7** | Testing & Validation | 🔴 CRITICAL | 2-3 hours | ⏳ PENDING |

**Progress:** 0/7 phases complete (0%)  
**Estimated Time:** ~20-29 hours  
**Completion Target:** Same-day completion (like Menu & Catalog)

---

##  🔐 **PHASE 1: AUTH & SECURITY (CRITICAL)**

**Priority:** 🔴 CRITICAL  
**Duration:** 4-6 hours  
**Risk:** 🔴 HIGH (currently NO RLS!)  
**Supabase MCP:** ✅ YES

---

### **1.1 Current Security Issues**

**CRITICAL VULNERABILITIES:**
- ❌ **No RLS on any table** - Anyone can modify any restaurant's hours
- ❌ **No tenant isolation** - Can see/edit competitors' schedules
- ❌ **No authorization** - Public users can create/delete schedules

**Example Attack:**
```sql
-- Public user can currently do this:
UPDATE menuca_v3.restaurant_schedules 
SET is_enabled = false 
WHERE restaurant_id = 72; -- Close competitor!
```

---

### **1.2 Add tenant_id Column**

**Purpose:** Fast multi-tenant isolation using restaurant UUID

```sql
-- Add tenant_id to all 4 tables
ALTER TABLE menuca_v3.restaurant_schedules 
ADD COLUMN tenant_id UUID REFERENCES public.restaurants(uuid);

ALTER TABLE menuca_v3.restaurant_special_schedules 
ADD COLUMN tenant_id UUID REFERENCES public.restaurants(uuid);

ALTER TABLE menuca_v3.restaurant_service_configs 
ADD COLUMN tenant_id UUID REFERENCES public.restaurants(uuid);

ALTER TABLE menuca_v3.restaurant_time_periods 
ADD COLUMN tenant_id UUID REFERENCES public.restaurants(uuid);
```

---

### **1.3 Backfill tenant_id**

```sql
-- Backfill tenant_id from restaurants table
UPDATE menuca_v3.restaurant_schedules rs
SET tenant_id = r.uuid
FROM menuca_v3.restaurants r
WHERE rs.restaurant_id = r.id;

UPDATE menuca_v3.restaurant_special_schedules rss
SET tenant_id = r.uuid
FROM menuca_v3.restaurants r
WHERE rss.restaurant_id = r.id;

UPDATE menuca_v3.restaurant_service_configs rsc
SET tenant_id = r.uuid
FROM menuca_v3.restaurants r
WHERE rsc.restaurant_id = r.id;

UPDATE menuca_v3.restaurant_time_periods rtp
SET tenant_id = r.uuid
FROM menuca_v3.restaurants r
WHERE rtp.restaurant_id = r.id;

-- Make NOT NULL and index
ALTER TABLE menuca_v3.restaurant_schedules 
ALTER COLUMN tenant_id SET NOT NULL;

ALTER TABLE menuca_v3.restaurant_special_schedules 
ALTER COLUMN tenant_id SET NOT NULL;

ALTER TABLE menuca_v3.restaurant_service_configs 
ALTER COLUMN tenant_id SET NOT NULL;

ALTER TABLE menuca_v3.restaurant_time_periods 
ALTER COLUMN tenant_id SET NOT NULL;

-- Create indexes
CREATE INDEX idx_restaurant_schedules_tenant 
ON menuca_v3.restaurant_schedules(tenant_id);

CREATE INDEX idx_restaurant_special_schedules_tenant 
ON menuca_v3.restaurant_special_schedules(tenant_id);

CREATE INDEX idx_restaurant_service_configs_tenant 
ON menuca_v3.restaurant_service_configs(tenant_id);

CREATE INDEX idx_restaurant_time_periods_tenant 
ON menuca_v3.restaurant_time_periods(tenant_id);
```

---

### **1.4 Enable RLS on All Tables**

```sql
-- Enable RLS
ALTER TABLE menuca_v3.restaurant_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_special_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_service_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.restaurant_time_periods ENABLE ROW LEVEL SECURITY;
```

---

### **1.5 Create RLS Policies**

#### **Restaurant Schedules Policies**

```sql
-- Public: Read active restaurant schedules
CREATE POLICY "public_read_schedules" ON menuca_v3.restaurant_schedules
    FOR SELECT
    USING (
        is_enabled = true 
        AND EXISTS (
            SELECT 1 FROM menuca_v3.restaurants r 
            WHERE r.id = restaurant_id 
            AND r.status = 'active'
        )
    );

-- Restaurant Admins: Full access to their schedules
CREATE POLICY "tenant_manage_schedules" ON menuca_v3.restaurant_schedules
    FOR ALL
    USING (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID)
    WITH CHECK (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID);

-- Super Admins: Full access
CREATE POLICY "admin_access_schedules" ON menuca_v3.restaurant_schedules
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');
```

#### **Special Schedules Policies**

```sql
-- Public: Read active special schedules (holidays, closures)
CREATE POLICY "public_read_special_schedules" ON menuca_v3.restaurant_special_schedules
    FOR SELECT
    USING (
        is_active = true 
        AND date_stop >= CURRENT_DATE
    );

-- Restaurant Admins: Manage their special schedules
CREATE POLICY "tenant_manage_special_schedules" ON menuca_v3.restaurant_special_schedules
    FOR ALL
    USING (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID)
    WITH CHECK (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID);

-- Super Admins: Full access
CREATE POLICY "admin_access_special_schedules" ON menuca_v3.restaurant_special_schedules
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');
```

#### **Service Configs Policies**

```sql
-- Public: Read active service configs (delivery/takeout enabled)
CREATE POLICY "public_read_service_configs" ON menuca_v3.restaurant_service_configs
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM menuca_v3.restaurants r 
            WHERE r.id = restaurant_id 
            AND r.status = 'active'
        )
    );

-- Restaurant Admins: Manage their service configs
CREATE POLICY "tenant_manage_service_configs" ON menuca_v3.restaurant_service_configs
    FOR ALL
    USING (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID)
    WITH CHECK (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID);

-- Super Admins: Full access
CREATE POLICY "admin_access_service_configs" ON menuca_v3.restaurant_service_configs
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');
```

#### **Time Periods Policies**

```sql
-- Public: Read all time periods (menu items reference these)
CREATE POLICY "public_read_time_periods" ON menuca_v3.restaurant_time_periods
    FOR SELECT
    USING (is_enabled = true);

-- Restaurant Admins: Manage their time periods
CREATE POLICY "tenant_manage_time_periods" ON menuca_v3.restaurant_time_periods
    FOR ALL
    USING (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID)
    WITH CHECK (tenant_id = (auth.jwt() ->> 'restaurant_id')::UUID);

-- Super Admins: Full access
CREATE POLICY "admin_access_time_periods" ON menuca_v3.restaurant_time_periods
    FOR ALL
    USING ((auth.jwt() ->> 'role') = 'admin');
```

---

### **1.6 Verification Queries**

```sql
-- Verify RLS is enabled
SELECT 
    tablename,
    CASE WHEN rowsecurity THEN '✅ RLS Enabled' ELSE '❌ No RLS' END as status
FROM pg_tables
WHERE schemaname = 'menuca_v3'
    AND tablename IN (
        'restaurant_schedules',
        'restaurant_special_schedules',
        'restaurant_service_configs',
        'restaurant_time_periods'
    );

-- Count RLS policies
SELECT 
    COUNT(*) as total_policies,
    COUNT(DISTINCT tablename) as tables_with_policies
FROM pg_policies
WHERE schemaname = 'menuca_v3'
    AND tablename LIKE 'restaurant_%';

-- Verify tenant_id coverage
SELECT 
    'restaurant_schedules' as table_name,
    COUNT(*) as total_rows,
    COUNT(tenant_id) as with_tenant_id,
    CASE WHEN COUNT(*) = COUNT(tenant_id) THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM menuca_v3.restaurant_schedules
UNION ALL
SELECT 
    'restaurant_special_schedules',
    COUNT(*),
    COUNT(tenant_id),
    CASE WHEN COUNT(*) = COUNT(tenant_id) THEN '✅ PASS' ELSE '❌ FAIL' END
FROM menuca_v3.restaurant_special_schedules
UNION ALL
SELECT 
    'restaurant_service_configs',
    COUNT(*),
    COUNT(tenant_id),
    CASE WHEN COUNT(*) = COUNT(tenant_id) THEN '✅ PASS' ELSE '❌ FAIL' END
FROM menuca_v3.restaurant_service_configs
UNION ALL
SELECT 
    'restaurant_time_periods',
    COUNT(*),
    COUNT(tenant_id),
    CASE WHEN COUNT(*) = COUNT(tenant_id) THEN '✅ PASS' ELSE '❌ FAIL' END
FROM menuca_v3.restaurant_time_periods;
```

---

## 📊 **PHASE 2: PERFORMANCE & SCHEDULE APIs**

**Priority:** 🔴 HIGH  
**Duration:** 4-6 hours  
**Risk:** 🟢 LOW (additive only)  
**Supabase MCP:** ✅ YES

---

### **2.1 Critical APIs for Santiago**

Santiago's backend needs these APIs:

1. **`is_restaurant_open_now()`** - Check if restaurant is currently open
2. **`get_restaurant_hours()`** - Get all hours for a restaurant
3. **`get_restaurant_config()`** - Get delivery/takeout settings
4. **`check_special_schedules()`** - Check for holidays/closures

---

### **2.2 Create is_restaurant_open_now() Function**

**Purpose:** Check if restaurant is currently accepting orders

```sql
CREATE OR REPLACE FUNCTION menuca_v3.is_restaurant_open_now(
    p_restaurant_id BIGINT,
    p_service_type public.service_type, -- 'delivery' or 'takeout'
    p_check_time TIMESTAMPTZ DEFAULT NOW()
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_is_enabled BOOLEAN;
    v_current_day INTEGER;  -- 1-7 (Mon-Sun)
    v_current_time TIME;
    v_is_open BOOLEAN DEFAULT false;
    v_special_schedule_type VARCHAR;
BEGIN
    -- Get current day and time in restaurant's local timezone
    -- (Assuming timezone stored in cities table linked to restaurant)
    v_current_day := EXTRACT(ISODOW FROM p_check_time); -- 1=Monday, 7=Sunday
    v_current_time := p_check_time::TIME;
    
    -- Check for special schedules first (holidays, closures)
    SELECT schedule_type INTO v_special_schedule_type
    FROM menuca_v3.restaurant_special_schedules
    WHERE restaurant_id = p_restaurant_id
        AND is_active = true
        AND p_check_time::DATE BETWEEN date_start AND date_stop
        AND (
            apply_to = 'both' 
            OR apply_to = p_service_type::VARCHAR
        )
    ORDER BY date_start DESC
    LIMIT 1;
    
    -- If closed for special reason, return false
    IF v_special_schedule_type = 'closed' THEN
        RETURN false;
    END IF;
    
    -- Check regular schedule
    SELECT EXISTS (
        SELECT 1
        FROM menuca_v3.restaurant_schedules
        WHERE restaurant_id = p_restaurant_id
            AND type = p_service_type
            AND is_enabled = true
            AND v_current_day BETWEEN day_start AND day_stop
            AND v_current_time BETWEEN time_start AND time_stop
    ) INTO v_is_open;
    
    RETURN v_is_open;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.is_restaurant_open_now TO anon, authenticated;

COMMENT ON FUNCTION menuca_v3.is_restaurant_open_now IS 
    'Check if restaurant is currently open for delivery or takeout. Respects special schedules (holidays, closures).';
```

---

### **2.3 Create get_restaurant_hours() Function**

```sql
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_hours(
    p_restaurant_id BIGINT
)
RETURNS TABLE (
    service_type VARCHAR,
    day_of_week INTEGER,
    day_name VARCHAR,
    time_start TIME,
    time_stop TIME,
    is_enabled BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rs.type::VARCHAR,
        rs.day_start,
        CASE rs.day_start
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            WHEN 7 THEN 'Sunday'
        END,
        rs.time_start,
        rs.time_stop,
        rs.is_enabled
    FROM menuca_v3.restaurant_schedules rs
    WHERE rs.restaurant_id = p_restaurant_id
        AND rs.is_enabled = true
    ORDER BY rs.type, rs.day_start, rs.time_start;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.get_restaurant_hours TO anon, authenticated;
```

---

### **2.4 Create get_restaurant_config() Function**

```sql
CREATE OR REPLACE FUNCTION menuca_v3.get_restaurant_config(
    p_restaurant_id BIGINT
)
RETURNS TABLE (
    delivery_enabled BOOLEAN,
    delivery_time_minutes INTEGER,
    delivery_min_order NUMERIC,
    takeout_enabled BOOLEAN,
    takeout_time_minutes INTEGER,
    takeout_discount_enabled BOOLEAN,
    takeout_discount_type VARCHAR,
    takeout_discount_value NUMERIC,
    allow_preorders BOOLEAN,
    preorder_time_frame_hours INTEGER,
    is_bilingual BOOLEAN,
    default_language VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rsc.delivery_enabled,
        rsc.delivery_time_minutes,
        rsc.delivery_min_order,
        rsc.takeout_enabled,
        rsc.takeout_time_minutes,
        rsc.takeout_discount_enabled,
        rsc.takeout_discount_type,
        rsc.takeout_discount_value,
        rsc.allow_preorders,
        rsc.preorder_time_frame_hours,
        rsc.is_bilingual,
        rsc.default_language
    FROM menuca_v3.restaurant_service_configs rsc
    WHERE rsc.restaurant_id = p_restaurant_id;
END;
$$;

GRANT EXECUTE ON FUNCTION menuca_v3.get_restaurant_config TO anon, authenticated;
```

---

### **2.5 Performance Indexes**

```sql
-- Composite indexes for fast schedule lookups
CREATE INDEX idx_schedules_restaurant_type_day 
ON menuca_v3.restaurant_schedules(restaurant_id, type, day_start);

CREATE INDEX idx_schedules_enabled 
ON menuca_v3.restaurant_schedules(restaurant_id, is_enabled) 
WHERE is_enabled = true;

-- Special schedules date range index
CREATE INDEX idx_special_schedules_dates 
ON menuca_v3.restaurant_special_schedules(restaurant_id, date_start, date_stop) 
WHERE is_active = true;

-- Service configs single-row lookup
CREATE UNIQUE INDEX idx_service_configs_restaurant 
ON menuca_v3.restaurant_service_configs(restaurant_id);
```

---

## 🏗️ **PHASE 3: SCHEMA OPTIMIZATION**

**Priority:** 🟡 MEDIUM  
**Duration:** 3-4 hours  
**Risk:** 🟢 LOW  
**Supabase MCP:** ✅ YES

---

### **3.1 Add Missing Audit Columns**

```sql
-- Add created_by, updated_by to all tables
ALTER TABLE menuca_v3.restaurant_schedules 
ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES menuca_v3.admin_users(id),
ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_special_schedules 
ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES menuca_v3.admin_users(id),
ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_service_configs 
ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES menuca_v3.admin_users(id),
ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_time_periods 
ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES menuca_v3.admin_users(id),
ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES menuca_v3.admin_users(id);
```

---

### **3.2 Add Timezone Awareness**

```sql
-- Add timezone column for explicit timezone handling
ALTER TABLE menuca_v3.restaurant_schedules 
ADD COLUMN IF NOT EXISTS timezone VARCHAR(50);

-- Backfill from restaurant's city
UPDATE menuca_v3.restaurant_schedules rs
SET timezone = c.timezone
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
JOIN menuca_v3.cities c ON c.id = rl.city_id
WHERE rs.restaurant_id = r.id
AND rs.timezone IS NULL;
```

---

## 🚀 **PHASE 4: REAL-TIME SCHEDULE UPDATES**

**Priority:** 🟡 MEDIUM  
**Duration:** 3-4 hours  
**Risk:** 🟢 LOW  
**Supabase MCP:** ✅ YES

---

### **4.1 Enable Supabase Realtime**

```sql
-- Enable Realtime on schedule tables
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.restaurant_schedules;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.restaurant_special_schedules;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.restaurant_service_configs;
```

---

### **4.2 Create Notification Function**

```sql
CREATE OR REPLACE FUNCTION menuca_v3.notify_schedule_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM pg_notify('schedule_changed', json_build_object(
        'table', TG_TABLE_NAME,
        'action', TG_OP,
        'restaurant_id', COALESCE(NEW.restaurant_id, OLD.restaurant_id),
        'tenant_id', COALESCE(NEW.tenant_id, OLD.tenant_id)
    )::text);
    RETURN NEW;
END;
$$;

-- Apply trigger to all schedule tables
CREATE TRIGGER notify_schedules_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.restaurant_schedules
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_schedule_change();

CREATE TRIGGER notify_special_schedules_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.restaurant_special_schedules
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_schedule_change();

CREATE TRIGGER notify_service_configs_change
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.restaurant_service_configs
    FOR EACH ROW
    EXECUTE FUNCTION menuca_v3.notify_schedule_change();
```

---

## 🗑️ **PHASE 5: SOFT DELETE & AUDIT**

**Priority:** 🟢 LOW  
**Duration:** 2-3 hours  
**Risk:** 🟢 LOW  
**Supabase MCP:** ✅ YES

---

### **5.1 Add Soft Delete Columns**

```sql
-- Add soft delete tracking
ALTER TABLE menuca_v3.restaurant_schedules 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_special_schedules 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurant_time_periods 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);
```

---

### **5.2 Create Active-Only Views**

```sql
CREATE OR REPLACE VIEW menuca_v3.active_schedules AS 
SELECT * FROM menuca_v3.restaurant_schedules 
WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW menuca_v3.active_special_schedules AS 
SELECT * FROM menuca_v3.restaurant_special_schedules 
WHERE deleted_at IS NULL;

GRANT SELECT ON menuca_v3.active_schedules TO anon, authenticated;
GRANT SELECT ON menuca_v3.active_special_schedules TO anon, authenticated;
```

---

## 🌍 **PHASE 6: MULTI-LANGUAGE SUPPORT**

**Priority:** 🟢 LOW  
**Duration:** 2-3 hours  
**Risk:** 🟢 LOW  
**Supabase MCP:** ✅ YES

---

### **6.1 Add Schedule Label Translations**

```sql
-- Table for translating schedule labels
CREATE TABLE menuca_v3.schedule_translations (
    id BIGSERIAL PRIMARY KEY,
    language_code VARCHAR(5) NOT NULL CHECK (language_code IN ('en', 'fr', 'es', 'zh', 'ar')),
    label_key VARCHAR(50) NOT NULL, -- 'monday', 'tuesday', 'delivery', 'takeout', 'closed_for_holiday'
    translated_text VARCHAR(255) NOT NULL,
    CONSTRAINT uq_schedule_translation UNIQUE (language_code, label_key)
);

-- Seed common translations
INSERT INTO menuca_v3.schedule_translations (language_code, label_key, translated_text) VALUES
('en', 'monday', 'Monday'),
('fr', 'monday', 'Lundi'),
('es', 'monday', 'Lunes'),
('en', 'delivery', 'Delivery'),
('fr', 'delivery', 'Livraison'),
('es', 'delivery', 'Entrega'),
('en', 'closed_for_holiday', 'Closed for Holiday'),
('fr', 'closed_for_holiday', 'Fermé pour vacances');
```

---

## ✅ **PHASE 7: TESTING & VALIDATION**

**Priority:** 🔴 CRITICAL  
**Duration:** 2-3 hours  
**Risk:** 🟢 LOW  
**Supabase MCP:** ✅ YES

---

### **7.1 RLS Testing**

```sql
-- Test: Public can only read active schedules
-- Test: Restaurant admin can manage only their schedules
-- Test: Super admin can access all schedules
```

---

### **7.2 Performance Benchmarks**

```sql
-- Test: is_restaurant_open_now() < 50ms
-- Test: get_restaurant_hours() < 100ms
-- Test: Schedule lookup with indexes < 20ms
```

---

### **7.3 Integration Testing**

- [ ] Test schedule changes trigger real-time notifications
- [ ] Test special schedules override regular schedules
- [ ] Test soft delete hides schedules correctly
- [ ] Test timezone handling

---

## 📝 **INTEGRATION CHECKLIST FOR SANTIAGO**

### Backend APIs Needed:
- [ ] GET `/api/restaurants/:id/is-open` - Check if open now
- [ ] GET `/api/restaurants/:id/hours` - Get all hours
- [ ] GET `/api/restaurants/:id/config` - Get service settings
- [ ] GET `/api/restaurants/:id/special-schedules` - Get holidays/closures
- [ ] POST `/api/restaurants/:id/schedules` - Create schedule (admin)
- [ ] PUT `/api/restaurants/:id/schedules/:scheduleId` - Update schedule (admin)
- [ ] DELETE `/api/restaurants/:id/schedules/:scheduleId` - Soft delete (admin)

### Real-time Subscriptions:
- [ ] Subscribe to schedule changes for live updates
- [ ] Handle holiday/closure notifications
- [ ] Update UI when hours change

---

## 🎯 **SUCCESS CRITERIA**

- [ ] RLS enabled on all 4 tables
- [ ] 12 RLS policies created (3 per table)
- [ ] tenant_id column added and backfilled (100% coverage)
- [ ] 4 critical functions created (is_open, get_hours, get_config, check_special)
- [ ] Performance < 50ms for is_open checks
- [ ] Real-time notifications working
- [ ] Soft delete implemented with recovery
- [ ] 100% test coverage

---

## 📊 **EXPECTED TIMELINE**

| Day | Phases | Hours |
|-----|--------|-------|
| Day 1 | Phase 1-2 | 8-12 hours |
| Day 1 (cont) | Phase 3-4 | 6-8 hours |
| Day 1 (cont) | Phase 5-7 | 6-9 hours |
| **Total** | **All 7 Phases** | **20-29 hours** |

**Target:** Complete in 1 day (like Menu & Catalog)

---

**Status:** 📋 PLAN COMPLETE | **Next:** Phase 1 Implementation | **Santiago:** Backend docs after each phase ✅



