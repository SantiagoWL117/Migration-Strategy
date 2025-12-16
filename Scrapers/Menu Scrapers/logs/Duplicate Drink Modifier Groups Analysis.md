# Duplicate Drink Modifier Groups Analysis

**Generated:** December 16, 2025  
**Total Dishes Affected:** 295 (293 combos, 2 non-combos)

---

## 🔴 CRITICAL TIMELINE: Scraper Activity

### Complete Event Timeline

| Date               | Time            | Event                            | Details                                                     |
| ------------------ | --------------- | -------------------------------- | ----------------------------------------------------------- |
| **Nov 9-14, 2025** | -               | Original modifier groups created | IDs 6502-31204                                              |
| **Nov 19, 2025**   | 21:19:53        | River Pizza bug                  | Two identical groups created 1 sec apart (IDs 39257, 39258) |
| **Dec 10, 2025**   | 17:09-18:37 UTC | **❌ Duplicate groups created**  | IDs 40462-40902 (~295 duplicates)                           |
| **Dec 15, 2025**   | 17:42-18:09 UTC | Combo Drinks Scraper ran         | Updated 349 modifier groups (both original + duplicates)    |
| **Dec 16, 2025**   | 10:07-10:28 UTC | Combo Drinks Upsert Scraper      | Updated 22 modifier groups                                  |

### Dec 15, 2025 Scraper Summary (Combo Drinks Scraper.log)

- **Restaurants processed:** 132
- **Success:** 42 restaurants
- **No drinks sections:** 90 restaurants
- **Total combo dishes found:** 634
- **Drinks sections found:** 349
- **Modifier groups updated:** 349 (including duplicates!)

### Dec 16, 2025 Scraper Summary (combo_drinks_upsert_20251216_100732.log)

- **Restaurants processed:** 60 (with combo dishes)
- **Success with updates:** 11 restaurants
- **All current (no updates needed):** 31 restaurants
- **Total combo dishes found:** 634
- **Updated:** 22 modifier groups
- **Skipped (no change):** 350
- **Skipped (no drinks section):** 254

---

## Impact Analysis

### Dec 15 Scraper - Updated Both Original AND Duplicate Groups

The Dec 15 scraper updated 349 modifier groups, **including the duplicates created on Dec 10**. Examples from the log:

| Dish                                 | Original ID Updated | Duplicate ID Updated |
| ------------------------------------ | ------------------- | -------------------- |
| Small Pizza Everyday Special         | 27500 (original)    | 40543 (duplicate)    |
| The Perfect Combo Deal with PopCurds | 8457 (original)     | 40552 (duplicate)    |
| 1 Topping Pizza Deal                 | 8505 (original)     | 40553 (duplicate)    |

This means **both the original and duplicate groups now have the same data**, making them true redundant duplicates.

### Dec 16 Upsert Scraper - Proper Updates

The Dec 16 upsert scraper properly updated existing modifier groups without creating new duplicates. Examples:

- Milano (V3:88) - Updated "Combo No.1 HIDED" → modifier_group 27448
- Milano (V3:350) - Updated "Pizza Special" → modifier_group 12253 (min=2, max=2, free=2)

---

## Summary by Restaurant (Sorted by Priority)

### 🔴 HIGH PRIORITY - Delete Duplicates (Same names)

| Restaurant      | V3 ID | Dishes | Dec 10 Dups | Original | Issue                        |
| --------------- | ----- | ------ | ----------- | -------- | ---------------------------- |
| Mano City Pizza | 118   | 8      | 8           | 8        | ❌ Same names duplicated     |
| Tony's Pizza    | 143   | 7      | 7           | 7        | ❌ Same names duplicated     |
| Prima Pizza     | 824   | 2      | 2           | 2        | ❌ Same name (2 Bottled Drinks) |
| Napolis         | 515   | 1      | 1           | 1        | ❌ Same name (1L Drink)      |
| River Pizza     | 952   | 1      | 0           | 2        | ❌ Bug (Nov 19, same name x2) |
| **TOTAL**       |       | **19** |             |          |                              |

### 🟡 MEDIUM PRIORITY - Review (Different names - may be intentional)

| Restaurant             | V3 ID | Dishes | Dec 10 Dups | Original | Issue                                     |
| ---------------------- | ----- | ------ | ----------- | -------- | ----------------------------------------- |
| Papa Joe's Pizza       | 13    | 7      | 7           | 7        | ⚠️ Different names (Choose X vs Can)      |
| Bobbie's Pizza & Subs  | 45    | 3      | 3           | 3        | ⚠️ Different names (Drinks vs Drinks Can) |
| Lorenzo's Pizzeria     | 77    | 2      | 2           | 2        | ⚠️ Different names (Choose X vs Drinks)   |
| The Original Georgie's | 84    | 2      | 2           | 2        | ⚠️ Different names (Four/Six vs can)      |
| **TOTAL**              |       | **14** |             |          |                                           |

### ✅ NO ACTION - Valid Pattern (Free + Paid)

| Restaurant             | V3 ID    | Dishes  | Dec 10 Dups | Original | Pattern                        |
| ---------------------- | -------- | ------- | ----------- | -------- | ------------------------------ |
| Milano (27 locations)  | Multiple | 261     | 261         | 261      | ✅ Free + Paid (Valid pattern) |
| Nachos Loco Gatineau   | 801      | 3       | 3           | 3        | ✅ Free + Paid (Valid)         |
| Nachos Loco Hull       | 790      | 3       | 3           | 3        | ✅ Free + Paid (Valid)         |
| Poutinerie Gatineau    | 1015     | 3       | 3           | 3        | ✅ Free + Paid (Valid)         |
| Poutinerie Hull        | 789      | 3       | 3           | 3        | ✅ Free + Paid (Valid)         |
| **TOTAL**              |          | **273** |             |          |                                |

