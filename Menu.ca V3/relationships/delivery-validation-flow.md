# Delivery Validation Flow

> **Delivery Eligibility Logic** - How the system validates delivery orders

---

## 📋 Overview

When a customer places a delivery order, the system must validate:
1. Restaurant is open and accepting orders
2. Customer address is within delivery zone
3. Order meets minimum requirements
4. Delivery time slot is available

---

## 🔄 Validation Flow

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         DELIVERY VALIDATION FLOW                          │
└───────────────────────────────────────────────────────────────────────────┘

   Customer Request                    Tables Consulted
   ─────────────────                   ─────────────────
         │
         ▼
┌─────────────────────┐
│ 1. Check Restaurant │────────────► restaurants.status = 'active'
│    Status           │              restaurants.online_ordering_enabled = true
└─────────┬───────────┘              restaurants.deleted_at IS NULL
         │
         ▼
┌─────────────────────┐
│ 2. Check Service    │────────────► restaurant_service_configs.has_delivery_enabled
│    Config           │              restaurant_delivery_config.disable_delivery_until
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│ 3. Check Operating  │────────────► restaurant_schedules (current day/time)
│    Hours            │              restaurant_special_schedules (holidays)
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│ 4. Validate Address │────────────► user_addresses OR guest_checkouts
│    Coordinates      │              (latitude, longitude required)
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐              restaurant_delivery_zones
│ 5. Check Delivery   │────────────► restaurant_delivery_areas
│    Zone Match       │              (polygon, radius, or postal code match)
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│ 6. Get Delivery Fee │────────────► restaurant_delivery_zones.delivery_fee
│    & Minimum Order  │              restaurant_delivery_zones.minimum_order
└─────────┬───────────┘
         │
         ▼
┌─────────────────────┐
│ 7. Validate Order   │────────────► carts.subtotal >= minimum_order
│    Total            │
└─────────┬───────────┘
         │
         ▼
    ✅ ORDER VALID
```

---

## 📊 Tables Involved

### Primary Tables

| Table | Role in Validation |
|-------|-------------------|
| `restaurants` | Status check |
| `restaurant_service_configs` | Delivery enabled |
| `restaurant_delivery_config` | Advanced delivery settings |
| `restaurant_schedules` | Operating hours |
| `restaurant_special_schedules` | Holiday hours |
| `restaurant_delivery_zones` | Zone definitions |
| `restaurant_delivery_areas` | Area boundaries |

### Secondary Tables

| Table | Role in Validation |
|-------|-------------------|
| `user_addresses` | Customer location |
| `guest_checkouts` | Guest customer location |
| `carts` | Order total |
| `restaurant_locations` | Restaurant origin point |

---

## 🔧 Key SQL Functions

### Check Restaurant Open Status

```sql
CREATE OR REPLACE FUNCTION menuca_v3.is_restaurant_open(
    p_restaurant_id bigint,
    p_timestamp timestamptz DEFAULT NOW()
)
RETURNS boolean AS $$
DECLARE
    v_timezone varchar;
    v_local_time time;
    v_day_of_week integer;
    v_is_open boolean;
BEGIN
    -- Get restaurant timezone
    SELECT timezone INTO v_timezone
    FROM menuca_v3.restaurants
    WHERE id = p_restaurant_id;
    
    -- Convert to local time
    v_local_time := (p_timestamp AT TIME ZONE COALESCE(v_timezone, 'America/Toronto'))::time;
    v_day_of_week := EXTRACT(DOW FROM p_timestamp AT TIME ZONE COALESCE(v_timezone, 'America/Toronto'));
    
    -- Check special schedule first (holidays)
    SELECT NOT is_closed INTO v_is_open
    FROM menuca_v3.restaurant_special_schedules
    WHERE restaurant_id = p_restaurant_id
    AND date = (p_timestamp AT TIME ZONE COALESCE(v_timezone, 'America/Toronto'))::date;
    
    IF FOUND THEN
        RETURN v_is_open;
    END IF;
    
    -- Check regular schedule
    SELECT 
        NOT is_closed 
        AND v_local_time BETWEEN open_time AND close_time
    INTO v_is_open
    FROM menuca_v3.restaurant_schedules
    WHERE restaurant_id = p_restaurant_id
    AND day_of_week = v_day_of_week;
    
    RETURN COALESCE(v_is_open, false);
END;
$$ LANGUAGE plpgsql;
```

### Check Address in Delivery Zone

```sql
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
) AS $$
BEGIN
    -- Check radius-based zones first
    RETURN QUERY
    SELECT 
        true,
        rdz.id,
        rdz.delivery_fee,
        rdz.minimum_order,
        rdz.estimated_time_minutes
    FROM menuca_v3.restaurant_delivery_zones rdz
    JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = rdz.restaurant_id AND rl.is_primary = true
    WHERE rdz.restaurant_id = p_restaurant_id
    AND rdz.is_active = true
    AND rdz.zone_type = 'radius'
    AND (
        6371 * acos(
            cos(radians(rl.latitude)) * cos(radians(p_latitude)) *
            cos(radians(p_longitude) - radians(rl.longitude)) +
            sin(radians(rl.latitude)) * sin(radians(p_latitude))
        )
    ) <= rdz.radius_km
    ORDER BY rdz.priority
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::bigint, NULL::numeric, NULL::numeric, NULL::integer;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

---

## 📝 Validation Error Codes

| Code | Message | Condition |
|------|---------|-----------|
| `RESTAURANT_CLOSED` | Restaurant is currently closed | Schedule check fails |
| `DELIVERY_DISABLED` | Delivery is not available | has_delivery_enabled = false |
| `ADDRESS_NOT_DELIVERABLE` | Address outside delivery area | No zone match |
| `MINIMUM_NOT_MET` | Order below minimum | subtotal < minimum_order |
| `PREORDER_TOO_FAR` | Preorder time too far ahead | Exceeds preorder_time_frame |

---

## 🔍 Edge Cases

1. **Multiple Zone Match**: Use `priority` field to select best zone
2. **Boundary Addresses**: Default to excluding boundary cases
3. **Timezone Issues**: Always use restaurant's timezone
4. **Temporary Closures**: Check `disable_delivery_until`

---

**Last Updated:** 2025-11-27

