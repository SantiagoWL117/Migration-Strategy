# 04 - Order Management Entity

> **Transactions** - Orders, payments, and order lifecycle

---

## 📋 Purpose

The Order Management Entity handles **all transactional data**:
- **Order Processing** - From cart to completion
- **Payment Handling** - Transactions and refunds
- **Order Items** - Line items with customizations
- **Order Status** - Lifecycle tracking
- **Tips** - Gratuity management

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
**Purpose:** Primary order records - partitioned by month

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `uuid` | uuid | External identifier |
| `restaurant_id` | bigint | FK to restaurants |
| `user_id` | uuid | FK to users |
| `order_number` | varchar(50) | Human-readable order # |
| `status` | order_status | Current status |
| `order_type` | varchar(20) | delivery/takeout |
| `subtotal` | numeric(10,2) | Items total |
| `tax_amount` | numeric(10,2) | Tax amount |
| `delivery_fee` | numeric(10,2) | Delivery charge |
| `tip_amount` | numeric(10,2) | Tip amount |
| `total` | numeric(10,2) | Grand total |
| `payment_status` | varchar(50) | Payment state |
| `created_at` | timestamptz | Order placed time |

**Partitions:** `orders_2025_01` through `orders_2026_12`

---

#### `order_items` (PARTITIONED)
**Purpose:** Individual items within an order

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `order_id` | bigint | FK to orders |
| `dish_id` | bigint | FK to dishes |
| `quantity` | integer | Number of items |
| `unit_price` | numeric(10,2) | Price per unit |
| `modifiers` | jsonb | Selected modifiers |

---

#### `order_item_modifiers`
**Purpose:** Modifiers applied to order items

---

#### `order_status_history`
**Purpose:** Order status change audit trail

---

### Payment Tables

#### `payment_transactions`
**Purpose:** Payment records

---

#### `refunds`
**Purpose:** Refund records

---

### Guest/Cart Tables

#### `guest_checkouts`
**Purpose:** Orders without account

#### `carts`
**Purpose:** Shopping cart records

#### `cart_items`
**Purpose:** Items in shopping cart

---

## 🔧 SQL Functions

**TODO:** Document after database query

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| `create-payment-intent` | `/functions/v1/create-payment-intent` | Initialize Stripe |
| `process-webhook` | `/functions/v1/process-webhook` | Handle webhooks |

---

## 📇 Indexes

**TODO:** Document after database query

---

## 🔒 RLS Policies

**TODO:** Document after database query

---

## ⚙️ Triggers

**TODO:** Document after database query

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None yet |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| - | Table partitioning | Complete |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 10 |
| Partitions | 24 |

---

**Last Updated:** 2025-11-27

