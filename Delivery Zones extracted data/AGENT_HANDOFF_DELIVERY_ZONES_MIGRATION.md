# Agent Handoff: Delivery & Zones Data Migration

**Date Created:** November 25, 2025  
**Migration Status:** Phase 1 Complete (5 MVP) | Phase 2 Re-run Complete (159 restaurants)  
**Purpose:** Enable new agent to continue V1 → V3 delivery area migration

---

## 🎯 Mission Overview

**PRIMARY GOAL:** Extract all "Delivery & Zones" entity data from V1 legacy dump and migrate to V3 PostgreSQL schema for 164 active restaurants.

**CRITICAL GUIDELINE:** All restaurants use **polygon-based delivery areas**. **IGNORE all radius-related data completely.**

---

## 📊 Current Status Summary

### ✅ Completed: Phase 1 - MVP Restaurants (5 restaurants)

**Successfully migrated:**
1. Lucky Star Chinese Food (V3 ID: 8, V1 ID: 90) - 2 polygons
2. Champa Thai Cuisine (V3 ID: 87, V1 ID: 203) - 1 polygon
3. Ginkgo Garden (V3 ID: 105, V1 ID: 224) - 1 polygon
4. Hung Mein (V3 ID: 119, V1 ID: 239) - 1 polygon
5. Orchid Sushi (V3 ID: 245, V1 ID: 387) - 1 polygon

**Total Phase 1:** 6 polygons inserted into `menuca_v3.restaurant_delivery_areas`

### ✅ Completed: Phase 2 - All Remaining Restaurants (159 restaurants)

**Re-run completed after fixing deserialization bug:**
- Extracted: 159 restaurants (excluding 5 MVP)
- SQL generated: 6 batches (batch_1_30 through batch_151_159)
- Polygons extracted: 15 additional polygons
- **Combined total: 21 polygons** (6 from Phase 1 + 15 from Phase 2)

**Phase 2 Output Location:** `extracted_data/phase2_all_restaurants/`

### ⚠️ Current Issue: Empty Polygon Data

**147 restaurants (89.6%)** have empty polygon arrays `[]` in V1 `deliveryArea` BLOB:
- **21 restaurants** have actual polygon coordinates ✅
- **147 restaurants** need manual polygon configuration ⚠️
- **2 restaurants** missing from V1 dump entirely (All Out Burger 951 Notre-Dame, Econo Pizza)

---

## 🗂️ Project Structure

