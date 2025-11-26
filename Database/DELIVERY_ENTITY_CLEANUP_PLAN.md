# 🚀 Delivery Entity Cleanup & Optimization Plan
**menuca_v3 Database Schema**  
**Created:** 2025-11-25  
**Status:** 🔴 CRITICAL - Major Refactoring Needed

---

## 📊 Executive Summary

The Delivery entity currently has **THREE overlapping delivery systems** with significant data duplication, configuration conflicts, and unused tables. This creates:
- ❌ **Confusion** for developers (which system to use?)
- ❌ **Data inconsistency** (pricing in 3 different places)
- ❌ **Maintenance overhead** (updating multiple tables for one change)
- ❌ **Performance issues** (unnecessary table joins)

**Current State:**
- 6 tables, 3 systems, ~150 total columns
- Only 1 of 6 tables actively used by most restaurants
- Critical data duplicated across 3 tables

**Target State:**
- 3 core tables, 1 unified system, ~80 columns
- Clear separation of concerns
- Zero duplication, complete data coverage

---

## 🔍 Current State Analysis

### **6 Delivery Tables (Current)**

#### 1. `restaurant_delivery_config` ⚠️ **Bloated & Conflicted**
**Purpose:** High-level delivery configuration  
**Columns:** 24  
**Status:** Active but problematic  
**Issues:**
- ❌ **Duplicate data:** `delivery_max_distance_km` also in `restaurant_service_configs`
- ❌ **Duplicate data:** `restaurant_delivery_charge` redundant with zone fees
- ❌ **Configuration conflicts:** `delivery_method='radius'` but no radius set, uses polygons instead
- ❌ **Legacy bloat:** 7 boolean columns for V1 integrations (mostly unused)
- ⚠️ **Split logic:** Delivery pricing split between this table and zones
- ⚠️ **JSONB overuse:** `active_partners`, `partner_credentials` rarely queried

**Key Columns:**
```sql
-- Identity
id, uuid, restaurant_id

-- Method Configuration (CONFLICTED)
delivery_method ENUM ('radius', 'polygon', 'areas', 'disabled')  -- Says 'radius'...
delivery_radius_km DECIMAL                                       -- ...but NULL
use_polygon_areas BOOLEAN                                        -- ...actually uses polygons
use_multiple_areas BOOLEAN
max_delivery_distance_km DECIMAL                                 -- DUPLICATE with service_configs

-- Pricing (DUPLICATE)
restaurant_delivery_charge DECIMAL                               -- DUPLICATE with zones
delivery_service_extra DECIMAL                                   -- Unclear purpose

-- Partners
active_partners JSONB                                            -- Rarely queried, hard to index
partner_credentials JSONB                                        -- Security concern

-- Scheduling
disable_delivery_until TIMESTAMP

-- Legacy V1 Flags (MOSTLY UNUSED)
legacy_v1_twilio_call BOOLEAN                                    -- Only one in use
legacy_v1_send_to_delivery BOOLEAN
legacy_v1_daily_delivery BOOLEAN
legacy_v1_geodispatch BOOLEAN
legacy_v1_tookan BOOLEAN
legacy_v1_wedeliver BOOLEAN
legacy_v1_check_pings BOOLEAN

-- Audit
notes TEXT
created_at, created_by, updated_at, updated_by
```

**Usage Stats (153 restaurants):**
- `delivery_method = 'radius'`: 5 (3.3%)
- `delivery_method = 'areas'`: 142 (92.8%)
- `delivery_method = 'polygon'`: 0 (0%)
- `delivery_method = 'disabled'`: 6 (3.9%)

---

#### 2. `restaurant_service_configs` ⚠️ **Mixed Concerns**
**Purpose:** Service-level settings (delivery, takeout, preorders)  
**Columns:** 25  
**Status:** Active but mixing concerns  
**Issues:**
- ❌ **Duplicate data:** `delivery_max_distance_km` also in `restaurant_delivery_config`
- ❌ **Duplicate data:** `delivery_min_order` should be in zones (varies by zone)
- ⚠️ **Mixed concerns:** Delivery, takeout, preorders, language, tips all in one table
- ⚠️ **Poor separation:** Delivery settings split across this and `restaurant_delivery_config`

