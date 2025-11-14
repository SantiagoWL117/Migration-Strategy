# Restaurant 949 - COMPLETE ✅

**Restaurant**: All Out Burger - 585 Montreal Road  
**Database ID**: 949  
**CRM ID (legacy_v1_id)**: 1071  
**Date Completed**: November 14, 2025

---

## Summary

Both Phase 1 and Phase 2 have been successfully completed for Restaurant 949!

---

## Phase 1: Courses & Dishes ✅

### Results:
- **14 courses** scraped and inserted
- **111 dishes** scraped and inserted
- All dishes have `source_id` stored for Phase 2 scraping

### Courses:
1. Specials (4 dishes)
2. Appetizers (13 dishes)
3. Our New Creations SOLO (5 dishes)
4. Our New Creations COMBO (5 dishes)
5. Burgers SOLO (18 dishes)
6. Burger COMBOS (18 dishes)
7. Hot Dogs (3 dishes)
8. Salads (2 dishes)
9. Chicken (8 dishes)
10. Poutine (6 dishes)
11. Kids Menu (2 dishes)
12. Mini Donuts Hot and Fresh Made (4 dishes)
13. Cake by Slice (10 dishes)
14. Drinks (13 dishes)

---

## Phase 2: Prices & Modifiers ✅

### Results:
- **111/111 dishes** processed successfully
- **0 failures**
- **136 prices** inserted
- **130 modifier groups** inserted
- **736 modifier items** inserted
- **736 modifier prices** inserted

### Breakdown by Data Type:

#### Prices:
- 111 dishes have at least one price
- Some dishes have multiple prices for different sizes (Small, Medium, Large)
- Total: 136 price entries

#### Modifiers:
- **130 modifier groups** across 52 dishes
- **736 modifier items** with their respective prices
- Modifier types include:
  - Drinks (e.g., "2 Drinks" for combo meals)
  - Side Dishes (e.g., "Side Dishes for COMBOS")
  - Extras (e.g., "Burgers EXTRAS", "Extras for Salads")
  - Bread (e.g., "Burgers Bun Selection")
  - Sauces (e.g., "Wings Sauces")
  - Custom Ingredients (e.g., "Ramadan Special Burger Selection")

---

## Technical Details

### Phase 1 Files:
- `scraper/scrape_949_phase1.py` - Phase 1 scraper
- `scraper/config.py` - Configuration file
- `scraper/scraper.py` - Base scraper class
- `scraper/database.py` - Database manager

### Phase 2 Files:
- `scraper/scrape_949_phase2.py` - Phase 2 scraper

### Key Fixes Applied:
1. **Modifier Type Mapping**: Fixed CHECK constraint violation by using correct plural forms:
   - `custom_ingredients` (not `custom_ingredient`)
   - `extras` (not `extra`)
   - `side_dishes` (not `side_dish`)
   - `drinks` (not `drink`)
   - `sauces` (not `sauce`)

2. **CRM ID Mapping**: Used CRM ID 1071 (not database ID 949) for scraping

### Database Tables Populated:
- ✅ `menuca_v3.courses` (14 rows)
- ✅ `menuca_v3.dishes` (111 rows)
- ✅ `menuca_v3.dish_prices` (136 rows)
- ✅ `menuca_v3.modifier_groups` (130 rows)
- ✅ `menuca_v3.dish_modifiers` (736 rows)
- ✅ `menuca_v3.dish_modifier_prices` (736 rows)

---

## Verification

### Final Database Counts:
```sql
Total Dishes:           111
Dishes with Prices:     111
Total Dish Prices:      136
Dishes with Modifiers:   52
Total Modifier Groups:  130
Total Modifier Items:   736
Total Modifier Prices:  736
```

### Sample Data:
**Example Dish**: "2 Cheeseburgers with Fries and Drinks HIDE"
- Price: $26.99
- Modifier Group: "2 Drinks" (required, min: 2, max: 2)
  - 12 drink options (Ginger Ale, Ice Tea, Pepsi, etc.) - all $0.00

**Example Dish with Multiple Prices**: "Basil Seed Drinks (290ml ) HIDE"
- 8 different flavor/size combinations with different prices

---

## Status

✅ **Phase 1: COMPLETE** (14 courses, 111 dishes)  
✅ **Phase 2: COMPLETE** (136 prices, 130 modifier groups, 736 modifier items)

**Restaurant 949 is now fully scraped and ready for production!**

