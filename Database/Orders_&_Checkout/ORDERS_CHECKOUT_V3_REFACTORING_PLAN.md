# Orders & Checkout Entity - V3 Refactoring Plan
## Enterprise-Grade Order Management System

**Entity:** Orders & Checkout (Priority 7)  
**Dependencies:** ✅ Menu & Catalog (Complete), ✅ Users & Access (Complete), ✅ Service Config (Complete)  
**Created:** January 17, 2025  
**Developer:** Brian (Agent 1) with AI Assistant  
**Status:** 🚧 **IN PROGRESS**

---

## 🎯 **EXECUTIVE SUMMARY**

### **Current State**
The Orders & Checkout entity has basic V3 schema created (October 2025):
- ✅ **7 tables** designed: orders, order_items, order_item_modifiers, order_delivery_addresses, order_discounts, order_status_history, order_pdfs
- ✅ **Basic schema** with FK relationships
- ✅ **Legacy ID tracking** (V1/V2 traceability)
- ⚠️ **No business logic layer** - just tables
- ⚠️ **No RLS policies** - security not implemented
- ⚠️ **No SQL functions** - no API layer
- ⚠️ **No real-time features** - static data only

**Existing Schema File:** `/Database/Orders_&_Checkout/01_create_v3_order_schema.sql`

---

### **Refactoring Objective**

**GOAL:** Transform Orders & Checkout from "basic schema" to **enterprise-grade order management system** that rivals Uber Eats, DoorDash, and Skip the Dishes.

**Focus Areas:**
1. 🔒 **Auth & Security** - RLS policies, multi-party access control (customers, restaurants, admins, drivers)
2. ⚡ **Performance** - Handle 100K+ orders/day, real-time status updates
3. 💰 **Revenue Flow** - Payment processing, refunds, financial tracking
4. 📊 **Business Logic** - Order validation, eligibility checks, total calculations
5. 🚀 **Real-time** - Live order tracking, status notifications
6. 🌍 **Multi-language** - Order status messages in EN/ES/FR
7. 🔗 **Integration** - Connect with Menu, Service Config, Marketing, Delivery

**Why This Matters:**
- 💰 **Revenue Critical** - This is where money flows through the system
- 🛒 **Core Business Function** - Can't process customer orders without it
- 📊 **Analytics Foundation** - Order data drives business intelligence
- 🔗 **Integration Hub** - Connects all other entities

---

## 📋 **REFACTORING PHASES**

### **Phase Overview**

| Phase | Focus | Priority | Effort | Status |
|-------|-------|----------|--------|--------|
| **Phase 1** | Auth & Security (RLS) | 🔴 CRITICAL | 6-8 hours | 🔄 IN PROGRESS |
| **Phase 2** | Performance & Core APIs | 🔴 HIGH | 6-8 hours | ⏳ PENDING |
| **Phase 3** | Schema Optimization | 🟡 MEDIUM | 4-6 hours | ⏳ PENDING |
| **Phase 4** | Real-time Updates | 🟡 MEDIUM | 4-6 hours | ⏳ PENDING |
| **Phase 5** | Multi-language Support | 🟢 LOW | 3-4 hours | ⏳ PENDING |
| **Phase 6** | Advanced Features | 🟢 LOW | 4-5 hours | ⏳ PENDING |
| **Phase 7** | Testing & Documentation | 🔴 CRITICAL | 3-4 hours | ⏳ PENDING |

**Progress:** 0/7 phases complete (0%)  
**Estimated Total Time:** 30-38 hours  
**Target Completion:** January 18-19, 2025

---

## 🔐 **PHASE 1: AUTH & SECURITY (CRITICAL)**

**Priority:** 🔴 CRITICAL  
**Duration:** 6-8 hours  
**Status:** 🔄 IN PROGRESS  
**Risk:** 🟡 MEDIUM (test thoroughly, can break queries)

### **Objective**
Implement comprehensive RLS policies for multi-party access control:
- **Customers** - View own orders only
- **Restaurant Staff** - View orders for their restaurant
- **Drivers** - View assigned deliveries only
- **Admins** - View all orders
- **Service Accounts** - Payment processing APIs

