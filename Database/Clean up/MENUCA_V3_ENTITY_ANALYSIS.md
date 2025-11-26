# Menuca V3 Schema - Core Entity Analysis
**Role**: Senior Database Administrator  
**Date**: 2025-11-14  
**Purpose**: Analyze and group tables, functions, and edge functions into core entities for optimization

---

## Executive Summary

**Current Schema Stats:**
- **Tables**: 110 (~~6.5 GB~~ **~596 MB total** after optimization)
- **SQL Functions**: 178
- **Edge Functions**: ~~38~~ **34** (4 legacy functions removed)
- **Target**: 185 active restaurants
- **Optimization Progress**: 
  - 489 MB saved from audit logs ✅
  - 54 MB saved from orphan menu data cleanup ✅
  - 348 orphan admin assignments removed ✅
  - **Total Saved**: 543 MB + 348 records (45% reduction) 🎯

**Largest Tables by Size:**
1. `dish_modifiers` - 203 MB
2. `dish_modifier_prices` - 164 MB  
3. `audit_log_2025_11` - 100 MB
4. `dishes` - 38 MB
5. `users` - 33 MB
6. ~~`audit_log_2025_10` - 489 MB~~ **ARCHIVED** (now 56 KB)

---

## Core Entity Groups

### 🏢 **ENTITY 1: RESTAURANT MANAGEMENT** (Core Business)
*Primary entity - all operations depend on this*

#### Tables (30 tables, ~10 MB)
**Primary:**
- `restaurants` (1.9 MB) - Main restaurant data
- `restaurant_locations` (1.5 MB) - Physical locations
- `restaurant_onboarding` (360 KB) - New restaurant setup

**Configuration:**
- `restaurant_service_configs` (696 KB) - Service settings
- `restaurant_delivery_config` (856 KB) - Delivery settings
- `restaurant_twilio_config` (96 KB) - SMS/phone config
- `restaurant_domains` (816 KB) - Custom domains

**Contacts & Reviews:**
- `restaurant_contacts` (1.2 MB) - Contact information
- `restaurant_reviews` (280 KB) - Customer reviews
- `restaurant_partner_schedules` (96 KB) - Partner schedules

**Classification:**
- `restaurant_cuisines` (304 KB) - Cuisine types
- `restaurant_tags` (80 KB) - Tag definitions
- `restaurant_tag_assignments` (624 KB) - Restaurant-tag links
- `restaurant_tag_associations` (136 KB) - Tag associations
- `cuisine_types` (64 KB) - Available cuisines

**Status & History:**
- `restaurant_status_history` (480 KB) - Status tracking
- `restaurant_onboarding` (360 KB) - Onboarding progress

#### SQL Functions (45 functions)
**Restaurant Operations:**
- `create_restaurant_onboarding`, `complete_onboarding_and_activate`
- `get_restaurant_by_slug`, `get_restaurant_config`, `get_restaurant_status_stats`
- `search_restaurants`, `find_nearby_restaurants`, `get_restaurants_near_location`
- `toggle_online_ordering`, `can_accept_orders`, `is_restaurant_open_now`

**Franchise Management:**
- `create_franchise_parent`, `convert_to_franchise`, `batch_link_franchise_children`
- `get_franchise_children`, `get_franchise_parent`, `get_franchise_summary`
- `is_franchise_location`, `validate_franchise_hierarchy`, `compare_franchise_locations`
- `bulk_update_franchise_feature`, `get_franchise_analytics`, `get_franchise_menu_coverage`

**Restaurant Features:**
- `add_cuisine_to_restaurant`, `add_tag_to_restaurant`
- `get_restaurants_by_cuisine`, `get_restaurants_by_tag`
- `create_restaurant_with_cuisine`, `get_restaurant_vendor`

**Status Management:**
- `audit_restaurant_status_change`, `get_restaurant_status_timeline`
- `get_restaurant_availability`, `check_admin_restaurant_access`

#### Edge Functions (12 functions)
- `create-restaurant-onboarding`, `complete-restaurant-onboarding`
- `update-restaurant-status`, `toggle-online-ordering`
- `check-restaurant-availability`, `get-operational-restaurants`
- `search-restaurants`, `get-restaurant-onboarding`, `update-onboarding-step`
- `create-franchise-parent`, `convert-restaurant-to-franchise`, `bulk-update-franchise-feature`

---

