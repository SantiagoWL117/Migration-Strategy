# menuca_v3 Schema Simplification Analysis

**Date:** 2025-11-10  
**Database:** menu-rebuild-vo (nthpbtdjhhnwfxqsxbvy)  
**Objective:** Simplify schema complexity to support only the 189 active billing restaurants

---

## Executive Summary

The menuca_v3 schema currently contains **110 tables**, **29 views**, and **178 functions**, but analysis reveals significant opportunities for simplification:

- **44 tables are completely empty** (0 rows)
- **727 suspended restaurants** (76% of total) with orphaned data
- **489 MB of audit logs** tracking primarily test/import churn
- **Multiple unused features** (translations, orders, user accounts, etc.)
- **Data is already 99%+ associated with active restaurants**

**Recommendation:** Archive suspended restaurant data and remove unused features to reduce complexity by ~40-50%.

---

## Current State Overview

### Restaurant Distribution

| Status | Count | Percentage | In Billing List |
|--------|-------|------------|----------------|
| **Active** | 194 | 20.3% | 189 (97.4%) |
| Suspended | 727 | 76.1% | 0 (0%) |
| Pending | 34 | 3.6% | 0 (0%) |
| **Total** | **955** | **100%** | **189** |

**Note:** 5 restaurants are marked "active" in database but not in the billing list. These need investigation.

### Storage Analysis

| Table/Partition | Size | Rows | Notes |
|----------------|------|------|-------|
| audit_log_2025_10 | 489 MB | 352,185 | Mostly dish INSERT/DELETE churn |
| dish_modifiers | 155 MB | 81,097 | 100% belong to active restaurants |
| audit_log_2025_11 | 44 MB | 43,412 | Current month audit |
| dish_modifier_prices | 36 MB | 145,368 | Active restaurants only |
| users | 33 MB | 32,320 | Customer accounts |
| dishes | 33 MB | 19,348 | 99.4% active (108 suspended) |

**Total Schema Size:** ~1.2 GB

---

## 🔴 CRITICAL: Empty Tables (44 Tables - Can Be Removed)

These tables have **0 rows** and no production usage:

### Translation/i18n Tables (8 tables)
- `course_translations` - No multilingual menus
- `dish_translations` - No multilingual menus
- `modifier_group_translations` - No multilingual modifiers
- `combo_group_translations` - No multilingual combos
- `dish_modifier_translations` - No multilingual modifier text
- `ingredient_translations` - No multilingual ingredients
- `marketing_tags_translations` - Marketing tags not translated
- `promotional_coupons_translations` - Coupons not translated
- `promotional_deals_translations` - Deals not translated
- `schedule_translations` - Schedules not translated

**Impact:** Translations system is built but not used. Safe to remove.

### Order Management Tables (12 tables)
- `orders` (partitioned parent)
- `orders_2025_10`, `orders_2025_11`, `orders_2025_12`
- `orders_2026_01`, `orders_2026_02`, `orders_2026_03`
- `order_items` (partitioned parent)
- `order_items_2025_10`, `order_items_2025_11`, `order_items_2025_12`
- `order_items_2026_01`, `order_items_2026_02`, `order_items_2026_03`
- `order_status_history`
- `payment_transactions`
- `stripe_webhook_events`
- `coupon_usage_log` (2 rows only)

**Impact:** System not in production yet. Orders are likely handled in a different system.

### User Account Features (7 tables)
- `cart_sessions` - No shopping carts stored
- `user_addresses` - No saved addresses
- `user_delivery_addresses` - No delivery addresses
- `user_favorite_dishes` - No favorites feature used
- `user_favorite_restaurants` - No favorites feature used
- `user_payment_methods` - No saved payment methods
- `autologin_tokens` - No auto-login feature
- `password_reset_tokens` - No password resets logged

**Impact:** User account features not implemented in frontend.

### Dish Features (5 tables)
- `dish_allergens` - Allergen tracking not used
- `dish_dietary_tags` - Dietary tags not used
- `dish_inventory` - Inventory tracking not used
- `dish_size_options` - Size options not used (use dish_prices instead)

**Impact:** Advanced dish features not implemented.

### System/Infrastructure (7 tables)
- `admin_action_logs` - Empty (use audit_log instead)
- `admin_user_preferences` - No preferences stored
- `email_queue` - Email sending handled elsewhere
- `failed_jobs` - No job queue in database
- `rate_limits` - Rate limiting not implemented
- `combo_steps` - Combo feature not used

**Impact:** Infrastructure features moved to application layer or not needed.

