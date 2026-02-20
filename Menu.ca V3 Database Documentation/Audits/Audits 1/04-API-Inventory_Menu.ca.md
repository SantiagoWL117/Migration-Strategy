# 04 - API Inventory (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database schema + entity documentation + workspace exploration  
**Auditor:** AI (Cursor workspace — Migration Strategy repo + Supabase DB access)

---

## Missing Access

> **I do NOT have access to the application source code (Replit repo).** The REST/GraphQL route files, Express/Fastify handlers, and frontend code are not in this workspace. The inventory below is reconstructed from:
> - Database functions (168 in `menuca_v3`)
> - Supabase Edge Functions found in `supabase/functions/`
> - Entity documentation in `Menu.ca V3/entities/`
> - Handoff docs (e.g., `RESTOZONE_TABLET_API_HANDOFF.md`)
>
> **To complete this section, run this audit in the Replit environment** where the actual application code lives.

---

## A. Supabase Edge Functions (Deployed serverless functions)

Found in `supabase/functions/`:

| Function | Purpose | Notes |
|---|---|---|
| `calculate-vendor-commission` | Calculate commission for vendor reports | Part of commission workflow |
| `complete-commission-workflow` | End-to-end commission report generation | Orchestrator function |
| `get-commission-preview` | Preview commission calculations before finalizing | Read-only |
| `toggle-online-ordering` | Enable/disable online ordering for a restaurant | Critical operational toggle |
| `check-restaurant-availability` | Check if restaurant is currently accepting orders | Used by frontend before checkout |
| `mcp-proxy` | MCP proxy for AI tool access | Internal tooling |

---

## B. Database Functions as API Surface (168 functions)

Supabase exposes PostgreSQL functions as RPC endpoints via PostgREST. These are the **actual API surface** for the app.

### Order Lifecycle Functions (CRITICAL)

| Function | Return | Purpose | DB Tables Touched | Side Effects |
|---|---|---|---|---|
| `create_order()` | record | Create new order | orders, order_items, order_status_history | Triggers status logging, webhook |
| `update_order_status()` | record | Transition order state | orders, order_status_history | Trigger: log_order_status_change |
| `cancel_order()` | record | Cancel order (admin/system) | orders, order_status_history | Sets cancelled_at |
| `cancel_customer_order()` | jsonb | Customer-initiated cancel | orders | Validates cancellation policy |
| `get_order_details()` | record | Fetch single order | orders, order_items | Read-only |
| `get_restaurant_orders()` | record | Fetch orders for restaurant | orders | Read-only (RLS scoped) |
| `get_customer_order_history()` | record | Fetch customer's past orders | orders | Read-only |
| `get_cancellation_policy()` | jsonb | Return cancellation rules | orders | Read-only |
| `tablet_update_order_status()` | record | POS device status update | orders, order_status_history | Device acknowledgment |
| `tablet_get_valid_order_ids()` | bigint | Get pending orders for tablet | orders | Read-only |

### Payment Functions

| Function | Return | Purpose |
|---|---|---|
| `calculate_order_total()` | record | Compute subtotal + tax + fees |
| `calculate_order_taxes()` | jsonb | Tax breakdown by province |
| `check_order_eligibility()` | record | Validate order before payment |

### Menu Functions

| Function | Return | Purpose |
|---|---|---|
| `get_restaurant_menu()` | jsonb | Fetch full menu (live query) |
| `get_restaurant_menu_cached()` | jsonb | Fetch from menu cache |
| `rebuild_menu_cache()` | void | Regenerate cached menu JSON |
| `rebuild_all_menu_caches()` | record | Rebuild all restaurant caches |
| `invalidate_menu_cache()` | void | Mark cache stale |
| `get_dish_availability()` | jsonb | Check dish availability |
| `update_dish_availability()` | jsonb | Toggle dish available/sold out |

### Restaurant Functions

