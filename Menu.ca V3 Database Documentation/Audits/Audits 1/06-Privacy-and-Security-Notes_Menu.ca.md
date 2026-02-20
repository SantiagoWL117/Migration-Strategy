# 06 - Privacy and Security Notes (Menu.ca V3)

**Audit Date:** 2026-02-17  
**Source:** Database schema analysis  
**Status:** PARTIAL -- Database-level security only, no app-level access

---

## Missing Access

I cannot inspect:
- Application-level auth middleware (JWT verification, session handling)
- CORS configuration
- API rate limiting enforcement (beyond rate_limits table)
- Logging configuration (what gets logged, PII in logs)
- Stripe webhook signature verification code
- Network/infrastructure security

To complete: Run audit in Replit environment with full app code access.

---

## Section H: PII Handling

### Where PII is Stored

| Table | PII Fields | Access Control |
|---|---|---|
| users | email, first_name, last_name, phone | RLS enabled |
| user_addresses | Full addresses | RLS enabled |
| user_delivery_addresses | Full addresses | RLS enabled |
| user_payment_methods | stripe_customer_id (no raw card data) | RLS enabled |
| orders | customer_name, customer_phone, customer_email, delivery_address | RLS enabled |
| orders | guest_email, guest_name, guest_phone | RLS enabled |
| admin_users | email, first_name, last_name, phone | RLS enabled |
| password_reset_tokens | Token values | RLS enabled |
| autologin_tokens | Token values | RLS enabled |
| email_queue | recipient_email, recipient_name | NO RLS |

### PII Risk Assessment

| Risk | Level | Notes |
|---|---|---|
| Raw card data in DB | LOW | Stripe handles payment -- only stripe IDs stored |
| Customer addresses in orders | MEDIUM | Full delivery addresses stored as text, not encrypted |
| PII in audit_log | HIGH | audit_log stores old_data and new_data as JSONB with full records. Has NO RLS. |
| PII in email_queue | MEDIUM | email_queue has NO RLS -- recipient emails visible to anyone with DB access |
| Guest order PII | MEDIUM | Guest checkout stores email/name/phone directly on order |

---

## Access Controls

### Database-Level (RLS)

55 tables have Row Level Security enabled.

### Tables WITHOUT RLS (Potential Risk)

| Table | Risk | Recommendation |
|---|---|---|
| audit_log (plus partitions) | HIGH -- contains full change history with PII | Add RLS or restrict access |
| admin_audit_log | MEDIUM | Add RLS |
| email_queue | MEDIUM -- contains recipient emails | Add RLS |
| admin_roles | LOW -- no PII | OK as-is |
| failed_jobs | LOW -- may contain error context | Review for PII in payloads |
| commission_weekly_snapshots | LOW -- financial data | Consider RLS |
| Backup tables (courses_backup_test etc) | MEDIUM -- copies of production data | Delete or restrict |

### Auth Architecture

| Component | Implementation | Evidence |
|---|---|---|
| Auth provider | Supabase Auth | auth_user_id (uuid) columns on users and admin_users |
| Session type | Supabase JWT via auth.uid() | Standard Supabase pattern |
| Admin roles | 2 roles: Super Admin, Restaurant Admin | admin_roles table |
| Role enforcement | RLS policies plus check_admin_restaurant_access() | DB-level |
| Customer auth | Supabase Auth plus autologin tokens | autologin_tokens table |
| Password reset | Token-based | password_reset_tokens table |

---

## Payment Security

| Aspect | Status | Details |
|---|---|---|
| Payment processing | Stripe | Industry-standard PCI compliance |
| Card data storage | NONE | Only Stripe IDs stored in DB |
| Webhook signature verification | UNKNOWN | Need app code to verify |
| Webhook idempotency | YES | stripe_event_id unique constraint |
| Test vs Live mode | MIXED | 180/186 restaurants on test mode |
| Refund handling | Stripe-side | order_refunds table records amounts |

### CRITICAL: Test/Live Payment Mode Confusion

180 out of 186 restaurants on payment_mode = test. 57 of 137 orders flagged is_test_order = true. The remaining 80 real orders need verification against Stripe dashboard.

---

## Recommendations

1. Add RLS to audit_log -- contains full change history including PII
2. Add RLS to email_queue -- contains recipient emails
3. Delete backup tables -- courses_backup_test and dishes_backup_test contain production data copies
4. Verify webhook signature checking in app code
5. Audit autologin tokens -- verify expiration and single-use enforcement
6. Review audit_log retention -- PII in old records should be purged or anonymized
7. Resolve test/live confusion -- clear separation needed
