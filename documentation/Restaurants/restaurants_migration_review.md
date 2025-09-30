## Restaurants Migration Review — Data Integrity Verification

### Purpose
This document provides a comprehensive review of the `menuca_v3.restaurants` migration to verify:
1. **Mapping Compliance**: Does the actual migration follow the mapping conventions defined in `restaurant-management-mapping.md`?
2. **Data Integrity**: Are all source records accounted for? Are there any duplicates, orphans, or data loss?
3. **Data Quality**: Are status mappings, timestamps, and relationships correctly preserved?

---

## 1. Mapping Convention Compliance Analysis

### 1.1 Source Tables Review

**V1 `restaurants` table structure** (lines 1488-1680 in menuca_v1 structure.sql):
- Primary key: `id` (int, AUTO_INCREMENT=1095)
- Key fields: `name`, `active`, `pending`, `suspend_operation`, `suspended_at`, `addedBy`, `addedon`
- Status fields: `active` ENUM('Y','N'), `pending` ENUM('y','n'), `suspend_operation` TINYINT(0/1)
- Timestamps: `addedon` (timestamp), no `updated_at`
- Audit: `addedBy` (int)

**V2 `restaurants` table structure** (lines 988-1040 in menuca_v2 structure.sql):
- Primary key: `id` (int, AUTO_INCREMENT)
- Key fields: `v1_id`, `name`, `active`, `pending`, `suspend_operation`, `suspended_at`, `added_by`, `added_at`, `updated_at`, `updated_by`
- Status fields: `active` ENUM('y','n'), `pending` ENUM('y','n'), `suspend_operation` TINYINT
- Timestamps: `added_at` (timestamp), `updated_at` (timestamp)
- Audit: `added_by` (int), `updated_by` (int)

### 1.2 Target Table Review

**`menuca_v3.restaurants` structure** (lines 41-65 in menuca_v3.sql):
```sql
CREATE TABLE menuca_v3.restaurants (
  id bigint NOT NULL,
  uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
  legacy_v1_id integer,
  legacy_v2_id integer,
  name varchar(255) NOT NULL,
  status restaurant_status DEFAULT 'pending' NOT NULL,
  activated_at timestamp with time zone,
  suspended_at timestamp with time zone,
  closed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by integer,
  updated_at timestamp with time zone,
  updated_by integer
);
```

### 1.3 Mapping Convention vs. Implementation

| Convention (restaurant-management-mapping.md) | Migration Plan Implementation | ✓/✗ | Notes |
|---|---|---|---|
| **legacy_v1_id** from `restaurants_v1.id` | ✓ Step 3A inserts V1 id as `legacy_v1_id` | ✓ | Correct |
| **legacy_v2_id** from `restaurants_v2.id` | ✓ Step 3B/3C sets `legacy_v2_id` | ✓ | Correct |
| **name** prefer V2 when both exist | ✓ Step 3B: `COALESCE(v.name, r.name)` | ✓ | Correct |
| **status** derived from pending/active/suspend | ✓ CASE logic in Steps 3A/B/C | ✓ | **Needs verification** (see below) |
| **activated_at** optional backfill | ⚠ Step 3B sets from `v.added_at` | ⚠ | Convention says "optional"; migration sets it for V2 |
| **suspended_at** from epoch | ✓ `to_timestamp(suspended_at)` | ✓ | Correct |
| **created_at** from `addedon`/`added_at` | ✓ `COALESCE(added_on, now())` | ✓ | Correct |
| **created_by** from `addedBy`/`added_by` | ✓ Direct copy | ✓ | Correct |
| **updated_at** from V2 only | ✓ From `v.updated_at` | ✓ | Correct |
| **updated_by** from V2 only | ✓ From `v.updated_by` | ✓ | Correct |

---

## 2. Status Mapping Logic Review

### 2.1 Defined Convention (restaurant-management-mapping.md lines 41-45):
```
- If `pending` = 'y' -> `pending`
- Else if `active` = 'Y' (v1) or 'y' (v2) -> `active`
- Else if `suspend_operation` in ('1','y') -> `suspended`
- Else -> `inactive`
```

### 2.2 Implemented Logic (restaurants migration plan.md lines 108-113, 141-146):

