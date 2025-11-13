# V2 Restaurant Scraper - Development Handoff

**Prepared For**: Brian  
**Date**: November 13, 2025  
**Purpose**: Build scraper for V2-only restaurants from aggregator-admin.menu.ca

---

# PART 1: HUMAN-FRIENDLY EXPLANATION

## What Needs to Be Built

You need to create a **scraper system for V2-only restaurants** - these are restaurants that exist in the new V2 system (`aggregator-admin.menu.ca`) but were never in the legacy V1 CRM system.

### The Challenge
- **V1 restaurants**: Already scraped from `menuadmin.menu.ca` (legacy CRM) ✅ **DONE (65 restaurants)**
- **V2 restaurants**: Need to be scraped from `aggregator-admin.menu.ca` (V2 admin dashboard)

### Data Source
- **V2 Admin System**: `https://aggregator-admin.menu.ca`
- **Authentication**: You'll need login credentials
- **Data Format**: HTML forms with Bootstrap panels
- **Access Method**: Web scraping (similar approach to V1, but different HTML structure)

---

## The 2-Phase Approach

This proven approach should be followed for V2 restaurants:

### **Phase 1: Courses & Dishes**
1. Get list of V2 restaurants from database
2. For each restaurant, navigate to their menu page
3. Extract course names (Appetizers, Main Courses, etc.)
4. Extract dish names and descriptions
5. Insert into `menuca_v3.courses` and `menuca_v3.dishes` tables

**Estimated Time**: 2-4 hours to build, 1-2 hours to run

### **Phase 2: Prices & Modifiers**
1. For each dish scraped in Phase 1
2. Click on each dish to open the details modal
3. Extract dish prices (if multiple sizes exist)
4. Extract customization options (modifiers):
   - Extras (extra cheese, bacon, etc.)
   - Side dishes (fries, salad, etc.)
   - Drinks (Pepsi, 7Up, etc.)
   - Sauces, breads, dressings, etc.
5. Insert into:
   - `menuca_v3.dish_prices`
   - `menuca_v3.modifier_groups`
   - `menuca_v3.dish_modifiers`
   - `menuca_v3.dish_modifier_prices`

**Estimated Time**: 3-5 hours to build, 2-4 hours to run

---

## V2 System Data Structure

### Dish Modal Structure
V2 dishes are displayed in a **Bootstrap modal** with collapsible panels for each modifier type.

**Key Elements:**
- **Dish ID**: `<input type="hidden" name="dish_id" value="9001">`
- **Dish Name**: `<h4 class="modal-title" id="dish-modal-title">Shawarma 6" TRIO</h4>`
- **Has Customization**: Radio button `name="has_customization"`
- **Modifier Types**: Panels with IDs like `#extra`, `#side_dish`, `#drink`, `#sauce`, etc.

### Modifier Type Panels
Each modifier type (e.g., "Extras", "Side dishes", "Drinks") has:
1. **Enable checkbox**: `name="customization[TYPE][use]" value="1"`
2. **Configuration**:
   - Title for free items: `name="customization[TYPE][title_free]"`
   - Title for paid items: `name="customization[TYPE][title_paid]"`
   - Min items: `name="customization[TYPE][min]"`
   - Max items: `name="customization[TYPE][max]"`
   - Free items: `name="customization[TYPE][free]"`
   - Display order: `name="customization[TYPE][display_order]"`

3. **Available Groups**: Radio buttons for selecting modifier groups
   - Group ID: `<input type="hidden" name="group" value="486">`
   - Group name in label: e.g., "Ajouter une autre personne 12.99"
   
4. **Group Items**: Individual modifier items with prices
   - Item label: `<label for="item_486_45e8a6e1">Ajouter une autre personne</label>`
   - Item price: `<input name="item[486][45e8a6e1]" value="12.99">`

### Modifier Type Codes
- `extra` → "extras" (extra toppings, add-ons)
- `side_dish` → "side_dishes" 
- `drink` → "drinks"
- `sauce` → "sauces"
- `bread` → "bread"
- `dressing` → "dressing"
- `custom_ingredients` → "custom_ingredients"
- `cooking_method` → "cooking_method"

---

## Database Requirements

