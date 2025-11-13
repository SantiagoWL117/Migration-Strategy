# List 4 Scraper - V1 Restaurants NOT Scraped

## Overview

This scraper is designed to scrape menu data for the 50 restaurants identified in **List 4** of `ACTIVE_V1_RESTAURANTS_SCRAPPED.md`. These are active V1 client restaurants that were not included in the initial Phase 1 English scraper run.

The scraper follows the exact same two-phase approach as the English and French scrapers:

- **Phase 1**: Scrapes courses and dishes
- **Phase 2**: Scrapes prices and modifiers for each dish

## Key Features

### Language Detection

The List 4 scraper includes automatic language detection:

1. **Phase 1** checks both English and French menu pages for each restaurant
2. Identifies which language has menu data (some restaurants only have French menus)
3. Stores the detected language in Phase 1 results
4. **Phase 2** uses the correct language from Phase 1 for each restaurant

This ensures all menu data is captured regardless of the restaurant's primary language.

### Resume Capability

Both Phase 1 and Phase 2 can be interrupted and resumed:

- Progress is saved after each restaurant (Phase 1) or dish (Phase 2)
- Progress files: `list4_scrape_progress.json` and `list4_prices_progress.json`
- Re-running the script will skip already-processed items

### Error Handling

- Gracefully handles restaurants with no menu data (skips them)
- Logs all errors for manual review
- Continues processing remaining items even if some fail

## Files and Structure

### Input Files

| File | Description |
|------|-------------|
| `list4_restaurants.json` | List of 50 restaurants with DB IDs, CRM IDs, names, and addresses |

### Scripts

| Script | Phase | Description |
|--------|-------|-------------|
| `extract_list4_restaurants.py` | Setup | Extracts List 4 restaurants from markdown and queries database for IDs |
| `batch_scrape_list4.py` | Phase 1 | Scrapes courses and dishes for all restaurants |
| `batch_scrape_list4_prices.py` | Phase 2 | Scrapes prices and modifiers for all dishes |
| `monitor_list4_progress.py` | Monitor | Real-time progress monitor for both phases |

### Output Files

| File | Description |
|------|-------------|
| `list4_scrape_results.json` | Detailed Phase 1 results (courses, dishes, language used) |
| `list4_scrape_progress.json` | Phase 1 progress tracking (completed, failed, skipped) |
| `batch_scrape_list4.log` | Phase 1 detailed log |
| `list4_prices_results.json` | Detailed Phase 2 results (prices, modifiers) |
| `list4_prices_progress.json` | Phase 2 progress tracking |
| `batch_scrape_list4_prices.log` | Phase 2 detailed log |

## Usage

### Step 1: Extract Restaurant List

First, extract the List 4 restaurants and query the database for their IDs:

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"
python extract_list4_restaurants.py
```

This will create `list4_restaurants.json` with 50 restaurants that have valid DB IDs and CRM IDs.

**Note**: 16 restaurants from the original List 4 (66 total) could not be processed because they don't have CRM IDs or don't exist in the database yet.

### Step 2: Run Phase 1 (Courses & Dishes)

Run the Phase 1 scraper to extract courses and dishes:

```powershell
# Run in background (Windows PowerShell)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper' ; python batch_scrape_list4.py"
```

Or run in foreground (blocks terminal):

```powershell
python batch_scrape_list4.py
```

**Expected Duration**: ~2-3 minutes (50 restaurants × 2-3 seconds each)

### Step 3: Monitor Phase 1 Progress

In a separate terminal, monitor the progress:

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"
python monitor_list4_progress.py
```

The monitor will show:
- Progress bar
- Restaurants completed/failed/skipped
- Total courses and dishes inserted
- Recent log activity
- Last processed restaurant

Press `Ctrl+C` to stop monitoring (scraper continues running).

### Step 4: Verify Phase 1 Results

After Phase 1 completes, review the results:

```powershell
# View summary
python -c "import json; r = json.load(open('list4_scrape_results.json')); print(f'Successful: {sum(1 for x in r if x[\"status\"]==\"success\")}'); print(f'Total Courses: {sum(x.get(\"courses\", 0) for x in r if x[\"status\"]==\"success\")}'); print(f'Total Dishes: {sum(x.get(\"dishes\", 0) for x in r if x[\"status\"]==\"success\")}')"
```

### Step 5: Run Phase 2 (Prices & Modifiers)

After Phase 1 completes successfully, run Phase 2:

```powershell
# Run in background (Windows PowerShell)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper' ; python batch_scrape_list4_prices.py"
```

Or run in foreground:

```powershell
python batch_scrape_list4_prices.py
```

**Expected Duration**: Varies based on total dishes (typically 1-3 hours for ~2,000-5,000 dishes)

### Step 6: Monitor Phase 2 Progress

Monitor Phase 2 progress:

```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"
python monitor_list4_progress.py
```

The monitor will show both Phase 1 (completed) and Phase 2 (in progress):
- Progress bar for dishes
- Dishes completed/failed/skipped
- Total prices, modifier groups, items, and prices inserted
- Dishes with/without modifiers
- Recent log activity
- Last processed dish

