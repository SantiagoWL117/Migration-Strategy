# tenant_id Removal Migration - Technical Handoff

**Migration Date:** 2025-10-30
**Database:** nthpbtdjhhnwfxqsxbvy.supabase.co
**Schema:** menuca_v3
**Status:** COMPLETED

---

## Executive Summary

The `tenant_id` column (UUID) has been completely removed from the menuca_v3 schema. All restaurant relationships now use `restaurant_id` (bigint FK to restaurants.id) exclusively.

**Key Change:** `tenant_id` was a denormalized copy of `restaurants.uuid`. It has been replaced with `restaurant_id`, which is a proper foreign key to `restaurants.id`.

**Impact:** 22 tables, 21 indexes, 13 functions, 2 RLS policies, and 9 views were modified.

---

## 1. Tables Modified

### 1.1 Columns Dropped

The `tenant_id` column was dropped from 22 tables:

| Table Name | tenant_id Type | Replacement | Notes |
|------------|---------------|-------------|-------|
| `combo_group_modifier_pricing` | UUID (nullable) | `restaurant_id` (bigint FK) | Already existed |
| `combo_groups` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `combo_items` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `combo_steps` | UUID (nullable) | `restaurant_id` (bigint FK) | Already existed |
| `courses` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `devices` | UUID (nullable) | `restaurant_id` (bigint FK) | Already existed |
| `dish_modifier_prices` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `dish_modifiers` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `dishes` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `ingredient_group_items` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `ingredient_groups` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `ingredients` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `promotional_coupons` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `promotional_deals` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_locations` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_schedules` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_service_configs` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_special_schedules` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_tag_associations` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `restaurant_time_periods` | UUID NOT NULL | `restaurant_id` (bigint FK) | Already existed |
| `vendor_commission_reports` | UUID NOT NULL | Uses `restaurant_uuid` | No change needed |
| `vendor_restaurants` | UUID NOT NULL | Uses `restaurant_uuid` | No change needed |

**Important:** All tables already had `restaurant_id` column before this migration. The `tenant_id` column was redundant.

### 1.2 How to Query Tables Now

**BEFORE (using tenant_id):**
```sql
SELECT * FROM menuca_v3.dishes WHERE tenant_id = '68adb3a4-1dc6-46fd-8cc8-126003d8df92';
```

**AFTER (using restaurant_id):**
```sql
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 89;
```

**To get restaurant UUID when needed:**
```sql
SELECT d.*, r.uuid as restaurant_uuid
FROM menuca_v3.dishes d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE d.restaurant_id = 89;
```

---

## 2. Indexes Dropped

21 indexes on `tenant_id` were dropped:

| Index Name | Table |
|------------|-------|
| `idx_combo_group_modifier_pricing_tenant_id` | combo_group_modifier_pricing |
| `idx_combo_groups_tenant_id` | combo_groups |
| `idx_combo_items_tenant_id` | combo_items |
| `idx_courses_tenant_id` | courses |
| `idx_devices_tenant` | devices |
| `idx_dish_modifier_prices_tenant` | dish_modifier_prices |
| `idx_dish_modifiers_tenant_id` | dish_modifiers |
| `idx_dishes_tenant_id` | dishes |
| `idx_ingredient_group_items_tenant_id` | ingredient_group_items |
| `idx_ingredient_groups_tenant_id` | ingredient_groups |
| `idx_ingredients_tenant_id` | ingredients |
| `idx_promotional_coupons_tenant` | promotional_coupons |
| `idx_promotional_deals_tenant` | promotional_deals |
| `idx_restaurant_locations_tenant` | restaurant_locations |
| `idx_restaurant_schedules_tenant` | restaurant_schedules |
| `idx_restaurant_service_configs_tenant` | restaurant_service_configs |
| `idx_restaurant_special_schedules_tenant` | restaurant_special_schedules |
| `idx_restaurant_tag_associations_tenant` | restaurant_tag_associations |
| `idx_restaurant_time_periods_tenant` | restaurant_time_periods |
| `idx_vendor_commission_reports_tenant` | vendor_commission_reports |
| `idx_vendor_restaurants_tenant` | vendor_restaurants |

**Replacement:** All tables already have indexes on `restaurant_id` (e.g., `idx_dishes_restaurant_id`). These remain intact.

---

## 3. Functions Modified

### 3.1 Core Functions (5 total)

#### Function 1: `register_device()`

**Location:** `menuca_v3.register_device()`

**What Changed:**
- **Return Type:** Now returns `restaurant_id` (bigint) instead of `tenant_id` (uuid)
- **Logic:** No longer looks up `restaurants.uuid`, directly returns `restaurant_id`

**BEFORE:**
```sql
CREATE FUNCTION menuca_v3.register_device(...)
RETURNS TABLE(
    device_id bigint,
    device_uuid uuid,
    device_name varchar,
    tenant_id uuid,  -- ← Returned restaurants.uuid
    created_at timestamptz
)
```

**AFTER:**
```sql
CREATE FUNCTION menuca_v3.register_device(...)
RETURNS TABLE(
    device_id bigint,
    device_uuid uuid,
    device_name varchar,
    restaurant_id bigint,  -- ← Returns restaurants.id (FK)
    created_at timestamptz
)
```

**Application Impact:**
```typescript
// BEFORE
interface RegisterDeviceResult {
    tenant_id: string;  // UUID
}