### Connection Details
- **Database**: PostgreSQL (via Supabase)
- **Schema**: `menuca_v3`
- **Connection String**: Stored in environment variable `DB_CONNECTION_STRING`
- **Database Module**: `database.py` (REUSE THIS - already built)

### Tables to Insert Into

#### Phase 1 Tables:
1. **`menuca_v3.courses`**
   ```sql
   - restaurant_id (integer, NOT NULL)
   - name (text, NOT NULL)
   - description (text, default '')
   - display_order (integer, default 0)
   - deleted_at (timestamp, NULL for active)
   ```

2. **`menuca_v3.dishes`**
   ```sql
   - restaurant_id (integer, NOT NULL)
   - course_id (integer, NOT NULL, FK to courses)
   - name (text, NOT NULL)
   - description (text, default '')
   - display_order (integer, default 0)
   - source_id (text, NULL) -- V2 dish_id
   - deleted_at (timestamp, NULL for active)
   ```

#### Phase 2 Tables:
3. **`menuca_v3.dish_prices`**
   ```sql
   - dish_id (integer, NOT NULL, FK to dishes)
   - size_variant (text, default 'standard') -- 'Small', 'Medium', 'Large', etc.
   - price (numeric(10,2), NOT NULL)
   - display_order (integer, default 0)
   - deleted_at (timestamp, NULL for active)
   ```

4. **`menuca_v3.modifier_groups`**
   ```sql
   - dish_id (integer, NOT NULL, FK to dishes)
   - name (text, NOT NULL) -- "Extras", "Side dishes", "Drinks"
   - is_required (boolean, default false)
   - min_selections (integer, default 0)
   - max_selections (integer, default 1)
   - display_order (integer, default 0)
   - deleted_at (timestamp, NULL for active)
   ```

5. **`menuca_v3.dish_modifiers`**
   ```sql
   - restaurant_id (integer, NOT NULL)
   - dish_id (integer, NOT NULL, FK to dishes)
   - modifier_group_id (integer, NOT NULL, FK to modifier_groups)
   - name (text, NOT NULL) -- "Extra Cheese", "Pepsi", "BBQ Sauce"
   - modifier_type (text, NOT NULL) -- 'extras', 'drinks', 'side_dishes', etc.
   - is_default (boolean, default false)
   - display_order (integer, default 0)
   - deleted_at (timestamp, NULL for active)
   ```

6. **`menuca_v3.dish_modifier_prices`**
   ```sql
   - dish_modifier_id (integer, NOT NULL, FK to dish_modifiers)
   - dish_id (integer, NOT NULL, FK to dishes)
   - restaurant_id (integer, NOT NULL)
   - size_variant (text, default 'standard') -- Must match dish size variants
   - price (numeric(10,2), NOT NULL)
   - display_order (integer, default 0)
   - deleted_at (timestamp, NULL for active)
   ```

### Database Helper Methods (Already Built!)

The `DatabaseManager` class in `database.py` has all the methods you need:

```python
# Phase 1 Methods
db.insert_course(restaurant_id, name, description, display_order)
db.insert_dish(restaurant_id, course_id, name, description, display_order, legacy_menu_entry_id)

# Phase 2 Methods
db.insert_dish_price(dish_id, size_variant, price, display_order)
db.insert_modifier_group(dish_id, name, is_required, min_selections, max_selections, display_order)
db.insert_dish_modifier(restaurant_id, dish_id, modifier_group_id, name, modifier_type, is_default, display_order)
db.insert_dish_modifier_price(dish_modifier_id, dish_id, restaurant_id, size_variant, price, display_order)
```

**Auto-Reconnection**: All methods call `db.ensure_connection()` automatically, so you don't need to worry about lost connections!

---

## Tools Required

### 1. **Web Scraping**
- **Playwright** (recommended) or **Selenium**
- For browser automation and JavaScript rendering
- V2 system uses Bootstrap modals that require JavaScript

### 2. **HTML Parsing**
- **BeautifulSoup4** (with `lxml` parser)
- For extracting data from HTML

### 3. **Database**
- **psycopg2** (already in use)
- PostgreSQL adapter for Python

### 4. **Progress Tracking**
- **JSON files** (standard library)
- For saving progress and enabling resume

### 5. **Logging**
- **logging module** (standard library)
- For comprehensive log files

### Installation
```bash
pip install playwright beautifulsoup4 lxml psycopg2-binary python-dotenv
playwright install chromium
```