### Audit Log Partitions (Future) (6 tables)
- `audit_log` (parent table - empty)
- `audit_log_2025_12` - Future partition (empty)
- `audit_log_2026_01` - Future partition (empty)
- `audit_log_2026_02` - Future partition (empty)
- `audit_log_2026_03` - Future partition (empty)

**Impact:** Pre-created partitions for future data. Can be created dynamically when needed.

### Backup Tables (6 tables - DELETE)
- `courses_backup_test_234` (0 rows)
- `courses_backup_test_35` (1 row)
- `courses_backup_test_726` (1 row)
- `dishes_backup_test_234` (0 rows)
- `dishes_backup_test_35` (3 rows)
- `dishes_backup_test_726` (1 row)

**Impact:** Test/backup tables no longer needed. Should be deleted immediately.

---

## 🟡 MODERATE: Minimal Usage Tables (Consider Removal)

| Table | Rows | Notes | Recommendation |
|-------|------|-------|----------------|
| `ingredient_translations` | 1 | Single translation entry | Remove |
| `admin_consolidation_summary` | 1 | Migration artifact? | Review & remove |
| `coupon_usage_log` | 2 | Not tracking coupon usage | Remove |
| `flash_sale_claims` | 5 | Flash sales not used | Remove |
| `restaurant_time_periods` | 6 | Custom time periods not used | Remove if not needed |
| `restaurant_partner_schedules` | 7 | Partner schedules minimal | Keep if active |
| `delivery_company_emails` | 9 | Delivery company contacts | Keep |
| `restaurant_twilio_config` | 18 | SMS notifications config | Keep if active |
| `restaurant_delivery_zones` | 1 | New delivery zones (vs areas) | Migrate to zones, remove areas |
| `restaurant_delivery_areas` | 47 | Old delivery areas system | Migrate to zones, remove areas |
| `marketing_tags` | 36 | Marketing tags for restaurants | Keep if used |
| `restaurant_tag_associations` | 29 | Tag associations | Keep if used |

---

## 🟢 Orphaned Data from Suspended Restaurants (727 restaurants)

### Data to Archive/Delete

| Table | Suspended Restaurant Records | % of Total |
|-------|------------------------------|------------|
| `restaurant_contacts` | 646 | 79.1% |
| `restaurant_schedules` | 272 | 26.8% |
| `devices` | 143 | 14.6% |
| `dishes` | 108 | 0.6% |
| `courses` | 13 | 0.6% |
| `dish_modifiers` | 0 | 0% |
| `restaurant_delivery_config` | ~600 | est. 73% |
| `restaurant_service_configs` | ~600 | est. 64% |
| `restaurant_locations` | ~600 | est. 66% |
| `restaurant_domains` | ~500 | est. 71% |
| `restaurant_onboarding` | ~700 | est. 73% |

**Total Impact:** Archiving suspended restaurant data could reduce active dataset by ~25-30%.

**Recommendation:** 
1. Export suspended restaurant data to archive schema (`archive` schema already exists)
2. Soft-delete all suspended restaurant records (set `deleted_at`)
3. Create archive views for historical reporting if needed

---

## Large Table Optimization Opportunities

### Audit Log Analysis (489 MB)

```
Table: audit_log_2025_10 (October 2025)
Action Breakdown:
- dishes INSERT: 115,896 operations
- dishes DELETE: 108,630 operations  
- users UPDATE: 85,012 operations
- dishes UPDATE: 37,414 operations
- restaurants UPDATE: 4,354 operations
```

**Analysis:** High churn in dishes table indicates:
- Bulk import/export operations
- Menu testing/adjustments
- Possible data quality issues

**Recommendations:**
1. Archive audit logs older than 60-90 days
2. Implement audit log retention policy (keep last 3-6 months)
3. Investigate dish INSERT/DELETE churn (246,526 operations seems excessive)
4. Consider disabling audit logging for bulk operations

**Potential Savings:** 400+ MB by archiving old audit logs

---

## Function Analysis (178 Functions)

### Functions by Category

| Category | Count | Notes |
|----------|-------|-------|
| Restaurant Management | 45 | Core functionality |
| Menu & Dishes | 35 | Core functionality |
| Orders & Promotions | 25 | Orders not in use, promotions active |
| Admin & Auth | 22 | Core functionality |
| Franchise Management | 18 | Used by Milano, Papa Grecque chains |
| Delivery Zones | 12 | Active feature |
| Vendor Commission | 8 | Active feature |
| Domain Management | 7 | SSL/DNS verification |
| Soft Delete/Restore | 6 | Core functionality |

### Unused Function Categories (Can Be Reviewed)

