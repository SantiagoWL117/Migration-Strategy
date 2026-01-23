# 06 - Admin Entity

> **Platform Administrators** - Restaurant managers, system administrators, and support staff

---

## 📋 Purpose

The Admin Entity manages **internal platform user access** for the Menu.ca admin portal:
- **Admin Users** - Platform users who manage restaurants (not customers)
- **Role-Based Access Control** - Roles with granular permissions
- **Restaurant Assignment** - Admin-to-restaurant multi-tenancy
- **Supabase Auth Integration** - JWT-based authentication via `auth.users`
- **Audit Logging** - Complete audit trail for admin actions

---

## 🔐 Relationship with Supabase Auth

The Admin Entity extends Supabase Auth (`auth.users`) with platform-specific data:

```
┌─────────────────────┐         ┌─────────────────────┐
│   auth.users        │ 1:1     │   admin_users       │
│   (Supabase Auth)   │◄───────►│   (menuca_v3)       │
├─────────────────────┤         ├─────────────────────┤
│ id (uuid)           │         │ auth_user_id (uuid) │
│ email               │         │ email               │
│ email_confirmed_at  │         │ first_name          │
│ last_sign_in_at     │         │ last_name           │
│ created_at          │         │ role_id             │
│ user_metadata       │         │ status              │
│                     │         │ preferred_language  │
└─────────────────────┘         └─────────────────────┘
```

**Authentication Flow:**
1. Admin logs in via Supabase Auth → receives JWT token
2. JWT contains `auth.uid()` (the `id` from `auth.users`)
3. SQL functions use `auth.uid()` to find the matching `admin_users.auth_user_id`
4. Admin's role and restaurant access is retrieved from `admin_users` + `admin_user_restaurants`

**Key Integration Points:**
- `auth_user_id` column links `admin_users` to `auth.users.id`
- `auth.uid()` function retrieves current authenticated user's ID
- Edge Functions use `supabaseAdmin.auth.admin.createUser()` to create auth users
- Password validation and MFA handled by Supabase Auth

---

## 📑 Index

