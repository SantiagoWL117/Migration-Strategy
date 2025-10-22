# 🎯 AGENT 2: Marketing & Promotions Entity - Complete Refactoring Mission

**Date:** January 17, 2025  
**Your Mission:** Transform Marketing & Promotions entity to production-ready V3 standard  
**Working Repository:** https://github.com/SantiagoWL117/Migration-Strategy  

---

## 📋 **YOUR MISSION CONTEXT**

You are Agent 2 in a **2-agent parallel refactoring operation**. While you work on Marketing & Promotions, Agent 1 is simultaneously working on Orders & Checkout. Your entities are **completely independent** with zero conflicts.

### **Current Project Status (40% Complete):**

✅ **COMPLETED (4 entities):**
1. Restaurant Management ✅
2. Menu & Catalog ✅
3. Service Configuration & Schedules ✅
4. Delivery Operations ✅ (Just finished!)

🚧 **YOUR TARGET:** Marketing & Promotions (Priority 6)  
🚧 **Agent 1 Target:** Orders & Checkout (Priority 7)

⏳ **Remaining After You:** Devices & Infrastructure, Vendors & Franchises

---

## 🎯 **YOUR SPECIFIC ASSIGNMENT: MARKETING & PROMOTIONS**

### **Entity Details:**
- **Priority:** 6 (Revenue Driver!)
- **Status:** 🟡 Complete refactoring plan exists, ready to implement
- **Dependencies:** ✅ ALL MET (Restaurants ✅, Menu ✅)
- **Tables:** promotional_deals, promotional_coupons, marketing_tags, restaurant_tag_associations, coupon_usage_log
- **Estimated Rows:** ~1,700+

### **Why This Entity is Critical:**
- 💰 **Revenue Driver** - Promotions increase order volume and customer acquisition
- 🎁 **Customer Acquisition** - Deals attract new customers
- 🔁 **Retention Tool** - Coupons drive repeat purchases
- 📊 **Analytics Gold** - Marketing data reveals what sells
- 🏆 **Competitive Edge** - Dynamic pricing and promotions

### **What Already Exists:**
```
/Database/Marketing & Promotions/
  ├── MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md ✅ (Complete plan ready!)
  └── [Various legacy migration files]
```

**IMPORTANT:** Your refactoring plan already exists! Read it first:
📂 [Marketing & Promotions V3 Refactoring Plan](./Database/Marketing%20&%20Promotions/MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md)

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
2. [MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md](./Database/Marketing%20&%20Promotions/MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md) - Your blueprint!
3. Any ONE complete entity's Integration Guide (Menu & Catalog recommended)
4. [PROJECT_CONTEXT.md](./MEMORY_BANK/PROJECT_CONTEXT.md) - Overall context

---

## 🏗️ **YOUR 7-PHASE EXECUTION PLAN**

Follow this EXACT structure (proven in 4 entities):

### **Phase 1: Authentication & Security (RLS Policies)** 🔒
**Deliverable:** `PHASE_1_BACKEND_DOCUMENTATION.md` + `PHASE_1_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Enable Row Level Security (RLS) on all tables
- ✅ Create JWT helper functions (`auth.user_id()`, `auth.role()`)
- ✅ Implement RLS policies:
  - **Public:** View active deals/coupons (read-only)
  - **Customers:** Use/redeem coupons
  - **Restaurant Staff:** Create/manage restaurant-specific deals
  - **Restaurant Admins:** Full deal management for their restaurant
  - **Platform Admins:** Manage platform-wide promotions
- ✅ Set up secure defaults (deny by default, explicit grants)

**Example RLS Policy Pattern:**
```sql
-- Public can view active deals
CREATE POLICY "Public view active deals"
  ON promotional_deals FOR SELECT
  TO public
  USING (
    is_active = true 
    AND deleted_at IS NULL
    AND NOW() BETWEEN start_date AND end_date
  );

-- Restaurant staff manage their deals
CREATE POLICY "Restaurant staff manage deals"
  ON promotional_deals FOR ALL
  TO authenticated
  USING (
    restaurant_id IN (
      SELECT restaurant_id FROM restaurant_staff 
      WHERE user_id = auth.user_id()
    ) AND auth.role() IN ('restaurant_admin', 'restaurant_manager')
  );

