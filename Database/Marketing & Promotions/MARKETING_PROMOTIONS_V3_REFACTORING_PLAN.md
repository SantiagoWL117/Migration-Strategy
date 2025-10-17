# Marketing & Promotions V3 - Enterprise Refactoring Plan

**Entity:** Marketing & Promotions  
**Current Status:** ⚠️ Tables exist, RLS partial, NO tenant isolation  
**Goal:** Enterprise-grade security & performance (Uber Eats/DoorDash standard)  
**Methodology:** Proven 6-phase approach from Service Config & Schedules  
**Date:** January 16, 2025  

---

## 🚨 **CURRENT STATE ANALYSIS**

### **Tables in Scope (5)**

| Table | Rows (Est.) | RLS Status | tenant_id | Priority |
|-------|-------------|------------|-----------|----------|
| `promotional_deals` | ~300 | ⚠️ Partial | ❌ No | HIGH |
| `promotional_coupons` | ~1,300 | ⚠️ Partial | ❌ No | HIGH |
| `marketing_tags` | ~50 | ⚠️ Partial | ❌ No | MEDIUM |
| `restaurant_tag_associations` | ~varies | ⚠️ Partial | ❌ No | MEDIUM |
| `coupon_usage_log` | ~varies | ❌ None | ❌ No | LOW |

**Total Estimated Rows:** ~1,700+

---

### **Critical Security Vulnerabilities**

**BEFORE Refactoring:**
- ❌ **No tenant_id:** Can't efficiently filter by restaurant
- ❌ **Incomplete RLS:** Some tables exposed, some protected
- ❌ **No Audit Trail:** Can't track who created/modified deals
- ❌ **No Soft Delete:** Accidental deletions permanent
- ❌ **Slow Queries:** No multi-tenant indexes
- ❌ **Data Leaks:** Restaurant A can see Restaurant B's deals/coupons

---

## 🎯 **BUSINESS REQUIREMENTS**

### **Security Goals**
1. **Multi-tenant Isolation:** Restaurant A cannot access Restaurant B's promotions
2. **Public Deals:** Customers can view active deals for restaurants
3. **Admin Control:** Super admins manage all promotions
4. **Coupon Privacy:** Customers can only see their own redeemed coupons

### **Performance Goals**
1. **Fast Deal Lookup:** < 50ms for restaurant's active deals
2. **Coupon Validation:** < 20ms to check if coupon valid
3. **Tag Filtering:** < 30ms to get restaurants by tag

### **Business Logic Goals**
1. **Deal Management:** Create, update, disable deals
2. **Coupon Redemption:** Track usage, prevent double-redemption
3. **Tag Organization:** Categorize restaurants (e.g., "Pizza", "Vegan")
4. **Audit Trail:** Track who created/modified promotions

---

## 📋 **6-PHASE REFACTORING PLAN**

### **Phase 1: Auth & Security** (4-6 hours)

**Goal:** Implement enterprise-grade RLS and multi-tenant isolation

**Tasks:**
1. Add `tenant_id UUID NOT NULL` to all 5 tables
2. Backfill `tenant_id` from `restaurant_id` → `restaurants.uuid`
3. Create indexes on `tenant_id` (fast filtering)
4. Enable RLS on all 5 tables
5. Create comprehensive RLS policies:
   - Public read active deals/coupons
   - Restaurant admins manage their promotions
   - Super admins manage all promotions
   - Customers view only their coupon usage

**Deliverables:**
- ✅ `tenant_id` on all tables
- ✅ 20+ RLS policies
- ✅ 100% multi-tenant isolation
- ✅ 5+ indexes for performance

**Documentation:**
- `PHASE_1_BACKEND_DOCUMENTATION.md`

---

### **Phase 2: Performance & APIs** (4-6 hours)

**Goal:** Create production-ready APIs for deal/coupon management

**Core APIs (5):**
1. `get_active_deals(restaurant_id)` - Get restaurant's active deals
2. `validate_coupon(code, restaurant_id)` - Check if coupon valid
3. `redeem_coupon(coupon_id, customer_id, order_id)` - Use coupon
4. `get_restaurants_by_tag(tag_id)` - Filter restaurants
5. `calculate_deal_discount(deal_id, order_total)` - Compute savings