```
extracted_data/
├── phase1_mvp/                          # Phase 1 MVP migration (COMPLETE)
│   ├── mvp_extracted_data.csv           # Non-BLOB data for 5 restaurants
│   ├── mvp_blob_deliveryArea.json       # Raw BLOB data
│   ├── mvp_blob_delivery_schedule.json  # Raw schedule BLOBs
│   ├── mvp_blob_fee.json                # Raw fee BLOBs
│   ├── 01_update_service_configs.sql    # Service config updates
│   ├── 02_upsert_delivery_config.sql    # Delivery config upserts
│   ├── 03_insert_schedules.sql          # Schedule inserts
│   ├── 04_insert_delivery_areas.sql     # Polygon inserts (6 polygons)
│   ├── 05_insert_delivery_fees.sql      # Fee inserts
│   └── EXTRACTION_SUMMARY.md            # Phase 1 completion report
│
├── phase2_all_restaurants/              # Phase 2 full migration (COMPLETE)
│   ├── all_restaurants_extracted_data.csv        # All 164 restaurants
│   ├── phase2_only_extracted_data.csv            # 159 (excluding MVP)
│   ├── all_restaurants_blob_*.json               # BLOB data for all
│   ├── phase2_only_blob_*.json                   # BLOB data for Phase 2
│   │
│   ├── batch_1_30/                               # Batch 1: Restaurants 1-30
│   │   ├── batch_1_30_blob_*.json                # BLOB data
│   │   ├── batch_1_30_deserialized_*.json        # Deserialized data
│   │   ├── batch_1_30_service_configs.sql        # SQL for service configs
│   │   ├── batch_1_30_delivery_configs.sql       # SQL for delivery configs
│   │   ├── batch_1_30_schedules.sql              # SQL for schedules
│   │   ├── batch_1_30_areas.sql                  # SQL for areas (6 polygons)
│   │   └── batch_1_30_fees.sql                   # SQL for fees
│   │
│   ├── batch_31_60/                              # Batch 2: Restaurants 31-60
│   │   └── [same structure as batch_1_30]        # (8 polygons)
│   │
│   ├── batch_61_90/                              # Batch 3: Restaurants 61-90
│   │   └── [same structure]                      # (1 polygon)
│   │
│   ├── batch_91_120/                             # Batch 4: Restaurants 91-120
│   │   └── [same structure]                      # (0 polygons)
│   │
│   ├── batch_121_150/                            # Batch 5: Restaurants 121-150
│   │   └── [same structure]                      # (0 polygons)
│   │
│   ├── batch_151_159/                            # Batch 6: Restaurants 151-159
│   │   └── [same structure]                      # (0 polygons)
│   │
│   ├── extract_all_v2.py                         # Main extraction script
│   ├── generate_v3_sql.py                        # Non-BLOB SQL generator
│   ├── process_batch.py                          # Batch splitter
│   ├── deserialize_batch.py                      # BLOB deserializer (FIXED)
│   ├── generate_batch_sql.py                     # Batch SQL generator
│   ├── filter_mvp_restaurants.py                 # MVP filter script
│   ├── PHASE2_VALIDATION_REPORT.md               # Phase 2 completion report
│   ├── PHASE2_DESERIALIZATION_FIX.md             # Bug fix documentation
│   ├── PHASE2_FIX_RESULTS.md                     # Results after fix
│   └── README.md                                 # Execution guide
│
├── v1_v3_mapping.csv                    # Master ID mapping (164 restaurants)
├── v1_ids.txt                           # V1 IDs from V3 (167 restaurants)
├── v2_ids.txt                           # V2 IDs from V3 (94 restaurants)
├── v2_restaurants_extracted.csv         # All 629 V2 restaurants extracted
├── extract_v2_restaurant_ids.py         # V2 extraction & matching script
├── check_polygon_restaurants_in_v2.py   # Check 21 polygon restos in V2
├── V2_V3_MATCHING_REPORT.md             # V2 to V3 matching analysis
├── V1_POLYGON_RESTAURANTS_VS_V2_ANALYSIS.md # 21 polygon restos vs V2
└── CORRECTED_DELIVERY_AREAS_ANALYSIS.md # Polygon data analysis
```

---

## 📋 V1 Source Data Structure

### Source Files

**Primary Source:**
- `Database/v1_structure/restaurants_dump.sql` (10.74 MB, 1,654 restaurants)

**Schema Reference:**
- `Database/v1_structure/structure.sql` (V1 table definitions)
- `V1_DELIVERY_ZONES_COLUMN_MAPPING.md` (Column mapping guide)

### V1 Columns Extracted (from `restaurants` table)

| V1 Column Position | Column Name | Data Type | V3 Target Table | Notes |
|-------------------|-------------|-----------|-----------------|-------|
| 22 | `delivery` | enum('1','0') | `restaurant_service_configs.has_delivery_enabled` | |
| 25 | `min_order` | varchar(125) | `restaurant_service_configs.delivery_min_order` | |
| 17 | `delivery_time` | int unsigned | `restaurant_service_configs.delivery_time_minutes` | Clamped 15-120 |
| 32 | `multipleDeliveryArea` | enum('Y','N') | `restaurant_delivery_config.use_multiple_areas` | |
| 142 | `use_delivery_areas` | enum('y','n') | `restaurant_delivery_config.delivery_method` | Y='areas', N='radius' |
| **9** | **`delivery_schedule`** | **BLOB** | `restaurant_schedules` | **PHP serialized** |
| **33** | **`deliveryArea`** | **BLOB** | `restaurant_delivery_areas` | **PHP serialized JSON** |
| **24** | **`fee`** | **BLOB** | `restaurant_delivery_fees` | **PHP serialized** |

