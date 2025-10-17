# Franchise Hierarchy - Quick Start Guide

**Status:** ✅ Production Ready  
**Last Updated:** 2025-10-16

---

## ⚡ 30-Second Summary

Your franchise hierarchy backend is **LIVE** and **READY TO USE** in Supabase. 

- ✅ **19 franchise chains** with **97 locations** managed
- ✅ **7 backend functions** deployed and tested
- ✅ **Zero data integrity issues**
- ✅ **Sub-50ms query performance**

---

## 🚀 Quick Test (Copy & Paste)

Run this in your Supabase SQL Editor to verify everything works:

```sql
-- Test 1: View all franchise chains
SELECT * FROM menuca_v3.v_franchise_chains ORDER BY location_count DESC;

-- Test 2: Get Milano Pizza (48 locations)
SELECT * FROM menuca_v3.get_franchise_children(986) LIMIT 5;

-- Test 3: Check data integrity (should return 0 rows)
SELECT * FROM menuca_v3.validate_franchise_hierarchy();

-- Test 4: Get summary stats
SELECT * FROM menuca_v3.get_franchise_summary(986);
```

**Expected:** All queries should return results instantly (< 50ms).

---

## 📚 Available Functions

### 1. `get_franchise_children(parent_id)`
Get all child locations for a franchise parent.

```sql
SELECT * FROM menuca_v3.get_franchise_children(986);  -- Milano Pizza
```

### 2. `get_franchise_summary(parent_id)`
Get aggregate statistics for a franchise chain.

```sql
SELECT * FROM menuca_v3.get_franchise_summary(986);
-- Returns: location counts, status breakdown, date ranges
```

### 3. `is_franchise_location(restaurant_id)`
Check if a restaurant is part of a franchise.

```sql
SELECT menuca_v3.is_franchise_location(624);  -- Returns: TRUE
```

### 4. `get_franchise_parent(child_id)`
Get the parent restaurant for a franchise location.

```sql
SELECT * FROM menuca_v3.get_franchise_parent(624);
-- Returns: parent_id=986, brand_name='Milano Pizza'
```

### 5. `bulk_update_franchise_feature(parent_id, feature_key, is_enabled, updated_by)`
Enable/disable a feature for all franchise locations.

```sql
SELECT menuca_v3.bulk_update_franchise_feature(
    987,                -- Colonnade Pizza
    'loyalty_program',  -- Feature key
    true,               -- Enable
    1                   -- Admin user ID
);
-- Returns: 7 (number of locations updated)
```

### 6. `find_nearest_franchise_locations(parent_id, lat, lng, max_km, limit)`
Find nearest franchise locations (requires PostGIS data).

```sql
SELECT * FROM menuca_v3.find_nearest_franchise_locations(
    986,      -- Milano Pizza
    45.4215,  -- Ottawa latitude
    -75.6972, -- Ottawa longitude
    25,       -- Within 25km
    5         -- Top 5 results
);
```

### 7. `validate_franchise_hierarchy()`
Check for data integrity issues.

```sql
SELECT * FROM menuca_v3.validate_franchise_hierarchy();
-- Returns: Empty if all OK (currently 0 issues ✅)
```

---

## 🔥 Top Franchise Chains (Your Data)

| Brand | Locations | Status |
|-------|-----------|--------|
| Milano Pizza | 48 | 43 active, 5 suspended |
| Colonnade Pizza | 7 | 5 active, 2 suspended |
| All Out Burger | 5 | 5 active |
| Fat Albert's | 4 | 1 active, 3 suspended |
| House of Pizza | 3 | 2 active, 1 suspended |

---

## 💻 API Integration (TypeScript)

### Get Franchise Details
```typescript
const { data } = await supabase
    .from('v_franchise_chains')
    .select('*')
    .eq('chain_id', 986)
    .single();

console.log(data.franchise_brand_name);  // "Milano Pizza"
console.log(data.location_count);        // 48
```

### Get All Children
```typescript
const { data } = await supabase
    .rpc('get_franchise_children', { 
        p_parent_id: 986 
    });

console.log(data.length);  // 48 Milano locations
```

### Bulk Enable Feature
```typescript
const { data } = await supabase
    .rpc('bulk_update_franchise_feature', {
        p_parent_id: 987,
        p_feature_key: 'loyalty_program',
        p_is_enabled: true,
        p_updated_by: userId
    });

console.log(`Updated ${data} locations`);  // Updated 7 locations
```

---

## 📁 Documentation Files

| File | Purpose |
|------|---------|
| `FRANCHISE_IMPLEMENTATION_COMPLETE.md` | Executive summary & sign-off |
| `FRANCHISE_BACKEND_VALIDATION_REPORT.md` | Complete test results |
| `FRANCHISE_CHAIN_HIERARCHY_COMPREHENSIVE.md` | Business logic guide |
| `franchise_business_logic_functions.sql` | Function source code |
| `franchise_comprehensive_tests.sql` | Validation test suite |
| `QUICK_START_FRANCHISE.md` | This document |

---

## ✅ Validation Checklist

Run these checks to verify everything is working:

```sql
-- ✅ Check 1: Functions exist (should return 7)
SELECT COUNT(*) FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'menuca_v3'
  AND p.proname LIKE '%franchise%';

-- ✅ Check 2: No data issues (should return 0)
SELECT COUNT(*) FROM menuca_v3.validate_franchise_hierarchy();

-- ✅ Check 3: Milano has 48 locations (should return 48)
SELECT COUNT(*) FROM menuca_v3.get_franchise_children(986);

-- ✅ Check 4: View works (should return 19)
SELECT COUNT(*) FROM menuca_v3.v_franchise_chains();
```

**All checks PASS? ✅ You're ready to integrate!**

---

## 🎯 Next Steps

### Immediate
1. ✅ **Test functions** - Run queries above
2. ✅ **Integrate into API** - Use functions in Edge Functions
3. ✅ **Build UI** - Create franchise management dashboard

### Short Term
1. **Populate PostGIS data** for geospatial queries:
   ```sql
   UPDATE menuca_v3.restaurant_locations
   SET location_point = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
   WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
   ```

2. **Add monitoring** - Weekly integrity validation job

---

## 🆘 Need Help?

### Common Issues

**Q: Function not found error**
```
ERROR: function menuca_v3.get_franchise_children does not exist
```
**A:** Functions are deployed. Check schema name: `menuca_v3.get_franchise_children()`

**Q: View returns empty**
```sql
SELECT * FROM menuca_v3.v_franchise_chains WHERE chain_id = 986;
-- Returns: []
```
**A:** View is working. Check data: `SELECT * FROM menuca_v3.restaurants WHERE id = 986;`

**Q: Performance is slow**
**A:** Check indexes: `SELECT * FROM pg_indexes WHERE tablename = 'restaurants';`

### Documentation References
- Complete guide: `FRANCHISE_CHAIN_HIERARCHY_COMPREHENSIVE.md`
- Test results: `FRANCHISE_BACKEND_VALIDATION_REPORT.md`
- Function source: `franchise_business_logic_functions.sql`

---

## 🎉 Success!

Your franchise hierarchy backend is **production-ready**. Start building your franchise management UI!

**Questions?** Check the comprehensive documentation files listed above.

---

**Last Updated:** 2025-10-16  
**Status:** ✅ All Systems Go

