# Tenant ID Analysis Report - MenuCA V3

## Executive Summary
Tenant ID exists in V3 and is used extensively across 31 tables for multi-tenant isolation. However, there's a data quality issue where some records have incorrect tenant_id values.

## What is Tenant ID?

### Original Intent:
- **Tenant ID = Restaurant UUID** (each restaurant is its own tenant)
- Used for Row-Level Security (RLS) to isolate data between restaurants
- Ensures Restaurant A cannot see/modify Restaurant B's data

### Current State in V3:
- ? **31 tables** have tenant_id column
- ? **15,740 dishes** (68.4%) have correct tenant_id matching their restaurant's UUID
- ? **7,266 dishes** (31.6%) have incorrect tenant_id values
- ? **Most problematic**: One tenant_id (68adb3a4-1dc6-46fd-8cc8-126003d8df92) is incorrectly used by 57 different restaurants

## Tables Using Tenant ID

All menu-related tables include tenant_id:
- active_combo_groups
- active_courses
- active_dish_modifiers
- active_dishes
- active_ingredient_groups
- active_ingredients
- active_schedules
- active_special_schedules
- active_time_periods
- combo_group_modifier_pricing
- combo_groups
- combo_items
- combo_steps
- courses
- devices
- dish_modifier_prices
- dish_modifiers
- dishes
- ingredient_group_items
- ingredient_groups
- ingredients
- promotional_coupons
- promotional_deals
- restaurant_locations
- restaurant_schedules
- restaurant_service_configs
- restaurant_special_schedules
- restaurant_tag_associations
- restaurant_time_periods
- vendor_commission_reports
- vendor_restaurants

## How Tenant ID Was Used in V1/V2

Based on the migration patterns:
- **V1**: No explicit tenant_id (single-tenant system)
- **V2**: No explicit tenant_id (restaurant isolation via foreign keys)
- **V3**: Introduced tenant_id for enterprise multi-tenant architecture

## How We're Using It Now in V3

### Security Layer (RLS Policies):
```sql
-- Example RLS policy using tenant_id
CREATE POLICY "tenant_manage_dishes"
ON menuca_v3.dishes FOR ALL TO public
USING (tenant_id = auth.jwt() ->> 'tenant_id');
```

### Data Isolation:
- Each restaurant admin's JWT contains their restaurant's UUID as tenant_id
- RLS automatically filters all queries to show only their restaurant's data
- Prevents cross-restaurant data access

### Current Implementation Issues:

1. **Incorrect Tenant Assignments**: 
   - 57 restaurants share tenant_id `68adb3a4-1dc6-46fd-8cc8-126003d8df92`
   - This breaks isolation - these restaurants can see each other's data!

2. **No Tenant ID in Restaurants Table**:
   - The restaurants table itself doesn't have tenant_id
   - This is actually correct - a restaurant IS the tenant

3. **Missing Relationships**:
   - Users table doesn't have tenant_id
   - Admin users are linked via restaurant_admin_users junction table

## SQL to Fix Tenant ID Issues

```sql
-- Fix dishes where tenant_id doesn't match restaurant UUID
UPDATE menuca_v3.dishes d
SET tenant_id = r.uuid
FROM menuca_v3.restaurants r
WHERE d.restaurant_id = r.id
  AND d.tenant_id != r.uuid;

-- Similar updates needed for all 31 tables with tenant_id
```

## Recommendations

1. **Immediate Action**: Fix all mismatched tenant_ids to restore proper isolation
2. **Validation**: Add constraints to ensure tenant_id always matches restaurant UUID
3. **Migration Review**: Investigate why 57 restaurants got the same tenant_id
4. **Testing**: Verify RLS policies work correctly after tenant_id correction

## Impact if Not Fixed

- **Security Risk**: 57 restaurants can potentially access each other's data
- **Data Integrity**: Orders/modifications might affect wrong restaurant
- **Compliance**: Violates data isolation requirements
- **Business Risk**: Competitors could see each other's menus/pricing

## Summary

Tenant ID was correctly designed in V3 as a multi-tenant isolation mechanism where each restaurant is its own tenant. However, the migration process incorrectly assigned the same tenant_id to multiple restaurants, breaking the isolation model. This needs immediate correction to ensure proper security and data isolation.