# V2 Scraper - Quick Start Guide

**For**: Brian  
**Quick Reference**: Essential info to get started fast

---

## 🎯 What You're Building

A scraper for **V2-only restaurants** (restaurants not in the legacy V1 CRM system).

---

## 📋 Pre-Flight Checklist

Before coding anything, answer these:

1. **Where is the V2 menu data?**
   - [ ] API endpoint? URL: _________________
   - [ ] Website? URL: _________________
   - [ ] Database? Connection: _________________
   - [ ] Files? Location: _________________

2. **How many V2 restaurants?**
   - Run this query:
   ```sql
   SELECT COUNT(*) 
   FROM menuca_v3.restaurants 
   WHERE legacy_v1_id IS NULL 
     AND legacy_v2_id IS NOT NULL 
     AND deleted_at IS NULL;
   ```

3. **Do you have access credentials?**
   - [ ] API key / token
   - [ ] Username / password
   - [ ] Database credentials

---

## 🚀 Quick Steps

### Step 1: Get V2 Restaurant List (15 min)
```python
from database import DatabaseManager

db = DatabaseManager()
db.connect()

query = """
    SELECT id, name, address, legacy_v2_id
    FROM menuca_v3.restaurants
    WHERE legacy_v1_id IS NULL 
      AND legacy_v2_id IS NOT NULL 
      AND deleted_at IS NULL
"""

db.cursor.execute(query)
v2_restaurants = [dict(row) for row in db.cursor.fetchall()]

# Save to file
import json
with open('v2_restaurants.json', 'w') as f:
    json.dump(v2_restaurants, f, indent=2)

print(f"Found {len(v2_restaurants)} V2 restaurants")
```

### Step 2: Test Data Access (15 min)
Test that you can access V2 menu data for 1 restaurant:
- Can you get course names?
- Can you get dish names?
- Can you get prices?
- Can you get modifiers?

### Step 3: Build Phase 1 (2-4 hours)
Copy `scraper/List 4 Scrapper/batch_scrape_list4.py` as your template.

**Change these parts:**
1. Data source (replace Playwright/HTML scraping with your method)
2. File names (use `v2_` prefix)
3. Keep everything else the same!

### Step 4: Test Phase 1 (30 min)
```python
# In your script, test with 2 restaurants first:
to_process = v2_restaurants[:2]  # Only 2 for testing

# After it works, process all:
to_process = v2_restaurants
```

### Step 5: Build Phase 2 (2-4 hours)
Copy `scraper/List 4 Scrapper/batch_scrape_list4_prices_english.py` as your template.

**Change these parts:**
1. Data source for prices/modifiers
2. File names (use `v2_` prefix)
3. Keep everything else the same!

---

## 🔑 Key Code Snippets

### Import Pattern (top of every script)
```python
import sys
import os

# Add parent dir to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA
```

### Database Usage
```python
db = DatabaseManager()
db.connect()

# Insert course
course_id = db.insert_course(
    restaurant_id=123,
    name="Appetizers",
    description="",
    display_order=0
)

# Insert dish
dish_id = db.insert_dish(
    restaurant_id=123,
    course_id=course_id,
    name="Spring Rolls",
    description="Crispy vegetable rolls",
    display_order=0,
    legacy_menu_entry_id=None  # V2 may not have this
)

# Insert price
db.insert_dish_price(
    dish_id=dish_id,
    size_variant="standard",  # or "Small", "Large", etc.
    price=8.99,
    display_order=0
)

db.close()
```

### Progress Tracking
```python
import json
from pathlib import Path

def load_progress():
    if Path('v2_progress.json').exists():
        with open('v2_progress.json', 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}

def save_progress(progress):
    with open('v2_progress.json', 'w') as f:
        json.dump(progress, f, indent=2)

# Use it:
progress = load_progress()
completed = set(progress['completed'])

for restaurant in v2_restaurants:
    if restaurant['id'] in completed:
        continue
    
    try:
        # Process restaurant
        # ...
        
        progress['completed'].append(restaurant['id'])
        save_progress(progress)
    except Exception as e:
        progress['failed'].append(restaurant['id'])
        save_progress(progress)
```

---

## ✅ Data Structure You Need to Return

### Phase 1: Menu Structure
```python
{
    'courses': [
        {
            'name': 'Appetizers',
            'description': '',
            'display_order': 0,
            'dishes': [
                {
                    'name': 'Spring Rolls',
                    'description': 'Crispy vegetable rolls',
                    'display_order': 0,
                    'source_id': 'optional_id'  # May not have for V2
                }
            ]
        }
    ]
}
```

### Phase 2: Prices & Modifiers
```python
{
    'prices': [
        {'size_variant': 'Small', 'price': 10.99, 'display_order': 0},
        {'size_variant': 'Large', 'price': 16.99, 'display_order': 1}
    ],
    'modifiers': [
        {
            'name': 'Extra Toppings',
            'type_code': 'ci',  # or 'e', 'sa', 'br', etc.
            'is_required': False,
            'min_selections': 0,
            'max_selections': 5,
            'display_order': 0,
            'items': [
                {
                    'name': 'Extra Cheese',
                    'prices': [2.00, 3.00],  # Per size variant
                    'display_order': 0,
                    'is_default': False
                }
            ]
        }
    ]
}
```

---

## 🆘 Common Issues & Solutions

### Issue: Import Error
```
ModuleNotFoundError: No module named 'database'
```
**Solution**: Add parent directory to path (see Import Pattern above)

### Issue: Connection String Missing
```
KeyError: 'DB_CONNECTION_STRING'
```
**Solution**: Check `.env` file exists and has `DB_CONNECTION_STRING=...`

### Issue: Unicode Errors on Windows
```
UnicodeEncodeError: 'charmap' codec can't encode...
```
**Solution**: Use `safe_print()` instead of `print()`
```python
def safe_print(text):
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))
```

---

## 📞 Need Help?

**Reference these files:**
- `scraper/V2_SCRAPER_HANDOFF.md` - Full detailed guide
- `scraper/database.py` - Database methods
- `scraper/List 4 Scrapper/batch_scrape_list4.py` - Phase 1 example
- `scraper/List 4 Scrapper/batch_scrape_list4_prices_english.py` - Phase 2 example

**Key Principle**: 
Copy the V1 scraper structure, only change the data source!

---

**Ready to build? Start with Step 1! 🚀**

