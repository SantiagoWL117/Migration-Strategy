# V1 Delivery & Zones Entity - Column Mapping

**Purpose:** Identify V1 database columns needed to extract complete Delivery & Zones data  
**Source:** `restaurants_dump.sql` and related V1 tables  
**Date:** 2025-11-21

---

## 📊 V1 Data Structure Overview

The V1 system stores delivery data across **multiple tables** and uses **BLOB columns** for complex data (serialized PHP arrays).

---

## 🗂️ PRIMARY TABLE: `restaurants`

### Core Delivery Configuration Columns

| Column Position | Column Name     | Data Type     | Description                       | V3 Equivalent                                      |
| --------------- | --------------- | ------------- | --------------------------------- | -------------------------------------------------- |
| **21**          | `pickup`        | enum('1','0') | Pickup service enabled            | N/A (deprecated)                                   |
| **22**          | `delivery`      | enum('1','0') | Delivery service enabled          | `restaurant_service_configs.has_delivery_enabled`  |
| **23**          | `takeout`       | enum('1','0') | Takeout service enabled           | `restaurant_service_configs.takeout_enabled`       |
| **17**          | `delivery_time` | int unsigned  | Estimated delivery time (minutes) | `restaurant_service_configs.delivery_time_minutes` |
| **18**          | `takeout_time`  | int           | Estimated takeout time (minutes)  | `restaurant_service_configs.takeout_time_minutes`  |
| **25**          | `min_order`     | varchar(125)  | Minimum order amount              | `restaurant_service_configs.delivery_min_order`    |

### Delivery Coverage Columns

| Column Position | Column Name            | Data Type     | Description                                    | V3 Equivalent                                   |
| --------------- | ---------------------- | ------------- | ---------------------------------------------- | ----------------------------------------------- |
| **31**          | `deliveryRadius`       | float         | Delivery radius in KM                          | `restaurant_delivery_config.delivery_radius_km` |
| **32**          | `multipleDeliveryArea` | enum('Y','N') | Use multiple delivery areas                    | `restaurant_delivery_config.use_multiple_areas` |
| **33**          | `deliveryArea`         | **BLOB**      | ⚠️ Serialized PHP array of polygon coordinates | `restaurant_delivery_areas` table               |
| **9**           | `delivery_schedule`    | **BLOB**      | ⚠️ Serialized delivery hours                   | `restaurant_schedules` table                    |
| **103**         | `deliverToArea`        | varchar(125)  | Neighborhood names covered                     | `restaurant_delivery_areas.area_name`           |

### Delivery Fees & Charges

| Column Position | Column Name                  | Data Type     | Description                          | V3 Equivalent                                           |
| --------------- | ---------------------------- | ------------- | ------------------------------------ | ------------------------------------------------------- |
| **24**          | `fee`                        | **BLOB**      | ⚠️ Serialized delivery fee structure | `restaurant_delivery_fees` table                        |
| **133**         | `restaurant_delivery_charge` | decimal(5,2)  | What restaurant pays for delivery    | `restaurant_delivery_config.restaurant_delivery_charge` |
| **141**         | `deliveryServiceExtra`       | decimal(5,2)  | Extra delivery service fees          | `restaurant_delivery_config.delivery_service_extra`     |
| **142**         | `use_delivery_areas`         | enum('y','n') | Use areas vs distance-based fees     | `restaurant_delivery_config.delivery_method`            |
| **143**         | `delivery_restaurant_id`     | int           | Shared delivery config ID            | N/A                                                     |
| **144**         | `max_delivery_distance`      | tinyint       | Max delivery distance                | `restaurant_delivery_config.max_delivery_distance_km`   |
| **145**         | `disable_delivery_until`     | datetime      | Temp disable delivery                | `restaurant_delivery_config.disable_delivery_until`     |

### Third-Party Delivery Integration

| Column Position | Column Name                 | Data Type     | Description                 | V3 Equivalent                                                 |
| --------------- | --------------------------- | ------------- | --------------------------- | ------------------------------------------------------------- |
| **109**         | `sendToDelivery`            | enum('y','n') | Send to delivery company    | `restaurant_delivery_config.legacy_v1_send_to_delivery`       |
| **110**         | `sendToDailyDelivery`       | enum('Y','N') | Send to Daily Delivery      | `restaurant_delivery_config.legacy_v1_send_to_daily_delivery` |
| **111**         | `sendToGeodispatch`         | enum('Y','N') | Send to GeoDispatch         | `restaurant_delivery_config.legacy_v1_send_to_geodispatch`    |
| **112**         | `geodispatch_username`      | varchar(125)  | GeoDispatch username        | N/A                                                           |
| **113**         | `geodispatch_password`      | varchar(125)  | GeoDispatch password        | N/A                                                           |
| **114**         | `geodispatch_api_key`       | varchar(125)  | GeoDispatch API key         | N/A                                                           |
| **115**         | `sendToDelivery_email`      | varchar(125)  | Delivery company email      | N/A                                                           |
| **134**         | `tookan_delivery`           | enum('y','n') | Tookan delivery integration | `restaurant_delivery_config.legacy_v1_tookan_delivery`        |
| **135**         | `tookan_tags`               | varchar(125)  | Tookan tags                 | N/A                                                           |
| **136**         | `tookan_restaurant_email`   | varchar(125)  | Tookan email                | N/A                                                           |
| **137**         | `tookan_delivery_as_pickup` | enum('y','n') | Tookan as pickup            | N/A                                                           |
| **138**         | `weDeliver`                 | enum('y','n') | WeDeliver integration       | `restaurant_delivery_config.legacy_v1_we_deliver`             |
| **139**         | `weDeliver_driver_notes`    | text          | WeDeliver driver notes      | N/A                                                           |
| **140**         | `weDeliverEmail`            | varchar(125)  | WeDeliver email             | N/A                                                           |
| **146**         | `twilio_call`               | enum('y','n') | Twilio call notifications   | `restaurant_delivery_config.legacy_v1_twilio_call`            |

