# Session Summary - January 15, 2026

## Admin Entity Cleanup

### 1. Simplified Admin Roles
**Before:** 6 roles (Super Admin, Manager, Support, Restaurant Manager, Staff, plus unused)
**After:** 2 roles only

| ID | Role | Description |
|----|------|-------------|
| 1 | Super Admin | Full platform access, can create all roles |
| 2 | Restaurant Admin | Full CRUD on menu items for assigned restaurants |

**Restaurant Admin Permissions:**
```json
{
  "page_access": ["menu", "dishes", "modifiers", "combos", "courses", "prices", "orders", "deals"],
  "restaurant_access": ["assigned"],
  "crud_permissions": {
    "dishes": ["create", "read", "update", "delete"],
    "dish_prices": ["create", "read", "update", "delete"],
    "modifier_groups": ["create", "read", "update", "delete"],
    "modifiers": ["create", "read", "update", "delete"],
    "modifier_prices": ["create", "read", "update", "delete"],
    "combo_groups": ["create", "read", "update", "delete"],
    "combo_group_sections": ["create", "read", "update", "delete"],
    "courses": ["create", "read", "update", "delete"],
    "orders": ["read", "update"]
  }
}
```

### 2. Removed Redundant Auth Columns from `admin_users`
Dropped columns (all were unused - 0 records):
- `password_hash`
- `mfa_enabled`
- `mfa_secret`
- `mfa_backup_codes`

**Reason:** Authentication is handled by Supabase Auth (`auth.users`), not custom columns. All 159 admin users have `auth_user_id` linking to `auth.users`.

### 3. Created Brian Lapp Admin Account
| Field | Value |
|-------|-------|
| Admin ID | 1099 |
| Email | brian+1@worklocal.ca |
| Name | Brian Lapp |
| Phone | 6138663429 |
| Role | Super Admin (role_id: 1) |
| Auth User ID | 48fdcce4-30ab-46de-a9cb-3171edbcba31 |
| Password | WL!2w3e4r5t |

---

## Database Performance Crisis Resolution

### Problem
At ~12:40pm, database hit 100% CPU with high IOwait. Root cause: **27MB of JSONB menu cache stored directly in `restaurants` table**, causing PostgREST `SELECT *` queries to decompress massive TOAST data on every request.

### Fixes Applied

#### 1. VACUUM ANALYZE
Ran on `restaurants` and all audit log partitions to update statistics.

#### 2. Audit Log Indexes (10 indexes created)
```sql
-- For each partition (2025_11, 2025_12, 2026_01, 2026_02, 2026_03):
idx_audit_log_YYYY_MM_created (created_at DESC)
idx_audit_log_YYYY_MM_table_id (table_name, record_id)
```

#### 3. Moved Menu Cache to Separate Table
**Before:**
```
restaurants (35 MB)
├── id, name, slug, status...
├── menu_cache_en (JSONB - avg 107KB)  ← TOAST hell
├── menu_cache_fr (JSONB - avg 113KB)  ← TOAST hell
└── menu_cache_updated_at
```

**After:**
```
restaurants (296 KB)           restaurant_menu_cache (28 MB)
├── id, name, slug, status...  ├── restaurant_id (PK)
└── (no cache columns)         ├── menu_cache_en (JSONB)
                               ├── menu_cache_fr (JSONB)
                               └── updated_at
```

#### 4. Updated Cache Functions
All cache functions now use `restaurant_menu_cache` table:
- `rebuild_menu_cache(restaurant_id)`
- `invalidate_menu_cache(restaurant_id)`
- `get_restaurant_menu_cached(restaurant_id, lang)`
- `rebuild_all_menu_caches()`

### Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| `restaurants` table size | 35 MB | 296 KB | **99% smaller** |
| `SELECT *` query time | 2.5-3.5s | 0.15ms | **~20,000x faster** |
| Cached menu query | N/A | 2.6ms | Works correctly |

### Migration Files Created
- `Database/Migrations/fix_010_move_menu_cache.sql`
- `Database/Migrations/fix_011_update_cache_functions.sql`

---

## Concepts Explained

### MFA (Multi-Factor Authentication)
Requires 2+ types of proof to log in:
- Something you know (password)
- Something you have (phone with authenticator app)
- Something you are (fingerprint)

Supabase handles MFA via `auth.mfa_factors`, `auth.mfa_challenges`, `auth.mfa_amr_claims` tables.

### Audit Logs
Automatic records of every data change:
- **Who** made the change
- **What** was changed (table, record, fields)
- **When** it happened
- **Before/After** state (JSONB snapshots)

Partitioned by month for easy archival and faster queries.

### Menu Cache Architecture
- **Lazy Invalidation:** Cache set to NULL on changes, not immediately rebuilt
- **Fallback:** `get_restaurant_menu_cached()` falls back to live query if cache is NULL
- **Triggers:** 11 tables have auto-invalidation triggers
- **Separate Table:** Prevents PostgREST TOAST decompression issues

---

## `admin_users` vs `restaurant_contacts`

| Aspect | `admin_users` | `restaurant_contacts` |
|--------|---------------|----------------------|
| **Purpose** | Login & platform access | Contact info & notifications |
| **Count** | 175 active | 189 active |
| **Auth** | Linked to `auth.users` | No auth - just contact data |
| **Restaurant link** | Via junction table | Direct FK |
| **Unique emails** | 175 | 125 (55 are placeholders) |

**Key insight:** They serve different purposes and should NOT be merged:
- `admin_users` = Who can **do** things (authentication)
- `restaurant_contacts` = Who to **notify** (communication)

---

## Final `admin_users` Schema (18 columns)

```sql
id               BIGINT (PK)
email            VARCHAR (unique, NOT NULL)
first_name       VARCHAR
last_name        VARCHAR
phone            VARCHAR
role_id          BIGINT (FK → admin_roles)
auth_user_id     UUID (FK → auth.users)
is_active        BOOLEAN
status           admin_user_status ENUM
last_login_at    TIMESTAMPTZ
suspended_at     TIMESTAMPTZ
suspended_reason TEXT
v1_admin_id      INTEGER (legacy)
v2_admin_id      INTEGER (legacy)
created_at       TIMESTAMPTZ
updated_at       TIMESTAMPTZ
deleted_at       TIMESTAMPTZ
deleted_by       BIGINT
```


# Admin Contacts Data Migration

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