**Delivery-Related Columns:**
```sql
-- Delivery Settings (SHOULD BE IN DELIVERY TABLE)
has_delivery_enabled BOOLEAN
delivery_time_minutes INTEGER
delivery_min_order DECIMAL                -- Should vary by zone, not global
delivery_max_distance_km DECIMAL          -- DUPLICATE

-- Takeout Settings (BELONGS IN SEPARATE TABLE)
takeout_enabled BOOLEAN
takeout_time_minutes INTEGER
takeout_discount_enabled BOOLEAN
takeout_discount_type VARCHAR
takeout_discount_value DECIMAL

-- Preorders (BELONGS IN SEPARATE TABLE)
allows_preorders BOOLEAN
preorder_time_frame_hours INTEGER

-- Other Settings (BELONGS IN RESTAURANT TABLE)
is_bilingual BOOLEAN
default_language VARCHAR

-- Customer Settings (BELONGS IN RESTAURANT TABLE)
accepts_tips BOOLEAN
requires_phone BOOLEAN
```

**Verdict:** This table is a **dumping ground** for unrelated settings.

---

#### 3. `restaurant_delivery_zones` ✅ **Modern & Clean**
**Purpose:** PostGIS-based delivery zones (NEW system)  
**Columns:** 17  
**Status:** NEW system, minimal adoption  
**Issues:**
- ⚠️ **Low adoption:** Only 1 of 175 restaurants uses this
- ⚠️ **Competing systems:** Most restaurants use legacy `restaurant_delivery_areas` instead

**Key Columns:**
```sql
-- Identity
id, restaurant_id

-- Naming
zone_name VARCHAR

-- Geometry (PostGIS)
zone_geometry GEOMETRY(Polygon, 4326)
center_latitude DECIMAL
center_longitude DECIMAL
radius_meters INTEGER

-- Pricing (CORRECT - per-zone pricing)
delivery_fee_cents INTEGER
minimum_order_cents INTEGER

-- Time
estimated_delivery_minutes INTEGER

-- Status
is_active BOOLEAN

-- Audit
created_at, created_by, updated_at, updated_by, deleted_at, deleted_by
```

**Verdict:** This is the **CORRECT design** - clean, purpose-built, PostGIS-enabled.

---

#### 4. `restaurant_delivery_fees` ❌ **LEGACY - UNUSED**
**Purpose:** Distance/area-based tiered pricing  
**Columns:** 18  
**Status:** LEGACY system, minimal use  
**Usage:** 43 records across all restaurants  
**Issues:**
- ❌ **Obsolete:** Replaced by per-zone pricing in `restaurant_delivery_zones`
- ❌ **Complex:** Tier-based pricing harder to manage than zone-based
- ❌ **Duplicate:** Same data should be in zones

**Key Columns:**
```sql
fee_type ENUM ('distance', 'area')
tier_value INTEGER
total_delivery_fee DECIMAL
driver_earning DECIMAL
restaurant_pays DECIMAL
vendor_pays DECIMAL
is_active BOOLEAN
```

**Verdict:** **DEPRECATE** - Move to zone-based pricing.

---