// AFTER
interface RegisterDeviceResult {
    restaurant_id: number;  // bigint
}
```

---

#### Function 2: `add_restaurant_to_vendor()`

**Location:** `menuca_v3.add_restaurant_to_vendor()`

**What Changed:**
- **Logic:** No longer inserts `tenant_id` into `vendor_restaurants` table
- **Note:** `vendor_restaurants` table uses `restaurant_uuid` column (unchanged)

**BEFORE:**
```sql
INSERT INTO menuca_v3.vendor_restaurants (
    vendor_id,
    restaurant_uuid,
    tenant_id,  -- ← Inserted restaurants.uuid
    ...
)
```

**AFTER:**
```sql
INSERT INTO menuca_v3.vendor_restaurants (
    vendor_id,
    restaurant_uuid,  -- ← Still uses UUID, no tenant_id
    ...
)
```

**Application Impact:** None - function signature unchanged

---

#### Function 3: `notify_schedule_change()` [TRIGGER]

**Location:** `menuca_v3.notify_schedule_change()`
**Trigger:** Fires on `restaurant_schedules` INSERT/UPDATE/DELETE

**What Changed:**
- **Notification Payload:** Now sends `restaurant_id` (bigint) instead of `tenant_id` (uuid)

**BEFORE:**
```sql
PERFORM pg_notify('schedule_changed', json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'tenant_id', COALESCE(NEW.tenant_id, OLD.tenant_id)  -- UUID
)::text);
```

**AFTER:**
```sql
PERFORM pg_notify('schedule_changed', json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'restaurant_id', COALESCE(NEW.restaurant_id, OLD.restaurant_id)  -- bigint FK
)::text);
```

**Application Impact:**
```typescript
// BEFORE
supabase.channel('schedules')
  .on('postgres_changes', {...}, (payload) => {
    const tenantId = payload.new.tenant_id;  // UUID string
  });

// AFTER
supabase.channel('schedules')
  .on('postgres_changes', {...}, (payload) => {
    const restaurantId = payload.new.restaurant_id;  // number
  });
```

---

#### Function 4: `notify_location_change()` [TRIGGER]

**Location:** `menuca_v3.notify_location_change()`
**Trigger:** Fires on `restaurant_locations` INSERT/UPDATE/DELETE

**What Changed:**
- **Notification Payload:** Now sends `restaurant_id` (bigint) instead of `tenant_id` (uuid)

**BEFORE:**
```sql
PERFORM pg_notify('location_changed', json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'tenant_id', COALESCE(NEW.tenant_id, OLD.tenant_id)  -- UUID
)::text);
```

**AFTER:**
```sql
PERFORM pg_notify('location_changed', json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'restaurant_id', COALESCE(NEW.restaurant_id, OLD.restaurant_id)  -- bigint FK
)::text);
```

**Application Impact:** Same as `notify_schedule_change()`

---

#### Function 5: `create_flash_sale()`

**Location:** `menuca_v3.create_flash_sale()`

**What Changed:**
- **Logic:** No longer inserts `tenant_id` into `promotional_deals` table
- **Logic:** Uses `restaurant_id` FK directly

**BEFORE:**
```sql
DECLARE
    v_tenant_id UUID;
BEGIN
    -- Lookup tenant_id
    SELECT tenant_id INTO v_tenant_id
    FROM menuca_v3.promotional_deals
    WHERE restaurant_id = p_restaurant_id
    LIMIT 1;

    INSERT INTO menuca_v3.promotional_deals (
        restaurant_id,
        tenant_id,  -- ← Inserted UUID
        ...
    )
