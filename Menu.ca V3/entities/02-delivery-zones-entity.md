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
**Row Count:** 0 (cleared)

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

### Delivery Zone Tables

#### `restaurant_delivery_areas`

**Purpose:** Delivery area configurations with PostGIS geometry  
**Row Count:** 235 (181 restaurants)  
**Primary Table:** This is the main delivery zone table for all restaurants

| Column                        | Type                   | Nullable | Default            | Description                              |
| ----------------------------- | ---------------------- | -------- | ------------------ | ---------------------------------------- |
| `id`                          | bigint                 | NO       | identity           | Primary key                              |
| `uuid`                        | uuid                   | NO       | uuid_generate_v4() | External identifier                      |
| `restaurant_id`               | bigint                 | NO       | -                  | FK to restaurants                        |
| `area_number`                 | integer                | NO       | -                  | Area sequence number                     |
| `area_name`                   | varchar                | YES      | -                  | Area display name                        |
| `delivery_fee`                | numeric                | YES      | -                  | Flat delivery fee amount                 |
| `delivery_min_order`          | numeric                | YES      | -                  | Minimum order amount                     |
| `geometry`                    | geometry(Polygon,4326) | YES      | -                  | PostGIS polygon boundary                 |
| `is_active`                   | boolean                | NO       | true               | Area is active                           |
| `created_at`                  | timestamptz            | NO       | now()              | Creation timestamp                       |
| `created_by`                  | bigint                 | YES      | -                  | FK to admin_users                        |
| `updated_at`                  | timestamptz            | YES      | -                  | Last update timestamp                    |
| `updated_by`                  | bigint                 | YES      | -                  | FK to admin_users                        |
| `deleted_at`                  | timestamptz            | YES      | -                  | Soft delete timestamp                    |
| `deleted_by`                  | bigint                 | YES      | -                  | FK to admin_users                        |
| `estimated_delivery_minutes`  | integer                | YES      | -                  | Estimated delivery time                  |
| `distance_based_delivery_fee` | boolean                | NO       | false              | Uses distance-based fees instead of flat |

**Constraints:**

- `delivery_areas_positive_minutes`: `estimated_delivery_minutes IS NULL OR estimated_delivery_minutes > 0`
- FK constraints on `created_by`, `updated_by`, `deleted_by` → `admin_users(id)`

**Data Population Status:**

- `delivery_fee`: 229/235 populated (97%) - 6 missing are distance-based restaurants
- `delivery_min_order`: 235/235 populated (100%)
- `geometry`: 216/235 populated (92%) - 19 missing are distance-based or have no delivery area defined
- `estimated_delivery_minutes`: 235/235 populated (100%)
- `distance_based_delivery_fee`: 8 restaurants = true, 227 = false

---

#### `delivery_and_pickup_configs`

**Purpose:** Restaurant-level service configuration (delivery, pickup, ordering settings)  
**Row Count:** 185 (100% of restaurants)

| Column                    | Type        | Nullable | Default            | Description                   |
| ------------------------- | ----------- | -------- | ------------------ | ----------------------------- |
| `id`                      | bigint      | NO       | identity           | Primary key                   |
| `uuid`                    | uuid        | NO       | uuid_generate_v4() | External identifier           |
| `restaurant_id`           | bigint      | NO       | -                  | FK to restaurants             |
| `has_delivery_enabled`    | boolean     | NO       | false              | Delivery service enabled      |
| `pickup_enabled`          | boolean     | NO       | false              | Pickup service enabled        |
| `takeout_time_minutes`    | integer     | YES      | -                  | Average pickup time           |
| `allows_preorders`        | boolean     | YES      | false              | Accept future orders          |
| `is_bilingual`            | boolean     | YES      | false              | Supports both EN/FR           |
| `default_language`        | varchar     | YES      | 'en'               | Primary language              |
| `accepts_tips`            | boolean     | YES      | true               | Accept tips on orders         |
| `requires_phone`          | boolean     | YES      | true               | Phone required for orders     |
| `closing_warning_minutes` | integer     | YES      | -                  | Warning before closing        |
| `twilio_call`             | boolean     | YES      | -                  | Enable Twilio call on order   |
| `created_at`              | timestamptz | NO       | now()              | Creation timestamp            |
| `created_by`              | integer     | YES      | -                  | Admin who created             |
| `updated_at`              | timestamptz | YES      | -                  | Last update timestamp         |
| `updated_by`              | integer     | YES      | -                  | Admin who updated             |
| `deleted_at`              | timestamptz | YES      | -                  | Soft delete timestamp         |
| `deleted_by`              | bigint      | YES      | -                  | Admin who deleted             |

