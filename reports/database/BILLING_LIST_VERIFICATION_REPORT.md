# Billing List Verification Report

## SOURCE OF TRUTH FOR DATABASE CLEANUP

**Date:** 2025-11-10  
**Database:** menu-rebuild-vo (menuca_v3)  
**Billing List:** Restaurants-active.md (189 restaurants)  
**Purpose:** Identify which restaurants to KEEP vs DELETE during schema cleanup

---

## ⚠️ CRITICAL WARNING

**TWO BATCH SCRAPING JOBS ARE CURRENTLY RUNNING**  
Do NOT delete any restaurant with status ✅ FOUND until batch jobs complete.  
These restaurants have their IDs confirmed and are safe to keep.

---

## Executive Summary

| Status                    | Count       | Action                                 |
| ------------------------- | ----------- | -------------------------------------- |
| ✅ **FOUND - Keep These** | 137         | PROTECTED - Do not delete              |
| 🔴 **NOT FOUND**          | 52          | 8 need scraping, 44 need investigation |
| ⚠️ **DUPLICATE**          | 4 (2 pairs) | Keep 1 from each pair, delete other    |
| 🟡 **MISSING ADDRESS**    | 4           | Add addresses, then keep               |
| **TOTAL BILLING LIST**    | **189**     | Target final count                     |

---

## ✅ SECTION 1: FOUND IN DATABASE - KEEP THESE (137 restaurants)

**STATUS: PROTECTED - DO NOT DELETE THESE RESTAURANT IDs**

These restaurants from your billing list exist in the database with confirmed IDs and addresses.
All of these are currently being scraped or have been scraped successfully.

