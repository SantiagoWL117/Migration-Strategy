# Restaurant Hub Relationships

> **Central Entity Connections** - How restaurants connect to everything else

---

## 📋 Overview

The `restaurants` table is the **central hub** of the menuca_v3 schema. Almost every other table has a direct or indirect foreign key relationship to restaurants.

---

## 🔗 Direct Relationships

### Configuration Tables

```
restaurants
    ├── restaurant_locations (1:N)
    │   └── stores addresses, coordinates, phone
    │
    ├── restaurant_service_configs (1:1)
    │   └── delivery, takeout, tips settings
    │
    ├── restaurant_delivery_config (1:1)
    │   └── advanced delivery settings
    │
    ├── restaurant_twilio_config (1:1)
    │   └── phone/SMS integration
    │
    └── restaurant_contacts (1:N)
        └── additional contact people
```

### Schedule Tables

```
restaurants
    ├── restaurant_schedules (1:7)
    │   └── weekly operating hours
    │
    ├── restaurant_special_schedules (1:N)
    │   └── holiday/exception hours
    │
    ├── restaurant_time_periods (1:N)
    │   └── time slot definitions
    │
    └── restaurant_partner_schedules (1:N)
        └── delivery partner availability
```

### Delivery Zone Tables

```
restaurants
    ├── restaurant_delivery_zones (1:N)
    │   └── zone definitions with fees
    │
    ├── restaurant_delivery_areas (1:N)
    │   └── detailed area configurations
    │
    ├── restaurant_delivery_companies (1:N)
    │   └── delivery service providers
    │
    └── restaurant_delivery_fees (1:N)
        └── fee structures
```

### Menu Tables

```
restaurants
    ├── courses (1:N)
    │   └── menu categories
    │
    ├── dishes (1:N)
    │   └── menu items
    │
    ├── dish_modifiers (1:N)
    │   └── customization options
    │
    └── dish_modifier_prices (1:N)
        └── modifier pricing
```

### Order Tables

```
restaurants
    ├── orders (1:N)
    │   └── customer orders
    │
    └── carts (1:N)
        └── shopping carts
```

### Admin/Access Tables

```
restaurants
    ├── admin_restaurant_access (N:M via admin_users)
    │   └── admin permissions
    │
    └── vendor_restaurants (N:M via vendors)
        └── vendor relationships
```

---

## 📊 Entity Relationship Diagram

```
                              ┌─────────────────┐
                              │   restaurants   │
                              └────────┬────────┘
                                       │
       ┌───────────────┬───────────────┼───────────────┬───────────────┐
       │               │               │               │               │
       ▼               ▼               ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  locations   │ │   configs    │ │  schedules   │ │    zones     │ │    menu      │
├──────────────┤ ├──────────────┤ ├──────────────┤ ├──────────────┤ ├──────────────┤
│ addresses    │ │ service_cfg  │ │ weekly hrs   │ │ delivery     │ │ courses      │
│ coordinates  │ │ delivery_cfg │ │ special hrs  │ │ areas        │ │ dishes       │
│ phone/email  │ │ twilio_cfg   │ │ time periods │ │ companies    │ │ modifiers    │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
                                                                           │
                                                                           ▼
                                                                    ┌──────────────┐
                                                                    │    orders    │
                                                                    ├──────────────┤
                                                                    │ order_items  │
                                                                    │ payments     │
                                                                    └──────────────┘
```

---

## 🔑 Key Foreign Key Constraints

### From `restaurant_id` Column

| Table | Constraint Name | On Delete |
|-------|----------------|-----------|
| `restaurant_locations` | `fk_restaurant` | CASCADE |
| `restaurant_service_configs` | `fk_restaurant` | CASCADE |
| `restaurant_schedules` | `fk_restaurant` | CASCADE |
| `restaurant_delivery_zones` | `fk_restaurant` | CASCADE |
| `courses` | `fk_restaurant` | CASCADE |
| `dishes` | `fk_restaurant` | CASCADE |
| `orders` | `fk_restaurant` | RESTRICT |

---

## 💡 Usage Patterns

### Get Full Restaurant Profile

```sql
SELECT 
    r.*,
    rl.street_address, rl.city_id, rl.latitude, rl.longitude,
    rsc.has_delivery_enabled, rsc.takeout_enabled
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id AND rl.is_primary = true
LEFT JOIN menuca_v3.restaurant_service_configs rsc ON rsc.restaurant_id = r.id
WHERE r.id = :restaurant_id
AND r.deleted_at IS NULL;
```

### Get Restaurant with Schedule

```sql
SELECT 
    r.id, r.name,
    rs.day_of_week, rs.open_time, rs.close_time
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules rs ON rs.restaurant_id = r.id
WHERE r.id = :restaurant_id
AND r.deleted_at IS NULL
ORDER BY rs.day_of_week;
```

---

## ⚠️ Data Integrity Considerations

1. **Cascading Deletes**: Most child tables cascade on restaurant deletion
2. **Soft Deletion**: Use `deleted_at` on restaurants, cascades to children
3. **Orphan Prevention**: All child records require valid `restaurant_id`
4. **Required Children**: Some tables should always have records:
   - `restaurant_service_configs` (1:1 required)
   - `restaurant_schedules` (7 records required)
   - `restaurant_locations` (at least 1 required)

---

**Last Updated:** 2025-11-27

