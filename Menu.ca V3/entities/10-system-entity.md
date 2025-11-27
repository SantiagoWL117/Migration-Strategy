# 10 - System Entity

> **Infrastructure** - Audit logs, migrations, and system tables

---

## 📋 Purpose

The System Entity handles **infrastructure concerns**:
- **Audit Logging** - Change tracking
- **Migrations** - Schema version control
- **Feature Flags** - Feature toggles
- **System Config** - Global settings

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

### Audit Tables

#### `audit_log` (PARTITIONED)
**Purpose:** Change audit trail - partitioned by month

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `table_name` | varchar | Affected table |
| `record_id` | bigint | Affected record ID |
| `action` | varchar | INSERT/UPDATE/DELETE |
| `old_data` | jsonb | Previous values |
| `new_data` | jsonb | New values |
| `changed_by` | uuid | User who changed |
| `changed_at` | timestamptz | Change timestamp |
| `ip_address` | inet | Source IP |

**Partitions:** `audit_log_2025_01` through `audit_log_2026_12`

---

#### `data_migrations`
**Purpose:** Schema migration tracking

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `migration_name` | varchar | Migration identifier |
| `executed_at` | timestamptz | Execution time |
| `success` | boolean | Success status |
| `error_message` | text | Error if failed |
| `duration_ms` | integer | Execution duration |

---

### Configuration Tables

#### `feature_flags`
**Purpose:** Feature toggles

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | varchar | Flag name |
| `description` | text | Flag description |
| `is_enabled` | boolean | Global enabled |
| `restaurant_ids` | bigint[] | Specific restaurants |
| `user_ids` | uuid[] | Specific users |
| `percentage` | integer | Rollout percentage |
| `created_at` | timestamptz | Creation time |

---

#### `system_config`
**Purpose:** Global settings

| Column | Type | Description |
|--------|------|-------------|
| `key` | varchar | Config key |
| `value` | jsonb | Config value |
| `description` | text | Description |
| `updated_at` | timestamptz | Last update |
| `updated_by` | bigint | Admin who updated |

---

### Translation Tables

#### `translations`
**Purpose:** Multi-language content

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `table_name` | varchar | Source table |
| `record_id` | bigint | Source record |
| `field_name` | varchar | Translated field |
| `language` | varchar(5) | Language code |
| `translation` | text | Translated text |
| `is_verified` | boolean | Human verified |

---

## 🔧 SQL Functions

```sql
-- Function: Audit trigger
CREATE OR REPLACE FUNCTION menuca_v3.audit_trigger_func()
RETURNS trigger
```

```sql
-- Function: Set updated_at
CREATE OR REPLACE FUNCTION menuca_v3.set_updated_at()
RETURNS trigger
```

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| - | - | System functions internal |

---

## 📇 Indexes

| Index | Table | Columns |
|-------|-------|---------|
| `idx_audit_table_record` | audit_log | `table_name, record_id` |
| `idx_audit_changed_at` | audit_log | `changed_at DESC` |
| `idx_translations_lookup` | translations | `table_name, record_id, language` |

---

## 🔒 RLS Policies

| Policy | Operation | Description |
|--------|-----------|-------------|
| `audit_service_role_only` | ALL | Service role only |
| `config_service_role_only` | ALL | Service role only |

---

## ⚙️ Triggers

| Trigger | Table | Description |
|---------|-------|-------------|
| `audit_trigger` | * (many tables) | Logs changes |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason |
|------|--------------|--------|
| - | - | None |

---

## ✨ New Functionalities

| Date | Functionality | Status |
|------|--------------|--------|
| - | Partitioned audit logs | Complete |

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
| Audit Partitions | 24 |

---

**Last Updated:** 2025-11-27

