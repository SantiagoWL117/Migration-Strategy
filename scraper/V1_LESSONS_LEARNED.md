# V1 Scraping Process - Lessons Learned & Best Practices

**Date:** November 20, 2025  
**Purpose:** Agent handoff documentation for fixing V1 scraping issues  
**Context:** This document contains key lessons learned from the V1 scraping process that successfully migrated 18 restaurants with zero orphaned records.

---

## 🎯 Executive Summary

The V1 scraping process successfully migrated menu data from the legacy V2 admin system (`aggregator-admin.menu.ca`) to the new `menuca_v3` database schema. This document captures the critical implementation patterns and lessons learned that should be applied to any scraping work or fixes.

### Final V1 Results:
- ✅ **18 restaurants** fully migrated
- ✅ **778 dishes** with **1,207 prices**
- ✅ **1,260 modifier groups** with **6,563 modifiers**
- ✅ **Zero orphaned records** - all data properly linked
- ✅ **100% source_id coverage** - full V2 traceability

---

## 🎓 Key Lessons Learned

### 1. **Direct Database Writes (No JSON Files)**

**Problem:** Previous approaches used JSON files as intermediate storage, causing sync issues and complexity.

**Solution:** Write directly to the `menuca_v3` PostgreSQL schema using `psycopg2`.

**Implementation:**
```python
import psycopg2
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

# Insert directly
cur.execute("""
    INSERT INTO menuca_v3.courses (restaurant_id, name, description, source_id)
    VALUES (%s, %s, %s, %s)
    RETURNING id
""", (restaurant_id, name, description, source_id))

course_id = cur.fetchone()[0]
conn.commit()
```

**Why it matters:** Eliminates data sync issues, reduces complexity, and ensures data integrity.

---

### 2. **Two-Phase Scraping Strategy**

**Phase 1:** Scrape menu structure (courses, dishes, dish prices)  
**Phase 2:** Scrape modifiers (modifier groups, modifier items, modifier prices)

**Why separate phases:**
- Phase 1 is fast (~4 minutes for 8 restaurants)
- Phase 2 is slow (~2 hours for 8 restaurants) due to modal loading
- Allows verification of Phase 1 data before committing to lengthy Phase 2
- Better error recovery - can re-run phases independently

**Execution order:**
1. Run Phase 1 for all restaurants
2. Verify data in database
3. Run Phase 2 for all restaurants

---

### 3. **Timestamped Logging**

**Implementation:**
```python
import logging
from datetime import datetime

timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
log_file = f'phase1_scraper_{timestamp}.log'

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
```

**Why it matters:** Enables debugging, progress tracking, and issue identification with exact timestamps.

---

### 4. **Database Transaction Management**

**Critical Pattern:**
```python
try:
    # Scrape and insert data for restaurant
    insert_course(conn, course_data)
    insert_dishes(conn, dish_data)
    insert_prices(conn, price_data)
    
    conn.commit()
    logger.info("✓ Success")
    
except Exception as e:
    conn.rollback()
    logger.error(f"✗ Error: {e}")
    raise
```

**Why it matters:** Ensures data consistency - either all data for a restaurant is inserted, or none. Prevents partial/corrupted data.

---

### 5. **Modal-Based Modifier Extraction**

**Critical Discovery:** Modifiers cannot be accessed via direct API URLs. They must be extracted from the UI modal.

**Correct Approach:**
1. Navigate to restaurant menu page: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{v2_id}/menu/restaurant`
2. Find the dish's "edit" button
3. Click the button to open the modifier modal
4. Wait for modal to load
5. Parse modal HTML with BeautifulSoup
6. Extract modifier groups and items
7. Close modal
8. Repeat for next dish

**Code Pattern:**
```python
# Navigate to menu page
page.goto(f"{base_url}/index.php/restaurants/edit/{v2_restaurant_id}/menu/restaurant")

# Find and click edit button for specific dish
edit_button = page.locator(f"button[data-dish-id='{v2_dish_id}']")
edit_button.click()

# Wait for modal
page.wait_for_selector(".modal-dialog", state="visible")

