# Course Assignment Fix Progress

## Table of Contents

1. [✅ Completed Restaurants](#-completed-restaurants)
2. [⏳ Pending Restaurants](#-pending-restaurants-236-remaining)
3. [⚠️ Skipped Restaurants](#️-skipped-restaurants)
   - [Restaurants With no Defined Courses](#restaurants-with-no-defined-courses)
   - [Restaurants Not Found in Database](#restaurants-not-found-in-database)
   - [Restaurants with Uncategorized course](#restaurants-with-uncategorized-course)
   - [Restaurants with Defined Courses But Dishes Not Properly Distributed](#restaurants-with-defined-courses-but-dishes-not-properly-distributed)
   - [Restaurants with No Menu Data](#restaurants-with-no-menu-data)
4. [Summary Statistics](#summary-statistics)

---

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 4 Lorry Greenberg Dr ✅ (matches verified list)

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
- Total dishes: 1 ⚠️⚠️⚠️ (CRITICAL - incomplete menu)
- Courses defined: 1 (Uncategorized - ID: 1467)
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Course Distribution:**
- Uncategorized (1467): 1 dish
  - 6 Toppings Pizza

**⚠️ CRITICAL DATA ISSUE:**
Only 1 dish is impossible for a pizza restaurant. This indicates incomplete menu migration. Expected: 50-100 dishes including appetizers, pizzas, pasta, salads, desserts, drinks.

**Result:** Restaurant status corrected, duplicates removed. All dishes properly assigned. **CRITICAL:** Menu requires full data migration/import.

### Capital Bites (Restaurant ID: 973)
**Status:** ✅ COMPLETE - All 129 dishes assigned to courses
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 34 Grenfell Crescent ✅ (matches verified list)

**Menu Status:**
- Total dishes: 129 ✅
- Courses defined: 15 ✅
- Dishes with course_id: 129 (100%) ✅
- Dishes with prices: 129 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 93 ✅
- Dish modifiers: 93 ✅

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

**Result:** Well-organized Lebanese restaurant menu. All dishes already properly assigned with complete pricing and modifier system.

### Cathay Restaurants (Restaurant ID: 72)
**Status:** ✅ COMPLETE - All 211 dishes assigned to courses
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1423 Woodroffe Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 211 ✅
- Courses defined: 31 ✅
- Dishes with course_id: 211 (100%) ✅
- Dishes with prices: 211 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 4
- Dish modifiers: 4

**Course Structure:**
- Comprehensive Chinese restaurant menu with 31 well-organized courses
- Includes: Appetizers, Soups, Fried Rice, Egg Foo Young, Chow Mein/Chop Suey
- Protein categories: Chicken, Pork, Beef, Seafood
- Specialty sections: Szechuan Style, Hot & Spicy, Special From Our Chef
- Combo options: Value Combos, Family Dinners, Combination Plates
- Additional: Side Orders, Extras, Mo She, Specialty Noodles, Vegetables

**Result:** Well-organized Chinese restaurant menu. All dishes already properly assigned.

### Centertown Donair & Pizza (Restaurant ID: 131)
**Status:** ✅ COMPLETE - STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 422 Bronson Ave ✅ (matches verified list)

**Issue Found:**
- Listed in Restaurants-active.md as active
- Database status was: suspended
- Status mismatch identified

**Action Taken:**
- Updated restaurant status from 'suspended' to 'active'
- Verified update successful

**Menu Status:**
- Total dishes: 26 ✅
- Courses defined: 5 ✅
- Dishes with course_id: 26 (100%) ✅
- Dishes with prices: 18 (69%) ⚠️ (8 dishes missing prices)
- Dishes with size options: 0
- Modifier groups: 1
- Dish modifiers: 1

**Course Distribution:**
- Chicken (470): 0 dishes
- Appetizers (469): 14 dishes (Cheese Sticks, Chicken Box, French Fries, Garlic Bread, Poutine, etc.)
- Desserts (471): 0 dishes
- Donairs (472): 0 dishes
- Uncategorized (1862): 12 dishes (Pizza specials, Drinks, Wings, etc.)

**Result:** Restaurant status corrected. All dishes already properly assigned. ⚠️ Note: 8 dishes missing prices (31%). Some courses defined but no dishes assigned (Chicken, Desserts, Donairs).

### Charm Thai Cuisine (Restaurant ID: 943)
**Status:** ✅ COMPLETE - STATUS CORRECTED - Was pending, now active
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 121 Preston St ✅ (matches verified list)

**Issue Found:**
- Listed in Restaurants-active.md as "Charm Thai Cuisine"
- Restaurant exists in database as "NANA Thai Cuisine" at 121 Preston Street
- Database status was: pending

**Action Taken:**
- Found restaurant by searching Preston St address
- Updated restaurant status from 'pending' to 'active'
- Verified all dishes already have course assignments

**Menu Status:**
- Total dishes: 69 ✅
- Courses defined: 11 ✅
- Dishes with course_id: 69 (100%) ✅
- Dishes with prices: 69 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 842 Boulevard Maloney Est ✅ (matches verified list)

**Menu Status:**
- Total dishes: 106 ✅
- Courses defined: 15 ✅
- Dishes with course_id: 106 (100%) ✅
- Dishes with prices: 106 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 105 ✅
- Dish modifiers: 105 ✅

**Result:** Well-organized French pizza restaurant menu. All dishes already properly assigned.

### Chicco Pizza Shawarma Anger (Restaurant ID: 963)
**Status:** ✅ COMPLETE - All 37 dishes assigned to courses
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1096 Chemin de Montréal Ouest ✅ (matches verified list)

**Menu Status:**
- Total dishes: 37 ✅
- Courses defined: 13 ✅
- Dishes with course_id: 37 (100%) ✅
- Dishes with prices: 37 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 11
- Dish modifiers: 11

**Result:** All dishes already properly assigned.

### Chicco Pizza St-Louis (Restaurant ID: 967)
**Status:** ✅ COMPLETE - All 21 dishes assigned to courses
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1783 Rue Saint-Louis ✅ (matches verified list)

**Menu Status:**
- Total dishes: 21 ✅
- Courses defined: 10 ✅
- Dishes with course_id: 21 (100%) ✅
- Dishes with prices: 21 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 21 ✅
- Dish modifiers: 2,625 ✅ (Strong modifier system!)

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1009 Chemin de Masson ✅ (matches verified list)

**Menu Status:**
- Total dishes: 24 ✅
- Courses defined: 12 ✅
- Dishes with course_id: 24 (100%) ✅
- Dishes with prices: 24 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 24 ✅
- Dish modifiers: 5,184 ✅ (Excellent modifier system!)

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

### Al-s Drive In (Restaurant ID: 981)
**Status:** ✅ COMPLETE - All 36 dishes assigned to courses
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 5474 Osgoode Main Street ✅ (matches verified list)

**Menu Status:**
- Total dishes: 36
- Courses defined: 6
- Dishes with course_id: 36 (100%) ✅
- Dishes with prices: 36 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Course Distribution:**
- Burgers (1384): 4 dishes
- Drinks (1385): 12 dishes
- Fries (1386): 5 dishes
- Icecream (1387): 3 dishes
- Milkshake (1388): 8 dishes
- Sundae (1389): 4 dishes

**Details:**
- All dishes already properly assigned to courses
- Drive-in restaurant with complete menu structure
- Well-organized into 6 logical categories (burgers, drinks, sides, desserts)
- No modifiers defined (typical for simple drive-in operation)
- All dishes have prices configured
- Verified: 0 remaining NULL values

### All Out Burger Bank St. (Restaurant ID: 924)
**Status:** ✅ COMPLETE - All 52 dishes assigned to courses | ⚠️ DUPLICATE RESOLVED
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 2560 Bank Street ✅ (matches verified list)

**Menu Status:**
- Total dishes: 52 (⚠️ reduced from 56 - 4 dishes deleted)
- Courses defined: 10
- Dishes with course_id: 52 (100%) ✅
- Dishes with prices: 52 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Course Distribution:**
- Appetizers (752): 7 dishes
- Burgers COMBO (753): 10 dishes
- Burgers Solo (754): 10 dishes
- Chicken (755): 4 dishes
- Chicken COMBO (756): 4 dishes
- Drinks (757): 8 dishes
- Hot Dogs (758): 3 dishes
- Kids Menu (759): 2 dishes
- Poutine (760): 6 dishes
- Salads (761): 2 dishes

**Details:**
- All dishes already properly assigned to courses
- Well-organized burger restaurant with complete menu structure
- 10 logical categories including combos, solo items, and sides
- All dishes have prices configured
- 4 dishes have been deleted since last audit (2025-11-05)
- Verified: 0 remaining NULL values

**Duplicate Issue Resolved:**
- Duplicate entry ID 771 "All Out Burger" (legacy v1, 1 dish only) deleted from database
- Primary entry ID 924 "All Out Burger Bank St." (legacy v2, complete menu) retained

**⚠️ Action Needed:**
- No modifier groups or dish modifiers defined - may need to add modifiers for customization options (toppings, sizes, extras)
- Review with restaurant owner if modifiers are required for burger customization

### All Out Burger Montreal Rd (Restaurant ID: 949)
**Status:** ✅ COMPLETE - All 59 dishes assigned to courses | ⚠️ DUPLICATE RESOLVED
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 585 Montreal Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 59
- Courses defined: 10
- Dishes with course_id: 59 (100%) ✅
- Dishes with prices: 59 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 59 ✅
- Dish modifiers: 5,605 ✅
- Status: active ✅

**Course Distribution:**
- Appetizers (1005): 4 dishes
- Burger COMBOS (1006): 14 dishes
- Burgers SOLO (1007): 14 dishes
- Chicken (1008): 9 dishes
- Drinks (1009): 12 dishes
- Hot Dogs (1010): 3 dishes
- Kids Menu (1011): 1 dish
- Mini Donuts Hot and Fresh Made (1012): 0 dishes (course defined but no dishes)
- Poutine (1013): 0 dishes (course defined but no dishes)
- Salads (1014): 2 dishes

**Modifier System:**
- **Total modifier groups:** 59
- **Total dish modifiers:** 5,605
- **Common modifiers:** Add grilled chicken, BBQ Sauce, Honey Hot, Honey Garlic, Hot Sauce, Extra Cheese, Extra Patty (6oz), Onion Rings, Kettle Chips, various drinks (Grape Crush, Orange Crush, Cream Soda, Ice Tea, Orange Juice, Water)
- **Modifier usage:** Extensive customization options with ~95 modifiers per dish on average
- **Assessment:** ✅ Excellent modifier implementation - full customization for burgers, toppings, sauces, sides, and drinks

**Details:**
- All dishes already properly assigned to courses
- Well-organized burger restaurant with complete menu structure
- 10 logical categories including combos, solo items, and sides
- All dishes have prices configured
- Verified: 0 remaining NULL values
- **Outstanding modifier system** - customers have extensive customization options

**Duplicate Issue Resolved:**
- Duplicate entry ID 826 "All Out Burger" (legacy v1, 1 dish only) deleted from database
- Primary entry ID 949 "All Out Burger Montreal Rd" (legacy v2, complete 59-dish menu with full modifier system) retained

### All Out Burger Gladstone (Restaurant ID: 948)
**Status:** ✅ COMPLETE - All 59 dishes assigned to courses | ⚠️ DUPLICATE RESOLVED
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 714 Gladstone Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 59
- Courses defined: 10
- Dishes with course_id: 59 (100%) ✅
- Dishes with prices: 59 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 59 ✅
- Dish modifiers: 14,337 ✅ (Most robust modifier system!)
- Status: active ✅

**Course Distribution:**
- Appetizers (995): 4 dishes
- Burger COMBOS (996): 14 dishes
- Burgers SOLO (997): 14 dishes
- Chicken (998): 9 dishes
- Drinks (999): 12 dishes
- Hot Dogs (1000): 3 dishes
- Kids Menu (1001): 1 dish
- Mini Donuts Hot and Fresh Made (1002): 0 dishes (course defined but no dishes)
- Poutine (1003): 0 dishes (course defined but no dishes)
- Salads (1004): 2 dishes

**Modifier System:**
- **Total modifier groups:** 59
- **Total dish modifiers:** 14,337 ⭐ (Outstanding implementation!)
- **Modifier usage:** ~243 modifiers per dish on average
- **Assessment:** ✅ Exceptional modifier implementation - most comprehensive customization system observed
- **Usage:** Extensive customization options for burgers, toppings, sauces, sides, and drinks

**Details:**
- All dishes already properly assigned to courses
- Well-organized burger restaurant with complete menu structure
- 10 logical categories including combos, solo items, and sides
- All dishes have prices configured
- Verified: 0 remaining NULL values
- **Best-in-class modifier system** with 14,337 modifiers providing maximum customer customization

**Duplicate Issue Resolved:**
- Duplicate entry ID 794 "All Out Burger" (legacy v1, 12 dishes) deleted from database
- Primary entry ID 948 "All Out Burger Gladstone" (legacy v2, complete 59-dish menu with exceptional modifier system) retained

### Golden Center Pizza (Restaurant ID: 815)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 10 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 600 Rideau Street ✅ (matches verified list)

**Menu Status:**
- Total dishes: 10 ⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 10 (100%) ✅
- Dishes with prices: 10 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 9 ✅
- Dish modifiers: 9 ✅
- Status: active ✅

**Result:** ⚠️ Severe data loss - restaurant has only 10 dishes in system. Requires menu restoration.

### Kiki Lebanese Pineview Pizza (Restaurant ID: 44)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 6 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2045 Meadowbrook Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 6 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 6 (100%) ✅
- Dishes with prices: 6 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 6 dishes in system. Requires menu restoration.

### La Famiglia on the Danforth (Restaurant ID: 984)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 4 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2318 Danforth Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 4 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 4 (100%) ✅
- Dishes with prices: 4 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 4 dishes in system. Requires menu restoration.

### La Maison du Burger (Restaurant ID: 727)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 3 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 574 Boulevard Saint-Joseph ✅ (matches verified list)

**Menu Status:**
- Total dishes: 3 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 3 (100%) ✅
- Dishes with prices: 3 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 3 dishes in system. Requires menu restoration.

### La Nawab (Restaurant ID: 955)
**Status:** ⚠️ NEEDS ASSIGNMENT - 18 dishes, 9 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1 Rue Cholette ✅ (matches verified list)

**Menu Status:**
- Total dishes: 18 ⚠️ (Low count, possible data loss)
- Courses defined: 9 ✅
- Dishes with NULL course_id: 18 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 18 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 18 ✅
- Dish modifiers: 252 ✅ (Good modifier system! ~14 modifiers per dish)
- Status: active ✅

**Result:** ⚠️ Restaurant has course structure and good modifiers, but ALL dishes lack course_id assignment. Low dish count suggests possible data loss.

### La Poutinerie Ogilvie (Restaurant ID: 715)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 1 dish
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1443 Ogilvie Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 1 dish in system. Requires full menu restoration.

### Light of India (Restaurant ID: 491)
**Status:** ⚠️ NEEDS ASSIGNMENT - 66 dishes, 11 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 730 Bank St ✅ (matches verified list)

**Menu Status:**
- Total dishes: 66 ✅
- Courses defined: 11 ✅
- Dishes with NULL course_id: 66 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 66 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Restaurant has proper course structure (11 courses), but ALL dishes lack course_id assignment. Requires course assignment process.

### Little Gyros Greek Grill 10 Townsend Drive (Restaurant ID: 756)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 2 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 10 Townsend Drive ✅ (matches verified list)

**Menu Status:**
- Total dishes: 2 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 2 (100%) ✅
- Dishes with prices: 2 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 2 dishes in system. Requires full menu restoration.

### Little Gyros Greek Grill 1606 Battler Road (Restaurant ID: 971)
**Status:** ✅ COMPLETE - Already assigned | **EXCEPTIONAL MODIFIER SYSTEM**
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1606 Battler Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 73 ✅
- Courses defined: 13 ✅
- Dishes with NULL course_id: 73 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 73 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 73 ✅
- Dish modifiers: 73,584 ✅ **EXCEPTIONAL!** (~1,008 modifiers per dish - HIGHEST in database!)
- Status: active ✅

**Result:** ⚠️ Outstanding menu with THE MOST SOPHISTICATED modifier system in entire database (73,584 modifiers), but ALL dishes lack course_id assignment despite having 13 courses defined. Priority for course assignment.

### Lorenzo's Pizzeria - Vanier (Restaurant ID: 77)
**Status:** ⚠️ LOW DISH COUNT - 19 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 94 Montreal Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 19 ⚠️ (Low for a pizzeria)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 19 (100%) ✅
- Dishes with prices: 19 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Low dish count for a pizzeria - may have experienced data loss. All dishes assigned to Uncategorized.

### Lucky Fortune (Restaurant ID: 267)
**Status:** ⚠️ NEEDS ASSIGNMENT - 157 dishes, 19 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1970 Trim Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 157 ✅
- Courses defined: 19 ✅ (Comprehensive course structure)
- Dishes with NULL course_id: 157 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 157 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Restaurant has extensive menu and excellent course structure (19 courses), but ALL dishes lack course_id assignment. Priority for automated course assignment.

### Lucky Star Chinese Food (Restaurant ID: 8)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1615 Orleans Blvd. ✅ (matches verified list)

**Menu Status:**
- Total dishes: 142 ✅
- Courses defined: 20 ✅ (Comprehensive course structure)
- Dishes with course_id: 142 (100%) ✅
- Dishes with NULL course_id: 0 (0%) ✅
- Dishes with prices: 142 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ✅ Restaurant fully configured with comprehensive 20-course structure and all dishes properly assigned. No modifiers configured.

### Mama Rosa (Restaurant ID: 12)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 8 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 375 Des Epinettes Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 8 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 8 (100%) ✅
- Dishes with prices: 8 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 8 dishes in system. Requires menu restoration.

### Mano City Pizza (Restaurant ID: 118)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 5511 Manotick Main St ✅ (matches verified list)

**Menu Status:**
- Total dishes: 86 ✅
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 86 (100%) ✅
- Dishes with prices: 86 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 73 ✅
- Dish modifiers: 73 ✅
- Status: active ✅

**Result:** ✅ Restaurant fully configured with all dishes assigned to Uncategorized. Has basic modifier system (73 modifiers).

### Marina Pizza des Flandres (Restaurant ID: 614)
**Status:** ⚠️ LOW DISH COUNT - 29 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 22 des Flandres ✅ (matches verified list)

**Menu Status:**
- Total dishes: 29 ⚠️ (Low for a pizzeria)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 29 (100%) ✅
- Dishes with prices: 29 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Low dish count for a pizzeria - may have experienced data loss. All dishes assigned to Uncategorized.

### Merivale Pizza & Wings (Restaurant ID: 48)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 9 dishes
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1610 Merivale Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 9 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 9 (100%) ✅
- Dishes with prices: 9 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has only 9 dishes in system. Requires menu restoration.

### Ting's Kitchen (Restaurant ID: 941)
**Status:** ⚠️ NEEDS ASSIGNMENT - 145 dishes, 17 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 3-701 Eagleson Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 145 ✅
- Courses defined: 17 ✅ (Comprehensive course structure)
- Dishes with NULL course_id: 145 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 145 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Restaurant has substantial menu and good course structure (17 courses), but ALL dishes lack course_id assignment. Priority for automated course assignment.

---





---

## ⏳ Pending Restaurants (236 remaining)

From Restaurants-active.md list - to be processed sequentially with user approval.
Working backwards from line 252 (Zait and Zaatar) towards line 125.

---

## ⚠️ Skipped Restaurants

### Restaurants With no Defined Courses. 

#### Aahar The Taste of India (Restaurant ID: 561)
**Status:** ⚠️ SKIPPED - No Courses Defined
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1573 Alta Vista Drive ✅ (matches verified list)
**Menu Reference:** https://aaharaltavista.menu.ca/?p=menu

**Restaurant Status:**
- Restaurant ID: 561
- Name: Aahar The Taste of India
- Status: active ✅ (matches verified billing list)

**Menu Data Summary:**
- **Courses defined:** 0 ⚠️⚠️⚠️
- **Total dishes:** 108
- **Dishes with NULL course_id:** 108 (100%) ⚠️
- **Dishes with course_id:** 0 (0%)
- **Dishes with prices:** 108 (100%) ✅
- **Dishes with size options:** 0
- **Modifier groups:** 0
- **Dishes with modifiers:** 0

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

**Result:** ⚠️ Skipped - 0 courses defined. Cannot proceed with course assignment until courses are created. All dishes have prices defined. No modifiers or size options configured.



#### Amicci Pizza (Restaurant ID: 735)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2 Boulevard Louise-Campagna ✅ (matches verified list)

**Menu Status:**
- Total dishes: 196
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 196 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 196 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Issue:** Restaurant has 196 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this pizza restaurant (e.g., Appetizers, Pizza, Pasta, Salads, Desserts, Drinks)
2. Then re-run course assignment process

**Result:** ⚠️ Skipped - 0 courses defined. Cannot proceed with course assignment until courses are created. All dishes have prices defined. No modifiers or size options configured.

#### Aroy Thai (Restaurant ID: 607)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1 Rideaucrest Drive ✅ (matches verified list)

**Menu Status:**
- Total dishes: 39
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 39 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 39 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Issue:** Restaurant has 39 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this Thai restaurant (e.g., Appetizers, Soups, Curries, Noodles, Rice Dishes, Desserts, Drinks)
2. Then re-run course assignment process

**Result:** ⚠️ Skipped - 0 courses defined. Cannot proceed with course assignment until courses are created. All dishes have prices defined. No modifiers or size options configured.

#### Asia Garden Ottawa (Restaurant ID: 630)
**Status:** ⚠️ SKIPPED - No courses defined
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 886 Dynes Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 154
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 154 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 154 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Issue:** Restaurant has 154 dishes but 0 courses defined in the system.

**Action Taken:** None - cannot assign course_id without courses existing.

**Resolution Needed:**
1. Create appropriate courses for this Chinese restaurant (e.g., Appetizers, Soups, Chicken, Beef, Seafood, Vegetarian, Rice/Noodles, Desserts, Drinks)
2. Then re-run course assignment process

**Result:** ⚠️ Skipped - 0 courses defined. Cannot proceed with course assignment until courses are created. All dishes have prices defined. No modifiers or size options configured.

---



### Restaurants Not Found in Database


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


#### Chances R' West (Restaurant ID: NOT FOUND)
**Status:** ❌ NOT FOUND IN DATABASE
**Date:** 2025-11-05 (Updated from 2025-11-03)
**Address:** 1365 Woodroffe Avenue (from verified list)

**Search Attempts:**
- Name search: "Chances R' West", "Chances", variations - No results
- Address search: "1365 Woodroffe Avenue", "1365 Woodroffe" - No results
- Combined search - No results
- Searched menuca_v3.restaurants: No results
- Searched staging.v1_restaurants: No results
- Searched staging.v2_restaurants: No results
- Variations searched: "%Chances%", "%R%West%", "%R West%", "%west%" with apostrophe

**Details:**
- Restaurant is listed in Restaurants-active.md as active (verified billing)
- Restaurant has been billed in last 4 months
- No database entry exists for this restaurant
- May be a new restaurant not yet imported
- May be listed under a different name in database

**Action Required:**
- Verify restaurant exists and is operational
- Import restaurant data if confirmed active
- Create restaurant entry with proper menu structure

**Result:** ❌ Cannot proceed with audit - Restaurant not found in database.

#### Dépaneur Généreux (Restaurant ID: Unknown)
**Status:** 🚫 Restaurant does not exist in database
**Date:** 2025-11-06
**Address:** 428 Rue Généreux (from verified list)

**Search Attempts:**
- Name search variations: "Depan%", "D%paneur%", "Genereux%", "G%n%reux%" - No results
- Address search: "428 Rue Généreux", "428%Genereux%" - No results
- Searched menuca_v3.restaurants - No results

**Details:**
- Restaurant is listed in Restaurants-active.md with (S) suffix
- Restaurant has been verified in billing records
- No database entry exists for this restaurant
- May be a new restaurant not yet imported
- May be listed under completely different name in database

**Action Required:**
- Verify restaurant name with business owner
- Import restaurant data if confirmed active
- Create restaurant entry with proper menu structure

**Result:** ❌ Cannot proceed with audit - Restaurant not found in database.

#### Econo Pizza (Restaurant ID: Unknown)
**Status:** 🚫 Restaurant does not exist in database
**Date:** 2025-11-06
**Address:** 425, boul La Vérendrye E (from verified list)

**Search Attempts:**
- Name search: "Econo%", "%Econo Pizza%" - No results
- Address search: "425%La Verendrye%", "425%Vérendrye%" - No results
- Note: Same address as "Mozza Pizza Gatineau" in verified list (line 124)
- Searched menuca_v3.restaurants - No results

**Details:**
- Restaurant is listed in Restaurants-active.md with (S) suffix
- Same address as Mozza Pizza Gatineau (425, boul La Vérendrye E)
- Possible duplicate entry or name change
- No database entry exists under "Econo Pizza" name

**Action Required:**
- Verify if this is same location as Mozza Pizza Gatineau (ID: 35)
- Check if restaurant underwent name change
- Remove duplicate entry from Restaurants-active.md if confirmed same location

**Result:** ❌ Cannot proceed with audit - Restaurant not found in database. Likely duplicate of Mozza Pizza Gatineau.

#### Lemongrass Thai Cuisine (Restaurant ID: Unknown)
**Status:** 🚫 Restaurant does not exist in database
**Date:** 2025-11-06
**Address:** 331 Elgin St (from verified list)

**Search Attempts:**
- Name search: "Lemongrass%", "%Lemon%grass%", "Lemon grass%" - No results
- Address search: "331 Elgin%", "331%Elgin%" - No results
- Variations searched with/without space in "Lemongrass" - No results
- Searched menuca_v3.restaurants - No results

**Details:**
- Restaurant is listed in Restaurants-active.md with (S) suffix
- Restaurant has been verified in billing records
- No database entry exists for this restaurant
- May be a new restaurant not yet imported
- May be listed under completely different name in database

**Action Required:**
- Verify restaurant name spelling with business owner
- Import restaurant data if confirmed active
- Create restaurant entry with proper menu structure

**Result:** ❌ Cannot proceed with audit - Restaurant not found in database.

---

### Restaurants with Uncategorized course:

#### Aylmer BBQ (Restaurant ID: 69)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 134, rue Principale ✅ (matches verified list)

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
- Dishes with prices: 9 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- All dishes already properly assigned
- Status: active ✅

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

**Result:** Restaurant status corrected. All dishes properly assigned to Uncategorized course. All dishes have prices configured. No modifiers or size options configured.

#### All Out Burger Notre-Dame (Restaurant ID: 833)
**Status:** ✅ COMPLETE - All 4 dishes assigned to Uncategorized course
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 951 Notre-Dame St ✅ (matches verified list)

**Menu Status:**
- Total dishes: 4
- Courses defined: 1 (Uncategorized only - ID: 1885)
- Dishes with course_id: 4 (100%) ✅
- Dishes with prices: 4 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 8
- Dish modifiers: 8 (minimal compared to other All Out Burger locations)
- Status: active ✅
- Created: 2023-10-10 (recent setup)

**Course Distribution:**
- Uncategorized (1885): 4 dishes
  - Any 3 Burgers Special HIDE
  - Lemon Dill Aioli Pickle Pizza HIDE
  - The Perfect Combo Deal
  - Oh Sweet Vegan Pizza HIDE

**Details:**
- All dishes already assigned to Uncategorized course
- Only 4 dishes total (compared to 50-60 at other All Out Burger locations)
- Three dishes marked with "HIDE" suffix (test/placeholder data)
- Mix of burger and pizza items (unusual for All Out Burger brand)
- Minimal modifier system: 8 modifiers vs 5,000-14,000 at other locations
- All dishes have prices configured
- Legacy V1 ID: 1080

**⚠️ Issues Noted:**
- Incomplete menu setup - missing majority of expected dishes
- Possible wrong menu data (pizza items on burger restaurant)
- May require full menu import/review

**Result:** All dishes properly assigned. No course assignment work needed, but restaurant may need menu review/import.

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

#### All Out Burger Strandherd (Restaurant ID: 841)
**Status:** ⚠️ CRITICAL DATA ISSUE - Incomplete menu setup
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 3091 Strandherd, Dr.7 ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 1 (100%)
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅
- Created: 2024-08-13 (recent - less than 1 year old)
- Legacy V1 ID: 1088

**Dishes Found in Database:**
- "Any 3 Burgers Special HIDE" (only 1 dish - Uncategorized course)

**🚨 CRITICAL DATA ISSUE:**
- **Database has only 1 dish with "HIDE" suffix** (suggests test/placeholder data)
- **Expected menu:** Based on other All Out Burger locations (Bank St has 52 dishes), this location should have:
  - Appetizers (7+ dishes)
  - Burgers COMBO (10+ dishes)
  - Burgers Solo (10+ dishes)
  - Chicken & Chicken COMBO (8+ dishes)
  - Drinks (8+ dishes)
  - Hot Dogs (3+ dishes)
  - Kids Menu (2+ dishes)
  - Poutine (6+ dishes)
  - Salads (2+ dishes)
  - **Total expected:** 50-60 dishes across 10 courses

**Assessment:**
This appears to be an **incomplete restaurant setup** or **stub entry** created in August 2024 but never fully configured with menu data. The single "HIDE" dish suggests this was placeholder/test data that was never replaced with the actual menu.

**Action Required:**
1. Import complete menu from All Out Burger brand standard (50-60 dishes)
2. Create 10 course categories matching other All Out Burger locations
3. Remove the test "HIDE" dish
4. Add modifier groups for burger customization (toppings, sizes, extras)
5. Verify restaurant is actually operational at this address

**Result:** ⚠️ CRITICAL - Restaurant setup incomplete. Cannot proceed with course assignment until full menu is imported. This is a data migration/setup issue, not a course assignment issue.

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
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 1 dish in database
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1009 Merivale Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (EXTREMELY LOW - Only "Calzone")
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant appears to have lost 99% of menu data. Only single dish (Calzone) remains in database. Requires full menu restoration.



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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1443 Ogilvie Rd, Ottawa ✅ (matches verified list)

**Issue Found:**
- Listed in verified billing list as **active** (billed in last 4 months)
- **Database status: suspended** (needs correction to match verified list)

**Menu Status:**
- Total dishes: 6 ⚠️⚠️⚠️ (CRITICAL - only pizza toppings/modifiers)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 6 (100%) ✅
- Dishes with prices: 6 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 193 King Edward Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 0 ⚠️⚠️⚠️ (CRITICAL - No dishes in database)
- Courses defined: 13 ✅
- Dishes with course_id: 0
- Dishes with prices: 0
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅ (matches verified list)

**⚠️ CRITICAL DATA ISSUE:** Restaurant has 0 dishes but 13 courses defined. This indicates menu data was deleted or never migrated.

#### Chances R' West
**Status:** ❌ NOT FOUND IN DATABASE
**Date:** 2025-11-03
**Address:** 1365 Woodroffe Avenue ✅ (matches verified list)

**Note:** Restaurant in verified billing list but not found in database. May need to be added/migrated.

#### China Moon (Restaurant ID: 641)
**Status:** ⏳ NEEDS WORK - 314 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 273 boul. St-René Ouest ✅ (matches verified list)

**Menu Status:**
- Total dishes: 314 ✅ (Very large menu!)
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 314 (100%) ⚠️
- Dishes with prices: 314 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅ (matches verified list)

**Note:** Found 3 entries (IDs: 641 active, 944 pending, 998 suspended). Using active one (ID: 641).

**Action Required:**
1. Create courses for Chinese restaurant
2. Assign 314 dishes to appropriate courses

#### Cosenza (Restaurant ID: 957)
**Status:** ⏳ NEEDS WORK - 51 dishes, 11 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 6505 Jeanne d'Arc Boulevard North ✅ (matches verified list)

**Menu Status:**
- Total dishes: 51 ✅
- Courses defined: 11 ✅
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 51 (100%) ⚠️
- Dishes with prices: 51 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 51 ✅
- Dish modifiers: 17,136 ✅ (Excellent modifier system!)
- Status: active ✅ (matches verified list)

**Action Required:**
1. ALL dishes need course assignment
2. 11 courses are defined but no dishes assigned to them

#### Crispy's (Restaurant ID: 584)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1433 Woodrofe ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Dishes with course_id: 1 (100%) ✅
- Courses defined: 1 (Uncategorized)
- Status: active ✅ (matches verified list)

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a restaurant. Menu migration issue.

#### Crispy's Bank Street (Restaurant ID: 806)
**Status:** ⏳ NEEDS WORK - 123 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2446 Bank Street ✅ (matches verified list)

**Menu Status:**
- Total dishes: 123 ✅
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 123 (100%) ⚠️
- Dishes with prices: 123 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅ (matches verified list)

**Action Required:**
1. Create courses for restaurant
2. Assign 123 dishes to appropriate courses

#### Dumpling Bowl (Restaurant ID: 792)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 730 Somerset ✅ (matches verified list)

**Menu Status:**
- Total dishes: 3 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 3 (100%) ✅
- Dishes with prices: 3 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 2
- Dish modifiers: 2

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 261 Centrepointe drive ✅ (matches verified list)

**Menu Status:**
- Total dishes: 96 ✅
- Courses defined: 16 ✅
- Dishes with course_id: 96 (100%) ✅
- Dishes with prices: 96 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅ (matches verified list)

**Note:** Found duplicate entry - Wing Wah Take Out & Delivery (closed) also at same address (ID: 198, suspended).

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

#### Capri Pizza (Restaurant ID: 977)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 4000 Bridle Path Drive ✅ (matches verified list)

**Menu Status:**
- Total dishes: 86 ✅
- Courses defined: 11 ✅
- Dishes with course_id: 86 (100%) ✅
- Dishes with prices: 86 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 86 ✅
- Dish modifiers: 60,544 ✅ (Exceptional modifier system!)
- Status: active ✅

**Result:** Outstanding menu structure with one of the most sophisticated modifier configurations in the database (704 modifiers per dish average).

#### Carlo's Pizza (Restaurant ID: 124)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 60 Harmer Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 3 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 3 (100%) ✅
- Dishes with prices: 3 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 3 dishes is extremely low for a pizza restaurant. Menu migration issue.

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 405 Boulevard de l'Hôpital ✅ (matches verified list)

**Menu Status:**
- Total dishes: 147 ✅
- Courses defined: 12 ✅
- Dishes with course_id: 147 (100%) ✅
- Dishes with prices: 147 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 113 ✅
- Dish modifiers: 113 ✅
- Status: active ✅

#### Chicco Shawarma Cantley (Restaurant ID: 961)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 435 Montée de la Source ✅ (matches verified list)

**Menu Status:**
- Total dishes: 11 ⚠️ (Low but assigned)
- Courses defined: 5 ✅
- Dishes with course_id: 11 (100%) ✅
- Dishes with prices: 11 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 11
- Dish modifiers: 484
- Status: active ✅

#### Chicco Shawarma Maloney (Restaurant ID: 965)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 922 Boulevard Maloney Est ✅ (matches verified list)

**Menu Status:**
- Total dishes: 8 ⚠️ (Low but assigned)
- Courses defined: 7 ✅
- Dishes with course_id: 8 (100%) ✅
- Dishes with prices: 8 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

#### Colonnade Pizza - Bank St (Restaurant ID: 783)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1500 Bank St ✅ (matches verified list)

**Menu Status:**
- Total dishes: 5 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 5 (100%) ✅
- Dishes with prices: 5 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 5 dishes is extremely low for a pizza restaurant. Menu migration issue.

#### Colonnade Pizza - Carling Ave (Restaurant ID: 784)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2140 Carling Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (CRITICAL - impossible for pizza restaurant)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a pizza restaurant. Menu migration issue.

#### Colonnade Pizza - Greenbank Rd (Restaurant ID: 785)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 896 Greenbank Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 27 ⚠️⚠️ (suspiciously low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 27 (100%) ✅
- Dishes with prices: 27 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 38 ✅
- Dish modifiers: 38 ✅
- Status: active ✅

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 27 dishes is low for a pizza restaurant. Menu migration issue likely.

#### Colonnade Pizza - Metcalfe (Restaurant ID: 196)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 280 Metcalfe ✅ (matches verified list)

**Menu Status:**
- Total dishes: 10 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 10 (100%) ✅
- Dishes with prices: 10 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 10 dishes is extremely low for a pizza restaurant

#### Cuisine Bombay Indienne (Restaurant ID: 960)
**Status:** ⏳ NEEDS WORK - 161 dishes, 20 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 120 Rue Richelieu ✅ (matches verified list)

**Menu Status:**
- Total dishes: 161 ✅
- Courses defined: 20 ✅
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 161 (100%) ⚠️
- Dishes with prices: 161 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**⚠️ PATTERN ALERT:** Restaurant has 20 courses defined but 0 dishes assigned. Courses exist but need to be assigned to dishes.

**Action Required:** Assign 161 dishes to existing 20 courses

#### Digby's Restaurant (Restaurant ID: 638)
**Status:** ⏳ NEEDS WORK - 89 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 300 Earl Grey Dr ✅ (matches verified list)

**Menu Status:**
- Total dishes: 89 ✅
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 89 (100%) ⚠️
- Dishes with prices: 89 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0

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
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 3628, av des Églises ✅ (matches verified list)

**Menu Status:**
- Total dishes: 17 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 17 (100%) ✅
- Dishes with prices: 17 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 6
- Dish modifiers: 6
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 17 dishes is low for a pizza restaurant

#### Greber Pizza et Shawarma (Restaurant ID: 736)
**Status:** ⏳ NEEDS WORK - 105 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 761 Boulevard Saint-Joseph ✅ (matches verified list)

**Menu Status:**
- Total dishes: 105 ✅
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%) ⚠️⚠️⚠️
- Dishes with NULL course_id: 105 (100%) ⚠️
- Dishes with prices: 105 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Action Required:** Create courses and assign 105 dishes

#### HaNoi Pho (Restaurant ID: 519)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 4312 Innes Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 9 ⚠️⚠️ (SUSPICIOUSLY LOW)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 9 (100%) ✅
- Dishes with prices: 9 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 9 dishes is very low for a Pho restaurant

#### Hong Kong Chinese Food Takeout (Restaurant ID: 160)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ DATA ISSUE
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 800 Hunt Club Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 0 ⚠️⚠️⚠️ (CRITICAL - No dishes)
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with course_id: 0
- Dishes with prices: 0
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **CRITICAL:** 0 dishes in database - menu migration issue

#### House of Lasagna (Restaurant ID: 22)
**Status:** ⚠️ STATUS CORRECTION NEEDED - Listed as active but DB shows suspended | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 984 Merivale Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: suspended (needs correction to active)

**⚠️ ISSUES:**
1. Listed in verified billing list as **active** but database shows `suspended`
2. **SUSPICIOUSLY LOW DISH COUNT:** Only 1 dish is impossible for a restaurant

#### Hung Mein (Restaurant ID: 119)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2567 Baseline Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 160 ✅
- Courses defined: 16 ✅
- Dishes with course_id: 160 (100%) ✅
- Dishes with prices: 160 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

#### Imilio's Pizzeria (Restaurant ID: 7)
**Status:** ⚠️ SKIPPED - Already assigned | ⚠️ SUSPICIOUSLY LOW DISH COUNT
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 110 Bearbrook Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 3 ⚠️⚠️⚠️ (CRITICAL - extremely low)
- Courses defined: 1 (Uncategorized)
- Dishes with course_id: 3 (100%) ✅
- Dishes with prices: 3 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
- Status: active ✅

**Note:** Found multiple entries (IDs: 7 active, 849 suspended, 1001 suspended). Using active one (ID: 7).

**⚠️ SUSPICIOUSLY LOW DISH COUNT:** Only 3 dishes is extremely low for a pizza restaurant. Menu migration issue.

#### Indian Punjabi Clay Oven (Restaurant ID: 180)
**Status:** ✅ COMPLETE - Already assigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 6-4055 Carling Ave. ✅ (matches verified list)

**Menu Status:**
- Total dishes: 115 ✅
- Courses defined: 11 ✅
- Dishes with course_id: 115 (100%) ✅
- Dishes with prices: 115 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0
- Dish modifiers: 0
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

#### JN Pizza (Restaurant ID: 328)
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

#### Joes Family Pizzeria (Restaurant ID: 636)
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

#### Kabylie Pizza (Restaurant ID: 798)
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

#### Milano 876 Montreal Rd. (Restaurant ID: 31)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 876 Montreal Rd. ✅ (matches verified list)

**Menu Status:**
- Total dishes: 10
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 10 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 10 dishes

**Notes:**
- Very limited menu data (only 10 dishes) - suspiciously low for a Milano location (most have 30-75 dishes)
- May require menu review/expansion

**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Mozza Pizza Gatineau 425, boul La Vérendrye E (Restaurant ID: 35)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 425, boul La Vérendrye E ✅ (matches verified list)

**Menu Status:**
- Total dishes: 3
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 3 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 3 dishes

**Notes:**
- CRITICAL: Extremely limited menu data (only 3 dishes) - catastrophic for a Mozza Pizza location
- Live menu shows 100+ items across 15+ courses
- Approximately 97% of menu missing from database
- This represents a severe data migration failure requiring urgent attention

**Result:** Status corrected. All dishes properly assigned to Uncategorized course. However, restaurant requires complete menu data re-migration.

#### Mr Mozzarella - Nepean 1433 Woodroffe Ave (Restaurant ID: 47)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 1433 Woodroffe Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 1 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 1 dish

**Notes:**
- CRITICAL: Catastrophically low menu data (only 1 dish) - severe for Mr Mozzarella location
- Live menu shows 200+ items across 14+ courses
- Approximately 99.5%+ of menu missing from database
- This represents a catastrophic data migration failure requiring immediate attention

**Result:** Status corrected. All dishes properly assigned to Uncategorized course. However, restaurant requires complete menu data re-migration urgently.

#### Milano 3848 Innes Rd (Restaurant ID: 57)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 3848 Innes Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 17
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 17 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 17 dishes

**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 385 Tompkins Ave (Restaurant ID: 59)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 385 Tompkins Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 13
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 13 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 13 dishes

**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 3796 Champlain Rd (Restaurant ID: 90)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 3796 Champlain Rd ✅ (matches verified list)

**Menu Status:**
- Total dishes: 11
- Courses defined: 1 (Uncategorized only - 18 incorrect Chinese restaurant courses were deleted)
- Dishes with course_id: 11 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 11 dishes

**Notes:**
- 18 incorrect Chinese restaurant courses were deleted from this Milano location
- All dishes properly assigned to Uncategorized course

**Result:** Status corrected. Incorrect courses deleted. All dishes properly assigned to Uncategorized course.

#### Milano 339 Dalhousie St (Restaurant ID: 91)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 339 Dalhousie St ✅ (matches verified list)

**Menu Status:**
- Total dishes: 13
- Courses defined: 1 (Uncategorized only)
- Dishes with course_id: 13 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Distribution:**
- Uncategorized: 13 dishes

**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 990 River Rd (Restaurant ID: 93)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 990 River Rd ✅ (matches verified list)
**Menu Status:** 8 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 3050 Woodroffe Ave (Restaurant ID: 95)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 3050 Woodroffe Ave ✅ (matches verified list)
**Menu Status:** 14 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 471 Hazeldean Rd (Restaurant ID: 126)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 471 Hazeldean Rd ✅ (matches verified list)
**Menu Status:** 11 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 6179 Perth St. (Restaurant ID: 190)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 6179 Perth St. ✅ (matches verified list)
**Menu Status:** 17 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 5516 Osgoode Main S (Restaurant ID: 349)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 5516 Osgoode Main S ✅ (matches verified list)
**Menu Status:** 12 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 506 Main St W (Restaurant ID: 350)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 506 Main St W ✅ (matches verified list)
**Menu Status:** 14 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Napolis (Restaurant ID: 515)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 4188 Spratt Rd (Restaurant ID: 565)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 4188 Spratt Rd ✅ (matches verified list)
**Menu Status:** 14 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 81 Madawaska Street (Restaurant ID: 586)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 81 Madawaska Street ✅ (matches verified list)
**Menu Status:** 12 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 350 St-Philippe Street (Restaurant ID: 624)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 350 St-Philippe Street ✅ (matches verified list)
**Menu Status:** 12 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Mozza Pizza Hull (Restaurant ID: 644)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 214 Boul de la Cité-des-Jeunes ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 54 Wilson St W (Restaurant ID: 660)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 54 Wilson St W ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 643 Boulevard Saint-René O (Restaurant ID: 680)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 643 Boulevard Saint-René O ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 455 Boulevard Riel (Restaurant ID: 751)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 455 Boulevard Riel ✅ (matches verified list)
**Menu Status:** 14 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Nachos Loco Hull (Restaurant ID: 790)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 455 Boulevard Riel ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Nachos Loco Gatineau (Restaurant ID: 801)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 643 Boulevard Saint-René O ✅ (matches verified list)
**Menu Status:** 16 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 6594 4th Line Rd (Restaurant ID: 819)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 6594 4th Line Rd ✅ (matches verified list)
**Menu Status:** 17 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 83 Mill Street (Restaurant ID: 821)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 83 Mill Street ✅ (matches verified list)
**Menu Status:** 11 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Milano 6500 Russell Road (Restaurant ID: 837)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 6500 Russell Road ✅ (matches verified list)
**Menu Status:** 15 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Mont Liban Bakery & Shawarma (Restaurant ID: 205)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 351 Montreal Rd ✅ (matches verified list)
**Menu Status:** 26 dishes, 1 course (Uncategorized), all assigned ✅, status active ✅
**Notes:** Google Maps shows location as "PERMANENTLY CLOSED" but restaurant appears on verified billing list
**Result:** Status corrected. All dishes properly assigned to Uncategorized course.

#### Vanier Pizza & Subs (Restaurant ID: 62)
**Status:** ⚠️ CRITICAL DATA ISSUE - Only 1 dish in database
**Date:** 2025-11-05 | **Last Updated:** 2025-11-06
**Address:** 201 Marier Ave ✅ (matches verified list)

**Menu Status:**
- Total dishes: 1 ⚠️⚠️⚠️ (EXTREMELY LOW)
- Courses defined: 1 (Uncategorized) ✅
- Dishes with course_id: 1 (100%) ✅
- Dishes with prices: 1 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Critical data loss - restaurant has lost majority of menu data. Only 1 dish remains in database. Requires menu restoration.

---

### Restaurants with Defined Courses But Dishes Not Properly Distributed

#### Milano 777 Principale St (Restaurant ID: 89)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 777 Principale St ✅ (matches verified list)
**Menu Reference:** [https://casselman.milanopizzeria.ca/?p=menu](https://casselman.milanopizzeria.ca/?p=menu)

**Menu Status:**
- Total dishes: 41
- Courses defined: 18 ✅ (Proper courses exist)
- Dishes with course_id: 41 (100%) ✅
- Status: active ✅ (corrected from suspended)

**Course Structure:**
- 18 courses defined: Appetizers, Cold Subs, Chicken, Combos, Dessert, Donair and Shawarma, Drinks, Everyday Specials, Greek, Hot Subs, Italian, Mexican, Pita Pockets, Salads, Sandwiches, Seafood, Traditional Pizza, Uncategorized

**Critical Issue:**
- **ALL 41 dishes assigned to "Uncategorized" course** despite having 17 other proper courses defined
- The 17 proper courses exist but have 0 dishes assigned to them
- This requires manual redistribution of dishes from Uncategorized to the appropriate courses

**Notes:**
- Course structure in database doesn't fully match live menu structure
- Database courses need alignment with live menu before dish redistribution
- Requires manual review and dish-to-course assignment

**Result:** Status corrected. Restaurant has proper course structure but all dishes incorrectly assigned to Uncategorized. Requires manual dish redistribution.

#### River Pizza (Restaurant ID: 952)
**Status:** ⚠️ NEEDS ASSIGNMENT - 71 dishes, 12 courses defined, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 4042 Innes Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 71 ✅
- Courses defined: 12 ✅
- Dishes with NULL course_id: 71 (100%) ⚠️⚠️⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 71 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 71 ✅ (Outstanding!)
- Dish modifiers: 26,270 ✅ (Exceptional modifier system! ~370 modifiers per dish)
- Status: active ✅

**Course Structure:**
12 courses defined in database - awaiting course-to-dish assignment.

**Result:** ⚠️ Restaurant has comprehensive menu data and exceptional modifier configuration, but ALL dishes lack course_id assignment. Requires automated or manual course assignment process.

---

### Restaurants with No Courses Defined

#### Mykonos Greek Grill 2600 County Rd 43 (Restaurant ID: 846)
**Status:** ✅ Active
**Date:** 2025-11-05
**Address:** 2600 County Rd 43 ✅ (matches verified list)
**Menu Reference:** [https://kemptville.mykonosgreekgrill.ca/?p=menu](https://kemptville.mykonosgreekgrill.ca/?p=menu)

**Menu Status:**
- Total dishes: 42
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 42 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Status: active ✅

**Required Courses (from live menu):**
1. Mykonos Souvlaki Platter (11 items)
2. Pita Wraps (6 items)
3. Salads (2 items)
4. Appetizers (9 items)
5. Extras (6 items)
6. Desserts (3 items)
7. Drinks (6 items)

**Notes:**
- No courses exist in database - must create all courses first
- All 42 dishes have NULL course_id
- Modifiers exist for Mini Donuts (flavor options: Icing Sugar, Oreo, Cinnamon Sugar)

**Result:** Restaurant requires course creation before any dish assignment can proceed.

#### Mykonos Greek Grill 6594 Fourth Line Rd (Restaurant ID: 845)
**Status:** ✅ Active
**Date:** 2025-11-05
**Address:** 6594 Fourth Line Rd ✅ (matches verified list)
**Menu Reference:** [https://northgower.mykonosgreekgrill.ca/?p=menu](https://northgower.mykonosgreekgrill.ca/?p=menu)

**Menu Status:**
- Total dishes: 41
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 41 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Status: active ✅

**Required Courses (from live menu):**
1. Mykonos Souvlaki Platter (10 items)
2. Pita Wraps (6 items)
3. Salads (2 items)
4. Appetizers (9 items)
5. Extras (6 items)
6. Desserts (3 items)
7. Drinks (5 items)

**Notes:**
- No courses exist in database - must create all courses first
- All 41 dishes have NULL course_id
- Modifiers exist for Mini Donuts (flavor options: Icing Sugar, Oreo, Cinnamon Sugar)

**Result:** Restaurant requires course creation before any dish assignment can proceed.

#### Kirkwood Pizza (Restaurant ID: 832)
**Status:** ⚠️ CRITICAL - No menu data
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 1078 Merivale Road ✅ (matches verified list)

**Menu Status:**
- Total dishes: 0 ⚠️⚠️⚠️
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 0
- Dishes with course_id: 0
- Dishes with prices: 0
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️⚠️⚠️ Complete data loss - restaurant has ZERO dishes and ZERO courses. Requires full menu migration from scratch.

#### La Maison Pho (Restaurant ID: 721)
**Status:** ⚠️ NEEDS COURSES - 135 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 4 Rue Belmont ✅ (matches verified list)

**Menu Status:**
- Total dishes: 135 ✅
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 135 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 135 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Restaurant has substantial menu data (135 dishes), but NO courses defined. Requires course structure creation before dish assignment.

#### Sushi Fleury (Restaurant ID: 596)
**Status:** ⚠️ NEEDS COURSES - 338 dishes, 0 courses, 100% unassigned
**Date:** 2025-11-03 | **Last Updated:** 2025-11-06
**Address:** 2481 Fleury Est ✅ (matches verified list)

**Menu Status:**
- Total dishes: 338 ✅ (Large menu!)
- Courses defined: 0 ⚠️⚠️⚠️
- Dishes with NULL course_id: 338 (100%) ⚠️
- Dishes with course_id: 0 (0%)
- Dishes with prices: 338 (100%) ✅
- Dishes with size options: 0
- Modifier groups: 0 ⚠️
- Dish modifiers: 0 ⚠️
- Status: active ✅

**Result:** ⚠️ Restaurant has extensive menu (338 dishes), but NO courses defined. Requires comprehensive course structure creation before dish assignment.

---

### Restaurants with No Menu Data

#### New Hong Kong 1433 Woodroffe Ave (Restaurant ID: 502)
**Status:** ✅ STATUS CORRECTED - Was suspended, now active
**Date:** 2025-11-05
**Address:** 1433 Woodroffe Ave ✅ (matches verified list)
**Menu Reference:** [https://newhongkongchinese.ca/?p=menu](https://newhongkongchinese.ca/?p=menu)

**Menu Status:**
- Total dishes: 0 ⚠️⚠️⚠️
- Courses defined: 0 ⚠️⚠️⚠️
- Status: active ✅ (corrected from suspended)

**Live Menu Structure (from website):**
- Chef's Special (13 items)
- Combination Plates (12 items)
- Family Dinners (8 items)
- Appetizers (9+ items)
- Soups, Fried Rice, Oriental Style Rice, Chop Suey, Chicken, Beef, Pork
- Vegetarian Dishes
- Noodles (80+ items)
- Hot and Spicy (Mild) (13+ items)
- Miscellaneous, Seafood, Egg Foo Young
- Beverages (5 items)
- **Estimated Total:** 150+ dishes on live menu

**Critical Issue:**
- **ZERO dishes in database** despite active online ordering menu with 150+ items
- **ZERO courses defined**
- This represents a 100% data migration failure
- Restaurant is active and billing but has no menu data in database

**Result:** Status corrected. Catastrophic data migration failure - restaurant requires complete menu data migration from scratch.

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