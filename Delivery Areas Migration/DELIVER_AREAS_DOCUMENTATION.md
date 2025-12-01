# Agent Handoff: Delivery & Zones Data Migration

**Date Created:** November 25, 2025  
**Last Updated:** November 28, 2025  
**Migration Status:** ✅ **SUCCESSFULLY COMPLETED** - 161 restaurants with 230 delivery areas  
**Purpose:** Complete documentation of V1/V2 → V3 delivery area migration

---

## 🎯 Mission Overview

**PRIMARY GOAL:** Extract all "Delivery & Zones" entity data from V1/V2 legacy dumps and migrate to V3 PostgreSQL schema.

**CRITICAL GUIDELINE:** All restaurants use **polygon-based delivery areas**. **IGNORE all radius-related data completely.**

---

## 📊 Final Migration Statistics

### ✅ **MIGRATION COMPLETED SUCCESSFULLY**

**Final Database State (November 27, 2025):**
- **Total Restaurants in V3:** 185
- **Restaurants with Delivery Areas:** 161 (87.0%)
- **Total Delivery Areas:** 230
- **Restaurants without Delivery Areas Migrated:** 0 (0%) ✅
- **Restaurants needing Delivery Areas Defined:** 23 (12.4%) - includes 4 takeout-only restaurants

### Data Sources Summary

| Source | Restaurants | Delivery Areas | Status |
| ------ | ----------- | -------------- | ------ |
| **Phase 1 (MVP)** | 5 | 6 | ✅ Complete |
| **Phase 2 (V2 Export)** | 78 | 85 | ✅ Complete |
| **Phase 2 (V1 Fallback)** | 3 | 3 | ✅ Complete |
| **Phase 4 (V1 Bulk)** | 60 | 106 | ✅ Complete |
| **Phase 5 (V2 Legacy)** | 4 | 4 | ✅ Complete |
| **Phase 6 (V1 Final 10)** | 10 | 11 | ✅ Complete |
| **Total Migrated** | **161** | **230** | ✅ Complete |

---

## 📋 Complete Restaurant Lists

### ✅ Restaurants WITH Delivery Areas (161 restaurants, 230 areas)

