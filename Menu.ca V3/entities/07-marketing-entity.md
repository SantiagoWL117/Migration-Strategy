# 07 - Marketing Entity

> **Promotions** - Coupons, discounts, and campaigns

---

## 📋 Purpose

The Marketing Entity manages **promotional activities**:
- **Coupons** - Discount codes
- **Campaigns** - Marketing initiatives
- **Promotions** - Special offers
- **Referrals** - Customer referral tracking

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

### Promotion Tables

#### `promotions`
**Purpose:** Promotional offers

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `uuid` | uuid | External identifier |
| `restaurant_id` | bigint | FK to restaurants (null=global) |
| `name` | varchar | Promotion name |
| `description` | text | Description |
| `discount_type` | varchar | percentage/fixed/free_item |
| `discount_value` | numeric | Discount amount |
| `minimum_order` | numeric | Minimum order required |
| `start_date` | date | Start date |
| `end_date` | date | End date |
| `is_active` | boolean | Currently active |
| `created_at` | timestamptz | Creation time |

---

#### `coupons`
**Purpose:** Discount codes

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `code` | varchar | Coupon code |
| `promotion_id` | bigint | FK to promotions |
| `max_uses` | integer | Maximum uses |
| `current_uses` | integer | Current use count |
| `is_active` | boolean | Code active |
| `expires_at` | timestamptz | Expiration |

---

#### `coupon_usage`
**Purpose:** Coupon redemption tracking

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `coupon_id` | bigint | FK to coupons |
| `order_id` | bigint | FK to orders |
| `user_id` | uuid | FK to users |
| `discount_applied` | numeric | Amount discounted |
| `created_at` | timestamptz | Redemption time |

---

#### `marketing_campaigns`
**Purpose:** Marketing campaign tracking

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | varchar | Campaign name |
| `type` | varchar | email/sms/push |
| `status` | varchar | draft/active/completed |
| `target_audience` | jsonb | Targeting criteria |
| `scheduled_at` | timestamptz | Send time |
| `sent_at` | timestamptz | Actual send time |

---

## 🔧 SQL Functions

**TODO:** Document after database query

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | - |

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
| - | - | - |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 4 |

---

**Last Updated:** 2025-11-27

