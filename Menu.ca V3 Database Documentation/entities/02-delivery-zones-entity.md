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

- [📊 Tables](#-tables)
  - [restaurant_schedules](#restaurant_schedules)
  - [restaurant_special_schedules](#restaurant_special_schedules)
  - [restaurant_delivery_areas](#restaurant_delivery_areas)
  - [delivery_and_pickup_configs](#delivery_and_pickup_configs)
  - [restaurant_delivery_companies](#restaurant_delivery_companies)
  - [restaurant_distance_based_delivery_fees](#restaurant_distance_based_delivery_fees)
  - [delivery_providers](#delivery_providers)
  - [delivery_company_emails](#delivery_company_emails)
  - [Views](#views)
- [🔧 SQL Functions](#-sql-functions)
- [⚡ Edge Functions](#-edge-functions)
- [📇 Indexes](#-indexes)
- [🔒 RLS Policies](#-rls-policies)
- [⚙️ Triggers](#️-triggers)
- [🗑️ Migration History](#️-migration-history)
- [🚨 Data Integrity Issues](#-data-integrity-issues)
- [📈 Statistics](#-statistics)
- [🔗 Related Entities](#-related-entities)

---

## 📊 Tables

### Scheduling Tables

#### `restaurant_schedules`

**Purpose:** Regular operating hours (delivery, takeout, dine-in)  
**Row Count:** 2,887

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

**Purpose:** Holiday closures, vacation periods, and exception hours  
**Row Count:** 0

| Column          | Type        | Nullable | Default            | Description                                      |
| --------------- | ----------- | -------- | ------------------ | ------------------------------------------------ |
| `id`            | bigint      | NO       | identity           | Primary key                                      |
| `uuid`          | uuid        | NO       | uuid_generate_v4() | External identifier                              |
| `restaurant_id` | bigint      | NO       | -                  | FK to restaurants                                |
| `schedule_type` | varchar     | NO       | -                  | Type (e.g., 'closure', 'modified_hours')         |
| `date_start`    | date        | NO       | -                  | Period start date                                |
| `date_stop`     | date        | NO       | -                  | Period end date                                  |
| `time_start`    | time        | YES      | -                  | Modified opening time (NULL if full-day closure) |
| `time_stop`     | time        | YES      | -                  | Modified closing time (NULL if full-day closure) |
| `reason`        | varchar     | YES      | -                  | Reason for special schedule                      |
| `apply_to`      | varchar     | YES      | -                  | Which service types this applies to              |
| `notes`         | text        | YES      | -                  | Additional notes                                 |
| `is_active`     | boolean     | NO       | -                  | Schedule entry is active                         |
| `created_at`    | timestamptz | NO       | -                  | Creation timestamp                               |
| `created_by`    | integer     | YES      | -                  | Admin who created                                |
| `updated_at`    | timestamptz | YES      | -                  | Last update timestamp                            |
| `updated_by`    | integer     | YES      | -                  | Admin who updated                                |
| `deleted_at`    | timestamptz | YES      | -                  | Soft delete timestamp                            |
| `deleted_by`    | bigint      | YES      | -                  | Admin who deleted                                |

---

### Delivery Zone Tables

#### `restaurant_delivery_areas`

**Purpose:** Delivery area configurations with PostGIS geometry  
**Row Count:** 239  
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

**Constraints:**

- `delivery_areas_positive_minutes`: `estimated_delivery_minutes IS NULL OR estimated_delivery_minutes > 0`
- FK constraints on `created_by`, `updated_by`, `deleted_by` → `admin_users(id)`

**Data Population Status:**

- `delivery_fee`: 229/235 populated (97%) - 6 missing are distance-based restaurants
- `delivery_min_order`: 235/235 populated (100%)
- `geometry`: 216/235 populated (92%) - 19 missing are distance-based or have no delivery area defined
- `estimated_delivery_minutes`: 235/235 populated (100%)

---

#### `delivery_and_pickup_configs`

**Purpose:** Restaurant-level service configuration (delivery, pickup, ordering settings)  
**Row Count:** 186

| Column                          | Type        | Nullable | Default            | Description                              |
| ------------------------------- | ----------- | -------- | ------------------ | ---------------------------------------- |
| `id`                            | bigint      | NO       | identity           | Primary key                              |
| `uuid`                          | uuid        | NO       | uuid_generate_v4() | External identifier                      |
| `restaurant_id`                 | bigint      | NO       | -                  | FK to restaurants                        |
| `has_delivery_enabled`          | boolean     | NO       | false              | Delivery service enabled                 |
| `pickup_enabled`                | boolean     | NO       | false              | Pickup service enabled                   |
| `takeout_time_minutes`          | integer     | YES      | -                  | Average pickup time                      |
| `allows_preorders`              | boolean     | YES      | false              | Accept future orders                     |
| `is_bilingual`                  | boolean     | YES      | false              | Supports both EN/FR                      |
| `default_language`              | varchar     | YES      | 'en'               | Primary language                         |
| `accepts_tips`                  | boolean     | YES      | true               | Accept tips on orders                    |
| `requires_phone`                | boolean     | YES      | true               | Phone required for orders                |
| `closing_warning_minutes`       | integer     | YES      | -                  | Warning before closing                   |
| `twilio_call`                   | boolean     | YES      | -                  | Enable Twilio call on order              |
| `distance_based_delivery_fee`   | boolean     | NO       | false              | Uses distance-based fees                 |
| `delivery_provider_id`          | smallint    | YES      | -                  | FK to delivery_providers                 |
| `delivery_provider_external_id` | varchar(100)| YES      | -                  | Restaurant's ID in provider's system     |
| `payment_mode`                  | text        | YES      | 'test'             | Payment mode configuration               |
| `busy_takeout_time_minutes`     | integer     | YES      | -                  | Takeout time when in busy mode           |
| `busy_mode_enabled`             | boolean     | YES      | false              | Restaurant is currently in busy mode     |
| `peak_hours`                    | jsonb       | YES      | -                  | Peak hour configuration                  |
| `created_at`                    | timestamptz | NO       | now()              | Creation timestamp                       |
| `created_by`                    | integer     | YES      | -                  | Admin who created                        |
| `updated_at`                    | timestamptz | YES      | -                  | Last update timestamp                    |
| `updated_by`                    | integer     | YES      | -                  | Admin who updated                        |
| `deleted_at`                    | timestamptz | YES      | -                  | Soft delete timestamp                    |
| `deleted_by`                    | bigint      | YES      | -                  | Admin who deleted                        |

**Data Quality:**

- `has_delivery_enabled`: 150/185 = true (81%)
- `pickup_enabled`: 168/185 = true (91%)
- `takeout_time_minutes`: 185/185 populated (100%)
- `closing_warning_minutes`: 158/185 populated (85%)
- `twilio_call`: 169 = true (91%), 16 = false (9%)
- `distance_based_delivery_fee`: 8 = true, 177 = false
- `delivery_provider_id`: 8 = RestoZone, 177 = NULL (no external provider)

---

#### `restaurant_delivery_companies`

**Purpose:** Links restaurants to third-party delivery companies (commission, payment terms)  
**Row Count:** 19

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
**Row Count:** 59

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

#### `delivery_providers`

**Purpose:** Master list of third-party delivery provider companies  
**Row Count:** 1

| Column                  | Type        | Nullable | Default            | Description                         |
| ----------------------- | ----------- | -------- | ------------------ | ----------------------------------- |
| `id`                    | smallint    | NO       | identity           | Primary key                         |
| `uuid`                  | uuid        | NO       | uuid_generate_v4() | External identifier                 |
| `code`                  | varchar(50) | NO       | -                  | Unique provider code (e.g., 'restozone') |
| `name`                  | varchar(100)| NO       | -                  | Display name (e.g., 'RestoZone')    |
| `api_base_url`          | varchar(255)| YES      | -                  | Provider's API base URL             |
| `is_active`             | boolean     | YES      | true               | Provider is available               |
| `supports_fee_api`      | boolean     | YES      | false              | Can query fees from their API       |
| `supports_dispatch_api` | boolean     | YES      | false              | Can dispatch drivers via API        |
| `supports_tracking`     | boolean     | YES      | false              | Provides driver tracking            |
| `created_at`            | timestamptz | YES      | now()              | Creation timestamp                  |
| `updated_at`            | timestamptz | YES      | -                  | Last update timestamp               |

**Current Data:**

| ID | Code      | Name      | API URL              | Fee API | Dispatch | Tracking |
|----|-----------|-----------|----------------------|---------|----------|----------|
| 1  | restozone | RestoZone | https://restozone.ca | Yes     | Yes      | No       |

> Tookan, DoorDash Drive, and Uber Direct were previously seeded but have been removed. Only RestoZone is currently in use.

**Note:** `delivery_and_pickup_configs.delivery_provider_id` references this table to link restaurants to their provider.

---

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
| `tablet_get_delivery_config(...)`       | Get delivery config for tablet app        |
| `tablet_update_delivery_enabled(...)`   | Toggle delivery enabled from tablet app   |

---

## ⚡ Edge Functions

| Function Name          | Endpoint                     | Purpose                           |
| ---------------------- | ---------------------------- | --------------------------------- |
| `delete-delivery-zone` | DELETE /delete-delivery-zone | Soft delete delivery zone via API |

---

## 📇 Indexes

### `restaurant_schedules` Table Indexes

| Index Name                                    | Columns                                          | Type        | Notes                    |
| --------------------------------------------- | ------------------------------------------------ | ----------- | ------------------------ |
| `restaurant_schedules_pkey`                   | `id`                                             | PRIMARY KEY | -                        |
| `restaurant_schedules_uuid_key`               | `uuid`                                           | UNIQUE      | -                        |
| `u_sched_restaurant_service_day`              | `restaurant_id, type, day_start, time_start, time_stop` | UNIQUE | Prevent duplicates |
| `idx_schedules_restaurant`                    | `restaurant_id`                                  | BTREE       | -                        |
| `idx_schedules_restaurant_type`               | `restaurant_id, type, day_start`                 | BTREE       | -                        |
| `idx_schedules_enabled`                       | `restaurant_id, is_enabled`                      | BTREE       | WHERE is_enabled = true  |
| `idx_restaurant_schedules_deleted`            | `restaurant_id`                                  | BTREE       | WHERE deleted_at IS NULL |
| `idx_restaurant_schedules_soft_delete_active` | `restaurant_id, day_start, type`                 | BTREE       | WHERE deleted_at IS NULL |

### `restaurant_delivery_areas` Table Indexes

| Index Name                              | Columns                      | Type        | Notes                                         |
| --------------------------------------- | ---------------------------- | ----------- | --------------------------------------------- |
| `restaurant_delivery_areas_pkey`        | `id`                         | PRIMARY KEY | -                                             |
| `u_restaurant_area`                     | `restaurant_id, area_number` | UNIQUE      | Prevent duplicates                            |
| `idx_delivery_areas_restaurant`         | `restaurant_id`              | BTREE       | -                                             |
| `idx_delivery_areas_area_number`        | `restaurant_id, area_number` | BTREE       | -                                             |
| `idx_delivery_areas_geometry`           | `geometry`                   | GIST        | Spatial index                                 |
| `idx_delivery_areas_deleted`            | `deleted_at`                 | BTREE       | WHERE deleted_at IS NOT NULL                  |
| `idx_delivery_areas_active_not_deleted` | `restaurant_id, is_active`   | BTREE       | WHERE deleted_at IS NULL AND is_active = true |

### `delivery_and_pickup_configs` Table Indexes

| Index Name                             | Columns                   | Type        | Notes                                    |
| -------------------------------------- | ------------------------- | ----------- | ---------------------------------------- |
| `delivery_and_pickup_configs_pkey`     | `id`                      | PRIMARY KEY | -                                        |
| `delivery_and_pickup_configs_uuid_key` | `uuid`                    | UNIQUE      | -                                        |
| `u_delivery_pickup_restaurant`         | `restaurant_id`           | UNIQUE      | One config per restaurant                |
| `idx_delivery_pickup_restaurant`       | `restaurant_id`           | BTREE       | -                                        |
| `idx_delivery_pickup_configs_deleted`  | `restaurant_id`           | BTREE       | WHERE deleted_at IS NULL                 |
| `idx_delivery_pickup_delivery_enabled` | `has_delivery_enabled`    | BTREE       | WHERE has_delivery_enabled=true          |
| `idx_delivery_pickup_takeout_enabled`  | `pickup_enabled`          | BTREE       | WHERE pickup_enabled=true                |
| `idx_delivery_pickup_distance_based`   | `restaurant_id`           | BTREE       | WHERE distance_based_delivery_fee=true   |
| `idx_dpc_delivery_provider`            | `delivery_provider_id`    | BTREE       | WHERE delivery_provider_id IS NOT NULL   |

### `restaurant_special_schedules` Table Indexes

| Index Name                                | Columns              | Type        | Notes                    |
| ----------------------------------------- | -------------------- | ----------- | ------------------------ |
| `restaurant_special_schedules_pkey`       | `id`                 | PRIMARY KEY | -                        |
| `restaurant_special_schedules_uuid_key`   | `uuid`               | UNIQUE      | -                        |
| `idx_special_schedules_restaurant`        | `restaurant_id`      | BTREE       | -                        |
| `idx_special_schedules_dates`             | `date_start, date_stop` | BTREE    | Date range lookup        |
| `idx_special_schedules_active`            | `is_active`          | BTREE       | WHERE is_active = true   |

### `restaurant_delivery_companies` Table Indexes

| Index Name                                      | Columns                          | Type        | Notes                    |
| ----------------------------------------------- | -------------------------------- | ----------- | ------------------------ |
| `restaurant_delivery_companies_pkey`            | `id`                             | PRIMARY KEY | -                        |
| `u_restaurant_company`                          | `restaurant_id, company_email_id`| UNIQUE      | One link per company     |
| `idx_delivery_companies_restaurant`             | `restaurant_id`                  | BTREE       | -                        |
| `idx_delivery_companies_email`                  | `company_email_id`               | BTREE       | -                        |
| `idx_restaurant_delivery_companies_active`      | `restaurant_id, is_active`       | BTREE       | WHERE is_active = true   |

### `restaurant_distance_based_delivery_fees` Table Indexes

| Index Name                                       | Columns         | Type        | Notes |
| ------------------------------------------------ | --------------- | ----------- | ----- |
| `restaurant_distance_based_delivery_fees_pkey`   | `id`            | PRIMARY KEY | -     |
| `idx_distance_fees_restaurant`                   | `restaurant_id` | BTREE       | -     |
| `idx_distance_fees_company`                      | `company_email_id` | BTREE    | -     |

### `delivery_company_emails` Table Indexes

| Index Name                              | Columns     | Type        | Notes                  |
| --------------------------------------- | ----------- | ----------- | ---------------------- |
| `delivery_company_emails_pkey`          | `id`        | PRIMARY KEY | -                      |
| `delivery_company_emails_email_key`     | `email`     | UNIQUE      | -                      |
| `idx_delivery_company_emails_active`    | `is_active` | BTREE       | WHERE is_active = true |

### `delivery_providers` Table Indexes

| Index Name                      | Columns      | Type        | Notes                  |
| ------------------------------- | ------------ | ----------- | ---------------------- |
| `delivery_providers_pkey`       | `id`         | PRIMARY KEY | -                      |
| `delivery_providers_uuid_key`   | `uuid`       | UNIQUE      | -                      |
| `delivery_providers_code_key`   | `code`       | UNIQUE      | Unique provider code   |
| `idx_delivery_providers_active` | `is_active`  | BTREE       | WHERE is_active = true |

---

## 🔒 RLS Policies

### `restaurant_schedules` Table Policies

| Policy Name                              | Operation | Roles         | Description                       |
| ---------------------------------------- | --------- | ------------- | --------------------------------- |
| `public_view_schedules`                  | SELECT    | public        | Public can read schedules         |
| `admin_crud_own_restaurant_schedules`    | ALL       | authenticated | Admin full CRUD on own restaurant |
| `schedules_service_role_all`             | ALL       | service_role  | Service role full access          |

### `restaurant_special_schedules` Table Policies

| Policy Name                                    | Operation | Roles         | Description                       |
| ---------------------------------------------- | --------- | ------------- | --------------------------------- |
| `public_read_special_schedules`                | SELECT    | public        | Public can read special schedules |
| `admin_crud_own_restaurant_special_schedules`  | ALL       | authenticated | Admin full CRUD on own restaurant |
| `special_schedules_service_role_all`           | ALL       | service_role  | Service role full access          |

### `restaurant_delivery_areas` Table Policies

| Policy Name                                | Operation | Roles         | Description                       |
| ------------------------------------------ | --------- | ------------- | --------------------------------- |
| `public_view_delivery_areas`               | SELECT    | public        | Public can read areas             |
| `admin_crud_own_restaurant_delivery_areas` | ALL       | authenticated | Admin full CRUD on own restaurant |
| `delivery_areas_service_role_all`          | ALL       | service_role  | Service role full access          |

### `delivery_and_pickup_configs` Table Policies

| Policy Name                                   | Operation | Roles         | Description                       |
| --------------------------------------------- | --------- | ------------- | --------------------------------- |
| `public_read_delivery_pickup`                 | SELECT    | public        | Public can read configs           |
| `admin_crud_own_delivery_and_pickup_configs`  | ALL       | authenticated | Admin full CRUD on own restaurant |
| `delivery_pickup_service_role_all`            | ALL       | service_role  | Service role full access          |

### `restaurant_delivery_companies` Table Policies

| Policy Name                                         | Operation | Roles         | Description                       |
| --------------------------------------------------- | --------- | ------------- | --------------------------------- |
| `admin_crud_own_restaurant_delivery_companies`      | ALL       | authenticated | Admin full CRUD on own restaurant |
| `delivery_companies_manage_restaurant_admin`        | ALL       | authenticated | Admin manage delivery companies   |
| `delivery_companies_service_role_all`               | ALL       | service_role  | Service role full access          |

### `restaurant_distance_based_delivery_fees` Table Policies

| Policy Name                                                   | Operation | Roles         | Description                       |
| ------------------------------------------------------------- | --------- | ------------- | --------------------------------- |
| `admin_crud_own_restaurant_distance_based_delivery_fees`      | ALL       | authenticated | Admin full CRUD on own restaurant |
| `distance_fees_manage_admin`                                  | ALL       | authenticated | Admin manage distance fees        |
| `distance_fees_service_role_all`                              | ALL       | service_role  | Service role full access          |

### `delivery_company_emails` Table Policies

| Policy Name                                | Operation | Roles         | Description                   |
| ------------------------------------------ | --------- | ------------- | ----------------------------- |
| `public_read_delivery_emails`              | SELECT    | public        | Public can read emails        |
| `admin_select_delivery_emails`             | SELECT    | authenticated | Admin can read emails         |
| `delivery_company_emails_service_role_all` | ALL       | service_role  | Service role full access      |

### `delivery_providers` Table Policies

| Policy Name                          | Operation | Roles        | Description                      |
| ------------------------------------ | --------- | ------------ | -------------------------------- |
| `delivery_providers_public_read`     | SELECT    | public       | Public can read active providers |
| `delivery_providers_service_role_all`| ALL       | service_role | Service role full access         |

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

### `restaurant_distance_based_delivery_fees` Table Triggers

| Trigger Name                   | Event  | Timing | Function           | Description           |
| ------------------------------ | ------ | ------ | ------------------ | --------------------- |
| `trg_distance_fees_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `delivery_company_emails` Table Triggers

| Trigger Name                             | Event  | Timing | Function           | Description           |
| ---------------------------------------- | ------ | ------ | ------------------ | --------------------- |
| `trg_delivery_company_emails_updated_at` | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

### `delivery_providers` Table Triggers

| Trigger Name                         | Event  | Timing | Function           | Description           |
| ------------------------------------ | ------ | ------ | ------------------ | --------------------- |
| `trg_delivery_providers_updated_at`  | UPDATE | BEFORE | `set_updated_at()` | Auto-update timestamp |

---

## 🗑️ Migration History

> **Summary:** Between Nov 2025 and Jan 2026, this entity underwent extensive cleanup:
> - **Dropped tables (5):** `restaurant_delivery_zones`, `restaurant_delivery_config`, `restaurant_time_periods`, `restaurant_partner_schedules`, `schedule_translations`
> - **Dropped columns (20+):** Legacy/unused columns removed from `restaurant_delivery_areas`, `restaurant_distance_based_delivery_fees`, `restaurant_delivery_companies`, `delivery_company_emails`, `delivery_and_pickup_configs`
> - **Dropped functions (8):** `create_delivery_zone`, `create_delivery_zone_onboarding`, `update_delivery_zone`, `get_restaurant_delivery_summary`, `is_address_in_delivery_zone`, `get_restaurant_schedule`, `get_delivery_zone_area_sq_km`, `get_upcoming_schedule_changes`
> - **Dropped Edge Functions (2):** `create-delivery-zone`, `update-delivery-zone`
> - **Commission columns** (`commission_enabled`, `commission_rate`, `commission_base`) migrated to Order Management Entity (2026-01-19)
> - **`delivery_providers`** seeded with 4 providers (2026-01-23), later reduced to 1 (RestoZone only)
> - All V1/V2 delivery areas migrated, data populated, tables renamed for clarity

---

## 🚨 Data Integrity Issues

| Issue | Details |
| ----- | ------- |
| **4 restaurants without delivery areas** | Colonnade Pizza (IDs: 196, 783, 784, 785) — these are pickup-only, by design |
| **`restaurant_special_schedules` is empty** | 0 rows — table was restructured but not yet populated with new data |
| **Duplicate indexes cleaned (2026-02-17)** | Dropped 4 redundant indexes: `idx_restaurant_delivery_companies_restaurant`, `idx_restaurant_delivery_companies_company`, `idx_delivery_pickup_configs_soft_delete`, `idx_delivery_company_emails_email` |
| **`delivery_providers` reduced to 1** | Tookan, DoorDash Drive, and Uber Direct rows were removed; only RestoZone remains |

---

## 📈 Statistics

| Metric                                      | Value          |
| ------------------------------------------- | -------------- |
| **Total Tables**                            | 8 (+ 3 views)  |
| **Total RLS Policies**                      | 23             |
| **restaurant_schedules**                    | 2,887 rows     |
| **restaurant_special_schedules**            | 0 rows         |
| **delivery_and_pickup_configs**             | 186 rows       |
| **restaurant_delivery_areas**               | 239 rows       |
| **restaurant_delivery_companies**           | 19 rows        |
| **restaurant_distance_based_delivery_fees** | 59 rows        |
| **delivery_company_emails**                 | 9 rows         |
| **delivery_providers**                      | 1 row          |

---

## 🔗 Related Entities

- **Restaurant Entity** → Parent relationship via `restaurant_id`
- **Order Entity** → Validates delivery eligibility
- **User Entity** → Validates user addresses against zones, stores delivery addresses
- **Geography Entity** → Uses cities/provinces for location data
- **Admin Users Entity** → FK for audit columns (`created_by`, `updated_by`, `deleted_by`)

### Delivery Fee Lookup Flow

1. Query `delivery_and_pickup_configs` by `restaurant_id` → check `has_delivery_enabled`, `distance_based_delivery_fee`
2. If `has_delivery_enabled = false` → No delivery available
3. If `distance_based_delivery_fee = false` → Query `restaurant_delivery_areas.delivery_fee` (flat fee), use `ST_Contains()` for geometry check
4. If `distance_based_delivery_fee = true` → Calculate distance, query `restaurant_distance_based_delivery_fees` by `distance_in_km`, return `total_delivery_fee`

---

**Last Updated:** 2026-02-17
