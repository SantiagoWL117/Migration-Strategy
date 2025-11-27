## Core Business Entities

This document lists the remaining core business entities that need to be migrated from V1 and V2 of the Menu.ca databases to V3.

**Migration Status Summary**:
- ✅ **Completed & Tested**: Restaurant Management, Service Configuration & Schedules, Delivery Operations, Users & Access, Menu & Catalog, Marketing & Promotions, Location & Geography
- 🔄 **In Progress**: (None currently)
- ❌ **Not Needed**: , Orders & Checkout, Payments, Accounting & Reporting

### Delivery Operations
- Purpose: Delivery pricing, delivery company integrations, partner configuration, and phone notifications
- **V1 Tables** - TO MIGRATE:
  - `delivery_info` (250 rows) - Delivery company emails (needs normalization - comma-separated emails)
  - `distance_fees` (687 rows) - Distance-based fee structure
  - `tookan_fees` (868 rows) - Area-based fee structure (Tookan delivery partner)
  - Delivery flags in `restaurants` (847 restaurants) - Partner credentials, configuration, and enablement flags (24 columns)
- **V1 Tables EXCLUDED** (Empty/Irrelevant/User Decision):
  - `restaurant_delivery_areas` - Empty
  - `quebec_delivery_retries` - Empty/irrelevant
  - `geodispatch_retries` - Empty/irrelevant
  - `geodispatch_reports` - Empty/irrelevant
  - ✅ `delivery_orders` - **USER DECISION: Data no longer relevant** (1,513 rows with BLOB data)
  - ✅ `restaurants.deliveryArea` (BLOB column) - **USER DECISION: No data exists**
- **V2 Tables** - TO MIGRATE:
  - `restaurants_delivery_schedule` (7 rows) - Delivery partner schedule for restaurant 1635
  - `restaurants_delivery_fees` (61 rows) - Delivery partner fees for restaurant 1635 (distance-based, measured in km)
  - `twilio` (39 rows) - Twilio phone integration for order notifications
  - `restaurants_delivery_areas` (639 rows) - Delivery zones with PostGIS geometry
  - Delivery flags in `restaurants` (629 restaurants) - V2 delivery configuration per restaurant
- **V2 Tables EXCLUDED** (Empty/Irrelevant):
  - `restaurants_delivery_info` - Empty/irrelevant
  - `extra_delivery_fees` - Empty/irrelevant
  - `delivery_company_retries` - Runtime retry queue
  - `deliveryzone_retries` - Empty/irrelevant
  - `restaurants_disable_delivery` - Empty/irrelevant
- **V3 Target**: `delivery_company_emails`, `restaurant_delivery_companies`, `restaurant_delivery_fees`, `restaurant_partner_schedules`, `restaurant_twilio_config`, `restaurant_delivery_config`, `restaurant_delivery_areas` (7 tables)
- **Migration Guide**: `Delivery Operations/DELIVERY_OPERATIONS_MIGRATION_GUIDE.md`
- **Data Volume**: ~1,912 rows (8 tables: 3 V1 + 4 V2 + restaurant flags)
- **Key Insights**: 
  - V2 delivery partner data exists for only 1 active restaurant (1635)
  - V2 restaurants_delivery_areas contains PostGIS geometry data (639 polygon delivery zones)
  - Restaurant delivery flags need normalization from both V1 and V2
  - V1 delivery_orders EXCLUDED per user (operational data, no longer relevant)
  - V1 deliveryArea BLOB EXCLUDED per user (no data exists)
- **Migration Complexity**: 🟡 MEDIUM (PostGIS geometry, flag normalization, email normalization)
- **Timeline**: 6-8 days (reduced from 10-12 due to exclusions)
- **Status**: 📋 User Approved Scope - Ready for Schema Creation

### Orders & Checkout - ❌ NOT NEEDED
- Purpose: Order lifecycle, line items, customizations, and order artifacts.
- V1 Tables: `user_orders`, `orders`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `donations`, `over_hundred`.
- V2 Tables: `order_details`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `cancel_order_requests`.
- **Status**: Migration not required