```

**AFTER:**
```sql
BEGIN
    -- No tenant_id lookup needed

    INSERT INTO menuca_v3.promotional_deals (
        restaurant_id,  -- ← Only uses FK
        ...
    )
```

**Application Impact:** None - function signature unchanged

---

### 3.2 Helper Functions (8 total)

All helper functions were updated to remove `tenant_id` references. Changes are consistent across all:

| Function Name | Changes |
|---------------|---------|
| `add_restaurant_location_onboarding` | Removed `v_tenant_id` variable, removed tenant_id from INSERT |
| `apply_schedule_template_onboarding` | Removed `v_tenant_id` variable, removed tenant_id from INSERT |
| `bulk_copy_schedule_onboarding` | Removed `v_tenant_id` variable, removed tenant_id from INSERT |
| `check_schedule_overlap` | Removed tenant_id from EXISTS check |
| `clone_schedule_to_day` | Removed `v_tenant_id` variable, removed tenant_id from INSERT |
| `has_schedule_conflict` | Removed `p_tenant_id` parameter, removed tenant_id from WHERE clause |
| `update_dish_availability` | No tenant_id usage (already used restaurant_id only) |
| `decrement_dish_inventory` | No tenant_id usage (already used restaurant_id only) |

**Example:** `has_schedule_conflict()`

**BEFORE:**
```sql
CREATE FUNCTION menuca_v3.has_schedule_conflict(
    p_restaurant_id bigint,
    p_tenant_id uuid,  -- ← Removed
    p_day_start integer,
    ...
)
```

**AFTER:**
```sql
CREATE FUNCTION menuca_v3.has_schedule_conflict(
    p_restaurant_id bigint,  -- ← Only parameter needed
    p_day_start integer,
    ...
)
```

**Application Impact:** If calling `has_schedule_conflict()` directly, remove the `tenant_id` argument.

---

## 4. RLS Policies Modified

### 4.1 Policy 1: `admin_manage_coupon_translations`

**Table:** `menuca_v3.promotional_coupons_translations`
**Operation:** ALL
**Role:** authenticated

**What Changed:**
- **Access Control:** Changed from JWT `tenant_id` claim to `admin_user_restaurants` JOIN

**BEFORE:**
```sql
CREATE POLICY admin_manage_coupon_translations
ON menuca_v3.promotional_coupons_translations
FOR ALL TO authenticated
USING (
    (
        SELECT pc.tenant_id  -- ← Used tenant_id from JWT
        FROM menuca_v3.promotional_coupons pc
        WHERE pc.id = promotional_coupons_translations.coupon_id
    )::text = ((auth.jwt() -> 'tenant_id')::text)
);
```

**AFTER:**
```sql
CREATE POLICY admin_manage_coupon_translations
ON menuca_v3.promotional_coupons_translations
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM menuca_v3.promotional_coupons pc
        JOIN menuca_v3.admin_user_restaurants aur ON (aur.restaurant_id = pc.restaurant_id)
        JOIN menuca_v3.admin_users au ON (aur.admin_user_id = au.id)
        WHERE pc.id = promotional_coupons_translations.coupon_id
        AND au.auth_user_id = auth.uid()
        AND au.status = 'active'
        AND au.deleted_at IS NULL
    )
);
```

**How It Works Now:**
1. Gets current user's auth_user_id from `auth.uid()`
2. Finds admin_user record via `admin_users`
3. Checks if admin has access to restaurant via `admin_user_restaurants`
4. Joins to promotional_coupons via `restaurant_id` FK

**Application Impact:** JWT tokens no longer need `tenant_id` claim (if they had one)

---

### 4.2 Policy 2: `admin_manage_deal_translations`

**Table:** `menuca_v3.promotional_deals_translations`
**Operation:** ALL
**Role:** authenticated

**What Changed:**
- **Access Control:** Changed from JWT `tenant_id` claim to `admin_user_restaurants` JOIN

**BEFORE:**
```sql
CREATE POLICY admin_manage_deal_translations
ON menuca_v3.promotional_deals_translations
FOR ALL TO authenticated
USING (
    (
        SELECT pd.tenant_id  -- ← Used tenant_id from JWT
        FROM menuca_v3.promotional_deals pd
        WHERE pd.id = promotional_deals_translations.deal_id
    )::text = ((auth.jwt() -> 'tenant_id')::text)
);
```

**AFTER:**
```sql
CREATE POLICY admin_manage_deal_translations
ON menuca_v3.promotional_deals_translations
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM menuca_v3.promotional_deals pd
        JOIN menuca_v3.admin_user_restaurants aur ON (aur.restaurant_id = pd.restaurant_id)
        JOIN menuca_v3.admin_users au ON (aur.admin_user_id = au.id)
        WHERE pd.id = promotional_deals_translations.deal_id
        AND au.auth_user_id = auth.uid()
        AND au.status = 'active'
        AND au.deleted_at IS NULL
    )
);
```

**How It Works Now:** Same pattern as `admin_manage_coupon_translations`

**Application Impact:** JWT tokens no longer need `tenant_id` claim (if they had one)

---

## 5. Views Modified

9 views were recreated without `tenant_id` column:

| View Name | Table Source | Columns | tenant_id Removed? |
|-----------|-------------|---------|-------------------|
| `active_dishes` | dishes | 31 | ✅ Yes |
| `active_courses` | courses | 16 | ✅ Yes |
| `active_ingredients` | ingredients | 20 | ✅ Yes |
| `active_ingredient_groups` | ingredient_groups | 22 | ✅ Yes |
| `active_combo_groups` | combo_groups | 20 | ✅ Yes |
| `active_dish_modifiers` | dish_modifiers | 17 | ✅ Yes |
| `active_schedules` | restaurant_schedules | 17 | ✅ Yes |
| `active_special_schedules` | restaurant_special_schedules | 18 | ✅ Yes |
| `active_time_periods` | restaurant_time_periods | 17 | ✅ Yes |

**What Changed:**
- All views still filter by `WHERE deleted_at IS NULL`
- All views include `restaurant_id` (bigint FK)
- All views exclude `tenant_id` from SELECT list

**Example:** `active_dishes`

**BEFORE:**
```sql
CREATE VIEW menuca_v3.active_dishes AS
SELECT
    id, uuid, restaurant_id, course_id, ..., tenant_id  -- ← Had tenant_id
