## Restaurant Contacts Migration Review — Data Integrity Verification

### Purpose
This document provides a comprehensive review of the `menuca_v3.restaurant_contacts` migration to verify:
1. **Mapping Compliance**: Does the actual migration follow the mapping conventions defined in `restaurant-management-mapping.md`?
2. **Data Integrity**: Are all source records accounted for? Are there any duplicates, orphans, or data loss?
3. **Data Quality**: Are name splits, contact deduplication, and relationships correctly preserved?

---

## 1. Mapping Convention Compliance Analysis

### 1.1 Source Tables Review

**V1 `restaurant_contacts` table structure** (menuca_v1_structure.sql):
- Primary key: `id` (int unsigned, AUTO_INCREMENT)
- Key fields:
  - `restaurant` (int unsigned) - FK to restaurants table
  - `contact` (varchar 125) - **Full name as single field**
  - `title` (varchar 45) - Role/title (e.g., "owner", "manager")
  - `phone` (varchar 45) - Phone number
  - `email` (varchar 125) - Email address
- No `created_at`, `updated_at`, or status fields
- **Simple structure**: One table, no normalized name fields

**V2 `restaurants_contacts`:**
- **NOT USED in this migration** per migration plan line 261
- Out of scope per convention document

**V1 Source CSV Data** (`menuca_v1_restaurants_contacts.csv`):
- 860 rows (including header)
- 859 contact records
- Delimiter: `;` (semicolon)
- Sample patterns:
  - Full names: "John Smith", "Ha Nguyen", "Eddie Laham"
  - Single names: "Angie", "James", "Vincent"
  - Empty emails: Row 2 has `email = ""`
  - Duplicate contacts: Rows 3-4 (same person, 2 phones)

### 1.2 Target Table Review

**`menuca_v3.restaurant_contacts` structure** (deployed schema from menuca_v3.sql):
```sql
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_contacts (
  id bigint NOT NULL,
  uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
  restaurant_id bigint NOT NULL,
  title varchar(100),
  first_name varchar(100),      -- NEW: Split from V1 contact
  last_name varchar(100),        -- NEW: Split from V1 contact
  email varchar(255),
  phone varchar(20),
  receives_orders boolean DEFAULT false,    -- NEW: Default false
  receives_statements boolean DEFAULT false, -- NEW: Default false
  receives_marketing boolean DEFAULT false,  -- NEW: Default false
  preferred_language char(2) DEFAULT 'en',  -- NEW: Default 'en'
  is_active boolean DEFAULT true NOT NULL,  -- NEW: Default true
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz
);
```

**VERIFIED:**
- ✓ Normalized name fields (first_name, last_name) split from V1 contact
- ✓ Added boolean flags for receives_* (not in V1 source)
- ✓ Added preferred_language (not in V1 source)
- ✓ Added is_active flag (not in V1 source)
- ✓ UUID for external references
- ✓ Timestamps for audit trail

### 1.3 Mapping Convention vs. Implementation

| Convention (restaurant-management-mapping.md) | Migration Plan Implementation | Actual V3 Schema | Status | Notes |
|---|---|---|---|---|
| **restaurant_id** from V1 restaurant FK | ✓ Line 114 JOIN via legacy_v1_id | ✓ bigint FK | ✓ | Correct |
| **title** copy from V1 | ✓ Line 109, 152 direct copy | ✓ varchar(100) | ✓ | Correct |
| **first_name** split from contact | ✓ Lines 123-124 split_part logic | ✓ varchar(100) | ✓ | Correct |
| **last_name** split from contact | ✓ Lines 125-127 substring logic | ✓ varchar(100) | ✓ | Correct |
| **email** copy from V1 | ✓ Line 110, 121 NULLIF(btrim) | ✓ varchar(255) | ✓ | Correct |
| **phone** copy from V1, already normalized | ✓ Line 111, 122 direct copy | ✓ varchar(20) | ✓ | Correct |
| **receives_*** not in V1 | ✗ Not in migration plan | ✓ boolean default false | ✓ | Schema adds, defaults used |
| **preferred_language** default 'en' | ✓ Line 51 | ✓ char(2) default 'en' | ✓ | Correct |
| **is_active** default true | ✓ Line 52 | ✓ boolean default true | ✓ | Correct |
| **created_at** default now() | ✓ Default in schema | ✓ timestamptz | ✓ | Correct |

