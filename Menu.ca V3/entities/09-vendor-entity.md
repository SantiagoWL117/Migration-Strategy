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

### Utility Functions

| Function | Purpose |
|----------|---------|
| `notify_vendor_change()` | Trigger function - sends pg_notify on vendor_restaurant changes |
| `update_last_commission_rate()` | Trigger function - caches last-used commission rate |

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
| `idx_vendors_email` | (email) | BTREE | - | Email search |
| `idx_vendors_legacy_id` | (legacy_v2_admin_user_id) | BTREE | - | Migration lookup |

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

## 🔒 RLS Policies

### Vendors Table

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `Vendors can view own profile` | public | SELECT | auth_user_id = auth.uid() |
| `Vendors can view their own record` | authenticated | SELECT | auth.uid() = auth_user_id |
| `Vendors can update own profile` | public | UPDATE | auth_user_id = auth.uid() |
| `vendors_admin_manage_all` | authenticated | ALL | User is active admin + not deleted |
| `vendors_service_role_all` | service_role | ALL | Full access for backend |

### Vendor Restaurants Table

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `Vendors can view own restaurant assignments` | public | SELECT | vendor_id belongs to user's vendor |
| `Vendors can view their restaurant assignments` | authenticated | SELECT | vendor_id belongs to user's vendor |
| `vendor_restaurants_admin_manage_all` | authenticated | ALL | User is active admin + not deleted |
| `vendor_restaurants_restaurant_admin_view` | authenticated | SELECT | User is admin for the restaurant |
| `vendor_restaurants_service_role_all` | service_role | ALL | Full access for backend |

### Vendor Commission Reports Table

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `Vendors can view own commission reports` | public | SELECT | vendor_id belongs to user's vendor |
| `Vendors can view their commission reports` | authenticated | SELECT | vendor_id belongs to user's vendor |

### Vendor Statement Numbers Table

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `Vendors can view own statement numbers` | public | SELECT | vendor_id belongs to user's vendor |
| `Vendors can view their statement numbers` | authenticated | SELECT | vendor_id belongs to user's vendor |

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

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| 2025-12 | `vendor_api_keys` table | Not needed - using Supabase auth |
| 2025-12 | `vendor_branding` table | Deferred - not MVP requirement |
| 2025-12 | `tenant_id` in vendor_restaurants | Redundant - restaurant_uuid is sufficient |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| 2025-11 | Commission calculation Edge Functions | Complete |
| 2025-11 | Statement number tracking | Complete |
| 2025-12 | Commission rate history tracking | Complete |
| 2025-12 | Realtime vendor change notifications | Complete |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| 2025-12 | Added `commission_rate_used` to reports | Historical rate tracking |
| 2025-12 | Added `last_commission_rate_used` to vendor_restaurants | Rate caching |
| 2025-12 | Removed tenant_id column | Schema simplification |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |
| SQL Functions | 8 |
| Edge Functions | 2 |
| Indexes | 19 |
| RLS Policies | 14 |
| Triggers | 6 |

---

## 🔗 Related Entities

- **Restaurant Management** - vendor_restaurants references restaurants.uuid
- **Users & Access** - vendors.auth_user_id references auth.users
- **Accounting & Reporting** - Commission reports feed into financial reporting

---

**Last Updated:** 2025-12-16