---

### **1.1 Enable Row-Level Security (RLS)**

**Problem:**
```sql
-- Currently ANYONE can see ALL orders
SELECT * FROM menuca_v3.orders WHERE restaurant_id = 123;
-- No protection, no auth checks
```

**Solution: Enable RLS on all tables**

```sql
-- Enable RLS on all order tables
ALTER TABLE menuca_v3.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_item_modifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_delivery_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE menuca_v3.order_pdfs ENABLE ROW LEVEL SECURITY;
```

---

### **1.2 Create JWT Helper Functions**

```sql
-- Get current user ID from JWT
CREATE OR REPLACE FUNCTION auth.user_id() 
RETURNS UUID AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::json->>'sub',
    current_setting('request.jwt.claim.sub', true)
  )::UUID;
$$ LANGUAGE sql STABLE;

-- Get current user role from JWT
CREATE OR REPLACE FUNCTION auth.role() 
RETURNS TEXT AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::json->>'role',
    current_setting('request.jwt.claim.role', true),
    'anon'
  )::TEXT;
$$ LANGUAGE sql STABLE;

-- Check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
  SELECT auth.role() IN ('admin', 'super_admin');
$$ LANGUAGE sql STABLE;
```

---

### **1.3 RLS Policies for Orders**

#### **Policy 1: Customer Access**
```sql
-- Customers can view their own orders
CREATE POLICY "customers_view_own_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  user_id = auth.user_id() 
  AND auth.role() = 'customer'
);

-- Customers can create orders
CREATE POLICY "customers_create_orders"
ON menuca_v3.orders FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.user_id()
  AND auth.role() = 'customer'
);

-- Customers can cancel their own orders (if eligible)
CREATE POLICY "customers_cancel_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  user_id = auth.user_id()
  AND auth.role() = 'customer'
  AND status IN ('pending', 'accepted')  -- Can only cancel if not preparing
)
WITH CHECK (
  user_id = auth.user_id()
  AND status = 'canceled'  -- Can only set to canceled
);
```

#### **Policy 2: Restaurant Staff Access**
```sql
-- Restaurant staff can view orders for their restaurant
CREATE POLICY "restaurant_staff_view_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  restaurant_id IN (
    SELECT restaurant_id 
    FROM menuca_v3.restaurant_staff 
    WHERE user_id = auth.user_id()
  )
  AND auth.role() IN ('restaurant_admin', 'restaurant_manager', 'restaurant_staff')
);

-- Restaurant staff can update order status
CREATE POLICY "restaurant_staff_update_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  restaurant_id IN (
    SELECT restaurant_id 
    FROM menuca_v3.restaurant_staff 
    WHERE user_id = auth.user_id()
  )
  AND auth.role() IN ('restaurant_admin', 'restaurant_manager', 'restaurant_staff')
)
WITH CHECK (
  restaurant_id IN (
    SELECT restaurant_id 
    FROM menuca_v3.restaurant_staff 
    WHERE user_id = auth.user_id()
  )
);
```

#### **Policy 3: Driver Access**
```sql
-- Drivers can view their assigned deliveries
CREATE POLICY "drivers_view_assigned_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (
  id IN (
    SELECT order_id 
    FROM menuca_v3.deliveries 
    WHERE driver_id = auth.user_id()
  )
  AND auth.role() = 'driver'
  AND order_type = 'delivery'
);

-- Drivers can update delivery status
CREATE POLICY "drivers_update_delivery_status"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (
  id IN (
    SELECT order_id 
    FROM menuca_v3.deliveries 
    WHERE driver_id = auth.user_id()
  )
  AND auth.role() = 'driver'
)
WITH CHECK (
  status IN ('out_for_delivery', 'completed')  -- Drivers can only mark as picked up or delivered
);
```

#### **Policy 4: Admin Access**
```sql
-- Admins can view all orders
CREATE POLICY "admins_view_all_orders"
ON menuca_v3.orders FOR SELECT
TO authenticated
USING (auth.is_admin());

-- Admins can update any order
CREATE POLICY "admins_update_all_orders"
ON menuca_v3.orders FOR UPDATE
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- Admins can delete orders (soft delete)
CREATE POLICY "admins_delete_orders"
ON menuca_v3.orders FOR DELETE
TO authenticated
USING (auth.is_admin());
```