### 📍 **ENTITY 2: LOCATION & GEOGRAPHY** (Support)

#### Tables (3 tables, ~300 KB)
- `cities` (144 KB) - City definitions
- `provinces` (88 KB) - Province/state data
- `restaurant_locations` (1.5 MB) - *Shared with Restaurant Management*

#### SQL Functions (4 functions)
- `get_all_provinces`, `get_cities_by_province`
- `search_cities`, `find_nearest_franchise_locations`

#### Edge Functions (0 functions)
*No dedicated edge functions - handled via SQL functions*

---

### 🍕 **ENTITY 3: MENU & CATALOG** (Core Product)
*Largest data footprint - 450+ MB*

#### Tables (20 tables, ~450 MB)
**Primary:**
- `dishes` (38 MB) - Menu items
- `dish_modifiers` (203 MB) - Modifiers (largest table!)
- `dish_modifier_prices` (164 MB) - Modifier pricing (2nd largest!)
- `dish_prices` (11 MB) - Dish pricing

**Courses & Organization:**
- `courses` (1.7 MB) - Menu courses/categories
- `combo_steps` (2.2 MB) - Combo meal steps
- `combo_group_modifier_pricing` (14 MB) - Combo pricing

**Translations:**
- `dish_translations` (96 KB) - Multi-language support
- `course_translations` (96 KB) - Course translations
- `dish_modifier_translations` (48 KB) - Modifier translations
- `modifier_group_translations` (48 KB) - Group translations
- `combo_group_translations` (48 KB) - Combo translations

**Attributes & Options:**
- `dish_allergens` (56 KB) - Allergen information
- `dish_dietary_tags` (56 KB) - Dietary restrictions
- `dish_size_options` (48 KB) - Size variations
- `dish_inventory` (64 KB) - Stock tracking
- `modifier_groups` (3.9 MB) - Modifier groupings

**Backup Tables (TO REVIEW FOR DELETION):**
- `courses_backup_test_234` (8 KB)
- `courses_backup_test_35` (16 KB)
- `courses_backup_test_726` (16 KB)
- `dishes_backup_test_234` (8 KB)
- `dishes_backup_test_35` (16 KB)
- `dishes_backup_test_726` (16 KB)

#### SQL Functions (28 functions)
**Menu Operations:**
- `get_restaurant_menu`, `get_restaurant_menu_translated`
- `add_menu_item_onboarding`, `copy_franchise_menu_onboarding`
- `refresh_menu_summary`

**Dish Management:**
- `soft_delete_dish`, `restore_dish`, `update_dish_availability`
- `is_dish_available_now`, `auto_expire_unavailable_dishes`
- `get_dish_allergens`, `get_dish_dietary_tags`, `get_dish_size_options`
- `dish_contains_allergen`, `filter_dishes_by_dietary_tags`

**Inventory:**
- `decrement_dish_inventory`, `dish_inventory` (table)

**Modifiers & Combos:**
- `validate_dish_modifiers`, `validate_combo_configuration`
- `calculate_combo_price`, `enforce_dish_pricing`

**Notifications:**
- `notify_menu_change`

#### Edge Functions (2 functions)
- `import-menu` - Menu import utility
- `copy-franchise-menu` - Franchise menu copying

---

### 🕐 **ENTITY 4: SCHEDULES & HOURS** (Operations)

#### Tables (6 tables, ~2 MB)
- `restaurant_schedules` (864 KB) - Regular hours
- `restaurant_special_schedules` (144 KB) - Holiday/special hours
- `restaurant_time_periods` (112 KB) - Time periods
- `restaurant_partner_schedules` (96 KB) - Partner schedules
- `schedule_translations` (40 KB) - Schedule translations

#### SQL Functions (12 functions)
**Schedule Management:**
- `get_restaurant_schedule`, `get_restaurant_hours`, `get_restaurant_hours_i18n`
- `clone_schedule_to_day`, `bulk_copy_schedule_onboarding`
- `apply_schedule_template_onboarding`

**Validation:**
- `check_schedule_overlap`, `has_schedule_conflict`
- `validate_schedule_no_overlap`, `validate_timezone`

**Operations:**
- `bulk_toggle_schedules`, `soft_delete_schedule`, `restore_schedule`
- `get_upcoming_schedule_changes`

**Notifications:**
- `notify_schedule_change`

#### Edge Functions (1 function)
- `apply-schedule-template` - Schedule template application

---

