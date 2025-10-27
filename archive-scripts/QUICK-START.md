# Quick Start Guide

## TL;DR - How to Archive restaurant_admin_users

### Step 1: Run Archive Scripts (Do This Now)

**Windows PowerShell:**
```powershell
cd "C:\Users\santi\Menu.ca\Legacy Database\Migration Strategy\archive-scripts"
.\execute-archive.ps1
```

**Or directly with psql:**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -f 00-MASTER-EXECUTE-ALL.sql
```

**Time:** ~2-5 minutes

**What it does:**
- ✅ Creates backup table: `restaurant_admin_users_archive`
- ✅ Generates migration audit reports
- ✅ Extracts historical analytics
- ✅ Migrates user preferences to `admin_user_preferences`

**Safe?** Yes - no destructive operations

---

### Step 2: Review Reports

After Step 1 completes, review the output for:

- ✅ Migration completeness (should be 100%)
- ✅ Email consistency checks
- ✅ Restaurant access verification
- ⚠️ Any warnings or mismatches

**Action:** Fix any issues found before proceeding

---

### Step 3: Wait & Monitor (1-3 months)

Monitor your application to ensure:
- New admin system (`admin_users` + `admin_user_restaurants`) works correctly
- Email notifications using `admin_user_preferences` work
- No users report access issues
- No application errors related to admin authentication

---

### Step 4: Deprecate Table (After 1-3 months)

**Windows PowerShell:**
```powershell
.\execute-archive.ps1 05
```

**What it does:**
- Renames table to `restaurant_admin_users_deprecated`
- Marks it as deprecated
- Sets deletion schedule (6 months out)

**Reversible?** Yes - can rename back if issues found

---

### Step 5: Wait & Monitor (6 months)

Continue monitoring for:
- System stability
- No need to reference old table
- No rollback scenarios

---

### Step 6: Final Deletion (After 6+ months total)

**Windows PowerShell:**
```powershell
.\execute-archive.ps1 06
```

**What it does:**
- Permanently deletes the deprecated table
- Archive tables remain for historical reference

**Reversible?** No - permanent deletion

---

## What Gets Created?

| New Table | Purpose | Keep? |
|-----------|---------|-------|
| `restaurant_admin_users_archive` | Complete backup | ✅ Forever |
| `restaurant_admin_users_analytics` | Metrics snapshots | ✅ Forever |
| `admin_user_preferences` | Active preferences table | ✅ Forever |
| `table_deprecation_log` | Audit trail | ✅ Forever |

---

## Quick Verification

After running the archive scripts, verify with:

```sql
-- Check archive was created
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users_archive;
-- Should match count from original table (438)

-- Check preferences were migrated
SELECT COUNT(*) FROM menuca_v3.admin_user_preferences;
-- Should show migrated preferences

-- Check analytics snapshot
SELECT * FROM menuca_v3.restaurant_admin_users_analytics ORDER BY report_date DESC LIMIT 1;
-- Should show recent snapshot
```

---

## Need Help?

1. **Script fails?** Check connection string and psql installation
2. **Record count mismatch?** Review migration audit report (script 02)
3. **Permission denied?** Ensure you have admin database privileges
4. **Questions?** See full `README.md` for detailed documentation

---

## Timeline Summary

```
Today           → Run archive scripts (Step 1)
                ↓
1-3 months      → Deprecate table (Step 4)
                ↓
6 months        → Final deletion (Step 6)
                ↓
Forever         → Keep archive tables
```

**Total: 7-9 months from start to finish**

---

## Safety Built In

✅ Multiple verification checks
✅ Backup before any changes
✅ Phased approach with monitoring
✅ All operations logged
✅ Archive preserved forever

**You cannot accidentally lose data with these scripts.**

---

**Ready to start?** Run `.\execute-archive.ps1` now!
