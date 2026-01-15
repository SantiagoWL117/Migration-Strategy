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
│                     │         │ mfa_enabled         │
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

#### `admin_users` (457 records)
**Purpose:** Platform administrators - linked to Supabase Auth

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `auth_user_id` | uuid | **FK to auth.users.id** |
| `email` | varchar | Admin email (unique) |
| `first_name` | varchar | First name |
| `last_name` | varchar | Last name |
| `role_id` | bigint | FK to admin_roles |
| `status` | admin_user_status | active/suspended/inactive |
| `is_active` | boolean | Account active (default true) |
| `mfa_enabled` | boolean | MFA enabled |
| `mfa_secret` | varchar | MFA secret key |
| `mfa_backup_codes` | text[] | MFA backup codes |
| `password_hash` | varchar | Legacy password hash |
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

#### `admin_user_restaurants` (167 records)
**Purpose:** Admin-to-restaurant assignments (multi-tenancy)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `admin_user_id` | bigint | FK to admin_users | 
| `restaurant_id` | integer | FK to restaurants |
| `role` | varchar | Access role (default 'staff') |
| `created_at` | timestamptz | Assignment date |

---

#### `admin_roles` (5 records)
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
| ID | Name | Description | Access |
|----|------|-------------|--------|
| 1 | Super Admin | Full platform access | All pages, all restaurants |
| 2 | Manager | Manager access | restaurants, orders (assigned) |
| 3 | Support | Support access | orders, customers (all restaurants) |
| 5 | Restaurant Manager | Manage assigned restaurants | menu, deals, orders (assigned) |
| 6 | Staff | View-only access | orders (assigned) |

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

#### `admin_user_preferences` (0 records)
**Purpose:** Admin UI preferences (empty - not yet used)

---

#### `admin_action_logs` (0 records)
**Purpose:** Detailed action logs (empty - not yet used)

---

### Legacy Tables (Migration)

#### `restaurant_admin_users` (163 records)
**Purpose:** Legacy restaurant-specific admin system (pre-consolidation)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `uuid` | uuid | External identifier |
| `restaurant_id` | bigint | FK to restaurants |
| `user_type` | varchar | User type (default 'r') |
| `first_name` | varchar | First name |
| `last_name` | varchar | Last name |
| `email` | varchar | Email |
| `password_hash` | varchar | Password hash |
| `last_login_at` | timestamptz | Last login |
| `login_count` | integer | Login count |
| `is_active` | boolean | Active |
| `sends_statements` | boolean | Receives statements |
| `migrated_to_admin_user_id` | bigint | Link to migrated admin_user |
| `created_at` | timestamptz | Created |
| `updated_at` | timestamptz | Updated |

---

#### `restaurant_admin_users_archive` (438 records)
**Purpose:** Archived legacy restaurant admins

---

#### `restaurant_admin_users_analytics` (1 record)
**Purpose:** Legacy analytics (migration tracking)

---

#### `admin_consolidation_summary` (1 record)
**Purpose:** Migration summary from legacy to unified admin system

---

## 👁️ Views

#### `active_admin_users` (457 records)
**Purpose:** Active admins filter

```sql
SELECT id, email, first_name, last_name, mfa_enabled, 
       is_active, status, last_login_at, auth_user_id, 
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

| Function | Arguments | Returns | Purpose |
|----------|-----------|---------|---------|
| `get_admin_profile` | (none) | TABLE | Get current admin's profile using `auth.uid()` |
| `get_admin_restaurants` | (none) | TABLE | Get restaurants assigned to current admin |
| `get_admin_devices` | (none) | TABLE | Get devices for current admin |
| `get_my_admin_info` | (none) | TABLE | Get admin info |
| `check_admin_restaurant_access` | (p_restaurant_id) | boolean | Verify current admin has access to restaurant |
| `assign_restaurants_to_admin` | (p_admin_user_id, p_restaurant_ids[], p_action) | void | Assign/remove restaurant access |
| `log_admin_audit` | (...params) | void | Log audit event |

**Example - Get Current Admin Profile:**
```sql
SELECT * FROM menuca_v3.get_admin_profile();
-- Uses auth.uid() to find the admin_user matching current JWT
```

**Example - Check Restaurant Access:**
```sql
SELECT menuca_v3.check_admin_restaurant_access(123::bigint);
-- Returns TRUE if current admin has access to restaurant 123
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

| Index | Table | Columns | Type |
|-------|-------|---------|------|
| `admin_users_pkey` | admin_users | id | PRIMARY |
| `admin_users_email_key` | admin_users | email | UNIQUE |
| `idx_admin_users_email` | admin_users | email | BTREE |
| `idx_admin_users_email_lower` | admin_users | lower(email) | BTREE |
| `idx_admin_users_auth_user_id` | admin_users | auth_user_id | BTREE |
| `idx_admin_users_auth_unique` | admin_users | auth_user_id | UNIQUE (where not null) |
| `idx_admin_users_deleted_at` | admin_users | deleted_at | PARTIAL (where null) |
| `idx_admin_users_mfa` | admin_users | id | PARTIAL (where mfa_enabled) |
| `idx_admin_users_v1_id` | admin_users | v1_admin_id | BTREE |
| `idx_admin_users_v2_id` | admin_users | v2_admin_id | BTREE |

---

## 🔒 RLS Policies

| Table | Policy | Operation | Description |
|-------|--------|-----------|-------------|
| admin_users | `admin_users_service_role_all` | ALL | Service role full access |

**Note:** Admin access is controlled via Edge Functions (service role) and SQL functions with `SECURITY DEFINER`. RLS is minimal as admins should only access their own data via controlled functions.

---

## ⚙️ Triggers

| Trigger | Table | Event | Purpose |
|---------|-------|-------|---------|
| `trg_admin_users_updated_at` | restaurant_admin_users | UPDATE | Auto-update `updated_at` |

---

## 📊 Data Quality

### Statistics (as of 2026-01-14)

| Metric | Value | Notes |
|--------|-------|-------|
| Total admin users | 457 | |
| Active (is_active=true) | 457 | 100% |
| With Supabase auth linked | 453 | 99% |
| With MFA enabled | 4 | 0.9% |
| Migrated from v1 | 404 | 88% |
| Never logged in | 457 | 100% ⚠️ |
| With restaurant access | 157 | 34% |
| Without restaurant access | 300 | 66% ⚠️ |

### Known Issues

| Issue | Count | Severity |
|-------|-------|----------|
| Duplicate emails | 0 | ✅ Clean |
| Missing first_name | 4 | 🟡 Low |
| Missing last_name | 40 | 🟡 Low |
| Test admin accounts | 7 | 🟠 Medium |
| Admins without restaurant access | 300 | 🟠 Medium |

### Test Admin Users (7)
| ID | Email |
|----|-------|
| 917 | test.admin@menu.ca |
| 918 | test.admin.FI9Smuit@menu.ca |
| 920 | final.test.PyT_P-kQ@menu.ca |
| 921 | complete.test.rW8K97@menu.ca |
| 922 | test.admin@worklocal.ca |
| 927 | testadmin@menu.ca |
| 931 | test-complete@menu.ca |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None yet |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 9 |
| Views | 1 |
| SQL Functions | 7 |
| Edge Functions | 3 |
| Indexes | 10 |
| Custom Types | 2 |

---

**Last Updated:** 2026-01-14