#### 5. `restaurant_delivery_areas` ❌ **LEGACY V2 - PARTIAL USE**
**Purpose:** Legacy V2 polygon delivery areas  
**Columns:** 21  
**Status:** LEGACY system, 16 records  
**Usage:** 16 records (mostly Ginkgo Garden's area)  
**Issues:**
- ❌ **Duplicate functionality:** Same as `restaurant_delivery_zones` but legacy
- ❌ **Incomplete data:** Many NULL fields (fee_type, delivery_fee, min_order_value)
- ❌ **Poor design:** area_number (1, 2, 3...) instead of meaningful names
- ❌ **Mixed geometry:** Both PostGIS `geometry` AND text `coordinates`

**Key Columns:**
```sql
area_number INTEGER
area_name VARCHAR
display_name VARCHAR               -- Often NULL
fee_type ENUM                      -- Often NULL
delivery_fee DECIMAL               -- Often NULL
conditional_fee DECIMAL            -- Often NULL
conditional_threshold DECIMAL      -- Often NULL
min_order_value DECIMAL            -- Often NULL
is_complex BOOLEAN
coordinates TEXT                   -- DUPLICATE of geometry
geometry GEOMETRY                  -- PostGIS
area_sq_km DECIMAL
```

**Verdict:** **MIGRATE** data to `restaurant_delivery_zones`, then **DROP TABLE**.

---

#### 6. `restaurant_delivery_companies` ❌ **UNUSED**
**Purpose:** Third-party delivery service integrations  
**Columns:** 15  
**Status:** Minimal use (15 records)  
**Issues:**
- ❌ **Low value:** Only 15 records across all restaurants
- ❌ **Better in partners:** Should be part of `active_partners` JSONB in config
- ❌ **Maintenance overhead:** Separate table for rarely-used feature

**Verdict:** **CONSOLIDATE** into `restaurant_delivery_config.active_partners` or **DROP**.

---

## 🎯 Proposed Solution

### **New Structure: 3 Core Tables**

---

### ✅ **Table 1: `restaurant_delivery_config` (Simplified)**
**Purpose:** High-level delivery settings & partner configuration  
**Columns:** 15 (down from 24)  

```sql
CREATE TABLE restaurant_delivery_config (
    -- Identity
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE DEFAULT gen_random_uuid(),
    restaurant_id BIGINT NOT NULL UNIQUE REFERENCES restaurants(id),
    
    -- Method (SIMPLIFIED)
    delivery_method VARCHAR(20) NOT NULL DEFAULT 'zones',  -- 'zones' | 'disabled'
    -- REMOVED: delivery_radius_km (moved to zones)
    -- REMOVED: use_multiple_areas (implicit with multiple zones)
    -- REMOVED: use_polygon_areas (all zones use PostGIS)
    -- REMOVED: max_delivery_distance_km (calculated from zones)
    -- REMOVED: restaurant_delivery_charge (per-zone pricing)
    -- REMOVED: delivery_service_extra (unclear purpose)
    
    -- Scheduling
    disable_delivery_until TIMESTAMP,
    disable_delivery_reason VARCHAR(255),
    
    -- Partners (KEPT - useful for integrations)
    active_partners JSONB DEFAULT '[]'::jsonb,
    partner_credentials JSONB DEFAULT '{}'::jsonb,  -- Encrypted at app level
    
    -- REMOVED: 7 legacy V1 flags (obsolete)
    
    -- Audit
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by BIGINT REFERENCES admin_users(id),
    updated_at TIMESTAMP DEFAULT NOW(),
    updated_by BIGINT REFERENCES admin_users(id)
);

CREATE INDEX idx_delivery_config_restaurant ON restaurant_delivery_config(restaurant_id);
CREATE INDEX idx_delivery_config_method ON restaurant_delivery_config(delivery_method);
```

**Changes:**
- ✅ **Removed 9 columns** (duplicates, legacy flags, unclear fields)
- ✅ **Simplified delivery_method** to 2 values: 'zones' or 'disabled'
- ✅ **All geometry in zones table** (single source of truth)
- ✅ **All pricing in zones table** (per-zone fees, no global fees)

---

### ✅ **Table 2: `restaurant_delivery_zones` (No Changes)**
**Purpose:** PostGIS delivery zones with per-zone pricing  
**Columns:** 17 (unchanged)  
**Status:** ✅ **Already perfect** - no changes needed

```sql
-- KEEP AS-IS - This is the correct design
CREATE TABLE restaurant_delivery_zones (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES restaurants(id),
    zone_name VARCHAR(255) NOT NULL,
    zone_geometry GEOMETRY(Polygon, 4326) NOT NULL,
    center_latitude DECIMAL(10, 7),
    center_longitude DECIMAL(10, 7),
    radius_meters INTEGER,
    delivery_fee_cents INTEGER NOT NULL DEFAULT 0,
    minimum_order_cents INTEGER NOT NULL DEFAULT 0,
    estimated_delivery_minutes INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT NOW(),
    updated_by BIGINT,
    deleted_at TIMESTAMP,
    deleted_by BIGINT
);

CREATE INDEX idx_delivery_zones_restaurant ON restaurant_delivery_zones(restaurant_id);
CREATE INDEX idx_delivery_zones_active ON restaurant_delivery_zones(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_delivery_zones_geometry ON restaurant_delivery_zones USING GIST (zone_geometry);
```

**Why this is perfect:**
- ✅ PostGIS geometry for spatial queries
- ✅ Per-zone pricing (fee, minimum order)
- ✅ Per-zone time estimates
- ✅ Soft delete support
- ✅ Audit trail

---

### ✅ **Table 3: `restaurant_service_settings` (NEW - Extracted from service_configs)**
**Purpose:** Service-level settings (separated by concern)  
**Columns:** 19 (extracted from 25)  

```sql
CREATE TABLE restaurant_service_settings (
    -- Identity
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE DEFAULT gen_random_uuid(),
    restaurant_id BIGINT NOT NULL UNIQUE REFERENCES restaurants(id),
    
    -- Delivery Settings (MOVED FROM service_configs)
    has_delivery_enabled BOOLEAN DEFAULT FALSE,
    delivery_time_minutes INTEGER DEFAULT 45,
    -- REMOVED: delivery_min_order (per-zone in delivery_zones)
    -- REMOVED: delivery_max_distance_km (calculated from zones)
    
    -- Takeout Settings
    takeout_enabled BOOLEAN DEFAULT FALSE,
    takeout_time_minutes INTEGER DEFAULT 20,
    takeout_discount_enabled BOOLEAN DEFAULT FALSE,
    takeout_discount_type VARCHAR(20),  -- 'percentage' | 'fixed_amount'
    takeout_discount_value DECIMAL(10, 2),
    
    -- Preorder Settings
    allows_preorders BOOLEAN DEFAULT FALSE,
    preorder_time_frame_hours INTEGER DEFAULT 24,
    
    -- General Settings
    is_bilingual BOOLEAN DEFAULT FALSE,
    default_language VARCHAR(5) DEFAULT 'en',
    accepts_tips BOOLEAN DEFAULT FALSE,
    requires_phone BOOLEAN DEFAULT TRUE,
    
    -- Audit
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    created_by BIGINT REFERENCES admin_users(id),
    updated_at TIMESTAMP DEFAULT NOW(),
    updated_by BIGINT REFERENCES admin_users(id),
    deleted_at TIMESTAMP,
    deleted_by BIGINT REFERENCES admin_users(id)
);

CREATE INDEX idx_service_settings_restaurant ON restaurant_service_settings(restaurant_id);
CREATE INDEX idx_service_settings_delivery_enabled ON restaurant_service_settings(has_delivery_enabled) WHERE has_delivery_enabled = TRUE;
CREATE INDEX idx_service_settings_takeout_enabled ON restaurant_service_settings(takeout_enabled) WHERE takeout_enabled = TRUE;
```

**Changes from old `restaurant_service_configs`:**
- ✅ **Removed duplicate columns** (delivery_min_order, delivery_max_distance_km)
- ✅ **Clearer naming** (service_settings vs service_configs)
- ✅ **Better indexing** for enabled services

---

### 🗑️ **Tables to DEPRECATE**

#### 1. **`restaurant_delivery_fees`** ❌ DROP
**Reason:** Obsolete tier-based pricing  
**Action:** Migrate data to `restaurant_delivery_zones`  
**Migration:**
```sql
-- For each restaurant with fee tiers:
-- 1. Create zone with fee from tier 1
-- 2. Log migration in notes
-- 3. Mark old records as migrated
```

#### 2. **`restaurant_delivery_areas`** ❌ DROP
**Reason:** Duplicate of `restaurant_delivery_zones` (legacy V2)  
**Action:** Migrate 16 records to `restaurant_delivery_zones`  
**Migration:**
```sql
INSERT INTO restaurant_delivery_zones (
    restaurant_id,
    zone_name,
    zone_geometry,
    delivery_fee_cents,
    minimum_order_cents,
    is_active,
    created_at,
    created_by
)
SELECT 
    restaurant_id,
    COALESCE(display_name, area_name, 'Zone ' || area_number),
    geometry,
    COALESCE(delivery_fee * 100, 0),  -- Convert to cents
    COALESCE(min_order_value * 100, 0),
    is_active,
    created_at,
    created_by
FROM restaurant_delivery_areas
WHERE geometry IS NOT NULL;
```

#### 3. **`restaurant_delivery_companies`** ⚠️ EVALUATE
**Options:**
- **Option A:** Drop entirely (15 records, low value)
- **Option B:** Consolidate into `active_partners` JSONB in `restaurant_delivery_config`

**Recommendation:** **Option B** - Keep as JSONB, provides flexibility without table overhead.

---

## 📋 Migration Plan

### **Phase 1: Data Consolidation** (Week 1)

#### Step 1.1: Migrate Legacy Delivery Areas
```sql
-- Create zones from legacy areas
INSERT INTO restaurant_delivery_zones (...)
SELECT ... FROM restaurant_delivery_areas;

-- Verify migration
SELECT COUNT(*) FROM restaurant_delivery_areas WHERE migrated = FALSE;
```

#### Step 1.2: Migrate Fee Tiers
```sql
-- Create zones from fee tiers
-- Use tier 1 as base zone, tier 2+ as additional zones
```

#### Step 1.3: Consolidate Delivery Companies
```sql
-- Move company data to active_partners JSONB
UPDATE restaurant_delivery_config
SET active_partners = (
    SELECT jsonb_agg(
        jsonb_build_object(
            'company_name', company_name,
            'company_id', company_id,
            'sends_to_delivery', sends_to_delivery,
            'commission_rate', commission_rate
        )
    )
    FROM restaurant_delivery_companies
    WHERE restaurant_delivery_companies.restaurant_id = restaurant_delivery_config.restaurant_id
);
```

---

### **Phase 2: Schema Updates** (Week 2)

#### Step 2.1: Create New `restaurant_service_settings` Table
```sql
CREATE TABLE restaurant_service_settings (...);

-- Migrate data from restaurant_service_configs
INSERT INTO restaurant_service_settings (...)
SELECT ... FROM restaurant_service_configs;
```

#### Step 2.2: Update `restaurant_delivery_config`
```sql
-- Add new columns
ALTER TABLE restaurant_delivery_config 
ADD COLUMN disable_delivery_reason VARCHAR(255);

-- Drop obsolete columns
ALTER TABLE restaurant_delivery_config
DROP COLUMN delivery_radius_km,
DROP COLUMN use_multiple_areas,
DROP COLUMN use_polygon_areas,
DROP COLUMN max_delivery_distance_km,
DROP COLUMN restaurant_delivery_charge,
DROP COLUMN delivery_service_extra,
DROP COLUMN legacy_v1_twilio_call,
DROP COLUMN legacy_v1_send_to_delivery,
DROP COLUMN legacy_v1_daily_delivery,
DROP COLUMN legacy_v1_geodispatch,
DROP COLUMN legacy_v1_tookan,
DROP COLUMN legacy_v1_wedeliver,
DROP COLUMN legacy_v1_check_pings;

-- Update delivery_method enum
ALTER TABLE restaurant_delivery_config
ALTER COLUMN delivery_method TYPE VARCHAR(20);

UPDATE restaurant_delivery_config
SET delivery_method = 'zones'
WHERE delivery_method IN ('radius', 'polygon', 'areas');
```

---

### **Phase 3: Update Functions & Triggers** (Week 2)

#### Step 3.1: Update SQL Functions
- Update `is_address_in_delivery_zone()` to use new structure
- Update `get_restaurant_delivery_summary()` for new columns
- Update `create_delivery_zone_onboarding()` for new schema

#### Step 3.2: Update Edge Functions
- `create-delivery-zone` - Update validation
- `update-delivery-zone` - Update column references
- `toggle-zone-status` - No changes needed

---

### **Phase 4: Deprecate Old Tables** (Week 3)

#### Step 4.1: Rename to Archive
```sql
ALTER TABLE restaurant_delivery_fees 
RENAME TO _archived_restaurant_delivery_fees;

ALTER TABLE restaurant_delivery_areas 
RENAME TO _archived_restaurant_delivery_areas;

ALTER TABLE restaurant_delivery_companies 
RENAME TO _archived_restaurant_delivery_companies;

ALTER TABLE restaurant_service_configs 
RENAME TO _archived_restaurant_service_configs;
```

#### Step 4.2: Monitor for 2 Weeks
- Watch logs for queries to archived tables
- Update any missed references

#### Step 4.3: Drop After Validation
```sql
-- After 2 weeks of monitoring
DROP TABLE _archived_restaurant_delivery_fees;
DROP TABLE _archived_restaurant_delivery_areas;
DROP TABLE _archived_restaurant_delivery_companies;
DROP TABLE _archived_restaurant_service_configs;
```

---

## 📊 Impact Analysis

### **Before Cleanup**

| Metric | Value |
|--------|-------|
| **Total Tables** | 6 |
| **Total Columns** | ~150 |
| **Duplicate Data Points** | ~45 |
| **Delivery Systems** | 3 (conflicting) |
| **Unused Tables** | 3 |
| **Configuration Conflicts** | Multiple |
| **Avg Query Complexity** | High (3-4 table joins) |

### **After Cleanup**

| Metric | Value | Improvement |
|--------|-------|-------------|
| **Total Tables** | 3 | ✅ 50% reduction |
| **Total Columns** | ~80 | ✅ 47% reduction |
| **Duplicate Data Points** | 0 | ✅ 100% elimination |
| **Delivery Systems** | 1 (unified) | ✅ Clear architecture |
| **Unused Tables** | 0 | ✅ All tables active |
| **Configuration Conflicts** | None | ✅ Single source of truth |
| **Avg Query Complexity** | Low (1-2 table joins) | ✅ 50% reduction |

---

## ✅ Benefits

### **Developer Experience**
- ✅ **Clear architecture** - One delivery system, not three
- ✅ **No duplication** - Single source of truth for all data
- ✅ **Better performance** - Fewer joins, better indexes
- ✅ **Easier onboarding** - New developers understand structure instantly

### **Data Quality**
- ✅ **No conflicts** - Impossible to have mismatched data
- ✅ **Complete data** - Required fields enforced by schema
- ✅ **Audit trail** - Clear history of all changes

### **Maintenance**
- ✅ **Fewer tables** - 50% reduction in surface area
- ✅ **Fewer columns** - 47% reduction in complexity
- ✅ **Clearer naming** - Purpose-driven table names
- ✅ **Better indexes** - Optimized for actual queries

---

## 🚨 Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Breaking existing queries** | High | Phase rollout, monitor logs, maintain aliases |
| **Data loss during migration** | Critical | Dry-run migrations, validation queries, backups |
| **Downtime during schema changes** | Medium | Blue-green deployment, archive tables first |
| **Edge function compatibility** | Medium | Update functions first, test thoroughly |
| **Partner integrations break** | High | Consolidate company data carefully, test webhooks |

---

## 🎯 Success Metrics

### **Technical Metrics**
- [ ] Zero duplicate data points
- [ ] Zero configuration conflicts
- [ ] 100% of restaurants on unified system
- [ ] Query performance improved by 30%+
- [ ] All linter warnings resolved

### **Business Metrics**
- [ ] Zero delivery-related bugs reported
- [ ] Developer onboarding time reduced by 50%
- [ ] Schema documentation 100% accurate
- [ ] Zero customer-facing issues

---

## 📝 Next Steps

1. **Review & Approve** this plan with team
2. **Schedule migration** (3-week timeline)
3. **Create backup** of all delivery tables
4. **Run Phase 1** (Data Consolidation)
5. **Validate** Phase 1 results
6. **Run Phase 2** (Schema Updates)
7. **Update docs** and developer guides
8. **Monitor** for 2 weeks
9. **Drop archived tables** after validation

---

## 🤝 Approval Required

**Reviewed By:** _____________________  
**Approved By:** _____________________  
**Date:** _____________________

---

## 📚 References

- Current Schema: `MVP_RESTAURANTS.md` (lines 1803-1847)
- V1 Schema: `Database/v1_structure/structure.sql`
- V2 Schema: `Database/Legacy Schemas/v2_structure.sql`
- Delivery Analysis: `extracted_data/AGENT_HANDOFF_DELIVERY_ZONES_MIGRATION.md`

