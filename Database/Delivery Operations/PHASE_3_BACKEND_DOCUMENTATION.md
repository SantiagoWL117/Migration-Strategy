# Phase 3 Backend Documentation: Schema Optimization & Data Validation
## Delivery Operations Entity - For Backend Development

**Created:** January 17, 2025  
**Developer:** Brian (Database) → Santiago (Backend)  
**Phase:** 3 of 7 - Schema Optimization & Data Validation  
**Status:** ✅ COMPLETE - Ready for Backend Implementation

---

## 📋 **SANTIAGO'S QUICK REFERENCE**

### **Business Problem Summary**
The delivery operations system needs **data integrity guarantees** and **type safety** to prevent:
- Invalid status transitions (e.g., delivery going from "pending" directly to "delivered")
- Financial calculation errors (negative earnings, mismatched totals)
- Geographic data corruption (invalid coordinates, impossible distances)
- Performance issues from missing indexes on high-traffic queries
- Incomplete business logic validation at the database level

**Impact:** Without these safeguards, we risk data corruption, incorrect driver payments, failed deliveries, and poor user experience.

---

### **The Solution**
Implement **database-level validation** through:
1. **Enum types** for type-safe status values
2. **Check constraints** for data validation (coordinates, amounts, timestamps)
3. **Validation functions** for business logic (status transitions, earnings calculations)
4. **Performance indexes** for common query patterns
5. **Helper views** for dashboards and analytics

This creates a **"fortress database"** where bad data cannot enter, regardless of backend bugs.

---

### **Gained Business Logic Components**

#### **1. Type-Safe Enums (PostgreSQL Types)**
✅ **What Changed:** Created 8 enum types for status fields  
✅ **Why:** Prevents typos and invalid values at database level  
✅ **Backend Impact:** TypeScript types can be generated from these enums

**Available Enums:**
- `driver_status_type`: pending, approved, active, inactive, suspended, blocked
- `availability_status_type`: online, offline, busy, on_break
- `delivery_status_type`: pending, searching_driver, assigned, accepted, picked_up, in_transit, arrived, delivered, cancelled, failed
- `vehicle_type_enum`: car, bike, motorcycle, scooter, bicycle, walk
- `zone_type_enum`: circle, polygon, radius
- `payment_status_type`: pending, approved, paid, disputed, refunded
- `background_check_status_type`: pending, approved, rejected
- `location_source_type`: gps, network, manual

**Backend Usage:**
```typescript
// These enums are now enforced at database level
// TypeScript types should match exactly
type DriverStatus = 'pending' | 'approved' | 'active' | 'inactive' | 'suspended' | 'blocked';
type DeliveryStatus = 'pending' | 'searching_driver' | 'assigned' | 'accepted' | 'picked_up' | 'in_transit' | 'arrived' | 'delivered' | 'cancelled' | 'failed';
```

---

#### **2. Status Transition Validation**
✅ **Function:** `validate_delivery_status_transition(current, new)`  
✅ **Function:** `validate_driver_status_transition(current, new)`

**Business Rules Enforced:**
```
Delivery Flow:
pending → searching_driver → assigned → accepted → picked_up → in_transit → arrived → delivered ✅
pending → delivered ❌ (INVALID - skips required steps)

Driver Flow:
pending → approved → active ↔ inactive
Any status → suspended/blocked (admin override)
blocked → * (TERMINAL STATE - cannot change)
```

**Backend Implementation Required:**
```typescript
// BEFORE updating delivery status, validate transition
export async function updateDeliveryStatus(
  deliveryId: number,
  newStatus: DeliveryStatus
) {
  // 1. Get current status
  const { data: delivery } = await supabase
    .from('deliveries')
    .select('delivery_status')
    .eq('id', deliveryId)
    .single();

  // 2. Validate transition
  const { data: isValid } = await supabase.rpc(
    'validate_delivery_status_transition',
    {
      p_current_status: delivery.delivery_status,
      p_new_status: newStatus
    }
  );

  if (!isValid) {
    throw new Error(
      `Invalid status transition: ${delivery.delivery_status} → ${newStatus}`
    );
  }

  // 3. Update status
  const { data, error } = await supabase
    .from('deliveries')
    .update({
      delivery_status: newStatus,
      // Set appropriate timestamp based on status
      ...(newStatus === 'picked_up' && { pickup_time: new Date().toISOString() }),
      ...(newStatus === 'delivered' && { delivered_at: new Date().toISOString() })
    })
    .eq('id', deliveryId)
    .select()
    .single();

  return data;
}
```

---

