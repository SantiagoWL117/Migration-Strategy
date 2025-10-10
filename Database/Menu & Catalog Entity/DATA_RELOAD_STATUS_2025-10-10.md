# V1 Menu Data Reload Status - October 10, 2025

## ✅ Completed Work

### 1. Root Cause Analysis
**Problem:** Combo migration failing with 92.81% orphan rate

**Cause:** The `menuca_v1_menu.sql` dump file has been pre-filtered:
- Original V1 table: ~58,057 rows
- Current dump: 14,884 rows (25.6% of original)
- **Excluded:** 43,173 rows (74.4%) - hidden dishes, blank names, inactive items

**Impact:** Combos reference dishes by ID, including the "excluded" items used as modifiers/toppings

---

### 2. Immediate Workaround Created

**Table Created:** `staging.menuca_v1_menu_full`

```sql
-- Combined menu + ingredients for better coverage
SELECT * FROM staging.menuca_v1_menu         -- 14,884 rows
UNION ALL
SELECT * FROM staging.menuca_v1_ingredients  -- 43,930 rows
```

**Result:** 58,814 total rows

**Coverage Achieved:**
- Combo dishes found: 2,108 out of 5,777 (36.49%)
- **Still missing: 3,669 dish IDs (63.51%)**

---

### 3. Documentation Created

**For Santiago:**
- `MISSING_COMBO_DISHES_FOR_SANTIAGO.md` - Complete data request with examples
- Lists the exact 3,669 missing dish IDs needed
- Provides SQL queries to extract from source database

**Updated:**
- `04_STAGING_COMBOS_BLOCKED.md` - Current status and progress
- Documented partial solution and remaining blockers

---

## ⏳ Waiting For

### Santiago to Provide One of:

**Option 1: Full Unfiltered Menu Dump** (Preferred)
```sql
-- From menuca_v1 MySQL database
SELECT * FROM menu 
-- NO WHERE clause - export everything including hidden/blank items
ORDER BY id;
```
Expected: ~58,057 rows (or at least the 3,669 missing dish IDs)

**Option 2: Database Access Credentials**
- I can query the source database directly
- Extract only the 3,669 missing dishes
- Fast targeted solution

**Option 3: Targeted Export**
```sql
SELECT * FROM menu 
WHERE id IN (4150,4151,4152,...) -- list of 3,669 IDs
```

---

## 📊 Current Status

| Metric | Value | Status |
|--------|-------|--------|
| Combo dishes required | 5,777 | - |
| Combo dishes found | 2,108 | ⚠️ 36.49% |
| Combo dishes missing | 3,669 | ❌ 63.51% |
| Target coverage | 95%+ | ❌ Not met |
| Blocking ticket | 04_STAGING_COMBOS | ⏸️ Paused |

---

## 🎯 Next Steps

### When Data Arrives:

1. **Load missing 3,669 dishes** into `staging.menuca_v1_menu_full`
2. **Re-validate coverage** (should reach 95%+)
3. **Resume Ticket 04** - Run combo migration script
4. **Verify orphan rate** drops below 5%
5. **Continue to Ticket 05** - Staging validation
6. **Deploy to production** - Tickets 06-10

### Expected Timeline:
- Data load: ~15 minutes
- Validation: ~10 minutes
- Combo migration: ~20 minutes
- **Total: ~45 minutes** from data receipt to unblocking

---

## 💡 Key Insight

The "missing" dishes aren't actually missing - they were intentionally filtered out during an earlier data cleaning phase because they had:
- Blank names
- `showinmenu='N'` flag
- Were from inactive restaurants

However, **combos need these dishes** because they're used as:
- Pizza toppings (hidden modifiers)
- Side dish options
- Drink choices
- Add-on items
- Customization options

This is why the combo system can't work with only the "visible" menu items.

---

## 📞 Contact

- **Discovered by:** Claude (Migration Agent)
- **Date:** October 10, 2025, 16:00 UTC
- **Waiting on:** Santiago (database access)
- **Priority:** HIGH - Blocks production deployment

---

## 🔗 Related Files

- `/Database/Agent_Tasks/04_STAGING_COMBOS_BLOCKED.md`
- `/Database/Menu & Catalog Entity/MISSING_COMBO_DISHES_FOR_SANTIAGO.md`
- `/Database/Menu & Catalog Entity/EXCLUDED_DATA_PATTERN_ANALYSIS 2.md`

---

**Status:** ⏸️ **PAUSED - Awaiting data from Santiago**  
**Progress:** 36.49% combo coverage achieved, need 95%+ to proceed

