# Remove tenant_id from menuca_v3 Schema

**Migration Date:** 2025-10-30
**Schema:** menuca_v3
**Purpose:** Remove redundant `tenant_id` (UUID) columns and use only `restaurant_id` (bigint FK) for all restaurant relationships

---

## Overview

This migration removes the `tenant_id` column from 31 tables in the menuca_v3 schema. The `tenant_id` was designed as a denormalized copy of `restaurants.uuid` for multi-tenant isolation, but has proven to be:

- **Redundant**: Duplicates information already available via `restaurant_id → restaurants.uuid`
- **Error-prone**: 432K+ records have incorrect tenant_id values due to migration issues
- **Underutilized**: Only 2 RLS policies actually use it
- **Unmaintained**: No foreign key constraints, leading to data integrity issues

After this migration, all relationships will use `restaurant_id` (FK to `restaurants.id`) exclusively.

---

## What Gets Changed

### Tables (31 total)
- 22 base tables: tenant_id column dropped
- 9 active_* views: recreated without tenant_id

### Indexes (21 total)
All indexes on tenant_id will be dropped:
- `idx_dishes_tenant_id`
- `idx_courses_tenant_id`
- `idx_promotional_deals_tenant`
- ... (18 more)

### Functions (13 total)
Functions updated to remove tenant_id references:
- `register_device`
- `add_restaurant_to_vendor`
- `notify_schedule_change` (trigger)
- `notify_location_change` (trigger)
- `create_flash_sale`
- ... (8 more onboarding/schedule functions)

### RLS Policies (2 total)
Policies updated to use restaurant_id access patterns:
- `promotional_coupons_translations.admin_manage_coupon_translations`
- `promotional_deals_translations.admin_manage_deal_translations`

---

## Migration Scripts

Execute in this order:

### 1. `01_BACKUP_AND_VALIDATION.sql`
**Purpose:** Pre-migration checks and backup creation

**Actions:**
- Validates current state
- Counts all objects to be modified
- Checks data quality
- Optionally creates backup schema

**Duration:** 1-2 minutes
**Reversible:** Yes (read-only)

---

### 2. `02_UPDATE_FUNCTIONS.sql`
**Purpose:** Remove tenant_id from SQL functions

**Actions:**
- Updates 5 core functions to remove tenant_id logic
- Removes tenant_id from function return types
- Removes tenant_id from INSERT/UPDATE statements

**Duration:** < 1 minute
**Reversible:** Yes (can restore old function definitions)

**Functions modified:**
- `register_device` - removed tenant_id from RETURNS TABLE
- `add_restaurant_to_vendor` - removed tenant_id INSERT
- `notify_schedule_change` - removed tenant_id from payload
- `notify_location_change` - removed tenant_id from payload
- `create_flash_sale` - removed tenant_id lookup and INSERT

---

### 3. `03_UPDATE_RLS_POLICIES.sql`
**Purpose:** Update RLS policies to use restaurant_id

**Actions:**
- Drops 2 existing tenant_id-based policies
- Creates new policies using restaurant_id access patterns
- Uses standard admin_user_restaurants JOIN pattern

**Duration:** < 1 minute
**Reversible:** Yes (can restore old policies)

**Impact:** Admin users will still have proper access control, but through `restaurant_id` instead of JWT `tenant_id` claim

---

### 4. `04_UPDATE_VIEWS.sql`
**Purpose:** Recreate views without tenant_id column

**Actions:**
- Recreates 9 active_* views
- Removes tenant_id from SELECT lists
- Maintains all other columns and WHERE clauses

**Duration:** < 1 minute
**Reversible:** Yes (can restore old view definitions)

**Views updated:**
- `active_dishes`
- `active_courses`
- `active_ingredients`
- `active_ingredient_groups`
- `active_combo_groups`
- `active_dish_modifiers`
- `active_schedules`
- `active_special_schedules`
- `active_time_periods`

---

### 5. `05_DROP_INDEXES_AND_COLUMNS.sql`
**Purpose:** Remove all tenant_id indexes and columns

**Actions:**
- Drops 21 indexes on tenant_id
- Drops tenant_id column from 22 base tables
- Runs comprehensive validation queries

**Duration:** 1-3 minutes (depending on table sizes)
**Reversible:** NO - requires restore from backup
**⚠️  CRITICAL:** This is the point of no return

**Tables modified (22 total):**
```
combo_group_modifier_pricing
combo_groups
combo_items
combo_steps
courses
devices
dish_modifier_prices
dish_modifiers
dishes
ingredient_group_items
ingredient_groups
ingredients
promotional_coupons
promotional_deals
restaurant_locations
restaurant_schedules
restaurant_service_configs
restaurant_special_schedules
restaurant_tag_associations
restaurant_time_periods
vendor_commission_reports
vendor_restaurants
```

---

## Pre-Migration Checklist

- [ ] **Backup database** (full backup or schema-only)
- [ ] **Review all scripts** in this directory
- [ ] **Test on staging environment** first
- [ ] **Notify team members** of scheduled maintenance
- [ ] **Check for running transactions** on affected tables
- [ ] **Have rollback plan ready** (restore from backup)
- [ ] **Schedule maintenance window** (estimated 10-15 minutes)

---

## Execution Instructions

### Option A: Step-by-Step Execution (Recommended)

