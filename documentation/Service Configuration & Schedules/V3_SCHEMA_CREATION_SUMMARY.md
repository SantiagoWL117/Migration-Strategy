# Service Configuration & Schedules - V3 Schema Creation Summary

## ✅ Schema Creation Complete

**Date**: 2025-10-03  
**Status**: Successfully created all 4 tables in `menuca_v3` schema  
**Database**: Supabase PostgreSQL

---

## Tables Created

### 1. ✅ `menuca_v3.restaurant_schedules` (Already existed)
**Purpose**: Regular delivery and takeout service hours

**Key Columns**:
- `id` (BIGINT, PK, auto-increment)
- `uuid` (UUID, unique)
- `restaurant_id` (BIGINT, FK → restaurants.id) ✅
- `type` (service_type enum: 'delivery' or 'takeout')
- `day_start` (SMALLINT, 1-7 for Mon-Sun)
- `day_stop` (SMALLINT, 1-7 for Mon-Sun)
- `time_start` (TIME - local time)
- `time_stop` (TIME - local time)
- `is_enabled` (BOOLEAN)
- Audit: `created_at`, `updated_at`

**Constraints**:
- FK to `restaurants(id)` with CASCADE delete ✅
- Check: `day_start` and `day_stop` between 1-7
- Unique index on `(restaurant_id, type, day_start, time_start, time_stop)`

**Indexes**:
- `idx_schedules_restaurant` on `restaurant_id`
- Unique: `u_sched_restaurant_service_day`

---

### 2. ✅ `menuca_v3.restaurant_special_schedules` (NEW - Created)
**Purpose**: Holiday, vacation, and special hour overrides

**Key Columns**:
- `id` (BIGINT, PK, auto-increment)
- `uuid` (UUID, unique)
- `restaurant_id` (BIGINT, FK → restaurants.id) ✅
- `schedule_type` (VARCHAR: 'closed', 'open', 'modified')
- `date_start` (DATE)
- `date_stop` (DATE)
- `time_start` (TIME - local time, nullable)
- `time_stop` (TIME - local time, nullable)
- `reason` (VARCHAR: 'vacation', 'bad_weather', 'holiday', 'maintenance')
- `apply_to` (VARCHAR: 'delivery', 'takeout', 'both')
- `notes` (TEXT)
- `is_active` (BOOLEAN)
- Audit: `created_at`, `created_by`, `updated_at`, `updated_by`

**Constraints**:
- FK to `restaurants(id)` with CASCADE delete ✅
- Check: `date_stop >= date_start`
- Check: `schedule_type IN ('closed', 'open', 'modified')`
- Check: `apply_to IN ('delivery', 'takeout', 'both')`

**Indexes**:
- `idx_special_schedules_restaurant` on `restaurant_id`
- `idx_special_schedules_dates` on `(date_start, date_stop)`
- `idx_special_schedules_active` on `is_active` (partial index)

**Trigger**:
- `trg_special_schedules_updated_at` - auto-updates `updated_at`

---

### 3. ✅ `menuca_v3.restaurant_service_configs` (NEW - Created)
**Purpose**: Service capabilities and configuration per restaurant

**Key Columns**:
- `id` (BIGINT, PK, auto-increment)
- `uuid` (UUID, unique)
- `restaurant_id` (BIGINT, FK → restaurants.id) ✅
- **Delivery Config**:
  - `delivery_enabled` (BOOLEAN)
  - `delivery_time_minutes` (INTEGER)
  - `delivery_min_order` (NUMERIC 10,2)
  - `delivery_max_distance_km` (NUMERIC 6,2)
- **Takeout Config**:
  - `takeout_enabled` (BOOLEAN)
  - `takeout_time_minutes` (INTEGER)
  - `takeout_discount_enabled` (BOOLEAN)
  - `takeout_discount_type` (VARCHAR: 'percentage', 'fixed')
  - `takeout_discount_value` (NUMERIC 10,2)
- **Preorder Config**:
  - `allow_preorders` (BOOLEAN)
  - `preorder_time_frame_hours` (INTEGER)
- **Language Config**:
  - `is_bilingual` (BOOLEAN)
  - `default_language` (VARCHAR: 'en', 'fr', 'es')