**V1 mapping:**
```sql
CASE
  WHEN COALESCE(NULLIF(pending,''),'n')          IN ('y','Y','1') THEN 'pending'
  WHEN COALESCE(NULLIF(active,''),'n')           IN ('y','Y','1') THEN 'active'
  WHEN COALESCE(NULLIF(suspend_operation,''),'n') IN ('y','1') OR suspended_at IS NOT NULL THEN 'suspended'
  ELSE 'inactive'
END
```

**V2 mapping:**
```sql
CASE
  WHEN COALESCE(NULLIF(v.pending,''),'n')          IN ('y','Y','1') THEN 'pending'
  WHEN COALESCE(NULLIF(v.active,''),'n')           IN ('y','Y','1') THEN 'active'
  WHEN COALESCE(NULLIF(v.suspend_operation,''),'n') IN ('y','1') OR v.suspended_at IS NOT NULL THEN 'suspended'
  ELSE 'inactive'
END
```

### 2.3 Analysis

| Aspect | Convention | Implementation | Status |
|---|---|---|---|
| Precedence order | pending → active → suspended → inactive | ✓ Same | ✓ |
| Pending match | 'y' | 'y','Y','1' | ⚠ **Over-inclusive** |
| Active match (V1) | 'Y' | 'y','Y','1' | ⚠ **V1 uses 'Y' per schema, not 'y'** |
| Active match (V2) | 'y' | 'y','Y','1' | ⚠ **Over-inclusive** |
| Suspended match | '1','y' | 'y','1' OR suspended_at IS NOT NULL | ⚠ **Adds timestamp check (good)** |
| Default | 'inactive' | 'inactive' | ✓ |

**Issue Found:**
- Convention says V1 `active` = **'Y'** (uppercase), but implementation checks both 'Y' and 'y'
- V2 schema defines `active` ENUM('y','n'), so lowercase is correct for V2
- V1 schema defines `active` ENUM('Y','N'), so uppercase is correct for V1

**Recommendation:** Update verification query to check if any V1 records have `active='y'` (lowercase) that would be misclassified.

---

## 3. Data Integrity Verification Queries

### 3.1 Row Count Verification

**Expected formula** (from migration plan lines 210-213):
```sql
expected_v3_rows = 
  (v1_restaurants count) 
  + (v2_restaurants where v1_id IS NULL) 
  + (v2_restaurants where v1_id NOT IN (v1_restaurants.id))
```

**Run this query:**
```sql
WITH v2_linked AS (
  SELECT COUNT(*) AS c 
  FROM staging.v2_restaurants v 
  JOIN staging.v1_restaurants r ON r.id = v.v1_id
),
v2_unlinked AS (
  SELECT COUNT(*) AS c 
  FROM staging.v2_restaurants v 
  WHERE v.v1_id IS NULL
),
v2_orphaned AS (
  SELECT COUNT(*) AS c 
  FROM staging.v2_restaurants v 
  WHERE v.v1_id IS NOT NULL 
    AND v.v1_id NOT IN (SELECT id FROM staging.v1_restaurants)
)
SELECT
  (SELECT COUNT(*) FROM staging.v1_restaurants) AS v1_rows,
  (SELECT c FROM v2_linked)                     AS v2_linked_rows,
  (SELECT c FROM v2_unlinked)                   AS v2_unlinked_rows,
  (SELECT c FROM v2_orphaned)                   AS v2_orphaned_rows,
  (SELECT COUNT(*) FROM menuca_v3.restaurants)  AS v3_actual_rows,
  ((SELECT COUNT(*) FROM staging.v1_restaurants)
   + (SELECT c FROM v2_unlinked)
   + (SELECT c FROM v2_orphaned)
  ) AS v3_expected_rows,
  (SELECT COUNT(*) FROM menuca_v3.restaurants) - 
  ((SELECT COUNT(*) FROM staging.v1_restaurants)
   + (SELECT c FROM v2_unlinked)
   + (SELECT c FROM v2_orphaned)
  ) AS row_difference;
```

**Expected Outcome:**
- `v3_actual_rows` = `v3_expected_rows`
- `row_difference` = 0

### 3.2 Uniqueness Verification

**V1 Legacy ID uniqueness:**
```sql
SELECT legacy_v1_id, COUNT(*) AS dup_count
FROM menuca_v3.restaurants
WHERE legacy_v1_id IS NOT NULL
GROUP BY legacy_v1_id 
HAVING COUNT(*) > 1;
```
**Expected:** 0 rows (no duplicates)

