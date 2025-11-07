# Menu Modifier Scraping & Import System

Complete system for scraping dish modifiers from Menu.ca V1/V2 sites and importing them into Supabase V3 database.

## 📋 Overview

This system extracts the hidden dish-to-modifier relationships from restaurant websites and stores them in a normalized database schema. It handles both:

- **V1 sites** (e.g., Papa Burger): Multi-step modal workflows with sequential customization
- **V2 sites** (e.g., Paréa): Single-page customization with grouped radio/checkbox options

## 🏗️ Architecture

```
┌─────────────────────┐
│  Restaurant Config  │  restaurants-config.ts
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Playwright        │
│   Scrapers          │  v1-scraper.ts, v2-scraper.ts
│  • V1: Modal steps  │
│  • V2: Form groups  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   JSON Output       │  scraped-data/{restaurant}/
│  • Raw extracts     │  {restaurant}-{timestamp}.json
│  • Screenshots      │  screenshots/{restaurant}/
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Validator         │  validate-scraped.ts
│  • Structure checks │
│  • Data integrity   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   SQL Generator     │  supabase-import.ts
│  • Creates SQL      │  sql-generated/{restaurant}-import.sql
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Supabase V3 DB    │  Via MCP or manual execution
│  • modifier_groups  │
│  • modifier_options │
│  • group_assignments│
└─────────────────────┘
```

## 🚀 Quick Start

### 1. Configure Restaurants

Edit [restaurants-config.ts](./restaurants-config.ts) and add your 26 restaurants:

```typescript
{
  id: 'my-restaurant',
  name: 'My Restaurant Name',
  version: 'v1', // or 'v2'
  baseUrl: 'https://myrestaurant.com/menu',
  dishLimit: 10, // optional
  notes: 'Any special notes'
}
```

### 2. Run Scrapers

```bash
# Scrape all configured restaurants
npm run scrape-all

# Scrape specific restaurants
npm run scrape -- papa-burger parea-greek

# Scrape with screenshots (for debugging)
# Edit scraper config: headless: false
```

**Output:**
- `scraped-data/{restaurant}/{restaurant}-{timestamp}.json` - Raw data
- `screenshots/{restaurant}/` - Screenshot evidence
- `scraped-data/scrape-session-{timestamp}.json` - Session report

### 3. Validate Data

```bash
npm run validate-scraped-data
```

This checks:
- ✅ All dishes have names and prices
- ✅ Groups have at least one option
- ✅ Min/max selection rules are logical
- ✅ No duplicate group names per dish
- ✅ Price deltas are present

**Output:**
- `scraped-data/validation-report.json`
- Console summary with issues

### 4. Generate SQL

```bash
npm run import-to-supabase
```

**Output:**
- `sql-generated/{restaurant}-import.sql` for each restaurant
- Safe to review before execution

### 5. Import to Supabase

#### Option A: Using MCP (Recommended)

Your Cursor agent with Supabase MCP access can execute the SQL:

```bash
# In Cursor/Claude with MCP:
"Execute the SQL file sql-generated/papa-burger-import.sql on project {projectId}"
```

#### Option B: Manual via Supabase Dashboard

1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql)
2. Copy/paste SQL from `sql-generated/{restaurant}-import.sql`
3. Execute

#### Option C: CLI

```bash
# If you have Supabase CLI configured
supabase db execute -f sql-generated/papa-burger-import.sql
```

## 📊 Data Schema

### Tables Created

#### `menuca_v3.modifier_groups`
Groups of related options (e.g., "Sauces", "Toppings")

| Column | Type | Description |
|--------|------|-------------|
| id | bigserial | Primary key |
| restaurant_id | integer | Restaurant FK |
| name | varchar(255) | Group name |
| select_type | varchar(20) | 'single' or 'multi' |
| min_selections | integer | Minimum required (0 = optional) |
| max_selections | integer | Max allowed (NULL = unlimited) |
| is_required | boolean | Must customer select something? |
| display_order | integer | Sort order |

#### `menuca_v3.modifier_options`
Individual choices within a group

| Column | Type | Description |
|--------|------|-------------|
| id | bigserial | Primary key |
| group_id | bigint | Group FK |
| name | varchar(255) | Option name |
| price_delta | decimal(10,2) | Price adjustment (+/- from base) |
| is_default | boolean | Pre-selected? |
| display_order | integer | Sort order |

