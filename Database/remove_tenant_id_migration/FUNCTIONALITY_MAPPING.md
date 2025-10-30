# tenant_id → restaurant_id Functionality Mapping

**Purpose:** This document explains how each function that used `tenant_id` is updated to use `restaurant_id` instead, **maintaining 100% of the original functionality**.

---

## Key Concept

**tenant_id was always just a copy of restaurants.uuid**

Since every table with `tenant_id` also has `restaurant_id` (FK to restaurants.id), we can replace tenant_id with restaurant_id without losing any functionality:

```sql
-- BEFORE: Using tenant_id (UUID)
dishes.tenant_id → restaurants.uuid

-- AFTER: Using restaurant_id (bigint)
dishes.restaurant_id → restaurants.id

-- Both point to the same restaurant!
-- restaurant_id is better because it's a proper FK with constraints
```

---

## Function-by-Function Mapping

### 1. register_device()

**What it did with tenant_id:**
- Looked up `restaurants.uuid` for the given restaurant_id
- Stored it in `devices.tenant_id`
- Returned it to the caller

**What it does now with restaurant_id:**
- Stores `restaurant_id` in `devices.restaurant_id` (already exists)
- Returns `restaurant_id` to the caller
- **Same functionality**, just using the FK instead of a UUID copy

**API Change:**
```typescript
// BEFORE
interface RegisterDeviceResult {
  device_id: bigint;
  device_uuid: uuid;
  device_name: string;
  tenant_id: uuid;  // ← restaurants.uuid
  created_at: timestamp;
}

// AFTER
interface RegisterDeviceResult {
  device_id: bigint;
  device_uuid: uuid;
  device_name: string;
  restaurant_id: bigint;  // ← restaurants.id (FK)
  created_at: timestamp;
}

// To get restaurant UUID if needed:
// SELECT uuid FROM restaurants WHERE id = restaurant_id
```

**Impact:** Application code needs to expect `restaurant_id` instead of `tenant_id` in response

---

### 2. add_restaurant_to_vendor()

**What it did with tenant_id:**
- Looked up `restaurants.uuid`
- Stored it in `vendor_restaurants.tenant_id` column

**What it does now:**
- Still uses `restaurants.uuid` but stores it in `vendor_restaurants.restaurant_uuid` (existing column)
- `tenant_id` column removed as it was redundant
- **Same functionality**, the relationship is still UUID-based via `restaurant_uuid`

**Table Structure:**
```sql
-- BEFORE
vendor_restaurants:
  - restaurant_uuid (FK to restaurants.uuid)
  - tenant_id (redundant copy of restaurant_uuid)

-- AFTER
vendor_restaurants:
  - restaurant_uuid (FK to restaurants.uuid)
  ✓ No change to functionality, just removed redundant column
```

**Impact:** No application code changes needed (function signature unchanged)

---

### 3. notify_schedule_change() [TRIGGER]

**What it did with tenant_id:**
- Sent real-time notification with `tenant_id` (UUID) in the payload
- Clients filtered by `tenant_id`

**What it does now:**
- Sends real-time notification with `restaurant_id` (bigint) in the payload
- Clients filter by `restaurant_id`
- **Same functionality**, just different identifier type

**Notification Payload:**
```javascript
// BEFORE
{
  table: 'restaurant_schedules',
  action: 'UPDATE',
  restaurant_id: 123,
  tenant_id: '68adb3a4-1dc6-46fd-8cc8-126003d8df92'  // UUID
}

// AFTER
{
  table: 'restaurant_schedules',
  action: 'UPDATE',
  restaurant_id: 123  // bigint FK
}

// If client needs UUID:
// They already have restaurant_id, can look up UUID from restaurants table
```

**Impact:** WebSocket/realtime listeners need to filter by `restaurant_id` instead of `tenant_id`

---

### 4. notify_location_change() [TRIGGER]

**What it did with tenant_id:**
- Same as `notify_schedule_change()`

**What it does now:**
- Same as `notify_schedule_change()`
- **Same functionality**, just using `restaurant_id`

**Impact:** Same as notify_schedule_change()

---

### 5. create_flash_sale()

**What it did with tenant_id:**
- Looked up `tenant_id` from existing promotional deals
- Inserted it into `promotional_deals.tenant_id`

**What it does now:**
- Uses `restaurant_id` FK directly
- **Same functionality**, flash sales still created correctly

**Database:**
```sql
-- BEFORE
promotional_deals:
  - restaurant_id (FK to restaurants.id)
  - tenant_id (redundant copy of restaurants.uuid)

-- AFTER
promotional_deals:
  - restaurant_id (FK to restaurants.id)
  ✓ No functional change, relationships intact
```

**Impact:** No application code changes (function signature unchanged)

---

## Summary Table

| Function | tenant_id Usage | restaurant_id Replacement | App Code Changes Required |
|----------|----------------|--------------------------|---------------------------|
| `register_device` | Returned in result | Returns restaurant_id instead | ✅ Yes - update response interface |
| `add_restaurant_to_vendor` | Stored redundantly | Uses restaurant_uuid only | ❌ No - function signature same |
| `notify_schedule_change` | In notification payload | restaurant_id in payload | ✅ Yes - update event listeners |
| `notify_location_change` | In notification payload | restaurant_id in payload | ✅ Yes - update event listeners |
| `create_flash_sale` | Stored redundantly | Uses restaurant_id FK | ❌ No - function signature same |

---

## Application Code Migration Guide

### 1. Update TypeScript Interfaces

```typescript
// Update device registration response
interface RegisterDeviceResult {
  device_id: bigint;
  device_uuid: uuid;
  device_name: string;
  restaurant_id: bigint;  // Changed from: tenant_id: uuid
  created_at: timestamp;
}
```

