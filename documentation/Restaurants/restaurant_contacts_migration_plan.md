## menuca_v3.restaurant_contacts — Migration Plan

### Purpose
Normalize restaurant internal contact persons into `menuca_v3.restaurant_contacts` using V1 authoritative contacts only.

### Source vs Target Mapping (evidence)

Sources consulted:

- V1 schema `restaurant_contacts`:
```1249:1260:Database/schema/menuca_v1 structure.sql
DROP TABLE IF EXISTS `restaurant_contacts`;
CREATE TABLE `restaurant_contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `contact` varchar(125) ...,
  `title` varchar(45) ...,
  `phone` varchar(45) ...,
  `email` varchar(125) ...,
  PRIMARY KEY (`id`)
)
```

- Target table in v3:
```101:118:Database/schema/menuca_v3.sql
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_contacts (
    id bigint NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    restaurant_id bigint NOT NULL,
    title varchar(100),
    first_name varchar(100),
    last_name varchar(100),
    email varchar(255),
    phone varchar(20),
    preferred_language char(2) DEFAULT 'en',
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz
);
```

Mapping convention from `restaurant-management-mapping.md` confirms V1-only source for internal contacts and name split rules.

### Field Mapping

- restaurant_id: resolve via legacy linking (V1 `restaurant_contacts.restaurant` → v3 `restaurants.legacy_v1_id` → v3 `restaurants.id`).
- title: copy from V1 `restaurant_contacts.title`.
- first_name, last_name: split V1 `restaurant_contacts.contact` by whitespace. First token → `first_name`; remaining tokens joined → `last_name`. If null/empty, leave both null.
- email: copy from V1 `restaurant_contacts.email`.
- phone: copy from V1 `restaurant_contacts.phone`; already normalized to (###) ###-#### — do not reformat.
- preferred_language: default 'en'.
- is_active: default true.

Notes:
This migration consumes only V1 `restaurant_contacts`.

### Preconditions (Step 0)

- Ensure `extensions.uuid_generate_v4()` exists.
- Ensure `menuca_v3.restaurants` is loaded and contains legacy keys (`legacy_v1_id`).

### Staging (Step 1)

Create minimal staging tables or views reflecting V1 data that we actually have (name splitting handled in SQL):

```sql
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.v1_restaurant_contacts;
CREATE TABLE staging.v1_restaurant_contacts (
  legacy_contact_id integer,
  legacy_v1_restaurant_id integer,
  contact text,
  title text,
  phone text,
  email text
);
-- Load from CSV or link to source V1 schema as applicable
```

Optional: basic cleanup during load (trim, collapse whitespace):

```sql
UPDATE staging.v1_restaurant_contacts
SET contact = NULLIF(regexp_replace(trim(contact), '\\s+', ' ', 'g'), ''),
    title   = NULLIF(trim(title), ''),
    phone   = NULLIF(trim(phone), ''),
    email   = lower(NULLIF(trim(email), ''));
```

### Transform and Upsert (Step 2) — Idempotent

- Name split: first token to `first_name`, remaining to `last_name`.
- Resolve FK via `legacy_v1_id`.
- Upsert key priority: if `email` present use `(restaurant_id, lower(email))`. If email is NULL, use `(restaurant_id, phone)`; since phones are already normalized to (###) ###-####, string equality is stable. Create expression unique indexes to support idempotency.

```sql
BEGIN;

-- Allow multiple contacts per restaurant distinguished by (email, phone)
-- Create a composite UNIQUE INDEX on the actual columns so ON CONFLICT can infer it
CREATE UNIQUE INDEX IF NOT EXISTS u_contacts_rest_email_phone_idx
  ON menuca_v3.restaurant_contacts (restaurant_id, email, phone);

WITH base AS (
  SELECT
    rc.legacy_contact_id,
    r.id AS restaurant_id,
    rc.title,
    rc.email,
    rc.phone,
    rc.contact AS contact_raw
  FROM staging.v1_restaurant_contacts rc
  JOIN menuca_v3.restaurants r
    ON r.legacy_v1_id = rc.legacy_v1_restaurant_id
), split AS (
  SELECT
    legacy_contact_id,
    restaurant_id,
    title,
    NULLIF(btrim(email), '') AS email,
    NULLIF(btrim(phone), '') AS phone,
    CASE WHEN btrim(contact_raw) = '' OR contact_raw IS NULL THEN NULL 
         ELSE split_part(btrim(contact_raw), ' ', 1) END AS first_name,
    CASE WHEN btrim(contact_raw) = '' OR contact_raw IS NULL THEN NULL
         WHEN array_length(string_to_array(btrim(contact_raw), ' '), 1) = 1 THEN NULL
         ELSE btrim(substring(btrim(contact_raw) from position(' ' in btrim(contact_raw)) + 1)) END AS last_name
  FROM base
), norm AS (
  SELECT
    legacy_contact_id,
    restaurant_id,
    title,
    email,
    phone,
    lower(email) AS email_norm,
    phone AS phone_norm,
    first_name,
    last_name
  FROM split
), ranked AS (
  -- Deduplicate within the batch by (restaurant, email_norm, phone_norm)
  SELECT n.*,
         row_number() OVER (
           PARTITION BY restaurant_id, email_norm, phone_norm
           ORDER BY length(coalesce(first_name,'')||coalesce(last_name,'')) DESC,
                    legacy_contact_id
         ) AS rn
  FROM norm n
)
INSERT INTO menuca_v3.restaurant_contacts (
  restaurant_id, title, first_name, last_name, email, phone
)
SELECT restaurant_id, title, first_name, last_name, email, phone
FROM ranked
WHERE rn = 1
ON CONFLICT (restaurant_id, email, phone)
DO UPDATE SET
  title = COALESCE(EXCLUDED.title, menuca_v3.restaurant_contacts.title),
  first_name = COALESCE(EXCLUDED.first_name, menuca_v3.restaurant_contacts.first_name),
  last_name = COALESCE(EXCLUDED.last_name, menuca_v3.restaurant_contacts.last_name),
  email = COALESCE(EXCLUDED.email, menuca_v3.restaurant_contacts.email),
  phone = COALESCE(EXCLUDED.phone, menuca_v3.restaurant_contacts.phone),
  updated_at = now();