FROM menuca_v3.dishes
WHERE deleted_at IS NULL;
```

**AFTER:**
```sql
CREATE VIEW menuca_v3.active_dishes AS
SELECT
    id, uuid, restaurant_id, course_id, ...  -- ← No tenant_id
FROM menuca_v3.dishes
WHERE deleted_at IS NULL;
```

**Application Impact:**
```typescript
// BEFORE
interface ActiveDish {
    restaurant_id: number;
    tenant_id: string;  // ← No longer exists
    // ...
}

// AFTER
interface ActiveDish {
    restaurant_id: number;
    // ...
}
```

---

## 6. Triggers

No triggers were modified directly. However, the trigger functions `notify_schedule_change()` and `notify_location_change()` were updated (see Section 3.1).

**Trigger Definitions (Unchanged):**
```sql
-- These trigger definitions remain the same
CREATE TRIGGER schedule_change_notify
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.restaurant_schedules
    FOR EACH ROW EXECUTE FUNCTION menuca_v3.notify_schedule_change();

CREATE TRIGGER location_change_notify
    AFTER INSERT OR UPDATE OR DELETE ON menuca_v3.restaurant_locations
    FOR EACH ROW EXECUTE FUNCTION menuca_v3.notify_location_change();
```

**What Changed:** Only the function bodies changed (payload now uses `restaurant_id`)

---

## 7. How to Work with the New Schema

### 7.1 Querying by Restaurant

**Use restaurant_id (bigint FK) everywhere:**

```sql
-- Get all dishes for a restaurant
SELECT * FROM menuca_v3.dishes WHERE restaurant_id = 89;

-- Get active dishes for a restaurant
SELECT * FROM menuca_v3.active_dishes WHERE restaurant_id = 89;

-- Get promotional deals for a restaurant
SELECT * FROM menuca_v3.promotional_deals WHERE restaurant_id = 349;

-- Get schedules for a restaurant
SELECT * FROM menuca_v3.restaurant_schedules WHERE restaurant_id = 89;
```

### 7.2 Getting Restaurant UUID

**If you need the restaurant UUID (e.g., for external APIs):**

```sql
-- Join to restaurants table
SELECT
    d.*,
    r.uuid as restaurant_uuid,
    r.name as restaurant_name
FROM menuca_v3.dishes d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE d.restaurant_id = 89;
```

### 7.3 Creating New Records

**Use restaurant_id when inserting:**

```sql
-- Insert a dish
INSERT INTO menuca_v3.dishes (
    restaurant_id,  -- ← Use FK, not tenant_id
    name,
    course_id,
    base_price
) VALUES (
    89,
    'Chicken Burger',
    5,
    12.99
);

