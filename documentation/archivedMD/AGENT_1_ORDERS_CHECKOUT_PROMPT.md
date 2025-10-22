# 🎯 AGENT 1: Orders & Checkout Entity - Complete Refactoring Mission

**Date:** January 17, 2025  
**Your Mission:** Transform Orders & Checkout entity to production-ready V3 standard  
**Working Repository:** https://github.com/SantiagoWL117/Migration-Strategy  

---

## 📋 **YOUR MISSION CONTEXT**

You are Agent 1 in a **2-agent parallel refactoring operation**. While you work on Orders & Checkout, Agent 2 is simultaneously working on Marketing & Promotions. Your entities are **completely independent** with zero conflicts.

### **Current Project Status (40% Complete):**

✅ **COMPLETED (4 entities):**
1. Restaurant Management ✅
2. Menu & Catalog ✅
3. Service Configuration & Schedules ✅
4. Delivery Operations ✅ (Just finished!)

🚧 **YOUR TARGET:** Orders & Checkout (Priority 7)  
🚧 **Agent 2 Target:** Marketing & Promotions (Priority 6)

⏳ **Remaining After You:** Devices & Infrastructure, Vendors & Franchises

---

## 🎯 **YOUR SPECIFIC ASSIGNMENT: ORDERS & CHECKOUT**

### **Entity Details:**
- **Priority:** 7 (Critical Path - Revenue Flow!)
- **Status:** ⏳ Basic files exist, needs complete refactoring
- **Dependencies:** ✅ ALL MET (Menu ✅, Users ✅, Service Config ✅)
- **Tables:** orders, order_items, order_payments, order_status_history, checkout_sessions

### **Why This Entity is Critical:**
- 💰 **Revenue Critical** - This is where money flows through the system
- 🛒 **Core Business Function** - Can't process customer orders without it
- 🔗 **Integration Hub** - Connects Menu, Users, Service Config, and Delivery
- 📊 **Analytics Foundation** - Order data drives business intelligence

### **What Already Exists:**
```
/Database/Orders_&_Checkout/
  ├── 01_create_v3_order_schema.sql (basic schema)
  ├── DATA_NEEDED.md (requirements doc)
  └── PHASE_1_SUMMARY.md (initial planning)
```

---

## 📖 **YOUR INSTRUCTION MANUAL: FOLLOW THE PROVEN PATTERN**

You MUST follow the exact same pattern used in the 4 completed entities. Study these as your blueprints:

### **🌟 REFERENCE ENTITIES (Your Templates):**

