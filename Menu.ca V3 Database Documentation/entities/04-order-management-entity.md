# 04 - Order Management Entity

> **Transactions** - Orders, payments, and order lifecycle

---

## 📋 Purpose

The Order Management Entity handles **all transactional data**:
- **Order Processing** - From cart to completion
- **Payment Handling** - Transactions and refunds via Stripe
- **Order Items** - Line items with customizations and modifiers
- **Order Status** - Lifecycle tracking with full audit trail
- **Cart Management** - Session-based shopping carts
- **Commission Tracking** - Platform commission per order

---

## 📑 Index

- [📊 Tables](#-tables)
  - [orders (partitioned)](#orders-partitioned) — core order records
  - [order_items (partitioned)](#order_items-partitioned) — line items
  - [order_status_history](#order_status_history) — audit trail
  - [order_refunds](#order_refunds) — refund records
  - [payment_transactions](#payment_transactions), [restaurant_payment_options](#restaurant_payment_options), [user_payment_methods](#user_payment_methods)
  - [cart_sessions](#cart_sessions)
  - [restaurant_commission_configs](#restaurant_commission_configs), [platform_commission_reports](#platform_commission_reports)
  - [commission_weekly_snapshots](#commission_weekly_snapshots), [vendor_commission_reports](#vendor_commission_reports)
- [🔧 SQL Functions](#-sql-functions-31-total)
- [⚡ Edge Functions](#-edge-functions)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [💰 Commission Flow](#-commission-flow)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [🗑️ Migration History](#️-migration-history)
- [📈 Statistics](#-statistics)

---

## 📊 Tables

### Core Order Tables

#### `orders` (PARTITIONED)
**Purpose:** Primary order records - partitioned by month for scalability

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `user_id` | bigint | YES | - | FK to users |
| `order_number` | varchar(50) | NO | - | Human-readable order # |
| `order_type` | varchar(20) | NO | - | delivery/takeout/dine_in |
| `order_status` | varchar(20) | NO | - | Current lifecycle status |
| `service_type` | varchar(10) | NO | 'asap' | 'asap' or 'scheduled' |
| `subtotal` | numeric(10,2) | NO | - | Items total before tax/fees |
| `tax_amount` | numeric(10,2) | NO | 0 | Tax amount |
| `tax_breakdown` | jsonb | YES | - | Detailed tax breakdown (GST/PST/HST) |
| `tax_province_id` | smallint | YES | - | FK to provinces for tax rates |
| `delivery_fee` | numeric(10,2) | NO | 0 | Delivery charge |
| `tip_amount` | numeric(10,2) | NO | 0 | Tip amount |
| `discount_amount` | numeric(10,2) | NO | 0 | Coupon/promo discount |
| `total_amount` | numeric(10,2) | NO | - | Grand total |
| `customer_name` | varchar(255) | YES | - | Customer display name |
| `customer_phone` | varchar(50) | YES | - | Contact phone |
| `customer_email` | varchar(255) | YES | - | Contact email |
| `delivery_address` | text | YES | - | Street address (e.g., "123 Main St") |
| `unit_number` | varchar(20) | YES | - | Apartment/suite number |
| `postal_code` | varchar(7) | NO | '' | Canadian postal code |
| `delivery_city_id` | integer | YES | - | FK to cities |
| `delivery_instructions` | text | YES | - | Driver instructions |
| `scheduled_delivery_time` | timestamptz | YES | - | Requested delivery time (if scheduled) |
| `estimated_ready_time` | timestamptz | YES | - | Restaurant prep estimate |
| `estimated_delivery_time` | timestamptz | YES | - | Delivery estimate |
| `actual_delivery_time` | timestamptz | YES | - | Actual delivery time |
| `confirmed_at` | timestamptz | YES | - | When restaurant confirmed |
| `completed_at` | timestamptz | YES | - | When order completed |
| `cancelled_at` | timestamptz | YES | - | When order cancelled |
| `cancellation_reason` | text | YES | - | Cancellation details |
| `cancelled_by` | bigint | YES | - | User who cancelled |
| `coupon_code` | varchar(50) | YES | - | Applied coupon code |
| `promotional_deal_id` | bigint | YES | - | FK to promotional_deals |
| `special_instructions` | text | YES | - | Order-level notes |
| `items` | jsonb | YES | - | Denormalized items snapshot (includes modifiers) |
| `payment_method` | payment_method_type | YES | - | Payment type enum |
| `payment_status` | varchar(50) | YES | 'pending' | Payment state |
| `stripe_payment_intent_id` | varchar(255) | YES | - | Stripe PI reference |
| `acknowledged_by_device_id` | integer | YES | - | POS device that accepted |
| `acknowledged_at` | timestamptz | YES | - | When acknowledged by POS |
| `is_guest_order` | boolean | YES | false | Whether this is a guest order |
| `guest_email` | text | YES | - | Guest email (if guest order) |
| `guest_name` | text | YES | - | Guest name (if guest order) |
| `guest_phone` | text | YES | - | Guest phone (if guest order) |
| `is_test_order` | boolean | YES | false | Flag for test orders |
| `created_at` | timestamptz | NO | now() | Order placed time |
| `updated_at` | timestamptz | NO | now() | Last update time |

**Row Count:** 140

**Partitions:** Monthly partitions (`orders_2025_10`, `orders_2025_11`, etc.)

**Service Type Values:** (CHECK constraint)
- `asap` - Order for immediate preparation
- `scheduled` - Order for specific time (see `scheduled_delivery_time`)

**Payment Method Enum Values:** (`payment_method_type`)
- `cash`
- `credit_card`
- `interac`
- `credit_or_debit_at_door`
- `credit_at_door`
- `debit_at_door`

**Order Status Values:**
- `pending` - Order placed, awaiting restaurant confirmation
- `confirmed` - Restaurant accepted the order
- `preparing` - Kitchen is preparing
- `ready` - Ready for pickup/delivery
- `out_for_delivery` - Driver has picked up (delivery only)
- `delivered` / `completed` - Order fulfilled
- `cancelled` - Order cancelled

**Items JSONB Structure:**
```json
[
  {
    "dish_id": 123,
    "name": "Chicken Shawarma Plate",
    "quantity": 2,
    "unit_price": 15.99,
    "total_price": 31.98,
    "modifiers": [
      {"id": 45, "name": "Extra Garlic Sauce", "price": 1.50},
      {"id": 46, "name": "Add Hummus", "price": 2.00}
    ],
    "special_instructions": "No onions"
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `dish_id` | integer | FK to dishes (for analytics) |
| `name` | string | Dish name (frozen snapshot) |
| `quantity` | integer | Number of items |
| `unit_price` | numeric | Price per unit at time of order |
| `total_price` | numeric | quantity × unit_price + modifiers |
| `modifiers` | array | Selected modifiers with id, name, price |
| `special_instructions` | string | Item-level notes |

---

#### `order_items` (PARTITIONED)
**Purpose:** Individual items within an order

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `order_id` | bigint | NO | - | FK to orders |
| `dish_id` | integer | YES | - | FK to dishes (null if deleted) |
| `item_name` | varchar(255) | NO | - | Dish name snapshot |
| `item_description` | text | YES | - | Item description |
| `quantity` | integer | NO | - | Number of items |
| `unit_price` | numeric(10,2) | NO | - | Price per unit |
| `total_price` | numeric(10,2) | NO | - | Line item total |
| `customizations` | jsonb | YES | - | Selected modifiers |
| `special_instructions` | text | YES | - | Item-level notes |
| `created_at` | timestamptz | NO | now() | Creation time |

**Partitions:** Monthly partitions aligned with orders



#### `order_status_history`
**Purpose:** Order status change audit trail

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `order_id` | bigint | NO | - | FK to orders |
| `order_created_at` | timestamptz | NO | - | Partition key reference |
| `status` | varchar(50) | NO | - | Status value |
| `notes` | text | YES | - | Status change notes |
| `created_at` | timestamptz | NO | now() | When status changed |

---

### Payment Tables

#### `payment_transactions`
**Purpose:** Stripe payment records

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `order_id` | bigint | NO | - | FK to orders |
| `order_created_at` | timestamptz | NO | - | Partition key reference |
| `user_id` | bigint | NO | - | FK to users |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `stripe_payment_intent_id` | varchar(255) | NO | - | Stripe PI ID (unique) |
| `stripe_charge_id` | varchar(255) | YES | - | Stripe charge ID |
| `amount` | numeric(10,2) | NO | - | Transaction amount |
| `currency` | varchar(3) | YES | 'CAD' | Currency code |
| `status` | varchar(50) | NO | - | Transaction status |
| `payment_method` | varchar(50) | YES | - | Card type / method |
| `failure_reason` | text | YES | - | Error message if failed |
| `refund_amount` | numeric(10,2) | YES | 0 | Refunded amount |
| `refunded_at` | timestamptz | YES | - | When refund processed |
| `created_at` | timestamptz | NO | now() | Transaction time |
| `updated_at` | timestamptz | NO | now() | Last update |

---

#### `restaurant_payment_options`
**Purpose:** Available payment methods per restaurant

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `payment_method` | payment_method_type | NO | - | Payment method enum |
| `is_enabled` | boolean | NO | true | Whether method is active |
| `display_order` | integer | NO | 0 | UI ordering |
| `english_label` | text | YES | - | Custom English label |
| `french_label` | text | YES | - | Custom French label |
| `created_at` | timestamptz | NO | now() | Creation time |
| `updated_at` | timestamptz | NO | now() | Last update |

**Row Count:** 1,116

---

#### `user_payment_methods`
**Purpose:** Saved customer payment methods (Stripe)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `user_id` | bigint | NO | - | FK to users |
| `stripe_payment_method_id` | varchar | NO | - | Stripe PM ID (unique) |
| `card_brand` | varchar | YES | - | Card brand (visa, mastercard) |
| `last_4_digits` | varchar | YES | - | Last 4 digits of card |
| `exp_month` | integer | YES | - | Expiration month |
| `exp_year` | integer | YES | - | Expiration year |
| `is_default` | boolean | NO | false | Default payment method |
| `created_at` | timestamptz | NO | now() | Creation time |
| `updated_at` | timestamptz | NO | now() | Last update |

**Row Count:** 0

---

### Cart Tables

#### `cart_sessions`
**Purpose:** Shopping cart sessions (authenticated and guest)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `session_id` | uuid | NO | gen_random_uuid() | Session identifier |
| `user_id` | bigint | YES | - | FK to users (null for guest) |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `cart_data` | jsonb | NO | '{}' | Cart items and state |
| `expires_at` | timestamptz | NO | now() + 24 hours | Auto-expiry time |
| `created_at` | timestamptz | NO | now() | Session start |
| `updated_at` | timestamptz | NO | now() | Last cart update |

---


### Commission Tables

#### `restaurant_commission_configs`
**Purpose:** Platform commission configuration per restaurant with historical rate tracking

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `commission_enabled` | boolean | NO | false | Whether commission is charged |
| `commission_rate` | numeric(5,2) | NO | 0 | Commission rate (percentage or fixed) |
| `commission_type` | commission_rate_type | NO | 'percentage' | Type: percentage or fixed |
| `commission_base` | text | NO | 'gross' | Base: 'gross' or 'net' |
| `effective_from` | date | NO | CURRENT_DATE | When rate becomes effective |
| `effective_until` | date | YES | - | When rate expires (null = current) |
| `created_at` | timestamptz | NO | now() | Creation time |
| `created_by` | bigint | YES | - | Admin who created |
| `updated_at` | timestamptz | NO | now() | Last update time |
| `updated_by` | bigint | YES | - | Admin who updated |

**Row Count:** 186  
**Unique Constraint:** `(restaurant_id, effective_from)`

---

#### `platform_commission_reports`
**Purpose:** Weekly (informational) and monthly (billing) commission reports

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `report_type` | platform_commission_report_type | NO | - | 'weekly' or 'monthly' |
| `statement_number` | integer | YES | - | Only for monthly billing reports |
| `report_period_start` | date | NO | - | Report period start |
| `report_period_end` | date | NO | - | Report period end |
| `total_orders` | integer | NO | 0 | Total orders in period |
| `completed_orders` | integer | NO | 0 | Completed orders |
| `cancelled_orders` | integer | NO | 0 | Cancelled orders |
| `total_order_amount` | numeric(12,2) | NO | 0 | Total order value |
| `commission_rate_used` | numeric(5,2) | NO | - | Rate used for calculation |
| `commission_type_used` | commission_rate_type | NO | - | Type used |
| `commission_base_used` | text | NO | - | Base used (gross/net) |
| `platform_commission_amount` | numeric(10,2) | NO | 0 | Commission amount |
| `calculation_details` | jsonb | YES | - | Calculation breakdown |
| `report_status` | varchar(20) | YES | 'draft' | draft/finalized/sent/paid |
| `report_generated_at` | timestamptz | NO | now() | When report generated |
| `report_generated_by` | uuid | YES | - | Who generated report |
| `pdf_file_url` | text | YES | - | PDF report URL |
| `sent_at` | timestamptz | YES | - | When report emailed (monthly) |
| `paid_at` | timestamptz | YES | - | When payment received (monthly) |
| `created_at` | timestamptz | NO | now() | Creation time |
| `updated_at` | timestamptz | NO | now() | Last update time |

**Row Count:** 0  
**Unique Constraint:** `(restaurant_id, report_type, report_period_start, report_period_end)`

**Enum: `platform_commission_report_type`**
- `weekly` - Informational sales report
- `monthly` - Official billing statement

---

### Refund Tables

#### `order_refunds`
**Purpose:** Refund records with commission/fee reversal tracking  
**Row Count:** 28

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | integer | NO | Primary key |
| `order_id` | integer | NO | FK to orders |
| `restaurant_id` | integer | NO | FK to restaurants |
| `refund_amount` | numeric | NO | Refund amount |
| `original_order_total` | numeric | NO | Original order total |
| `refund_type` | varchar | NO | Type of refund |
| `reason_code` | varchar | NO | Reason code |
| `notes` | text | YES | Additional notes |
| `stripe_refund_id` | varchar | YES | Stripe refund reference |
| `stripe_payment_intent_id` | varchar | YES | Stripe PI reference |
| `stripe_refund_status` | varchar | YES | Stripe refund status |
| `commission_reversed` | numeric | YES | Commission amount reversed |
| `delivery_commission_reversed` | numeric | YES | Delivery commission reversed |
| `transaction_fee_reversed` | numeric | YES | Transaction fee reversed |
| `bank_fee_reversed` | numeric | YES | Bank fee reversed |
| `hst_reversed` | numeric | YES | HST reversed |
| `adjustment_id` | integer | YES | Related adjustment |
| `applies_to_week_start` | date | YES | Commission week start |
| `applies_to_week_end` | date | YES | Commission week end |
| `refunded_by` | integer | NO | Admin who issued refund |
| `refunded_by_email` | varchar | YES | Admin email |
| `created_at` | timestamptz | YES | Creation time |
| `status` | varchar | YES | Refund status |

---

#### `commission_weekly_snapshots`
**Purpose:** Weekly commission calculation snapshots per restaurant  
**Row Count:** 0

#### `vendor_commission_reports`
**Purpose:** Commission reports for vendor-managed restaurants  
**Row Count:** 204

---

## 🔧 SQL Functions (31 total)

### Order Creation & Management

| Function | Purpose |
|----------|---------|
| `create_order(...)` | Creates order with items, validates eligibility, calculates totals, populates both `orders.items` JSONB and `order_items` table |
| `calculate_order_total(...)` | Server-side price calculation (NEVER trust client prices) |
| `calculate_order_taxes(...)` | Calculate taxes (GST/PST/HST) for a subtotal |

### Order Status & Lifecycle

| Function | Purpose |
|----------|---------|
| `update_order_status(...)` | Updates status with validation of allowed transitions |
| `cancel_order(...)` | Cancellation with refund calculation |
| `cancel_customer_order(...)` | Customer-initiated cancellation |
| `tablet_update_order_status(...)` | Tablet app order status update |
| `tablet_get_valid_order_ids(...)` | Get valid order IDs for tablet app |

### Order Retrieval

| Function | Purpose |
|----------|---------|
| `get_order_details(...)` | Full order details with authorization check |
| `get_customer_order_history(...)` | Paginated order history for customers |
| `get_restaurant_orders(...)` | Restaurant dashboard order list |

### Eligibility & Validation

| Function | Purpose |
|----------|---------|
| `check_order_eligibility(...)` | Pre-order restaurant availability check |
| `can_accept_orders(...)` | Quick check if restaurant can accept orders |
| `validate_deal_eligibility(...)` | Validate promotional deal eligibility |

### Coupon Functions

| Function | Purpose |
|----------|---------|
| `apply_coupon_to_order(...)` | Apply coupon with validation and recalculate total |
| `validate_coupon(...)` | Validate coupon code |
| `redeem_coupon(...)` | Redeem a coupon |
| `restore_coupon(...)` | Restore a redeemed coupon |
| `soft_delete_coupon(...)` | Soft delete a coupon |
| `check_coupon_usage_limit(...)` | Check if coupon usage limit reached |
| `get_coupon_redemption_rate(...)` | Get coupon redemption analytics |
| `get_coupons_i18n(...)` | Get coupons with bilingual support |
| `get_top_coupons(...)` | Get top performing coupons |

### Utility & Trigger Functions

| Function | Purpose |
|----------|---------|
| `toggle_online_ordering(...)` | Enable/disable online ordering |
| `log_order_status_change()` | Trigger: auto-log status changes |
| `update_order_timestamp()` | Trigger: auto-update `updated_at` |
| `prevent_items_modification()` | Trigger: prevent orders.items JSONB modification |
| `prevent_order_items_modification()` | Trigger: prevent order_items UPDATE/DELETE |

### Commission Functions

| Function | Purpose |
|----------|---------|
| `calculate_platform_commission(...)` | Calculate commission for any date range |
| `generate_platform_commission_report(...)` | Create weekly or monthly report |
| `prepare_commission_calculation(...)` | Prepare commission data for vendor reports |
| `update_last_commission_rate()` | Trigger: update last commission rate on vendor reports |

---

## ⚡ Edge Functions

| Function | Endpoint | JWT | Purpose |
|----------|----------|-----|---------|
| `toggle-online-ordering` | `/functions/v1/toggle-online-ordering` | No | Toggle restaurant ordering availability |
| `check-restaurant-availability` | `/functions/v1/check-restaurant-availability` | No | Real-time availability check |

**Note:** Payment processing edge functions (create-payment-intent, process-webhook) are planned for Phase 5.

---

## 📇 Indexes

### Orders Table (Base + Partitions)

| Index Name | Columns | Type | Condition | Purpose |
|------------|---------|------|-----------|---------|
| `orders_pkey` | (id, created_at) | UNIQUE | - | Primary key (composite for partitioning) |
| `orders_uuid_created_at_key` | (uuid, created_at) | UNIQUE | - | UUID uniqueness |
| `orders_order_number_created_at_key` | (order_number, created_at) | UNIQUE | - | Order number uniqueness |
| `idx_orders_restaurant_id` | (restaurant_id, created_at DESC) | BTREE | - | Restaurant order lookup |
| `idx_orders_restaurant_status_created` | (restaurant_id, order_status, created_at DESC) | BTREE | - | Dashboard filtering |
| `idx_orders_user_id` | (user_id, created_at DESC) | BTREE | - | Customer order history |
| ~~`idx_orders_user_created`~~ | - | - | - | **Dropped 2026-02-17** (duplicate of above) |
| `idx_orders_uuid` | (uuid) | BTREE | - | API lookups by UUID |
| `idx_orders_order_number` | (order_number) | BTREE | - | Order number search |
| `idx_orders_status` | (order_status) | BTREE | WHERE status IN ('pending','confirmed','preparing','ready') | Active orders only |
| `idx_orders_payment_status` | (payment_status) | BTREE | - | Payment reconciliation |
| `idx_orders_stripe_payment` | (stripe_payment_intent_id) | BTREE | - | Webhook processing |
| `idx_orders_guest_email` | (guest_email) | BTREE | WHERE is_guest_order = true | Guest order lookup (⚠️ does not exist — needs creation) |
| `idx_orders_acknowledged` | (acknowledged_at) | BTREE | WHERE acknowledged_at IS NULL | Unacknowledged orders |
| `idx_orders_cancelled_by` | (cancelled_by) | BTREE | - | Cancellation audit |
| `idx_orders_delivery_city_id` | (delivery_city_id) | BTREE | - | Delivery analytics |
| `idx_orders_promotional_deal_id` | (promotional_deal_id) | BTREE | WHERE promotional_deal_id IS NOT NULL | Promo tracking |
| `idx_orders_items` | (items) | GIN | - | JSONB item search |

### Order Items Table

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `order_items_pkey` | (id, created_at) | Primary key |
| `idx_order_items_order_id` | (order_id, created_at) | Parent order lookup |
| `idx_order_items_dish` | (dish_id) WHERE dish_id IS NOT NULL | Menu analytics |

### Order Status History

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `idx_order_history_order` | (order_id, order_created_at) | Parent order lookup |
| `idx_order_history_created` | (created_at DESC) | Timeline queries |
| `idx_order_status_history_order_id` | (order_id, created_at) | Alternate lookup |

### Payment Transactions

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `idx_payment_transactions_order` | (order_id, order_created_at) | Order payment lookup |
| `idx_payment_transactions_stripe` | (stripe_payment_intent_id) | Webhook processing |
| `idx_payment_transactions_user` | (user_id) | User payment history |

### Cart Sessions

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `idx_cart_sessions_session_id` | (session_id) | Session lookup |
| `idx_cart_sessions_user` | (user_id) | User cart recovery |
| `idx_cart_sessions_restaurant_id` | (restaurant_id) | Restaurant analytics |
| `idx_cart_sessions_expires` | (expires_at) | Cleanup queries |

---

## 🔒 RLS Policies

### All Policies (19 total)

| Table | Policy | Roles | Cmd |
|-------|--------|-------|-----|
| `orders` | `orders_customer_select_own` | authenticated | SELECT |
| `orders` | `orders_customer_update_own` | authenticated | UPDATE |
| `orders` | `anon_can_read_orders` | anon | SELECT |
| `orders` | `orders_service_role_all` | service_role | ALL |
| `order_items` | `order_items_customer_select` | authenticated | SELECT |
| `order_items` | `order_items_service_role_all` | service_role | ALL |
| `order_status_history` | `order_status_history_customer_select` | authenticated | SELECT |
| `order_status_history` | `order_status_history_service_role_all` | service_role | ALL |
| `restaurant_commission_configs` | `restaurant_commission_configs_admin_select` | authenticated | SELECT |
| `restaurant_commission_configs` | `restaurant_commission_configs_service_role_all` | service_role | ALL |
| `platform_commission_reports` | `platform_commission_reports_admin_select` | authenticated | SELECT |
| `platform_commission_reports` | `platform_commission_reports_service_role_all` | service_role | ALL |
| `restaurant_payment_options` | `anyone_can_view_restaurant_payment_options` | anon, authenticated | SELECT |
| `restaurant_payment_options` | `admin_crud_own_restaurant_payment_options` | authenticated | ALL |
| `restaurant_payment_options` | `restaurant_payment_options_service_role_all` | service_role | ALL |
| `user_payment_methods` | `payment_methods_select_own` | authenticated | SELECT |
| `user_payment_methods` | `payment_methods_insert_own` | authenticated | INSERT |
| `user_payment_methods` | `payment_methods_update_own` | authenticated | UPDATE |
| `user_payment_methods` | `payment_methods_delete_own` | authenticated | DELETE |
| `user_payment_methods` | `payment_methods_service_role_all` | service_role | ALL |

**Note:** No INSERT policy on `orders`/`order_items` — created exclusively via `create_order()` function.

---

## ⚙️ Triggers

### Orders Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `trg_orders_update_timestamp` | BEFORE | UPDATE | `update_order_timestamp()` | Auto-update `updated_at` |
| `trg_orders_log_status_change` | AFTER | UPDATE | `log_order_status_change()` | Auto-log status changes to history |
| `trg_prevent_items_modification` | BEFORE | UPDATE | `prevent_items_modification()` | **Prevents modification of `items` JSONB** |

### Order Items Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `trg_prevent_order_items_modification` | BEFORE | UPDATE/DELETE | `prevent_order_items_modification()` | **Prevents modification/deletion of order items** |

**Note:** All triggers are applied to partition tables automatically (3 per orders partition, 1 per order_items partition).

### Vendor Commission Report Triggers

| Trigger | Event | Function | Purpose |
|---------|-------|----------|---------|
| `trg_update_last_commission_rate` | AFTER INSERT/UPDATE | `update_last_commission_rate()` | Sync last rate |
| `update_commission_reports_updated_at` | BEFORE UPDATE | `update_updated_at_column()` | Auto-update timestamp |

### Data Protection Summary

| Table | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|
| `orders` | Only via `create_order()` | Allowed (except `items` column) | Blocked by RLS |
| `order_items` | Only via `create_order()` | Blocked by trigger | Blocked by trigger |

---

## 💰 Commission Flow

Platform commission is calculated **monthly** (post-order billing) with optional **weekly** reports.

1. **Configuration** (`restaurant_commission_configs`) — rate, base (gross/net), enabled per restaurant with historical tracking via `effective_from`/`effective_until`
2. **Aggregation** — `calculate_platform_commission()` aggregates orders for a period
3. **Calculation** — Percentage: `total_amount × (rate/100)` or Fixed: `rate × completed_orders`
4. **Report Generation** — `generate_platform_commission_report()` creates weekly (informational, always finalized) or monthly (billing: draft → finalized → sent → paid)
5. **Vendor System** — Separate `vendor_commission_reports` (204 rows) for vendor-managed restaurants

---

## 🚨 Data Integrity Issues

| Issue | Details |
|-------|---------|
| **Guest columns are actively used** | 85/140 orders are guest orders. `cancel_customer_order` and `validate_deal_eligibility` reference guest columns. Previous doc incorrectly stated these were removed — corrected. |
| **Duplicate index dropped (2026-02-17)** | Dropped `idx_orders_user_created` — was identical to `idx_orders_user_id` (both `user_id, created_at DESC`). |
| **Missing restaurant admin RLS** | Restaurant admins cannot view/update orders via RLS. Need `orders_restaurant_select`, `orders_restaurant_update`, `order_items_restaurant_select`, `order_status_history_restaurant_select` policies. **Action:** Create these policies during off-hours (before 10 AM). |

---

## 🗑️ Migration History

> **Summary:** Major updates between Oct 2025 and Jan 2026:
> - **Table partitioning** (Oct 2025): orders and order_items partitioned by month
> - **Schema simplification** (Jan 2026): Dropped `source`, `created_by`/`updated_by`, `delivery_address_json`, `delivery_lat`/`delivery_lng` columns. Guest columns (`is_guest_order`, `guest_email`, `guest_name`, `guest_phone`) were retained — they are actively used (85/140 orders are guest orders).
> - **Commission system** (Jan 2026): Refactored from per-order to monthly billing. Created `restaurant_commission_configs`, `platform_commission_reports`. Dropped `orders.commission_amount`.
> - **Dual storage** (Jan 2026): `create_order()` now populates both `orders.items` JSONB and `order_items` table, with trigger protection on both
> - **Order items protection** (Jan 2026): Triggers prevent UPDATE/DELETE on `order_items`
> - **Duplicate index cleanup** (Feb 2026): Dropped `idx_orders_user_created` (duplicate of `idx_orders_user_id`)

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| **Total Tables** | 13 (+ 12 partition tables) |
| **Total SQL Functions** | 31 |
| **Total RLS Policies** | 19 |
| **Total Triggers** | 30 (across partitions) |
| **Orders** | 140 |
| **Order Items** | 0 |
| **Order Status History** | 1,611 |
| **Payment Transactions** | 54 |
| **Order Refunds** | 28 |
| **Restaurant Payment Options** | 1,116 |
| **Commission Configs** | 186 |
| **Vendor Commission Reports** | 204 |
| **Monthly Partitions** | 6 (Oct 2025 — Mar 2026) |

---

**Last Updated:** 2026-02-17