**Data Quality:**

- `has_delivery_enabled`: 150/185 = true (81%)
- `pickup_enabled`: 168/185 = true (91%)
- `takeout_time_minutes`: 185/185 populated (100%)
- `closing_warning_minutes`: 158/185 populated (85%)
- `twilio_call`: 169 = true (91%), 16 = false (9%)

---

#### `restaurant_delivery_companies`

**Purpose:** Links restaurants to third-party delivery companies (commission, payment terms)  
**Row Count:** 18

| Column                       | Type        | Nullable | Default            | Description                         |
| ---------------------------- | ----------- | -------- | ------------------ | ----------------------------------- |
| `id`                         | bigint      | NO       | identity           | Primary key                         |
| `uuid`                       | uuid        | NO       | uuid_generate_v4() | External identifier                 |
| `restaurant_id`              | bigint      | NO       | -                  | FK to restaurants                   |
| `company_email_id`           | smallint    | NO       | -                  | FK to delivery_company_emails       |
| `sends_to_delivery`          | boolean     | YES      | -                  | Sends orders to this company        |
| `disable_until`              | timestamptz | YES      | -                  | Temporarily disable                 |
| `commission`                 | numeric     | YES      | -                  | Commission percentage               |
| `restaurant_pays_difference` | numeric     | YES      | -                  | Extra amount restaurant pays driver |
| `is_active`                  | boolean     | YES      | true               | Currently active                    |
| `created_at`                 | timestamptz | NO       | now()              | Creation timestamp                  |
| `created_by`                 | integer     | YES      | -                  | Admin who created                   |
| `updated_at`                 | timestamptz | YES      | -                  | Last update timestamp               |
| `updated_by`                 | integer     | YES      | -                  | Admin who updated                   |

---

#### `restaurant_distance_based_delivery_fees`

**Purpose:** Distance-based tier fee structures (fee breakdown by distance tier)  
**Row Count:** 44

| Column               | Type        | Nullable | Default            | Description                   |
| -------------------- | ----------- | -------- | ------------------ | ----------------------------- |
| `id`                 | bigint      | NO       | identity           | Primary key                   |
| `uuid`               | uuid        | NO       | uuid_generate_v4() | External identifier           |
| `restaurant_id`      | bigint      | NO       | -                  | FK to restaurants             |
| `company_email_id`   | smallint    | YES      | -                  | FK to delivery_company_emails |
| `distance_in_km`     | smallint    | NO       | -                  | Distance tier (5-10km)        |
| `total_delivery_fee` | numeric     | YES      | -                  | Total fee charged to customer |
| `driver_earning`     | numeric     | YES      | -                  | Driver's portion              |
| `restaurant_pays`    | numeric     | YES      | -                  | Restaurant's contribution     |
| `vendor_pays`        | numeric     | YES      | -                  | Menu.ca's contribution        |
| `is_active`          | boolean     | YES      | true               | Currently active              |
| `created_at`         | timestamptz | NO       | now()              | Creation timestamp            |
| `created_by`         | integer     | YES      | -                  | Admin who created             |
| `updated_at`         | timestamptz | YES      | -                  | Last update timestamp         |
| `updated_by`         | integer     | YES      | -                  | Admin who updated             |

**Note:** This table stores distance-based delivery fee tiers. Restaurants using distance-based fees have `distance_based_delivery_fee = true` in `restaurant_delivery_areas`. Fee tiers are typically 5-10 km with breakdown of driver/restaurant/vendor portions.