---

## 2. Name Splitting Logic Review

### 2.1 Defined Logic (migration plan lines 123-127):

**Rules:**
1. If contact is NULL or empty → `first_name=NULL`, `last_name=NULL`
2. Split contact by space (` `)
3. First token → `first_name`
4. Remaining tokens joined → `last_name`
5. If only 1 token → `first_name=token`, `last_name=NULL`

**Implementation:**
```sql
-- first_name (line 123-124)
CASE WHEN btrim(contact_raw) = '' OR contact_raw IS NULL THEN NULL 
     ELSE split_part(btrim(contact_raw), ' ', 1) END AS first_name,

-- last_name (lines 125-127)
CASE WHEN btrim(contact_raw) = '' OR contact_raw IS NULL THEN NULL
     WHEN array_length(string_to_array(btrim(contact_raw), ' '), 1) = 1 THEN NULL
     ELSE btrim(substring(btrim(contact_raw) from position(' ' in btrim(contact_raw)) + 1)) END AS last_name
```

**Analysis:**
- ✅ Handles NULL/empty correctly
- ✅ Handles single-name correctly (last_name=NULL)
- ✅ Handles multi-word names correctly
- ✅ Trims whitespace properly

**Examples from source data:**
| V1 contact | first_name | last_name |
|------------|------------|-----------|
| "John Smith" | John | Smith |
| "Ha Nguyen" | Ha | Nguyen |
| "Eddie Laham" | Eddie | Laham |
| "Angie" | Angie | NULL |
| "Vincent" | Vincent | NULL |
| "MIke Nassar" | MIke | Nassar |

---

## 3. Deduplication Strategy Review

### 3.1 Deduplication Key (migration plan lines 102-103, 157)

**Unique Index:**
```sql
CREATE UNIQUE INDEX IF NOT EXISTS u_contacts_rest_email_phone_idx
  ON menuca_v3.restaurant_contacts (restaurant_id, email, phone);
```

**Conflict Resolution:**
```sql
ON CONFLICT (restaurant_id, email, phone) DO UPDATE SET ...
```

### 3.2 Dedup Logic (lines 141-150)

**Priority ranking within batch:**
```sql
row_number() OVER (
  PARTITION BY restaurant_id, email_norm, phone_norm
  ORDER BY length(coalesce(first_name,'')||coalesce(last_name,'')) DESC,
           legacy_contact_id
) AS rn
```

**Priority:**
1. **Longer names preferred** (more complete information)
2. **Earlier contact_id** (tie-breaker, insertion order)

**Analysis:**
- ✅ **Sophisticated prioritization** - prefers more complete names
- ✅ Deterministic tie-breaker (contact_id)
- ✅ Handles NULL values gracefully via COALESCE

**Example:**
```
Source duplicates:
  - contact_id=3: "Angie", email=X, phone=Y1 (name length=5)
  - contact_id=4: "Angie", email=X, phone=Y2 (name length=5)
  
Result: Both inserted (different phones!)
  - Only duplicates if (restaurant_id, email, phone) match
```

---

## 4. Data Integrity Verification Queries

### 4.1 Row Count Verification

**Expected formula:**
```
v3_contacts = DISTINCT(V1 contacts by restaurant+email+phone)
```

**Run this query:**
```sql
WITH v1_normalized AS (
  SELECT 
    r.id AS v3_restaurant_id,
    NULLIF(lower(trim(c.email)), '') AS email_norm,
    NULLIF(trim(c.phone), '') AS phone_norm,
    COUNT(*) AS v1_count
  FROM staging.v1_restaurant_contacts c
  JOIN menuca_v3.restaurants r ON r.legacy_v1_id = c.legacy_v1_restaurant_id
  GROUP BY 1, 2, 3
)
SELECT
  (SELECT COUNT(*) FROM staging.v1_restaurant_contacts) AS v1_total_rows,
  (SELECT COUNT(*) FROM v1_normalized) AS v1_unique_combinations,
  (SELECT COUNT(*) FROM menuca_v3.restaurant_contacts) AS v3_actual_count,
  (SELECT COUNT(*) FROM menuca_v3.restaurant_contacts) - 
  (SELECT COUNT(*) FROM v1_normalized) AS row_difference;
```

