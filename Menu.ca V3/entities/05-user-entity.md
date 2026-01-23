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

#### `users` (21 columns)
**Purpose:** User profile extension of auth.users

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `email` | varchar | NO | - | User email (unique) |
| `has_email_verified` | boolean | YES | false | Email verification flag |
| `first_name` | varchar | YES | - | First name |
| `last_name` | varchar | YES | - | Last name |
| `phone` | varchar | YES | - | Phone number |
| `language` | varchar | YES | 'EN' | Preferred language |
| `login_count` | integer | YES | 0 | Total login count |
| `last_login_at` | timestamptz | YES | - | Last login timestamp |
| `last_login_ip` | inet | YES | - | Last login IP address |
| `credit_balance` | numeric | YES | 0.00 | Store credit balance |
| `origin_restaurant_id` | integer | YES | - | Restaurant where user signed up |
| `auth_user_id` | uuid | YES | - | FK to auth.users |
| `auth_provider` | varchar | YES | 'email' | Auth method (email, google, etc.) |
| `email_verified_at` | timestamptz | YES | - | Email verification timestamp |
| `stripe_customer_id` | varchar | YES | - | Stripe customer ID (unique) |
| `v1_user_id` | integer | YES | - | Legacy v1 system ID |
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

#### `user_delivery_addresses` (3 records)
**Purpose:** Delivery addresses with geolocation (newer table with lat/lng)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `user_id` | bigint | NO | FK to users |
| `address_label` | varchar | YES | Label (Home, Work, etc.) |
| `street_address` | varchar | NO | Street address |
| `unit` | varchar | YES | Apartment/unit |
| `city_id` | bigint | YES | FK to cities |
| `postal_code` | varchar | NO | Postal code |
| `latitude` | numeric | YES | GPS latitude |
| `longitude` | numeric | YES | GPS longitude |
| `delivery_instructions` | text | YES | Driver notes |
| `is_default` | boolean | NO | Default address flag |
| `created_at` | timestamptz | NO | Creation time |
| `updated_at` | timestamptz | NO | Last update |

**Note:** This appears to be a newer version of `user_addresses` with geolocation support.

---

#### `user_favorite_restaurants` (0 records)
**Purpose:** User's favorite restaurants

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `user_id` | bigint | NO | FK to users |
| `restaurant_id` | integer | NO | FK to restaurants |
| `created_at` | timestamptz | YES | When favorited |

---

#### `user_payment_methods` (0 records)
**Purpose:** Stored Stripe payment methods

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `user_id` | bigint | NO | FK to users |
| `stripe_payment_method_id` | varchar | NO | Stripe PM ID |
| `card_brand` | varchar | YES | Visa, Mastercard, etc. |
| `last_4_digits` | varchar | YES | Last 4 of card |
| `exp_month` | integer | YES | Expiration month |
| `exp_year` | integer | YES | Expiration year |
| `is_default` | boolean | NO | Default payment method |
| `created_at` | timestamptz | NO | Creation time |
| `updated_at` | timestamptz | NO | Last update |

---

### Tables NOT Yet Implemented

| Table | Purpose | Status |
|-------|---------|--------|
| `user_preferences` | Dietary restrictions, allergies | Not created |

---

## 🔧 SQL Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `get_user_profile` | - | TABLE | Retrieve authenticated user's profile via `auth.uid()` |
| `get_user_addresses` | - | TABLE | Retrieve authenticated user's addresses via `auth.uid()` |

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | None yet |

---

## 📇 Indexes

### Users Table (14 indexes)

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
| `idx_users_origin` | (origin_restaurant_id) | BTREE | - | Signup origin |

### User Addresses Table (legacy)

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `user_addresses_pkey` | (id) | UNIQUE | - | Primary key |
| `idx_user_addresses_user` | (user_id) | BTREE | - | User's addresses |
| `idx_user_addresses_city` | (city_id) | BTREE | - | City lookup |
| `idx_user_addresses_default` | (user_id, is_default) | BTREE | WHERE is_default = true | Default address |
| `idx_user_addresses_one_default` | (user_id, is_default) | UNIQUE | WHERE is_default = true | One default per user |

### User Delivery Addresses Table (new)

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| `user_delivery_addresses_pkey` | (id) | UNIQUE | Primary key |
| `user_delivery_addresses_user_id_address_label_key` | (user_id, address_label) | UNIQUE | One label per user |
| `idx_user_delivery_addresses_user` | (user_id) | BTREE | User's addresses |
| `idx_user_delivery_addresses_city_id` | (city_id) | BTREE | City lookup |
| `idx_user_delivery_addresses_default` | (user_id, is_default) | UNIQUE | One default per user |