---

### Supporting Tables

#### `delivery_company_emails`

**Purpose:** Delivery company contact information (shared across restaurants)  
**Row Count:** 9

| Column         | Type        | Nullable | Default            | Description            |
| -------------- | ----------- | -------- | ------------------ | ---------------------- |
| `id`           | smallint    | NO       | identity           | Primary key            |
| `uuid`         | uuid        | NO       | uuid_generate_v4() | External identifier    |
| `email`        | varchar     | NO       | -                  | Contact email (unique) |
| `company_name` | varchar     | YES      | -                  | Company display name   |
| `is_active`    | boolean     | YES      | true               | Currently active       |
| `created_at`   | timestamptz | NO       | now()              | Creation timestamp     |
| `created_by`   | integer     | YES      | -                  | Admin who created      |
| `updated_at`   | timestamptz | YES      | -                  | Last update timestamp  |
| `updated_by`   | integer     | YES      | -                  | Admin who updated      |

**Current Data:**

| ID  | Email                        | Company Name       |
| --- | ---------------------------- | ------------------ |
| 1   | deliveryzonecanada@gmail.com | Deliveryzonecanada |
| 2   | mattmenuottawa2@gmail.com    | Mattmenuottawa2    |
| 3   | restozonedispatch@gmail.com  | Restozonedispatch  |

---

#### `user_delivery_addresses`

**Purpose:** Customer saved delivery addresses  
**Row Count:** 0 (cleared test data)

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

| Function Name                             | Purpose                                  |
| ----------------------------------------- | ---------------------------------------- |
| `check_schedule_overlap(...)`             | Check if schedule overlaps with existing |
| `has_schedule_conflict(...)`              | Validate schedule doesn't conflict       |
| `clone_schedule_to_day(...)`              | Copy schedule from one day to another    |
| `bulk_copy_schedule_onboarding(...)`      | Bulk copy schedules during onboarding    |
| `bulk_toggle_schedules(...)`              | Enable/disable multiple schedules        |
| `apply_schedule_template_onboarding(...)` | Apply schedule template                  |
| `notify_schedule_change()`                | Trigger function for real-time updates   |
| `soft_delete_schedule(...)`               | Soft delete a schedule                   |
| `restore_schedule(...)`                   | Restore a soft-deleted schedule          |
| `validate_timezone(...)`                  | Validate timezone string                 |

### Delivery Zone Functions

| Function Name                           | Purpose                                   |
| --------------------------------------- | ----------------------------------------- |
| `soft_delete_delivery_zone(...)`        | Soft delete a delivery zone               |
| `restore_delivery_zone(...)`            | Restore a soft-deleted zone               |
| `toggle_delivery_zone_status(...)`      | Enable/disable delivery zone              |
| `find_nearby_restaurants(...)`          | Find restaurants near a location          |
| `find_nearest_franchise_locations(...)` | Find franchise locations that can deliver |

---

## ⚡ Edge Functions

| Function Name          | Endpoint                     | Purpose                           |
| ---------------------- | ---------------------------- | --------------------------------- |
| `delete-delivery-zone` | DELETE /delete-delivery-zone | Soft delete delivery zone via API |

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

### `delivery_and_pickup_configs` Table Indexes

| Index Name                             | Columns                | Type        | Notes                            |
| -------------------------------------- | ---------------------- | ----------- | -------------------------------- |
| `delivery_and_pickup_configs_pkey`     | `id`                   | PRIMARY KEY | -                                |
| `delivery_and_pickup_configs_uuid_key` | `uuid`                 | UNIQUE      | -                                |
| `u_delivery_pickup_restaurant`         | `restaurant_id`        | UNIQUE      | One config per restaurant        |
| `idx_delivery_pickup_restaurant`       | `restaurant_id`        | BTREE       | -                                |
| `idx_delivery_pickup_configs_deleted`  | `restaurant_id`        | BTREE       | WHERE deleted_at IS NULL         |
| `idx_delivery_pickup_delivery_enabled` | `has_delivery_enabled` | BTREE       | WHERE has_delivery_enabled=true  |
| `idx_delivery_pickup_takeout_enabled`  | `pickup_enabled`       | BTREE       | WHERE pickup_enabled=true        |

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

