# 04 - Environments, Deployment & Rollback (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database schema, workspace config files, entity documentation  
**Status:** PARTIAL — No access to CI/CD pipelines or Replit deployment config

---

## Missing Access

> I do not have access to:
> - Replit deployment configuration
> - GitHub Actions / CI/CD pipeline definitions
> - Production server configs
> - Staging environment details
> - Domain/DNS configuration (beyond what's in DB)
>
> **To complete this section:** Run audit in Replit environment and check GitHub repo settings.

---

## Section D1: Environments Map

### What We Know

| Component | Details | Evidence |
|---|---|---|
| **Database** | Supabase PostgreSQL | Host: `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Schema** | `menuca_v3` | 150 tables/views, 168 functions |
| **App hosting** | Replit (confirmed) | Workspace references, `menuv3.replit.app` URL used in reviews |
| **Edge Functions** | Supabase Edge Functions | `supabase/functions/` directory in workspace |
| **Payment** | Stripe | Webhook events table, `stripe_payment_intent_id` on orders |
| **Phone fallback** | Twilio | `restaurant_twilio_config` table (15 configs) |
| **Delivery integration** | RestoZone, Tookan, DoorDash, Uber | `delivery_providers` table |

### Environments (Inferred)

| Environment | URL | DB | Stripe Mode | Evidence |
|---|---|---|---|---|
| **Production** | `menuv3.replit.app` + custom domains | Supabase (above) | **97% TEST / 3% LIVE** | `payment_mode` column |
| **Staging** | UNKNOWN | UNKNOWN | UNKNOWN | No evidence found |
| **Local dev** | UNKNOWN | UNKNOWN | UNKNOWN | No evidence found |

### Custom Domains

```sql
SELECT COUNT(*) as total_domains,
    COUNT(*) FILTER (WHERE is_verified = true) as verified,
    COUNT(*) FILTER (WHERE ssl_status = 'active') as ssl_active
FROM menuca_v3.restaurant_domains;
```

Domain management is tracked in `restaurant_domains` and `restaurant_subdomains` tables.

### CRITICAL Finding: No Environment Separation

**180 out of 186 restaurants have `payment_mode = 'test'`**. This means the "production" environment is running with test payment processing for almost all restaurants. There is no evidence of a separate staging environment.

---

## Section D2: Deployment Procedure

### What We Know

| Aspect | Details | Evidence |
|---|---|---|
| **Code hosting** | GitHub (assumed) + Replit | Git repo in workspace |
| **Branch strategy** | `main` branch observed | Git status shows `main` |
| **Build process** | UNKNOWN | No build configs in this workspace |
| **Deploy trigger** | UNKNOWN | Likely Replit auto-deploy on push |
| **Who can deploy** | Brian (primary dev), Santiago (DB/data) | Conversation context |
| **Deploy time** | UNKNOWN | — |

### Database Deployments

| Method | Details |
|---|---|
| Schema changes | Direct SQL against Supabase (no migration tool observed) |
| Function updates | Direct `CREATE OR REPLACE FUNCTION` |
| Edge Functions | Supabase CLI deploy (see `supabase/functions/DEPLOYMENT_GUIDE.md`) |
| Data migrations | Manual SQL scripts (no `data_migrations` table exists despite being documented) |

### Edge Function Deployment (Documented)

From `supabase/functions/DEPLOYMENT_GUIDE.md`:
```bash
supabase functions deploy <function-name> --project-ref nthpbtdjhhnwfxqsxbvy
```

---

## Section D3: Rollback & Kill-Switches

### Current State: MINIMAL

| Capability | Exists? | Details |
|---|---|---|
| **Code rollback** | PARTIAL | Git revert + Replit redeploy (manual) |
| **Database rollback** | NO | No migration versioning, no down migrations |
| **Feature flags** | NO | `feature_flags` table documented but never created |
| **Kill-switch: ordering** | YES | `toggle_online_ordering()` function per restaurant |
| **Kill-switch: delivery** | YES | `tablet_update_delivery_enabled()` per restaurant |
| **Kill-switch: payment capture** | NO | No evidence of payment pause capability |
| **Kill-switch: global** | NO | No global ordering disable |
| **Canary/gradual rollout** | NO | No percentage-based rollout mechanism |
| **Safe mode** | NO | No minimal ordering path defined |

### Available Emergency Actions (Database-Level)

```sql
-- Disable ordering for a specific restaurant
SELECT menuca_v3.toggle_online_ordering(restaurant_id, false);

-- Disable delivery for a restaurant
UPDATE menuca_v3.delivery_and_pickup_configs
SET has_delivery_enabled = false
WHERE restaurant_id = <id>;

-- Disable ALL ordering (nuclear option)
UPDATE menuca_v3.restaurants SET online_ordering_enabled = false;

-- Switch payment mode to test (stop real charges)
UPDATE menuca_v3.delivery_and_pickup_configs SET payment_mode = 'test';
```

### Proposed Minimum Viable Rollback Plan

1. **Create `feature_flags` table** (as documented in system entity)
2. **Add global kill-switch flags:**
   - `ordering_enabled` (global)
   - `payments_enabled` (global)
   - `delivery_dispatch_enabled` (global)
3. **Add per-restaurant override flags:**
   - `restaurant_ids` array on each flag
4. **Implement in app:** Check flags before critical operations
5. **Add down-migration scripts** for every schema change

---

## Supabase-Specific Considerations

| Feature | Status | Notes |
|---|---|---|
| Point-in-time recovery | AVAILABLE (Supabase Pro) | Can restore DB to any point in last 7 days |
| Database backups | Automatic (Supabase) | Daily backups |
| Edge Function versioning | NO | Functions overwrite on deploy |
| RLS as safety net | YES | 55 tables have RLS — prevents unauthorized data access even if app is compromised |
| Realtime subscriptions | UNKNOWN | May be used for tablet order updates |