| V3 ID | Restaurant Name                     | V1 ID | V2 ID | Areas |
| ----- | ----------------------------------- | ----- | ----- | ----- |
| 561   | Aahar The Taste of India            | 781   | -     | 1     |
| 981   | Al-s Drive In                       | -     | 1678  | 1     |
| 833   | All Out Burger                      | 1080  | -     | 2     |
| 924   | All Out Burger Bank St.             | 1013  | 1611  | 1     |
| 735   | Amicci Pizza                        | 973   | -     | 2     |
| 607   | Aroy Thai                           | 830   | -     | 1     |
| 630   | Asia Garden Ottawa                  | 856   | -     | 2     |
| 69    | Aylmer BBQ                          | 183   | 1093  | 1     |
| 241   | Beneci Pizza                        | 383   | 1266  | 1     |
| 45    | Bobbie's Pizza & Subs               | 143   | 1069  | 1     |
| 973   | Capital Bites                       | -     | 1670  | 1     |
| 977   | Capri Pizza                         | -     | 1674  | 1     |
| 124   | Carlo's Pizza                       | 246   | 1148  | 1     |
| 72    | Cathay Restaurants                  | 187   | 1096  | 1     |
| 131   | Centertown Donair & Pizza           | 255   | 1155  | 1     |
| 87    | Champa Thai Cuisine                 | 203   | 1111  | 1     |
| 943   | Charm Thai Cuisine                  | 323   | 1630  | 1     |
| 966   | Chicco Pizza de l'Hopital           | -     | 1663  | 1     |
| 964   | Chicco Pizza Maloney                | -     | 1661  | 1     |
| 963   | Chicco Pizza Shawarma Anger         | -     | 1660  | 1     |
| 967   | Chicco Pizza St-Louis               | -     | 1664  | 1     |
| 965   | Chicco Shawarma Maloney             | -     | 1662  | 1     |
| 641   | China Moon                          | 869   | -     | 1     |
| 584   | Crispy's                            | 805   | -     | 1     |
| 806   | Crispy's Bank Street                | 1050  | -     | 1     |
| 960   | Cuisine Bombay Indienne             | -     | 1657  | 1     |
| 816   | Depanneur Genereux                  | 1060  | -     | 2     |
| 638   | Digby's Restaurant                  | 865   | -     | 1     |
| 28    | Eastview Pizza                      | 124   | 1052  | 1     |
| 1009  | Econo Pizza                         | 1095  | -     | 1     |
| 511   | Egg Roll Factory                    | 716   | 1536  | 1     |
| 211   | Erman Pizza                         | 350   | 1236  | 1     |
| 730   | Friendly Restaurant and Pizzeria    | 968   | -     | 3     |
| 105   | Ginkgo Garden                       | 224   | 1129  | 2     |
| 815   | Golden Center Pizza                 | 1059  | -     | 1     |
| 736   | Greber Pizza et Shawarma            | 974   | -     | 1     |
| 160   | Hong Kong Chinese Food Takeout      | 294   | 1184  | 1     |
| 22    | House of Lasagna                    | 117   | 1046  | 1     |
| 119   | Hung Mein                           | 239   | 1143  | 1     |
| 7     | Imilio's Pizzeria                   | 89    | -     | 1     |
| 180   | Indian Punjabi Clay Oven            | 318   | 1205  | 1     |
| 646   | JC Royal Thai Cuisine               | 874   | -     | 1     |
| 328   | JN Pizza                            | 489   | 1353  | 2     |
| 636   | Joes Family Pizzeria                | 863   | -     | 2     |
| 798   | Kabylie Pizza                       | 1042  | -     | 2     |
| 44    | Kiki Lebanese Pineview Pizza        | 142   | 1068  | 2     |
| 950   | Kirkwood Pizza                      | -     | 1637  | 1     |
| 984   | La Famiglia on the Danforth         | 364   | -     | 1     |
| 727   | La Maison du Burger                 | 965   | -     | 1     |
| 1010  | Lemongrass Thai Cuisine             | 219   | -     | 1     |
| 77    | Lorenzo's Pizzeria - Vanier         | 192   | 1101  | 1     |
| 267   | Lucky Fortune                       | 413   | 1292  | 1     |
| 174   | Lucky King Take Out                 | 312   | 1199  | 1     |
| 8     | Lucky Star Chinese Food             | 90    | 1032  | 1     |
| 12    | Mama Rosa                           | 94    | 1036  | 1     |
| 118   | Mano City Pizza                     | 238   | -     | 1     |
| 614   | Marina Pizza des Flandres           | 838   | -     | 1     |
| 48    | Merivale Pizza & Wings              | 146   | 1072  | 1     |
| 31    | Milano                              | 127   | 1055  | 1     |
| 55    | Milano                              | 161   | 1079  | 1     |
| 57    | Milano                              | 164   | 1081  | 1     |
| 59    | Milano                              | 172   | 1083  | 1     |
| 75    | Milano                              | 190   | 1099  | 1     |
| 88    | Milano                              | 204   | 1112  | 1     |
| 89    | Milano                              | 205   | 1113  | 2     |
| 90    | Milano                              | 206   | 1114  | 1     |
| 91    | Milano                              | 207   | 1115  | 1     |
| 92    | Milano                              | 208   | 1116  | 1     |
| 491   | Light of India                      | 695   | 1516  | 1     |
| 93    | Milano                              | 209   | 1117  | 1     |
| 95    | Milano                              | 211   | 1119  | 1     |
| 97    | Milano                              | 213   | 1121  | 1     |
| 123   | Milano                              | 245   | 1147  | 1     |
| 126   | Milano                              | 248   | 1150  | 1     |
| 190   | Milano                              | 328   | 1215  | 1     |
| 349   | Milano                              | 512   | 1374  | 1     |
| 350   | Milano                              | 513   | 1375  | 2     |
| 565   | Milano                              | 785   | -     | 1     |
| 569   | Milano                              | 789   | -     | 2     |
| 586   | Milano                              | 807   | -     | 4     |
| 601   | Milano                              | 824   | -     | 2     |
| 624   | Milano                              | 850   | -     | 1     |
| 651   | Milano                              | 879   | -     | 1     |
| 660   | Milano                              | 889   | -     | 2     |
| 680   | Milano                              | 913   | -     | 5     |
| 701   | Milano                              | 937   | -     | 2     |
| 749   | Milano                              | 987   | -     | 1     |
| 751   | Milano                              | 989   | -     | 1     |
| 818   | Milano                              | 1062  | -     | 9     |
| 819   | Milano                              | 1063  | -     | 2     |
| 821   | Milano                              | 1065  | -     | 1     |
| 835   | Milano                              | 1082  | -     | 1     |
| 837   | Milano                              | 1084  | -     | 1     |
| 840   | Milano                              | 1087  | -     | 1     |
| 842   | Milano                              | 1089  | -     | 1     |
| 205   | Mont Liban Bakery & Shawarma        | 344   | 1230  | 1     |
| 644   | Mozza Pizza Hull                    | 872   | -     | 1     |
| 1011  | Mozza Pizza Gatineau                | 132   | -     | 1     |
| 47    | Mr Mozzarella - Nepean              | 145   | 1071  | 1     |
| 845   | Mykonos Greek Grill                 | 1092  | -     | 2     |
| 846   | Mykonos Greek Grill                 | 1093  | -     | 2     |
| 801   | Nachos Loco Gatineau                | 1045  | -     | 5     |
| 790   | Nachos Loco Hull                    | 1033  | -     | 1     |
| 515   | Napolis                             | 721   | 1540  | 1     |
| 502   | New Hong Kong                       | 707   | 1527  | 1     |
| 15    | New Mee Fung Restaurant             | 101   | 1039  | 1     |
| 234   | New Mukut Restaurant Indian Cuisine | 374   | 1259  | 1     |
| 65    | Number One Chinese Take Out         | 179   | 1089  | 1     |
| 714   | Ogilvie Pizza                       | 951   | -     | 1     |
| 681   | Oka's Hull                          | 914   | -     | 2     |
| 245   | Orchid Sushi                        | 387   | 1270  | 1     |
| 974   | Pachino Pizza                       | -     | 1671  | 1     |
| 521   | Palermo Pizzeria                    | 729   | 1546  | 1     |
| 797   | Papa Burger                         | 1041  | -     | 1     |
| 822   | Papa Burger Maloney                 | 1066  | -     | 1     |
| 540   | Papa Grecque des Flandres           | 758   | -     | 1     |
| 616   | Papa Grecque Maloney                | 840   | -     | 1     |
| 437   | Papa Joe's Fried Chicken - Downtown | 612   | 1462  | 1     |
| 13    | Papa Joe's Pizza - Downtown         | 95    | 1037  | 1     |
| 70    | Papa Pizza - Hull                   | 184   | 1094  | 1     |
| 602   | Papa Pizza Cantley                  | 825   | -     | 1     |
| 1012  | Papa Pizza Des Flandres             | 231   | -     | 1     |
| 1013  | Papa Pizza Maloney                  | 346   | -     | 1     |
| 795   | Papa Pizza Chem. de Masson          | 1039  | -     | 1     |
| 1014  | Papa Pizza Val-Des-Monts            | 703   | -     | 1     |
| 712   | Patate Lou Lou                      | 948   | -     | 1     |
| 199   | Pho Bo Ga King - Somerset           | 337   | 1224  | 1     |
| 147   | Pho Dau Bo Restaurant - Kitchener   | 280   | 1171  | 1     |
| 139   | Pizza Bravo                         | 264   | 1163  | 1     |
| 562   | Pizza des Hautes Plaines            | 782   | -     | 1     |
| 726   | Pizza Joanna                        | 964   | -     | 3     |
| 507   | Pizza Lovers Hunt Club              | 712   | 1532  | 1     |
| 696   | Pizza Maisonneuve                   | 930   | -     | 1     |
| 976   | Pizza Marie                         | -     | 1673  | 5     |
| 829   | Pizzalicious                        | 1074  | -     | 1     |
| 716   | PizzaRama                           | 953   | -     | 2     |
| 1015  | Poutinerie Quebecurds Gatineau      | 1046  | -     | 5     |
| 789   | Poutinerie Quebecurds Hull          | 1032  | -     | 1     |
| 497   | Rangoli                             | 701   | 1522  | 1     |
| 106   | Restaurant Le Choix                 | 225   | 1130  | 2     |
| 109   | Restaurant Chez Gerry               | 228   | 1133  | 1     |
| 952   | River Pizza                         | -     | 1639  | 1     |
| 133   | Riverside Pizzeria                  | 257   | 1157  | 1     |
| 1016  | Roulas Grecque et Pizza             | 173   | -     | 1     |
| 376   | Sachi Sushi                         | 542   | 1401  | 1     |
| 83    | Season's Pizza                      | 199   | -     | 1     |
| 269   | Shaan Tandoori                      | 415   | 1294  | 1     |
| 836   | Souvlaki Souvlaki                   | 1083  | -     | 1     |
| 595   | Supreme Pizzeria                    | 817   | -     | 1     |
| 711   | Supreme Pizzeria                    | 947   | -     | 1     |
| 1017  | Sushi Express Chambly               | 511   | -     | 2     |
| 596   | Sushi Fleury                        | 818   | -     | 2     |
| 1020  | Sushi Presse                        | -     | 1285  | 1     |
| 84    | The Original Georgie's              | 200   | 1108  | 1     |
| 941   | Ting's Kitchen                      | 694   | 1628  | 1     |
| 143   | Tony's Pizza                        | 275   | 1167  | 1     |
| 62    | Vanier Pizza & Subs                 | 175   | 1086  | 1     |
| 820   | Vieux Hull Pizza                    | 1064  | -     | 1     |
| 954   | Wandee Thai                         | -     | 1641  | 1     |
| 367   | Xtreme Pizza                        | 532   | 1392  | 1     |
| 985   | Yorgo's - Nepean                    | 547   | -     | 2     |

