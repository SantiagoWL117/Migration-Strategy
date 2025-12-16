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

### Core Order Tables

#### `orders` (PARTITIONED)
**Purpose:** Primary order records - partitioned by month for scalability

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `user_id` | bigint | YES | - | FK to users (null for guest) |
| `order_number` | varchar(50) | NO | - | Human-readable order # |
| `order_type` | varchar(20) | NO | - | delivery/takeout/dine_in |
| `order_status` | varchar(20) | NO | - | Current lifecycle status |
| `subtotal` | numeric(10,2) | NO | - | Items total before tax/fees |
| `tax_amount` | numeric(10,2) | NO | 0 | Tax amount |
| `delivery_fee` | numeric(10,2) | NO | 0 | Delivery charge |
| `tip_amount` | numeric(10,2) | NO | 0 | Tip amount |
| `discount_amount` | numeric(10,2) | NO | 0 | Coupon/promo discount |
| `total_amount` | numeric(10,2) | NO | - | Grand total |
| `customer_name` | varchar(255) | YES | - | Customer display name |
| `customer_phone` | varchar(50) | YES | - | Contact phone |
| `customer_email` | varchar(255) | YES | - | Contact email |
| `delivery_address` | text | YES | - | Delivery address (text) |
| `delivery_address_json` | jsonb | YES | - | Structured address data |
| `delivery_instructions` | text | YES | - | Driver instructions |
| `delivery_city_id` | integer | YES | - | FK to cities |
| `delivery_lat` | numeric | YES | - | Delivery latitude |
| `delivery_lng` | numeric | YES | - | Delivery longitude |
| `scheduled_delivery_time` | timestamptz | YES | - | Scheduled delivery slot |
| `estimated_ready_time` | timestamptz | YES | - | Restaurant estimate |
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
| `payment_method` | payment_method | YES | - | Payment type enum |
| `payment_status` | varchar(50) | YES | 'pending' | Payment state |
| `stripe_payment_intent_id` | varchar(255) | YES | - | Stripe PI reference |
| `source` | varchar(50) | YES | - | Order source (web/app/phone) |
| `is_guest_order` | boolean | NO | false | Guest checkout flag |
| `guest_name` | varchar(255) | YES | - | Guest customer name |
| `guest_email` | varchar(255) | YES | - | Guest email |
| `guest_phone` | varchar(20) | YES | - | Guest phone |
| `items` | jsonb | YES | - | Denormalized items snapshot |
| `acknowledged_by_device_id` | integer | YES | - | POS device that accepted |
| `acknowledged_at` | timestamptz | YES | - | When acknowledged by POS |
| `created_at` | timestamptz | NO | now() | Order placed time |
| `created_by` | bigint | YES | - | User who created |
| `updated_at` | timestamptz | NO | now() | Last update time |
| `updated_by` | bigint | YES | - | User who updated |

**Partitions:** Monthly partitions (`orders_2025_10`, `orders_2025_11`, etc.)

**Order Status Values:**
- `pending` - Order placed, awaiting restaurant confirmation
- `confirmed` - Restaurant accepted the order
- `preparing` - Kitchen is preparing
- `ready` - Ready for pickup/delivery
- `out_for_delivery` - Driver has picked up (delivery only)
- `delivered` / `completed` - Order fulfilled
- `cancelled` - Order cancelled

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

---

#### `order_item_modifiers`
**Purpose:** Modifiers applied to order items (toppings, size variants, etc.)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | nextval | Primary key |
| `order_item_id` | bigint | NO | - | FK to order_items |
| `order_item_created_at` | timestamptz | NO | - | Partition key reference |
| `combo_modifier_id` | bigint | NO | - | FK to combo_modifiers |
| `combo_modifier_group_id` | bigint | YES | - | FK to combo_modifier_groups |
| `size_variant` | text | YES | - | Size (small/medium/large) |
| `price_charged` | numeric(10,2) | NO | 0 | Price for this modifier |
| `quantity` | integer | YES | 1 | Modifier quantity |
| `placement` | text | YES | 'whole' | Pizza placement (left/right/whole) |
| `created_at` | timestamptz | YES | now() | Creation time |