**IGNORED Columns:**
- Column 31: `deliveryRadius` (all values = 0, per guideline)
- Column 103: `deliverToArea` (text only, no coordinates)

---

## 🗄️ V3 Target Schema (menuca_v3)

### Tables Updated by Migration

#### 1. `menuca_v3.restaurant_service_configs`
```sql
-- Columns updated:
- has_delivery_enabled (boolean) ← V1.delivery
- delivery_min_order (numeric) ← V1.min_order
- delivery_time_minutes (integer) ← V1.delivery_time (clamped 15-120)
```

#### 2. `menuca_v3.restaurant_delivery_config`
```sql
-- Columns updated:
- use_multiple_areas (boolean) ← V1.multipleDeliveryArea
- delivery_method (enum: 'radius', 'areas', 'polygon', 'disabled') ← V1.use_delivery_areas
  * 'Y' → 'areas'
  * 'N' → 'radius' (but per guideline, should be 'areas')
```

#### 3. `menuca_v3.restaurant_schedules`
```sql
-- Columns inserted:
- restaurant_id (bigint)
- type (text) = 'delivery'
- day_start (smallint) 1-7 (Mon-Sun) ← V1 BLOB deserialized
- day_stop (smallint) 1-7 (Mon-Sun) ← V1 BLOB deserialized
- time_start (time) ← V1 BLOB deserialized
- time_stop (time) ← V1 BLOB deserialized

-- V1 BLOB Structure:
{
  start: { mon: { i1: "11:00", i2: "17:00", i3: "" }, tue: {...}, ... },
  stop:  { mon: { i1: "14:00", i2: "21:00", i3: "" }, tue: {...}, ... }
}

-- Day Mapping:
mon → 1, tue → 2, wed → 3, thu → 4, fri → 5, sat → 6, sun → 7
```

#### 4. `menuca_v3.restaurant_delivery_areas` ⭐ KEY TABLE
```sql
-- Columns inserted:
- restaurant_id (bigint)
- area_number (integer) ← from V1 BLOB
- area_name (text) = "Delivery Zone {area_number}"
- geometry (geometry(Polygon,4326)) ← V1 BLOB JSON → PostGIS WKT

-- V1 BLOB Structure (PHP serialized string containing JSON):
s:LENGTH:"{"1":[{"lat":45.123,"lng":-75.456},...], "2":[...]}"

-- JSON Structure:
{
  "1": [  // Area number
    {"lat": 45.123, "lng": -75.456},  // OR {"Ya": 45.123, "Za": -75.456}
    {"lat": 45.124, "lng": -75.457},  // OR {"ob": 45.124, "pb": -75.457}
    ...
  ],
  "2": [...],
  ...
}

-- Conversion to PostGIS:
POLYGON((lng1 lat1, lng2 lat2, ..., lng1 lat1))  // Close polygon
ST_GeomFromText('POLYGON(...)', 4326)
```

#### 5. `menuca_v3.restaurant_delivery_fees`
```sql
-- Columns inserted:
- restaurant_id (bigint)
- fee_type (text) = 'distance'
- tier_value (numeric) ← V1 BLOB (distance tier)
- total_delivery_fee (numeric) ← V1 BLOB (fee amount)

-- V1 BLOB Structure:
{ "1": "3.50", "2": "4.50", "3": "5.50", ... }
// Key = tier (distance), Value = fee
```

---

## 🔧 Key Scripts & Their Purpose

### Phase 1 Scripts (MVP - Complete)

1. **`extract_mvp_mysql.py`**
   - Parses V1 dump for 5 MVP restaurants
   - Extracts non-BLOB + raw BLOB data
   - Output: CSV + 3 JSON files

2. **`generate_v3_sql.py`** (Phase 1)
   - Generates SQL for service_configs and delivery_config
   - Output: 2 SQL files

3. **`deserialize_blobs.py`** (Phase 1)
   - Deserializes PHP BLOBs using `phpserialize` library
   - Special handling for deliveryArea: regex + json.loads()
   - Output: 3 deserialized JSON files

4. **`generate_blob_sql.py`** (Phase 1)
   - Generates SQL for schedules, areas, fees
   - Output: 3 SQL files

