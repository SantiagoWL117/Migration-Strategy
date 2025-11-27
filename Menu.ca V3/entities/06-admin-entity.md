# 06 - Admin Entity

> **Internal Users** - Restaurant admins and system administrators

---

## 📋 Purpose

The Admin Entity manages **internal user access**:
- **Admin Users** - Restaurant managers and owners
- **Role Assignment** - Restaurant access control
- **Permissions** - Feature-level access
- **Authentication** - Admin-specific auth flows

---

## 📑 Index

- [Tables](#tables)
- [SQL Functions](#sql-functions)
- [Edge Functions](#edge-functions)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Triggers](#triggers)
- [Removed Functionalities](#removed-functionalities)
- [New Functionalities](#new-functionalities)
- [Schema Fixes Applied](#schema-fixes-applied)

---

## 📊 Tables

### Core Admin Tables

#### `admin_users`
**Purpose:** Restaurant administrators

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `uuid` | uuid | External identifier |
| `email` | varchar | Admin email |
| `full_name` | varchar | Admin name |
| `phone` | varchar | Contact phone |
| `role` | admin_role | super_admin/admin/manager |
| `is_active` | boolean | Account active |
| `last_login_at` | timestamptz | Last login |
| `created_at` | timestamptz | Account created |
| `deleted_at` | timestamptz | Soft delete |

---

#### `admin_restaurant_access`
**Purpose:** Admin-to-restaurant assignments

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `admin_user_id` | bigint | FK to admin_users |
| `restaurant_id` | bigint | FK to restaurants |
| `access_level` | varchar | full/limited/view |
| `granted_by` | bigint | Admin who granted |
| `granted_at` | timestamptz | When granted |
| `revoked_at` | timestamptz | When revoked |

---

#### `admin_permissions`
**Purpose:** Feature-level permissions

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `admin_user_id` | bigint | FK to admin_users |
| `permission` | varchar | Permission name |
| `granted` | boolean | Has permission |

---

#### `admin_sessions`
**Purpose:** Session tracking

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `admin_user_id` | bigint | FK to admin_users |
| `session_token` | varchar | Session token |
| `ip_address` | inet | Login IP |
| `user_agent` | text | Browser info |
| `created_at` | timestamptz | Session start |
| `expires_at` | timestamptz | Session expiry |

---

## 🔧 SQL Functions

**TODO:** Document after database query

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| `create-admin-user` | `/functions/v1/create-admin-user` | Create admin |
| `assign-admin-restaurants` | `/functions/v1/assign-admin-restaurants` | Assign access |

---

## 📇 Indexes

**TODO:** Document after database query

---

## 🔒 RLS Policies

| Policy | Operation | Description |
|--------|-----------|-------------|
| `admin_select_own` | SELECT | Admins see own profile |
| `admin_service_role` | ALL | Service role full access |

---

## ⚙️ Triggers

**TODO:** Document after database query

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None yet |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| - | - | - |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |

---

**Last Updated:** 2025-11-27

