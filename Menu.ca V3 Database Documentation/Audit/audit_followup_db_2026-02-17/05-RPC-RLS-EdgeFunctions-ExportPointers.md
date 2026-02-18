# 05 - RPC / RLS / Edge Functions Export Pointers

**Date:** 2026-02-17  
**Schema:** menuca_v3

---

## 5.1 RPC Functions Touching Critical Paths

### Order Lifecycle (11 functions)

| Function | Purpose | Invocation |
|---|---|---|
| `create_order()` | Create new order row + items | Frontend -> Supabase RPC |
| `update_order_status()` | Transition order status | Admin/system RPC |
| `cancel_order()` | Admin-initiated cancel | Admin RPC |
| `cancel_customer_order()` | Customer-initiated cancel | Customer RPC (RLS-scoped) |
| `get_order_details()` | Fetch single order | Read-only RPC |
| `get_restaurant_orders()` | Fetch orders for restaurant | Admin RPC (restaurant-scoped) |
| `get_customer_order_history()` | Fetch customer orders | Customer RPC (user-scoped) |
| `get_cancellation_policy()` | Return cancellation rules | Read-only RPC |
| `check_order_eligibility()` | Validate before payment | Frontend RPC |
| `log_order_status_change()` | TRIGGER: auto-log status transitions | Trigger on orders UPDATE |
| `prevent_order_items_modification()` | TRIGGER: prevent item edits after creation | Trigger on order_items |

### Payment (3 functions)

| Function | Purpose | Invocation |
|---|---|---|
| `calculate_order_total()` | Compute subtotal + tax + fees + discounts | Frontend RPC |
| `calculate_order_taxes()` | Province-based tax calculation | Called by calculate_order_total |
| `apply_coupon_to_order()` | Apply coupon discount to order | Frontend RPC |

### Tablet/Device Operations (4 functions)

| Function | Purpose | Invocation |
|---|---|---|
| `tablet_update_order_status()` | Device updates order status (ACK, preparing, ready) | Tablet app RPC |
| `tablet_get_valid_order_ids()` | Get pending order IDs for polling | Tablet app RPC |
| `tablet_get_delivery_config()` | Get delivery settings | Tablet app RPC |
| `tablet_update_delivery_enabled()` | Toggle delivery from tablet | Tablet app RPC |

### Restaurant/Domain Mapping (7 functions)

| Function | Purpose | Invocation |
|---|---|---|
| `get_restaurant_by_slug()` | URL slug -> restaurant record | Frontend page load |
| `get_restaurant_config()` | Full config for frontend rendering | Frontend RPC |
| `get_subdomain_mapping()` | Custom domain -> restaurant | DNS/routing |
| `get_all_subdomain_mappings()` | All domain mappings | System/cron |
| `get_domain_verification_status()` | Domain SSL/verification status | Admin RPC |
| `mark_domain_verified()` | Set domain as verified | System RPC |
| `toggle_online_ordering()` | Enable/disable ordering | Admin RPC |

### Restaurant Availability (3 functions)

| Function | Purpose | Invocation |
|---|---|---|
| `is_restaurant_open_now()` | Boolean: is restaurant open? | Frontend check |
| `can_accept_orders()` | Boolean: can restaurant take orders now? | Frontend pre-checkout |
| `get_restaurant_availability()` | Full availability details | Frontend RPC |

---

## 5.2 RLS Policies

### Policy Coverage Summary

**54 tables have RLS enabled** with policies defined. **1 table has RLS enabled but 0 policies** (promotion_templates -- effectively blocks all access).

### Policy Counts by Table (Top 20)

| Table | Policy Count |
|---|---|
| user_payment_methods | 5 |
| user_delivery_addresses | 5 |
| user_addresses | 5 |
| orders | 4 |
| user_favorite_restaurants | 4 |
| users | 4 |
| restaurants | 3 |
| delivery_and_pickup_configs | 3 |
| restaurant_delivery_areas | 3 |
| restaurant_schedules | 3 |
| restaurant_distance_based_delivery_fees | 3 |
| restaurant_delivery_companies | 3 |
| delivery_company_emails | 3 |
| restaurant_special_schedules | 3 |
| promotional_coupons | 2 |
| promotional_deals | 2 |
| order_items | 2 |
| order_status_history | 2 |
| platform_commission_reports | 2 |
| devices | 1 |

### Critical Table Policies (Exported)

#### `orders` (4 policies)

| Policy | Role | Command | Rule |
|---|---|---|---|
| `anon_can_read_orders` | anon | SELECT | `true` (any anon user can read all orders) |
| `orders_customer_select_own` | authenticated | SELECT | user_id matches auth.uid() via users table |
| `orders_customer_update_own` | authenticated | UPDATE | user_id matches auth.uid() via users table |
| `orders_service_role_all` | service_role | ALL | `true` |