---

## 🗂️ RELATED TABLES (Separate Dumps Required)

### 1. `distance_fees` (Distance-Based Pricing)

Maps to: `menuca_v3.restaurant_delivery_fees`

| Column            | Type         | Description                      |
| ----------------- | ------------ | -------------------------------- |
| `restaurant_id`   | int          | Restaurant ID                    |
| `distance`        | tinyint      | Distance tier (KM)               |
| `driver_earning`  | decimal(5,2) | Driver earnings                  |
| `restaurant_pays` | decimal(5,2) | Restaurant pays                  |
| `vendor_pays`     | decimal(5,2) | Vendor pays                      |
| `delivery_fee`    | varchar(125) | Delivery fee charged to customer |

### 2. `restaurant_delivery_areas` (Polygon-Based Zones)

Maps to: `menuca_v3.restaurant_delivery_areas`

| Column          | Type         | Description                         |
| --------------- | ------------ | ----------------------------------- |
| `restaurant_id` | int          | Restaurant ID                       |
| `area_number`   | int          | Area sequence number                |
| `area_name`     | varchar(255) | Zone name                           |
| `delivery_fee`  | text         | Fee for this zone                   |
| `coords`        | text         | Polygon coordinates (lat/lng pairs) |

### 3. `delivery_schedule` (Delivery Hours)

Maps to: `menuca_v3.restaurant_schedules`

| Column          | Type    | Description                  |
| --------------- | ------- | ---------------------------- |
| `restaurant_id` | int     | Restaurant ID                |
| `day`           | char(3) | Day of week (mon, tue, etc.) |
| `start`         | time    | Start time                   |
| `stop`          | time    | Stop time                    |

### 4. `extra_delivery_fees` (Peak Hour Surcharges)

Maps to: Custom pricing logic in V3

| Column            | Type         | Description                 |
| ----------------- | ------------ | --------------------------- |
| `restaurant_id`   | int          | Restaurant ID               |
| `extra_fee`       | decimal(5,2) | Surcharge amount            |
| `available_from`  | int          | Start time (Unix timestamp) |
| `available_until` | int          | End time (Unix timestamp)   |

### 5. `delivery_info` (Third-Party Delivery Config)

Maps to: `menuca_v3.restaurant_delivery_companies`

| Column           | Type          | Description                 |
| ---------------- | ------------- | --------------------------- |
| `restaurant_id`  | int           | Restaurant ID               |
| `sendToDelivery` | enum('y','n') | Enable third-party delivery |
| `disable_until`  | datetime      | Temp disable until          |
| `email`          | varchar(255)  | Delivery company email      |
| `notes`          | varchar(255)  | Notes                       |
| `commission`     | decimal(5,2)  | Commission rate             |
| `rpd`            | decimal(5,2)  | Restaurant pays difference  |

---

## ⚠️ CRITICAL CHALLENGES

### 1. **BLOB Columns (Serialized PHP Arrays)**

Three key columns store complex data as serialized PHP:

- `deliveryArea` (column 33) - Polygon coordinates
- `delivery_schedule` (column 9) - Operating hours
- `fee` (column 24) - Fee structure

**Problem:** These require PHP deserialization to extract actual data.

**Example serialized format:**

```php
a:2:{s:5:"start";a:7:{s:3:"mon";a:3:{s:2:"i1";s:5:"09:00";...}}}
```

### 2. **Multiple Data Sources**

Complete delivery data requires querying **5+ separate tables**, not just the `restaurants` table.

### 3. **Data Migration Already Complete**

All V1 data has been migrated to V3 in structured format (no BLOBs).

---

## ✅ RECOMMENDED APPROACH

### Option A: Extract from V3 (RECOMMENDED)

- ✅ All V1 data already migrated
- ✅ Proper relational structure
- ✅ No BLOB parsing needed
- ✅ Faster and more reliable

### Option B: Parse V1 Dump (Complex)

- ❌ Requires PHP deserialization library
- ❌ Must query 5+ separate tables
- ❌ Risk of encoding issues
- ❌ Time-consuming

---

## 📋 COLUMN POSITIONS FOR EXTRACTION

If extracting from V1 dump, here are the key column positions in order:

```
Position    Column Name
--------    -----------
1           id
4           name
5           address
6           city
7           province
9           delivery_schedule (BLOB)
17          delivery_time
18          takeout_time
20          zip
22          delivery (enum)
23          takeout (enum)
24          fee (BLOB)
25          min_order
29          latitude
30          longitude
31          deliveryRadius
32          multipleDeliveryArea
33          deliveryArea (BLOB)
103         deliverToArea
109         sendToDelivery
110         sendToDailyDelivery
111         sendToGeodispatch
133         restaurant_delivery_charge
134         tookan_delivery
138         weDeliver
141         deliveryServiceExtra
142         use_delivery_areas
143         delivery_restaurant_id
144         max_delivery_distance
145         disable_delivery_until
146         twilio_call
```

---

## 🎯 NEXT STEPS

**Question for User:** Should we:

1. **Extract from V3 database** (structured, clean data) ✅ RECOMMENDED
2. **Parse V1 dump** (requires BLOB deserialization, complex)
3. **Both** (for validation/comparison)

**Awaiting confirmation on approach before proceeding with extraction.**
