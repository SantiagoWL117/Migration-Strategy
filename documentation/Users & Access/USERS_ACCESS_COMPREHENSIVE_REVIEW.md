# Users & Access Entity - Comprehensive Migration Review

**Date:** January 7, 2025  
**Purpose:** Complete verification and data quality assessment for Users & Access entity migration  
**Status:** 🔄 IN PROGRESS - Initial Assessment

---

## 📋 EXECUTIVE SUMMARY

The Users & Access entity encompasses customer accounts, admin users, delivery addresses, and authentication tokens. This review validates source data quality, identifies gaps, and assesses readiness for V3 migration.

### Key Metrics

| Metric | Value | Status |
|--------|-------|--------|
| **V1 Tables** | 4 core + 1 auth | ✅ Identified |
| **V2 Tables** | 7 core + 3 auth | ✅ Identified |
| **Total Source Rows** | ~665,000 | ✅ Counted |
| **Expected V3 Rows** | ~28,000 (after filters) | ⏳ Pending validation |
| **Missing Dumps** | 1 critical table | 🚨 **V1 user addresses** |
| **Data Quality Issues** | TBD | ⏳ Assessment in progress |

---

## 🗂️ SECTION 1: SOURCE TABLES VERIFICATION

### 1.1 V1 Tables from `menuca_v1` Schema

| # | Table Name | Schema Exists | Dump Exists | CSV Exists | Rows (CSV) | Status |
|---|------------|---------------|-------------|------------|------------|--------|
| 1 | **users** | ✅ | ❌ No single dump | ✅ (4 parts) | 442,282 | ⚠️ **Split across 4 CSVs** |
| 2 | **admin_users** | ✅ | ✅ | ✅ | 0 | 🚨 **EMPTY** |
| 3 | **callcenter_users** | ✅ | ✅ | ✅ | 37 | ✅ |
| 4 | **users_delivery_addresses** | ✅ | ❌ **MISSING** | ❌ **MISSING** | Unknown | 🚨 **CRITICAL GAP** |
| 5 | **pass_reset** | ✅ | ✅ | ✅ | 203,017 | ✅ |
| 6 | **logintoken** | ✅ | ✅ | ✅ | 7 | ✅ |

**V1 Total Estimated:** ~645,343 rows (excluding missing addresses table)

### 1.2 V2 Tables from `menuca_v2` Schema

| # | Table Name | Schema Exists | Dump Exists | CSV Exists | Rows (CSV) | Status |
|---|------------|---------------|-------------|------------|------------|--------|
| 1 | **site_users** | ✅ | ✅ | ✅ | 8,942 | ✅ |
| 2 | **admin_users** | ✅ | ✅ | ✅ | 52 | ✅ |
| 3 | **admin_users_restaurants** | ✅ | ✅ | ✅ | 99 | ✅ |
| 4 | **admin_users_actions** | ✅ | ❌ Not needed | ❌ | N/A | ℹ️ **Audit log - skip** |
| 5 | **site_users_delivery_addresses** | ✅ | ✅ | ✅ | 12,045 | ✅ |
| 6 | **site_users_favorite_restaurants** | ✅ | ✅ | ✅ | 1 | ✅ |
| 7 | **site_users_fb** | ✅ | ✅ | ✅ | 0 | ℹ️ **EMPTY** |
| 8 | **site_users_autologins** | ✅ | ✅ | ✅ | 890 | ✅ |
| 9 | **reset_codes** | ✅ | ✅ | ✅ | 3,629 | ✅ |
| 10 | **ci_sessions** | ✅ | ✅ | ✅ | 110 | ℹ️ **Skip per plan** |
| 11 | **login_attempts** | ✅ | ✅ | ❌ Empty | -1 (empty) | ℹ️ **EMPTY - create structure only** |

**V2 Total:** 25,768 rows (active tables only)

### 1.3 Critical Gaps Identified

#### 🚨 CRITICAL: Missing V1 User Delivery Addresses

**Issue:**
- `menuca_v1.users_delivery_addresses` table exists in schema (AUTO_INCREMENT=1446223)
- **No SQL dump file** in `Database/Users_&_Access/dumps/`
- **No CSV file** in `Database/Users_&_Access/CSV/`
- Mapping document (`users-mapping.md` line 179) expects this data: "(need CSV export)"

**Impact:**
- Cannot migrate V1 user addresses (~1.4 million potential addresses)
- V3 will only have V2 addresses (12,045 rows)
- Historical order delivery addresses may be incomplete
- User profile data incomplete for V1-only customers