**Order Functions (if orders not used):**
- `get_order_details()`
- `get_restaurant_orders()`
- `update_order_status()`
- `calculate_order_totals()` (if exists)

**Translation Functions (translations empty):**
- `translate_marketing_tag()`
- Functions referencing translation tables

**Combo/Meal Deal Functions:**
- `validate_combo_configuration()`
- Functions related to `combo_steps`, `combo_group_*` tables

**Recommendation:** Audit function usage in application code before removal. Many functions may be called via RPC from frontend.

---

## Views Analysis (29 Views)

### Active Views (Keep)
- `active_restaurants` - Core
- `active_dishes` - Core  
- `active_courses` - Core
- `active_dish_modifiers` - Core
- `v_operational_restaurants` - Used for filtering
- `v_franchise_chains` - Milano, Papa chains
- `v_featured_restaurants` - Featured listings
- `v_active_vendor_restaurants` - Commission reporting

### Views to Review
- `v_onboarding_incomplete` - If onboarding complete
- `v_onboarding_progress_stats` - If onboarding complete  
- `v_onboarding_stats` - If onboarding complete
- `v_incomplete_onboarding_restaurants` - If onboarding complete
- `v_domains_needing_attention` - If domain verification stable
- `v_schedule_conflicts` - If schedules stable
- `v_midnight_crossing_schedules` - Edge case handling

**Recommendation:** Keep all views initially, remove after confirming no application dependencies.

---

## Franchise Management Impact

### Franchise Chains in Active Restaurants

**Milano Pizzeria:**
- Active: 36 locations
- Suspended: 20 locations  
- Pending: 1 location
- **Total: 57 Milano locations**

**Papa Grecque/Papa Pizza/Papa Burger:**
- Active: ~12 locations (estimated)
- Uses franchise features

**Recommendation:** Franchise management features are actively used and should be retained.

---

## Detailed Recommendations

### Phase 1: Immediate Cleanup (Low Risk)

**1. Delete Backup Tables (High Priority)**
```sql
DROP TABLE IF EXISTS menuca_v3.courses_backup_test_234;
DROP TABLE IF EXISTS menuca_v3.courses_backup_test_35;
DROP TABLE IF EXISTS menuca_v3.courses_backup_test_726;
DROP TABLE IF EXISTS menuca_v3.dishes_backup_test_234;
DROP TABLE IF EXISTS menuca_v3.dishes_backup_test_35;
DROP TABLE IF EXISTS menuca_v3.dishes_backup_test_726;
```
**Impact:** No risk, ~10-50 KB saved

**2. Archive Old Audit Logs**
```sql
-- Archive audit_log_2025_10 to archive schema
-- Keep only last 60-90 days
```
**Impact:** ~489 MB saved, historical data preserved

**3. Remove Empty Future Partitions**
```sql
-- Drop future audit_log partitions (2025-12, 2026-01, 2026-02, 2026-03)
-- Create dynamically when needed
```
**Impact:** Cleaner schema, no functional change

### Phase 2: Feature Removal (Medium Risk - Requires Testing)

**1. Remove Order Management System (if confirmed unused)**
- Drop all `orders*` and `order_items*` tables
- Drop payment/transaction tables
- Remove order-related functions
- **Impact:** ~50 MB saved, 15+ tables removed

**2. Remove Translation/i18n System (if confirmed unused)**
- Drop all `*_translations` tables (10 tables)
- Remove translation functions
- **Impact:** Cleaner schema, easier maintenance

**3. Remove User Account Features (if confirmed unused)**
- Drop cart, favorites, addresses, payment methods tables
- **Impact:** 7 tables removed

**4. Remove Advanced Dish Features (if confirmed unused)**
- Drop allergens, dietary_tags, inventory, size_options tables
- **Impact:** 5 tables removed

### Phase 3: Suspended Restaurant Data Archive (High Impact)

**1. Archive Suspended Restaurants**
```sql
-- Move 727 suspended restaurants to archive schema
-- Set deleted_at timestamp for soft delete
-- Archive related data:
--   - 646 contacts
--   - 272 schedules
--   - 143 devices
--   - 108 dishes
--   - 13 courses
--   - ~600 configs, locations, domains
```
**Impact:** ~25-30% reduction in active dataset

**2. Create Archive Views**
```sql
-- Create views in archive schema for historical reporting
CREATE VIEW archive.v_archived_restaurants AS ...
```

### Phase 4: Schema Optimization (Ongoing)

**1. Implement Audit Log Retention Policy**
- Keep last 60-90 days in hot storage
- Archive older partitions quarterly
- **Impact:** Ongoing space management