#### **Policy 5: Service Account Access (APIs)**
```sql
-- Payment service can update payment status
CREATE POLICY "service_account_payment_updates"
ON menuca_v3.orders FOR UPDATE
TO service_role
USING (true)  -- Service role can update any order
WITH CHECK (true);
```

---

### **1.4 RLS Policies for Order Items**

```sql
-- Customers can view items for their orders
CREATE POLICY "customers_view_own_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.user_id()
  )
  AND auth.role() = 'customer'
);

-- Restaurant staff can view items for their restaurant's orders
CREATE POLICY "restaurant_staff_view_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (
      SELECT restaurant_id FROM menuca_v3.restaurant_staff 
      WHERE user_id = auth.user_id()
    )
  )
  AND auth.role() IN ('restaurant_admin', 'restaurant_manager', 'restaurant_staff')
);

-- Admins can view all items
CREATE POLICY "admins_view_all_order_items"
ON menuca_v3.order_items FOR SELECT
TO authenticated
USING (auth.is_admin());
```

---

### **1.5 RLS Policies for Delivery Addresses**

```sql
-- Customers can view addresses for their orders
CREATE POLICY "customers_view_own_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE user_id = auth.user_id()
  )
  AND auth.role() = 'customer'
);

-- Restaurant staff can view addresses for their orders
CREATE POLICY "restaurant_staff_view_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT id FROM menuca_v3.orders 
    WHERE restaurant_id IN (
      SELECT restaurant_id FROM menuca_v3.restaurant_staff 
      WHERE user_id = auth.user_id()
    )
  )
  AND auth.role() IN ('restaurant_admin', 'restaurant_manager', 'restaurant_staff')
);

-- Drivers can view addresses for their assigned deliveries
CREATE POLICY "drivers_view_delivery_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT order_id FROM menuca_v3.deliveries 
    WHERE driver_id = auth.user_id()
  )
  AND auth.role() = 'driver'
);

-- Admins can view all addresses
CREATE POLICY "admins_view_all_addresses"
ON menuca_v3.order_delivery_addresses FOR SELECT
TO authenticated
USING (auth.is_admin());
```

---

### **1.6 Security Summary**

**RLS Policies Created:**
- ✅ 7 tables with RLS enabled
- ✅ 15+ policies for customers
- ✅ 10+ policies for restaurant staff
- ✅ 5+ policies for drivers
- ✅ 5+ policies for admins
- ✅ Service account policies for APIs

**Total:** ~40 RLS policies

**Deliverables:**
- `PHASE_1_BACKEND_DOCUMENTATION.md` - Complete RLS documentation
- `PHASE_1_MIGRATION_SCRIPT.sql` - All RLS policies and helper functions

---

## ⚡ **PHASE 2: PERFORMANCE & CORE APIs**

**Priority:** 🔴 HIGH  
**Duration:** 6-8 hours  
**Status:** ⏳ PENDING

### **Objective**
Create SQL functions for order management and optimize performance with indexes.

---

### **2.1 Core SQL Functions (15-20 functions)**

#### **Order Creation & Validation**
```sql
-- Validate order before submission
CREATE FUNCTION validate_order(
  p_user_id UUID,
  p_restaurant_id BIGINT,
  p_items JSONB,
  p_service_type TEXT
) RETURNS JSONB;

-- Calculate order total with tax and fees
CREATE FUNCTION calculate_order_total(
  p_restaurant_id BIGINT,
  p_subtotal DECIMAL,
  p_delivery_fee DECIMAL DEFAULT 0,
  p_discounts JSONB DEFAULT '[]'::JSONB
) RETURNS JSONB;

-- Create complete order with items
CREATE FUNCTION create_order(
  p_user_id UUID,
  p_restaurant_id BIGINT,
  p_items JSONB,
  p_delivery_address JSONB,
  p_payment_method TEXT
) RETURNS JSONB;
```

