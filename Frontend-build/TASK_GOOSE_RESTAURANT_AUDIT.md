# TASK FOR GOOSE AGENT: Multi-Restaurant Menu Audit

**Priority:** 🔴 CRITICAL
**Estimated Time:** 2-3 hours
**Agent:** Goose (Testing/Analysis)
**Context:** See `/Frontend-build/DATA_DISCREPANCY_PRIMA_PIZZA.md`

---

## OBJECTIVE

Determine if the data discrepancy found in Prima Pizza is an isolated incident or a system-wide problem affecting all/most restaurants.

---

## YOUR TASKS

### Task 1: Select Restaurant Sample
**Query menuca_v3 for active restaurants with menus:**

Use Supabase MCP:
```sql
SELECT
  r.id,
  r.name,
  r.slug,
  r.legacy_v1_id,
  rl.website_url,
  COUNT(d.id) as dish_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
WHERE r.status = 'active'
  AND r.online_ordering_enabled = true
  AND rl.website_url IS NOT NULL
GROUP BY r.id, r.name, r.slug, r.legacy_v1_id, rl.website_url
HAVING COUNT(d.id) > 20
ORDER BY RANDOM()
LIMIT 10;
```

**Output:** List of 10 restaurants to audit

---

### Task 2: Visit Live Sites with Playwright
**For each restaurant:**

1. Visit their website (from `website_url` column)
2. Navigate to menu page (usually `/menu` or `/order`)
3. Extract menu structure:
   - Categories/sections
   - 5-10 sample dish names
   - Sample prices
4. Take screenshot of menu

**Save results to:** `/Frontend-build/AUDITS/restaurant_live_sites/`

Example structure:
```
/AUDITS/restaurant_live_sites/
  ├── prima-pizza-824.json
  ├── prima-pizza-824.png
  ├── restaurant-2.json
  └── ...
```

JSON format:
```json
{
  "restaurant_id": 824,
  "name": "Prima Pizza",
  "live_url": "https://m.primapizza.ca/menu",
  "scraped_at": "2025-10-27T...",
  "categories": [
    {
      "name": "Deals",
      "sample_items": [
        {"name": "Small Pizza 3 Toppings", "price": "$11.00"},
        {"name": "XL Pepperoni Pizza", "price": "$24.00"}
      ]
    },
    {
      "name": "Pizzas",
      "sample_items": [...]
    }
  ],
  "notes": "Organized categories, current prices, professional layout"
}
```

---

### Task 3: Query V3 Database for Same Restaurants
**For each restaurant from Task 1:**

```sql
SELECT
  d.id,
  d.name,
  d.base_price,
  c.name as category_name,
  d.created_at,
  d.updated_at
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON c.id = d.course_id
WHERE d.restaurant_id = [ID]
  AND d.deleted_at IS NULL
  AND d.is_active = true
ORDER BY d.name
LIMIT 20;
```

**Save results to:** `/Frontend-build/AUDITS/restaurant_v3_data/`

---

### Task 4: Compare and Score
**For each restaurant, calculate:**

1. **Category Match:** Do V3 categories match live site? (Yes/No)
2. **Dish Names Match:** % of live dishes found in V3
3. **Price Accuracy:** % of dishes with matching prices (±$0.50)
4. **Data Freshness:** Date of last V3 update vs live site currency

**Scoring:**
- 🟢 **GOOD:** >90% match, categories present, prices accurate
- 🟡 **PARTIAL:** 50-90% match, some discrepancies
- 🔴 **POOR:** <50% match, major differences (like Prima Pizza)

---

### Task 5: Create Visual Report
**Use Auto Visualiser MCP to create:**

1. **Pie Chart:** Distribution of restaurants by score (Good/Partial/Poor)
2. **Bar Chart:** % of data accuracy per restaurant
3. **Table:** Full comparison matrix

**Save to:** `/Frontend-build/AUDITS/RESTAURANT_AUDIT_REPORT_2025_10_27.md`

Include:
- Summary statistics
- Visual charts
- Detailed findings per restaurant
- Recommendations

---

## DELIVERABLES

1. ✅ JSON files for 10 restaurants (live site data)
2. ✅ Screenshots of each live menu
3. ✅ SQL query results (V3 data)
4. ✅ Comparison scoring spreadsheet
5. ✅ Visual audit report with charts
6. ✅ Summary: "Is this a Prima Pizza issue or system-wide?"

---

## KEY QUESTIONS TO ANSWER

1. How many restaurants have data discrepancies?
2. Is the V3 data mostly accurate or mostly wrong?
3. Are categories missing across the board or just Prima Pizza?
4. Are prices generally correct or generally wrong?
5. **Can we launch V3 with current data quality?**

---

## TOOLS TO USE

- **Playwright MCP:** Visit restaurant websites, scrape menus
- **Supabase MCP:** Query menuca_v3 database
- **Auto Visualiser MCP:** Create charts and graphs
- **Memory MCP:** Store findings for future reference

---

## NOTES

- Focus on quality over quantity - 10 thorough audits better than 50 shallow ones
- Take detailed notes on any patterns you observe
- If a site is down or password-protected, skip and note it
- Save all raw data - we may need it later

---

**Created:** 2025-10-27
**Assigned To:** Goose Agent
**Status:** 🔴 Ready to Start
**Expected Completion:** End of day 2025-10-27
