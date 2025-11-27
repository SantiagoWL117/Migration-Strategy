# V1 Delivery Areas Extraction - Missing Data Report

**Date:** 2025-11-26
**Total Restaurants Analyzed:** 95

---

## Summary

- **With Polygon Data:** 60 restaurants
- **Missing Polygon Data:** 35 restaurants

### Breakdown of Missing Data:

- **Empty BLOB (a:0:{})**:  13 restaurants
- **NULL BLOB:** 15 restaurants
- **Malformed/Parse Errors:** 0 restaurants
- **Not Found in V1 Dump:** 7 restaurants

---

## Empty BLOB Restaurants (13)

These restaurants have `deliveryArea` set to `a:0:{}` (empty PHP array).

| V3 ID | Restaurant Name | V1 ID |
|-------|-----------------|-------|
| 783 | Colonnade Pizza | 1025 |
| 784 | Colonnade Pizza | 1027 |
| 785 | Colonnade Pizza | 1028 |
| 196 | Colonnade Pizza | 334 |
| 715 | La Poutinerie Ogilvie | 952 |
| 491 | Light of India | 695 |
| 118 | Mano City Pizza | 238 |
| 265 | Milano | 411 |
| 822 | Papa Burger Maloney | 1066 |
| 1012 | Papa Pizza Des Flandres | 231 |
| 1013 | Papa Pizza Maloney | 346 |
| 109 | Restaurant Chez Gerry | 228 |
| 820 | Vieux Hull Pizza | 1064 |

## NULL BLOB Restaurants (15)

These restaurants have `deliveryArea` set to NULL.

| V3 ID | Restaurant Name | V1 ID |
|-------|-----------------|-------|
| 841 | All Out Burger | 1088 |
| 948 | All Out Burger Gladstone | 1038 |
| 949 | All Out Burger Montreal Rd | 1071 |
| 792 | Dumpling Bowl | 1035 |
| 519 | HaNoi Pho | 727 |
| 721 | La Maison Pho | 959 |
| 825 | La Nawab V2 | 1070 |
| 756 | Little Gyros Greek Grill | 998 |
| 593 | Milano | 815 |
| 807 | Oh My Grill | 1051 |
| 810 | Papa Grecque Cantley | 1054 |
| 824 | Prima Pizza | 1069 |
| 745 | Sala Thai | 983 |
| 847 | Sushiyana | 1094 |
| 479 | iCook Pho You | 669 |

## Not Found in V1 Dump (7)

These restaurants exist in V3 with V1 IDs but were not found in the V1 dump file.

| V3 ID | Restaurant Name | V1 ID |
|-------|-----------------|-------|
| 124 | Carlo's Pizza | 246 |
| 584 | Crispy's | 805 |
| 806 | Crispy's Bank Street | 1050 |
| 638 | Digby's Restaurant | 865 |
| 1009 | Econo Pizza | 1095 |
| 681 | Oka's Hull | 914 |
| 941 | Ting's Kitchen | 694 |

---

## Recommendations

1. **Empty BLOB & NULL BLOB**: These restaurants likely never had delivery areas configured in V1.
2. **Not Found in Dump**: Verify V1 IDs are correct, or these may be V2-only restaurants.
3. **Malformed**: Manual review may be required if data recovery is needed.