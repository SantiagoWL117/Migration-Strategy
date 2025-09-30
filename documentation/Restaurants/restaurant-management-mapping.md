## Restaurant Management Entity: Source Ã¢â€ â€™ menuca_v3 Mapping

This document maps essential fields from V1/V2 Restaurant Management tables to the normalized Supabase-ready schema created under `menuca_v3`.

Scope sources:
- V1: `restaurants`, `restaurant_domains`, `restaurant_contacts`, `restaurants_schedule_normalized`, `restaurant_admins`, `restaurants_special_schedule`
- V2: `restaurants`, `restaurants_domain`, `restaurants_contacts`, `restaurants_schedule`

Target schema tables:
- `menuca_v3.restaurants`
- `menuca_v3.restaurant_locations`
- `menuca_v3.restaurant_domains`
- `menuca_v3.restaurant_contacts`
- `menuca_v3.restaurant_contact_messages`
- `menuca_v3.restaurant_admin_users`
- `menuca_v3.restaurant_schedules`

Notes:
- IDs: each target table uses BIGSERIAL `id` (internal) and `uuid` (external/API). Populate `uuid` automatically; preserve source IDs in `legacy_*` where applicable.
- Dates/times are stored in UTC (`TIMESTAMPTZ`).
- Booleans map from V1/V2 enums: `'y'|'Y'` Ã¢â€ â€™ true, `'n'|'N'` Ã¢â€ â€™ false.

### menuca_v3.restaurants

| Target column | Source (V1) | Source (V2) | Transform / Notes |
| --- | --- | --- | --- |
| id | n/a | n/a | BIGSERIAL generated in Supabase |
| uuid | n/a | n/a | `uuid_generate_v4()` default |
| legacy_v1_id | `restaurants_v1.id` | n/a | direct copy into staging column |
| legacy_v2_id | n/a | `restaurants_v2.id` | copy once v2 rows are resolved |
| name | `restaurants_v1.name` | `restaurants_v2.name` | prefer v2 value when both exist |
| status | `restaurants_v1.pending`, `restaurants_v1.active`, `restaurants_v1.suspend_operation` | `restaurants_v2.pending`, `restaurants_v2.active`, `restaurants_v2.suspend_operation` | derive state (see mapping below) |
| activated_at | n/a | n/a | optional backfill from business events |
| suspended_at | `restaurants_v1.suspended_at` | `restaurants_v2.suspended_at` | convert epoch/int to timestamptz |
| closed_at | n/a | n/a | leave null unless archival dates surface |
| created_at | `restaurants_v1.addedon` | `restaurants_v2.added_at` | convert to timestamptz (UTC) |
| created_by | `restaurants_v1.addedBy` | `restaurants_v2.added_by` | retain legacy user references |
| updated_at | n/a | `restaurants_v2.updated_at` | timestamptz; v1 has no equivalent |
| updated_by | n/a | `restaurants_v2.updated_by` | copy when present |

Status mapping guidance:
- If `pending` = 'y' -> `pending`
- Else if `active` = 'Y' (v1) or 'y' (v2) -> `active`
- Else if `suspend_operation` in ('1','y') -> `suspended`
- Else -> `inactive`
### menuca_v3.restaurant_locations

| Target column | Source (V1) | Source (V2) | Transform / Notes |
|---|---|---|---|
| id, uuid | n/a | n/a | generated |
| restaurant_id | link by legacy ids | link by legacy ids | FK to `menuca_v3.restaurants.id` |
| is_primary | n/a | n/a | default TRUE for one row per restaurant |
| street_address | `restaurants.address` | `restaurants.address` | direct copy |
| unit_number | n/a | n/a | optional parse if present |
| city | `restaurants.city` (string) | `restaurants.city_id` | resolve `city_id` → name via lookup; if unavailable, leave NULL |
| province_id | n/a | `restaurants.province_id` | copy V2; for V1 map text to an id if needed |
| postal_code | `restaurants.zip` | `restaurants.zip` | direct copy |
| country_code | n/a | n/a | default `CA` |
| latitude | `restaurants.latitude` | `restaurants.lat` | numeric cast |
| longitude | `restaurants.longitude` | `restaurants.lng` | numeric cast |
| phone | `restaurants.phone` | `restaurants.phone` | direct copy |
| email | `restaurants.mainEmail` | `restaurants.email` | prefer V2 if present |
| is_active | `restaurants.active` | `restaurants.active` | map enum Ã¢â€ â€™ boolean |
| created_at/updated_at | n/a | `restaurants.updated_at` | set on insert; update from source if needed |

### menuca_v3.restaurant_domains

