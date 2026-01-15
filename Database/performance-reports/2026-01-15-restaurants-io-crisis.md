# Database Performance Report: Restaurants Table IO Crisis

**Date:** January 15, 2026  
**Project:** menu-rebuild-vo (`nthpbtdjhhnwfxqsxbvy`)  
**Schema:** `menuca_v3`  
**Reported by:** Brian Lapp  
**For:** Santiago (Development Team)

---

## Executive Summary

The database experienced a critical outage at ~12:40pm with CPU hitting 100% and high IOwait. Root cause analysis identified **massive JSONB menu caches stored directly in the restaurants table**, causing every PostgREST query to decompress 27+ MB of TOAST data.

**Impact:** 
- Disk IO Budget depleted (Supabase notification received)
- Query times of 3.45s for a 186-row table
- Database became unresponsive

**Resolution Status:** Compute upgraded to Micro (free), fixes in progress.

---

## Root Cause Analysis

### 1. Table Bloat Analysis

| Metric | Value | Assessment |
|--------|-------|------------|
| Row count | 186 rows | Tiny table |
| Table size | 2,880 KB | Normal |
| **TOAST size** | **31 MB** | **THE CULPRIT** |
| Index size | 568 KB | Normal |
| **Total size** | **35 MB** | Way too large for 186 rows |
| Avg row size | **151 KB** | Massive |
| Max row size | **1.2 MB** | Extreme |
| Dead rows | 1 | Minimal bloat |

**Verdict:** Minimal dead row bloat, but massive row sizes from TOAST data.

### 2. Column Size Analysis

| Column | Total Size | Avg Size | Max Size | Non-null Count |
|--------|-----------|----------|----------|----------------|
| `menu_cache_en` | **13 MB** | 107 KB | 572 KB | 125 |
| `menu_cache_fr` | **14 MB** | 113 KB | 612 KB | 125 |

**Combined JSONB caches: 27 MB for 125 restaurants**

Other wide columns:
- `search_vector`: 180 bytes avg (tsvector)
- `meta_keywords`: 169 bytes avg  
- `banner_image_url`: 132 bytes avg
- `meta_description`: 130 bytes avg

### 3. The Slow Query (from pg_stat_statements)

```sql
-- PostgREST pagination query - 2.59s average!
WITH pgrst_source AS (
  SELECT "menuca_v3"."restaurants".*  -- Fetches ALL columns including 27MB of JSONB!
  FROM "menuca_v3"."restaurants"
  WHERE "menuca_v3"."restaurants"."status" = $1
  LIMIT $2 OFFSET $3
), pgrst_source_count AS (...)
```

The `SELECT *` forces PostgreSQL to decompress all TOAST data (the JSONB menu caches), even for a simple status filter.

### 4. VACUUM Status (Critical Issue)

| Metric | Value |
|--------|-------|
| `last_vacuum` | **NULL** (never run) |
| `last_autovacuum` | **NULL** (never run) |
| `last_analyze` | **NULL** (never run) |
| `vacuum_count` | 0 |
| `autovacuum_count` | 0 |

**Autovacuum has never run on this table.** Statistics are completely stale.

### 5. Index Usage

The `idx_restaurants_status` index IS being used, but:
- **100% of rows are `status='active'`** (186/186)
- Index selectivity is zero - every query returns all rows
- The index scan is fast (7ms), but then heap fetches decompress TOAST data

---

## Additional IO Drains Discovered

### TOAST Storage by Table

| Table | Table Size | TOAST Size | Total | Issue |
|-------|-----------|-----------|-------|-------|
| `audit_log_2026_01` | 51 MB | **238 MB** | 295 MB | Seq scans, no indexes |
| `restaurants` | 2.8 MB | **31 MB** | 35 MB | SELECT * on JSONB |
| `audit_log_2025_11` | 118 MB | 2.2 MB | 133 MB | Historical, still scanned |

### Sequential Scans (No Index Usage)

| Table | Seq Scans | Rows Read | Index Scans |
|-------|-----------|-----------|-------------|
| `combo_modifier_prices` | 2 | 397,784 | 0 |
| `modifier_prices` | 2 | 250,516 | 105 |
| `audit_log_2025_11` | 2 | 222,464 | 0 |
| `audit_log_2026_01` | 2 | 71,962 | 0 |

**Audit logs are being sequential scanned** with zero index usage.

---

## Remediation Plan

### Immediate Actions (Do Today)