---

### ❌ Restaurants WITHOUT Delivery Areas Migrated (0 restaurants)

✅ **ALL RESTAURANTS WITH LEGACY DATA HAVE BEEN MIGRATED!**

---

### 🚫 Restaurants With No Delivery Areas Defined  (23 restaurants)

**Reason:** These restaurants need delivery areas to be manually defined (geometry is NULL)

| V3 ID | Restaurant Name            | Address                 | V1 ID | V2 ID | min_order_value | delivery_fee | takeout_only |
| ----- | -------------------------- | ----------------------- | ----- | ----- | --------------- | ------------ | ------------ |
| 948   | All Out Burger Gladstone   | -                       | 1038  | 1635  | 15.00           | 0            | false        |
| 841   | All Out Burger             | 2560 Bank Street        | 1088  | -     | 5.00            | 0            | false        |
| 949   | All Out Burger Montreal Rd | 585 Montreal Road       | 1071  | 1636  | 0               | 0            | false        |
| 961   | Chicco Shawarma Cantley    | -                       | -     | 1658  | -               | 0            | false        |
| 196   | Colonnade Pizza            | -                       | 334   | 1221  | 20.00           | 3.00         | **true**     |
| 783   | Colonnade Pizza            | -                       | 1025  | -     | 20.00           | 3.00         | **true**     |
| 784   | Colonnade Pizza            | -                       | 1027  | -     | 20.00           | 3.00         | **true**     |
| 785   | Colonnade Pizza            | -                       | 1028  | -     | 20.00           | 3.00         | **true**     |
| 957   | Cosenza                    | -                       | -     | 1654  | -               | 0            | false        |
| 792   | Dumpling Bowl              | 730 Somerset            | 1035  | -     | 0               | 0            | false        |
| 519   | HaNoi Pho                  | 4312 Innes Road         | 727   | 1544  | 0               | 0            | false        |
| 479   | iCook Pho You              | 2006 Robertson Rd       | 669   | 1504  | 15.00           | 0            | false        |
| 721   | La Maison Pho              | 4 Rue Belmont           | 959   | -     | 0               | 0            | false        |
| 825   | La Nawab V2                | 1 Rue Cholette          | 1070  | -     | 0               | 0            | false        |
| 971   | Little Gyros Greek Grill   | -                       | -     | 1668  | 0               | 0            | false        |
| 756   | Little Gyros Greek Grill   | 10 Townsend Drive       | 998   | -     | 0               | 0            | false        |
| 265   | Milano                     | -                       | 411   | 1290  | 15.00           | 0            | false        |
| 593   | Milano                     | 1824 Beachburg          | 815   | -     | 15.00           | 0            | false        |
| 807   | Oh My Grill                | 169 York St             | 1051  | -     | 0               | 0            | false        |
| 810   | Papa Grecque Cantley       | 393 Montée de la Source | 1054  | -     | 10.00           | 0            | false        |
| 824   | Prima Pizza                | 26 Northside Road       | 1069  | -     | 13.00           | 0            | false        |
| 745   | Sala Thai                  | 2666 Alta Vista Dr      | 983   | -     | 0               | 0            | false        |
| 847   | Sushiyana                  | 34 boul mont bleu       | 1094  | -     | 15.00           | 0            | false        |

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