COMMIT;
```

Handle rows without email (fallback merge) in a second idempotent pass, using a temporary unique constraint in-session to avoid multiple updates to the same target row:

-- Second pass no longer needed; the composite (email, phone) key handles all rows, including missing email or phone.

Notes:
- The two-pass approach avoids the "ON CONFLICT DO UPDATE cannot affect row a second time" error by pre-deduplicating and separating keyed vs non-keyed upserts.
- If you later decide to enforce uniqueness for the fallback key, create an expression index tailored to your policy; for now we leave it flexible and log duplicates via verification.

### Post-load Normalization (Step 3)

```sql
-- Phones are already normalized to (###) ###-####. Verify non-conforming rows (should be zero):
SELECT restaurant_id, phone
FROM menuca_v3.restaurant_contacts
WHERE phone IS NOT NULL AND phone <> ''
  AND phone !~ '^\(\d{3}\) \d{3}-\d{4}$';
```

### Verification (Step 4)

```sql
-- A) Source vs target counts
SELECT COUNT(*) AS v1_contacts FROM staging.v1_restaurant_contacts;
SELECT COUNT(*) AS v3_contacts FROM menuca_v3.restaurant_contacts;

-- B) Broken FK (should be zero)
SELECT rc.legacy_v1_restaurant_id
FROM staging.v1_restaurant_contacts rc
LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = rc.legacy_v1_restaurant_id
WHERE r.id IS NULL
GROUP BY rc.legacy_v1_restaurant_id;

-- C) Duplicate contact pairs per restaurant (email/phone combination) — should be zero
SELECT
  restaurant_id,
  coalesce(lower(email), '∅') AS email_norm,
  coalesce(phone, '∅') AS phone_norm,
  COUNT(*)
FROM menuca_v3.restaurant_contacts
GROUP BY restaurant_id, coalesce(lower(email), '∅'), coalesce(phone, '∅')
HAVING COUNT(*) > 1;

-- D) Source vs target distinct pair counts (sanity)
WITH src AS (
  SELECT r.id AS restaurant_id,
         NULLIF(lower(trim(s.email)), '') AS email_norm,
         NULLIF(trim(s.phone), '') AS phone_norm
  FROM staging.v1_restaurant_contacts s
  JOIN menuca_v3.restaurants r ON r.legacy_v1_id = s.legacy_v1_restaurant_id
), src_pairs AS (
  SELECT DISTINCT restaurant_id,
                  coalesce(email_norm, '∅') AS email_norm,
                  coalesce(phone_norm, '∅') AS phone_norm
  FROM src
), tgt_pairs AS (
  SELECT DISTINCT restaurant_id,
                  coalesce(lower(email), '∅') AS email_norm,
                  coalesce(phone, '∅') AS phone_norm
  FROM menuca_v3.restaurant_contacts
)
SELECT (SELECT COUNT(*) FROM src_pairs) AS expected_pairs,
       (SELECT COUNT(*) FROM tgt_pairs) AS actual_pairs;

-- E) Null/empty contact fields distribution
SELECT
  SUM(CASE WHEN coalesce(first_name,'') = '' AND coalesce(last_name,'') = '' THEN 1 ELSE 0 END) AS empty_names,
  SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) AS empty_emails,
  SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) AS empty_phones
FROM menuca_v3.restaurant_contacts;

-- F) Sample join to restaurant names
SELECT c.*, r.name AS restaurant_name
FROM menuca_v3.restaurant_contacts c
JOIN menuca_v3.restaurants r ON r.id = c.restaurant_id
ORDER BY r.name, c.email NULLS LAST
LIMIT 50;
```

Remediation tips:
- Any rows reported by (B) require adding the missing restaurants or fixing legacy links.
- Rows flagged by (C) or (D) can be consolidated manually or with a targeted merge query if desired.

### Execution Order

1) Run Preconditions (Step 0).
2) Load staging (Step 1).
3) Execute Transform/Upsert (Step 2).
4) Run Post-load normalization (Step 3) [optional].
5) Run Verification (Step 4) and remediate as needed; steps are idempotent.

### Out-of-Scope

No tasks involving V2 `restaurants_contacts`.


