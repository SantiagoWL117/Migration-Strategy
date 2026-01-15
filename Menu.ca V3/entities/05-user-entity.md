# 05 - User Entity

> **Customers** - End users and their data

---

## 📋 Purpose

The User Entity manages **customer accounts and data**:
- **User Profiles** - Account information and preferences
- **Addresses** - Saved delivery locations
- **Authentication** - Via Supabase Auth (auth_user_id link)
- **Migration History** - Links to legacy v1/v2 systems

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

### Core User Tables

#### `users`
**Purpose:** User profile extension of auth.users

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `email` | varchar | NO | - | User email (unique) |
| `has_email_verified` | boolean | YES | false | Email verification flag |
| `first_name` | varchar | YES | - | First name |
| `last_name` | varchar | YES | - | Last name |
| `display_name` | varchar | YES | - | Display name |
| `phone` | varchar | YES | - | Phone number |
| `language` | varchar | YES | 'EN' | Preferred language |
| `is_newsletter_subscribed` | boolean | YES | false | Newsletter opt-in |
| `is_vegan_newsletter_subscribed` | boolean | YES | false | Vegan newsletter opt-in |
| `login_count` | integer | YES | 0 | Total login count |
| `last_login_at` | timestamptz | YES | - | Last login timestamp |
| `last_login_ip` | inet | YES | - | Last login IP address |
| `credit_balance` | numeric | YES | 0.00 | Store credit balance |
| `credit_earned_at` | timestamptz | YES | - | When credit was earned |
| `facebook_id` | varchar | YES | - | Facebook OAuth ID |
| `origin_restaurant_id` | integer | YES | - | Restaurant where user signed up |
| `origin_source` | varchar | YES | - | Signup source |
| `auth_user_id` | uuid | YES | - | FK to auth.users |
| `auth_provider` | varchar | YES | 'email' | Auth method (email, google, etc.) |
| `email_verified_at` | timestamptz | YES | - | Email verification timestamp |
| `stripe_customer_id` | varchar | YES | - | Stripe customer ID (unique) |
| `v1_user_id` | integer | YES | - | Legacy v1 system ID |
| `v2_user_id` | integer | YES | - | Legacy v2 system ID |
| `created_at` | timestamptz | YES | now() | Registration time |
| `updated_at` | timestamptz | YES | now() | Last update time |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | User who deleted |

---

#### `user_addresses`
**Purpose:** Saved delivery addresses

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `user_id` | bigint | NO | - | FK to users |
| `street_address` | varchar | YES | - | Street address |
| `apartment` | varchar | YES | - | Apartment/unit number |
| `city_id` | integer | YES | - | FK to cities |
| `postal_code` | varchar | YES | - | Postal code |
| `phone` | varchar | YES | - | Contact phone for this address |
| `delivery_instructions` | text | YES | - | Driver notes |
| `is_default` | boolean | YES | false | Default address flag |
| `v2_address_id` | integer | YES | - | Legacy v2 address ID |
| `created_at` | timestamptz | YES | now() | Creation time |
| `updated_at` | timestamptz | YES | now() | Last update |

---

### Tables NOT Yet Implemented

| Table | Purpose | Status |
|-------|---------|--------|
| `user_favorites` | Favorite restaurants | Not created |
| `user_preferences` | Dietary restrictions, allergies | Not created |

---

## 🔧 SQL Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `get_user_profile` | - | TABLE | Retrieve authenticated user's profile |
| `get_user_addresses` | - | TABLE | Retrieve authenticated user's addresses |
| `get_admin_profile` | - | TABLE | Retrieve admin user profile |

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | None yet |

---

## 📇 Indexes

### Users Table

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `users_pkey` | (id) | UNIQUE | - | Primary key |
| `users_email_key` | (email) | UNIQUE | - | Email uniqueness |
| `idx_users_email` | (email) | BTREE | - | Email lookup |
| `idx_users_email_lower` | (lower(email)) | BTREE | - | Case-insensitive email lookup |
| `idx_users_auth_user_id` | (auth_user_id) | BTREE | - | Supabase auth lookup |
| `idx_users_auth_user_unique` | (auth_user_id) | UNIQUE | WHERE auth_user_id IS NOT NULL | Unique auth link |
| `users_stripe_customer_id_key` | (stripe_customer_id) | UNIQUE | - | Stripe uniqueness |
| `idx_users_stripe_customer` | (stripe_customer_id) | BTREE | - | Stripe lookup |
| `idx_users_last_login` | (last_login_at DESC) | BTREE | - | Recent activity |
| `idx_users_created_at` | (created_at DESC) | BTREE | - | Registration timeline |
| `idx_users_updated_at` | (updated_at DESC) | BTREE | - | Recent updates |
| `idx_users_deleted_at` | (deleted_at) | BTREE | WHERE deleted_at IS NULL | Active users filter |
| `idx_users_v1_id` | (v1_user_id) | BTREE | - | Legacy v1 lookup |
| `idx_users_v2_id` | (v2_user_id) | BTREE | - | Legacy v2 lookup |
| `idx_users_origin` | (origin_restaurant_id) | BTREE | - | Signup origin |
| `idx_users_display_name` | (display_name) | BTREE | WHERE display_name IS NOT NULL | Display name search |

### User Addresses Table

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `user_addresses_pkey` | (id) | UNIQUE | - | Primary key |
| `idx_user_addresses_user` | (user_id) | BTREE | - | User's addresses |
| `idx_user_addresses_city` | (city_id) | BTREE | - | City lookup |
| `idx_user_addresses_default` | (user_id, is_default) | BTREE | WHERE is_default = true | Default address |
| `idx_user_addresses_one_default` | (user_id, is_default) | UNIQUE | WHERE is_default = true | One default per user |

---

## 🔒 RLS Policies

### Users Table

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `users_select_own` | authenticated | SELECT | auth_user_id = auth.uid() |
| `users_update_own` | authenticated | UPDATE | auth_user_id = auth.uid() |
| `users_insert_own` | authenticated | INSERT | auth_user_id = auth.uid() |
| `users_service_role_all` | service_role | ALL | Full access for backend |

---

## ⚙️ Triggers

| Trigger | Table | Timing | Event | Function | Purpose |
|---------|-------|--------|-------|----------|---------|
| `audit_users_changes` | users | AFTER | INSERT, UPDATE, DELETE | `audit_trigger_func()` | Audit trail logging |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None yet |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| 2025-10 | Migration from v1/v2 systems | Complete |
| 2025-10 | Supabase Auth integration | Complete |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| 2026-01-13 | Deleted 21 test user accounts | Data cleanup |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 2 |
| Total Users | ~32,320 |
| User Addresses | 0 |
| Indexes | 21 |
| RLS Policies | 4 |
| Triggers | 1 |
| SQL Functions | 3 |

### User Breakdown

| Metric | Count | Percentage |
|--------|-------|------------|
| Total users | 32,320 | 100% |
| Email verified | 8,910 | 27.5% |
| With Supabase auth | 29,242 | 90% |
| Migrated from v1 | 23,406 | 72% |
| Migrated from v2 | 8,910 | 27.5% |
| Newsletter subscribers | 7,526 | 23% |
| Ever logged in | 23,406 | 72% |

---

**Last Updated:** 2026-01-13