#### **3. Driver Earnings Calculator**
✅ **Function:** `calculate_driver_earnings(delivery_fee, distance_km, duration_minutes, tip_amount)`

**Formula Implemented:**
```
Base Pay:        $5.00 fixed
Distance Pay:    $1.50 per km
Time Bonus:      $0.25 per minute
Tip:             100% to driver
Surge Bonus:     $0.00 (TODO: dynamic pricing)
------------------------
Total Earning:   Sum of all above
Commission:      15% of total
Net Earning:     Total - Commission
```

**Backend Implementation Required:**
```typescript
// When delivery is completed, calculate earnings
export async function completeDelivery(deliveryId: number) {
  // 1. Get delivery details
  const { data: delivery } = await supabase
    .from('deliveries')
    .select('*')
    .eq('id', deliveryId)
    .single();

  // 2. Calculate actual duration
  const acceptedAt = new Date(delivery.accepted_at);
  const deliveredAt = new Date();
  const durationMinutes = Math.floor(
    (deliveredAt.getTime() - acceptedAt.getTime()) / (1000 * 60)
  );

  // 3. Calculate earnings
  const { data: earnings } = await supabase.rpc('calculate_driver_earnings', {
    p_delivery_fee: delivery.delivery_fee,
    p_distance_km: delivery.distance_km,
    p_duration_minutes: durationMinutes,
    p_tip_amount: delivery.tip_amount || 0
  });

  // 4. Update delivery
  await supabase
    .from('deliveries')
    .update({
      delivery_status: 'delivered',
      delivered_at: deliveredAt.toISOString(),
      actual_duration_minutes: durationMinutes,
      driver_earnings: earnings.net_earning
    })
    .eq('id', deliveryId);

  // 5. Create earnings record
  await supabase
    .from('driver_earnings')
    .insert({
      driver_id: delivery.driver_id,
      delivery_id: delivery.id,
      base_earning: earnings.base_earning,
      distance_earning: earnings.distance_earning,
      time_bonus: earnings.time_bonus,
      tip_amount: earnings.tip_amount,
      surge_bonus: earnings.surge_bonus,
      total_earning: earnings.total_earning,
      platform_commission: earnings.platform_commission,
      net_earning: earnings.net_earning,
      payment_status: 'pending',
      earned_at: deliveredAt.toISOString()
    });

  // 6. Update driver totals
  await supabase.rpc('update_driver_earnings_totals', {
    p_driver_id: delivery.driver_id
  });

  return earnings;
}
```

---

#### **4. Data Validation Constraints**
✅ **What Changed:** Added 20+ check constraints for automatic validation

**Validations Now Enforced:**

**Geographic Coordinates:**
```sql
-- Latitude must be between -90 and 90
-- Longitude must be between -180 and 180
-- Database will REJECT invalid coordinates
```

**Financial Amounts:**
```sql
-- All fees must be >= 0
-- total_earning = base + distance + time + tip + surge
-- net_earning = total - commission
-- Database will REJECT invalid calculations
```

**Ratings:**
```sql
-- Customer/driver ratings must be 1-5 (if provided)
-- Database will REJECT ratings outside this range
```

**Timestamps:**
```sql
-- assigned_at >= created_at
-- accepted_at >= assigned_at
-- pickup_time >= accepted_at
-- delivered_at >= pickup_time
-- Database will REJECT time paradoxes
```

**Backend Impact:**
```typescript
// You DON'T need to validate these in backend - database does it!
// But you should still show user-friendly error messages

try {
  await supabase.from('deliveries').insert({
    pickup_latitude: 100, // INVALID - will be rejected
    delivery_fee: -5,     // INVALID - will be rejected
    // ...
  });
} catch (error) {
  // Database will return constraint violation error
  // Parse and show user-friendly message
  if (error.code === '23514') { // Check constraint violation
    return {
      error: 'Invalid data: coordinates must be valid, fees must be positive'
    };
  }
}
```

---

#### **5. Performance Views for Dashboards**
✅ **Created 3 analytical views for common queries**

**View 1: `driver_performance_summary`**
```sql
-- Real-time driver performance metrics
SELECT * FROM menuca_v3.driver_performance_summary;
```

**Fields Available:**
- driver_id, driver_name
- driver_status, availability_status, vehicle_type
- average_rating
- total_deliveries, completed_deliveries, cancelled_deliveries
- acceptance_rate, completion_rate, on_time_rate
- earnings_total, earnings_pending, earnings_paid
- avg_earnings_per_delivery
- driver_since, last_location_update

**Backend API Endpoint:**
```typescript
// GET /api/admin/drivers/performance
export async function getDriverPerformance() {
  const { data, error } = await supabase
    .from('driver_performance_summary')
    .select('*')
    .order('total_deliveries', { ascending: false })
    .limit(100);

  return data;
}
```