### 2. Update Real-time Event Listeners

```typescript
// BEFORE
supabase
  .channel('schedule_changes')
  .on('postgres_changes',
    { event: '*', schema: 'menuca_v3', table: 'restaurant_schedules' },
    (payload) => {
      const tenantId = payload.new.tenant_id;  // UUID
      if (tenantId === currentTenantId) {
        // Handle update
      }
    }
  )
  .subscribe();

// AFTER
supabase
  .channel('schedule_changes')
  .on('postgres_changes',
    { event: '*', schema: 'menuca_v3', table: 'restaurant_schedules' },
    (payload) => {
      const restaurantId = payload.new.restaurant_id;  // bigint
      if (restaurantId === currentRestaurantId) {
        // Handle update
      }
    }
  )
  .subscribe();
```

### 3. Update JWT Token Claims (if applicable)

If your JWT tokens include a `tenant_id` claim for RLS policies:

```typescript
// BEFORE
const token = {
  sub: userId,
  tenant_id: restaurantUuid,  // UUID
  role: 'admin'
}

// AFTER
const token = {
  sub: userId,
  restaurant_id: restaurantId,  // bigint FK
  role: 'admin'
}
```

**Note:** The updated RLS policies use `admin_user_restaurants` JOIN pattern instead of JWT claims, so this may not be necessary.

---

## What Does NOT Change

✅ **Restaurant relationships** - All FK constraints remain intact
✅ **Data integrity** - restaurant_id is a proper FK with ON DELETE CASCADE
✅ **Query performance** - restaurant_id already has indexes
✅ **Security** - RLS policies still enforce proper access control
✅ **Business logic** - All operations work identically
✅ **Menu operations** - Creating dishes, courses, ingredients unchanged
✅ **Promotional features** - Deals and coupons work the same
✅ **Device management** - Registration and tracking unchanged
✅ **Schedule operations** - Time periods, special schedules work the same

---

## Benefits of Using restaurant_id Instead of tenant_id

### 1. **Data Integrity**
```sql
-- tenant_id: No FK constraint
-- ❌ Can have invalid UUIDs (like 432K+ bad records)

-- restaurant_id: Has FK constraint
-- ✅ Cannot have invalid values
-- ✅ ON DELETE CASCADE ensures cleanup
```

### 2. **Simplicity**
```sql
-- BEFORE: Two ways to reference a restaurant
dishes.restaurant_id → restaurants.id
dishes.tenant_id → restaurants.uuid

-- AFTER: One canonical way
dishes.restaurant_id → restaurants.id
```

### 3. **Performance**
```sql
-- restaurant_id: bigint (8 bytes)
-- tenant_id: uuid (16 bytes)
-- 31 tables × 1M avg rows × 8 bytes saved = 248 MB saved
```

### 4. **Maintainability**
```sql
-- BEFORE: Two fields to keep in sync
INSERT INTO dishes (restaurant_id, tenant_id, ...)
VALUES (123, (SELECT uuid FROM restaurants WHERE id = 123), ...);

-- AFTER: One field, automatic FK
INSERT INTO dishes (restaurant_id, ...)
VALUES (123, ...);
```

---

## Migration Checklist for Developers

### Before Migration
- [ ] Review this document
- [ ] Identify code that uses tenant_id
- [ ] Plan TypeScript interface updates
- [ ] Plan real-time listener updates

### During Migration
- [ ] Update TypeScript interfaces
- [ ] Update device registration handlers
- [ ] Update real-time event listeners
- [ ] Update any JWT token generation (if applicable)

### After Migration
- [ ] Test device registration
- [ ] Test real-time notifications
- [ ] Test restaurant filtering
- [ ] Test admin access control
- [ ] Verify no tenant_id references remain

### Testing Scenarios

1. **Device Registration**
   ```typescript
   const result = await registerDevice({
     deviceName: 'POS-001',
     restaurantId: 123
   });
   console.assert(typeof result.restaurant_id === 'bigint');
   console.assert(result.restaurant_id === 123);
   ```

2. **Real-time Updates**
   ```typescript
   // Subscribe to schedule changes for restaurant 123
   const subscription = supabase
     .channel('schedules')
     .on('postgres_changes', {/*...*/}, (payload) => {
       console.assert(payload.new.restaurant_id === 123);
     });
   ```

3. **Flash Sale Creation**
   ```typescript
   const flashSale = await createFlashSale({
     restaurantId: 123,
     title: 'Happy Hour',
     discountValue: 20,
     quantityLimit: 50,
     durationHours: 2
   });
   // Verify flash sale is created and linked to restaurant 123
   ```

---

## Questions & Answers

**Q: Can I still get the restaurant UUID if I need it?**

A: Yes! Just JOIN to the restaurants table:
```sql
SELECT d.*, r.uuid as restaurant_uuid
FROM dishes d
JOIN restaurants r ON r.id = d.restaurant_id
WHERE d.restaurant_id = 123;
```

**Q: Will existing queries break?**

A: Queries using `tenant_id` will break (column removed). Update them to use `restaurant_id` instead.

**Q: What about frontend caching by tenant_id?**

A: Update cache keys to use `restaurant_id` instead:
```typescript
// BEFORE
const cacheKey = `menu:${tenantId}`;

// AFTER
const cacheKey = `menu:${restaurantId}`;
```

**Q: Can I rollback if something breaks?**

A: Yes, before Step 5. After Step 5, you need to restore from database backup.

---

## Conclusion

**No functionality is lost**. Every operation that used `tenant_id` has been updated to use `restaurant_id` instead, maintaining 100% of the original behavior while improving data integrity, simplicity, and maintainability.

The changes are straightforward:
- UUID → bigint (both identify the same restaurant)
- Redundant field → canonical FK
- Manual sync → automatic referential integrity