**Recommended Actions:**
1. **Option A:** Export `menuca_v1.users_delivery_addresses` from MySQL
   - Generate SQL dump: `mysqldump menuca_v1 users_delivery_addresses > menuca_v1_users_delivery_addresses.sql`
   - Generate CSV: Export via MySQL Workbench or script
   
2. **Option B:** Skip V1 addresses if deemed inactive
   - Users with recent activity (per filter: `lastLogin > 2020-01-01`) likely re-entered addresses in V2
   - Verify assumption: Check if V2 active users have addresses in V2 table
   
3. **Option C:** Extract addresses from orders table
   - V1 orders may contain delivery address snapshots
   - Can backfill from historical order data if needed

**User Decision Required:** Which option to proceed with?

#### ⚠️ WARNING: Empty V1 admin_users Table

**Issue:**
- CSV shows 0 rows for `menuca_v1_admin_users.csv`
- Schema shows table exists
- Mapping expects data from this table

**Possible Causes:**
1. Data was migrated to V2 and V1 table cleared
2. CSV export failed
3. All V1 admins are in `callcenter_users` instead

**Impact:**
- Low - V2 has 52 admin_users (current/active)
- V1 `callcenter_users` has 37 rows (may be subset of admins)
- Historical admin data may be lost, but V2 likely authoritative

**Action:** Verify if `callcenter_users` contains all V1 admin data or if dump needs re-export

---

## 📊 SECTION 2: ROW COUNT VERIFICATION

### 2.1 Source Data Totals

| Source | Tables | Total Rows | Status |
|--------|--------|------------|--------|
| **V1** | 4 active + 2 auth | ~645,343 | ⚠️ Missing addresses |
| **V2** | 7 active + 3 auth | 25,768 | ✅ Complete |
| **GRAND TOTAL** | 17 tables | **671,111** | ⚠️ Incomplete |

### 2.2 V1 Customer Users Breakdown

**Critical Note:** V1 users table split across 4 CSV files

| File | Rows | Cumulative | Notes |
|------|------|------------|-------|
| `menuca_v1_users.csv` | 14,291 | 14,291 | Main file |
| `menuca_v1_users_part1.csv` | 142,664 | 156,955 | |
| `menuca_v1_users_part2.csv` | 142,664 | 299,619 | |
| `menuca_v1_users_part3.csv` | 142,663 | 442,282 | |
| **TOTAL** | **442,282** | | Must combine before migration |

**Data Quality Concern:**
- File split suggests large data size (~442k users)
- Per mapping doc decision: **Filter to active users only** (lastLogin > 2020-01-01)
- Expected reduction: 442k → ~10-15k active users (97% reduction)

### 2.3 Expected Post-Filter Row Counts

Based on stakeholder decisions (Section 8 of `users-mapping.md`):

| Table | Pre-Filter | Post-Filter | Reduction | Rationale |
|-------|------------|-------------|-----------|-----------|
| **users** | 442,282 (V1) + 8,942 (V2) | ~15,000 | 97% | Active users only, deduplicate on email |
| **user_addresses** | ~1.4M (V1) + 12,045 (V2) | ~12,000 | 99% | V2 addresses + V1 active user addresses only |
| **admin_users** | 0 (V1) + 37 (callcenter) + 52 (V2) | ~90 | N/A | Merge callcenter into admin |
| **password_reset_tokens** | 203,017 (V1) + 3,629 (V2) | ~500 | 99.8% | Active tokens only (expires_at > NOW()) |
| **autologin_tokens** | 7 (V1) + 890 (V2) | ~300 | 66% | Active tokens only |
| **favorite_restaurants** | N/A + 1 (V2) | 1 | N/A | Defer migration |

**Estimated V3 Total:** ~28,000 rows (94% reduction from source!)

---

## 🔍 SECTION 3: DATA INTEGRITY CHECKS

### 3.1 Primary Key & Uniqueness Validation

**To be executed once data loaded to staging:**

#### Query 1: Check for Duplicate User Emails (Critical)

