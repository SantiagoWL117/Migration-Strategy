# Restaurant Deletion Preview Report

**Date:** November 14, 2025  
**Task:** Delete restaurants NOT in `Restaurants-active.md` from `menuca_v3` schema  
**Status:** ⚠️ PENDING APPROVAL - NO DELETIONS EXECUTED YET

---

## 📊 Deletion Summary

### Restaurants to Delete:
| Metric | Count |
|--------|-------|
| **Total Restaurants to Delete** | **761** |
| Currently Active (not soft-deleted) | 759 |
| Already Soft-Deleted | 2 |

### Related Data to Delete (Cascade):
| Table | Records to Delete |
|-------|-------------------|
| **Courses** | 581 |
| **Dishes** | 5,463 |
| **Dish Prices** | 8,338 |
| **Modifier Groups** | (will cascade) |
| **Dish Modifiers** | (will cascade) |
| **Dish Modifier Prices** | (will cascade) |

---

## ✅ Restaurants that WILL REMAIN (185 total)

These are the restaurants from `Restaurants-active.md` that will be preserved:

- Aahar The Taste of India (561)
- Al-s Drive In (981)
- All Out Burger - 2560 Bank Street (924)
- All Out Burger - 3091 Strandherd (841)
- All Out Burger - 585 Montreal Road (949) ✓ Recently restored
- All Out Burger - 714 Gladstone Ave (948)
- All Out Burger - 951 Notre-Dame St (833)
- ... (and 178 more active restaurants)

**Total restaurants that will remain: 185**

---

## 🗑️ Sample of Restaurants to DELETE

Here are some examples of restaurants that will be deleted (first 50):

| ID | Restaurant Name | Status | Has Menu Data? |
|----|-----------------|--------|----------------|
| 3 | Oriental Chu Shing Restaurant | Active | No (0 courses, 0 dishes) |
| 4 | Pizza Shark | Active | No |
| 5 | Cedar Valley | Active | No |
| 6 | Kanata Noodle House | Active | No |
| 9 | Ho Ho Restaurant | Active | No |
| 10 | Salito Gourmet Specialty Pizza (DROPPED) | Active | No |
| 11 | Hello Sushi Man | Active | No |
| 14 | Kal's Place Restaurant | Active | No |
| 16 | Papa Joe's Pizza - Greely & Findlay Creek | Active | No |
| 17 | Papa Joe's Pizza ( now house of pizza only) | Active | No |
| 18 | Papa Joe's Pizza | Active | No |
| 20 | Gladstone Golden Grill (Dropped) | Active | No |
| 23 | Pita Pit | Active | No |
| 24 | Villa Pizzeria N The Greek Place | Active | No |
| 25 | Mandarin Court ( closed sold) | Active | No |
| 26 | Hungry Sammys(sold) | Active | No |
| 27 | New Shawarma King | Active | No |
| 29 | Pizza Palace And Cafe (dropped) | Active | No |
| 30 | Vanier Grill | Active | No |
| 32 | Golden Crust Pizzeria | Active | No |
| 33 | Bien Pho Vietnamese and Thai Cuisine | Active | No |
| 34 | Pizza Express Extra | Active | No |
| **35** | **Mozza Pizza** | **Active** | **YES - 17 courses, 105 dishes, 199 prices** ⚠️ |
| 36 | Taj Indian Cuisine | Active | No |
| 37 | House of Pizza | Active | No |
| 40 | Yang Sheng Restaurant | Active | No |
| 41 | East India Co | Active | No |
| **42** | **Cypress Garden** | **Active** | **YES - 14 courses, 166 dishes, 181 prices** ⚠️ |
| 43 | Liu's Cuisine (DROPPED) | Active | No |
| 46 | Koi Asia (CLOSED) | Active | No |
| 49 | Mom's Chicken | Active | No |
| 50 | Shawarma House | Active | No |
| 51 | Dino's & Donald's Pizza | Active | No |
| 52 | Wing Hing Chinese Food | Active | No |
| 53 | Greekos | Active | No |
| 54 | House of Pizza | Active | No |
| 56 | House of Pizza | Active | No |
| 58 | Greekos Souvlaki & Pizza (closed) | Active | No |
| 60 | Opa's | Active | No |
| 61 | Joe's Pizza and Subs | Active | No |
| 63 | Mr Mozzarella York | Active | No |
| 64 | Willie's Chinese Food | Active | No |
| 66 | Elegant Pizza (Dropped) | Active | No |
| 67 | Milano ( dropped) | Active | No |
| 68 | Pizzeria Riverview | Active | No |
| 71 | Shawarma and Souvlaki House | Active | No |
| 73 | Naked Fish Sushi | Active | No |
| **74** | **Andiamo Pizzeria** | **Active** | **YES - 17 courses, 165 dishes, 336 prices** ⚠️ |

