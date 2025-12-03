# Delivery Zones Entity - Agent Handoff

> **Last Updated:** 2025-12-03  
> **Status:** ✅ Clean and Ready for Production

---

## 🎯 Quick Reference

### What This Entity Manages

| Aspect | Table | Description |
|--------|-------|-------------|
| **WHEN** can restaurants deliver? | `restaurant_schedules` | Operating hours by day |
| **IF** delivery/pickup is enabled | `delivery_and_pickup_configs` | Service on/off switches |
| **WHERE** can restaurants deliver? | `restaurant_delivery_areas` | Polygon zones + flat fees |
| **HOW MUCH** for distance-based? | `restaurant_distance_based_delivery_fees` | Fee tiers by km |
| **WHO** delivers? | `restaurant_delivery_companies` + `delivery_company_emails` | Third-party delivery partners |

---

## 📊 Tables Overview

### Core Tables (6 active)

| Table | Rows | Purpose |
|-------|------|---------|
| `restaurant_schedules` | 2,890 | Daily operating hours (delivery/takeout/dine-in) |
| `restaurant_special_schedules` | 0 | Holiday/vacation closures (empty, ready for use) |
| `delivery_and_pickup_configs` | 185 | Delivery/pickup enabled flags + ordering settings |
| `restaurant_delivery_areas` | 235 | **MAIN** delivery zones with geometry + flat fees |
| `restaurant_distance_based_delivery_fees` | 44 | Distance-based fee tiers (5-10 km) |
| `delivery_company_emails` | 9 | Shared delivery company contacts |
| `restaurant_delivery_companies` | 18 | Restaurant ↔ delivery company links |
| `user_delivery_addresses` | 0 | Customer saved addresses (empty, ready for use) |

### Supporting Views (3)

| View | Purpose |
|------|---------|
| `v_midnight_crossing_schedules` | Schedules that cross midnight |
| `v_schedule_conflicts` | Overlapping schedule detection |
| `v_schedule_coverage` | Coverage gap analysis |

---

## 🔑 Key Concepts

### Delivery Fee Types

There are **TWO** types of delivery fees:

#### 1. Flat Fee (227 restaurants)
- Stored in: `restaurant_delivery_areas.delivery_fee`
- Flag: `distance_based_delivery_fee = false`
- Example: $3.00 flat fee for any address in zone

#### 2. Distance-Based Fee (8 restaurants)
- Stored in: `restaurant_distance_based_delivery_fees`
- Flag: `restaurant_delivery_areas.distance_based_delivery_fee = true`
- Example: $5.00 for 5km, $6.00 for 6km, etc.

### Where to Find What

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DELIVERY FEE LOOKUP                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Check restaurant_delivery_areas.distance_based_delivery_fee    │
│                                                                     │
│     ├─ FALSE → Use restaurant_delivery_areas.delivery_fee          │
│     │          (flat fee for the zone)                              │
│     │                                                               │
│     └─ TRUE  → Query restaurant_distance_based_delivery_fees       │
│                by restaurant_id + distance_in_km                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Table Relationships

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                              restaurants                                        │
│                                  (185)                                          │
└──────────────────────────────────┬─────────────────────────────────────────────┘
                                   │ restaurant_id
          ┌────────────────────────┼────────────────────────────────┐
          │                        │                                │
          ▼                        ▼                                ▼
┌─────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────────┐
│ delivery_and_pickup │  │ restaurant_delivery_    │  │ restaurant_schedules        │
│ _configs (185)      │  │ areas (235)             │  │ (2,890)                     │
├─────────────────────┤  ├─────────────────────────┤  ├─────────────────────────────┤
│ has_delivery_enabled│  │ geometry (polygon)      │  │ type (delivery/takeout)     │
│ pickup_enabled      │  │ delivery_fee (flat)     │  │ day_start, day_stop         │
│ takeout_time_minutes│  │ delivery_min_order      │  │ time_start, time_stop       │
│ twilio_call         │  │ distance_based_fee ─────┼──┼───────────────┐             │
│ closing_warning_min │  │ estimated_delivery_min  │  │               │             │
└─────────────────────┘  └─────────────────────────┘  └───────────────┼─────────────┘
                                                                      │
                                                                      │ IF true
                                                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    restaurant_distance_based_delivery_fees (44)                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│ restaurant_id │ distance_in_km │ total_delivery_fee │ driver_earning │          │
│ company_email_id ──────────────┼────────────────────┤ restaurant_pays│          │
│               │                │                    │ vendor_pays    │          │
└───────────────┼────────────────┴────────────────────┴────────────────┴──────────┘
                │
                │ company_email_id
                ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    restaurant_delivery_companies (18)                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│ restaurant_id │ company_email_id ─────────┐ │ commission │ restaurant_pays_diff │
└───────────────┴───────────────────────────┼─┴────────────┴──────────────────────┘
                                            │
                                            ▼
                              ┌─────────────────────────────┐
                              │ delivery_company_emails (9) │
                              ├─────────────────────────────┤
                              │ email (unique)              │
                              │ company_name                │
                              └─────────────────────────────┘
```

---

## 📋 Common Queries

### Check if restaurant delivers to an address

```sql
-- 1. First check if delivery is enabled
SELECT has_delivery_enabled 
FROM menuca_v3.delivery_and_pickup_configs 
WHERE restaurant_id = :restaurant_id;

