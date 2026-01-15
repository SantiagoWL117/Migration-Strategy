# Session Summary - January 15, 2026

Compare restaurant_contacts and admin_users and see if we can merge both of them

# Data / Migration Scrapper summary

## V1 Admin Contacts Scraper

**Purpose:** Scrape restaurant admin contact info from V1 CRM and populate `admin_users` table.

**Files Created:**
- `Scrapers/Restaurant Admin Scrapers/V1/v1_admin_contacts_scraper.py`
- `Scrapers/Restaurant Admin Scrapers/V1/run_v1_admin_scraper.py`

**Process:**
1. Login to V1 CRM (`crm.menu.ca`)
2. For each V1 restaurant, navigate to `/account/view/{v1_id}`
3. Parse contact forms to extract: email, contact name, phone
4. Split contact name into `first_name` + `last_name`
5. Create Supabase Auth user (if not exists)
6. Upsert `admin_users` record with `role_id=2` (Restaurant Admin)
7. Link admin to restaurant via `admin_user_restaurants`

**Results:**
| Metric | Count |
|--------|-------|
| V1 Restaurants processed | 132 |
| Admin users created | ~400 |
| Restaurant links | ~1,200 |

---

## V2 Admin Contacts Scraper

**Purpose:** Scrape restaurant admin contact info from V2 CRM for 20 specific restaurants.

**Files Created:**
- `Scrapers/Restaurant Admin Scrapers/V2/v2_admin_contacts_scraper.py`
- `Scrapers/Restaurant Admin Scrapers/V2/run_v2_admin_scraper.py`

**Process:**
1. Login to V2 CRM (`aggregator-admin.menu.ca`)
2. For each V2 restaurant, navigate to `/restaurants/edit/{v2_id}/info`
3. Parse "Owner info" table to extract: name, email, phone
4. Filter out contacts with "test" in email/name
5. Create Supabase Auth user (or link existing)
6. Upsert `admin_users` record with `role_id=2` (Restaurant Admin)
7. Link admin to restaurant via `admin_user_restaurants`

**Results:**
| Metric | Count |
|--------|-------|
| V2 Restaurants processed | 20/20 |
| Admin users created | 30 |
| Restaurant links | 20 |
| With Supabase Auth linked | 17 |

---

## Manual Admin Assignments

For restaurants with no CRM contact info, manual assignments were made:

| Restaurant | V3 ID | Admin Assigned |
|------------|-------|----------------|
| All Out Burger (Barrhaven) | 841 | ID 1060 (Ghandour) |
| All Out Burger (Embrun) | 833 | ID 1060 (Ghandour) |
| Erman Pizza | 211 | ID 1132 (Azad Germavy) |
| Mont Liban Bakery | 205 | ID 1133 (Eli El-salibi) |
| Papa Burger Maloney | 822 | ID 979 |

---

## Remaining Restaurants Without Admin (10)

| V3 ID | Restaurant | City |
|-------|------------|------|
| 837, 126, 840, 92, 821 | Milano (5 locations) | Various |
| 801, 790 | Nachos Loco (2 locations) | Gatineau, Hull |
| 1015, 789 | Poutinerie Québecurds (2 locations) | Gatineau, Hull |
| 820 | Vieux Hull Pizza | Gatineau |

---

## Password Reset Support

**Status:** ✅ Supported via Supabase Auth

| Admin Type | Count | Can Reset Password? |
|------------|-------|---------------------|
| With `auth_user_id` | 160 | ✅ Yes |
| Without `auth_user_id` | 15 | ❌ Need auth user first |

**How it works:**
- `supabase.auth.resetPasswordForEmail(email)` - Sends reset link
- `supabase.auth.updateUser({ password })` - Sets new password

**Admins without auth link (15):**
- 13 V2 admins with real emails (auth user exists, just not linked)
- 2 manual creates with placeholder emails (need real emails)