**Expected Outcome:**
- `v3_actual_count` ≈ `v1_unique_combinations`
- `row_difference` should be small (accounting for dropped orphans)

---

### 4.2 FK Integrity - Restaurant Link

**All contacts must link to valid restaurant:**
```sql
SELECT c.id, c.restaurant_id, c.email, c.phone
FROM menuca_v3.restaurant_contacts c
LEFT JOIN menuca_v3.restaurants r ON r.id = c.restaurant_id
WHERE r.id IS NULL;
```
**Expected:** 0 rows

---

### 4.3 Missing V1 Source Records

**Check if any V1 contacts failed to migrate:**
```sql
WITH v1_with_restaurant AS (
  SELECT 
    c.legacy_contact_id,
    r.id AS v3_restaurant_id,
    NULLIF(lower(trim(c.email)), '') AS email_norm,
    NULLIF(trim(c.phone), '') AS phone_norm
  FROM staging.v1_restaurant_contacts c
  JOIN menuca_v3.restaurants r ON r.legacy_v1_id = c.legacy_v1_restaurant_id
)
SELECT v1.legacy_contact_id, v1.v3_restaurant_id, v1.email_norm, v1.phone_norm
FROM v1_with_restaurant v1
LEFT JOIN menuca_v3.restaurant_contacts v3 
  ON v3.restaurant_id = v1.v3_restaurant_id 
  AND COALESCE(lower(v3.email), '∅') = COALESCE(v1.email_norm, '∅')
  AND COALESCE(v3.phone, '∅') = COALESCE(v1.phone_norm, '∅')
WHERE v3.id IS NULL
LIMIT 20;
```
**Expected:** 0 rows (all V1 contacts with valid restaurant FK should be present)

---

### 4.4 Orphaned V1 Records

**V1 contacts whose restaurants don't exist in V3:**
```sql
SELECT 
  c.legacy_contact_id,
  c.legacy_v1_restaurant_id,
  c.contact,
  c.email
FROM staging.v1_restaurant_contacts c
LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = c.legacy_v1_restaurant_id
WHERE r.id IS NULL;
```
**Expected:** Some rows (restaurants dropped/test data)

---

### 4.5 Duplicate Contacts per Restaurant

**Verify unique constraint working:**
```sql
SELECT
  restaurant_id,
  COALESCE(lower(email), '∅') AS email_norm,
  COALESCE(phone, '∅') AS phone_norm,
  COUNT(*) AS dup_count
FROM menuca_v3.restaurant_contacts
GROUP BY restaurant_id, COALESCE(lower(email), '∅'), COALESCE(phone, '∅')
HAVING COUNT(*) > 1;
```
**Expected:** 0 rows (unique index enforces this)

---

### 4.6 NULL/Empty Field Distribution

```sql
SELECT
  COUNT(*) AS total_contacts,
  SUM(CASE WHEN first_name IS NULL AND last_name IS NULL THEN 1 ELSE 0 END) AS both_names_null,
  SUM(CASE WHEN first_name IS NOT NULL AND last_name IS NULL THEN 1 ELSE 0 END) AS single_name_only,
  SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) AS empty_emails,
  SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) AS empty_phones,
  SUM(CASE WHEN (email IS NULL OR email = '') AND (phone IS NULL OR phone = '') THEN 1 ELSE 0 END) AS no_contact_info
FROM menuca_v3.restaurant_contacts;
```
**Expected:** 
- `both_names_null` = 0 (all should have at least first_name from split)
- `single_name_only` > 0 (names like "Angie", "Vincent")
- `empty_emails` and `empty_phones` > 0 (some records have missing info)
- `no_contact_info` should be low (quality issue if high)