```sql
-- V1 + V2 email collision analysis
WITH combined_emails AS (
  SELECT 
    LOWER(TRIM(email)) as email_normalized,
    'v1' as source,
    id as source_id,
    lastLogin as activity_date
  FROM staging.v1_users_combined
  WHERE email IS NOT NULL AND email != ''
  
  UNION ALL
  
  SELECT 
    LOWER(TRIM(email)) as email_normalized,
    'v2' as source,
    id as source_id,
    last_login as activity_date
  FROM staging.v2_site_users
  WHERE email IS NOT NULL AND email != ''
)
SELECT 
  email_normalized,
  COUNT(*) as total_occurrences,
  COUNT(*) FILTER (WHERE source='v1') as v1_count,
  COUNT(*) FILTER (WHERE source='v2') as v2_count,
  STRING_AGG(source || ':' || source_id, ', ') as source_ids
FROM combined_emails
GROUP BY email_normalized
HAVING COUNT(*) > 1
ORDER BY total_occurrences DESC
LIMIT 100;
```

**Expected Result:** 8,000-9,000 duplicate emails (users who migrated from V1 to V2)

**Business Rule:** V2 wins conflicts (most recent data)

#### Query 2: Check for NULL/Empty Emails

```sql
-- Customer users without email (invalid accounts)
SELECT 
  'v1' as source,
  COUNT(*) as null_email_count,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v1_users_combined) as percentage
FROM staging.v1_users_combined
WHERE email IS NULL OR TRIM(email) = ''

UNION ALL

SELECT 
  'v2' as source,
  COUNT(*) as null_email_count,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v2_site_users) as percentage
FROM staging.v2_site_users
WHERE email IS NULL OR TRIM(email) = '';
```

**Expected Result:** Email is required, should be 0 or very low percentage

#### Query 3: Admin User Email Uniqueness

```sql
-- Check admin email collisions across V1 callcenter + V2 admin
SELECT 
  LOWER(TRIM(email)) as email_normalized,
  COUNT(*) as occurrence_count,
  STRING_AGG(source, ', ') as sources
FROM (
  SELECT email, 'v1_callcenter' as source FROM staging.v1_callcenter_users
  UNION ALL
  SELECT email, 'v2_admin' as source FROM staging.v2_admin_users
) combined
GROUP BY email_normalized
HAVING COUNT(*) > 1;
```

**Expected Result:** Should be 0 (each admin should have unique email)

### 3.2 Foreign Key Integrity Checks

#### Query 4: Orphaned User Addresses (User ID not found)

```sql
-- V2 addresses with invalid user_id
SELECT 
  COUNT(*) as orphaned_addresses,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v2_site_users_delivery_addresses) as percentage
FROM staging.v2_site_users_delivery_addresses sda
WHERE NOT EXISTS (
  SELECT 1 FROM staging.v2_site_users u WHERE u.id = sda.user_id
);
```

**Expected Result:** 0 orphaned addresses (FK should be valid)

#### Query 5: Orphaned Admin-Restaurant Relationships

```sql
-- V2 admin-restaurant mappings with invalid references
SELECT 
  'invalid_user' as issue,
  COUNT(*) as count
FROM staging.v2_admin_users_restaurants ar
WHERE NOT EXISTS (
  SELECT 1 FROM staging.v2_admin_users au WHERE au.id = ar.user_id
)

UNION ALL

SELECT 
  'invalid_restaurant' as issue,
  COUNT(*) as count
FROM staging.v2_admin_users_restaurants ar
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.restaurants r WHERE r.legacy_v2_id = ar.restaurant_id
);
```

**Expected Result:** 
- invalid_user: 0 (admin should exist)
- invalid_restaurant: Unknown until restaurants migrated

#### Query 6: Orphaned Password Reset Tokens

```sql
-- V2 reset codes with invalid user_id
SELECT 
  COUNT(*) as orphaned_tokens,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v2_reset_codes) as percentage
FROM staging.v2_reset_codes rc
WHERE NOT EXISTS (
  SELECT 1 FROM staging.v2_site_users u WHERE u.id = rc.user_id
);
```

**Expected Result:** Some orphaned tokens expected (users may have been deleted)

### 3.3 Data Range & Format Validation

#### Query 7: Invalid Date Ranges

```sql
-- Users with future birthdates, invalid login dates, etc.
SELECT 
  'future_last_login' as issue,
  COUNT(*) as count
FROM staging.v1_users_combined
WHERE lastLogin > NOW()

UNION ALL

SELECT 
  'future_created_at' as issue,
  COUNT(*) as count
FROM staging.v2_site_users
WHERE created_at > NOW()

UNION ALL

SELECT 
  'disabled_before_created' as issue,
  COUNT(*) as count
FROM staging.v2_site_users
WHERE disabled_at IS NOT NULL AND disabled_at < created_at;
```