| Function | Return | Purpose |
|---|---|---|
| `get_restaurant_by_slug()` | record | Lookup by URL slug |
| `get_restaurant_config()` | record | Full config for frontend |
| `get_restaurant_availability()` | record | Open/closed + schedule |
| `get_restaurant_hours()` | record | Weekly schedule |
| `is_restaurant_open_now()` | boolean | Real-time open check |
| `can_accept_orders()` | boolean | Ordering eligibility check |
| `toggle_online_ordering()` | record | Enable/disable ordering |
| `search_restaurants()` | record | Text search |
| `find_nearby_restaurants()` | record | Geo proximity search |
| `get_restaurants_near_location()` | record | Location-based discovery |
| `get_restaurants_by_cuisine()` | record | Filter by cuisine type |
| `get_restaurants_by_tag()` | record | Filter by tags |

### Delivery Functions

| Function | Return | Purpose |
|---|---|---|
| `tablet_get_delivery_config()` | record | Delivery settings for POS |
| `tablet_update_delivery_enabled()` | record | Toggle delivery from tablet |
| `toggle_delivery_zone_status()` | boolean | Enable/disable delivery zone |
| `soft_delete_delivery_zone()` | boolean | Soft delete zone |
| `restore_delivery_zone()` | boolean | Restore deleted zone |

### Promotions & Coupons

| Function | Return | Purpose |
|---|---|---|
| `validate_coupon()` | record | Validate coupon code |
| `apply_coupon_to_order()` | record | Apply coupon discount |
| `redeem_coupon()` | bigint | Record coupon usage |
| `auto_apply_best_deal()` | record | Find best available deal |
| `validate_deal_eligibility()` | record | Check deal conditions |
| `calculate_deal_discount()` | record | Compute discount amount |
| `create_flash_sale()` | record | Create time-limited deal |
| `claim_flash_sale_slot()` | record | Customer claims flash deal |
| `get_active_deals()` | record | Active deals for restaurant |

### User & Auth Functions

| Function | Return | Purpose |
|---|---|---|
| `get_user_profile()` | record | Current user profile |
| `get_user_addresses()` | record | User's saved addresses |
| `toggle_favorite_restaurant()` | record | Add/remove favorite |
| `get_favorite_restaurants()` | record | User's favorites list |

### Admin Functions

| Function | Return | Purpose |
|---|---|---|
| `get_admin_profile()` | record | Admin user profile |
| `get_admin_restaurants()` | record | Restaurants admin can access |
| `check_admin_restaurant_access()` | boolean | Authorization check |
| `current_admin_restaurant_ids()` | bigint | List of accessible restaurant IDs |
| `assign_restaurants_to_admin()` | record | Grant restaurant access |

### Commission & Vendor Functions

| Function | Return | Purpose |
|---|---|---|
| `calculate_platform_commission()` | record | Commission per order |
| `prepare_commission_calculation()` | jsonb | Pre-calculate for preview |
| `generate_platform_commission_report()` | uuid | Generate weekly report |
| `get_vendor_locations()` | record | Vendor's assigned restaurants |
| `add_restaurant_to_vendor()` | uuid | Assign restaurant to vendor |
| `create_vendor()` | uuid | New vendor account |
| `get_all_vendors()` | record | List all vendors |

### Franchise Functions

| Function | Return | Purpose |
|---|---|---|
| `create_franchise_parent()` | record | Create franchise group |
| `convert_to_franchise()` | record | Convert restaurant to franchise |
| `batch_link_franchise_children()` | record | Bulk link locations |
| `compare_franchise_locations()` | record | Compare menu/settings across locations |
| `bulk_update_franchise_feature()` | integer | Push settings to all locations |
| `get_franchise_analytics()` | record | Cross-location analytics |

### Device/Tablet Functions

| Function | Return | Purpose |
|---|---|---|
| `register_device()` | record | Register POS tablet |
| `deactivate_device()` | boolean | Deactivate device |
| `restore_device()` | boolean | Reactivate device |
| `get_restaurant_devices()` | record | List devices for restaurant |
| `cleanup_expired_device_sessions()` | integer | Session cleanup |

