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

- [Tables](#-tables)
- [SQL Functions](#-sql-functions)
- [Edge Functions](#-edge-functions)
- [Indexes](#-indexes)
- [RLS Policies](#-rls-policies)
- [Triggers](#-triggers)
- [Removed Functionalities](#️-removed-functionalities)
- [New Functionalities](#-new-functionalities)
- [Schema Fixes Applied](#-schema-fixes-applied)
- [Statistics](#-statistics)
- [Related Entities](#-related-entities)

---

## 📊 Tables

### Scheduling Tables

#### `restaurant_schedules`

**Purpose:** Regular operating hours (delivery, takeout, dine-in)  
**Row Count:** 1,735

| Column          | Type        | Nullable | Default            | Description                              |
| --------------- | ----------- | -------- | ------------------ | ---------------------------------------- |
| `id`            | bigint      | NO       | identity           | Primary key                              |
| `uuid`          | uuid        | NO       | uuid_generate_v4() | External identifier                      |
| `restaurant_id` | bigint      | NO       | -                  | FK to restaurants                        |
| `type`          | enum        | NO       | -                  | Schedule type (delivery/takeout/dine_in) |
| `day_start`     | smallint    | NO       | -                  | Start day (1-7, Mon-Sun)                 |
| `day_stop`      | smallint    | NO       | -                  | End day (1-7, Mon-Sun)                   |
| `time_start`    | time        | NO       | -                  | Opening time                             |
| `time_stop`     | time        | NO       | -                  | Closing time                             |
| `is_enabled`    | boolean     | NO       | true               | Schedule is active                       |
| `created_at`    | timestamptz | NO       | now()              | Creation timestamp                       |
| `created_by`    | integer     | YES      | -                  | Admin who created                        |
| `updated_at`    | timestamptz | YES      | -                  | Last update timestamp                    |
| `updated_by`    | integer     | YES      | -                  | Admin who updated                        |
| `deleted_at`    | timestamptz | YES      | -                  | Soft delete timestamp                    |
| `deleted_by`    | bigint      | YES      | -                  | Admin who deleted                        |

---

#### `restaurant_special_schedules`

**Purpose:** Holiday and exception hours  
**Row Count:** 24

| Column          | Type        | Nullable | Default            | Description              |
| --------------- | ----------- | -------- | ------------------ | ------------------------ |
| `id`            | bigint      | NO       | identity           | Primary key              |
| `uuid`          | uuid        | NO       | uuid_generate_v4() | External identifier      |
| `restaurant_id` | bigint      | NO       | -                  | FK to restaurants        |
| `date`          | date        | NO       | -                  | Specific date            |
| `is_closed`     | boolean     | NO       | false              | Closed on this date      |
| `open_time`     | time        | YES      | -                  | Special opening time     |
| `close_time`    | time        | YES      | -                  | Special closing time     |
| `reason`        | varchar     | YES      | -                  | Reason for special hours |
| `created_at`    | timestamptz | NO       | now()              | Creation timestamp       |
| `updated_at`    | timestamptz | YES      | -                  | Last update timestamp    |

---

#### `restaurant_time_periods`

**Purpose:** Time slot definitions for ordering (Lunch, Dinner, etc.)  
**Row Count:** 3

| Column          | Type        | Nullable | Default  | Description                 |
| --------------- | ----------- | -------- | -------- | --------------------------- |
| `id`            | bigint      | NO       | identity | Primary key                 |
| `restaurant_id` | bigint      | NO       | -        | FK to restaurants           |
| `name`          | varchar     | NO       | -        | Period name (Lunch, Dinner) |
| `start_time`    | time        | NO       | -        | Period start                |
| `end_time`      | time        | NO       | -        | Period end                  |
| `days_of_week`  | integer[]   | YES      | -        | Active days                 |
| `created_at`    | timestamptz | NO       | now()    | Creation timestamp          |

---

#### `restaurant_partner_schedules`

**Purpose:** Delivery partner availability  
**Row Count:** 7

| Column          | Type        | Nullable | Default  | Description             |
| --------------- | ----------- | -------- | -------- | ----------------------- |
| `id`            | bigint      | NO       | identity | Primary key             |
| `restaurant_id` | bigint      | NO       | -        | FK to restaurants       |
| `partner_name`  | varchar     | NO       | -        | Partner identifier      |
| `day_of_week`   | integer     | NO       | -        | 0=Sunday, 6=Saturday    |
| `start_time`    | time        | NO       | -        | Partner available from  |
| `end_time`      | time        | NO       | -        | Partner available until |
| `is_active`     | boolean     | NO       | true     | Currently active        |
| `legacy_v2_id`  | integer     | YES      | -        | Migration reference     |
| `created_at`    | timestamptz | NO       | now()    | Creation timestamp      |
| `updated_at`    | timestamptz | YES      | -        | Last update timestamp   |

---

#### `schedule_translations`

**Purpose:** Multi-language schedule labels  
**Row Count:** 30

| Column        | Type       | Nullable | Description           |
| ------------- | ---------- | -------- | --------------------- |
| `id`          | bigint     | NO       | Primary key           |
| `schedule_id` | bigint     | NO       | FK to schedule record |
| `language`    | varchar(5) | NO       | Language code (en/fr) |
| `label`       | varchar    | YES      | Translated label      |

---

### Delivery Zone Tables

#### `restaurant_delivery_areas`

**Purpose:** Delivery area configurations with PostGIS geometry  
**Row Count:** 201  
**Primary Table:** This is the main delivery zone table for all restaurants

| Column                       | Type                   | Nullable | Default            | Description                           |
| ---------------------------- | ---------------------- | -------- | ------------------ | ------------------------------------- |
| `id`                         | bigint                 | NO       | identity           | Primary key                           |
| `uuid`                       | uuid                   | NO       | uuid_generate_v4() | External identifier                   |
| `restaurant_id`              | bigint                 | NO       | -                  | FK to restaurants                     |
| `area_number`                | integer                | NO       | -                  | Area sequence number                  |
| `area_name`                  | varchar                | YES      | -                  | Area display name                     |
| `delivery_fee`               | numeric                | YES      | -                  | Delivery fee amount (84% populated)   |
| `min_order_value`            | numeric                | YES      | -                  | Minimum order amount (100% populated) |
| `geometry`                   | geometry(Polygon,4326) | NO       | -                  | PostGIS polygon boundary              |
| `is_active`                  | boolean                | NO       | true               | Area is active                        |
| `created_at`                 | timestamptz            | NO       | now()              | Creation timestamp                    |
| `created_by`                 | bigint                 | YES      | -                  | FK to admin_users                     |
| `updated_at`                 | timestamptz            | YES      | -                  | Last update timestamp                 |
| `updated_by`                 | bigint                 | YES      | -                  | FK to admin_users                     |
| `deleted_at`                 | timestamptz            | YES      | -                  | Soft delete timestamp                 |
| `deleted_by`                 | bigint                 | YES      | -                  | FK to admin_users                     |
| `estimated_delivery_minutes` | integer                | YES      | -                  | Estimated delivery time               |

**Constraints:**

- `delivery_areas_positive_minutes`: `estimated_delivery_minutes IS NULL OR estimated_delivery_minutes > 0`
- FK constraints on `created_by`, `updated_by`, `deleted_by` → `admin_users(id)`

**Data Population Status:**

- `delivery_fee`: 169/201 populated (84%), 31 restaurants need manual entry
- `min_order_value`: 201/201 populated (100%)

---

#### `restaurant_delivery_config`

**Purpose:** Restaurant-level delivery configuration  
**Row Count:** 185

| Column                       | Type        | Nullable | Default            | Description                  |
| ---------------------------- | ----------- | -------- | ------------------ | ---------------------------- |
| `id`                         | bigint      | NO       | identity           | Primary key                  |
| `uuid`                       | uuid        | NO       | uuid_generate_v4() | External identifier          |
| `restaurant_id`              | bigint      | NO       | -                  | FK to restaurants            |
| `use_multiple_areas`         | boolean     | YES      | false              | Use multiple delivery areas  |
| `max_delivery_distance_km`   | smallint    | YES      | -                  | Maximum delivery distance    |
| `active_partners`            | jsonb       | YES      | -                  | Active delivery partners     |
| `partner_credentials`        | jsonb       | YES      | -                  | Partner API credentials      |
| `disable_delivery_until`     | timestamptz | YES      | -                  | Temporarily disable delivery |
| `legacy_v1_send_to_delivery` | boolean     | YES      | -                  | V1 migration flag            |
| `legacy_v1_twilio_call`      | boolean     | YES      | -                  | V1 Twilio integration flag   |
| `restaurant_delivery_charge` | numeric     | YES      | -                  | Restaurant's delivery charge |
| `delivery_service_extra`     | numeric     | YES      | -                  | Extra service fee            |
| `created_at`                 | timestamptz | NO       | now()              | Creation timestamp           |
| `created_by`                 | integer     | YES      | -                  | Admin who created            |
| `updated_at`                 | timestamptz | YES      | -                  | Last update timestamp        |
| `updated_by`                 | integer     | YES      | -                  | Admin who updated            |

---

#### `restaurant_delivery_companies`

**Purpose:** Delivery service providers per restaurant  
**Row Count:** 15

| Column             | Type        | Nullable | Default  | Description                   |
| ------------------ | ----------- | -------- | -------- | ----------------------------- |
| `id`               | bigint      | NO       | identity | Primary key                   |
| `restaurant_id`    | bigint      | NO       | -        | FK to restaurants             |
| `company_name`     | varchar     | NO       | -        | Company name                  |
| `company_email_id` | bigint      | YES      | -        | FK to delivery_company_emails |
| `is_active`        | boolean     | NO       | true     | Currently active              |
| `priority`         | integer     | YES      | 0        | Selection priority            |
| `api_credentials`  | jsonb       | YES      | -        | API integration credentials   |
| `created_at`       | timestamptz | NO       | now()    | Creation timestamp            |
| `updated_at`       | timestamptz | YES      | -        | Last update timestamp         |

---

#### `restaurant_delivery_fees`

**Purpose:** Distance-based tier fee structures (for delivery company accounting)  
**Row Count:** 294

| Column               | Type        | Nullable | Default            | Description                   |
| -------------------- | ----------- | -------- | ------------------ | ----------------------------- |
| `id`                 | bigint      | NO       | identity           | Primary key                   |
| `uuid`               | uuid        | NO       | uuid_generate_v4() | External identifier           |
| `legacy_v1_id`       | integer     | YES      | -                  | V1 migration reference        |
| `legacy_source`      | varchar     | YES      | -                  | Source of legacy data         |
| `restaurant_id`      | bigint      | NO       | -                  | FK to restaurants             |
| `company_email_id`   | smallint    | YES      | -                  | FK to delivery_company_emails |
| `fee_type`           | varchar     | NO       | -                  | Fee type (distance)           |
| `tier_value`         | smallint    | NO       | -                  | Distance tier (1-10)          |
| `total_delivery_fee` | numeric     | YES      | -                  | Total fee charged             |
| `driver_earning`     | numeric     | YES      | -                  | Driver's portion              |
| `restaurant_pays`    | numeric     | YES      | -                  | Restaurant's portion          |
| `vendor_pays`        | numeric     | YES      | -                  | Vendor's portion              |
| `notes`              | text        | YES      | -                  | Admin notes                   |
| `is_active`          | boolean     | YES      | -                  | Currently active              |
| `created_at`         | timestamptz | NO       | now()              | Creation timestamp            |
| `created_by`         | integer     | YES      | -                  | Admin who created             |
| `updated_at`         | timestamptz | YES      | -                  | Last update timestamp         |
| `updated_by`         | integer     | YES      | -                  | Admin who updated             |

**Note:** This table is used for distance-based delivery fee accounting with delivery companies, separate from polygon-based delivery areas.

---

### Supporting Tables

#### `delivery_company_emails`

**Purpose:** Delivery service contact information  
**Row Count:** 9

| Column         | Type        | Nullable | Default  | Description            |
| -------------- | ----------- | -------- | -------- | ---------------------- |
| `id`           | bigint      | NO       | identity | Primary key            |
| `company_name` | varchar     | NO       | -        | Company name           |
| `email`        | varchar     | NO       | -        | Contact email (unique) |
| `phone`        | varchar     | YES      | -        | Contact phone          |
| `is_active`    | boolean     | NO       | true     | Currently active       |
| `created_at`   | timestamptz | NO       | now()    | Creation timestamp     |
| `updated_at`   | timestamptz | YES      | -        | Last update timestamp  |

---

#### `user_delivery_addresses`

**Purpose:** Customer saved delivery addresses  
**Row Count:** (user data)

| Column                  | Type        | Nullable | Default  | Description              |
| ----------------------- | ----------- | -------- | -------- | ------------------------ |
| `id`                    | bigint      | NO       | identity | Primary key              |
| `user_id`               | bigint      | NO       | -        | FK to users              |
| `address_label`         | varchar     | YES      | -        | Label (Home, Work, etc.) |
| `street_address`        | varchar     | NO       | -        | Street address           |
| `unit`                  | varchar     | YES      | -        | Unit/apartment number    |
| `city_id`               | bigint      | YES      | -        | FK to cities             |
| `postal_code`           | varchar     | NO       | -        | Postal code              |
| `latitude`              | numeric     | YES      | -        | Address latitude         |
| `longitude`             | numeric     | YES      | -        | Address longitude        |
| `delivery_instructions` | text        | YES      | -        | Special instructions     |
| `is_default`            | boolean     | NO       | false    | Default address          |
| `created_at`            | timestamptz | NO       | now()    | Creation timestamp       |
| `updated_at`            | timestamptz | NO       | -        | Last update timestamp    |

---

### Views

#### `v_midnight_crossing_schedules`

**Purpose:** Identifies schedules that cross midnight

#### `v_schedule_conflicts`

**Purpose:** Identifies overlapping schedule entries

#### `v_schedule_coverage`

**Purpose:** Shows schedule coverage gaps

---

## 🔧 SQL Functions

### Schedule Functions

| Function Name                              | Purpose                                  |
| ------------------------------------------ | ---------------------------------------- |
| `get_restaurant_schedule(p_restaurant_id)` | Get complete schedule for a restaurant   |
| `check_schedule_overlap(...)`              | Check if schedule overlaps with existing |
| `has_schedule_conflict(...)`               | Validate schedule doesn't conflict       |
| `clone_schedule_to_day(...)`               | Copy schedule from one day to another    |
| `bulk_copy_schedule_onboarding(...)`       | Bulk copy schedules during onboarding    |
| `bulk_toggle_schedules(...)`               | Enable/disable multiple schedules        |
| `apply_schedule_template_onboarding(...)`  | Apply schedule template                  |
| `get_upcoming_schedule_changes(...)`       | Get pending schedule changes             |
| `notify_schedule_change()`                 | Trigger function for real-time updates   |
| `soft_delete_schedule(...)`                | Soft delete a schedule                   |
| `restore_schedule(...)`                    | Restore a soft-deleted schedule          |
| `validate_timezone(...)`                   | Validate timezone string                 |

### Delivery Zone Functions

| Function Name                           | Purpose                                                                |
| --------------------------------------- | ---------------------------------------------------------------------- |
| `create_delivery_zone(...)`             | Create a new delivery zone from polygon coordinates                    |
| `create_delivery_zone_onboarding(...)`  | Create zone during onboarding (radius-based, creates circular polygon) |
| `update_delivery_zone(...)`             | Update existing delivery zone                                          |
| `soft_delete_delivery_zone(...)`        | Soft delete a delivery zone                                            |
| `restore_delivery_zone(...)`            | Restore a soft-deleted zone                                            |
| `toggle_delivery_zone_status(...)`      | Enable/disable delivery zone                                           |
| `is_address_in_delivery_zone(...)`      | Check if address is within zone                                        |
| `get_delivery_zone_area_sq_km(...)`     | Calculate zone area in sq km                                           |
| `get_restaurant_delivery_summary(...)`  | Get delivery configuration summary                                     |
| `find_nearby_restaurants(...)`          | Find restaurants near a location                                       |
| `find_nearest_franchise_locations(...)` | Find franchise locations that can deliver                              |

---

## ⚡ Edge Functions

| Function Name          | Endpoint                     | Purpose                                      |
| ---------------------- | ---------------------------- | -------------------------------------------- |
| `create-delivery-zone` | POST /create-delivery-zone   | Create delivery zone via API (polygon-based) |
| `update-delivery-zone` | POST /update-delivery-zone   | Update delivery zone via API                 |
| `delete-delivery-zone` | DELETE /delete-delivery-zone | Soft delete delivery zone via API            |

---

## 📇 Indexes

### `restaurant_schedules` Table Indexes

| Index Name                                    | Columns                          | Type        | Notes                    |
| --------------------------------------------- | -------------------------------- | ----------- | ------------------------ |
| `restaurant_schedules_pkey`                   | `id`                             | PRIMARY KEY | -                        |
| `restaurant_schedules_uuid_key`               | `uuid`                           | UNIQUE      | -                        |
| `u_sched_restaurant_service_day`              | `restaurant_id, type, day_start` | UNIQUE      | Prevent duplicates       |
| `idx_schedules_restaurant`                    | `restaurant_id`                  | BTREE       | -                        |
| `idx_schedules_restaurant_type`               | `restaurant_id, type`            | BTREE       | -                        |
| `idx_schedules_enabled`                       | `is_enabled`                     | BTREE       | -                        |
| `idx_restaurant_schedules_deleted`            | `deleted_at`                     | BTREE       | -                        |
| `idx_restaurant_schedules_soft_delete_active` | `restaurant_id`                  | BTREE       | WHERE deleted_at IS NULL |

### `restaurant_delivery_areas` Table Indexes

| Index Name                              | Columns                      | Type        | Notes                                         |
| --------------------------------------- | ---------------------------- | ----------- | --------------------------------------------- |
| `restaurant_delivery_areas_pkey`        | `id`                         | PRIMARY KEY | -                                             |
| `u_restaurant_area`                     | `restaurant_id, area_number` | UNIQUE      | Prevent duplicates                            |
| `idx_delivery_areas_restaurant`         | `restaurant_id`              | BTREE       | -                                             |
| `idx_delivery_areas_area_number`        | `area_number`                | BTREE       | -                                             |
| `idx_delivery_areas_geometry`           | `geometry`                   | GIST        | Spatial index                                 |
| `idx_delivery_areas_deleted`            | `deleted_at`                 | BTREE       | WHERE deleted_at IS NOT NULL                  |
| `idx_delivery_areas_active_not_deleted` | `restaurant_id, is_active`   | BTREE       | WHERE deleted_at IS NULL AND is_active = true |

### `restaurant_delivery_config` Table Indexes

| Index Name                        | Columns           | Type        | Notes                     |
| --------------------------------- | ----------------- | ----------- | ------------------------- |
| `restaurant_delivery_config_pkey` | `id`              | PRIMARY KEY | -                         |
| `u_restaurant_delivery_config`    | `restaurant_id`   | UNIQUE      | One config per restaurant |
| `idx_delivery_config_restaurant`  | `restaurant_id`   | BTREE       | -                         |
| `idx_delivery_config_partners`    | `active_partners` | GIN         | JSONB index               |

---

## 🔒 RLS Policies

### `restaurant_schedules` Table Policies

| Policy Name                         | Operation | Roles               | Description                      |
| ----------------------------------- | --------- | ------------------- | -------------------------------- |
| `public_view_schedules`             | SELECT    | public              | Public can read schedules        |
| `restaurant_schedules_public_read`  | SELECT    | anon, authenticated | Public can read schedules        |
| `schedules_select_restaurant_admin` | SELECT    | authenticated       | Admin can select their schedules |
| `schedules_insert_restaurant_admin` | INSERT    | authenticated       | Admin can create schedules       |
| `schedules_update_restaurant_admin` | UPDATE    | authenticated       | Admin can update schedules       |
| `schedules_delete_restaurant_admin` | DELETE    | authenticated       | Admin can delete schedules       |
| `schedules_service_role_all`        | ALL       | service_role        | Service role full access         |

### `restaurant_special_schedules` Table Policies

| Policy Name                                 | Operation | Roles         | Description                       |
| ------------------------------------------- | --------- | ------------- | --------------------------------- |
| `public_read_special_schedules`             | SELECT    | public        | Public can read special schedules |
| `special_schedules_select_restaurant_admin` | SELECT    | authenticated | Admin can select                  |
| `special_schedules_insert_restaurant_admin` | INSERT    | authenticated | Admin can create                  |
| `special_schedules_update_restaurant_admin` | UPDATE    | authenticated | Admin can update                  |
| `special_schedules_delete_restaurant_admin` | DELETE    | authenticated | Admin can delete                  |
| `special_schedules_service_role_all`        | ALL       | service_role  | Service role full access          |

### `restaurant_delivery_areas` Table Policies

| Policy Name                              | Operation | Roles         | Description              |
| ---------------------------------------- | --------- | ------------- | ------------------------ |
| `public_view_delivery_areas`             | SELECT    | public        | Public can read areas    |
| `delivery_areas_manage_restaurant_admin` | ALL       | authenticated | Admin full access        |
| `delivery_areas_service_role_all`        | ALL       | service_role  | Service role full access |

### `restaurant_delivery_config` Table Policies

| Policy Name                               | Operation | Roles         | Description              |
| ----------------------------------------- | --------- | ------------- | ------------------------ |
| `delivery_config_manage_restaurant_admin` | ALL       | authenticated | Admin full access        |
| `delivery_config_service_role_all`        | ALL       | service_role  | Service role full access |

### `user_delivery_addresses` Table Policies

| Policy Name                  | Operation | Roles         | Description                    |
| ---------------------------- | --------- | ------------- | ------------------------------ |
| `addresses_select_own`       | SELECT    | authenticated | Users can read own addresses   |
| `addresses_insert_own`       | INSERT    | authenticated | Users can create addresses     |
| `addresses_update_own`       | UPDATE    | authenticated | Users can update own addresses |
| `addresses_delete_own`       | DELETE    | authenticated | Users can delete own addresses |
| `addresses_service_role_all` | ALL       | service_role  | Service role full access       |

---

## ⚙️ Triggers

### `restaurant_schedules` Table Triggers

| Trigger Name                          | Event                  | Timing | Function                   | Description                   |
| ------------------------------------- | ---------------------- | ------ | -------------------------- | ----------------------------- |
| `trg_schedules_updated_at`            | UPDATE                 | BEFORE | `set_updated_at()`         | Auto-update timestamp         |
| `trg_restaurant_schedules_no_overlap` | INSERT, UPDATE         | BEFORE | `check_schedule_overlap()` | Prevent overlapping schedules |
| `notify_schedules_change`             | INSERT, UPDATE, DELETE | AFTER  | `notify_schedule_change()` | Real-time notification        |

### `restaurant_special_schedules` Table Triggers

| Trigger Name                       | Event                  | Timing | Function                   | Description            |
| ---------------------------------- | ---------------------- | ------ | -------------------------- | ---------------------- |
| `trg_special_schedules_updated_at` | UPDATE                 | BEFORE | `set_updated_at()`         | Auto-update timestamp  |
| `notify_special_schedules_change`  | INSERT, UPDATE, DELETE | AFTER  | `notify_schedule_change()` | Real-time notification |

### `restaurant_delivery_areas` Table Triggers

| Trigger Name                    | Event  | Timing | Function           | Description           |
| ------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_delivery_areas_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `restaurant_delivery_config` Table Triggers

| Trigger Name                     | Event  | Timing | Function           | Description           |
| -------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_delivery_config_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `restaurant_delivery_companies` Table Triggers

| Trigger Name                                   | Event  | Timing | Function           | Description           |
| ---------------------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_restaurant_delivery_companies_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `restaurant_delivery_fees` Table Triggers

| Trigger Name                              | Event  | Timing | Function           | Description           |
| ----------------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_restaurant_delivery_fees_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `restaurant_partner_schedules` Table Triggers

| Trigger Name                                  | Event  | Timing | Function           | Description           |
| --------------------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_restaurant_partner_schedules_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `delivery_company_emails` Table Triggers

| Trigger Name                             | Event  | Timing | Function           | Description           |
| ---------------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_delivery_company_emails_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

---

## 🗑️ Removed Functionalities

| Date       | Functionality                     | Reason                                        | Migration Notes                                                                                                                                        |
| ---------- | --------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2025-11-27 | `restaurant_delivery_zones` table | Consolidated into `restaurant_delivery_areas` | All delivery zone functionality now uses `restaurant_delivery_areas`. The 2 rows in `restaurant_delivery_zones` were not migrated as per user request. |
| 2025-11-27 | `display_name` column             | Duplicate of `area_name`                      | Removed from `restaurant_delivery_areas`. One record's display_name was preserved by updating area_name.                                               |
| 2025-11-27 | `legacy_v2_id` column             | Never used (0% populated)                     | Removed from `restaurant_delivery_areas` along with its unique constraint.                                                                             |
| 2025-11-27 | `is_complex` column               | Redundant (all values false)                  | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `conditional_fee` column          | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `conditional_threshold` column    | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `notes` column                    | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `coordinates` column              | Redundant with `geometry`                     | Removed - geometry is the source of truth for polygon data.                                                                                            |
| 2025-11-27 | `fee_type` column                 | Simplified schema                             | Removed from `restaurant_delivery_areas` - fee type can be inferred from delivery_fee value.                                                           |

---

## ✨ New Functionalities

| Date       | Functionality                  | Status      | Notes                                                                                                                   |
| ---------- | ------------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| 2025-11-27 | V1/V2 Delivery Areas Migration | ✅ Complete | 201 delivery areas migrated to `restaurant_delivery_areas`                                                              |
| 2025-11-27 | Soft Delete Support            | ✅ Complete | Added `deleted_at`, `deleted_by` columns with FK to `admin_users`                                                       |
| 2025-11-27 | Estimated Delivery Time        | ✅ Complete | Added `estimated_delivery_minutes` column                                                                               |
| 2025-11-27 | Consolidated Delivery Zones    | ✅ Complete | All delivery zone operations now use `restaurant_delivery_areas` exclusively                                            |
| 2025-11-27 | Data Population                | ✅ Complete | `delivery_fee` populated from `restaurant_delivery_fees`, `min_order_value` populated from `restaurant_service_configs` |

---

## 🔧 Schema Fixes Applied

| Date       | Fix Description                        | SQL Applied                                                                                                                | Impact                                                      |
| ---------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| 2025-11-27 | Made `geometry` NOT NULL               | `ALTER COLUMN geometry SET NOT NULL`                                                                                       | Ensures all areas have valid polygons                       |
| 2025-11-27 | Made `is_active` NOT NULL with default | `ALTER COLUMN is_active SET NOT NULL, SET DEFAULT true`                                                                    | Consistent active state                                     |
| 2025-11-27 | Added FK constraints for audit columns | `ADD CONSTRAINT ... FOREIGN KEY ... REFERENCES admin_users(id)`                                                            | Data integrity for `created_by`, `updated_by`, `deleted_by` |
| 2025-11-27 | Added soft delete indexes              | `CREATE INDEX idx_delivery_areas_deleted`, `idx_delivery_areas_active_not_deleted`                                         | Query performance for soft delete queries                   |
| 2025-11-27 | Removed 9 unused columns               | `DROP COLUMN legacy_v2_id, is_complex, conditional_fee, conditional_threshold, notes, coordinates, fee_type, display_name` | Schema cleanup - reduced from 24 to 16 columns              |
| 2025-11-27 | Populated `delivery_fee`               | `UPDATE ... SET delivery_fee = total_delivery_fee FROM restaurant_delivery_fees`                                           | 81 rows populated from tier-based fees                      |
| 2025-11-27 | Populated `min_order_value`            | `UPDATE ... SET min_order_value = delivery_min_order FROM restaurant_service_configs`                                      | 164 rows populated, then 15 more manually                   |

---

## 📈 Statistics

| Metric                            | Value                      |
| --------------------------------- | -------------------------- |
| **Total Tables**                  | 10 (+ 3 views)             |
| **restaurant_schedules**          | 1,735 rows                 |
| **restaurant_special_schedules**  | 24 rows                    |
| **restaurant_time_periods**       | 3 rows                     |
| **restaurant_partner_schedules**  | 7 rows                     |
| **schedule_translations**         | 30 rows                    |
| **restaurant_delivery_areas**     | 201 rows (146 restaurants) |
| **restaurant_delivery_config**    | 185 rows                   |
| **restaurant_delivery_companies** | 15 rows                    |
| **restaurant_delivery_fees**      | 294 rows                   |
| **delivery_company_emails**       | 9 rows                     |

### Data Quality

| Column                       | Populated  | Missing                        |
| ---------------------------- | ---------- | ------------------------------ |
| `delivery_fee`               | 169 (84%)  | 31 restaurants                 |
| `min_order_value`            | 201 (100%) | 0                              |
| `estimated_delivery_minutes` | 0 (0%)     | 201 (business decision needed) |

---

## 🔗 Related Entities

- **Restaurant Entity** → Parent relationship via `restaurant_id`
- **Order Entity** → Validates delivery eligibility
- **User Entity** → Validates user addresses against zones, stores delivery addresses
- **Geography Entity** → Uses cities/provinces for location data
- **Admin Users Entity** → FK for audit columns (`created_by`, `updated_by`, `deleted_by`)
- **Restaurant Service Configs** → Source for `min_order_value` defaults

---

## 📋 Data Gaps Report

See `Menu.ca V3/Clean up scripts/Delivery Zones Entity/data_gaps_report.md` for:

- 31 restaurants missing `delivery_fee`
- 32 restaurants with min_order but no delivery areas

---

**Last Updated:** 2025-11-27