| Billing List Name & Address                                      | DB ID | DB Name                            | DB Address                        | Notes                            | Menu Data Scraped |
| ---------------------------------------------------------------- | ----- | ---------------------------------- | --------------------------------- | -------------------------------- | ----------------- |
| Aahar The Taste of India 1573 Alta Vista Drive                   | 561   | Aahar The Taste of India           | 1573 Alta Vista Drive             | Perfect match                    | YES               |
| Al-s Drive In 5474 Osgoode Main Street                           | 981   | Al-s Drive In                      | 5474 Osgoode Main Street          | Perfect match                    | NO                |
| All Out Burger 2560 Bank Street                                  | 924   | All Out Burger Bank St.            | 2560 Bank Street                  | Perfect match                    | NO                |
| All Out Burger 3091 Strandherd, Dr.7                             | 841   | All Out Burger                     | 3091 Strandherd, Dr.7             | Perfect match                    | NO                |
| All Out Burger 585 Montreal Road                                 | 949   | All Out Burger Montreal Rd         | 585 Montréal Road                 | Perfect match                    | NO                |
| All Out Burger 714 Gladstone Ave                                 | 948   | All Out Burger Gladstone           | 714 Gladstone Avenue              | Perfect match                    | NO                |
| All Out Burger 951 Notre-Dame St                                 | 833   | All Out Burger                     | 951 Notre-Dame St                 | Perfect match                    | NO                |
| Amicci Pizza 2 Boulevard Louise-Campagna                         | 735   | Amicci Pizza                       | 2 Boulevard Louise-Campagna       | Perfect match                    | NO                |
| Aroy Thai 1 Rideaucrest Drive                                    | 607   | Aroy Thai                          | 1 Rideaucrest Drive               | Perfect match                    | YES               |
| Asia Garden Ottawa 886 Dynes Road                                | 630   | Asia Garden Ottawa                 | 886 Dynes Road                    | Perfect match                    | NO                |
| Aylmer BBQ 134, rue Principale                                   | 69    | Aylmer BBQ                         | 134, rue Principale               | Perfect match                    | YES               |
| Beneci Pizza 4 Lorry Greenberg Dr                                | 241   | Beneci Pizza                       | 4 Lorry Greenberg Dr              | Perfect match                    | YES               |
| Capital Bites 34 Grenfell Crescent                               | 973   | Capital Bites                      | 34 Grenfell Crescent              | Perfect match                    | NO                |
| Capri Pizza 4000 Bridle Path Drive                               | 977   | Capri Pizza                        | 4000 Bridle Path Drive            | Perfect match                    | NO                |
| Carlo's Pizza 60 Harmer Ave                                      | 124   | Carlo's Pizza                      | 60 Harmer Ave                     | Perfect match                    | YES               |
| Cathay Restaurants 1423 Woodroffe Ave                            | 72    | Cathay Restaurants                 | 1423 Woodroffe Ave                | Perfect match                    | YES               |
| Centertown Donair & Pizza 422 Bronson Ave                        | 131   | Centertown Donair & Pizza          | 422 Bronson Ave                   | Perfect match                    | YES               |
| Champa Thai Cuisine 193 King Edward Ave                          | 87    | Champa Thai Cuisine                | 193 King Edward Ave               | Perfect match                    | YES               |
| Charm Thai Cuisine 121 Preston St                                | 943   | Charm Thai Cuisine                 | 121 Preston Street                | Perfect match                    | NO                |
| Chicco Pizza & Shawarma Buckingham 1009 Chemin de Masson         | 962   | Chicco Pizza & Shawarma Buckingham | 1009 Chemin de Masson             | Perfect match                    | NO                |
| Chicco Pizza Maloney 842 Boulevard Maloney Est                   | 964   | Chicco Pizza Maloney               | 842 Boulevard Maloney Est         | Perfect match                    | NO                |
| Chicco Pizza Shawarma Anger 1096 Chemin de Montréal Ouest        | 963   | Chicco Pizza Shawarma Anger        | 1096 Chemin de Montréal Ouest     | Perfect match                    | NO                |
| Chicco Pizza St-Louis 1783 Rue Saint-Louis                       | 967   | Chicco Pizza St-Louis              | 1783 Rue Saint-Louis              | Perfect match                    | NO                |
| Chicco Pizza de l'Hopital 405 Boulevard de l'Hôpital             | 966   | Chicco Pizza de l'Hopital          | 405 Boulevard de l'Hôpital        | Perfect match                    | NO                |
| Chicco Shawarma Cantley 435 Montée de la Source                  | 961   | Chicco Shawarma Cantley            | 435 Montée de la Source           | Perfect match                    | NO                |
| Chicco Shawarma Maloney 922 Boulevard Maloney Est                | 965   | Chicco Shawarma Maloney            | 922 Boulevard Maloney Est         | Perfect match                    | NO                |
| China Moon 273 boul. St-RenÃ© Ouest                              | 641   | China Moon                         | 273 boul. St-René Ouest           | Perfect match                    | YES               |
| Colonnade Pizza 1500 Bank St                                     | 783   | Colonnade Pizza                    | 1500 Bank St                      | Perfect match                    | NO                |
| Colonnade Pizza 2140 Carling Ave                                 | 784   | Colonnade Pizza                    | 2140 Carling Ave                  | Perfect match                    | NO                |
| Colonnade Pizza 896 Greenbank Rd                                 | 785   | Colonnade Pizza                    | 896 Greenbank Rd                  | Perfect match                    | NO                |
| Cosenza 6505 Jeanne d'Arc Boulevard North                        | 957   | Cosenza                            | 6505 Jeanne d'Arc Boulevard North | Perfect match                    | NO                |
| Crispy's 1433 Woodrofe                                           | 584   | Crispy's                           | 1433 Woodrofe                     | Perfect match                    | YES               |
| Crispy's Bank Street 2446 Bank Street                            | 806   | Crispy's Bank Street               | 2446 Bank Street                  | Perfect match                    | NO                |
| Cuisine Bombay Indienne 120 Rue Richelieu                        | 960   | Cuisine Bombay Indienne            | 120 Rue Richelieu                 | Perfect match                    | NO                |
| Digby's Restaurant 300 Earl Grey Dr                              | 638   | Digby's Restaurant                 | 300 Earl Grey Dr                  | Perfect match                    | YES               |
| Dumpling Bowl 730 Somerset                                       | 792   | Dumpling Bowl                      | 730 Somerset                      | Perfect match                    | NO                |
| DÃ©panneur GÃ©nÃ©reux 428 Rue GÃ©nÃ©reux                         | 816   | Dï¿½panneur Gï¿½nï¿½reux           | 428 Rue Généreux                  | Encoding issue - same restaurant | YES               |
| Egg Roll Factory 261 Centrepointe drive                          | 511   | Egg Roll Factory                   | 261 Centrepointe drive            | Perfect match                    | YES               |
| Friendly Restaurant and Pizzeria 1756 Laurier St                 | 730   | Friendly Restaurant and Pizzeria   | 1756 Laurier St                   | Perfect match                    | NO                |
| Golden Center Pizza 600 Rideau Street                            | 815   | Golden Center Pizza                | 600 Rideau Street                 | Perfect match                    | NO                |
| Hung Mein 2567 Baseline Rd                                       | 119   | Hung Mein                          | 2567 Baseline Rd                  | Perfect match                    | YES               |
| Imilio's Pizzeria 110 Bearbrook Rd                               | 7     | Imilio's Pizzeria                  | 110 Bearbrook Rd                  | Perfect match                    | YES               |
| Indian Punjabi Clay Oven 6-4055 Carling Ave.                     | 180   | Indian Punjabi Clay Oven           | 6-4055 Carling Ave.               | Perfect match                    | YES               |
| JC Royal Thai Cuisine 100 Jamieson Pkwy, Unit 11                 | 646   | JC Royal Thai Cuisine              | 100 Jamieson Pkwy, Unit 11        | Perfect match                    | YES               |
| Joes Family Pizzeria 284 Pembroke St W                           | 636   | Joes Family Pizzeria               | 284 Pembroke St W                 | Perfect match                    | YES               |
| Kirkwood Pizza 1078 Merivale Road                                | 950   | Kirkwood Pizza                     | 1078 Merivale Road                | Perfect match                    | NO                |
| La Maison Pho 4 Rue Belmont                                      | 721   | La Maison Pho                      | 4 Rue Belmont                     | Perfect match                    | NO                |
| La Maison du Burger 574 Boulevard Saint-Joseph                   | 727   | La Maison du Burger                | 574 Boulevard Saint-Joseph        | Perfect match                    | YES               |
| La Poutinerie Ogilvie 1443 Ogilvie Rd                            | 715   | La Poutinerie Ogilvie              | 1443 Ogilvie Rd                   | Perfect match                    | NO                |
| Light of India 730 Bank St                                       | 491   | Light of India                     | 730 Bank St                       | Perfect match                    | YES               |
| Little Gyros Greek Grill 10 Townsend Drive                       | 756   | Little Gyros Greek Grill           | 10 Townsend Drive                 | Perfect match                    | NO                |
| Little Gyros Greek Grill 1606 Battler Road                       | 971   | Little Gyros Greek Grill           | 1606 Battler Road                 | Perfect match                    | NO                |
| Lucky King Take Out 1134 Cadboro Rd                              | 174   | Lucky King Take Out                | 1134 Cadboro Rd                   | Perfect match                    | YES               |
| Lucky Star Chinese Food 1615 Orleans Blvd.                       | 8     | Lucky Star Chinese Food            | 1615 Orleans Blvd.                | Perfect match                    | YES               |
| Mano City Pizza 5511 Manotick Main St                            | 118   | Mano City Pizza                    | 5511 Manotick Main St             | Perfect match                    | YES               |
| Marina Pizza des Flandres 22 des Flandres                        | 614   | Marina Pizza des Flandres          | 22 des Flandres                   | Perfect match                    | NO                |
| Milano 105 Broadway West                                         | 749   | Milano                             | 105 Broadway West                 | Perfect match                    | NO                |
| Milano 1216 Bank St                                              | 835   | Milano                             | 1216 Bank St                      | Perfect match                    | NO                |
| Milano 147 Main Street Unit 3                                    | 701   | Milano                             | 147 Main Street Unit 3            | Perfect match                    | NO                |
| Milano 1589 Main St                                              | 601   | Milano                             | 1589 Main St                      | Perfect match                    | YES               |
| Milano 178 King St E                                             | 842   | Milano                             | 178 King St E                     | Perfect match                    | NO                |
| Milano 1824 Beachburg                                            | 593   | Milano                             | 1824 Beachburg                    | Perfect match                    | NO                |
| Milano 1896 Prince of Wales                                      | 840   | Milano                             | 1896 Prince of Wales              | Perfect match                    | NO                |
| Milano 2 Woodfield Dr                                            | 651   | Milano                             | 2 Woodfield Dr                    | Perfect match                    | NO                |
| Milano 2529 Baseline                                             | 569   | Milano                             | 2529 Baseline                     | Perfect match                    | NO                |
| Milano 2609 Laurier St                                           | 818   | Milano                             | 2609 Laurier St                   | Perfect match                    | NO                |
| Milano 3050 Woodroffe Ave                                        | 95    | Milano                             | 3050 Woodroffe Ave                | Perfect match                    | YES               |
| Milano 339 Dalhousie St                                          | 91    | Milano                             | 339 Dalhousie St                  | Perfect match                    | YES               |
| Milano 350 St-Philippe Street                                    | 624   | Milano                             | 350 St-Philippe Street            | Perfect match                    | YES               |
| Milano 3796 Champlain Rd                                         | 90    | Milano                             | 3796 Champlain Rd                 | Perfect match                    | YES               |
| Milano 3848 Innes Rd                                             | 57    | Milano                             | 3848 Innes Rd                     | Perfect match                    | YES               |
| Milano 385 Tompkins Ave                                          | 59    | Milano                             | 385 Tompkins Ave                  | Perfect match                    | YES               |
| Milano 4188 Spratt Rd                                            | 565   | Milano                             | 4188 Spratt Rd                    | Perfect match                    | NO                |
| Milano 455 Boulevard Riel                                        | 751   | Milano                             | 455 Boulevard Riel                | Perfect match                    | NO                |
| Milano 471 Hazeldean Rd                                          | 126   | Milano                             | 471 Hazeldean Rd                  | Perfect match                    | YES               |
| Milano 506 Main St W                                             | 350   | Milano                             | 506 Main St W                     | Perfect match                    | YES               |
| Milano 54 Wilson St W                                            | 660   | Milano                             | 54 Wilson St W                    | Perfect match                    | YES               |
| Milano 5516 Osgoode Main S                                       | 349   | Milano                             | 5516 Osgoode Main S               | Perfect match                    | YES               |
| Milano 6179 Perth St.                                            | 190   | Milano                             | 6179 Perth St.                    | Perfect match                    | YES               |
| Milano 643 Boulevard Saint-RenÃ© O                               | 680   | Milano                             | 643 Boulevard Saint-René O        | Perfect match                    | YES               |
| Milano 6500 Russell Road                                         | 837   | Milano                             | 6500 Russell Road                 | Perfect match                    | NO                |
| Milano 6594 4th Line Rd                                          | 819   | Milano                             | 6594 4th Line Rd                  | Perfect match                    | NO                |
| Milano 777 Principale St                                         | 89    | Milano                             | 777 Principale St                 | Perfect match                    | YES               |
| Milano 81 Madawaska Street                                       | 586   | Milano                             | 81 Madawaska Street               | Perfect match                    | NO                |
| Milano 83 Mill Street                                            | 821   | Milano                             | 83 Mill Street                    | Perfect match                    | NO                |
| Milano 876 Montreal Rd.                                          | 31    | Milano                             | 876 Montreal Rd.                  | Perfect match                    | YES               |
| Milano 990 River Rd                                              | 93    | Milano                             | 990 River Rd                      | Perfect match                    | YES               |
| Mont Liban Bakery & Shawarma 351 Montreal Rd                     | 205   | Mont Liban Bakery & Shawarma       | 351 Montreal Rd                   | Perfect match                    | YES               |
| Mozza Pizza Gatineau 425, boul La VÃ©rendrye E                   | 35    | Mozza Pizza                        | 425, boul La Vérendrye E          | Perfect match                    | YES               |
| Mozza Pizza Hull 214 Boul de la CitÃ©-des-Jeunes                 | 644   | Mozza Pizza Hull                   | 214 Boul de la Cité-des-Jeunes    | Perfect match                    | YES               |
| Mr Mozzarella - Nepean 1433 Woodroffe Ave                        | 47    | Mr Mozzarella - Nepean             | 1433 Woodroffe Ave                | Perfect match                    | YES               |
| Mykonos Greek Grill 2600 County Rd 43                            | 846   | Mykonos Greek Grill                | 2600 County Rd 43                 | Perfect match                    | NO                |
| Mykonos Greek Grill 6594 Fourth Line Rd                          | 845   | Mykonos Greek Grill                | 6594 Fourth Line Rd               | Perfect match                    | NO                |
| Nachos Loco Gatineau 643 Boulevard Saint-RenÃ© O                 | 801   | Nachos Loco Gatineau               | 643 Boulevard Saint-René O        | Perfect match                    | NO                |
| Nachos Loco Hull 455 Boulevard Riel                              | 790   | Nachos Loco Hull                   | 455 Boulevard Riel                | Perfect match                    | NO                |
| Napolis 81 Richmond Rd                                           | 515   | Napolis                            | 81 Richmond Rd                    | Perfect match                    | YES               |
| New Hong Kong 1433 Woodroffe Ave                                 | 502   | New Hong Kong                      | 1433 Woodroffe Ave                | Perfect match                    | YES               |
| Number One Chinese Take Out 988 Wellington St                    | 65    | Number One Chinese Take Out        | 988 Wellington St                 | Perfect match                    | YES               |
| Ogilvie Pizza 631 Montreal Rd                                    | 714   | Ogilvie Pizza                      | 631 Montreal Rd                   | Perfect match                    | NO                |
| Oh My Grill 169 York St                                          | 807   | Oh My Grill                        | 169 York St                       | Perfect match                    | NO                |
| Oka's Hull 1030 Boulevard Saint-Joseph                           | 681   | Oka's Hull                         | 1030 Boulevard Saint-Joseph       | Perfect match                    | YES               |
| Orchid Sushi 445 Laurier Ave W                                   | 245   | Orchid Sushi                       | 445 Laurier Ave W                 | Perfect match                    | YES               |
| Pachino Pizza 3515 Albion Road South                             | 974   | Pachino Pizza                      | 3515 Albion Road South            | Perfect match                    | NO                |
| Papa Burger 22, rue des Flandres                                 | 797   | Papa Burger                        | 22, rue des Flandres              | Perfect match                    | YES               |
| Papa Burger Maloney 253 Boul Maloney E                           | 822   | Papa Burger Maloney                | 253 Boul Maloney E                | Perfect match                    | YES               |
| Papa Grecque Cantley 393 MontÃ©e de la Source                    | 810   | Papa Grecque Cantley               | 393 Montée de la Source           | Perfect match                    | YES               |
| Papa Grecque Maloney 253 Boul Maloney                            | 616   | Papa Grecque Maloney               | 253 Boul Maloney                  | Perfect match                    | YES               |
| Papa Grecque des Flandres 22 rue des flandres                    | 540   | Papa Grecque des Flandres          | 22 rue des flandres               | Perfect match                    | YES               |
| Papa Pizza Cantley 393 MontÃ©e de la Source                      | 602   | Papa Pizza Cantley                 | 393 Montée de la Source           | Perfect match                    | YES               |
| Papa Pizza Chem. de Masson 855 Chem. de Masson                   | 795   | Papa Pizza Chem. de Masson         | 855 Chem. de Masson               | Perfect match                    | YES               |
| Patate Lou Lou 29 Chemin Eardley                                 | 712   | Patate Lou Lou                     | 29 Chemin Eardley                 | Perfect match                    | YES               |
| Pho Dau Bo Restaurant - Kitchener 685 Fischer Hallman Rd, Unit G | 147   | Pho Dau Bo Restaurant - Kitchener  | 685 Fischer Hallman Rd, Unit G    | Perfect match                    | YES               |
| Pizza Maisonneuve 574 Boulevard Saint-Joseph                     | 696   | Pizza Maisonneuve                  | 574 Boulevard Saint-Joseph        | Perfect match                    | YES               |
| Pizza Marie 4 Rue d'Orléans                                      | 976   | Pizza Marie                        | 4 Rue d'Orléans                   | Perfect match                    | NO                |
| Pizzalicious 1009 Merivale Rd                                    | 829   | Pizzalicious                       | 1009 Merivale Rd                  | Perfect match                    | NO                |
| Poutinerie QuÃ©becurds Gatineau 643 Boulevard Saint-RenÃ© O      | 802   | Poutinerie Québecurds Gatineau     | 643 Boulevard Saint-René O        | Perfect match                    | NO                |
| Poutinerie QuÃ©becurds Hull 455 Boulevard Riel                   | 789   | Poutinerie Québecurds Hull         | 455 Boulevard Riel                | Perfect match                    | NO                |
| Prima Pizza 26 Northside Road                                    | 824   | Prima Pizza                        | 26 Northside Road                 | Perfect match                    | NO                |
| River Pizza 4042 Innes Road                                      | 952   | River Pizza                        | 4042 Innes Road                   | Perfect match                    | NO                |
| Riverside Pizzeria 3679 Riverside Dr                             | 978   | Riverside Pizzeria                 | 3679 Riverside Drive              | Perfect match                    | NO                |
| Sala Thai 2666 Alta Vista Dr                                     | 745   | Sala Thai                          | 2666 Alta Vista Dr                | Perfect match                    | NO                |
| Season's Pizza 725 Somerset Street West                          | 83    | Season's Pizza                     | 725 Somerset Street West          | Perfect match                    | YES               |
| Shaan Tandoori 2550, boul LapiniÃ¨re                             | 269   | Shaan Tandoori                     | 2550, boul Lapinière              | Perfect match                    | YES               |
| Souvlaki Souvlaki 1216 Bank St                                   | 836   | Souvlaki Souvlaki                  | 1216 Bank St                      | Perfect match                    | NO                |
| Supreme Pizzeria 380 Chemin Vanier                               | 711   | Supreme Pizzeria                   | 380 Chemin Vanier                 | Perfect match                    | NO                |
| Supreme Pizzeria 425 Donald St                                   | 595   | Supreme Pizzeria                   | 425 Donald St                     | Perfect match                    | YES               |
| Sushi Fleury 2481 Fleury Est                                     | 596   | Sushi Fleury                       | 2481 Fleury Est                   | Perfect match                    | YES               |
| Sushi Presse 6497, rue Beaubien Est                              | 260   | Sushi Presse                       | 6497, rue Beaubien Est            | Perfect match                    | YES               |
| Sushiyana 34 boul mont bleu                                      | 847   | Sushiyana                          | 34 boul mont bleu                 | Perfect match                    | NO                |
| Tony's Pizza 7772 Jeanne d'Arc Blvd                              | 929   | Tony's Pizza                       | 7772 Jeanne d'Arc Boulevard North | Perfect match                    | NO                |
| Vanier Pizza & Subs 201 Marier Ave                               | 62    | Vanier Pizza & Subs                | 201 Marier Ave                    | Perfect match                    | NO                |

