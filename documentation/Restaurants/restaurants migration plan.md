## Migration Plan: menuca_v3.restaurants (Supabase-ready)

This document provides a clear, repeatable process to migrate Restaurant records from MySQL V1/V2 dumps into `menuca_v3.restaurants` in Supabase/Postgres.

### 0) Preconditions

- Ensure the `menuca_v3` schema and `menuca_v3.restaurants` table exist (see `SQL/menuca_v3.sql`).
- Ensure the enum `public.restaurant_status` exists:

```sql
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'restaurant_status') THEN
    CREATE TYPE public.restaurant_status AS ENUM ('pending','active','suspended','inactive','closed');
  END IF;
END$$;
```

### 1) Create Staging Schema and Tables (in Supabase/Postgres)

Use staging tables to import raw V1/V2 restaurant data before mapping to v3.

```sql
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.v1_restaurants;
CREATE TABLE staging.v1_restaurants (
  id                integer PRIMARY KEY,
  name              text,
  pending           text,      -- 'y'/'n' or 'Y'/'N'
  active            text,      -- 'y'/'n' or 'Y'/'N'
  suspend_operation text,      -- '1'/'0' or 'y'/'n'
  suspended_at      bigint,    -- epoch seconds if present
  added_on          timestamptz,
  updated_at        timestamptz,
  added_by          integer,
  updated_by        integer
);

DROP TABLE IF EXISTS staging.v2_restaurants;
CREATE TABLE staging.v2_restaurants (
  id                 integer PRIMARY KEY,
  v1_id              integer,
  name               text NOT NULL,
  pending            text,        -- 'y'/'n'
  active             text,        -- 'y'/'n'
  suspend_operation  text,        -- '1'/'0' or 'y'/'n'
  suspended_at       bigint,      -- epoch seconds, NULL if none
  added_at           timestamptz, -- v2.added_at
  updated_at         timestamptz,
  added_by           integer,
  updated_by         integer
);
```

### 2) Load Data into Staging

- Recommended (CSV via Workbench Result Grid with UTF‑8):
  - Export `SELECT * FROM menuca_v1.restaurants;` and `menuca_v2.restaurants;` as UTF‑8 CSV.
  - Import into staging with COPY:

```sql
-- V1 CSV columns (header): id;added_by;added_on;name;active;pending;suspend_operation;suspended_at
COPY staging.v1_restaurants (
  id,
  added_by,
  added_on,
  name,
  active,
  pending,
  suspend_operation,
  suspended_at
)
FROM 'Database/Restaurant Management Entity/restaurants/CSV/menuca_v1_restaurants.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';', QUOTE '"', NULL '');

-- V2 CSV columns (header): id;v1_id;added_by;added_at;suspend_operation;suspended_at;name;active;pending;updated_at;updated_by
COPY staging.v2_restaurants (
  id,
  v1_id,
  added_by,
  added_at,
  suspend_operation,
  suspended_at,
  name,
  active,
  pending,
  updated_at,
  updated_by
)
FROM 'Database/Restaurant Management Entity/restaurants/CSV/menuca_v2_restaurants.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';', QUOTE '"', NULL '');
```


### 3) Migrate to menuca_v3.restaurants

Run in a transaction the first time. The logic is: insert V1 baseline; update with V2 where `v2.v1_id` links a V1; then insert remaining V2 that don’t link to V1.

```sql
BEGIN;

-- A) Insert from V1 (baseline)
WITH v1_map AS (
  SELECT
    id,
    name,
    CASE
      WHEN COALESCE(NULLIF(pending,''),'n')          IN ('y','Y','1') THEN 'pending'
      WHEN COALESCE(NULLIF(active,''),'n')           IN ('y','Y','1') THEN 'active'
      WHEN COALESCE(NULLIF(suspend_operation,''),'n') IN ('y','1') OR suspended_at IS NOT NULL THEN 'suspended'
      ELSE 'inactive'
    END::public.restaurant_status AS status_mapped,
    added_on,
    updated_at,
    added_by,
    updated_by,
    suspended_at
  FROM staging.v1_restaurants
)
INSERT INTO menuca_v3.restaurants (
  legacy_v1_id, name, status, activated_at, suspended_at, closed_at,
  created_at, created_by, updated_at, updated_by
)
SELECT
  id AS legacy_v1_id,
  name,
  status_mapped,
  NULL::timestamptz AS activated_at,
  CASE WHEN suspended_at IS NOT NULL AND suspended_at > 0 THEN to_timestamp(suspended_at) END AS suspended_at,
  NULL::timestamptz AS closed_at,
  COALESCE(added_on, now()) AS created_at,
  added_by,
  updated_at,
  updated_by
FROM v1_map
ON CONFLICT DO NOTHING;

-- B) Update existing rows using V2 where v2.v1_id matches legacy_v1_id
WITH v2_map AS (
  SELECT v.*, CASE
    WHEN COALESCE(NULLIF(v.pending,''),'n')          IN ('y','Y','1') THEN 'pending'
    WHEN COALESCE(NULLIF(v.active,''),'n')           IN ('y','Y','1') THEN 'active'
    WHEN COALESCE(NULLIF(v.suspend_operation,''),'n') IN ('y','1') OR v.suspended_at IS NOT NULL THEN 'suspended'
    ELSE 'inactive'
  END::public.restaurant_status AS status_mapped
  FROM staging.v2_restaurants v
)
UPDATE menuca_v3.restaurants r
SET
  legacy_v2_id = v.id,
  name         = COALESCE(v.name, r.name),
  status       = v.status_mapped,
  activated_at = COALESCE(r.activated_at, v.added_at),
  suspended_at = COALESCE(r.suspended_at, CASE WHEN v.suspended_at IS NOT NULL AND v.suspended_at > 0 THEN to_timestamp(v.suspended_at) END),
  updated_at   = COALESCE(v.updated_at, r.updated_at),
  updated_by   = COALESCE(v.updated_by, r.updated_by)
FROM v2_map v
WHERE v.v1_id IS NOT NULL AND v.v1_id = r.legacy_v1_id;

-- C) Insert V2 rows that do not link to V1 and are not yet present by legacy_v2_id
WITH v2_map AS (
  SELECT v.*, CASE
    WHEN COALESCE(NULLIF(v.pending,''),'n')          IN ('y','Y','1') THEN 'pending'
    WHEN COALESCE(NULLIF(v.active,''),'n')           IN ('y','Y','1') THEN 'active'
    WHEN COALESCE(NULLIF(v.suspend_operation,''),'n') IN ('y','1') OR v.suspended_at IS NOT NULL THEN 'suspended'
    ELSE 'inactive'
  END::public.restaurant_status AS status_mapped
  FROM staging.v2_restaurants v
)
INSERT INTO menuca_v3.restaurants (
  legacy_v2_id, name, status, activated_at, suspended_at,
  created_at, created_by, updated_at, updated_by
)
SELECT
  v.id,
  v.name,
  v.status_mapped,
  v.added_at,
  CASE WHEN v.suspended_at IS NOT NULL AND v.suspended_at > 0 THEN to_timestamp(v.suspended_at) END AS suspended_at,
  v.added_at AS created_at,
  v.added_by,
  v.updated_at,
  v.updated_by
FROM v2_map v
LEFT JOIN menuca_v3.restaurants r
  ON r.legacy_v2_id = v.id
  OR (v.v1_id IS NOT NULL AND v.v1_id = r.legacy_v1_id)
WHERE r.id IS NULL;

COMMIT;
```

