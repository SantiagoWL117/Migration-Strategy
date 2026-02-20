# Entity Documentation Index

Quick navigation for the `menuca_v3` schema documentation. Each entity document covers tables, SQL functions, indexes, RLS policies, triggers, and data integrity issues.

---

## By Entity

| # | Entity | File | Tables | Lines |
|---|--------|------|--------|-------|
| 01 | [Restaurant](./01-restaurant-entity.md) | `01-restaurant-entity.md` | 17 | 719 |
| 02 | [Delivery Zones](./02-delivery-zones-entity.md) | `02-delivery-zones-entity.md` | 8 | 626 |
| 03 | [Menu Management](./03-menu-management-entity.md) | `03-menu-management-entity.md` | 18 | 677 |
| 04 | [Order Management](./04-order-management-entity.md) | `04-order-management-entity.md` | 12 | 642 |
| 05 | [User](./05-user-entity.md) | `05-user-entity.md` | 4 | 386 |
| 06 | [Admin](./06-admin-entity.md) | `06-admin-entity.md` | 4 | 426 |
| 07 | [Marketing](./07-marketing-entity.md) | `07-marketing-entity.md` | 11 | 649 |
| 08 | [Geography](./08-geography-entity.md) | `08-geography-entity.md` | 3 | 162 |
| 09 | [Vendor](./09-vendor-entity.md) | `09-vendor-entity.md` | 5 | 418 |
| 10 | [System](./10-system-entity.md) | `10-system-entity.md` | 6 | 290 |

---

## By Table Name

Find which entity document covers a specific table.

### 01 — Restaurant
`restaurants` · `restaurant_locations` · `restaurant_domains` · `restaurant_subdomains` · `restaurant_onboarding` · `restaurant_status_history` · `restaurant_twilio_config` · `restaurant_analytics_configs` · `restaurant_commission_configs` · `restaurant_payment_options` · `restaurant_cuisines` · `restaurant_tag_assignments` · `restaurant_tag_associations` · `restaurant_tags` · `restaurant_reviews` · `restaurant_ownership_groups` · `restaurant_group_memberships`

### 02 — Delivery Zones
`restaurant_schedules` · `restaurant_special_schedules` · `restaurant_delivery_areas` · `delivery_and_pickup_configs` · `restaurant_delivery_companies` · `restaurant_distance_based_delivery_fees` · `delivery_providers` · `delivery_company_emails`

### 03 — Menu Management
`courses` · `dishes` · `dish_prices` · `dish_availability` · `modifier_groups` · `dish_modifier_groups` · `modifier_group_details` · `modifiers` · `modifier_prices` · `modifier_size_variants` · `dish_size_variants` · `combo_groups` · `dish_combo_groups` · `combo_group_sections` · `combo_modifier_groups` · `combo_modifiers` · `combo_modifier_prices` · `restaurant_menu_cache`

### 04 — Order Management
`orders` (partitioned) · `order_items` (partitioned) · `order_status_history` · `order_refunds` · `payment_transactions` · `restaurant_payment_options` · `user_payment_methods` · `cart_sessions` · `restaurant_commission_configs` · `platform_commission_reports` · `commission_weekly_snapshots` · `vendor_commission_reports`

### 05 — User
`users` · `user_delivery_addresses` · `user_favorite_restaurants` · `user_payment_methods`

### 06 — Admin
`admin_users` · `admin_user_restaurants` · `admin_roles` · `admin_audit_log`

### 07 — Marketing
`promotional_deals` · `promotional_coupons` · `coupon_usage_log` · `promotion_campaigns` · `promotion_codes` · `promotion_targets` · `promotion_tiers` · `promotion_redemptions` · `promotion_templates` · `marketing_tags` · `restaurant_tag_associations`

### 08 — Geography
`cities` · `provinces` · `cuisine_types`

### 09 — Vendor
`vendors` · `vendor_restaurants` · `vendor_commission_reports` · `vendor_statement_numbers` · `vendor_configs`

### 10 — System
`audit_log` (partitioned) · `autologin_tokens` · `password_reset_tokens` · `cart_sessions` · `payment_transactions` · `translation_lookup`

---

## By Topic

| Looking for... | Go to |
|----------------|-------|
| Restaurant profiles, hours, config | [01-restaurant](./01-restaurant-entity.md) |
| Delivery areas, fees, schedules | [02-delivery-zones](./02-delivery-zones-entity.md) |
| Menu items, dishes, modifiers, combos | [03-menu-management](./03-menu-management-entity.md) |
| Menu caching (JSONB) | [03-menu-management](./03-menu-management-entity.md) |
| Orders, order items, status tracking | [04-order-management](./04-order-management-entity.md) |
| Commissions, Stripe payments | [04-order-management](./04-order-management-entity.md) |
| Customer accounts, addresses, favorites | [05-user](./05-user-entity.md) |
| Auth flow (Supabase Auth ↔ users) | [05-user](./05-user-entity.md) |
| Admin users, roles, permissions | [06-admin](./06-admin-entity.md) |
| Admin audit log | [06-admin](./06-admin-entity.md) |
| Promotions, deals, coupons | [07-marketing](./07-marketing-entity.md) |
| Tags (restaurant categorization) | [07-marketing](./07-marketing-entity.md) |
| Cities, provinces, cuisine types | [08-geography](./08-geography-entity.md) |
| Vendor management, B2B billing | [09-vendor](./09-vendor-entity.md) |
| Audit log (partitioned) | [10-system](./10-system-entity.md) |
| Auth tokens, password resets | [10-system](./10-system-entity.md) |
| Cart sessions | [10-system](./10-system-entity.md) |
| Bilingual translations | [10-system](./10-system-entity.md) |
