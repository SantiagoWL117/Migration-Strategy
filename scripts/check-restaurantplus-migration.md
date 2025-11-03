# RestaurantPlus.net Migration Check

**Date:** 2025-11-03
**Purpose:** Cross-reference our active restaurant list with RestaurantPlus.net to identify restaurants that have migrated to their platform

## Confirmed Matches Found

### From RestaurantPlus.net Homepage (https://restaurantplus.net/home/food):

1. **Lucky King** (1134 Cadboro Rd)
   - Matches: "Lucky King Take Out 1134 Cadboro Rd" from our list (line 96)
   - Status: Found on RestaurantPlus.net
   - Action: Flag for service verification

### From User Confirmation:

2. **Vanier Pizza & Subs** (201 Marier Ave)
   - Matches: "Vanier Pizza & Subs 201 Marier Ave" from our list (line 243)
   - Status: Confirmed on RestaurantPlus.net
   - Action: Already flagged - needs service verification

3. **Westboro Subs** (1262 Wellington St. W)
   - Matches: "Westboro Subs 1262 Wellington St. W" from our list (line 246)
   - Status: Confirmed on RestaurantPlus.net
   - Action: Already flagged - needs service verification

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

