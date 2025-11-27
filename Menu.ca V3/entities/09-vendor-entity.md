# 09 - Vendor Entity

> **B2B Platform** - Multi-tenant and vendor management

---

## 📋 Purpose

The Vendor Entity supports **B2B/multi-tenant** functionality:
- **Vendor Accounts** - Third-party integrators
- **API Keys** - Integration credentials
- **White-label** - Brand customization
- **Multi-tenant** - Shared infrastructure

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

### Vendor Tables

#### `vendors`
**Purpose:** Vendor/partner accounts

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `uuid` | uuid | External identifier |
| `name` | varchar | Vendor name |
| `company_name` | varchar | Legal company name |
| `contact_email` | varchar | Primary contact |
| `contact_phone` | varchar | Phone number |
| `is_active` | boolean | Account active |
| `created_at` | timestamptz | Creation time |

---

#### `vendor_api_keys`
**Purpose:** API credentials

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `vendor_id` | bigint | FK to vendors |
| `key_name` | varchar | Key identifier |
| `api_key_hash` | varchar | Hashed API key |
| `permissions` | jsonb | Allowed operations |
| `rate_limit` | integer | Requests/minute |
| `is_active` | boolean | Key active |
| `last_used_at` | timestamptz | Last usage |
| `expires_at` | timestamptz | Expiration |

---

#### `vendor_restaurants`
**Purpose:** Vendor-restaurant relationships

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `vendor_id` | bigint | FK to vendors |
| `restaurant_id` | bigint | FK to restaurants |
| `relationship_type` | varchar | owner/partner/reseller |
| `commission_rate` | numeric | Commission % |
| `created_at` | timestamptz | Relationship start |

---

#### `vendor_branding`
**Purpose:** White-label customization

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `vendor_id` | bigint | FK to vendors |
| `logo_url` | varchar | Custom logo |
| `primary_color` | varchar | Brand color |
| `custom_domain` | varchar | White-label domain |
| `email_from_name` | varchar | Email sender name |

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
| Total Tables | 4 |

---

**Last Updated:** 2025-11-27