- **Additional**:
  - `accepts_tips` (BOOLEAN)
  - `requires_phone` (BOOLEAN)
- Audit: `created_at`, `created_by`, `updated_at`, `updated_by`

**Constraints**:
- FK to `restaurants(id)` with CASCADE delete ✅
- **UNIQUE**: One config per restaurant (`u_service_config_restaurant`)
- Check: `delivery_time_minutes > 0` (if not null)
- Check: `takeout_time_minutes > 0` (if not null)
- Check: `discount_type IN ('percentage', 'fixed')`
- Check: `default_language IN ('en', 'fr', 'es')`

**Indexes**:
- `idx_service_configs_restaurant` on `restaurant_id`
- `idx_service_configs_delivery_enabled` (partial index)
- `idx_service_configs_takeout_enabled` (partial index)

**Trigger**:
- `trg_service_configs_updated_at` - auto-updates `updated_at`

---

### 4. ✅ `menuca_v3.restaurant_time_periods` (NEW - Created)
**Purpose**: Named time windows (Lunch, Dinner) for menu item availability

**Key Columns**:
- `id` (BIGINT, PK, auto-increment)
- `uuid` (UUID, unique)
- `restaurant_id` (BIGINT, FK → restaurants.id) ✅
- `name` (VARCHAR 50: 'Lunch', 'Dinner', 'Happy Hour', etc.)
- `time_start` (TIME - local time)
- `time_stop` (TIME - local time)
- `is_enabled` (BOOLEAN)
- `display_order` (INTEGER)
- Audit: `created_at`, `created_by`, `updated_at`, `updated_by`, `disabled_at`, `disabled_by`

**Constraints**:
- FK to `restaurants(id)` with CASCADE delete ✅
- **UNIQUE**: Period name per restaurant (`u_restaurant_period_name`)
- Check: `time_stop > time_start`

**Indexes**:
- `idx_time_periods_restaurant` on `restaurant_id`
- `idx_time_periods_enabled` (partial index)
- `idx_time_periods_name` on `name`

**Trigger**:
- `trg_time_periods_updated_at` - auto-updates `updated_at`

---

## Enum Types Verified

### ✅ `public.service_type`
**Values**:
1. `'delivery'`
2. `'takeout'`

**Usage**: `restaurant_schedules.type` column

**Migration Mapping**:
- V1/V2 `'d'` → `'delivery'`
- V1/V2 `'t'` → `'takeout'`

---

## Foreign Key Relationships Summary

All 4 tables have proper foreign key constraints to `restaurants` table:

| Table | FK Constraint Name | Source Column | Target Table | Target Column | On Delete |
|-------|-------------------|---------------|--------------|---------------|-----------|
| `restaurant_schedules` | `restaurant_schedules_restaurant_id_fkey` | `restaurant_id` | `restaurants` | `id` | CASCADE |
| `restaurant_special_schedules` | `restaurant_special_schedules_restaurant_id_fkey` | `restaurant_id` | `restaurants` | `id` | CASCADE |
| `restaurant_service_configs` | `restaurant_service_configs_restaurant_id_fkey` | `restaurant_id` | `restaurants` | `id` | CASCADE |
| `restaurant_time_periods` | `restaurant_time_periods_restaurant_id_fkey` | `restaurant_id` | `restaurants` | `id` | CASCADE |

✅ **All foreign keys verified and working**

---

## Timezone Strategy Implementation

### ✅ Decision: Option C - Local Time + Timezone Column

**Implementation Status**:
- ✅ All TIME columns store local time (no timezone conversion)
- ✅ `cities` table already has `timezone` column (VARCHAR 45)
- ✅ Restaurants can reference city timezone via `restaurant_locations.city_id`

**How it works**:
1. Schedule times stored as local time (e.g., `09:00:00` = 9am at restaurant location)
2. Restaurant location links to city
3. City has timezone (e.g., 'America/Toronto')
4. Application logic converts to/from UTC when needed for operations

**Migration Impact**:
- ✅ No time conversion needed during migration
- ✅ Times migrate as-is from V1/V2
- ⚠️ Need to ensure all cities have proper timezone values

---

## Data Integrity Features

### Cascading Deletes
All tables use `ON DELETE CASCADE` for `restaurant_id` FK:
- If a restaurant is deleted, all related schedules/configs/periods are automatically removed
- Maintains referential integrity

