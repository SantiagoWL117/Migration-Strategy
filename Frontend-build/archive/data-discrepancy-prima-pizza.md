# CRITICAL: Prima Pizza Menu Data Discrepancy

**Date:** 2025-10-27
**Severity:** 🔴 CRITICAL - Blocks V3 frontend launch
**Restaurant:** Prima Pizza (ID: 824, legacy_v1_id: 1069)
**Discovered By:** Frontend testing during modifier groups integration

---

## 🚨 THE PROBLEM

**The live production site menu DOES NOT MATCH the menuca_v3 database menu.**

### Live Site (https://m.primapizza.ca/menu)
- Shows organized categories: Deals, Pizzas, Indian Specialty, Appetizers, Burgers, Subs, Salads, Desserts
- Example items:
  - "Small Pizza 3 Toppings" - $11.00
  - "XL Pepperoni Pizza" - $24.00
  - "Mega Meal" - $59.99
  - "Mozzarella Sticks (6 pieces)" - $10.99
  - "Greek Salad" - $6.99
  - "Beyond Meat Burger" - $7.49

### menuca_v3 Database (restaurant_id: 824)
- **NO categories** - all 140 dishes have `course_id = NULL`
- Shows different/incomplete items:
  - "1 Topping Pizza Deal" - $24.70
  - "BBQ Chicken Pizza" - $15.15
  - "Greek Salad" - $9.95 (different price!)
  - "Mozzarella Cheese Sticks (8 pcs)" - $12.00 (different size and price!)
  - Found "Small Pizza 3 Toppings" but with `base_price = NULL`
  - Found "Mega Meal" but with `base_price = NULL`

---

## 📊 DATA ANALYSIS

### Restaurant Record
```
ID: 824
Name: Prima Pizza
Slug: prima-pizza-824
Status: active
legacy_v1_id: 1069
legacy_v2_id: NULL
Created: 2023-01-17
Last Updated: 2025-10-20
```

### Dishes in menuca_v3
- **Total dishes:** 140
- **Source:** 100% from V1 (`source_system = 'v1'`)
- **Oldest dish:** 2025-10-09 (recent!)
- **Most recent update:** 2025-10-14
- **Categories:** NONE (all have `course_id = NULL`)

### Live Site Backend
- **System:** Custom PHP-based ordering platform
- **Not using menuca_v3** - appears to be separate system
- No API version identifiers visible
- Proprietary solution, not SaaS

---

## 🔍 KEY FINDINGS

1. **Price Mismatches:**
   - Greek Salad: Live $6.99 vs DB $9.95
   - Mozzarella Sticks: Live $10.99 (6 pcs) vs DB $12.00 (8 pcs)

2. **Missing Prices in DB:**
   - "Small Pizza 3 Toppings" exists but `base_price = NULL`
   - "Mega Meal" exists but `base_price = NULL`

3. **Live Site NOT Using V3:**
   - Live site (m.primapizza.ca) is running on a different backend
   - menuca_v3 has V1 data but it doesn't match current live data
   - Restaurant appears to have updated their menu since V1 export

4. **No Menu Structure:**
   - DB has no categories/courses
   - Live site has proper categorization

---

## 💥 IMPACT

**This affects the entire V3 migration:**

1. **Prima Pizza is unusable in V3** - wrong menu, wrong prices
2. **Likely affects ALL or MOST restaurants** - if Prima Pizza has stale data, others probably do too
3. **Frontend testing is blocked** - can't validate features with incorrect data
4. **Cannot launch V3** until data is current and accurate

---

## 🎯 ROOT CAUSE ANALYSIS

### Theory 1: Stale V1 Export
- menuca_v3 was populated from V1 database export
- Prima Pizza has updated their menu AFTER the export was taken
- Live site is still running V1 or a separate system
- V3 has outdated snapshot

### Theory 2: Incomplete Migration
- V1 → V3 migration script didn't capture all data
- Some dishes were skipped or partially migrated
- Categories/courses weren't migrated
- Prices weren't migrated correctly

### Theory 3: Multiple Systems
- Live site uses a different database/system than V1
- Restaurant owner manually updates live site
- V1 database (which V3 migrated from) was never the source of truth
- Need to migrate from live site's actual backend

---

## 🔧 INVESTIGATION TASKS

### Task 1: Identify Live Site's Backend ✅ COMPLETE
**Findings:** Custom PHP system, not using V3, no clear API version

**Recommended for:** ~~Goose with Chrome DevTools~~

### Task 2: Check V1 Database for Prima Pizza
**Goal:** Verify if V1 DB has current data or stale data
**Queries:**
```sql
-- Check V1 database for restaurant ID 1069 (Prima's legacy ID)
-- Compare dishes, prices, categories with live site
```

**Recommended for:** Cursor with Supabase connection to V1 (if accessible)

### Task 3: Audit Other Restaurants
**Goal:** Determine if this is a Prima Pizza issue or system-wide
**Sample:** Check 5-10 restaurants, compare V3 data with their live sites

