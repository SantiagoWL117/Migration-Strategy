# V1 Migration Schema Clarification

**Date:** October 31, 2025  
**Issue:** Understanding `staging` vs `temp_migration` schemas

---

## ✅ **CORRECT ARCHITECTURE**

### Official ETL Flow (from `ETL_METHODOLOGY.md`):

```
V1/V2 Source → staging schema → Verify → menuca_v3 (production)
```

### Schema Purpose:

1. **`staging` schema** ✅ **OFFICIAL STAGING AREA**
   - Raw V1/V2 data loaded here first
   - Transformations happen here
   - Verification happens here
   - **Current:** Contains `staging.menuca_v1_menu` with **14,884 rows** from **396 restaurants**

2. **`temp_migration` schema** ❌ **LEFTOVER/MISTAKE**
   - Contains `temp_migration.v1_menu` with **0 rows** (empty)
   - Appears to be incorrectly created or unused
   - **Should NOT be used** for migration

3. **`menuca_v3` schema** ✅ **PRODUCTION**
   - Final destination after verification
   - Current production database

---

## 📊 Current State

| Schema | Table | Rows | Restaurants | Status |
|--------|-------|------|-------------|--------|
| **staging** | `menuca_v1_menu` | 14,884 shows | 396 restaurants | ✅ **READY** |
| **temp_migration** | `v1_menu` | 0 | 0 | ❌ **EMPTY - IGNORE** |
| **menuca_v3** | `dishes` | ~10,585 | ~944 restaurants | ✅ **PRODUCTION** |

---

## 🎯 **CORRECTED MIGRATION PLAN**

### For V1 Active Restaurants Migration:

**Step 1: Use `staging.menuca_v1_menu`** (NOT `temp_migration.v1_menu`)

The V1 data is already in `staging.menuca_v1_menu`:
- 14,884 menu rows
- 396 restaurants
- Ready for filtering by V1 active restaurant IDs

**Step 2: Filter by V1 Active Restaurant IDs**

```sql
-- Filter staging.menuca_v1_menu for V1 active restaurants
SELECT 
    vm.*,
    arm.new_restaurant_id as v3_restaurant_id
FROM staging.menuca_v1_menu vm
JOIN archive.restaurant_id_mapping arm 
    ON CAST(vm.restaurant AS INTEGER) = arm.old_restaurant_id
WHERE arm.status = 'active'
    AND arm.old_restaurant_id IN (
        -- Your 133 V1 active restaurant IDs
        781, 1080, 1088, 1013, 1071, 1038, 973, 830, 856, 1018, 826, 869, 991, 
        1025, 1027, 1028, 1029, 805, 1050, 865, 1035, 981, 968, 985, 1059, 1023, 
        974, 1007, 89, 874, 863, 1042, 1085, 364, 965, 970, 959, 892, 1070, 952, 
        392, 998, 894, 861, 1072, 238, 838, 839, 824, 913, 978, 785, 789, 807, 808, 
        815, 833, 850, 879, 889, 937, 987, 989, 1062, 1063, 1065, 1081, 1082, 1084, 
        1087, 1089, 112, 872, 1093, 1092, 1045, 1033, 951, 1051, 1090, 914, 1073, 
        1058, 1041, 1066, 1054, 758, 840, 613, 825, 1039, 875, 948, 1010, 1009, 925, 
        286, 790, 988, 912, 782, 964, 114, 930, 921, 878, 1074, 953, 766, 1069, 1019, 
        983, 1034, 199, 237, 1083, 947, 817, 818, 1094, 1044, 963, 920, 1064, 1020, 
        934, 547, 406
    );
```

**Step 3: Transform & Load to `menuca_v3`**

Follow standard ETL methodology:
1. Transform data in `staging` (if needed)
2. Verify data quality
3. Load from `staging` → `menuca_v3` (production)

---

## 🔍 **Why `temp_migration` Exists**

**Hypothesis:** `temp_migration` schema was created during initial migration attempts but was never populated. The actual V1 data was loaded into `staging.menuca_v1_menu` instead.

**Action:** `temp_migration` can be ignored or dropped. Use `staging` schema only.

---

## ✅ **Next Steps**

1. ✅ **Use `staging.menuca_v1_menu`** (14,884 rows, 396 restaurants)
2. ✅ **Filter by V1 active restaurant IDs** (133 restaurants)
3. ✅ **Transform & verify** in staging
4. ✅ **Load to `menuca_v3`** (production)

---

**Report Generated:** October 31, 2025  
**Status:** ✅ **CLARIFIED - Use `staging` schema, ignore `temp_migration`**


