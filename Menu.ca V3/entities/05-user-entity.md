# 05 - User Entity

> **Customers** - End users and their data

---

## 📋 Purpose

The User Entity manages **customer accounts and data**:
- **User Profiles** - Account information
- **Addresses** - Delivery locations
- **Preferences** - Food preferences and settings
- **Authentication** - Via Supabase Auth

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

### Core User Tables

#### `users`
**Purpose:** User profile extension of auth.users

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key (matches auth.users.id) |
| `email` | varchar | User email |
| `full_name` | varchar | Display name |
| `phone` | varchar | Phone number |
| `avatar_url` | varchar | Profile image |
| `default_language` | varchar(5) | Preferred language |
| `email_notifications` | boolean | Email opt-in |
| `sms_notifications` | boolean | SMS opt-in |
| `created_at` | timestamptz | Registration time |
| `updated_at` | timestamptz | Last update |
| `deleted_at` | timestamptz | Soft delete |

---

#### `user_addresses`
**Purpose:** Saved delivery addresses

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | uuid | FK to users |
| `label` | varchar | Address label (Home, Work) |
| `street_address` | varchar | Street address |
| `city_id` | integer | FK to cities |
| `province_id` | integer | FK to provinces |
| `postal_code` | varchar | Postal code |
| `latitude` | numeric | Latitude |
| `longitude` | numeric | Longitude |
| `is_default` | boolean | Default address |
| `delivery_instructions` | text | Driver notes |

---

#### `user_favorites`
**Purpose:** Favorite restaurants

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | uuid | FK to users |
| `restaurant_id` | bigint | FK to restaurants |
| `created_at` | timestamptz | When favorited |

---

#### `user_preferences`
**Purpose:** Food preferences and dietary restrictions

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | uuid | FK to users |
| `dietary_restrictions` | text[] | Restrictions array |
| `favorite_cuisines` | integer[] | Cuisine type IDs |
| `allergies` | text[] | Allergy list |

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

| Policy | Operation | Description |
|--------|-----------|-------------|
| `users_select_own` | SELECT | Users see own profile |
| `users_update_own` | UPDATE | Users update own profile |

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

