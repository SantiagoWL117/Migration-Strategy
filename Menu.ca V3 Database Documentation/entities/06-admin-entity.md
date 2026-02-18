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

- [🔐 Relationship with Supabase Auth](#-relationship-with-supabase-auth)
- [📊 Tables](#-tables) — `admin_users`, `admin_user_restaurants`, `admin_roles`, `admin_audit_log`
- [👁️ Views](#️-views) — `active_admin_users`
- [🎨 Custom Types](#-custom-types)
- [🔧 SQL Functions](#-sql-functions)
- [⚡ Edge Functions](#-edge-functions)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [🗑️ Migration History](#️-migration-history)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)

---

## 📊 Tables

### Core Admin Tables (Active)

#### `admin_users` (177 records)
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

#### `active_admin_users` (176 records)
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

## 🗑️ Migration History

**Tables dropped (7):** `admin_user_preferences`, `admin_action_logs`, `restaurant_admin_users`, `restaurant_admin_users_archive`, `restaurant_admin_users_analytics`, `admin_consolidation_summary` (2026-01-19); `restaurant_contacts` (2026-01-16, data merged into `admin_users`).

**Columns dropped (5):** `mfa_enabled`, `mfa_secret`, `mfa_backup_codes`, `password_hash` (2026-01-16, auth handled by Supabase); `role` from `admin_user_restaurants` (unused).

**Functions/triggers dropped:** `get_restaurant_primary_contact`, `add_primary_contact_onboarding`, `trg_contacts_updated_at`, `trg_admin_users_updated_at` (2026-01-18/19).

**Indexes dropped (5):** Redundant indexes on `admin_user_restaurants` replaced with clean `idx_admin_user_restaurants_admin_user_id` and `idx_admin_user_restaurants_restaurant_id` (2026-01-23).

**RLS additions:** Created `current_admin_restaurant_ids()` helper function. Enabled RLS on 7 tables. Created 17 restaurant admin access policies (13 CRUD + 3 SELECT + 1 global read). Fixed overly-permissive `delivery_company_emails` policy (2026-01-23).

**Data fixes:** Consolidated roles to 2 (Super Admin, Restaurant Admin). Cleaned test accounts. Filled missing phone numbers for 15 restaurant admins. Soft-deleted `system@menu.ca` (id=43). Linked 13 admins to existing `auth.users` records (2026-02-17).

---

## 🚨 Data Integrity Issues

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 | `idx_admin_users_email` is redundant with `admin_users_email_key` UNIQUE | 🟡 Medium | Open | Duplicate index — the UNIQUE constraint already provides BTREE lookup |
| 2 | `v1_admin_id` and `v2_admin_id` columns — legacy migration IDs | 🟡 Medium | Open | 143 and 30 non-null values respectively, but 0 functions/views reference them — candidates for drop |
| 3 | ~~15 active admins without `auth_user_id`~~ → 2 remaining | 🟡 Medium | Partial | 13 linked to existing auth.users (2026-02-17). 2 placeholder accounts remain: `erman_pizza_admin@placeholder.menu.ca` (Erman Pizza), `mont_liban_admin@placeholder.menu.ca` (Mont Liban) — need real emails or soft-delete |
| 4 | 9 admins without `role_id` | 🟡 Medium | Open | Internal staff accounts with no role assigned |
| 5 | 11 restaurants without any admin assigned | ℹ️ Info | Known | JJ's Shawarma, Milano (5), Nachos Loco (2), Poutinerie Québecurds (2), Vieux Hull Pizza |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |
| Views | 1 |
| Total Admin Users | 177 (176 active, 1 deleted) |
| Admin Roles | 2 (Super Admin: 3, Restaurant Admin: 162+) |
| Admin-Restaurant Assignments | 186 |
| Audit Log Entries | 3 |
| SQL Functions | 5 |
| Edge Functions | 3 |
| Indexes | 20 |
| Custom Types | 2 |
| RLS Policies | 19 (2 core + 17 restaurant admin access) |

---

**Last Updated:** 2026-02-17
