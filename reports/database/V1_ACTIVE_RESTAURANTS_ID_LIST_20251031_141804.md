# V1 Active Restaurants - ID List & Migration Plan

**Date:** October 31, 2025  
**Source:** Direct V1 active restaurant list from source  
**Total Restaurants:** 133  
**Overlap with V2:** 1 restaurant

---

## 📊 Summary

| Category | Count | Notes |
|----------|-------|-------|
| **Total V1 Active** | 133 | From your source list |
| **V1+V2 Overlap** | 1 | Sushi Presse (already migrated) |
| **V1-Only** | 132 | Need V1 data migration |
| **Already Have Dishes** | 130 | May need data refresh |
| **Missing Dishes** | 2 | clona stefan, La Maison Grillée |

---

## 🔍 V1+V2 Overlap (1 Restaurant)

| V1 ID | V3 ID | Restaurant Name | V2 ID | Current Dishes | Action |
|-------|-------|-----------------|-------|----------------|--------|
| 406 | 260 | Sushi Presse | 1285 | 354 | ✅ Already migrated (V2) - May supplement with V1 if needed |

**Strategy:** Check if V1 has dishes missing from V2, supplement if needed.

---

## 📋 V1 Restaurant IDs (All 133)

### V1-Only Restaurants (132):

```
781, 1080, 1088, 1013, 1071, 1038, 973, 830, 856, 1018, 826, 869, 991, 
1025, 1027, 1028, 1029, 805, 1050, 865, 1035, 981, 968, 985, 1059, 1023, 
974, 1007, 89, 874, 863, 1042, 1085, 364, 965, 970, 959, 892, 1070, 952, 
392, 998, 894, 861, 1072, 238, 838, 839, 824, 913, 978, 785, 789, 807, 808, 
815, 833, 850, 879, 889, 937, 987, 989, 1062, 1063, 1065, 1081, 1082, 1084, 
1087, 1089, 112, 872, 1093, 1092, 1045, 1033, 951, 1051, 1090, 914, 1073, 
1058, 1041, 1066, 1054, 758, 840, 613, 825, 1039, 875, 948, 1010, 1009, 925, 
286, 790, 988, 912, 782, 964, 114, 930, 921, 878, 1074, 953, 766, 1069, 1019, 
983, 1034, 199, 237, 1083, 947, 817, 818, 1094, 1044, 963, 920, 1064, 1020, 
934, 547
```

**Missing Dishes (2):**
- `991` - clona stefan (V3 ID: 752)
- `970` - La Maison Grillée (V3 ID: 732)

---

## 💡 Migration Strategy

### For V1-Only Restaurants (132):

**Option 1: Refresh All V1 Data**
- Load V1 data for all 132 restaurants
- Compare with existing V3 dishes
- Add missing dishes, update prices if V1 is different
- **Benefit:** Ensures complete V1 data

**Option 2: Focus on Missing**
- Only migrate the 2 restaurants missing dishes
- Leave others as-is (they already have data)
- **Benefit:** Minimal changes, lower risk

**Recommended:** **Option 1** - Refresh all V1 data to ensure completeness and fix any gaps.

### For V1+V2 Overlap (1 restaurant):

**Sushi Presse (V1: 406, V2: 1285)**
- Current: 354 dishes from V2
- Action: Check if V1 has additional dishes/prices not in V2
- Strategy: Add missing V1 dishes, update prices if V1 is different

---

## 🔧 Migration Script Plan

### Step 1: Load V1 Data (Filtered by Restaurant List)

```sql
-- Create temp table with V1 active restaurant IDs
CREATE TEMP TABLE temp_v1_active_ids AS
SELECT unnest(ARRAY[
    781, 1080, 1088, 1013, 1071, 1038, 973, 830, 856, 1018, 826, 869, 991, 
    1025, 1027, 1028, 1029, 805, 1050, 865, 1035, 981, 968, 985, 1059, 1023, 
    974, 1007, 89, 874, 863, 1042, 1085, 364, 965, 970, 959, 892, 1070, 952, 
    392, 998, 894, 861, 1072, 238, 838, 839, 824, 913, 978, 785, 789, 807, 808, 
    815, 833, 850, 879, 889, 937, 987, 989, 1062, 1063, 1065, 1081, 1082, 1084, 
    1087, 1089, 112, 872, 1093, 1092, 1045, 1033, 951, 1051, 1090, 914, 1073, 
    1058, 1041, 1066, 1054, 758, 840, 613, 825, 1039, 875, 948, 1010, 1009, 925, 
    286, 790, 988, 912, 782, 964, 114, 930, 921, 878, 1074, 953, 766, 1069, 1019, 
    983, 1034, 199, 237, 1083, 947, 817, 818, 1094, 1044, 963, 920, 1064, 1020, 
    934, 547, 406  -- Include overlap restaurant too
]) AS v1_restaurant_id;

-- Load V1 menu data for these restaurants only
INSERT INTO temp_migration.v1_menu (...)
SELECT ... FROM <v1_source>
WHERE CAST(restaurant AS INTEGER) IN (
    SELECT v1_restaurant_id FROM temp_v1_active_ids
);
```

### Step 2: V1→V3 Migration

**For V1-Only Restaurants:**
- Direct migration (add missing dishes, update prices)
- Use ON CONFLICT for idempotency

**For V1+V2 Overlap (Sushi Presse):**
- Merge strategy: Add V1 dishes that don't exist in V2
- Match by name (case-insensitive)
- Update prices if V1 is different

---

## 📝 Next Steps

1. ✅ **You provided:** V1 active restaurant list
2. ✅ **I extracted:** V1 restaurant IDs (133 restaurants)
3. ✅ **Identified:** 1 overlap, 132 V1-only
4. ⏳ **Next:** Load V1 data into temp_migration (filtered by these IDs)
5. ⏳ **Then:** Create migration script with merge logic
6. ⏳ **Finally:** Test and execute

---

**Report Generated:** October 31, 2025  
**Status:** ✅ **READY - V1 IDs extracted, migration plan ready**