---

## Recommended Workflow

### Step 1: Setup (30 minutes)
1. Get V2 admin credentials
2. Test manual login to `aggregator-admin.menu.ca`
3. Identify URL patterns for restaurant menus
4. Query database for V2-only restaurants:
   ```sql
   SELECT id, name, address, legacy_v2_id
   FROM menuca_v3.restaurants
   WHERE legacy_v1_id IS NULL 
     AND legacy_v2_id IS NOT NULL 
     AND deleted_at IS NULL;
   ```

### Step 2: Build Phase 1 Scraper (3-4 hours)
1. Create `v2_scraper.py` with Playwright browser automation
2. Implement login functionality
3. Navigate to restaurant menu pages
4. Extract courses and dishes from menu HTML
5. Insert using existing `DatabaseManager` methods
6. Implement progress tracking
7. Test with 2 restaurants first
8. Run full batch

### Step 3: Build Phase 2 Scraper (4-5 hours)
1. Create `v2_scraper_phase2.py`
2. Query dishes from Phase 1
3. For each dish:
   - Open dish detail modal
   - Wait for modal to load
   - Parse modifier panels
   - Extract group configurations
   - Extract modifier items and prices
4. Insert using database methods
5. Test with 2 restaurants
6. Run full batch

### Step 4: Validation (1 hour)
1. Verify all V2 restaurants have data
2. Check for completeness
3. Generate summary report

---

## Success Criteria

Your V2 scraper is complete when:
- ✅ All V2 restaurants have courses and dishes
- ✅ All dishes have at least one price
- ✅ Dishes with customization have modifier groups
- ✅ All modifier items have prices
- ✅ Data is in `menuca_v3` schema
- ✅ No duplicate data
- ✅ Progress tracking works (can resume if interrupted)
- ✅ Comprehensive logs generated

---

# PART 2: AGENT-FRIENDLY INSTRUCTIONS

## Code Architecture & Patterns

### Directory Structure
```
scraper/
├── database.py              # ✅ REUSE THIS (database manager)
├── config.py                # ✅ REUSE THIS (configuration)
├── v2_config.py             # 🆕 Create (V2-specific config)
├── v2_scraper.py            # 🆕 Create (main V2 scraper class)
├── v2_scraper_phase1.py     # 🆕 Create (courses & dishes)
├── v2_scraper_phase2.py     # 🆕 Create (prices & modifiers)
└── V2 Scrapper/             # 🆕 Create this directory
    ├── v2_restaurants.json          # List of V2 restaurants
    ├── v2_phase1_progress.json      # Phase 1 progress tracking
    ├── v2_phase1_results.json       # Phase 1 results
    ├── v2_phase2_progress.json      # Phase 2 progress tracking
    └── v2_phase2_results.json       # Phase 2 results
```

---

## Module Import Pattern

For scripts in subdirectories (like `V2 Scrapper/`):

```python
#!/usr/bin/env python3
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA
from v2_config import V2_BASE_URL, V2_USERNAME, V2_PASSWORD

# Your V2 scraper code here
```

---

## Configuration File Pattern

**File**: `v2_config.py`

```python
import os
from dotenv import load_dotenv

load_dotenv()

# V2 Admin System Configuration
V2_BASE_URL = 'https://aggregator-admin.menu.ca'
V2_USERNAME = os.getenv('V2_USERNAME', '')
V2_PASSWORD = os.getenv('V2_PASSWORD', '')

# V2 URL Patterns
V2_LOGIN_URL = f'{V2_BASE_URL}/index.php/auth/login'
V2_RESTAURANT_MENU_URL = f'{V2_BASE_URL}/index.php/restaurant_menu/restaurant/{{restaurant_id}}'
V2_DISH_MODAL_ENDPOINT = f'{V2_BASE_URL}/index.php/ajax/restaurant_menu/get_dish'

# Scraping Configuration
SCRAPE_DELAY = 2  # seconds between requests
HEADLESS = True   # run browser in headless mode
TIMEOUT = 30000   # milliseconds (30 seconds)
```

**File**: `.env` (add these lines)

```bash
# Existing V1 config
DB_CONNECTION_STRING=postgresql://user:pass@host:port/database

# New V2 config
V2_USERNAME=your_v2_username
V2_PASSWORD=your_v2_password
```