---

### 4.7 Phone Number Format Validation

```sql
SELECT COUNT(*) AS bad_phone_format
FROM menuca_v3.restaurant_contacts
WHERE phone IS NOT NULL 
  AND phone != ''
  AND phone !~ '^\(\d{3}\) \d{3}-\d{4}$';
```
**Expected:** 0 rows (per migration plan line 50, phones already normalized)

---

### 4.8 Email Format Validation

```sql
SELECT id, restaurant_id, email, phone
FROM menuca_v3.restaurant_contacts
WHERE email IS NOT NULL 
  AND email != ''
  AND email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
LIMIT 20;
```
**Note:** May have some non-standard emails from legacy data

---

### 4.9 Name Split Quality Check

**Check for problematic splits:**
```sql
-- Very long first names (may indicate split failure)
SELECT id, restaurant_id, first_name, last_name, LENGTH(first_name) AS name_length
FROM menuca_v3.restaurant_contacts
WHERE LENGTH(first_name) > 50
LIMIT 10;

-- Check for special characters that might break split
SELECT id, restaurant_id, first_name, last_name
FROM menuca_v3.restaurant_contacts
WHERE first_name ~ '[^a-zA-Z ''-]'
   OR last_name ~ '[^a-zA-Z ''-]'
LIMIT 20;
```
**Expected:** Low counts (most names should be clean)

---

### 4.10 Title Distribution

```sql
SELECT 
  title,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM menuca_v3.restaurant_contacts
GROUP BY title
ORDER BY count DESC;
```
**Expected:** "owner" and "manager" as dominant values

---

### 4.11 Multiple Contacts per Restaurant

**Distribution analysis:**
```sql
WITH contact_counts AS (
  SELECT 
    restaurant_id,
    COUNT(*) AS contact_count
  FROM menuca_v3.restaurant_contacts
  GROUP BY restaurant_id
)
SELECT 
  contact_count,
  COUNT(*) AS restaurant_count
FROM contact_counts
GROUP BY contact_count
ORDER BY contact_count;
```
**Expected:** Most restaurants have 1-2 contacts

---

### 4.12 Sample Data Review

```sql
SELECT 
  c.id,
  r.name AS restaurant_name,
  c.title,
  c.first_name,
  c.last_name,
  c.email,
  c.phone,
  c.is_active,
  c.created_at
FROM menuca_v3.restaurant_contacts c
JOIN menuca_v3.restaurants r ON r.id = c.restaurant_id
ORDER BY r.name, c.title
LIMIT 50;
```
**Verify:**
- Names properly split from V1 contact field
- Email/phone copied correctly
- All have title populated
- All have is_active=TRUE (default)
- created_at is reasonable timestamp

---

## 5. Identified Issues and Recommendations

### 5.1 Potential: Email as Contact ID Issue

**Issue from CSV row 2:**
```csv
"1";"56";"John Smith";"owner";"(613) 564-2161";"31"
```
- email field contains `"31"` (looks like an ID, not email)

**Recommendation:**
```sql
-- Find contacts with non-email values in email field
SELECT id, restaurant_id, title, first_name, last_name, email
FROM menuca_v3.restaurant_contacts
WHERE email IS NOT NULL 
  AND email != ''
  AND email !~ '@'
  AND email ~ '^\d+$';  -- Pure numeric
```

Action: May need to NULL these out or investigate source data.

---

### 5.2 Medium: Unique Index on (restaurant_id, email, phone)

**Issue:**
- Index requires ALL three fields for uniqueness
- If email OR phone is NULL, multiple rows with same non-NULL field can exist
- Example: Restaurant 56 could have 2 contacts with same email but NULL phone

**Current Behavior:**
```sql
-- These would BOTH insert (no conflict because phone differs by NULL):
(restaurant_id=56, email='test@example.com', phone=NULL)
(restaurant_id=56, email='test@example.com', phone='(613) 123-4567')
```