---

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

## 🔧 SQL Functions

### Order Creation & Management

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `create_order` | p_restaurant_id, p_items, p_order_type, etc. | TABLE(success, order_id, order_number, grand_total, error) | Creates new order with items, validates eligibility, calculates totals |
| `create_order` (overload) | p_user_id, p_restaurant_id, p_items, ... | TABLE | Legacy signature with explicit user_id |
| `calculate_order_total` | p_restaurant_id, p_items, p_order_type, p_coupon_code | TABLE(subtotal, tax, delivery_fee, service_fee, discount, grand_total, tax_rate) | Server-side price calculation (NEVER trust client prices) |
| `calculate_order_total` (overload) | p_items, p_restaurant_id, p_delivery_fee, p_tip, p_coupon_code | jsonb | Legacy JSONB return signature |

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
| `check_order_eligibility` (overload) | p_restaurant_id, p_customer_id, p_order_type | TABLE | Legacy with customer_id |
| `can_accept_orders` | p_restaurant_id | boolean | Quick check if restaurant can accept orders |
| `check_cart_availability` | p_cart_items | jsonb | Checks dish availability before checkout |

### Utility Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `apply_coupon_to_order` | p_order_id, p_coupon_code, p_discount_amount | boolean | Applies coupon to existing order |
| `toggle_online_ordering` | p_restaurant_id, p_enabled, p_reason, p_updated_by | TABLE(success, message, new_status) | Enable/disable online ordering |
| `log_order_status_change` | - (trigger) | trigger | Auto-logs status changes to history |
| `update_order_timestamp` | - (trigger) | trigger | Updates `updated_at` on order changes |

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

### Orders

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `orders_customer_select_own` | authenticated | SELECT | user_id matches JWT user |
| `orders_customer_insert_own` | authenticated | INSERT | user_id matches JWT user |
| `orders_customer_update_own` | authenticated | UPDATE | user_id matches JWT user |
| `orders_restaurant_select` | authenticated | SELECT | User is admin for order's restaurant |
| `orders_restaurant_update` | authenticated | UPDATE | User is admin for order's restaurant |
| `orders_service_role_all` | service_role | ALL | Full access for backend |

### Order Items

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `order_items_customer_select` | authenticated | SELECT | Order belongs to JWT user |
| `order_items_customer_insert` | authenticated | INSERT | Order belongs to JWT user |
| `order_items_restaurant_select` | authenticated | SELECT | User is admin for order's restaurant |
| `order_items_service_role_all` | service_role | ALL | Full access for backend |

### Order Status History

| Policy | Roles | Command | Logic |
|--------|-------|---------|-------|
| `order_status_history_customer_select` | authenticated | SELECT | Order belongs to JWT user |
| `order_status_history_restaurant_select` | authenticated | SELECT | User is admin for order's restaurant |
| `order_status_history_service_role_all` | service_role | ALL | Full access for backend |

---

## ⚙️ Triggers

### Orders Table

| Trigger | Timing | Event | Function | Purpose |
|---------|--------|-------|----------|---------|
| `trg_orders_update_timestamp` | BEFORE | UPDATE | `update_order_timestamp()` | Auto-update `updated_at` |
| `trg_orders_log_status_change` | AFTER | UPDATE | `log_order_status_change()` | Auto-log status changes to history |

**Note:** Triggers are applied to all partition tables automatically.

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None yet |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| 2025-10 | Table partitioning by month | Complete |
| 2025-10 | Guest checkout support | Complete |
| 2025-11 | POS device acknowledgment | Complete |
| 2025-11 | JSONB items denormalization | Complete |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Core Tables | 5 |
| Monthly Partitions | 6 (Oct 2025 - Mar 2026) |
| SQL Functions | 17 |
| Indexes | 35+ |
| RLS Policies | 13 |
| Triggers | 2 per partition |

---

**Last Updated:** 2025-12-16

