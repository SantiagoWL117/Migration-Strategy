# Menu CRM Scraper

A Python-based web scraper to extract menu data from the legacy CRM (menuadmin.menu.ca) and load it into the menuca_v3 PostgreSQL schema.

## 🎯 Purpose

Extract menu data (courses and dishes) for 189 active restaurants from the CRM and populate the menuca_v3 schema in Supabase.

## 📋 Prerequisites

- Python 3.9+
- PostgreSQL client (psql)
- CRM login credentials
- Supabase access (already configured)

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd scraper
pip install -r requirements.txt
playwright install chromium
```

### 2. Configure Environment

Copy the example environment file and fill in your CRM credentials:

```bash
copy .env.example .env
```

Edit `.env` and set:
- `CRM_USERNAME` - Your menuadmin.menu.ca username
- `CRM_PASSWORD` - Your menuadmin.menu.ca password

### 3. Run Proof of Concept

Test the scraper with a single restaurant (Aahar):

```bash
python main_poc.py
```

This will:
1. Connect to the database
2. Login to the CRM
3. Scrape the menu for restaurant ID 781 (Aahar)
4. Load courses and dishes into menuca_v3 schema
5. Display a summary

## 📁 Project Structure

```
scraper/
├── config.py           # Configuration settings
├── database.py         # Database operations
├── scraper.py          # Web scraping logic
├── main_poc.py         # Proof of concept script
├── requirements.txt    # Python dependencies
├── .env.example        # Environment template
├── .env                # Your credentials (DO NOT COMMIT)
└── README.md           # This file
```

## 🗄️ Database Schema Mapping

### CRM → menuca_v3

| CRM Element | Database Table | Key Fields |
|-------------|----------------|------------|
| Course (h3) | `menuca_v3.courses` | `restaurant_id`, `name`, `display_order` |
| Dish (li) | `menuca_v3.dishes` | `restaurant_id`, `course_id`, `name`, `display_order` |
| Menu Entry ID | `menuca_v3.dishes.source_id` | Legacy reference |

## 🔧 Components

### `scraper.py`
- Browser automation with Playwright
- HTML parsing with BeautifulSoup
- Session management and authentication
- Menu structure extraction

### `database.py`
- PostgreSQL connection management
- CRUD operations for courses and dishes
- Conflict resolution (upserts)
- Data validation

### `config.py`
- Environment variable management
- URL patterns
- Configuration constants

## 📊 Scraped Data Structure

```python
{
    'restaurant_id': 781,
    'courses': [
        {
            'name': 'Starters',
            'description': '',
            'display_order': 0,
            'dishes': [
                {
                    'name': 'Samosa (2 pcs)',
                    'description': 'Serving two samosas...',
                    'display_order': 0,
                    'menu_entry_id': 77442
                }
            ]
        }
    ]
}
```

## 🔐 Authentication

The scraper uses Playwright to:
1. Navigate to menuadmin.menu.ca
2. Fill in login form
3. Submit credentials
4. Maintain session for subsequent requests

## ⚙️ Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `SCRAPE_DELAY` | 0.5 | Delay between requests (seconds) |
| `MAX_RETRIES` | 3 | Maximum retry attempts |
| `BATCH_SIZE` | 10 | Restaurants per batch |

## 📝 Logging

Logs are written to:
- Console (stdout)
- `scraper.log` file

Log levels:
- INFO: Progress and status updates
- ERROR: Failures and exceptions
- DEBUG: Detailed execution trace (if enabled)

## 🚦 Next Steps

After POC validation:

1. **Create Restaurant ID Mapping**
   - Map restaurant names to CRM IDs
   - Store in CSV or database table

2. **Implement Detail Page Scraping**
   - Extract pricing information
   - Parse modifiers/customizations
   - Handle ingredient groups

3. **Build Batch Processor**
   - Process all 189 restaurants
   - Resume capability for failed runs
   - Progress tracking

4. **Add Validation**
   - Verify data completeness
   - Check for missing prices
   - Validate course/dish counts

## 🐛 Troubleshooting

### Login Failed
- Verify credentials in `.env`
- Check if CRM is accessible
- Ensure login form selectors are correct

### Database Connection Failed
- Verify Supabase credentials
- Check network connectivity
- Ensure PostgreSQL client is installed

### No Data Scraped
- Check restaurant ID is correct
- Verify HTML structure hasn't changed
- Review logs for parsing errors

## 📚 Dependencies

- `playwright` - Browser automation
- `beautifulsoup4` - HTML parsing
- `psycopg2` - PostgreSQL adapter
- `python-dotenv` - Environment management

## 🔒 Security Notes

- **Never commit `.env` file**
- Keep credentials secure
- Use service role key for database operations
- Implement rate limiting for production

## 📈 Performance

- POC processes ~25 dishes in ~10 seconds
- Full 189 restaurants: ~30-60 minutes (estimated)
- Headless browser mode for efficiency
- Parallel processing possible (future enhancement)

## ✅ Success Criteria

POC is successful if:
- [x] Connects to CRM successfully
- [x] Extracts all courses and dishes
- [x] Loads data into menuca_v3 schema
- [x] Maintains correct display order
- [x] Handles conflicts gracefully

## 📞 Support

Issues or questions? Check:
1. Log files (`scraper.log`)
2. Database connection string
3. CRM accessibility
4. HTML structure changes
