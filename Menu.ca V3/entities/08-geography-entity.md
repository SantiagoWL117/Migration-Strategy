# 08 - Geography Entity

> **Location Data** - Cities, provinces, and reference data

---

## 📋 Purpose

The Geography Entity provides **reference data** for locations:
- **Cities** - Canadian cities
- **Provinces** - Canadian provinces
- **Countries** - Country reference
- **Postal Codes** - Postal code lookups

This is **read-only reference data** used by other entities.

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

### Reference Tables

#### `countries`
**Purpose:** Country reference

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `name` | varchar | Country name |
| `code` | varchar(3) | ISO code |
| `phone_code` | varchar | Phone prefix |

---

#### `provinces`
**Purpose:** Province/state reference

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `country_id` | integer | FK to countries |
| `name` | varchar | Province name |
| `code` | varchar(5) | Province code (ON, QC) |

---

#### `cities`
**Purpose:** City reference

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `province_id` | integer | FK to provinces |
| `name` | varchar | City name |
| `slug` | varchar | URL-friendly name |
| `latitude` | numeric | Center latitude |
| `longitude` | numeric | Center longitude |
| `timezone` | varchar | Timezone |

---

#### `postal_codes`
**Purpose:** Postal code lookups

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `postal_code` | varchar(7) | Postal code |
| `city_id` | integer | FK to cities |
| `province_id` | integer | FK to provinces |
| `latitude` | numeric | Latitude |
| `longitude` | numeric | Longitude |

---

#### `cuisine_types`
**Purpose:** Cuisine classification

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `name` | varchar | Cuisine name |
| `slug` | varchar | URL-friendly name |
| `display_order` | integer | Sort order |
| `is_active` | boolean | Active status |

---

## 🔧 SQL Functions

```sql
-- Function: Get city by postal code
CREATE OR REPLACE FUNCTION menuca_v3.get_city_by_postal(
    p_postal_code varchar
)
RETURNS TABLE(city_id integer, city_name varchar, province_code varchar)
```

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | None - reference data |

---

## 📇 Indexes

| Index | Table | Columns |
|-------|-------|---------|
| `idx_cities_province` | cities | `province_id` |
| `idx_postal_codes_code` | postal_codes | `postal_code` |
| `idx_cuisine_types_slug` | cuisine_types | `slug` |

---

## 🔒 RLS Policies

| Policy | Operation | Description |
|--------|-----------|-------------|
| `public_read` | SELECT | Public read access |

---

## ⚙️ Triggers

None - reference data only

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| - | - | - |

---

## 🔧 Schema Fixes Applied

| Date | Fix | Impact |
|------|-----|--------|
| - | - | None |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 5 |
| Total Cities | ~5,600 |
| Total Provinces | 13 |
| Total Postal Codes | ~850,000 |

---

**Last Updated:** 2025-11-27