### `delivery_and_pickup_configs` Table Policies

| Policy Name                      | Operation | Roles         | Description                |
| -------------------------------- | --------- | ------------- | -------------------------- |
| `public_read_delivery_pickup`    | SELECT    | public        | Public can read configs    |
| `delivery_pickup_select_admin`   | SELECT    | authenticated | Admin can select           |
| `delivery_pickup_insert_admin`   | INSERT    | authenticated | Admin can insert           |
| `delivery_pickup_update_admin`   | UPDATE    | authenticated | Admin can update           |
| `delivery_pickup_delete_admin`   | DELETE    | authenticated | Admin can delete           |
| `delivery_pickup_service_role_all` | ALL     | service_role  | Service role full access   |

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

### `delivery_and_pickup_configs` Table Triggers

| Trigger Name                     | Event                  | Timing | Function                   | Description           |
| -------------------------------- | ---------------------- | ------ | -------------------------- | --------------------- |
| `trg_delivery_pickup_updated_at` | UPDATE                 | BEFORE | `set_updated_at()`         | Auto-update timestamp |
| `notify_delivery_pickup_change`  | INSERT, UPDATE, DELETE | AFTER  | `notify_schedule_change()` | Real-time updates     |

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

| Date       | Functionality                        | Reason                                        | Migration Notes                                                                                                                                        |
| ---------- | ------------------------------------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2025-11-27 | `restaurant_delivery_zones` table    | Consolidated into `restaurant_delivery_areas` | All delivery zone functionality now uses `restaurant_delivery_areas`. The 2 rows in `restaurant_delivery_zones` were not migrated as per user request. |
| 2025-11-27 | `display_name` column                | Duplicate of `area_name`                      | Removed from `restaurant_delivery_areas`. One record's display_name was preserved by updating area_name.                                               |
| 2025-11-27 | `legacy_v2_id` column                | Never used (0% populated)                     | Removed from `restaurant_delivery_areas` along with its unique constraint.                                                                             |
| 2025-11-27 | `is_complex` column                  | Redundant (all values false)                  | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `conditional_fee` column             | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `conditional_threshold` column       | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `notes` column                       | Never used (0% populated)                     | Removed from `restaurant_delivery_areas`.                                                                                                              |
| 2025-11-27 | `coordinates` column                 | Redundant with `geometry`                     | Removed - geometry is the source of truth for polygon data.                                                                                            |
| 2025-11-27 | `fee_type` column                    | Simplified schema                             | Removed from `restaurant_delivery_areas` - fee type can be inferred from delivery_fee value.                                                           |
| 2025-12-02 | `delivery_min_order` column          | Consolidated to delivery_areas                | Removed from `restaurant_service_configs` - now exclusively in `restaurant_delivery_areas` to support zone-specific minimums.                          |
| 2025-12-02 | `takeout_only` column                | Not needed                                    | Removed from `restaurant_delivery_areas` - takeout-only status handled by `has_delivery_enabled` in service_configs.                                   |
| 2025-12-02 | Colonnade Pizza delivery areas       | Takeout-only restaurants                      | Deleted 4 delivery areas for Colonnade Pizza locations (IDs: 196, 783, 784, 785) - these are pickup-only restaurants.                                  |
| 2025-12-02 | `fee_type` column                    | Simplified schema                             | Removed from `restaurant_distance_based_delivery_fees` - all records are distance-based.                                                               |
| 2025-12-02 | `legacy_v1_id` column                | Migration complete                            | Removed from `restaurant_distance_based_delivery_fees`.                                                                                                |
| 2025-12-02 | `legacy_source` column               | Migration complete                            | Removed from `restaurant_distance_based_delivery_fees`.                                                                                                |
| 2025-12-02 | `notes` column                       | Never used                                    | Removed from `restaurant_distance_based_delivery_fees`, `restaurant_delivery_companies`, and `delivery_company_emails`.                                |
| 2025-12-02 | `active_partners` column             | Legacy data                                   | Removed from `restaurant_distance_based_delivery_fees`.                                                                                                |
| 2025-12-02 | `legacy_v1_delivery_info_id`         | Migration complete                            | Removed from `restaurant_delivery_companies`.                                                                                                          |
| 2025-12-02 | Old distance-based fee records       | Data cleanup                                  | Deleted all records except Champa Thai Cuisine (V3 ID 87), then re-scraped V1 restaurants.                                                             |
| 2025-12-02 | `restaurant_time_periods` table      | Sparse data (3 rows, 2 restaurants)           | Dropped table - only used by 2 restaurants with questionable data quality.                                                                             |
| 2025-12-02 | `restaurant_partner_schedules` table | Legacy V2 artifact (7 rows, 1 restaurant)     | Dropped table - incomplete schema (no partner_name), only used by All Out Burger Gladstone.                                                            |
| 2025-12-02 | `schedule_translations` table        | Static lookup, translations in frontend       | Dropped table - day-of-week translations handled by frontend i18n.                                                                                     |
| 2025-12-02 | `restaurant_special_schedules` data  | Historical/stale data cleanup                 | Deleted all 24 records - contained outdated vacation closures from 2024-2025.                                                                          |
| 2025-12-03 | `restaurant_delivery_config` table   | Legacy table, all data unused or migrated     | Dropped table - 185 rows with legacy V1 flags and empty partner credentials.                                                                            |
| 2025-12-03 | `user_delivery_addresses` data       | Test data cleanup                             | Deleted 7 test records - table ready for production user data.                                                                                           |
| 2025-12-03 | 8 broken SQL functions               | Referenced deleted/renamed columns            | Dropped: create_delivery_zone, create_delivery_zone_onboarding, update_delivery_zone, get_restaurant_delivery_summary, is_address_in_delivery_zone, get_restaurant_schedule, get_delivery_zone_area_sq_km, get_upcoming_schedule_changes |
| 2025-12-03 | 2 broken Edge functions              | Called deleted SQL functions                  | Deleted: create-delivery-zone, update-delivery-zone (called deleted SQL functions)                                                                                                                                                        |
| 2025-12-03 | Renamed indexes/triggers/policies    | Table renamed to delivery_and_pickup_configs  | Renamed 8 indexes, 2 triggers, 6 RLS policies to match new table name.                                                                                                                                                                    |
| 2025-12-03 | Renamed distance fees indexes        | Table renamed to restaurant_distance_based... | Renamed 3 indexes, 1 trigger, 2 RLS policies. Dropped 2 duplicate indexes.                                                                                                                                                                |

