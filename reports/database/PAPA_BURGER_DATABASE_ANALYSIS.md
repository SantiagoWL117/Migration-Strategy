# Papa Burger Database Analysis
**Date:** 2025-11-07
**Status:** Data Mismatch Identified

## Summary

The scraper found **80 dishes** on papaburger.ca, but the database has inconsistent data across two restaurant entries with **NO modifiers** for the main Papa Burger Maloney location.

## Database Current State

### Restaurant IDs
1. **Papa Burger** (ID: 797)
   - Only 4 dishes
   - Different menu items (Blackened Steak Salad, Clocktower Club, Falafel, Lettuce Wraps)
   - Has modifier groups assigned (but only 1 modifier each)
   - Appears to be wrong restaurant data

2. **Papa Burger Maloney** (ID: 822)
   - 64 dishes with French names
   - All have `legacy_v1_id` (from V1 import)
   - All have `course_id: NULL` - **No course assignments**
   - All have `has_customization: false` - **No modifiers linked**
   - Missing 16 dishes compared to scraper (80 found vs 64 in DB)

### Key Issues

1. **Missing Dishes:** 80 on website vs 64 in database = **16 dishes missing**
2. **No Modifiers:** Papa Burger Maloney has ZERO modifier groups/options
3. **No Courses:** All dishes have NULL course_id
4. **Wrong Restaurant:** Papa Burger (797) has wrong menu entirely

## Scraper Results

### What Works ✅
- Found all 80 dishes on website
- Extracted **33 modifier groups** with **165 options** perfectly
- Examples of perfect modifier data:
  - Sauce levels: "Douce", "Moyenne", "Fort", "Miel et Ail"
  - Drinks: "Pepsi", "Diet Pepsi", "7 Up", "Ginger Ale"
  - Sides: "Frites", "Rondelles d'oignon", "Poutine"

### What Fails ❌
- Dish names all show "Unknown"
- Prices all show `null`

## Database Schema Structure

The current schema uses:
- `dishes` table (no tenant_id column)
- `modifier_groups` table (dish_id FK - groups are dish-specific)
- `dish_modifiers` table (individual modifier options)
- `courses` table (for categorization)

**NOT using the new v3_modifier_schema.sql we created**

## Action Items

### Immediate (Fix Scraper)
1. Fix dish name extraction in v1-scraper-improved.ts
2. Fix price extraction
3. Consider 3-tool approach:
   - Tool 1: Get dish names (user's Firecrawl scraper works 100%)
   - Tool 2: Get modifiers (current scraper works 100%)
   - Tool 3: Stitch them together by position/index

### Database Import
1. Create courses for Papa Burger Maloney
2. Assign dishes to courses
3. Import modifier groups and options from scraper
4. Link modifiers to correct dishes
5. Verify 80 dishes total (may need to scrape missing 16)

### Verification
1. Compare scraped data position by position with existing dishes
2. Map by `legacy_v1_id` if available
3. Handle the 16 missing dishes

## Next Steps

1. **Focus on Papa Burger Maloney (822)** - this is the correct restaurant
2. Fix scraper name/price extraction
3. Create import tool to match scraped modifiers to existing dishes
4. Verify all 80 dishes are captured