Execute each script individually and verify results:

```bash
# 1. Validation
psql "$CONNECTION_STRING" -f 01_BACKUP_AND_VALIDATION.sql > validation_output.txt

# Review validation_output.txt, ensure everything looks correct

# 2. Update functions
psql "$CONNECTION_STRING" -f 02_UPDATE_FUNCTIONS.sql

# Verify: No functions should reference tenant_id

# 3. Update RLS policies
psql "$CONNECTION_STRING" -f 03_UPDATE_RLS_POLICIES.sql

# Verify: Policies work correctly

# 4. Update views
psql "$CONNECTION_STRING" -f 04_UPDATE_VIEWS.sql

# Verify: Views query successfully

# 5. Drop indexes and columns (IRREVERSIBLE)
psql "$CONNECTION_STRING" -f 05_DROP_INDEXES_AND_COLUMNS.sql

# Verify: All tenant_id columns and indexes are gone
```

### Option B: All-at-Once Execution (Advanced)

⚠️ **Not recommended** - harder to debug if something fails

```bash
cat 01_BACKUP_AND_VALIDATION.sql \
    02_UPDATE_FUNCTIONS.sql \
    03_UPDATE_RLS_POLICIES.sql \
    04_UPDATE_VIEWS.sql \
    05_DROP_INDEXES_AND_COLUMNS.sql \
    | psql "$CONNECTION_STRING"
```

---

## Post-Migration Tasks

### Immediate (Required)

1. **Vacuum and Analyze**
   ```sql
   VACUUM ANALYZE menuca_v3.dishes;
   VACUUM ANALYZE menuca_v3.courses;
   VACUUM ANALYZE menuca_v3.ingredients;
   -- ... repeat for all affected tables
   ```

2. **Test critical queries**
   - Menu retrieval by restaurant
   - Dish creation/updates
   - Promotional deals/coupons
   - Schedule operations

3. **Verify RLS policies work**
   - Test admin access to restaurant data
   - Verify proper isolation between restaurants

### Within 24 Hours

4. **Monitor query performance**
   - Check slow query logs
   - Compare query plans before/after
   - Add indexes on `restaurant_id` if needed (most already exist)

5. **Update application code** (if needed)
   - Remove JWT `tenant_id` claims generation
   - Update any client code expecting tenant_id in responses
   - Update API documentation

6. **Update ORM/Type definitions** (if applicable)
   - Remove tenant_id from TypeScript interfaces
   - Update database models
   - Regenerate schema types

---

## Rollback Procedure

### If migration fails during Steps 1-4:
Simply stop execution and restore function/policy/view definitions from backup or version control.

### If migration fails after Step 5:
**You MUST restore from database backup.**

The `99_ROLLBACK.sql` script is provided as a reference for understanding what needs to be restored, but it does NOT restore actual data.

**Proper rollback:**
```bash
# 1. Stop application
# 2. Restore database from backup
pg_restore -d your_database backup_file.dump
# 3. Verify restoration
# 4. Restart application
```

---

## Testing Recommendations

### Before Production Migration

Test on staging/dev environment:

1. **Functional tests:**
   - Create new restaurants
   - Add dishes, courses, ingredients
   - Create promotional deals
   - Update schedules

2. **Performance tests:**
   - Query dishes by restaurant (10,000+ rows)
   - Bulk operations on menu items
   - Concurrent writes to different restaurants

3. **Security tests:**
   - Verify RLS policies work correctly
   - Test admin access restrictions
   - Ensure proper restaurant isolation

### After Production Migration

1. **Smoke tests:**
   - Dashboard loads correctly
   - Menu management works
   - Orders can be placed
   - Admin panel accessible

2. **Monitor for 24-48 hours:**
   - Application logs
   - Database slow query logs
   - Error rates
   - User reports

---

## Estimated Downtime

| Environment | Table Sizes | Expected Downtime |
|-------------|-------------|-------------------|
| **Development** | < 100K rows | 2-5 minutes |
| **Staging** | 100K-1M rows | 5-10 minutes |
| **Production** | 1M+ rows | 10-15 minutes |

Downtime is primarily from:
- Dropping indexes (1-2 min per large table)
- Dropping columns (1-2 min per large table)
- Lock acquisition on busy tables

---

## Support

**Questions or issues during migration?**

- Check validation outputs after each step
- Review error messages in PostgreSQL logs
- Consult database administrator before proceeding if uncertain
- Have backup restoration procedure ready

**Success indicators:**
- All validation queries return 0 results (meaning no tenant_id remains)
- Views query successfully
- Application can query restaurants and menu items
- RLS policies enforce proper access control

---

## Summary

This migration simplifies the menuca_v3 schema by removing the redundant `tenant_id` column and consolidating on `restaurant_id` as the single source of truth for restaurant relationships.

**Benefits:**
- ✅ Eliminates 432K+ incorrect tenant_id values
- ✅ Simplifies schema (31 fewer columns)
- ✅ Reduces data redundancy
- ✅ Easier to maintain (one less field to sync)
- ✅ No performance impact (restaurant_id already indexed)

**Risks:**
- Application code may need updates if it relies on tenant_id
- JWT tokens with tenant_id claims will need to be updated
- Irreversible after Step 5 (requires backup restore)

Execute carefully and test thoroughly!