**Recommended for:** Goose with Auto Visualiser to create comparison report

### Task 4: Find Data Source of Truth
**Options:**
1. V1 database (menuca_v1 schema)
2. V2 database (menuca_v2 schema)
3. Live sites' backend APIs
4. Restaurant owner's current menus (manual entry)

**Recommended for:** Backend team coordination + Cursor SQL investigation

### Task 5: Create Data Re-sync Strategy
**Depends on findings from Tasks 2-4**

**Deliverable:** Migration script or API integration plan

---

## 🎬 RECOMMENDED APPROACH

### Phase 1: Investigation (Cursor Agent)
**Task:** Access V1 and V2 databases, query Prima Pizza data, compare with V3
```sql
-- V1 query
SELECT * FROM menuca_v1.dishes WHERE restaurant_id = 1069;
SELECT * FROM menuca_v1.courses WHERE restaurant_id = 1069;

-- V2 query (if exists)
SELECT * FROM menuca_v2.dishes WHERE restaurant_id = ?;
```

**Output:** Document which system has accurate current data

### Phase 2: Pattern Analysis (Goose Agent)
**Task:**
1. Sample 10 restaurants from different categories
2. Visit their live sites
3. Compare menus with V3 database
4. Calculate mismatch percentage
5. Create visual report

**Tools:** Playwright MCP (visit sites), Auto Visualiser (create charts)

**Output:** Report showing scope of problem (1 restaurant? 10? All?)

### Phase 3: Data Sync Decision (Backend Team + You)
**Options:**
- **A)** Re-export from V1 with current data
- **B)** Build API scraper for live sites
- **C)** Manual menu entry/update by restaurant owners
- **D)** Hybrid: migrate what's available, flag for owner review

---

## 🚧 BLOCKERS FOR FRONTEND

1. ❌ **Cannot test real menus** - data is wrong
2. ❌ **Cannot validate pricing** - prices don't match
3. ❌ **Cannot test categories** - no categories in DB
4. ❌ **Cannot launch to customers** - would show wrong menu

**Frontend work CAN continue on:**
- ✅ Modifier groups system (working correctly with whatever data exists)
- ✅ Cart functionality
- ✅ Checkout flow (with test data)
- ✅ UI/UX improvements

**Frontend work BLOCKED on:**
- ❌ Real restaurant testing
- ❌ End-to-end order flow validation
- ❌ Production deployment
- ❌ Customer beta testing

---

## 📋 NEXT STEPS

### Immediate (Today)
1. ✅ Document issue (this file)
2. ⏳ Cursor: Query V1/V2 databases for Prima Pizza data
3. ⏳ Goose: Sample 5 restaurants, create comparison matrix

### Short Term (This Week)
4. Identify source of truth for menu data
5. Determine if problem is isolated or system-wide
6. Create data re-sync strategy

### Medium Term (Next Week)
7. Execute data sync/migration
8. Validate all restaurant data
9. Resume frontend testing with accurate data

---

## 🔗 RELATED FILES

- `/Frontend-build/MODIFIER_GROUPS_DATA_ISSUE.md` - Modifier migration (separate, fixed issue)
- `/Frontend-build/RESTAURANT_DATA_AUDIT_2025_10_24.md` - Previous data audit
- `/Frontend-build/DATABASE_SCHEMA_REFERENCE.md` - Schema documentation

---

## 📞 AGENT ASSIGNMENTS

### Cursor Agent (Backend/SQL Expert)
**Primary Tasks:**
1. Access menuca_v1 schema (if exists in Supabase)
2. Query Prima Pizza data from V1, compare with V3
3. Check if V2 database exists
4. Document which database has current accurate data
5. Propose SQL migration/sync strategy

**Why Cursor:** Direct Supabase access, SQL expertise, can write migration scripts

### Goose Agent (Testing/Analysis)
**Primary Tasks:**
1. Visit 10 sample restaurant live sites with Playwright
2. Extract their menus (categories, dishes, prices)
3. Compare with menuca_v3 database
4. Create visual comparison report with Auto Visualiser
5. Calculate: % of restaurants with data mismatches

**Why Goose:** Playwright for web scraping, Auto Visualiser for reports, good for repetitive tasks

### Claude (Frontend/Coordinator)
**Primary Tasks:**
1. Maintain documentation
2. Coordinate findings between Cursor and Goose
3. Continue frontend development on non-blocked features
4. Test with whatever data is available
5. Report findings to user

---

## 📈 SUCCESS CRITERIA

**Issue is resolved when:**
1. ✅ Prima Pizza's V3 menu matches live site (m.primapizza.ca)
2. ✅ All dishes have correct prices
3. ✅ Categories/courses are properly assigned
4. ✅ Sample audit of 10 restaurants shows <5% discrepancy
5. ✅ Frontend can test real menus and complete orders

---

**Status:** 🔴 CRITICAL - Investigation in Progress
**Owner:** Backend Team + Cursor Agent
**Reporter:** Claude (Frontend Agent)
**Created:** 2025-10-27
**Last Updated:** 2025-10-27