## 📁 Files in This Directory

### Scripts (V2 Migration)

| File | Purpose |
| ---- | ------- |
| `convert_v2_coords_to_v3_sql.py` | V2 coordinate parser and SQL generator |
| `create_validation_queries.py` | Pre/post validation query generator |
| `extract_v1_polygons_to_sql.py` | V1 polygon extractor (fallback) |
| `extract_v2_v3_from_report.py` | V2→V3 mapping extractor |
| `map_v2_to_v3_ids.py` | V2→V3 ID mapper with validation |
| `match_restaurants_with_v2_delivery_areas.py` | Restaurant matching script |
| `merge_migration_sql.py` | SQL merger with transaction wrapper |

### Data Files (V2 Migration)

| File | Purpose |
| ---- | ------- |
| `v2_delivery_areas_export_FILTERED.csv` | V2 source data (88 rows) |
| `v2_restaurants_extracted.csv` | All V2 restaurant records |
| `v2_v3_id_mapping.json` | V2→V3 ID mappings |
| `v2_v3_mappings_from_report.csv` | V2→V3 mappings CSV |
| `v1_v3_mapping.csv` | Master V1→V3 ID mappings |
| `v3_legacy_ids_raw.csv` | Raw legacy IDs from V3 |

### SQL Files (Executed)

