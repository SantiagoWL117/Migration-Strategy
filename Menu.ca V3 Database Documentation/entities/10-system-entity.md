
# 10 - System Entity

> **Infrastructure** - Audit logs, authentication tokens, payments, translations, and cart sessions

---

## 📋 Purpose

The System Entity handles **cross-cutting infrastructure concerns**:
- **Audit Logging** - Partitioned change tracking for all audited tables
- **Authentication Tokens** - Autologin and password reset tokens
- **Payment Transactions** - Stripe payment processing records
- **Cart Sessions** - Shopping cart state management
- **Translation Lookup** - Bilingual term reference (EN/FR)

**Note:** `data_migrations`, `feature_flags`, `system_config`, and `translations` tables do not exist in the schema despite being previously documented.

---

## 📑 Index

- [📊 Tables](#-tables) — `audit_log` (partitioned), `autologin_tokens`, `password_reset_tokens`, `cart_sessions`, `payment_transactions`, `translation_lookup`
- [🔧 SQL Functions](#-sql-functions-6-total)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)

---

## 📊 Tables

### Audit Tables

#### `audit_log` (PARTITIONED — 115,456 rows)
**Purpose:** Change audit trail — partitioned by month on `created_at`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key (composite with created_at) |
| `table_name` | varchar | NO | Affected table |
| `record_id` | bigint | NO | Affected record ID |
| `action` | varchar | NO | INSERT/UPDATE/DELETE |
| `old_data` | jsonb | YES | Previous values |
| `new_data` | jsonb | YES | New values |
| `changed_fields` | text[] | YES | Array of changed column names |
| `changed_by_user_id` | bigint | YES | FK to users (customer changes) |
| `changed_by_admin_id` | bigint | YES | FK to admin_users (admin changes) |
| `ip_address` | inet | YES | Source IP |
| `user_agent` | text | YES | Browser user agent |
| `created_at` | timestamptz | NO | Change timestamp (partition key) |

**Active Partitions:** `audit_log_2025_12`, `audit_log_2026_01`, `audit_log_2026_02`, `audit_log_2026_03`

---

### Authentication Tables

#### `autologin_tokens` (0 rows)
**Purpose:** Remember-me / autologin tokens

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `user_id` | bigint | NO | FK to users |
| `token` | varchar | NO | Token value (UNIQUE) |
| `expires_at` | timestamptz | NO | Expiration time |
| `last_used_at` | timestamptz | YES | Last usage |
| `user_agent` | text | YES | Browser info |
| `ip_address` | inet | YES | Source IP |
| `created_at` | timestamptz | NO | Creation time |

---

#### `password_reset_tokens` (0 rows)
**Purpose:** Password reset flow tokens

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `user_id` | bigint | NO | FK to users |
| `token` | varchar | NO | Token value (UNIQUE) |
| `expires_at` | timestamptz | NO | Expiration time |
| `used_at` | timestamptz | YES | When token was used |
| `created_at` | timestamptz | YES | Creation time |

---

### Transaction Tables

#### `cart_sessions` (0 rows)
**Purpose:** Shopping cart state management

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `session_id` | uuid | NO | Session identifier (UNIQUE) |
| `user_id` | bigint | YES | FK to users (nullable for guests) |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `cart_data` | jsonb | NO | Cart contents |
| `expires_at` | timestamptz | NO | Expiration time |
| `created_at` | timestamptz | NO | Creation time |
| `updated_at` | timestamptz | NO | Last update |

---

#### `payment_transactions` (56 rows)
**Purpose:** Stripe payment processing records

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `order_id` | bigint | NO | FK to orders |
| `order_created_at` | timestamptz | NO | Order timestamp (for partition routing) |
| `user_id` | bigint | NO | FK to users |
| `restaurant_id` | bigint | NO | FK to restaurants |
| `stripe_payment_intent_id` | varchar | NO | Stripe PI ID (UNIQUE) |
| `stripe_charge_id` | varchar | YES | Stripe charge ID |
| `amount` | numeric | NO | Payment amount |
| `currency` | varchar | YES | Currency code |
| `status` | varchar | NO | Payment status |
| `payment_method` | varchar | YES | Payment method type |
| `failure_reason` | text | YES | Failure description |
| `refund_amount` | numeric | YES | Refund amount |
| `refunded_at` | timestamptz | YES | Refund timestamp |
| `created_at` | timestamptz | NO | Creation time |
| `updated_at` | timestamptz | NO | Last update |

---

### Reference Tables

#### `translation_lookup` (2,426 rows)
**Purpose:** Bilingual term reference (EN/FR pairs)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | integer | NO | Primary key |
| `term_en` | varchar | NO | English term |
| `term_fr` | varchar | NO | French translation |
| `category` | varchar | YES | Term category |

---

## 🔧 SQL Functions (6 total)

| Function | Purpose |
|----------|---------|
| `audit_trigger_func()` | Trigger function — logs INSERT/UPDATE/DELETE to `audit_log` |
| `set_updated_at()` | Trigger function — sets `updated_at = now()` on UPDATE |
| `trigger_set_updated_at()` | Alternate trigger function for `updated_at` |
| `cleanup_old_audit_logs()` | Removes old audit log entries |
| `audit_restaurant_status_change()` | Logs restaurant status changes |
| `get_deletion_audit_trail()` | Retrieves deletion history for a record |

---

## 📇 Indexes

### `audit_log` Parent (5 indexes, inherited by partitions)

| Index Name | Columns | Type |
|------------|---------|------|
| `audit_log_pkey` | `(id, created_at)` | PRIMARY KEY |
| `idx_audit_log_table_record` | `(table_name, record_id)` | BTREE |
| `idx_audit_log_created_at` | `(created_at DESC)` | BTREE |
| `idx_audit_log_action` | `(action)` | BTREE |
| `idx_audit_log_changed_by_admin` | `(changed_by_admin_id)` | BTREE (partial) |
| `idx_audit_log_changed_by_user` | `(changed_by_user_id)` | BTREE (partial) |

Each partition inherits these indexes automatically.

### `autologin_tokens` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `autologin_tokens_pkey` | `(id)` | PRIMARY KEY |
| `autologin_tokens_token_key` | `(token)` | UNIQUE |
| `idx_autologin_user` | `(user_id)` | BTREE |
| `idx_autologin_expires` | `(expires_at)` | BTREE |

### `password_reset_tokens` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `password_reset_tokens_pkey` | `(id)` | PRIMARY KEY |
| `password_reset_tokens_token_key` | `(token)` | UNIQUE |
| `idx_reset_tokens_user` | `(user_id)` | BTREE |
| `idx_reset_tokens_expires` | `(expires_at)` | BTREE |

### `cart_sessions` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `cart_sessions_pkey` | `(id)` | PRIMARY KEY |
| `cart_sessions_session_id_key` | `(session_id)` | UNIQUE |
| `idx_cart_sessions_user` | `(user_id)` | BTREE |
| `idx_cart_sessions_restaurant_id` | `(restaurant_id)` | BTREE |
| `idx_cart_sessions_expires` | `(expires_at)` | BTREE |

### `payment_transactions` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `payment_transactions_pkey` | `(id)` | PRIMARY KEY |
| `payment_transactions_stripe_payment_intent_id_key` | `(stripe_payment_intent_id)` | UNIQUE |
| `idx_payment_transactions_order` | `(order_id)` | BTREE |
| `idx_payment_transactions_user` | `(user_id)` | BTREE |

### `translation_lookup` (1 index)

| Index Name | Columns | Type |
|------------|---------|------|
| `translation_lookup_pkey` | `(id)` | PRIMARY KEY |

---

## 🔒 RLS Policies (9 total)

### `autologin_tokens` (1 policy)

| Policy | Roles | Command |
|--------|-------|---------|
| `autologin_tokens_service_role_all` | service_role | ALL |

### `password_reset_tokens` (1 policy)

| Policy | Roles | Command |
|--------|-------|---------|
| `password_reset_tokens_service_role_all` | service_role | ALL |

### `cart_sessions` (5 policies — created 2026-02-17)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `cart_sessions_service_role_all` | service_role | ALL | Full access |
| `cart_sessions_select_own` | authenticated | SELECT | Own cart via auth.uid() |
| `cart_sessions_insert_own` | authenticated | INSERT | Own cart via auth.uid() |
| `cart_sessions_update_own` | authenticated | UPDATE | Own cart via auth.uid() |
| `cart_sessions_delete_own` | authenticated | DELETE | Own cart via auth.uid() |

### `payment_transactions` (2 policies — created 2026-02-17)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `payment_transactions_service_role_all` | service_role | ALL | Full access |
| `payment_transactions_select_own` | authenticated | SELECT | Own transactions via auth.uid() |

**No RLS (by design):** `audit_log` (system data, no direct user access), `translation_lookup` (public reference data).

---

## ⚙️ Triggers

No triggers directly on system tables. `audit_trigger_func()` and `set_updated_at()` are trigger *functions* used by triggers on other entity tables.

---

## 🚨 Data Integrity Issues

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 | ~~8 duplicate indexes on audit_log partitions~~ | ✅ | Resolved | Dropped 8 indexes (2026-02-17) |
| 2 | ~~`idx_autologin_token` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 3 | ~~`idx_reset_tokens_token` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 4 | ~~`idx_cart_sessions_session_id` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 5 | ~~`idx_payment_transactions_stripe` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 6 | ~~RLS disabled on `cart_sessions` and `payment_transactions`~~ | ✅ | Resolved | Enabled RLS + created 7 policies (2026-02-17). `audit_log` and `translation_lookup` left without RLS by design. |
| 7 | `autologin_tokens`, `cart_sessions`, `password_reset_tokens` all have 0 rows | ℹ️ Info | Expected | Features not yet active |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 6 (+ 4 audit partitions) |
| Audit Log Rows | 115,456 |
| Payment Transactions | 56 |
| Translation Terms | 2,426 |
| SQL Functions | 6 |
| Indexes | 48 |
| RLS Policies | 9 |
| Triggers | 0 (functions used by other entities) |

---

**Last Updated:** 2026-02-17