### Payments - ❌ NOT NEEDED
- Purpose: Customer payment profiles, payment intents/transactions, and providers.
- V1 Tables: `tokens`, `stripe_payments`, `stripe_payment_clients`, `stripe_payments_intents`.
- V2 Tables: `payment_clients`, `payments`, `stripe_payment_clients`, `stripe_payments_intents`.
- **Status**: Migration not required

### Marketing & Promotions - ✅ COMPLETED & TESTED
- Purpose: Coupons, deals, landing pages, tags, and navigation metadata.
- V1 Tables: `coupons`, `deals`, `user_coupons`, `tags` (✅ Migrated: 816 rows)
- V2 Tables: `restaurants_deals`, `tags`, `restaurants_tags` (✅ Migrated: 110 rows)
- **V3 Tables Created**: `marketing_tags` (36), `promotional_deals` (202), `promotional_coupons` (581), `restaurant_tag_associations` (29)
- **BLOB Columns Processed**: `deals.exceptions` (100% deserialized, 41 rows)
- **Migration Completeness**: 848/926 source rows loaded (91.6% - 78 skipped due to test accounts/invalid FKs)
- **Data Quality**: 100% FK integrity, 100% JSONB integrity, Zero orphaned records
- **Documentation**: `Database/Marketing & Promotions/COMPREHENSIVE_DATA_QUALITY_REVIEW.md`
- **Excluded Tables** (Documented): `vendors`, `vendor_users`, `vendors_restaurants` (belong to Vendors entity), `ci_sessions` (belongs to Users entity), `nav*`, `permissions_list` (V2 admin UI config)
- **Status**: ✅ Production ready, fully tested, comprehensive review complete

### Vendors & Franchises ✅ COMPLETED & TESTED
- Purpose: Vendor relationships, franchise groupings, and splits/templates.
- V1 Tables: `vendors`, `vendors_restaurants`, `vendor_users`, vendor report files.
- V2 Tables: `vendors`, `francizes`, `vendor_sites`, `vendor_splits`, `vendor_splits_templates`, `vendor_reports`, `vendor_reports_numbers`, `vendor_invoices`.
- **Status**: ✅ Production ready, fully tested, comprehensive review complete


#### ❌ NOT NEEDED -
### Accounting & Reporting - 
- Purpose: Fees, statements, vendor reports, and financial aggregates.
- V1 Tables: `restaurant_fees`, `restaurant_fees_stripe`, `restaurant_charges`, `issued_statements`, `statement_info`, `statement_invoices`, `statement_payments`, `statement_carry_values`, `vendors_reports`.
- V2 Tables: `restaurants_fees`, `restaurants_accounting_fees`, `restaurants_charges`, `statements`, `restaurants_statements`, `vendor_reports`, `vendor_reports_numbers`, `vendor_invoices`, `statement_carry_values`.
- **Status**: Migration not required

### Vendors & Franchises
- Purpose: Vendor relationships, franchise groupings, and splits/templates.
- V1 Tables: `vendors`, `vendors_restaurants`, `vendor_users`, vendor report files.
- V2 Tables: `vendors`, `francizes`, `vendor_sites`, `vendor_splits`, `vendor_splits_templates`, `vendor_reports`, `vendor_reports_numbers`, `vendor_invoices`.

### Devices & Infrastructure
- Purpose: Restaurant tablets and supporting runtime/system metadata.
- V1 Tables: `tablets`, `tablet_orders`, `ci_sessions`, `groups`, `groups_permissions`, `themes`, `theme_*`.
- V2 Tables: `tablets`, `tablet_orders`, `ci_sessions`, `groups`, `groups_permissions`, `phinxlog`.


---

**Total Entities by Status**:
- ✅ Completed & Tested: 6 (Restaurant Management, Service Schedules, Delivery Operations, Users & Access, Menu & Catalog, Marketing & Promotions)
- 🔄 In Progress: 0
- ⏳ Pending: 2 (Vendors & Franchises, Devices & Infrastructure)
- ❌ Not Needed: 4 (Location & Geography, Orders & Checkout, Payments, Accounting & Reporting)