1. **Menu & Catalog** (Best reference for customer-facing features)
   - [Integration Guide](./documentation/Menu%20&%20Catalog/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
   - [7 Phase Documentation](./Database/Menu%20&%20Catalog%20Entity/)
   
2. **Service Config & Schedules** (Best reference for business logic)
   - [Integration Guide](./documentation/Service%20Configuration%20&%20Schedules/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
   - [4 Phase Documentation](./Database/Service%20Configuration%20&%20Schedules/)

3. **Delivery Operations** (Best reference for complex workflows)
   - [Integration Guide](./documentation/Delivery%20Operations/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
   - [7 Phase Documentation](./Database/Delivery%20Operations/)

### **📚 READ THESE FIRST:**
Before starting, read:
1. [SANTIAGO_MASTER_INDEX.md](./SANTIAGO_MASTER_INDEX.md) - Big picture
2. Any ONE complete entity's Integration Guide (Menu & Catalog recommended)
3. [PROJECT_CONTEXT.md](./MEMORY_BANK/PROJECT_CONTEXT.md) - Overall context

---

## 🏗️ **YOUR 7-PHASE EXECUTION PLAN**

Follow this EXACT structure (proven in 4 entities):

### **Phase 1: Authentication & Security (RLS Policies)** 🔒
**Deliverable:** `PHASE_1_BACKEND_DOCUMENTATION.md` + `PHASE_1_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Enable Row Level Security (RLS) on all tables
- ✅ Create JWT helper functions (`auth.user_id()`, `auth.role()`)
- ✅ Implement RLS policies:
  - Customers: View own orders only
  - Restaurant staff: View orders for their restaurant
  - Admins: View all orders
  - Service accounts: API access for payment processing
- ✅ Set up secure defaults (deny by default, explicit grants)

**Example RLS Policy Pattern:**
```sql
-- Customers view own orders
CREATE POLICY "Customers view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (customer_id = auth.user_id() AND auth.role() = 'customer');

-- Restaurant staff view their orders
CREATE POLICY "Restaurant staff view orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurant_staff WHERE user_id = auth.user_id()
    ) AND auth.role() IN ('restaurant_admin', 'restaurant_staff')
  );
```

---

### **Phase 2: Performance & Core APIs** ⚡
**Deliverable:** `PHASE_2_BACKEND_DOCUMENTATION.md` + `PHASE_2_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Create SQL functions (10-15 functions):
  - `calculate_order_total()` - Calculate order total with tax
  - `validate_order()` - Validate order before submission
  - `create_order()` - Create order with items
  - `update_order_status()` - Update status with history tracking
  - `get_order_details()` - Get complete order info
  - `check_order_eligibility()` - Check if user can order (hours, zones)
  - `apply_promotions()` - Calculate discounts (integrate with Marketing entity later)
  - `calculate_delivery_fee()` - Calculate delivery cost
  - `get_customer_order_history()` - Paginated order history
  - `get_restaurant_orders()` - Restaurant order queue
  
- ✅ Create indexes for performance:
  - Orders by customer_id
  - Orders by restaurant_id
  - Orders by status + created_at
  - Order_items by order_id
  - Payment status lookups

- ✅ Performance benchmarks (all queries < 100ms)

**API Endpoints to Document (15-20 endpoints):**
```
Customer APIs:
1. POST /api/orders/checkout - Start checkout session
2. POST /api/orders - Create order
3. GET /api/orders/:id - Get order details
4. GET /api/orders/me - Get my order history
5. PUT /api/orders/:id/cancel - Cancel order (if eligible)
6. POST /api/orders/:id/reorder - Reorder previous order
7. GET /api/orders/:id/receipt - Get receipt

Restaurant APIs:
8. GET /api/restaurants/:rid/orders - Get order queue
9. PUT /api/restaurants/:rid/orders/:id/accept - Accept order
10. PUT /api/restaurants/:rid/orders/:id/reject - Reject order
11. PUT /api/restaurants/:rid/orders/:id/ready - Mark ready for pickup/delivery
12. GET /api/restaurants/:rid/orders/stats - Order statistics

Admin APIs:
13. GET /api/admin/orders - All orders (paginated)
14. GET /api/admin/orders/:id - Order details with full audit
15. POST /api/admin/orders/:id/refund - Issue refund
16. GET /api/admin/orders/analytics - Order analytics

Payment APIs:
17. POST /api/orders/:id/payment - Process payment
18. GET /api/orders/:id/payment/status - Check payment status
19. POST /api/orders/:id/payment/retry - Retry failed payment
20. POST /api/webhooks/payment - Payment webhook handler
```

---

### **Phase 3: Schema Optimization (Audit Trails & Soft Delete)** 📊
**Deliverable:** `PHASE_3_BACKEND_DOCUMENTATION.md` + `PHASE_3_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Add audit columns to all tables:
  ```sql
  created_at TIMESTAMPTZ DEFAULT NOW()
  updated_at TIMESTAMPTZ DEFAULT NOW()
  created_by UUID REFERENCES users(id)
  updated_by UUID REFERENCES users(id)
  deleted_at TIMESTAMPTZ  -- soft delete
  deleted_by UUID REFERENCES users(id)
  ```

- ✅ Create audit triggers (auto-update `updated_at`)
- ✅ Implement soft delete:
  - Add `deleted_at` column
  - Update RLS policies to filter deleted records
  - Create `restore_order()` function
  
- ✅ Create order status history tracking:
  - `order_status_history` table
  - Automatic trigger on status change
  - Complete audit trail for compliance

**Order Status Flow:**
```
pending → confirmed → preparing → ready → 
(pickup: completed | delivery: out_for_delivery → delivered) →
(possible: cancelled, refunded)
```

---

### **Phase 4: Real-Time Updates (WebSocket)** 🔴
**Deliverable:** `PHASE_4_BACKEND_DOCUMENTATION.md` + `PHASE_4_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Enable Supabase Realtime on tables
- ✅ Set up WebSocket subscriptions:
  - Customer: Subscribe to their order updates
  - Restaurant: Subscribe to new orders queue
  - Driver: Subscribe to assigned delivery updates
  
- ✅ Create real-time triggers for notifications
- ✅ Test real-time performance (< 500ms latency)

**Example Subscription:**
```typescript
// Customer subscribes to their order
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
    }
  )
  .subscribe()

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
    }
  )
  .subscribe()
```

---

### **Phase 5: Multi-Language Support** 🌍
**Deliverable:** `PHASE_5_BACKEND_DOCUMENTATION.md` + `PHASE_5_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Create translation tables:
  - `order_status_translations` (pending, confirmed, etc.)
  - `order_cancellation_reasons_translations`
  
- ✅ Support languages: EN (default), ES (Spanish), FR (French)
- ✅ Update SQL functions to accept `lang` parameter
- ✅ Implement fallback logic (FR → EN if missing)

**Example Function:**
```sql
CREATE OR REPLACE FUNCTION get_order_status_text(
  p_status TEXT,
  p_lang TEXT DEFAULT 'en'
)
RETURNS TEXT AS $$
  SELECT COALESCE(
    (SELECT text FROM order_status_translations 
     WHERE status = p_status AND language = p_lang),
    (SELECT text FROM order_status_translations 
     WHERE status = p_status AND language = 'en'),
    p_status  -- fallback to raw status
  );
$$ LANGUAGE sql STABLE;
```

---

### **Phase 6: Advanced Features** 🚀
**Deliverable:** `PHASE_6_BACKEND_DOCUMENTATION.md` + `PHASE_6_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ **Order Scheduling:** Schedule orders for future delivery
- ✅ **Tip Management:** Add tipping for drivers
- ✅ **Order Notes:** Special instructions, allergy info
- ✅ **Favorites:** Save favorite orders for quick reorder
- ✅ **Batch Processing:** Bulk order operations for restaurants
- ✅ **Order Modification:** Allow order edits before confirmation (time window)

**Additional Functions:**
```sql
-- Schedule order for future
CREATE FUNCTION schedule_order(
  p_order_id UUID,
  p_scheduled_for TIMESTAMPTZ
) RETURNS JSONB;

-- Add/update tip
CREATE FUNCTION update_order_tip(
  p_order_id UUID,
  p_tip_amount DECIMAL
) RETURNS JSONB;

-- Check if order can be modified
CREATE FUNCTION can_modify_order(
  p_order_id UUID
) RETURNS BOOLEAN;
```

---

### **Phase 7: Testing & Documentation** ✅
**Deliverable:** `ORDERS_CHECKOUT_COMPLETION_REPORT.md`

**What to Build:**
- ✅ Comprehensive test suite:
  - Unit tests for all SQL functions
  - Integration tests for order flow
  - RLS policy tests (verify permissions)
  - Performance tests (load testing)
  
- ✅ **SANTIAGO_BACKEND_INTEGRATION_GUIDE.md** (Master document)
  - Business problem summary
  - The solution
  - Gained business logic components
  - Backend functionality requirements (API endpoints)
  - menuca_v3 schema modifications
  - Integration patterns
  - Code examples
  
- ✅ Completion report with metrics
- ✅ Deployment checklist

---

## 📁 **YOUR DELIVERABLES STRUCTURE**

Create files in this exact structure:

```
/Database/Orders_&_Checkout/
├── ORDERS_CHECKOUT_V3_REFACTORING_PLAN.md (overall plan)
├── PHASE_1_BACKEND_DOCUMENTATION.md
├── PHASE_1_MIGRATION_SCRIPT.sql
├── PHASE_2_BACKEND_DOCUMENTATION.md
├── PHASE_2_MIGRATION_SCRIPT.sql
├── PHASE_3_BACKEND_DOCUMENTATION.md
├── PHASE_3_MIGRATION_SCRIPT.sql
├── PHASE_4_BACKEND_DOCUMENTATION.md
├── PHASE_4_MIGRATION_SCRIPT.sql
├── PHASE_5_BACKEND_DOCUMENTATION.md
├── PHASE_5_MIGRATION_SCRIPT.sql
├── PHASE_6_BACKEND_DOCUMENTATION.md
├── PHASE_6_MIGRATION_SCRIPT.sql
├── PHASE_7_BACKEND_DOCUMENTATION.md
├── PHASE_7_MIGRATION_SCRIPT.sql
└── ORDERS_CHECKOUT_COMPLETION_REPORT.md

/documentation/Orders & Checkout/
└── SANTIAGO_BACKEND_INTEGRATION_GUIDE.md (master guide)
```

---

## 🎯 **SUCCESS CRITERIA**

Your entity is complete when:

✅ **7 phases delivered** with documentation + SQL scripts  
✅ **15-20 SQL functions** created and tested  
✅ **30+ RLS policies** implemented and verified  
✅ **15-20 API endpoints** documented with examples  
✅ **Real-time subscriptions** working (<500ms)  
✅ **Multi-language support** (EN/ES/FR)  
✅ **Performance benchmarks met** (all queries <100ms)  
✅ **SANTIAGO_BACKEND_INTEGRATION_GUIDE.md** created  
✅ **All tests passing** (unit, integration, RLS, performance)  
✅ **Completion report** with metrics delivered  

---

## 🎓 **STUDY MATERIALS (READ THESE FIRST!)**

### **Required Reading (Priority Order):**

1. **Big Picture:**
   - [SANTIAGO_MASTER_INDEX.md](./SANTIAGO_MASTER_INDEX.md)
   - [PROJECT_CONTEXT.md](./MEMORY_BANK/PROJECT_CONTEXT.md)

2. **Best Pattern References:**
   - [Menu & Catalog Integration Guide](./documentation/Menu%20&%20Catalog/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
   - [Delivery Operations Integration Guide](./documentation/Delivery%20Operations/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

3. **Phase Examples (Pick ONE entity, read all 7 phases):**
   - [Menu & Catalog Phases 1-7](./Database/Menu%20&%20Catalog%20Entity/)
   - OR [Delivery Operations Phases 1-7](./Database/Delivery%20Operations/)

4. **Study the Pattern:**
   - Notice the structure of documentation
   - Copy the SQL function style
   - Replicate the RLS policy patterns
   - Match the API documentation format

---

## 🚀 **EXECUTION CHECKLIST**

### **Before You Start:**
- [ ] Read SANTIAGO_MASTER_INDEX.md
- [ ] Read one complete Integration Guide (Menu & Catalog recommended)
- [ ] Skim through one entity's 7 phases to understand the pattern
- [ ] Clone the repository and review existing Orders & Checkout files
- [ ] Understand dependencies (Menu, Users, Service Config schemas)

### **Phase by Phase:**
For each phase (1-7):
- [ ] Create `PHASE_X_BACKEND_DOCUMENTATION.md`
- [ ] Create `PHASE_X_MIGRATION_SCRIPT.sql`
- [ ] Test SQL script locally (if possible)
- [ ] Document all functions with examples
- [ ] Include TypeScript API wrapper examples
- [ ] Add test cases for the phase
- [ ] Update progress in documentation

### **Final Deliverables:**
- [ ] Create SANTIAGO_BACKEND_INTEGRATION_GUIDE.md (master document)
- [ ] Create ORDERS_CHECKOUT_COMPLETION_REPORT.md
- [ ] Update SANTIAGO_MASTER_INDEX.md to mark entity complete
- [ ] Push all changes to GitHub
- [ ] Report completion to Brian

---

## 💡 **TIPS FOR SUCCESS**

### **Copy What Works:**
- Don't reinvent the wheel
- Copy SQL function patterns from Menu & Catalog
- Copy RLS policy patterns from Service Config
- Copy documentation structure from ANY completed entity

### **Focus on Quality:**
- Each phase should be production-ready
- Include comprehensive examples
- Add TypeScript wrappers for Santiago
- Document edge cases and error handling

### **Think Like Santiago (Backend Developer):**
- He needs clear API contracts
- He needs working code examples
- He needs performance benchmarks
- He needs security guidelines
- Make his life easy!

### **Integration Points:**
Orders & Checkout integrates with:
- **Menu & Catalog:** Dish selection, inventory checking
- **Users & Access:** Customer authentication, restaurant staff
- **Service Config:** Check if restaurant is open for orders
- **Delivery Operations:** Create delivery when order is confirmed (future)
- **Marketing & Promotions:** Apply coupons/deals (Agent 2 is building this!)

---

## 📞 **COORDINATION WITH AGENT 2**

You are working in parallel with Agent 2 (Marketing & Promotions). Here's how to coordinate:

### **Your Integration Point:**
Orders & Checkout will need to call Marketing & Promotions functions:
- `apply_coupon_to_order()` - Apply coupon discount
- `validate_deal_eligibility()` - Check if deal applies
- `track_coupon_usage()` - Log coupon redemption

### **Stub These Functions:**
For now, create stub functions that Agent 2 will implement:
```sql
-- Stub: Will be implemented by Marketing & Promotions entity
CREATE OR REPLACE FUNCTION apply_coupon_to_order(
  p_order_id UUID,
  p_coupon_code TEXT
)
RETURNS JSONB AS $$
BEGIN
  -- TODO: Implement after Marketing & Promotions completion
  RETURN jsonb_build_object(
    'success', false,
    'message', 'Coupon system not yet implemented'
  );
END;
$$ LANGUAGE plpgsql;
```

### **Document Integration:**
In your Integration Guide, add section:
```markdown
## Integration with Marketing & Promotions (Future)

Orders will integrate with Marketing & Promotions for:
- Coupon code validation
- Deal application
- Discount calculation
- Usage tracking

**Status:** Stub functions created. Full integration after Agent 2 completes Marketing entity.
```

---

## 🎯 **YOUR STARTING POINT**

1. **Read this entire prompt** (you're here! ✅)
2. **Read SANTIAGO_MASTER_INDEX.md** to understand the big picture
3. **Read Menu & Catalog Integration Guide** as your template
4. **Create ORDERS_CHECKOUT_V3_REFACTORING_PLAN.md** (overall plan)
5. **Start Phase 1** (Auth & Security)
6. **Execute phases 1-7** sequentially
7. **Create final Integration Guide**
8. **Report completion**

---

## 📊 **EXPECTED METRICS (Your Goals)**

When complete, you should deliver:

| Metric | Target |
|--------|--------|
| SQL Functions | 15-20 |
| RLS Policies | 30-40 |
| API Endpoints | 15-20 |
| Translation Keys | 20-30 |
| Test Cases | 50+ |
| Performance | <100ms per query |
| Real-time Latency | <500ms |
| Documentation Pages | 9 (7 phases + guide + report) |

---

## 🏁 **READY? LET'S GO!**

You have everything you need:
- ✅ Clear mission (Orders & Checkout)
- ✅ Proven pattern (4 completed entities)
- ✅ Reference materials (documentation)
- ✅ Phase-by-phase instructions
- ✅ Success criteria
- ✅ Support (Brian for questions)

**Time to build! 🚀**

Your work will enable:
- 🛒 Customers to place orders
- 💰 Revenue to flow through the system
- 📊 Business analytics and reporting
- 🔗 Integration with delivery system
- 📱 Mobile and web ordering

**Go make it happen, Agent 1! 💪**

---

**Questions?** Ask Brian or reference SANTIAGO_MASTER_INDEX.md  
**Stuck?** Look at how Menu & Catalog or Delivery Operations solved similar problems  
**Done?** Update SANTIAGO_MASTER_INDEX.md and celebrate! 🎉