---

## 🔴 HIGH PRIORITY: Delete These Duplicates

### True Duplicates (Same name, same data after Dec 15 scraper)

| Restaurant      | V3 ID | Modifier Group IDs to DELETE                           | Count |
| --------------- | ----- | ------------------------------------------------------ | ----- |
| River Pizza     | 952   | 39258                                                  | 1     |
| Mano City Pizza | 118   | 40626, 40627, 40628, 40629, 40630, 40631, 40632, 40633 | 8     |
| Tony's Pizza    | 143   | 40659, 40660, 40661, 40662, 40663, 40664, 40665        | 7     |
| Prima Pizza     | 824   | 40879, 40880                                           | 2     |
| Napolis         | 515   | 40699                                                  | 1     |

**Total: 19 modifier groups to delete**

### SQL to Delete High Priority Duplicates

```sql
-- Delete duplicate modifier groups (keeping originals)
DELETE FROM menuca_v3.modifier_groups
WHERE id IN (
    -- River Pizza (1 duplicate from Nov 19)
    39258,
    -- Mano City Pizza (8 Dec 10 duplicates)
    40626, 40627, 40628, 40629, 40630, 40631, 40632, 40633,
    -- Tony's Pizza (7 Dec 10 duplicates)
    40659, 40660, 40661, 40662, 40663, 40664, 40665,
    -- Prima Pizza (2 Dec 10 duplicates)
    40879, 40880,
    -- Napolis (1 Dec 10 duplicate)
    40699
);
-- Expected: 19 rows deleted
```

---

## ✅ VALID: Milano "Free + Paid" Pattern

The Milano restaurants use an **intentional two-group pattern**:

1. **"First X 591ml Drinks Free"** - Included free drinks
2. **"Drinks 591ml WITH PRICES"** - Paid extra drinks

The Dec 10 scraper created the second group ("WITH PRICES"), which is the **intended behavior** for Milano restaurants. These are NOT duplicates - they represent different functionality.

**Example (Milano V3:88):**
| Group Type | Name | ID | Purpose |
|------------|------|-----|---------|
| Original | First Two 591ml Drinks Free | 27450 | Free included drinks |
| Dec 10 | Drinks 591ml WITH PRICES | 40539 | Paid extra drinks |

**Restaurants with valid Free+Paid pattern:**

- All Milano locations (27)
- Nachos Loco Gatineau & Hull
- Poutinerie QuébeCurds Gatineau & Hull

---

## 🟡 MEDIUM PRIORITY: Review Different Names

These restaurants have two groups with **different names** - may be intentional:

### Bobbie's Pizza & Subs (V3: 45)

| Original       | Dec 10             |
| -------------- | ------------------ |
| Drinks (25776) | Drinks Can (40480) |
| Drinks (25778) | Drinks Can (40481) |
| Drinks (25780) | Drinks Can (40482) |

**Recommendation:** Check if "Drinks" = bottles and "Drinks Can" = cans. If so, keep both.

### Papa Joe's Pizza (V3: 13)

| Original                  | Dec 10               |
| ------------------------- | -------------------- |
| Choose your Drink (24620) | Drinks - Can (40462) |
| Choose 2 Drinks (24622)   | Drinks - Can (40464) |
| Choose 4 Drinks (24624)   | Drinks - Can (40466) |

**Recommendation:** Likely intentional (free selection + paid extras). Verify.

### Lorenzo's Pizzeria (V3: 77)

| Original                | Dec 10         |
| ----------------------- | -------------- |
| Choose 3 Drinks (27243) | Drinks (40520) |
| Choose 2 Drinks (27244) | Drinks (40521) |

**Recommendation:** Likely intentional. Verify.

### The Original Georgie's (V3: 84)

| Original            | Dec 10                |
| ------------------- | --------------------- |
| Four Drinks (27363) | Drinks----can (40536) |
| Six Drinks (27364)  | Drinks----can (40537) |

**Recommendation:** Fix "Drinks----can" naming. May be intentional pattern.

---

## Root Cause Analysis

### What Happened on Dec 10?

A scraper ran on Dec 10, 2025 that created new modifier groups instead of finding existing ones. The IDs 40462-40902 were all created during this run.

**Possible causes:**

1. **Name matching failure** - The scraper couldn't find existing groups due to name variations
2. **Missing lookup logic** - The scraper created new groups without checking for existing ones
3. **Different search criteria** - The scraper used different criteria than expected

### Why Dec 15 & Dec 16 Scrapers Updated Both?

The Dec 15 combo drinks scraper:

- Found 349 dishes with drinks sections
- Updated modifier groups using an alternative lookup (by name pattern like "Drinks")
- This caused it to update BOTH the original AND duplicate groups

The Dec 16 upsert scraper:

- Properly found existing groups
- Made 22 updates to existing groups
- Did NOT create new duplicates

---

## Recommended Actions

### 1. 🔴 Immediate: Delete 19 True Duplicates

Run the SQL delete statement above.

### 2. 🟡 Review: Check "Different Name" Restaurants

- Bobbie's Pizza (bottles vs cans?)
- Papa Joe's (free vs paid?)
- Lorenzo's (choose vs extra?)
- The Original Georgie's (naming issue)

### 3. 🟢 Monitor: Dec 10 Scraper

Investigate which scraper ran on Dec 10 and why it created duplicates. The scraper code should be updated to:

- Check for existing modifier groups before creating
- Use proper name matching (case-insensitive, whitespace-tolerant)

### 4. ✅ Confirm: Milano Pattern is Valid

The "Free + Paid" pattern for Milano and similar restaurants is intentional business logic. No action needed for these 261+ dishes.
