# 02 - Delivery & Zones Entity

> **Scheduling & Delivery Management** - When and where restaurants can serve

---

## 📋 Purpose

The Delivery & Zones Entity manages all aspects of **delivery availability**:
- **When** restaurants can accept orders (schedules, operating hours)
- **Where** restaurants can deliver (zones, areas, distances)
- **How** delivery is handled (partners, fees, configurations)

**Key Responsibilities:**
- Operating hours and schedule management
- Special/holiday schedule handling
- Delivery zone definitions and boundaries
- Delivery fee calculations
- Delivery partner integrations

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

### Scheduling Tables

#### `restaurant_schedules`
**Purpose:** Regular operating hours

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `day_of_week` | integer | NO | - | 0=Sunday, 6=Saturday |
| `open_time` | time | NO | - | Opening time |
| `close_time` | time | NO | - | Closing time |
| `is_closed` | boolean | NO | false | Closed this day |
| `delivery_open_time` | time | YES | - | Delivery start time |
| `delivery_close_time` | time | YES | - | Delivery end time |
| `takeout_open_time` | time | YES | - | Takeout start time |
| `takeout_close_time` | time | YES | - | Takeout end time |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `restaurant_special_schedules`
**Purpose:** Holiday and exception hours

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `date` | date | NO | - | Specific date |
| `is_closed` | boolean | NO | false | Closed on this date |
| `open_time` | time | YES | - | Special opening time |
| `close_time` | time | YES | - | Special closing time |
| `reason` | varchar | YES | - | Reason for special hours |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_time_periods`
**Purpose:** Time slot definitions for ordering

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `name` | varchar | NO | - | Period name (Lunch, Dinner) |
| `start_time` | time | NO | - | Period start |
| `end_time` | time | NO | - | Period end |
| `days_of_week` | integer[] | YES | - | Active days |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_partner_schedules`
**Purpose:** Delivery partner availability

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `partner_name` | varchar | NO | - | Partner identifier |
| `day_of_week` | integer | NO | - | 0=Sunday, 6=Saturday |
| `start_time` | time | NO | - | Partner available from |
| `end_time` | time | NO | - | Partner available until |
| `is_active` | boolean | NO | true | Currently active |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `schedule_translations`
**Purpose:** Multi-language schedule labels

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | bigint | NO | Primary key |
| `schedule_id` | bigint | NO | FK to schedule record |
| `language` | varchar(5) | NO | Language code (en/fr) |
| `label` | varchar | YES | Translated label |

---

### Delivery Zone Tables

#### `restaurant_delivery_zones`
**Purpose:** Delivery zone definitions

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `uuid` | uuid | NO | gen_random_uuid() | External identifier |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `zone_name` | varchar | NO | - | Zone display name |
| `zone_type` | varchar | YES | - | Type (radius, polygon, postal) |
| `delivery_fee` | numeric(10,2) | YES | 0 | Delivery fee |
| `minimum_order` | numeric(10,2) | YES | 0 | Minimum order amount |
| `estimated_time_minutes` | integer | YES | - | Estimated delivery time |
| `is_active` | boolean | NO | true | Zone is active |
| `priority` | integer | YES | 0 | Zone priority/order |
| `polygon_coordinates` | jsonb | YES | - | Polygon boundary points |
| `radius_km` | numeric(6,2) | YES | - | Radius in kilometers |
| `center_lat` | numeric(13,10) | YES | - | Center latitude |
| `center_lng` | numeric(13,10) | YES | - | Center longitude |
| `postal_codes` | text[] | YES | - | Array of postal codes |
| `created_at` | timestamptz | NO | now() | Creation timestamp |
| `created_by` | bigint | YES | - | Admin who created |
| `updated_at` | timestamptz | YES | - | Last update timestamp |
| `updated_by` | bigint | YES | - | Admin who updated |
| `deleted_at` | timestamptz | YES | - | Soft delete timestamp |
| `deleted_by` | bigint | YES | - | Admin who deleted |

---