**Performance Enhancements:**
- Composite indexes on (restaurant_id, is_active, date_start, date_stop)
- Partial indexes on active-only deals/coupons
- JSONB GIN indexes on deal conditions
- Cached coupon lookups

**Target Performance:**
- Deal lookup: < 30ms
- Coupon validation: < 20ms
- Tag filtering: < 25ms

**Deliverables:**
- ✅ 5 SQL functions
- ✅ 10+ indexes
- ✅ 6-8x faster queries

**Documentation:**
- `PHASE_2_BACKEND_DOCUMENTATION.md`

---

### **Phase 3: Schema Optimization** (3-4 hours)

**Goal:** Add audit trails, soft delete, validation

**Audit Columns (All 5 tables):**
```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
created_by INTEGER  -- User who created
updated_at TIMESTAMPTZ  -- Auto-updated
updated_by INTEGER  -- User who modified
deleted_at TIMESTAMPTZ  -- Soft delete
deleted_by BIGINT  -- User who deleted
```

**Validation Functions:**
1. `validate_deal_dates()` - Ensure date_start < date_stop
2. `check_coupon_redemption_limit()` - Prevent over-redemption
3. `validate_promo_code()` - Ensure unique promo codes

**Admin Helper Functions (5):**
1. `soft_delete_deal(deal_id)` - Safe deletion
2. `restore_deal(deal_id)` - Undelete
3. `clone_deal(deal_id, new_restaurant_id)` - Duplicate deal
4. `bulk_disable_deals(restaurant_id)` - Turn off all deals
5. `get_deal_usage_stats(deal_id)` - Analytics

**Deliverables:**
- ✅ Complete audit trail
- ✅ Soft delete on all tables
- ✅ 5 admin helper functions
- ✅ 3 validation triggers

**Documentation:**
- `PHASE_3_BACKEND_DOCUMENTATION.md`

---

### **Phase 4: Real-time Updates** (2-3 hours)

**Goal:** Enable live deal/coupon notifications

**Real-time Features:**
1. **Supabase Realtime:** Enable on all 5 tables
2. **pg_notify Triggers:** Custom notifications
3. **WebSocket Subscriptions:** Frontend real-time updates
4. **Deal Activation Alerts:** Notify customers of new deals

**Use Cases:**
- Customer sees new deal immediately
- Admin dashboard live updates
- Coupon usage updates in real-time
- Tag changes reflect instantly

**Deliverables:**
- ✅ Realtime on 5 tables
- ✅ 5 pg_notify triggers
- ✅ WebSocket integration examples

**Documentation:**
- `PHASE_4_BACKEND_DOCUMENTATION.md`

---

### **Phase 5: Multi-language Support** (2-3 hours)

**Goal:** Serve deals/coupons in multiple languages

**Functions:**
1. `get_deals_i18n(restaurant_id, language)` - Localized deals
2. `get_coupons_i18n(restaurant_id, language)` - Localized coupons
3. `translate_deal_type(deal_type, language)` - Deal type labels

**Languages Supported:**
- English (en)
- Spanish (es)
- French (fr)

**Deliverables:**
- ✅ 3 translation functions
- ✅ Multi-language support

**Documentation:**
- `PHASE_5_BACKEND_DOCUMENTATION.md`

---

### **Phase 6: Testing & Validation** (2-3 hours)

**Goal:** Comprehensive testing and performance validation

**Test Categories:**
1. **Security Tests:** Verify tenant isolation
2. **Performance Tests:** Benchmark all APIs
3. **Business Logic Tests:** Validate coupon redemption
4. **Real-time Tests:** Check WebSocket subscriptions
5. **Multi-language Tests:** Verify translations

**Success Criteria:**
- ✅ All APIs < 50ms
- ✅ 100% tenant isolation
- ✅ Zero RLS bypasses
- ✅ All functions tested

**Deliverables:**
- ✅ Test results
- ✅ Performance benchmarks
- ✅ Production readiness confirmation

**Documentation:**
- `PHASE_6_BACKEND_DOCUMENTATION.md`

---

## 📊 **EXPECTED OUTCOMES**

### **Security Improvements**

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **RLS Coverage** | 0% complete | 100% | ✅ Full protection |
| **tenant_id Columns** | 0/5 tables | 5/5 tables | ✅ Complete isolation |
| **RLS Policies** | Partial | 20+ policies | ✅ Comprehensive |
| **Audit Trail** | None | 6 columns/table | ✅ Full tracking |
| **Soft Delete** | No | Yes | ✅ Data recovery |

