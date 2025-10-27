# Restaurant Data Audit Report
**Date:** October 24, 2025
**Database:** menuca_v3 (Supabase)
**Purpose:** Identify which "active" restaurants have usable menu data for customer frontend

---

## 🚨 CRITICAL FINDINGS

Out of **277 restaurants marked as "active"**:
- ❌ **248 restaurants (89.5%) have NO MENU DATA**
- ✅ **29 restaurants (10.5%) have active menu data**
- ⭐ **5 restaurants (1.8%) are FULLY READY** (menu + location + contact + schedule)

### Summary Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| Total "Active" Restaurants | 277 | 100% |
| **With Menu Data** | **29** | **10.5%** ✅ |
| **WITHOUT Menu Data** | **248** | **89.5%** ❌ |
| With Location Data | 254 | 91.7% |
| With Contact Data | 204 | 73.6% |
| With Schedule Data | 34 | 12.3% |
| Online Ordering Enabled | 277 | 100% |
| **FULLY READY (all data)** | **5** | **1.8%** ⭐ |
| Menu Only (missing other data) | 24 | 8.7% |

---

## ✅ THE 29 RESTAURANTS WITH MENU DATA

### Restaurant IDs (for SQL queries/filtering)
```
8, 15, 42, 54, 65, 72, 89, 90, 119, 126, 131, 147, 174, 180,
245, 267, 269, 427, 486, 511, 929, 963, 964, 965, 966, 973, 974, 978
```

---

## ⭐ FULLY READY RESTAURANTS (5 total)
**These have: Menu + Location + Contact + Schedule**

### 1. Pho Dau Bo Restaurant - Kitchener
- **ID:** 147
- **Slug:** `pho-dau-bo-restaurant-kitchener-147`
- **URL:** `http://localhost:3001/r/pho-dau-bo-restaurant-kitchener-147`
- **Menu:** 11 courses, 186 dishes 🎉
- **Status:** FULLY READY ✅

### 2. New Mee Fung Restaurant
- **ID:** 15
- **Slug:** `new-mee-fung-restaurant-15`
- **URL:** `http://localhost:3001/r/new-mee-fung-restaurant-15`
- **Menu:** 12 courses, 143 dishes
- **Status:** FULLY READY ✅

### 3. Lucky Star Chinese Food
- **ID:** 8
- **Slug:** `lucky-star-chinese-food-8`
- **URL:** `http://localhost:3001/r/lucky-star-chinese-food-8`
- **Menu:** 19 courses, 142 dishes
- **Status:** FULLY READY ✅

### 4. Wandee Thai Cuisine Sept 2022
- **ID:** 486
- **Slug:** `wandee-thai-cuisine-sept-2022-486`
- **URL:** `http://localhost:3001/r/wandee-thai-cuisine-sept-2022-486`
- **Menu:** 18 courses, 35 dishes
- **Status:** FULLY READY ✅

### 5. Papa Joe's Pizza - Bridle Path
- **ID:** 427
- **Slug:** `papa-joes-pizza-bridle-path-427`
- **URL:** `http://localhost:3001/r/papa-joes-pizza-bridle-path-427`
- **Menu:** 14 courses, 15 dishes
- **Status:** FULLY READY ✅

---

## ⚠️ MENU ONLY RESTAURANTS (24 total)
**These have menu data but may be missing location/contact/schedule info**

### Top 10 by Dish Count

| ID | Name | Slug | Courses | Dishes |
|----|------|------|---------|--------|
| 72 | Cathay Restaurants | `cathay-restaurants-72` | 30 | 233 |
| 269 | Shaan Tandoori | `shaan-tandoori-269` | 22 | 199 |
| 42 | Cypress Garden | `cypress-garden-42` | 14 | 169 |
| 245 | Orchid Sushi | `orchid-sushi-245` | 16 | 160 |
| 119 | Hung Mein | `hung-mein-119` | 16 | 160 |
| 267 | Lucky Fortune | `lucky-fortune-267` | 19 | 157 |
| 966 | Chicco Pizza de l'Hopital | `chicco-pizza-de-lhopital-966` | 11 | 152 |
| 174 | Lucky King Take Out | `lucky-king-take-out-174` | 14 | 141 |
| 973 | Capital Bites | `capital-bites-973` | 14 | 138 |
| 65 | Number One Chinese Take Out | `number-one-chinese-take-out-65` | 16 | 126 |

