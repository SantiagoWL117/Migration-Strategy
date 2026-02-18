# 09 - Vendor Entity

> **B2B/Multi-tenant** - Vendors, franchises, and revenue-sharing agreements

---

## 📋 Purpose

The Vendor Entity manages **B2B platform relationships**:
- **Vendor Management** - Partners who manage multiple restaurants
- **Restaurant Assignments** - Vendor-restaurant relationships
- **Commission Tracking** - Revenue-sharing calculations and reports
- **Statement Generation** - Automated billing statements

---

## 📑 Index

- [📊 Tables](#-tables) — `vendors`, `vendor_restaurants`, `vendor_commission_reports`, `vendor_statement_numbers`, `vendor_configs`
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

### `vendors`
**Purpose:** Vendor/partner accounts managing multiple restaurants

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `legacy_v2_admin_user_id` | integer | YES | - | Migration reference (unique) |
| `business_name` | varchar(255) | NO | - | Company/business name |
| `contact_first_name` | varchar(100) | NO | - | Primary contact first name |
| `contact_last_name` | varchar(100) | NO | - | Primary contact last name |
| `email` | varchar(255) | NO | - | Contact email (unique) |
| `auth_user_id` | uuid | YES | - | FK to auth.users for login |
| `phone` | varchar(50) | YES | - | Contact phone number |
| `billing_address` | text | YES | - | Billing address |
| `billing_contact_info` | jsonb | YES | - | Additional billing contacts |
| `is_active` | boolean | NO | true | Active status |
| `disabled_at` | timestamptz | YES | - | When disabled |
| `disabled_by` | uuid | YES | - | FK to auth.users |
| `preferred_language` | varchar(10) | YES | 'en' | Language preference |
| `receives_statements` | boolean | YES | true | Receives commission statements |
| `settings` | jsonb | YES | '{}' | Vendor-specific settings |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | uuid | YES | - | FK to auth.users |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |
| `updated_by` | uuid | YES | - | FK to auth.users |
| `last_activity_at` | timestamptz | YES | - | Last login/activity |
| `metadata` | jsonb | YES | '{}' | Extensible metadata |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | uuid | YES | - | FK to auth.users |

**Constraints:**
- `email` must be unique
- `email` must be valid email format
- `business_name` minimum 2 characters
- `legacy_v2_admin_user_id` unique (for migration)

---

### `vendor_restaurants`
**Purpose:** Vendor-restaurant assignment relationships

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `legacy_v2_id` | integer | YES | - | Migration reference (unique) |
| `vendor_id` | uuid | NO | - | FK to vendors |
| `restaurant_uuid` | uuid | NO | - | FK to restaurants.uuid |
| `commission_template` | varchar(50) | NO | - | Template name for calculations |
| `is_active` | boolean | NO | true | Assignment active |
| `assignment_start_date` | date | NO | CURRENT_DATE | When assignment began |
| `assignment_end_date` | date | YES | - | When assignment ended |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | uuid | YES | - | FK to auth.users |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |
| `updated_by` | uuid | YES | - | FK to auth.users |
| `metadata` | jsonb | YES | '{}' | Extensible metadata |
| `last_commission_rate_used` | numeric | YES | - | Last rate used in calculation |
| `last_commission_type_used` | commission_rate_type | YES | 'percentage' | Rate type (percentage/fixed) |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | uuid | YES | - | FK to auth.users |

**Commission Templates:**
- `percent_commission` - Standard percentage-based commission
- `mazen_milanos` - Custom formula for specific vendor

**Note:** Commission rates are NOT stored here - they are provided by the client at calculation time via the Edge Function. Only the last-used rate is cached for reference.

---

### `vendor_commission_reports`
**Purpose:** Commission calculation reports generated via Edge Function

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `legacy_v2_report_id` | integer | YES | - | Migration reference (unique) |
| `vendor_id` | uuid | NO | - | FK to vendors |
| `restaurant_uuid` | uuid | NO | - | FK to restaurants.uuid |
| `statement_number` | integer | NO | - | Sequential statement # |
| `report_period_start` | date | NO | - | Period start date |
| `report_period_end` | date | NO | - | Period end date |
| `calculation_template` | varchar(50) | NO | - | Template used |
| `calculation_input` | jsonb | NO | - | Input parameters |
| `calculation_result` | jsonb | NO | - | Full calculation breakdown |
| `total_order_amount` | numeric(10,2) | NO | - | Sum of orders in period |
| `vendor_commission_amount` | numeric(10,2) | NO | - | Vendor's commission |
| `platform_fee_amount` | numeric(10,2) | NO | - | Platform fee |
| `menu_ottawa_amount` | numeric(10,2) | YES | - | Menu Ottawa's share |
| `commission_rate_used` | numeric | YES | - | Historical rate used |
| `commission_type_used` | commission_rate_type | YES | 'percentage' | Historical rate type |
| `report_generated_at` | timestamptz | NO | now() | Generation timestamp |
| `report_generated_by` | uuid | YES | - | FK to auth.users |
| `pdf_file_url` | text | YES | - | Generated PDF URL |
| `report_status` | varchar(20) | YES | 'draft' | Report lifecycle status |
| `sent_at` | timestamptz | YES | - | When sent to vendor |
| `paid_at` | timestamptz | YES | - | When payment received |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |
| `metadata` | jsonb | YES | '{}' | Extensible metadata |

**Report Status Values:**
- `draft` - Generated but not finalized
- `finalized` - Ready for sending
- `sent` - Sent to vendor
- `paid` - Payment received
- `cancelled` - Report cancelled

---

### `vendor_statement_numbers`
**Purpose:** Tracks incremental statement numbers per vendor

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `vendor_id` | uuid | NO | - | FK to vendors (PK) |
| `current_statement_number` | integer | NO | 0 | Next statement number |
| `last_statement_generated_at` | timestamptz | YES | - | Last generation time |
| `pdf_file_prefix` | varchar(125) | YES | 'vendor_statement_' | PDF filename prefix |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | NO | now() | Last update timestamp |

---

### `vendor_configs` (4 records)
**Purpose:** Vendor configuration — HST numbers, tax rates, payment terms

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | integer | NO | Primary key |
| `vendor_name` | varchar | NO | Vendor display name |
| `vendor_code` | varchar | NO | Short code (UNIQUE) |
| `company_name` | varchar | YES | Legal company name |
| `hst_number` | varchar | YES | HST registration number |
| `tax_rate` | numeric | YES | Applicable tax rate |
| `contact_email` | varchar | YES | Contact email |
| `payment_terms` | varchar | YES | Payment terms |
| `notes` | text | YES | Notes |
| `created_at` | timestamptz | YES | Creation time |

---

---

## 🔧 SQL Functions

### Vendor Management

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `create_vendor` | p_business_name, p_contact_first_name, p_contact_last_name, p_email, p_phone | uuid | Creates new vendor (admin only) |
| `get_all_vendors` | - | TABLE(vendor_id, vendor_name, email, phone, is_active, location_count) | Lists all vendors with restaurant counts |
| `get_restaurant_vendor` | p_restaurant_uuid | TABLE(vendor_id, vendor_name, email, phone, commission_template, is_active) | Gets vendor for a restaurant |
| `get_vendor_locations` | p_vendor_id | TABLE(restaurant_id, restaurant_uuid, restaurant_name, restaurant_slug, is_active, commission_template, assignment_start_date) | Lists vendor's assigned restaurants |

### Restaurant Assignment

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `add_restaurant_to_vendor` | p_vendor_id, p_restaurant_uuid, p_commission_template | uuid | Assigns restaurant to vendor |

### Commission Calculation

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `prepare_commission_calculation` | p_template_name, p_total, p_restaurant_commission, p_commission_type, p_menuottawa_share, p_vendor_id, p_restaurant_uuid | jsonb | Prepares input for Edge Function |

### Statement & Platform Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `get_next_statement_number` | p_vendor_id | integer | Get and increment statement number for vendor |
| `calculate_platform_commission` | (varies) | jsonb | Calculate platform's share of commission |

### Trigger Functions

| Function | Purpose |
|----------|---------|
| `notify_vendor_change()` | Sends pg_notify on vendor_restaurant changes |
| `update_last_commission_rate()` | Caches last-used commission rate on vendor_restaurants |

---

## ⚡ Edge Functions

| Function | Endpoint | JWT | Purpose |
|----------|----------|-----|---------|
| `calculate-vendor-commission` | `/functions/v1/calculate-vendor-commission` | Yes | Calculates commission for a period |
| `get-commission-preview` | `/functions/v1/get-commission-preview` | Yes | Preview calculation without saving |

### calculate-vendor-commission

**Request:**
```json
{
  "vendor_id": "uuid",
  "restaurant_uuid": "uuid",
  "period_start": "2025-01-01",
  "period_end": "2025-01-31",
  "commission_rate": 12.5,
  "commission_type": "percentage"
}
```

**Response:**
```json
{
  "success": true,
  "report_id": "uuid",
  "statement_number": 42,
  "total_order_amount": 15000.00,
  "vendor_commission_amount": 1875.00,
  "platform_fee_amount": 750.00,
  "menu_ottawa_amount": 375.00
}
```

---

## 📇 Indexes

### Vendors Table

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `vendors_pkey` | (id) | UNIQUE | - | Primary key |
| `vendors_email_key` | (email) | UNIQUE | - | Email uniqueness |
| `vendors_legacy_v2_admin_user_id_key` | (legacy_v2_admin_user_id) | UNIQUE | - | Migration uniqueness |
| `idx_vendors_active` | (is_active) | BTREE | - | Active vendor filtering |
| `idx_vendors_auth_user` | (auth_user_id) | BTREE | - | Auth lookup |
| `idx_vendors_created_at` | (created_at) | BTREE | - | Timeline queries |
| `idx_vendors_deleted` | (deleted_at) | BTREE | WHERE deleted_at IS NULL | Active records only |

### Vendor Restaurants Table

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `vendor_restaurants_pkey` | (id) | UNIQUE | - | Primary key |
| `vendor_restaurants_legacy_v2_id_key` | (legacy_v2_id) | UNIQUE | - | Migration uniqueness |
| `uq_vendor_restaurant_active` | (vendor_id, restaurant_uuid, is_active) | UNIQUE | - | Prevent duplicate active assignments |
| `idx_vendor_restaurants_vendor` | (vendor_id) | BTREE | - | Vendor's restaurants |
| `idx_vendor_restaurants_restaurant` | (restaurant_uuid) | BTREE | - | Restaurant's vendor |
| `idx_vendor_restaurants_active` | (is_active) | BTREE | - | Active assignments |
| `idx_vendor_restaurants_deleted` | (deleted_at) | BTREE | WHERE deleted_at IS NULL | Non-deleted only |
| `idx_vendor_restaurants_template` | (commission_template) | BTREE | - | Template filtering |

### Vendor Commission Reports Table

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| `vendor_commission_reports_pkey` | (id) | UNIQUE | Primary key |
| `vendor_commission_reports_legacy_v2_report_id_key` | (legacy_v2_report_id) | UNIQUE | Migration uniqueness |
| `idx_commission_reports_vendor` | (vendor_id) | BTREE | Vendor's reports |
| `idx_commission_reports_restaurant` | (restaurant_uuid) | BTREE | Restaurant's reports |
| `idx_commission_reports_period` | (report_period_start, report_period_end) | BTREE | Period range queries |
| `idx_commission_reports_status` | (report_status) | BTREE | Status filtering |

---

## 🔒 RLS Policies (11 total — created 2026-02-17)

### `vendors` (3 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `vendors_service_role_all` | service_role | ALL | Full access |
| `vendors_select_own` | authenticated | SELECT | `auth_user_id = auth.uid()` |
| `vendors_update_own` | authenticated | UPDATE | `auth_user_id = auth.uid()` |

### `vendor_restaurants` (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `vendor_restaurants_service_role_all` | service_role | ALL | Full access |
| `vendor_restaurants_select_own` | authenticated | SELECT | `vendor_id` belongs to authenticated vendor |

### `vendor_commission_reports` (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `vendor_commission_reports_service_role_all` | service_role | ALL | Full access |
| `vendor_commission_reports_select_own` | authenticated | SELECT | `vendor_id` belongs to authenticated vendor |

### `vendor_statement_numbers` (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `vendor_statement_numbers_service_role_all` | service_role | ALL | Full access |
| `vendor_statement_numbers_select_own` | authenticated | SELECT | `vendor_id` belongs to authenticated vendor |

### `vendor_configs` (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `vendor_configs_service_role_all` | service_role | ALL | Full access |
| `vendor_configs_select_authenticated` | authenticated | SELECT | All authenticated users can read configs |

---

## ⚙️ Triggers

### Vendors Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `update_vendors_updated_at` | BEFORE | UPDATE | `update_updated_at_column()` | Auto-update updated_at |

### Vendor Restaurants Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `update_vendor_restaurants_updated_at` | BEFORE | UPDATE | `update_updated_at_column()` | Auto-update updated_at |
| `vendor_restaurant_changed` | AFTER | INSERT, UPDATE, DELETE | `notify_vendor_change()` | Realtime notifications |

### Vendor Commission Reports Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `update_commission_reports_updated_at` | BEFORE | UPDATE | `update_updated_at_column()` | Auto-update updated_at |
| `trg_update_last_commission_rate` | AFTER | INSERT, UPDATE | `update_last_commission_rate()` | Cache rate to vendor_restaurants |

### Vendor Statement Numbers Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `update_statement_numbers_updated_at` | BEFORE | UPDATE | `update_updated_at_column()` | Auto-update updated_at |

---

## 🗑️ Migration History

**Tables dropped:** `vendor_api_keys` (not needed, using Supabase auth), `vendor_branding` (deferred). Column `tenant_id` removed from `vendor_restaurants` (redundant with `restaurant_uuid`).

**Additions:** `commission_rate_used` on reports, `last_commission_rate_used` on vendor_restaurants (rate caching), commission calculation Edge Functions, statement number tracking, realtime vendor change notifications.

**2026-02-17:** Dropped `vendor_invoices` and `vendor_restaurant_assignments` (both empty, not active). Dropped 2 redundant indexes (`idx_vendors_email`, `idx_vendors_legacy_id`). Enabled RLS on all 5 vendor tables and created 11 policies.

---

## 🚨 Data Integrity Issues

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 | ~~RLS disabled on all vendor tables~~ | ✅ | Resolved | Enabled RLS + created 11 policies across 5 tables (2026-02-17) |
| 2 | ~~`idx_vendors_email` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 3 | ~~`idx_vendors_legacy_id` redundant~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 4 | ~~`vendor_invoices` empty~~ | ✅ | Resolved | Table dropped (2026-02-17) |
| 5 | ~~`vendor_restaurant_assignments` empty~~ | ✅ | Resolved | Table dropped (2026-02-17) |
| 6 | Dual vendor config systems: `vendors` (UUID-based, 2 rows) and `vendor_configs` (integer-based, 4 rows) | 🟡 Medium | Open | See note below |

**Issue 6 — Dual vendor-restaurant systems:**

There are two parallel systems for managing vendors:

| Aspect | `vendors` + `vendor_restaurants` | `vendor_configs` |
|--------|----------------------------------|-------------------|
| **ID type** | UUID | Integer |
| **Restaurant link** | `restaurant_uuid` (UUID) | N/A (was via dropped `vendor_restaurant_assignments`) |
| **Auth** | `auth_user_id` → auth.users | None |
| **Commission** | Template-based via Edge Function | `commission_rate` was on `vendor_restaurant_assignments` |
| **Data** | 2 vendors, 22 assignments, 204 reports | 4 configs, 0 invoices (table dropped) |
| **Features** | Full (statements, commission calc, realtime) | Basic (HST, tax rate, payment terms) |

The UUID-based system (`vendors` + `vendor_restaurants`) is the active, feature-complete system. `vendor_configs` contains 4 records with billing metadata (HST numbers, tax rates) that could be merged into the `vendors` table's `settings` JSONB or `billing_contact_info` JSONB. Consider consolidating in the future.

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 5 |
| Vendors | 2 |
| Vendor Restaurants | 22 |
| Commission Reports | 204 |
| Statement Numbers | 2 |
| Vendor Configs | 4 |
| SQL Functions | 10 |
| Edge Functions | 2 |
| Indexes | 24 |
| RLS Policies | 11 |
| Triggers | 6 |

---

**Last Updated:** 2026-02-17