---

## Database Connection Pattern

**Use existing `DatabaseManager` from `database.py`**

```python
from database import DatabaseManager

# Initialize
db = DatabaseManager()
db.connect()

# Use insert methods (auto-reconnection built-in)
course_id = db.insert_course(restaurant_id, name, description, display_order)
dish_id = db.insert_dish(restaurant_id, course_id, name, description, display_order, source_id)

# Close when done
db.close()
```

---

## V2 Scraper Class Pattern

**File**: `v2_scraper.py`

```python
#!/usr/bin/env python3
"""
V2 Menu Scraper - Scrapes menu data from aggregator-admin.menu.ca
"""
import logging
import time
from playwright.sync_api import sync_playwright, Page, TimeoutError as PlaywrightTimeout
from bs4 import BeautifulSoup
from typing import Optional, Dict, List

logger = logging.getLogger(__name__)

class V2MenuScraper:
    """Scraper for V2 admin system (aggregator-admin.menu.ca)"""
    
    def __init__(self, base_url: str, username: str, password: str, headless: bool = True):
        self.base_url = base_url
        self.username = username
        self.password = password
        self.headless = headless
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.logged_in = False
    
    def start(self):
        """Initialize Playwright browser."""
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        logger.info("Browser started")
    
    def stop(self):
        """Close browser and cleanup."""
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
        logger.info("Browser stopped")
    
    def login(self) -> bool:
        """Login to V2 admin system."""
        try:
            logger.info("Logging in to V2 admin...")
            login_url = f"{self.base_url}/index.php/auth/login"
            
            self.page.goto(login_url)
            self.page.fill('input[name="username"]', self.username)
            self.page.fill('input[name="password"]', self.password)
            self.page.click('button[type="submit"]')
            
            # Wait for navigation after login
            self.page.wait_for_load_state('networkidle')
            
            # Check if login successful (adjust selector as needed)
            if 'dashboard' in self.page.url.lower() or 'logout' in self.page.content().lower():
                self.logged_in = True
                logger.info("Login successful")
                return True
            else:
                logger.error("Login failed")
                return False
                
        except Exception as e:
            logger.error(f"Login error: {e}")
            return False
    
    def scrape_restaurant_menu(self, v2_restaurant_id: int) -> Optional[Dict]:
        """
        Scrape courses and dishes for a V2 restaurant.
        
        Args:
            v2_restaurant_id: V2 restaurant ID (legacy_v2_id)
        
        Returns:
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
                                'v2_dish_id': '9001'
                            }
                        ]
                    }
                ]
            }
        """
        if not self.logged_in:
            logger.error("Not logged in")
            return None
        
        try:
            # Navigate to restaurant menu page
            menu_url = f"{self.base_url}/index.php/restaurant_menu/restaurant/{v2_restaurant_id}"
            logger.info(f"Navigating to: {menu_url}")
            
            self.page.goto(menu_url, wait_until='networkidle')
            time.sleep(2)  # Wait for dynamic content
            
            # Parse HTML
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract courses and dishes
            # (Implementation depends on V2 menu page HTML structure)
            courses = []
            
            # TODO: Parse V2 menu page HTML
            # Look for course sections and dish items
            # This will vary based on actual V2 HTML structure
            
            return {'courses': courses}
            
        except Exception as e:
            logger.error(f"Error scraping restaurant menu: {e}")
            return None
    
    def scrape_dish_details(self, v2_dish_id: int) -> Optional[Dict]:
        """
        Scrape prices and modifiers for a V2 dish.
        
        Args:
            v2_dish_id: V2 dish ID
        
        Returns:
            {
                'prices': [
                    {'size_variant': 'standard', 'price': 10.99, 'display_order': 0}
                ],
                'modifiers': [
                    {
                        'name': 'Extras',
                        'type_code': 'extra',
                        'is_required': False,
                        'min_selections': 1,
                        'max_selections': 5,
                        'display_order': 0,
                        'items': [
                            {
                                'name': 'Extra Cheese',
                                'prices': [2.00],
                                'display_order': 0
                            }
                        ]
                    }
                ]
            }
        """
        if not self.logged_in:
            logger.error("Not logged in")
            return None
        
        try:
            # Open dish modal (click on dish or use AJAX endpoint)
            logger.info(f"Opening dish {v2_dish_id}")
            
            # Option 1: Use AJAX endpoint
            modal_url = f"{self.base_url}/index.php/ajax/restaurant_menu/get_dish?dish_id={v2_dish_id}"
            self.page.goto(modal_url)
            
            # OR Option 2: Click on dish link to open modal
            # dish_selector = f'a[data-dish-id="{v2_dish_id}"]'
            # self.page.click(dish_selector)
            # self.page.wait_for_selector('.modal-content', state='visible')
            
            time.sleep(1)  # Wait for modal to render
            
            # Parse modal HTML
            html = self.page.content()
            soup = BeautifulSoup(html, 'lxml')
            
            # Extract prices
            prices = []
            # TODO: Parse price inputs or display
            
            # Extract modifiers
            modifiers = []
            
            # Find all modifier type panels
            modifier_panels = soup.select('.panel-group#group_dish_customization > .panel')
            
            for panel in modifier_panels:
                # Get panel type from ID (e.g., #extra, #side_dish, #drink)
                panel_id = panel.select_one('.panel-collapse')
                if not panel_id:
                    continue
                
                type_code = panel_id.get('id', '')  # 'extra', 'side_dish', 'drink', etc.
                
                # Check if this modifier type is enabled
                enabled_checkbox = soup.select_one(f'input[name="customization[{type_code}][use]"]')
                if not enabled_checkbox or not enabled_checkbox.get('checked'):
                    continue
                
                # Get configuration
                min_input = soup.select_one(f'input[name="customization[{type_code}][min]"]')
                max_input = soup.select_one(f'input[name="customization[{type_code}][max]"]')
                free_input = soup.select_one(f'input[name="customization[{type_code}][free]"]')
                display_input = soup.select_one(f'input[name="customization[{type_code}][display_order]"]')
                title_input = soup.select_one(f'input[name="customization[{type_code}][title_paid]"]')
                
                modifier_group = {
                    'name': title_input.get('value', type_code.replace('_', ' ').title()) if title_input else type_code.replace('_', ' ').title(),
                    'type_code': type_code,
                    'is_required': int(min_input.get('value', 0)) > 0 if min_input else False,
                    'min_selections': int(min_input.get('value', 0)) if min_input else 0,
                    'max_selections': int(max_input.get('value', 1)) if max_input else 1,
                    'display_order': int(display_input.get('value', 0)) if display_input else 0,
                    'items': []
                }
                
                # Find selected group (checked radio button)
                selected_group_radio = soup.select_one(f'input[name="customization[{type_code}][group]"][checked]')
                if selected_group_radio:
                    group_id = selected_group_radio.get('value')
                    
                    # Find all items in this group
                    item_inputs = soup.select(f'input[name^="item[{group_id}]"]')
                    
                    for idx, item_input in enumerate(item_inputs):
                        item_label = soup.select_one(f'label[for="{item_input.get("id")}"]')
                        item_name = item_label.get_text(strip=True) if item_label else f"Item {idx}"
                        item_price = float(item_input.get('value', 0))
                        
                        modifier_group['items'].append({
                            'name': item_name,
                            'prices': [item_price],
                            'display_order': idx,
                            'is_default': False
                        })
                
                if modifier_group['items']:
                    modifiers.append(modifier_group)
            
            return {
                'prices': prices if prices else [{'size_variant': 'standard', 'price': 0.0, 'display_order': 0}],
                'modifiers': modifiers
            }
            
        except Exception as e:
            logger.error(f"Error scraping dish details: {e}")
            return None
```