### Phase 2 Scripts (All Restaurants - Complete)

1. **`extract_all_v2.py`**
   - Parses V1 dump for all 164 restaurants
   - Same logic as Phase 1 extraction
   - Output: CSV + 3 JSON files

2. **`generate_v3_sql.py`** (Phase 2)
   - Same as Phase 1 but for 164 restaurants
   - Clamps delivery_time to 15-120 range
   - Output: 2 SQL files

3. **`filter_mvp_restaurants.py`**
   - Filters out 5 MVP from full extraction
   - Creates phase2_only_* files (159 restaurants)

4. **`process_batch.py`**
   - Splits 159 restaurants into 6 batches
   - Creates batch-specific BLOB JSON files
   - Batch sizes: 30, 30, 30, 30, 30, 9

5. **`deserialize_batch.py`** ⭐ CRITICAL - FIXED
   - Deserializes BLOB data for one batch
   - **BUG FIX:** Uses regex + json.loads() for deliveryArea (not phpserialize)
   - Handles multiple coordinate key variations (Ya/Za, ob/pb, hb/ib, lat/lng)
   - Output: 3 deserialized JSON files per batch

6. **`generate_batch_sql.py`**
   - Generates SQL for one batch
   - Adds DELETE before INSERT for schedules
   - Output: 5 SQL files per batch

---

## 🐛 Critical Bug & Fix History

### Phase 2 Deserialization Failure (RESOLVED)

**Problem:** Phase 2 initially extracted 0 polygons despite having BLOB data.

**Root Cause:**
- Phase 1 used: `regex.search()` → `json.loads()` → ✅ Worked
- Phase 2 used: `phpserialize.loads()` → assumed wrong structure → ❌ Failed

**Fix Applied:**
1. Ported Phase 1's regex + json.loads() logic to Phase 2
2. Added flexible coordinate key handling:
   - Original: `lat`, `lng`
   - Variations: `Ya`, `Za`, `ob`, `pb`, `hb`, `ib`
3. Re-ran all 6 batches

**Result:** 15 polygons extracted from Phase 2 (21 total with Phase 1)

**Documentation:** `PHASE2_DESERIALIZATION_FIX.md`

---

## 📊 Restaurant ID Mapping

### V1 to V3 ID Mapping (164 active restaurants)

**File:** `extracted_data/v1_v3_mapping.csv`

```csv
v3_id,v3_name,legacy_v1_id
561,Aahar The Taste of India,781
841,All Out Burger,1088
...
```

**Total counts in V3:**
- **167 restaurants** have `legacy_v1_id` (3 more than our migration list)
- **94 restaurants** have `legacy_v2_id`

**V1 IDs tuple (for queries):**
```python
legacy_v1_ids = (89, 90, 94, 95, 101, 117, 124, 127, 132, 142, 143, 145, 146, 161, 164, 172, 173, 175, 179, 183, 184, 187, 190, 192, 199, 200, 203, 204, 205, 206, 207, 208, 209, 211, 213, 219, 224, 225, 228, 231, 238, 239, 245, 246, 248, 255, 257, 264, 275, 280, 294, 312, 318, 323, 328, 334, 337, 344, 346, 350, 364, 374, 383, 387, 411, 413, 415, 489, 511, 512, 513, 532, 542, 547, 612, 669, 694, 695, 701, 703, 707, 712, 716, 721, 727, 729, 758, 781, 782, 785, 789, 805, 807, 815, 817, 818, 824, 825, 830, 838, 840, 850, 856, 863, 865, 869, 872, 874, 879, 889, 913, 914, 930, 937, 947, 948, 951, 952, 953, 959, 964, 965, 968, 973, 974, 983, 987, 989, 998, 1013, 1025, 1027, 1028, 1032, 1033, 1035, 1038, 1039, 1041, 1042, 1045, 1046, 1050, 1051, 1054, 1059, 1060, 1062, 1063, 1064, 1065, 1066, 1069, 1070, 1071, 1074, 1080, 1082, 1083, 1084, 1087, 1088, 1089, 1092, 1093, 1094, 1095)
```