### 4) Verification

Sanity counts and expected totals:

```sql
-- How many V2 rows link to a V1 row?
WITH v2_linked AS (
  SELECT COUNT(*) AS c FROM staging.v2_restaurants v JOIN staging.v1_restaurants r ON r.id = v.v1_id
), v2_unlinked AS (
  SELECT COUNT(*) AS c FROM staging.v2_restaurants v WHERE v.v1_id IS NULL
)
SELECT
  (SELECT COUNT(*) FROM staging.v1_restaurants) AS v1_rows,
  (SELECT c FROM v2_linked)                     AS v2_linked_rows,
  (SELECT c FROM v2_unlinked)                   AS v2_unlinked_rows,
  (SELECT COUNT(*) FROM menuca_v3.restaurants)  AS v3_rows,
  ((SELECT COUNT(*) FROM staging.v1_restaurants)
   + (SELECT COUNT(*) FROM staging.v2_restaurants v WHERE v.v1_id IS NULL)
   + (SELECT COUNT(*) FROM staging.v2_restaurants v WHERE v.v1_id IS NOT NULL AND v.v1_id NOT IN (SELECT id FROM staging.v1_restaurants))
  ) AS expected_v3_rows;
```

Uniqueness of legacy links:

```sql
SELECT legacy_v1_id, COUNT(*) c
FROM menuca_v3.restaurants
WHERE legacy_v1_id IS NOT NULL
GROUP BY legacy_v1_id HAVING COUNT(*) > 1;

SELECT legacy_v2_id, COUNT(*) c
FROM menuca_v3.restaurants
WHERE legacy_v2_id IS NOT NULL
GROUP BY legacy_v2_id HAVING COUNT(*) > 1;
```

Not-null and distribution:

```sql
SELECT COUNT(*) AS unnamed FROM menuca_v3.restaurants WHERE name IS NULL;
SELECT status, COUNT(*) FROM menuca_v3.restaurants GROUP BY status ORDER BY 2 DESC;
```

Spot-check updates where both versions exist:

```sql
SELECT r.id, r.legacy_v1_id, r.legacy_v2_id, r.name, r.status, r.created_at, r.updated_at
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IS NOT NULL AND r.legacy_v2_id IS NOT NULL
ORDER BY r.id
LIMIT 50;
```

### 5) Optional Reset (development only)

```sql
-- DANGER: wipes table for a clean rerun
TRUNCATE TABLE menuca_v3.restaurants RESTART IDENTITY CASCADE;
```

### 6) Troubleshooting (encoding)

If MySQL Workbench fails with `UnicodeEncodeError` (cp1252), export with UTF‑8:

- Result Grid → Export recordset → Encoding UTF‑8; or use `mysqldump --default-character-set=utf8mb4`.

Find offending columns (values not representable in cp1252):

```sql
SET SESSION group_concat_max_len = 1024*1024;
SET @schema := 'menuca_v1';
SET @table  := 'restaurants';

SELECT GROUP_CONCAT(q SEPARATOR ' UNION ALL ') INTO @sql
FROM (
  SELECT CONCAT(
    'SELECT ''', COLUMN_NAME, ''' AS column_name, id AS pk, ',
           '`', COLUMN_NAME, '` AS val ',
    'FROM `', @schema, '`.`', @table, '` ',
    'WHERE `', COLUMN_NAME, '` IS NOT NULL ',
    'AND `', COLUMN_NAME, '` <> CONVERT(CONVERT(`', COLUMN_NAME, '` USING latin1) USING utf8mb4)'
  ) AS q
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME   = @table
    AND DATA_TYPE IN ('char','varchar','tinytext','text','mediumtext','longtext')
) s;

PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
```

### Outcome

After executing steps 1–3, verification in step 4 should confirm that:
- All V1 rows are present in `menuca_v3.restaurants` with `legacy_v1_id` set.
- V2 rows are linked via `legacy_v2_id`; if `v1_id` existed, the row was updated rather than duplicated.
- Status, timestamps, and audit fields are populated per mapping.


