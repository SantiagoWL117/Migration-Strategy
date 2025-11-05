# Course Assignment Fix Progress

## ✅ Completed Restaurants

### Wandee Thai (Restaurant ID: 954)
**Status:** ✅ COMPLETE - All 94 dishes assigned to courses
**Date:** 2025-11-03

**Course Distribution:**
- CHEF'S SPECIAL - THAI STYLE STREET FOOD (1085): 0 dishes (course defined but no dishes)
- Lunch- Appetizers (1097): 3 dishes
- Lunch- Soups (1101): 4 dishes
- Lunch- Rice and Noodle Dishes (1100): 6 dishes
- Lunch- Curries (1099): 4 dishes
- Lunch- Stir Fried Dishes (1102): 7 dishes
- Lunch- Combos (1098): 4 dishes
- Dinner- Appetizers (1086): 8 dishes
- Dinner- Soups (1093): 5 dishes
- Dinner- Noodle Dishes (1089): 7 dishes
- Dinner- Rice Dishes (1090): 3 dishes
- Dinner- Salads (1091): 4 dishes
- Dinner- Curries (1088): 6 dishes
- Dinner- Stir Fried Dishes (1094): 15 dishes
- Dinner- Seafood (1092): 5 dishes
- Dinner- Combos (1087): 4 dishes
- Extras (1096): 5 dishes
- Drinks (1095): 4 dishes

**Details:**
- All NULL course_id values resolved
- Thai restaurant with complete menu structure (Lunch and Dinner menus)
- Dishes assigned using code pattern matching (A=Appetizers, C=Combos, D=Drinks, E=Extras, G=Curries, N=Noodles, P=Stir Fried, R=Rice, S=Soups, T=Seafood, Y=Salads, L prefix=Lunch)
- Verified: 0 remaining NULL values

### Lucky King Take Out (Restaurant ID: 174)
**Status:** ✅ COMPLETE - All 141 dishes assigned to courses
**Date:** 2025-11-03
**Address:** 1134 Cadboro Rd ✅ (matches verified list)

**Details:**
- Total dishes: 141
- Dishes with course_id: 141 (100%) ✅
- Courses defined: 14
- Status: active ✅

**Course Distribution:**
All 141 dishes properly assigned to 14 course categories.

**Details:**
- All dishes already properly assigned to courses
- Chinese restaurant with complete menu structure
- Verified: 0 remaining NULL values

### Beneci Pizza (Restaurant ID: 241)
**Status:** ✅ COMPLETE - STATUS CORRECTED & CLEANED - Was suspended, now active
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Multiple duplicate/test entries found (IDs: 516, 760, 932)

**Action Taken:**
- Deleted 3 incorrect restaurant entries (Beneci Pizza Cobden, Vanier, Yanni Practice)
- Updated restaurant status from 'suspended' to 'active'
- Verified address exists: 4 Lorry Greenberg Dr
- Note: restaurant_locations.is_active was false, explaining why address wasn't found initially

**Menu Status:**
- Total dishes: 1
- Courses defined: 1 (Uncategorized - ID: 1467)
- Dishes with course_id: 1 (100%) ✅

**Course Distribution:**
- Uncategorized (1467): 1 dish
  - 6 Toppings Pizza

**Result:** Restaurant status corrected, duplicates removed. All dishes properly assigned.

### Capital Bites (Restaurant ID: 973)
**Status:** ✅ COMPLETE - All 129 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 129
- Courses defined: 15
- Dishes with course_id: 129 (100%) ✅

**Course Distribution:**
- Walk In (1322): display_order 0
- Pizza Combo Deals (1316): display_order 1
- 2 For 1 Pizza Deals (1309): display_order 2
- 2 For 1 Wings (1310): display_order 3
- Pizza (1315): display_order 4
- Appetizers (1311): display_order 5
- Salads (1319): display_order 6
- Poutine (1318): display_order 7
- Donairs (1312): display_order 8
- Seafood (1320): display_order 9
- Italian Dishes (1314): display_order 10
- Subs (1321): display_order 11
- Platters (1317): display_order 12
- Drinks (1313): display_order 13
- Uncategorized (1854): display_order 999

**Result:** Well-organized Lebanese restaurant menu. All dishes already properly assigned.

### Cathay Restaurants (Restaurant ID: 72)
**Status:** ✅ COMPLETE - All 211 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 211
- Courses defined: 32
- Dishes with course_id: 211 (100%) ✅

**Course Structure:**
- Comprehensive Chinese restaurant menu with 32 well-organized courses
- Includes: Appetizers, Soups, Fried Rice, Egg Foo Young, Chow Mein/Chop Suey
- Protein categories: Chicken, Pork, Beef, Seafood
- Specialty sections: Szechuan Style, Hot & Spicy, Special From Our Chef
- Combo options: Value Combos, Family Dinners, Combination Plates
- Additional: Side Orders, Extras, Mo She, Specialty Noodles, Vegetables

**Result:** Well-organized Chinese restaurant menu. All dishes already properly assigned.

### Centertown Donair & Pizza (Restaurant ID: 131)
**Status:** ✅ COMPLETE - STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Status mismatch identified

**Action Taken:**
- Updated restaurant status from 'suspended' to 'active'
- Verified update successful

**Menu Status:**
- Total dishes: 26
- Courses defined: 5
- Dishes with course_id: 26 (100%) ✅

**Course Distribution:**
- Chicken (470): 0 dishes
- Appetizers (469): 14 dishes (Cheese Sticks, Chicken Box, French Fries, Garlic Bread, Poutine, etc.)
- Desserts (471): 0 dishes
- Donairs (472): 0 dishes
- Uncategorized (1862): 12 dishes (Pizza specials, Drinks, Wings, etc.)

**Result:** Restaurant status corrected. All dishes already properly assigned. Note: Some courses defined but no dishes assigned (Chicken, Desserts, Donairs).

### Charm Thai Cuisine (Restaurant ID: 943)
**Status:** ✅ COMPLETE - STATUS CORRECTED - Was pending, now active
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as "Charm Thai Cuisine"
- Restaurant exists in database as "NANA Thai Cuisine" at 121 Preston Street
- Database status was: pending

**Action Taken:**
- Found restaurant by searching Preston St address
- Updated restaurant status from 'pending' to 'active'
- Verified all dishes already have course assignments

**Menu Status:**
- Total dishes: 69
- Courses defined: 11
- Dishes with course_id: 69 (100%) ✅

**Course Distribution:**
- Lunch Special (931): 12 dishes
- Appetizers (926): 5 dishes
- Soups (935): 5 dishes
- Salad - Yum (932): 5 dishes
- Seafood (933): 5 dishes
- Curries (929): 7 dishes
- Chicken - Pork - Beef (928): 4 dishes
- Vegetarian (936): 4 dishes
- Fried Rice - Noodles (930): 15 dishes
- Sides (934): 2 dishes
- Beverages (927): 5 dishes

**Result:** Restaurant found under different name. Status corrected to active. Well-organized Thai restaurant menu with all dishes properly assigned.

### Chicco Pizza Maloney (Restaurant ID: 964)
**Status:** ✅ COMPLETE - All 106 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 106
- Courses defined: 15
- Dishes with course_id: 106 (100%) ✅

**Result:** Well-organized French pizza restaurant menu. All dishes already properly assigned.

### Chicco Pizza Shawarma Anger (Restaurant ID: 963)
**Status:** ✅ COMPLETE - All 37 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 37
- Courses defined: 10
- Dishes with course_id: 37 (100%) ✅

**Result:** All dishes already properly assigned.

### Chicco Pizza St-Louis (Restaurant ID: 967)
**Status:** ✅ COMPLETE - All 21 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 21
- Courses defined: 10
- Dishes with course_id: 21 (100%) ✅

**Course Distribution:**
- Les Nachos (1249): 3 dishes
- Club sandwich (1246): 2 dishes
- Les à Cotés (1248): 2 dishes
- Desserts (1247): 1 dish
- Breuvages (1245): 7 dishes
- Spéciaux (1254): 5 dishes
- Les Pizzas Classiques (1250): 1 dish

**Details:**
- All NULL course_id values resolved
- Dishes mapped based on logical categorization
- Verified: 0 remaining NULL values

### Chicco Pizza & Shawarma Buckingham (Restaurant ID: 962)
**Status:** ✅ COMPLETE - All 24 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 24
- Courses defined: 12
- Dishes with course_id: 24 (100%) ✅

**Course Distribution:**
- Shawarmas Formats Familiaux (1199): 4 dishes
- Les Nachos (1194): 3 dishes
- Club Sandwich (1191): 2 dishes
- Desserts (1192): 2 dishes
- Breuvages (1190): 9 dishes
- Spéciaux (1201): 3 dishes
- Les Pizzas Classiques (1195): 1 dish

**Details:**
- All NULL course_id values resolved
- Dishes mapped based on logical categorization
- Verified: 0 remaining NULL values

### Chicco Shawarma Cantley (Restaurant ID: 961)
**Status:** ✅ COMPLETE - All 11 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 11
- Courses defined: 5
- Dishes with course_id: 11 (100%) ✅

**Course Distribution:**
- Shawarmas Formats Familiaux (1189): 3 dishes
- Les à Cotés (1186): 1 dish
- Breuvages (1185): 7 dishes

**Details:**
- All NULL course_id values resolved
- Dishes mapped based on logical categorization
- Verified: 0 remaining NULL values

### Chicco Shawarma Maloney (Restaurant ID: 965)
**Status:** ✅ COMPLETE - All 8 dishes assigned to courses
**Date:** 2025-11-03

**Menu Status:**
- Total dishes: 8
- Courses defined: 5
- Dishes with course_id: 8 (100%) ✅

**Result:** All dishes already properly assigned.

### Tony's Pizza (Restaurant ID: 929)
**Status:** ✅ COMPLETE - All 123 dishes assigned to courses
**Date:** 2025-11-03
**Address:** 7772 Jeanne d'Arc Blvd ✅ (matches verified list)

**Course Distribution:**
- Appetizers: Assigned ✅
- Desserts: Assigned ✅
- Drinks: Assigned ✅
- Italian: Assigned ✅
- Nachos: Assigned ✅
- Pizza: Assigned ✅
- Platters: Assigned ✅
- Salads: Assigned ✅
- Subs: Assigned ✅
- Wings: Assigned ✅
- Wraps: Assigned ✅

**Details:**
- Total dishes: 123
- Dishes with course_id: 123 (100%) ✅
- Courses defined: 11
- All dishes already properly assigned and categorized
- Verified: 0 remaining NULL values

**Note:** Multiple Tony's Pizza locations exist (IDs: 143, 956, 929, 992). This active location (ID: 929) has complete course assignments.

---

## 🔄 In Progress Restaurants

(None currently)

---

## ⏳ Pending Restaurants (236 remaining)

From Restaurants-active.md list - to be processed sequentially with user approval.
Working backwards from line 252 (Zait and Zaatar) towards line 125.

---

## ⚠️ Skipped Restaurants

### ⚠️ Skipped Restaurants - No Courses Defined

#### Aahar The Taste of India (Restaurant ID: 561)
**Status:** ⚠️ SKIPPED - No Courses Defined
**Date:** 2025-11-03
**Address:** 1573 Alta Vista Drive ✅ (matches verified list)
**Menu Reference:** https://aaharaltavista.menu.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Aahar%';
```
- Restaurant ID: 561
- Name: Aahar The Taste of India
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 561;
```
- Courses defined: 0 ⚠️
- **Action:** Cannot proceed until courses are created

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 561 AND deleted_at IS NULL;
```
- Total dishes: 108
- Dishes with NULL course_id: 108 (100%)
- Dishes with course_id: 0 (0%)

**Recommended Course Structure:**
Based on live menu at https://aaharaltavista.menu.ca/?p=menu:
- Starters (Samosa, Onion Bhaji, Aloo Tikki, Vegetable Pakora, Shrimp Pakoras, Sheekh Kebab, Paneer Pakora, Fish Pakoras, Chicken Pakoras)
- Soups (Daal Soup, Mullagatawny Soup, Khumb Ras Soup)
- Main Vegetarian Dishes (Navratan Korma, Aloo Mattar, Shahi Paneer, Palak Paneer, Mattar Paneer, Sabzi, Saag Paneer, Paneer Tikka, Kadai Paneer, Paneer Dilruba, Vegetable Dilruba, Channa Masala, Punjabi Kadhi, Sarson Da Saag, Dal Makhni, Dal Tadka, Began Bartha, Bhindi Masala, Aloo Gobi)
- Main Chicken Dishes (Butter Chicken, Chicken Curry, Chicken Tikka Masala, Chicken Korma, Chicken Vindaloo, Chicken Saag, Chicken Bhuna, Chicken Dilruba, Chicken Tandoori, etc.)
- Main Lamb and Beef Dishes (Lamb Curry, Beef Curry, Lamb Rogan Josh, Beef Vindaloo, Lamb Saag, etc.)
- Seafood and Tandoori Dishes (Shrimp Curry, Fish Curry, etc.)
- Chicken Tandoori Dishes
- Traditional Breads (Naan, Garlic Naan, Onion Paratha, Paneer Naan/Paratha, Lachha Paratha, Aloo Paratha, Onion Kulcha, Tandoori Missi Roti, etc.)
- Rice (Plain Rice, Vegetable Biryani, Beef Biryani, Chicken Biryani, Lamb Biryani, Egg Biryani)
- Chutneys (Mint Chutney, Coconut Chutney, Mango Chutney, Mix Pickle, Chutney Thaly)
- Side Dishes (Papadum, Raita, Salad, Chutney, Mixed Pickle)
- Desserts (Kheer, Ras Malai, Gulab Jamun, Carrot Halwa)
- Beverages (Lassi, Mango Lassi, Shikanjvi, Juice, Bottled Water, Kadak Chai, Masala Chai, Rooh Afza, Jal Jerra, Soft Drinks)

**Result:** ⚠️ Skipped - 0 courses defined. Cannot proceed with course assignment until courses are created. Waiting for authorization.

### ⏸️ Restaurants with Suspended/Pending Status

#### Milano 3050 Woodroffe Ave (Restaurant ID: 95)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 3050 Woodroffe Ave ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 95
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 95;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 95 AND deleted_at IS NULL;
```
- Total dishes: 14
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 14 (100%) ✅

**Result:** ⏸️ STOPPED - Status mismatch found. Restaurant is listed as active in verified billing list but database shows `suspended`. All dishes already have course_id assigned, but status correction is required before proceeding. Waiting for authorization to update status from `suspended` to `active`.

#### Milano 339 Dalhousie St (Restaurant ID: 91)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 339 Dalhousie St ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 91
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 91;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 91 AND deleted_at IS NULL;
```
- Total dishes: 13
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 13 (100%) ✅

**Result:** ⏸️ STOPPED - Status mismatch found. Restaurant is listed as active in verified billing list but database shows `suspended`. All dishes already have course_id assigned, but status correction is required before proceeding. Waiting for authorization to update status from `suspended` to `active`.

#### Milano 350 St-Philippe Street (Restaurant ID: 624)
**Status:** ✅ SKIPPED - Already Assigned
**Date:** 2025-11-03
**Address:** 350 St-Philippe Street ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 624
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 624;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 624 AND deleted_at IS NULL;
```
- Total dishes: 34
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 34 (100%) ✅

**Result:** ✅ Already assigned - All 34 dishes have course_id. No work needed.

#### Milano 3796 Champlain Rd (Restaurant ID: 90)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 3796 Champlain Rd ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 90
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 90;
```
- Courses defined: 19 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 90 AND deleted_at IS NULL;
```
- Total dishes: 11
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 11 (100%) ✅

**Result:** ⏸️ STOPPED - Status mismatch found. Restaurant is listed as active in verified billing list but database shows `suspended`. All dishes already have course_id assigned, but status correction is required before proceeding. Waiting for authorization to update status from `suspended` to `active`.

#### Milano 3848 Innes Rd (Restaurant ID: 57)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 3848 Innes Rd ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 57
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 57;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 57 AND deleted_at IS NULL;
```
- Total dishes: 17
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 17 (100%) ✅

**Result:** ⏸️ STOPPED - Status mismatch found. Restaurant is listed as active in verified billing list but database shows `suspended`. All dishes already have course_id assigned, but status correction is required before proceeding. Waiting for authorization to update status from `suspended` to `active`.

#### Milano 385 Tompkins Ave (Restaurant ID: 59)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 385 Tompkins Ave ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 59
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 59;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT COUNT(*) as total_dishes, COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count, COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count FROM menuca_v3.dishes WHERE restaurant_id = 59 AND deleted_at IS NULL;
```
- Total dishes: 13
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 13 (100%) ✅

**Result:** ⏸️ Status mismatch - suspended vs active. Already assigned.