---

## ✨ New Functionalities

| Date       | Functionality                  | Status      | Notes                                                                                                                   |
| ---------- | ------------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| 2025-11-27 | V1/V2 Delivery Areas Migration | ✅ Complete | 201 delivery areas migrated to `restaurant_delivery_areas`                                                              |
| 2025-11-27 | Soft Delete Support            | ✅ Complete | Added `deleted_at`, `deleted_by` columns with FK to `admin_users`                                                       |
| 2025-11-27 | Estimated Delivery Time        | ✅ Complete | Added `estimated_delivery_minutes` column                                                                               |
| 2025-11-27 | Consolidated Delivery Zones    | ✅ Complete | All delivery zone operations now use `restaurant_delivery_areas` exclusively                                            |
| 2025-11-27 | Data Population                | ✅ Complete | `delivery_fee` populated from `restaurant_delivery_fees`, `min_order_value` populated from `restaurant_service_configs` |
| 2025-12-02 | Distance-Based Fee Flag        | ✅ Complete | Added `distance_based_delivery_fee` boolean column to `restaurant_delivery_areas`                                       |
| 2025-12-02 | V1 Distance-Based Fee Scraper  | ✅ Complete | Scraped 8 restaurants with distance-based fees from V1 CRM, populated fee tiers and company links                       |

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
| 2025-12-02 | Renamed `min_order_value`              | `ALTER TABLE ... RENAME COLUMN min_order_value TO delivery_min_order`                                                      | Consistent naming with source column                        |
| 2025-12-02 | Removed test data                      | `DELETE FROM restaurant_delivery_areas WHERE restaurant_id = 105 AND area_number = 2`                                      | Removed "Friends of Rockcliff" test area ($300 min)         |
| 2025-12-02 | Fixed discrepancies                    | `UPDATE ... SET delivery_min_order = X WHERE restaurant_id IN (...)`                                                       | Fixed 4 restaurants with mismatched min order values        |
| 2025-12-02 | Added distance_based flag              | `ALTER TABLE restaurant_delivery_areas ADD COLUMN distance_based_delivery_fee boolean NOT NULL DEFAULT false`              | Explicitly tracks which areas use distance-based pricing    |
| 2025-12-02 | Normalized distance-based fee table    | `ALTER TABLE restaurant_delivery_fees RENAME TO restaurant_distance_based_delivery_fees`                                   | Clarified purpose of distance-based fee table               |
| 2025-12-02 | Renamed distance tier column           | `ALTER TABLE ... RENAME COLUMN tier_value TO distance_in_km`                                                               | Uses explicit distance naming instead of generic tier       |
| 2025-12-02 | Aligned delivery company accounting    | `ALTER TABLE restaurant_delivery_companies RENAME COLUMN restaurant_pays_driver TO restaurant_pays_difference`             | Clarified that only the difference is tracked               |
| 2025-12-02 | Cleaned distance-based fee table       | `DROP COLUMN legacy_v1_id, legacy_source, notes, active_partners, fee_type`                                                | Removed 5 legacy/unused columns from fee table              |
| 2025-12-02 | Cleaned delivery companies table       | `DROP COLUMN notes, legacy_v1_delivery_info_id`                                                                            | Removed legacy columns                                      |
| 2025-12-02 | Populated company names                | `UPDATE delivery_company_emails SET company_name = ... WHERE company_name IS NULL`                                         | Auto-generated names from email local-part                  |
| 2025-12-02 | Scraped V1 distance-based fees         | Python scraper: `Distance based delivery fees/main.py`                                                                     | 8 restaurants, 44 fee tiers, 18 company links               |
| 2025-12-03 | Populated missing delivery_fee         | V1 migration + manual fix for Pho Dau Bo                                                                                   | 40 V1 restaurants migrated, 1 V2 set to $0                  |
| 2025-12-03 | Populated missing delivery_minutes     | `UPDATE ... SET estimated_delivery_minutes = 40 WHERE restaurant_id = 715`                                                 | La Poutinerie Ogilvie - last missing value                  |
| 2025-12-03 | Renamed service configs table          | `ALTER TABLE restaurant_service_configs RENAME TO delivery_and_pickup_configs`                                             | Clearer table name reflecting its purpose                   |
| 2025-12-03 | Added twilio_call column               | `ALTER TABLE delivery_and_pickup_configs ADD COLUMN twilio_call boolean`                                                   | Enable Twilio call notifications per restaurant             |
| 2025-12-03 | Populated twilio_call from legacy      | `UPDATE ... FROM v1_twillio_call.csv, v2_twillio_call.csv`                                                                 | 155 = true, 7 = false, 23 = NULL (not in legacy data)       |