**SECURITY NOTE:** `anon_can_read_orders` allows ANY unauthenticated request to read ALL orders. This is a potential data exposure risk if the Supabase anon key is known (it's public by design in Supabase).

#### `restaurants` (3 policies)

| Policy | Role | Command | Rule |
|---|---|---|---|
| `Enable public read access` | public | SELECT | `true` |
| `admin_crud_own_restaurants` | authenticated | ALL | id IN current_admin_restaurant_ids() |
| `restaurants_service_role_all` | service_role | ALL | `true` |

#### `users` (4 policies)

| Policy | Role | Command | Rule |
|---|---|---|---|
| `users_insert_own` | authenticated | INSERT | auth_user_id = auth.uid() |
| `users_select_own` | authenticated | SELECT | auth_user_id = auth.uid() |
| `users_update_own` | authenticated | UPDATE | auth_user_id = auth.uid() |
| `users_service_role_all` | service_role | ALL | `true` |

#### `admin_users` (1 policy)

| Policy | Role | Command | Rule |
|---|---|---|---|
| `admin_users_service_role_all` | service_role | ALL | `true` |

**NOTE:** No authenticated-role policy for admin_users. Admin operations must go through service_role.

### Tables WITHOUT RLS (Notable)

| Table | Contains Sensitive Data? |
|---|---|
| audit_log (+ monthly partitions) | YES - full change history with PII |
| admin_audit_log | Possibly |
| admin_roles | No |
| email_queue | YES - recipient emails |
| failed_jobs | Possibly |
| commission_weekly_snapshots | Financial data |
| Backup tables (courses_backup_test_*) | Copies of production data |

### How to Export Full RLS Policies

For engineering to get the complete RLS export:

```sql
-- Full export of all RLS policies with complete expressions
SELECT schemaname, tablename, policyname, permissive, roles, cmd,
    pg_get_expr(polqual, polrelid) AS using_expression,
    pg_get_expr(polwithcheck, polrelid) AS with_check_expression
FROM pg_policy
JOIN pg_class ON pg_class.oid = polrelid
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE nspname = 'menuca_v3'
ORDER BY tablename, policyname;
```

Or via Supabase UI: Dashboard -> Authentication -> Policies -> Select schema `menuca_v3`.

---

## 5.3 Edge Functions

35 Edge Functions found in the workspace `supabase/functions/`:

### Onboarding & Restaurant Management

| Function | Purpose |
|---|---|
| `create-restaurant-onboarding` | Initialize onboarding flow |
| `complete-restaurant-onboarding` | Finalize and activate |
| `get-restaurant-onboarding` | Get onboarding status |
| `get-onboarding-dashboard` | Admin dashboard view |
| `update-onboarding-step` | Update onboarding progress |
| `update-restaurant-status` | Change restaurant status |
| `get-operational-restaurants` | List operational restaurants |

### Ordering & Availability

| Function | Purpose |
|---|---|
| `check-restaurant-availability` | Is restaurant accepting orders? |
| `toggle-online-ordering` | Enable/disable ordering |
| `search-restaurants` | Restaurant search |

### Commission & Vendor

| Function | Purpose |
|---|---|
| `calculate-vendor-commission` | Calculate commission |
| `complete-commission-workflow` | End-to-end commission report |
| `generate-commission-reports` | Generate reports |
| `generate-commission-pdfs` | PDF generation |
| `get-commission-preview` | Preview before finalizing |
| `send-commission-reports` | Email reports |

### Franchise

| Function | Purpose |
|---|---|
| `create-franchise-parent` | Create franchise group |
| `convert-restaurant-to-franchise` | Convert to franchise |
| `copy-franchise-menu` | Copy menu across locations |
| `bulk-update-franchise-feature` | Push settings to all locations |

### Admin & Access

| Function | Purpose |
|---|---|
| `create-admin-user` | Create admin account |
| `create-admin-user-v2` | Updated admin creation |
| `assign-admin-restaurants` | Grant restaurant access |

### Data Management

| Function | Purpose |
|---|---|
| `soft-delete-record` | Generic soft delete |
| `restore-deleted-record` | Generic restore |
| `get-deletion-audit-trail` | View deletion history |
| `delete-delivery-zone` | Delete delivery zone |
| `toggle-zone-status` | Enable/disable zone |

### Domain & DNS

| Function | Purpose |
|---|---|
| `verify-single-domain` | Verify one domain |
| `verify-domains-cron` | Cron: verify all domains |

### Other

| Function | Purpose |
|---|---|
| `add-restaurant-cuisine` | Add cuisine type |
| `add-restaurant-tag` | Add tag |
| `apply-schedule-template` | Apply schedule template |
| `mcp-proxy` | AI tool proxy |
| `test-simple` | Test function |

### Notable Gaps (No Edge Functions For)

- **Payment/checkout flow** -- handled by app code + Stripe, not Edge Functions
- **Order creation/management** -- handled by RPC functions, not Edge Functions
- **Webhook processing** -- handled by app code, not Edge Functions
- **Analytics/event tracking** -- no Edge Functions for this