---

**View 2: `active_delivery_tracking`**
```sql
-- Live tracking of all in-progress deliveries
SELECT * FROM menuca_v3.active_delivery_tracking;
```

**Fields Available:**
- delivery_id, order_id
- restaurant_id, restaurant_name
- driver_id, driver_name, driver_phone
- delivery_status
- delivery_address, customer_name, customer_phone
- estimated_duration_minutes
- created_at, assigned_at, accepted_at, pickup_time
- minutes_in_progress (calculated)
- driver_latitude, driver_longitude, last_location_update
- is_contactless, is_priority, delivery_instructions

**Backend API Endpoint:**
```typescript
// GET /api/admin/deliveries/active
export async function getActiveDeliveries() {
  const { data, error } = await supabase
    .from('active_delivery_tracking')
    .select('*')
    .order('created_at', { ascending: false });

  // Real-time subscription
  const subscription = supabase
    .channel('active_deliveries')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'menuca_v3',
        table: 'deliveries',
        filter: 'delivery_status=in.(assigned,accepted,picked_up,in_transit,arrived)'
      },
      (payload) => {
        // Refresh active deliveries view
        console.log('Delivery updated:', payload);
      }
    )
    .subscribe();

  return data;
}
```

---

**View 3: `delivery_zone_summary`**
```sql
-- Delivery zone performance statistics (last 30 days)
SELECT * FROM menuca_v3.delivery_zone_summary;
```

**Fields Available:**
- zone_id, restaurant_id, restaurant_name
- zone_name, zone_code, zone_type
- base_delivery_fee, per_km_fee, minimum_order_amount, free_delivery_threshold
- radius_km, is_active, accepts_deliveries
- estimated_delivery_time_minutes, priority
- total_deliveries, completed_deliveries (last 30 days)
- avg_delivery_time_minutes, avg_delivery_fee

**Backend API Endpoint:**
```typescript
// GET /api/restaurants/:id/zones/stats
export async function getZoneStatistics(restaurantId: number) {
  const { data, error } = await supabase
    .from('delivery_zone_summary')
    .select('*')
    .eq('restaurant_id', restaurantId)
    .order('total_deliveries', { ascending: false });

  return data;
}
```

---

### **Backend Functionality Required for This Phase**

#### **Priority 1: Status Transition Validation** ✅ IMPLEMENT IMMEDIATELY
**Why:** Prevents data corruption from invalid status changes

**Endpoints to Update:**
1. `PUT /api/deliveries/:id/status` - Add validation before update
2. `PUT /api/drivers/:id/status` - Add validation before update

**Implementation Pattern:**
```typescript
// middleware/validateStatusTransition.ts
export async function validateDeliveryTransition(req, res, next) {
  const { delivery_id, new_status } = req.body;

  const { data: delivery } = await supabase
    .from('deliveries')
    .select('delivery_status')
    .eq('id', delivery_id)
    .single();

  const { data: isValid } = await supabase.rpc(
    'validate_delivery_status_transition',
    {
      p_current_status: delivery.delivery_status,
      p_new_status: new_status
    }
  );

  if (!isValid) {
    return res.status(400).json({
      error: 'Invalid status transition',
      current_status: delivery.delivery_status,
      requested_status: new_status,
      allowed_transitions: getAllowedTransitions(delivery.delivery_status)
    });
  }

  next();
}

function getAllowedTransitions(currentStatus: string): string[] {
  const transitions = {
    'pending': ['searching_driver', 'cancelled'],
    'searching_driver': ['assigned', 'cancelled'],
    'assigned': ['accepted', 'cancelled'],
    'accepted': ['picked_up', 'cancelled'],
    'picked_up': ['in_transit'],
    'in_transit': ['arrived'],
    'arrived': ['delivered', 'failed'],
    'delivered': [],
    'cancelled': [],
    'failed': []
  };
  return transitions[currentStatus] || [];
}
```

---

#### **Priority 2: Earnings Calculation** ✅ IMPLEMENT IMMEDIATELY
**Why:** Ensures driver payments are calculated correctly

**Endpoint to Update:**
1. `POST /api/deliveries/:id/complete` - Calculate and record earnings

