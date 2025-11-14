# V2 Scraper - Hybrid Workflow Guide

**Last Updated**: November 14, 2025  
**Approach**: Hybrid (Python Scraping + psql Database Operations)  
**Status**: Ready for Execution

---

## 🎯 Project Guidelines

### **Guideline #1: Database Operations via psql/Supabase CLI ONLY**
All queries and data manipulations to the `menu-rebuild-vo` project or `menuca_v3` schema **MUST** be done using:
- ✅ `psql` (PostgreSQL client)
- ✅ `supabase` CLI

**NOT allowed:**
- ❌ Python scripts with direct database connections
- ❌ Any other database clients

### **Guideline #2: 20 Restaurants = Source of Truth**
Only scrape these 20 restaurants (regardless of what's in database):

| Restaurant Name                          | Address                              | menuca_v3 ID |
|------------------------------------------|--------------------------------------|--------------|
| Al-s Drive In                            | 5474 Osgoode Main Street            | 981          |
| Capital Bites                            | 34 Grenfell Crescent                | 973          |
| Capri Pizza                              | 4000 Bridle Path Drive              | 977          |
| Chicco Pizza & Shawarma Buckingham       | 1009 Chemin de Masson               | 962          |
| Chicco Pizza Maloney                     | 842 Boulevard Maloney Est           | 964          |
| Chicco Pizza Shawarma Anger              | 1096 Chemin de Montréal Ouest       | 963          |
| Chicco Pizza St-Louis                    | 1783 Rue Saint-Louis                | 967          |
| Chicco Pizza de l'Hopital                | 405 Boulevard de l'Hôpital          | 966          |
| Chicco Shawarma Cantley                  | 435 Montée de la Source             | 961          |
| Chicco Shawarma Maloney                  | 922 Boulevard Maloney Est           | 965          |
| Cosenza                                  | 6505 Jeanne d'Arc Boulevard North   | 957          |
| Cuisine Bombay Indienne                  | 120 Rue Richelieu                   | 960          |
| Kirkwood Pizza                           | 1078 Merivale Road                  | 950          |
| La Nawab                                 | 1 Rue Cholette                      | 825          |
| Little Gyros Greek Grill                 | 1606 Battler Road                   | 971          |
| Pachino Pizza                            | 3515 Albion Road South              | 974          |
| Pizza Marie                              | 4 Rue d'Orléans                     | 976          |
| River Pizza                              | 4042 Innes Road                     | 952          |
| Sushi Presse                             | 6497, rue Beaubien Est              | 1019         |
| Wandee Thai                              | 40 Beech Street                     | 954          |

### **Guideline #3: Ignore legacy_v1_id and legacy_v2_id Columns**
Do **NOT** filter by or consider `legacy_v1_id` or `legacy_v2_id` in any queries or scraping logic.

### **Guideline #4: V2 IDs from Dashboard Markup**
V2 restaurant IDs are discovered by scraping the V2 dashboard restaurant list.

**Example**: For "La Nawab", the edit link contains V2 ID 1642:
```html
<a href="https://aggregator-admin.menu.ca/index.php/restaurants/edit/1642/info" class="btn btn-default btn-xs">
    <i class="glyphicon glyphicon-edit"></i> Edit
</a>
```

### **Guideline #5: DELETE Before INSERT Strategy**
Some restaurants may already have menu data. Assume it's **outdated** and **replace it completely**.

**Strategy**: DELETE all existing courses, dishes, and prices for the restaurant BEFORE inserting new data.

---

## 🏗️ Architecture Overview

### Hybrid Approach
```
┌─────────────────────────────────────────────────────────────┐
│                    PYTHON SCRAPER                            │
│  (NO database connections - JSON output only)                │
│                                                              │
│  1. v2_discover_ids.py  → Discover V2 IDs from dashboard    │
│  2. v2_scraper_phase1.py → Scrape courses & dishes          │
│  3. v2_scraper_phase2.py → Scrape modifiers                 │
│                                                              │
│  Output: JSON files in phase1_output/ and phase2_output/    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   SQL IMPORT SCRIPTS                         │
│        (psql-based - respects Guideline #1)                 │
│                                                              │
│  1. import_phase1_wrapper.sh → Load courses, dishes, prices │
│  2. import_phase2_wrapper.sh → Load modifiers               │
│                                                              │
│  Strategy: DELETE existing data, then INSERT new data       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   VERIFICATION QUERIES                       │
│            (psql-based SQL queries)                          │
│                                                              │
│  Verify data integrity, completeness, and quality            │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 File Structure

```
scraper/
├── v2_config.py                    # Configuration (URLs, credentials)
├── v2_scraper.py                   # Scraper class (NO DB connections)
├── v2_discover_ids.py              # Discover V2 IDs from dashboard
├── v2_scraper_phase1.py            # Phase 1: Scrape courses & dishes
├── v2_scraper_phase2.py            # Phase 2: Scrape modifiers [TODO]
│
└── V2 Scrapper/
    ├── v2_restaurants.json         # 20 restaurants list (source of truth)
    ├── v2_phase1_progress.json     # Phase 1 progress tracking
    ├── v2_phase2_progress.json     # Phase 2 progress tracking
    │
    ├── phase1_output/              # JSON output from Phase 1
    │   └── restaurant_{id}_menu.json
    │
    ├── phase2_output/              # JSON output from Phase 2
    │   └── restaurant_{id}_modifiers.json
    │
    └── sql/                        # SQL import scripts (psql-based)
        ├── import_phase1_wrapper.sh
        ├── import_phase2_wrapper.sh [TODO]
        └── verification_queries.sql [TODO]
```

---

## 🚀 Complete Workflow (Step-by-Step)

### **Prerequisites**

1. **V2 Admin Credentials** in `.env` file:
```bash
V2_USERNAME=your_v2_username
V2_PASSWORD=your_v2_password
```

2. **Python Dependencies**:
```bash
pip install playwright beautifulsoup4 lxml python-dotenv
playwright install chromium
```

3. **System Dependencies**:
```bash
# macOS
brew install jq postgresql

# Verify psql connection
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "SELECT 1;"
```

---

### **PHASE 0: Setup and V2 ID Discovery**

#### Step 0.1: Verify Restaurant List

The 20 restaurants are pre-loaded in `v2_restaurants.json`. Verify:
```bash
cat V2\ Scrapper/v2_restaurants.json | jq '. | length'
# Should output: 20
```

#### Step 0.2: Discover V2 IDs from Dashboard

Run the V2 ID discovery script:
```bash
cd scraper
python3 v2_discover_ids.py
```

**What it does:**
- Logs into V2 dashboard
- Scrapes restaurant list page
- Extracts V2 IDs from edit links
- Updates `v2_restaurants.json` with discovered IDs

**Expected output:**
```
============================================================================
V2 ID DISCOVERY SCRIPT
Discovering V2 restaurant IDs from dashboard
============================================================================

✓ Login successful
Navigating to: https://aggregator-admin.menu.ca/index.php/restaurants/show/active
Found 20 restaurant rows
  Al-s Drive In: V2 ID = 1678
  Capital Bites: V2 ID = 1670
  ...
✓ Discovered 20 V2 IDs
✓ Updated 20/20 restaurants

============================================================================
V2 ID DISCOVERY COMPLETE
Updated 20 restaurants with V2 IDs
============================================================================
```

#### Step 0.3: Verify V2 IDs

Check that all restaurants have V2 IDs:
```bash
cat V2\ Scrapper/v2_restaurants.json | jq '.[] | select(.v2_id == null)'
```

If any restaurant shows up, manually update its V2 ID in the JSON file.

---

### **PHASE 1: Scrape Courses, Dishes, and Prices**

#### Step 1.1: Run Phase 1 Scraper

```bash
cd scraper
python3 v2_scraper_phase1.py
```

**What it does:**
- Reads `v2_restaurants.json`
- For each restaurant:
  - Logs into V2 dashboard
  - Navigates to menu page
  - Detects English/French menu
  - Extracts courses, dishes, and prices
  - Saves to `phase1_output/restaurant_{id}_menu.json`
  - Updates progress in `v2_phase1_progress.json`
- Delay of 2 seconds between restaurants

**Expected output:**
```
============================================================================
V2 RESTAURANT SCRAPER - PHASE 1 (Courses & Dishes)
HYBRID APPROACH: Outputs to JSON, NO database operations
============================================================================

✓ Loaded 20 V2 restaurants
✓ Already completed: 0
✓ Remaining to process: 20

[1/20] Processing: Al-s Drive In
  DB ID: 981 | V2 ID: 1678
✓ Extracted 8 courses with 45 dishes
✓ Saved to: V2 Scrapper/phase1_output/restaurant_981_menu.json

[2/20] Processing: Capital Bites
...

============================================================================
PHASE 1 SUMMARY
============================================================================
Duration:         0:12:34
Successful:       20/20
Failed:           0
Skipped:          0
Total courses:    156
Total dishes:     1,203
Output directory: V2 Scrapper/phase1_output/
============================================================================
```

#### Step 1.2: Review JSON Output

Inspect a sample JSON file:
```bash
cat V2\ Scrapper/phase1_output/restaurant_981_menu.json | jq '.' | head -50
```

Expected structure:
```json
{
  "db_restaurant_id": 981,
  "v2_restaurant_id": 1678,
  "courses": [
    {
      "name": "Burgers",
      "description": "",
      "display_order": 0,
      "v2_course_id": "1234",
      "dishes": [
        {
          "name": "Classic Burger",
          "description": "Beef patty with lettuce, tomato, onion",
          "display_order": 0,
          "v2_dish_id": "5678",
          "prices": [
            {
              "size_variant": "standard",
              "price": 9.99,
              "display_order": 0
            }
          ]
        }
      ]
    }
  ]
}
```

#### Step 1.3: Import to Database via psql

Make the import script executable:
```bash
chmod +x V2\ Scrapper/sql/import_phase1_wrapper.sh
```

Run the import:
```bash
cd V2\ Scrapper/sql
./import_phase1_wrapper.sh
```

**What it does:**
- For each JSON file in `phase1_output/`:
  - **DELETE** existing courses, dishes, prices for that restaurant
  - **INSERT** new courses
  - **INSERT** new dishes (with `source_id` = V2 dish ID)
  - **INSERT** new dish prices
- All operations via `psql` (respects Guideline #1)

**Expected output:**
```
============================================================================
V2 Phase 1 Import - Courses, Dishes, and Prices
Strategy: DELETE existing data, then INSERT new data
============================================================================

Found 20 restaurant menu files

[1/20] Processing: restaurant_981_menu.json (Restaurant ID: 981)
  → Deleting existing menu data for restaurant 981...
  → Importing courses, dishes, and prices...
  ✓ Success

[2/20] Processing: restaurant_973_menu.json (Restaurant ID: 973)
  → Deleting existing menu data for restaurant 973...
  → Importing courses, dishes, and prices...
  ✓ Success

...

============================================================================
Import Summary
============================================================================
Total restaurants processed: 20
Successful: 20
Estimated courses imported: 156

============================================================================
```

#### Step 1.4: Verify Import

Query the database to verify:
```bash
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT c.id) AS courses,
    COUNT(DISTINCT d.id) AS dishes,
    COUNT(DISTINCT dp.id) AS prices
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
LEFT JOIN menuca_v3.dish_prices dp ON dp.restaurant_id = r.id
WHERE r.id IN (981, 973, 977, 962, 964, 963, 967, 966, 961, 965, 957, 960, 950, 825, 971, 974, 976, 952, 1019, 954)
GROUP BY r.id, r.name
ORDER BY r.id;
"
```

---

### **PHASE 2: Scrape Modifiers** [TODO]

#### Step 2.1: Run Phase 2 Scraper

```bash
cd scraper
python3 v2_scraper_phase2.py
```

**What it does:**
- Queries dishes from Phase 1 (via JSON files or database query via psql)
- For each dish with V2 dish ID:
  - Opens dish edit modal
  - Extracts modifier groups and items
  - Saves to `phase2_output/restaurant_{id}_modifiers.json`

#### Step 2.2: Import to Database via psql

```bash
cd V2\ Scrapper/sql
./import_phase2_wrapper.sh
```

**What it does:**
- For each JSON file in `phase2_output/`:
  - **DELETE** existing modifier groups and items for dishes
  - **INSERT** new modifier groups
  - **INSERT** new dish modifiers
  - **INSERT** new dish modifier prices

---

### **PHASE 3: Verification** [TODO]

Run verification queries:
```bash
psql "CONNECTION_STRING" -f V2\ Scrapper/sql/verification_queries.sql
```

**Checks:**
- All 20 restaurants have courses
- All 20 restaurants have dishes
- All dishes have at least one price
- Dishes with modifiers have modifier groups
- No orphaned records
- No duplicate data

---

## 📊 Progress Tracking

### Progress Files

**Phase 1 Progress**: `V2 Scrapper/v2_phase1_progress.json`
```json
{
  "completed": [981, 973, 977],
  "failed": [962],
  "skipped": []
}
```

**Phase 2 Progress**: `V2 Scrapper/v2_phase2_progress.json`

### Resume Capability

If scraping is interrupted:
1. Progress files track completed/failed/skipped restaurants
2. Re-run the scraper - it will **skip** already completed restaurants
3. Fix any failures and re-run to retry failed restaurants

To **reset** and re-scrape all:
```bash
rm V2\ Scrapper/v2_phase1_progress.json
rm V2\ Scrapper/v2_phase2_progress.json
```

---

## 🔍 Troubleshooting

### V2 Login Fails

**Problem**: Scraper can't log in to V2 dashboard

**Solution**:
1. Verify credentials in `.env` file
2. Try manual login at https://aggregator-admin.menu.ca/index.php/auth/login
3. Check if account is locked or password expired

### Restaurant Not Found in Dashboard

**Problem**: Restaurant in list not appearing in V2 dashboard

**Solution**:
1. Verify restaurant is "Active" in V2 system
2. Check spelling of restaurant name (might not match exactly)
3. Manually find V2 ID and update `v2_restaurants.json`

### JSON Import Fails

**Problem**: SQL import script fails with error

**Solution**:
1. Check log file: `V2 Scrapper/sql/import_phase1.log`
2. Verify JSON structure is correct
3. Check for database connection issues
4. Ensure restaurant ID exists in `menuca_v3.restaurants`

### No Menu Data Found

**Problem**: Restaurant scraped but JSON shows 0 courses

**Solution**:
1. Check if restaurant has menu data in V2 dashboard
2. Verify English/French menu detection logic
3. Check HTML structure hasn't changed

---

## 📝 Notes

### Why Hybrid Approach?

1. **Respects Guideline #1**: All database operations via psql
2. **Separation of Concerns**: Scraping and database operations are separate
3. **Debugging**: JSON output can be inspected before importing
4. **Resume Capability**: Can re-import without re-scraping
5. **Flexibility**: Can modify import logic without re-scraping

### V2 Dashboard Structure

- **Restaurant List**: `/index.php/restaurants/show/active`
- **Restaurant Menu**: `/index.php/restaurants/edit/{V2_ID}/menu/restaurant` (English)
- **Restaurant Menu (French)**: `/index.php/restaurants/edit/{V2_ID}/menu/2/restaurant`
- **Dish Edit Modal**: `/index.php/ajax/restaurant_menu/edit_dish/{V2_DISH_ID}/{V2_RESTAURANT_ID}/2`

### Important SQL Notes

- `source_id` column in `menuca_v3.dishes` stores V2 dish ID
- Required for Phase 2 to map modifiers to correct dishes
- DELETE strategy ensures clean data (no duplicates or stale data)

---

## ✅ Success Criteria

Phase 1 is complete when:
- ✅ All 20 restaurants scraped successfully
- ✅ JSON files generated for all 20 restaurants
- ✅ All courses, dishes, and prices imported via psql
- ✅ Verification queries pass
- ✅ No failed or skipped restaurants

Phase 2 is complete when:
- ✅ All dishes with modifiers scraped successfully
- ✅ JSON files generated for all applicable restaurants
- ✅ All modifier groups and items imported via psql
- ✅ Verification queries pass

---

**Last Updated**: November 14, 2025  
**Version**: 1.0 (Hybrid Approach)  
**Author**: Claude (AI Agent)