#### `restaurant_delivery_areas`
**Purpose:** Detailed delivery area configurations

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `area_name` | varchar | YES | - | Area display name |
| `area_type` | varchar | YES | - | Type classification |
| `boundary_geojson` | jsonb | YES | - | GeoJSON boundary |
| `delivery_fee_cents` | integer | YES | 0 | Fee in cents |
| `minimum_order_cents` | integer | YES | 0 | Minimum in cents |
| `is_active` | boolean | NO | true | Area is active |
| `legacy_v1_id` | integer | YES | - | Migration reference |
| `legacy_v2_id` | integer | YES | - | Migration reference |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_delivery_companies`
**Purpose:** Delivery service providers

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `company_name` | varchar | NO | - | Company name |
| `company_email_id` | bigint | YES | - | FK to delivery_company_emails |
| `is_active` | boolean | NO | true | Currently active |
| `priority` | integer | YES | 0 | Selection priority |
| `api_credentials` | jsonb | YES | - | API integration credentials |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

#### `restaurant_delivery_fees`
**Purpose:** Detailed fee structures

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `restaurant_id` | bigint | NO | - | FK to restaurants |
| `company_email_id` | bigint | YES | - | FK to delivery_company_emails |
| `distance_from_km` | numeric | YES | - | Distance range start |
| `distance_to_km` | numeric | YES | - | Distance range end |
| `fee_amount` | numeric(10,2) | NO | - | Fee amount |
| `fee_type` | varchar | YES | 'flat' | flat or percentage |
| `is_active` | boolean | NO | true | Currently active |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

### Supporting Tables

#### `delivery_company_emails`
**Purpose:** Delivery service contact information

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | bigint | NO | identity | Primary key |
| `company_name` | varchar | NO | - | Company name |
| `email` | varchar | NO | - | Contact email |
| `phone` | varchar | YES | - | Contact phone |
| `is_active` | boolean | NO | true | Currently active |
| `created_at` | timestamptz | NO | now() | Creation timestamp |

---

## 🔧 SQL Functions

### Schedule Validation

```sql
-- Function: Check if restaurant is currently open
CREATE OR REPLACE FUNCTION menuca_v3.is_restaurant_open(
    p_restaurant_id bigint,
    p_timestamp timestamptz DEFAULT NOW()
)
RETURNS boolean
```

```sql
-- Function: Get next available order time
CREATE OR REPLACE FUNCTION menuca_v3.get_next_available_time(
    p_restaurant_id bigint,
    p_service_type varchar DEFAULT 'delivery'
)
RETURNS timestamptz
```

### Delivery Zone Validation

```sql
-- Function: Check if address is in delivery zone
CREATE OR REPLACE FUNCTION menuca_v3.is_address_deliverable(
    p_restaurant_id bigint,
    p_latitude numeric,
    p_longitude numeric
)
RETURNS TABLE(
    is_deliverable boolean,
    zone_id bigint,
    delivery_fee numeric,
    minimum_order numeric,
    estimated_time integer
)
```

```sql
-- Function: Calculate delivery fee for address
CREATE OR REPLACE FUNCTION menuca_v3.calculate_delivery_fee(
    p_restaurant_id bigint,
    p_latitude numeric,
    p_longitude numeric
)
RETURNS numeric
```

**TODO:** Document all SQL functions after database query

---

## ⚡ Edge Functions

| Function Name | Endpoint | Purpose |
|--------------|----------|---------|
| - | - | No dedicated Edge Functions yet |

**TODO:** Document Edge Functions when created

---

## 📇 Indexes

### `restaurant_schedules` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurant_schedules_pkey` | `id` | PRIMARY KEY | - |
| `idx_schedules_restaurant` | `restaurant_id` | BTREE | - |
| `idx_schedules_day` | `restaurant_id, day_of_week` | BTREE | - |

### `restaurant_delivery_zones` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurant_delivery_zones_pkey` | `id` | PRIMARY KEY | - |
| `idx_delivery_zones_restaurant` | `restaurant_id` | BTREE | - |
| `idx_delivery_zones_active` | `restaurant_id, is_active` | BTREE | `is_active = true` |

### `restaurant_delivery_areas` Table Indexes

| Index Name | Columns | Type | Condition |
|------------|---------|------|-----------|
| `restaurant_delivery_areas_pkey` | `id` | PRIMARY KEY | - |
| `idx_delivery_areas_restaurant` | `restaurant_id` | BTREE | - |

---

## 🔒 RLS Policies

### `restaurant_schedules` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `schedules_public_read` | SELECT | anon, authenticated | Public can read schedules |
| `schedules_select_restaurant_admin` | SELECT | authenticated | Admin can select their schedules |
| `schedules_insert_restaurant_admin` | INSERT | authenticated | Admin can create schedules |
| `schedules_update_restaurant_admin` | UPDATE | authenticated | Admin can update schedules |
| `schedules_delete_restaurant_admin` | DELETE | authenticated | Admin can delete schedules |

### `restaurant_delivery_zones` Table Policies

| Policy Name | Operation | Roles | Description |
|-------------|-----------|-------|-------------|
| `zones_public_read` | SELECT | anon, authenticated | Public can read active zones |
| `zones_admin_manage` | ALL | authenticated | Admin full access to their zones |
| `zones_service_role` | ALL | service_role | Service role full access |

---

## ⚙️ Triggers

### `restaurant_schedules` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `trg_schedules_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |
| `notify_schedule_change` | INSERT, UPDATE, DELETE | AFTER | `notify_schedule_change()` | Real-time notification |

### `restaurant_delivery_zones` Table Triggers

| Trigger Name | Event | Timing | Function | Description |
|--------------|-------|--------|----------|-------------|
| `trg_zones_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

---

## 🗑️ Removed Functionalities

| Date | Functionality | Reason | Migration Notes |
|------|--------------|--------|-----------------|
| - | - | - | No removed functionalities yet |

---

## ✨ New Functionalities

| Date | Functionality | Status | Notes |
|------|--------------|--------|-------|
| - | V1 Delivery Zones Migration | In Progress | Migrating legacy V1 delivery zones |
| - | V2 Delivery Areas Migration | In Progress | Migrating legacy V2 delivery areas |

---

## 🔧 Schema Fixes Applied

| Date | Fix Description | SQL Applied | Impact |
|------|-----------------|-------------|--------|
| - | - | - | No fixes applied yet |

---

## 📈 Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 9 |
| Total Schedules | ~1,750 (7 days × 250 restaurants) |
| Total Delivery Zones | ~175 |
| Total Delivery Areas | ~90 |

---

## 🔗 Related Entities

- **Restaurant Entity** → Parent relationship via `restaurant_id`
- **Order Entity** → Validates delivery eligibility
- **User Entity** → Validates user addresses against zones
- **Geography Entity** → Uses cities/provinces for location data

---

**Last Updated:** 2025-11-27