**Implementation:**
```typescript
// api/deliveries/[id]/complete.ts
export async function completeDelivery(req, res) {
  const { delivery_id } = req.params;

  // 1. Validate delivery status
  const { data: delivery } = await supabase
    .from('deliveries')
    .select('*')
    .eq('id', delivery_id)
    .single();

  if (delivery.delivery_status !== 'arrived') {
    return res.status(400).json({
      error: 'Delivery must be in "arrived" status to complete'
    });
  }

  // 2. Calculate duration
  const acceptedAt = new Date(delivery.accepted_at);
  const deliveredAt = new Date();
  const durationMinutes = Math.floor(
    (deliveredAt.getTime() - acceptedAt.getTime()) / (1000 * 60)
  );

  // 3. Calculate earnings using database function
  const { data: earnings, error: earningsError } = await supabase.rpc(
    'calculate_driver_earnings',
    {
      p_delivery_fee: delivery.delivery_fee,
      p_distance_km: delivery.distance_km,
      p_duration_minutes: durationMinutes,
      p_tip_amount: delivery.tip_amount || 0
    }
  );

  if (earningsError) {
    return res.status(500).json({ error: 'Failed to calculate earnings' });
  }

  // 4. Update delivery (using transaction)
  const { error: updateError } = await supabase.rpc('complete_delivery_transaction', {
    p_delivery_id: delivery_id,
    p_delivered_at: deliveredAt.toISOString(),
    p_actual_duration: durationMinutes,
    p_driver_earnings: earnings.net_earning,
    p_earnings_breakdown: earnings
  });

  if (updateError) {
    return res.status(500).json({ error: 'Failed to complete delivery' });
  }

  res.json({
    success: true,
    delivery_id,
    earnings: {
      base_pay: earnings.base_earning,
      distance_pay: earnings.distance_earning,
      time_bonus: earnings.time_bonus,
      tip: earnings.tip_amount,
      total: earnings.net_earning,
      breakdown: earnings
    }
  });
}
```

---

#### **Priority 3: Dashboard Endpoints** ⚠️ OPTIONAL BUT RECOMMENDED
**Why:** Provides real-time insights for admins and restaurant owners

**New Endpoints to Create:**
```typescript
// GET /api/admin/drivers/performance
// GET /api/admin/deliveries/active
// GET /api/restaurants/:id/zones/stats
```

All of these can simply query the views created in Phase 3:
```typescript
const { data } = await supabase
  .from('driver_performance_summary') // or other views
  .select('*');
```

---

#### **Priority 4: Error Handling for Constraints** ✅ IMPLEMENT IMMEDIATELY
**Why:** Database will now reject invalid data - need user-friendly messages

**Pattern:**
```typescript
// utils/handleDatabaseError.ts
export function handleDatabaseConstraintError(error: any) {
  if (error.code === '23514') { // Check constraint violation
    const constraintName = error.constraint;
    
    // Map constraint names to user-friendly messages
    const messages = {
      'chk_drivers_latitude_valid': 'Invalid latitude: must be between -90 and 90',
      'chk_drivers_longitude_valid': 'Invalid longitude: must be between -180 and 180',
      'chk_deliveries_fees_non_negative': 'All fees must be positive',
      'chk_earnings_components_valid': 'Invalid earnings calculation',
      'chk_deliveries_customer_rating_valid': 'Rating must be between 1 and 5',
      // ... add more mappings
    };

    return {
      error: messages[constraintName] || 'Data validation failed',
      constraint: constraintName,
      details: error.detail
    };
  }

  if (error.code === '23505') { // Unique constraint violation
    return {
      error: 'This value is already in use',
      field: error.constraint.replace('uq_', '').replace('_', ' ')
    };
  }

  return {
    error: 'Database error',
    details: error.message
  };
}

// Usage in API routes
try {
  await supabase.from('drivers').insert(driverData);
} catch (error) {
  const friendlyError = handleDatabaseConstraintError(error);
  return res.status(400).json(friendlyError);
}
```

---

### **Schema Modifications Summary**

#### **New Database Objects Created:**

**Enum Types (8):**
- ✅ `driver_status_type` - Driver account status
- ✅ `availability_status_type` - Real-time driver availability
- ✅ `delivery_status_type` - Delivery lifecycle status
- ✅ `vehicle_type_enum` - Vehicle types
- ✅ `zone_type_enum` - Delivery zone types
- ✅ `payment_status_type` - Earnings payment status
- ✅ `background_check_status_type` - Background check results
- ✅ `location_source_type` - GPS source

**Check Constraints (20+):**
- ✅ Coordinate validation (lat/lon ranges)
- ✅ Financial validation (non-negative amounts, formula matches)
- ✅ Rating validation (1-5 range)
- ✅ Timestamp validation (chronological order)
- ✅ Zone configuration validation