### All Menu-Only Restaurants

| ID | Name | Slug | Courses | Dishes |
|----|------|------|---------|--------|
| 72 | Cathay Restaurants | `cathay-restaurants-72` | 30 | 233 |
| 269 | Shaan Tandoori | `shaan-tandoori-269` | 22 | 199 |
| 42 | Cypress Garden | `cypress-garden-42` | 14 | 169 |
| 245 | Orchid Sushi | `orchid-sushi-245` | 16 | 160 |
| 119 | Hung Mein | `hung-mein-119` | 16 | 160 |
| 267 | Lucky Fortune | `lucky-fortune-267` | 19 | 157 |
| 966 | Chicco Pizza de l'Hopital | `chicco-pizza-de-lhopital-966` | 11 | 152 |
| 174 | Lucky King Take Out | `lucky-king-take-out-174` | 14 | 141 |
| 973 | Capital Bites | `capital-bites-973` | 14 | 138 |
| 65 | Number One Chinese Take Out | `number-one-chinese-take-out-65` | 16 | 126 |
| 929 | Tony's Pizza | `tonys-pizza-929` | 11 | 123 |
| 180 | Indian Punjabi Clay Oven | `indian-punjabi-clay-oven-180` | 11 | 115 |
| 964 | Chicco Pizza Maloney | `chicco-pizza-maloney-964` | 11 | 106 |
| 974 | Pachino Pizza | `pachino-pizza-974` | 12 | 100 |
| 511 | Egg Roll Factory | `egg-roll-factory-511` | 16 | 96 |
| 924 | All Out Burger Bank St. | `all-out-burger-bank-st-924` | 10 | 56 |
| 89 | Milano | `milano-89` | 17 | 48 |
| 963 | Chicco Pizza Shawarma Anger | `chicco-pizza-shawarma-anger-963` | 12 | 37 |
| 54 | House of Pizza | `house-of-pizza-54` | 4 | 15 |
| 131 | Centertown Donair & Pizza | `centertown-donair-pizza-131` | 4 | 12 |
| 90 | Milano | `milano-90` | 18 | 11 |
| 126 | Milano | `milano-126` | 1 | 9 |
| 965 | Chicco Shawarma Maloney | `chicco-shawarma-maloney-965` | 6 | 8 |
| 978 | Riverside Pizzeria | `riverside-pizzeria-978` | 12 | 2 |

---

## 🧪 TESTING RECOMMENDATIONS

### For Frontend Testing
**Use these URLs for guaranteed menu data:**

```
http://localhost:3001/r/pho-dau-bo-restaurant-kitchener-147
http://localhost:3001/r/lucky-star-chinese-food-8
http://localhost:3001/r/cathay-restaurants-72
http://localhost:3001/r/shaan-tandoori-269
http://localhost:3001/r/cypress-garden-42
```

### For SQL Filtering
**Filter by these IDs to only show restaurants with menu data:**

```sql
WHERE restaurant_id IN (
  8, 15, 42, 54, 65, 72, 89, 90, 119, 126, 131, 147, 174, 180,
  245, 267, 269, 427, 486, 511, 929, 963, 964, 965, 966, 973, 974, 978
)
```

---

## ❌ THE PROBLEM

The other **248 restaurants** are marked as:
- `status = 'active'`
- `online_ordering_enabled = true`
- But have **0 courses and 0 dishes**

When customers visit these restaurant pages:
- ❌ Blank menu page displays
- ❌ "No menu available" message shows
- ❌ Poor user experience
- ❌ Looks like a broken website

