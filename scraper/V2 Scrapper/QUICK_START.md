# V2 Scraper - Quick Start Guide

**Status**: Phase 1 Implementation Complete ✅  
**Ready to Execute**: YES (needs V2 credentials)

---

## 📋 What's Complete

### ✅ Phase 1: Courses, Dishes, and Prices
- **v2_config.py** - Configuration file
- **v2_scraper.py** - Scraper class (NO database connections)
- **v2_discover_ids.py** - V2 ID discovery from dashboard
- **v2_scraper_phase1.py** - Phase 1 scraper (outputs JSON)
- **import_phase1_wrapper.sh** - SQL import script (psql-based, DELETE then INSERT)
- **v2_restaurants.json** - 20 restaurants list (source of truth)
- **Sushi Presse** created in database (ID: 1019)
- **La Nawab** confirmed in database (ID: 825)

### ⏳ Phase 2: Modifiers (TODO)
- v2_scraper_phase2.py - [Pending]
- import_phase2_wrapper.sh - [Pending]

### ⏳ Verification (TODO)
- verification_queries.sql - [Pending]

---

## 🚀 Execute Phase 1 (3 Simple Steps)

### Prerequisites

Add V2 credentials to `.env` file:
```bash
# In project root directory
echo "V2_USERNAME=your_v2_username" >> .env
echo "V2_PASSWORD=your_v2_password" >> .env
```

### Step 1: Discover V2 IDs (5 minutes)

```bash
cd /Users/brianlapp/Documents/GitHub/Migration-Strategy/scraper
python3 v2_discover_ids.py
```

**What it does**: Scrapes V2 dashboard to find V2 IDs for all 20 restaurants

**Expected**: Updates `v2_restaurants.json` with V2 IDs

### Step 2: Scrape Menus (15-30 minutes)

```bash
cd /Users/brianlapp/Documents/GitHub/Migration-Strategy/scraper
python3 v2_scraper_phase1.py
```

**What it does**: Scrapes courses, dishes, and prices → outputs to JSON files

**Expected**: 20 JSON files in `V2 Scrapper/phase1_output/`

### Step 3: Import to Database (2 minutes)

```bash
cd "/Users/brianlapp/Documents/GitHub/Migration-Strategy/scraper/V2 Scrapper/sql"
chmod +x import_phase1_wrapper.sh
./import_phase1_wrapper.sh
```

**What it does**: 
- DELETEs existing menu data for each restaurant
- INSERTs new courses, dishes, and prices via psql

**Expected**: All 20 restaurants have updated menu data in menuca_v3

---

## 🔍 Verify Results

Quick verification:
```bash
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -c "
SELECT 
    COUNT(DISTINCT r.id) AS restaurants,
    COUNT(DISTINCT c.id) AS courses,
    COUNT(DISTINCT d.id) AS dishes,
    COUNT(DISTINCT dp.id) AS prices
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
LEFT JOIN menuca_v3.dish_prices dp ON dp.restaurant_id = r.id
WHERE r.id IN (981, 973, 977, 962, 964, 963, 967, 966, 961, 965, 957, 960, 950, 825, 971, 974, 976, 952, 1019, 954);
"
```

Expected: 20 restaurants, ~150+ courses, ~1000+ dishes, ~1500+ prices

---

## 📂 Files Created

```
scraper/
├── v2_config.py                           ✅ Configuration
├── v2_scraper.py                          ✅ Scraper class
├── v2_discover_ids.py                     ✅ V2 ID discovery
├── v2_scraper_phase1.py                   ✅ Phase 1 scraper
│
└── V2 Scrapper/
    ├── v2_restaurants.json                ✅ 20 restaurants
    ├── v2_phase1_progress.json            ✅ Progress tracking
    ├── phase1_output/                     ✅ JSON output dir
    ├── phase2_output/                     ✅ JSON output dir
    │
    ├── sql/
    │   └── import_phase1_wrapper.sh       ✅ SQL import script
    │
    ├── V2_HYBRID_WORKFLOW_GUIDE.md        ✅ Complete guide
    └── QUICK_START.md                     ✅ This file
```

---

## 🎯 Guidelines Implemented

1. ✅ **All database operations via psql** (no Python database connections)
2. ✅ **20 restaurants = source of truth** (hardcoded list, not database query)
3. ✅ **Ignore legacy_v1_id and legacy_v2_id** (use user-provided list)
4. ✅ **V2 IDs from dashboard markup** (discovered from edit links)
5. ✅ **DELETE before INSERT strategy** (replace outdated menu data)

---

## ⚠️ Important Notes

### Restaurant List (Source of Truth)
The 20 restaurants in `v2_restaurants.json` are the **ONLY** restaurants to scrape:
- Al-s Drive In (981)
- Capital Bites (973)
- Capri Pizza (977)
- Chicco Pizza & Shawarma Buckingham (962)
- Chicco Pizza Maloney (964)
- Chicco Pizza Shawarma Anger (963)
- Chicco Pizza St-Louis (967)
- Chicco Pizza de l'Hopital (966)
- Chicco Shawarma Cantley (961)
- Chicco Shawarma Maloney (965)
- Cosenza (957)
- Cuisine Bombay Indienne (960)
- Kirkwood Pizza (950)
- La Nawab (825) - V2 ID: 1642
- Little Gyros Greek Grill (971)
- Pachino Pizza (974)
- Pizza Marie (976)
- River Pizza (952)
- Sushi Presse (1019) - Created ✅
- Wandee Thai (954)

### V2 Dashboard
- **URL**: https://aggregator-admin.menu.ca
- **Login**: Requires V2 admin credentials
- **Restaurant List**: `/index.php/restaurants/show/active`

### Output Format
Each JSON file contains:
```json
{
  "db_restaurant_id": 981,
  "v2_restaurant_id": 1678,
  "courses": [...]
}
```

---

## 🐛 Troubleshooting

### "V2 credentials not configured"
→ Add V2_USERNAME and V2_PASSWORD to `.env` file

### "No V2 ID found for restaurant"
→ Run `v2_discover_ids.py` first to discover IDs

### "Restaurant not found in dashboard"
→ Verify restaurant is active in V2 system, check name spelling

### Import script fails
→ Check log file: `V2 Scrapper/sql/import_phase1.log`

---

## 📞 Need Help?

- **Full Documentation**: `V2_HYBRID_WORKFLOW_GUIDE.md`
- **Original Handoff**: `V2_SCRAPER_HANDOFF.md`
- **HTML Structure**: `V2_PHASE1_HTML_STRUCTURE.md`

---

**Ready to execute when you have V2 credentials!** 🚀