**V2 Legacy ID uniqueness:**
```sql
SELECT legacy_v2_id, COUNT(*) AS dup_count
FROM menuca_v3.restaurants
WHERE legacy_v2_id IS NOT NULL
GROUP BY legacy_v2_id 
HAVING COUNT(*) > 1;
```
**Expected:** 0 rows (no duplicates)

### 3.3 Data Loss Detection

**Missing V1 records:**
```sql
SELECT v1.id, v1.name
FROM staging.v1_restaurants v1
LEFT JOIN menuca_v3.restaurants v3 ON v3.legacy_v1_id = v1.id
WHERE v3.id IS NULL;
```
**Expected:** 0 rows (all V1 should be present)

**Missing V2 records that should be linked:**
```sql
SELECT v2.id, v2.v1_id, v2.name
FROM staging.v2_restaurants v2
LEFT JOIN menuca_v3.restaurants v3 
  ON (v3.legacy_v2_id = v2.id OR (v2.v1_id IS NOT NULL AND v3.legacy_v1_id = v2.v1_id))
WHERE v3.id IS NULL;
```
**Expected:** 0 rows (all V2 should be present or linked)

### 3.4 NULL Name Detection

```sql
SELECT id, legacy_v1_id, legacy_v2_id, status
FROM menuca_v3.restaurants 
WHERE name IS NULL OR TRIM(name) = '';
```
**Expected:** 0 rows (name is NOT NULL per schema)

### 3.5 Status Distribution Verification

```sql
SELECT status, COUNT(*) AS count
FROM menuca_v3.restaurants 
GROUP BY status 
ORDER BY count DESC;
```

**Expected:** Reasonable distribution across `pending`, `active`, `suspended`, `inactive`.

**Cross-check V1 source:**
```sql
SELECT 
  CASE
    WHEN COALESCE(NULLIF(pending,''),'n')          IN ('y','Y','1') THEN 'pending'
    WHEN COALESCE(NULLIF(active,''),'n')           IN ('y','Y','1') THEN 'active'
    WHEN COALESCE(NULLIF(suspend_operation,''),'n') IN ('y','1') OR suspended_at IS NOT NULL THEN 'suspended'
    ELSE 'inactive'
  END AS status_v1,
  COUNT(*) AS count_v1
FROM staging.v1_restaurants
GROUP BY 1;
```

**Cross-check V2 source:**
```sql
SELECT 
  CASE
    WHEN COALESCE(NULLIF(pending,''),'n')          IN ('y','Y','1') THEN 'pending'
    WHEN COALESCE(NULLIF(active,''),'n')           IN ('y','Y','1') THEN 'active'
    WHEN COALESCE(NULLIF(suspend_operation,''),'n') IN ('y','1') OR suspended_at IS NOT NULL THEN 'suspended'
    ELSE 'inactive'
  END AS status_v2,
  COUNT(*) AS count_v2
FROM staging.v2_restaurants
GROUP BY 1;
```

Compare these distributions with `menuca_v3.restaurants` to identify discrepancies.

### 3.6 V2 Update Verification

**Check that V2 data properly updated V1 baseline:**
```sql
SELECT 
  r.id,
  r.legacy_v1_id,
  r.legacy_v2_id,
  r.name,
  r.status,
  r.suspended_at,
  r.updated_at,
  r.updated_by
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IS NOT NULL 
  AND r.legacy_v2_id IS NOT NULL
ORDER BY r.id
LIMIT 50;
```

**Verify:**
- `name` should reflect V2 value (per convention "prefer V2")
- `status` should reflect V2 status
- `suspended_at` should reflect V2 if present
- `updated_at`/`updated_by` should be from V2

**Spot-check specific case:**
```sql
-- Pick a known V1/V2 pair and verify all fields
SELECT 
  'V1' AS source, v1.id, v1.name, v1.active, v1.pending, v1.suspend_operation, v1.suspended_at, v1.added_on, v1.added_by
FROM staging.v1_restaurants v1
WHERE v1.id = 308 -- example from earlier conversation
UNION ALL
SELECT 
  'V2' AS source, v2.id, v2.name, v2.active, v2.pending, v2.suspend_operation, v2.suspended_at, v2.added_at, v2.added_by
FROM staging.v2_restaurants v2
WHERE v2.v1_id = 308
UNION ALL
SELECT 
  'V3' AS source, r.id, r.name, r.status::text, NULL, NULL, EXTRACT(EPOCH FROM r.suspended_at)::bigint, r.created_at, r.created_by
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id = 308;
```