#### `menuca_v3.modifier_group_assignments`
Links groups to dishes/courses/restaurants (supports inheritance)

| Column | Type | Description |
|--------|------|-------------|
| id | bigserial | Primary key |
| restaurant_id | integer | Restaurant FK |
| group_id | bigint | Group FK |
| dish_id | bigint | Specific dish (or NULL) |
| course_id | bigint | Course-wide (or NULL) |
| is_required | boolean | Override group default |
| step_order | integer | For V1 multi-step (NULL = single page) |
| display_order | integer | Sort order |

**Inheritance precedence:** Dish-specific > Course-wide > Restaurant-wide

## 🔍 How It Works

### V1 Scraping (Multi-step Modals)

1. Navigate to menu page
2. Click "Choisissez cet item" button
3. Wait for modal to open
4. Parse current step's group name and options
5. Select first option to enable "Next" button
6. Click "Next" to advance to next step
7. Repeat until final "Submit" button appears
8. Extract all steps, then close modal (ESC)

**Key challenges solved:**
- Button states (disabled until selection)
- French/English text variations
- Price parsing from "Name - $X.XX" format
- Distinguishing group titles from option text

### V2 Scraping (Single-page Forms)

1. Navigate to menu page
2. Click "PICK UP" if address gate present
3. Navigate to dish create page (`/dish/create/{id}/0`)
4. Wait for form to render
5. Find all fieldsets/option groups
6. For each group:
   - Extract legend/heading as group name
   - Find radio/checkbox inputs
   - Extract labels and price deltas
   - Determine if required (heuristics)
7. Screenshot and return

**Key challenges solved:**
- Address/pickup gating
- Fieldset vs. div-based group containers
- Price delta extraction from labels
- Determining min/max from input types

## 📁 File Structure

```
scripts/
├── scrapers/
│   ├── types.ts                 # TypeScript definitions
│   ├── v1-scraper.ts           # V1 site scraper
│   ├── v2-scraper.ts           # V2 site scraper
│   ├── restaurants-config.ts   # Restaurant list
│   ├── run-all.ts              # Main runner
│   └── README.md               # This file
├── validation/
│   └── validate-scraped.ts     # Data validator
└── import/
    └── supabase-import.ts      # SQL generator

Database/Menu & Catalog Entity/
└── v3_modifier_schema.sql      # DB schema

scraped-data/                    # Output directory
├── {restaurant}/
│   └── {restaurant}-{ts}.json
├── scrape-session-{ts}.json
└── validation-report.json

screenshots/                     # Screenshot evidence
└── {restaurant}/
    └── {counter}-{name}.png

sql-generated/                   # Generated SQL
└── {restaurant}-import.sql
```

## 🛠️ Troubleshooting

### Scraper hangs on a dish

**Cause:** Modal didn't open or unexpected UI structure

**Fix:**
1. Set `headless: false` in scraper config to watch
2. Check screenshots in `screenshots/{restaurant}/`
3. Adjust selectors in `v1-scraper.ts` or `v2-scraper.ts`

### No options extracted

**Cause:** Different DOM structure than expected

**Fix:**
1. Review screenshot to see actual structure
2. Update `extractCurrentStep()` (V1) or `extractModifierGroups()` (V2)
3. Add fallback selectors

### Price extraction incorrect

**Cause:** Different price format (e.g., EUR, no decimals)

**Fix:**
1. Update regex in price parsing functions
2. Handle comma vs. period decimals
3. Check for currency symbols

### Validation errors

**Cause:** Scraped data has issues

**Fix:**
1. Review `validation-report.json` for specifics
2. Common issues:
   - Duplicate group names → Scraper identified wrong elements
   - Min > options → Group had fewer options than expected
   - Missing prices → Price selector didn't match

## 🎯 Best Practices

### Before Scraping

1. ✅ Test on 1-2 restaurants first
2. ✅ Run with `dishLimit: 5` initially
3. ✅ Keep `headless: true` for speed (use `false` for debugging)
4. ✅ Ensure stable internet connection

### During Scraping

1. ✅ Monitor console for errors
2. ✅ Check if screenshots are being saved
3. ✅ Don't scrape too fast (3s delay between restaurants)

### After Scraping

1. ✅ **Always** validate before importing
2. ✅ Manually spot-check 2-3 dishes per restaurant
3. ✅ Compare JSON with live site
4. ✅ Review generated SQL before execution

## 📈 Performance