### 🚚 **ENTITY 5: DELIVERY & ZONES** (Logistics)

#### Tables (7 tables, ~2 MB)
**Zones & Areas:**
- `restaurant_delivery_areas` (240 KB) - Delivery coverage
- `restaurant_delivery_zones` (104 KB) - Zone definitions
- `restaurant_delivery_fees` (208 KB) - Fee structure

**Configuration:**
- `restaurant_delivery_config` (856 KB) - Delivery settings
- `restaurant_delivery_companies` (168 KB) - Delivery partners
- `delivery_company_emails` (80 KB) - Company contacts

#### SQL Functions (9 functions)
**Zone Management:**
- `create_delivery_zone`, `create_delivery_zone_onboarding`
- `update_delivery_zone`, `soft_delete_delivery_zone`, `restore_delivery_zone`
- `toggle_delivery_zone_status`, `get_delivery_zone_area_sq_km`

**Address Validation:**
- `is_address_in_delivery_zone`

**Restaurant Summary:**
- `get_restaurant_delivery_summary`

#### Edge Functions (4 functions)
- `create-delivery-zone`, `update-delivery-zone`
- `delete-delivery-zone`, `toggle-zone-status`

---

### 🛒 **ENTITY 6: ORDERS & CHECKOUT** (Transactions)
*Partitioned tables - historical data*

#### Tables (16 tables, ~1 GB including audit logs)
**Orders (Partitioned by Month):**
- `orders` (0 bytes - parent/partition table)
- `orders_2025_10` (224 KB)
- `orders_2025_11` (224 KB)
- `orders_2025_12` (120 KB)
- `orders_2026_01` (120 KB)
- `orders_2026_02` (120 KB)
- `orders_2026_03` (120 KB)

**Order Items (Partitioned):**
- `order_items` (0 bytes - parent)
- `order_items_2025_10` (32 KB)
- `order_items_2025_11` (64 KB)
- `order_items_2025_12` (32 KB)
- `order_items_2026_01` (32 KB)
- `order_items_2026_02` (32 KB)
- `order_items_2026_03` (32 KB)

**Order Tracking:**
- `order_status_history` (80 KB) - Status changes
- `cart_sessions` (48 KB) - Shopping carts
- `payment_transactions` (48 KB) - Payment processing

#### SQL Functions (17 functions)
**Order Creation & Management:**
- `create_order` (2 versions)
- `calculate_order_total` (2 versions)
- `check_order_eligibility` (2 versions)
- `cancel_order`, `cancel_customer_order`
- `update_order_status`

**Order Queries:**
- `get_customer_order_history`, `get_restaurant_orders`
- `get_order_details`

**Cart Operations:**
- `check_cart_availability`

**Triggers:**
- `log_order_status_change`, `update_order_timestamp`

**Partitioning:**
- `create_next_month_partitions`

**Business Logic:**
- `get_cancellation_policy`

#### Edge Functions (0 functions)
*Orders handled via SQL functions for security*

---

### 💰 **ENTITY 7: MARKETING & PROMOTIONS** (Sales)

#### Tables (11 tables, ~2 MB)
**Promotional Deals:**
- `promotional_deals` (320 KB) - Active deals
- `promotional_deals_translations` (80 KB) - Multi-language

**Coupons:**
- `promotional_coupons` (672 KB) - Coupon definitions
- `promotional_coupons_translations` (80 KB) - Translations
- `coupon_usage_log` (96 KB) - Redemption tracking

**Flash Sales:**
- `flash_sale_claims` (72 KB) - Flash sale claims

**Marketing Tags:**
- `marketing_tags` (96 KB) - Marketing tags
- `marketing_tags_translations` (80 KB) - Tag translations
- `ingredient_translations` (96 KB) - Ingredient info

#### SQL Functions (29 functions)
**Deal Management:**
- `get_active_deals`, `get_deal_with_translation`, `get_deals_i18n`
- `auto_apply_best_deal`, `is_deal_active_now`
- `clone_deal` (2 versions)
- `toggle_deal_status`, `bulk_enable_deals`, `bulk_disable_deals`
- `soft_delete_deal`, `restore_deal`
- `get_popular_deals`, `get_deal_usage_stats`
- `validate_deal_eligibility`, `calculate_deal_discount`