---

## 📈 Statistics

| Metric                                      | Value                      |
| ------------------------------------------- | -------------------------- |
| **Total Tables**                            | 6 (+ 3 views)              |
| **restaurant_schedules**                    | 1,735 rows                 |
| **restaurant_special_schedules**            | 0 rows (cleared)           |
| **delivery_and_pickup_configs**             | 185 rows (100% coverage)   |
| **restaurant_delivery_areas**               | 235 rows (181 restaurants) |
| **restaurant_delivery_companies**           | 18 rows                    |
| **restaurant_distance_based_delivery_fees** | 44 rows                    |
| **delivery_company_emails**                 | 9 rows                     |

### Distance-Based Delivery Fees

| Restaurant                | V3 ID | Fee Tiers | Delivery Companies |
| ------------------------- | ----- | --------- | ------------------ |
| Centertown Donair & Pizza | 131   | 4         | 3                  |
| Champa Thai Cuisine       | 87    | 6         | 3 (MVP)            |
| Charm Thai Cuisine        | 943   | 4         | 0                  |
| Lemongrass Thai Cuisine   | 1010  | 6         | 3                  |
| New Mee Fung Restaurant   | 15    | 4         | 0                  |
| Oh My Grill               | 807   | 6         | 3                  |
| Pho Bo Ga King - Somerset | 199   | 4         | 0                  |
| Sushiyana                 | 847   | 6         | 3                  |