**Expected Result:** 0 for all (data should be logically consistent)

#### Query 8: Invalid Geocoding Data (Addresses)

```sql
-- Addresses with zero or invalid coordinates
SELECT 
  'zero_coordinates' as issue,
  COUNT(*) as count
FROM staging.v2_site_users_delivery_addresses
WHERE (lat = 0 AND lng = 0) OR lat IS NULL OR lng IS NULL

UNION ALL

SELECT 
  'out_of_canada_bounds' as issue,
  COUNT(*) as count
FROM staging.v2_site_users_delivery_addresses
WHERE lat NOT BETWEEN 41.0 AND 84.0 
   OR lng NOT BETWEEN -141.0 AND -52.0;
```

**Expected Result:** Some zero coordinates expected (geocoding failures)

#### Query 9: Invalid Postal Code Format

```sql
-- Canadian postal codes that don't match pattern A1A 1A1 or A1A1A1
SELECT 
  COUNT(*) as invalid_postal_codes,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staging.v2_site_users_delivery_addresses) as percentage
FROM staging.v2_site_users_delivery_addresses
WHERE zip IS NOT NULL 
  AND zip NOT SIMILAR TO '[A-Z][0-9][A-Z] [0-9][A-Z][0-9]'
  AND zip NOT SIMILAR TO '[A-Z][0-9][A-Z][0-9][A-Z][0-9]';
```

**Expected Result:** 5-10% invalid format (user input errors)

---

## 🎯 SECTION 4: BUSINESS LOGIC VALIDATION

### 4.1 Active User Status Consistency

#### Query 10: Active Users with Disabled Timestamps

```sql
-- V2 users marked active but have disabled_at timestamp (data inconsistency)
SELECT 
  id,
  email,
  active,
  disabled_at,
  disabled_by
FROM staging.v2_site_users
WHERE active = 'y' AND disabled_at IS NOT NULL;
```

**Expected Result:** 0 (active = 'y' should mean disabled_at IS NULL)

**Business Rule:** If found, prioritize disabled_at (set active = 'n')

#### Query 11: Admin Users with Inconsistent Status

```sql
-- V2 admin users marked active but recently disabled
SELECT 
  id,
  email,
  active,
  disabled_at,
  last_activity
FROM staging.v2_admin_users
WHERE active = 'n' AND last_activity > disabled_at;
```