#### Milano 4188 Spratt Rd (Restaurant ID: 565)
**Status:** ✅ SKIPPED - Already Assigned
**Date:** 2025-11-03
**Address:** 4188 Spratt Rd ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 565
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 565;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT COUNT(*) as total_dishes, COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count, COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count FROM menuca_v3.dishes WHERE restaurant_id = 565 AND deleted_at IS NULL;
```
- Total dishes: 14
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 14 (100%) ✅

**Result:** ✅ Already assigned - All 14 dishes have course_id. No work needed.

#### Milano 455 Boulevard Riel (Restaurant ID: 751)
**Status:** ✅ SKIPPED - Already Assigned
**Date:** 2025-11-03
**Address:** 455 Boulevard Riel ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 751
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 751;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT COUNT(*) as total_dishes, COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count, COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count FROM menuca_v3.dishes WHERE restaurant_id = 751 AND deleted_at IS NULL;
```
- Total dishes: 31
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 31 (100%) ✅

**Result:** ✅ Already assigned - All 31 dishes have course_id. No work needed.

#### Milano 471 Hazeldean Rd (Restaurant ID: 126)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 471 Hazeldean Rd ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 126
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 126;
```
- Courses defined: 2 ✅

**Step 3: Check Dishes**
```sql
SELECT COUNT(*) as total_dishes, COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count, COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count FROM menuca_v3.dishes WHERE restaurant_id = 126 AND deleted_at IS NULL;
```
- Total dishes: 9
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 9 (100%) ✅

**Result:** ⏸️ Status mismatch - suspended vs active. Already assigned.

#### Milano 506 Main St W (Restaurant ID: 350)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 506 Main St W ✅ (matches verified list)
**Assignee:** Brian (B)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 350
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 350;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT COUNT(*) as total_dishes, COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count, COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count FROM menuca_v3.dishes WHERE restaurant_id = 350 AND deleted_at IS NULL;
```
- Total dishes: 81
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 81 (100%) ✅

**Result:** ⏸️ Status mismatch - suspended vs active. Already assigned.

#### Milano 54 Wilson St W (Restaurant ID: 660)
**Status:** ✅ SKIPPED - Already Assigned
**Date:** 2025-11-03
**Address:** 54 Wilson St W ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** Optional (already assigned, reasonable dish count)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 660
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 660;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 660 AND deleted_at IS NULL;
```
- Total dishes: 11
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 11 (100%) ✅

**Result:** ✅ Already assigned - All 11 dishes have course_id. No work needed.

#### Milano 5516 Osgoode Main S (Restaurant ID: 349)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 5516 Osgoode Main S ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** Optional (already assigned, reasonable dish count)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 349
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 349;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 349 AND deleted_at IS NULL;
```
- Total dishes: 73
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 73 (100%) ✅

**Result:** ⏸️ STOPPED - Status mismatch found. Restaurant is listed as active in verified billing list but database shows `suspended`. All dishes already have course_id assigned, but status correction is required before proceeding. Waiting for authorization to update status from `suspended` to `active`.

#### Milano 6179 Perth St. (Restaurant ID: 190)
**Status:** ⏸️ STATUS MISMATCH - Listed as active but DB shows suspended
**Date:** 2025-11-03
**Address:** 6179 Perth St. ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://richmond.milanopizzeria.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 190
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 190;
```
- Courses defined: 1 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 190 AND deleted_at IS NULL;
```
- Total dishes: 31
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 31 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 190 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 31 dishes are assigned to "Uncategorized" course, but live menu shows multiple courses (Appetizers, Pizza, Pasta, Burgers, Drinks, etc.)

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 190 AND dm.deleted_at IS NULL;
```
- Total modifiers: 68
- Dishes with modifiers: 22 (out of 31 dishes)
- **Menu link analysis:** Need to verify modifier assignments match live menu structure

**Menu Analysis from https://richmond.milanopizzeria.ca/?p=menu:**
Live menu courses include:
- Bruyère DONATION
- Features Of The Month
- Mini Donuts Hot and Fresh Made
- PIZZAS WITH FANTINO MONDELLO PANCETTA
- 2 Pizza and Two Free 591ml Drinks
- Daily Special
- Appetizers
- Chicken Wings
- Southern Fried Chicken
- Salads
- Subs
- Beef Donairs and Chicken Shawarma Wraps
- Poutine
- Pizza
- Pasta
- Burgers - Sandwiches - Platters
- Drinks

**Result:** ⚠️ CRITICAL ISSUE - All dishes incorrectly assigned to "Uncategorized" course. Live menu has proper course structure with 17+ courses. Dishes need to be reassigned to correct courses. Status mismatch also needs correction (suspended → active). Modifiers exist but need verification once courses are corrected. Waiting for authorization to create proper courses and reassign dishes.

#### Milano 643 Boulevard Saint-René O (Restaurant ID: 680)
**Status:** ⚠️ CRITICAL ISSUE - All dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 643 Boulevard Saint-René O ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://gatineau.milanopizzeria.ca/?p=menu&lang=fr

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 680
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 680;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 680 AND deleted_at IS NULL;
```
- Total dishes: 75
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 75 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 680 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 75 dishes are assigned to "Uncategorized" course. Need menu link to verify proper course structure.

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 680 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://gatineau.milanopizzeria.ca/?p=menu&lang=fr:**
Live menu courses include (French menu):
- Spécial Lundi & Mardi
- Prix de Groupe
- Spécial 2 Pizzas
- Pizza et Poutine
- Pizzas et Accompagnements
- Offres Duo
- Accompagnement (Appetizers)
- Trempettes (Dips)
- Poutine
- Nos Poutines Végétaliennes (Vegan Poutines)
- Les Sandwiches
- Nos Nachos
- Menu Pizza
- Nos Pizza Végétalienne (Vegan Pizza)
- Nos Pâtes (Pasta)
- Dessert
- Breuvage (Drinks)

**Result:** ⚠️ CRITICAL ISSUE - All 75 dishes incorrectly assigned to "Uncategorized" course. Live menu has proper course structure with 17+ courses. Dishes need to be reassigned to correct courses. No modifiers found. Waiting for authorization to create proper courses and reassign dishes.

