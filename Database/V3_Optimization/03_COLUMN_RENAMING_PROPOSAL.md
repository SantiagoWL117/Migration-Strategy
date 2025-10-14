# V3 Column Renaming Proposal

**Date:** October 14, 2025  
**Status:** 📋 PROPOSAL - Awaiting Team Review  
**Estimated Effort:** 2-3 hours (DB migration + app code updates)  
**Risk Level:** 🟡 MEDIUM (requires coordinated deployment)  
**Business Value:** 🟢 HIGH (improved code readability & maintainability)

---

## 🎯 **Executive Summary**

**Problem:** 34 columns in menuca_v3 don't follow industry-standard naming conventions, causing confusion and inconsistency.

**Solution:** Rename columns to follow PostgreSQL/Rails conventions (boolean: `is_*`/`has_*`, timestamps: `*_at`).

**Impact:** 
- ✅ Better code readability
- ✅ Follows industry standards
- ✅ Easier onboarding for new developers
- ✅ More maintainable codebase

**Risk:** Requires updating application code + coordinated deployment.

---

## 📊 **34 Columns Requiring Renaming**

### **Category 1: Boolean Columns (21 columns)**
❌ **Issue:** Not using `is_*`, `has_*`, or `can_*` prefixes

| # | Table | Current Name | Proposed Name | Priority | Reason |
|---|-------|--------------|---------------|----------|--------|
| 1 | `devices` | `supports_printing` | `has_printing_support` | 🟡 Medium | Clarity |
| 2 | `promotional_coupons` | `add_to_email` | `includes_in_email` | 🟡 Medium | Clarity |
| 3 | `promotional_deals` | `first_order_only` | `is_first_order_only` | 🟡 Medium | Convention |
| 4 | `promotional_deals` | `send_in_email` | `sends_in_email` | 🟡 Medium | Convention |
| 5 | `promotional_deals` | `show_on_thankyou` | `shows_on_thankyou` | 🟡 Medium | Convention |
| 6 | `restaurant_admin_users` | `send_statement` | `sends_statements` | 🟡 Medium | Convention |
| 7 | `restaurant_delivery_companies` | `send_to_delivery` | `sends_to_delivery` | 🟡 Medium | Convention |
| 8 | `restaurant_delivery_config` | `use_custom_fee` | `uses_custom_fee` | 🟡 Medium | Convention |
| 9 | `restaurant_delivery_config` | `use_dynamic_eta` | `uses_dynamic_eta` | 🟡 Medium | Convention |
| 10 | `restaurant_service_configs` | `allow_preorders` | `allows_preorders` | 🟡 Medium | Convention |
| 11 | `restaurant_service_configs` | `delivery_enabled` | `has_delivery_enabled` | 🟡 Medium | Convention |
| 12 | `restaurant_twilio_config` | `enable_call` | `enables_calls` | 🟡 Medium | Convention |
| 13 | `users` | `email_verified` | `has_email_verified` | 🟡 Medium | Convention |
| 14 | `users` | `newsletter_subscribed` | `is_newsletter_subscribed` | 🟡 Medium | Convention |
| 15 | `users` | `vegan_newsletter_subscribed` | `is_vegan_newsletter_subscribed` | 🟡 Medium | Convention |

### **Category 2: Timestamp Columns (5 columns)**
❌ **Issue:** Not using `*_at` suffix

| # | Table | Current Name | Proposed Name | Priority | Reason |
|---|-------|--------------|---------------|----------|--------|
| 16 | `dishes` | `unavailable_until` | `unavailable_until_at` | 🟢 Low | Convention |
| 17 | `promotional_coupons` | `valid_from` | `valid_from_at` | 🟡 Medium | Convention |
| 18 | `promotional_coupons` | `valid_until` | `valid_until_at` | 🟡 Medium | Convention |
| 19 | `restaurant_admin_users` | `last_login` | `last_login_at` | 🔴 High | Consistency (other tables use `*_at`) |
| 20 | `restaurant_delivery_companies` | `disable_until` | `disabled_until_at` | 🟡 Medium | Convention |
| 21 | `restaurant_delivery_config` | `disable_delivery_until` | `disabled_until_at` | 🟡 Medium | Convention |

