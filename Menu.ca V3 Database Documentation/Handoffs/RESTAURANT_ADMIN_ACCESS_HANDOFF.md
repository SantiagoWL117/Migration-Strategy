/# Restaurant Admin Access Control Handoff

> **Document Purpose:** Explains how Restaurant Admin users access data, what tables/rows they can modify, and how cross-restaurant restrictions are enforced.

---

## 1. Example User Profile

| Field | Value |
|-------|-------|
| **Admin ID** | 984 |
| **Email** | scottd.budden@gmail.com |
| **Name** | Scott Budden |
| **Role ID** | 2 |
| **Role Name** | Restaurant Admin |
| **Status** | active |
| **Assigned Restaurant** | Centertown Donair & Pizza (ID: 131) |

---

## 2. Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AUTHENTICATION FLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   1. User logs in via Supabase Auth                                         │
│      ↓                                                                       │
│   2. Receives JWT token containing auth.uid() = auth_user_id                │
│      ↓                                                                       │
│   3. Frontend makes request to Supabase (REST API or Realtime)              │
│      ↓                                                                       │
│   4. PostgreSQL RLS policies evaluate using auth.uid()                      │
│      ↓                                                                       │
│   5. current_admin_restaurant_ids() returns [131]                           │
│      ↓                                                                       │
│   6. Query filtered to only rows where restaurant_id = 131                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Access Permissions by Table

### 3.1 Full CRUD Access (13 Tables)

These tables allow **SELECT, INSERT, UPDATE, DELETE** operations for the admin's assigned restaurants.

| Table | Key Column | Example Row Count (ID 131) | Operations |
|-------|------------|---------------------------|------------|
| `restaurants` | `id` | 1 | Edit restaurant name, settings |
| `restaurant_locations` | `restaurant_id` | 1 | Edit address, phone, email |
| `restaurant_domains` | `restaurant_id` | 1-2 | Manage custom domains |
| `restaurant_subdomains` | `restaurant_id` | 0-1 | Manage subdomain |
| `restaurant_onboarding` | `restaurant_id` | 1 | Track onboarding status |
| `restaurant_payment_options` | `restaurant_id` | 0-5 | Configure payment methods |
| `restaurant_cuisines` | `restaurant_id` | 1-3 | Assign cuisine types |
| `restaurant_schedules` | `restaurant_id` | ~14 | Set operating hours (7 days × 2 services) |
| `restaurant_special_schedules` | `restaurant_id` | 0-10 | Holiday/special hours |
| `restaurant_delivery_areas` | `restaurant_id` | 1-5 | Define delivery zones |
| `delivery_and_pickup_configs` | `restaurant_id` | 1 | Delivery/pickup settings |
| `restaurant_delivery_companies` | `restaurant_id` | 0-3 | Assign delivery providers |
| `restaurant_distance_based_delivery_fees` | `restaurant_id` | 0-10 | Distance-based fee tiers |

### 3.2 Read-Only Access (3 Tables)

These tables allow **SELECT only** - no modifications.

| Table | Key Column | Reason for Read-Only |
|-------|------------|---------------------|
| `restaurant_analytics_configs` | `restaurant_id` | Analytics settings managed by platform |
| `restaurant_reviews` | `restaurant_id` | Customer reviews - admin can view, not edit |
| `delivery_company_emails` | (global) | Lookup table - shared across all restaurants |

### 3.3 Global Lookup Tables (1 Table)

| Table | Access | Description |
|-------|--------|-------------|
| `restaurant_tags` | SELECT (all authenticated) | Global tag definitions, shared across platform |

---

## 4. Cross-Restaurant Restriction Enforcement

### 4.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MULTI-TENANCY ENFORCEMENT                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌──────────────────┐                                                       │
│   │   JWT Token      │ Contains: auth.uid() = 'd0a48b93-9ba9-...'           │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ▼                                                                 │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │   current_admin_restaurant_ids()                                  │      │
│   │   ────────────────────────────────────────────────────────────── │      │
│   │   SECURITY DEFINER function that:                                 │      │
│   │   1. Looks up admin_users by auth.uid()                          │      │
│   │   2. Joins admin_user_restaurants                                 │      │
│   │   3. Returns SETOF bigint (restaurant IDs)                       │      │
│   │                                                                   │      │
│   │   For user 984: Returns {131}                                    │      │
│   └────────┬─────────────────────────────────────────────────────────┘      │
│            │                                                                 │
│            ▼                                                                 │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │   RLS Policy on each table                                        │      │
│   │   ────────────────────────────────────────────────────────────── │      │
│   │   USING (restaurant_id IN (SELECT current_admin_restaurant_ids()))│      │
│   │   WITH CHECK (restaurant_id IN (SELECT current_admin_restaurant_ids()))│ │
│   └────────┬─────────────────────────────────────────────────────────┘      │
│            │                                                                 │
│            ▼                                                                 │
│   ┌──────────────────┐                                                       │
│   │   Filtered Data  │ Only rows where restaurant_id = 131                  │
│   └──────────────────┘                                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 The Helper Function