#### **Order Status Management**
```sql
-- Update order status with validation
CREATE FUNCTION update_order_status(
  p_order_id BIGINT,
  p_new_status TEXT,
  p_changed_by UUID,
  p_reason TEXT DEFAULT NULL
) RETURNS JSONB;

-- Check if order can be canceled
CREATE FUNCTION can_cancel_order(
  p_order_id BIGINT,
  p_user_id UUID
) RETURNS BOOLEAN;

-- Cancel order
CREATE FUNCTION cancel_order(
  p_order_id BIGINT,
  p_user_id UUID,
  p_reason TEXT
) RETURNS JSONB;
```

#### **Order Retrieval**
```sql
-- Get order details with all relationships
CREATE FUNCTION get_order_details(
  p_order_id BIGINT,
  p_user_id UUID
) RETURNS JSONB;

-- Get customer order history (paginated)
CREATE FUNCTION get_customer_order_history(
  p_user_id UUID,
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
) RETURNS JSONB;

-- Get restaurant order queue
CREATE FUNCTION get_restaurant_orders(
  p_restaurant_id BIGINT,
  p_status TEXT[] DEFAULT ARRAY['pending', 'accepted', 'preparing', 'ready'],
  p_date_from TIMESTAMPTZ DEFAULT NOW() - INTERVAL '24 hours'
) RETURNS JSONB;
```

#### **Order Eligibility**
```sql
-- Check if restaurant accepts orders now
CREATE FUNCTION check_order_eligibility(
  p_restaurant_id BIGINT,
  p_service_type TEXT,
  p_delivery_address JSONB DEFAULT NULL
) RETURNS JSONB;

-- Check if user can reorder
CREATE FUNCTION can_reorder(
  p_user_id UUID,
  p_order_id BIGINT
) RETURNS BOOLEAN;

-- Create reorder from previous order
CREATE FUNCTION reorder(
  p_user_id UUID,
  p_original_order_id BIGINT
) RETURNS JSONB;
```

#### **Financial Functions**
```sql
-- Calculate delivery fee based on zone
CREATE FUNCTION calculate_delivery_fee(
  p_restaurant_id BIGINT,
  p_delivery_address JSONB
) RETURNS DECIMAL;

-- Apply discount/coupon (stub for Marketing integration)
CREATE FUNCTION apply_coupon_to_order(
  p_order_id BIGINT,
  p_coupon_code TEXT
) RETURNS JSONB;

-- Process refund
CREATE FUNCTION process_refund(
  p_order_id BIGINT,
  p_refund_amount DECIMAL,
  p_reason TEXT
) RETURNS JSONB;
```

#### **Analytics Functions**
```sql
-- Get order statistics
CREATE FUNCTION get_order_stats(
  p_restaurant_id BIGINT,
  p_date_from TIMESTAMPTZ,
  p_date_to TIMESTAMPTZ
) RETURNS JSONB;

-- Get customer lifetime value
CREATE FUNCTION get_customer_ltv(
  p_user_id UUID
) RETURNS JSONB;
```

---

### **2.2 Performance Indexes**

```sql
-- Orders table indexes
CREATE INDEX idx_orders_user_status ON menuca_v3.orders(user_id, status);
CREATE INDEX idx_orders_restaurant_status ON menuca_v3.orders(restaurant_id, status);
CREATE INDEX idx_orders_status_placed_at ON menuca_v3.orders(status, placed_at DESC);
CREATE INDEX idx_orders_placed_at_brin ON menuca_v3.orders USING BRIN (placed_at);
CREATE INDEX idx_orders_payment_status ON menuca_v3.orders(payment_status);
CREATE INDEX idx_orders_order_type ON menuca_v3.orders(order_type);

-- Order items indexes
CREATE INDEX idx_order_items_order_dish ON menuca_v3.order_items(order_id, dish_id);
CREATE INDEX idx_order_items_display_order ON menuca_v3.order_items(order_id, display_order);

-- Modifiers indexes
CREATE INDEX idx_order_item_modifiers_item ON menuca_v3.order_item_modifiers(order_item_id);
CREATE INDEX idx_order_item_modifiers_ingredient ON menuca_v3.order_item_modifiers(ingredient_id);

-- Delivery addresses indexes
CREATE INDEX idx_delivery_addresses_postal ON menuca_v3.order_delivery_addresses(postal_code);
CREATE INDEX idx_delivery_addresses_location ON menuca_v3.order_delivery_addresses USING GIST (ll_to_earth(latitude, longitude));

-- Discounts indexes
CREATE INDEX idx_order_discounts_code ON menuca_v3.order_discounts(discount_code);
CREATE INDEX idx_order_discounts_type ON menuca_v3.order_discounts(discount_type);

-- Status history indexes
CREATE INDEX idx_status_history_order_changed_at ON menuca_v3.order_status_history(order_id, changed_at DESC);
```