**Validation Functions (4):**
- ✅ `validate_delivery_status_transition()` - Enforce delivery flow
- ✅ `validate_driver_status_transition()` - Enforce driver status rules
- ✅ `calculate_driver_earnings()` - Calculate payment breakdown
- ✅ `validate_zone_configuration()` - Validate zone setup

**Performance Indexes (10):**
- ✅ `idx_drivers_status_rating` - Driver search optimization
- ✅ `idx_drivers_availability_location` - Nearby driver search
- ✅ `idx_deliveries_driver_status_date` - Driver delivery history
- ✅ `idx_deliveries_restaurant_status_date` - Restaurant delivery history
- ✅ `idx_deliveries_status_created` - Pending delivery queue
- ✅ `idx_driver_earnings_driver_date_status` - Earnings lookups
- ✅ `idx_driver_earnings_pending_batch` - Payout processing
- ✅ `idx_driver_locations_driver_time_desc` - Location history
- ✅ `idx_driver_locations_delivery_time` - Active delivery tracking
- ✅ `idx_delivery_zones_restaurant_active` - Zone matching

**Analytical Views (3):**
- ✅ `driver_performance_summary` - Driver KPIs
- ✅ `active_delivery_tracking` - Live delivery dashboard
- ✅ `delivery_zone_summary` - Zone performance metrics

**Extended Statistics (3):**
- ✅ `stats_drivers_status_location` - Better query planning
- ✅ `stats_deliveries_status_time` - Optimized delivery queries
- ✅ `stats_driver_earnings_driver_status` - Faster earnings reports

---

### **Testing Checklist for Backend**

#### **Test 1: Status Transition Validation**
```typescript
// Should SUCCEED
await updateDeliveryStatus(123, 'searching_driver'); // from pending
await updateDeliveryStatus(123, 'assigned'); // from searching_driver

// Should FAIL
await updateDeliveryStatus(123, 'delivered'); // from pending (skips steps)
// Expected: 400 Bad Request with validation error
```

#### **Test 2: Constraint Validation**
```typescript
// Should FAIL - invalid coordinates
await supabase.from('deliveries').insert({
  pickup_latitude: 100, // > 90
  pickup_longitude: -200, // < -180
  // ...
});
// Expected: 400 Bad Request with constraint error

// Should FAIL - negative fees
await supabase.from('deliveries').insert({
  delivery_fee: -5,
  // ...
});
// Expected: 400 Bad Request with constraint error
```

#### **Test 3: Earnings Calculation**
```typescript
// Test earnings formula
const earnings = await supabase.rpc('calculate_driver_earnings', {
  p_delivery_fee: 10.00,
  p_distance_km: 5.0,
  p_duration_minutes: 20,
  p_tip_amount: 3.00
});

// Expected:
// base_earning: 5.00
// distance_earning: 7.50 (5 km * $1.50)
// time_bonus: 5.00 (20 min * $0.25)
// tip_amount: 3.00
// total_earning: 20.50
// platform_commission: 3.08 (15% of 20.50)
// net_earning: 17.42
```

#### **Test 4: Views Accessibility**
```typescript
// Should return data
const drivers = await supabase.from('driver_performance_summary').select('*');
const active = await supabase.from('active_delivery_tracking').select('*');
const zones = await supabase.from('delivery_zone_summary').select('*');

// All should return valid data
```

---

## 🎯 **IMPLEMENTATION PRIORITY**

### **This Week (Critical):**
1. ✅ Add status transition validation to delivery status updates
2. ✅ Add status transition validation to driver status updates
3. ✅ Implement earnings calculation on delivery completion
4. ✅ Add constraint error handling with user-friendly messages

### **Next Week (Important):**
1. ⚠️ Create dashboard endpoints using performance views
2. ⚠️ Add TypeScript types matching enum types
3. ⚠️ Create admin UI for driver performance monitoring
4. ⚠️ Create restaurant UI for zone performance stats

### **Future (Nice to Have):**
1. 💡 Implement surge pricing logic in earnings calculator
2. 💡 Add automated tests for all validation functions
3. 💡 Create webhooks for status transition events

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 3 Complete** - Schema optimization done
2. ⏳ **Santiago: Implement Backend Logic** - Follow this guide
3. ⏳ **Phase 4: Real-Time Updates** - Enable live tracking
4. ⏳ **Phase 5: Soft Delete & Audit** - Add audit trails

---

## 📞 **QUESTIONS FOR SANTIAGO?**

If you need clarification on:
- Status transition rules
- Earnings calculation formula
- Constraint error handling
- View usage in APIs

**Ping Brian** - The database is a fortress, but we need your backend to use it properly! 🏰

---

**Status:** ✅ Database fortress built, ready for backend integration!

