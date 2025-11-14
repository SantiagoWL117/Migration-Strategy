# V2 Restaurant Scraper - Complete Handoff Package

**For**: Brian's Team  
**Last Updated**: November 13, 2025  
**Status**: Ready for Implementation

---

## 📦 Package Contents

This folder contains everything needed to build the V2 restaurant scraper:

### 1. **Main Documentation**

#### `V2_SCRAPER_HANDOFF.md` ⭐ (Main Guide)
- **Part 1**: Human-friendly explanation of the project
- **Part 2**: Complete technical implementation guide with:
  - Full `V2MenuScraper` class implementation
  - Phase 1 and Phase 2 script templates
  - Database connection patterns
  - Progress tracking systems
  - Error handling patterns

#### `V2_PHASE1_HTML_STRUCTURE.md` 🔍 (Phase 1 Details)
- Complete HTML structure breakdown for V2 system
- Step-by-step parsing instructions with examples
- BeautifulSoup code snippets
- URL patterns and navigation flows
- Size/price relationship explanations

#### `V2_SCRAPER_QUICK_START.md` 🚀 (Quick Reference)
- Pre-flight checklist
- 5-step quick start guide
- Copy-paste code snippets
- Common issues and solutions

#### `HANDOFF_PACKAGE_SUMMARY.md` 📋 (Overview)
- Package inventory
- What's provided vs. what needs building
- Success criteria
- File map

### 2. **Reference Materials**

#### `prompt.txt` (HTML Examples)
- Real V2 HTML markup examples
- Phase 1: Course and dish table structure
- Phase 2: Modifier modal structure

---

## 🎯 Quick Start

### For Humans (Product Owners/Managers)
1. Read `V2_SCRAPER_HANDOFF.md` Part 1 (lines 1-250)
2. Understand the 2-phase approach
3. Review success criteria
4. Estimated timeline: 1-2 days

### For AI Agents (Claude, GPT, etc.)
1. Read `V2_SCRAPER_HANDOFF.md` Part 2 (lines 250+)
2. Read `V2_PHASE1_HTML_STRUCTURE.md` for Phase 1 details
3. Follow the code templates provided
4. All patterns are production-tested from V1 scrapers

### For Human Developers
1. Start with `V2_SCRAPER_QUICK_START.md`
2. Reference `V2_PHASE1_HTML_STRUCTURE.md` while coding Phase 1
3. Reference `V2_SCRAPER_HANDOFF.md` for Phase 2 and patterns
4. Use `prompt.txt` to understand HTML structure

---

## 📊 Data Flow

```
V2 Admin System (aggregator-admin.menu.ca)
    ↓
Phase 1: Scrape Courses & Dishes
    → Parse HTML from menu pages
    → Extract course names, dish names, descriptions, sizes, prices
    → Insert into menuca_v3:
        - courses (restaurant_id, name, description, display_order)
        - dishes (restaurant_id, course_id, name, description, source_id, display_order)
        - dish_prices (dish_id, size_variant, price, display_order)
    ↓
Phase 2: Scrape Modifiers
    → For each dish, open edit modal
    → Extract modifier groups and items
    → Insert into menuca_v3:
        - modifier_groups (dish_id, name, min/max selections, display_order)
        - dish_modifiers (dish_id, modifier_group_id, name, modifier_type, display_order)
        - dish_modifier_prices (dish_modifier_id, size_variant, price, display_order)
    ↓
Complete V2 Menu Data in menuca_v3
```

---

## 🛠️ Tools & Technologies

### Required
- **Python 3.8+**
- **Playwright** (browser automation)
- **BeautifulSoup4** (HTML parsing)
- **psycopg2** (PostgreSQL driver)
- **python-dotenv** (environment variables)

### Installation
```bash
pip install playwright beautifulsoup4 lxml psycopg2-binary python-dotenv
playwright install chromium
```

### Reusable (Already Built)
- `database.py` - DatabaseManager with all insert methods ✅
- `config.py` - Configuration patterns ✅
- Auto-reconnection system ✅
- Progress tracking patterns ✅

---

## 🗂️ Database Schema

### menuca_v3 Tables

**Phase 1 Tables**:
- `courses` (restaurant_id, name, description, display_order)
- `dishes` (restaurant_id, course_id, name, description, source_id, display_order)
- `dish_prices` (dish_id, size_variant, price, display_order)

**Phase 2 Tables**:
- `modifier_groups` (dish_id, name, is_required, min_selections, max_selections, display_order)
- `dish_modifiers` (restaurant_id, dish_id, modifier_group_id, name, modifier_type, is_default, display_order)
- `dish_modifier_prices` (dish_modifier_id, dish_id, restaurant_id, size_variant, price, display_order)

All tables have:
- Auto-incrementing `id` (primary key)
- `created_at` timestamp
- `updated_at` timestamp
- `deleted_at` timestamp (soft delete)