**Expected Result:** 0 (can't be active after being disabled)

### 4.2 OAuth Data Validation

#### Query 12: OAuth Users Without Email

```sql
-- Users who authenticated via OAuth but missing email (should be extracted from OAuth)
SELECT 
  COUNT(*) as oauth_no_email
FROM staging.v2_site_users
WHERE oauth_provider IS NOT NULL 
  AND oauth_provider != 'site'
  AND (email IS NULL OR TRIM(email) = '');
```

**Expected Result:** 0 (OAuth providers always return email)

#### Query 13: OAuth UID Duplicates

```sql
-- Multiple users sharing same OAuth provider + UID (should be impossible)
SELECT 
  oauth_provider,
  oauth_uid,
  COUNT(*) as user_count,
  STRING_AGG(id::TEXT, ', ') as user_ids
FROM staging.v2_site_users
WHERE oauth_provider IS NOT NULL
GROUP BY oauth_provider, oauth_uid
HAVING COUNT(*) > 1;
```

**Expected Result:** 0 (each OAuth UID should be unique per provider)

### 4.3 Password Security Validation

#### Query 14: Password Hash Format Verification

```sql
-- Check that passwords are bcrypt hashed (should start with $2y$10$ or $2a$10$)
SELECT 
  'v1_invalid_hash' as source,
  COUNT(*) as invalid_hash_count
FROM staging.v1_users_combined
WHERE password NOT LIKE '$2%'
  AND password IS NOT NULL

UNION ALL

SELECT 
  'v2_invalid_hash' as source,
  COUNT(*) as invalid_hash_count
FROM staging.v2_site_users
WHERE password NOT LIKE '$2%'
  AND password IS NOT NULL;
```

**Expected Result:** 0 (all passwords should be bcrypt)

**Action if issues found:** Flag users for forced password reset on V3

---

## 📋 SECTION 5: SAMPLE DATA SPOT CHECKS

### 5.1 V1 Users Sample Analysis

**Query 15: Random Sample of V1 Users**

```sql
SELECT 
  id,
  email,
  fname,
  lname,
  isActive,
  lastLogin,
  loginCount,
  createdFrom,
  restaurant as origin_restaurant_id,
  globalUser
FROM staging.v1_users_combined
ORDER BY RANDOM()
LIMIT 50;
```

**Manual Review Checklist:**
- [ ] Name fields properly capitalized
- [ ] Email format valid (contains @, domain)
- [ ] lastLogin dates reasonable (not in future, not too old)
- [ ] loginCount corresponds to activity level
- [ ] createdFrom values ('d', 'm') consistent
- [ ] Character encoding correct (no mojibake like Ã©, Ã )

### 5.2 V2 Site Users Sample Analysis

**Query 16: Random Sample of V2 Users**

```sql
SELECT 
  id,
  email,
  fname,
  lname,
  active,
  last_login,
  created_at,
  oauth_provider,
  newsletter,
  sms,
  origin_restaurant
FROM staging.v2_site_users
ORDER BY RANDOM()
LIMIT 50;
```

**Manual Review Checklist:**
- [ ] OAuth fields populated correctly for social logins
- [ ] Consent flags (newsletter, sms) are 'y'/'n' (not NULL)
- [ ] created_at < last_login (timeline makes sense)
- [ ] origin_restaurant exists in restaurants table (once available)

### 5.3 Address Data Sample Analysis

**Query 17: Random Sample of V2 Addresses**

```sql
SELECT 
  id,
  user_id,
  street,
  apartment,
  city,
  province,
  zip,
  lat,
  lng,
  missingData,
  special_instructions
FROM staging.v2_site_users_delivery_addresses
ORDER BY RANDOM()
LIMIT 50;
```

**Manual Review Checklist:**
- [ ] Street addresses formatted properly (not empty)
- [ ] City names capitalized correctly
- [ ] Province codes valid (ON, QC, BC, etc.)
- [ ] Postal codes have space (K2P 1A4 not K2P1A4)
- [ ] Coordinates within Canada bounds
- [ ] missingData='y' flag correlates with incomplete fields

---

## 📊 SECTION 6: DATA QUALITY REPORT

### 6.1 Known Data Quality Issues (from CSV analysis)

| Issue | Source | Severity | Count | Impact | Mitigation |
|-------|--------|----------|-------|--------|------------|
| **Split CSV files** | V1 users | HIGH | 442k rows across 4 files | Must combine before load | Create unified staging table |
| **Missing V1 addresses** | V1 | CRITICAL | Unknown (~1.4M?) | Incomplete user profiles | Re-export from MySQL or skip |
| **Empty admin_users** | V1 | MEDIUM | 0 rows | Historical admin data lost | Verify if callcenter_users is complete set |
| **Inactive users** | V1 | MEDIUM | ~433k (98%) | Data bloat | Filter by lastLogin > 2020-01-01 |
| **Expired tokens** | V1 + V2 | LOW | ~206k | Unnecessary data | Filter by expires_at > NOW() |
| **CSV delimiter mismatch** | V1 vs V2 | LOW | All files | Load errors | V1 uses ';', V2 uses ',' - specify in COPY |
| **NULL date formats** | V1 | LOW | Unknown | Data parsing | Handle '0000-00-00 00:00:00' as NULL |
| **Character encoding** | V1 | MEDIUM | Unknown | Accented names corrupted | Verify ISO-8859-1 vs UTF-8 on load |

### 6.2 Data Completeness Matrix

| Table | Schema ✅ | Dump ✅ | CSV ✅ | Rows Known | Complete |
|-------|-----------|---------|---------|------------|----------|
| v1.users | ✅ | ❌ | ✅ (4 parts) | 442,282 | ⚠️ Split files |
| v1.admin_users | ✅ | ✅ | ✅ | 0 | 🚨 Empty |
| v1.callcenter_users | ✅ | ✅ | ✅ | 37 | ✅ |
| v1.users_delivery_addresses | ✅ | ❌ | ❌ | Unknown | 🚨 **Missing** |
| v1.pass_reset | ✅ | ✅ | ✅ | 203,017 | ✅ |
| v1.logintoken | ✅ | ✅ | ✅ | 7 | ✅ |
| v2.site_users | ✅ | ✅ | ✅ | 8,942 | ✅ |
| v2.admin_users | ✅ | ✅ | ✅ | 52 | ✅ |
| v2.admin_users_restaurants | ✅ | ✅ | ✅ | 99 | ✅ |
| v2.site_users_delivery_addresses | ✅ | ✅ | ✅ | 12,045 | ✅ |
| v2.site_users_favorite_restaurants | ✅ | ✅ | ✅ | 1 | ✅ |
| v2.site_users_fb | ✅ | ✅ | ✅ | 0 | ℹ️ Empty |
| v2.site_users_autologins | ✅ | ✅ | ✅ | 890 | ✅ |
| v2.reset_codes | ✅ | ✅ | ✅ | 3,629 | ✅ |
| v2.ci_sessions | ✅ | ✅ | ✅ | 110 | ℹ️ Skip |
| v2.login_attempts | ✅ | ✅ | ❌ Empty | 0 | ℹ️ Empty |

**Completeness Score:** 13/16 tables complete (81.25%)

---

## 🚨 SECTION 7: CRITICAL FINDINGS & BLOCKERS

### 7.1 Migration Blockers (Must Resolve)

#### BLOCKER 1: Missing V1 User Delivery Addresses 🔴

**Status:** CRITICAL - Migration cannot proceed without decision

**Details:**
- Table exists in V1 schema (AUTO_INCREMENT suggests ~1.4M addresses)
- No dump file, no CSV export
- 12,045 V2 addresses available, but V1 addresses missing

**Impact:**
- V1-only active users (~10-15k after filtering) will have no saved addresses
- Historical order data may reference missing addresses
- User experience degraded (users must re-enter addresses)

**Resolution Options:**
1. **Export from source MySQL** (Recommended)
   - Provides complete data
   - Allows filtering by user activity
   
2. **Skip V1 addresses entirely** (Quick fix)
   - Only use V2 addresses (12k rows)
   - Assumes V1 active users re-entered addresses in V2
   
3. **Extract from orders table** (Fallback)
   - Parse delivery addresses from historical orders
   - More complex, may have duplicates

**User Decision Required:** Which option?

#### BLOCKER 2: Empty V1 Admin Users Table 🟡

**Status:** MEDIUM - May not block migration

**Details:**
- V1 admin_users.csv shows 0 rows
- V1 callcenter_users has 37 rows
- V2 admin_users has 52 rows (current/active)

**Impact:**
- Historical V1 admin accounts not available
- May lose audit trail for old admin actions
- V2 likely has all current admins

**Resolution:**
- Verify if callcenter_users represents all V1 admins
- If yes: Merge callcenter → admin_users with role='callcenter'
- If no: Re-export admin_users from V1 MySQL

### 7.2 Data Quality Warnings (Non-Blocking)

| Issue | Severity | Action Required |
|-------|----------|-----------------|
| Split V1 users CSV (4 parts) | MEDIUM | Combine into single staging table before migration |
| 98% inactive V1 users | LOW | Apply filter: `lastLogin > 2020-01-01` |
| 99.8% expired password reset tokens | LOW | Apply filter: `expires_at > NOW()` |
| Character encoding (V1) | MEDIUM | Verify UTF-8 encoding on CSV load |
| Empty site_users_fb table | LOW | Skip migration, structure only |
| Empty login_attempts table | LOW | Create V3 structure only |

---

## 📝 SECTION 8: MYSQL ROW COUNT QUERY

To verify row counts in the source MySQL databases:

```sql
-- ================================================================
-- Users & Access Entity - Source Table Row Counts
-- Purpose: Get row counts from all V1 and V2 source tables
-- Date: January 7, 2025
-- ================================================================

-- ================================================================
-- SECTION 1: V1 TABLES (menuca_v1 schema)
-- ================================================================

SELECT 
    'menuca_v1' AS schema_name,
    'users' AS table_name,
    COUNT(*) AS row_count,
    'Customer accounts' AS description
FROM menuca_v1.users

UNION ALL

SELECT 
    'menuca_v1',
    'admin_users',
    COUNT(*),
    'Platform administrator accounts'
FROM menuca_v1.admin_users

UNION ALL

SELECT 
    'menuca_v1',
    'callcenter_users',
    COUNT(*),
    'Call center staff accounts'
FROM menuca_v1.callcenter_users

UNION ALL

SELECT 
    'menuca_v1',
    'users_delivery_addresses',
    COUNT(*),
    'User saved delivery addresses'
FROM menuca_v1.users_delivery_addresses

UNION ALL

SELECT 
    'menuca_v1',
    'pass_reset',
    COUNT(*),
    'Password reset tokens (historical)'
FROM menuca_v1.pass_reset

UNION ALL

SELECT 
    'menuca_v1',
    'logintoken',
    COUNT(*),
    'Legacy login tokens'
FROM menuca_v1.logintoken

-- ================================================================
-- SECTION 2: V2 TABLES (menuca_v2 schema)
-- ================================================================

UNION ALL

SELECT 
    'menuca_v2',
    'site_users',
    COUNT(*),
    'Customer accounts (V2)'
FROM menuca_v2.site_users

UNION ALL

SELECT 
    'menuca_v2',
    'admin_users',
    COUNT(*),
    'Admin accounts (V2)'
FROM menuca_v2.admin_users

UNION ALL

SELECT 
    'menuca_v2',
    'admin_users_restaurants',
    COUNT(*),
    'Admin-restaurant access mappings'
FROM menuca_v2.admin_users_restaurants

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_delivery_addresses',
    COUNT(*),
    'User delivery addresses (V2)'
FROM menuca_v2.site_users_delivery_addresses

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_favorite_restaurants',
    COUNT(*),
    'User favorite restaurants'
FROM menuca_v2.site_users_favorite_restaurants

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_fb',
    COUNT(*),
    'OAuth/Facebook user profiles'
FROM menuca_v2.site_users_fb

UNION ALL

SELECT 
    'menuca_v2',
    'site_users_autologins',
    COUNT(*),
    '"Remember me" autologin tokens'
FROM menuca_v2.site_users_autologins

UNION ALL

SELECT 
    'menuca_v2',
    'reset_codes',
    COUNT(*),
    'Password reset codes (V2)'
FROM menuca_v2.reset_codes

UNION ALL

SELECT 
    'menuca_v2',
    'ci_sessions',
    COUNT(*),
    'Active user sessions (ephemeral)'
FROM menuca_v2.ci_sessions

UNION ALL

SELECT 
    'menuca_v2',
    'login_attempts',
    COUNT(*),
    'Failed login attempt log'
FROM menuca_v2.login_attempts

-- ================================================================
-- ORDER BY: Schema first, then table name
-- ================================================================
ORDER BY 
    CASE schema_name 
        WHEN 'menuca_v1' THEN 1 
        WHEN 'menuca_v2' THEN 2 
    END,
    table_name;

-- ================================================================
-- EXPECTED OUTPUT (based on CSV analysis):
-- ================================================================
-- | schema_name | table_name                      | row_count | description                          |
-- |-------------|---------------------------------|-----------|--------------------------------------|
-- | menuca_v1   | admin_users                     |         0 | Platform administrator accounts      |
-- | menuca_v1   | callcenter_users                |        37 | Call center staff accounts           |
-- | menuca_v1   | logintoken                      |         7 | Legacy login tokens                  |
-- | menuca_v1   | pass_reset                      |   203,017 | Password reset tokens (historical)   |
-- | menuca_v1   | users                           |   442,282 | Customer accounts                    |
-- | menuca_v1   | users_delivery_addresses        |   UNKNOWN | User saved delivery addresses        |
-- | menuca_v2   | admin_users                     |        52 | Admin accounts (V2)                  |
-- | menuca_v2   | admin_users_restaurants         |        99 | Admin-restaurant access mappings     |
-- | menuca_v2   | ci_sessions                     |       110 | Active user sessions (ephemeral)     |
-- | menuca_v2   | login_attempts                  |         0 | Failed login attempt log             |
-- | menuca_v2   | reset_codes                     |     3,629 | Password reset codes (V2)            |
-- | menuca_v2   | site_users                      |     8,942 | Customer accounts (V2)               |
-- | menuca_v2   | site_users_autologins           |       890 | "Remember me" autologin tokens       |
-- | menuca_v2   | site_users_delivery_addresses   |    12,045 | User delivery addresses (V2)         |
-- | menuca_v2   | site_users_favorite_restaurants |         1 | User favorite restaurants            |
-- | menuca_v2   | site_users_fb                   |         0 | OAuth/Facebook user profiles         |
-- ================================================================
-- 16 rows in set
-- ================================================================
```

---

## ✅ SECTION 9: NEXT STEPS & RECOMMENDATIONS

### 9.1 Immediate Actions Required

**Priority 1: Resolve Missing Data (CRITICAL)**
1. [ ] **Export V1 users_delivery_addresses** from MySQL
   - OR document decision to skip V1 addresses
2. [ ] **Verify V1 admin_users** - re-export or confirm callcenter_users is complete

**Priority 2: Data Preparation**
3. [ ] Combine 4 V1 users CSV files into single staging table
4. [ ] Run MySQL row count query to verify actual source data
5. [ ] Load all dumps/CSVs into staging schema

**Priority 3: Data Quality Validation**
6. [ ] Execute all 17 validation queries (Section 3-5)
7. [ ] Document actual findings vs expected
8. [ ] Identify and fix data quality issues

**Priority 4: Migration Execution**
9. [ ] Apply filters (active users, active tokens)
10. [ ] Execute email deduplication (V2 wins)
11. [ ] Transform and load to V3 schema
12. [ ] Post-migration validation

### 9.2 Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Missing V1 addresses | HIGH | HIGH | Export from MySQL before migration |
| Email duplication issues | MEDIUM | HIGH | Implement robust deduplication logic |
| Character encoding corruption | MEDIUM | MEDIUM | Verify encoding on load, test samples |
| Orphaned foreign keys | LOW | MEDIUM | Validate FKs during transformation |
| Data loss during filtering | LOW | HIGH | Backup staging before applying filters |

### 9.3 Success Criteria

Migration is successful when:
- [ ] All source tables accounted for (100%)
- [ ] Zero orphaned records in V3
- [ ] Email uniqueness enforced (1 email = 1 account)
- [ ] Active user filter correctly applied (~15k users)
- [ ] All FK relationships valid
- [ ] Password hashes preserved (bcrypt)
- [ ] Zero data loss for active users
- [ ] Post-migration spot checks pass

---

## 📊 APPENDIX A: TABLE RELATIONSHIP DIAGRAM

```
menuca_v3 Schema (Proposed):

┌──────────────────┐
│ users            │◄─────────┐
│ (customer accts) │          │
└────────┬─────────┘          │
         │                    │
         │ 1:N                │ N:1
         ▼                    │
┌──────────────────┐          │
│ user_addresses   │          │
│ (delivery locs)  │          │
└──────────────────┘          │
         │                    │
         │ 1:N                │
         ▼                    │
┌──────────────────┐          │
│ password_reset_  │          │
│ tokens           │          │
└──────────────────┘          │
         │                    │
         │ 1:N                │
         ▼                    │
┌──────────────────┐          │
│ user_autologin_  │          │
│ tokens           │          │
└──────────────────┘          │
         │                    │
         │ N:M                │
         ▼                    │
┌──────────────────┐          │
│ user_favorite_   │──────────┘
│ restaurants      │
└──────────────────┘

┌──────────────────┐
│ admin_users      │
│ (staff accts)    │
└────────┬─────────┘
         │
         │ N:M (via junction)
         ▼
┌──────────────────┐       ┌──────────────┐
│ admin_users_     │──────►│ restaurants  │
│ restaurants      │  N:1  │ (migrated)   │
│ (junction)       │       └──────────────┘
└──────────────────┘
```

---

## 📊 APPENDIX B: DATA VOLUME ANALYSIS

### Pre-Filter Data Volume

| Category | Tables | Rows | Size Est. |
|----------|--------|------|-----------|
| Customer Users | V1 + V2 users | 451,224 | ~200 MB |
| Admin Users | V1 + V2 admin | 89 | <1 MB |
| Addresses | V1 + V2 addresses | ~1.4M + 12k | ~500 MB |
| Auth Tokens | All token tables | 207,543 | ~50 MB |
| **TOTAL** | **16 tables** | **~2.1M rows** | **~750 MB** |

### Post-Filter Data Volume (Target V3)

| Category | Tables | Rows | Reduction |
|----------|--------|------|-----------|
| Customer Users | users | 15,000 | 97% |
| Admin Users | admin_users | 90 | 0% |
| Addresses | user_addresses | 12,000 | 99% |
| Auth Tokens | All token tables | 800 | 99.6% |
| **TOTAL** | **8 tables** | **~28,000** | **98.7%** |

**Storage Savings:** ~750 MB → ~15 MB (98% reduction!)

---

**Report Generated:** January 7, 2025  
**Analyst:** AI Migration Reviewer  
**Status:** 🚨 **AWAITING USER DECISIONS ON BLOCKERS**

**Critical Decisions Required:**
1. ❓ V1 users_delivery_addresses - Export, Skip, or Extract from orders?
2. ❓ V1 admin_users empty - Re-export or use callcenter_users only?