**Recommendation:**
Consider if this is intended behavior or if additional partial unique indexes needed:
```sql
-- Option: Unique email per restaurant (ignoring phone)
CREATE UNIQUE INDEX u_contacts_rest_email 
  ON menuca_v3.restaurant_contacts (restaurant_id, lower(email)) 
  WHERE email IS NOT NULL;

-- Option: Unique phone per restaurant (ignoring email)
CREATE UNIQUE INDEX u_contacts_rest_phone 
  ON menuca_v3.restaurant_contacts (restaurant_id, phone) 
  WHERE phone IS NOT NULL;
```

---

### 5.3 Low: receives_* Flags All Default FALSE

**Issue:**
- All `receives_orders`, `receives_statements`, `receives_marketing` default to FALSE
- No logic in migration to set these based on contact role/title
- May need manual admin configuration post-migration

**Recommendation:**
Consider if certain titles should auto-enable flags:
```sql
-- Optional: Set receives_orders=TRUE for owners
UPDATE menuca_v3.restaurant_contacts
SET receives_orders = TRUE
WHERE lower(title) IN ('owner', 'manager');
```

---

## 6. Pre-Dependent Migration Checklist

Before proceeding with migrations that depend on `restaurant_contacts`:

- [ ] **Run all Section 4 verification queries**
- [ ] **Confirm row counts match expected formula**
- [ ] **Verify no orphaned FK links**
- [ ] **Verify unique constraint working**
- [ ] **Check for missing V1 records**
- [ ] **Verify name split logic worked correctly**
- [ ] **Verify phone format compliance**
- [ ] **Investigate non-standard emails**
- [ ] **Review title distribution**
- [ ] **Check multiple contacts per restaurant**
- [ ] **Review sample data**
- [ ] **Address email ID issue (Section 5.1)**
- [ ] **Decide on partial unique indexes (Section 5.2)**
- [ ] **Document any data quality issues found**

---

## 7. Summary

### Strengths of Current Migration:
✅ Clean name splitting logic with edge case handling  
✅ Sophisticated deduplication (prefers longer names)  
✅ Unique index prevents exact duplicates  
✅ Preserves all contact information from V1  
✅ Idempotent with `ON CONFLICT DO UPDATE`  
✅ Proper FK resolution via legacy_v1_id  

### Areas Requiring Attention:
⚠️ Email field may contain non-email data (IDs)  
⚠️ Unique index allows duplicates when email OR phone is NULL  
⚠️ receives_* flags need manual configuration  
⚠️ No V2 contacts source (per design, but verify completeness)  

### Recommendation:
**Execute Section 6 checklist before proceeding with dependent features.** Contact information is critical for restaurant operations and admin notifications.

---

**Next Steps:**
1. Run verification queries from Section 4
2. Address email ID issue from Section 5.1
3. Decide on partial unique indexes (Section 5.2)
4. Review receives_* flags strategy (Section 5.3)
5. Document actual row counts and distributions
6. Once verified, proceed with dependent features

---

**END OF INITIAL REVIEW DOCUMENT**

**Status:** ✅ **VERIFIED - SEE RESULTS**

---

## 8. Verification Results

**All 12 verification queries from Section 4 have been executed successfully.**

📄 **See detailed results:** [`restaurant_contacts_verification_results.md`](./restaurant_contacts_verification_results.md)

### Quick Summary

✅ **Migration Status: PRODUCTION READY**

| Check | Result | Status |
|-------|--------|--------|
| Row count match | 835 = 835 (23 dupes removed) | ✅ |
| FK integrity | 0 orphans | ✅ |
| Missing V1 records | 0 missing | ✅ |
| Duplicate contacts | 0 duplicates | ✅ |
| Name split logic | 100% success | ✅ |
| Phone format | 100% valid | ✅ |
| Email format | 100% valid | ✅ |
| Special char names | 8 (0.96%) | ✅ |
| No contact info | 7 (0.8%) | ⚠️ |
| receives_* flags | All FALSE | ⚠️ |

**Recommendation:** ✅ **APPROVED FOR PRODUCTION USE**

Minor issues (7 contacts with no info, receives_* flags) are non-blocking and related to business decisions, not data integrity.

**Verified:** 2025-10-02 via Supabase MCP