-- 2. If enabled, check if address is in delivery zone
SELECT id, delivery_fee, delivery_min_order, distance_based_delivery_fee
FROM menuca_v3.restaurant_delivery_areas
WHERE restaurant_id = :restaurant_id
AND ST_Contains(geometry, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))
AND is_active = true AND deleted_at IS NULL;
```

### Get delivery fee for distance-based restaurant

```sql
SELECT distance_in_km, total_delivery_fee, driver_earning, restaurant_pays, vendor_pays
FROM menuca_v3.restaurant_distance_based_delivery_fees
WHERE restaurant_id = :restaurant_id
AND distance_in_km = :distance_km
AND is_active = true;
```

### Get restaurant schedule for a specific day

```sql
SELECT type, time_start, time_stop, is_enabled
FROM menuca_v3.restaurant_schedules
WHERE restaurant_id = :restaurant_id
AND day_start = :day_of_week  -- 1=Monday, 7=Sunday
AND deleted_at IS NULL;
```

---

## ⚙️ SQL Functions

### Schedule Functions (10)

| Function | Purpose |
|----------|---------|
| `check_schedule_overlap(...)` | Check if schedule overlaps with existing |
| `has_schedule_conflict(...)` | Validate schedule doesn't conflict |
| `clone_schedule_to_day(...)` | Copy schedule from one day to another |
| `bulk_copy_schedule_onboarding(...)` | Bulk copy schedules during onboarding |
| `bulk_toggle_schedules(...)` | Enable/disable multiple schedules |
| `apply_schedule_template_onboarding(...)` | Apply schedule template |
| `notify_schedule_change()` | Trigger function for real-time updates |
| `soft_delete_schedule(...)` | Soft delete a schedule |
| `restore_schedule(...)` | Restore a soft-deleted schedule |
| `validate_timezone(...)` | Validate timezone string |

### Delivery Zone Functions (5)

| Function | Purpose |
|----------|---------|
| `soft_delete_delivery_zone(...)` | Soft delete a delivery zone |
| `restore_delivery_zone(...)` | Restore a soft-deleted zone |
| `toggle_delivery_zone_status(...)` | Enable/disable delivery zone |
| `find_nearby_restaurants(...)` | Find restaurants near a location |
| `find_nearest_franchise_locations(...)` | Find franchise locations that can deliver |

---

## ⚡ Edge Functions

| Function | Endpoint | Purpose |
|----------|----------|---------|
| `delete-delivery-zone` | DELETE /delete-delivery-zone | Soft delete delivery zone via API |

---

## 🚨 Important Notes

### Deleted Tables (DO NOT USE)
- ~~`restaurant_delivery_config`~~ - DELETED (legacy)
- ~~`restaurant_time_periods`~~ - DELETED
- ~~`restaurant_partner_schedules`~~ - DELETED
- ~~`schedule_translations`~~ - DELETED
- ~~`restaurant_delivery_zones`~~ - DELETED (consolidated into `restaurant_delivery_areas`)

### Deleted SQL Functions (DO NOT CALL)
- ~~`create_delivery_zone`~~ - DELETED
- ~~`create_delivery_zone_onboarding`~~ - DELETED
- ~~`update_delivery_zone`~~ - DELETED
- ~~`get_restaurant_delivery_summary`~~ - DELETED
- ~~`is_address_in_delivery_zone`~~ - DELETED
- ~~`get_restaurant_schedule`~~ - DELETED
- ~~`get_delivery_zone_area_sq_km`~~ - DELETED
- ~~`get_upcoming_schedule_changes`~~ - DELETED

### Renamed Tables
- `restaurant_service_configs` → `delivery_and_pickup_configs`
- `restaurant_delivery_fees` → `restaurant_distance_based_delivery_fees`

### Renamed Columns
- `min_order_value` → `delivery_min_order` (in `restaurant_delivery_areas`)
- `tier_value` → `distance_in_km` (in `restaurant_distance_based_delivery_fees`)
- `restaurant_pays_driver` → `restaurant_pays_difference` (in `restaurant_delivery_companies`)

---

## 📈 Data Quality Summary

| Table | Coverage | Notes |
|-------|----------|-------|
| `delivery_and_pickup_configs` | 100% | All 185 restaurants have configs |
| `restaurant_delivery_areas` | 181/185 | 4 Colonnade Pizza = pickup only |
| `restaurant_schedules` | 100% | All restaurants have schedules |
| `delivery_fee` | 97% | 6 missing use distance-based |
| `geometry` | 92% | 19 missing use distance-based or no delivery |

---

## 🔄 Distance-Based Fee Restaurants (8)

| Restaurant | V3 ID | Fee Tiers | Delivery Companies |
|------------|-------|-----------|-------------------|
| Centertown Donair & Pizza | 131 | 4 | 3 |
| Champa Thai Cuisine | 87 | 6 | 3 |
| Charm Thai Cuisine | 943 | 4 | 0 |
| Lemongrass Thai Cuisine | 1010 | 6 | 3 |
| New Mee Fung Restaurant | 15 | 4 | 0 |
| Oh My Grill | 807 | 6 | 3 |
| Pho Bo Ga King - Somerset | 199 | 4 | 0 |
| Sushiyana | 847 | 6 | 3 |

---

## ✅ Validation Checklist

Before making changes to this entity:

- [ ] All restaurants have a record in `delivery_and_pickup_configs`
- [ ] Restaurants with `has_delivery_enabled = true` have at least one delivery area
- [ ] Distance-based restaurants have `distance_based_delivery_fee = true` in areas
- [ ] Distance-based restaurants have fee tiers in `restaurant_distance_based_delivery_fees`
- [ ] All schedules have valid time ranges
- [ ] No schedule conflicts exist (check `v_schedule_conflicts`)

---

**Questions?** Check the full documentation at `Menu.ca V3/entities/02-delivery-zones-entity.md`