**Coupon Operations:**
- `validate_coupon`, `apply_coupon_to_order`, `redeem_coupon`
- `get_coupon_with_translation`, `get_coupons_i18n`
- `soft_delete_coupon`, `restore_coupon`
- `check_coupon_usage_limit`, `get_coupon_redemption_rate`

**Flash Sales:**
- `create_flash_sale`, `claim_flash_sale_slot`

**Analytics:**
- `get_promotion_analytics`

**Marketing Tags:**
- `translate_marketing_tag`

#### Edge Functions (0 functions)
*Promotions handled via SQL functions*

---

### 👥 **ENTITY 8: USERS & CUSTOMERS** (End Users)

#### Tables (8 tables, ~34 MB)
**User Accounts:**
- `users` (33 MB) - Customer accounts (LARGE!)
- `user_addresses` (48 KB) - Saved addresses
- `user_delivery_addresses` (80 KB) - Delivery addresses
- `autologin_tokens` (48 KB) - Auto-login tokens
- `password_reset_tokens` (40 KB) - Password resets

**User Preferences:**
- `user_favorite_dishes` (24 KB) - Saved dishes
- `user_favorite_restaurants` (72 KB) - Saved restaurants
- `user_payment_methods` (32 KB) - Payment info

#### SQL Functions (5 functions)
**User Profile:**
- `get_user_profile`, `get_user_addresses`

**Favorites:**
- `get_favorite_restaurants`, `toggle_favorite_restaurant`

#### Edge Functions (0 functions)
*User management via Supabase Auth*

---

### 🔐 **ENTITY 9: ADMIN & ACCESS CONTROL** (Internal Users)

#### Tables (8 tables, ~2 MB)
**Admin Users:**
- `admin_users` (616 KB) - Admin accounts
- `admin_user_restaurants` (424 KB) - Restaurant assignments
- `restaurant_admin_users` (456 KB) - Restaurant admins (duplicate?)
- `admin_roles` (48 KB) - Role definitions
- `admin_user_preferences` (160 KB) - Admin preferences

**Analytics & Archive:**
- `restaurant_admin_users_analytics` (32 KB) - Usage stats
- `restaurant_admin_users_archive` (264 KB) - Archived admins

**Audit:**
- `admin_audit_log` (96 KB) - Admin activity
- `admin_action_logs` (48 KB) - Action tracking
- `admin_consolidation_summary` (32 KB) - Consolidation info

#### SQL Functions (6 functions)
**Admin Operations:**
- `assign_restaurants_to_admin`, `check_admin_restaurant_access`
- `get_admin_profile`, `get_my_admin_info`
- `get_admin_restaurants`, `log_admin_audit`

#### Edge Functions (2 functions)
- `create-admin-user` - Create admin accounts
- `assign-admin-restaurants` - Assign restaurants to admins

---

### 📱 **ENTITY 10: DEVICES & INFRASTRUCTURE** (Hardware)

#### Tables (2 tables, ~800 KB)
- `devices` (784 KB) - Registered devices
- `restaurant_domains` (816 KB) - Custom domains

#### SQL Functions (9 functions)
**Device Management:**
- `register_device`, `authenticate_device`, `deactivate_device`
- `device_heartbeat`, `update_device_heartbeat`
- `get_admin_devices`, `get_restaurant_devices`
- `soft_delete_device`, `restore_device`

**Domain Management:**
- `get_domain_verification_status`, `mark_domain_verified`

**Notifications:**
- `alert_ssl_expiring`, `notify_location_change`

#### Edge Functions (4 functions)
- `verify-domains-cron` - Automated domain verification
- `verify-single-domain` - Single domain check
- `add-restaurant-contact` - Contact management
- `update-restaurant-contact`, `delete-restaurant-contact`

---

### 🏢 **ENTITY 11: VENDORS & FRANCHISES** (Business Partnerships)

#### Tables (4 tables, ~1.5 MB)
- `vendors` (160 KB) - Vendor definitions
- `vendor_restaurants` (288 KB) - Vendor-restaurant links
- `vendor_commission_reports` (1.1 MB) - Commission tracking
- `vendor_statement_numbers` (24 KB) - Statement numbering

#### SQL Functions (8 functions)
**Vendor Management:**
- `create_vendor`, `add_restaurant_to_vendor`
- `get_all_vendors`, `get_vendor_locations`

**Commission:**
- `prepare_commission_calculation`, `get_next_statement_number`
- `update_last_commission_rate`

**Notifications:**
- `notify_vendor_change`

