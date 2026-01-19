# Migration & Scraper Summary

> **Session Date:** 2026-01-16  
> **Agent Handoff Document**

---

## 📋 Session Accomplishments

### 1. Admin Entity Documentation Updated

**File:** `Menu.ca V3/entities/06-admin-entity.md`

Updated with current database state (was significantly outdated):

| Metric | Old Value | New Value |
|--------|-----------|-----------|
| `admin_users` records | 457 | **175** |
| `admin_user_restaurants` records | 167 | **186** |
| `admin_roles` records | 5 | **2** |
| With Supabase auth linked | 453 (99%) | **160 (91.4%)** |
| With restaurant access | 157 (34%) | **162 (92.6%)** |
| Without restaurant access | 300 (66%) | **13 (7.4%)** |

**Key Finding Corrected:** The claim "300 admins (66%) have no restaurant access" was outdated. Current reality: only **13 admins (7.4%)** lack restaurant access, and these are all internal/system accounts (Super Admins, Menu.ca staff).

---

### 2. Schema Cleanup: Dropped Unused Column

**Table:** `menuca_v3.admin_user_restaurants`

**Dropped:** `role` column (varchar, default 'staff')

**Reason:** All 186 records had the same default value 'staff'. Column was never used by any SQL functions or Edge Functions.

**Verification:** Checked all related functions before dropping:
- `assign_restaurants_to_admin` (SQL) - No reference
- `check_admin_restaurant_access` (SQL) - No reference
- `get_admin_restaurants` (SQL) - No reference
- `create-admin-user` (Edge) - No reference
- `create-admin-user-v2` (Edge) - No reference
- `assign-admin-restaurants` (Edge) - No reference

---

### 3. CSV Export Created

**File:** `restaurant_admins.csv` (project root)

**Contents:** 186 admin-restaurant relationships with columns:
- `admin_email`
- `first_name`
- `last_name`
- `restaurant_id`
- `restaurant_name`
- `street_address`
- `city`
- `postal_code`

---

### 4. Restaurant Location Contact Data Updated

**Table:** `menuca_v3.restaurant_locations`

Identified 33 locations missing email, cross-referenced with `admin_users`, and populated contact data where possible.

**Updates Applied:**

| Action | Count |
|--------|-------|
| Location emails updated from admin emails | **24** |
| Location phone updated from admin phone | **1** |
| **Total records updated** | **25** |

**Results:**

| Metric | Before | After |
|--------|--------|-------|
| Has phone | 185 (99.5%) | **186 (100%)** |
| Has email | 153 (82.3%) | **177 (95.2%)** |
| Has both | 153 (82.3%) | **177 (95.2%)** |
| Missing email | 33 | **9** |
| Missing both | 1 | **0** |

---

## 🔴 Remaining Work

### 9 Locations Still Missing Email

| Location ID | Restaurant ID | Restaurant Name | Reason |
|-------------|---------------|-----------------|--------|
| 5069 | 211 | Erman Pizza | Placeholder admin email |
| 5063 | 205 | Mont Liban Bakery | Placeholder admin email |
| 5496 | 1021 | JJ's Shawarma | No admin assigned |
| 4335 | 821 | Milano (Mill St) | No admin assigned |
| 4354 | 840 | Milano (Prince of Wales) | No admin assigned |
| 4315 | 801 | Nachos Loco Gatineau | No admin assigned |
| 4304 | 790 | Nachos Loco Hull | No admin assigned |
| 4303 | 789 | Poutinerie Québecurds Hull | No admin assigned |
| 4334 | 820 | Vieux Hull Pizza | No admin assigned |

**Required Actions:**
- **2 locations** need real emails to replace placeholder admin emails
- **7 locations** need admin assignment first (these are the restaurants without any admin)

---

### 11 Restaurants Without Admin Assignment

| V3 ID | Restaurant Name |
|-------|-----------------|
| 1021 | JJ's Shawarma |
| 126 | Milano |
| 837 | Milano |
| 92 | Milano |
| 840 | Milano |
| 821 | Milano |
| 801 | Nachos Loco Gatineau |
| 790 | Nachos Loco Hull |
| 1015 | Poutinerie Québecurds Gatineau |
| 789 | Poutinerie Québecurds Hull |
| 820 | Vieux Hull Pizza |

---

### 13 Internal Admins Without Restaurant Access (Expected)

These are internal Menu.ca/Worklocal staff accounts - **no action needed**:

| ID | Email | Role |
|----|-------|------|
| 18 | james.walker@menu.ca | Super Admin |
| 932 | santiago@worklocal.ca | Super Admin |
| 1099 | brian+1@worklocal.ca | Super Admin |
| 12 | chris@menu.ca | Internal |
| 16 | george@menu.ca | Internal |
| 19 | james@menu.ca | Internal |
| 23 | jordan@worklocal.ca | Internal |
| 33 | razvan@menu.ca | Internal |
| 40 | stefan@menu.ca | Internal |
| 41 | stephane@menu.ca | Internal |
| 43 | system@menu.ca | System |
| 49 | vendor2@menu.ca | Vendor |
| 50 | yanni@menu.ca | Internal |

---

## 📁 Files Modified This Session

| File | Action |
|------|--------|
| `Menu.ca V3/entities/06-admin-entity.md` | Updated with current data |
| `restaurant_admins.csv` | Created (new) |
| `Migration/scrapper summary.md` | Created (this file) |

---

## 🔗 Database Changes Applied

```sql
-- 1. Dropped unused column
ALTER TABLE menuca_v3.admin_user_restaurants DROP COLUMN role;

-- 2. Updated 24 location emails from admin emails
UPDATE menuca_v3.restaurant_locations rl
SET email = au.email, updated_at = NOW()
FROM menuca_v3.admin_user_restaurants aur
JOIN menuca_v3.admin_users au ON aur.admin_user_id = au.id
WHERE rl.restaurant_id = aur.restaurant_id
AND rl.deleted_at IS NULL
AND (rl.email IS NULL OR rl.email = '')
AND au.email IS NOT NULL 
AND au.email NOT LIKE '%@placeholder.menu.ca';

-- 3. Updated Lemongrass Thai Cuisine phone
UPDATE menuca_v3.restaurant_locations 
SET phone = '613-277-2008', updated_at = NOW()
WHERE id = 5487;
```

---

## 📊 Current Data Quality Summary

### Admin Users (175 total)

| Metric | Value |
|--------|-------|
| Active | 175 (100%) |
| With Supabase auth linked | 160 (91.4%) |
| With restaurant access | 162 (92.6%) |
| Migrated from V1 | 143 (81.7%) |
| Migrated from V2 | 30 (17.1%) |
| Never logged in | 175 (100%) ⚠️ |

### Restaurant Locations (186 total)

| Metric | Value |
|--------|-------|
| Has phone | 186 (100%) ✅ |
| Has email | 177 (95.2%) |
| Missing email | 9 (4.8%) |

---

## 🔧 Connection Info

**Project:** `menu-rebuild-vo` (nthpbtdjhhnwfxqsxbvy)

**To connect:**
```powershell
# Load environment
$envPath = "C:\Users\santi\Software Development Projects\Worklocal\Migration-Strategy\.env files\.env"
Get-Content $envPath | ForEach-Object {
    if ($_ -match '^([A-Z_][A-Z0-9_]*)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# Run queries
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" $env:DB_CONNECTION_STRING -c "YOUR_SQL"
```

---

**Last Updated:** 2026-01-16