---

## Progress Tracking Pattern

```python
import json
from pathlib import Path

def load_progress(filename='v2_phase1_progress.json'):
    """Load scraping progress from file."""
    progress_file = Path(filename)
    if progress_file.exists():
        with open(progress_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {'completed': [], 'failed': [], 'skipped': []}

def save_progress(progress, filename='v2_phase1_progress.json'):
    """Save scraping progress to file."""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2)
```

---

## Phase 1 Main Script Pattern

**File**: `v2_scraper_phase1.py`

```python
#!/usr/bin/env python3
"""
V2 Restaurant Scraper - Phase 1: Courses & Dishes
"""
import sys
import os
import json
import logging
import time
from datetime import datetime

# Add parent to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager
from config import SCHEMA
from v2_config import V2_BASE_URL, V2_USERNAME, V2_PASSWORD, SCRAPE_DELAY
from v2_scraper import V2MenuScraper

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('v2_scraper_phase1.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def safe_print(text):
    """Print with Unicode error handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'ignore').decode('ascii'))

def load_progress():
    # ... (see Progress Tracking Pattern)
    pass

def save_progress(progress):
    # ... (see Progress Tracking Pattern)
    pass

def get_v2_restaurants(db):
    """Get V2-only restaurants from database."""
    query = f"""
        SELECT 
            id,
            name,
            address,
            legacy_v2_id
        FROM {SCHEMA}.restaurants
        WHERE legacy_v1_id IS NULL
          AND legacy_v2_id IS NOT NULL
          AND deleted_at IS NULL
        ORDER BY id
    """
    
    db.cursor.execute(query)
    results = db.cursor.fetchall()
    return [dict(row) for row in results]

def main():
    start_time = datetime.now()
    
    logger.info("=" * 60)
    logger.info("V2 Restaurant Scraper - Phase 1 (Courses & Dishes)")
    logger.info("=" * 60)
    
    # Initialize database
    db = DatabaseManager()
    db.connect()
    logger.info("Database connected")
    
    # Get V2 restaurants
    v2_restaurants = get_v2_restaurants(db)
    logger.info(f"Found {len(v2_restaurants)} V2 restaurants")
    
    # Save restaurant list
    with open('V2 Scrapper/v2_restaurants.json', 'w', encoding='utf-8') as f:
        json.dump(v2_restaurants, f, indent=2, ensure_ascii=False)
    
    # Load progress
    progress = load_progress('V2 Scrapper/v2_phase1_progress.json')
    completed = set(progress.get('completed', []))
    
    # Filter to process
    to_process = [r for r in v2_restaurants if r['id'] not in completed]
    logger.info(f"Remaining to process: {len(to_process)}")
    
    # Initialize scraper
    scraper = V2MenuScraper(V2_BASE_URL, V2_USERNAME, V2_PASSWORD, headless=True)
    scraper.start()
    
    # Login
    if not scraper.login():
        logger.error("Failed to login. Exiting.")
        scraper.stop()
        db.close()
        return
    
    # Track statistics
    total_courses = 0
    total_dishes = 0
    successful = 0
    
    try:
        for idx, restaurant in enumerate(to_process, 1):
            db_id = restaurant['id']
            v2_id = restaurant['legacy_v2_id']
            name = restaurant['name']
            
            logger.info(f"\n[{idx}/{len(to_process)}] Processing: {name} (DB:{db_id}, V2:{v2_id})")
            
            try:
                # Scrape menu
                menu_data = scraper.scrape_restaurant_menu(v2_id)
                
                if not menu_data or not menu_data.get('courses'):
                    logger.warning(f"No menu data for {name}")
                    progress['skipped'].append(db_id)
                    save_progress(progress, 'V2 Scrapper/v2_phase1_progress.json')
                    continue
                
                # Insert courses and dishes
                for course_data in menu_data['courses']:
                    course_id = db.insert_course(
                        restaurant_id=db_id,
                        name=course_data['name'],
                        description=course_data.get('description', ''),
                        display_order=course_data['display_order']
                    )
                    
                    if course_id:
                        total_courses += 1
                        
                        for dish_data in course_data.get('dishes', []):
                            dish_id = db.insert_dish(
                                restaurant_id=db_id,
                                course_id=course_id,
                                name=dish_data['name'],
                                description=dish_data.get('description', ''),
                                display_order=dish_data['display_order'],
                                legacy_menu_entry_id=dish_data.get('v2_dish_id')
                            )
                            
                            if dish_id:
                                total_dishes += 1
                
                logger.info(f"✓ Success: {total_courses} courses, {total_dishes} dishes inserted")
                successful += 1
                
                # Mark completed
                completed.add(db_id)
                progress['completed'] = list(completed)
                save_progress(progress, 'V2 Scrapper/v2_phase1_progress.json')
                
                # Delay between restaurants
                time.sleep(SCRAPE_DELAY)
                
            except Exception as e:
                logger.error(f"✗ Failed: {e}")
                progress['failed'].append(db_id)
                save_progress(progress, 'V2 Scrapper/v2_phase1_progress.json')
    
    finally:
        scraper.stop()
        db.close()
    
    # Summary
    duration = datetime.now() - start_time
    logger.info("\n" + "=" * 60)
    logger.info("PHASE 1 SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Duration: {duration}")
    logger.info(f"Successful: {successful}")
    logger.info(f"Failed: {len(progress['failed'])}")
    logger.info(f"Skipped: {len(progress['skipped'])}")
    logger.info(f"Total courses: {total_courses}")
    logger.info(f"Total dishes: {total_dishes}")
    logger.info("=" * 60)

if __name__ == "__main__":
    main()
```

