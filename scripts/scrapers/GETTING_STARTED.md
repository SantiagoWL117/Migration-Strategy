# Getting Started - First Run

## ⚡ Quick Test (5 minutes)

Let's verify everything works with a single dish test:

```bash
# Test V1 scraper (Papa Burger)
npm run test-scraper

# Or test V2 scraper (Paréa)
npm run test-scraper -- --v2

# Or test both
npm run test-scraper -- --both
```

**What this does:**
1. Opens a browser window (you can watch it work!)
2. Navigates to the menu
3. Clicks one dish
4. Extracts all modifier groups and options
5. Shows you the JSON structure
6. Saves output to `scraped-data/test-v1/` or `test-v2/`

**Expected output:**
```
🧪 Testing V1 Scraper (Papa Burger)

🚀 STARTING SCRAPE SESSION
[V1] Navigating to https://papaburger.ca/?p=menu
[V1] Found 20 dishes, will scrape up to 10
[V1] Processing dish 1/10
[V1] Clicking dish: Combo Pour 1 ($22.95)
[V1]   Step 1: Sauces pour Ailes (4 options)
[V1]   Step 2: Boissons (4 options)

📋 First Dish Details:

{
  "restaurant": "Papa Burger TEST",
  "dish": {
    "name": "Combo Pour 1",
    "basePrice": 22.95
  },
  "groups": [
    {
      "name": "Sauces pour Ailes",
      "selectType": "single",
      "minSelections": 1,
      "maxSelections": 1,
      "isRequired": true,
      "options": [
        { "name": "Douce", "priceDelta": 0 },
        { "name": "Moyenne", "priceDelta": 0 },
        { "name": "Fort", "priceDelta": 0 },
        { "name": "Miel et Ail", "priceDelta": 0 }
      ]
    },
    {
      "name": "Boissons",
      "selectType": "single",
      "minSelections": 1,
      "maxSelections": 1,
      "isRequired": true,
      "options": [
        { "name": "Ginger Ale", "priceDelta": 0 },
        { "name": "Pepsi", "priceDelta": 0 },
        { "name": "Diet Pepsi", "priceDelta": 0 },
        { "name": "7 Up", "priceDelta": 0 }
      ]
    }
  ]
}

✅ Test complete!
```

## ✅ If Test Works

Great! You're ready to proceed. Next steps:

1. **Add your 26 restaurants** to [restaurants-config.ts](./restaurants-config.ts)
2. **Run a small batch test** (2-3 restaurants):
   ```bash
   npm run scrape -- restaurant-1 restaurant-2
   ```
3. **Validate the output:**
   ```bash
   npm run validate-scraped-data
   ```
4. **Review JSON files** in `scraped-data/`
5. **Spot-check** against live sites
6. **Run full scrape** when confident:
   ```bash
   npm run scrape-all
   ```

## ❌ If Test Fails

### Error: "Cannot find module"

```bash
# Reinstall dependencies
npm install
```

### Error: "Browser not found"

```bash
# Install Playwright browsers
npx playwright install chromium
```

### Scraper hangs or doesn't extract data

1. Open the browser window (should be visible with `headless: false`)
2. Watch what it's doing
3. Check if the website structure changed
4. Review screenshots in `screenshots/test-v1/` or `test-v2/`

**Common fixes:**
- Update selectors in `v1-scraper.ts` or `v2-scraper.ts`
- Increase timeout in scraper config
- Check if website requires login/authentication

### No modifiers extracted

Check if the dish actually has customization:
1. Visit the website manually
2. Click "Add to Cart" or equivalent
3. See if options appear

If no options, that's expected! Not all dishes have modifiers.

## 🎯 Understanding the Output

### JSON Structure

```json
{
  "restaurant": "Restaurant Name",
  "dish": {
    "name": "Dish Name",
    "basePrice": 10.00,
    "description": "Optional description"
  },
  "groups": [
    {
      "name": "Group Name (e.g., Sauces)",
      "selectType": "single",  // or "multi"
      "minSelections": 1,       // 0 = optional
      "maxSelections": 1,       // null = unlimited
      "isRequired": true,
      "displayOrder": 0,
      "stepOrder": 1,          // Only for V1 multi-step
      "options": [
        {
          "name": "Option Name",
          "priceDelta": 0.00,  // Added cost
          "isDefault": false   // Pre-selected?
        }
      ]
    }
  ]
}
```

### Key Fields

| Field | Meaning |
|-------|---------|
| `selectType: "single"` | Radio buttons (pick one) |
| `selectType: "multi"` | Checkboxes (pick many) |
| `minSelections: 1` | Must select at least 1 |
| `maxSelections: null` | No limit (for multi) |
| `isRequired: true` | Customer must choose |
| `priceDelta: 2.50` | Adds $2.50 to base price |
| `stepOrder: 1` | V1 only - which step in wizard |

## 📸 Screenshots

The scraper automatically saves screenshots to help you debug:

```
screenshots/
├── test-v1/
│   ├── 0-dish-0-modal-opened.png
│   ├── 1-dish-0-step-1.png
│   └── 2-dish-0-final-step.png
└── test-v2/
    └── 0-dish-0-customization.png
```

**Use these to:**
- Verify scraper clicked the right elements
- See what the modal/form looks like
- Debug selector issues
- Document menu structure

## 🔧 Configuration Options

Edit scraper configs in test file or main runner:

```typescript
{
  restaurantName: 'My Restaurant',
  baseUrl: 'https://restaurant.com/menu',
  version: 'v1',           // or 'v2'
  headless: false,         // true = hide browser, false = show
  timeout: 30000,          // ms to wait for selectors
  screenshotsDir: './screenshots/test',
  outputDir: './scraped-data/test'
}
```

## 📚 Next Steps

After successful test:

1. ✅ [Configure your 26 restaurants](./restaurants-config.ts)
2. ✅ [Run full scrape](../../MODIFIER_SCRAPING_QUICKSTART.md#step-6-run-full-scrape-15-2-hours)
3. ✅ [Validate data](../../MODIFIER_SCRAPING_QUICKSTART.md#step-7-validate-all-data-5-minutes)
4. ✅ [Import to Supabase](../../MODIFIER_SCRAPING_QUICKSTART.md#step-10-import-to-supabase-via-mcp-5-minutes-per-restaurant)

## 🆘 Need More Help?

- **Detailed guide:** [README.md](./README.md)
- **Quick reference:** [MODIFIER_SCRAPING_QUICKSTART.md](../../MODIFIER_SCRAPING_QUICKSTART.md)
- **Complete overview:** [MODIFIER_SYSTEM_SUMMARY.md](../../MODIFIER_SYSTEM_SUMMARY.md)
- **Database schema:** [v3_modifier_schema.sql](../../Database/Menu%20&%20Catalog%20Entity/v3_modifier_schema.sql)

---

**Ready?** Run `npm run test-scraper` now! 🚀
