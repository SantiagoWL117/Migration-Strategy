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

- [Authentication Flow](#authentication-flow)
- [Tables](#tables)
- [Constraints](#constraints)
- [Foreign Key References](#foreign-key-references)
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

#### `users` (15 columns)
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
| `origin_restaurant_id` | integer | - | YES | - | Restaurant where user signed up (all NULL) |
| `auth_user_id` | uuid | - | YES | - | FK to auth.users (CASCADE DELETE) |
| `stripe_customer_id` | varchar | 255 | YES | - | Stripe customer ID (unique) |
| `created_at` | timestamptz | - | YES | now() | Registration time |
| `updated_at` | timestamptz | - | YES | now() | Last update time |
| `deleted_at` | timestamptz | - | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | - | YES | - | FK to admin_users (who deleted) |

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
| `user_addresses` | `user_id` | Legacy addresses |
| `user_delivery_addresses` | `user_id` | New addresses with geolocation |
| `user_favorite_restaurants` | `user_id` | Favorite restaurants |
| `user_payment_methods` | `user_id` | Saved payment methods |

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
| 2026-01-27 | Column `language` | Moved to Supabase Auth user metadata |
| 2026-01-27 | Column `login_count` | Redundant with `last_login_at` |
| 2026-01-27 | Column `last_login_ip` | Privacy concern, rarely used |
| 2026-01-27 | Column `auth_provider` | All users use email (future: use Supabase Auth metadata) |
| 2026-01-27 | Column `email_verified_at` | Use `has_email_verified` boolean instead |
| 2026-01-27 | Column `v1_user_id` | Legacy migration complete |
| 2026-01-27 | Index `idx_users_email` | Redundant with `users_email_key` UNIQUE |
| 2026-01-27 | Index `idx_users_stripe_customer` | Redundant with `users_stripe_customer_id_key` UNIQUE |
| 2026-01-27 | Index `idx_users_origin` | All `origin_restaurant_id` values set to NULL |
| 2026-01-27 | Index `idx_users_v1_id` | Column dropped |

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
| ~~Users without auth~~ | ~~3,097~~ | ✅ Fixed | Soft-deleted 2026-01-27 (no orders, couldn't login) |
| No Stripe customer | 32,462 | ✅ Expected | Most users haven't paid |
| Zero addresses (old table) | 0 | 🟡 Medium | `user_addresses` is empty |
| Few addresses (new table) | 3 | 🟡 Medium | `user_delivery_addresses` has 3 records |
| No favorites | 0 | ✅ Expected | Feature not launched |
| No payment methods | 0 | ✅ Expected | Feature not launched |
| **deleted_at without deleted_by** | 2 | ✅ Low | Minor inconsistency |
| **Only 3 users have phone** | 3 | ✅ Info | Phone rarely collected |
| ~~NULL language~~ | ~~89~~ | ✅ Fixed | Column dropped 2026-01-27 |
| ~~origin_restaurant_id = 0~~ | ~~8,910~~ | ✅ Fixed | All set to NULL 2026-01-27 |

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
| 2026-01-26 | Documentation audit - added Constraints section | 5 constraints on users table |
| 2026-01-26 | Documentation audit - added Foreign Key References | 27 tables reference users |
| 2026-01-26 | Documentation audit - added column max lengths | varchar columns now show max_length |
| 2026-01-26 | Documentation audit - added new data quality issues | NULL language, origin_restaurant_id=0, etc. |
| 2026-01-27 | Dropped 6 columns from `users` | `language`, `login_count`, `last_login_ip`, `auth_provider`, `email_verified_at`, `v1_user_id` |
| 2026-01-27 | Set all `origin_restaurant_id` to NULL | 23,400 records updated |
| 2026-01-27 | Dropped 4 redundant indexes | `idx_users_email`, `idx_users_stripe_customer`, `idx_users_origin`, `idx_users_v1_id` |
| 2026-01-27 | Fixed `get_user_profile()` function | Removed `language` column reference |
| 2026-01-27 | Recreated `active_users` view | Removed dropped columns |
| 2026-01-27 | Linked 2 orphaned users to auth.users | Fixed users with matching emails |
| 2026-01-27 | Set all `has_email_verified` to false | 8,910 records updated |
| 2026-01-27 | Soft-deleted 3,097 users without auth | No orders, can't login - cleaned up |
| 2026-01-27 | Added Authentication Flow section | Documented login/password reset flows with code examples |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 5 |
| Total Users | 32,467 |
| Active Users | 29,368 |
| User Addresses (legacy) | 0 |
| User Delivery Addresses (new) | 3 |
| Favorite Restaurants | 0 |
| Payment Methods | 0 |
| Indexes | 28 |
| RLS Policies | 23 |
| Triggers | 1 |
| SQL Functions | 2 |
| Constraints | 5 |
| FK References (from other tables) | 27 |

### User Breakdown

| Metric | Count | Percentage |
|--------|-------|------------|
| Total users | 32,467 | 100% |
| Active (not deleted) | 29,368 | 90.5% |
| Soft-deleted | 3,099 | 9.5% |
| Email verified | 0 | 0% (reset) |
| **With Supabase auth** | **29,368** | **100%** ✅ |
| Has Stripe customer ID | 5 | 0.02% |
| Has first name | 29,366 | 99.99% |
| Has phone number | 3 | 0.01% |
| Has credit balance > 0 | 0 | 0% |

---

**Last Updated:** 2026-01-27
