# V1 Active Restaurants Migration Plan - From Source List

**Date:** October 31, 2025  
**Status:** 📋 **READY FOR MIGRATION**  
**Source:** Direct V1 active restaurant list (not from mapping table)

---

## 🎯 Strategy

**Approach:** Use the actual V1 active restaurant list you provided to:
1. Match restaurant names to get V1 IDs from mapping table
2. Identify V1+V2 overlaps (need conflict resolution)
3. Load V1 data for these specific restaurants into temp_migration
4. Migrate V1→V3 with proper overlap handling

---

## 📊 Restaurant List Analysis

**Total Restaurants in V1 Active List:** ~230+ restaurants (many Milano locations, multiple locations per brand)

**Key Observations:**
- Many restaurants have multiple locations (e.g., Milano has 40+ locations)
- Some restaurant names may need fuzzy matching (addresses vary)
- Need to extract V1 restaurant IDs from the mapping table

---

## 🔍 Next Steps

### Step 1: Extract V1 Restaurant IDs

**Action:** Match restaurant names from your list to `archive.restaurant_id_mapping` to get V1 IDs

**Query Strategy:**
- Use ILIKE matching for restaurant names
- Handle multiple locations (some have addresses in name)
- Extract unique V1 restaurant IDs

### Step 2: Identify Overlaps

**Action:** Check which V1 active restaurants also have V2 data

**Query:**
```sql
SELECT 
    arm.old_restaurant_id as v1_id,
    arm.new_restaurant_id as v3_id,
    arm.restaurant_name,
    r.legacy_v2_id as v2_id,
    CASE 
        WHEN r.legacy_v2_id IS NOT NULL THEN 'OVERLAP_WITH_V2'
        ELSE 'V1_ONLY'
    END as migration_type
FROM archive.restaurant_id_mapping arm
LEFT JOIN menuca_v3.restaurants r ON r.id = arm.new_restaurant_id
WHERE arm.status = 'active'
    AND arm.restaurant_name IN (
        -- Match names from your V1 active list
    );
```

### Step 3: Create Migration Plan

**For V1-Only Restaurants:**
- Direct migration (no conflicts)
- Load V1 data → Create courses → Create dishes → Create prices

**For V1+V2 Overlaps:**
- **Merge Strategy:** Add missing dishes, update prices if V1 is different
- Match dishes by name (case-insensitive)
- Keep V2 dishes, add V1-only dishes
- Use V1 prices if V2 prices are $0.00 or missing

---

## 📋 Migration Script Outline

### Phase 1: Load V1 Data (Filtered by Restaurant List)

```sql
-- Create temp table with V1 active restaurant IDs
CREATE TEMP TABLE temp_v1_active_ids AS
SELECT DISTINCT old_restaurant_id
FROM archive.restaurant_id_mapping
WHERE status = 'active'
    AND restaurant_name IN (
        -- Names from your V1 active list
    );

-- Load V1 menu data for these restaurants only
INSERT INTO temp_migration.v1_menu (...)
SELECT ... FROM <v1_source>
WHERE CAST(restaurant AS INTEGER) IN (
    SELECT old_restaurant_id FROM temp_v1_active_ids
);
```

### Phase 2: Identify Conflicts

```sql
-- Find V1+V2 overlaps
SELECT 
    r.id as v3_restaurant_id,
    r.name,
    r.legacy_v1_id,
    r.legacy_v2_id,
    (SELECT COUNT(*) FROM menuca_v3.dishes d WHERE d.restaurant_id = r.id AND d.deleted_at IS NULL) as v2_dish_count,
    (SELECT COUNT(*) FROM temp_migration.v1_menu v1m WHERE CAST(v1m.restaurant AS INTEGER) = r.legacy_v1_id) as v1_menu_count
FROM menuca_v3.restaurants r
WHERE r.legacy_v1_id IN (SELECT old_restaurant_id FROM temp_v1_active_ids)
    AND r.legacy_v2_id IS NOT NULL;
```

### Phase 3: Migration (V1-Only)

```sql
-- Direct migration for V1-only restaurants
-- No conflicts, straightforward insert
```

### Phase 4: Migration (V1+V2 Overlaps)

```sql
-- Merge strategy for overlaps
-- Add missing dishes, update prices
```

---

## 💡 Conflict Resolution Strategy

### Recommended: Merge Strategy (Option C)

**Logic:**
1. **Keep existing V2 dishes** (they're already migrated)
2. **Add V1 dishes that don't exist in V2** (by name matching)
3. **Update prices** if V1 price is different and V2 price is $0.00 or missing
4. **Mark source:** `source_system = 'V1_MERGED'` for new dishes

**Benefits:**
- Preserves V2 migration work
- Adds missing V1 dishes
- Comprehensive coverage
- Clear audit trail

---

## 📝 Action Items

1. ✅ **You provided:** V1 active restaurant list
2. ⏳ **Next:** Match names to get V1 IDs (query above)
3. ⏳ **Then:** Check overlaps (V1+V2 restaurants)
4. ⏳ **Then:** Create filtered loading script (only these restaurants)
5. ⏳ **Then:** Create migration script with merge logic
6. ⏳ **Finally:** Test with 1-2 restaurants, then full migration

---

**Report Generated:** October 31, 2025  
**Status:** 📋 **READY - Waiting for V1 ID extraction**

