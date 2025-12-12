# Phase 2 Scraping Session Summary

**Date:** December 11, 2025  
**Session Duration:** ~3 hours  
**Status:** Phase 2 Critical Restaurants Complete ✅

---

## Overview

This session focused on completing the Phase 2 menu scraper for 6 critical restaurants and creating a scanner to identify "special combo sections" across all restaurants.

---

## Completed Tasks

### 1. Phase 2 Scraper Bug Fixes

**Problem:** The scraper was not populating `combo_modifier_groups`, `combo_modifiers`, or `combo_modifier_prices` tables.

**Root Causes Found & Fixed:**

#### Fix 1: Incorrect CSS Selector Prefix
- **File:** `Scrapers/Menu Scrapers/Phase2 Restaurants Scraper/phase2_scraper.py`
- **Function:** `_parse_section_modifier_groups()`
- **Issue:** `type_prefix` was being derived as `'ci_id'` instead of `'ci'`, causing CSS selectors to fail
- **Fix:** Changed `type_code_map` to strip `'_id'` suffix, resulting in correct selector `name=f'{type_prefix}_radio'`

#### Fix 2: Missing Checked Attribute Filter
- **File:** `Scrapers/Menu Scrapers/Phase2 Restaurants Scraper/phase2_scraper.py`
- **Function:** `_parse_section_modifier_groups()`
- **Issue:** All combo modifier groups were being inserted, not just the checked/active ones
- **Fix:** Added `if radio.has_attr('checked'):` condition to filter for only active groups

---

### 2. Phase 2 Critical Restaurants Scraped

All 6 critical restaurants have been fully scraped and stored in the `menuca_v3` schema:

| Restaurant | V3 ID | V1 ID | Combo Groups | Courses | Dishes | Prices | Modifiers | Status |
|------------|-------|-------|--------------|---------|--------|--------|-----------|--------|
| Joes Family Pizzeria | 636 | 863 | 80 | 37 | 374 | 651 | 3,394 | ✅ |
| Milano - 2 Pembroke | 265 | 411 | 34 | 20 | 150 | 339 | 1,481 | ✅ |
| Aroy Thai | 607 | 830 | 6 | 9 | 39 | 104 | 0 | ✅ |
| All Out Burger Bank St. | 924 | 1013 | 1 | 14 | 111 | 132 | 337 | ✅ |
| All Out Burger Gladstone | 948 | 1038 | 1 | 14 | 111 | 132 | 337 | ✅ |
| All Out Burger Montreal Rd | 949 | 1071 | 1 | 14 | 111 | 132 | 337 | ✅ |

**Log Files:**
- `Scrapers/Menu Scrapers/logs/phase2_scraper_20251211_152652.log` - Joes Family Pizzeria
- `Scrapers/Menu Scrapers/logs/Phase 2 Critical Restaurants completed.log` - Remaining 5 restaurants

---

### 3. Schema Documentation Created

**File:** `Menu.ca V3/BRIAN HANDOFF.md`

Created comprehensive documentation explaining:
- Normal dish vs combo dish schema differences
- Section type mapping (7 section types)
- Hide-on-days functionality
- Example queries for Joes Family Pizzeria dishes
- Data flow diagrams

---

### 4. Special Combo Sections Scanner Created

**Purpose:** Identify restaurants with "special combo sections" - combo groups where specific menu items are pre-checked as valid selections.

**Files Created:**
- `Scrapers/Menu Scrapers/Combo scraper/Special combo sections/special_combo_scanner.py`
- `Scrapers/Menu Scrapers/Combo scraper/Special combo sections/run_scanner.py`

**Scanner Results (123 restaurants scanned):**

| Restaurant | V3 ID | Special Groups | Checked Items | Complexity |
|------------|-------|----------------|---------------|------------|
| Milano | 680 | 21 | 349 | 🔴 HIGH |
| Aroy Thai | 607 | 4 | 116 | 🔴 HIGH |
| Amicci Pizza | 735 | 5 | 60 | 🟡 MEDIUM |
| Nachos Loco Hull | 790 | 3 | 36 | 🟡 MEDIUM |
| Nachos Loco Gatineau | 801 | 3 | 36 | 🟡 MEDIUM |
| Dumpling Bowl | 792 | 1 | 22 | 🟢 LOW |
| Mano City Pizza | 118 | 3 | 19 | 🟢 LOW |
| All Out Burger | 833 | 1 | 12 | 🟢 LOW |
| Little Gyros Greek Grill | 756 | 2 | 10 | 🟢 LOW |
| Orchid Sushi | 245 | 1 | 8 | 🟢 LOW |
| Milano | 350 | 2 | 7 | 🟢 LOW |
| Milano | 123 | 2 | 4 | 🟢 LOW |

**Log File:** `Scrapers/Menu Scrapers/logs/special_combo_scan_20251211_162730.log`

**Total:** 12 restaurants with 48 special combo groups containing 679 pre-checked items.

---

## Key Files & Locations

