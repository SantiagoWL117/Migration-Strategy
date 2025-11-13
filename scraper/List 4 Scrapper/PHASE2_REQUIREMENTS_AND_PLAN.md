# List 4 Phase 2 - Requirements & Execution Plan

## What Phase 2 Does

Phase 2 scrapes **detailed pricing and customization data** for each dish:

### Data to Scrape:
1. **Dish Prices** (with size variants)
   - Price values
   - Size variants (Small, Medium, Large, X-Large, etc.)
   - Display order

2. **Modifier Groups**
   - Group name (e.g., "Crust Type", "Toppings", "Sauce")
   - Required vs optional
   - Min/max selections
   - Display order

3. **Modifier Items**
   - Item name (e.g., "Thin Crust", "Extra Cheese", "BBQ Sauce")
   - Type (bread, custom_ingredients, dressing, sauces, side_dishes, drinks, extras, cooking_method)
   - Is default selection
   - Display order

4. **Modifier Prices**
   - Price per size variant
   - Some modifiers cost different amounts for different pizza sizes

---

## Current Situation

### Phase 1 Results:
- ✅ **65 restaurants** scraped (courses and dishes)
- ✅ **1,112 courses** inserted
- ✅ **8,746 dishes** inserted

### Breakdown by Language:
1. **English Restaurants**: 53 restaurants, 7,262 dishes
2. **French Restaurants**: 12 restaurants, 1,484 dishes

---

## Why Two Separate Scrapers?

### Language-Specific URLs:
- **English**: `https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant={crm_id}&load=editDish&showLang=en&menuEntry={menu_entry_id}`
- **French**: `https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant={crm_id}&load=editDish&showLang=fr&menuEntry={menu_entry_id}`

### Different HTML Structure:
- French menus may have different labels, selectors, and patterns
- The `MenuScraper.scrape_dish_details()` method already supports a `language` parameter

---

## Requirements for Phase 2

### 1. Input Files Needed ✅

**English Restaurants:**
- `list4_scrape_results.json` - Contains 53 English restaurants from Phase 1
- This file already exists and has `language: 'en'` marked

**French Restaurants:**
- `list4_french_results.json` - Contains 12 French restaurants from Phase 1
- This file already exists and has `language: 'fr'` marked

### 2. Database Requirements ✅

**Dishes with `source_id` (menu_entry_id):**
- Query all dishes from the 65 restaurants where `source_id IS NOT NULL`
- The `source_id` is the CRM menu entry ID needed to fetch dish details
- **Total dishes to process**: ~8,746

### 3. Scraper Methods ✅

**Already Available:**
```python
MenuScraper.scrape_dish_details(
    restaurant_id: int,
    menu_entry_id: int,
    language: str = 'en'  # 'en' or 'fr'
)
```

Returns:
```python
{
    'prices': [
        {'size_variant': 'Small', 'price': 16.80, 'display_order': 0},
        {'size_variant': 'Large', 'price': 26.90, 'display_order': 1}
    ],
    'modifiers': [
        {
            'name': 'Crust Type',
            'type_code': 'br',
            'is_required': True,
            'min_selections': 1,
            'max_selections': 1,
            'display_order': 0,
            'items': [
                {'name': 'Regular', 'prices': [0.0], 'display_order': 0},
                {'name': 'Thick', 'prices': [0.0, 0.0], 'display_order': 1}
            ]
        }
    ]
}
```

### 4. Database Insert Methods ✅

**Already Available in `DatabaseManager`:**
- `insert_dish_price(dish_id, size_variant, price, display_order)`
- `insert_modifier_group(dish_id, name, is_required, min_selections, max_selections, display_order)`
- `insert_dish_modifier(restaurant_id, dish_id, modifier_group_id, name, modifier_type, is_default, display_order)`
- `insert_dish_modifier_price(dish_modifier_id, dish_id, restaurant_id, size_variant, price, display_order)`

---

## Execution Plan: Two Parallel Scrapers

### Scraper 1: English Restaurants (53 restaurants, ~7,262 dishes)

**Script**: `batch_scrape_list4_prices_english.py`

**Configuration:**
- Input: `list4_scrape_results.json` (filter `language == 'en'`)
- Language parameter: `'en'`
- Progress file: `list4_prices_english_progress.json`
- Results file: `list4_prices_english_results.json`
- Log file: `batch_scrape_list4_prices_english.log`

**Query dishes from these DB IDs:**
```python
# Extract from list4_scrape_results.json where language='en'
english_restaurant_db_ids = [45, 196, 792, 28, 1009, ...] # 53 restaurants
```

### Scraper 2: French Restaurants (12 restaurants, ~1,484 dishes)

**Script**: `batch_scrape_list4_prices_french.py`

**Configuration:**
- Input: `list4_french_results.json` (all have `language == 'fr'`)
- Language parameter: `'fr'`
- Progress file: `list4_prices_french_progress.json`
- Results file: `list4_prices_french_results.json`
- Log file: `batch_scrape_list4_prices_french.log`

**Query dishes from these DB IDs:**
```python
# Extract from list4_french_results.json
french_restaurant_db_ids = [211, 798, 1011, 810, 70, 602, 1012, 1013, 1014, 139, 1016, 1017]
```

---

## Safety Features for Parallel Execution

### 1. **Separate Progress Files** ✅
- Each scraper tracks its own completed/failed/skipped dishes
- No collision between the two scrapers

### 2. **Non-Overlapping Dish Sets** ✅
- English scraper: dishes from 53 restaurants
- French scraper: dishes from 12 restaurants
- **Zero overlap** - completely safe to run in parallel

### 3. **Database Connection Safety** ✅
- Each scraper has its own database connection
- PostgreSQL handles concurrent writes safely
- Each scraper checks connection health and reconnects as needed

### 4. **Browser Session Isolation** ✅
- Each scraper launches its own Playwright browser instance
- Separate login sessions
- No interference between scrapers

---

## Estimated Timing

### Based on Previous Scraping Performance:

**English Scraper (7,262 dishes):**
- ~1 second per dish average
- Estimated: **2-3 hours**

**French Scraper (1,484 dishes):**
- ~1 second per dish average
- Estimated: **25-40 minutes**

**Total Parallel Time**: ~2-3 hours (both complete together)

---

## What I Need From You

### ✅ Already Have:
1. Phase 1 results files (`list4_scrape_results.json`, `list4_french_results.json`)
2. All dishes in database with `source_id` (menu_entry_id)
3. Working scraper methods for both English and French
4. Database insert methods for prices and modifiers

### 🔧 Need to Create:
1. `batch_scrape_list4_prices_english.py` - English dishes scraper
2. `batch_scrape_list4_prices_french.py` - French dishes scraper
3. Filter logic to separate English and French restaurant DB IDs

### 📋 Execution Steps:
1. Create both scripts
2. Open **two terminal windows**
3. Start English scraper in terminal 1: `python batch_scrape_list4_prices_english.py`
4. Start French scraper in terminal 2: `python batch_scrape_list4_prices_french.py`
5. Monitor progress files and logs
6. Verify completion when both finish

---

## Ready to Proceed?

All requirements are met! I can now:
1. ✅ Create the two separate Phase 2 scrapers
2. ✅ Configure them for parallel execution
3. ✅ Start both scrapers

**Would you like me to create and start both scrapers now?**

