# Comprehensive Menu Scraper Handoff

**Last Updated:** December 11, 2025  
**Purpose:** Complete documentation of ALL scrapers in the codebase for agent continuity  
**Status:** Production systems with ongoing migration work

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Scraper Systems Overview](#scraper-systems-overview)
3. [V2 Scraper (Legacy Admin)](#v2-scraper-legacy-admin)
4. [V1 Scraper (CRM Admin)](#v1-scraper-crm-admin)
5. [Combo Scraper](#combo-scraper)
6. [Phase 2 Restaurants Scraper](#phase-2-restaurants-scraper)
7. [Special Combo Sections Scanner](#special-combo-sections-scanner)
8. [Database Schema Reference](#database-schema-reference)
9. [Environment Setup](#environment-setup)
10. [Current Status & Next Steps](#current-status--next-steps)

---

## Executive Summary

This project migrates menu data from two legacy systems to the `menuca_v3` PostgreSQL schema:

| Source System | URL | Restaurants | Status |
|--------------|-----|-------------|--------|
| V2 Legacy Admin | `aggregator-admin.menu.ca` | 24 | ✅ Complete (18 migrated) |
| V1 CRM Admin | `menuadmin.menu.ca` | 166 | 🟡 In Progress |

### Migration Progress

| Data Type | V2 Restaurants | V1 Restaurants | Total |
|-----------|----------------|----------------|-------|
| **Restaurants** | 18/24 | 6/166 | 24/190 |
| **Combo Groups** | N/A | 1,138+ | 1,138+ |
| **Courses** | 100 | 108+ | 208+ |
| **Dishes** | 778 | 896+ | 1,674+ |
| **Modifiers** | 6,563 | 14,000+ | 20,563+ |

---

## Scraper Systems Overview

```
Scrapers/Menu Scrapers/
├── V1 Scrapper/                    # V1 mapping & planning docs
├── V2 Scraper/                     # V2 restaurant JSON mappings
├── Combo scraper/                  # Combo groups scraper (V1 CRM)
│   ├── Phase 1/                    # Combo groups extraction
│   ├── Phase 2/                    # Combo details extraction
│   └── Special combo sections/     # Special combo scanner
├── Phase2 Restaurants Scraper/     # Full menu scraper (V1 CRM)
├── Final Review Scraper/           # Post-migration validation
└── logs/                           # All scraper logs
```

### Scraper Timeline

| Date | Scraper | Restaurants | Data Extracted |
|------|---------|-------------|----------------|
| Nov 19, 2025 | V2 Phase 1 & 2 | 18 | Courses, dishes, prices, modifiers |
| Dec 9-10, 2025 | Combo Phase 1 | 123 | Combo groups, sections, modifier groups |
| Dec 11, 2025 | Phase 2 Restaurants | 6 | Full menu + combo data |
| Dec 11, 2025 | Special Combo Scanner | 123 | Identified 12 special restaurants |

---

## V2 Scraper (Legacy Admin)

### Overview

**Source:** `https://aggregator-admin.menu.ca`  
**Target:** 24 V2 restaurants  
**Status:** ✅ 18 restaurants fully migrated

### Files

```
Scrapers/Menu Scrapers/
├── v2_scraper.py                   # Core scraper class
├── v2_config.py                    # V2 configuration
├── phase1_english_corrected.py     # English Phase 1 (8 restaurants)
├── phase2_english_corrected.py     # English Phase 2 (8 restaurants)
├── phase1_french_scraper.py        # French Phase 1 (5 restaurants)
├── phase2_french_scraper.py        # French Phase 2 (5 restaurants)
└── V2 Scraper/
    ├── v2_restaurants_english.json # English V2/V3 ID mappings
    └── v2_restaurants_french.json  # French V2/V3 ID mappings
```

### Results

| Language | Restaurants | Courses | Dishes | Prices | Modifier Groups | Modifiers |
|----------|-------------|---------|--------|--------|-----------------|-----------|
| English | 8 | 100 | 778 | 1,207 | 1,260 | 6,563 |
| French | 5 | (pre-existing) | (scraped) | (scraped) | (scraped) | (scraped) |

### Commands

```powershell
cd "Scrapers\Menu Scrapers"

# Phase 1: Menu structure (courses, dishes, prices)
python phase1_english_corrected.py
python phase1_french_scraper.py

# Phase 2: Modifiers
python phase2_english_corrected.py
python phase2_french_scraper.py
```

### Documentation

- **Handoff:** `Scrapers/Menu Scrapers/V2_SCRAPER_HANDOFF.md`
- **Lessons Learned:** `Scrapers/Menu Scrapers/V1_LESSONS_LEARNED.md`

---

## V1 Scraper (CRM Admin)

### Overview

**Source:** `https://menuadmin.menu.ca`  
**Target:** 166 V1 restaurants  
**Status:** 🟡 Planning complete, scraping in progress

### Key Information

- **Total V1 Restaurants:** 166
- **Successfully Mapped:** 166 (100%)
- **V1 ID Range:** 89 to 1095 (non-sequential)
- **V3 ID Range:** 7 to 1017 (different from V1!)

### Restaurant Categories

| Category | Count | V1 IDs | Notes |
|----------|-------|--------|-------|
| Standard (Phase 1) | 161 | Various | Has existing course/dish data |
| Complete Re-scrape (Phase 2) | 5 | 830, 1013, 1038, 1071 | Missing or incomplete data |

**Phase 2 Restaurants (need complete scrape):**
- Aroy Thai (V3: 607, V1: 830)
- All Out Burger Bank St. (V3: 924, V1: 1013)
- All Out Burger Gladstone (V3: 948, V1: 1038)
- All Out Burger Montreal Rd (V3: 949, V1: 1071)
- All Out Burger Notre-Dame (V3: 833, V1: 1071) - shares V1 ID!

### Files

```
Scrapers/Menu Scrapers/V1 Scrapper/
├── V1_SCRAPER.md                   # Complete documentation
├── DATA_INTEGRITY_REPORT.md        # Data verification results
├── SCRAPING_STRATEGY.md            # Phase 1 & 2 strategy
├── v1_v3_id_mapping.csv            # PRIMARY mapping file
└── verify_data_integrity.py        # Verification script
```

### Critical Rule: ID Mapping

**NEVER assume V1 ID = V3 ID!**

```python
# Example mappings (V1 ID → V3 ID)
# Aahar The Taste of India: 781 → 561
# Pho Dau Bo Restaurant: 280 → 147
# All Out Burger Montreal Rd: 1071 → 949
```

**Always use:** `v1_v3_id_mapping.csv`

---

## Combo Scraper

### Overview

**Source:** `https://menuadmin.menu.ca` (Combo Groups page)  
**Target:** Combo groups for 123+ V1 restaurants  
**Status:** ✅ Phase 1 complete (Dec 9-10, 2025)

### What It Scrapes

Combo groups are special menu items that bundle multiple dishes with customization options.

**Tables populated:**
- `combo_groups` - The combo meal itself
- `combo_group_sections` - Sections within a combo (e.g., "Choose your pizza")
- `combo_modifier_groups` - Groups of selectable options
- `combo_modifiers` - Individual selectable items
- `combo_modifier_prices` - Prices per size variant

### Files

```
Scrapers/Menu Scrapers/Combo scraper/
├── combo_scraper.py               # Core scraper logic
├── combo_config.py                # Configuration
├── combo_database.py              # Database operations
├── run_phase1.py                  # Phase 1 entry point
├── run_phase1_rescrape.py         # Re-scrape missed restaurants
├── run_phase2.py                  # Phase 2 entry point
├── Phase 1/
│   └── phase 1 prompt.md          # Phase 1 requirements
└── Phase 2/
    └── phase 2 prompt.md          # Phase 2 requirements
```

### Phase 1 Results (Dec 9-10, 2025)

| Metric | Count |
|--------|-------|
| Restaurants Processed | 123 |
| Combo Groups | 880+ |
| Sections | 1,294 |
| Modifier Groups | 1,294 |
| Modifiers | 10,830 |
| Prices | 20,870 |

### Commands

```powershell
cd "Scrapers\Menu Scrapers\Combo scraper"
$env:CRM_V1_USERNAME = "your_username"
$env:CRM_V1_PASSWORD = "your_password"

# Phase 1: Combo groups, sections, modifier groups
python run_phase1.py

# Re-scrape missed restaurants
python run_phase1_rescrape.py

# Phase 2: Additional combo details
python run_phase2.py --all
```

### Log Files

- `logs/Combo Phase 1 successful.log` - Main Phase 1 log (123 restaurants)
- `logs/combo_phase1_rescrape_summary_*.csv` - Summary CSVs
- `logs/combo_phase2_*.log` - Phase 2 logs

---

## Phase 2 Restaurants Scraper

### Overview

**Source:** `https://menuadmin.menu.ca`  
**Target:** 6 critical restaurants with missing/incomplete data  
**Status:** ✅ Complete (Dec 11, 2025)

### What It Scrapes

This is the **most comprehensive** scraper - extracts everything:

1. **Combo Groups** - Combo meal definitions
2. **Combo Sections** - Sections within combos
3. **Combo Modifier Groups** - Selectable option groups
4. **Combo Modifiers** - Individual options with prices
5. **Courses** - Menu categories
6. **Dishes** - Individual menu items (normal + combo)
7. **Dish Prices** - Prices per size variant
8. **Dish Availability** - Hide-on-days rules
9. **Modifier Groups** - Dish modifier groups
10. **Modifiers** - Dish modifier options with prices

### Files

```
Scrapers/Menu Scrapers/Phase2 Restaurants Scraper/
├── phase2_scraper.py              # Main scraper logic
├── phase2_config.py               # Configuration & restaurant list
├── phase2_database.py             # Database operations
└── run_scraper.py                 # Entry point with CLI args
```

### Restaurants Scraped

| Restaurant | V3 ID | V1 ID | Combo Groups | Courses | Dishes | Modifiers |
|------------|-------|-------|--------------|---------|--------|-----------|
| Joes Family Pizzeria | 636 | 863 | 80 | 37 | 374 | 3,394 |
| Milano - 2 Pembroke | 265 | 411 | 34 | 20 | 150 | 1,481 |
| Aroy Thai | 607 | 830 | 6 | 9 | 39 | 0* |
| All Out Burger Bank St. | 924 | 1013 | 1 | 14 | 111 | 337 |
| All Out Burger Gladstone | 948 | 1038 | 1 | 14 | 111 | 337 |
| All Out Burger Montreal Rd | 949 | 1071 | 1 | 14 | 111 | 337 |

*Aroy Thai uses special combo sections instead of dish modifiers

### Bug Fixes Applied (Dec 11, 2025)

**Bug 1: Incorrect CSS Selector Prefix**
- **File:** `phase2_scraper.py`, function `_parse_section_modifier_groups()`
- **Issue:** `type_prefix` was `'ci_id'` instead of `'ci'`
- **Fix:** Changed selector to use `name=f'{type_prefix}_radio'`

**Bug 2: Missing Checked Attribute Filter**
- **File:** `phase2_scraper.py`, function `_parse_section_modifier_groups()`
- **Issue:** All combo modifier groups were inserted, not just active ones
- **Fix:** Added `if radio.has_attr('checked'):` condition

### Commands

```powershell
cd "Scrapers\Menu Scrapers\Phase2 Restaurants Scraper"
$env:CRM_V1_USERNAME = "your_username"
$env:CRM_V1_PASSWORD = "your_password"

# Run on all 6 restaurants
python run_scraper.py --all

# Run on single restaurant
python run_scraper.py --restaurant 636

# Run on all except specific restaurant
python run_scraper.py --all --exclude 636
```

### Configuration: Restaurant List

Edit `phase2_config.py` to modify target restaurants:

```python
RESTAURANTS = [
    {'v3_id': 636, 'v1_id': 863, 'name': 'Joes Family Pizzeria'},
    {'v3_id': 265, 'v1_id': 411, 'name': 'Milano - 2 Pembroke'},
    {'v3_id': 607, 'v1_id': 830, 'name': 'Aroy Thai'},
    {'v3_id': 924, 'v1_id': 1013, 'name': 'All Out Burger Bank St.'},
    {'v3_id': 948, 'v1_id': 1038, 'name': 'All Out Burger Gladstone'},
    {'v3_id': 949, 'v1_id': 1071, 'name': 'All Out Burger Montreal Rd'},
]
```

### Known Issue: Import Order

**CRITICAL:** In `phase2_config.py`, the `sys.path.insert` MUST appear BEFORE `from config import`:

```python
import os
import sys

# This MUST be before config import
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config import (  # Now this will work
    CRM_BASE_URL, CRM_USERNAME, ...
)
```

Some IDE plugins auto-organize imports and break this. Disable import sorting for this file.

---

## Special Combo Sections Scanner

### Overview

**Purpose:** Identify restaurants with "special combo sections" - combo groups where specific menu items are pre-checked as valid customer selections.

**Status:** ✅ Complete (Dec 11, 2025)

### What It Finds

Some combo groups have checkboxes with `checked=""` attribute, meaning:
- Customers can only select from pre-checked items
- These are NOT the same as regular combo modifier groups
- Examples: "Pick any Large Pizza from Menu" with 12 pizzas pre-checked

### Files

```
Scrapers/Menu Scrapers/Combo scraper/Special combo sections/
├── special_combo_scanner.py       # Scanner logic
├── run_scanner.py                 # Entry point
└── special combo sections prompt.md  # Requirements
```

### Scan Results (Dec 11, 2025)

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

**Totals:** 12 restaurants, 48 special groups, 679 pre-checked items

### Pattern Types Found

1. **"Pick from Menu" Combos** - Customer chooses from menu items
2. **Dietary Restriction Variants** - Separate groups for allergies (e.g., "without Shrimp")
3. **Simple Either/Or Selections** - "Garden or Caesar Salad"
4. **Combo Meal Components** - Salad + soup + drink combos

### Commands

```powershell
cd "Scrapers\Menu Scrapers\Combo scraper\Special combo sections"
$env:CRM_V1_USERNAME = "your_username"
$env:CRM_V1_PASSWORD = "your_password"

python run_scanner.py
```

---

## Database Schema Reference

### Connection

```
Database: Supabase PostgreSQL
Schema: menuca_v3
Connection String: $env:DB_CONNECTION_STRING or SUPABASE_DB_URL
```

### Tables Overview

#### Restaurant & Menu Structure
| Table | Description |
|-------|-------------|
| `restaurants` | Restaurant definitions |
| `courses` | Menu categories |
| `dishes` | Individual menu items |
| `dish_prices` | Prices per size variant |
| `dish_availability` | Hide-on-days rules |

#### Dish Modifiers
| Table | Description |
|-------|-------------|
| `modifier_groups` | Groups of modifiers for dishes |
| `modifiers` | Individual modifier options |
| `modifier_prices` | Modifier prices per size |

#### Combo Groups
| Table | Description |
|-------|-------------|
| `combo_groups` | Combo meal definitions |
| `combo_group_sections` | Sections within combos |
| `combo_modifier_groups` | Selectable option groups in combos |
| `combo_modifiers` | Individual combo options |
| `combo_modifier_prices` | Combo modifier prices per size |
| `dish_combo_groups` | Links combo dishes to combo groups |

### Key Relationships

```
restaurants (1) ──→ (N) courses
courses (1) ──→ (N) dishes
dishes (1) ──→ (N) dish_prices
dishes (1) ──→ (N) modifier_groups
modifier_groups (1) ──→ (N) modifiers
modifiers (1) ──→ (N) modifier_prices

restaurants (1) ──→ (N) combo_groups
combo_groups (1) ──→ (N) combo_group_sections
combo_group_sections (1) ──→ (N) combo_modifier_groups
combo_modifier_groups (1) ──→ (N) combo_modifiers
combo_modifiers (1) ──→ (N) combo_modifier_prices

dishes (combo) (1) ──→ (N) dish_combo_groups
dish_combo_groups (N) ←── (1) combo_groups
```

### Section Types (Combo Group Sections)

| Code | Name | HTML Prefix | Description |
|------|------|-------------|-------------|
| BR | Build Recipe | br_id | Custom recipe builder |
| CI | Combo Items | ci_id | Combo item selection |
| DR | Drinks | dr_id | Beverage selection |
| SA | Sauces | sa_id | Sauce selection |
| SD | Sides | sd_id | Side dish selection |
| E | Extra | e_id | Extra items |
| CM | Comment | cm_id | Special instructions |

---

## Environment Setup

### Required Environment Variables

Create `.env` file in project root or `Scrapers/Menu Scrapers/`:

```env
# Database
DB_CONNECTION_STRING=postgresql://user:password@host:5432/database
SUPABASE_DB_URL=postgresql://user:password@host:5432/database

# V1 CRM (menuadmin.menu.ca)
CRM_V1_USERNAME=your_username
CRM_V1_PASSWORD=your_password
CRM_BASE_URL=https://menuadmin.menu.ca

# V2 Admin (aggregator-admin.menu.ca) - if needed
CRM_USERNAME=your_username
CRM_PASSWORD=your_password
```

### Python Dependencies

```
playwright>=1.47.0
beautifulsoup4>=4.12.3
html5lib>=1.1
psycopg2-binary>=2.9.9
python-dotenv>=1.0.1
lxml>=5.3.0
```

### Setup Commands

```powershell
cd "Scrapers\Menu Scrapers"
pip install -r requirements.txt
playwright install chromium
```

---

## Current Status & Next Steps

### Completed ✅

1. **V2 Scraper** - 18/24 restaurants fully migrated
2. **V1 Mapping** - All 166 restaurants mapped to V1/V3 IDs
3. **Combo Scraper Phase 1** - 123 restaurants, 880+ combo groups
4. **Phase 2 Restaurants Scraper** - 6 critical restaurants complete
5. **Special Combo Scanner** - 12 restaurants identified with special handling

### In Progress 🟡

1. **V1 Standard Scraping** - 160 restaurants need modifier scraping
2. **Special Combo Sections** - 12 restaurants need special handling

### Next Steps

#### Option A: Expand Phase 2 Scraper to More Restaurants

1. Update `RESTAURANTS` list in `phase2_config.py`
2. Add new V3/V1 ID pairs from `v1_v3_id_mapping.csv`
3. Run `python run_scraper.py --all`

```python
# Example: Add more restaurants
RESTAURANTS = [
    # Existing...
    {'v3_id': 118, 'v1_id': 238, 'name': 'Mano City Pizza'},
    {'v3_id': 123, 'v1_id': 245, 'name': 'Milano'},
    # ... more restaurants
]
```

#### Option B: Handle Special Combo Sections

The 12 restaurants with special combo sections need manual review or enhanced scraping:

**High Priority:**
- Milano (V3: 680) - 349 checked items
- Aroy Thai (V3: 607) - 116 checked items (already scraped)

**Medium Priority:**
- Amicci Pizza (V3: 735) - 60 checked items
- Nachos Loco (V3: 790, 801) - 72 checked items total

#### Option C: Batch V1 Modifier Scraping

For the 160 restaurants that only need modifier data (not full menu):

1. Use the V1 Scraper strategy from `V1_SCRAPER.md`
2. Target tables: `modifier_groups`, `modifiers`, `modifier_prices`
3. Skip `courses`, `dishes`, `dish_prices` (already exist)

---

## Quick Reference Commands

```powershell
# Set credentials (PowerShell)
$env:CRM_V1_USERNAME = "your_username"
$env:CRM_V1_PASSWORD = "your_password"

# Phase 2 Restaurants Scraper
cd "Scrapers\Menu Scrapers\Phase2 Restaurants Scraper"
python run_scraper.py --all
python run_scraper.py --restaurant 636
python run_scraper.py --all --exclude 636

# Combo Scraper
cd "Scrapers\Menu Scrapers\Combo scraper"
python run_phase1.py
python run_phase2.py --all

# Special Combo Scanner
cd "Scrapers\Menu Scrapers\Combo scraper\Special combo sections"
python run_scanner.py

# V2 Scraper
cd "Scrapers\Menu Scrapers"
python phase1_english_corrected.py
python phase2_english_corrected.py
```

---

## Log Files Reference

| Log File | Content |
|----------|---------|
| `logs/Combo Phase 1 successful.log` | Combo scraper Phase 1 (123 restaurants) |
| `logs/Phase 2 Critical Restaurants completed.log` | Phase 2 scraper (5 restaurants) |
| `logs/phase2_scraper_20251211_*.log` | Individual Phase 2 runs |
| `logs/special_combo_scan_20251211_*.log` | Special combo scanner results |
| `logs/phase1_english_corrected_*.log` | V2 Phase 1 English |
| `logs/phase2_english_corrected_*.log` | V2 Phase 2 English |

---

## Documentation Files Reference

| File | Purpose |
|------|---------|
| `V1_SCRAPER.md` | V1 scraper planning & mapping |
| `V2_SCRAPER_HANDOFF.md` | V2 scraper complete documentation |
| `V1_LESSONS_LEARNED.md` | Best practices from V1/V2 scraping |
| `Menu.ca V3/BRIAN HANDOFF.md` | Schema explanation for combos/dishes |
| `COMPREHENSIVE_SCRAPER_HANDOFF.md` | This file - complete overview |

---

## Agent Continuity Checklist

When continuing this work, verify:

- [ ] `.env` file has valid credentials
- [ ] Database connection works
- [ ] `phase2_config.py` has correct import order (sys.path.insert BEFORE config import)
- [ ] Check logs for last successful restaurant
- [ ] Verify target restaurant isn't already scraped

**To add a new restaurant:**
1. Find V1 ID from `v1_v3_id_mapping.csv` or CRM
2. Find V3 ID from `menuca_v3.restaurants` table
3. Add to `RESTAURANTS` list in `phase2_config.py`
4. Run scraper

**To verify scraped data:**
```sql
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

**End of Comprehensive Handoff**  
**Status:** Ready for agent continuation  
**Good luck! 🚀**

