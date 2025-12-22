# Duplicate Dishes Cleanup - December 19, 2025

## Summary of Accomplishments

### 1️⃣ Milano Mini Donuts Cleanup ✅
**Scope:** 15+ Milano locations

**Actions Taken:**
- **Deleted 41 duplicate dishes** from "Desserts" course (kept "Mini Donuts Hot and Fresh Made" course versions)
- **Set `is_upsell = true`** for 48 Mini Donuts dishes across all Milano locations
- Resolved price mismatches between "Mini Donuts Hot and Fresh Made" and "Hot Fresh Mini Donuts" courses

**Result:** Mini Donuts are now properly organized with upsell functionality enabled.

---

### 2️⃣ Friendly Restaurant Dips Transformation ✅
**Restaurant:** Friendly Restaurant and Pizzeria (ID: 730)

**Problem:** "Dips" dish existed in both Pizza and Appetizers courses with 19 size variants as modifiers.

**Actions Taken:**
- **Created new "Dips" course** (ID: 6558)
- **Created 19 individual dishes** for each dip type:
  - Garlic, Marinara, Balsamic, Tzatziki, Hot Sauce, BBQ, Honey Mustard, etc.
  - Large Garlic Dip ($10.00)
  - Regular dips ($1.50 each)
- **Deleted original duplicate dishes** (IDs: 135202, 135225)

**Result:** Dips are now properly structured as individual menu items under their own course.

---

### 3️⃣ Sushi Fleury Course Merge ✅
**Restaurant:** Sushi Fleury

**Problem:** Same Poke Bowl dishes existed in two courses: "PokeBowls" and "Poke Bowls" (spelling variation) with different availability days.

**Actions Taken:**
- **Merged courses** into single "Poke Bowls" course
- **Deleted 11 duplicate dishes** (IDs: 150091-150102)
- **Updated availability** to make remaining dishes visible every day
- **Soft-deleted empty course** (ID: 4105)

**Result:** Poke Bowls are now in a single course with consistent availability.

---

### 4️⃣ Inactive Duplicate Dishes Hard Delete ✅
**Scope:** Multiple restaurants

**Actions Taken:**
- Identified all duplicate dishes (same name, same price) where one copy was `is_active = false`
- **Hard deleted inactive duplicates** along with their:
  - `dish_prices` records
  - `dish_modifiers` records
  - `dish_combo_groups` records
  - `dish_availability` records

**Result:** Removed orphaned/obsolete dish records from the database.

---

## Patterns Identified for Future Cleanup

| Pattern | Status | Dishes Affected |
|---------|--------|-----------------|
| Milano Mini Donuts | ✅ COMPLETED | ~150 |
| Friendly Restaurant Dips | ✅ COMPLETED | 19 |
| Sushi Fleury Poke Bowls | ✅ COMPLETED | 11 |
| La Maison du Burger Combos | ⏳ PENDING (courses soft-deleted) | 12 |
| Papa Pizza group (4 locations) | ⏳ PENDING | ~480 |
| Kabylie Pizza | ⏳ PENDING | 126 |
| Erman Pizza | ⏳ PENDING | 119 |
| Season's Pizza | ⏳ PENDING | 85 |
| Other smaller duplicates | ⏳ PENDING | ~100 |

---

## Database Queries Used

All operations were performed using PostgreSQL via `psql` with:
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://..." --pset pager=off -c "SQL_QUERY"
```

All destructive operations were wrapped in `BEGIN`/`COMMIT` transactions for safety.

---

## Next Steps (December 22+)
1. Resolve La Maison du Burger data inconsistency (courses deleted but dishes active)
2. Clean up Papa Pizza duplicate combos across 4 locations
3. Address remaining cross-course duplicates in other restaurants

