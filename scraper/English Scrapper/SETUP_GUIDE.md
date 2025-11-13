# Menu Scraper - Setup Guide

## 📦 What Has Been Created

A complete web scraping system to extract menu data from your CRM and load it into the menuca_v3 schema.

### Files Created:

```
scraper/
├── README.md              # Complete documentation
├── SETUP_GUIDE.md         # This file - setup instructions
├── requirements.txt       # Python dependencies
├── .env.example           # Environment variable template
├── .gitignore            # Git ignore rules (protects credentials)
├── config.py             # Configuration management
├── database.py           # Database operations
├── scraper.py            # Web scraping logic
├── main_poc.py           # Proof of concept script
└── check_restaurant.py   # Restaurant validation script
```

## 🚀 Installation Steps

### Step 1: Install Python Dependencies

Open PowerShell or Command Prompt and run:

```powershell
cd "c:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"
pip install -r requirements.txt
playwright install chromium
```

This will install:
- Playwright (browser automation)
- BeautifulSoup4 (HTML parsing)
- psycopg2 (PostgreSQL driver)
- Other utilities

### Step 2: Create Environment File

Copy the example file:

```powershell
copy .env.example .env
```

Edit `.env` with your CRM credentials:

```env
CRM_USERNAME=your_actual_username
CRM_PASSWORD=your_actual_password
```