#### Edge Functions (3 functions)
- `calculate-vendor-commission` - Commission calculation
- `get-commission-preview` - Preview calculations
- `add-restaurant-cuisine`, `add-restaurant-tag`

---

### 📊 **ENTITY 12: AUDIT & LOGGING** (Compliance)
*Largest storage footprint - 600+ MB*

#### Tables (9 tables, ~600 MB)
**Audit Logs (Partitioned):**
- `audit_log` (0 bytes - parent)
- `audit_log_2025_10` (489 MB) ⚠️ HUGE!
- `audit_log_2025_11` (100 MB) ⚠️ LARGE!
- `audit_log_2025_12` (56 KB)
- `audit_log_2026_01` (56 KB)
- `audit_log_2026_02` (56 KB)
- `audit_log_2026_03` (56 KB)

**Operational Logs:**
- `coupon_usage_log` (96 KB) - Coupon redemptions
- `order_status_history` (80 KB) - Order tracking

#### SQL Functions (4 functions)
**Audit Operations:**
- `audit_trigger_func`, `cleanup_old_audit_logs`
- `get_deletion_audit_trail`

**Triggers:**
- `set_updated_at`, `trigger_set_updated_at`

#### Edge Functions (1 function)
- `get-deletion-audit-trail` - Audit trail viewer

---

### 🛠️ **ENTITY 13: SYSTEM & UTILITIES** (Infrastructure)

#### Tables (5 tables, ~200 KB)
- `rate_limits` (40 KB) - API rate limiting
- `email_queue` (40 KB) - Email sending queue
- `failed_jobs` (32 KB) - Failed job tracking
- `stripe_webhook_events` (48 KB) - Payment webhooks

#### SQL Functions (8 functions)
**Timestamp Management:**
- `set_updated_at`, `trigger_set_updated_at`
- `update_onboarding_timestamp`, `update_restaurant_features_timestamp`
- `manage_feature_timestamps`

**Utility:**
- `get_day_name`, `generate_restaurant_slug`

**Soft Delete:**
- `soft_delete_record`, `restore_deleted_record`

#### Edge Functions (3 functions)
- `soft-delete-record` - Generic soft delete
- `restore-deleted-record` - Generic restore
- `get-deletion-audit-trail` - Deletion tracking

---

### 🔄 **ENTITY 14: LEGACY MIGRATION** (Temporary - Can Be Removed)

#### Tables (0 tables)
*No dedicated tables - uses existing user tables*

#### SQL Functions (0 functions)
*Migration handled via Edge Functions*

#### Edge Functions (0 functions) ✅ **DELETED**
- ~~`check-legacy-account`~~ - DELETED 2025-11-14
- ~~`complete-legacy-migration`~~ - DELETED 2025-11-14
- ~~`get-migration-stats`~~ - DELETED 2025-11-14
- ~~`create-legacy-auth-accounts`~~ - DELETED 2025-11-14

**✅ COMPLETED**: All legacy migration edge functions removed from codebase.

---

## Storage Analysis by Entity

| Entity | Tables | Size | SQL Functions | Edge Functions | Priority |
|--------|--------|------|---------------|----------------|----------|
| **Audit & Logging** | 9 | ~~**600 MB**~~ **111 MB** | 4 | 1 | ✅ Optimized |
| **Menu & Catalog** | 20 | **450 MB** | 28 | 2 | Optimize |
| **Users & Customers** | 8 | **34 MB** | 5 | 0 | Review |
| **Orders & Checkout** | 16 | **1 MB** | 17 | 0 | Keep |
| **Restaurant Management** | 30 | **10 MB** | 45 | 12 | Core - Keep |
| **Marketing & Promotions** | 11 | **2 MB** | 29 | 0 | Review |
| **Schedules & Hours** | 6 | **2 MB** | 12 | 1 | Keep |
| **Delivery & Zones** | 7 | **2 MB** | 9 | 4 | Keep |
| **Admin & Access Control** | 8 | **2 MB** | 6 | 2 | Review |
| **Vendors & Franchises** | 4 | **1.5 MB** | 8 | 3 | Review |
| **Devices & Infrastructure** | 2 | **800 KB** | 9 | 4 | Keep |
| **Location & Geography** | 3 | **300 KB** | 4 | 0 | Keep |
| **System & Utilities** | 5 | **200 KB** | 8 | 3 | Keep |
| **Legacy Migration** | 0 | **0 MB** | 0 | ~~4~~ **0** | ✅ **DELETED** |
| **TOTAL** | **110** | ~~**~1.1 GB**~~ **~650 MB** | **178** | ~~**38**~~ **34** | - |