**TOTAL FOUND: 137 restaurants**

### 🔒 PROTECTION STATUS: LOCKED

**DO NOT DELETE ANY OF THESE 137 RESTAURANT IDs UNTIL BATCH JOBS COMPLETE**

---

## ⚠️ SECTION 2: DUPLICATES - Resolve Before Cleanup (4 IDs, 2 pairs)

**ACTION REQUIRED: Keep one ID from each pair, mark the other for deletion**

### Duplicate Pair 1: La Nawab (Same address: 1 Rue Cholette)

| Billing List Entry      | DB ID | DB Name     | Status        | Recommendation             |
| ----------------------- | ----- | ----------- | ------------- | -------------------------- |
| La Nawab 1 Rue Cholette | 825   | La Nawab V2 | Has menu data | ✅ KEEP THIS ONE           |
| La Nawab 1 Rue Cholette | 955   | La Nawab    | Duplicate     | 🗑️ DELETE AFTER BATCH JOBS |

### Duplicate Pair 2: Wandee Thai (Same address: 40 Beech Street)

| Billing List Entry          | DB ID | DB Name                       | Status    | Recommendation             |
| --------------------------- | ----- | ----------------------------- | --------- | -------------------------- |
| Wandee Thai 40 Beech Street | 954   | Wandee Thai                   | Primary   | ✅ KEEP THIS ONE           |
| Wandee Thai 40 Beech Street | 486   | Wandee Thai Cuisine Sept 2022 | Duplicate | 🗑️ DELETE AFTER BATCH JOBS |