**V2 IDs tuple (for V2 dump queries):**
```python
legacy_v2_ids = (1032, 1036, 1037, 1039, 1046, 1052, 1055, 1068, 1069, 1071, 1072, 1079, 1081, 1083, 1086, 1089, 1093, 1094, 1096, 1099, 1101, 1108, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1119, 1121, 1129, 1130, 1133, 1143, 1147, 1148, 1150, 1155, 1157, 1163, 1167, 1171, 1184, 1199, 1205, 1215, 1221, 1224, 1230, 1236, 1259, 1266, 1270, 1290, 1292, 1294, 1353, 1374, 1375, 1392, 1401, 1462, 1504, 1516, 1522, 1527, 1532, 1536, 1540, 1544, 1546, 1611, 1628, 1630, 1635, 1636, 1637, 1639, 1641, 1654, 1657, 1658, 1660, 1661, 1662, 1663, 1664, 1668, 1670, 1671, 1673, 1674, 1678)
```

### Missing Restaurants (2)

**Not in V1 dump:**
1. **All Out Burger** - 951 Notre-Dame St (V3 ID: 833, V1 ID: 1071)
2. **Econo Pizza** - 425 boul La Vérendrye E (V3 ID: 1009, V1 ID: 1095)

**Action:** Flagged for manual entry or investigation.

---

## 🔌 Database Connection Details

### Supabase V3 Database

**Connection via psql:**
```bash
& 'C:\Program Files\PostgreSQL\17\bin\psql.exe' 'postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres'
```

**Project Details:**
- Host: `db.nthpbtdjhhnwfxqsxbvy.supabase.co`
- Port: `5432`
- Database: `postgres`
- User: `postgres`
- Password: `Gz35CPTom1RnsmGM`
- Project Ref: `nthpbtdjhhnwfxqsxbvy`

**Full documentation:** `.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`

---

## ⚠️ Critical Guidelines for New Agent

### 1. **IGNORE RADIUS DATA**
- All restaurants use polygon-based delivery areas
- V1 `deliveryRadius` column is always 0
- Do NOT extract or migrate radius-related data
- Set `delivery_method = 'areas'` for all

### 2. **BLOB Deserialization Strategy**
For `deliveryArea` BLOB specifically:
```python
# ✅ CORRECT (Phase 1 working method):
blob_data = unescape_blob(raw_blob)
match = re.search(r's:(\d+):"(\{.+?\})";?', blob_data, re.DOTALL)
json_string = match.group(2)
areas = json.loads(json_string)

# ❌ WRONG (Phase 2 original - failed):
data = phpserialize.loads(blob_data)
areas = data['deliveryArea']  # Key doesn't exist!
```

### 3. **Coordinate Key Variations**
V1 JSON uses different key names across restaurants:
- `lat` / `lng` (most common)
- `Ya` / `Za` (some restaurants)
- `ob` / `pb` (some restaurants)
- `hb` / `ib` (rare)

**Always check all variations:**
```python
lat = point.get('lat') or point.get('Ya') or point.get('ob') or point.get('hb')
lng = point.get('lng') or point.get('Za') or point.get('pb') or point.get('ib')
```

### 4. **PostGIS Polygon Format**
- Coordinate order: `lng lat` (NOT lat lng)
- Must close polygon: first point = last point
- Format: `POLYGON((lng1 lat1, lng2 lat2, ..., lng1 lat1))`
- SRID: 4326

### 5. **Schedule Time Validation**
- Format: `HH:MM` (24-hour)
- Validate with regex: `^\d{2}:\d{2}$`
- Skip invalid times (e.g., "15:90")
- Map days: mon=1, tue=2, wed=3, thu=4, fri=5, sat=6, sun=7

### 6. **Delivery Time Constraints**
- V3 constraint: 15-120 minutes
- Clamp values: < 15 → 15, > 120 → 120, 0 → 60

### 7. **Phase 2 Batch Processing**
- Always DELETE existing schedules before INSERT
- Process batches sequentially: 1→2→3→4→5→6
- Validate each batch before moving to next

---