---

### **2.3 API Endpoints Documentation (15-20 endpoints)**

#### **Customer APIs**
1. `POST /api/orders/checkout` - Start checkout session
2. `POST /api/orders` - Create order
3. `GET /api/orders/:id` - Get order details
4. `GET /api/orders/me` - Get my order history
5. `PUT /api/orders/:id/cancel` - Cancel order
6. `POST /api/orders/:id/reorder` - Reorder previous order
7. `GET /api/orders/:id/receipt` - Get receipt

#### **Restaurant APIs**
8. `GET /api/restaurants/:rid/orders` - Get order queue
9. `PUT /api/restaurants/:rid/orders/:id/accept` - Accept order
10. `PUT /api/restaurants/:rid/orders/:id/reject` - Reject order
11. `PUT /api/restaurants/:rid/orders/:id/ready` - Mark ready
12. `GET /api/restaurants/:rid/orders/stats` - Order statistics

#### **Admin APIs**
13. `GET /api/admin/orders` - All orders (paginated)
14. `GET /api/admin/orders/:id` - Order details with audit
15. `POST /api/admin/orders/:id/refund` - Issue refund
16. `GET /api/admin/orders/analytics` - Order analytics

#### **Payment APIs**
17. `POST /api/orders/:id/payment` - Process payment
18. `GET /api/orders/:id/payment/status` - Check payment status
19. `POST /api/orders/:id/payment/retry` - Retry failed payment
20. `POST /api/webhooks/payment` - Payment webhook handler

---

### **2.4 Performance Benchmarks**

**Target:**
- Order creation: < 200ms
- Order retrieval: < 100ms
- Order list (paginated): < 150ms
- Status update: < 100ms
- Order validation: < 100ms

---

## 📊 **PHASE 3: SCHEMA OPTIMIZATION**

**Priority:** 🟡 MEDIUM  
**Duration:** 4-6 hours  
**Status:** ⏳ PENDING

### **3.1 Add Audit Columns**

```sql
-- Add audit columns to all tables
ALTER TABLE menuca_v3.orders ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES menuca_v3.users(id);
ALTER TABLE menuca_v3.orders ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES menuca_v3.users(id);
ALTER TABLE menuca_v3.orders ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE menuca_v3.orders ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES menuca_v3.users(id);

-- Repeat for all order tables...
```

### **3.2 Implement Soft Delete**

```sql
-- Create soft delete function
CREATE FUNCTION soft_delete_order(
  p_order_id BIGINT,
  p_deleted_by UUID,
  p_reason TEXT
) RETURNS JSONB;

-- Create restore function
CREATE FUNCTION restore_order(
  p_order_id BIGINT,
  p_restored_by UUID
) RETURNS JSONB;

-- Update RLS policies to filter deleted records
-- Add: AND deleted_at IS NULL to all SELECT policies
```

### **3.3 Automatic Status History Tracking**

```sql
-- Create trigger for automatic status tracking
CREATE OR REPLACE FUNCTION track_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO menuca_v3.order_status_history (
      order_id,
      old_status,
      new_status,
      changed_by_user_id,
      changed_at
    ) VALUES (
      NEW.id,
      OLD.status,
      NEW.status,
      NEW.updated_by,
      NOW()
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_status_history
AFTER UPDATE OF status ON menuca_v3.orders
FOR EACH ROW
EXECUTE FUNCTION track_order_status_change();
```

---

## 🔴 **PHASE 4: REAL-TIME UPDATES**