### Onboarding Functions

| Function | Return | Purpose |
|---|---|---|
| `create_restaurant_onboarding()` | record | Initialize onboarding flow |
| `complete_onboarding_and_activate()` | record | Finalize and activate restaurant |
| `get_onboarding_status()` | record | Current onboarding step |
| `get_onboarding_summary()` | record | Progress overview |
| `add_menu_item_onboarding()` | record | Add dish during onboarding |
| `add_restaurant_location_onboarding()` | record | Set location during onboarding |
| `apply_schedule_template_onboarding()` | record | Apply schedule template |
| `copy_franchise_menu_onboarding()` | record | Copy menu from franchise parent |

### Soft Delete / Restore Functions

| Function | Return | Purpose |
|---|---|---|
| `soft_delete_record()` | record | Generic soft delete |
| `restore_deleted_record()` | record | Generic restore |
| `soft_delete_dish()` | jsonb | Soft delete dish + invalidate cache |
| `restore_dish()` | jsonb | Restore dish + invalidate cache |
| `soft_delete_deal()` / `restore_deal()` | record | Deal lifecycle |
| `soft_delete_coupon()` / `restore_coupon()` | record | Coupon lifecycle |
| `soft_delete_schedule()` / `restore_schedule()` | boolean | Schedule lifecycle |
| `soft_delete_device()` / `restore_device()` | boolean | Device lifecycle |

---

## C. Webhook Endpoints

### Stripe Webhooks
- **Table:** `stripe_webhook_events` stores all incoming events
- **Event types observed:** `payment_intent.succeeded`, `payment_intent.payment_failed`, `charge.refunded`
- **Volume:** 8,012 total events (7,616 succeeded, 334 failed, 62 refunds)
- **Processing:** `processed` boolean flag; all 8,012 are marked processed
- **Idempotency:** `stripe_event_id` column (unique) prevents duplicate processing
- **Signature verification:** UNKNOWN (requires app code access)

### Twilio Webhooks
- **Table:** `restaurant_twilio_config` (15 restaurants configured)
- **Status history shows:** `twilio_fallback_call` (25), `twilio_fallback_confirmed` (6), `twilio_fallback_max_reached` (5)
- **Purpose:** Phone call fallback when restaurant device doesn't acknowledge order

---

## D. Known API Gaps (Need App Code Access)

| What's Missing | Where to Find It | Why It Matters |
|---|---|---|
| REST endpoint routes | Replit repo: `server/`, `api/`, `routes/` | Can't map HTTP methods/paths to handlers |
| GraphQL schema/resolvers | Replit repo | Don't know if GraphQL is used |
| Auth middleware | Replit repo | Can't verify JWT/session handling |
| Stripe checkout session creation | Replit repo | Can't trace payment flow initiation |
| Stripe webhook handler code | Replit repo | Can't verify signature verification or idempotency logic |
| Rate limiting implementation | App code | `rate_limits` table exists but enforcement code unknown |
| WebSocket/real-time subscriptions | Replit/Supabase Realtime config | Tablet real-time order updates |
| Error handling middleware | Replit repo | Don't know how errors are caught and logged |
| CORS configuration | Replit repo | Public-facing API security |

---

## E. RLS Policy Coverage

**55 tables have Row Level Security enabled.** Key tables covered:
- `orders` - Scoped to restaurant or customer
- `restaurants` - Public read, admin write
- `dishes`, `courses`, `modifiers` - Restaurant-scoped
- `admin_users`, `admin_user_restaurants` - Auth-scoped
- `users` - Self-access only
- `payment_transactions` - Restricted access
- `promotional_deals`, `promotional_coupons` - Restaurant-scoped

**Tables WITHOUT RLS (potential risk):**
- `audit_log` partitions
- `admin_audit_log`
- `admin_roles`
- Backup tables (`courses_backup_test_*`, `dishes_backup_test_*`)
- `commission_weekly_snapshots`
- `email_queue`
- `failed_jobs`
- Various combo tables