-- Customers can use coupons
CREATE POLICY "Customers use coupons"
  ON coupon_usage_log FOR INSERT
  TO authenticated
  WITH CHECK (
    customer_id = auth.user_id() 
    AND auth.role() = 'customer'
  );
```

---

### **Phase 2: Performance & Core APIs** ⚡
**Deliverable:** `PHASE_2_BACKEND_DOCUMENTATION.md` + `PHASE_2_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Create SQL functions (13-15 functions per your plan):
  
  **Deal Management:**
  - `get_active_deals(restaurant_id, service_type)` - Get active deals
  - `validate_deal_eligibility(deal_id, order_details)` - Check if deal applies
  - `calculate_deal_discount(deal_id, order_total)` - Calculate discount
  - `create_promotional_deal()` - Create new deal (admin)
  - `toggle_deal_status()` - Activate/deactivate deal
  
  **Coupon Management:**
  - `validate_coupon(coupon_code, customer_id, order_details)` - Validate coupon
  - `apply_coupon_to_order(order_id, coupon_code)` - Apply coupon
  - `redeem_coupon(coupon_code, customer_id, order_id)` - Redeem coupon
  - `track_coupon_usage()` - Log coupon redemption
  - `check_coupon_usage_limit(coupon_code, customer_id)` - Check usage limits
  
  **Analytics:**
  - `get_promotion_analytics(restaurant_id, date_range)` - Promotion performance
  - `get_coupon_redemption_rate(coupon_id)` - Redemption metrics
  - `get_popular_deals(restaurant_id)` - Top performing deals
  
- ✅ Create indexes for performance:
  - Deals by restaurant_id + is_active
  - Deals by start_date/end_date
  - Coupons by code (unique)
  - Coupon usage by customer_id
  - Tags by name for search

- ✅ Performance benchmarks (all queries < 100ms)

**API Endpoints to Document (15-20 endpoints):**
```
Public/Customer APIs:
1. GET /api/restaurants/:id/deals - Get active deals
2. GET /api/deals/:id - Get deal details
3. POST /api/coupons/validate - Validate coupon code
4. POST /api/coupons/apply - Apply coupon to cart
5. GET /api/restaurants/:id/tags - Get restaurant tags
6. GET /api/deals/featured - Get platform featured deals
7. GET /api/customers/me/coupons - Get my available coupons

Restaurant APIs:
8. GET /api/restaurants/:id/deals/manage - Manage deals dashboard
9. POST /api/restaurants/:id/deals - Create deal
10. PUT /api/restaurants/:id/deals/:did - Update deal
11. DELETE /api/restaurants/:id/deals/:did - Soft delete deal
12. POST /api/restaurants/:id/deals/:did/toggle - Activate/deactivate
13. GET /api/restaurants/:id/promotions/analytics - Analytics
14. POST /api/restaurants/:id/coupons - Create coupon
15. GET /api/restaurants/:id/coupons/usage - Usage stats

Admin APIs:
16. POST /api/admin/deals/platform - Create platform deal
17. GET /api/admin/promotions/all - All promotions
18. GET /api/admin/promotions/analytics - Platform analytics
19. POST /api/admin/tags - Create marketing tag
20. GET /api/admin/tags/manage - Tag management
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
  - Create `restore_deal()`, `restore_coupon()` functions
  
- ✅ Create promotion history tracking:
  - Track deal performance over time
  - Log coupon redemptions with full context
  - Analytics-ready schema

**Promotion Lifecycle:**
```
draft → scheduled → active → expired → archived
(possible: paused, cancelled)
```

---

### **Phase 4: Real-Time Updates (WebSocket)** 🔴
**Deliverable:** `PHASE_4_BACKEND_DOCUMENTATION.md` + `PHASE_4_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Enable Supabase Realtime on tables
- ✅ Set up WebSocket subscriptions:
  - **Customers:** Subscribe to new deals/coupons for favorite restaurants
  - **Restaurant Staff:** Subscribe to promotion performance updates
  - **Admin Dashboard:** Subscribe to platform-wide promotion metrics
  
- ✅ Create real-time triggers for notifications:
  - New deal published → notify customers
  - Deal expires soon → notify restaurant
  - Coupon usage threshold reached → alert
  
- ✅ Test real-time performance (< 500ms latency)