**DUPLICATE SUMMARY:**

- Total IDs with duplicates: 4
- Keep: 2 IDs (825, 954)
- Delete after batch jobs: 2 IDs (955, 486)

---

## 🟡 SECTION 3: MISSING ADDRESS - Add Address Then Keep (4 restaurants)

**ACTION REQUIRED: Add addresses to restaurant_locations table, then protect like Section 1**

| Billing List Entry                            | DB ID | DB Name                     | Missing Data                       | Action Required          |
| --------------------------------------------- | ----- | --------------------------- | ---------------------------------- | ------------------------ |
| La Famiglia on the Danforth 2318 Danforth Ave | 984   | La Famiglia on the Danforth | No address in restaurant_locations | Add: 2318 Danforth Ave   |
| Pho Xua                                       | 982   | Pho Xua                     | No address in restaurant_locations | Research and add address |
| Pizza Lime                                    | 983   | Pizza Lime                  | No address in restaurant_locations | Research and add address |
| Yorgo's - Nepean 1356 Clyde Ave               | 985   | Yorgo's - Nepean            | No address in restaurant_locations | Add: 1356 Clyde Ave      |

**MISSING ADDRESS SUMMARY:**

- Total: 4 restaurants
- Have DB ID: Yes
- Action: Add addresses, then treat as FOUND (Section 1)

