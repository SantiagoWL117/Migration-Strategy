# Delivery Operations Entity - Business Rules & Logic

**Schema**: `menuca_v3`  
**Purpose**: Guide for developers and AI models to understand Delivery Operations business rules  
**Last Updated**: October 7, 2025

---

## Table of Contents

1. [Entity Overview](#entity-overview)
2. [Core Data Model](#core-data-model)
3. [Delivery Company Management](#delivery-company-management)
4. [Delivery Fees System](#delivery-fees-system)
5. [Partner Schedules](#partner-schedules)
6. [Phone Notifications (Twilio)](#phone-notifications-twilio)
7. [Delivery Areas (PostGIS)](#delivery-areas-postgis)
8. [Restaurant Delivery Configuration](#restaurant-delivery-configuration)
9. [Query Patterns](#query-patterns)
10. [Business Constraints](#business-constraints)

---

## Entity Overview

The Delivery Operations entity manages how restaurants fulfill delivery orders:

- **Delivery Companies**: Email addresses for third-party delivery partners
- **Delivery Fees**: Distance-based or area-based pricing structures
- **Partner Schedules**: When delivery partners are available to fulfill orders
- **Phone Notifications**: Twilio integration for calling restaurants when orders arrive
- **Delivery Areas**: PostGIS polygon-based delivery zones with geometry support
- **Delivery Configuration**: Per-restaurant partner credentials and enablement flags

**Key Principle**: Flexible delivery partner integration supporting multiple providers (Geodispatch, Tookan, WeDeliver) with configurable pricing and availability.

---

## Core Data Model

### Schema Structure

```
menuca_v3.restaurants (944 restaurants)
├── menuca_v3.delivery_company_emails (9 companies)
│   └── menuca_v3.restaurant_delivery_companies (160 relationships)
│       └── Links restaurants to delivery companies (many-to-many)
│
├── menuca_v3.restaurant_delivery_fees (210 fee records)
│   └── Distance-based or area-based fee structures
│
├── menuca_v3.restaurant_partner_schedules (7 schedules)
│   └── Delivery partner availability (restaurant 1635 only)
│
├── menuca_v3.restaurant_twilio_config (18 configs)
│   └── Phone notification settings
│
├── menuca_v3.restaurant_delivery_areas (47 areas)
│   └── PostGIS polygon delivery zones
│
└── menuca_v3.restaurant_delivery_config (825 configs)
    └── JSONB partner configuration and credentials
```

### Source Tracking

All records have legacy ID tracking fields:

- `legacy_v1_id`: V1 ID for cross-reference (where applicable)
- `legacy_v2_id`: V2 ID for cross-reference (where applicable)
- `notes`: Migration notes and source information

**Usage**: Always check legacy IDs when troubleshooting data lineage.

---

## Delivery Company Management

### Delivery Company Emails

**Table**: `menuca_v3.delivery_company_emails`

**Purpose**: Normalized master list of delivery company email addresses

**Core Fields**:
- `id`: Primary key (SMALLINT)
- `email`: Company email address (VARCHAR 255, UNIQUE)
- `company_name`: Optional company name (VARCHAR 100)
- `is_active`: Whether company is active (BOOLEAN, default TRUE)

**Business Rules**:

**Rule 1: Email Uniqueness**
- Each email can only appear once in the system
- Prevents duplicate delivery companies

**Rule 2: Email Format Validation**
- All emails must contain `@` and `.`
- Format: `%@%.%`

**Example**:
```sql
-- Get all active delivery companies
SELECT id, email, company_name
FROM menuca_v3.delivery_company_emails
WHERE is_active = TRUE
ORDER BY company_name;
```

---

### Restaurant-Company Relationships

**Table**: `menuca_v3.restaurant_delivery_companies`

**Purpose**: Many-to-many relationship between restaurants and delivery companies

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT)
- `company_email_id`: FK to delivery_company_emails (SMALLINT)
- `send_to_delivery`: Whether to send orders to this company (BOOLEAN)
- `disable_until`: Temporary suspension timestamp (TIMESTAMPTZ)
- `commission`: Delivery commission percentage (NUMERIC 5,2)
- `restaurant_pays_difference`: Restaurant's portion of delivery cost (NUMERIC 5,2)
- `notes`: Additional notes (TEXT)

**Business Rules**:

**Rule 1: Unique Restaurant-Company Pair**
- Constraint: `UNIQUE (restaurant_id, company_email_id)`
- A restaurant can't have duplicate relationships with same company

**Rule 2: Temporary Suspension**
- If `disable_until` is set and in the future, company is temporarily disabled
- Automatically re-enables when timestamp passes

**Rule 3: Commission Structure**
- Commission is a percentage (0-100)
- `restaurant_pays_difference` is the fixed amount restaurant pays

**Example**:
```sql
-- Get all delivery companies for a restaurant
SELECT 
  dce.email,
  dce.company_name,
  rdc.send_to_delivery,
  rdc.commission,
  rdc.disable_until,
  CASE 
    WHEN rdc.disable_until IS NOT NULL AND rdc.disable_until > NOW() 
    THEN 'Temporarily Disabled'
    WHEN rdc.send_to_delivery = FALSE 
    THEN 'Disabled'
    ELSE 'Active'
  END AS status
FROM menuca_v3.restaurant_delivery_companies rdc
JOIN menuca_v3.delivery_company_emails dce ON dce.id = rdc.company_email_id
WHERE rdc.restaurant_id = :restaurant_id
ORDER BY dce.company_name;
```

---

## Delivery Fees System

**Table**: `menuca_v3.restaurant_delivery_fees`

**Purpose**: Distance-based or area-based delivery fee structure per restaurant

### Fee Structure

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT)
- `company_email_id`: FK to delivery_company_emails (SMALLINT, OPTIONAL)
- `fee_type`: 'distance' or 'area' (VARCHAR 20)
- `tier_value`: Distance (km) or area number (SMALLINT)
- `total_delivery_fee`: Total delivery cost (NUMERIC 5,2)
- `driver_earning`: Driver's portion (NUMERIC 5,2)
- `restaurant_pays`: Restaurant's portion (NUMERIC 5,2)
- `vendor_pays`: Platform's portion (NUMERIC 5,2)

**Business Rules**:

**Rule 1: Fee Type**
- **'distance'**: Fee based on distance in kilometers
- **'area'**: Fee based on predefined area zones

**Rule 2: Tier Value**
- Must be > 0 (CHECK constraint)
- For 'distance': Represents distance in km (e.g., 5 = 0-5 km)
- For 'area': Represents area/zone number (e.g., 1 = Zone 1)

**Rule 3: Fee Breakdown**
- `total_delivery_fee` should equal `driver_earning + restaurant_pays + vendor_pays`
- Each component can be NULL (flexible cost allocation)

**Rule 4: Unique Fee Tiers**
- Constraint: `UNIQUE (restaurant_id, company_email_id, fee_type, tier_value)`
- Can't have duplicate fee tiers for same restaurant/company/type

### Distance-Based Fees

**Example**: Pizza restaurant with distance-based fees

```
Restaurant A:
├─ 0-5 km:  $5.00 (driver: $3.50, restaurant: $1.00, vendor: $0.50)
├─ 5-10 km: $7.50 (driver: $5.00, restaurant: $1.50, vendor: $1.00)
└─ 10-15 km: $10.00 (driver: $6.50, restaurant: $2.00, vendor: $1.50)
```

**Query Pattern**:
```sql
-- Get distance-based fees for a restaurant
SELECT 
  tier_value AS distance_km,
  total_delivery_fee,
  driver_earning,
  restaurant_pays,
  vendor_pays
FROM menuca_v3.restaurant_delivery_fees
WHERE restaurant_id = :restaurant_id
  AND fee_type = 'distance'
ORDER BY tier_value;
```

### Area-Based Fees (Tookan)

**Example**: Restaurant using Tookan with area-based zones

```
Restaurant B:
├─ Area 1: $6.00 (downtown)
├─ Area 2: $8.00 (suburbs)
└─ Area 3: $12.00 (outlying areas)
```

**Query Pattern**:
```sql
-- Get area-based fees for a restaurant
SELECT 
  tier_value AS area_number,
  total_delivery_fee,
  driver_earning,
  restaurant_pays,
  vendor_pays
FROM menuca_v3.restaurant_delivery_fees
WHERE restaurant_id = :restaurant_id
  AND fee_type = 'area'
ORDER BY tier_value;
```

---

## Partner Schedules

**Table**: `menuca_v3.restaurant_partner_schedules`

**Purpose**: When delivery partners are available to fulfill orders

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT)
- `company_email_id`: FK to delivery_company_emails (SMALLINT, OPTIONAL)
- `day_of_week`: 1-7 (1=Monday, 7=Sunday) (SMALLINT)
- `time_start`: Opening time (TIME)
- `time_stop`: Closing time (TIME)
- `is_enabled`: Whether schedule is active (BOOLEAN)

**Business Rules**:

**Rule 1: Day of Week**
- Values: 1-7 (1=Monday, 7=Sunday)
- CHECK constraint: `day_of_week BETWEEN 1 AND 7`

**Rule 2: Valid Time Range**
- CHECK constraint: `time_stop > time_start`
- Ensures closing time is after opening time

**Rule 3: Unique Schedule**
- Constraint: `UNIQUE (restaurant_id, company_email_id, day_of_week)`
- One schedule per restaurant/company/day

**Rule 4: Partner Schedule vs Restaurant Hours**
- This is the PARTNER's schedule (when they can deliver)
- NOT the restaurant's business hours
- Partner may have limited hours (e.g., dinner only)

**Example**: Restaurant 1635 Partner Schedule
```
Monday:    11:00 AM - 9:00 PM
Tuesday:   11:00 AM - 9:00 PM
Wednesday: 11:00 AM - 9:00 PM
Thursday:  11:00 AM - 9:00 PM
Friday:    11:00 AM - 10:00 PM
Saturday:  11:00 AM - 10:00 PM
Sunday:    12:00 PM - 8:00 PM
```

**Query Pattern**:
```sql
-- Check if delivery partner is available right now
SELECT 
  day_of_week,
  time_start,
  time_stop,
  is_enabled
FROM menuca_v3.restaurant_partner_schedules
WHERE restaurant_id = :restaurant_id
  AND day_of_week = EXTRACT(ISODOW FROM NOW()) -- Monday=1, Sunday=7
  AND time_start <= NOW()::TIME
  AND time_stop >= NOW()::TIME
  AND is_enabled = TRUE;
```

---

## Phone Notifications (Twilio)

**Table**: `menuca_v3.restaurant_twilio_config`

**Purpose**: Twilio phone notification configuration per restaurant

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT, UNIQUE)
- `enable_call`: Whether phone calls are enabled (BOOLEAN)
- `phone_number`: Phone number to call (VARCHAR 20)

**Business Rules**:

**Rule 1: One Config Per Restaurant**
- Constraint: `UNIQUE (restaurant_id)`
- Each restaurant can only have one Twilio configuration

**Rule 2: Phone Number Format**
- VARCHAR(20) to support international formats
- Example: "+1-555-123-4567", "(555) 123-4567"

**Rule 3: Enable/Disable Logic**
- If `enable_call = FALSE`, no calls are made
- If `enable_call = TRUE` but `phone_number IS NULL`, log error

**Use Cases**:
1. **Order Arrival Notification**: Call restaurant when order arrives at delivery partner
2. **Order Ready Reminder**: Call restaurant if order not picked up after X minutes
3. **Delivery Issue Alert**: Call restaurant if delivery partner has issue

**Example**:
```sql
-- Get Twilio config for a restaurant
SELECT 
  restaurant_id,
  enable_call,
  phone_number,
  CASE 
    WHEN enable_call = FALSE THEN 'Calls Disabled'
    WHEN phone_number IS NULL THEN 'No Phone Number'
    ELSE 'Active'
  END AS status
FROM menuca_v3.restaurant_twilio_config
WHERE restaurant_id = :restaurant_id;
```

---

## Delivery Areas (PostGIS)

**Table**: `menuca_v3.restaurant_delivery_areas`

**Purpose**: Delivery zones with PostGIS geometry polygon support

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT)
- `area_number`: Area identifier (INTEGER)
- `area_name`: Human-readable name (VARCHAR 255)
- `delivery_fee`: Fixed delivery fee for this area (NUMERIC 5,2)
- `min_order_value`: Minimum order required (NUMERIC 5,2)
- `is_complex`: Whether polygon is complex (BOOLEAN)
- `coordinates`: Original coords string (TEXT)
- `geometry`: PostGIS POLYGON (GEOMETRY(POLYGON, 4326))

**Business Rules**:

**Rule 1: Unique Area Number**
- Constraint: `UNIQUE (restaurant_id, area_number)`
- Each restaurant's area numbers must be unique

**Rule 2: PostGIS Geometry**
- SRID 4326 (WGS84 coordinate system)
- Polygon format: `POLYGON((lng1 lat1, lng2 lat2, ..., lng1 lat1))`
- Must be closed (first point = last point)

**Rule 3: Delivery Fee Structure**
- Can be free (delivery_fee = 0 or NULL)
- Can be flat fee (delivery_fee = 5.00)
- Can be conditional (see conditional fee parsing below)

**Rule 4: Minimum Order Value**
- Optional minimum order amount for this area
- If set, orders below this amount can't be delivered here

### Conditional Fee Parsing

**Fee Type Patterns**:

1. **Free Delivery**: `delivery_fee = "0"` or `NULL`
   ```json
   {
     "fee_type": "free",
     "delivery_fee": 0.00
   }
   ```

2. **Flat Fee**: `delivery_fee = "5"`
   ```json
   {
     "fee_type": "flat",
     "delivery_fee": 5.00
   }
   ```

3. **Conditional Fee**: `delivery_fee = "10 < 30"`
   ```json
   {
     "fee_type": "conditional",
     "conditional_fee": 10.00,
     "conditional_threshold": 30.00
   }
   ```
   **Meaning**: $10 delivery fee if order total is below $30, free if above $30

### PostGIS Geometry Queries

**Check if address is within delivery area**:
```sql
-- Check if a point (lat, lng) is within any delivery area
SELECT 
  area_number,
  area_name,
  delivery_fee,
  min_order_value,
  ST_Area(geometry::geography) / 1000000 AS area_km2
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id = :restaurant_id
  AND ST_Contains(
    geometry,
    ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
  )
  AND is_active = TRUE;
```

**Find all restaurants that deliver to a location**:
```sql
-- Find restaurants delivering to a specific point
SELECT 
  r.id,
  r.name,
  rda.area_name,
  rda.delivery_fee,
  rda.min_order_value
FROM menuca_v3.restaurant_delivery_areas rda
JOIN menuca_v3.restaurants r ON r.id = rda.restaurant_id
WHERE ST_Contains(
  rda.geometry,
  ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
)
  AND rda.is_active = TRUE
  AND r.is_active = TRUE
ORDER BY rda.delivery_fee;
```

**Calculate delivery area size**:
```sql
-- Get delivery area size in km²
SELECT 
  area_number,
  area_name,
  ST_Area(geometry::geography) / 1000000 AS area_km2,
  ST_Perimeter(geometry::geography) / 1000 AS perimeter_km
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id = :restaurant_id
ORDER BY area_number;
```

---

## Restaurant Delivery Configuration

**Table**: `menuca_v3.restaurant_delivery_config`

**Purpose**: Normalized delivery configuration and partner credentials per restaurant

**Core Fields**:
- `restaurant_id`: FK to restaurants (BIGINT, UNIQUE)
- `delivery_method`: 'areas', 'radius', 'polygon', or 'disabled' (VARCHAR 20)
- `delivery_radius_km`: Simple radius delivery in km (NUMERIC 5,2)
- `use_multiple_areas`: Whether using multiple area zones (BOOLEAN)
- `use_polygon_areas`: Whether using PostGIS polygons (BOOLEAN)
- `max_delivery_distance_km`: Maximum delivery distance (SMALLINT)
- `active_partners`: JSONB partner configuration
- `partner_credentials`: JSONB partner credentials (API keys, passwords)
- `disable_delivery_until`: Temporary suspension timestamp (TIMESTAMPTZ)

**Business Rules**:

**Rule 1: One Config Per Restaurant**
- Constraint: `UNIQUE (restaurant_id)`
- Each restaurant has exactly one delivery configuration

**Rule 2: Delivery Method Types**

1. **'areas'**: Area-based zones (most common, 94.5%)
   - Uses `restaurant_delivery_areas` table with area_number
   - Fee based on which area customer is in

2. **'radius'**: Simple radius delivery
   - Uses `delivery_radius_km` (e.g., 10 km radius)
   - Fee may be distance-based or flat

3. **'polygon'**: PostGIS polygon zones
   - Uses `restaurant_delivery_areas` table with geometry
   - Advanced spatial queries

4. **'disabled'**: Delivery not available (5.5%)
   - Restaurant doesn't offer delivery

**Rule 3: Partner Enablement Flags (Legacy V1)**
- `legacy_v1_send_to_delivery`: Old V1 flag preserved
- `legacy_v1_send_to_daily_delivery`: Old V1 flag preserved
- `legacy_v1_send_to_geodispatch`: Old V1 flag preserved
- `legacy_v1_tookan_delivery`: Old V1 flag preserved
- `legacy_v1_we_deliver`: Old V1 flag preserved
- `legacy_v1_twilio_call`: Old V1 flag preserved

**Rule 4: Temporary Suspension**
- If `disable_delivery_until` is set and in future, delivery is suspended
- Automatically re-enables when timestamp passes

### JSONB Active Partners Structure

**Format**:
```json
{
  "geodispatch": {
    "enabled": true,
    "username": "restaurant123",
    "email": "notify@geodispatch.com"
  },
  "tookan": {
    "enabled": false,
    "tags": "area1,area2,area3",
    "email": "tookan@delivery.com",
    "treat_as_pickup": false
  },
  "wedeliver": {
    "enabled": true,
    "email": "wedeliver@company.com",
    "driver_notes": "Call customer on arrival"
  }
}
```

**Query Pattern**:
```sql
-- Check if a specific partner is enabled
SELECT 
  restaurant_id,
  active_partners->'geodispatch'->>'enabled' AS geodispatch_enabled,
  active_partners->'tookan'->>'enabled' AS tookan_enabled,
  active_partners->'wedeliver'->>'enabled' AS wedeliver_enabled
FROM menuca_v3.restaurant_delivery_config
WHERE restaurant_id = :restaurant_id;
```

### JSONB Partner Credentials Structure

**Format** (⚠️ Should be encrypted in production):
```json
{
  "geodispatch": {
    "username": "restaurant123",
    "password": "ENCRYPTED_PASSWORD",
    "api_key": "GEO_API_KEY_HERE"
  }
}
```

**Security Note**: In production, `partner_credentials` should use PostgreSQL encryption or external secrets management.

---

## Query Patterns

### Common Use Cases

**1. Get Complete Delivery Configuration**
```sql
SELECT 
  rdc.delivery_method,
  rdc.delivery_radius_km,
  rdc.max_delivery_distance_km,
  rdc.active_partners,
  rdc.disable_delivery_until,
  CASE 
    WHEN rdc.disable_delivery_until IS NOT NULL AND rdc.disable_delivery_until > NOW() 
    THEN 'Temporarily Suspended'
    WHEN rdc.delivery_method = 'disabled' 
    THEN 'Disabled'
    ELSE 'Active'
  END AS delivery_status
FROM menuca_v3.restaurant_delivery_config rdc
WHERE rdc.restaurant_id = :restaurant_id;
```

**2. Calculate Delivery Fee for Address**
```sql
-- For area-based delivery
WITH customer_area AS (
  SELECT area_number
  FROM menuca_v3.restaurant_delivery_areas
  WHERE restaurant_id = :restaurant_id
    AND ST_Contains(
      geometry,
      ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)
    )
  LIMIT 1
)
SELECT 
  rdf.tier_value AS area_number,
  rdf.total_delivery_fee,
  rda.min_order_value
FROM menuca_v3.restaurant_delivery_fees rdf
JOIN customer_area ca ON ca.area_number = rdf.tier_value
LEFT JOIN menuca_v3.restaurant_delivery_areas rda 
  ON rda.restaurant_id = rdf.restaurant_id 
  AND rda.area_number = rdf.tier_value
WHERE rdf.restaurant_id = :restaurant_id
  AND rdf.fee_type = 'area';
```

**3. Get All Active Delivery Partners**
```sql
-- Get restaurants with active delivery partners
SELECT 
  r.id,
  r.name,
  rdc.delivery_method,
  jsonb_object_keys(rdc.active_partners) AS partner_name,
  rdc.active_partners->jsonb_object_keys(rdc.active_partners)->>'enabled' AS enabled
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_delivery_config rdc ON rdc.restaurant_id = r.id
WHERE rdc.active_partners->jsonb_object_keys(rdc.active_partners)->>'enabled' = 'true';
```

**4. Find Restaurants by Delivery Partner**
```sql
-- Find all restaurants using Geodispatch
SELECT 
  r.id,
  r.name,
  rdc.active_partners->'geodispatch'->>'email' AS geodispatch_email,
  rdc.active_partners->'geodispatch'->>'username' AS geodispatch_username
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_delivery_config rdc ON rdc.restaurant_id = r.id
WHERE rdc.active_partners->'geodispatch'->>'enabled' = 'true';
```

---

## Business Constraints

### Data Integrity Rules

**1. Restaurant Ownership**
- Every delivery config MUST belong to exactly one restaurant
- Delivery areas, fees, schedules all tied to restaurant

**2. Email Uniqueness**
- Delivery company emails must be unique
- Prevents duplicate company entries

**3. Positive Values**
- All delivery fees >= 0
- All tier values > 0 (CHECK constraint)
- All distances/radii >= 0

**4. Valid Time Ranges**
- Partner schedule: `time_stop > time_start`
- Ensures valid operating hours

**5. PostGIS Geometry**
- All geometries must be valid
- Use `ST_IsValid()` to check
- Use `ST_MakeValid()` to fix self-intersecting polygons

### Business Validation Rules

**1. Delivery Method Validation**
- If `delivery_method = 'areas'`, should have records in `restaurant_delivery_fees` with `fee_type = 'area'`
- If `delivery_method = 'polygon'`, should have records in `restaurant_delivery_areas` with valid geometry
- If `delivery_method = 'radius'`, should have `delivery_radius_km > 0`

**2. Partner Configuration**
- If partner enabled in `active_partners`, should have corresponding credentials (if needed)
- Geodispatch requires username, password, API key
- Tookan requires tags, email
- WeDeliver requires email

**3. Fee Structure Validation**
- `total_delivery_fee` should roughly equal `driver_earning + restaurant_pays + vendor_pays`
- Each component can be NULL (flexible allocation)

**4. Area Coverage**
- Restaurant should have at least one delivery area if `delivery_method != 'disabled'`
- Areas should not overlap (business rule, not enforced in DB)

---

## Migration Notes

### Data Quality Decisions

**Exclusions During Migration**:
1. ❌ Test restaurant data (IDs 450, 708, etc.)
2. ❌ V1 delivery_orders (1,513 rows - data no longer relevant)
3. ❌ V1 restaurants.deliveryArea BLOB (all NULL values)
4. ✅ V2 data prioritized over V1 when conflicts exist

**Result**: 1,276 high-quality records in production (100% FK integrity)

### Schema Evolution

**Changes from Legacy V1/V2**:
1. ✅ Email normalization (comma-separated → FK relationships)
2. ✅ PostGIS geometry (rebuilt from coordinate strings)
3. ✅ JSONB partner configuration (normalized from 18 columns)
4. ✅ Conditional fee parsing (string patterns → structured data)
5. ✅ Source tracking added (audit trail via legacy IDs)

---

## Future Enhancements

### Planned Features

1. **Credential Encryption** (High Priority)
   - Encrypt `partner_credentials` JSONB
   - Use PostgreSQL pgcrypto or external secrets manager

2. **Dynamic Fee Calculation** (Medium Priority)
   - Add surge pricing support
   - Time-based fee multipliers
   - Weather-based adjustments

3. **Partner API Integration** (Low Priority)
   - Real-time availability checks
   - Automated order dispatch
   - Delivery tracking webhooks

4. **Multi-Provider Support** (Low Priority)
   - Support multiple partners per restaurant simultaneously
   - Intelligent partner selection algorithm

---

## Quick Reference

### Key Tables
- `delivery_company_emails`: 9 companies
- `restaurant_delivery_companies`: 160 relationships
- `restaurant_delivery_fees`: 210 fee records
- `restaurant_partner_schedules`: 7 schedules (restaurant 1635)
- `restaurant_twilio_config`: 18 phone configs
- `restaurant_delivery_areas`: 47 PostGIS areas
- `restaurant_delivery_config`: 825 configurations

### Key JSONB Fields
- `restaurant_delivery_config.active_partners`: Partner enablement and settings
- `restaurant_delivery_config.partner_credentials`: API keys and passwords

### Key PostGIS Functions
- `ST_Contains(geometry, point)`: Check if point is within polygon
- `ST_Area(geometry::geography)`: Calculate area in m²
- `ST_IsValid(geometry)`: Validate geometry
- `ST_MakeValid(geometry)`: Fix invalid geometry

### Key Constraints
- Email uniqueness: `delivery_company_emails(email)`
- Tier value positive: `restaurant_delivery_fees(tier_value > 0)`
- Valid time range: `restaurant_partner_schedules(time_stop > time_start)`
- Day of week: `restaurant_partner_schedules(day_of_week BETWEEN 1 AND 7)`

---

**For migration details, see**: `MIGRATION_SUMMARY.md`

**Last Updated**: October 7, 2025  
**Schema Version**: menuca_v3 (production)

