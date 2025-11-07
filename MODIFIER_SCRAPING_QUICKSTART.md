# Modifier Scraping Quick Start Guide

## 🎯 Goal
Extract dish-to-modifier relationships from 26 Menu.ca restaurants and import into Supabase V3 database.

## 📝 Prerequisites

- [x] Node.js 18+ installed
- [x] Supabase project with `menuca_v3` schema
- [x] MCP access for Supabase (or SQL editor access)
- [x] List of 26 restaurant URLs

## 🚀 Step-by-Step Workflow

### Step 1: Setup (5 minutes)

```bash
# Navigate to project
cd /Users/brianlapp/Documents/GitHub/Migration-Strategy

# Install dependencies (already done)
npm install

# Create output directories
mkdir -p scraped-data screenshots sql-generated
```

### Step 2: Configure Restaurants (10 minutes)

Edit [scripts/scrapers/restaurants-config.ts](scripts/scrapers/restaurants-config.ts):

```typescript
export const RESTAURANTS: RestaurantConfig[] = [
  {
    id: 'papa-burger',
    name: 'Papa Burger',
    version: 'v1',
    baseUrl: 'https://papaburger.ca/?p=menu',
    dishLimit: 10,
    notes: 'Multi-step combo customization'
  },
  {
    id: 'parea-greek',
    name: 'Paréa Authentic Greek',
    version: 'v2',
    baseUrl: 'https://ordereast.eatparea.com/index.php/menu',
    dishLimit: 10,
    notes: 'Grouped customization'
  },
  // Add your other 24 restaurants...
];
```

**How to determine version:**
- **V1**: Clicking "Add to Cart" opens a modal with "Next" buttons between steps
- **V2**: Clicking a dish goes to `/dish/create/` page with all options visible at once

### Step 3: Test Scrape (2 restaurants, 10 minutes)

```bash
# Test with 2 restaurants first
npm run scrape -- papa-burger parea-greek
```

**Expected output:**
```
🚀 STARTING SCRAPE SESSION
Total Restaurants: 2

[1/2] Processing: Papa Burger
[V1] Found 20 dishes, will scrape up to 10
[V1] Processing dish 1/10
[V1] Clicking dish: Combo Pour 1 ($22.95)
[V1]   Step 1: Sauces pour Ailes (4 options)
[V1]   Step 2: Boissons (4 options)
[V1] Screenshot saved: 0-dish-0-modal-opened.png
...

✅ Papa Burger (papa-burger)
   Dishes: 10, Groups: 18, Options: 72

✅ Paréa Authentic Greek (parea-greek)
   Dishes: 10, Groups: 25, Options: 98

📄 Full session report saved to: scraped-data/scrape-session-{timestamp}.json
```

**Check:**
- [ ] JSON files in `scraped-data/papa-burger/` and `scraped-data/parea-greek/`
- [ ] Screenshots in `screenshots/papa-burger/` and `screenshots/parea-greek/`
- [ ] Session report in `scraped-data/`

### Step 4: Validate Test Data (5 minutes)

```bash
npm run validate-scraped-data
```

**Expected output:**
```
📋 Found 2 restaurant directories to validate

✅ Papa Burger (papa-burger)
   Dishes: 10, Groups: 18, Options: 72

✅ Paréa Authentic Greek (parea-greek)
   Dishes: 10, Groups: 25, Options: 98

=================================================================================
📊 VALIDATION SUMMARY
=================================================================================
Total Restaurants: 2
✅ Valid:          2
❌ Invalid:        0

📦 Total Data:
   Dishes:         20
   Modifier Groups: 43
   Modifier Options: 170

✨ All restaurants passed validation!
   Ready to import to Supabase.
```

**If validation fails:**
1. Review issues in `scraped-data/validation-report.json`
2. Check screenshots to verify scraped data
3. Adjust scraper selectors if needed
4. Re-run scrape for failed restaurants

### Step 5: Spot-Check Against Live Sites (10 minutes)

Manually verify 2-3 dishes from each test restaurant:

**Example: Papa Burger "Combo Pour 1"**

1. Open https://papaburger.ca/?p=menu in browser
2. Click "Choisissez cet item" on "Combo Pour 1"
3. Compare modal steps with `scraped-data/papa-burger/{file}.json`

**Check:**
- [ ] All modifier groups are present
- [ ] All options within each group are captured
- [ ] Prices are correct (especially for paid add-ons)
- [ ] Required/optional status is accurate

### Step 6: Run Full Scrape (1.5-2 hours)

Once test results look good:

```bash
# Scrape all 26 restaurants
npm run scrape-all
```

**Tips:**
- Run during off-peak hours
- Keep terminal visible to monitor progress
- If a restaurant fails, it will continue with others
- Errors are logged in session report

### Step 7: Validate All Data (5 minutes)

```bash
npm run validate-scraped-data
```

**Review the report:**
- Fix any critical errors before importing
- Warnings are often acceptable (e.g., dishes without modifiers)
- Document any known issues

### Step 8: Generate SQL (2 minutes)

```bash
npm run import-to-supabase
```

**Output:**
- `sql-generated/papa-burger-import.sql`
- `sql-generated/parea-greek-import.sql`
- ... (one file per restaurant)

