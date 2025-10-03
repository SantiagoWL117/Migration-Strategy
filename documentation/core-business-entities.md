## Core Business Entities

This document lists the core business entities identified across V1 and V2 of the Menu.ca databases, with their purpose and relevant tables.

### Restaurant Management
- Purpose: Core profile, configuration, content, and ownership surface for each restaurant.
- V1 Tables: `restaurants`, `restaurant_domains`, `restaurant_contacts`, `restaurant_notes`, `restaurant_photos`, `restaurant_feedback`, `restaurant_votes`, `restaurant_thresholds`.
- V2 Tables: `restaurants`, `restaurants_domain`, `restaurants_contacts`, `restaurants_about`, `restaurants_seo`, `restaurants_landing`, `restaurants_messages`, `restaurants_announcements`, `restaurants_mail_templates`.

### Location & Geography
- Purpose: Physical address, geocoding, and area coverage details.
- V1 Tables: `restaurant_delivery_areas`, `restaurant_areas`, `restaurant_locations`.
- V2 Tables: `restaurants_delivery_areas`.

### Service Configuration & Schedules
- Purpose: Service capabilities (delivery/takeout), business hours, special schedules, and operational status.
- **V1 Tables** - TO MIGRATE: 
  - `restaurants_schedule_normalized` - Regular schedules (types: d=delivery, t=takeout) with day ranges
  - Service flags in `restaurants`: `pickup`, `delivery`, `takeout`, `delivery_time`, `takeout_time`, `vacation`, `vacationStart`, `vacationStop`, `suspendOrdering`, `suspend_operation`, `suspended_at`, `comingSoon`, `overrideAutoSuspend`
  - **Note**: Data already normalized from `restaurant_schedule` (416K+ rows), `delivery_schedule` (1.3K rows), and blob fields
- **V1 Tables EXCLUDED**: 
  - `restaurant_schedule`, `delivery_schedule` - Already normalized
  - `delivery_disable` (1.8K rows) - Historical events, not schedules
  - `restaurants_special_schedule` (5 rows) - Historical data only, V2 has better data
- **V2 Tables** - TO MIGRATE: 
  - `restaurants_schedule` (2.5K rows) - Regular schedules with day ranges (types: d=delivery, t=takeout)
  - `restaurants_special_schedule` (134 rows) - Override schedules for closures/special hours (date ranges with reason/type)
  - `restaurants_configs` - Service capabilities and configuration (takeout/delivery settings, times, discounts, preorders)
  - `restaurants_time_periods` (15 rows) - **CONFIRMED: Menu items reference these periods - must migrate**
  - Service flags in `restaurants`: `suspend_operation`, `suspended_at`, `coming_soon`, `vacation`, `vacation_start`, `vacation_stop`, `suspend_ordering`, `suspend_ordering_start`, `suspend_ordering_stop`, `active`, `pending`
- **V2 Tables EXCLUDED**: 
  - `restaurants_disable_delivery` (31 rows) - 2019 data only (expired)
- **V2 Tables - Other Entity**: 
  - `restaurants_delivery_schedule` (7 rows) - Delivery partner schedule for restaurant 1635 → **Delivery Operations entity**
- **V3 Target**: `restaurant_schedules`, `restaurant_special_schedules`, `restaurant_service_configs`, `restaurant_time_periods`
- **Migration Guide**: `Service Configuration & Schedules/SERVICE_SCHEDULES_MIGRATION_GUIDE.md`
- **Migration Complexity**: 🟢 LOW-MEDIUM (reduced from HIGH due to V1 pre-normalization)
- **Timeline**: 6-8 days
- **Status**: ✅ Schema created, ready for data migration

