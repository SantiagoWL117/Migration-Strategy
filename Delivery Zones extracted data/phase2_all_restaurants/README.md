# Phase 2: All Restaurants - Delivery & Zones Migration

## Overview

This directory contains all scripts, data, and SQL files for migrating the "Delivery & Zones" entity data for **159 Phase 2 restaurants** (164 total - 5 MVP) from V1 MySQL dump to V3 PostgreSQL schema.

## Directory Structure

```
phase2_all_restaurants/
├── README.md (this file)
├── PHASE2_VALIDATION_REPORT.md (detailed validation report)
│
├── Scripts/
│   ├── extract_all_v2.py (extract data from V1 dump)
│   ├── generate_v3_sql.py (generate non-BLOB SQL)
│   ├── process_batch.py (create batch files)
│   ├── deserialize_batch.py (deserialize BLOB data)
│   ├── generate_batch_sql.py (generate BLOB SQL)
│   └── filter_mvp_restaurants.py (exclude MVP from Phase 2)
│
├── Extracted Data/
│   ├── all_restaurants_extracted_data.csv (all 164 restaurants)
│   ├── phase2_only_extracted_data.csv (159 Phase 2 restaurants)
│   ├── all_restaurants_blob_*.json (BLOB data for all)
│   └── phase2_only_blob_*.json (BLOB data for Phase 2)
│
├── SQL Files (Executable)/
│   ├── 01_update_service_configs.sql (159 UPDATEs)
│   ├── 02_upsert_delivery_config.sql (159 INSERTs)
│   ├── batch_1_30_*.sql (Batch 1 BLOB data)
│   ├── batch_31_60_*.sql (Batch 2 BLOB data)
│   ├── batch_61_90_*.sql (Batch 3 BLOB data)
│   ├── batch_91_120_*.sql (Batch 4 BLOB data)
│   ├── batch_121_150_*.sql (Batch 5 BLOB data)
│   └── batch_151_159_*.sql (Batch 6 BLOB data)
│
└── Deserialized Data (JSON)/
    ├── batch_*_deserialized_schedules.json (6 batches)
    ├── batch_*_deserialized_areas.json (6 batches)
    └── batch_*_deserialized_fees.json (6 batches)
```

## Execution Summary

### Phase 1 (MVP - Already Complete)
- 5 restaurants processed separately
- V3 IDs: 8, 87, 105, 119, 245

### Phase 2 (This Phase)
- **159 restaurants** processed in 6 batches
- **100% success rate**
- **All SQL executed without errors**

## Key Fixes Applied

1. **delivery_method**: Changed from 'distance' to 'radius' (schema compliance)
2. **delivery_time**: Enforced 15-120 minute constraints
3. **Invalid times**: Filtered out (e.g., "15:90")
4. **Schedule overlaps**: DELETE before INSERT strategy
5. **Empty fees**: Skipped NULL/empty values

## How to Re-run (if needed)

### Step 1: Extract Data
```bash
python extract_all_v2.py
```

### Step 2: Filter MVP Restaurants
```bash
python filter_mvp_restaurants.py
```

### Step 3: Generate Non-BLOB SQL
```bash
python generate_v3_sql.py
```

### Step 4: Process Batches
```bash
# Batch 1
python process_batch.py 0 30
python deserialize_batch.py batch_1_30
python generate_batch_sql.py batch_1_30

# Batch 2
python process_batch.py 30 60
python deserialize_batch.py batch_31_60
python generate_batch_sql.py batch_31_60

# ... (repeat for batches 3-6)
```

### Step 5: Execute SQL
```powershell
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$conn = "postgresql://postgres:YOUR_PASSWORD@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"

# Non-BLOB SQL
& $psql $conn -f "01_update_service_configs.sql"
& $psql $conn -f "02_upsert_delivery_config.sql"

# Batch BLOB SQL
& $psql $conn -f "batch_1_30_schedules.sql"
& $psql $conn -f "batch_1_30_areas.sql"
& $psql $conn -f "batch_1_30_fees.sql"
# ... (repeat for all batches)
```

## Validation Queries

### Count restaurants with delivery enabled
```sql
SELECT COUNT(*) 
FROM menuca_v3.restaurant_service_configs rsc
JOIN menuca_v3.restaurants r ON r.id = rsc.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL 
AND rsc.has_delivery_enabled = true;
-- Expected: ~126
```

### Count delivery schedules
```sql
SELECT COUNT(DISTINCT restaurant_id) 
FROM menuca_v3.restaurant_schedules rs
JOIN menuca_v3.restaurants r ON r.id = rs.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL 
AND rs.type = 'delivery';
-- Expected: ~160
```

### Count delivery areas
```sql
SELECT COUNT(DISTINCT restaurant_id) 
FROM menuca_v3.restaurant_delivery_areas rda
JOIN menuca_v3.restaurants r ON r.id = rda.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL;
-- Expected: ~14
```

### Count delivery fees
```sql
SELECT COUNT(DISTINCT restaurant_id) 
FROM menuca_v3.restaurant_delivery_fees rdf
JOIN menuca_v3.restaurants r ON r.id = rdf.restaurant_id
WHERE r.legacy_v1_id IS NOT NULL;
-- Expected: ~133
```

## Final Status

✅ **Phase 2 Complete**
- 159 / 159 restaurants processed
- 1,261 schedule entries
- 16 delivery area polygons
- 294 fee tier entries
- 0 critical errors

**Combined with Phase 1:** 164 / 164 restaurants = **100% complete** 🎉

## Next Steps

1. ✅ Phase 1 MVP complete
2. ✅ Phase 2 all restaurants complete
3. ⏭️ Final business logic testing
4. ⏭️ Move to next entity (if applicable)

## Contact

For issues or questions, refer to `PHASE2_VALIDATION_REPORT.md` or contact the database administrator.