### User Favorite Restaurants Table

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| `user_favorite_restaurants_pkey` | (id) | UNIQUE | Primary key |
| `user_favorite_restaurants_user_id_restaurant_id_key` | (user_id, restaurant_id) | UNIQUE | One favorite per user/restaurant |
| `idx_favorites_user` | (user_id) | BTREE | User's favorites |
| `idx_favorites_restaurant` | (restaurant_id) | BTREE | Restaurant's fans |

### User Payment Methods Table

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| `user_payment_methods_pkey` | (id) | UNIQUE | Primary key |
| `user_payment_methods_stripe_payment_method_id_key` | (stripe_payment_method_id) | UNIQUE | Stripe PM uniqueness |
| `idx_payment_methods_user` | (user_id) | BTREE | User's payment methods |
| `idx_payment_methods_default` | (user_id, is_default) | UNIQUE | One default per user |

---

## 🔒 RLS Policies

### Users Table (4 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `users_select_own` | authenticated | SELECT | `auth_user_id = auth.uid()` |
| `users_update_own` | authenticated | UPDATE | `auth_user_id = auth.uid()` |
| `users_insert_own` | authenticated | INSERT | (no qual - checked via WITH CHECK) |
| `users_service_role_all` | service_role | ALL | Full access for backend |

### User Addresses Table - legacy (5 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `user_addresses_select_own` | authenticated | SELECT | `user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())` |
| `user_addresses_update_own` | authenticated | UPDATE | `user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())` |
| `user_addresses_insert_own` | authenticated | INSERT | (no qual - checked via WITH CHECK) |
| `user_addresses_delete_own` | authenticated | DELETE | `user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())` |
| `user_addresses_service_role_all` | service_role | ALL | Full access for backend |

### User Delivery Addresses Table - new (5 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `addresses_select_own` | authenticated | SELECT | User's own addresses via auth.uid() |
| `addresses_update_own` | authenticated | UPDATE | User's own addresses via auth.uid() |
| `addresses_insert_own` | authenticated | INSERT | (no qual - checked via WITH CHECK) |
| `addresses_delete_own` | authenticated | DELETE | User's own addresses via auth.uid() |
| `addresses_service_role_all` | service_role | ALL | Full access for backend |

### User Favorite Restaurants Table (4 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `user_favorites_select_own` | authenticated | SELECT | User's own favorites via auth.uid() |
| `user_favorites_insert_own` | authenticated | INSERT | (no qual - checked via WITH CHECK) |
| `user_favorites_delete_own` | authenticated | DELETE | User's own favorites via auth.uid() |
| `user_favorites_service_role_all` | service_role | ALL | Full access for backend |

### User Payment Methods Table (5 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `payment_methods_select_own` | authenticated | SELECT | User's own payment methods via auth.uid() |
| `payment_methods_insert_own` | authenticated | INSERT | (no qual - checked via WITH CHECK) |
| `payment_methods_update_own` | authenticated | UPDATE | User's own payment methods via auth.uid() |
| `payment_methods_delete_own` | authenticated | DELETE | User's own payment methods via auth.uid() |
| `payment_methods_service_role_all` | service_role | ALL | Full access for backend |

---

## ⚙️ Triggers

| Trigger | Table | Timing | Event | Function | Purpose |
|---------|-------|--------|-------|----------|---------|
| `audit_users_changes` | users | AFTER | INSERT, UPDATE, DELETE | `audit_trigger_func()` | Audit trail logging |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| 2026-01-19 | Column `credit_earned_at` | Never used (100% NULL) |
| 2026-01-19 | Column `facebook_id` | Facebook login not implemented (100% NULL) |
| 2026-01-19 | Column `origin_source` | Never populated (100% NULL) |
| 2026-01-19 | Column `display_name` | Never used, first/last name sufficient (100% NULL) |
| 2026-01-19 | Column `v2_user_id` | Legacy migration complete, no longer needed |
| 2026-01-19 | Column `is_newsletter_subscribed` | Feature not used |
| 2026-01-19 | Column `is_vegan_newsletter_subscribed` | Feature not used |
| 2026-01-19 | Index `idx_users_display_name` | Column dropped |
| 2026-01-19 | Index `idx_users_v2_id` | Column dropped |

---

## ⚠️ Known Issues