### **Category 3: Legacy Columns (Keep for Now)**
⚠️ **Note:** These will be handled during vendor migration

| # | Table | Column Pattern | Action | Notes |
|---|-------|----------------|--------|-------|
| 22-27 | `restaurant_delivery_config` | `legacy_v1_*` (6 cols) | Archive later | Migration reference |

**Total to Rename Now:** 21 columns (15 boolean + 6 timestamp)

---

## 💰 **Business Value**

### **1. Code Readability** 🔴 HIGH
**Before:**
```typescript
if (user.email_verified) { ... }  // Is this a boolean or a date?
if (deal.first_order_only) { ... }  // Not clear it's a boolean
```

**After:**
```typescript
if (user.has_email_verified) { ... }  // Clear: it's a boolean check
if (deal.is_first_order_only) { ... }  // Clear: it's a boolean flag
```

### **2. Developer Onboarding** 🟡 MEDIUM
- New developers immediately understand column purpose
- Follows conventions from Ruby/Rails, Laravel, Django
- Reduces questions and confusion

### **3. Maintainability** 🟡 MEDIUM
- Consistent naming across codebase
- Easier to search/grep for booleans (`has_*`, `is_*`)
- Clearer database schema

### **4. Future-Proofing** 🟢 LOW
- Sets standard for new columns
- Easier to add new fields following pattern

---

## 📋 **Migration Strategy**

### **Phase 1: Database Migration (5 minutes)**
```sql
BEGIN;

-- Boolean renames
ALTER TABLE menuca_v3.users 
  RENAME COLUMN email_verified TO has_email_verified;

ALTER TABLE menuca_v3.users 
  RENAME COLUMN newsletter_subscribed TO is_newsletter_subscribed;

-- Timestamp renames
ALTER TABLE menuca_v3.restaurant_admin_users 
  RENAME COLUMN last_login TO last_login_at;

-- ... (repeat for all 21 columns)

COMMIT;
```

**Time:** 5 minutes  
**Downtime:** None (instant rename in PostgreSQL)  
**Rollback:** Simple `RENAME COLUMN` back to original

---

### **Phase 2: Application Code Updates (1-2 hours)**

#### **Step 1: Find All References**
```bash
# Search for old column names
grep -r "email_verified" app/
grep -r "newsletter_subscribed" app/
grep -r "last_login" app/
# ... etc for all 21 columns
```

#### **Step 2: Update Code**
**Example Changes:**

**Models:**
```typescript
// Before
interface User {
  email_verified: boolean;
  newsletter_subscribed: boolean;
}

// After
interface User {
  has_email_verified: boolean;
  is_newsletter_subscribed: boolean;
}
```

**Queries:**
```typescript
// Before
const verified = await User.where('email_verified = true');

// After  
const verified = await User.where('has_email_verified = true');
```

**API Responses:**
```typescript
// Before
{ email_verified: true }

// After
{ has_email_verified: true }
```

#### **Step 3: Update Tests**
- Update all test fixtures
- Update test assertions
- Run full test suite

---

### **Phase 3: Coordinated Deployment**

#### **Option A: Zero-Downtime (Recommended)**
1. **Week 1:** Add **aliases** in application (read both old and new names)
2. **Week 2:** Deploy database rename + app code to use new names
3. **Week 3:** Remove old aliases after verification

#### **Option B: Quick Deploy (Faster)**
1. **Deploy together:** Database migration + app code update
2. **Timing:** Deploy during low-traffic period (2-3 AM)
3. **Rollback ready:** Can revert both if issues

---