| File | Purpose |
| ---- | ------- |
| `v2_to_v3_delivery_areas.sql` | V2 coordinate INSERTs |
| `v1_to_v3_delivery_areas.sql` | V1 polygon INSERTs |
| `FINAL_DELIVERY_AREAS_MIGRATION.sql` | Combined migration |

### V1 Bulk Extraction (Phase 4)

| File | Purpose |
| ---- | ------- |
| `v1_95_id_mappings.json` | V1→V3 ID mappings for bulk extraction |
| `v1_95_id_mappings.csv` | CSV version |
| `v1_95_raw_blobs.json` | Raw extracted BLOBs |
| `v1_95_deserialized_areas.json` | Structured polygon data |
| `v1_95_restaurants_migration.sql` | Generated migration SQL |
| `v1_95_extraction_summary.json` | Detailed extraction metadata |
| `v1_95_missing_data.md` | Report of restaurants without data |

### Subdirectories

| Directory | Purpose |
| --------- | ------- |
| `MVP Delivery Areas/` | Phase 1 MVP extraction (5 restaurants) |
| `V1 Delivery Areas/` | V1 analysis scripts and reports |

---

## 🗄️ V3 Target Schema

### Table: `menuca_v3.restaurant_delivery_areas`

```sql
-- Columns:
- restaurant_id (bigint) - FK to restaurants
- area_number (integer) - Sequential per restaurant
- area_name (text) - "Delivery Zone N"
- geometry (geometry(Polygon,4326)) - PostGIS polygon (NULL for undefined areas)
- delivery_fee (numeric) - Fee amount
- min_order_value (numeric) - Minimum order
- takeout_only (boolean) - True if restaurant only offers takeout, no delivery
```

### PostGIS Format

```sql
-- Coordinate order: longitude, latitude (NOT lat/lng!)
ST_GeomFromText('POLYGON((-75.7077 45.3975, -75.7069 45.3961, -75.7077 45.3975))', 4326)
```

---

## ⚠️ Critical Guidelines

### 1. IGNORE ALL RADIUS-RELATED DATA

All restaurants use polygon-based delivery areas. Radius-based delivery is NOT used.

### 2. BLOB Deserialization Strategy

```python
# CORRECT method for V1 deliveryArea BLOB:
blob_data = raw_blob.replace('\\"', '"')
match = re.search(r's:(\d+):"(\{.+?\})";?', blob_data, re.DOTALL)
json_string = match.group(2)
areas = json.loads(json_string)
```

### 3. Coordinate Key Variations

V1 JSON uses different key names - check all variations:
- `lat` / `lng` (most common)
- `Ya` / `Za` (some restaurants)
- `ob` / `pb` (some restaurants)

### 4. PostGIS Polygon Requirements

- Coordinate order: `lng lat` (NOT lat lng)
- Must close polygon: first point = last point
- SRID: 4326 (WGS 84)
- Minimum 3 unique points

---

## 🔍 Quick Diagnostic Commands

```sql
-- Total delivery areas
SELECT COUNT(*) FROM menuca_v3.restaurant_delivery_areas;

-- Restaurants with delivery areas
SELECT COUNT(DISTINCT restaurant_id) FROM menuca_v3.restaurant_delivery_areas;

-- Areas by restaurant
SELECT r.name, COUNT(da.id) as areas
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_delivery_areas da ON r.id = da.restaurant_id
GROUP BY r.id, r.name
ORDER BY areas DESC;

-- Restaurants WITHOUT delivery areas
SELECT r.id, r.name, r.legacy_v1_id, r.legacy_v2_id
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_delivery_areas da ON r.id = da.restaurant_id
WHERE da.id IS NULL
ORDER BY r.name;
```

---

**Last Updated:** November 28, 2025  
**Version:** 3.4  
**Status:** ✅ **MIGRATION SUCCESSFULLY COMPLETED**  
**Results:** 161 restaurants with 230 delivery areas, 0 restaurants without delivery areas migrated, 23 restaurants needing geometry defined (includes 4 takeout-only)