---

## Phase 2 Main Script Pattern

**File**: `v2_scraper_phase2.py`

```python
#!/usr/bin/env python3
"""
V2 Restaurant Scraper - Phase 2: Prices & Modifiers
"""
# Similar structure to Phase 1
# Use get_dishes_to_process() to query dishes from Phase 1
# Use scraper.scrape_dish_details() for each dish
# Insert prices and modifiers using database methods
# Follow same progress tracking and error handling patterns
```

---

## Modifier Type Mapping

```python
# Map V2 type codes to menuca_v3 modifier types
MODIFIER_TYPE_MAPPING = {
    'extra': 'extras',
    'side_dish': 'side_dishes',
    'drink': 'drinks',
    'sauce': 'sauces',
    'bread': 'bread',
    'dressing': 'dressing',
    'custom_ingredients': 'custom_ingredients',
    'cooking_method': 'cooking_method'
}
```

---

## Error Handling Pattern

```python
try:
    # Scraping operation
    data = scraper.scrape_restaurant_menu(v2_id)
    
    # Database operation
    db.insert_course(data)
    
    # Mark success
    progress['completed'].append(id)
    
except PlaywrightTimeout as e:
    logger.error(f"Timeout error: {e}")
    progress['failed'].append(id)
    
except ValueError as e:
    logger.error(f"Data validation error: {e}")
    progress['skipped'].append(id)
    
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    progress['failed'].append(id)
    import traceback
    traceback.print_exc()
    
finally:
    # Always save progress
    save_progress(progress)
```