### Delivery Operations
- Purpose: Delivery pricing, delivery partners, and runtime delivery controls.
- V1 Tables: `delivery_info`, `distance_fees`, `delivery_orders`, `quebec_delivery_retries`, `geodispatch_reports`, `geodispatch_retries`, `tookan_fees`.
- V2 Tables: `restaurants_delivery_info`, `restaurants_delivery_fees`, `delivery_company_retries`, `deliveryzone_retries`, `twilio`.
- **Additional V2 Table**: `restaurants_delivery_schedule` (7 rows) - Delivery partner availability for restaurant 1635 (mon-sun, 11am-10pm)

### Menu & Catalog
- Purpose: Menu structure (courses, dishes), combos, ingredients, and customizations.
- V1 Tables: `menu`, `courses`, `combos`, `combo_groups`, `ingredients`, `ingredient_groups`, `menuothers`.
- V2 Tables: `restaurants_courses`, `restaurants_dishes`, `restaurants_dishes_customization`, `restaurants_combo_groups`, `restaurants_combo_groups_items`, `restaurants_ingredients`, `restaurants_ingredient_groups`, `restaurants_ingredient_groups_items`, `custom_ingredients`, `global_courses`, `global_dishes`, `global_ingredients`, `global_restaurant_types`.

### Orders & Checkout
- Purpose: Order lifecycle, line items, customizations, and order artifacts.
- V1 Tables: `user_orders`, `orders`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `donations`, `over_hundred`.
- V2 Tables: `order_details`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `cancel_order_requests`.

### Payments
- Purpose: Customer payment profiles, payment intents/transactions, and providers.
- V1 Tables: `tokens`, `stripe_payments`, `stripe_payment_clients`, `stripe_payments_intents`.
- V2 Tables: `payment_clients`, `payments`, `stripe_payment_clients`, `stripe_payments_intents`.

### Users & Access
- Purpose: Customer and staff identities, sessions, and access control metadata.
- V1 Tables: `users`, `admin_users`, `restaurant_admins`, `callcenter_users`, `ci_sessions`, resets/auth helpers.
- V2 Tables: `site_users`, `admin_users`, `admin_users_restaurants`, `ci_sessions`, `reset_codes`, `login_attempts`, `site_users_autologins`, `site_users_delivery_addresses`, `site_users_favorite_restaurants`, `site_users_fb`.

### Marketing & Promotions
- Purpose: Coupons, deals, landing pages, tags, and navigation metadata.
- V1 Tables: `coupons`, `deals`, `user_coupons`, `banners`, `autoresponders`, `tags`, `redirects`.
- V2 Tables: `coupons`, `restaurants_deals`, `restaurants_deals_splits`, `landing_pages`, `landing_pages_restaurants`, `tags`, `restaurants_tags`, `nav`, `nav_subitems`, `permissions_list`.

### Accounting & Reporting
- Purpose: Fees, statements, vendor reports, and financial aggregates.
- V1 Tables: `restaurant_fees`, `restaurant_fees_stripe`, `restaurant_charges`, `issued_statements`, `statement_info`, `statement_invoices`, `statement_payments`, `statement_carry_values`, `vendors_reports`.
- V2 Tables: `restaurants_fees`, `restaurants_accounting_fees`, `restaurants_charges`, `statements`, `restaurants_statements`, `vendor_reports`, `vendor_reports_numbers`, `vendor_invoices`, `statement_carry_values`.

### Vendors & Franchises
- Purpose: Vendor relationships, franchise groupings, and splits/templates.
- V1 Tables: `vendors`, `vendors_restaurants`, `vendor_users`, vendor report files.
- V2 Tables: `vendors`, `francizes`, `vendor_sites`, `vendor_splits`, `vendor_splits_templates`, `vendor_reports`, `vendor_reports_numbers`, `vendor_invoices`.

### Devices & Infrastructure
- Purpose: Restaurant tablets and supporting runtime/system metadata.
- V1 Tables: `tablets`, `tablet_orders`, `ci_sessions`, `groups`, `groups_permissions`, `themes`, `theme_*`.
- V2 Tables: `tablets`, `tablet_orders`, `ci_sessions`, `groups`, `groups_permissions`, `phinxlog`.


