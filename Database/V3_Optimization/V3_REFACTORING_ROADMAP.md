# V3 Database Refactoring Roadmap - Phases 6-10

**Created:** October 14, 2025  
**Status:** 📋 READY TO EXECUTE  
**Team:** Brian + Santiago (Parallel Work Possible!)  
**Context:** Phases 1-5 Complete (Admin, Archive, Constraints, Naming, Pricing) ✅

---

## 🎯 **Objective**

Continue optimizing menuca_v3 schema beyond the initial 5 phases. Focus on performance, data integrity, and developer experience for the new application.

---

## ✅ **What's Already Done (Phases 1-5)**

- ✅ Admin tables consolidated (3→2)
- ✅ Legacy tables archived (2 tables)
- ✅ Critical constraints added (14 NOT NULL)
- ✅ Columns renamed for consistency (17 columns)
- ✅ JSONB pricing migrated to relational (7,502 records)

**Impact So Far:** 27 tables touched, 9,988 rows processed, 0% data loss

---

## 📊 **Remaining Opportunities (5 Phases)**

---

## 🔴 **PHASE 6: Performance Indexes** (HIGH PRIORITY)

**Goal:** Add missing indexes on foreign keys and frequently queried columns  
**Impact:** 🔴 HIGH - Dramatically improves query performance  
**Effort:** 🟢 LOW (1-2 hours)  
**Risk:** 🟢 ZERO (additive only, non-breaking)  
**Can Run in Parallel:** ✅ YES (doesn't conflict with other phases)

### **What's Missing:**

Many foreign key columns lack indexes, causing slow joins. These should be indexed:

| Table | Column | Why Index? | Priority |
|-------|--------|-----------|----------|
| `dishes` | `restaurant_id` | Join to restaurants | 🔴 HIGH |
| `dishes` | `course_id` | Join to courses | 🔴 HIGH |
| `ingredients` | `dish_id` | Join to dishes | 🔴 HIGH |
| `ingredient_groups` | `ingredient_id` | Join to ingredients | 🔴 HIGH |
| `combo_items` | `combo_group_id` | Join to combos | 🔴 HIGH |
| `combo_items` | `dish_id` | Join to dishes | 🔴 HIGH |
| `dish_modifiers` | `dish_id` | Join to dishes | 🟡 MEDIUM |
| `dish_customizations` | `dish_id` | Join to dishes | 🟡 MEDIUM |
| `promotional_deals` | `restaurant_id` | Filter by restaurant | 🟡 MEDIUM |
| `promotional_coupons` | `deal_id` | Join to deals | 🟡 MEDIUM |
| `user_delivery_addresses` | `user_id` | User's addresses | 🟡 MEDIUM |
| `user_delivery_addresses` | `city_id` | Filter by city | 🟢 LOW |

### **Execution Plan:**

```sql
-- Step 1: Analyze current index usage
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'menuca_v3'
ORDER BY idx_scan DESC;

-- Step 2: Add missing FK indexes (batch 1 - HIGH priority)
BEGIN;

CREATE INDEX CONCURRENTLY idx_dishes_restaurant_id ON menuca_v3.dishes(restaurant_id);
CREATE INDEX CONCURRENTLY idx_dishes_course_id ON menuca_v3.dishes(course_id);
CREATE INDEX CONCURRENTLY idx_ingredients_dish_id ON menuca_v3.ingredients(dish_id);
CREATE INDEX CONCURRENTLY idx_ingredient_groups_ingredient_id ON menuca_v3.ingredient_groups(ingredient_id);
CREATE INDEX CONCURRENTLY idx_combo_items_combo_group_id ON menuca_v3.combo_items(combo_group_id);
CREATE INDEX CONCURRENTLY idx_combo_items_dish_id ON menuca_v3.combo_items(dish_id);

COMMIT;

-- Step 3: Validate indexes created
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'menuca_v3' 
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
```

### **Success Criteria:**
- [ ] All HIGH priority FK columns have indexes
- [ ] Index creation completes without errors
- [ ] Query performance improves (test with EXPLAIN ANALYZE)

### **Assignment:**
- **Owner:** ⬜ Unassigned (Brian or Santiago)
- **Estimated Time:** 1-2 hours
- **Can Start:** ✅ Immediately

---

## 🟡 **PHASE 7: Enum Standardization** (MEDIUM PRIORITY)

**Goal:** Convert string-based status columns to proper PostgreSQL ENUMs  
**Impact:** 🟡 MEDIUM - Better data integrity, smaller storage  
**Effort:** 🟡 MEDIUM (3-4 hours)  
**Risk:** 🟡 MEDIUM (requires data validation, app coordination)  
**Can Run in Parallel:** ⚠️ PARTIAL (avoid same tables as other work)

### **Candidate Columns:**

| Table | Column | Current Type | Suggested Enum Values | Priority |
|-------|--------|--------------|----------------------|----------|
| `restaurants` | `status` | VARCHAR | 'active', 'inactive', 'suspended', 'pending' | 🔴 HIGH |
| `users` | `status` | VARCHAR | 'active', 'inactive', 'suspended', 'deleted' | 🔴 HIGH |
| `promotional_deals` | `status` | VARCHAR | 'active', 'inactive', 'scheduled', 'expired' | 🟡 MEDIUM |
| `promotional_coupons` | `status` | VARCHAR | 'active', 'inactive', 'used', 'expired' | 🟡 MEDIUM |
| `dishes` | `visibility` | VARCHAR? | 'visible', 'hidden', 'out_of_stock' | 🟢 LOW |

### **Execution Plan:**

```sql
-- Step 1: Analyze current values
SELECT DISTINCT status, COUNT(*) as count
FROM menuca_v3.restaurants
GROUP BY status
ORDER BY count DESC;

-- Step 2: Create enum types
CREATE TYPE menuca_v3.restaurant_status AS ENUM ('active', 'inactive', 'suspended', 'pending');
CREATE TYPE menuca_v3.user_status AS ENUM ('active', 'inactive', 'suspended', 'deleted');

-- Step 3: Add new column with enum type
ALTER TABLE menuca_v3.restaurants ADD COLUMN status_new menuca_v3.restaurant_status;

-- Step 4: Migrate data
UPDATE menuca_v3.restaurants 
SET status_new = CASE 
  WHEN LOWER(status) = 'active' THEN 'active'::menuca_v3.restaurant_status
  WHEN LOWER(status) = 'inactive' THEN 'inactive'::menuca_v3.restaurant_status
  WHEN LOWER(status) = 'suspended' THEN 'suspended'::menuca_v3.restaurant_status
  WHEN LOWER(status) = 'pending' THEN 'pending'::menuca_v3.restaurant_status
  ELSE 'active'::menuca_v3.restaurant_status
END;

-- Step 5: Swap columns (requires app coordination!)
-- ALTER TABLE menuca_v3.restaurants DROP COLUMN status;
-- ALTER TABLE menuca_v3.restaurants RENAME COLUMN status_new TO status;
```

### **Success Criteria:**
- [ ] All status values map cleanly to enum values
- [ ] No invalid data found
- [ ] App code updated to use enum values
- [ ] Rollback plan tested

### **Assignment:**
- **Owner:** ⬜ Unassigned (Requires app team coordination)
- **Estimated Time:** 3-4 hours
- **Can Start:** ⚠️ After app team review

---

## 🟡 **PHASE 8: Soft Delete Infrastructure** (MEDIUM PRIORITY)

**Goal:** Add soft delete capability to key tables (mark as deleted instead of physical delete)  
**Impact:** 🟡 MEDIUM - Better audit trail, data recovery, compliance  
**Effort:** 🟡 MEDIUM (2-3 hours)  
**Risk:** 🟢 LOW (additive only, doesn't break existing functionality)  
**Can Run in Parallel:** ✅ YES (independent of other phases)

### **Tables Needing Soft Delete:**

| Table | Priority | Reason |
|-------|----------|--------|
| `users` | 🔴 HIGH | Legal compliance (GDPR), customer service |
| `restaurants` | 🔴 HIGH | Business records, historical data |
| `dishes` | 🟡 MEDIUM | Menu history, reactivation capability |
| `promotional_deals` | 🟡 MEDIUM | Campaign history, analysis |
| `promotional_coupons` | 🟡 MEDIUM | Fraud prevention, auditing |
| `admin_users` | 🟢 LOW | Access control auditing |

### **Execution Plan:**

```sql
-- Step 1: Add soft delete columns to key tables
BEGIN;

ALTER TABLE menuca_v3.users 
  ADD COLUMN deleted_at TIMESTAMPTZ,
  ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.restaurants 
  ADD COLUMN deleted_at TIMESTAMPTZ,
  ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

ALTER TABLE menuca_v3.dishes 
  ADD COLUMN deleted_at TIMESTAMPTZ,
  ADD COLUMN deleted_by BIGINT REFERENCES menuca_v3.admin_users(id);

-- Step 2: Add indexes for filtering
CREATE INDEX idx_users_deleted_at ON menuca_v3.users(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_restaurants_deleted_at ON menuca_v3.restaurants(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_dishes_deleted_at ON menuca_v3.dishes(deleted_at) WHERE deleted_at IS NULL;

-- Step 3: Create helper views for active records
CREATE VIEW menuca_v3.active_users AS
SELECT * FROM menuca_v3.users WHERE deleted_at IS NULL;

CREATE VIEW menuca_v3.active_restaurants AS
SELECT * FROM menuca_v3.restaurants WHERE deleted_at IS NULL;

CREATE VIEW menuca_v3.active_dishes AS
SELECT * FROM menuca_v3.dishes WHERE deleted_at IS NULL;

COMMIT;
```

### **App Integration:**

```javascript
// Instead of DELETE
const deleteUser = (userId, adminId) => {
  return supabase
    .from('users')
    .update({ 
      deleted_at: new Date().toISOString(),
      deleted_by: adminId 
    })
    .eq('id', userId);
};

// Query active records
const getActiveUsers = () => {
  return supabase
    .from('users')
    .select('*')
    .is('deleted_at', null);
  
  // OR use view:
  return supabase.from('active_users').select('*');
};
```

### **Success Criteria:**
- [ ] Soft delete columns added to priority tables
- [ ] Indexes created for performance
- [ ] Helper views created
- [ ] App code can use soft delete (optional - can implement later)

### **Assignment:**
- **Owner:** ⬜ Unassigned (Brian or Santiago)
- **Estimated Time:** 2-3 hours
- **Can Start:** ✅ Immediately (blocked by vendor migration completion)

---

## 🟢 **PHASE 9: Additional Constraints & Validation** (NICE-TO-HAVE)

**Goal:** Add CHECK constraints, DEFAULT values, and unique constraints  
**Impact:** 🟢 LOW-MEDIUM - Prevents invalid data, better defaults  
**Effort:** 🟡 MEDIUM (3-4 hours)  
**Risk:** 🟡 MEDIUM (requires data validation first)  
**Can Run in Parallel:** ⚠️ PARTIAL (coordinate which tables)

### **Suggested Constraints:**

#### **CHECK Constraints (Data Validation):**

```sql
-- Pricing must be positive
ALTER TABLE menuca_v3.dish_prices 
  ADD CONSTRAINT check_dish_prices_positive 
  CHECK (price >= 0);

ALTER TABLE menuca_v3.promotional_deals 
  ADD CONSTRAINT check_deal_discount_valid 
  CHECK (discount_percentage >= 0 AND discount_percentage <= 100);

-- Contact info validation
ALTER TABLE menuca_v3.restaurant_contacts 
  ADD CONSTRAINT check_phone_format 
  CHECK (phone ~ '^\+?[0-9]{10,15}$' OR phone IS NULL);

-- Date logic
ALTER TABLE menuca_v3.promotional_deals 
  ADD CONSTRAINT check_deal_dates 
  CHECK (end_date IS NULL OR end_date >= start_date);

-- Coordinates within valid range
ALTER TABLE menuca_v3.cities 
  ADD CONSTRAINT check_lat_valid 
  CHECK (lat BETWEEN -90 AND 90);

ALTER TABLE menuca_v3.cities 
  ADD CONSTRAINT check_lng_valid 
  CHECK (lng BETWEEN -180 AND 180);
```

#### **DEFAULT Values:**

```sql
-- Boolean defaults
ALTER TABLE menuca_v3.restaurants 
  ALTER COLUMN has_delivery_enabled SET DEFAULT false;

ALTER TABLE menuca_v3.users 
  ALTER COLUMN is_newsletter_subscribed SET DEFAULT false;

-- Timestamp defaults
ALTER TABLE menuca_v3.promotional_deals 
  ALTER COLUMN start_date SET DEFAULT NOW();

-- Numeric defaults
ALTER TABLE menuca_v3.restaurants 
  ALTER COLUMN min_order_value SET DEFAULT 0;
```

#### **UNIQUE Constraints:**

```sql
-- Prevent duplicate domains
ALTER TABLE menuca_v3.restaurant_domains 
  ADD CONSTRAINT unique_domain 
  UNIQUE (domain);

-- Prevent duplicate emails (case-insensitive)
CREATE UNIQUE INDEX unique_users_email_lower 
  ON menuca_v3.users (LOWER(email));

-- Prevent duplicate coupons
ALTER TABLE menuca_v3.promotional_coupons 
  ADD CONSTRAINT unique_coupon_code 
  UNIQUE (code);
```

### **Execution Steps:**

1. **Validate existing data** (find violations before adding constraints)
2. **Clean invalid data** (fix or mark for review)
3. **Add constraints** (one at a time, validate after each)
4. **Test rollback** (ensure constraints can be dropped if needed)

### **Success Criteria:**
- [ ] All constraints added without errors
- [ ] No invalid data remains
- [ ] App can still insert/update records
- [ ] Rollback plan documented

### **Assignment:**
- **Owner:** ⬜ Unassigned (Good for Santiago - systematic work)
- **Estimated Time:** 3-4 hours
- **Can Start:** ✅ Immediately

---

## 🟢 **PHASE 10: Documentation & Developer Experience** (NICE-TO-HAVE)

**Goal:** Add table/column comments, create helpful views, document schema  
**Impact:** 🟢 LOW - Better developer onboarding, easier maintenance  
**Effort:** 🟡 MEDIUM (4-5 hours)  
**Risk:** 🟢 ZERO (documentation only)  
**Can Run in Parallel:** ✅ YES (fully independent)

### **What to Add:**

#### **1. Table Comments:**

```sql
-- Document all 44 tables
COMMENT ON TABLE menuca_v3.restaurants IS 
  'Core restaurant entity. Contains business info, settings, and operational status. 
   Links to: cities (location), restaurant_contacts (phone/email), restaurant_domains (custom domains).';

COMMENT ON TABLE menuca_v3.dishes IS 
  'Menu items offered by restaurants. Links to courses (category), ingredients (customization), 
   dish_prices (pricing by size). See dish_modifiers for additional options.';

-- And so on for all 44 tables...
```

#### **2. Column Comments:**

```sql
-- Document key columns
COMMENT ON COLUMN menuca_v3.restaurants.legacy_v1_id IS 
  'Original ID from menuca_v1 MySQL database. Used for data migration tracking and legacy system integration.';

COMMENT ON COLUMN menuca_v3.dishes.prices IS 
  'DEPRECATED: Legacy JSONB pricing. Use dish_prices relational table instead. Kept for backup during migration.';
```

#### **3. Helpful Views:**

```sql
-- Complete restaurant info (denormalized for API)
CREATE VIEW menuca_v3.restaurants_complete AS
SELECT 
  r.*,
  rl.address,
  rl.suite,
  c.name as city_name,
  p.name as province_name,
  rc.phone,
  rc.email
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON r.id = rl.restaurant_id
LEFT JOIN menuca_v3.cities c ON rl.city_id = c.id
LEFT JOIN menuca_v3.provinces p ON c.province_id = p.id
LEFT JOIN menuca_v3.restaurant_contacts rc ON r.id = rc.restaurant_id
WHERE r.deleted_at IS NULL;

-- Dishes with full pricing info
CREATE VIEW menuca_v3.dishes_with_pricing AS
SELECT 
  d.*,
  json_agg(json_build_object(
    'size', dp.size_variant,
    'price', dp.price,
    'order', dp.display_order
  ) ORDER BY dp.display_order) as pricing
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id AND dp.is_active = true
WHERE d.deleted_at IS NULL
GROUP BY d.id;

-- Active promotional deals with coupon counts
CREATE VIEW menuca_v3.active_deals_summary AS
SELECT 
  pd.*,
  r.name as restaurant_name,
  COUNT(pc.id) as coupon_count,
  COUNT(CASE WHEN pc.is_redeemed THEN 1 END) as redeemed_count
FROM menuca_v3.promotional_deals pd
LEFT JOIN menuca_v3.restaurants r ON pd.restaurant_id = r.id
LEFT JOIN menuca_v3.promotional_coupons pc ON pd.id = pc.deal_id
WHERE pd.is_active = true
  AND (pd.end_date IS NULL OR pd.end_date >= NOW())
GROUP BY pd.id, r.name;
```

#### **4. Schema Documentation File:**

Create `/Database/V3_SCHEMA_GUIDE.md` with:
- Entity-relationship diagram (ERD)
- Table purpose and relationships
- Common query patterns
- Migration history
- Performance tips

### **Success Criteria:**
- [ ] All 44 tables have comments
- [ ] Key columns documented
- [ ] 5-10 helpful views created
- [ ] Schema guide document created

### **Assignment:**
- **Owner:** ⬜ Unassigned (Great for systematic documentation work)
- **Estimated Time:** 4-5 hours
- **Can Start:** ✅ Immediately

---

## 📊 **Phases Summary**

| Phase | Priority | Effort | Risk | Can Parallelize? | Estimated Time |
|-------|----------|--------|------|------------------|----------------|
| **6: Performance Indexes** | 🔴 HIGH | 🟢 LOW | 🟢 ZERO | ✅ YES | 1-2 hours |
| **7: Enum Standardization** | 🟡 MEDIUM | 🟡 MEDIUM | 🟡 MEDIUM | ⚠️ PARTIAL | 3-4 hours |
| **8: Soft Delete** | 🟡 MEDIUM | 🟡 MEDIUM | 🟢 LOW | ✅ YES | 2-3 hours |
| **9: Additional Constraints** | 🟢 NICE-TO-HAVE | 🟡 MEDIUM | 🟡 MEDIUM | ⚠️ PARTIAL | 3-4 hours |
| **10: Documentation** | 🟢 NICE-TO-HAVE | 🟡 MEDIUM | 🟢 ZERO | ✅ YES | 4-5 hours |

**Total Estimated Time:** 13-18 hours (can be split across team)

---

## 🚀 **Parallel Work Strategy**

### **✅ Safe to Do Simultaneously:**

**Brian & Santiago can work on these at the same time:**

1. **Brian:** Phase 6 (Performance Indexes)  
   **Santiago:** Phase 10 (Documentation)  
   **Why:** Completely independent, zero conflict

2. **Brian:** Phase 8 (Soft Delete - tables 1-3)  
   **Santiago:** Phase 8 (Soft Delete - tables 4-6)  
   **Why:** Different tables, no overlap

3. **Brian:** Phase 9 (Constraints - dishes/restaurants)  
   **Santiago:** Phase 9 (Constraints - users/promotions)  
   **Why:** Different tables, coordinate in plan

### **⚠️ Must Coordinate:**

1. **Phase 7 (Enum Standardization)** - Requires app team coordination
2. Any work on same table at same time
3. Changes that affect foreign key relationships

---

## 📋 **Recommended Execution Order**

### **Sprint 1 (High Priority - 3-5 hours):**
1. ✅ Phase 6: Performance Indexes (1-2 hours) - **Assign to: Brian or Santiago**
2. ✅ Phase 8: Soft Delete (2-3 hours) - **Assign to: Brian or Santiago**

### **Sprint 2 (Medium Priority - 6-8 hours):**
3. ✅ Phase 9: Additional Constraints (3-4 hours) - **Both can split work**
4. ✅ Phase 7: Enum Standardization (3-4 hours) - **Coordinate with app team**

### **Sprint 3 (Nice-to-Have - 4-5 hours):**
5. ✅ Phase 10: Documentation (4-5 hours) - **Great for Santiago**

---

## 📊 **Progress Tracking**

### **Phase 6: Performance Indexes**
- [x] HIGH priority indexes analyzed
- [x] ALL 54 FK columns validated
- [x] 100% coverage confirmed (ZERO work needed!)
- [x] Analysis documented
- **Assigned to:** ✅ Brian + Claude
- **Status:** ✅ COMPLETE (2025-10-14) - NO WORK NEEDED!

### **Phase 7: Enum Standardization**
- [ ] Current status values analyzed
- [ ] Enum types created
- [ ] Data migration tested
- [ ] App team coordination complete
- [ ] Production migration executed
- **Assigned to:** ⬜ Unassigned
- **Status:** ⏳ Not Started (Blocked by app team)

### **Phase 8: Soft Delete Infrastructure**
- [x] Soft delete columns added (5 tables: users, restaurants, dishes, promotional_coupons, admin_users)
- [x] Indexes created (5 partial indexes for performance)
- [x] Helper views created (5 views: active_users, active_restaurants, active_dishes, active_promotional_coupons, active_admin_users)
- [x] Implementation documented
- [x] Verification complete (49,970 records protected, 0 data loss)
- **Assigned to:** ✅ Santiago + Claude
- **Status:** ✅ COMPLETE (2025-10-15) - PRODUCTION READY!

### **Phase 9: Additional Constraints**
- [ ] Data validation queries run
- [ ] Invalid data cleaned
- [ ] CHECK constraints added
- [ ] DEFAULT values set
- [ ] UNIQUE constraints created
- **Assigned to:** ⬜ Unassigned
- **Status:** ⏳ Not Started

### **Phase 10: Documentation**
- [ ] All tables commented
- [ ] Key columns documented
- [ ] Helpful views created
- [ ] Schema guide document created
- **Assigned to:** ⬜ Unassigned
- **Status:** ⏳ Not Started

---

## 🎯 **Quick Start Guide**

### **For Brian:**
1. Read this roadmap
2. Pick a phase (recommend: Phase 6 for quick wins)
3. Update "Assigned to" field
4. Execute the plan
5. Check off progress items
6. Push to main when complete

### **For Santiago:**
1. Read this roadmap
2. Coordinate with Brian on assignments
3. Pick a phase that doesn't conflict
4. Update "Assigned to" field
5. Execute the plan
6. Check off progress items
7. Push to main when complete

### **For Both (Parallel Work):**
1. Agree on assignments (via Slack/Discord)
2. Update this file with assignments
3. Work independently
4. Commit frequently to avoid merge conflicts
5. Communicate when done
6. Review each other's work

---

## 🔗 **Related Files**

- **Complete Audit:** `/Database/V3_COMPLETE_TABLE_AUDIT.md`
- **Completed Phases:** `/Database/V3_Optimization/` (files 01-06)
- **Optimization Status:** `/MEMORY_BANK/V3_OPTIMIZATION_STATUS.md`
- **Project Status:** `/MEMORY_BANK/PROJECT_STATUS.md`

---

## 🎉 **Success Criteria for All Phases**

When all 5 phases complete, we will have:

- ✅ **Optimized performance** (indexed FKs, faster queries)
- ✅ **Better data integrity** (enums, constraints, validation)
- ✅ **Audit capability** (soft delete, change tracking)
- ✅ **Developer-friendly** (documentation, views, guides)
- ✅ **Production-ready** (clean, consistent, industry-standard schema)

---

**Status:** 📋 READY FOR TEAM EXECUTION  
**Estimated Total Time:** 13-18 hours (parallelizable)  
**Blocking Issues:** 
- Phase 7: Needs app team coordination
- Phase 8: Blocked by vendor migration completion (for full implementation)

**Can Start Immediately:** Phases 6, 9, 10 ✅

---

**Created by:** Claude + Brian  
**Date:** October 14, 2025  
**Version:** 1.0  
**Next Review:** After Phases 6-8 complete