**Example Subscription:**
```typescript
// Customer subscribes to restaurant deals
const dealsSub = supabase
  .channel(`restaurant:${restaurantId}:deals`)
  .on('postgres_changes', 
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'promotional_deals',
      filter: `restaurant_id=eq.${restaurantId},is_active=eq.true`
    },
    (payload) => {
      console.log('New deal available!', payload.new)
      showNotification('New deal from your favorite restaurant!')
    }
  )
  .subscribe()

// Restaurant dashboard: Real-time redemptions
const usageSub = supabase
  .channel(`coupon-usage:${restaurantId}`)
  .on('postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'coupon_usage_log',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      updateRedemptionCount()
      console.log('Coupon redeemed!', payload.new)
    }
  )
  .subscribe()
```

---

### **Phase 5: Multi-Language Support** 🌍
**Deliverable:** `PHASE_5_BACKEND_DOCUMENTATION.md` + `PHASE_5_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ Create translation tables:
  - `promotional_deals_translations` (title, description, terms)
  - `promotional_coupons_translations` (description, terms)
  - `marketing_tags_translations` (tag display names)
  
- ✅ Support languages: EN (default), ES (Spanish), FR (French)
- ✅ Update SQL functions to accept `lang` parameter
- ✅ Implement fallback logic (FR → EN if missing)

**Translation Schema:**
```sql
CREATE TABLE promotional_deals_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID NOT NULL REFERENCES promotional_deals(id) ON DELETE CASCADE,
  language VARCHAR(5) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  terms_and_conditions TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(deal_id, language)
);

CREATE INDEX idx_deal_translations_lang ON promotional_deals_translations(deal_id, language);
```

**Example Function:**
```sql
CREATE OR REPLACE FUNCTION get_deal_with_translation(
  p_deal_id UUID,
  p_lang TEXT DEFAULT 'en'
)
RETURNS JSONB AS $$
DECLARE
  v_deal JSONB;
  v_translation RECORD;
BEGIN
  -- Get base deal
  SELECT jsonb_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'discount_type', discount_type,
    'discount_value', discount_value,
    'start_date', start_date,
    'end_date', end_date
  ) INTO v_deal
  FROM promotional_deals
  WHERE id = p_deal_id AND deleted_at IS NULL;

  -- Get translation (with fallback)
  SELECT * INTO v_translation
  FROM promotional_deals_translations
  WHERE deal_id = p_deal_id 
    AND language = p_lang;
  
  IF NOT FOUND THEN
    -- Fallback to English
    SELECT * INTO v_translation
    FROM promotional_deals_translations
    WHERE deal_id = p_deal_id 
      AND language = 'en';
  END IF;

  -- Merge translation into deal
  RETURN v_deal || jsonb_build_object(
    'title', v_translation.title,
    'description', v_translation.description,
    'terms', v_translation.terms_and_conditions
  );
END;
$$ LANGUAGE plpgsql STABLE;
```

---

### **Phase 6: Advanced Features** 🚀
**Deliverable:** `PHASE_6_BACKEND_DOCUMENTATION.md` + `PHASE_6_MIGRATION_SCRIPT.sql`

**What to Build:**
- ✅ **Dynamic Pricing:** Time-based discounts (happy hour, lunch specials)
- ✅ **Bundle Deals:** "Buy X get Y" promotions
- ✅ **First-Time Customer Offers:** Special deals for new customers
- ✅ **Loyalty Tiers:** Progressive discounts based on order history
- ✅ **Flash Sales:** Limited-time, limited-quantity deals
- ✅ **Referral Coupons:** Generate unique referral codes
- ✅ **Auto-Apply Deals:** Best deal automatically applied
- ✅ **Geofencing Deals:** Location-based promotions

**Advanced Functions:**
```sql
-- Check time-based eligibility
CREATE FUNCTION is_deal_active_now(
  p_deal_id UUID,
  p_service_type TEXT DEFAULT 'delivery'
) RETURNS BOOLEAN;

-- Get best applicable deal
CREATE FUNCTION get_best_deal_for_order(
  p_restaurant_id UUID,
  p_order_items JSONB,
  p_customer_id UUID
) RETURNS JSONB;

-- Generate referral code
CREATE FUNCTION generate_referral_coupon(
  p_customer_id UUID,
  p_discount_value DECIMAL
) RETURNS TEXT;

-- Track referral usage
CREATE FUNCTION track_referral_redemption(
  p_referral_code TEXT,
  p_referred_customer_id UUID
) RETURNS JSONB;