- **V1 sites:** ~30-45 seconds per dish (multi-step modals)
- **V2 sites:** ~10-15 seconds per dish (single page)
- **Total for 26 restaurants** (10 dishes each): ~1.5-2 hours

**Optimization tips:**
- Run during off-peak hours
- Use `dishLimit` to test smaller batches
- Run multiple instances (split restaurant list)

## 🔐 Security Notes

- Scrapers do **not** log in or access authenticated areas
- All data scraped is publicly visible on restaurant menus
- No PII or payment data is collected
- Generated SQL uses parameterized inserts (safe from injection)

## 🧪 Testing

### Test a Single Dish (V1)

```bash
# Edit v1-scraper.ts and add at bottom:
const testConfig = {
  restaurantName: 'Papa Burger',
  baseUrl: 'https://papaburger.ca/?p=menu',
  version: 'v1' as const,
  headless: false
};

scrapeV1Restaurant(testConfig).then(result => {
  console.log(JSON.stringify(result.dishes[0], null, 2));
});
```

```bash
npx ts-node scripts/scrapers/v1-scraper.ts
```

### Test a Single Dish (V2)

```bash
# Edit v2-scraper.ts and add at bottom:
const testUrls = [
  'https://ordereast.eatparea.com/index.php/dish/create/10917/0'
];

const scraper = new V2Scraper({
  restaurantName: 'Paréa',
  baseUrl: 'https://ordereast.eatparea.com/index.php/menu',
  version: 'v2',
  headless: false
});

scraper.initialize()
  .then(() => scraper.scrapeMenu(testUrls))
  .then(result => console.log(JSON.stringify(result, null, 2)))
  .finally(() => scraper.close());
```

```bash
npx ts-node scripts/scrapers/v2-scraper.ts
```

## 🎓 Understanding the Data Model

### Example: Pork Gyro Pita (V2)

**Scraped JSON:**
```json
{
  "dish": {
    "name": "Pork Gyro Pita - Regular",
    "basePrice": 10.00
  },
  "groups": [
    {
      "name": "Choose your sauce",
      "selectType": "single",
      "minSelections": 1,
      "maxSelections": 1,
      "isRequired": true,
      "options": [
        { "name": "Tzatziki", "priceDelta": 0 },
        { "name": "Garlic Sauce", "priceDelta": 0 }
      ]
    },
    {
      "name": "Extras",
      "selectType": "multi",
      "minSelections": 0,
      "maxSelections": null,
      "isRequired": false,
      "options": [
        { "name": "Extra Feta", "priceDelta": 2.00 },
        { "name": "Extra Meat", "priceDelta": 3.50 }
      ]
    }
  ]
}
```

**Resulting DB structure:**

```sql
-- modifier_groups
id=1, name='Choose your sauce', select_type='single', min=1, max=1
id=2, name='Extras', select_type='multi', min=0, max=NULL

-- modifier_options
id=1, group_id=1, name='Tzatziki', price_delta=0.00
id=2, group_id=1, name='Garlic Sauce', price_delta=0.00
id=3, group_id=2, name='Extra Feta', price_delta=2.00
id=4, group_id=2, name='Extra Meat', price_delta=3.50

-- modifier_group_assignments
id=1, group_id=1, dish_id=10917, is_required=true
id=2, group_id=2, dish_id=10917, is_required=false
```

**Customer orders with:**
- Sauce: Tzatziki (required, +$0)
- Extras: Extra Feta (+$2)

**Total:** $10.00 (base) + $0 + $2.00 = **$12.00**

## 📞 Support

For issues or questions:
1. Check this README first
2. Review [types.ts](./types.ts) for data structures
3. Check [v3_modifier_schema.sql](../../Database/Menu%20&%20Catalog%20Entity/v3_modifier_schema.sql) for DB schema
4. Open an issue with:
   - Restaurant name and URL
   - Error message or unexpected behavior
   - Screenshot if UI-related

## 🎉 Success Checklist

- [ ] All 26 restaurants configured in `restaurants-config.ts`
- [ ] Scrapers run without fatal errors
- [ ] JSON files generated in `scraped-data/`
- [ ] Validation passes (or issues documented)
- [ ] SQL files generated in `sql-generated/`
- [ ] Spot-checked 2-3 dishes per restaurant against live sites
- [ ] SQL executed via MCP or manually
- [ ] Verified data in Supabase dashboard
- [ ] Screenshots saved for audit trail

---

**Built with ❤️ for Menu.ca V3 Migration**
