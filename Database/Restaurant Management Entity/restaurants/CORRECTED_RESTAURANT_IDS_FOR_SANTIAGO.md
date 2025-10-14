# Restaurant Status Correction - IDs for Validation

**For:** Santiago (DB Manager)  
**Date:** October 14, 2025  
**Total Restaurants:** 101  
**Purpose:** Validate schedules, delivery operations, and other dependencies

---

## 📋 Complete List of Restaurant IDs

### All 101 Restaurant IDs (Comma-Separated)

```
8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546
```

### SQL Query Format (for WHERE IN clause)

```sql
SELECT * FROM menuca_v3.restaurants 
WHERE id IN (
  8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 
  65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 
  105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 
  196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 
  328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 
  486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546
);
```

---

## 🔍 Validation Queries for Santiago

### Check Restaurant Schedules

```sql
-- Find corrected restaurants WITHOUT schedules
SELECT 
  r.id,
  r.name,
  r.status,
  COUNT(s.id) as schedule_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
WHERE r.id IN (8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546)
GROUP BY r.id, r.name, r.status
HAVING COUNT(s.id) = 0
ORDER BY r.id;
```

### Check Delivery Operations

```sql
-- Find corrected restaurants WITHOUT delivery configurations
SELECT 
  r.id,
  r.name,
  r.status,
  COUNT(sc.id) as service_config_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_service_configs sc ON sc.restaurant_id = r.id
WHERE r.id IN (8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546)
GROUP BY r.id, r.name, r.status
HAVING COUNT(sc.id) = 0
ORDER BY r.id;
```

### Check Menu Items

```sql
-- Find corrected restaurants WITHOUT menu items
SELECT 
  r.id,
  r.name,
  r.status,
  COUNT(d.id) as dish_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
WHERE r.id IN (8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546)
GROUP BY r.id, r.name, r.status
HAVING COUNT(d.id) = 0
ORDER BY r.id;
```

### Check Locations

```sql
-- Find corrected restaurants WITHOUT location data
SELECT 
  r.id,
  r.name,
  r.status,
  COUNT(rl.id) as location_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
WHERE r.id IN (8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546)
GROUP BY r.id, r.name, r.status
HAVING COUNT(rl.id) = 0
ORDER BY r.id;
```

### Comprehensive Validation Query

```sql
-- Check ALL dependencies for the 101 corrected restaurants
SELECT 
  r.id,
  r.name,
  r.status,
  COUNT(DISTINCT rl.id) as locations,
  COUNT(DISTINCT s.id) as schedules,
  COUNT(DISTINCT sc.id) as service_configs,
  COUNT(DISTINCT d.id) as dishes,
  COUNT(DISTINCT c.id) as contacts,
  COUNT(DISTINCT rd.id) as domains
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_locations rl ON rl.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_schedules s ON s.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_service_configs sc ON sc.restaurant_id = r.id
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_contacts c ON c.restaurant_id = r.id
LEFT JOIN menuca_v3.restaurant_domains rd ON rd.restaurant_id = r.id
WHERE r.id IN (8, 13, 15, 16, 22, 28, 31, 35, 37, 42, 44, 45, 47, 48, 54, 55, 57, 59, 60, 62, 65, 69, 70, 72, 74, 75, 77, 78, 84, 87, 88, 89, 90, 92, 93, 94, 95, 97, 98, 102, 105, 106, 109, 112, 119, 123, 124, 126, 131, 133, 143, 160, 174, 180, 185, 190, 196, 199, 205, 207, 211, 223, 234, 241, 245, 249, 265, 267, 269, 273, 300, 302, 328, 348, 349, 350, 356, 367, 375, 376, 387, 427, 437, 443, 465, 468, 479, 482, 486, 490, 491, 497, 498, 502, 507, 511, 515, 519, 521, 538, 546)
GROUP BY r.id, r.name, r.status
ORDER BY r.id;
```

---

## 📊 Detailed List with Restaurant Names