## 🚨 **Risk Assessment**

### **🔴 High Risk Items:**
1. **API Breaking Changes** - External integrations may break
   - **Mitigation:** Version API, support both names temporarily
   
2. **Missed References** - Some code uses old names
   - **Mitigation:** Comprehensive grep search, thorough testing

### **🟡 Medium Risk Items:**
1. **Database-dependent scripts** - ETL, reports, etc.
   - **Mitigation:** Audit all scripts, update before deployment

2. **Third-party integrations** - Webhooks, exports
   - **Mitigation:** Map old→new names in API layer

### **🟢 Low Risk Items:**
1. **Performance** - Column renames are instant in PostgreSQL
2. **Data loss** - No data changes, just metadata

---

## ✅ **Testing Checklist**

### **Database Testing:**
- [ ] Run migration in test environment
- [ ] Verify all 21 columns renamed
- [ ] Check indexes still work
- [ ] Verify foreign keys unaffected
- [ ] Test rollback script

### **Application Testing:**
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] API tests pass (both old and new names if aliasing)
- [ ] Manual QA on critical flows

### **Critical User Flows:**
- [ ] User registration (email_verified)
- [ ] Newsletter signup (newsletter_subscribed)
- [ ] Admin login (last_login)
- [ ] Promotional deals display
- [ ] Delivery configuration

---

## 🔄 **Rollback Plan**

### **If Issues Detected:**

**Within 1 hour of deployment:**
```sql
BEGIN;

-- Revert all renames
ALTER TABLE menuca_v3.users 
  RENAME COLUMN has_email_verified TO email_verified;

-- ... (repeat for all 21 columns)

COMMIT;
```

**Then:**
1. Revert application code deploy
2. Investigate issue
3. Fix and retry

**Time to rollback:** < 10 minutes  
**Data loss:** 0% (no data changes)

---

## 📊 **Effort Estimation**

| Task | Estimated Time | Assigned To |
|------|----------------|-------------|
| **Planning & Approval** | 1 hour | Team review |
| **Database Migration Script** | 30 minutes | DBA/Backend |
| **Grep/Find All References** | 30 minutes | Backend team |
| **Update Application Code** | 1-2 hours | Backend team |
| **Update Tests** | 30-60 minutes | QA/Backend |
| **Testing in Staging** | 1 hour | QA team |
| **Deployment** | 15 minutes | DevOps |
| **Post-deploy Validation** | 30 minutes | Team |

**Total:** ~4-6 hours of dev time + 1 hour deployment

**Timeline:**
- **Week 1:** Review proposal, approve, schedule
- **Week 2:** Implement changes, test in staging
- **Week 3:** Deploy to production

---

## 💡 **Recommendation**

### **Do This If:**
- ✅ Team has 4-6 hours of dev capacity
- ✅ Can schedule coordinated deployment
- ✅ Want improved code readability
- ✅ Following industry standards matters

### **Skip This If:**
- ❌ Team is overwhelmed with other priorities
- ❌ Can't coordinate deployment window
- ❌ Current naming doesn't cause confusion
- ❌ Other work is more critical

---

## 📋 **Detailed Column Renaming Script**