| Target column | Source (V1) | Source (V2) | Transform / Notes |
|---|---|---|---|
| id, uuid | n/a | n/a | generated |
| restaurant_id | link | link | FK to v3.restaurants |
| domain | `restaurant_domains.domain` | `restaurants_domain.domain` | direct copy |
| is_enabled | n/a | `restaurants_domain.enabled` | map enum Ã¢â€ â€™ boolean; V1 default true |
| created_at | n/a | `restaurants_domain.added_at` | timestamptz |
| disabled_at | n/a | `restaurants_domain.disabled_at` | timestamptz |
| updated_at | n/a | n/a | maintained by trigger |

Deduplicate per `(restaurant_id, domain)`.

### menuca_v3.restaurant_contacts (internal roles)

| Target column | Source (V1) | Source (V2) | Transform / Notes |
|---|---|---|---|
| id, uuid | n/a | n/a | generated |
| restaurant_id | link | n/a | from V1 only |
| title | `restaurant_contacts.title` | n/a | copy |
| first_name | split `restaurant_contacts.contact` | n/a | best-effort split by space; remainder into last_name |
| last_name | split | n/a | see above |
| email | `restaurant_contacts.email` | n/a | copy |
| phone | `restaurant_contacts.phone` | n/a | copy |
| receives_* | n/a | n/a | default false |
| preferred_language | n/a | n/a | default 'en' |
| is_active | n/a | n/a | default true |
| created_at/updated_at | n/a | n/a | set by triggers |


### menuca_v3.restaurant_admin_users

| Target column | Source (V1) | Source (V2) | Transform / Notes |
|---|---|---|---|
| id, uuid | n/a | n/a | generated |
| restaurant_id | `restaurant_admins.restaurant` | n/a | link via legacy v1 restaurant id |
| user_type | `restaurant_admins.user_type` | n/a | default 'r' if null |
| first_name | `restaurant_admins.fname` | n/a | copy |
| last_name | `restaurant_admins.lname` | n/a | copy |
| email | `restaurant_admins.email` | n/a | copy |
| password_hash | `restaurant_admins.password` | n/a | copy as-is (rehash later) |
| last_login | `restaurant_admins.lastlogin` | n/a | timestamptz |
| login_count | `restaurant_admins.loginCount` | n/a | copy |
| is_active | `restaurant_admins.activeUser` | n/a | '1'Ã¢â€ â€™true, '0'Ã¢â€ â€™false |
| send_statement | `restaurant_admins.sendStatement` | n/a | map enum Ã¢â€ â€™ boolean |
| created_at/updated_at | `restaurant_admins.created_at` | n/a | timestamptz |

### menuca_v3.restaurant_schedules

Unify V1 `restaurant_schedule` (type: 'd','p','ds','ps') and V2 `restaurants_schedule` (type: 'd','t') into the Supabase-ready structure that keeps delivery and takeout rows together.

| Target column | Source (V1) | Source (V2) | Transform / Notes |
|---|---|---|---|
| id, uuid | n/a" | n/a" | generated |
| restaurant_id | `restaurant_schedule.restaurant` | `restaurants_schedule.restaurant_id` | link via legacy ids |
| type | `restaurant_schedule.type` | `restaurants_schedule.type` | map: 'd'â†’delivery, 'p'/'t'â†’takeout; ignore 'ds','ps' (specials) |
| day_start | `restaurant_schedule.day_start` | `restaurants_schedule.day_start` | map to 1..7 (Mon..Sun) during normalization |
| time_start | `restaurant_schedule.time_start` | `restaurants_schedule.start` | cast to time |
| day_stop | derived | derived | default to `day_start`; only shift when a window crosses midnight |
| time_stop | `restaurant_schedule.stop` | `restaurants_schedule.time_stop` | cast to time |
| is_enabled | `restaurant_schedule.enabled` | `restaurants_schedule.enabled` | enum â†’ boolean |
| created_at/updated_at | n/a" | n/a" | managed by triggers |

De-duplicate rows by `(restaurant_id, type, day_start, day_stop, time_start, time_stop)`. For legacy rows that stay within a single day, set `day_stop = day_start`.




### Linking rules

- Build `menuca_v3.restaurants` first, storing V1/V2 IDs in `legacy_v1_id`/`legacy_v2_id`.
- For child rows, resolve `restaurant_id` by joining source FK to the chosen legacy id.
- When both V1 and V2 have overlapping records (e.g., domains), insert unique set keyed by `(restaurant_id, domain)`.

### Data quality recommendations (non-blocking)

- Normalize province names/codes from V1 into an ID (prefer V2 `provinces.id`).
- For `restaurant_contacts.contact` free-form names, attempt best-effort split; keep original in `title` or a staging note if needed.
- Standardize phone formats and postal codes during load.


