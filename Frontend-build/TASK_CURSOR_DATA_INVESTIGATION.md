# TASK FOR CURSOR AGENT: Prima Pizza Data Investigation

**Priority:** 🔴 CRITICAL
**Estimated Time:** 1-2 hours
**Agent:** Cursor (Backend/SQL Expert)
**Context:** See `/Frontend-build/DATA_DISCREPANCY_PRIMA_PIZZA.md`

---

## OBJECTIVE

Determine why Prima Pizza's menu in menuca_v3 doesn't match their live site (https://m.primapizza.ca/menu) and identify the source of truth for restaurant menu data.

---

## YOUR TASKS

### Task 1: Check V1 Database
**Query Prima Pizza data from menuca_v1 schema (legacy_v1_id: 1069):**

```sql
-- Check if menuca_v1 schema exists
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'menuca_v1';

-- If exists, query Prima Pizza dishes
SELECT
  id,
  name,
  price,
  description,
  category_id,
  created_at,
  updated_at
FROM menuca_v1.dishes
WHERE restaurant_id = 1069
ORDER BY name
LIMIT 50;

-- Check categories
SELECT * FROM menuca_v1.categories WHERE restaurant_id = 1069;
```

**Compare with live site items:**
- "Small Pizza 3 Toppings" - $11.00
- "XL Pepperoni Pizza" - $24.00
- "Mega Meal" - $59.99
- "Mozzarella Sticks (6 pieces)" - $10.99
- "Greek Salad" - $6.99

**Document:** Does V1 have current accurate data? Or is it also outdated?

---

### Task 2: Check V2 Database (if exists)
```sql
-- Check if menuca_v2 schema exists
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'menuca_v2';

-- If exists, find Prima Pizza (need to find V2 ID)
SELECT * FROM menuca_v2.restaurants WHERE name ILIKE '%prima%pizza%';

-- Query dishes
SELECT * FROM menuca_v2.dishes WHERE restaurant_id = [v2_id];
```

**Document:** Does V2 exist? Does it have Prima Pizza? Is data current?

---

### Task 3: Analyze V1 → V3 Migration
**Check when V3 data was created:**
```sql
SELECT
  MIN(created_at) as first_dish_migrated,
  MAX(updated_at) as last_dish_updated,
  COUNT(*) as total_dishes,
  COUNT(CASE WHEN base_price IS NULL THEN 1 END) as dishes_without_price,
  COUNT(CASE WHEN course_id IS NULL THEN 1 END) as dishes_without_category
FROM menuca_v3.dishes
WHERE restaurant_id = 824;
```

**Look for migration logs/scripts:**
- Check `/supabase/migrations/` for V1 → V3 migration scripts
- Look for date stamps matching October 2025
- Find script that populated Prima Pizza data

**Document:** When was data migrated? What was the source? Why no categories?

---

### Task 4: Check All Restaurants Pattern
**Sample query to see if this is widespread:**
```sql
-- Find restaurants with no categories in V3
SELECT
  r.id,
  r.name,
  r.slug,
  COUNT(d.id) as dish_count,
  COUNT(CASE WHEN d.course_id IS NULL THEN 1 END) as uncategorized_dishes,
  COUNT(CASE WHEN d.base_price IS NULL THEN 1 END) as dishes_no_price
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true
GROUP BY r.id, r.name, r.slug
HAVING COUNT(d.id) > 0
ORDER BY dish_count DESC
LIMIT 30;
```

**Document:** Is this a Prima Pizza issue or system-wide problem?

---

### Task 5: Propose Solution

Based on your findings, recommend ONE of these approaches:

**Option A: Re-export from V1**
- If V1 has current data, re-run migration with updated export
- Include categories and fix NULL prices

**Option B: Sync from V2**
- If V2 exists and has current data, migrate from V2 instead
- May need new migration script

**Option C: Build Live Site Scraper**
- If neither V1 nor V2 has current data
- Need to scrape from live restaurant sites
- Most complex but gets true current state

**Option D: Manual Update**
- Restaurant owners manually update their menus in V3
- Admin interface needed
- Time-consuming but ensures accuracy

---

## DELIVERABLES

Create a file: `/Frontend-build/CURSOR_FINDINGS_DATA_INVESTIGATION.md`

Include:
1. ✅ V1 database findings (exists? has Prima? data current?)
2. ✅ V2 database findings (exists? has Prima? data current?)
3. ✅ Migration analysis (when? from where? why incomplete?)
4. ✅ Pattern analysis (1 restaurant or many?)
5. ✅ Recommended solution with justification
6. ✅ SQL scripts needed to implement solution

---

## NOTES

- Use Supabase MCP for all database queries
- Save important query results in your findings document
- If you find migration scripts, include relevant snippets
- Be thorough - this blocks frontend development

---

**Created:** 2025-10-27
**Assigned To:** Cursor Agent
**Status:** ✅ COMPLETE - See CURSOR_FINDINGS_DATA_INVESTIGATION.md