- [Tables](#tables)
- [Views](#views)
- [Custom Types](#custom-types)
- [SQL Functions](#sql-functions)
- [Edge Functions](#edge-functions)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Triggers](#triggers)
- [Data Quality](#data-quality)
- [Removed Functionalities](#removed-functionalities)
- [Schema Fixes Applied](#schema-fixes-applied)

---

## 📊 Tables

### Core Admin Tables (Active)

#### `admin_users` (174 records)
**Purpose:** Platform administrators - linked to Supabase Auth

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `auth_user_id` | uuid | **FK to auth.users.id** |
| `email` | varchar | Admin email (unique) |
| `first_name` | varchar | First name |
| `last_name` | varchar | Last name |
| `phone` | varchar | Phone number |
| `preferred_language` | char(2) | Communication language (default 'en') |
| `role_id` | bigint | FK to admin_roles |
| `status` | admin_user_status | active/suspended/inactive |
| `is_active` | boolean | Account active (default true) |
| `last_login_at` | timestamptz | Last login |
| `suspended_at` | timestamptz | Suspension date |
| `suspended_reason` | text | Suspension reason |
| `v1_admin_id` | integer | Legacy v1 admin ID |
| `v2_admin_id` | integer | Legacy v2 admin ID |
| `created_at` | timestamptz | Account created |
| `updated_at` | timestamptz | Last updated |
| `deleted_at` | timestamptz | Soft delete |
| `deleted_by` | bigint | Who deleted |

---

#### `admin_user_restaurants` (186 records)
**Purpose:** Admin-to-restaurant assignments (multi-tenancy)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `admin_user_id` | bigint | FK to admin_users | 
| `restaurant_id` | integer | FK to restaurants |
| `created_at` | timestamptz | Assignment date |

---

#### `admin_roles` (2 records)
**Purpose:** Role definitions with JSONB permissions

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | varchar | Role name |
| `description` | varchar | Role description |
| `permissions` | jsonb | Permissions object |
| `is_system_role` | boolean | System-defined role |
| `created_at` | timestamptz | Created date |

**Defined Roles:**
| ID | Name | Description | Admin Count |
|----|------|-------------|-------------|
| 1 | Super Admin | Full platform access | 3 |
| 2 | Restaurant Admin | Full menu management for assigned restaurants | 162 |

---

#### `admin_audit_log` (3 records)
**Purpose:** Audit trail for admin actions

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `performed_by_admin_id` | bigint | Admin who performed action |
| `performed_by_email` | varchar | Admin's email |
| `action` | admin_audit_action | Action type (enum) |
| `target_admin_id` | bigint | Affected admin (if applicable) |
| `target_email` | varchar | Affected email |
| `details` | jsonb | Action details |
| `success` | boolean | Action succeeded |
| `error_message` | text | Error if failed |
| `ip_address` | inet | Client IP |
| `user_agent` | text | Browser info |
| `created_at` | timestamptz | Action timestamp |

---

## 👁️ Views

#### `active_admin_users` (174 records)
**Purpose:** Active admins filter

```sql
SELECT id, email, first_name, last_name, is_active, 
       status, last_login_at, auth_user_id, role_id,
       created_at, updated_at
FROM menuca_v3.admin_users
WHERE deleted_at IS NULL 
  AND status = 'active';
```

---

## 🎨 Custom Types

#### `admin_user_status`
```sql
ENUM ('active', 'suspended', 'inactive')
```

#### `admin_audit_action`
```sql
ENUM (
  'create_user', 'update_user', 'delete_user',
  'assign_restaurants', 'remove_restaurants', 'replace_restaurants',
  'update_role', 'suspend_user', 'activate_user',
  'failed_create', 'failed_update', 'failed_delete'
)
```

---

## 🔧 SQL Functions

| Function | Arguments | Returns | Purpose | Status |
|----------|-----------|---------|---------|--------|
| `get_admin_profile` | (none) | TABLE | Get current admin's profile using `auth.uid()` | ✅ Working |
| `get_admin_restaurants` | (none) | TABLE | Get restaurants assigned to current admin (with contact data) | ✅ Working |
| `check_admin_restaurant_access` | (p_restaurant_id bigint) | boolean | Verify current admin has access to restaurant | ✅ Working |
| `assign_restaurants_to_admin` | (p_admin_user_id bigint, p_restaurant_ids bigint[], p_action text) | TABLE | Assign/remove restaurant access (returns result summary) | ✅ Working |
| `current_admin_restaurant_ids` | (none) | SETOF bigint | Returns restaurant IDs the current admin has access to (used by RLS policies) | ✅ Working |

### Function Details

#### 1. `get_admin_profile()`
Returns current admin's profile based on JWT `auth.uid()`.

**Returns:** id, auth_user_id, email, first_name, last_name, phone, preferred_language, role_id, status, created_at, updated_at

```sql
SELECT * FROM menuca_v3.get_admin_profile();
```

#### 2. `get_admin_restaurants()`
Returns restaurants assigned to the current admin with contact info from `restaurant_locations`.

**Returns:** restaurant_id, restaurant_name, restaurant_slug, restaurant_phone, restaurant_email, assigned_at

```sql
SELECT * FROM menuca_v3.get_admin_restaurants();
```

#### 3. `check_admin_restaurant_access(p_restaurant_id)`
Verifies if the current admin (via JWT) has access to a specific restaurant.

```sql
SELECT menuca_v3.check_admin_restaurant_access(123::bigint);
-- Returns TRUE if current admin has access to restaurant 123
```

#### 4. `assign_restaurants_to_admin(...)`
Assigns, removes, or replaces restaurant access for an admin. Actions: `add`, `remove`, `replace`.

**Returns:** success, action, admin_user_id, admin_email, assignments_before, assignments_after, affected_count, message

```sql
SELECT * FROM menuca_v3.assign_restaurants_to_admin(
  123,                    -- admin_user_id
  ARRAY[349, 350]::bigint[],  -- restaurant_ids
  'add'                   -- action: add, remove, or replace
);
```

#### 5. `current_admin_restaurant_ids()`
Returns the restaurant IDs that the current admin user has access to. **Used by RLS policies** to enforce multi-tenancy.

**Security:** `SECURITY DEFINER` - bypasses RLS to access `admin_user_restaurants`, returns only restaurant IDs.

```sql
SELECT * FROM menuca_v3.current_admin_restaurant_ids();
-- Returns: 349, 350, 351 (restaurant IDs the current admin can access)
```

**Used in RLS policies:**
```sql
CREATE POLICY "admin_crud_own_restaurants" ON menuca_v3.restaurants
FOR ALL TO authenticated
USING (id IN (SELECT menuca_v3.current_admin_restaurant_ids()));
```

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose | Auth |
|----------|----------|---------|------|
| `create-admin-user` | POST `/functions/v1/create-admin-user` | Create new admin user | Super Admin only |
| `create-admin-user-v2` | POST `/functions/v1/create-admin-user-v2` | Create admin (v2) | Super Admin only |
| `assign-admin-restaurants` | POST `/functions/v1/assign-admin-restaurants` | Assign/remove restaurant access | Super Admin only |

**Create Admin User Flow:**
1. Validates calling user is Super Admin (role_id = 1)
2. Validates password strength (min 8 chars, uppercase, lowercase, number, special char)
3. Creates user in `auth.users` via `supabaseAdmin.auth.admin.createUser()`
4. Creates corresponding `admin_users` record with `auth_user_id`
5. Assigns restaurants via `admin_user_restaurants`
6. Logs to `admin_audit_log`

---

## 📇 Indexes

### `admin_users` (9 indexes)

| Index | Columns | Type |
|-------|---------|------|
| `admin_users_pkey` | id | PRIMARY |
| `admin_users_email_key` | email | UNIQUE |
| `idx_admin_users_email` | email | BTREE |
| `idx_admin_users_email_lower` | lower(email) | BTREE |
| `idx_admin_users_auth_user_id` | auth_user_id | BTREE |
| `idx_admin_users_auth_unique` | auth_user_id | UNIQUE (where not null) |
| `idx_admin_users_deleted_at` | deleted_at | PARTIAL (where null) |
| `idx_admin_users_v1_id` | v1_admin_id | BTREE |
| `idx_admin_users_v2_id` | v2_admin_id | BTREE |

### `admin_user_restaurants` (4 indexes)

| Index | Columns | Type |
|-------|---------|------|
| `admin_user_restaurants_pkey` | id | PRIMARY |
| `admin_user_restaurants_admin_user_id_restaurant_id_key` | (admin_user_id, restaurant_id) | UNIQUE |
| `idx_admin_user_restaurants_admin_user_id` | admin_user_id | BTREE |
| `idx_admin_user_restaurants_restaurant_id` | restaurant_id | BTREE |

### `admin_roles` (2 indexes)

| Index | Columns | Type |
|-------|---------|------|
| `admin_roles_pkey` | id | PRIMARY |
| `admin_roles_name_key` | name | UNIQUE |

### `admin_audit_log` (5 indexes)

| Index | Columns | Type |
|-------|---------|------|
| `admin_audit_log_pkey` | id | PRIMARY |
| `idx_audit_log_performed_by` | performed_by_admin_id | BTREE |
| `idx_audit_log_performed_action_date` | (performed_by_admin_id, action, created_at DESC) | BTREE |
| `idx_audit_log_target_admin` | target_admin_id | BTREE |
| `idx_audit_log_success` | success | BTREE |

---

## 🔒 RLS Policies

### Admin Entity Core Tables

| Table | Policy | Operation | Description |
|-------|--------|-----------|-------------|
| admin_users | `admin_users_service_role_all` | ALL | Service role full access |
| admin_user_restaurants | `admin_user_restaurants_service_role_all` | ALL | Service role full access |

**Note:** Core admin tables use service_role policies. Direct access controlled via Edge Functions and `SECURITY DEFINER` SQL functions.

### Restaurant Admin Access Policies (Created 2026-01-23)

Restaurant Admins can now perform CRUD operations on their assigned restaurants' data through RLS policies that use the `current_admin_restaurant_ids()` helper function.

#### Full CRUD Access (13 tables)

| Table | Policy | Description |
|-------|--------|-------------|
| restaurants | `admin_crud_own_restaurants` | Manage assigned restaurants (uses `id` column) |
| restaurant_locations | `admin_crud_own_restaurant_locations` | Manage location details |
| restaurant_domains | `admin_crud_own_restaurant_domains` | Manage custom domains |
| restaurant_subdomains | `admin_crud_own_restaurant_subdomains` | Manage subdomains |
| restaurant_onboarding | `admin_crud_own_restaurant_onboarding` | Manage onboarding status |
| restaurant_payment_options | `admin_crud_own_restaurant_payment_options` | Manage payment options |
| restaurant_cuisines | `admin_crud_own_restaurant_cuisines` | Manage cuisine assignments |
| restaurant_schedules | `admin_crud_own_restaurant_schedules` | Manage operating hours |
| restaurant_special_schedules | `admin_crud_own_restaurant_special_schedules` | Manage holiday hours |
| restaurant_delivery_areas | `admin_crud_own_restaurant_delivery_areas` | Manage delivery zones |
| delivery_and_pickup_configs | `admin_crud_own_delivery_and_pickup_configs` | Manage delivery/pickup settings |
| restaurant_delivery_companies | `admin_crud_own_restaurant_delivery_companies` | Manage delivery providers |
| restaurant_distance_based_delivery_fees | `admin_crud_own_restaurant_distance_based_delivery_fees` | Manage distance-based fees |

**Policy Pattern:**
```sql
FOR ALL TO authenticated
USING (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
WITH CHECK (restaurant_id IN (SELECT menuca_v3.current_admin_restaurant_ids()))
```

#### Read-Only Access (3 tables)

| Table | Policy | Description |
|-------|--------|-------------|
| restaurant_analytics_configs | `admin_select_own_restaurant_analytics_configs` | View analytics settings |
| restaurant_reviews | `admin_select_own_restaurant_reviews` | View customer reviews |
| delivery_company_emails | `admin_select_delivery_emails` | View delivery company emails (global lookup) |

#### Global Lookup Tables

| Table | Policy | Description |
|-------|--------|-------------|
| restaurant_tags | `authenticated_read_tags` | All authenticated users can read tags |

---

## ⚙️ Triggers

*No triggers remaining after dropping legacy tables.*

---

## 📊 Data Quality

### Statistics (as of 2026-01-23)

| Metric | Value | Notes |
|--------|-------|-------|
| Total admin users | 174 | |
| Active (is_active=true) | 174 | 100% |
| With Supabase auth linked | 160 | 91.4% |
| Without auth linked | 15 | 8.6% |
| Migrated from V1 | 143 | 81.7% |
| Migrated from V2 | 30 | 17.1% |
| Never logged in | 175 | 100% ⚠️ |
| With restaurant access | 162 | 92.6% ✅ |
| Without restaurant access | 12 | 6.9% (internal accounts) |
| Restaurants with admins | 175 | 94.1% |
| Restaurants without admins | 11 | 5.9% |

### Known Issues

| Issue | Count | Severity |
|-------|-------|----------|
| Duplicate emails | 0 | ✅ Clean |
| Missing phone (restaurant admins) | 0 | ✅ Clean |
| Missing phone (internal accounts) | 12 | ✅ Expected |
| Missing first_name | 4 | 🟡 Low |
| Missing last_name | 30 | 🟡 Low |
| Test admin accounts | 0 | ✅ Clean |
| Admins without restaurant access | 13 | ✅ Expected (internal/system) |
| Internal admins without role_id | 9 | 🟡 Consider assigning role |

### Internal Admins Without Restaurant Access (12)

These are internal Menu.ca/Worklocal staff accounts - no restaurant assignment needed:

| ID | Email | Role |
|----|-------|------|
| 18 | james.walker@menu.ca | Super Admin |
| 932 | santiago@worklocal.ca | Super Admin |
| 1099 | brian+1@worklocal.ca | Super Admin |
| 12 | chris@menu.ca | ⚠️ No role assigned |
| 16 | george@menu.ca | ⚠️ No role assigned |
| 19 | james@menu.ca | ⚠️ No role assigned |
| 23 | jordan@worklocal.ca | ⚠️ No role assigned |
| 33 | razvan@menu.ca | ⚠️ No role assigned |
| 40 | stefan@menu.ca | ⚠️ No role assigned |
| 41 | stephane@menu.ca | ⚠️ No role assigned |
| 49 | vendor2@menu.ca | ⚠️ No role assigned |
| 50 | yanni@menu.ca | ⚠️ No role assigned |

### Internal Admins Without Role (9)

These accounts have `role_id = NULL` and may need a role assignment:

| ID | Email | First Name | Last Name |
|----|-------|------------|-----------|
| 12 | chris@menu.ca | Christos | Bouziotas |
| 16 | george@menu.ca | george | nicolae |
| 19 | james@menu.ca | James | Walker |
| 23 | jordan@worklocal.ca | Jordan | James |
| 33 | razvan@menu.ca | razvan | c |
| 40 | stefan@menu.ca | Stefan | Dragos |
| 41 | stephane@menu.ca | Soupa | Stephane |
| 49 | vendor2@menu.ca | vendor | 2 |
| 50 | yanni@menu.ca | yanni | bouziotas |

### Restaurants Without Admin (11)

| V3 ID | Restaurant Name |
|-------|-----------------|
| 1021 | JJ's Shawarma |
| 126, 837, 92, 840, 821 | Milano (5 locations) |
| 801, 790 | Nachos Loco (2 locations) |
| 1015, 789 | Poutinerie Québecurds (2 locations) |
| 820 | Vieux Hull Pizza |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| 2026-01-19 | Table `admin_user_preferences` | Never used (0 records) |
| 2026-01-19 | Table `admin_action_logs` | Never used (0 records), replaced by `admin_audit_log` |
| 2026-01-19 | Table `restaurant_admin_users` | Migration complete (163→admin_users) |
| 2026-01-19 | Table `restaurant_admin_users_archive` | Legacy archive no longer needed |
| 2026-01-19 | Table `restaurant_admin_users_analytics` | Migration tracking complete |
| 2026-01-19 | Table `admin_consolidation_summary` | Migration audit complete |
| 2026-01-19 | Trigger `trg_admin_users_updated_at` | Was on dropped `restaurant_admin_users` table |
| 2026-01-18 | `get_restaurant_primary_contact(bigint, text, integer, boolean)` | Function dependent on deleted `restaurant_contacts` table |
| 2026-01-18 | `add_primary_contact_onboarding(bigint, varchar, varchar, varchar, varchar, char)` | Function dependent on deleted `restaurant_contacts` table |
| 2026-01-18 | Trigger `trg_contacts_updated_at` | Trigger on deleted `restaurant_contacts` table |
| 2026-01-18 | RLS Policy `contacts_service_role_all` | Policy on deleted `restaurant_contacts` table |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| 2026-01-16 | Removed MFA columns (mfa_enabled, mfa_secret, mfa_backup_codes) | MFA handled by Supabase Auth |
| 2026-01-16 | Removed password_hash column | Auth handled by Supabase |
| 2026-01-16 | Added phone column | Admin contact info |
| 2026-01-16 | Consolidated roles to 2 (Super Admin, Restaurant Admin) | Simplified RBAC |
| 2026-01-16 | Cleaned up test accounts | 0 test accounts remaining |
| 2026-01-16 | Dropped `role` column from `admin_user_restaurants` | Unused (all 186 rows had same default 'staff' value) |
| 2026-01-16 | Added `preferred_language` column to `admin_users` | Merged from `restaurant_contacts` (default 'en') |
| 2026-01-16 | Dropped `restaurant_contacts` table | Data merged into `admin_users`; table no longer needed |
| 2026-01-16 | Filled missing phone numbers for 15 restaurant admins | All 162 restaurant admins now have phone numbers |
| 2026-01-18 | Dropped functions for `restaurant_contacts` | `get_restaurant_primary_contact`, `add_primary_contact_onboarding` |
| 2026-01-18 | Updated `active_admin_users` view | Removed `mfa_enabled`, added `role_id` |
| 2026-01-19 | Dropped 6 unused/legacy tables | `admin_user_preferences`, `admin_action_logs`, `restaurant_admin_users`, `restaurant_admin_users_archive`, `restaurant_admin_users_analytics`, `admin_consolidation_summary` |
| 2026-01-23 | Dropped 5 redundant indexes on `admin_user_restaurants` | Removed `idx_admin_restaurants_admin`, `idx_admin_restaurants_restaurant`, `idx_admin_user_restaurants_admin`, `idx_admin_user_restaurants_admin_user`, `idx_admin_user_restaurants_restaurant`; created clean indexes `idx_admin_user_restaurants_admin_user_id` and `idx_admin_user_restaurants_restaurant_id` |
| 2026-01-23 | Soft deleted system@menu.ca (id=43) | Internal system account - unused, no role assigned |
| 2026-01-23 | Created `current_admin_restaurant_ids()` helper function | SECURITY DEFINER function for RLS policies, returns restaurant IDs for current admin |
| 2026-01-23 | Enabled RLS on 7 tables | restaurant_subdomains, restaurant_onboarding, restaurant_analytics_configs, restaurant_payment_options, restaurant_cuisines, restaurant_reviews, restaurant_tags |
| 2026-01-23 | Created 17 Restaurant Admin RLS policies | 13 CRUD + 3 SELECT-only + 1 global read policy for multi-tenant access control |
| 2026-01-23 | Fixed overly-permissive `delivery_company_emails` policy | Replaced `ALL authenticated` with `SELECT` only |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |
| Views | 1 |
| SQL Functions | 5 (all working) |
| Edge Functions | 3 |
| Indexes | 20 |
| Custom Types | 2 |
| RLS Policies | 19 (2 core + 17 restaurant admin access) |

---

**Last Updated:** 2026-01-23