---

## 💡 RECOMMENDED FIXES

### Option 1: Database-Level Fix (Best for Backend Team)
Add a `menu_ready` boolean column to restaurants table and update it:

```sql
ALTER TABLE menuca_v3.restaurants
ADD COLUMN menu_ready BOOLEAN DEFAULT false;

UPDATE menuca_v3.restaurants r
SET menu_ready = true
WHERE EXISTS (
  SELECT 1 FROM menuca_v3.courses c
  WHERE c.restaurant_id = r.id
  AND c.is_active = true
  AND c.deleted_at IS NULL
)
AND EXISTS (
  SELECT 1 FROM menuca_v3.dishes d
  WHERE d.restaurant_id = r.id
  AND d.is_active = true
  AND d.deleted_at IS NULL
);
```

Then filter queries by `menu_ready = true`.

### Option 2: Frontend Filter (Quick Fix)
Update search/listing queries to only show the 29 restaurants with menu data:

```typescript
const { data: restaurants } = await supabase
  .from('restaurants')
  .select('*')
  .eq('status', 'active')
  .in('id', [8, 15, 42, 54, 65, 72, 89, 90, 119, 126, 131, 147, 174, 180,
             245, 267, 269, 427, 486, 511, 929, 963, 964, 965, 966, 973, 974, 978])
```

### Option 3: View-Based Filter (Recommended)
Create a database view for "customer-ready" restaurants:

```sql
CREATE VIEW menuca_v3.v_customer_ready_restaurants AS
SELECT r.*,
  COUNT(DISTINCT c.id) as course_count,
  COUNT(DISTINCT d.id) as dish_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id
  AND c.is_active = true AND c.deleted_at IS NULL
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
  AND d.is_active = true AND d.deleted_at IS NULL
WHERE r.status = 'active' AND r.deleted_at IS NULL
GROUP BY r.id
HAVING COUNT(DISTINCT c.id) > 0 AND COUNT(DISTINCT d.id) > 0;
```

Then query from the view instead of the restaurants table.

---

## 📊 SQL AUDIT QUERY

To reproduce this audit:

```sql
WITH restaurant_data_audit AS (
  SELECT
    r.id,
    r.name,
    r.slug,
    r.status,

    (SELECT COUNT(*) FROM menuca_v3.courses c
     WHERE c.restaurant_id = r.id AND c.is_active = true AND c.deleted_at IS NULL) as courses,
    (SELECT COUNT(*) FROM menuca_v3.dishes d
     WHERE d.restaurant_id = r.id AND d.is_active = true AND d.deleted_at IS NULL) as dishes,
    (SELECT COUNT(*) FROM menuca_v3.restaurant_locations rl
     WHERE rl.restaurant_id = r.id AND rl.deleted_at IS NULL) as has_location,
    (SELECT COUNT(*) FROM menuca_v3.restaurant_contacts rc
     WHERE rc.restaurant_id = r.id AND rc.deleted_at IS NULL) as has_contact,
    (SELECT COUNT(*) FROM menuca_v3.restaurant_schedules rs
     WHERE rs.restaurant_id = r.id AND rs.deleted_at IS NULL) as has_schedule

  FROM menuca_v3.restaurants r
  WHERE r.status = 'active' AND r.deleted_at IS NULL
)
SELECT * FROM restaurant_data_audit
WHERE courses > 0 AND dishes > 0
ORDER BY dishes DESC;
```

---

## 🔗 RELATED DOCUMENTS

- `DATABASE_SCHEMA_REFERENCE.md` - Complete schema documentation
- `HANDOFF_TO_NEW_SESSION.md` - Context for new sessions
- `MISSING_DATABASE_COLUMNS_REPORT.md` - Missing columns in restaurants table

---

**Generated by:** Supabase MCP Schema Discovery
**Verified:** All table/column names confirmed via direct database queries
**Action Required:** Filter frontend queries to only show the 29 restaurants with menu data