```sql
-- =========================================================================
-- COLUMN RENAMING MIGRATION
-- =========================================================================
-- Purpose: Rename 21 columns to follow PostgreSQL naming conventions
-- Date: TBD (after approval)
-- Estimated Duration: < 5 minutes
-- 
-- SAFETY: 
-- - All changes in single transaction
-- - No data changes, only metadata
-- - Instant in PostgreSQL (no table rewrite)
-- - Simple rollback available
-- =========================================================================

BEGIN;

-- =========================================================================
-- CATEGORY 1: BOOLEAN COLUMNS (15 columns)
-- =========================================================================

-- devices table
ALTER TABLE menuca_v3.devices 
  RENAME COLUMN supports_printing TO has_printing_support;

-- promotional_coupons table
ALTER TABLE menuca_v3.promotional_coupons 
  RENAME COLUMN add_to_email TO includes_in_email;

-- promotional_deals table
ALTER TABLE menuca_v3.promotional_deals 
  RENAME COLUMN first_order_only TO is_first_order_only;

ALTER TABLE menuca_v3.promotional_deals 
  RENAME COLUMN send_in_email TO sends_in_email;

ALTER TABLE menuca_v3.promotional_deals 
  RENAME COLUMN show_on_thankyou TO shows_on_thankyou;

-- restaurant_admin_users table
ALTER TABLE menuca_v3.restaurant_admin_users 
  RENAME COLUMN send_statement TO sends_statements;

-- restaurant_delivery_companies table
ALTER TABLE menuca_v3.restaurant_delivery_companies 
  RENAME COLUMN send_to_delivery TO sends_to_delivery;

-- restaurant_delivery_config table
ALTER TABLE menuca_v3.restaurant_delivery_config 
  RENAME COLUMN use_custom_fee TO uses_custom_fee;

ALTER TABLE menuca_v3.restaurant_delivery_config 
  RENAME COLUMN use_dynamic_eta TO uses_dynamic_eta;

-- restaurant_service_configs table
ALTER TABLE menuca_v3.restaurant_service_configs 
  RENAME COLUMN allow_preorders TO allows_preorders;

ALTER TABLE menuca_v3.restaurant_service_configs 
  RENAME COLUMN delivery_enabled TO has_delivery_enabled;

-- restaurant_twilio_config table
ALTER TABLE menuca_v3.restaurant_twilio_config 
  RENAME COLUMN enable_call TO enables_calls;

-- users table
ALTER TABLE menuca_v3.users 
  RENAME COLUMN email_verified TO has_email_verified;

ALTER TABLE menuca_v3.users 
  RENAME COLUMN newsletter_subscribed TO is_newsletter_subscribed;

ALTER TABLE menuca_v3.users 
  RENAME COLUMN vegan_newsletter_subscribed TO is_vegan_newsletter_subscribed;

-- =========================================================================
-- CATEGORY 2: TIMESTAMP COLUMNS (6 columns)
-- =========================================================================

-- dishes table
ALTER TABLE menuca_v3.dishes 
  RENAME COLUMN unavailable_until TO unavailable_until_at;

-- promotional_coupons table
ALTER TABLE menuca_v3.promotional_coupons 
  RENAME COLUMN valid_from TO valid_from_at;

ALTER TABLE menuca_v3.promotional_coupons 
  RENAME COLUMN valid_until TO valid_until_at;

-- restaurant_admin_users table
ALTER TABLE menuca_v3.restaurant_admin_users 
  RENAME COLUMN last_login TO last_login_at;

-- restaurant_delivery_companies table
ALTER TABLE menuca_v3.restaurant_delivery_companies 
  RENAME COLUMN disable_until TO disabled_until_at;

-- restaurant_delivery_config table
ALTER TABLE menuca_v3.restaurant_delivery_config 
  RENAME COLUMN disable_delivery_until TO disabled_until_at;

-- =========================================================================
-- VALIDATION
-- =========================================================================

DO $$
BEGIN
  RAISE NOTICE '========== COLUMN RENAMES COMPLETE ==========';
  RAISE NOTICE 'Boolean columns renamed: 15';
  RAISE NOTICE 'Timestamp columns renamed: 6';
  RAISE NOTICE 'Total columns renamed: 21';
  RAISE NOTICE 'Tables affected: 9';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Next: Update application code to use new names';
END $$;

-- COMMIT; -- Uncomment to apply changes
-- ROLLBACK; -- Default: test run only
```

---

## 🎯 **Success Criteria**

Migration is successful when:

- [ ] All 21 columns renamed in database
- [ ] All application code updated
- [ ] All tests passing
- [ ] No API errors in logs
- [ ] Critical user flows working
- [ ] No increase in error rates

---

## 📞 **Questions for Team Review**

1. **Timeline:** When can we schedule this? (Need 4-6 dev hours + deployment window)
2. **API Impact:** Do we need to support old column names in API responses?
3. **Third-Party:** Any external integrations using these columns?
4. **Testing:** Can we get full QA cycle in staging before production?
5. **Deployment:** Prefer zero-downtime (3-week) or quick deploy (1-week)?

---

## 🎊 **Why This Matters**

**Before (confusing):**
```sql
SELECT email_verified, newsletter_subscribed, last_login
FROM users WHERE first_order_only = true;
-- Are these booleans? Dates? Unclear!
```

**After (crystal clear):**
```sql
SELECT has_email_verified, is_newsletter_subscribed, last_login_at
FROM users WHERE is_first_order_only = true;
-- Obvious: booleans have is_/has_, dates have _at
```

---

## 📄 **Appendix: Full Rollback Script**

```sql
BEGIN;

-- Revert boolean renames
ALTER TABLE menuca_v3.devices RENAME COLUMN has_printing_support TO supports_printing;
ALTER TABLE menuca_v3.promotional_coupons RENAME COLUMN includes_in_email TO add_to_email;
ALTER TABLE menuca_v3.promotional_deals RENAME COLUMN is_first_order_only TO first_order_only;
ALTER TABLE menuca_v3.promotional_deals RENAME COLUMN sends_in_email TO send_in_email;
ALTER TABLE menuca_v3.promotional_deals RENAME COLUMN shows_on_thankyou TO show_on_thankyou;
ALTER TABLE menuca_v3.restaurant_admin_users RENAME COLUMN sends_statements TO send_statement;
ALTER TABLE menuca_v3.restaurant_delivery_companies RENAME COLUMN sends_to_delivery TO send_to_delivery;
ALTER TABLE menuca_v3.restaurant_delivery_config RENAME COLUMN uses_custom_fee TO use_custom_fee;
ALTER TABLE menuca_v3.restaurant_delivery_config RENAME COLUMN uses_dynamic_eta TO use_dynamic_eta;
ALTER TABLE menuca_v3.restaurant_service_configs RENAME COLUMN allows_preorders TO allow_preorders;
ALTER TABLE menuca_v3.restaurant_service_configs RENAME COLUMN has_delivery_enabled TO delivery_enabled;
ALTER TABLE menuca_v3.restaurant_twilio_config RENAME COLUMN enables_calls TO enable_call;
ALTER TABLE menuca_v3.users RENAME COLUMN has_email_verified TO email_verified;
ALTER TABLE menuca_v3.users RENAME COLUMN is_newsletter_subscribed TO newsletter_subscribed;
ALTER TABLE menuca_v3.users RENAME COLUMN is_vegan_newsletter_subscribed TO vegan_newsletter_subscribed;

-- Revert timestamp renames
ALTER TABLE menuca_v3.dishes RENAME COLUMN unavailable_until_at TO unavailable_until;
ALTER TABLE menuca_v3.promotional_coupons RENAME COLUMN valid_from_at TO valid_from;
ALTER TABLE menuca_v3.promotional_coupons RENAME COLUMN valid_until_at TO valid_until;
ALTER TABLE menuca_v3.restaurant_admin_users RENAME COLUMN last_login_at TO last_login;
ALTER TABLE menuca_v3.restaurant_delivery_companies RENAME COLUMN disabled_until_at TO disable_until;
ALTER TABLE menuca_v3.restaurant_delivery_config RENAME COLUMN disabled_until_at TO disable_delivery_until;

COMMIT;
```

---

**Status:** 📋 PROPOSAL - Ready for team review  
**Created by:** Brian + Claude  
**Date:** October 14, 2025  
**Next Step:** Team discussion and approval