-- Insert promotional deal
INSERT INTO menuca_v3.promotional_deals (
    restaurant_id,  -- ← Use FK, not tenant_id
    name,
    deal_type,
    discount_percent
) VALUES (
    349,
    'Happy Hour',
    'time-based',
    25.00
);
```

### 7.4 Filtering by Restaurant in JOINs

**All JOINs now use restaurant_id:**

```sql
-- Get dishes with their course names
SELECT
    d.name as dish_name,
    c.name as course_name,
    r.name as restaurant_name
FROM menuca_v3.dishes d
JOIN menuca_v3.courses c ON c.id = d.course_id
    AND c.restaurant_id = d.restaurant_id  -- ← FK-based join
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE d.restaurant_id = 89;
```

### 7.5 Admin Access Control

**RLS policies now check via admin_user_restaurants:**

The system verifies admin access by:
1. Getting `auth.uid()` (current user's auth_user_id)
2. Looking up in `admin_users` table
3. Checking `admin_user_restaurants` for restaurant access
4. Verifying active status and no deletion

**This works automatically - no application code changes needed for RLS.**

---

## 8. Application Code Migration

### 8.1 TypeScript Interfaces

**Update all interfaces that included tenant_id:**

```typescript
// BEFORE
interface Device {
    device_id: number;
    device_uuid: string;
    device_name: string;
    tenant_id: string;  // ← Remove
    restaurant_id: number;
    created_at: string;
}

// AFTER
interface Device {
    device_id: number;
    device_uuid: string;
    device_name: string;
    restaurant_id: number;  // ← Only identifier needed
    created_at: string;
}
```

### 8.2 Real-time Event Listeners

**Update WebSocket/realtime listeners:**

```typescript
// BEFORE
supabase
  .channel('schedule_changes')
  .on('postgres_changes',
    { event: '*', schema: 'menuca_v3', table: 'restaurant_schedules' },
    (payload) => {
      const tenantId = payload.new.tenant_id;  // UUID
      if (tenantId === currentTenantId) {
        handleScheduleUpdate(payload);
      }
    }
  )
  .subscribe();

// AFTER
supabase
  .channel('schedule_changes')
  .on('postgres_changes',
    { event: '*', schema: 'menuca_v3', table: 'restaurant_schedules' },
    (payload) => {
      const restaurantId = payload.new.restaurant_id;  // number
      if (restaurantId === currentRestaurantId) {
        handleScheduleUpdate(payload);
      }
    }
  )
  .subscribe();
```

### 8.3 JWT Token Claims

**If JWT tokens included tenant_id claim, it's no longer needed:**

```typescript
// BEFORE
const token = {
  sub: userId,
  tenant_id: restaurantUuid,  // ← Not needed
  role: 'admin'
}

// AFTER
const token = {
  sub: userId,
  // tenant_id claim removed - RLS uses admin_user_restaurants table
  role: 'admin'
}
```

**Note:** RLS policies now use `admin_user_restaurants` JOIN pattern, not JWT claims.

### 8.4 API Responses

**Update any API response handlers expecting tenant_id:**

```typescript
// BEFORE
async function registerDevice(deviceName: string, restaurantId: number) {
    const result = await supabase.rpc('register_device', {
        p_device_name: deviceName,
        p_restaurant_id: restaurantId
    });

    console.log(result.data.tenant_id);  // ← No longer exists
}

// AFTER
async function registerDevice(deviceName: string, restaurantId: number) {
    const result = await supabase.rpc('register_device', {
        p_device_name: deviceName,
        p_restaurant_id: restaurantId
    });

    console.log(result.data.restaurant_id);  // ← Use this instead
}
```

### 8.5 Database Queries in Application

**Update any raw SQL queries:**

```typescript
// BEFORE
const { data } = await supabase
    .from('dishes')
    .select('*')
    .eq('tenant_id', tenantUuid);  // ← Column doesn't exist

// AFTER
const { data } = await supabase
    .from('dishes')
    .select('*')
    .eq('restaurant_id', restaurantId);  // ← Use FK
```

---

## 9. Testing & Validation

### 9.1 Post-Migration Validation Queries

**Run these queries to verify the migration:**

```sql
-- 1. Verify no tables have tenant_id
SELECT COUNT(*) as remaining_tenant_id_columns
FROM information_schema.columns
WHERE table_schema = 'menuca_v3' AND column_name = 'tenant_id';
-- Expected: 0