---

## 🔴 SECTION 4: NOT FOUND IN DATABASE (45 restaurants)

**ACTION REQUIRED: Investigate before cleanup - These may need to be removed from billing list**

These restaurants are in your billing list but have NO database ID. They cannot be found in menuca_v3.restaurants.

---

### 📌 SUBSECTION 4A: SCRAPING PENDING (8 restaurants)

**STATUS: Active client confirmed - Needs scraping**

These are confirmed active paying clients that exist in the database but need menu data scraped.

| #   | Billing List Entry                  | Address                  | DB ID | Status           | Action Required                                         |
| --- | ----------------------------------- | ------------------------ | ----- | ---------------- | ------------------------------------------------------- |
| 1   | Kiki Lebanese Pineview Pizza        | 2045 Meadowbrook Rd      | 44    | SCRAPING PENDING | ⚠️ **CRITICAL:** Scrape menu data immediately           |
| 2   | Lemongrass Thai Cuisine             | 331 Elgin St             | TBD   | SCRAPING PENDING | ⚠️ **CRITICAL:** Add to database and scrape immediately |
| 3   | Lorenzo's Pizzeria - Vanier         | 94 Montreal Rd           | TBD   | SCRAPING PENDING | ⚠️ **CRITICAL:** Add to database and scrape immediately |
| 4   | Papa Joe's Fried Chicken - Downtown | 527 Bronson Ave          | 437   | SCRAPING PENDING | ⚠️ **CRITICAL:** Restaurant exists but needs menu data  |
| 5   | Papa Joe's Pizza - Downtown         | 527 Bronson Ave          | 13    | SCRAPING PENDING | ⚠️ **CRITICAL:** Restaurant exists but needs menu data  |
| 6   | Roulas Grecque et Pizza             | 245, rue de Cannes       | TBD   | SCRAPING PENDING | ⚠️ **CRITICAL:** Add to database and scrape immediately |
| 7   | Xtreme Pizza                        | 125 Preston St           | 367   | SCRAPING PENDING | ⚠️ **CRITICAL:** Restaurant exists but needs menu data  |
| 8   | Econo Pizza                         | 425, boul La Vérendrye E | TBD   | SCRAPING PENDING | ⚠️ **CRITICAL:** Add to database and scrape immediately |