---

## Testing Pattern

```python
# Test with 2 restaurants first
v2_restaurants = get_v2_restaurants(db)
to_process = v2_restaurants[:2]  # Test with 2

# After confirming success, process all
to_process = v2_restaurants  # All restaurants
```

---

## Key Guidelines & Parameters

### Scraping
- **Delay**: 2 seconds between requests
- **Timeout**: 30 seconds for page loads
- **Headless**: Run browser in headless mode (can disable for debugging)
- **Authentication**: Login once per session
- **Error Handling**: Log all errors, don't crash on single failure

### Database
- **Schema**: `menuca_v3`
- **Connection**: Use `DatabaseManager` class
- **Auto-reconnection**: Built-in via `ensure_connection()`
- **Transaction**: Auto-commit after each insert

### Progress Tracking
- **Save after each item**: Don't lose progress on crash
- **Three lists**: `completed`, `failed`, `skipped`
- **JSON format**: Easy to read and debug
- **Resume capability**: Check completed list before processing

### Logging
- **Level**: INFO for normal, WARNING for skips, ERROR for failures
- **Format**: Timestamp, level, message
- **Output**: Both file and console
- **Encoding**: UTF-8 for international characters

---

## Success Checklist

Before considering V2 scraper complete:

- [ ] V2 credentials obtained and tested
- [ ] Phase 1 script created and tested
- [ ] Phase 2 script created and tested
- [ ] All V2 restaurants have courses and dishes
- [ ] All dishes have prices
- [ ] Modifiers inserted for applicable dishes
- [ ] Progress tracking works (can resume)
- [ ] Logging is comprehensive
- [ ] Error handling is robust
- [ ] Reconnection system verified (inherited from DatabaseManager)
- [ ] Summary report generated
- [ ] Documentation updated

---

## Environment Variables Required

```bash
# .env file
DB_CONNECTION_STRING=postgresql://user:pass@host:port/database

# V2-specific
V2_USERNAME=your_v2_admin_username
V2_PASSWORD=your_v2_admin_password
```

---

**Questions? Check `database.py` for reusable database methods, or examine the V1 scraper patterns in `List 4 Scrapper/` for reference!**

**Good luck, Brian! 🚀**