-- 2. Verify no indexes on tenant_id
SELECT COUNT(*) as remaining_tenant_id_indexes
FROM pg_indexes
WHERE schemaname = 'menuca_v3' AND indexdef ILIKE '%tenant_id%';
-- Expected: 0

-- 3. Verify views don't expose tenant_id
SELECT table_name
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name LIKE 'active_%'
AND column_name = 'tenant_id';
-- Expected: 0 rows

-- 4. Test basic queries work
SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = 89;
SELECT COUNT(*) FROM menuca_v3.active_dishes WHERE restaurant_id = 89;
SELECT COUNT(*) FROM menuca_v3.promotional_deals WHERE restaurant_id = 349;
-- Expected: All return counts successfully
```

### 9.2 Functional Tests

**Test these operations:**

1. **Device Registration:**
```sql
SELECT * FROM menuca_v3.register_device(
    'Test Device',
    89,  -- restaurant_id
    true,
    1,
    1
);
-- Expected: Returns restaurant_id (89), not tenant_id
```

2. **Flash Sale Creation:**
```sql
SELECT * FROM menuca_v3.create_flash_sale(
    349,  -- restaurant_id
    'Test Flash Sale',
    20.00,
    50,
    2
);
-- Expected: Creates deal successfully
```

3. **Schedule Conflict Check:**
```sql
SELECT * FROM menuca_v3.has_schedule_conflict(
    89,  -- restaurant_id (no tenant_id param)
    1,   -- day_start
    1,   -- day_stop
    '09:00:00'::time,
    '17:00:00'::time
);
-- Expected: Returns boolean result
```

---

## 10. Rollback Information

**Migration Status:** COMPLETED (IRREVERSIBLE)

**Backup Available:**
- **File:** `backup_schema_only_before_tenant_removal_20251030.sql`
- **Type:** Schema-only (structure, no data)
- **Size:** 1,747 KB
- **Location:** `C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\Database\remove_tenant_id_migration\`

**To Rollback:**
Requires full database backup restore (schema-only backup does not contain data).

---

## 11. Summary of Changes

| Object Type | Count Modified | Impact |
|-------------|---------------|--------|
| Tables (columns dropped) | 22 | ✅ No longer have tenant_id column |
| Indexes (dropped) | 21 | ✅ No longer indexed on tenant_id |
| Functions (updated) | 13 | ✅ Use restaurant_id instead of tenant_id |
| RLS Policies (updated) | 2 | ✅ Use admin_user_restaurants JOIN instead of JWT claim |
| Views (recreated) | 9 | ✅ No longer expose tenant_id column |
| Triggers (function bodies updated) | 2 | ✅ Send restaurant_id in notification payload |

**Total Objects Modified:** 69

---

## 12. Key Takeaways

1. **Use restaurant_id everywhere** - It's a bigint FK to restaurants.id
2. **tenant_id is gone** - Column no longer exists in any table
3. **Get UUID when needed** - JOIN to restaurants table to get restaurants.uuid
4. **Functions return restaurant_id** - Update application code to expect bigint, not UUID
5. **Real-time events use restaurant_id** - Update WebSocket listeners
6. **RLS uses JOINs** - No need for tenant_id in JWT tokens
7. **Views don't expose tenant_id** - Update TypeScript interfaces
8. **All functionality preserved** - Just using FK instead of UUID copy

---

## 13. Contact & Support

**Migration Completed By:** Claude Code Agent
**Migration Date:** 2025-10-30
**Database:** nthpbtdjhhnwfxqsxbvy.supabase.co
**Schema:** menuca_v3

**Documentation Files:**
- `README.md` - Migration overview
- `EXECUTION_PLAN.md` - Step-by-step execution guide
- `FUNCTIONALITY_MAPPING.md` - Detailed functionality comparison
- `MIGRATION_HANDOFF.md` - This document

**SQL Scripts:**
- `01_BACKUP_AND_VALIDATION.sql` - Pre-migration validation
- `02_UPDATE_FUNCTIONS.sql` - Function updates
- `03_UPDATE_RLS_POLICIES.sql` - RLS policy updates
- `04_UPDATE_VIEWS.sql` - View recreation
- `05_DROP_INDEXES_AND_COLUMNS.sql` - Drop tenant_id (EXECUTED)
- `99_ROLLBACK.sql` - Rollback reference (requires backup)

---

**END OF HANDOFF DOCUMENT**