**2. Consolidate Delivery Systems**
- Migrate from `restaurant_delivery_areas` (47 rows) to `restaurant_delivery_zones` (1 row)
- Standardize on PostGIS zones
- **Impact:** Simpler delivery logic

**3. Function Audit**
- Review application code for function usage
- Remove unused functions
- **Impact:** Cleaner schema, easier maintenance

---

## Risk Assessment

### Low Risk Changes (Can Execute Immediately)
✅ Delete backup test tables  
✅ Archive audit logs > 90 days  
✅ Drop empty future partitions  
✅ Remove flash_sale_claims (5 rows)  
✅ Remove coupon_usage_log (2 rows)  

### Medium Risk Changes (Requires Application Testing)
⚠️ Remove translation tables (if translations not used in frontend)  
⚠️ Remove order management tables (if orders not processed in v3)  
⚠️ Remove user account features (if not used in frontend)  
⚠️ Remove dish allergen/dietary features (if not displayed)  

### High Risk Changes (Requires Extensive Testing)
🔴 Archive suspended restaurant data (affects 727 restaurants)  
🔴 Remove functions (must confirm no RPC calls from frontend)  
🔴 Consolidate delivery systems (affects delivery logic)  

---

## Expected Outcomes

### After Phase 1-2 (Feature Removal):
- **Tables Removed:** ~40-50 tables (36-45% reduction)
- **Storage Saved:** ~500-600 MB (40-50% reduction)
- **Functions Removed:** ~30-50 functions (17-28% reduction)
- **Complexity Reduced:** ~40% fewer tables to manage

### After Phase 3 (Suspend Archive):
- **Active Records:** Focus on 189 billing restaurants
- **Query Performance:** Improved (smaller active dataset)
- **Storage Saved:** Additional ~200-300 MB
- **Maintenance:** Simpler with focused dataset

### Final State:
- **Tables:** ~60-70 (vs 110 current)
- **Functions:** ~130-150 (vs 178 current)
- **Active Restaurants:** 189 (vs 955 current)
- **Storage:** ~500-700 MB (vs 1.2 GB current)

---

## Implementation Plan

### Week 1: Discovery & Validation
- [ ] Audit application code for function usage
- [ ] Confirm order system not in use
- [ ] Confirm translation system not in use
- [ ] Verify user account features not implemented
- [ ] Document function dependencies

### Week 2: Phase 1 Cleanup
- [ ] Backup entire database
- [ ] Delete backup test tables
- [ ] Archive audit_log_2025_10
- [ ] Drop empty future partitions
- [ ] Remove minimal-use tables (flash_sale, coupon_usage)

### Week 3: Phase 2 Feature Removal
- [ ] Remove unused translation system
- [ ] Remove unused order system  
- [ ] Remove unused user account features
- [ ] Remove unused dish features
- [ ] Test application thoroughly

### Week 4: Phase 3 Archive Planning
- [ ] Create archive schema structure
- [ ] Write archive migration scripts
- [ ] Test archive queries
- [ ] Document rollback procedure

### Week 5-6: Phase 3 Execution
- [ ] Archive suspended restaurant data
- [ ] Verify archived data accessible
- [ ] Monitor application performance
- [ ] Document new schema structure

---

## Maintenance Recommendations

### Ongoing
1. **Audit Log Management:** Implement automated monthly archiving
2. **Restaurant Status:** Regularly review and archive inactive restaurants
3. **Function Audit:** Quarterly review of function usage
4. **Table Growth:** Monitor table sizes and partition when needed
5. **Performance:** Regular VACUUM and ANALYZE operations

### Quarterly Reviews
1. Check for new empty/unused tables
2. Review suspended restaurant list (archive candidates)
3. Analyze audit log growth and adjust retention
4. Review function execution statistics
5. Optimize slow queries

---

## Conclusion

The menuca_v3 schema has significant opportunities for simplification:

**Quick Wins:**
- Remove 44 empty tables immediately
- Archive 489 MB of old audit logs
- Delete 6 backup test tables

**Medium-Term Goals:**
- Remove unused features (translations, orders, user accounts)
- Reduce from 110 to ~60-70 tables (35-40% reduction)
- Archive 727 suspended restaurants

**Long-Term Strategy:**
- Maintain lean schema focused on 189 active billing restaurants
- Implement automated archiving and retention policies
- Regular audits to prevent complexity creep

**Total Complexity Reduction:** 40-50% fewer tables, functions, and storage

---

**Prepared By:** Database Administrator AI  
**Review Status:** Pending stakeholder review  
**Next Steps:** Validate findings with application team, execute Phase 1