## 📝 V2 Alternative Data Source (DISCOVERED & ANALYZED)

### V2 Database Overview

**V2 Restaurants Dump:** `Database/Legacy Schemas/v2_restaurants_dump.sql`
- Total V2 records: 629 restaurants
- V3 restaurants matched to V2: **90 out of 164 (54.9%)**
- Matching method: V1 ID match (82), Name+Address exact (5), Fuzzy >90% (3)

**V2 Delivery Areas Dump:** `Database/Legacy Schemas/v2_restaurants_delivery_areas_dump.sql`
- Total delivery area records: 575 records
- Uses V2 restaurant IDs (not V1 IDs)

### V2 `restaurants_delivery_areas` Table Structure

```sql
CREATE TABLE restaurants_delivery_areas (
  restaurant_id int,
  area_number int,
  area_name varchar(255),
  delivery_fee decimal(10,2),
  min_order_value decimal(10,2),
  is_complex tinyint(1),
  coords text,  -- "lat1,lng1|lat2,lng2|lat3,lng3"
  geometry geometry  -- PostGIS format
)
```

### V2 Match Analysis for 21 V1 Polygon Restaurants

**KEY FINDING:** 19 out of 21 restaurants (90.5%) with V1 delivery area polygons also exist in V2!

**Breakdown:**
- **Phase 1 MVP (5 restaurants):** 5/5 in V2 (100%) ✅
- **Phase 2 Batch 1 (6 restaurants):** 5/6 in V2 (83.3%) ⚠️
- **Phase 2 Batch 2 (8 restaurants):** 8/8 in V2 (100%) ✅
- **Phase 2 Batch 3 (1 restaurant):** 1/1 in V2 (100%) ✅

**Restaurant NOT in V2:**
- Season's Pizza (V3 ID: 83, V1 ID: 199, V1 Name: Season's Pizza)

### V2 Matching Results for All 164 Restaurants

**Total Matched:** 90/164 (54.9%)

**Matched by Method:**
- V1 ID match: 82 restaurants (most reliable)
- Name+Address exact: 5 restaurants
- Fuzzy match (>90%): 3 restaurants

**Missing from V2:** 74/164 (45.1%)

**Reports Generated:**
- `extracted_data/V2_V3_MATCHING_REPORT.md` - Full matching report
- `extracted_data/V1_POLYGON_RESTAURANTS_VS_V2_ANALYSIS.md` - Polygon restaurants analysis
- `extracted_data/v2_restaurants_extracted.csv` - All 629 V2 records

### Implications for Empty Polygon Migration

**Opportunity:** Since 90 restaurants exist in both V1 and V2:
1. **Cross-reference delivery areas:** Check if V2 has polygons for the 147 restaurants with empty V1 BLOBs
2. **Use V2 as fallback:** If V2 has more complete polygon data
3. **Compare data quality:** V2 may have more recent/accurate polygons than V1

**Next Steps for V2 Data:**
1. Query `v2_restaurants_delivery_areas` for the 90 matched restaurants
2. Convert V2 coords format (`lat,lng|lat,lng`) to V3 PostGIS format
3. Map V2 IDs → V3 IDs using the matching report
4. Extract and generate SQL for any additional polygons found

---

## 🎯 Next Steps for New Agent

### Option A: Execute Generated SQL (Recommended)

**Phase 2 SQL files are ready to execute:**

```bash
# Batch 1 (30 restaurants)
psql < phase2_all_restaurants/batch_1_30/batch_1_30_service_configs.sql
psql < phase2_all_restaurants/batch_1_30/batch_1_30_delivery_configs.sql
psql < phase2_all_restaurants/batch_1_30/batch_1_30_schedules.sql
psql < phase2_all_restaurants/batch_1_30/batch_1_30_areas.sql
psql < phase2_all_restaurants/batch_1_30/batch_1_30_fees.sql

# Repeat for batches 2-6
```

**Validation queries:** See `phase2_all_restaurants/README.md`

### Option B: Address Empty Polygons (147 restaurants)

**Investigate V2 dump as alternative source:**

