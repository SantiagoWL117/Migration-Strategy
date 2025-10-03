# Restaurant Contacts - Data Quality Fix

## Overview

This directory contains a SQL script to address a minor data quality issue found during the migration review.

---

## Issue: 7 Contacts with No Email or Phone

### Problem
7 contact records (0.8% of total) have neither an email address nor a phone number, making them impossible to contact and operationally useless.

### Affected Records
| ID | Restaurant | Name | Title |
|----|------------|------|-------|
| 1750 | Chillies Indian Restaurant | Bromina Mehta (wife) | owner |
| 1968 | Café Asia | Jian Xiong Lin | owner |
| 2080 | Pho Lam Ici | Lam Truyen | owner |
| 2182 | Fusion House (closed) | Miao Ci Deng | owner |
| 2305 | Mozza Pizza Hull | Mohamed Maaloul | owner |
| 2355 | Yorgo's - Barrhaven | Adnan Amidi | manager |
| 2395 | Sala Thai | Maria | owner |

**Note:** Most are for closed/dropped restaurants, so operational impact is minimal.

---

## Fix: Mark as Inactive

### Solution
Set `is_active = FALSE` for these 7 contacts to:
- ✅ Preserve data history (no deletion)
- ✅ Prevent use in active operations
- ✅ Signal to admin that these records need attention

### Impact
- **Records affected:** 7
- **Risk level:** None (safe, reversible)
- **Data loss:** None
- **Operation:** Single UPDATE query

---

## Files

### `fix_contacts_no_info.sql`
Complete SQL script with:
- **Step 1:** Verification query (preview affected records)
- **Step 2:** UPDATE query (apply fix)
- **Step 3:** Post-verification (confirm success)
- **Rollback:** Instructions to revert if needed

---

## Execution Instructions

### Quick Start
1. Open Supabase SQL Editor
2. Copy/paste contents of `fix_contacts_no_info.sql`
3. Run **STEP 1** to preview (safe, read-only)
4. Review the 7 records
5. Run **STEP 2** to apply fix
6. Run **STEP 3** to verify success

### Expected Results

**Before:**
```
is_active=TRUE:  835 contacts
is_active=FALSE: 0 contacts
```

**After:**
```
is_active=TRUE:  828 contacts
is_active=FALSE: 7 contacts
```

---

## Status

- **Created:** 2025-10-02
- **Status:** ⏳ **READY TO EXECUTE**
- **Tested:** SQL validated against schema
- **Approved:** Per review document recommendation

---

## Related Documents

- **Review Document:** `documentation/Restaurants/Migration review plans/restaurant_contacts_migration_review.md`
- **Verification Results:** `documentation/Restaurants/Migration review plans/restaurant_contacts_verification_results.md`
- **Issue Reference:** Section 8.6 (NULL/Empty Field Distribution)

---

## Notes

- This is a **data quality improvement**, not a critical fix
- The migration was successful; this is cleanup of legacy data issues
- **Other issues NOT addressed:**
  - 8 contacts with special characters in names (accepted as-is)
  - receives_* flags (business decision deferred)

---

## Support

If you encounter issues or have questions:
1. Check the rollback section in `fix_contacts_no_info.sql`
2. Review the affected records list above
3. Consult the verification results document


