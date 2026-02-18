# 08 - Geography Entity

> **Location & Reference Data** - Cities, provinces, and cuisine types

---

## 📋 Purpose

The Geography Entity provides **read-only reference data** used by other entities:
- **Cities** - Canadian cities referenced by restaurant locations, delivery addresses, and delivery areas
- **Provinces** - Canadian provinces (bilingual: English and French names)
- **Cuisine Types** - Restaurant cuisine classifications

This is **reference data** — no `countries` or `postal_codes` tables exist in the schema.

---

## 📑 Index

- [📊 Tables](#-tables) — `cities`, `provinces`, `cuisine_types`
- [🔧 SQL Functions](#-sql-functions-6-total)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)

---

## 📊 Tables

#### `cities` (114 records)
**Purpose:** Canadian cities — referenced by `restaurant_locations`, `user_delivery_addresses`, `restaurant_delivery_areas`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | integer | NO | Primary key |
| `name` | varchar | NO | City name |
| `display_name` | varchar | YES | Display name (if different from `name`) |
| `province_id` | smallint | NO | FK to provinces |
| `lat` | numeric | YES | Center latitude |
| `lng` | numeric | YES | Center longitude |
| `timezone` | varchar | YES | Timezone (e.g., `America/Toronto`) |

---

#### `provinces` (13 records)
**Purpose:** Canadian provinces — bilingual names

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | smallint | NO | Primary key |
| `name` | varchar | NO | English name |
| `nom_francaise` | varchar | YES | French name |
| `short_name` | char | NO | Province code (ON, QC, etc.) |

---

#### `cuisine_types` (36 records)
**Purpose:** Cuisine classification for restaurants — referenced by `restaurant_cuisines`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | integer | NO | Primary key |
| `name` | varchar | NO | Cuisine name (UNIQUE) |
| `slug` | varchar | NO | URL-friendly name (UNIQUE) |
| `description` | text | YES | Cuisine description |
| `icon_url` | varchar | YES | Icon image URL |
| `display_order` | integer | NO | Sort order |
| `is_active` | boolean | NO | Active status |
| `created_at` | timestamptz | NO | Creation time |
| `updated_at` | timestamptz | YES | Last update |

---

## 🔧 SQL Functions (6 total)

| Function | Purpose |
|----------|---------|
| `get_all_provinces()` | Return all provinces |
| `get_cities_by_province()` | Return cities filtered by province |
| `add_cuisine_to_restaurant()` | Assign a cuisine type to a restaurant |
| `create_cuisine_type()` | Create a new cuisine type |
| `get_restaurants_by_cuisine()` | Get restaurants with a specific cuisine |
| `create_restaurant_with_cuisine()` | Create a restaurant and assign a cuisine in one call |

---

## 📇 Indexes

### `cities` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `cities_pkey` | `id` | PRIMARY KEY |
| `idx_cities_province_id` | `province_id` | BTREE |
| `idx_cities_name_trgm` | `name` | GIN (trigram) |
| `u_cities_name_province` | `lower(name), COALESCE(province_id, 0)` | UNIQUE |

### `provinces` (4 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `provinces_pkey` | `id` | PRIMARY KEY |
| `u_provinces_name` | `lower(name)` | UNIQUE |
| `u_provinces_short_name` | `lower(short_name)` | UNIQUE |
| `idx_provinces_short_name` | `short_name` | BTREE |

### `cuisine_types` (3 indexes)

| Index Name | Columns | Type |
|------------|---------|------|
| `cuisine_types_pkey` | `id` | PRIMARY KEY |
| `cuisine_types_name_key` | `name` | UNIQUE |
| `cuisine_types_slug_key` | `slug` | UNIQUE |

---

## 🔒 RLS Policies (6 total)

| Table | Policy | Operation | Roles |
|-------|--------|-----------|-------|
| `cities` | `public_read_cities` | SELECT | public |
| `cities` | `cities_service_role_all` | ALL | service_role |
| `provinces` | `public_read_provinces` | SELECT | public |
| `provinces` | `provinces_service_role_all` | ALL | service_role |
| `cuisine_types` | `public_read_cuisine_types` | SELECT | public |
| `cuisine_types` | `cuisine_types_service_role_all` | ALL | service_role |

---

## ⚙️ Triggers

None — reference data only.

---

## 🚨 Data Integrity Issues

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 | ~~`u_provinces_name_en` duplicate index~~ | ✅ | Resolved | Dropped (2026-02-17) |
| 2 | ~~`cuisine_types` missing RLS~~ | ✅ | Resolved | Enabled RLS + added `public_read_cuisine_types` and `cuisine_types_service_role_all` (2026-02-17) |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 3 |
| Cities | 114 |
| Provinces | 13 |
| Cuisine Types | 36 |
| SQL Functions | 6 |
| Indexes | 11 |
| RLS Policies | 6 |
| Triggers | 0 |

---

**Last Updated:** 2026-02-17