-- Flash sale quantity tracking
CREATE FUNCTION claim_flash_sale_slot(
  p_deal_id UUID,
  p_customer_id UUID
) RETURNS BOOLEAN;
```

---

### **Phase 7: Testing & Documentation** ✅
**Deliverable:** `MARKETING_PROMOTIONS_COMPLETION_REPORT.md`

**What to Build:**
- ✅ Comprehensive test suite:
  - Unit tests for all SQL functions
  - Integration tests for coupon flow
  - RLS policy tests (verify permissions)
  - Performance tests (load testing)
  - Edge cases (expired deals, usage limits, stacking rules)
  
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

**Test Scenarios:**
```sql
-- Test: Coupon validation
SELECT validate_coupon('SUMMER20', 'customer-123', '{...}');

-- Test: Deal eligibility
SELECT validate_deal_eligibility('deal-456', '{...}');

-- Test: Usage limits
SELECT check_coupon_usage_limit('WELCOME10', 'customer-123');

-- Test: Best deal selection
SELECT get_best_deal_for_order('restaurant-789', '[{...}]', 'customer-123');

-- Test: RLS policies
SET LOCAL role authenticated;
SET LOCAL request.jwt.claims TO '{"sub":"user-123","role":"customer"}';
SELECT * FROM promotional_deals; -- Should only see active deals
```

---

## 📁 **YOUR DELIVERABLES STRUCTURE**

Create files in this exact structure:

```
/Database/Marketing & Promotions/
├── MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md (already exists!)
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
└── MARKETING_PROMOTIONS_COMPLETION_REPORT.md

/documentation/Marketing & Promotions/
└── SANTIAGO_BACKEND_INTEGRATION_GUIDE.md (master guide)
```

---

## 🎯 **SUCCESS CRITERIA**

Your entity is complete when:

✅ **7 phases delivered** with documentation + SQL scripts  
✅ **13-15 SQL functions** created and tested  
✅ **20+ RLS policies** implemented and verified  
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

2. **Your Blueprint (READ THIS FIRST!):**
   - [MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md](./Database/Marketing%20&%20Promotions/MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md)

3. **Best Pattern References:**
   - [Menu & Catalog Integration Guide](./documentation/Menu%20&%20Catalog/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
   - [Delivery Operations Integration Guide](./documentation/Delivery%20Operations/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

4. **Phase Examples (Pick ONE entity, read all phases):**
   - [Menu & Catalog Phases 1-7](./Database/Menu%20&%20Catalog%20Entity/)
   - OR [Delivery Operations Phases 1-7](./Database/Delivery%20Operations/)

5. **Study the Pattern:**
   - Notice the structure of documentation
   - Copy the SQL function style
   - Replicate the RLS policy patterns
   - Match the API documentation format

---

## 🚀 **EXECUTION CHECKLIST**

### **Before You Start:**
- [ ] Read SANTIAGO_MASTER_INDEX.md
- [ ] Read MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md (your blueprint!)
- [ ] Read one complete Integration Guide (Menu & Catalog recommended)
- [ ] Skim through one entity's 7 phases to understand the pattern
- [ ] Clone the repository and review existing Marketing & Promotions files
- [ ] Understand dependencies (Restaurants, Menu schemas)

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
- [ ] Create MARKETING_PROMOTIONS_COMPLETION_REPORT.md
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

### **Think Like a Marketer:**
- What promotions drive sales?
- How do we prevent coupon fraud?
- What analytics do we need?
- How do we A/B test deals?

### **Integration Points:**
Marketing & Promotions integrates with:
- **Restaurants:** Restaurant-specific deals
- **Menu & Catalog:** Item-specific promotions
- **Orders & Checkout:** Apply discounts at checkout (Agent 1 is building this!)
- **Users & Access:** Customer-specific coupons
- **Analytics:** Track promotion ROI

---

## 📞 **COORDINATION WITH AGENT 1**

You are working in parallel with Agent 1 (Orders & Checkout). Here's how to coordinate:

### **Your Integration Point:**
Orders & Checkout will need to call YOUR functions:
- `apply_coupon_to_order(order_id, coupon_code)` - Apply coupon discount
- `validate_deal_eligibility(deal_id, order_details)` - Check if deal applies
- `track_coupon_usage(coupon_code, customer_id, order_id)` - Log coupon redemption
- `calculate_deal_discount(deal_id, order_total)` - Calculate discount

### **Design for Integration:**
Agent 1 will create stub functions that YOU will replace:
```sql
-- Agent 1 creates stub, YOU implement the real function
CREATE OR REPLACE FUNCTION apply_coupon_to_order(
  p_order_id UUID,
  p_coupon_code TEXT
)
RETURNS JSONB AS $$
DECLARE
  v_coupon RECORD;
  v_order RECORD;
  v_discount DECIMAL;
