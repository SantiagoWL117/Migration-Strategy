# 05 - User Entity

> **Customers** - End users and their data

---

## 📋 Purpose

The User Entity manages **customer accounts and data**:
- **User Profiles** - Account information and preferences
- **Addresses** - Saved delivery locations
- **Authentication** - Via Supabase Auth (auth_user_id link)
- **Payments** - Stripe customer integration

---

## 🔐 Authentication Flow

### Login Flow

```
1. User enters email + password
        ↓
2. Supabase Auth validates against auth.users
        ↓
3. Returns JWT with user.id (auth_user_id)
        ↓
4. Frontend calls get_user_profile()
        ↓
5. RLS policy: WHERE auth_user_id = auth.uid()
        ↓
6. User gets their profile data ✅
```

### Password Reset Flow

```
1. User clicks "Forgot Password"
        ↓
2. Frontend: supabase.auth.resetPasswordForEmail(email)
        ↓
3. Supabase sends reset email (configured in Dashboard)
        ↓
4. User clicks link, enters new password
        ↓
5. Frontend: supabase.auth.updateUser({ password })
        ↓
6. Password updated in auth.users.encrypted_password ✅
```

### Frontend Code Examples

```javascript
// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

// Reset password (sends email)
await supabase.auth.resetPasswordForEmail('user@example.com');

// Update password (after reset link)
await supabase.auth.updateUser({ password: 'newPassword123' });

// Get user profile
const { data: profile } = await supabase.rpc('get_user_profile');
```

### Authentication Status (verified 2026-01-27)

| Metric | Count | Status |
|--------|-------|--------|
| Active users | 29,368 | ✅ |
| With auth_user_id | 29,368 (100%) | ✅ |
| With password set | 29,368 (100%) | ✅ |
| Can reset password | 29,368 (100%) | ✅ |

---

## 📑 Index