```sql
CREATE OR REPLACE FUNCTION menuca_v3.current_admin_restaurant_ids()
RETURNS SETOF bigint
LANGUAGE sql
SECURITY DEFINER          -- Runs as postgres, bypasses RLS
STABLE                    -- Results consistent within transaction
SET search_path = 'menuca_v3', 'auth'
AS $$
  SELECT aur.restaurant_id::bigint
  FROM menuca_v3.admin_user_restaurants aur
  JOIN menuca_v3.admin_users au ON au.id = aur.admin_user_id
  WHERE au.auth_user_id = auth.uid()    -- JWT user ID
    AND au.deleted_at IS NULL           -- Not soft-deleted
    AND au.status = 'active';           -- Account is active
$$;
```

**Why SECURITY DEFINER?**
- The function needs to read `admin_users` and `admin_user_restaurants`
- Those tables have restrictive RLS (service_role only)
- SECURITY DEFINER runs as the function owner (postgres), bypassing RLS
- Returns only restaurant IDs - no sensitive data exposed

### 4.3 RLS Policy Pattern

Every table uses the same pattern:

```sql
-- Full CRUD policy
CREATE POLICY "admin_crud_own_restaurants" ON menuca_v3.restaurants
FOR ALL                    -- Applies to SELECT, INSERT, UPDATE, DELETE
TO authenticated           -- Only for logged-in users
USING (                    -- Filter for SELECT/UPDATE/DELETE
  id IN (SELECT menuca_v3.current_admin_restaurant_ids())
)
WITH CHECK (               -- Validate for INSERT/UPDATE
  id IN (SELECT menuca_v3.current_admin_restaurant_ids())
);

-- Read-only policy (no WITH CHECK)
CREATE POLICY "admin_select_own_restaurant_reviews" ON menuca_v3.restaurant_reviews
FOR SELECT                 -- Only SELECT allowed
TO authenticated
USING (
  restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids())
);
```

### 4.4 Data Flow Example

**Scenario:** User 984 (Scott Budden) queries `restaurant_schedules`

```sql
-- User's query (from frontend)
SELECT * FROM menuca_v3.restaurant_schedules;

-- What PostgreSQL actually executes (with RLS):
SELECT * FROM menuca_v3.restaurant_schedules
WHERE restaurant_id IN (
  SELECT aur.restaurant_id::bigint
  FROM menuca_v3.admin_user_restaurants aur
  JOIN menuca_v3.admin_users au ON au.id = aur.admin_user_id
  WHERE au.auth_user_id = 'd0a48b93-9ba9-4020-9813-894f5ccdab02'  -- From JWT
    AND au.deleted_at IS NULL
    AND au.status = 'active'
);

-- Result: Only schedules for restaurant_id = 131
```

---

## 5. Security Guarantees

### 5.1 What User 984 CAN Do

| Action | Example |
|--------|---------|
| ✅ View their restaurant's data | `SELECT * FROM restaurants WHERE id = 131` |
| ✅ Edit their restaurant's schedules | `UPDATE restaurant_schedules SET ... WHERE restaurant_id = 131` |
| ✅ Add delivery areas | `INSERT INTO restaurant_delivery_areas (restaurant_id, ...) VALUES (131, ...)` |
| ✅ Delete their payment options | `DELETE FROM restaurant_payment_options WHERE restaurant_id = 131` |

### 5.2 What User 984 CANNOT Do

| Action | Result |
|--------|--------|
| ❌ View another restaurant's data | Query returns 0 rows |
| ❌ Insert data for another restaurant | `WITH CHECK` violation error |
| ❌ Update another restaurant | Update affects 0 rows |
| ❌ Delete another restaurant's data | Delete affects 0 rows |
| ❌ Modify analytics configs | No INSERT/UPDATE/DELETE policy |
| ❌ Edit customer reviews | No INSERT/UPDATE/DELETE policy |

### 5.3 Attempted Cross-Restaurant Access

```sql
-- User 984 attempts to view restaurant 349 (Shawarma Palace)
SELECT * FROM menuca_v3.restaurants WHERE id = 349;
-- Result: 0 rows (RLS filters it out)

-- User 984 attempts to insert schedule for restaurant 349
INSERT INTO menuca_v3.restaurant_schedules (restaurant_id, day_of_week, ...)
VALUES (349, 1, ...);
-- Result: ERROR: new row violates row-level security policy

-- User 984 attempts to update restaurant 349
UPDATE menuca_v3.restaurants SET name = 'Hacked!' WHERE id = 349;
-- Result: UPDATE 0 (no rows affected)
```

---

## 6. Admin Assignment Management

### 6.1 Current Assignment (User 984)

