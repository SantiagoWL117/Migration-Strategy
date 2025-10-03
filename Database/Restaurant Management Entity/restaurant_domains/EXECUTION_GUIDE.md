# Restaurant Domains Fixes - Quick Execution Guide

## 🎯 Quick Start

You have **2 fixes** ready to apply from the migration review:

---

## Fix 1: Invalid Domain Format ⚡ Run Now

### What It Does
Removes the invalid `!` character from one domain.

### How to Execute
1. Open Supabase SQL Editor
2. Copy and paste the entire contents of `fix_invalid_domain_format.sql`
3. Click "Run"
4. Verify the output shows "✅ Fixed"

### Expected Output
```
id   | restaurant_id | domain              | is_enabled | status
-----|---------------|---------------------|------------|----------
2659 | 605          | phovanvan.menu.ca   | true       | ✅ Fixed

remaining_invalid_domains: 0
```

### Time Required
⏱️ 30 seconds

---

## Fix 2: V1 Upsert Idempotency 📝 Update Migration Plan

### What It Does
Prevents V1 from re-enabling domains that V2 disabled.

### How to Execute

#### Option A: Update the Migration Plan Document (Recommended)
1. Open `documentation/Restaurants/restaurant_domains_migration_plan.md`
2. Find line 141:
   ```sql
   SET is_enabled  = EXCLUDED.is_enabled,
   ```
3. Replace with:
   ```sql
   SET is_enabled  = COALESCE(menuca_v3.restaurant_domains.is_enabled, EXCLUDED.is_enabled),
   ```
4. Save the file

#### Option B: If You Need to Re-Run Migration
1. Open `fix_v1_upsert_idempotency.sql`
2. Copy the corrected V1 migration section (lines 18-68)
3. Replace the original V1 section in your migration script
4. Run the full migration

### Time Required
⏱️ 2 minutes

---

## 🚀 Execution Order

```
1. ✅ Run Fix 1 first (fixes current data)
   └─> Execute: fix_invalid_domain_format.sql
   
2. ✅ Apply Fix 2 second (prevents future issues)
   └─> Update: restaurant_domains_migration_plan.md line 141
```

---

## ✅ Post-Execution Checklist

### After Fix 1
- [ ] Query returned 0 invalid domains
- [ ] Restaurant 605 domain is now `phovanvan.menu.ca` (no `!`)
- [ ] `updated_at` timestamp is current

### After Fix 2
- [ ] Migration plan line 141 updated
- [ ] Change committed to version control
- [ ] Team notified of the update
- [ ] Next migration re-run will use corrected logic

---

## 🔍 Verification Commands

### Verify Fix 1 Worked
```sql
-- Should return 0
SELECT COUNT(*) FROM menuca_v3.restaurant_domains
WHERE domain !~* '^[a-z0-9.-]+\.[a-z]{2,}$';
```

### Verify Fix 2 (After Re-Running Migration)
```sql
-- Should return 23 (all V2 disabled domains still disabled)
SELECT COUNT(*) FROM menuca_v3.restaurant_domains
WHERE is_enabled = FALSE;
```

---

## 📞 Need Help?

- **Review Full Details:** See `README_FIXES.md`
- **Check Migration Plan:** `documentation/Restaurants/restaurant_domains_migration_plan.md`
- **Review Results:** `documentation/Restaurants/Migration review plans/restaurant_domains_migration_review.md`

---

## 🎉 Success Criteria

**Fix 1 Complete When:**
- ✅ 0 invalid domain formats in database
- ✅ Restaurant 605 domain accessible without `!`

**Fix 2 Complete When:**
- ✅ Migration plan updated with COALESCE logic
- ✅ Re-running migration doesn't change disabled domains

---

**Last Updated:** October 2, 2025  
**Estimated Total Time:** 3 minutes  
**Difficulty:** ⭐ Easy (Copy-paste operations)