| ID | Restaurant Name | Previous Status | New Status |
|----|-----------------|-----------------|------------|
| 8 | Lucky Star Chinese Food | pending | active |
| 13 | Papa Joe's Pizza - Downtown | suspended | active |
| 15 | New Mee Fung Restaurant | suspended | active |
| 16 | Papa Joe's Pizza - Greely & Findlay Creek | suspended | active |
| 22 | House of Lasagna | suspended | active |
| 28 | Eastview Pizza | suspended | active |
| 31 | Milano | suspended | active |
| 35 | Mozza Pizza | suspended | active |
| 37 | House of Pizza | suspended | active |
| 42 | Cypress Garden | pending | active |
| 44 | Kiki Lebanese Pineview Pizza | suspended | active |
| 45 | Bobbie's Pizza & Subs | suspended | active |
| 47 | Mr Mozzarella - Nepean | suspended | active |
| 48 | Merivale Pizza & Wings | suspended | active |
| 54 | House of Pizza | suspended | active |
| 55 | Milano | suspended | active |
| 57 | Milano | suspended | active |
| 59 | Milano | suspended | active |
| 60 | Opa's | suspended | active |
| 62 | Vanier Pizza & Subs | suspended | active |
| 65 | Number One Chinese Take Out | pending | active |
| 69 | Aylmer BBQ | suspended | active |
| 70 | Papa Pizza - Hull | suspended | active |
| 72 | Cathay Restaurants | pending | active |
| 74 | Moe's Famous Pizza | suspended | active |
| 75 | Milano | suspended | active |
| 77 | Lorenzo's Pizzeria - Vanier | suspended | active |
| 78 | House Of Georgie - 'Sorento's' | suspended | active |
| 84 | The Original Georgie's | suspended | active |
| 87 | Champa Thai Food | suspended | active |
| 88 | Milano | suspended | active |
| 89 | Milano | suspended | active |
| 90 | Milano | suspended | active |
| 92 | Milano | suspended | active |
| 93 | Milano | suspended | active |
| 94 | Milano | suspended | active |
| 95 | Milano | suspended | active |
| 97 | Milano | suspended | active |
| 98 | Milano | suspended | active |
| 102 | Lemon Grass Restaurant | pending | active |
| 105 | Ginkgo Garden | suspended | active |
| 106 | Restaurant Le Choix | suspended | active |
| 109 | Restaurant Chez Gerry | suspended | active |
| 112 | Papa Pizza - Gatineau Ouest | suspended | active |
| 119 | Hung Mein | pending | active |
| 123 | Milano | suspended | active |
| 124 | Carlo's Pizza | suspended | active |
| 126 | Milano | suspended | active |
| 131 | Centertown Donair & Pizza | suspended | active |
| 133 | Riverside Pizzeria | suspended | active |
| 143 | Tony's Pizza | suspended | active |
| 160 | Hong Kong Chinese Food Takeout | suspended | active |
| 174 | Lucky King Take Out | pending | active |
| 180 | Indian Punjabi Clay Oven | pending | active |
| 185 | Vietnamese Noodle House | suspended | active |
| 190 | Milano | suspended | active |
| 196 | Colonnade Pizza | suspended | active |
| 199 | Pho Bo Ga King - Somerset | suspended | active |
| 205 | Mont Liban Bakery & Shawarma | suspended | active |
| 207 | Papa Pizza - Gatineau Est | suspended | active |
| 211 | Erman Pizza | suspended | active |
| 223 | 2 for 1 Pizza | suspended | active |
| 234 | New Mukut Restaurant Indian Cuisine | suspended | active |
| 241 | Beneci Pizza | suspended | active |
| 245 | Orchid Sushi | pending | active |
| 249 | La Rumeur | suspended | active |
| 265 | Milano | suspended | active |
| 267 | Lucky Fortune | suspended | active |
| 269 | Shaan Tandoori | pending | active |
| 273 | Sous Le Palmier | suspended | active |
| 300 | Fat Albert's | suspended | active |
| 302 | La Porte de L'Inde | suspended | active |
| 328 | JN Pizza | suspended | active |
| 348 | Sushi Express Fantasia | suspended | active |
| 349 | Milano | suspended | active |
| 350 | Milano | suspended | active |
| 356 | Wow Sushi | suspended | active |
| 367 | Xtreme Pizza | suspended | active |
| 375 | Restaurant O'Wok | suspended | active |
| 376 | Sachi Sushi | suspended | active |
| 387 | Pizza Lovers Laurier | suspended | active |
| 427 | Papa Joe's Pizza - Bridle Path | pending | active |
| 437 | Papa Joe's Fried Chicken - Downtown | suspended | active |
| 443 | Papa Joe's Fried Chicken - Bridle Path | suspended | active |
| 465 | Royal Thai Cuisine | suspended | active |
| 468 | Just Wok | suspended | active |
| 479 | iCook Pho You | suspended | active |
| 482 | The Wok | suspended | active |
| 486 | Wandee Thai Cuisine Sept 2022 | pending | active |
| 490 | Thai to Go | suspended | active |
| 491 | Light of India | pending | active |
| 497 | Rangoli | suspended | active |
| 498 | Papa Pizza - Val-des-Monts | suspended | active |
| 502 | New Hong Kong | suspended | active |
| 507 | Pizza Lovers Hunt Club | suspended | active |
| 511 | Egg Roll Factory | pending | active |
| 515 | Napolis | suspended | active |
| 519 | HaNoi Pho | suspended | active |
| 521 | Palermo Pizzeria | suspended | active |
| 538 | Pizza la Différence | suspended | active |
| 546 | Burger Lovers | suspended | active |

---

## 🏪 Notable Chains in the List

### Milano Locations (18 locations)
IDs: 31, 55, 57, 59, 75, 88, 89, 90, 92, 93, 94, 95, 97, 98, 123, 126, 190, 265, 349, 350

### Papa Joe's Pizza (3 locations)
IDs: 13, 16, 427

### Papa Joe's Fried Chicken (2 locations)
IDs: 437, 443

### Papa Pizza (4 locations)
IDs: 70, 112, 207, 498

### House of Pizza (2 locations)
IDs: 37, 54

### Pizza Lovers (2 locations)
IDs: 387, 507

---

## ⚠️ Important Notes for Santiago

1. **All 101 restaurants are now `status='active'` in production**
2. **Changes were committed on:** 2025-10-14 13:37:08 UTC
3. **Validation needed for:**
   - Restaurant schedules (operating hours)
   - Delivery configurations
   - Menu items (dishes)
   - Location data
   - Contact information
   - Domain mappings

4. **Expected findings:**
   - Some restaurants may lack schedules if they were never fully configured in V1/V2
   - This is normal - they were marked active in V1 but may not have complete data

5. **Source of truth:** These restaurants were all marked `active='Y'` in V1 database

---

## 📞 Contact

Questions about this correction:
- See full report: `/Database/Restaurant Management Entity/restaurants/EXECUTION_REPORT_ACTIVE_STATUS_CORRECTION.md`
- Audit trail: Query `staging.active_restaurant_corrections` table
- Brian Lapp (Migration lead)

---

**Generated:** October 14, 2025  
**Total Restaurants:** 101  
**All Changes:** LIVE IN PRODUCTION ✅