```sql
SELECT * FROM menuca_v3.admin_user_restaurants WHERE admin_user_id = 984;
```

| id | admin_user_id | restaurant_id | created_at |
|----|---------------|---------------|------------|
| 145 | 984 | 131 | 2025-10-30 |

### 6.2 Granting Access to Additional Restaurants

Only Super Admins can modify restaurant assignments:

```sql
-- Via SQL function (called by Edge Function)
SELECT * FROM menuca_v3.assign_restaurants_to_admin(
  984,                      -- admin_user_id
  ARRAY[131, 349]::bigint[], -- restaurant_ids (add restaurant 349)
  'add'                     -- action: add, remove, or replace
);
```

### 6.3 Impact of Assignment Changes

When a restaurant is added to user 984's assignments:
1. `admin_user_restaurants` gets a new row
2. `current_admin_restaurant_ids()` immediately returns the new ID
3. All RLS policies automatically include the new restaurant
4. No policy changes needed - access is data-driven

---

## 7. Tables with RLS Policies Summary

| Table | RLS Enabled | Admin Policy | Service Role Policy |
|-------|-------------|--------------|---------------------|
| `restaurants` | ✅ | `admin_crud_own_restaurants` | `restaurants_service_role_all` |
| `restaurant_locations` | ✅ | `admin_crud_own_restaurant_locations` | `locations_service_role_all` |
| `restaurant_domains` | ✅ | `admin_crud_own_restaurant_domains` | `domains_service_role_all` |
| `restaurant_subdomains` | ✅ | `admin_crud_own_restaurant_subdomains` | `restaurant_subdomains_service_role_all` |
| `restaurant_onboarding` | ✅ | `admin_crud_own_restaurant_onboarding` | `restaurant_onboarding_service_role_all` |
| `restaurant_payment_options` | ✅ | `admin_crud_own_restaurant_payment_options` | `restaurant_payment_options_service_role_all` |
| `restaurant_cuisines` | ✅ | `admin_crud_own_restaurant_cuisines` | `restaurant_cuisines_service_role_all` |
| `restaurant_schedules` | ✅ | `admin_crud_own_restaurant_schedules` | `schedules_service_role_all` |
| `restaurant_special_schedules` | ✅ | `admin_crud_own_restaurant_special_schedules` | `special_schedules_service_role_all` |
| `restaurant_delivery_areas` | ✅ | `admin_crud_own_restaurant_delivery_areas` | `delivery_areas_service_role_all` |
| `delivery_and_pickup_configs` | ✅ | `admin_crud_own_delivery_and_pickup_configs` | `delivery_pickup_service_role_all` |
| `restaurant_delivery_companies` | ✅ | `admin_crud_own_restaurant_delivery_companies` | `delivery_companies_service_role_all` |
| `restaurant_distance_based_delivery_fees` | ✅ | `admin_crud_own_restaurant_distance_based_delivery_fees` | `distance_fees_service_role_all` |
| `restaurant_analytics_configs` | ✅ | `admin_select_own_restaurant_analytics_configs` (SELECT) | `restaurant_analytics_configs_service_role_all` |
| `restaurant_reviews` | ✅ | `admin_select_own_restaurant_reviews` (SELECT) | `restaurant_reviews_service_role_all` |
| `delivery_company_emails` | ✅ | `admin_select_delivery_emails` (SELECT, global) | `delivery_company_emails_service_role_all` |
| `restaurant_tags` | ✅ | `authenticated_read_tags` (SELECT, global) | `restaurant_tags_service_role_all` |

---

## 8. Key Files & Resources

| Resource | Path/Location |
|----------|---------------|
| Admin Entity Documentation | `Menu.ca V3/entities/06-admin-entity.md` |
| RLS Migration File | `Database/Migrations/2026-01-23_restaurant_admin_rls_policies.sql` |
| Access Control Plan | `.cursor/plans/restaurant_admin_rls_access_33a53514.plan.md` |
| Helper Function | `menuca_v3.current_admin_restaurant_ids()` |

---

## 9. Testing Checklist

To verify access control for a Restaurant Admin:

- [ ] User can SELECT from their assigned restaurant's tables
- [ ] User cannot SELECT from other restaurants (0 rows returned)
- [ ] User can INSERT with their restaurant_id
- [ ] User cannot INSERT with another restaurant_id (RLS violation)
- [ ] User can UPDATE their restaurant's rows
- [ ] User cannot UPDATE other restaurants (0 rows affected)
- [ ] User can DELETE their restaurant's rows
- [ ] User cannot DELETE other restaurants (0 rows affected)
- [ ] Read-only tables reject INSERT/UPDATE/DELETE
- [ ] Adding restaurant assignment immediately grants access
- [ ] Removing restaurant assignment immediately revokes access

---

**Last Updated:** 2026-01-28
**Author:** Database Administration
