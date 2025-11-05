# RestaurantPlus.net Platform Migration (Restaurants That Left Our Platform)

**Date:** 2025-11-03
**Purpose:** Document restaurants from our active list that are NO LONGER ACTIVE on our platform and have switched to RestaurantPlus.net/OlivePOS

**Note:** This is NOT a data migration check. These restaurants have LEFT our platform and moved to a competing POS/ordering system (RestaurantPlus.net/OlivePOS). They should be removed from our active restaurant list or marked as inactive/migrated.

## Confirmed Matches Found - 19 RESTAURANTS ON RESTAURANTPLUS.NET

**Date Confirmed:** 2025-11-03
**Source:** User verification from RestaurantPlus.net platform

### Complete List (19 restaurants):

1. **Oriental House Restaurant** (266 Elgin St, Ottawa)
2. **Guillotine Street Food** (105a Clarence St)
3. **Photime Authentic Vietnamese Eatery** (9255 Woodbine Ave Unit 7A)
4. **Cumberland Pizza**
5. **Samo's Greek Kitchen** (911 Richmond Road)
6. **Old Avenue Restaurant**
7. **The Bagel Run**
8. **Viet Express**
9. **My Thai Village Restaurant**
10. **Chili Craft Pizza**
11. **Laheeb Shawarma**
12. **Hà Nội Phố** (listed as "Pho Ha Noi 54" on RestaurantPlus.net)
13. **Pho Binh Minh 3**
14. **The Hot Wok**
15. **Da Nang Restaurant**
16. **River Pizza**
17. **Golden Center Pizza** (600 Rideau Street)
18. **Lucky King Take Out** (1134 Cadboro Rd) - Previously identified
19. **Vanier Pizza & Subs** (201 Marier Ave) - Previously identified
20. **Westboro Subs** (1262 Wellington St. W) - Previously identified

**Total:** 19 restaurants confirmed on RestaurantPlus.net/OlivePOS platform

## Database Status Check

Checking which of these restaurants exist in our menuca_v3 database:

### Found in Database:

1. **Centertown Donair & Pizza** (ID: 131)
   - Status: suspended
   - Dishes: 26
   - Courses: 5
   - Course Assignment: All assigned ✅
   - **Action:** Status mismatch - suspended but in active list

2. **Golden Center Pizza** (ID: 815)
   - Status: active
   - Dishes: 10
   - Courses: 1
   - Course Assignment: All assigned ✅
   - **Action:** Needs review - 10 dishes seems low for pizza restaurant

3. **River Pizza** (ID: 952)
   - Status: active
   - Dishes: 71
   - Courses: 12
   - Course Assignment: **71 NULL course_id** ⚠️ NEEDS ASSIGNMENT
   - **Action:** Restaurant on RestaurantPlus.net but needs course assignment work

4. **Samo's Greek Kitchen** (ID: 791)
   - Status: active
   - Dishes: 14
   - Courses: 1
   - Course Assignment: All assigned ✅
   - **Action:** Needs review - 14 dishes seems low, might need proper courses

5. **Lucky King Take Out** (ID: 174) - Previously documented
   - Status: active
   - Dishes: 141
   - Courses: 14
   - Course Assignment: All assigned ✅

6. **Vanier Pizza & Subs** (ID: 62) - Previously documented
   - Status: suspended
   - Dishes: 1
   - Courses: 1

7. **Westboro Subs** (ID: 778) - Previously documented
   - Status: active
   - Dishes: 47
   - Courses: 0

### Not Found in Database (Need Name Matching):

The following restaurants from RestaurantPlus.net were not found with exact name matches:
- Oriental House Restaurant
- Guillotine Street Food
- Photime Authentic Vietnamese Eatery
- Cumberland Pizza
- Old Avenue Restaurant
- The Bagel Run
- Viet Express
- My Thai Village Restaurant
- Chili Craft Pizza
- Laheeb Shawarma
- Hà Nội Phố / Pho Ha Noi 54
- Pho Binh Minh 3
- The Hot Wok
- Da Nang Restaurant

**Note:** These may exist in database with slightly different names or may not have been migrated.

## Pattern Identified

Restaurants on RestaurantPlus.net appear to be using **OlivePOS** (based on footer: "OliveNow Inc" and "Start using OlivePOS").

## Next Steps

1. **Systematic Check:** Need to search RestaurantPlus.net for each restaurant in our active list
2. **Update Documentation:** Mark restaurants found on RestaurantPlus.net as "USING RESTAURANTPLUS.NET/OLIVEPOS"
3. **Service Verification:** Confirm if these restaurants should be removed from our active list or marked differently
4. **Data Impact:** Restaurants using RestaurantPlus.net may not need course assignment work if they've fully migrated

## Method for Checking

Due to limitations in automated checking, recommend:
1. Manual search on RestaurantPlus.net for each restaurant name + address
2. Or use RestaurantPlus.net API/search functionality if available
3. Cross-reference addresses as matching criteria (names may vary slightly)

## Restaurants to Check

Priority restaurants to verify (those with suspicious data patterns):
- All restaurants with "No Courses Defined" but have dishes
- All restaurants with status mismatches (suspended but in active list)
- All restaurants with suspiciously low dish counts

