## Migration Plan: menuca_v3.restaurant_domains

Scope: Migrate domain records from V1/V2 into `menuca_v3.restaurant_domains`, linking to `menuca_v3.restaurants` via legacy ids, normalizing domains, and ensuring idempotency and integrity.

### menuca_v3.restaurant_domains
- Source tables identified in schemas:
  - V1: `menuca_v1.restaurant_domains` (actual schema). Suitable columns for migration:
    - `restaurant` (int) → link to `menuca_v3.restaurants.legacy_v1_id`
    - `domain` (text) → normalized `domain`
    - Note: no `enabled`/audit fields in V1; default `is_enabled=true`, `created_at=now()`, `disabled_at=NULL`.
  - V2: `menuca_v2.restaurants_domain` (see menuca_v2 structure.sql lines ~1618-1630). Suitable columns:
    - `restaurant_id` (int) → link to `menuca_v3.restaurants.legacy_v2_id`
    - `domain` (varchar) → normalized `domain`
    - `enabled` (enum 'y'/'n') → `is_enabled`
    - `added_at` (timestamp) → `created_at`
    - `disabled_at` (timestamp) → `disabled_at`
    - `type` (enum 'main'|'other'|'mobile') → not modeled in v3 (can be ignored or kept for analytics in staging)
    - `updated_at`/`added_by`/`disabled_by` → optional audit only; map `updated_at` if populated
- Fitness/caveats:
  - Both sources provide per-restaurant domain rows and on/off flags; V2 additionally stores a domain "type" which v3 does not require.
  - Domains may be stored as full URLs or with `www.`; normalization in this plan trims protocol and `www.` and lowercases.
  - V1/V2 restaurant linkage is via `legacy_v1_id`/`legacy_v2_id`; ensure `menuca_v3.restaurants` is populated first.

### 0) Preconditions
```sql
CREATE SCHEMA IF NOT EXISTS menuca_v3;

-- Target DDL (safe to re-run)
DROP TABLE IF EXISTS menuca_v3.restaurant_domains;
CREATE TABLE menuca_v3.restaurant_domains (
  id            bigserial PRIMARY KEY,
  uuid          uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
  restaurant_id bigint NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  domain        varchar(255) NOT NULL,
  domain_type   text,           -- from V2: type ('main'|'other'|'mobile')
  is_enabled    boolean NOT NULL DEFAULT true,
  added_by      integer,        -- from V2: added_by (optional audit)
  created_at    timestamptz NOT NULL DEFAULT now(),
  disabled_by   integer,        -- from V2: disabled_by (optional audit)
  disabled_at   timestamptz,
  updated_at    timestamptz
);

-- Enforce uniqueness per-restaurant in canonical form
CREATE UNIQUE INDEX IF NOT EXISTS u_restaurant_domains_restaurant_domain
  ON menuca_v3.restaurant_domains (restaurant_id, lower(domain));

-- Lookup and usage index
CREATE INDEX IF NOT EXISTS idx_restaurant_domains_domain
  ON menuca_v3.restaurant_domains (lower(domain));

-- Trigger maintained elsewhere (assumes function exists)
-- CREATE FUNCTION menuca_v3.set_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
-- BEGIN NEW.updated_at = now(); RETURN NEW; END $$;
DROP TRIGGER IF EXISTS trg_domains_updated_at ON menuca_v3.restaurant_domains;
CREATE TRIGGER trg_domains_updated_at
BEFORE UPDATE ON menuca_v3.restaurant_domains
FOR EACH ROW EXECUTE FUNCTION menuca_v3.set_updated_at();
```

### 1) Staging tables
```sql
CREATE SCHEMA IF NOT EXISTS staging;

-- Mirror V1 source (menuca_v1.restaurant_domains)
DROP TABLE IF EXISTS staging.v1_restaurant_domains;
CREATE TABLE staging.v1_restaurant_domains (
  id            integer PRIMARY KEY,
  restaurant    integer,     -- legacy V1 restaurant id
  domain        text
);

-- Mirror V2 source (menuca_v2.restaurants_domain)
DROP TABLE IF EXISTS staging.v2_restaurants_domain;
CREATE TABLE staging.v2_restaurants_domain (
  id            integer PRIMARY KEY,
  restaurant_id integer,     -- legacy V2 restaurant id
  domain        text NOT NULL,
  type          text,        -- 'main' | 'other' | 'mobile'
  enabled       text,        -- 'y'/'n' (some exports may have true/false)
  added_by      integer,
  added_at      timestamptz,
  disabled_by   integer,
  disabled_at   timestamptz
);
```