## Integration with Existing Scrapers

The List 4 scraper is **independent** and runs in parallel with the English scraper:

- Uses the same tools (`scraper.py`, `database.py`, `config.py`)
- Uses the same database schema (`menuca_v3`)
- Uses the same credentials (`.env` file)
- Follows the same two-phase approach

You can run:
1. **English Scraper** (batch_scrape_prices_modifiers.py) - for restaurants scraped in original Phase 1
2. **List 4 Scraper** (batch_scrape_list4.py and batch_scrape_list4_prices.py) - for List 4 restaurants
3. **French Scraper** (already complete)

All three scrapers can run **simultaneously** without interfering with each other, as they process different sets of restaurants.

## Database Schema

The scrapers insert data into the `menuca_v3` schema:

### Phase 1 inserts:
- `menuca_v3.courses` - Course names and display order
- `menuca_v3.dishes` - Dish names, descriptions, and `source_id` (menu_entry_id)

### Phase 2 inserts:
- `menuca_v3.dish_prices` - Prices for each size variant
- `menuca_v3.modifier_groups` - Modifier groups (e.g., "Toppings", "Sauces")
- `menuca_v3.modifier_group_items` - Individual modifier items
- `menuca_v3.modifier_group_item_prices` - Prices for each modifier item

## Troubleshooting

### Error: "No menu data found"

**Cause**: Restaurant doesn't have any courses or dishes in the CRM

**Solution**: These restaurants are automatically skipped and logged. Review the log to confirm.

### Error: "No CRM ID"

**Cause**: Restaurant exists in database but doesn't have a `legacy_v1_id` (CRM ID)

**Solution**: These restaurants are excluded during the extraction step. They need to be manually added to the CRM first.

### Error: "Restaurant not found in database"

**Cause**: Restaurant name/address from List 4 doesn't match any record in `menuca_v3.restaurants`

**Solution**: These restaurants are excluded during extraction. They may need to be added to the database first.

### Scraper hangs or crashes

**Cause**: Network issues, CRM timeout, or browser crash

**Solution**: 
1. Stop the scraper (`Ctrl+C`)
2. Re-run the script - it will resume from where it left off
3. Check the log file for specific error messages

## Progress Tracking

### Check Phase 1 Progress

```powershell
# View completed restaurants
python -c "import json; p = json.load(open('list4_scrape_progress.json')); print(f'Completed: {len(p[\"completed\"])}'); print(f'Failed: {len(p[\"failed\"])}'); print(f'Skipped: {len(p[\"skipped\"])}')"
```

### Check Phase 2 Progress

```powershell
# View completed dishes
python -c "import json; p = json.load(open('list4_prices_progress.json')); print(f'Completed: {len(p[\"completed\"])}'); print(f'Failed: {len(p[\"failed\"])}'); print(f'Skipped: {len(p[\"skipped\"])}')"
```

### View Last Error

```powershell
# View last 20 lines of Phase 1 log
Get-Content batch_scrape_list4.log -Tail 20

# View last 20 lines of Phase 2 log
Get-Content batch_scrape_list4_prices.log -Tail 20
```

## Expected Results

Based on the 50 restaurants in List 4:

### Phase 1 Estimates:
- **Successful restaurants**: ~45-48 (some may have no menu data)
- **Total courses**: ~400-600
- **Total dishes**: ~2,000-5,000

### Phase 2 Estimates:
- **Total dish prices**: ~3,000-8,000 (dishes may have multiple sizes)
- **Total modifier groups**: ~500-1,500
- **Total modifier items**: ~5,000-15,000
- **Total modifier prices**: ~10,000-30,000

These are estimates based on similar restaurant data from the English and French scrapers.

## Next Steps After Completion

After both Phase 1 and Phase 2 complete:

1. **Verify data in database**:
   - Query `menuca_v3.restaurants` to confirm dishes were added
   - Check that prices and modifiers are present

2. **Update tracking documents**:
   - Move successfully scraped restaurants from List 4 to List 2 in `ACTIVE_V1_RESTAURANTS_SCRAPPED.md`
   - Update counts in billing report

3. **Handle failed/skipped restaurants**:
   - Review log files for error details
   - Manually investigate restaurants with no menu data
   - Add notes to tracking documents

## Important Notes

- **Do not delete progress files** (`*_progress.json`) while scrapers are running
- **Scrapers are idempotent** - re-running them will update existing records, not create duplicates
- **Language detection is automatic** - no manual configuration needed
- **The monitor script is read-only** - stopping it won't affect the scraper
- **All scrapers use the same CRM session** - running multiple scrapers may cause rate limiting

## Contact

If you encounter issues or need assistance, refer to:
- Log files: `batch_scrape_list4.log` and `batch_scrape_list4_prices.log`
- Progress files: `list4_scrape_progress.json` and `list4_prices_progress.json`
- Results files: `list4_scrape_results.json` and `list4_prices_results.json`

