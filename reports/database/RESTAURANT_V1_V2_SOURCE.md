# Restaurant V1/V2 Source Database Categorization

**Generated:** 2025-11-06  
**Purpose:** Show which database (V1/V2) each restaurant came from

---

## Summary Statistics

| Source Database | Count | Description |
|----------------|-------|-------------|
| **V1** | 345 | Restaurants that came from V1 database only |
| **V2** | 117 | Restaurants that came from V2 database only |
| **BOTH** | 471 | Restaurants that exist in both V1 and V2 databases |
| **NONE** | 20 | Restaurants with no legacy ID (new in V3) |
| **TOTAL** | **953** | All restaurants in database |

---

## How to Read This

- **V1**: Restaurant has `legacy_v1_id` but no `legacy_v2_id` → Came from V1 database
- **V2**: Restaurant has `legacy_v2_id` but no `legacy_v1_id` → Came from V2 database  
- **BOTH**: Restaurant has both `legacy_v1_id` AND `legacy_v2_id` → Existed in both databases
- **NONE**: Restaurant has neither legacy ID → New restaurant added in V3

---

## Complete List

The complete list of all 953 restaurants with their source database has been exported to:
- `/Users/brianlapp/.cursor/projects/Users-brianlapp-Documents-GitHub-Migration-Strategy/agent-tools/8393e8d2-d801-4fee-b2c1-2eef7c7f3b26.txt`

**Format:** CSV-like format with:
- restaurant_id
- restaurant_name  
- status
- source_database (V1, V2, BOTH, or NONE)

---

## To Filter to Verified Active List

If you have the list of 142 verified active restaurant IDs, I can filter this list to show only those restaurants and their V1/V2 status.

**Query to filter:**
```sql
SELECT 
  r.id as restaurant_id,
  r.name as restaurant_name,
  r.status,
  CASE 
    WHEN r.legacy_v1_id IS NOT NULL AND r.legacy_v2_id IS NOT NULL THEN 'BOTH'
    WHEN r.legacy_v1_id IS NOT NULL THEN 'V1'
    WHEN r.legacy_v2_id IS NOT NULL THEN 'V2'
    ELSE 'NONE'
  END as source_database
FROM menuca_v3.restaurants r
WHERE r.deleted_at IS NULL
  AND r.id IN (/* verified active list IDs */)
ORDER BY source_database, r.name;
```

---

**Status:** ✅ Complete  
**Last Updated:** 2025-11-06