### 2) Load from CSV (Workbench exports)
Import the V1/V2 domain CSVs into the corresponding staging tables (UTF‑8, clean headers). Treat empty strings as NULL.

### 3) Transform and upsert (idempotent)
Rules:
- Normalize domains to host only: lower-case, trim, strip protocol (`http(s)://`), strip leading `www.`, strip trailing slash.
- Map enabled flags:
  - V2: `'y'` → true, `'n'` → false (stored in `menuca_v3.restaurant_domains.is_enabled`)
  - V1: no flag in source; default to true on insert
- Link restaurants via `menuca_v3.restaurants.legacy_v1_id` (for V1) or `legacy_v2_id` (for V2).
- Upsert on `(restaurant_id, lower(domain))`. Update only meaningful changes.

```sql
BEGIN;
-- V1 → v3
WITH v1_norm AS (
  SELECT
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\.|/$', '', 'i'
      )
    ) AS domain_norm,
    ROW_NUMBER() OVER (
      PARTITION BY r.id,
        lower(
          regexp_replace(
            regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
            '^www\.|/$', '', 'i'
          )
        )
      ORDER BY d.id
    ) AS rn
  FROM staging.v1_restaurant_domains d
  JOIN menuca_v3.restaurants r ON r.legacy_v1_id = d.restaurant
  WHERE COALESCE(trim(d.domain),'') <> ''
)
INSERT INTO menuca_v3.restaurant_domains (
  restaurant_id, domain, domain_type, is_enabled, added_by, created_at, disabled_by, disabled_at, updated_at
)
SELECT v3_restaurant_id,
       domain_norm,
       NULL::text              AS domain_type,
       true                    AS is_enabled,
       NULL::integer           AS added_by,
       now()                   AS created_at,
       NULL::integer           AS disabled_by,
       NULL::timestamptz       AS disabled_at,
       NULL::timestamptz       AS updated_at
FROM v1_norm
WHERE rn = 1
ON CONFLICT (restaurant_id, lower(domain)) DO UPDATE
SET 
    -- ✅ FIXED (2025-10-02): Preserve existing is_enabled to prevent V1 from re-enabling V2-disabled domains
    -- CRITICAL: Use COALESCE to preserve existing is_enabled status (idempotency fix)
    -- Previous: is_enabled = EXCLUDED.is_enabled (would overwrite V2's FALSE with V1's TRUE)
    -- Fixed: is_enabled = COALESCE(existing, new) (preserves V2's decisions)
    is_enabled  = COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled),
    domain_type = COALESCE(menuca_v3.restaurant_domains.domain_type, EXCLUDED.domain_type),
    added_by    = COALESCE(menuca_v3.restaurant_domains.added_by, EXCLUDED.added_by),
    disabled_by = COALESCE(EXCLUDED.disabled_by, menuca_v3.restaurant_domains.disabled_by),
    disabled_at = COALESCE(EXCLUDED.disabled_at, menuca_v3.restaurant_domains.disabled_at),
    updated_at  = COALESCE(EXCLUDED.updated_at, menuca_v3.restaurant_domains.updated_at)
WHERE menuca_v3.restaurant_domains.is_enabled  IS DISTINCT FROM COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled)
   OR menuca_v3.restaurant_domains.domain_type IS DISTINCT FROM EXCLUDED.domain_type
   OR menuca_v3.restaurant_domains.added_by    IS DISTINCT FROM EXCLUDED.added_by
   OR menuca_v3.restaurant_domains.disabled_at IS DISTINCT FROM EXCLUDED.disabled_at
   OR menuca_v3.restaurant_domains.updated_at  IS DISTINCT FROM EXCLUDED.updated_at;

-- V2 → v3
WITH v2_norm AS (
  SELECT
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\.|/$', '', 'i'
      )
    ) AS domain_norm,
    d.type        AS domain_type,
    CASE
      WHEN lower(NULLIF(d.enabled,'')) IN ('y','1','true','t')  THEN true
      WHEN lower(NULLIF(d.enabled,'')) IN ('n','0','false','f') THEN false
      ELSE false
    END AS is_enabled,
    d.added_by    AS added_by,
    d.added_at    AS created_at,
    d.disabled_by AS disabled_by,
    d.disabled_at AS disabled_at,
    ROW_NUMBER() OVER (
      PARTITION BY r.id,
        lower(
          regexp_replace(
            regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
            '^www\.|/$', '', 'i'
          )
        )
      ORDER BY
        (CASE lower(NULLIF(d.type,''))
           WHEN 'main'   THEN 3
           WHEN 'mobile' THEN 2
           WHEN 'other'  THEN 1
           ELSE 0
         END) DESC,
        (CASE WHEN lower(NULLIF(d.enabled,'')) IN ('y','1','true','t') THEN 1 ELSE 0 END) DESC,
        d.added_at DESC NULLS LAST,
        d.disabled_at ASC NULLS FIRST,
        d.id
    ) AS rn
  FROM staging.v2_restaurants_domain d
  JOIN menuca_v3.restaurants r ON r.legacy_v2_id = d.restaurant_id
  WHERE COALESCE(trim(d.domain),'') <> ''
)
INSERT INTO menuca_v3.restaurant_domains (
  restaurant_id, domain, domain_type, is_enabled, added_by, created_at, disabled_by, disabled_at, updated_at
)
SELECT v3_restaurant_id,
       domain_norm,
       domain_type,
       is_enabled,
       added_by,
       COALESCE(created_at, now()),
       disabled_by,
       disabled_at,
       NULL::timestamptz AS updated_at
FROM v2_norm
WHERE rn = 1
ON CONFLICT (restaurant_id, lower(domain)) DO UPDATE
SET is_enabled  = EXCLUDED.is_enabled,
    domain_type = CASE
      WHEN menuca_v3.restaurant_domains.domain_type IS NULL THEN EXCLUDED.domain_type
      WHEN (CASE lower(COALESCE(EXCLUDED.domain_type,''))
              WHEN 'main'   THEN 3
              WHEN 'mobile' THEN 2
              WHEN 'other'  THEN 1
              ELSE 0
            END)
         > (CASE lower(COALESCE(menuca_v3.restaurant_domains.domain_type,''))
              WHEN 'main'   THEN 3
              WHEN 'mobile' THEN 2
              WHEN 'other'  THEN 1
              ELSE 0
            END)
        THEN EXCLUDED.domain_type
      ELSE menuca_v3.restaurant_domains.domain_type
    END,
    added_by    = COALESCE(menuca_v3.restaurant_domains.added_by, EXCLUDED.added_by),
    disabled_by = COALESCE(EXCLUDED.disabled_by, menuca_v3.restaurant_domains.disabled_by),
    disabled_at = COALESCE(EXCLUDED.disabled_at, menuca_v3.restaurant_domains.disabled_at),
    updated_at  = COALESCE(EXCLUDED.updated_at, menuca_v3.restaurant_domains.updated_at)
WHERE menuca_v3.restaurant_domains.is_enabled  IS DISTINCT FROM EXCLUDED.is_enabled
   OR menuca_v3.restaurant_domains.domain_type IS DISTINCT FROM EXCLUDED.domain_type
   OR menuca_v3.restaurant_domains.added_by    IS DISTINCT FROM EXCLUDED.added_by
   OR menuca_v3.restaurant_domains.disabled_at IS DISTINCT FROM EXCLUDED.disabled_at
   OR menuca_v3.restaurant_domains.updated_at  IS DISTINCT FROM EXCLUDED.updated_at;

COMMIT;
```