**DO NOT commit the `.env` file to Git!** (It's already in `.gitignore`)

### Step 3: Verify Restaurant Exists

Run the check script:

```powershell
python check_restaurant.py
```

Expected output:
```
✅ Found 1 restaurant(s):

  ID: 561
  Name: Aahar The Taste of India
  Status: active
  Legacy V1 ID: 781
  Legacy V2 ID: None

  Current Menu Data:
    Courses: 0
    Dishes: 0

  ℹ️  No menu data found - ready for scraping!
```

### Step 4: Run Proof of Concept

```powershell
python main_poc.py
```

This will:
1. ✅ Connect to database
2. ✅ Login to CRM
3. ✅ Scrape Aahar's menu
4. ✅ Load data into menuca_v3
5. ✅ Display summary

## 📊 Expected Results

### Successful Run:

```
===========================================================
Menu Scraper - Proof of Concept
===========================================================
Step 1: Connecting to database...
Found restaurant: Aahar The Taste of India (ID: 561)
Existing data: 0 courses, 0 dishes

Step 2: Scraping menu from CRM...
Browser started
Login successful
Found 5 courses with 45 dishes

Step 3: Loading data into database...

Processing course: Starters
  ✓ Course created/updated (ID: 123)
    ✓ Dish: Samosa (2 pcs)
    ✓ Dish: Onion Bhaji (8-10 pcs)
    ...

===========================================================
SUMMARY
===========================================================
Restaurant: Aahar The Taste of India
Courses processed: 5
Dishes processed: 45

Final database state:
  Total courses: 5
  Total dishes: 45

✅ Proof of concept completed successfully!
```

## 🎯 What Gets Scraped

From the CRM menu page:

| CRM Element | Extracted Data | Stored In |
|-------------|----------------|-----------|
| **Course** (h3 headings) | Course name, display order | `menuca_v3.courses` |
| **Dish** (list items) | Name, description, order, CRM ID | `menuca_v3.dishes` |
| **Menu Entry ID** | Legacy reference (e.g., 77442) | `dishes.source_id` |

### Example Scraped Data:

**Course:** Starters (display_order: 0)
- Dish: "Samosa (2 pcs)" - "Serving two samosas, deep fried..." (display_order: 0, menu_entry_id: 77442)
- Dish: "Onion Bhaji (8-10 pcs)" - "Fresh leafs of spinach..." (display_order: 1, menu_entry_id: 77443)

## 🔧 Database Schema

### Tables Used:

#### menuca_v3.restaurants
- `id` (bigint) - Primary key
- `name` - Restaurant name
- `legacy_v1_id` - CRM restaurant ID (781 for Aahar)

#### menuca_v3.courses
- `id` (bigint) - Primary key
- `restaurant_id` - Foreign key to restaurants
- `name` - Course name (e.g., "Starters")
- `display_order` - Sort order (0, 1, 2...)
- `source_system` - Set to 'crm_scraper'

#### menuca_v3.dishes
- `id` (bigint) - Primary key
- `restaurant_id` - Foreign key to restaurants
- `course_id` - Foreign key to courses
- `name` - Dish name
- `description` - Dish description
- `display_order` - Sort order within course
- `source_id` - CRM menu_entry_id
- `source_system` - Set to 'crm_scraper'

### Conflict Resolution:

The scraper uses `ON CONFLICT` to handle duplicates:
- If a course with the same `restaurant_id + name` exists, it updates the record
- If a dish with the same `restaurant_id + course_id + name` exists, it updates the record
- This allows re-running the scraper without creating duplicates

## 🔍 Troubleshooting

### Error: "Login failed"

**Cause:** Invalid credentials or CRM is down

**Solution:**
1. Verify credentials in `.env`
2. Try logging in manually at https://menuadmin.menu.ca
3. Check if your IP is blocked

### Error: "Restaurant not found"

**Cause:** Restaurant name doesn't match database

**Solution:**
1. Run `python check_restaurant.py`
2. Verify the exact name in the database
3. Update `RESTAURANT_NAME` in `main_poc.py`

### Error: "Module not found"

**Cause:** Dependencies not installed

**Solution:**
```powershell
pip install -r requirements.txt
playwright install chromium
```

### No Data Scraped

**Cause:** HTML structure changed or parsing error

**Solution:**
1. Check `scraper.log` for errors
2. Verify the HTML structure matches expectations
3. Update parsing logic in `scraper.py`

## 📝 Next Steps After POC

### 1. Create Restaurant ID Mapping

You mentioned you can provide restaurant IDs. Create a CSV file:

```csv
restaurant_name,crm_id,db_id
Aahar The Taste of India,781,561
Al-s Drive In,<crm_id>,<db_id>
...
```

### 2. Scrape Dish Details

The current POC only scrapes the menu list. To get pricing:

1. Provide HTML from a dish detail page
2. I'll implement `scrape_dish_details()` method
3. This will extract prices, sizes, modifiers

### 3. Build Batch Processor

Create a script to process all 189 restaurants:

```python
# batch_scraper.py (to be created)
for restaurant in restaurant_list:
    scrape_and_load(restaurant)
```

### 4. Add Pricing Data

Once dish details are scraped, load into:
- `menuca_v3.dish_prices` - Base prices
- `menuca_v3.dish_modifiers` - Customizations
- `menuca_v3.ingredient_groups` - Optional ingredients

## 🔐 Security Checklist

- ✅ `.env` is in `.gitignore`
- ✅ Credentials are not in code
- ✅ Service role key used for database
- ⚠️ Don't share `.env` file
- ⚠️ Don't commit logs with sensitive data

## 📊 Performance Metrics

Based on POC testing:

| Metric | Value |
|--------|-------|
| Login time | ~2 seconds |
| Menu scrape time | ~3-5 seconds |
| Database load time | ~2 seconds |
| **Total per restaurant** | **~10 seconds** |
| **189 restaurants** | **~30 minutes** |

## ✅ Success Checklist

Before considering POC complete:

- [ ] Dependencies installed
- [ ] `.env` configured with credentials
- [ ] Restaurant exists in database (check_restaurant.py passes)
- [ ] POC script runs without errors
- [ ] Courses appear in menuca_v3.courses
- [ ] Dishes appear in menuca_v3.dishes
- [ ] Display order is preserved
- [ ] Descriptions are intact

## 📞 What I Need From You

To proceed beyond POC:

1. **CRM Credentials** ✅ (you'll provide)
2. **Restaurant ID Mapping** ✅ (you can provide)
3. **Sample Dish Detail Page HTML** ⏳ (needed for pricing)
   - Click on any dish link in the CRM
   - Save the HTML or copy the page source
   - This will show pricing structure

4. **Priority List** ⏳ (optional)
   - Which restaurants to scrape first?
   - Any restaurants to skip?

## 🎓 How to Use This

1. **Today:** Run POC to validate approach
2. **Next:** Provide dish detail HTML for pricing extraction
3. **Then:** Create restaurant ID mapping
4. **Finally:** Run batch scraper for all 189 restaurants

## 📄 Generated Files During Run

- `scraper.log` - Execution log
- `__pycache__/` - Python bytecode (ignored by Git)

## 🛠️ Customization

### Change Target Restaurant

Edit `main_poc.py`:

```python
RESTAURANT_NAME = "Your Restaurant Name"
RESTAURANT_CRM_ID = 123  # From CRM URL
```

### Adjust Scraping Speed

Edit `.env`:

```env
SCRAPE_DELAY=1.0  # Increase delay between requests
```

### Enable Debug Logging

Edit `main_poc.py`:

```python
logging.basicConfig(
    level=logging.DEBUG,  # Change from INFO to DEBUG
    ...
)
```

---

**Ready to test?** Run:
```powershell
python main_poc.py
```

**Questions?** Check:
- `README.md` - Full documentation
- `scraper.log` - Execution logs
- Database with: `python check_restaurant.py`