✅ **ANALYSIS COMPLETE:** 90 out of 164 restaurants (54.9%) exist in V2 dump  
✅ **POLYGON OVERLAP:** 19 out of 21 restaurants with V1 polygons (90.5%) also exist in V2

**Next Steps:**

1. **Query V2 delivery areas for the 90 matched restaurants:**
   ```sql
   -- Check which of our 90 matched restaurants have delivery areas in V2
   SELECT restaurant_id, area_number, area_name, coords
   FROM v2_restaurants_delivery_areas 
   WHERE restaurant_id IN (
     1031, 1032, 1036, 1037, 1039, 1046, 1052, 1055, 1068, 1069,
     1071, 1072, 1079, 1081, 1083, 1086, 1089, 1093, 1094, 1096,
     1099, 1101, 1108, 1111, 1112, 1113, 1114, 1115, 1116, 1117,
     1119, 1121, 1129, 1130, 1133, 1143, 1147, 1148, 1150, 1155,
     1157, 1163, 1167, 1171, 1184, 1199, 1205, 1210, 1215, 1221,
     1224, 1230, 1236, 1259, 1266, 1270, 1290, 1292, 1294, 1353,
     1373, 1374, 1375, 1392, 1401, 1406, 1462, 1504, 1509, 1515,
     1516, 1522, 1527, 1532, 1536, 1540, 1544, 1546, 1565, 1611,
     1626, 1635, 1636, 1091, 1084, 1059, 1136, 1232, 1523
   );
   -- These are the V2 IDs of our 90 matched restaurants
   ```

2. **Extract V2 coords and convert:**
   - Parse V2 pipe-separated format: `"lat1,lng1|lat2,lng2|..."`
   - Convert to PostGIS WKT: `POLYGON((lng1 lat1, lng2 lat2, ..., lng1 lat1))`
   - Use `V2_V3_MATCHING_REPORT.md` to map V2 IDs → V3 IDs
   - Generate INSERT statements for `menuca_v3.restaurant_delivery_areas`

3. **Prioritize extraction:**
   - Focus on the 147 restaurants with empty V1 polygons
   - Check if any of these 147 are in the 90 V2 matched list
   - Extract V2 polygons for those with overlap

4. **For remaining empty restaurants:**
   - Flag for manual polygon drawing in V3 admin interface
   - Document which restaurants need configuration
   - Consider if they should use default radius as fallback

### Option C: Validate Existing Data

**Check Phase 1 + Phase 2 inserts:**

```sql
-- Total polygons in V3
SELECT COUNT(*) FROM menuca_v3.restaurant_delivery_areas;
-- Expected: 21+ (6 Phase 1 + 15 Phase 2)

-- Restaurants with polygons
SELECT restaurant_id, COUNT(*) as polygon_count
FROM menuca_v3.restaurant_delivery_areas
GROUP BY restaurant_id
ORDER BY restaurant_id;

-- Restaurants without polygons (from our 164)
SELECT r.id, r.name, r.legacy_v1_id
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IN (89, 90, 94, ...)  -- Use full tuple
  AND r.id NOT IN (SELECT DISTINCT restaurant_id FROM menuca_v3.restaurant_delivery_areas)
  AND r.deleted_at IS NULL;
```

---

## 📚 Reference Documents

### Migration Plan
- **`V1 .plan.md`** - Original extraction plan (12 steps, 2 phases)

### Phase Reports
- **`extracted_data/phase1_mvp/EXTRACTION_SUMMARY.md`** - Phase 1 completion
- **`extracted_data/phase1_mvp/VALIDATION_REPORT.md`** - Phase 1 validation
- **`extracted_data/phase2_all_restaurants/PHASE2_VALIDATION_REPORT.md`** - Phase 2 completion
- **`extracted_data/phase2_all_restaurants/PHASE2_FIX_RESULTS.md`** - Results after bug fix
- **`extracted_data/phase2_all_restaurants/PHASE2_DESERIALIZATION_FIX.md`** - Bug analysis
- **`extracted_data/CORRECTED_DELIVERY_AREAS_ANALYSIS.md`** - Polygon analysis