### Scrapers
```
Scrapers/Menu Scrapers/Phase2 Restaurants Scraper/
├── phase2_scraper.py      # Main scraper logic
├── phase2_config.py       # Configuration & restaurant list
├── phase2_database.py     # Database operations
└── run_scraper.py         # Entry point with CLI args

Scrapers/Menu Scrapers/Combo scraper/Special combo sections/
├── special_combo_scanner.py  # Scanner logic
└── run_scanner.py            # Entry point
```

### Configuration
```
Scrapers/Menu Scrapers/config.py  # Shared config (credentials, DB connection)
```

### Logs
```
Scrapers/Menu Scrapers/logs/
├── phase2_scraper_20251211_*.log
├── Phase 2 Critical Restaurants completed.log
├── special_combo_scan_20251211_162730.log
└── Combo Phase 1 successful.log  # Contains 123 restaurants to process
```

---

## Database Schema (menuca_v3)

### Tables Populated by Phase 2 Scraper:

**Combo-related:**
- `combo_groups` - Combo meal definitions
- `combo_group_sections` - Sections within combos (e.g., "Choose your pizza size")
- `combo_modifier_groups` - Groups of selectable options within sections
- `combo_modifiers` - Individual selectable items
- `combo_modifier_prices` - Prices per size variant

**Dish-related:**
- `courses` - Menu categories
- `dishes` - Individual menu items
- `dish_prices` - Prices per size variant
- `dish_combo_groups` - Links combo dishes to their combo groups
- `dish_availability` - Hide-on-days rules

**Modifier-related:**
- `modifier_groups` - Groups of modifiers for dishes
- `modifiers` - Individual modifier options
- `modifier_prices` - Prices per size variant

---

## Commands Reference

### Run Phase 2 Scraper on All 6 Restaurants
```powershell
cd "Scrapers\Menu Scrapers\Phase2 Restaurants Scraper"
$env:CRM_V1_USERNAME = "santiago@worklocal.ca"
$env:CRM_V1_PASSWORD = "542sfgsgeerg4%$"
python run_scraper.py --all
```

### Run Phase 2 Scraper Excluding Specific Restaurant
```powershell
python run_scraper.py --all --exclude 636  # Exclude Joes Family Pizzeria
```

### Run Phase 2 Scraper on Single Restaurant
```powershell
python run_scraper.py --restaurant 636  # Just Joes Family Pizzeria
```

### Run Special Combo Scanner
```powershell
cd "Scrapers\Menu Scrapers\Combo scraper\Special combo sections"
$env:CRM_V1_USERNAME = "santiago@worklocal.ca"
$env:CRM_V1_PASSWORD = "542sfgsgeerg4%$"
python run_scanner.py
```

---

## Next Steps for Continuation

### Option A: Expand Phase 2 to More Restaurants
The Phase 2 scraper is production-ready. To scrape additional restaurants:

1. Update `RESTAURANTS` list in `phase2_config.py` with new V3/V1 ID pairs
2. Run `python run_scraper.py --all`

### Option B: Handle Special Combo Sections
12 restaurants have "special combo sections" that need special handling:
- These combos have pre-checked items that customers can select from
- The current scraper captures these in `combo_modifier_groups` but the relationship to actual dishes may need verification

**High Priority (complex menus):**
- Milano (V3: 680) - 21 special groups, 349 items
- Aroy Thai (V3: 607) - 4 special groups, 116 items (already in Phase 2 list)

### Option C: Verify Data Integrity
Run verification queries to confirm data was stored correctly:

```sql
-- Count records per restaurant
SELECT r.name, 
       COUNT(DISTINCT cg.id) as combo_groups,
       COUNT(DISTINCT c.id) as courses,
       COUNT(DISTINCT d.id) as dishes
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.combo_groups cg ON cg.restaurant_id = r.id
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.course_id = c.id
WHERE r.id IN (636, 265, 607, 924, 948, 949)
GROUP BY r.id, r.name;
```

---

## Known Issues / Notes

1. **Import Order in phase2_config.py:** The `sys.path.insert` statement MUST appear BEFORE `from config import`. Some IDE plugins may auto-reorganize imports and break this.

2. **Aroy Thai has 0 dish modifiers:** This is expected - Aroy Thai uses special combo sections where modifiers are stored in `combo_modifier_groups` instead of on individual dishes.

3. **All Out Burger locations are nearly identical:** Same menu structure, same prices, same modifiers. Only the restaurant IDs differ.

4. **Upsert Logic:** The scraper uses upsert (INSERT ON CONFLICT UPDATE) so re-running on the same restaurant updates existing records rather than creating duplicates.

---

## Session Metrics

| Metric | Value |
|--------|-------|
| Restaurants Scraped | 6 |
| Total Combo Groups | 123 |
| Total Courses | 108 |
| Total Dishes | 896 |
| Total Modifiers | 5,986 |
| Bugs Fixed | 2 |
| New Scanners Created | 1 |
| Documentation Files | 2 |