**Note:** Shares address with Mozza Pizza (ID 35) but is a DIFFERENT restaurant/client.

---

### 📌 SUBSECTION 4B: INVESTIGATION NEEDED (44 restaurants)

| #   | Billing List Entry                                        | Status    | Investigation Needed                     |
| --- | --------------------------------------------------------- | --------- | ---------------------------------------- |
| 1   | Bobbie's Pizza & Subs 1443 Ogilvie Rd                     | NOT FOUND | Check if closed or name changed          |
| 2   | Chances R' East                                           | NOT FOUND | No address provided - investigate        |
| 3   | Chances R' West 1365 Woodroffe Avenue                     | NOT FOUND | Check if closed or name changed          |
| 4   | Colonnade Pizza 280 Metcalfe                              | NOT FOUND | Other Colonnade locations exist - verify |
| 5   | Eastview Pizza 251 Montreal Rd                            | NOT FOUND | Check if closed or name changed          |
| 6   | Erman Pizza 3628, av des Ã‰glises                         | NOT FOUND | Check if closed or name changed          |
| 7   | Ginkgo Garden 2225 St Laurent Blvd                        | NOT FOUND | Check if closed or name changed          |
| 8   | Greber Pizza et Shawarma 761 Boulevard Saint-Joseph       | NOT FOUND | Check if closed or name changed          |
| 9   | HaNoi Pho 4312 Innes Road                                 | NOT FOUND | Check if closed or name changed          |
| 10  | Hong Kong Chinese Food Takeout 800 Hunt Club Rd           | NOT FOUND | Check if closed or name changed          |
| 11  | House of Lasagna 984 Merivale Rd                          | NOT FOUND | Check if closed or name changed          |
| 12  | JN Pizza 1663 Cyrville Rd                                 | NOT FOUND | Check if closed or name changed          |
| 13  | Kabylie Pizza 355 Bd GrÃ©ber                              | NOT FOUND | Check if closed or name changed          |
| 14  | Lucky Fortune 1970 Trim Rd                                | NOT FOUND | Check if closed or name changed          |
| 15  | Mama Rosa 375 Des Epinettes Ave                           | NOT FOUND | Check if closed or name changed          |
| 16  | Merivale Pizza & Wings 1610 Merivale Rd                   | NOT FOUND | Check if closed or name changed          |
| 17  | Milano 14 Main St E                                       | NOT FOUND | Other Milano locations exist             |
| 18  | Milano 1234 Merivale Rd Unit 3                            | NOT FOUND | Other Milano locations exist             |
| 19  | Milano 2 Pembroke St ( Highway 17 )                       | NOT FOUND | Other Milano locations exist             |
| 20  | Milano 2241 St Laurent Blvd                               | NOT FOUND | Other Milano locations exist             |
| 21  | Milano 2430 Bank St                                       | NOT FOUND | Other Milano locations exist             |
| 22  | Milano 26 Bridge St                                       | NOT FOUND | Other Milano locations exist             |
| 23  | Milano 2600 County Rd 43                                  | NOT FOUND | Other Milano locations exist             |
| 24  | New Mee Fung Restaurant 350 Booth St                      | NOT FOUND | Check if closed or name changed          |
| 25  | New Mukut Restaurant Indian Cuisine 1968 Portobello Blvd  | NOT FOUND | Check if closed or name changed          |
| 26  | Palermo Pizzeria 25 Tapiola Cres                          | NOT FOUND | Check if closed or name changed          |
| 27  | Papa Pizza - Hull 574, boul Saint-Joseph                  | NOT FOUND | Check if closed or name changed          |
| 28  | Papa Pizza Des Flandres 22, rue des Flandres              | NOT FOUND | Check if closed or name changed          |
| 29  | Papa Pizza Maloney 253, boul Maloney                      | NOT FOUND | Check if closed or name changed          |
| 30  | Papa Pizza Val-Des-Monts 1797, rte du Carrefour           | NOT FOUND | Check if closed or name changed          |
| 31  | Parea Authentic Greek 1675 Tenth Line Road                | NOT FOUND | Check if closed or name changed          |
| 32  | Parea Express 540 Montréal Road                           | NOT FOUND | Check if closed or name changed          |
| 33  | Pho Bo Ga King - Somerset 778 Somerset St W               | NOT FOUND | Check if closed or name changed          |
| 34  | Pizza Bravo 108, boul Lorrain                             | NOT FOUND | Check if closed or name changed          |
| 35  | Pizza Joanna 229 Boulevard Saint-RenÃ© Ouest              | NOT FOUND | Check if closed or name changed          |
| 36  | Pizza Lovers Hunt Club 800 Hunt Club Road                 | NOT FOUND | Check if closed or name changed          |
| 37  | Pizza des Hautes Plaines 760 Boulevard des Hautes-Plaines | NOT FOUND | Check if closed or name changed          |
| 38  | PizzaRama 253, boul Maloney                               | NOT FOUND | Check if closed or name changed          |
| 39  | Rangoli 2491 St-Joseph Blvd                               | NOT FOUND | Check if closed or name changed          |
| 40  | Restaurant Chez Gerry 9, rue Therien                      | NOT FOUND | Check if closed or name changed          |
| 41  | Restaurant Le Choix 139, rue Principale                   | NOT FOUND | Check if closed or name changed          |
| 42  | Sachi Sushi 4931, rue Beaubien E                          | NOT FOUND | Check if closed or name changed          |
| 43  | Sushi Express Chambly 886 ch de Chambly                   | NOT FOUND | Check if closed or name changed          |
| 44  | The Original Georgie's 1661 Carling Ave                   | NOT FOUND | Check if closed or name changed          |
| 45  | Ting's Kitchen 3-701 Eagleson Rd                          | NOT FOUND | Check if closed or name changed          |
| 46  | Vieux Hull Pizza 574, boul Saint-Joseph                   | NOT FOUND | Check if closed or name changed          |
| 47  | iCook Pho You 2006 Robertson Rd                           | NOT FOUND | Check if closed or name changed          |

