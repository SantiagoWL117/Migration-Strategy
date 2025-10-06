## Core Business Entities

This document lists the remaining core business entities that need to be migrated from V1 and V2 of the Menu.ca databases to V3.

**Migration Status Summary**:
- ✅ **Completed**: Restaurant Management, Menu & Catalog, Service Configuration & Schedules
- 🔄 **In Progress**: Users & Access
- ❌ **Not Needed**: Location & Geography (handled differently in V3)

### Delivery Operations
- Purpose: Delivery pricing, delivery partners, and runtime delivery controls.
- V1 Tables: `delivery_info`, `distance_fees`, `delivery_orders`, `quebec_delivery_retries`, `geodispatch_reports`, `geodispatch_retries`, `tookan_fees`.
- V2 Tables: `restaurants_delivery_info`, `restaurants_delivery_fees`, `delivery_company_retries`, `deliveryzone_retries`, `twilio`.
- **Additional V2 Table**: `restaurants_delivery_schedule` (7 rows) - Delivery partner availability for restaurant 1635 (mon-sun, 11am-10pm)

### Orders & Checkout
- Purpose: Order lifecycle, line items, customizations, and order artifacts.
- V1 Tables: `user_orders`, `orders`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `donations`, `over_hundred`.
- V2 Tables: `order_details`, `order_main_items`, `order_sub_items`, `order_sub_items_combo`, `order_pdf`, `tablet_orders`, `browser_list`, `cancel_order_requests`.

### Payments
- Purpose: Customer payment profiles, payment intents/transactions, and providers.
- V1 Tables: `tokens`, `stripe_payments`, `stripe_payment_clients`, `stripe_payments_intents`.
- V2 Tables: `payment_clients`, `payments`, `stripe_payment_clients`, `stripe_payments_intents`.

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