#### Milano 6500 Russell Road (Restaurant ID: 837)
**Status:** ⚠️ CRITICAL ISSUE - All dishes in Uncategorized, suspiciously low dish count
**Date:** 2025-11-03
**Address:** 6500 Russell Road ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://carlsbadsprings.milanopizzeria.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 837
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 837;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 837 AND deleted_at IS NULL;
```
- Total dishes: 8 ⚠️⚠️⚠️ (SUSPICIOUSLY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 8 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 837 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 8 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 837 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://carlsbadsprings.milanopizzeria.ca/?p=menu:**
Live menu courses include:
- Daily Specials
- 2 Pizza and Two Free 591ml Drinks
- Appetizers
- Subs
- Wings
- Platters
- Salads
- Pizza
- Pasta
- VEGAN (Vegan Pizza, Vegan Poutine)
- Greek Appetizers
- Souvlaki Platters
- Pita Wraps
- Desserts
- Drinks

**CRITICAL DATA MIGRATION ISSUE:** Database shows only 8 dishes, but live menu has 15+ courses with dozens of dishes. This indicates a severe data migration problem - most menu items are missing from the database.

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Only 8 dishes in database vs. full menu with 15+ courses. All 8 dishes incorrectly assigned to "Uncategorized" course. This is NOT just a course assignment issue - most menu items are missing from database. Need to investigate data migration process. No modifiers found. Waiting for authorization to investigate missing dishes and correct course structure.

#### Milano 6594 4th Line Rd (Restaurant ID: 819)
**Status:** ⚠️ CRITICAL ISSUE - All dishes in Uncategorized, suspiciously low dish count
**Date:** 2025-11-03
**Address:** 6594 4th Line Rd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://mnorthgower.milanopizzeria.ca/ - **ONLINE ORDERING TEMPORARILY SUSPENDED**

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 819
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 819;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 819 AND deleted_at IS NULL;
```
- Total dishes: 18 ⚠️⚠️ (SUSPICIOUSLY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 18 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 819 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 18 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 819 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://mnorthgower.milanopizzeria.ca/
- **Status:** Online ordering temporarily suspended - "We're sorry. Our online ordering service is temporarily suspended. Please call the restaurant at: (613) 489-1444"
- **Impact:** Cannot verify menu structure or dish completeness via online menu. Need to contact restaurant or check alternative sources.

**Result:** ⚠️ CRITICAL ISSUE - Only 18 dishes (suspiciously low for Milano restaurant). All dishes incorrectly assigned to "Uncategorized" course. Online ordering is temporarily suspended, so cannot verify menu structure or missing dishes via web menu. May need to contact restaurant directly or wait for online ordering to resume. No modifiers found. Waiting for menu access or alternative verification method.

#### Milano 777 Principale St (Restaurant ID: 89)
**Status:** ⏸️ STATUS MISMATCH + ⚠️ CRITICAL ISSUE - Courses exist but all dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 777 Principale St ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://casselman.milanopizzeria.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 89
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 89;
```
- Courses defined: 18 ✅ (Good - proper courses exist!)

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 89 AND deleted_at IS NULL;
```
- Total dishes: 41
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 41 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 89 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 18 ✅
- **CRITICAL ISSUE:** All 41 dishes are assigned to "Uncategorized" course, but proper courses exist:
  - Appetizers (0 dishes)
  - Cold Subs (0 dishes)
  - Chicken (0 dishes)
  - Combos (0 dishes)
  - Dessert (0 dishes)
  - Donair and Shawarma (0 dishes)
  - Drinks (0 dishes)
  - Everyday Specials (0 dishes)
  - Greek (0 dishes)
  - Hot Subs (0 dishes)
  - Italian (0 dishes)
  - Mexican (0 dishes)
  - Pita Pockets (0 dishes)
  - Salads (0 dishes)
  - Sandwiches (0 dishes)
  - Seafood (0 dishes)
  - Traditional Pizza (0 dishes)
  - Uncategorized (41 dishes) ⚠️

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 89 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://casselman.milanopizzeria.ca/?p=menu:**
Live menu courses include:
- Bruyère DONATION
- Tuesdays and Wednesdays (Shawarma Sandwich, Shawarma Platter, Southern Fried Chicken variants)
- Features Of The Month
- Mini Donuts Hot and Fresh Made
- PIZZAS WITH FANTINO MONDELLO PANCETTA
- 2 Pizza and 2 Free 591ml Drinks
- Specials
- Salads
- Poutine and Fries
- Chicken Wings
- Southern Fried Chicken
- Appetizers
- Sandwiches
- Platters
- Submarines Sandwiches
- Pizza with Free 591 Beverage
- Pasta
- Burgers
- VEGAN (Vegan Pizza, Vegan Poutine)
- Desserts
- Drinks

**Course Mapping Analysis:**
Database has 18 courses, but they don't match live menu structure. Database courses (Appetizers, Cold Subs, Chicken, Combos, Dessert, Donair and Shawarma, Drinks, Everyday Specials, Greek, Hot Subs, Italian, Mexican, Pita Pockets, Salads, Sandwiches, Seafood, Traditional Pizza) vs. Live menu courses (Appetizers, Salads, Sandwiches, Platters, Submarines, Pizza, Pasta, Burgers, Chicken Wings, Southern Fried Chicken, Poutine, VEGAN, Desserts, Drinks, Specials).

**Result:** ⚠️ CRITICAL ISSUE - Proper courses exist (18 courses) but ALL 41 dishes incorrectly assigned to "Uncategorized" instead of proper courses. Course structure in database doesn't fully match live menu structure. Need to reassign dishes to correct courses based on live menu. Status mismatch also needs correction (suspended → active). No modifiers found. Waiting for authorization to reassign dishes to proper courses.

#### Milano 81 Madawaska Street (Restaurant ID: 586)
**Status:** ⚠️ CRITICAL ISSUE - All dishes in Uncategorized, suspiciously low dish count
**Date:** 2025-11-03
**Address:** 81 Madawaska Street ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://marnprior.milanopizzeria.ca/ - **ONLINE ORDERING TEMPORARILY UNAVAILABLE**

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 586
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 586;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 586 AND deleted_at IS NULL;
```
- Total dishes: 14 ⚠️⚠️ (SUSPICIOUSLY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 14 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 586 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 14 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 586 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://marnprior.milanopizzeria.ca/
- **Status:** Online ordering temporarily unavailable - "We're sorry. Our online ordering service is temporarily unavailable. Please call the restaurant at: (613) 623-2233"
- **Impact:** Cannot verify menu structure or dish completeness via online menu. Need to contact restaurant or check alternative sources.

**Result:** ⚠️ CRITICAL ISSUE - Only 14 dishes (suspiciously low for Milano restaurant). All dishes incorrectly assigned to "Uncategorized" course. Online ordering is temporarily unavailable, so cannot verify menu structure or missing dishes via web menu. May need to contact restaurant directly or wait for online ordering to resume. No modifiers found. Waiting for menu access or alternative verification method.

#### Milano 83 Mill Street (Restaurant ID: 821)
**Status:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Extremely low dish count
**Date:** 2025-11-03
**Address:** 83 Mill Street ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://mrussell.milanopizzeria.ca/menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 821
- Name: Milano
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 821;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 821 AND deleted_at IS NULL;
```
- Total dishes: 5 ⚠️⚠️⚠️ (EXTREMELY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 5 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 821 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 5 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 821 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://mrussell.milanopizzeria.ca/menu:**
Live menu courses include:
- Daily Specials (5 combo deals)
- Traditional Pizza (15+ pizza varieties with multiple sizes)
- Gourmet Pizza (6 gourmet pizza varieties)
- Subs (13 sub varieties with 6" and 12" sizes)
- Wings and Things (wings, cheese curds, fries, poutine, appetizers - 15+ items)
- Sandwiches (8 sandwich varieties)
- Salads (5 salad varieties with small/large sizes)
- Side Orders (garlic bread, sauces, etc.)
- Soft Drinks and Water (multiple beverage options)

**CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Database shows only 5 dishes, but live menu has 9+ courses with 70+ individual dishes across all courses. This is a severe data migration problem - approximately 93%+ of menu items are missing from the database.

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Only 5 dishes in database vs. full menu with 9+ courses and 70+ dishes. This is NOT just a course assignment issue - 93%+ of menu items are missing from database. All 5 dishes incorrectly assigned to "Uncategorized" course. Need to investigate data migration process immediately. No modifiers found. Waiting for authorization to investigate missing dishes and correct course structure.

#### Milano 876 Montreal Rd. (Restaurant ID: 31)
**Status:** ⏸️ STATUS MISMATCH + ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Extremely low dish count
**Date:** 2025-11-03
**Address:** 876 Montreal Rd. ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://montreal.milanopizzeria.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 31
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 31;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 31 AND deleted_at IS NULL;
```
- Total dishes: 10 ⚠️⚠️ (SUSPICIOUSLY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 10 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 31 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 10 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 31 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://montreal.milanopizzeria.ca/?p=menu:**
Live menu courses include:
- Bruyère DONATION
- Feature Of The Month
- Mini Donuts Hot and Fresh Made
- PIZZAS WITH FANTINO MONDELLO PANCETTA
- 2 Pizza Deal with Two 591ml Pop
- Everyday Specials
- Appetizers
- Wings
- Southern Fried Chicken
- Salads
- Subs
- Donairs
- Poutine
- Pizza
- Pasta
- Burgers - Sandwiches - Platters
- VEGAN (Vegan Pizza, Vegan Burgers, Vegan Poutine, Vegan Wraps)
- Desserts
- Drinks

**CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Database shows only 10 dishes, but live menu has 19+ courses with dozens of dishes across all courses. This is a severe data migration problem - approximately 85%+ of menu items are missing from the database.

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Only 10 dishes in database vs. full menu with 19+ courses and 80+ dishes. This is NOT just a course assignment issue - 85%+ of menu items are missing from database. All 10 dishes incorrectly assigned to "Uncategorized" course. Status mismatch also needs correction (suspended → active). Need to investigate data migration process immediately. No modifiers found. Waiting for authorization to investigate missing dishes and correct course structure.

#### Milano 990 River Rd (Restaurant ID: 93)
**Status:** ⏸️ STATUS MISMATCH + ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Extremely low dish count
**Date:** 2025-11-03
**Address:** 990 River Rd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu Reference:** https://manotick.milanopizzeria.ca/?p=menu

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Milano%';
```
- Restaurant ID: 93
- Name: Milano
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 93;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 93 AND deleted_at IS NULL;
```
- Total dishes: 8 ⚠️⚠️⚠️ (EXTREMELY LOW - Most Milano locations have 30-75 dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 8 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 93 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 8 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 93 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Analysis from https://manotick.milanopizzeria.ca/?p=menu:**
Live menu courses include:
- Bruyère DONATION
- Features Of The Month
- Mini Donuts Hot and Fresh Made
- PIZZAS WITH FANTINO MONDELLO PANCETTA
- 2 Pizza and Two Free 591ml Drinks
- Every Day Special
- Appetizers
- Chicken and Wings
- Salads
- Rice Bowls
- Chicken Shawarma
- Donairs
- Subs
- Poutine
- Pizza
- Gourmet Pizza
- Pasta
- Platters and Sandwiches
- VEGAN (Vegan Pizza, Vegan Burgers, Vegan Poutine, Vegan Wraps)
- Desserts
- Drinks
- Beer and Wine

**CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Database shows only 8 dishes, but live menu has 23+ courses with dozens of dishes across all courses. This is a severe data migration problem - approximately 90%+ of menu items are missing from the database.

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Only 8 dishes in database vs. full menu with 23+ courses and 80+ dishes. This is NOT just a course assignment issue - 90%+ of menu items are missing from database. All 8 dishes incorrectly assigned to "Uncategorized" course. Status mismatch also needs correction (suspended → active). Need to investigate data migration process immediately. No modifiers found. Waiting for authorization to investigate missing dishes and correct course structure.

#### Mont Liban Bakery & Shawarma 351 Montreal Rd (Restaurant ID: 205)
**Status:** ⏸️ STATUS MISMATCH + ⚠️ CRITICAL ISSUE - All dishes in Uncategorized, modifiers exist
**Date:** 2025-11-03
**Address:** 351 Montreal Rd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** NEEDED (all dishes in Uncategorized, 29 modifiers on 15 dishes need verification)
**⚠️ IMPORTANT:** Google Maps shows location as "PERMANENTLY CLOSED" - may explain suspended status

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mont Liban%';
```
- Restaurant ID: 205
- Name: Mont Liban Bakery & Shawarma
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 205;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 205 AND deleted_at IS NULL;
```
- Total dishes: 26
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 26 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 205 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 26 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 205 AND dm.deleted_at IS NULL;
```
- Total modifiers: 29
- Dishes with modifiers: 15 (out of 26 dishes)
- **Menu link NEEDED:** To verify modifier assignments match live menu (which dishes should have modifiers, which modifiers belong to which dishes)

**⚠️ RESTAURANT STATUS NOTE:** Google Maps shows this location as "PERMANENTLY CLOSED". This may explain why database shows `suspended` status. However, restaurant appears on verified billing list (billed in last 4 months), suggesting it may have closed recently or status needs verification.

**Result:** ⚠️ CRITICAL ISSUE - All 26 dishes incorrectly assigned to "Uncategorized" course. Modifiers exist (29 modifiers on 15 dishes) but need menu link to verify assignments are correct. Status discrepancy: Database shows `suspended`, verified billing list shows active (billed in last 4 months), but Google Maps shows "PERMANENTLY CLOSED". Need to verify actual restaurant status before proceeding with course corrections. Waiting for menu link and status clarification.

#### Mozza Pizza Gatineau 425, boul La Vérendrye E (Restaurant ID: 35)
**Status:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Extremely low dish count
**Date:** 2025-11-03
**Address:** 425, boul La Vérendrye E ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://mozzapizzagatineau.com/?p=menu&lang=fr ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mozza%';
```
- Restaurant ID: 35
- Name: Mozza Pizza
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 35;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 35 AND deleted_at IS NULL;
```
- Total dishes: 3 ⚠️⚠️⚠️ (EXTREMELY LOW - Most pizza restaurants have 30+ dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 3 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 35 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 3 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 35 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://mozzapizzagatineau.com/?p=menu&lang=fr
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Spécial Petites (2 items)
  - Spécial Moyennes (3 items)
  - Spécial Grandes (3 items)
  - Spécial X-Grandes (3 items)
  - Pizzas (16+ pizza types with multiple sizes each = 60+ items)
  - Entrées (10+ items: frites, rouleaux, nachos, etc.)
  - Salades (2 items)
  - Wraps (3 items)
  - Pâtes Savoureuses (1 item: Lasagne)
  - Ailes de Poulet (1 item with 3 sizes)
  - Doigts De Poulet (1 item)
  - Sandwichs Roulés Chauds (1 item)
  - Sous-Marin Chaud (6 items)
  - Desserts (2 items)
  - Liqueurs (14+ beverage items)
- **Estimated Total Items:** 100+ dishes on live menu
- **Database Has:** Only 3 dishes (97%+ of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Live menu has 100+ items across 15+ courses, but database only contains 3 dishes. This represents a catastrophic data migration failure - approximately 97% of the menu is missing from the database. The 3 existing dishes are incorrectly assigned to "Uncategorized" course. Status mismatch also needs correction (suspended → active). This restaurant requires a complete menu data re-migration before course assignment can proceed. No modifiers found in database (live menu may have modifiers for pizza sizes, etc.). **URGENT: Data migration team must investigate and re-migrate full menu data.**

#### Mozza Pizza Hull 214 Boul de la Cité-des-Jeunes (Restaurant ID: 644)
**Status:** ⚠️ CRITICAL ISSUE - Suspiciously low dish count, all dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 214 Boul de la Cité-des-Jeunes ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://mozzapizzahull.com/?p=menu&lang=fr ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mozza%';
```
- Restaurant ID: 644
- Name: Mozza Pizza Hull
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 644;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 644 AND deleted_at IS NULL;
```
- Total dishes: 15 ⚠️⚠️ (SUSPICIOUSLY LOW - Most pizza restaurants have 30-100+ dishes, Mozza Pizza Gatineau has 100+ items)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 15 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 644 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 15 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 644 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://mozzapizzahull.com/?p=menu&lang=fr
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Mozza Box (8 items)
  - Spécial Petites (3 items)
  - Spécial Moyennes (3 items)
  - Spécial Grandes (3 items)
  - Spécial X-Grandes (3 items)
  - Trio (3 items)
  - Deals (8 items)
  - Pizzas (16+ pizza types with multiple sizes each = 60+ items)
  - Entrées (10+ items: frites, rouleaux, nachos, burgers, etc.)
  - Salades (2 items)
  - Wraps (3 items)
  - Pâtes Savoureuses (2 items: Lasagne, Spaghetti)
  - Ailes de Poulet (1 item with 3 sizes)
  - Doigts De Poulet (1 item)
  - Sandwichs Roulés Chauds (2 items)
  - Sous-Marin Chaud (8 items)
  - Desserts (11+ items - multiple varieties including Gâteau au Fromage with 7 flavors, Brownies, Créme Brulé, Tiramisu, Soufflé au Chocolat)
  - Liqueurs (14+ beverage items)
- **Estimated Total Items:** 100+ dishes on live menu
- **Database Has:** Only 15 dishes (85%+ of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Live menu has 100+ items across 18+ courses, but database only contains 15 dishes. This represents a severe data migration failure - approximately 85%+ of the menu is missing from the database. The 15 existing dishes are incorrectly assigned to "Uncategorized" course. This restaurant requires a complete menu data re-migration before course assignment can proceed. No modifiers found in database (live menu may have modifiers for pizza sizes, dessert flavors, etc.). **URGENT: Data migration team must investigate and re-migrate full menu data.**

#### Mr Mozzarella - Nepean 1433 Woodroffe Ave (Restaurant ID: 47)
**Status:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Only 1 dish, status mismatch
**Date:** 2025-11-03
**Address:** 1433 Woodroffe Ave ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://mmrmozzarellanepean.menu.ca/menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mozzarella%';
```
- Restaurant ID: 47
- Name: Mr Mozzarella - Nepean
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 47;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 47 AND deleted_at IS NULL;
```
- Total dishes: 1 ⚠️⚠️⚠️ (EXTREMELY LOW - Pizza restaurants typically have 30-100+ dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 1 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 47 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** The single dish is assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 47 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://mmrmozzarellanepean.menu.ca/menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Party Specials (2 items)
  - Deals (1 item)
  - Pizza and Wings Combo (4 items)
  - Mr Mozzarella Signature Pizzas (25+ pizza types with 4 sizes each = 100+ items)
  - Build Your Own Pizza (customizable with multiple sizes)
  - Wings (10+ flavors with multiple sizes = 30+ items)
  - Appetizers (15+ items: wings, chicken fingers, fries, cheese curds, mushrooms, cauliflower wings, mozzarella sticks, mac n cheese wedges, jalapeno poppers, pickles, garlic bread varieties, shrimp, nachos)
  - Poutine (6 varieties with sizes = 12+ items)
  - Baskets (4 items)
  - Italian Dishes (4 items with sizes = 8+ items)
  - Fresh Salads (3 types with sizes and protein options = 9+ items)
  - Footlongs (7 sub varieties)
  - Make A Platter (7 customizable options)
  - Desserts (3 items)
  - Drinks (20+ beverage items with multiple sizes)
- **Estimated Total Items:** 200+ dishes on live menu (when accounting for all sizes and variations)
- **Database Has:** Only 1 dish (99.5%+ of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Live menu has 200+ items across 14+ courses, but database only contains 1 dish. This represents a catastrophic data migration failure - approximately 99.5%+ of the menu is missing from the database. The single dish is incorrectly assigned to "Uncategorized" course. Status mismatch also needs correction (suspended → active). This restaurant requires a complete menu data re-migration before course assignment can proceed. No modifiers found in database (live menu has extensive modifiers for pizza sizes, wing flavors, sauce options, etc.). **URGENT: Data migration team must investigate and re-migrate full menu data immediately.**

#### Mykonos Greek Grill 2600 County Rd 43 (Restaurant ID: 846)
**Status:** ⚠️ ACTION REQUIRED - No courses defined, all dishes need assignment
**Date:** 2025-11-03
**Address:** 2600 County Rd 43 ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://kemptville.mykonosgreekgrill.ca/?p=menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mykonos%';
```
- Restaurant ID: 846
- Name: Mykonos Greek Grill
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 846;
```
- Courses defined: 0 ⚠️⚠️⚠️ **CRITICAL: No courses defined**

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 846 AND deleted_at IS NULL;
```
- Total dishes: 42 ✅
- Dishes with NULL course_id: 42 (100%) ⚠️⚠️⚠️ **ALL dishes need course assignment**
- Dishes with course_id: 0 (0%) ⚠️

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 846 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 0 ⚠️⚠️⚠️
- **CRITICAL ISSUE:** No courses exist - must create courses before assigning dishes

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 846 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://kemptville.mykonosgreekgrill.ca/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Mykonos Souvlaki Platter (11 items: Chicken, Beef, Lamb, Shrimp, Calamari, Falafel, Greek Veggie, Party Platters)
  - Pita Wraps (6 items: Chicken, Beef, Gyro Beef, Lamb, Vegetarian, Falafel)
  - Salads (2 items with sizes: Traditional Greek Salad, Mykonos Salad)
  - Appetizers (9 items: Tzatziki with Bread, Hummus with Bread, Crispy Fried Calamari, Feta Cheese with Olives, Greek Potatoes, Authentic Greek Ryzi-Rice, Spanakopita, Dolmades, Falafel with Hummus)
  - Extras (6 items: Pita Bread, Tzatziki, Hummus, Chicken/Beef/Lamb Skewers)
  - Desserts (3 items: Baklava, 6 Mini Donuts, 12 Mini Donuts - with modifier options for donut flavors)
  - Drinks (6 beverage items)
- **Total Items:** 42 dishes (matches database count ✅)
- **Modifiers Found:** Mini Donuts have modifier options (Icing Sugar, Oreo, Cinnamon Sugar)

**Result:** ⚠️ ACTION REQUIRED - Restaurant has 42 dishes but **NO courses defined**. All 42 dishes have NULL course_id and need course assignment. Must create 7 courses based on live menu structure: (1) Mykonos Souvlaki Platter, (2) Pita Wraps, (3) Salads, (4) Appetizers, (5) Extras, (6) Desserts, (7) Drinks. Then assign all 42 dishes to appropriate courses. Modifiers exist for Mini Donuts (flavor options) - need to verify these are correctly assigned in database. Waiting for authorization to create courses and assign dishes.

#### Mykonos Greek Grill 6594 Fourth Line Rd (Restaurant ID: 845)
**Status:** ⚠️ ACTION REQUIRED - No courses defined, all dishes need assignment
**Date:** 2025-11-03
**Address:** 6594 Fourth Line Rd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://northgower.mykonosgreekgrill.ca/?p=menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Mykonos%';
```
- Restaurant ID: 845
- Name: Mykonos Greek Grill
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 845;
```
- Courses defined: 0 ⚠️⚠️⚠️ **CRITICAL: No courses defined**

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 845 AND deleted_at IS NULL;
```
- Total dishes: 41 ✅
- Dishes with NULL course_id: 41 (100%) ⚠️⚠️⚠️ **ALL dishes need course assignment**
- Dishes with course_id: 0 (0%) ⚠️

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 845 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 0 ⚠️⚠️⚠️
- **CRITICAL ISSUE:** No courses exist - must create courses before assigning dishes

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 845 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://northgower.mykonosgreekgrill.ca/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Mykonos Souvlaki Platter (10 items: Chicken, Beef, Lamb, Shrimp, Calamari, Falafel, Greek Veggie, Party Platters)
  - Pita Wraps (6 items: Chicken, Beef, Gyro Beef, Lamb, Vegetarian, Falafel)
  - Salads (2 items with sizes: Traditional Greek Salad, Mykonos Salad)
  - Appetizers (9 items: Tzatziki with Bread, Hummus with Bread, Crispy Fried Calamari, Feta Cheese with Olives, Greek Potatoes, Authentic Greek Ryzi-Rice, Spanakopita, Dolmades, Falafel with Hummus)
  - Extras (6 items: Pita Bread, Tzatziki, Hummus, Chicken/Beef/Lamb Skewers)
  - Desserts (3 items: Baklava, 6 Mini Donuts, 12 Mini Donuts - with modifier options for donut flavors)
  - Drinks (5 beverage items)
- **Total Items:** 41 dishes (matches database count ✅)
- **Modifiers Found:** Mini Donuts have modifier options (Icing Sugar, Oreo, Cinnamon Sugar)

**Result:** ⚠️ ACTION REQUIRED - Restaurant has 41 dishes but **NO courses defined**. All 41 dishes have NULL course_id and need course assignment. Must create 7 courses based on live menu structure: (1) Mykonos Souvlaki Platter, (2) Pita Wraps, (3) Salads, (4) Appetizers, (5) Extras, (6) Desserts, (7) Drinks. Then assign all 41 dishes to appropriate courses. Modifiers exist for Mini Donuts (flavor options) - need to verify these are correctly assigned in database. Waiting for authorization to create courses and assign dishes.

#### Nachos Loco Gatineau 643 Boulevard Saint-René O (Restaurant ID: 801)
**Status:** ⚠️ CRITICAL ISSUE - Suspiciously low dish count, all dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 643 Boulevard Saint-René O ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** NEEDED (only 6 dishes - EXTREMELY LOW, all in Uncategorized, need to verify missing dishes and course structure)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Nachos%';
```
- Restaurant ID: 801
- Name: Nachos Loco Gatineau
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 801;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 801 AND deleted_at IS NULL;
```
- Total dishes: 6 ⚠️⚠️⚠️ (EXTREMELY LOW - Most restaurants have 20+ dishes)
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 6 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 801 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 6 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 801 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- **Status:** ❌ NO MENU FOUND - Unable to locate online menu for this location
- **Impact:** Cannot verify dish completeness or course structure without menu reference
- **Possible Reasons:** Restaurant may have closed, switched platforms, or menu not available online

**Result:** ⚠️ CRITICAL ISSUE - Only 6 dishes (EXTREMELY LOW for restaurant). All dishes incorrectly assigned to "Uncategorized" course. **NO MENU FOUND** - Unable to verify if this is a data migration issue (missing dishes) or if restaurant truly has limited menu. Without menu reference, cannot determine proper course structure. Status shows `active` in database and verified billing list, but no online menu available. May need to contact restaurant directly or check alternative sources. No modifiers found. **ACTION REQUIRED:** Verify restaurant status and menu availability before proceeding with course assignment.

#### Nachos Loco Hull 455 Boulevard Riel (Restaurant ID: 790)
**Status:** ⚠️ CRITICAL ISSUE - All dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 455 Boulevard Riel ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** NEEDED (23 dishes all in Uncategorized, need to verify course structure and assign dishes)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Nachos%';
```
- Restaurant ID: 790
- Name: Nachos Loco Hull
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 790;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 790 AND deleted_at IS NULL;
```
- Total dishes: 23 ✅
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 23 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 790 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 23 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 790 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Result:** ⚠️ CRITICAL ISSUE - All 23 dishes incorrectly assigned to "Uncategorized" course. Need menu link to verify proper course structure and reassign dishes to appropriate courses. No modifiers found. Waiting for menu link to proceed with course assignment.

#### Napolis 81 Richmond Rd (Restaurant ID: 515)
**Status:** ⚠️ CRITICAL ISSUE - Status mismatch, all dishes in Uncategorized
**Date:** 2025-11-03
**Address:** 81 Richmond Rd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://m.napoliswestboro.ca/menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Napolis%';
```
- Restaurant ID: 515
- Name: Napolis
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 515;
```
- Courses defined: 1 ⚠️

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 515 AND deleted_at IS NULL;
```
- Total dishes: 26 ✅
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 26 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 515 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 1 ⚠️
- Course name: "Uncategorized"
- **CRITICAL ISSUE:** All 26 dishes are assigned to "Uncategorized" course

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 515 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://m.napoliswestboro.ca/menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Wine (3 items)
  - Specials (1 item with sizes)
  - Pizza (4 items: Plain, One Item, Two Items, Three Items - all with sizes)
  - Famous Combos (11 pizza types with sizes = 33+ items)
  - Vegetarian Famous Combos (5 pizza types with sizes = 15+ items)
  - Submarines (7 items)
  - Salads (6 items with sizes = 12+ items)
  - Homemade Pastas (18 items)
  - Fettucine (4 items)
  - Chicken Platters (3 items)
  - Hot Sandwiches (3 items)
  - Platters (4 items with modifiers)
  - Miscellaneous (13 items with sizes/modifiers)
  - Drinks (4 items)
- **Estimated Total Items:** 100+ dishes on live menu (when accounting for all sizes and variations)
- **Database Has:** Only 26 dishes (75%+ of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - Live menu has 100+ items across 14+ courses, but database only contains 26 dishes. This represents a severe data migration failure - approximately 75%+ of the menu is missing from the database. The 26 existing dishes are incorrectly assigned to "Uncategorized" course. Status mismatch also needs correction (suspended → active). This restaurant requires a complete menu data re-migration before course assignment can proceed. No modifiers found in database (live menu has modifiers for sizes, upgrades, etc.). **URGENT: Data migration team must investigate and re-migrate full menu data.**

#### New Hong Kong 1433 Woodroffe Ave (Restaurant ID: 502)
**Status:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - No dishes, no courses, status mismatch
**Date:** 2025-11-03
**Address:** 1433 Woodroffe Ave ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://newhongkongchinese.ca/?p=menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%New Hong Kong%';
```
- Restaurant ID: 502
- Name: New Hong Kong
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 502;
```
- Courses defined: 0 ⚠️⚠️⚠️ **CRITICAL: No courses defined**

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 502 AND deleted_at IS NULL;
```
- Total dishes: 0 ⚠️⚠️⚠️ **CRITICAL: No dishes in database**

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 502 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 0 ⚠️⚠️⚠️
- **CRITICAL ISSUE:** No courses and no dishes exist

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 502 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://newhongkongchinese.ca/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Chef's Special (13 items)
  - Combination Plates (12 items)
  - Family Dinners (8 items)
  - Appetizers (9+ items with sizes)
  - Soups (multiple items)
  - Fried Rice (multiple items)
  - Oriental Style Rice (multiple items)
  - Chop Suey (multiple items)
  - Chicken (multiple items)
  - Beef (multiple items)
  - Pork (multiple items)
  - Vegetarian Dishes (multiple items)
  - Noodles (80+ items including various styles)
  - Hot and Spicy (Mild) (13+ items)
  - Miscellaneous (multiple items)
  - Seafood (multiple items)
  - Egg Foo Young (7 items)
  - Beverages (5 items)
- **Estimated Total Items:** 150+ dishes on live menu
- **Database Has:** 0 dishes (100% of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - **Restaurant was mis-marked as `suspended` in database, preventing menu data migration**. Live menu has 150+ items across 18+ courses, but database contains 0 dishes. Restaurant is listed as **active** in verified billing list (billed in last 4 months) and has a fully functional online menu. Status mismatch needs correction (suspended → active). **Root Cause:** Restaurant was incorrectly marked as suspended during migration, so menu data was never imported. **URGENT:** (1) Update status from `suspended` to `active`, (2) Complete menu data migration required - 150+ dishes need to be imported, (3) Create 18+ courses based on live menu structure, (4) Assign all dishes to appropriate courses. No courses, no dishes, no modifiers found. **URGENT: Correct status and complete menu data migration immediately.**

#### New Mee Fung Restaurant 350 Booth St (Restaurant ID: 15)
**Status:** ⚠️ STATUS MISMATCH - All dishes assigned, status needs correction
**Date:** 2025-11-03
**Address:** 350 Booth St ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://newmeefung.com/?p=menu ✅ (VERIFIED - Full menu available, course structure matches)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%New Mee Fung%';
```
- Restaurant ID: 15
- Name: New Mee Fung Restaurant
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 15;
```
- Courses defined: 13 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 15 AND deleted_at IS NULL;
```
- Total dishes: 144 ✅
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 144 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 15 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 13 ✅
- Course distribution:
  - Specialty Soups: 3 dishes
  - Appetizers: 11 dishes
  - Fried Rice and Noodle: 4 dishes
  - Soups: 4 dishes
  - Noodle Soups: 23 dishes
  - Dish of Rice: 22 dishes
  - Vermicelli Bowl: 41 dishes
  - Vegetarian: 5 dishes
  - Side Orders: 18 dishes
  - Roll Up with Rice Paper: 0 dishes
  - Beverages: 4 dishes
  - Coffee and Tea: 2 dishes
  - Bubble Tea: 7 dishes
- **✅ All dishes properly assigned to courses**

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 15 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://newmeefung.com/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Verification:**
  - Live menu courses match database courses ✅
  - SPECIALTY SOUPS (database: Specialty Soups) ✅
  - APPETIZERS (database: Appetizers) ✅
  - FRIED RICE and NOODLE (database: Fried Rice and Noodle) ✅
  - SOUPS (database: Soups) ✅
  - NOODLE SOUPS (database: Noodle Soups) ✅
  - DISH OF RICE (database: Dish of Rice) ✅
  - VERMICELLI BOWL (database: Vermicelli Bowl) ✅
  - ROLL UP WITH RICE PAPER (database: Roll Up with Rice Paper) ✅
  - VEGETARIAN (database: Vegetarian) ✅
  - SIDE ORDERS (database: Side Orders) ✅
  - Database also has: Beverages, Coffee and Tea, Bubble Tea (not shown in main menu navigation but present in menu)

**Result:** ✅ All 144 dishes properly assigned to 13 courses. Course structure matches live menu perfectly. Status mismatch needs correction (suspended → active). Restaurant is listed as **active** in verified billing list (billed in last 4 months) but database shows `suspended`. No modifiers found. **ACTION REQUIRED:** Update status from `suspended` to `active` to match verified billing list.

#### New Mukut Restaurant Indian Cuisine 1968 Portobello Blvd (Restaurant ID: 234)
**Status:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - No dishes, no courses, status mismatch
**Date:** 2025-11-03
**Address:** 1968 Portobello Blvd ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://mukutorleans.menu.ca/?p=menu ✅ (VERIFIED - Full menu available)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%New Mukut%';
```
- Restaurant ID: 234
- Name: New Mukut Restaurant Indian Cuisine
- Status: suspended ⚠️ (does NOT match verified billing list)
- **Issue:** Listed in verified billing list as **active** (billed in last 4 months) but database shows `suspended`

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 234;
```
- Courses defined: 0 ⚠️⚠️⚠️ **CRITICAL: No courses defined**

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 234 AND deleted_at IS NULL;
```
- Total dishes: 0 ⚠️⚠️⚠️ **CRITICAL: No dishes in database**

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 234 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 0 ⚠️⚠️⚠️
- **CRITICAL ISSUE:** No courses and no dishes exist

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 234 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://mukutorleans.menu.ca/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Found on Live Menu:**
  - Appetizers (6 items: Papadum, Onion Bhaji, Vegetable Samosas, Sheek Kabab, Chicken Tikka)
  - Soups (2 items: Mulligatawny Soup, Dall Soup)
  - Sundries (5 items: Yoghurt, Aachar, Cucumber Raita, Mango Chutney, Onion Salad)
  - Tandoori Dishes (4 items: Chicken Tandoori, Shrimp Tandoori, Chicken Tikka Platter, Lamb Tikka Platter)
  - Curries (20+ items: Shrimp/Chicken/Lamb/Beef Curry, Bhuna varieties, Sag varieties, Madras varieties, Vindaloo varieties, Pasanda varieties, Tikka Masala varieties, Korma varieties, Rogan Josh, Saag varieties)
  - Our Other Tasteful Entrees (multiple items)
  - Vegetable Dishes (13+ items: Aloo Gobi, Aloo Peas, Matar Paneer, Sag Aloo Bahji, Sag Paneer, Begun Bhaji, Cauliflower Bhaji, Aloo Gobi, Tarka Daal, Bombay Potato, Chana Masala, Panner Masala)
  - Biryanis (5 items: Chicken, Lamb, Beef, Shrimp, Vegetable Biryani)
  - Rice Dishes (3 items: Palao Rice, Vegetable Rice, Peas Palao)
  - Indian Breads (5 items: Paratha, Stuffed Paratha, Naan, Garlic Naan, Puri)
  - Dinner Combination for Two (5 items with modifiers)
  - Desserts (2 items: Gulab Jamun, Rashmalay)
  - Drinks (11 items: Coke, Pepsi, Diet Coke, Diet Pepsi, 7 Up, Sprite, Iced Tea, Ginger Ale, Club Soda, Tonic Water, Bottled Water, Mango Lassi)
- **Estimated Total Items:** 100+ dishes on live menu
- **Database Has:** 0 dishes (100% of menu missing)

**Result:** ⚠️⚠️⚠️ CRITICAL DATA MIGRATION ISSUE - **Restaurant was mis-marked as `suspended` in database, preventing menu data migration**. Live menu has 100+ items across 13+ courses, but database contains 0 dishes. Restaurant is listed as **active** in verified billing list (billed in last 4 months) and has a fully functional online menu. Status mismatch needs correction (suspended → active). **Root Cause:** Restaurant was incorrectly marked as suspended during migration, so menu data was never imported. **URGENT:** (1) Update status from `suspended` to `active`, (2) Complete menu data migration required - 100+ dishes need to be imported, (3) Create 13+ courses based on live menu structure, (4) Assign all dishes to appropriate courses. No courses, no dishes, no modifiers found. **URGENT: Correct status and complete menu data migration immediately.**

#### Number One Chinese Take Out 988 Wellington St (Restaurant ID: 65)
**Status:** ⚠️ MINOR ISSUE - 5 dishes in Uncategorized, needs reassignment
**Date:** 2025-11-03
**Address:** 988 Wellington St ✅ (matches verified list)
**Assignee:** Brian (B)
**Menu link:** https://no1chinesefoodottawa.com/?p=menu ✅ (VERIFIED - Full menu available, course structure matches)

**Step 1: Restaurant Status**
```sql
SELECT id, name, status FROM menuca_v3.restaurants WHERE name ILIKE '%Number One Chinese%';
```
- Restaurant ID: 65
- Name: Number One Chinese Take Out
- Status: active ✅ (matches verified billing list)

**Step 2: Check Courses**
```sql
SELECT COUNT(*) FROM menuca_v3.courses WHERE restaurant_id = 65;
```
- Courses defined: 17 ✅

**Step 3: Check Dishes**
```sql
SELECT
    COUNT(*) as total_dishes,
    COUNT(CASE WHEN course_id IS NULL THEN 1 END) as null_course_id_count,
    COUNT(CASE WHEN course_id IS NOT NULL THEN 1 END) as has_course_id_count
FROM menuca_v3.dishes
WHERE restaurant_id = 65 AND deleted_at IS NULL;
```
- Total dishes: 126 ✅
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with course_id: 126 (100%) ✅

**Step 4: Check Course Structure**
```sql
SELECT c.id, c.name, COUNT(d.id) as dish_count FROM menuca_v3.courses c LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL WHERE c.restaurant_id = 65 GROUP BY c.id, c.name ORDER BY c.display_order;
```
- Courses defined: 17 ✅
- Course distribution:
  - Full Course Dinners: 8 dishes
  - Combination Plates: 1 dish
  - Thai Special: 8 dishes
  - Appetizers and Side Orders: 10 dishes
  - Soups: 4 dishes
  - Fried Rice: 9 dishes
  - Fried Noodles: 9 dishes
  - Chow Mein: 7 dishes
  - Egg Foo Young: 6 dishes
  - Moo She: 4 dishes
  - Chicken: 15 dishes
  - Beef: 7 dishes
  - Pork: 3 dishes
  - Szechuan Cuisine: 11 dishes
  - Seafood: 11 dishes
  - Vegetables and Bean Curd: 8 dishes
  - Uncategorized: 5 dishes ⚠️
- **MINOR ISSUE:** 5 dishes assigned to "Uncategorized" course need reassignment

**Step 5: Check Modifiers**
```sql
SELECT 
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dm.dish_id) as dishes_with_modifiers
FROM menuca_v3.dish_modifiers dm
WHERE dm.restaurant_id = 65 AND dm.deleted_at IS NULL;
```
- Total modifiers: 0
- Dishes with modifiers: 0

**Menu Status Check:**
- Menu URL: https://no1chinesefoodottawa.com/?p=menu
- **Status:** ✅ Active online ordering menu available
- **Course Structure Verification:**
  - Live menu courses match database courses ✅
  - Full Course Dinners ✅
  - Combination Plates ✅
  - Thai Special ✅
  - Appetizers and Side Orders ✅
  - Soups ✅
  - Fried Rice ✅
  - Fried Noodles ✅
  - Chow Mein ✅
  - Egg Foo Young ✅
  - Moo She ✅
  - Chicken ✅
  - Beef ✅
  - Pork ✅
  - Szechuan Cuisine ✅
  - Seafood ✅
  - Vegetables & Bean Curd (database: Vegetables and Bean Curd) ✅

**Result:** ✅ Good progress - 121 dishes properly assigned to 16 courses. Course structure matches live menu perfectly. Minor issue: 5 dishes incorrectly assigned to "Uncategorized" course need reassignment to appropriate courses. No modifiers found. **ACTION REQUIRED:** Reassign 5 dishes from "Uncategorized" to appropriate courses based on dish names.

---

### Restaurants with No Courses Defined

#### Aahar The Taste of India (Restaurant ID: 561)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03

**Issue:** Restaurant has 108 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this Indian restaurant (e.g., Appetizers, Curries, Tandoori, Breads, Desserts, Drinks)
2. Then re-run course assignment process

#### River Pizza (Restaurant ID: 952)
**Status:** ⚠️ NEEDS WORK - 71 dishes, 12 courses defined, 100% unassigned
**Date:** 2025-11-03
**Address:** Verified active in billing list

**Details:**
- Total dishes: 71
- Dishes with course_id: 0 (0%) ❌
- Dishes with NULL course_id: 71 (100%) ⚠️
- Courses defined: 12
- Status: active ✅

**Courses Available:**
- Specials
- Pizzas
- Twin Pizzas
- Appetizers
- Big Salads
- Chicken Wings
- Submarines
- Canadian Food
- Donairs
- Pasta
- Desserts
- Drinks

**Action Required:** Assign all 71 dishes to appropriate courses from the 12 available courses.

#### Amicci Pizza (Restaurant ID: 735)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03

**Issue:** Restaurant has 196 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this pizza restaurant (e.g., Appetizers, Pizza, Pasta, Salads, Desserts, Drinks)
2. Then re-run course assignment process

#### Aroy Thai (Restaurant ID: 607)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03

**Issue:** Restaurant has 39 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this Thai restaurant (e.g., Appetizers, Soups, Curries, Noodles, Rice Dishes, Desserts, Drinks)
2. Then re-run course assignment process

#### Asia Garden Ottawa (Restaurant ID: 630)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03

**Issue:** Restaurant has 154 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this Chinese restaurant (e.g., Appetizers, Soups, Chicken, Beef, Seafood, Vegetarian, Rice/Noodles, Desserts, Drinks)
2. Then re-run course assignment process

---

### Restaurants with No Dishes

### Restaurants Not Found in Database

<<<<<<< HEAD

**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


#### Chances R' East (Restaurant ID: Unknown)
**Status:** 🚫 Restaurant does not exist in database
**Date:** 2025-11-03 (Re-verified)

**Issue Found:**
- Listed in Restaurants-active.md as active
- No restaurant found in database with name matching "Chances R' East" or variations

**Action Taken:**
- Searched menuca_v3.restaurants: No results
- Searched staging.v1_restaurants: No results
- Searched staging.v2_restaurants: No results
- Variations searched: "%Chances%", "%R%East%", "%R East%", "%east%" with apostrophe
- No matches in any database

**Resolution Needed:**
1. Verify restaurant name spelling with business owner
2. Check if restaurant exists under completely different name
3. If restaurant should exist, may need to be created from scratch


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


#### Chances R' West (Restaurant ID: Unknown)
**Status:** 🚫 Restaurant does not exist in database
**Date:** 2025-11-03 (Re-verified)

**Issue Found:**
- Listed in Restaurants-active.md as active
- No restaurant found in database with name matching "Chances R' West" or variations

**Action Taken:**
- Searched menuca_v3.restaurants: No results
- Searched staging.v1_restaurants: No results
- Searched staging.v2_restaurants: No results
- Variations searched: "%Chances%", "%R%West%", "%R West%", "%west%" with apostrophe
- No matches in any database

**Resolution Needed:**
1. Verify restaurant name spelling with business owner
2. Check if restaurant exists under completely different name
3. If restaurant should exist, may need to be created from scratch


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


#### Wok Bistro Noodles Bar and Grill (TEST) (1615 Orleans Blvd.)
**Status:** 🚫 REMOVED FROM ACTIVE LIST | ❌ NOT FOUND
**Date:** 2025-11-03

**Issue:** Restaurant listed in Restaurants-active.md but does not exist in menuca_v3.restaurants table.
- Note: Name includes "(TEST)" - may be a test restaurant that was never migrated
- Searched for variations: "Wok Bistro", "Wok", "Bistro" - no matches found
- Found other "Wok" restaurants but none match this name/address

**Action Taken:** None - restaurant does not exist in database.

**Resolution Needed:**
1. Verify if this test restaurant should be in database
2. Check if name differs in database vs active list
3. Determine if test restaurant was intentionally excluded from migration

---


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


### ⏸️ Restaurants with Suspended/Pending Status

#### Vanier Pizza & Subs (Restaurant ID: 62)
**Status:** ⚠️ LEFT PLATFORM - On RestaurantPlus.net | ⚠️ SKIP COURSE ASSIGNMENT
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status: suspended
- **SUSPICIOUS:** Only 1 dish in database (impossible for a pizza & subs restaurant)

**Current Database Status:**
- Total dishes: 1
- Courses defined: 1
- Dishes with course_id: 1 (100%) ✅
- Status: suspended

**⚠️ PLATFORM NOTE:** Restaurant has LEFT our platform and is now using **RestaurantPlus.net/OlivePOS** (CONFIRMED). The suspended status and single dish reflect that they left mid-migration. Restaurant should be removed from active list.

**Action Taken:** SKIP - Restaurant no longer on our platform. Do not proceed with course assignment.

---


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


#### Wow Sushi 50, rue Rachel E (Restaurant ID: 356)
**Status:** 🚫 REMOVED FROM ACTIVE LIST | ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ CRITICAL DATA ISSUE
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as **active** (user-provided list - should be active)
- **Database status: suspended** (needs correction to match active list)
- **CRITICAL:** 0 dishes in database (impossible for a sushi restaurant)

**Current Database Status:**
- Total dishes: 0
- Courses defined: 0
- Status: suspended

**🚨 CRITICAL DATA ISSUE:**
A sushi restaurant should have dozens of dishes (sushi rolls, nigiri, sashimi, appetizers, soups, bento boxes, etc.). Having 0 dishes indicates the menu data was never migrated or was deleted.

**Resolution Needed:**
1. Verify if restaurant should be active (likely yes, since listed in active list)
2. **URGENT:** Menu migration required - restaurant has no menu data
3. Cannot proceed with course assignment until menu is migrated

---


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


=======
>>>>>>> 5c2e923177459d5d17fbf94ab1c25a5227c5c348
### ✅ Restaurants with Status Corrected

#### Xtreme Pizza 125 Preston St (Restaurant ID: 38)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active | ⚠️ CRITICAL DATA ISSUE
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Restaurant name: "Preston Pizza (CHANGED TO XTREME PIZZA)"
- Status mismatch identified

**Action Taken:**
- Updated restaurant status from 'suspended' to 'active'
- Verified update successful

**🚨 CRITICAL DATA ISSUE DISCOVERED:**
- **Database has only 6 dishes** (Club, Ham and Cheese, Pepperoni and Cheese, Preston Pizza's Special, Steak, Steak and Pepperoni)
- **Actual menu** (https://mottawa.xtremepizzaottawa.com/menu) shows a full-service pizza restaurant with **15+ categories and 100+ dishes**:
  - Appetizers (Xtreme Platter, Cheese Sticks, Jalapeno Slammers, Zucchini, Garlic Bread, Burgers, Nachos, Fries, Onion Rings)
  - Poutine (Regular, Italian, Canadian, Donair)
  - Wings (Chicken Wings, Boneless Dippers - multiple sizes)
  - Pizza (Plain, 1-3 Toppings, Hawaiian, Canadian, Combination, Meat Lovers, House Special, Vegetarian, Chicken, Donair, Steak, Greek, Italian, Hot Spicy, New York Style, Xtreme Supreme - multiple sizes)
  - Donairs and Shawarma (Sandwiches, Platters, Deals)
  - Hot Subs (8+ varieties)
  - Cold Subs (4 varieties)
  - Platters (10+ varieties)
  - Salads (Garden, Greek, Caesar, Chicken Caesar, Xtreme)
  - Pasta (Spaghetti, Lasagna, Chicken Parmigiana)
  - Twin Pizzas (Deals)
  - Xtreme Pizza Deals (3 deals)
  - Pasta Deals
  - Xtreme Sub Deal
  - Desserts (Cheesecakes)
  - Drinks (20+ varieties)

**Current Database Status:**
- Total dishes in database: 6
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 6 (100%) ✅
- **MASSIVE DATA GAP:** ~95% of menu items missing from database

**Result:** Status corrected to active. **CRITICAL:** Menu data migration incomplete - restaurant needs full menu migration before course assignment can proceed. This is a data migration issue, not a course assignment issue.

---

### Restaurants with Uncategorized course:

#### Aylmer BBQ (Restaurant ID: 69)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Status mismatch identified

**Action Taken:**
- Updated restaurant status from 'suspended' to 'active'
- Verified update successful

**Menu Status:**
- Total dishes: 9
- Courses defined: 1 (Uncategorized - ID: 1536)
- Dishes with course_id: 9 (100%) ✅
- All dishes already properly assigned

**Course Distribution:**
- Uncategorized (1536): 9 dishes
  - Ail
  - French
  - Grande Special
  - Grande Spéciale
  - Greek
  - Italian
  - Meat Lover
  - Ranch
  - Vegetarian

**Result:** Restaurant status corrected. No course assignment work needed.

#### Carlo's Pizza (Restaurant ID: 124)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-03

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Status mismatch identified

**Action Taken:**
- Updated restaurant status from 'suspended' to 'active'
- Verified update successful

**Menu Status:**
- Total dishes: 3
- Courses defined: 1 (Uncategorized - ID: 1834)
- Dishes with course_id: 3 (100%) ✅

**Course Distribution:**
- Uncategorized (1834): 3 dishes
  - Club Sub 9" HIDE
  - Kafta Sandwich Combo
  - Vegetarian 9" HIDE

**Result:** Restaurant status corrected. All dishes already properly assigned.

---

#### Souvlaki Souvlaki (Restaurant ID: 836)
**Status:** ⚠️ SKIPPED - Already assigned | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03

**Details:**
- Total dishes in database: 1 ⚠️ (Only "Steamed Rice")
- Dishes with course_id: 1 (100%)
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course (1691)

**🌐 Online Menu Available:** https://souvlakisouvlaki.com/?p=menu
**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **LARGE MENU** online, but database only has 1 dish. This is a critical data migration issue similar to Xtreme Pizza.

**Actual Menu Structure (from online menu):**
- **Grand Opening Specials** - Two Beef Gyro Wraps, Two Chicken Souvlaki Wraps, Two Greek Salads
- **Appetizers** - Tzatziki, Calamari, Feta Cheese and Olives, Greek Potatoes, Rice, Spanakopita, Dolmades
- **Salads** - Greek Salad (Small/Large), House Salad (Small/Large)
- **Pita Wraps** - Chicken Souvlaki Wrap, Lamb Souvlaki Wrap, Beef Gyro Wrap
- **Souvlaki Platters** - Chicken Souvlaki Platter, Lamb Souvlaki Platter, Shrimp Souvlaki Platter, Calamari Platter, Beef Gyros Platter
- **Burgers** - Burger (with feta, tzatziki, Greek potatoes)
- **Subs** - Meatball Sub
- **Dessert** - Baklava
- **Drinks** - 591ml Pop (Pepsi varieties)

**Action Taken:** Skipped - all dishes already have course_id. **ACTION REQUIRED:** Full menu migration needed before proper course assignment can proceed. This is a data migration issue, not a course assignment issue.

**Action Taken:** Skipped - all dishes already have course_id. **ACTION REQUIRED:** Restaurant should be removed from `Restaurants-active.md` list or marked as inactive/left platform.

**Note:** There is also "New Shawarma King" (ID: 27) at 530 Rideau St (suspended) - different restaurant

#### Shaan Tandoori (Restaurant ID: 269)
**Status:** ✅ SKIPPED - Already has complete course assignments
**Date:** 2025-11-03
**Address:** 2550, boul Lapinière, Brossard ✅ (matches active list)

**Details:**
- Total dishes: 194 ✅ (Good count - full menu)
- Dishes with course_id: 194 (100%) ✅
- Courses defined: 24 ✅ (Well-structured menu)
- Status: active ✅ (matches active list)

**Menu Sample (Indian cuisine):**
- Appetizers (Dahl Soup, Onion Bhaji)
- Curries (Butter Chicken, Chicken Tikka Masala, Lamb Pasanda, etc.)
- Tandoori items (Chicken Tandoori, Chicken Tikka, Lamb Tikka, Platter Tandoori)
- Khorai dishes (Lamb, Beef, Chicken, Shrimp, Vegetable)
- Combos (Combo Bombay Special, Family Menu, Table d'Hôte)
- Desserts (Gulab Jamun, Payesh Rice Pudding, Kheer Rice Pudding)
- Drinks (Water, Coke, Sprite, 7-Up)

**Action Taken:** Skipped - all dishes already have course_id assigned and properly categorized. Restaurant has complete, well-structured menu with proper course organization.

#### Season's Pizza (Restaurant ID: 83)
**Status:** ⚠️ SKIPPED - Already assigned | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 725 Somerset Street West, Ottawa ✅ (matches active list)

**Details:**
- Total dishes in database: 1 ⚠️ (Only "Spaghatti Pizza")
- Dishes with course_id: 1 (100%)
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: active ✅ (matches active list - confirmed active with Google page linking to our platform)

**🌐 Online Menu Available:** https://seasonspizzaottawa.ca/?p=menu
**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 1 dish. This is a critical data migration issue similar to Xtreme Pizza and Souvlaki Souvlaki.

**Actual Menu Structure (from online menu):**
- **Season's Specials** - 6 combo deals (Pizza + Wings, Pizza + Poutine, Family Special, etc.)
- **Two for One Pizza** - 14 varieties (Plain, 1-3 Toppings, Combination, Canadian, Hawaiian, Chef Special, Meat Lovers, Meat Man, Season's Special, Season's Super Special, Italian, Burger, Vegetarian, Spaghatti Pizza)
- **Single Pizza** - Various sizes and toppings
- **Gourmet Pizza** - Multiple specialty pizzas
- **Submarines** - Various sub options
- **Donairs** - Donair options
- **Platters** - Multiple platter options
- **Salads** - Various salads
- **Seafood** - Seafood items
- **Garlic Bread** - Garlic bread options
- **Finger Food Specials** - Appetizers and finger foods
- **Chicken Tender Ribs** - Chicken items
- **Pasta** - Pasta dishes
- **Mexican Food** - Mexican items
- **Side Orders** - Fries, onion rings, burgers, cheese sticks, nachos, etc.
- **Desserts** - Mini donuts and churros (multiple flavors and sizes)
- **Drinks** - Various soft drinks and water

**Dishes Found in Database:**
- Spaghatti Pizza (only 1 dish - represents <1% of actual menu)

**Action Taken:** Skipped - all dishes already have course_id. **ACTION REQUIRED:** Full menu migration needed before proper course assignment can proceed. This is a data migration issue, not a course assignment issue.

**Note:** There is also another "Season's Pizza" (ID: 856) at 826 Somerset St W (suspended) - different restaurant

#### Sala Thai (Restaurant ID: 745)
**Status:** ⏳ NEEDS WORK - 94 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 2666 Alta Vista Dr, Ottawa ✅ (matches active list)

**Details:**
- Total dishes: 94 ✅ (Good count - full Thai menu)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 94 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅ (matches active list)

**Menu Structure Analysis:**
Thai restaurant with numbered dish codes (1., 2., 3., etc.). Sample dishes show:
- Appetizers (Pao Pia Goong, Pao Pia Vegetables, Satay, Tofu Tod)
- Soups (Tom Yum Goong or Gai, Tom Kha Goong or Gai, Gaeng Jued Woonsen)
- Salads (Yum Ma-Muang, Yum Woonsen, Som Tom, Nuea Nam Tok, Lapp)
- Stir-fried dishes (Pad Tofu, Pad Pak Raum Mit, Pad Bai Gra Prow, Pad Preow Warn)
- Curries (Gaeng Pak, Gaeng Pak with Tofu)
- Seafood (Pla Lad Prig, Pad Pak Talae, Goong Pad Med Ma-Muang, Goong Pad Ma-Khua Yao)
- Specialty dishes (Sala Sizzling, Tod Gratiam Prik Thai, Tao-Hu Ob Mor Din)
- Some dishes marked "HIDE" (hidden from menu)

**🌐 Online Menu Available:** https://salathaicuisine.menu.ca/?p=menu
**Menu Structure (from online menu):**
The restaurant has a well-organized menu structure with the following courses:
- **Family Dinner Feasts** - Combo meals for 2 or 4 people
- **Daily Luncheon Specials** - Lunch specials (11:30am-2pm)
- **Appetizers** - Spring rolls, satay, tofu (numbered 1-5)
- **Soup** - Tom Yum, Tom Kha, Gaeng Jued Woonsen (numbered 6-8)
- **Yum (Salad)** - Thai salads (numbered 9, 12-13)
- **Vegetarian** - Vegetarian dishes (numbered 16-19)
- **Seafood** - Seafood dishes (numbered 20-25)
- **Fried Rice & Noodles** - Pad Thai, Pad Kee Mao, Pad Siew, etc. (numbered 32-36)
- **Curries** - Red curry, green curry, Panang, Gaeng Garee (numbered 38-42)
- **Chicken, Beef & Pork** - Meat dishes (numbered 44-47)
- **Side Orders** - Steamed rice options
- **Desserts** - Tapioca pudding, chocolate cake
- **Drinks** - Soft drinks, water, Perrier
- **Beer** - Various beer options

**Action Required:**
1. Create courses matching the online menu structure:
   - Family Dinner Feasts
   - Daily Luncheon Specials
   - Appetizers
   - Soup
   - Yum (Salad)
   - Vegetarian
   - Seafood
   - Fried Rice & Noodles
   - Curries
   - Chicken, Beef & Pork
   - Side Orders
   - Desserts
   - Drinks
   - Beer
2. Assign 94 dishes to appropriate courses using numbered code patterns (matches online menu numbering)

**Resolution Needed:** CREATE COURSES (based on online menu structure) AND ASSIGN DISHES

**Note:** There is also another "Sala Thai" (ID: 940) at the same address (2666 Alta Vista Dr) with status "pending" - may be duplicate or pending activation.


#### Roulas Grecque et Pizza (Line 219)
**Status:** 🚫 REMOVED FROM ACTIVE LIST | ⚠️ NOT FOUND IN DATABASE - Has menu online | 🚨 DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 245, rue de Cannes, Gatineau ✅ (matches active list)

**Details:**
- Restaurant name from active list: "Roulas Grecque et Pizza"
- **🌐 Online Menu Available:** https://roulas.ca/?p=menu&lang=fr
- **RESTAURANT EXISTS AND HAS MENU WITH US** (user verified)
- Searched database for variations: "Roulas Grecque", "Roula Grec", "Grecque Pizza"
- Found restaurants at same address (245, rue de Cannes):
  - Roulas Jus et Gelato (ID: 777) - active
  - Opa's (ID: 60) - suspended
- No exact match found for "Roulas Grecque et Pizza" in database

**🚨 DATA MIGRATION ISSUE:**
Restaurant exists and has a full menu online but is **NOT IN DATABASE**. This indicates:
- Restaurant was never migrated to menuca_v3, OR
- Restaurant is listed under a different name in database, OR
- Data migration was incomplete

**Menu Structure (from online menu - French):**
- Plus pour Moins (Deals - Family Shawarma Plate, Trio Sandwich, Trio Poutine, Trio Submarine, Family Special, Special Roula)
- Les Spécialités Roulas (Platters - 1 Brochette, Donair Beef, Chicken Shawarma, Marinated Chicken, Various Brochettes, Combos, Vegetarian)
- Les Sandwiches (Shawarma KETO, Souvlaki on Pita, Gyro, Vegetarian Gyro, Donair, Chicken Shawarma, Kafta on Pita, Vegetarian Pita, Club on Pita)
- Les Sous-Marins (Submarines - Club, Hot Chicken, Donair, Shawarma, Tuna, Veggie)
- A la Carte Pizza (Many varieties - Regular, All Dressed, Pepperoni, Hawaiian, Vegetarian, BBQ, Mexicali, Chef's Specialty, etc.)
- Kalzone (Create Your Own)
- Les Salades (Greek Salad, Caesar Salad, Fattoush - with/without chicken, VIP versions)
- Ailes (Wings - 6, 12, 24 pieces, Wing and Fries combo - Hot, BBQ, Honey Garlic)
- Poutines (Regular, Shawarma, Donair, Club)
- Les Desserts Roulas (Baklava)
- Boissons (Drinks - Pepsi, Diet Pepsi, 7 Up, Ginger Ale)

**Action Required:**
1. **URGENT:** Find restaurant in database (may be under different name) OR migrate restaurant data
2. Once found/migrated, create courses matching online menu structure
3. Assign dishes to courses

**Resolution Needed:** RESTAURANT DATA MIGRATION REQUIRED - Restaurant exists and has menu but not in database

#### Riverside Pizzeria (Restaurant ID: 978)
**Status:** ⚠️ SKIPPED - Already assigned | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 3679 Riverside Drive, Ottawa ✅ (matches active list)

**Details:**
- Total dishes in database: 2 ⚠️ (Only "The Perfect Combo Deal with PopCurds HIDE" and "Oh Sweet Vegan Pizza")
- Dishes with course_id: 2 (100%)
- Courses defined: 13 ✅ (Good course structure but very few dishes)
- All dishes assigned to courses ✅
- Status: active ✅ (matches active list)

**🌐 Online Menu Available:** https://m.riversidepizzeriaottawa.ca/menu
**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 2 dishes. Restaurant is using **OLD VERSION of mobile platform** (old-school Google mobile version with tables). This is a critical data migration issue - menu exists but hasn't been migrated to menuca_v3.

**Actual Menu Structure (from online menu):**
- **Specials** - Melina's Famous Calzones, 30 Wings Special
- **Pizza** - 25+ varieties (Riverside Special, Canadian, Vegetarian, Greek, Meat Lovers, Santina, Aloha, Hawaiian Island, Parmesan Chicken, Steak and Veggie, Tango Special, Combination, Deluxe, BBQ Chicken, Pepperoni Lovers, Double Trouble, Poutine Pizza, Prosciutto White Pizza, Godfather, La Margherita, Garlic Lovers, Dani Boy Special, New Yorker, Nacho Pizza, Woww Pizza, Soprano, Butter Chicken Pizza)
- **Build Your Own Pizza** - Plain, 1-3 Toppings (all sizes)
- **Toasted Subs** - 9 varieties (Big D's Favourites, Cheese Steak, Club Sub, Meatball Sub, Chicken Parmesan, Pizza Sub, Greek Sub, Heart Attack Supreme, Crispy Chicken Sub)
- **Pastas** - 6 varieties (Spaghetti with Meat Sauce, Chicken Parmesan, Lasagna, Riverside Lasagna, Fettuccine Alfredo, Tortellini Three Cheese)
- **Salads** - Chef's Salad, Greek Salad, Caesar Salad
- **Chicken Wings** - Classic, Breaded, Boneless (10/20/30 wings)
- **Platters** - 7 varieties (Hamburger, Cheeseburger, Bacon Cheeseburger, Cheddar & Mushroom Jalapeno Burger Melt, Club Sandwich, Chicken Fingers, Chicken Burger - all with fries)
- **Go Solo** - 4 burger options (Hamburger, Cheeseburger, Bacon Cheeseburger, Cheddar & Mushroom Jalapeno Burger Melt)
- **Sides** - Pop Curds, Onion Rings, French Fries, Daniel's Famous Poutine, Deep Fried Pickles, Jalapeno Poppers, Mac N Cheese Bites, Nachos, Chicken/Beef Nachos, Mozzarella Sticks, Zucchini Sticks, Garlic Sticks, Garlic Bread, Dipping Sauces
- **Desserts** - Nutella Calzone, Cinnamon Balls, Caramel Apple Cheesecake, Reese's Peanut Butter Blondie, Strawberry Cheesecake
- **Drinks** - Coke, Diet Coke, A&W Root Beer, Ginger Ale

**Dishes Found in Database:**
- The Perfect Combo Deal with PopCurds HIDE (only 2 dishes - represents <1% of actual menu)
- Oh Sweet Vegan Pizza

**Action Taken:** Skipped - all dishes already have course_id. **ACTION REQUIRED:** Full menu migration needed from old platform to menuca_v3 before proper course assignment can proceed. This is a data migration issue, not a course assignment issue.

**Note:** There is also another "Riverside Pizzeria" (ID: 133) at the same address (3679 Riverside Dr) with status "suspended" - may be duplicate or old entry.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


**🚫 REMOVED FROM ACTIVE LIST** - Restaurant not in verified billing list (last 4 months). Course assignment work can be skipped.


#### Restaurant Le Choix (Restaurant ID: 106)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 139, rue Principale, Gatineau ✅ (matches active list)

**Issue Found:**
- Listed in Restaurants-active.md as **active** (user-provided list - should be active)
- **Database status: suspended** (needs correction to match active list)
- **Restaurant is ACTIVE** - Google Business page links to our platform (user verified)

**🌐 Online Menu Available:** https://lechoixaylmer.com/?p=menu&lang=fr
**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 12 dishes (many marked HIDE). This is a critical data migration issue - menu exists but hasn't been fully migrated to menuca_v3.

**Current Database Status:**
- Total dishes in database: 12 ⚠️ (Only specials, many marked HIDE)
- Dishes with course_id: 12 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: suspended (needs correction to active)

**Actual Menu Structure (from online menu - French):**
- **Spéciale** - 5 pizza specials (A-E: Grande/Jumbo All Dressed, Two Medium/Large Combination, Two Gyros)
- **Pizza** - 13+ varieties (Simple, 1 Ingrédient, Combinée, Hawaïenne, Végétarienne, Le Choix Spécial, Fajita, Pizza Grecque, Meat Lover, Steak Pizza, Canadienne, Mexicaine, Pizza Alfredo - all sizes)
- **Apéritifs** - Appetizers (Calamar, Spanakopita, Tzatziki, etc.)
- **Salades** - Salads (Greek Salad, Caesar Salad, etc.)
- **Assiettes Souvlaki** - Souvlaki platters (various proteins)
- **Sélection le Choix** - Special selection items
- **Wraps** - Wrap options
- **Frites** - Fries and Poutine
- **Hamburgers** - Burgers (Hamburger, Chicken Burger, with/without platter)
- **Sandwiches Club** - Club sandwiches, chicken fingers, wings, fish & chips
- **Sous-Marins** - Submarines (9 varieties)
- **Keto** - Keto options (Pizza, Souvlaki, Shrimp, Gyros)
- **Desserts** - Baklava
- **Breuvage** - Drinks (Coke, Diet Coke, Ginger Ale, Root Beer, Orange Crush, Water)

**Dishes Found in Database (Only Specials):**
- Special 5/6: Two Medium/Large Pizzas (English/French versions, many marked HIDE)
- A-D: Large/Jumbo/Two Medium/Two Large Pizza varieties (All Dressed, Combination)

**Resolution Needed:**
1. **STATUS CORRECTION:** Update database status from `suspended` to `active`
2. **URGENT:** Full menu migration needed - restaurant has full menu online but only 12 special dishes in database
3. Once migrated, create proper courses matching online menu structure
4. Then assign all dishes to appropriate courses

#### Restaurant Chez Gerry (Restaurant ID: 109)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 9, rue Therien, Gatineau ✅ (matches active list)

**Issue Found:**
- Listed in Restaurants-active.md as **active** (user-provided list - should be active)
- **Database status: suspended** (needs correction to match active list)
- **Restaurant is ACTIVE** - Google Business page links to our platform (user verified)

**🌐 Online Menu Available:** https://chezgerry.ca/?p=menu&lang=fr
**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 24 dishes (appear to be pizza toppings/ingredients, not actual menu items). This is a critical data migration issue - menu exists but hasn't been fully migrated to menuca_v3.

**Current Database Status:**
- Total dishes in database: 24 ⚠️ (Only pizza toppings/ingredients, not actual menu items)
- Dishes with course_id: 24 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: suspended (needs correction to active)

**Actual Menu Structure (from online menu - French):**
- **Spéciale** - Combo Platter (Zucchini, onion rings, chicken fingers, cheese sticks, fries)
- **Pizza** - 10+ varieties (Fromage, Une Garniture, Hawaiian, Toute Garnie, Végétarienne, Grecque, Méditerranéenne, Aubergineanne, Spéciale Maison, Pizza Gerry - all sizes)
- **Mets Canadiens** - 9 Canadian dishes (Club Sandwich, Club Poutine, Chicken Fingers, Fish & Chips, Hamburger Steak, Hot Chicken, Shrimp Basket, Chicken Tortilla, Chicken Souvlaki)
- **Burgers** - 3 varieties (Hamburger, Cheeseburger, Chicken Burger - sandwich or platter)
- **Entrées** - Appetizers (Fries, Poutine, Italian Poutine, Onion Rings, Chicken Nachos, Vegetarian Nachos, Cheese Sticks, Chicken Fingers, Zucchini Sticks, Wings, Sauces)
- **Salades** - 6 varieties (Salade Gerry, Greek Salad, Caesar Salad, Caesar with Chicken, Fattouche, Chef Salad)
- **12" Sous Marins** - 7 varieties (Biftek, Meatballs, Pepperoni, Smoked Meat, Roast Beef, Pizza, House Combination)
- **Ailes de Poulet** - Wings (10/15/20 wings with fries, various sauces)
- **Donair** - Beef and Chicken (sandwich or platter)
- **Italienne** - 10 pasta dishes (Lasagna varieties, Spaghetti varieties, Ravioli, Cannelloni, Manicotti, Chicken/Veal Parmesan)
- **Desserts** - 4 varieties (Cheesecake, Lava Cake, Cookies & Cream Cake, Pecan Pie)
- **Breuvages** - Drinks (Pepsi, Diet Pepsi, Coke, Diet Coke, Sprite, 7 Up, Orange Crush, Root Beer, Ginger Ale, Water)

**Dishes Found in Database (Only Pizza Toppings/Ingredients):**
- Pizza base/toppings (One Topping, Pepperoni, Champignons, Sauce à la viande, Tomates, Oignons, Bacon, Fromage Extra, Olives, Poivrons Verts, Ananas, Ail, Poivrons Rouges, Fromage Feta, Jambon, Artichauts)
- Crust options (Croûte Mince, Croûte Régulière)
- Sauces (Ranch)
- Special deals (marked HIDE)

**Resolution Needed:**
1. **STATUS CORRECTION:** Update database status from `suspended` to `active`
2. **URGENT:** Full menu migration needed - restaurant has full menu online but only pizza toppings/ingredients in database (not actual menu items)
3. Once migrated, create proper courses matching online menu structure
4. Then assign all dishes to appropriate courses

#### Rangoli (Restaurant ID: 497)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 2491 St-Joseph Blvd, Ottawa ✅ (matches active list)

**Issue Found:**
- Listed in Restaurants-active.md as **active** (user-provided list - should be active)
- **Database status: suspended** (needs correction to match active list)
- **Restaurant is ACTIVE** - Google Business page links to our platform (user verified)
- **🌐 Online Menu Available:** https://rangoli.menu.ca/?p=menu

**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 14 dishes. This is a critical data migration issue - menu exists but hasn't been fully migrated to menuca_v3.

**Current Database Status:**
- Total dishes in database: 14 ⚠️ (Only combination dinners and a few vegetarian dishes)
- Dishes with course_id: 14 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: suspended (needs correction to active)

**Actual Menu Structure (from online menu):**
- **Lunch Special** - 4 combo options (A-D: Vegetarian, Chicken, Lamb/Beef, Seafood)
- **Express Lunch To Go** - 3 quick lunch options (Butter Chicken, Chicken Curry, Channa Masala with Rice)
- **Appetizers** - 12+ items (Samosas, Pakoras, Aloo Tikki, Channa Bhatura, etc.)
- **Indian Bread** - 12+ varieties (Naan, Parantha, Roti, Kulcha, etc.)
- **Soups** - 2 varieties (Mulligatawny, Dal Soup)
- **Tandoori Specialities** - 6+ items (Mixed Tandoori, Paneer Tikka, Tandoori Chicken, Chicken Tikka, Sheekh Kabob, Tandoori Shrimp)
- **Entrees** - Dozens of curry dishes (Chicken, Lamb, Beef, Seafood varieties)
- **Seafood Specialities** - Multiple seafood curry options
- **Vegetable Entrees** - 10+ vegetarian dishes (Malai Kofta, Kadhai Paneer, Muttar Paneer, Palak Paneer, etc.)
- **Rice Specialities** - 7 biryani varieties (Vegetable, Chicken, Shrimp, Lamb, Beef, Mixed)
- **Side Orders** - 6+ items (Mango Chutney, Rice, Papadum, Salad, Raita, Pickles)
- **Traditional Indian Desserts** - 2 items (Rasmalai, Gulab Jamun)
- **Combination Dinners** - 6 thali/dinner combos (including the ones in database)
- **Drinks** - 10+ items (Chai, Coffee, Lassi varieties, Soft drinks)
- **Red Wine** - 3 varieties
- **White Wine** - 2 varieties
- **Beer** - 5 varieties

**Dishes Found in Database (Only 14):**
- Combination Dinners (Thali Vegetarian/Non-Vegetarian, Dinner For Two, Prawn Thali, Rangoli Dinner)
- A few vegetarian entrees (Malai Kofta, Kadhai Paneer, Muttar Paneer, Okra Masala, Mushroom Matar, Palak Paneer, Mattar Palak, Aloo Saag)

**Resolution Needed:**
1. **STATUS CORRECTION:** Update database status from `suspended` to `active`
2. **URGENT:** Full menu migration needed - restaurant has full menu online (~100+ dishes) but only 14 dishes in database (represents <15% of actual menu)
3. Once migrated, create proper courses matching online menu structure (17+ categories)
4. Then assign all dishes to appropriate courses

#### Prima Pizza (Restaurant ID: 824)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ NEEDS PROPER COURSE STRUCTURE
**Date:** 2025-11-03
**Address:** 26 Northside Road, Ottawa ✅ (matches active list)
**🌐 Online Menu Available:** https://primapizza.ca/?p=menu

**Details:**
- Total dishes: 140 ✅ (Good count - full menu)
- Dishes with course_id: 140 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: active ✅ (matches active list)

**Actual Course Structure (from online menu):**
The restaurant has a well-organized menu with the following courses that need to be created:
1. **Deals** - Combo deals (Small Pizza 3 Toppings, XL Pepperoni Pizza, Mega Meal, Tiny Bites, Pizza and Wing Combo Deal)
2. **Pizzas** - Regular pizzas (Plain, Pepperoni, Combination, All Canadian, Tropical, Hawaiian, Meat Lovers, Prima Special, BBQ Chicken, BBQ Chicken Bacon, Hot BBQ Chicken, Mega-Meat, BC Deluxe, Vegetarian, Mediterranean, Spicy Beef, Sweet and Salty - all sizes Small/Medium/Large/X-Large)
3. **Indian Specialty Pizzas** - Indian-style pizzas (Butter Chicken Pizza, Chicken Tikka Pizza, Paneer Pizza, Aloo Tikka Pizza, Keema Pizza - all sizes)
4. **Appetizers** - Appetizers (Garlic Bread, Mozzarella Cheese Sticks, Zucchini, Breaded Mushroom Caps, Nachos varieties, Breaded Fried Dill Pickles, etc.)
5. **Chicken** - Chicken items (Wings varieties, Chicken Fingers, etc.)
6. **Burgers** - Burgers (Hamburger, Cheeseburger, Bacon Cheeseburger, Chicken Burger, Veggie Burger, Aloo Tiki Burger, Beyond Meat Burger - with/without COMBO)
7. **Hot Subs** - 13" subs (Pepperoni Pizza Sub, Club Sub, Crispy Chicken Sub, Veggie Sub, Aloo Tiki Sub, Philly Steak Sub, Turkey Sub, Ham Sub, Turkey and Ham Sub, Meatball Marinara Sub - with/without COMBO)
8. **Fresh Salads** - Salads (Greek Salad, Greek Salad with Chicken, Caesar Salad, Chicken Caesar Salad, House Salad)
9. **Dessert** - Desserts (New York Cheesecake varieties, Black Forest Cake, Decadent Chocolate Truffle Cake, Milk Shake varieties)
10. **Drinks** - Drinks (Juice varieties, Powerade, Monster, Bottled Soft Drinks, Nestea)

**Action Taken:** Skipped - all dishes already have course_id assigned.
**⚠️ REVIEW NEEDED:** With 140 dishes, restaurant needs proper course structure (currently all in "Uncategorized"). Should create the 10 courses listed above and reassign dishes accordingly.



#### PizzaRama (Restaurant ID: 716)
**Status:** ⚠️ SKIPPED - Already assigned | 🚨 CRITICAL DATA MIGRATION ISSUE
**Date:** 2025-11-03
**Address:** 253, boul Maloney, Gatineau ✅ (matches active list)
**🌐 Online Menu Available:** https://pizzaramagatineau.ca/?p=menu&lang=fr

**⚠️ CRITICAL DATA MIGRATION ISSUE CONFIRMED:** Restaurant is **VERY ACTIVE** with a **FULL MENU** online, but database only has 14 dishes. This is a critical data migration issue - menu exists but hasn't been fully migrated to menuca_v3.

**Current Database Status:**
- Total dishes in database: 14 ⚠️ (Only pizza toppings/ingredients and combo deals)
- Dishes with course_id: 14 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: active ✅ (matches active list)

**Actual Menu Structure (from online menu - Bilingual French/English):**
The restaurant has a comprehensive menu with the following courses:
1. **Spéciales** - Special combo deals (Petite/Moyenne/Grande Pizza et Ailes, Petite/Moyenne/Grande Pizza et Poutine)
2. **Pizzas** - 12+ pizza varieties (Fromage, Un Ingrédient, Combinée, Spécial du Chef, Super Deluxe, Rama Spécial, Hawaïenne, Végétarienne, Club Pizza, Mexicaine, Godzilla - all sizes Petit/Moyenne/Grande/Jumbo)
3. **Rama Grecque - Plats de Spécialités** - Greek specialty platters (Brochette de poulet marinée, Brochette de filet mignon, Brochette de souvlaki, Brochette de crevettes)
4. **Rama Grecque - Gyros** - Greek gyros (Souvlaki Poulet Sandwich, Gyros sandwich varieties, Combo options)
5. **Rama Grecque - Salades** - Greek salads (various salad options)
6. **À La Carte** - A la carte items
7. **Sous Marins** - Submarines (13" subs - Club, Hot Chicken, Veggie, Steak, etc.)
8. **Mets Italiennes** - Italian dishes (Spaghetti, Lasagna, Penne varieties, Fettuccine Alfredo, Veal Parmesan, Chicken Parmesan)
9. **Poutines** - Poutine varieties (Regular, With Chicken, With Smoked Meat, With Bacon, etc.)
10. **Mets Canadiens** - Canadian dishes (Hot Chicken, Doigts de Poulet, Club Sandwich, Hamburger Steak, Burgers, Appetizers, Wings, Fries, Salads, Nachos, Assiette varieties)
11. **Menu Pour Enfants** - Kids menu (Pogo et Frites, Croquettes de Poulet, Doigt de Poulet avec Pogo)
12. **Desserts** - Desserts (Gâteau au Chocolat, Tarte au Sucre)
13. **Breuvages** - Drinks (Perrier, Pepsi, Diet Pepsi, 7 Up, Ginger Ale, Crush varieties, Root Beer, Iced Tea, Cream Soda, Mountain Dew, Bubbly, Jus varieties, Aquafina)

**Dishes Found in Database (Only 14):**
- Pizza toppings/ingredients (Un Ingrédient, Légumes, Sauce, Fromage)
- Special combo deals (Petite/Moyenne/Grande Pizza et Ailes, Petite/Moyenne/Grande Pizza et Poutine)
- Drinks (Pepsi, Diet Pepsi, 7 Up, Diet 7 Up)

**Resolution Needed:**
1. **URGENT:** Full menu migration needed - restaurant has full menu online (~150+ dishes across 13 categories) but only 14 dishes in database (represents <10% of actual menu)
2. Once migrated, create proper courses matching online menu structure (13 categories)
3. Then assign all dishes to appropriate courses

#### Pizzalicious (Restaurant ID: 829)
**Status:** ⚠️ SKIPPED 
**Date:** 2025-11-03
**Address:** 1009 Merivale Rd, Ottawa ✅ (matches active list)

**Details:**
- Total dishes: 1 ⚠️⚠️⚠️ (EXTREMELY LOW - Only "Calzone")
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: active ✅ (but restaurant is no longer a client)

**Action Taken:** Skipped - all dishes already have course_id assigned.
**ACTION REQUIRED:** Restaurant should be removed from `Restaurants-active.md` list or marked as inactive/no longer a client. Database status should be updated from `active` to `suspended`.



#### Sushi Presse (Restaurant ID: 260)
**Status:** ⏳ NEEDS WORK - 354 dishes, 18 courses defined, 100% unassigned
**Date:** 2025-11-03

**Details:**
- Total dishes: 354 ✅ (Very large menu!)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 354 (100%) ⚠️
- Courses defined: 18 ✅ (Bilingual French/English)

**Courses Available:**
- Latest / Nouveautés
- Chef's Specialties / Spécialités du Chef
- Nigiri / Sashimi / Nigiri - Sashimi
- Hosomakis
- Maki Rice Paper / Maki Feuille de Riz
- Assorted Plates / Assietes Assorties
- Futomakis
- Makis
- Maki de Printemps / Spring Makis
- Maki de Tartare / Tartar Makis
- Salads / Salades
- Miso Soup / Soupes
- Sushi Desserts
- Pokebols
- Extras
- Drinks / Breuvages

**Action Required:**
1. Assign 354 dishes to appropriate courses using pattern matching
2. Use bilingual course names to match French/English dish names
3. Pattern matching should identify:
   - Sushi types (Hosomaki, Futomaki, Maki varieties, Nigiri, Sashimi)
   - Specialties (Chef's Specialties items)
   - Plates/Combos (Assorted Plates)
   - Salads, Soups, Poke bowls
   - Drinks, Desserts, Extras

**Resolution Needed:** ASSIGN 354 DISHES TO EXISTING COURSES

#### Sushiyana (Restaurant ID: 847)
**Status:** ⏳ NEEDS WORK - 252 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03

**Details:**
- Total dishes: 252 ✅ (Good count - full menu)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 252 (100%) ⚠️
- Courses defined: 0 ⚠️

**Menu Structure Analysis:**
Japanese/Korean fusion restaurant with mix of:
- Sushi items (Hosomaki varieties, California rolls, Unagi, Nigiri combos)
- Korean items (Bibimbap, Bulgogi, Bento boxes)
- Appetizers (Deep Fried items, Chicken Karaage, Poke bowls)
- Drinks (7 Up, Coke, Diet Coke, Alia Basil Seeds Juice)
- Vegetarian options (Vegetarian rolls, Burrito Végétarien)
- Specials (Sushiyana branded items)

**Action Required:**
1. Create courses for Japanese/Korean fusion restaurant:
   - Appetizers
   - Sushi (Hosomaki, California, Specialty Rolls)
   - Nigiri/Sashimi
   - Korean Dishes (Bibimbap, Bulgogi, Bento)
   - Poke Bowls
   - Vegetarian Options
   - Drinks
   - Specials/Combos
2. Assign 252 dishes to appropriate courses using pattern matching

**Resolution Needed:** CREATE COURSES AND ASSIGN DISHES

#### Al-s Drive In (Restaurant ID: 981)
**Status:** ✅ COMPLETE - Already audited (36 dishes, 6 courses)
**Date:** 2025-11-03
**Address:** 5474 Osgoode Main Street, Osgoode ✅ (matches verified list)

**Note:** Already completed in audit. Restaurant IS in verified billing list - was incorrectly flagged. Course assignment work already done.

#### Bobbie's Pizza & Subs (Restaurant ID: 45)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 1443 Ogilvie Rd, Ottawa ✅ (matches verified list)

**Issue Found:**
- Listed in verified billing list as **active** (billed in last 4 months)
- **Database status: suspended** (needs correction to match verified list)

**Current Database Status:**
- Total dishes: 6 ⚠️⚠️ (EXTREMELY LOW - only pizza toppings/modifiers)
- Dishes with course_id: 6 (100%) ✅
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course
- Status: suspended (needs correction to active)

**Menu Sample:**
- Only pizza toppings/modifiers found (Ham, No Mayo, Bacon, Anchovies, Tomatoes, No Lettuce)
- No actual pizza varieties, subs, or menu items

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 6 dishes and they're all pizza toppings/modifiers. This pattern suggests:
- **CRITICAL:** Incomplete menu migration (similar to Restaurant Chez Gerry pattern), OR
- Menu data was deleted, OR
- Restaurant may have a very limited menu (but unlikely for a pizza & subs restaurant)

**Resolution Needed:**
1. **STATUS CORRECTION:** Update database status from `suspended` to `active`
2. **URGENT:** Verify if restaurant has full menu online - may need menu migration
3. If menu is complete, create proper courses and assign dishes

#### Champa Thai Cuisine (Restaurant ID: 87)
**Status:** ⚠️ SKIPPED - 0 dishes | ⚠️ DATA ISSUE
**Date:** 2025-11-03
**Address:** 193 King Edward Ave ✅ (matches verified list)

**Details:**
- Total dishes: 0 ⚠️⚠️ (CRITICAL - No dishes in database)
- Courses defined: 13 ✅
- Status: active ✅ (matches verified list)

**⚠️ CRITICAL DATA ISSUE:** Restaurant has 0 dishes but 13 courses defined. This indicates menu data was deleted or never migrated.

#### Chances R' West
**Status:** ❌ NOT FOUND IN DATABASE
**Date:** 2025-11-03
**Address:** 1365 Woodroffe Avenue ✅ (matches verified list)

**Note:** Restaurant in verified billing list but not found in database. May need to be added/migrated.

#### China Moon (Restaurant ID: 641)
**Status:** ⏳ NEEDS WORK - 314 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 273 boul. St-René Ouest ✅ (matches verified list)

**Details:**
- Total dishes: 314 ✅ (Very large menu!)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 314 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅ (matches verified list)

**Note:** Found 3 entries (IDs: 641 active, 944 pending, 998 suspended). Using active one (ID: 641).

**Action Required:**
1. Create courses for Chinese restaurant
2. Assign 314 dishes to appropriate courses

#### Cosenza (Restaurant ID: 957)
**Status:** ⏳ NEEDS WORK - 561 dishes, 561 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 6505 Jeanne d'Arc Boulevard North ✅ (matches verified list)

**Details:**
- Total dishes: 561 ✅ (EXTREMELY LARGE MENU!)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 561 (100%) ⚠️
- Courses defined: 561 ⚠️⚠️ (Suspicious - 1 course per dish? Should be ~10-20 courses)
- Status: active ✅ (matches verified list)

**⚠️ PATTERN ALERT:** Restaurant has 561 courses - this suggests courses were created per dish rather than per category. Need to consolidate courses and reassign dishes.

**Action Required:**
1. Review course structure - likely needs consolidation
2. Reassign 561 dishes to proper course categories

#### Crispy's (Restaurant ID: 584)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 1433 Woodrofe ✅ (matches verified list)

**Details:**
- Total dishes: 1 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅ (matches verified list)

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a restaurant. Menu migration issue.

#### Crispy's Bank Street (Restaurant ID: 806)
**Status:** ⏳ NEEDS WORK - 123 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 2446 Bank Street ✅ (matches verified list)

**Details:**
- Total dishes: 123 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 123 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅ (matches verified list)

**Action Required:**
1. Create courses for restaurant
2. Assign 123 dishes to appropriate courses

#### Dumpling Bowl (Restaurant ID: 792)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 730 Somerset ✅ (matches verified list)

**Details:**
- Total dishes: 3 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 3 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅ (matches verified list)

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 3 dishes is extremely low for a restaurant. Menu migration issue likely.

#### Eastview Pizza (Restaurant ID: 28)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ DATA ISSUE
**Date:** 2025-11-03
**Address:** 251 Montreal Rd ✅ (matches verified list)

**Details:**
- Total dishes: 0 ⚠️⚠️ (CRITICAL - No dishes)
- Courses defined: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **CRITICAL:** 0 dishes in database - menu migration issue

#### Egg Roll Factory (Restaurant ID: 511)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 261 Centrepointe drive ✅ (matches verified list)

**Details:**
- Total dishes: 96 ✅ (Good count)
- Dishes with course_id: 96 (100%) ✅
- Courses defined: 16 ✅
- Status: active ✅ (matches verified list)

**Note:** Found duplicate entry - Wing Wah Take Out & Delivery (closed) also at same address (ID: 198, suspended).

#### Amicci Pizza (Restaurant ID: 735)
**Status:** ⏳ NEEDS WORK - 196 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 2 Boulevard Louise-Campagna ✅ (matches verified list)

**Details:**
- Total dishes: 196 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 196 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Action Required:** Create courses and assign 196 dishes

#### Aroy Thai (Restaurant ID: 607)
**Status:** ⏳ NEEDS WORK - 39 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 1 Rideaucrest Drive ✅ (matches verified list)

**Details:**
- Total dishes: 39 ✅
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 39 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Note:** Found 3 entries (IDs: 607 active, 938 pending, 995 suspended). Using active one (ID: 607).

**Action Required:** Create courses for Thai restaurant and assign 39 dishes

#### Asia Garden Ottawa (Restaurant ID: 630)
**Status:** ⏳ NEEDS WORK - 154 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 886 Dynes Road ✅ (matches verified list)

**Details:**
- Total dishes: 154 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 154 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Note:** Found 3 entries (IDs: 630 active, 942 pending, 996 suspended). Using active one (ID: 630).

**Action Required:** Create courses and assign 154 dishes

#### Aylmer BBQ (Restaurant ID: 69)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 134, rue Principale ✅ (matches verified list)

**Details:**
- Total dishes: 9 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Dishes with course_id: 9 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 9 dishes is very low for a BBQ restaurant. Menu migration issue likely.

#### Beneci Pizza (Restaurant ID: 241)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 4 Lorry Greenberg Dr ✅ (matches verified list)

**Details:**
- Total dishes: 1 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a pizza restaurant. Menu migration issue.

#### Capital Bites (Restaurant ID: 973)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 34 Grenfell Crescent ✅ (matches verified list)

**Details:**
- Total dishes: 129 ✅ (Good count)
- Dishes with course_id: 129 (100%) ✅
- Courses defined: 15 ✅
- Status: active ✅

#### Capri Pizza (Restaurant ID: 977)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 4000 Bridle Path Drive ✅ (matches verified list)

**Details:**
- Total dishes: 86 ✅ (Good count)
- Dishes with course_id: 86 (100%) ✅
- Courses defined: 11 ✅
- Status: active ✅

#### Carlo's Pizza (Restaurant ID: 124)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 60 Harmer Ave ✅ (matches verified list)

**Details:**
- Total dishes: 3 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 3 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 3 dishes is extremely low for a pizza restaurant. Menu migration issue.

#### Cathay Restaurants (Restaurant ID: 72)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 1423 Woodroffe Ave ✅ (matches verified list)

**Details:**
- Total dishes: 211 ✅ (Good count)
- Dishes with course_id: 211 (100%) ✅
- Courses defined: 31 ✅
- Status: active ✅

#### Centertown Donair & Pizza (Restaurant ID: 131)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 422 Bronson Ave ✅ (matches verified list)

**Details:**
- Total dishes: 26 ✅
- Dishes with course_id: 26 (100%) ✅
- Courses defined: 5 ✅
- Status: active ✅

#### Charm Thai Cuisine (Restaurant ID: 943)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 121 Preston Street ✅ (matches verified list)

**Details:**
- Total dishes: 69 ✅
- Dishes with course_id: 69 (100%) ✅
- Courses defined: 11 ✅
- Status: active ✅

#### Chicco Pizza & Shawarma Buckingham (Restaurant ID: 962)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 1009 Chemin de Masson ✅ (matches verified list)

**Details:**
- Total dishes: 24 ✅
- Dishes with course_id: 24 (100%) ✅
- Courses defined: 12 ✅
- Status: active ✅

#### Chicco Pizza Maloney (Restaurant ID: 964)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 842 Boulevard Maloney Est ✅ (matches verified list)

**Details:**
- Total dishes: 106 ✅
- Dishes with course_id: 106 (100%) ✅
- Courses defined: 15 ✅
- Status: active ✅

#### Chicco Pizza Shawarma Anger (Restaurant ID: 963)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 1096 Chemin de Montréal Ouest ✅ (matches verified list)

**Details:**
- Total dishes: 37 ✅
- Dishes with course_id: 37 (100%) ✅
- Courses defined: 13 ✅
- Status: active ✅

#### Chicco Pizza St-Louis (Restaurant ID: 967)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 1783 Rue Saint-Louis ✅ (matches verified list)

**Details:**
- Total dishes: 21 ✅
- Dishes with course_id: 21 (100%) ✅
- Courses defined: 10 ✅
- Status: active ✅

#### Chicco Pizza de l'Hopital (Restaurant ID: 966)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 405 Boulevard de l'Hôpital ✅ (matches verified list)

**Details:**
- Total dishes: 147 ✅
- Dishes with course_id: 147 (100%) ✅
- Courses defined: 12 ✅
- Status: active ✅

#### Chicco Shawarma Cantley (Restaurant ID: 961)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 435 Montée de la Source ✅ (matches verified list)

**Details:**
- Total dishes: 11 ⚠️ (Low but assigned)
- Dishes with course_id: 11 (100%) ✅
- Courses defined: 5 ✅
- Status: active ✅

#### Chicco Shawarma Maloney (Restaurant ID: 965)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 922 Boulevard Maloney Est ✅ (matches verified list)

**Details:**
- Total dishes: 8 ⚠️ (Low but assigned)
- Dishes with course_id: 8 (100%) ✅
- Courses defined: 7 ✅
- Status: active ✅

#### Colonnade Pizza - Bank St (Restaurant ID: 783)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 1500 Bank St ✅ (matches verified list)

**Details:**
- Total dishes: 5 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 5 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 5 dishes is extremely low for a pizza restaurant. Menu migration issue.

#### Colonnade Pizza - Carling Ave (Restaurant ID: 784)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 2140 Carling Ave ✅ (matches verified list)

**Details:**
- Total dishes: 1 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a pizza restaurant. Menu migration issue.

#### Colonnade Pizza - Greenbank Rd (Restaurant ID: 785)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 896 Greenbank Rd ✅ (matches verified list)

**Details:**
- Total dishes: 27 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Dishes with course_id: 27 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 27 dishes is low for a pizza restaurant. Menu migration issue likely.

#### Colonnade Pizza - Metcalfe (Restaurant ID: 196)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 280 Metcalfe ✅ (matches verified list)

**Details:**
- Total dishes: 10 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 10 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 10 dishes is extremely low for a pizza restaurant

#### Cuisine Bombay Indienne (Restaurant ID: 960)
**Status:** ⏳ NEEDS WORK - 161 dishes, 20 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 120 Rue Richelieu ✅ (matches verified list)

**Details:**
- Total dishes: 161 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 161 (100%) ⚠️
- Courses defined: 20 ✅
- Status: active ✅

**⚠️ PATTERN ALERT:** Restaurant has 20 courses defined but 0 dishes assigned. Courses exist but need to be assigned to dishes.

**Action Required:** Assign 161 dishes to existing 20 courses

#### Digby's Restaurant (Restaurant ID: 638)
**Status:** ⏳ NEEDS WORK - 89 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 300 Earl Grey Dr ✅ (matches verified list)

**Details:**
- Total dishes: 89 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 89 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Action Required:** Create courses and assign 89 dishes

#### Friendly Restaurant and Pizzeria (Restaurant ID: 730)
**Status:** ⏳ NEEDS WORK - 145 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 1756 Laurier St ✅ (matches verified list)

**Details:**
- Total dishes: 145 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 145 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Action Required:** Create courses and assign 145 dishes

#### Ginkgo Garden (Restaurant ID: 930)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows pending | ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 2225 Saint Laurent Boulevard ✅ (matches verified list)

**Details:**
- Total dishes: 146 ✅ (Good count)
- Dishes with course_id: 146 (100%) ✅
- Courses defined: 13 ✅
- Status: pending (needs correction to active)

**Note:** Found multiple entries (IDs: 930 pending, 105 suspended, 1000 suspended). Listed as active in verified billing but DB shows pending.

**Resolution Needed:** Update status from `pending` to `active`

#### Econo Pizza
**Status:** ❌ NOT FOUND IN DATABASE
**Date:** 2025-11-03
**Address:** 425, boul La Vérendrye E ✅ (matches verified list)

**Note:** Restaurant in verified billing list but not found in database. May need to be added/migrated.

#### Erman Pizza (Restaurant ID: 211)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 3628, av des Églises ✅ (matches verified list)

**Details:**
- Total dishes: 17 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Dishes with course_id: 17 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 17 dishes is low for a pizza restaurant

#### Greber Pizza et Shawarma (Restaurant ID: 736)
**Status:** ⏳ NEEDS WORK - 105 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03
**Address:** 761 Boulevard Saint-Joseph ✅ (matches verified list)

**Details:**
- Total dishes: 105 ✅ (Good count)
- Dishes with course_id: 0 (0%)
- Dishes with NULL course_id: 105 (100%) ⚠️
- Courses defined: 0 ⚠️
- Status: active ✅

**Action Required:** Create courses and assign 105 dishes

#### HaNoi Pho (Restaurant ID: 519)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 4312 Innes Road ✅ (matches verified list)

**Details:**
- Total dishes: 9 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Dishes with course_id: 9 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 9 dishes is very low for a Pho restaurant

#### Hong Kong Chinese Food Takeout (Restaurant ID: 160)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ DATA ISSUE
**Date:** 2025-11-03
**Address:** 800 Hunt Club Rd ✅ (matches verified list)

**Details:**
- Total dishes: 0 ⚠️⚠️ (CRITICAL - No dishes)
- Courses defined: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **CRITICAL:** 0 dishes in database - menu migration issue

#### House of Lasagna (Restaurant ID: 22)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 984 Merivale Rd ✅ (matches verified list)

**Details:**
- Total dishes: 1 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a restaurant

#### Hung Mein (Restaurant ID: 119)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 2567 Baseline Rd ✅ (matches verified list)

**Details:**
- Total dishes: 160 ✅ (Good count)
- Dishes with course_id: 160 (100%) ✅
- Courses defined: 16 ✅
- Status: active ✅

#### Imilio's Pizzeria (Restaurant ID: 7)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 110 Bearbrook Rd ✅ (matches verified list)

**Details:**
- Total dishes: 3 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 3 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**Note:** Found multiple entries (IDs: 7 active, 849 suspended, 1001 suspended). Using active one (ID: 7).

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 3 dishes is extremely low for a pizza restaurant. Menu migration issue.

#### Indian Punjabi Clay Oven (Restaurant ID: 180)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03
**Address:** 6-4055 Carling Ave. ✅ (matches verified list)

**Details:**
- Total dishes: 115 ✅ (Good count)
- Dishes with course_id: 115 (100%) ✅
- Courses defined: 11 ✅
- Status: active ✅

#### JC Royal Thai Cuisine (Restaurant ID: 646)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03
**Address:** 100 Jamieson Pkwy, Unit 11 ✅ (matches verified list)

**Details:**
- Total dishes: 1 ⚠️⚠️ (EXTREMELY LOW)
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a restaurant. Menu migration issue.

### JN Pizza (Restaurant ID: 328)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT | ⚠️ MIGRATED TO OLIVEPOS/RESTAURANTPLUS
**Date:** 2025-11-03
**Address:** 1663 Cyrville Rd ✅ (matches verified list)
**Menu Reference:** https://order.jnpizza.com/?p=menu

**Issue Found:**
- Listed in verified billing list as **active** (billed in last 4 months)
- **Database status: suspended** (needs correction to match verified list)
- **⚠️ MIGRATION NOTE:** Restaurant has moved to OlivePOS/RestaurantPlus but maintains a secondary site with our platform

**Menu Status:**
- Total dishes: 21 ⚠️⚠️ (SUSPICIOUSLY LOW - very low for a pizza restaurant)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 21 (100%) ✅
- Dishes with NULL course_id: 0 ✅

**Course Distribution:**
- Uncategorized (1711): 21 dishes
  - Includes: Pizza varieties (Greek Pizza, Manzo Pizza, Pollo Pizza), Sandwiches (Chicken Club, Turkey Club), Poutine varieties, Spaghetti dishes, Appetizers (Chicken Fingers, Tater Tots), Extras (Extra Cheese, Feta)

**⚠️ ISSUES:**
1. **STATUS CORRECTION NEEDED:** Listed in verified billing list as **active** but database shows `suspended` - needs update to `active`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 21 dishes is very low for a pizza restaurant. This suggests incomplete menu migration - verify if restaurant has full menu online
3. **MIGRATION STATUS:** Restaurant has moved to OlivePOS/RestaurantPlus but still maintains our platform - verify if this is intentional or if menu needs to be updated

**Resolution Needed:**
1. **STATUS CORRECTION:** Update database status from `suspended` to `active`
2. **URGENT:** Review live menu at https://order.jnpizza.com/?p=menu to verify course structure and dish count
3. If menu is complete, create proper courses based on live menu structure and assign dishes appropriately

### Joes Family Pizzeria (Restaurant ID: 636)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ NEEDS PROPER COURSE STRUCTURE
**Date:** 2025-11-03
**Address:** 284 Pembroke St W ✅ (matches verified list)
**Menu Reference:** https://joesfamilypizzeria.ca/?p=menu

**Menu Status:**
- Total dishes: 67 ✅ (Good count)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 67 (100%) ✅
- Dishes with NULL course_id: 0 ✅
- Status: active ✅

**Course Distribution:**
- Uncategorized (1743): 67 dishes
  - Includes: Pizza varieties (1-3 Toppings, Cup & Char Pepperoni, Hawaiian, Canadian, Deluxe, Specials), Fish & Chips, Sauces (BBQ, Honey Garlic, Donair, Hot sauce, etc.), Combo meals, Party packs

**Issue Found:**
- All 67 dishes are assigned to a single "Uncategorized" course
- Restaurant needs proper course structure created to organize menu better

**Resolution Needed:**
- Review live menu at https://joesfamilypizzeria.ca/?p=menu to identify proper course categories
- Create proper courses based on live menu structure (Pizza, Fish & Chips, Combos/Specials, Sauces/Extras) and reassign dishes appropriately

### Kabylie Pizza (Restaurant ID: 798)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ NEEDS PROPER COURSE STRUCTURE
**Date:** 2025-11-03
**Address:** 355 Bd Gréber ✅ (matches verified list)
**Menu Reference:** https://kabyliepizza.com/?p=menu&lang=fr

**Menu Status:**
- Total dishes: 36 ✅ (Acceptable count)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 36 (100%) ✅
- Dishes with NULL course_id: 0 ✅
- Status: active ✅

**Course Distribution:**
- Uncategorized (1837): 36 dishes
  - Includes: Pizza varieties (Canadienne, Hawaïenne, Pepperoni, Grecque, Pesto, Poulet BBQ, etc.), Combos (Combo 1-4, Pizza + Ailes), Pizza deals (2 Pizzas avec Trempettes), Specialty pizzas (Maison Kabyle, Fruits de Mer, Amateurs de légumes/viande)

**Live Menu Course Structure** (from https://kabyliepizza.com/?p=menu&lang=fr):
- Spéciaux Nouveau Départ (New Start Specials)
- Pizza et Ailes (Pizza and Wings)
- Combos
- Amuse-Gueules (Appetizers)
- Salades (Salads)
- Poulet (Chicken)
- Sous-Marins (Subs)
- Grillés au Four (Grilled)
- Pizzas
- Pizzas Gourmet
- Deux Pizzas (Two Pizzas)
- Deux Pizzas Gourmet (Two Gourmet Pizzas)
- Poutines Spécialité (Specialty Poutines)
- Assiettes (Platters)
- Desserts
- Boissons (Drinks)

**Issue Found:**
- All 36 dishes are assigned to a single "Uncategorized" course
- Bilingual menu (French/English) - restaurant needs proper course structure created
- **CRITICAL:** Database only has 36 dishes but live menu shows extensive menu with many more items - suggests incomplete menu migration

**Resolution Needed:**
1. **URGENT:** Verify menu migration - database shows only 36 dishes but live menu has many more items
2. Review live menu at https://kabyliepizza.com/?p=menu&lang=fr to identify all courses
3. Create proper courses based on live menu structure and reassign dishes appropriately
4. Verify if additional dishes need to be migrated from live menu

#### The Original Georgie's (Restaurant ID: 84)
**Status:** ⚠️ SKIPPED - Already assigned but SUSPICIOUSLY LOW DISH COUNT | ⚠️ STATUS MISMATCH
**Date:** 2025-11-03

**Details:**
- Total dishes: 5 ⚠️ (Very low count)
- Dishes with course_id: 5 (100%)
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course (1529)

**⚠️ STATUS CORRECTION NEEDED:** Database status is "suspended" but restaurant is listed in Restaurants-active.md as active (database status needs correction to match active list)

**⚠️ DATA QUALITY CONCERN:** Only 5 dishes is suspiciously low. This pattern suggests:
- Incomplete menu migration, OR
- Restaurant may have closed/left platform (similar to Twisted Pita pattern)

**Dishes Found:**
- Buddy Pack (2 Free Garlic Sauces)
- Chicken
- Party Pack 1 (2 Free Garlic Sauces)
- Party Pack 2 (3 Free Garlic Sauces)
- Spaghetti For 2 HIDE

**⚠️ DATA MIGRATION ISSUE CONFIRMED:** User verified restaurant is missing a large number of menu items. Similar to Xtreme Pizza - this is a data migration issue, not a course assignment issue. The 5 dishes found are just a "good start" but represent incomplete menu migration.

**Action Taken:** Skipped - all dishes already have course_id. **ACTION REQUIRED:** Full menu migration needed before proper course assignment can proceed. Status should be verified (suspended vs active).


#### Vieux Hull Pizza (Restaurant ID: 820)
**Status:** ⚠️ SKIPPED - Already has course assignments (NEEDS REVIEW)
**Date:** 2025-11-03

**Details:**
- Total dishes: 33
- Dishes with course_id: 33 (100%)
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course (1586)

**Action Taken:** None - all dishes already have course_id assigned. Note: All dishes are in "Uncategorized" which may need refinement later, but technically complete.

#### Yorgo's - Nepean (Restaurant ID: 985)
**Status:** ⚠️ SKIPPED - Already has course assignments (NEEDS REVIEW)
**Date:** 2025-11-03

**Details:**
- Total dishes: 12
- Dishes with course_id: 12 (100%)
- Courses defined: 1 (Uncategorized)
- All dishes assigned to "Uncategorized" course (1501)

**Action Taken:** None - all dishes already have course_id assigned. 

**⚠️ REVIEW NEEDED - Online Menu Categories Found:**
Actual menu structure from online shows ~15 categories that should be created:
- Pita Wraps
- Munchies
- Poutine
- Wings
- Hot Subs
- Souvlaki Platters
- Specialty Platters
- Seafood
- Extra Satisfaction
- Yorgo's Pizza
- Create Your Own Pizza
- Twin Deals
- Pizza and Wing Special
- Yorgo's Daily Specials
- Salads
- Side Orders
- Desserts
- Drinks

**Future Action Required:**
1. Create proper courses based on online menu structure
2. Re-assign dishes from "Uncategorized" to appropriate courses
3. Verify all dishes are properly categorized

---

## Summary Statistics

**Last Updated:** 2025-11-05 - After comprehensive cleanup removing restaurants not in verified billing list

### Active Restaurants Status:
- **Total Restaurants in Active Billing List:** 189 (verified against last 4 months billing)
- **Completed Course Assignments:** 14 restaurants
  - Wandee Thai, Lucky King Take Out, Beneci Pizza, Capital Bites, Cathay Restaurants, Centertown Donair & Pizza, Charm Thai Cuisine, Chicco Pizza Maloney, Chicco Pizza Shawarma Anger, Chicco Pizza St-Louis, Chicco Pizza & Shawarma Buckingham, Chicco Shawarma Cantley, Chicco Shawarma Maloney, Tony's Pizza

### Work Needed:
- **Needs Courses Created:** 4 restaurants (Aahar, Amicci Pizza, Aroy Thai, Asia Garden)
- **Has Courses, Needs Assignment:** 1 restaurant (River Pizza - 71 dishes, 12 courses)
- **Status Corrected:** 3 restaurants (Xtreme Pizza, Aylmer BBQ, Carlo's Pizza)
- **Active with Good Assignments:** Multiple restaurants (Souvlaki Souvlaki, Shaan Tandoori, Season's Pizza, Sala Thai, etc.)

### Restaurants Removed from Document (Not in Billing List):
- **Total Removed:** 30+ restaurants across all sections
- **Key Removals:**
  - Left Platform section: Removed entire section (Vanier Pizza, Westboro Subs, Bank Shawarma, Samo's Greek Kitchen, etc.)
  - No Dishes: Champa Thai Food
  - Not Found: Chances R' East, Chances R' West, Wok Bistro TEST
  - Suspended/Closed: Wow Sushi, Sous Le Palmier, Royal Thai Cuisine, Restaurant O'Wok
  - Permanently Closed: Twisted Pita & Pizzeria, The Greek Flame and Pizza, The Cupboard, Pizza Run
  - Other: Routine Poutine, Roulas Jus et Gelato, Poutinerie locations, POS SIMPLICITY, Pizza Riverview, Yorgo's Barrhaven, etc.

### Data Quality Issues Noted:
- **Critical Migration Issues:** 3 restaurants (Xtreme Pizza - 6 dishes vs 100+ online, Souvlaki Souvlaki - 1 dish vs full menu, Season's Pizza - 1 dish vs full menu)
- **Status Mismatches:** The Original Georgie's (needs status update)

### Document Cleanup Statistics:
- **Sections Cleaned:** 10+ sections
- **Orphaned Flags Removed:** 25+ markers
- **Empty Sections:** 3 (No Dishes, Not Found in Database, Suspended/Pending Status)
- **All Remaining Restaurants:** Verified active in billing list ✅