### 3.7 Timestamp Conversion Verification

**Check `suspended_at` epoch-to-timestamp conversion:**
```sql
SELECT 
  r.legacy_v1_id,
  v1.suspended_at AS v1_epoch,
  r.suspended_at AS v3_timestamp,
  to_timestamp(v1.suspended_at) AS expected_timestamp,
  (r.suspended_at = to_timestamp(v1.suspended_at)) AS matches
FROM menuca_v3.restaurants r
JOIN staging.v1_restaurants v1 ON v1.id = r.legacy_v1_id
WHERE v1.suspended_at IS NOT NULL AND v1.suspended_at > 0
LIMIT 20;
```

**Expected:** All `matches` = TRUE

---

## 4. Identified Issues and Recommendations

### 4.1 Status Mapping: V1 Active Case Sensitivity

**Issue:**
- V1 schema defines `active` ENUM('Y','N') — uppercase
- Implementation checks for both 'Y' and 'y'

**Recommendation:**
Run this query to check for any lowercase 'y' in V1 active field:
```sql
SELECT id, name, active, pending, suspend_operation
FROM staging.v1_restaurants
WHERE active = 'y';  -- lowercase, which shouldn't exist per schema
```

If results are found, determine if this is a data quality issue or schema documentation error.

### 4.2 Missing Verification for `activated_at`

**Issue:**
- Convention says `activated_at` is "optional backfill from business events"
- Migration sets it from `v.added_at` for V2 in Step 3B (line 154)

**Recommendation:**
Clarify intent:
- If `activated_at` should truly be NULL until a separate "activation event" is logged, remove line 154
- If `added_at` is a reasonable proxy for activation, update the convention to reflect this

### 4.3 V2 Orphaned Records

**Issue:**
- V2 records with `v1_id` pointing to non-existent V1 records will be treated as "unlinked" by Step 3C

**Recommendation:**
Run the orphan detection query from 3.3 and investigate any results:
```sql
SELECT v2.id, v2.v1_id, v2.name
FROM staging.v2_restaurants v2
WHERE v2.v1_id IS NOT NULL 
  AND v2.v1_id NOT IN (SELECT id FROM staging.v1_restaurants);
```

---

## 5. Pre-Admin Migration Checklist

Before proceeding with `restaurant_admin_users` migration:

- [ ] **Run all Section 3 verification queries**
- [ ] **Confirm row counts match expected formula**
- [ ] **Verify no duplicate legacy IDs**
- [ ] **Verify no missing V1/V2 records**
- [ ] **Verify no NULL names**
- [ ] **Verify status distribution is reasonable**
- [ ] **Verify V2 updates are reflected correctly**
- [ ] **Verify timestamp conversions are accurate**
- [ ] **Investigate and resolve any orphaned V2 records**
- [ ] **Document any data quality issues found**

---

## 6. Summary

### Strengths of Current Migration:
✅ Clear three-phase approach (V1 baseline, V2 update, V2 new)  
✅ Idempotent with `ON CONFLICT DO NOTHING`  
✅ Comprehensive verification queries provided  
✅ Preserves audit trail with legacy IDs  
✅ Status mapping logic handles complex enum combinations  

### Areas Requiring Attention:
⚠️ Status mapping case sensitivity (V1 'Y' vs 'y')  
⚠️ Clarify `activated_at` population intent  
⚠️ Handle V2 orphaned records (v1_id pointing to missing V1 rows)  

### Recommendation:
**Execute Section 5 checklist before proceeding with `restaurant_admin_users` migration.** The `restaurant_id` FK in admin_users depends on the integrity of `menuca_v3.restaurants.id` and its legacy ID mappings.

---

**Next Steps:**
1. Run verification queries from Section 3
2. Address any issues found in Section 4
3. Document actual row counts and status distributions
4. Once verified, proceed with `restaurant_admin_users` migration plan