**Priority:** 🟡 MEDIUM  
**Duration:** 4-6 hours  
**Status:** ⏳ PENDING

### **4.1 Enable Supabase Realtime**

```sql
-- Enable real-time on orders table
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE menuca_v3.order_status_history;
```

### **4.2 WebSocket Subscriptions**

#### **Customer Subscription**
```typescript
// Customer subscribes to their order updates
const subscription = supabase
  .channel(`order:${orderId}`)
  .on('postgres_changes', 
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'orders',
      filter: `id=eq.${orderId}`
    },
    (payload) => {
      console.log('Order updated:', payload.new.status)
      updateOrderStatus(payload.new.status)
    }
  )
  .subscribe()
```

#### **Restaurant Subscription**
```typescript
// Restaurant subscribes to new orders
const restaurantSub = supabase
  .channel(`restaurant:${restaurantId}:orders`)
  .on('postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'orders',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      console.log('New order received!', payload.new)
      showNewOrderNotification(payload.new)
    }
  )
  .subscribe()
```

---

## 🌍 **PHASE 5: MULTI-LANGUAGE SUPPORT**

**Priority:** 🟢 LOW  
**Duration:** 3-4 hours  
**Status:** ⏳ PENDING

### **5.1 Create Translation Tables**

```sql
-- Order status translations
CREATE TABLE menuca_v3.order_status_translations (
  id SERIAL PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text VARCHAR(100) NOT NULL,
  description TEXT,
  UNIQUE(status, language)
);

-- Cancellation reason translations
CREATE TABLE menuca_v3.order_cancellation_reasons_translations (
  id SERIAL PRIMARY KEY,
  reason_code VARCHAR(50) NOT NULL,
  language VARCHAR(5) NOT NULL,
  text TEXT NOT NULL,
  UNIQUE(reason_code, language)
);

-- Insert translations for EN, ES, FR
INSERT INTO menuca_v3.order_status_translations (status, language, text) VALUES
  ('pending', 'en', 'Pending'),
  ('pending', 'es', 'Pendiente'),
  ('pending', 'fr', 'En attente'),
  ('accepted', 'en', 'Accepted'),
  ('accepted', 'es', 'Aceptado'),
  ('accepted', 'fr', 'Accepté'),
  -- ... more translations
```

### **5.2 Multi-language Functions**

```sql
-- Get order status in specific language
CREATE FUNCTION get_order_status_text(
  p_status TEXT,
  p_lang TEXT DEFAULT 'en'
) RETURNS TEXT AS $$
  SELECT COALESCE(
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = p_lang),
    (SELECT text FROM menuca_v3.order_status_translations 
     WHERE status = p_status AND language = 'en'),
    p_status
  );
$$ LANGUAGE sql STABLE;
```

---

## 🚀 **PHASE 6: ADVANCED FEATURES**

**Priority:** 🟢 LOW  
**Duration:** 4-5 hours  
**Status:** ⏳ PENDING

### **6.1 Scheduled Orders**

```sql
-- Schedule order for future delivery
CREATE FUNCTION schedule_order(
  p_order_id BIGINT,
  p_scheduled_for TIMESTAMPTZ
) RETURNS JSONB;

-- Get scheduled orders
CREATE FUNCTION get_scheduled_orders(
  p_restaurant_id BIGINT,
  p_date DATE
) RETURNS JSONB;
```

### **6.2 Tip Management**

```sql
-- Add/update tip after order
CREATE FUNCTION update_order_tip(
  p_order_id BIGINT,
  p_tip_amount DECIMAL
) RETURNS JSONB;
```

### **6.3 Order Favorites**

```sql
-- Save order as favorite
CREATE TABLE menuca_v3.favorite_orders (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES menuca_v3.users(id),
  order_id BIGINT NOT NULL REFERENCES menuca_v3.orders(id),
  nickname VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, order_id)
);
```

### **6.4 Order Modification Window**

```sql
-- Check if order can be modified
CREATE FUNCTION can_modify_order(
  p_order_id BIGINT
) RETURNS BOOLEAN AS $$
  SELECT 
    status = 'pending' 
    AND placed_at > NOW() - INTERVAL '5 minutes'
  FROM menuca_v3.orders
  WHERE id = p_order_id;
$$ LANGUAGE sql STABLE;
```