# Get modal HTML
modal_html = page.locator(".modal-dialog").inner_html()

# Parse with BeautifulSoup
soup = BeautifulSoup(modal_html, 'html.parser')
```

**Why it matters:** This is the ONLY way to reliably extract modifier data from the V2 admin system.

---

### 6. **Active vs. Available Modifiers**

**Critical Bug Discovery (November 19, 2025):**

The V2 admin panel shows two types of modifier panels:
- `panel-success` - Modifiers **ACTIVE** for this dish (should be scraped)
- `panel-default` - Modifiers **AVAILABLE** but not active (should be IGNORED)

**Solution:**
```python
# CORRECT - Only scrape active modifiers
modifier_panels = customization_container.select(':scope > .panel.panel-success')

# WRONG - Scrapes both active and available
modifier_panels = customization_container.select(':scope > .panel')
```

**Why it matters:** Prevents migrating unused/disabled modifiers that would clutter the menu.

---

### 7. **Size Variant Handling**

**Pattern:** Dishes and modifiers can have multiple sizes with different prices.

**Input format (from V2):**
```
size="Small,Large"
price="10.99,15.99"
```

**Output (in database):**
```python
# Two dish_prices records
dish_prices = [
    {'size_variant': 'Small', 'price': 10.99},
    {'size_variant': 'Large', 'price': 15.99}
]

# Two dish_modifier_prices records (if modifier price varies by size)
modifier_prices = [
    {'price': 0.50},  # Small size
    {'price': 1.00}   # Large size
]
```

**Implementation:**
```python
sizes = [s.strip() for s in size_value.split(',') if s.strip()]
prices = [p.strip() for p in price_value.split(',') if p.strip()]

if len(sizes) == len(prices):
    for size, price in zip(sizes, prices):
        insert_price(dish_id, size, float(price))
```

**Why it matters:** Preserves pricing accuracy for multi-size menu items.

---

### 8. **Language ID System**

**Language mapping:**
- **English:** `language_id=1`
- **French:** `language_id=2`

**URL patterns:**
- English: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{v2_id}/menu/restaurant`
- French: `https://aggregator-admin.menu.ca/index.php/restaurants/edit/{v2_id}/menu/2/restaurant`

**Implementation:**
```python
def get_menu_url(v2_restaurant_id, language='en'):
    base = "https://aggregator-admin.menu.ca/index.php/restaurants/edit"
    if language == 'fr':
        return f"{base}/{v2_restaurant_id}/menu/2/restaurant"
    else:
        return f"{base}/{v2_restaurant_id}/menu/restaurant"
```

**Why it matters:** Ensures correct menu language is scraped for bilingual restaurants.

---

### 9. **Playwright Browser Automation**

**Technology choice:** Playwright (NOT Selenium) with Chromium

**Advantages:**
- Faster and more reliable than Selenium
- Better handling of dynamic content
- Built-in wait mechanisms
- Cleaner API

**Setup:**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    
    # Login
    page.goto("https://aggregator-admin.menu.ca/index.php/dashboard/login")
    page.fill("input[name='username']", username)
    page.fill("input[name='password']", password)
    page.click("button[type='submit']")
    page.wait_for_load_state("networkidle")
    
    # Scrape data
    # ...
    
    browser.close()
```

**Why it matters:** Provides reliable automation for JavaScript-heavy admin panels.

---

### 10. **Comprehensive Error Handling**

**Required error handling patterns:**

```python
# Network errors
try:
    page.goto(url, timeout=30000)
except TimeoutError:
    logger.error(f"Timeout loading {url}")
    continue

# Parsing errors
try:
    dish_name = row.find_element("input[name='name']").get_attribute('value')
except Exception as e:
    logger.error(f"Error parsing dish: {e}")
    continue

# Database errors
try:
    cur.execute(sql, params)
    conn.commit()
except psycopg2.Error as e:
    conn.rollback()
    logger.error(f"Database error: {e}")
    raise

# Browser cleanup
finally:
    if browser:
        browser.close()