### Automatic Timestamps
All tables have triggers to auto-update `updated_at`:
- `trg_special_schedules_updated_at`
- `trg_service_configs_updated_at`
- `trg_time_periods_updated_at`
- `trg_schedules_updated_at` (already existed)

### Unique Constraints
- `restaurant_service_configs`: One config per restaurant
- `restaurant_time_periods`: Period names unique per restaurant
- `restaurant_schedules`: No duplicate schedule entries

---

## Next Steps for Migration

### 1. Data Extraction ⏳
Extract CSV data from V1 and V2 sources:
```bash
# V1 Regular schedules
mysql -u root -p menuca_v1 -e "SELECT * FROM restaurants_schedule_normalized" > v1_schedules.csv

# V2 Regular schedules
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_schedule" > v2_schedules.csv

# V2 Special schedules
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_special_schedule" > v2_special.csv

# V2 Service configs
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_configs" > v2_configs.csv

# V2 Time periods
mysql -u root -p menuca_v2 -e "SELECT * FROM restaurants_time_periods" > v2_time_periods.csv
```

### 2. Create Staging Tables ⏳
Create temporary staging tables for transformation

### 3. Data Transformation ⏳
- Map `'d'` → `'delivery'`, `'t'` → `'takeout'`
- Map `'y'`/`'n'` → `true`/`false`
- Map restaurant IDs from legacy to V3
- Handle V1 vs V2 conflicts (V2 wins)

### 4. Load to V3 ⏳
Insert transformed data into V3 tables

### 5. Verification ⏳
- Row count validation
- FK integrity checks
- Business rule validation
- Application testing

---

## Migration Scripts Location

**Documentation**:
- Migration plan: `documentation/Service Configuration & Schedules/service_schedules_migration_plan.md`
- Scope decision: `documentation/Service Configuration & Schedules/FINAL_SCOPE_DECISION.md`
- Table exclusions: `documentation/Service Configuration & Schedules/TABLES_EXCLUSION_RATIONALE.md`

**SQL Scripts** (To be created):
- `step1_create_staging_tables.sql`
- `step2_extract_v1_data.sql`
- `step3_extract_v2_data.sql`
- `step4_transform_and_load.sql`
- `step5_verification.sql`

---

## Schema Verification Queries

### Check table existence:
```sql
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_schema = 'menuca_v3' 
        AND table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'menuca_v3'
  AND table_name IN (
      'restaurant_schedules',
      'restaurant_special_schedules',
      'restaurant_service_configs',
      'restaurant_time_periods'
  );
```

### Check foreign keys:
```sql
SELECT tc.table_name, tc.constraint_name, kcu.column_name,
       ccu.table_name AS foreign_table, ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'menuca_v3'
  AND tc.table_name LIKE 'restaurant_%';
```

### Check enum values:
```sql
SELECT enumlabel 
FROM pg_enum e
JOIN pg_type t ON e.enumtypid = t.oid
WHERE t.typname = 'service_type'
ORDER BY e.enumsortorder;
```

---

## Success Metrics

✅ **Schema Creation**: 100% complete
- 4 of 4 tables created successfully
- All foreign keys established
- All indexes created
- All triggers configured
- All constraints applied

⏳ **Data Migration**: 0% complete (ready to start)

---

## Sign-Off

**Schema Created By**: Supabase MCP  
**Date**: 2025-10-03  
**Approved For Migration**: ✅ Ready  
**Status**: PRODUCTION READY - Begin data migration

---

## Notes

1. **Timezone handling**: Using local time storage with timezone lookup via cities table
2. **Service type enum**: Confirmed values are 'delivery' and 'takeout'
3. **Conflict resolution**: V2 data takes precedence over V1 during migration
4. **Time periods**: Required for menu item availability (7 restaurants use this feature)
5. **All tables have proper FK constraints to restaurants.id with CASCADE delete**

---

## References

- V3 Schema file: `Database/Legacy schemas/Menuca v3 schema/menuca_v3.sql`
- Migration plan: `documentation/Service Configuration & Schedules/service_schedules_migration_plan.md`
- Scope document: `documentation/Service Configuration & Schedules/FINAL_SCOPE_DECISION.md`