---

### **Performance Improvements**

| API | Before | After | Improvement |
|-----|--------|-------|-------------|
| **get_active_deals()** | ~120ms | ~20ms | **6x faster** |
| **validate_coupon()** | ~80ms | ~15ms | **5x faster** |
| **get_restaurants_by_tag()** | ~100ms | ~20ms | **5x faster** |
| **calculate_deal_discount()** | N/A | ~10ms | **New API** |

---

### **Business Logic Gained**

**Core Functions (5):**
- ✅ `get_active_deals()` - Retrieve restaurant deals
- ✅ `validate_coupon()` - Check coupon validity
- ✅ `redeem_coupon()` - Apply coupon to order
- ✅ `get_restaurants_by_tag()` - Filter by category
- ✅ `calculate_deal_discount()` - Compute savings

**Admin Functions (5):**
- ✅ `soft_delete_deal()` - Safe deletion
- ✅ `restore_deal()` - Undelete
- ✅ `clone_deal()` - Duplicate
- ✅ `bulk_disable_deals()` - Bulk operations
- ✅ `get_deal_usage_stats()` - Analytics

**Translation Functions (3):**
- ✅ `get_deals_i18n()` - Localized deals
- ✅ `get_coupons_i18n()` - Localized coupons
- ✅ `translate_deal_type()` - Type labels

**Total:** 13 production-ready functions

---

## 🗄️ **SCHEMA MODIFICATIONS SUMMARY**

### **Columns Added (Per Table)**

```sql
tenant_id UUID NOT NULL  -- Multi-tenant isolation
created_by INTEGER  -- Audit trail
updated_by INTEGER  -- Audit trail
deleted_at TIMESTAMPTZ  -- Soft delete
deleted_by BIGINT  -- Soft delete tracking
```

**Total:** 5 columns × 5 tables = **25 new columns**

---

### **Indexes Added**

```sql
-- Tenant filtering (5 indexes)
CREATE INDEX idx_{table}_tenant ON {table}(tenant_id);

-- Performance indexes (10+)
CREATE INDEX idx_deals_active_dates ON promotional_deals(restaurant_id, is_active, date_start, date_stop);
CREATE INDEX idx_coupons_code ON promotional_coupons(code);
CREATE INDEX idx_coupons_valid ON promotional_coupons(valid_from, valid_until) WHERE is_active = TRUE;
-- ... etc
```

**Total:** 15+ indexes

---

### **RLS Policies Added**

**Per Table (4-5 policies each):**
1. **Public Read Policy** - Customers view active deals
2. **Restaurant Admin Policy** - Manage own promotions
3. **Super Admin Policy** - Full access
4. **Customer Usage Policy** - View own coupon usage
5. **System Insert Policy** - Automated coupon creation

**Total:** 20+ policies

---

### **Triggers Added**

**Audit Triggers (5):**
- Auto-update `updated_at`, `updated_by`

**Validation Triggers (3):**
- Deal date validation
- Coupon redemption limit check
- Promo code uniqueness

**Real-time Triggers (5):**
- pg_notify on INSERT/UPDATE/DELETE

**Total:** 13 triggers

---

## 📅 **TIMELINE**

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Auth & Security | 4-6 hours | 4-6 hours |
| Phase 2: Performance & APIs | 4-6 hours | 8-12 hours |
| Phase 3: Schema Optimization | 3-4 hours | 11-16 hours |
| Phase 4: Real-time Updates | 2-3 hours | 13-19 hours |
| Phase 5: Multi-language | 2-3 hours | 15-22 hours |
| Phase 6: Testing & Validation | 2-3 hours | 17-25 hours |
| **Santiago Documentation** | 1 hour | **18-26 hours** |

**Total Estimated Time:** 18-26 hours

---

## 🎯 **SANTIAGO INTEGRATION**

After each phase, create:
- ✅ Business problem summary
- ✅ The solution
- ✅ Gained business logic components
- ✅ Backend functionality requirements
- ✅ menuca_v3 schema modifications

**Final Deliverable:** `SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

---

## 🚀 **READY TO START**

**Next:** Phase 1 - Auth & Security

**Let's CRUSH Marketing & Promotions!** 💪

---

**Status:** 📋 PLANNING COMPLETE | **Next:** Phase 1 Execution