```

**Why it matters:** Prevents cascading failures and provides actionable error messages for debugging.

---

## 📈 Performance Metrics

### Phase 1 Timing:
- **Duration:** ~4 minutes for 8 restaurants
- **Rate:** ~30 seconds per restaurant
- **Bottleneck:** Page load time

### Phase 2 Timing:
- **Duration:** ~2 hours 15 minutes for 8 restaurants
- **Rate:** ~17 minutes per restaurant
- **Bottleneck:** Modal loading time (1-2 seconds per dish)

**Optimization note:** Phase 2 cannot be significantly sped up due to modal render time. Running in headless mode provides marginal improvement (~10%).

---

## 🐛 Common Issues & Solutions

### Issue 1: "Invalid access point" Error
**Symptom:** API returns `{"msg":"Invalid access point","error":true}`  
**Cause:** Attempting to access modifier data via direct URL  
**Solution:** Use modal-based extraction (see Lesson #5)

### Issue 2: Too Many Modifiers Scraped
**Symptom:** Restaurant has hundreds of modifiers that aren't actually active  
**Cause:** Scraping both `panel-success` and `panel-default` classes  
**Solution:** Filter to only `panel-success` (see Lesson #6)

### Issue 3: Missing Modifier Prices
**Symptom:** Modifiers inserted but no prices  
**Cause:** Not parsing price fields from modal HTML  
**Solution:** Extract prices from modifier item rows: `input[name*='price']`

### Issue 4: Duplicate Records
**Symptom:** Running scraper twice creates duplicate data  
**Cause:** No duplicate checking before insert  
**Solution:** Add upsert logic or clear existing data before re-scraping

### Issue 5: Orphaned Records
**Symptom:** Modifiers exist but their parent dish doesn't  
**Cause:** Phase 2 ran without Phase 1, or Phase 1 failed mid-run  
**Solution:** Always run Phase 1 first, verify completion before Phase 2

---

## 🔧 Environment Setup

**Required environment variables (`.env` file):**
```env
DB_CONNECTION_STRING=postgresql://user:pass@host:port/database
CRM_USERNAME=admin_username
CRM_PASSWORD=admin_password
CRM_BASE_URL=https://aggregator-admin.menu.ca
```

**Required Python packages:**
```
playwright==1.40.0
beautifulsoup4==4.12.2
psycopg2-binary==2.9.9
python-dotenv==1.0.0
```

---

## 📋 Pre-Scraping Checklist

Before running any scraper:

- [ ] `.env` file configured with valid credentials
- [ ] Database connection tested
- [ ] Restaurant IDs verified (V2 ID vs V3 ID mapping)
- [ ] Playwright browsers installed (`playwright install chromium`)
- [ ] Log directory exists
- [ ] Phase 1 completed (if running Phase 2)
- [ ] Existing data cleared (if re-scraping)

---

## 🎯 Agent Instructions for Fixing V1 Issues

If you're tasked with fixing V1 scraping issues, follow these steps:

1. **Identify the issue:**
   - Review error logs with timestamps
   - Check database for orphaned/duplicate records
   - Verify restaurant ID mappings

2. **Apply the lessons:**
   - Use direct database writes (Lesson #1)
   - Follow two-phase strategy (Lesson #2)
   - Use modal-based extraction (Lesson #5)
   - Filter only active modifiers (Lesson #6)

3. **Test with a single restaurant:**
   - Create a test script for one restaurant
   - Verify Phase 1 data before running Phase 2
   - Check database for correctness

4. **Run full batch:**
   - Only after test succeeds
   - Monitor logs in real-time
   - Verify database after completion

---

## 📚 Additional Resources

- **V2 Admin Panel:** `https://aggregator-admin.menu.ca`
- **Database Schema:** `menuca_v3` in Supabase
- **Core Scraper Class:** `scraper/v2_scraper.py` (contains modal extraction logic)
- **Environment File:** `scraper/.env`

---

**Last Updated:** November 20, 2025  
**Status:** ✅ Production-tested with 18 restaurants successfully migrated











