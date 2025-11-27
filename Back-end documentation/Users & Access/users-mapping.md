# Users & Access Entity - V1/V2 to V3 Field Mapping

**Created:** 2025-10-06  
**Purpose:** Complete field-level mapping from menuca_v1 and menuca_v2 user tables to menuca_v3 schema  
**Status:** 🔄 IN PROGRESS - Phase 1

---

## 📋 Table of Contents

1. [Customer Users Mapping](#customer-users-mapping)
2. [Admin Users Mapping](#admin-users-mapping)
3. [User Addresses Mapping](#user-addresses-mapping)
4. [Authentication & Tokens Mapping](#authentication--tokens-mapping)
5. [V3 Schema Design](#v3-schema-design)
6. [Migration Strategy](#migration-strategy)
7. [Data Quality Issues](#data-quality-issues)

---

## 1. Customer Users Mapping

### Source Tables
- **V1:** `menuca_v1.users` (~442,286 rows)
- **V2:** `menuca_v2.site_users` (~8,943 rows)

### Merge Strategy ✅ UPDATED (2025-10-06)
- **V2 is authoritative** for active users
- **V1 active users only** - Filter by recent activity (lastLogin > 2020-01-01 or similar)
- **Skip 433k inactive V1 users** - Reduces dataset from 442k → ~10-15k V1 active users
- **Email is unique key** - Merge on email, prefer V2 data when duplicate
- **Expected final count:** ~15-20k unique users (instead of 440k)

### Field Mapping: menuca_v3.users

| V3 Field | Type | V1 Source | V2 Source | Transformation Notes |
|----------|------|-----------|-----------|---------------------|
| **id** | SERIAL | - | - | Auto-generated, never use V1/V2 IDs |
| **legacy_v1_id** | INTEGER | users.id | - | Track V1 origin (for order migration) |
| **legacy_v2_id** | INTEGER | - | site_users.id | Track V2 origin (for order migration) |
| **email** | VARCHAR(100) | users.email | site_users.email | **UNIQUE** - Email deduplication required |
| **password_hash** | VARCHAR(255) | users.password | site_users.password | Both use bcrypt ($2y$10$...) ✅ |
| **password_changed_at** | TIMESTAMPTZ | users.passwordChangedOn | - | V2 doesn't track, use NULL |
| **first_name** | VARCHAR(50) | users.fname | site_users.fname | TRIM and INITCAP |
| **last_name** | VARCHAR(50) | users.lname | site_users.lname | TRIM and INITCAP |
| **language** | VARCHAR(2) | users.language | - | V1: 'en'/'fr', default 'en' |
| **language_id** | INTEGER | - | site_users.language_id | V2: 1=English, 2=French |
| **active** | BOOLEAN | users.isActive='y' | site_users.active='y' | Convert enum to boolean |
| **email_confirmed** | BOOLEAN | users.isEmailConfirmed='1' | - | V2 assumes confirmed |
| **newsletter_opt_in** | BOOLEAN | users.newsletter='1' | site_users.newsletter='y' | Marketing consent |
| **sms_opt_in** | BOOLEAN | - | site_users.sms='y' | V2 only, default false for V1 |
| **vegan_newsletter** | BOOLEAN | users.vegan_newsletter='1' | - | V1 only, default false for V2 |
| **last_login** | TIMESTAMPTZ | users.lastLogin | site_users.last_login | Track user engagement |
| **login_count** | INTEGER | users.loginCount | - | V2 doesn't track, default 0 |
| **created_at** | TIMESTAMPTZ | - | site_users.created_at | V2 only, estimate for V1 users |
| **created_from** | VARCHAR(10) | users.createdFrom | - | V1: 'd'=desktop, 'm'=mobile |
| **creation_ip** | VARCHAR(45) | users.creationip | - | IPv4 address (V1 only) |
| **origin_restaurant_id** | INTEGER | users.restaurant | site_users.origin_restaurant | FK to restaurants (validate when available) |
| **is_global_user** | BOOLEAN | users.globalUser='y' | - | V1 concept, default true for V2 |
| **disabled_by** | INTEGER | - | site_users.disabled_by | FK to admin_users (soft delete) |
| **disabled_at** | TIMESTAMPTZ | - | site_users.disabled_at | When account disabled |
| **oauth_provider** | VARCHAR(50) | - | site_users.oauth_provider | 'site', 'facebook', 'google' |
| **oauth_uid** | VARCHAR(125) | - | site_users.oauth_uid | Social provider user ID |
| **oauth_picture_url** | VARCHAR(255) | - | site_users.picture_url | Profile picture from OAuth |
| **oauth_profile_url** | VARCHAR(255) | - | site_users.profile_url | Social profile link |
| **gender** | VARCHAR(10) | - | site_users.gender | OAuth field (V2 only) |
| **locale** | VARCHAR(10) | - | site_users.locale | OAuth locale (V2 only) |
| **autologin_code** | VARCHAR(40) | users.autologinCode | - | V1 stored in main table, V2 uses separate table |
| **updated_at** | TIMESTAMPTZ | - | - | Track last modification |

### V1-Only Fields (Marketing) - Separate Table or Skip?

**Option A:** Create `menuca_v3.user_marketing_stats` table
- V1 has extensive email marketing tracking (sent, opens, clicks, last_send, last_open, last_click, total_opens, total_clicks)
- If needed for reporting, migrate to separate table
- If not actively used, **SKIP** migration

**Option B:** Skip marketing stats entirely
- Likely historical data only
- Modern email marketing likely uses external platform (Mailchimp, SendGrid)
- **Recommendation:** SKIP unless stakeholder needs

### V1 Excluded Fields
- `fbid` - Replaced by oauth_uid in V2
- `storageToken` - Unknown purpose, likely deprecated
- `fsi` - Unknown purpose
- `creditValue`, `creditStartOn` - Credit system (likely deprecated)
- `firstMailFeedback` - Single campaign flag
- `unsub` - Replaced by newsletter_opt_in inverse
- `creationip` - Security value low, skip or archive separately

---

## 2. Admin Users Mapping

### Source Tables
- **V1:** `menuca_v1.admin_users` (~1 row - header only, need dump file)
- **V1:** `menuca_v1.restaurant_admins` (not in CSV exports, need dump)
- **V1:** `menuca_v1.callcenter_users` (~38 rows)
- **V2:** `menuca_v2.admin_users` (~53 rows)
- **V2:** `menuca_v2.admin_users_restaurants` (~100 rows - junction table)

### Merge Strategy
- **V2 is authoritative** for current admin accounts
- **V1 provides historical** admin data (if available)
- **Separate callcenter_users** - Merge or keep separate?
  - Option A: Merge into admin_users with role='callcenter'
  - Option B: Keep separate table
  - **Recommendation:** Merge with specific role

### Field Mapping: menuca_v3.admin_users

| V3 Field | Type | V1 Source | V2 Source | Transformation Notes |
|----------|------|-----------|-----------|---------------------|
| **id** | SERIAL | - | - | Auto-generated |
| **legacy_v1_id** | INTEGER | admin_users.id | - | Track V1 origin |
| **legacy_v2_id** | INTEGER | - | admin_users.id | Track V2 origin |
| **username** | VARCHAR(50) | admin_users.username | - | V1 only, V2 uses email |
| **email** | VARCHAR(100) | admin_users.email / callcenter_users.email | admin_users.email | **UNIQUE** |
| **password_hash** | VARCHAR(255) | admin_users.password / callcenter_users.password | admin_users.password | bcrypt |
| **first_name** | VARCHAR(50) | admin_users.fname / callcenter_users.fname | admin_users.fname | TRIM |
| **last_name** | VARCHAR(50) | admin_users.lname / callcenter_users.lname | admin_users.lname | TRIM |
| **phone** | VARCHAR(20) | - | admin_users.phone | V2 only |
| **user_type** | VARCHAR(20) | admin_users.user_type | - | V1: type of admin |
| **group_id** | INTEGER | - | admin_users.group | V2: FK to groups (roles) |
| **rank** | SMALLINT | admin_users.rank / callcenter_users.rank | - | Permission level |
| **active** | BOOLEAN | admin_users.activeUser='1' / callcenter_users.is_active='y' | admin_users.active='y' | Convert enum |
| **receive_statements** | BOOLEAN | - | admin_users.receive_statements='y' | Financial reports |
| **override_restaurants** | BOOLEAN | - | admin_users.override_restaurants='y' | Global access |
| **allow_login_to_sites** | BOOLEAN | - | admin_users.allow_login_to_sites='y' | Customer site login |
| **allow_api_access** | BOOLEAN | admin_users.allowApiAccess='Y' | - | API permissions |
| **api_key** | VARCHAR(40) | admin_users.apikey | - | API authentication |
| **vendor_id** | SMALLINT | admin_users.vendor | - | FK to vendors table |
| **show_clients** | BOOLEAN | admin_users.showClients='y' | - | UI permission |
| **preferred_language** | TINYINT | - | admin_users.preferred_language | 1=EN, 2=FR |
| **settings** | JSONB | - | admin_users.settings | UI preferences (JSON) |
| **billing_info** | TEXT | - | admin_users.billing_info | Payment details |
| **last_login** | TIMESTAMPTZ | admin_users.lastlogin / callcenter_users.last_login | - | V2 tracks last_activity instead |
| **last_activity** | TIMESTAMPTZ | - | admin_users.last_activity | More granular than last_login |
| **login_count** | INTEGER | admin_users.loginCount | - | V2 doesn't track |
| **last_password_change** | DATETIME | admin_users.lastPassChange | - | Security tracking |
| **created_at** | TIMESTAMPTZ | admin_users.created_at | admin_users.created_at | Account creation |
| **created_by** | INTEGER | - | admin_users.created_by | FK to admin_users (who created) |
| **updated_at** | TIMESTAMPTZ | admin_users.updated_at | - | Last modification |
| **disabled_by** | INTEGER | - | admin_users.disabled_by | FK to admin_users (soft delete) |
| **disabled_at** | TIMESTAMPTZ | - | admin_users.disabled_at | When disabled |

### V1 BLOB Fields - Requires Deserialization

**admin_users.permissions** (BLOB):
- Contains serialized PHP array of permission flags
- Need deserialization script (similar to Menu & Catalog Phase 4)
- Options:
  - Convert to JSONB in V3
  - Skip if V2 group-based permissions are better
  - **Recommendation:** Skip, use V2 group system

**restaurant_admins.allowed_restaurants** (BLOB):
- List of restaurant IDs admin can access
- Replaced by `admin_users_restaurants` junction table in V2
- **Recommendation:** Use V2 junction table instead

### Admin-Restaurant Relationship

**Junction Table:** `menuca_v3.admin_users_restaurants`

| V3 Field | Type | V1 Source | V2 Source | Notes |
|----------|------|-----------|-----------|-------|
| **id** | SERIAL | - | - | Auto-generated |
| **admin_user_id** | INTEGER | restaurant_admins.admin_user_id | admin_users_restaurants.user_id | FK to admin_users |
| **restaurant_id** | INTEGER | restaurant_admins.restaurant | admin_users_restaurants.restaurant_id | FK to restaurants |
| **created_at** | TIMESTAMPTZ | - | - | When access granted |

---

## 3. User Addresses Mapping

### Source Tables
- **V1:** `menuca_v1.users_delivery_addresses` (need CSV export)
- **V2:** `menuca_v2.site_users_delivery_addresses` (~11,710 rows)

### Critical Issue: City/Province Lookup
- **V1** stores city as VARCHAR (string) + province as INTEGER (FK to provinces)
- **V2** stores city as VARCHAR (string) + province as VARCHAR (2-letter code)
- **V3** needs city_id INTEGER (FK to menuca_v3.cities)
- **Challenge:** Must lookup city by name and province to find city_id

### Field Mapping: menuca_v3.user_addresses

| V3 Field | Type | V1 Source | V2 Source | Transformation Notes |
|----------|------|-----------|-----------|---------------------|
| **id** | SERIAL | - | - | Auto-generated |
| **legacy_v1_id** | INTEGER | users_delivery_addresses.id | - | Track V1 origin |
| **legacy_v2_id** | INTEGER | - | site_users_delivery_addresses.id | Track V2 origin |
| **user_id** | INTEGER | - | - | FK to menuca_v3.users (transformed from legacy IDs) |
| **active** | BOOLEAN | - | site_users_delivery_addresses.active='y' | V1 doesn't track, default true |
| **label** | VARCHAR(45) | users_delivery_addresses.label | - | "Home", "Work", etc. |
| **street** | VARCHAR(255) | users_delivery_addresses.street + streetNo | site_users_delivery_addresses.street | Combine street + number for V1 |
| **apartment** | VARCHAR(15) | users_delivery_addresses.apartment | site_users_delivery_addresses.apartment | Unit number |
| **city_id** | INTEGER | - | - | **LOOKUP:** Match city name → cities.id |
| **postal_code** | VARCHAR(7) | users_delivery_addresses.zip | site_users_delivery_addresses.zip | Format: A1A 1A1 |
| **latitude** | DECIMAL(11,8) | users_delivery_addresses.latitude | site_users_delivery_addresses.lat | Geocoding |
| **longitude** | DECIMAL(11,8) | users_delivery_addresses.longitude | site_users_delivery_addresses.lng | Geocoding |
| **phone** | VARCHAR(20) | users_delivery_addresses.phone + ext | site_users_delivery_addresses.phone | Combine phone + extension for V1 |
| **buzzer** | VARCHAR(15) | users_delivery_addresses.buzzer | site_users_delivery_addresses.ringer | Intercom code |
| **special_instructions** | VARCHAR(255) | users_delivery_addresses.comment | site_users_delivery_addresses.special_instructions | Delivery notes |
| **google_place_id** | VARCHAR(255) | - | site_users_delivery_addresses.place_id | Google Maps ID (V2 only) |
| **missing_data** | BOOLEAN | - | site_users_delivery_addresses.missingData='y' | Incomplete address flag (V2 only) |
| **created_at** | TIMESTAMPTZ | - | - | Estimate or NULL for V1 |
| **updated_at** | TIMESTAMPTZ | - | - | Last modification |

### City/Province Lookup Query (V1 Addresses)

```sql
-- V1: users_delivery_addresses
SELECT 
  uad.*,
  c.id as matched_city_id,
  p.code as province_code
FROM staging.v1_users_delivery_addresses uad
LEFT JOIN menuca_v3.provinces p ON p.id = uad.province
LEFT JOIN menuca_v3.cities c ON 
  LOWER(TRIM(c.name)) = LOWER(TRIM(uad.city)) 
  AND c.province_id = p.id;
```

### City/Province Lookup Query (V2 Addresses)

```sql
-- V2: site_users_delivery_addresses (province is VARCHAR, city is VARCHAR)
SELECT 
  sda.*,
  c.id as matched_city_id,
  p.id as province_id
FROM staging.v2_site_users_delivery_addresses sda
LEFT JOIN menuca_v3.provinces p ON 
  LOWER(TRIM(p.code)) = LOWER(TRIM(sda.province))
LEFT JOIN menuca_v3.cities c ON 
  LOWER(TRIM(c.name)) = LOWER(TRIM(sda.city)) 
  AND c.province_id = p.id;
```

### Expected Data Quality Issues
1. **Unmatched cities** - City names may not exist in cities table
2. **Typos** - "Otawa" instead of "Ottawa"
3. **Missing data** - V2 has `missingData='y'` flag (incomplete addresses)
4. **Geocoding errors** - Some lat/lng may be (0,0) or invalid
5. **Postal code format** - Some may lack space (K2L4B6 vs K2L 4B6)

---

## 4. Authentication & Tokens Mapping

### 4.1 Password Reset Tokens

**Source Tables:**
- V1: `menuca_v1.pass_reset` (~203,018 rows)
- V2: `menuca_v2.reset_codes` (~3,630 rows)

**Migration Strategy:**
- **Option A:** Migrate all tokens (historical + active)
- **Option B:** Skip expired tokens, migrate only active (expires_at > NOW())
- **Recommendation:** Skip V1 entirely (5+ years old), migrate only V2 active tokens

**Field Mapping:** `menuca_v3.password_reset_tokens`

| V3 Field | Type | V1 Source | V2 Source | Notes |
|----------|------|-----------|-----------|-------|
| **id** | SERIAL | - | - | Auto-generated |
| **user_id** | INTEGER | pass_reset.user_id | reset_codes.user_id | FK to users (transformed) |
| **code** | VARCHAR(36) | pass_reset.code | reset_codes.code | Reset token |
| **created_at** | TIMESTAMPTZ | - | reset_codes.added_at | When requested |
| **expires_at** | TIMESTAMPTZ | FROM_UNIXTIME(pass_reset.expire) | reset_codes.expires_at | Token expiry |
| **used_at** | TIMESTAMPTZ | FROM_UNIXTIME(pass_reset.used_at) | - | When token used |
| **request_ip** | VARCHAR(45) | - | reset_codes.request_ip | Security tracking |
| **deleted** | BOOLEAN | pass_reset.deleted='y' | - | Soft delete |

### 4.2 Autologin Tokens (Remember Me)

**Source Tables:**
- V1: `menuca_v1.users.autologinCode` (stored in main table)
- V2: `menuca_v2.site_users_autologins` (~891 rows)

**Migration Strategy:**
- **Option A:** Migrate V2 tokens, extract V1 from users table
- **Option B:** Skip all old tokens, generate new on next login
- **Recommendation:** Migrate V2 only (recent), force V1 users to re-authenticate

**Field Mapping:** `menuca_v3.user_autologin_tokens`

| V3 Field | Type | V1 Source | V2 Source | Notes |
|----------|------|-----------|-----------|-------|
| **id** | SERIAL | - | - | Auto-generated |
| **user_login** | VARCHAR(125) | - | site_users_autologins.user_login | Email or username |
| **selector** | VARCHAR(255) | - | site_users_autologins.selector | Public token half |
| **validator_hash** | VARCHAR(255) | users.autologinCode | site_users_autologins.password | Private token half (hashed) |
| **expires_at** | TIMESTAMPTZ | - | site_users_autologins.expire | Token expiry |
| **created_at** | TIMESTAMPTZ | - | - | When created |

### 4.3 Sessions

**Source Table:**
- V2: `menuca_v2.ci_sessions` (~111 rows)

**Migration Strategy:**
- **Recommendation:** **SKIP MIGRATION** - Sessions are ephemeral
- Active users will create new sessions on next login
- Session BLOB deserialization not worth effort for 111 rows
- Sessions likely expired anyway (table shows old timestamps)

**If migrating (NOT recommended):**

| V3 Field | Type | V2 Source | Notes |
|----------|------|-----------|-------|
| **id** | VARCHAR(40) | ci_sessions.id | Session ID |
| **ip_address** | VARCHAR(45) | ci_sessions.ip_address | User IP |
| **last_activity** | TIMESTAMPTZ | FROM_UNIXTIME(ci_sessions.timestamp) | Last active |
| **user_data** | JSONB | ci_sessions.data | Deserialized session data |

### 4.4 Login Attempts (Security)

**Source Table:**
- V2: `menuca_v2.login_attempts` (~0 rows - EMPTY)

**Migration Strategy:**
- **SKIP** - Empty table, likely cleared periodically
- Create table structure for future use

---

## 5. V3 Schema Design

### Proposed Tables in menuca_v3

1. **users** - Customer accounts (V1 + V2 merge)
2. **admin_users** - Platform/restaurant admin accounts
3. **admin_users_restaurants** - Admin-restaurant junction (many-to-many)
4. **user_addresses** - Saved delivery addresses
5. **password_reset_tokens** - Password reset codes
6. **user_autologin_tokens** - Remember me tokens (optional)
7. **user_sessions** - Active sessions (optional - may skip)
8. **login_attempts** - Failed login tracking (security)
9. **user_favorite_restaurants** - User favorites (defer until restaurants ready)

### Additional Tables (Optional)

10. **user_marketing_stats** - V1 email campaign data (if needed)
11. **user_oauth_profiles** - Social login data (or merge into users table)

---

## 6. Migration Strategy

### Phase 1: Data Loading & Assessment

**Step 1:** Load V1 data into staging
```sql
-- Load 4 parts of V1 users
staging.v1_users (14,292 rows - main file)
staging.v1_users_part1 (142,665 rows)
staging.v1_users_part2 (142,665 rows)
staging.v1_users_part3 (142,664 rows)
-- Total: 442,286 rows

-- Combine into single staging table
staging.v1_users_combined (442,286 rows)

-- Load other V1 tables
staging.v1_admin_users (from dump file)
staging.v1_callcenter_users (38 rows)
staging.v1_pass_reset (203,018 rows)
staging.v1_users_delivery_addresses (from dump file)
```

**Step 2:** Load V2 data into staging
```sql
staging.v2_site_users (8,943 rows)
staging.v2_admin_users (53 rows)
staging.v2_admin_users_restaurants (100 rows)
staging.v2_site_users_delivery_addresses (11,710 rows)
staging.v2_reset_codes (3,630 rows)
staging.v2_site_users_autologins (891 rows)
staging.v2_site_users_favorite_restaurants (2 rows)
```

**Step 3:** Data Quality Assessment
```sql
-- Email duplication analysis
SELECT 
  email, 
  COUNT(*) as cnt,
  COUNT(*) FILTER (WHERE source='v1') as v1_count,
  COUNT(*) FILTER (WHERE source='v2') as v2_count
FROM (
  SELECT LOWER(TRIM(email)) as email, 'v1' as source FROM staging.v1_users_combined
  UNION ALL
  SELECT LOWER(TRIM(email)) as email, 'v2' as source FROM staging.v2_site_users
) combined
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- Expected result: ~8,000-9,000 duplicate emails (V1 users who migrated to V2)
```

### Phase 2: Email Deduplication Strategy

**Rule:** V2 wins conflicts (most recent data)

```sql
-- Create deduplication mapping table
CREATE TABLE staging.user_email_resolution (
  email VARCHAR(100) PRIMARY KEY,
  v1_id INTEGER,
  v2_id INTEGER,
  winner VARCHAR(2), -- 'v1' or 'v2'
  reason VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Populate mapping
INSERT INTO staging.user_email_resolution
SELECT 
  email,
  MAX(v1_id) as v1_id,
  MAX(v2_id) as v2_id,
  CASE 
    WHEN MAX(v2_id) IS NOT NULL THEN 'v2'
    ELSE 'v1'
  END as winner,
  CASE 
    WHEN MAX(v2_id) IS NOT NULL THEN 'v2_active'
    ELSE 'v1_only'
  END as reason
FROM (
  SELECT LOWER(TRIM(email)) as email, id as v1_id, NULL::INTEGER as v2_id
  FROM staging.v1_users_combined
  UNION ALL
  SELECT LOWER(TRIM(email)) as email, NULL::INTEGER as v1_id, id as v2_id
  FROM staging.v2_site_users
) combined
GROUP BY email;
```

### Phase 3: Transformation & Load

**Priority Order:**
1. Users (customers)
2. Admin users
3. Admin-restaurant junction
4. User addresses (requires user IDs)
5. Password reset tokens (requires user IDs)
6. Autologin tokens (optional)

---

## 7. Data Quality Issues

### Known Issues from CSV Analysis

1. **CSV Delimiter Mismatch**
   - V1 uses semicolon (;)
   - V2 uses comma (,)
   - Solution: Specify delimiter in COPY command

2. **NULL Representation**
   - V1: Empty strings, "0000-00-00 00:00:00" for dates
   - V2: Empty strings, sometimes "N" for NULL
   - Solution: NULLIF transformations

3. **Character Encoding**
   - V1: ISO-8859-1 or Windows-1252 (accented characters may be corrupted)
   - V2: UTF-8
   - Solution: Verify encoding on load, may need CONVERT()

4. **Broken CSV Rows**
   - V2 admin_users has JSON escaping issues (last row in sample)
   - Solution: Manual review and fix, or exclude bad rows

5. **Address City Lookup**
   - Many city names may not match cities table exactly
   - Typos, abbreviations, alternate spellings
   - Solution: Fuzzy matching or manual mapping table

6. **Inactive Users**
   - 433k V1 users not in V2 (98% of V1 data)
   - Likely inactive for 5+ years
   - Decision needed: Migrate all or active only?
   - **Recommendation:** Migrate all (historical orders may reference them)

7. **Password Security**
   - Both V1 and V2 use bcrypt - Good! ✅
   - Can migrate hashes directly without forced reset

---

## 8. Stakeholder Decisions ✅ APPROVED (2025-10-06)

1. **V1-only users:** ✅ **Active Users Only** - Skip 433k inactive V1 users
   - Impact: ~440k → ~10-15k users (massive reduction!)
   - Strategy: Filter by `lastLogin > 2020-01-01` or similar activity threshold
   
2. **Marketing data:** ✅ **Skip** - Legacy access available if needed later
   - V1 email campaign stats (sent/opens/clicks) will not migrate
   
3. **Sessions:** ✅ **Skip for sure** - Start fresh
   - ci_sessions table will not migrate (111 rows)
   
4. **Expired tokens:** ✅ **Active only** - Migrate V2 active tokens only
   - Filter: `expires_at > NOW()`
   - Estimated: ~500-1,000 active tokens instead of 206k
   
5. **Address validation:** ⏳ **Review data first**
   - Use postcodes for relation if cities match
   - Will assess unmatched cities during Phase 1 loading
   
6. **Restaurant FK:** ✅ **Load with NULL** - Backfill optional later
   - origin_restaurant_id will be NULL initially
   - Will auto-populate on first V3 order anyway
   - Can optionally backfill from legacy data after Restaurant Management completes
   - Impact: None - feature continues to work, just starts fresh on V3 platform

---

## 9. Estimated Row Counts (Post-Deduplication) ✅ UPDATED

**BEFORE Stakeholder Decisions:** 468,692 rows  
**AFTER Stakeholder Decisions:** ~30,000 rows (94% reduction!) 🎉

| Table | Est. Rows | Source | Decision Impact |
|-------|-----------|--------|-----------------|
| users | **15,000** | V2 (9k) + V1 active only (~10k) - 4k duplicates | ✅ Skip 433k inactive V1 users |
| admin_users | 90 | V1 (unknown) + V2 (53) + V1 callcenter (38) | No change |
| admin_users_restaurants | 100 | V2 only (V1 needs deserialization) | No change |
| user_addresses | 12,000 | V2 (11,710) + V1 active users only (~500) | ✅ Reduced from 25k |
| password_reset_tokens | **500** | V2 active only (expires_at > NOW()) | ✅ Skip 206k expired |
| user_autologin_tokens | **300** | V2 active only (expire > NOW()) | ✅ Skip expired tokens |
| user_favorite_restaurants | 2 | V2 only (defer) | No change |
| **TOTAL** | **~28,000** | **Focus: 15k active customer accounts** | **🎉 94% reduction!** |

### Filter Strategy for "Active Users Only"

**Option 1: Recent Login (Recommended)**
```sql
-- V1 users with login in last 3-5 years
WHERE users.lastLogin > '2020-01-01'
```

**Option 2: Recent Orders**
```sql
-- V1 users with orders in last 3 years
WHERE users.id IN (
  SELECT DISTINCT user_id 
  FROM orders 
  WHERE created_at > '2022-01-01'
)
```

**Option 3: Combined Activity**
```sql
-- Login OR order in last 3 years
WHERE users.lastLogin > '2020-01-01' 
   OR users.id IN (SELECT DISTINCT user_id FROM orders WHERE created_at > '2022-01-01')
```

**Recommendation:** Option 1 (lastLogin) - Simplest and covers most active users

---

**Next Steps:**
1. Review and approve mapping
2. Resolve open questions
3. Begin Phase 1: Load data into staging
4. Run deduplication analysis
5. Create V3 schema DDL

**Status:** ✅ Mapping Complete - Ready for Review