**Each SQL file contains:**
- Table inserts for modifier_groups, modifier_options
- Group-to-dish assignments
- Upsert logic (safe to run multiple times)

### Step 9: Review SQL (10 minutes)

Spot-check a few SQL files:

```sql
-- Should see blocks like this:
INSERT INTO menuca_v3.modifier_groups (
  restaurant_id, name, select_type, min_selections, max_selections, ...
) VALUES (
  v_restaurant_id,
  'Sauces pour Ailes',
  'single',
  1,
  1,
  ...
);

INSERT INTO menuca_v3.modifier_options (
  group_id, name, price_delta, ...
) VALUES (
  v_group_0_id,
  'Tzatziki',
  0.00,
  ...
);
```

### Step 10: Import to Supabase (via MCP, 5 minutes per restaurant)

#### Option A: Using MCP in Cursor/Claude

```
"Execute the SQL file sql-generated/papa-burger-import.sql on Supabase project {projectId}"
```

Repeat for each restaurant.

#### Option B: Manual via Supabase Dashboard

1. Open https://supabase.com/dashboard/project/{projectId}/sql
2. Copy/paste SQL from `sql-generated/papa-burger-import.sql`
3. Click "Run"
4. Repeat for each restaurant

#### Option C: CLI (if configured)

```bash
for file in sql-generated/*.sql; do
  echo "Importing $file..."
  supabase db execute -f "$file"
done
```

### Step 11: Verify in Database (5 minutes)

Run queries in Supabase SQL editor:

```sql
-- Check total counts
SELECT
  (SELECT COUNT(*) FROM menuca_v3.modifier_groups) as groups,
  (SELECT COUNT(*) FROM menuca_v3.modifier_options) as options,
  (SELECT COUNT(*) FROM menuca_v3.modifier_group_assignments) as assignments;

-- Check a specific restaurant
SELECT
  d.name as dish_name,
  mg.name as group_name,
  mg.select_type,
  mg.is_required,
  COUNT(mo.id) as option_count
FROM menuca_v3.dishes d
JOIN menuca_v3.modifier_group_assignments mga ON mga.dish_id = d.id
JOIN menuca_v3.modifier_groups mg ON mg.id = mga.group_id
LEFT JOIN menuca_v3.modifier_options mo ON mo.group_id = mg.id
WHERE d.restaurant_id = {restaurant_id}
GROUP BY d.id, d.name, mg.id, mg.name, mg.select_type, mg.is_required
ORDER BY d.name, mg.display_order;
```

**Expected results:**
- Hundreds of modifier groups
- Thousands of modifier options
- Each dish with modifiers has assignments

## 🎯 Success Checklist

- [ ] All 26 restaurants configured
- [ ] Test scrape successful (2 restaurants)
- [ ] Test validation passes
- [ ] Spot-checked test data against live sites
- [ ] Full scrape completes (26 restaurants)
- [ ] Full validation passes (or issues documented)
- [ ] SQL generated for all restaurants
- [ ] SQL reviewed for correctness
- [ ] Data imported to Supabase
- [ ] Database verification queries run
- [ ] Spot-checked 2-3 restaurants in database against live sites

## 🐛 Common Issues & Fixes

### Issue: Scraper hangs on "Waiting for selector"

**Fix:**
```typescript
// In v1-scraper.ts or v2-scraper.ts
await page.waitForSelector('text=...', { timeout: 10000 }); // Increase timeout
```

### Issue: No modifiers extracted for a dish

**Possible causes:**
1. Dish has no customization (expected)
2. Selectors don't match site structure (adjust scraper)
3. Modal didn't open (check screenshots)

**Fix:** Review screenshots, adjust selectors in `extractCurrentStep()` or `extractModifierGroups()`

### Issue: Validation shows "duplicate group names"

**Cause:** Scraper identified same heading multiple times

**Fix:**
```typescript
// Add deduplication in scraper
const groupsSeen = new Set<string>();
if (groupsSeen.has(groupName)) continue;
groupsSeen.add(groupName);
```

### Issue: SQL import fails "restaurant not found"

**Cause:** Restaurant doesn't exist in `menuca_v3.restaurants` yet

**Fix:**
```sql
-- First, ensure restaurant exists:
INSERT INTO menuca_v3.restaurants (name, website, is_active)
VALUES ('Papa Burger', 'https://papaburger.ca', true)
ON CONFLICT (name) DO NOTHING;
```

## 📊 Expected Metrics (26 restaurants, 10 dishes each)

| Metric | Estimated |
|--------|-----------|
| Total Dishes | ~260 |
| Total Groups | ~500-800 |
| Total Options | ~2000-4000 |
| Unique Groups (deduplicated) | ~100-200 |
| Scrape Duration | 1.5-2 hours |
| Import Duration (MCP) | 10-15 minutes |

## 📞 Need Help?

1. Check [scripts/scrapers/README.md](scripts/scrapers/README.md) for detailed documentation
2. Review [Database/Menu & Catalog Entity/v3_modifier_schema.sql](Database/Menu%20&%20Catalog%20Entity/v3_modifier_schema.sql) for schema
3. Check screenshots in `screenshots/{restaurant}/` to debug UI issues
4. Review validation report in `scraped-data/validation-report.json`

---

**Ready to start? Jump to [Step 2: Configure Restaurants](#step-2-configure-restaurants-10-minutes)**