**Note:** Many restaurants marked as "DROPPED" or "CLOSED" will be deleted.

---

## ⚠️ Important Observations

### Restaurants with Menu Data to be Deleted:
Among the 761 restaurants to delete, some have menu data:
- **35** - Mozza Pizza (17 courses, 105 dishes, 199 prices)
- **42** - Cypress Garden (14 courses, 166 dishes, 181 prices)
- **74** - Andiamo Pizzeria (17 courses, 165 dishes, 336 prices)
- And potentially others...

**Total menu data to be deleted:**
- 581 courses
- 5,463 dishes
- 8,338 prices
- Plus all modifiers

### Why These Will Be Deleted:
These restaurants are NOT in the `Restaurants-active.md` source of truth, which is based on:
- Billing records (last 4 months)
- 190 verified active restaurant locations
- Only 185 have been added to menuca_v3 (5 are TBD)

---

## 🔍 Verification Checks

### Before Deletion:
- ✅ Total restaurants in database: ~946 (estimated)
- ✅ Restaurants to keep: 185
- ✅ Restaurants to delete: 761
- ✅ Expected remaining: 185

### After Deletion:
- ⏹️ Total restaurants remaining: 185
- ⏹️ All remaining restaurants match `Restaurants-active.md`
- ⏹️ No active client restaurants deleted

---

## 🚨 CRITICAL WARNINGS

### ⚠️ This is a PERMANENT DELETION (Hard Delete)
- This will use `DELETE FROM` SQL command
- **NOT** a soft delete (no `deleted_at` timestamp)
- Records will be **completely removed** from the database
- Cannot be undone without restoring from backup

### ⚠️ Backup Status
- ✅ **Full backup completed:** November 14, 2025 at 1:20 PM
- ✅ **Backup location:** `Database/Menuca_v3 backup/`
- ✅ **Backup size:** 86.25 MB (compressed), 663.14 MB (SQL)
- ✅ **Backup verified:** Yes

### ⚠️ Cascade Effects
All related data will be automatically deleted due to foreign key constraints:
- All courses for deleted restaurants
- All dishes for deleted restaurants
- All prices for those dishes
- All modifier groups for those dishes
- All modifiers and modifier prices

---

## 📝 Deletion SQL Statement (READY TO EXECUTE)

```sql
DELETE FROM menuca_v3.restaurants 
WHERE id NOT IN (
    561, 981, 924, 841, 949, 948, 833, 735, 607, 630,
    69, 241, 45, 973, 977, 124, 72, 131, 87, 943,
    962, 966, 964, 963, 967, 961, 965, 641, 783, 784,
    196, 785, 957, 584, 806, 960, 638, 792, 816, 28,
    1009, 511, 211, 730, 105, 815, 736, 519, 160, 22,
    119, 479, 7, 180, 646, 328, 636, 798, 44, 950,
    984, 727, 721, 825, 715, 1010, 491, 756, 971, 77,
    267, 174, 8, 12, 118, 614, 48, 749, 835, 55,
    88, 701, 601, 842, 593, 840, 265, 651, 92, 75,
    569, 123, 97, 818, 95, 91, 624, 90, 57, 59,
    565, 751, 126, 350, 660, 349, 190, 680, 837, 819,
    89, 586, 821, 31, 93, 205, 1011, 644, 47, 846,
    845, 801, 790, 515, 502, 15, 234, 65, 714, 807,
    681, 245, 974, 521, 797, 822, 810, 540, 616, 437,
    13, 70, 602, 795, 1012, 1013, 1014, 712, 199, 147,
    139, 562, 726, 507, 696, 976, 829, 716, 1015, 789,
    824, 497, 109, 106, 952, 133, 1016, 376, 745, 83,
    269, 836, 711, 595, 1017, 596, 847, 84, 941, 143,
    62, 820, 954, 367, 985
);
```

---

## ✅ Next Steps - AWAITING YOUR APPROVAL

**Current Status:** Step 1 Complete - Identification and Preview

**Options:**

### Option A: PROCEED WITH DELETION
Type: **"EXECUTE DELETION"** to permanently delete the 761 restaurants

### Option B: CANCEL
Type: **"CANCEL"** to abort this operation

### Option C: REVIEW SPECIFIC RESTAURANTS
Request specific restaurant details before deciding

---

## 📋 Post-Deletion Verification Plan

After deletion (if approved), I will:

1. ✅ Count remaining restaurants (should be 185)
2. ✅ Verify all remaining restaurants match `Restaurants-active.md`
3. ✅ Confirm no active client restaurants were deleted
4. ✅ Generate verification report
5. ✅ Update documentation

---

**⚠️ WAITING FOR YOUR APPROVAL TO PROCEED ⚠️**

Type **"EXECUTE DELETION"** to confirm and proceed with permanent deletion of 761 restaurants.