BEGIN
  -- YOUR IMPLEMENTATION HERE
  -- 1. Validate coupon exists and is active
  -- 2. Check usage limits
  -- 3. Validate eligibility rules
  -- 4. Calculate discount
  -- 5. Track usage
  -- 6. Return result
  
  RETURN jsonb_build_object(
    'success', true,
    'discount_amount', v_discount,
    'coupon_id', v_coupon.id,
    'message', 'Coupon applied successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### **Document Integration:**
In your Integration Guide, add section:
```markdown
## Integration with Orders & Checkout

Marketing & Promotions provides these functions for order processing:
- `apply_coupon_to_order()` - Called during checkout
- `validate_deal_eligibility()` - Called when adding items to cart
- `calculate_deal_discount()` - Called during total calculation
- `track_coupon_usage()` - Called after order confirmation

**Status:** Functions ready for Orders & Checkout integration.

**Usage Example:**
\`\`\`typescript
// In checkout flow
const result = await supabase.rpc('apply_coupon_to_order', {
  p_order_id: orderId,
  p_coupon_code: 'SUMMER20'
})

if (result.data.success) {
  updateOrderTotal(result.data.discount_amount)
}
\`\`\`
```

---

## 🎯 **YOUR STARTING POINT**

1. **Read this entire prompt** (you're here! ✅)
2. **Read SANTIAGO_MASTER_INDEX.md** to understand the big picture
3. **Read MARKETING_PROMOTIONS_V3_REFACTORING_PLAN.md** (your blueprint!)
4. **Read Menu & Catalog Integration Guide** as your template
5. **Start Phase 1** (Auth & Security)
6. **Execute phases 1-7** sequentially
7. **Create final Integration Guide**
8. **Report completion**

---

## 📊 **EXPECTED METRICS (Your Goals)**

When complete, you should deliver:

| Metric | Target |
|--------|--------|
| SQL Functions | 13-15 |
| RLS Policies | 20-30 |
| API Endpoints | 15-20 |
| Translation Keys | 30-40 |
| Test Cases | 40+ |
| Performance | <100ms per query |
| Real-time Latency | <500ms |
| Documentation Pages | 9 (7 phases + guide + report) |

---

## 🎁 **BONUS: MARKETING-SPECIFIC FEATURES**

Since you're building Marketing & Promotions, consider these advanced features:

### **Fraud Prevention:**
- Rate limiting on coupon attempts
- Device fingerprinting for multi-account detection
- Geographic restrictions
- Email/phone verification for high-value coupons

### **A/B Testing:**
- Split test different deal formats
- Track conversion rates
- Automatic winner selection

### **Personalization:**
- Customer segment targeting
- Behavior-based deal recommendations
- Purchase history analysis

### **Gamification:**
- Scratch-off coupons
- Spin-to-win wheels
- Progressive unlock deals

---

## 🏁 **READY? LET'S GO!**

You have everything you need:
- ✅ Clear mission (Marketing & Promotions)
- ✅ Proven pattern (4 completed entities)
- ✅ Reference materials (documentation)
- ✅ **Complete refactoring plan** (your blueprint!)
- ✅ Phase-by-phase instructions
- ✅ Success criteria
- ✅ Support (Brian for questions)

**Time to build! 🚀**

Your work will enable:
- 🎁 Restaurants to create attractive deals
- 💰 Platform to drive revenue through promotions
- 🎯 Targeted marketing campaigns
- 📊 Promotion ROI analytics
- 🔁 Customer retention through coupons

**Go make it happen, Agent 2! 💪**

---

**Questions?** Ask Brian or reference SANTIAGO_MASTER_INDEX.md  
**Stuck?** Look at how Menu & Catalog or Delivery Operations solved similar problems  
**Done?** Update SANTIAGO_MASTER_INDEX.md and celebrate! 🎉