---

## ✅ Implementation Checklist

### Pre-Development
- [ ] V2 admin credentials obtained
- [ ] Manual login tested: `https://aggregator-admin.menu.ca`
- [ ] Database connection string configured in `.env`
- [ ] V2 restaurant count queried from database

### Phase 1 Development
- [ ] `v2_config.py` created with V2 URLs and credentials
- [ ] `v2_scraper.py` created with `V2MenuScraper` class
- [ ] Login functionality tested
- [ ] `scrape_restaurant_menu()` method implemented
- [ ] English/French menu detection working
- [ ] Course parsing working
- [ ] Dish parsing working (name, description, sizes, prices)
- [ ] `v2_scraper_phase1.py` main script created
- [ ] Progress tracking implemented
- [ ] Tested with 2 restaurants successfully
- [ ] Full Phase 1 batch run completed

### Phase 1 Verification
- [ ] All V2 restaurants have courses in database
- [ ] All V2 restaurants have dishes in database
- [ ] All dishes have prices in database
- [ ] `source_id` column populated with V2 dish IDs
- [ ] Summary report generated

### Phase 2 Development
- [ ] `scrape_dish_details()` method implemented
- [ ] Modifier modal parsing working
- [ ] Modifier group extraction working
- [ ] Modifier item extraction working
- [ ] Modifier prices extraction working
- [ ] `v2_scraper_phase2.py` main script created
- [ ] Progress tracking implemented
- [ ] Tested with 2 restaurants successfully
- [ ] Full Phase 2 batch run completed

### Phase 2 Verification
- [ ] All dishes with customization have modifier groups
- [ ] All modifier items have prices
- [ ] Modifier prices match dish size variants
- [ ] Summary report generated

### Final Verification
- [ ] All V2 restaurants have complete menu data
- [ ] No duplicate data
- [ ] Progress tracking works (resume capability)
- [ ] Logs are comprehensive
- [ ] Documentation updated
- [ ] Handoff complete

---

## 🚨 Critical Notes

### 1. V2 Restaurant Identification
Query V2 restaurants:
```sql
SELECT id, name, address, legacy_v2_id
FROM menuca_v3.restaurants
WHERE legacy_v1_id IS NULL
  AND legacy_v2_id IS NOT NULL
  AND deleted_at IS NULL;
```

### 2. English vs French Menus
- **Check**: `<div id="sortable">` exists = English
- **If not**: Navigate to `.../menu/2/restaurant` for French

### 3. Size Variants & Prices
- **Format**: Comma-separated strings in HTML
- **Parse**: Split and zip together
- **Example**: `sizes="Poulet,Boeuf,Mixte"` + `prices="12.98,12.98,13.69"`
  - Result: 3 price records with different size_variants

### 4. V2 Dish ID Storage
- **Critical**: Store V2 dish ID in `dishes.source_id` column
- **Why**: Phase 2 needs this to re-identify dishes

### 5. Database Reconnection
- **Built-in**: `DatabaseManager.ensure_connection()` automatically handles reconnections
- **Called**: Before every insert operation
- **No action needed**: Just use the existing methods

---

## 📞 Support & Questions

**Reference Files**:
- Phase 1 HTML details → `V2_PHASE1_HTML_STRUCTURE.md`
- Database methods → `database.py` in parent directory
- V1 scraper patterns → `../List 4 Scrapper/` directory
- Reconnection system → `../List 4 Scrapper/RECONNECTION_SYSTEM_VERIFIED.md`

**Key Patterns**:
- Module imports → See "Module Import Pattern" in handoff
- Progress tracking → See "Progress Tracking Pattern" in handoff
- Error handling → See "Error Handling Pattern" in handoff
- Logging setup → See "Logging Pattern" in handoff

---

## 🎉 Success Criteria

V2 scraper is **COMPLETE** when:

1. ✅ All V2 restaurants identified and processed
2. ✅ All courses and dishes inserted (Phase 1)
3. ✅ All prices inserted with correct size variants (Phase 1)
4. ✅ All modifier groups and items inserted (Phase 2)
5. ✅ All modifier prices inserted per size variant (Phase 2)
6. ✅ Progress tracking works (can resume after crash)
7. ✅ Comprehensive logs generated
8. ✅ Summary reports created
9. ✅ No duplicate data
10. ✅ Data validated in database

---

## 📈 Expected Results

Based on V1 scraper performance:

- **V1 Stats**: 65 restaurants, 1,112 courses, 8,746 dishes
- **V2 Expected**: TBD (query database for count)
- **Phase 1 Duration**: 1-2 hours (depends on restaurant count)
- **Phase 2 Duration**: 2-4 hours (depends on dish count)
- **Success Rate**: 95%+ (based on V1 experience)

---

**Package is READY for implementation! 🚀**

**Last Verified**: November 13, 2025  
**Version**: 1.0