**NOT FOUND SUMMARY:**

- **Scraping Pending:** 8 (Kiki Lebanese Pineview Pizza - DB ID 44, Lemongrass Thai Cuisine - needs DB entry, Lorenzo's Pizzeria - Vanier - needs DB entry, Papa Joe's Fried Chicken - Downtown - DB ID 437 needs menu data, Papa Joe's Pizza - Downtown - DB ID 13 needs menu data, Roulas Grecque et Pizza - needs DB entry, Xtreme Pizza - DB ID 367 needs menu data, Econo Pizza - needs DB entry)
- **Investigation Needed:** 44 entries (includes 6 Milano locations)
- **Total Not Found:** 52 restaurants
- **Action:** Scrape Kiki Lebanese Pineview Pizza (ID 44), Papa Joe's Fried Chicken - Downtown (ID 437), Papa Joe's Pizza - Downtown (ID 13), and Xtreme Pizza (ID 367) immediately; Add Lemongrass Thai Cuisine, Lorenzo's Pizzeria - Vanier, Roulas Grecque et Pizza, and Econo Pizza to database and scrape; investigate the other 44

---

## 📊 CLEANUP STRATEGY SUMMARY

### Phase 1: Protect Current Operations (NOW)

1. ✅ **Lock 137 restaurant IDs** - These are actively being scraped
2. 🆕 **Scrape Kiki Lebanese Pineview Pizza** - Restaurant exists (ID 44) but needs menu data
3. 🆕 **Scrape Papa Joe's Fried Chicken - Downtown** - Restaurant exists (ID 437) but needs menu data
4. 🆕 **Scrape Papa Joe's Pizza - Downtown** - Restaurant exists (ID 13) but needs menu data
5. 🆕 **Scrape Xtreme Pizza** - Restaurant exists (ID 367) but needs menu data
6. 🆕 **Add Lemongrass Thai Cuisine** - Create new restaurant record and scrape immediately
7. 🆕 **Add Lorenzo's Pizzeria - Vanier** - Create new restaurant record and scrape immediately
8. 🆕 **Add Roulas Grecque et Pizza** - Create new restaurant record and scrape immediately
9. 🆕 **Add Econo Pizza** - Create new restaurant record and scrape immediately
10. ⚠️ **Flag 2 duplicate IDs** for later deletion (955, 486)
11. 🟡 **Add 4 missing addresses** to protect those IDs

### Phase 2: After Batch Jobs Complete

1. 🗑️ **Delete 2 duplicate IDs**: 955 (La Nawab), 486 (Wandee Thai Cuisine Sept 2022)
2. 🔍 **Query database for restaurants NOT in billing list** - these are candidates for deletion
3. 🗑️ **Delete all active restaurants not in the 137 + 4 missing address + 4 new restaurants (Lemongrass Thai Cuisine, Lorenzo's Pizzeria - Vanier, Roulas Grecque et Pizza, Econo Pizza) list**

### Phase 3: Billing List Cleanup

1. 🆕 **Add Lemongrass Thai Cuisine** to database (1 restaurant confirmed active)
2. 🆕 **Add Lorenzo's Pizzeria - Vanier** to database (1 restaurant confirmed active)
3. 🆕 **Add Roulas Grecque et Pizza** to database (1 restaurant confirmed active)
4. 🆕 **Add Econo Pizza** to database (1 restaurant confirmed active)
5. ❌ **Remove or add 52 NOT FOUND entries** from Restaurants-active.md after investigation
6. ✅ **Verify final count**: Should have exactly 189 restaurants total

---

## 🎯 FINAL TARGET STATE

After complete cleanup:

- **Active in Database:** 137 (FOUND) + 4 (missing address added) + 4 (Lemongrass Thai Cuisine, Lorenzo's Pizzeria - Vanier, Roulas Grecque et Pizza, Econo Pizza added) - 2 (duplicates removed) = **143 restaurants**
- **Or if all NOT FOUND resolved:** 189 restaurants total
- **CRITICAL:** Add Lemongrass Thai Cuisine, Lorenzo's Pizzeria - Vanier, Roulas Grecque et Pizza, and Econo Pizza to database immediately (active paying clients)
- **Recommended:** Investigate the 52 NOT FOUND and remove from billing list if they're truly closed

---

## 📋 CRITICAL IDs TO PROTECT DURING CLEANUP

**DO NOT DELETE THESE IDs - THEY ARE IN THE BILLING LIST:**

```
7,8,31,35,44,47,57,59,65,69,72,83,87,89,90,91,93,95,118,119,124,126,131,147,174,180,190,205,241,245,260,269,350,349,491,502,511,515,540,561,584,595,596,601,602,607,616,624,636,638,641,644,646,660,680,681,696,701,712,714,715,721,727,730,745,749,751,756,783,784,785,792,795,797,801,802,806,807,810,815,816,818,819,821,822,825,829,833,835,836,837,840,841,842,845,846,847,943,946,948,949,950,952,954,957,960,961,962,963,964,965,966,967,971,973,974,976,977,978,789,790,929,982,983,984,985
```

**MARK THESE FOR DELETION AFTER BATCH JOBS:**

```
486,955
```

---

**Document Status:** SOURCE OF TRUTH - Use this for all cleanup decisions  
**Last Updated:** 2025-11-10  
**Next Review:** After batch scraping jobs complete