---

## Immediate Optimization Opportunities

### 🔥 **HIGH PRIORITY - Immediate Action**

1. **Archive Old Audit Logs** ✅ **COMPLETED** (Saved 489 MB)
   - ~~`audit_log_2025_10` (489 MB)~~ **ARCHIVED & TRUNCATED 2025-11-14**
     - Exported 352,218 rows to `audit_log_2025_10_archive.csv`
     - Partition size reduced from 489 MB → 56 KB
   - `audit_log_2025_11` (100 MB) **KEPT** - Current month data (last 11 days)
   - Action: ~~Archive to cold storage~~ **Done!** Keeping last 30 days

2. **Delete Backup Tables** (Save ~50 KB)
   - `courses_backup_test_*` (3 tables)
   - `dishes_backup_test_*` (3 tables)
   - Action: Verify not needed, delete

3. **Remove Legacy Migration Functions** ✅ **COMPLETED**
   - ~~4 Edge Functions~~ **DELETED 2025-11-14**
   - Action: ~~Delete if migration complete~~ **Done!**

4. **Clean Up Orphan Data** ✅ **COMPLETED** (Saved 54 MB + 348 records)
   - ~~584 orphan courses~~ **DELETED 2025-11-14**
   - ~~5,574 orphan dishes~~ **DELETED 2025-11-14**
   - ~~10,639 orphan prices~~ **DELETED 2025-11-14**
   - ~~2,978 orphan modifier groups~~ **DELETED 2025-11-14**
   - ~~348 orphan admin assignments~~ **DELETED 2025-11-14**
   - Total: 20,123 orphan records removed
   - Menu data exported to CSV for audit trail
   - Action: ~~Investigate and delete~~ **Done!**

5. **Entity 1 Audit: Restaurant Management** ✅ **COMPLETED** (100% Clean)
   - Audited all 30 tables in Entity 1
   - Found and removed 348 orphan admin-restaurant assignments (278 deleted restaurant IDs)
   - **Status**: All Entity 1 tables verified clean ✅
   - Action: ~~Audit for orphans~~ **Done!**

### ⚠️ **MEDIUM PRIORITY - Review & Optimize**

6. **Analyze Dish Modifiers** (450 MB)
   - `dish_modifiers` (203 MB)
   - `dish_modifier_prices` (164 MB)
   - Action: Check for unused modifiers, optimize data structure

7. **Review User Table** (33 MB)
   - Action: Check for inactive users, clean up test accounts

8. **Consolidate Admin Tables**
   - `restaurant_admin_users` vs `admin_users` - duplicates?
   - Action: Verify data and merge if possible

### 💡 **LOW PRIORITY - Future Optimization**

9. **Review Unused Functions**
   - 178 SQL functions - identify rarely used
   - Action: Performance audit

10. **Optimize Partitioned Tables**
   - Orders and order_items partitions
   - Action: Automate old partition archival

---

## 📋 Investigation Reports

### V1 Restaurants Missing Modifiers (November 17, 2025)
**Report:** `Database/Clean up/V1_RESTAURANTS_MISSING_MODIFIERS_REPORT.md`

**Summary:**
- 163 out of 170 V1 restaurants (95.9%) have dishes without modifiers
- 22 restaurants have 100% of dishes missing modifiers
- ~18,000 dishes affected (60% of V1 dishes)
- Asian cuisine types most affected (Chinese, Sushi, Thai, Indian)
- **Assigned to:** Brian for further investigation
- **Priority:** Medium (affects customer ordering experience)

**Key Finding:** V1 scraping appears to have missed or skipped modifier data. Requires validation and potential re-scraping with V2 scraper.

---

## Next Steps

1. **Confirm Entity Groupings** - Review with team ✅ **COMPLETE**
2. **Prioritize Cleanup Tasks** - Which entities to tackle first? ✅ **IN PROGRESS**
3. **Create Detailed Plans** - One entity at a time ✅ **IN PROGRESS**
4. **Execute Cleanup** - Measure impact ✅ **ONGOING**

**Current Progress:** Entity 1 (Restaurant Management) fully audited and cleaned. Investigation report created for V1 modifier issues.