### Data Quality

| Column                        | Populated   | Missing                                            |
| ----------------------------- | ----------- | -------------------------------------------------- |
| `delivery_fee`                | 229 (97%)   | 6 areas (distance-based restaurants)               |
| `delivery_min_order`          | 235 (100%)  | 0                                                  |
| `geometry`                    | 216 (92%)   | 19 areas (distance-based or no delivery defined)   |
| `estimated_delivery_minutes`  | 235 (100%)  | 0                                                  |
| `distance_based_delivery_fee` | 235 (100%)  | 0 (8 = true, 227 = false)                          |

---

## 🔗 Related Entities

- **Restaurant Entity** → Parent relationship via `restaurant_id`
- **Order Entity** → Validates delivery eligibility
- **User Entity** → Validates user addresses against zones, stores delivery addresses
- **Geography Entity** → Uses cities/provinces for location data
- **Admin Users Entity** → FK for audit columns (`created_by`, `updated_by`, `deleted_by`)

### Distance-Based Delivery Fee Relationships

```
┌──────────────────────┐
│     restaurants      │
└──────────┬───────────┘
           │
    ┌──────┴──────┬────────────────────────┐
    │             │                        │
    ▼             ▼                        ▼
┌─────────────────────────┐  ┌─────────────────────────────┐  ┌─────────────────────────────────┐
│ restaurant_delivery_    │  │ restaurant_delivery_        │  │ restaurant_distance_based_      │
│ areas (235)             │  │ companies (18)              │  │ delivery_fees (44)              │
├─────────────────────────┤  ├─────────────────────────────┤  ├─────────────────────────────────┤
│ distance_based_         │  │ company_email_id ──────────┐│  │ company_email_id ──────────────┐│
│ delivery_fee (bool)     │  │ commission                 ││  │ distance_in_km                 ││
│ delivery_fee (flat)     │  │ restaurant_pays_difference ││  │ total_delivery_fee             ││
│ delivery_min_order      │  │ sends_to_delivery          ││  │ driver_earning                 ││
└─────────────────────────┘  └────────────────────────────┼┘  │ restaurant_pays                ││
                                                          │   │ vendor_pays                    ││
                                                          │   └────────────────────────────────┼┘
                                                          │                                    │
                                                          ▼                                    │
                                            ┌─────────────────────────────┐◄───────────────────┘
                                            │  delivery_company_emails    │
                                            │         (9)                 │
                                            ├─────────────────────────────┤
                                            │ email (unique)              │
                                            │ company_name                │
                                            └─────────────────────────────┘
```

**Flow:**

1. `restaurant_delivery_areas.distance_based_delivery_fee = true` → Restaurant uses distance-based pricing
2. `restaurant_delivery_companies` → Links restaurant to delivery company with commission terms
3. `restaurant_distance_based_delivery_fees` → Fee tiers (5-10 km) with driver/restaurant/vendor split
4. `delivery_company_emails` → Shared delivery company contact info

---

**Last Updated:** 2025-12-03 (Renamed restaurant_service_configs → delivery_and_pickup_configs, added twilio_call column)