### Documentation Issues Found (2026-01-19)

| Issue | Description | Resolution |
|-------|-------------|------------|
| Wrong function listed | `get_admin_profile` was listed under User Entity | Removed - belongs to Admin Entity |
| Missing RLS policies | Only 4 of 9 policies were documented | Added 5 missing `user_addresses` policies |
| Outdated statistics | User counts were from 2026-01-13 | Updated with current counts |
| Wrong function count | Listed 3 functions, only 2 exist | Corrected to 2 |
| Wrong RLS count | Listed 4 policies, actually 9 | Corrected to 9 |

### Data Quality Issues

| Issue | Count | Severity | Notes |
|-------|-------|----------|-------|
| Deleted users | 2 | ✅ Low | Soft-deleted accounts |
| Users without auth | 3,099 | 🟡 Medium | 9.5% have no Supabase auth link |
| Users never logged in | 9,061 | 🟡 Medium | 27.9% never logged in |
| No email verification | 23,557 | 🟡 Medium | 72.6% unverified emails |
| No Stripe customer | 32,462 | ✅ Expected | Most users haven't paid |
| Zero addresses (old table) | 0 | 🟡 Medium | `user_addresses` is empty |
| Few addresses (new table) | 3 | 🟡 Medium | `user_delivery_addresses` has 3 records |
| No favorites | 0 | ✅ Expected | Feature not launched |
| No payment methods | 0 | ✅ Expected | Feature not launched |

### Schema Issues

| Issue | Description | Recommendation |
|-------|-------------|----------------|
| Duplicate address tables | Both `user_addresses` and `user_delivery_addresses` exist | Consider consolidating - newer table has lat/lng |
| ~~Missing 3 tables in docs~~ | ~~`user_delivery_addresses`, `user_favorite_restaurants`, `user_payment_methods` not documented~~ | ✅ Fixed 2026-01-19 |
| ~~No RLS on payment_methods~~ | ~~`user_payment_methods` has zero RLS policies~~ | ✅ Fixed 2026-01-23 |

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
| 2026-01-19 | Documentation audit - removed wrong function reference | `get_admin_profile` belongs to Admin Entity |
| 2026-01-19 | Documentation audit - added missing RLS policies | Added 5 `user_addresses` policies |
| 2026-01-19 | Documentation audit - updated statistics | Corrected counts and percentages |
| 2026-01-19 | Documentation audit - added 3 missing tables | `user_delivery_addresses`, `user_favorite_restaurants`, `user_payment_methods` |
| 2026-01-19 | Documentation audit - added 13 missing indexes | Indexes on new tables |
| 2026-01-19 | Documentation audit - added 9 missing RLS policies | Policies on new tables (except payment_methods) |
| 2026-01-19 | ~~**Security issue found**~~ | ~~`user_payment_methods` has no RLS policies~~ → Fixed 2026-01-23 |
| 2026-01-19 | Dropped 7 unused columns from `users` | `credit_earned_at`, `facebook_id`, `origin_source`, `display_name`, `v2_user_id`, `is_newsletter_subscribed`, `is_vegan_newsletter_subscribed` |
| 2026-01-19 | Recreated `active_users` view | Removed dropped columns from view |
| 2026-01-19 | Auto-dropped 2 indexes | `idx_users_display_name`, `idx_users_v2_id` |
| 2026-01-23 | Fixed `get_user_profile()` function | Removed reference to dropped `newsletter_subscribed` column |
| 2026-01-23 | Added RLS policies to `user_payment_methods` | 5 policies: SELECT, INSERT, UPDATE, DELETE for authenticated + ALL for service_role |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 5 |
| Total Users | 32,467 |
| Active Users | 32,465 |
| User Addresses (legacy) | 0 |
| User Delivery Addresses (new) | 3 |
| Favorite Restaurants | 0 |
| Payment Methods | 0 |
| Indexes | 32 |
| RLS Policies | 23 |
| Triggers | 1 |
| SQL Functions | 2 |

### User Breakdown

| Metric | Count | Percentage |
|--------|-------|------------|
| Total users | 32,467 | 100% |
| Active (not deleted) | 32,465 | 99.99% |
| Email verified | 8,910 | 27.4% |
| With Supabase auth | 29,368 | 90.5% |
| Migrated from v1 | 23,406 | 72.1% |
| Ever logged in | 23,406 | 72.1% |
| Has Stripe customer ID | 5 | 0.02% |

---

**Last Updated:** 2026-01-23