### 4) Verification
```sql
-- A) Row count
SELECT COUNT(*) AS total_domains FROM menuca_v3.restaurant_domains;

-- B) Critical not‑null
SELECT COUNT(*) AS bad_rows
FROM menuca_v3.restaurant_domains
WHERE restaurant_id IS NULL OR domain IS NULL OR trim(domain) = '';

-- C) Find restairants that have the same domain
WITH d AS (
  SELECT restaurant_id, lower(domain) AS dom, COUNT(*) AS c
  FROM menuca_v3.restaurant_domains
  GROUP BY restaurant_id, lower(domain)
)
SELECT * FROM d WHERE c > 1;

-- D) Broken FK links (should be zero)
SELECT COUNT(*) AS broken_links
FROM menuca_v3.restaurant_domains d
LEFT JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE r.id IS NULL;

-- E) Domain format sanity (loose but useful)
SELECT COUNT(*) AS invalid_domains
FROM menuca_v3.restaurant_domains
WHERE domain !~* '^[a-z0-9.-]+\.[a-z]{2,}$';

-- F) No full URLs or leading www. sneaking in
SELECT COUNT(*) AS looks_like_url
FROM menuca_v3.restaurant_domains
WHERE domain ~* '^(https?://|www\.)';

-- G) Sample joined look
SELECT r.id AS restaurant_id, r.name, d.domain, d.is_enabled, d.created_at, d.disabled_at
FROM menuca_v3.restaurant_domains d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
ORDER BY r.id, d.domain
LIMIT 100;

-- H) Index presence (required for ON CONFLICT)
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND tablename  = 'restaurant_domains'
  AND indexname  = 'u_restaurant_domains_restaurant_domain';



-- J) is_enabled must never be NULL
SELECT COUNT(*) AS null_is_enabled
FROM menuca_v3.restaurant_domains
WHERE is_enabled IS NULL;

-- K) domain_type in v3 should match the canonical winner from staging (after dedup rules)
WITH stg_canon AS (
  SELECT
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\\.|/$', '', 'i'
      )
    ) AS domain_norm,
    d.type AS src_type,
    ROW_NUMBER() OVER (
      PARTITION BY r.id,
        lower(
          regexp_replace(
            regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
            '^www\\.|/$', '', 'i'
          )
        )
      ORDER BY
        (CASE lower(NULLIF(d.type,''))
           WHEN 'main'   THEN 3
           WHEN 'mobile' THEN 2
           WHEN 'other'  THEN 1
           ELSE 0
         END) DESC,
        (CASE WHEN lower(NULLIF(d.enabled,'')) IN ('y','1','true','t') THEN 1 ELSE 0 END) DESC,
        d.added_at DESC NULLS LAST,
        d.disabled_at ASC NULLS FIRST,
        d.id
    ) AS rn
  FROM staging.v2_restaurants_domain d
  JOIN menuca_v3.restaurants r ON r.legacy_v2_id = d.restaurant_id
  WHERE COALESCE(trim(d.domain),'') <> ''
), v3 AS (
  SELECT restaurant_id, lower(domain) AS domain_norm, domain_type
  FROM menuca_v3.restaurant_domains
)
SELECT COUNT(*) AS mismatched_domain_type
FROM stg_canon n
JOIN v3 v ON v.restaurant_id = n.v3_restaurant_id AND v.domain_norm = n.domain_norm
WHERE n.rn = 1 AND v.domain_type IS DISTINCT FROM n.src_type;

-- L) V1 rows should have NULL audit/type fields
SELECT COUNT(*) AS v1_nonnull_audit
FROM menuca_v3.restaurant_domains d
JOIN menuca_v3.restaurants r ON r.id = d.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL
  AND (d.domain_type IS NOT NULL OR d.added_by IS NOT NULL OR d.disabled_by IS NOT NULL);

-- M) Dedup correctness for V2: if any candidate is enabled, chosen row should be enabled
WITH cand AS (
  SELECT
    r.id AS v3_restaurant_id,
    lower(
      regexp_replace(
        regexp_replace(trim(COALESCE(d.domain,'')), '^https?://', '', 'i'),
        '^www\\.|/$', '', 'i'
      )
    ) AS domain_norm,
    MAX(CASE WHEN COALESCE(NULLIF(lower(d.enabled),''),'y') IN ('y','1','true','t') THEN 1 ELSE 0 END) AS any_enabled
  FROM staging.v2_restaurants_domain d
  JOIN menuca_v3.restaurants r ON r.legacy_v2_id = d.restaurant_id
  WHERE COALESCE(trim(d.domain),'') <> ''
  GROUP BY 1,2
  HAVING COUNT(*) > 1
), chosen AS (
  SELECT restaurant_id AS v3_restaurant_id, lower(domain) AS domain_norm, is_enabled
  FROM menuca_v3.restaurant_domains
)
SELECT COUNT(*) AS dedup_mismatch
FROM cand c
JOIN chosen ch ON ch.v3_restaurant_id = c.v3_restaurant_id AND ch.domain_norm = c.domain_norm
WHERE (c.any_enabled = 1 AND ch.is_enabled IS NOT TRUE);
```

### 5) Optional cleanups
- Extend normalization to drop trailing dots, unicode homoglyphs, or convert IDN to punycode if needed.
- If a restaurant changed domain, store both; uniqueness is per `(restaurant_id, domain)`.

### 6) Idempotency
All statements are safe to re-run. Upserts avoid duplicate rows and only update when values change.

### 7) Development reset (danger)
```sql
-- Danger: development only
TRUNCATE TABLE menuca_v3.restaurant_domains RESTART IDENTITY CASCADE;
```