- [🔐 Authentication Flow](#-authentication-flow)
- [📊 Tables](#-tables) — `users`, `user_delivery_addresses`, `user_favorite_restaurants`, `user_payment_methods`
- [🔗 Constraints](#-constraints)
- [🔀 Foreign Key References](#-foreign-key-references)
- [🔧 SQL Functions](#-sql-functions-4-total)
- [⚡ Edge Functions](#-edge-functions)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [🗑️ Migration History](#️-migration-history)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)

---

## 📊 Tables

### Core User Tables

#### `users` (14 columns)
**Purpose:** User profile extension of auth.users

| Column | Type | Max Len | Nullable | Default | Description |
|--------|------|---------|----------|---------|-------------|
| `id` | bigint | - | NO | nextval | Primary key |
| `email` | varchar | 255 | NO | - | User email (unique) |
| `has_email_verified` | boolean | - | YES | false | Email verification flag |
| `first_name` | varchar | 100 | YES | - | First name |
| `last_name` | varchar | 100 | YES | - | Last name |
| `phone` | varchar | 20 | YES | - | Phone number |
| `last_login_at` | timestamptz | - | YES | - | Last login timestamp |
| `credit_balance` | numeric | - | YES | 0.00 | Store credit balance |
| `auth_user_id` | uuid | - | YES | - | FK to auth.users (CASCADE DELETE) |
| `stripe_customer_id` | varchar | 255 | YES | - | Stripe customer ID (unique) |
| `created_at` | timestamptz | - | YES | now() | Registration time |
| `updated_at` | timestamptz | - | YES | now() | Last update time |
| `deleted_at` | timestamptz | - | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | - | YES | - | FK to admin_users (who deleted) |

---

#### `user_delivery_addresses` (8 records)
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

## 🔗 Constraints

### Users Table (5 constraints)

| Constraint | Type | Definition |
|------------|------|------------|
| `users_pkey` | PRIMARY KEY | `(id)` |
| `users_email_key` | UNIQUE | `(email)` |
| `users_stripe_customer_id_key` | UNIQUE | `(stripe_customer_id)` |
| `users_auth_user_id_fkey` | FOREIGN KEY | `auth_user_id → auth.users(id) ON DELETE CASCADE` |
| `users_deleted_by_fkey` | FOREIGN KEY | `deleted_by → admin_users(id)` |

---

## 🔀 Foreign Key References

### Tables Referencing `users` (27 references)

These tables have foreign keys pointing to the `users` table. Important for understanding cascade effects.

| Table | Column(s) | Notes |
|-------|-----------|-------|
| `orders` | `user_id`, `cancelled_by` | Order ownership and cancellation tracking |
| `orders_2025_10` through `orders_2026_03` | `user_id`, `cancelled_by` | Partitioned order tables |
| `cart_sessions` | `user_id` | Shopping cart sessions |
| `autologin_tokens` | `user_id` | Remember-me tokens |
| `password_reset_tokens` | `user_id` | Password reset flow |
| `payment_transactions` | `user_id` | Payment history |
| `coupon_usage_log` | `user_id` | Coupon redemption tracking |
| `promotion_codes` | `generated_for_user_id`, `referrer_user_id` | Referral program |
| `promotion_redemptions` | `user_id` | Promotion usage |
| `restaurant_reviews` | `user_id` | User reviews |
| `user_delivery_addresses` | `user_id` | Delivery addresses with geolocation |
| `user_favorite_restaurants` | `user_id` | Favorite restaurants |
| `user_payment_methods` | `user_id` | Saved payment methods |

---

## 🔧 SQL Functions (4 total)

| Function | Purpose |
|----------|---------|
| `get_user_profile()` | Retrieve authenticated user's profile via `auth.uid()` |
| `get_user_addresses()` | Retrieve authenticated user's addresses via `auth.uid()` |
| `get_favorite_restaurants()` | Retrieve authenticated user's favorite restaurants |
| `toggle_favorite_restaurant()` | Add/remove a restaurant from favorites |

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | None yet |

---

## 📇 Indexes

### Users Table (10 indexes)

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `users_pkey` | (id) | UNIQUE | - | Primary key |
| `users_email_key` | (email) | UNIQUE | - | Email uniqueness |
| `idx_users_email_lower` | (lower(email)) | BTREE | - | Case-insensitive email lookup |
| `idx_users_auth_user_id` | (auth_user_id) | BTREE | - | Supabase auth lookup |
| `idx_users_auth_user_unique` | (auth_user_id) | UNIQUE | WHERE auth_user_id IS NOT NULL | Unique auth link |
| `users_stripe_customer_id_key` | (stripe_customer_id) | UNIQUE | - | Stripe uniqueness |
| `idx_users_last_login` | (last_login_at DESC) | BTREE | - | Recent activity |
| `idx_users_created_at` | (created_at DESC) | BTREE | - | Registration timeline |
| `idx_users_updated_at` | (updated_at DESC) | BTREE | - | Recent updates |
| `idx_users_deleted_at` | (deleted_at) | BTREE | WHERE deleted_at IS NULL | Active users filter |

### User Delivery Addresses Table

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

### User Delivery Addresses Table (5 policies)

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

## 🗑️ Migration History

**Columns dropped (13):** `credit_earned_at`, `facebook_id`, `origin_source`, `display_name`, `v2_user_id`, `is_newsletter_subscribed`, `is_vegan_newsletter_subscribed` (2026-01-19); `language`, `login_count`, `last_login_ip`, `auth_provider`, `email_verified_at`, `v1_user_id` (2026-01-27).

**Indexes dropped (6):** `idx_users_display_name`, `idx_users_v2_id` (auto-dropped with columns); `idx_users_email`, `idx_users_stripe_customer`, `idx_users_origin`, `idx_users_v1_id` (redundant).

**Data fixes:** Deleted 21 test accounts (2026-01-13). Soft-deleted 3,097 users without auth (2026-01-27). Linked 2 orphaned users to auth.users. Set all `origin_restaurant_id` to NULL. Set all `has_email_verified` to false. Fixed `get_user_profile()` and `active_users` view after column drops.

**RLS fixes:** Added 5 missing `user_addresses` policies (2026-01-19). Added 5 `user_payment_methods` policies (2026-01-23).

**Table dropped:** `user_addresses` (2026-02-17) — empty legacy table (0 rows), superseded by `user_delivery_addresses`. No functions, views, or FK references depended on it.

**Column dropped:** `origin_restaurant_id` from `users` (2026-02-17) — 100% NULL, no functions/views/indexes/constraints referenced it.

---

## 🚨 Data Integrity Issues

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 | ~~Duplicate address tables~~ | ✅ | Resolved | Dropped `user_addresses` (2026-02-17) — 0 rows, no dependencies |
| 2 | `user_favorite_restaurants` has 0 records | ✅ Expected | — | Feature not launched yet |
| 3 | `user_payment_methods` has 0 records | ✅ Expected | — | Feature not launched yet |
| 4 | 3,099 soft-deleted users without `deleted_by` | ✅ Low | Known | Bulk soft-delete on 2026-01-27 did not set `deleted_by` |
| 5 | ~~`origin_restaurant_id` column 100% NULL~~ | ✅ | Resolved | Column dropped (2026-02-17) — no dependencies |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |
| Total Users | 32,475 |
| Active Users | 29,376 |
| User Delivery Addresses | 8 |
| Favorite Restaurants | 0 |
| Payment Methods | 0 |
| Indexes | 23 |
| RLS Policies | 18 |
| Triggers | 1 |
| SQL Functions | 4 |
| Constraints | 5 |
| FK References (from other tables) | 27 |

---

**Last Updated:** 2026-02-17