---

## ✅ **PHASE 7: TESTING & DOCUMENTATION**

**Priority:** 🔴 CRITICAL  
**Duration:** 3-4 hours  
**Status:** ⏳ PENDING

### **7.1 Comprehensive Test Suite**

```sql
-- Test order creation
SELECT create_order(
  '123e4567-e89b-12d3-a456-426614174000'::UUID,
  1,
  '[{"dish_id": 1, "quantity": 2}]'::JSONB,
  '{"street": "123 Main St"}'::JSONB,
  'credit_card'
);

-- Test order status update
SELECT update_order_status(1, 'accepted', '123e4567-e89b-12d3-a456-426614174000'::UUID, 'Restaurant accepted');

-- Test order cancellation
SELECT cancel_order(1, '123e4567-e89b-12d3-a456-426614174000'::UUID, 'Changed mind');

-- Test RLS policies
SET LOCAL role authenticated;
SET LOCAL request.jwt.claims TO '{"sub":"user-123","role":"customer"}';
SELECT * FROM menuca_v3.orders; -- Should only see own orders
```

### **7.2 Create Integration Guide**

**File:** `/documentation/Orders & Checkout/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

**Contents:**
- Business problem summary
- The solution
- Gained business logic components
- Backend functionality requirements (API endpoints)
- menuca_v3 schema modifications
- Integration patterns with Menu, Service Config, Marketing
- Code examples (TypeScript wrappers)
- Testing guide

### **7.3 Completion Report**

**File:** `/Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md`

**Metrics:**
- SQL functions created
- RLS policies implemented
- API endpoints documented
- Performance benchmarks
- Test coverage
- Integration points

---

## 🔗 **INTEGRATION POINTS**

### **With Menu & Catalog:**
- Validate dish availability before order
- Get dish pricing for total calculation
- Check inventory status

### **With Service Configuration:**
- Check if restaurant is open
- Validate order timing (ASAP vs scheduled)
- Check service type availability (delivery/takeout)

### **With Marketing & Promotions (Agent 2):**
- Apply coupon codes
- Validate deal eligibility
- Calculate discounts
- Track coupon usage

**Stub Functions for Marketing Integration:**
```sql
-- STUB: Will be implemented by Agent 2
CREATE OR REPLACE FUNCTION apply_coupon_to_order(
  p_order_id BIGINT,
  p_coupon_code TEXT
) RETURNS JSONB AS $$
BEGIN
  -- TODO: Full implementation by Marketing & Promotions entity
  RETURN jsonb_build_object(
    'success', false,
    'message', 'Marketing & Promotions entity not yet complete'
  );
END;
$$ LANGUAGE plpgsql;
```

### **With Delivery Operations:**
- Create delivery when order confirmed
- Assign driver
- Track delivery status

---

## 📊 **SUCCESS METRICS**

When complete, Orders & Checkout will have:

| Metric | Target |
|--------|--------|
| SQL Functions | 15-20 |
| RLS Policies | 35-40 |
| API Endpoints | 15-20 |
| Translation Keys | 20-30 |
| Test Cases | 50+ |
| Performance | <200ms order creation |
| Real-time Latency | <500ms |
| Documentation Pages | 9 (7 phases + guide + report) |

---

## 🎯 **NEXT STEPS**

### **Current: Phase 1 (Auth & Security)**
1. ✅ Create refactoring plan (this document)
2. 🔄 Implement RLS policies
3. ⏳ Test multi-party access
4. ⏳ Document Phase 1
5. ⏳ Create Phase 1 migration script

### **After Phase 1:**
- Phase 2: Core SQL functions & indexes
- Phase 3: Audit trails & soft delete
- Phase 4: Real-time subscriptions
- Phase 5: Multi-language support
- Phase 6: Advanced features
- Phase 7: Testing & integration guide

---

**Status:** 🚧 Phase 1 in progress  
**Created:** January 17, 2025  
**Agent:** Agent 1 (Brian)  
**Next Checkpoint:** Phase 1 completion (6-8 hours)