### V2 Analysis Reports
- **`extracted_data/V2_V3_MATCHING_REPORT.md`** - V2 to V3 restaurant matching (90 matched)
- **`extracted_data/V1_POLYGON_RESTAURANTS_VS_V2_ANALYSIS.md`** - 21 polygon restaurants in V2 (19 found)
- **`extracted_data/v2_restaurants_extracted.csv`** - All 629 V2 restaurant records

### Schema & Mapping
- **`V1_DELIVERY_ZONES_COLUMN_MAPPING.md`** - Single source of truth for V1 columns
- **`Database/v1_structure/structure.sql`** - V1 table definitions
- **`Database/Legacy Schemas/v2_structure.sql`** - V2 table definitions

### Execution Guides
- **`extracted_data/phase2_all_restaurants/README.md`** - How to execute Phase 2

---

## 🔍 Quick Diagnostic Commands

### Check extraction status
```bash
cd extracted_data/phase2_all_restaurants
ls batch_*/batch_*_areas.sql
# Should see 6 batch SQL files
```

### Count polygons in each batch
```bash
# In PowerShell
foreach ($batch in 1..6) {
  $file = "batch_*_$batch/batch_*_areas.sql"
  $count = (Select-String -Path $file -Pattern "INSERT INTO").Count
  Write-Host "Batch $batch: $count polygons"
}
```

### Check V3 current state
```sql
-- Total delivery areas
SELECT COUNT(*) FROM menuca_v3.restaurant_delivery_areas;

-- Areas by restaurant
SELECT restaurant_id, COUNT(*) as areas
FROM menuca_v3.restaurant_delivery_areas
GROUP BY restaurant_id;

-- Restaurants with schedules
SELECT COUNT(DISTINCT restaurant_id) 
FROM menuca_v3.restaurant_schedules 
WHERE type = 'delivery';
```

---

## ⚙️ Required Tools & Libraries

### Python Dependencies
```bash
pip install phpserialize
```

### Database Tools
- PostgreSQL client (psql)
- Supabase CLI (optional, for schema management)

### Windows PowerShell
- Version 5.1+ (for script execution)

---

## 🚨 Known Issues & Workarounds

### 1. Empty Polygon Arrays (147 restaurants)
**Issue:** Most restaurants have `deliveryArea` BLOB = `a:0:{}` (empty array)  
**Workaround:** Check V2 dump or flag for manual configuration

### 2. Invalid Schedule Times
**Issue:** Some restaurants have "15:90" or similar invalid times  
**Solution:** Validation regex in `deserialize_batch.py` skips these

### 3. Multiple Coordinate Key Names
**Issue:** V1 uses `lat/lng`, `Ya/Za`, `ob/pb`, `hb/ib` inconsistently  
**Solution:** Check all variations when parsing (already implemented)

### 4. Missing Restaurants in Dump
**Issue:** 2 restaurants (IDs 1071, 1095) not in V1 dump  
**Status:** Documented in reports, flagged for manual entry

---

## 💡 Tips for New Agent

1. **Read the bug fix doc first:** `PHASE2_DESERIALIZATION_FIX.md` explains why Phase 2 initially failed

2. **Don't re-extract Phase 1:** The 5 MVP restaurants are already complete and in production

3. **Use batch processing:** Phase 2 is split into 6 batches for easier debugging

4. **Validate incrementally:** Execute one batch, validate, then move to next

5. **Check V2 dump for empty polygons:** Could be the missing data source

6. **Trust the CSV files:** ID mappings in `v1_v3_mapping.csv` are authoritative

7. **Watch for PowerShell escaping:** Use single quotes around connection strings

8. **Always close polygons:** First coordinate must equal last coordinate

---

## 📞 User Preferences

- User prefers **direct implementation** over suggestions
- User expects **detailed explanations** of issues found
- User wants **comprehensive documentation** for handoffs
- User appreciates **batch processing** for large datasets
- User values **data validation** at each step

---

**Last Updated:** November 25, 2025  
**Version:** 1.0  
**Status:** Phase 2 Complete (SQL Ready), Empty Polygons Remain  
**Ready for:** SQL Execution or V2 Investigation

