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

- [Tables](#tables)
- [SQL Functions](#sql-functions)
- [Edge Functions](#edge-functions)
- [Indexes](#indexes)
- [RLS Policies](#rls-policies)
- [Triggers](#triggers)
- [Commission Flow](#commission-flow)
- [Issues to Fix](#issues-to-fix)
- [Removed Functionalities](#removed-functionalities)
- [New Functionalities](#new-functionalities)
- [Schema Fixes Applied](#schema-fixes-applied)

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
| `created_at` | timestamptz | NO | now() | Order placed time |
| `updated_at` | timestamptz | NO | now() | Last update time |

**Row Count:** 0 (test data cleared)

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

**Row Count:** 30

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

## 🔧 SQL Functions

### Order Creation & Management

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `create_order` | p_restaurant_id, p_items, p_order_type, p_delivery_address, p_unit_number, p_postal_code, p_delivery_city_id, p_customer_name, p_customer_phone, p_customer_email, p_service_type, p_scheduled_delivery_time, p_special_instructions, p_payment_method, p_coupon_code | TABLE(success, order_id, order_number, grand_total, error) | Creates order with items, validates eligibility, calculates totals, **populates both `orders.items` JSONB and `order_items` table** |
| `calculate_order_total` | p_restaurant_id, p_items, p_order_type, p_coupon_code | TABLE(subtotal, tax, delivery_fee, service_fee, discount, grand_total, tax_rate) | Server-side price calculation (NEVER trust client prices) |
| `calculate_order_taxes` | p_restaurant_id, p_subtotal | jsonb | Calculate taxes for a given subtotal |

### Order Status & Lifecycle

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `update_order_status` | p_order_id, p_new_status, p_notes | TABLE(success, error, previous_status, new_status) | Updates status with validation of allowed transitions |
| `cancel_order` | p_order_id, p_cancellation_reason | TABLE(success, error, refund_amount, cancellation_fee) | Cancellation with refund calculation (policy-based) |
| `cancel_customer_order` | p_order_id, p_user_id, p_guest_email, p_cancellation_reason | jsonb | Customer-initiated cancellation |

### Order Retrieval

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `get_order_details` | p_order_id | TABLE(order details with restaurant, customer, items, history) | Full order details with authorization check |
| `get_customer_order_history` | p_limit, p_offset, p_status_filter | TABLE(orders with restaurant info, item counts) | Paginated order history for customers |
| `get_restaurant_orders` | p_restaurant_id, p_status_filter, p_limit, p_offset | TABLE(orders with customer, items) | Restaurant dashboard order list |

### Eligibility & Validation

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `check_order_eligibility` | p_restaurant_id, p_order_type | TABLE(eligible, reason, restaurant_status) | Pre-order restaurant availability check |
| `can_accept_orders` | p_restaurant_id | boolean | Quick check if restaurant can accept orders |

### Utility Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `apply_coupon_to_order` | p_order_id, p_coupon_code, p_discount_amount | TABLE(success, error, new_total) | Applies coupon with validation and recalculates total |
| `toggle_online_ordering` | p_restaurant_id, p_enabled, p_reason, p_updated_by | TABLE(success, message, new_status) | Enable/disable online ordering |
| `log_order_status_change` | - (trigger) | trigger | Auto-logs status changes to history |
| `update_order_timestamp` | - (trigger) | trigger | Updates `updated_at` on order changes |

### Commission Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `calculate_platform_commission` | p_restaurant_id, p_period_start, p_period_end | TABLE(total_orders, completed_orders, cancelled_orders, total_amount, commission_rate, commission_type, commission_base, commission_amount) | Calculate platform commission for any date range |
| `generate_platform_commission_report` | p_restaurant_id, p_report_type, p_period_start, p_period_end | uuid | Create weekly or monthly commission report |

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
| `idx_orders_user_created` | (user_id, created_at DESC) | BTREE | - | Customer history (duplicate) |
| `idx_orders_uuid` | (uuid) | BTREE | - | API lookups by UUID |
| `idx_orders_order_number` | (order_number) | BTREE | - | Order number search |
| `idx_orders_status` | (order_status) | BTREE | WHERE status IN ('pending','confirmed','preparing','ready') | Active orders only |
| `idx_orders_payment_status` | (payment_status) | BTREE | - | Payment reconciliation |
| `idx_orders_stripe_payment` | (stripe_payment_intent_id) | BTREE | - | Webhook processing |
| `idx_orders_guest_email` | (guest_email) | BTREE | WHERE is_guest_order = true | Guest order lookup |
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

### Orders (3 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `orders_customer_select_own` | authenticated | SELECT | user_id matches JWT user |
| `orders_customer_update_own` | authenticated | UPDATE | user_id matches JWT user |
| `orders_service_role_all` | service_role | ALL | Full access for backend |

**⚠️ No INSERT policy for customers** - Orders MUST be created via `create_order()` function.

### Order Items (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `order_items_customer_select` | authenticated | SELECT | Order belongs to JWT user |
| `order_items_service_role_all` | service_role | ALL | Full access for backend |

**⚠️ No INSERT policy for customers** - Order items are created only via `create_order()` function.

### Order Status History (Actual: 2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `order_status_history_customer_select` | authenticated | SELECT | Order belongs to JWT user |
| `order_status_history_service_role_all` | service_role | ALL | Full access for backend |

### Restaurant Commission Configs (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `restaurant_commission_configs_admin_select` | authenticated | SELECT | Restaurant admin can view their config |
| `restaurant_commission_configs_service_role_all` | service_role | ALL | Full access for backend |

### Platform Commission Reports (2 policies)

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `platform_commission_reports_admin_select` | authenticated | SELECT | Restaurant admin can view their reports |
| `platform_commission_reports_service_role_all` | service_role | ALL | Full access for backend/billing |

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

**Note:** All triggers are applied to partition tables automatically.

### Data Protection Summary

| Table | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|
| `orders` | Only via `create_order()` | Allowed (except `items` column) | Blocked by RLS |
| `order_items` | Only via `create_order()` | Blocked by trigger | Blocked by trigger |

---

## 💰 Commission Flow

Platform commission is calculated **monthly** (post-order billing) with optional **weekly** reports for visibility.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PLATFORM COMMISSION ARCHITECTURE                      │
└─────────────────────────────────────────────────────────────────────────────┘
    ┌─────────────────────────────────┐     ┌─────────────────────────────────┐
    │  ⚙️ CONFIGURATION               │     │  📦 ORDERS                      │
    │  ─────────────────────────────  │     │  ─────────────────────────────  │
    │  restaurant_commission_configs  │     │  orders (partitioned)           │
    │  • commission_enabled           │     │  • subtotal                     │
    │  • commission_rate              │     │  • order_status                 │
    │  • commission_type              │     │  • restaurant_id                │
    │  • commission_base (gross/net)  │     │  • created_at                   │
    │  • effective_from / until       │     │                                 │
    └────────────────┬────────────────┘     └────────────────┬────────────────┘
                     │                                       │
                     │  rate, base, enabled                  │  aggregate by period
                     │                                       │
                     └───────────────────┬───────────────────┘
                                         │
                                         ▼
                     ┌───────────────────────────────────────┐
                     │  ⚡ FUNCTIONS                          │
                     │  ───────────────────────────────────  │
                     │  calculate_platform_commission()      │
                     │  • Aggregates orders for date range   │
                     │  • Applies commission rate            │
                     │  • Returns calculation results        │
                     │                                       │
                     │  generate_platform_commission_report()│
                     │  • Creates report record              │
                     │  • Handles weekly vs monthly logic    │
                     └───────────────────┬───────────────────┘
                                         │
                        ┌────────────────┴────────────────┐
                        │                                 │
                        ▼                                 ▼
    ┌─────────────────────────────────┐ ┌─────────────────────────────────┐
    │  📊 WEEKLY REPORTS              │ │  📊 MONTHLY REPORTS             │
    │  ─────────────────────────────  │ │  ─────────────────────────────  │
    │  platform_commission_reports    │ │  platform_commission_reports    │
    │  report_type = 'weekly'         │ │  report_type = 'monthly'        │
    │                                 │ │                                 │
    │  • Informational only           │ │  • Official billing             │
    │  • No statement_number          │ │  • Has statement_number         │
    │  • Status: always 'finalized'   │ │  • Status lifecycle:            │
    │  • For visibility/tracking      │ │    draft → finalized → sent →   │
    │                                 │ │    paid                         │
    └─────────────────────────────────┘ └─────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────┐
    │  🏪 VENDOR SYSTEM (Separate - in Vendor Entity)                         │
    │  ─────────────────────────────────────────────────────────────────────  │
    │  vendor_commission_reports - For vendor-managed restaurants only        │
    │  Uses: vendor_restaurants.commission_template, last_commission_rate     │
    └─────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PLATFORM COMMISSION FLOW                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. CONFIGURATION (restaurant_commission_configs)                           │
│     └─ Each restaurant has commission settings (rate, base, enabled)        │
│     └─ Historical tracking via effective_from/effective_until               │
│                                                                             │
│  2. ORDER AGGREGATION                                                       │
│     └─ calculate_platform_commission() aggregates orders for a period       │
│     └─ Counts: total_orders, completed_orders, cancelled_orders             │
│     └─ Amounts: Based on commission_base (gross or net)                     │
│                                                                             │
│  3. COMMISSION CALCULATION                                                  │
│     └─ Percentage: total_amount × (rate / 100)                              │
│     └─ Fixed: rate × completed_orders                                       │
│                                                                             │
│  4. REPORT GENERATION (generate_platform_commission_report)                 │
│     └─ Weekly: Informational snapshot (always finalized)                    │
│     └─ Monthly: Official billing with statement_number                      │
│                                                                             │
│  5. BILLING LIFECYCLE (Monthly only)                                        │
│     └─ draft → finalized → sent → paid                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Platform Commission Tables

| Table | Purpose |
|-------|---------|
| `restaurant_commission_configs` | Commission configuration per restaurant (rate, base, enabled) |
| `platform_commission_reports` | Weekly/monthly commission reports and billing |

### Platform Commission Functions

| Function | Purpose |
|----------|---------|
| `calculate_platform_commission` | Calculate commission for a restaurant for any date range |
| `generate_platform_commission_report` | Create weekly (informational) or monthly (billing) report |

### Report Types

| Type | Purpose | Status Flow |
|------|---------|-------------|
| `weekly` | Sales visibility | Always 'finalized' |
| `monthly` | Official billing | draft → finalized → sent → paid |

### Vendor Commission (Separate System)

| Table/Function | Purpose |
|----------------|---------|
| `vendor_restaurants` | Vendor-specific commission template and rates |
| `vendor_commission_reports` | Vendor billing reports (in Vendor Entity) |
| `prepare_commission_calculation` | Prepares commission data for vendor reports |

### Current State (as of 2026-01-19)

- **186 restaurants** with commission configs migrated
- Commission calculated post-order via `calculate_platform_commission`
- Weekly reports: informational only
- Monthly reports: official billing with statement numbers

---

## 🚨 Issues to Fix

### 1. Missing RLS Policies for Restaurant Admins
**Severity:** High  
**Description:** Restaurant admins cannot view/update orders for their restaurants via RLS

**Missing Policies (from documentation vs actual):**
| Policy | Table | Command | Should Allow |
|--------|-------|---------|--------------|
| `orders_restaurant_select` | orders | SELECT | Admin views restaurant's orders |
| `orders_restaurant_update` | orders | UPDATE | Admin updates order status |
| `order_items_restaurant_select` | order_items | SELECT | Admin views order items |
| `order_status_history_restaurant_select` | order_status_history | SELECT | Admin views status history |

**SQL to Create:**
```sql
-- Orders: Restaurant admin SELECT
CREATE POLICY orders_restaurant_select ON menuca_v3.orders
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM menuca_v3.admin_user_restaurants aur
        WHERE aur.restaurant_id = orders.restaurant_id
        AND aur.admin_user_id = (
            SELECT au.id FROM menuca_v3.admin_users au
            WHERE au.auth_user_id = auth.uid()
        )
    )
);

-- Orders: Restaurant admin UPDATE
CREATE POLICY orders_restaurant_update ON menuca_v3.orders
FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM menuca_v3.admin_user_restaurants aur
        WHERE aur.restaurant_id = orders.restaurant_id
        AND aur.admin_user_id = (
            SELECT au.id FROM menuca_v3.admin_users au
            WHERE au.auth_user_id = auth.uid()
        )
    )
);
```

---

### 2. ✅ RESOLVED: Dual Storage Fully Implemented
**Severity:** Resolved  
**Description:** Dual storage is now fully implemented and protected.

**Current State:**
- `orders.items` (JSONB): ✅ Populated by `create_order()` with modifiers
- `order_items` table: ✅ Populated with modifiers in `customizations`
- `order_item_modifiers` table: ❌ Dropped (not needed)

**Protection Implemented:**
- `trg_prevent_items_modification` trigger protects `orders.items` ✅
- `trg_prevent_order_items_modification` trigger protects `order_items` ✅

**When to use each:** See [BRIAN HANDOFF.md](../../BRIAN%20HANDOFF.md)

---

### 3. ✅ RESOLVED: `create_order()` Now Populates `orders.items`
**Severity:** Resolved  
**Status:** Fixed on 2026-01-20

**Previous Issue:** `create_order()` only inserted into `order_items` table but did NOT populate `orders.items` JSONB.

**Resolution:** Updated `create_order()` to:
1. Build items JSONB array during processing loop
2. Include all modifiers in the JSONB
3. Update `orders.items` after all items are processed

**Current Behavior:**
- `order_items` table: ✅ Populated with modifiers in `customizations`
- `orders.items` JSONB: ✅ Populated with same data including modifiers

---

### 4. Missing Function: `check_cart_availability`
**Severity:** Medium  
**Description:** Function is documented but does not exist in database

**Expected Signature:**
```sql
check_cart_availability(p_cart_items jsonb) RETURNS jsonb
```

**Purpose:** Validate dish availability before checkout (check if dishes are still active, in stock, etc.)

**Action Required:** Either create the function or remove from documentation.

---

### 5. Commission System Refactored ✅ RESOLVED
**Severity:** Medium  
**Status:** ✅ Fixed on 2026-01-19

**Previous Issue:** `orders.commission_amount` column existed but was never populated

**Resolution:**
- Refactored to monthly post-order billing model
- Created `restaurant_commission_configs` table for configuration
- Created `platform_commission_reports` table for weekly/monthly reports
- Created `calculate_platform_commission` and `generate_platform_commission_report` functions
- Removed `orders.commission_amount` column (was 100% NULL)
- Removed commission columns from `delivery_and_pickup_configs` (migrated)

---

### 6. Documentation Inaccuracy: payment_method Type
**Severity:** Low  
**Status:** ✅ Fixed in this update

**Was:** `payment_method` (incorrect enum name)
**Is:** `payment_method_type` (correct enum name in `menuca_v3` schema)

---

### 7. Duplicate Index
**Severity:** Low  
**Description:** `idx_orders_user_id` and `idx_orders_user_created` are identical

Both indexes:
- Columns: `(user_id, created_at DESC)`
- Table: `orders`

**Action Required:** Drop one of the duplicate indexes to save space.

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| 2026-01-20 | `guest_name`, `guest_email`, `guest_phone`, `is_guest_order` columns | Schema simplification - use customer_* instead |
| 2026-01-20 | `source` column | Not needed |
| 2026-01-20 | `created_by`, `updated_by` columns | Redundant with user_id |
| 2026-01-20 | `delivery_address_json` column | Redundant with delivery_address |
| 2026-01-20 | `delivery_lat`, `delivery_lng` columns | Not needed |
| 2026-01-20 | 82 test orders | Cleared to allow NOT NULL constraint on postal_code |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| 2025-10 | Table partitioning by month | Complete |
| 2025-10 | Guest checkout support | Complete (user_id NULL = guest) |
| 2025-11 | POS device acknowledgment | Complete |
| 2025-11 | JSONB items denormalization | Complete |
| 2025-12 | Tax breakdown tracking | Complete |
| 2026-01 | Platform commission system | Complete |
| 2026-01 | `service_type` column (asap/scheduled) | Complete |
| 2026-01 | `unit_number` column | Complete |
| 2026-01 | `postal_code` column | Complete |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| 2026-01-19 | Documentation audit - added missing tables | Documentation only |
| 2026-01-19 | Corrected payment_method enum name | Documentation only |
| 2026-01-19 | Added undocumented columns (tax_breakdown, tax_province_id) | Documentation only |
| 2026-01-19 | Created `restaurant_commission_configs` table | New table - 186 rows migrated |
| 2026-01-19 | Created `platform_commission_reports` table | New table for weekly/monthly reports |
| 2026-01-19 | Created `platform_commission_report_type` enum | New enum: weekly/monthly |
| 2026-01-19 | Created `calculate_platform_commission` function | Commission calculation |
| 2026-01-19 | Created `generate_platform_commission_report` function | Report generation |
| 2026-01-19 | Dropped `orders.commission_amount` column | Column removed - was 100% NULL |
| 2026-01-19 | Dropped commission columns from `delivery_and_pickup_configs` | Migrated to new table |
| 2026-01-20 | Added `service_type` column to orders | 'asap' or 'scheduled' |
| 2026-01-20 | Added `unit_number` column to orders | Apartment/suite number |
| 2026-01-20 | Added `postal_code` column to orders | Canadian postal code (NOT NULL) |
| 2026-01-20 | Dropped 10 columns from orders | Schema simplification |
| 2026-01-20 | Added `delivery_city_id` FK to cities | Proper foreign key constraint |
| 2026-01-20 | Updated `create_order()` function | Now populates tax_breakdown, items JSONB, all new columns |
| 2026-01-20 | Dropped `order_item_modifiers` table | Not used, modifiers stored in JSONB |
| 2026-01-20 | Created `trg_prevent_items_modification` trigger | Prevents modification of orders.items |
| 2026-01-20 | Created `trg_prevent_order_items_modification` trigger | Prevents UPDATE/DELETE on order_items |
| 2026-01-20 | Removed `orders_customer_insert_own` policy | Orders must be created via create_order() |
| 2026-01-20 | Removed `order_items_customer_insert` policy | Order items created only via create_order() |
| 2026-01-20 | Deleted 82 test orders | Clean slate for production |
| 2026-01-20 | Updated `create_order()` to populate `orders.items` JSONB | Dual storage now fully functional |
| 2026-01-20 | Dropped old `create_order()` overloads | Single function with updated signature |
| 2026-01-20 | Dropped `check_order_eligibility` legacy overload | Unused p_customer_id parameter |
| 2026-01-20 | Fixed `apply_coupon_to_order` | Now validates, authorizes, and recalculates total |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Core Tables | 10 |
| Orders Table Columns | 44 |
| Monthly Partitions | 6 (Oct 2025 - Mar 2026) |
| SQL Functions | 17 |
| Indexes | ~38 |
| RLS Policies | 13 |
| Triggers | 14 (2 per partition × 7 partitions) |
| Total Orders | 0 (test data cleared) |
| Commission Configs | 186 |

---

**Last Updated:** 2026-01-20 (Orders Table Simplification)
