# Quick Start: Prices & Modifiers Scraper

## 🎯 What Was Built

An enhanced scraper that extracts **dish prices** and **modifiers/customizations** from the CRM dish detail pages and populates the menuca_v3 database.

### Files Created/Modified:
1. ✅ `scraper.py` - Added price & modifier extraction methods
2. ✅ `database.py` - Added insert methods for prices & modifiers
3. ✅ `batch_scrape_prices_modifiers.py` - Batch processor for all dishes
4. ✅ `test_prices_modifiers_poc.py` - POC test script
5. ✅ `PRICES_MODIFIERS_IMPLEMENTATION.md` - Complete documentation

---

## 🚀 Quick Start

### Step 1: Test POC (5 minutes)

Test with Carlo's Pizza - Pepperoni Pizza:

```bash
cd "c:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\scraper"
python test_prices_modifiers_poc.py
```

**What It Tests:**
- Connects to database ✓
- Finds test dish (Pepperoni Pizza) ✓
- Scrapes detail page ✓
- Extracts 3 prices (Small, Medium, Large) ✓
- Extracts 3+ modifier groups (Crust, Toppings, Dips) ✓
- Inserts into database ✓
- Verifies insertion ✓

**Expected Success:**
```
✅ POC test completed successfully!
```

### Step 2: Run Batch Scraper

Once POC passes, process all ~19,000 dishes:

```bash
python batch_scrape_prices_modifiers.py
```

**Runtime:** ~5-8 hours  
**Dishes:** ~19,000  
**Rate Limiting:** 1 second per dish

**Progress Tracking:**
- `prices_modifiers_progress.json` - Resume state
- `prices_modifiers_results.json` - Detailed results
- `batch_scrape_prices_modifiers.log` - Full log

**Resume:** If interrupted, just run again - it will continue where it left off.

---

## ⚠️ Known Issue: ingredient_id

The `dish_modifiers` table requires `ingredient_id` (NOT NULL), but we don't have ingredient data from scraping.

**Current Solution:** Hardcoded to `ingredient_id = 1`

**Potential Problem:** May fail if ingredient ID 1 doesn't exist.

**If You Get Errors:**

```sql
-- Check if ingredient ID 1 exists
SELECT * FROM menuca_v3.ingredients WHERE id = 1;

-- If not, create a placeholder:
INSERT INTO menuca_v3.ingredients (id, name, restaurant_id)
VALUES (1, 'Unknown Ingredient', 1)
ON CONFLICT (id) DO NOTHING;
```

OR

```sql
-- Make ingredient_id nullable (database change):
ALTER TABLE menuca_v3.dish_modifiers 
ALTER COLUMN ingredient_id DROP NOT NULL;
```

---

## 📊 What Gets Scraped

### Example: Pepperoni Pizza (Carlo's Pizza)

#### Prices:
- Small: $16.80
- Medium: $26.90
- Large: $31.55

#### Modifiers:
1. **Crust Type** (Required, choose 1)
   - Regular Crust: $0.00
   - Thick Crust: $0.00
   - Thin Crust: $0.00
   - Gluten Free Crust: $5.00

2. **Add more toppings** (Optional, choose 0+)
   - Pepperoni: $3.00
   - Green Peppers: $3.00
   - Mushrooms: $3.00
   - ... and 12 more items

3. **Dips** (Optional, choose 0+)
   - Creamy Garlic: $2.50
   - Ranch: $2.50
   - Marinara: $2.50

---

## 🔍 Verify Results

### Check Prices for Carlo's Pizza:
```sql
SELECT 
    d.name,
    dp.size_variant,
    dp.price
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
WHERE d.restaurant_id = 124
ORDER BY d.name, dp.display_order;
```

### Check Modifiers:
```sql
SELECT 
    d.name as dish,
    mg.name as group_name,
    COUNT(dm.id) as items
FROM menuca_v3.dishes d
JOIN menuca_v3.modifier_groups mg ON d.id = mg.dish_id
JOIN menuca_v3.dish_modifiers dm ON mg.id = dm.modifier_group_id
WHERE d.restaurant_id = 124
GROUP BY d.name, mg.name;
```

### Summary Stats:
```sql
SELECT 
    (SELECT COUNT(*) FROM menuca_v3.dish_prices) as prices,
    (SELECT COUNT(*) FROM menuca_v3.modifier_groups) as groups,
    (SELECT COUNT(*) FROM menuca_v3.dish_modifiers) as items;
```

---

## 🐛 Troubleshooting

### Error: "dish_modifiers_dish_id_ingredient_id_fkey"
**Cause:** ingredient_id = 1 doesn't exist

**Fix:** Create placeholder ingredient or make column nullable (see above)

### Error: "No details scraped"
**Cause:** Dish might not have a detail page or menu_entry_id is incorrect

**Fix:** Check if dish exists in CRM, verify source_id is correct

### Error: "Login failed"
**Cause:** CRM credentials issue

**Fix:** Verify credentials in `.env` file, check CRM accessibility

### Slow Performance
**Cause:** Rate limiting (1 second per dish)

**Fix:** Adjust `DELAY_BETWEEN_DISHES` in `batch_scrape_prices_modifiers.py` (line 23)

---

## 📈 Expected Results

### For 139 Restaurants (~19,000 dishes):

| Metric | Estimate |
|--------|----------|
| Runtime | 5-8 hours |
| Prices | ~30,000-40,000 |
| Modifier Groups | ~50,000-80,000 |
| Modifier Items | ~200,000-500,000 |

### Per Restaurant Average:
- ~137 dishes
- ~2-3 prices per dish
- ~2-4 modifier groups per dish
- ~10-20 items per group

---

## ✅ Success Criteria

POC is successful if:
- ✅ No errors in console
- ✅ Prices inserted (3 for Pepperoni Pizza)
- ✅ Modifier groups inserted (3+)
- ✅ Modifier items inserted (15+)
- ✅ Database queries return data

Batch scrape is successful if:
- ✅ All ~19,000 dishes processed
- ✅ ~30,000+ prices inserted
- ✅ ~50,000+ modifier groups inserted
- ✅ No critical errors
- ✅ Data quality validation passes

---

## 🔄 Re-running

Safe to run multiple times:
- Manual upsert logic (no duplicates)
- Updates existing records
- Progress tracking with resume

To start fresh:
```bash
rm prices_modifiers_progress.json
python batch_scrape_prices_modifiers.py
```

---

## 📚 Full Documentation

See `PRICES_MODIFIERS_IMPLEMENTATION.md` for:
- Complete technical details
- Database schema
- Known limitations
- Verification queries
- Troubleshooting guide

---

## 🎉 You're Ready!

1. Run POC: `python test_prices_modifiers_poc.py`
2. Verify results in database
3. Run batch: `python batch_scrape_prices_modifiers.py`
4. Monitor progress in logs
5. Validate final data

**Good luck!** 🚀