#### 1. Run VACUUM ANALYZE
```sql
VACUUM ANALYZE menuca_v3.restaurants;
VACUUM ANALYZE menuca_v3.audit_log_2026_01;
VACUUM ANALYZE menuca_v3.audit_log_2025_12;
VACUUM ANALYZE menuca_v3.audit_log_2025_11;
```

#### 2. Add Indexes to Audit Logs
```sql
CREATE INDEX IF NOT EXISTS idx_audit_log_2026_01_created 
ON menuca_v3.audit_log_2026_01 (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_2026_01_table_id 
ON menuca_v3.audit_log_2026_01 (table_name, record_id);

-- Repeat for other partitions
CREATE INDEX IF NOT EXISTS idx_audit_log_2025_12_created 
ON menuca_v3.audit_log_2025_12 (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_2025_11_created 
ON menuca_v3.audit_log_2025_11 (created_at DESC);
```

#### 3. Update PostgREST Queries

**Before (bad):**
```
GET /restaurants?status=eq.active
```

**After (good):**
```
GET /restaurants?select=id,uuid,name,status,slug,logo_url,primary_color,secondary_color&status=eq.active
```

### Schema Changes (This Week)

#### 4. Move menu_cache to Separate Table

```sql
-- Create dedicated cache table
CREATE TABLE menuca_v3.restaurant_menu_cache (
  restaurant_id BIGINT PRIMARY KEY REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  menu_cache_en JSONB,
  menu_cache_fr JSONB,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Copy existing data
INSERT INTO menuca_v3.restaurant_menu_cache (restaurant_id, menu_cache_en, menu_cache_fr, updated_at)
SELECT id, menu_cache_en, menu_cache_fr, COALESCE(menu_cache_updated_at, now())
FROM menuca_v3.restaurants
WHERE menu_cache_en IS NOT NULL OR menu_cache_fr IS NOT NULL;

-- Create index for cache lookups
CREATE INDEX idx_menu_cache_updated ON menuca_v3.restaurant_menu_cache (updated_at DESC);

-- After verification, drop columns from main table
-- ALTER TABLE menuca_v3.restaurants DROP COLUMN menu_cache_en;
-- ALTER TABLE menuca_v3.restaurants DROP COLUMN menu_cache_fr;
-- ALTER TABLE menuca_v3.restaurants DROP COLUMN menu_cache_updated_at;
```

#### 5. Add Covering Index for Common Queries
```sql
CREATE INDEX idx_restaurants_status_covering 
ON menuca_v3.restaurants (status) 
INCLUDE (id, uuid, name, slug, logo_url);
```

---

## Expected Improvements

| Action | IO Reduction | Query Time Reduction |
|--------|-------------|---------------------|
| VACUUM ANALYZE | 10-20% | 20-30% (better plans) |
| Audit log indexes | 30-40% | N/A (background) |
| Move menu_cache | 40-50% | 90%+ (2.5s → 50ms) |
| Explicit column selection | Immediate | 80%+ |

**Combined expected improvement: Query times from 3.45s → <100ms**

---

## Monitoring Recommendations

1. **Set up Disk IO alerts** in Supabase dashboard
2. **Schedule weekly VACUUM ANALYZE** via pg_cron
3. **Add slow query logging** (queries > 500ms)
4. **Monitor pg_stat_statements** for regression

---

## Appendix: Current Table Schema

```sql
-- restaurants table columns
id                            BIGINT (PK)
uuid                          UUID (unique)
name                          VARCHAR(255)
status                        restaurant_status (enum)
slug                          VARCHAR(255) (unique)
timezone                      VARCHAR(50)
-- ... timestamps and FK columns ...
logo_url                      TEXT
banner_image_url              TEXT
primary_color                 VARCHAR(7)
secondary_color               VARCHAR(7)
-- ... other styling columns ...
menu_cache_en                 JSONB  -- ⚠️ PROBLEM: avg 107KB
menu_cache_fr                 JSONB  -- ⚠️ PROBLEM: avg 113KB
menu_cache_updated_at         TIMESTAMPTZ
```

---

## Questions for Santiago

1. Where are the PostgREST queries being called from? (Frontend, Edge Functions?)
2. Is the menu_cache being used for SSR or can we serve from CDN?
3. Should we consider Redis for menu caching instead of Postgres?
4. Do we need the audit logs older than 30 days in hot storage?

---

*Report generated from live Supabase diagnostics on 2026-01-15*
