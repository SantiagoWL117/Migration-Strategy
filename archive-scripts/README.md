# Restaurant Admin Users Archive & Migration Scripts

## Overview

This directory contains SQL scripts to safely archive, extract analytics, and eventually deprecate/delete the legacy `restaurant_admin_users` table as part of the migration to the new admin system (`admin_users` + `admin_user_restaurants`).

## Background

The database has three admin-related tables:

1. **`restaurant_admin_users`** (Legacy V2) - Old restaurant-specific admin accounts
   - Self-contained authentication with password hashes
   - One restaurant per admin
   - All 438 records have been migrated to the new system
   - Contains valuable historical data (login counts, preferences)

2. **`admin_users`** (Modern V3) - Centralized admin accounts using Supabase Auth
   - Supports multiple restaurants per admin
   - Modern security features (MFA, soft delete, audit trails)

3. **`admin_user_restaurants`** - Junction table linking admins to restaurants

## Migration Status

✅ **100% Complete** - All 438 legacy admin users have been migrated
📊 **Last Login Activity** - September 12, 2025 (recent activity in deprecated table)
⚠️ **Status** - Legacy table still active but ready for archival

## Script Execution Order

### Phase 1: Archive & Extract (Run Now)

```bash
00-MASTER-EXECUTE-ALL.sql    # Runs all phase 1 scripts
  ├─ 01-create-archive-backup.sql
  ├─ 02-migration-audit-report.sql
  ├─ 03-historical-analytics.sql
  └─ 04-user-preferences-extraction.sql
```

**What it does:**
- Creates complete backup in `restaurant_admin_users_archive`
- Generates comprehensive migration audit reports
- Extracts historical analytics into `restaurant_admin_users_analytics`
- Migrates user preferences to new `admin_user_preferences` table

**Safe to run:** Yes - read-only operations plus new table creation

**Time estimate:** 2-5 minutes

### Phase 2: Deprecate (Wait 1-3 months)

```bash
05-deprecate-table.sql
```

**What it does:**
- Renames table to `restaurant_admin_users_deprecated`
- Marks it as deprecated
- Sets scheduled deletion date (6 months out)
- Logs action in `table_deprecation_log`

**When to run:** After 1-3 months of stable operation with new system

**Reversible:** Yes - can rename back if needed

### Phase 3: Delete (Wait 6+ months)

```bash
06-final-deletion.sql
```

**What it does:**
- Permanently deletes the deprecated table
- Creates final snapshot
- Logs deletion action

**When to run:** After 6+ months of stable operation with new system

**Reversible:** No - permanent deletion (but archive remains)

## Quick Start

### Option 1: Using Master Script (Recommended)

```bash
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -f 00-MASTER-EXECUTE-ALL.sql
```

### Option 2: Using PowerShell Helper Script

```powershell
.\execute-archive.ps1
```

### Option 3: Individual Scripts

```bash
# Windows
"C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -f 01-create-archive-backup.sql

# Mac/Linux
psql "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" -f 01-create-archive-backup.sql
```

## New Tables Created

| Table | Purpose | Keep Forever? |
|-------|---------|---------------|
| `restaurant_admin_users_archive` | Complete backup of all data | ✅ Yes |
| `restaurant_admin_users_analytics` | Historical metrics snapshots | ✅ Yes |
| `admin_user_preferences` | Migrated user preferences (active use) | ✅ Yes |
| `table_deprecation_log` | Audit trail of table lifecycle | ✅ Yes |

## Key Reports Generated

### Migration Audit (Script 02)
- Migration completeness overview
- Email consistency verification
- Restaurant access verification
- Multi-restaurant admin identification
- Authentication status checks

### Historical Analytics (Script 03)
- User engagement metrics
- Account age distribution
- Login activity timeline
- Top 20 most active admins
- Inactive admin analysis
- Restaurant admin coverage

### User Preferences (Script 04)
- Statement recipients by restaurant
- Email notification configuration export
- Multi-restaurant statement recipients

## Important Data Preserved

### Historical Metrics
- **Login counts** - Some users have 5000+ logins tracked
- **Last login dates** - User engagement patterns
- **Account creation dates** - Account age history

### User Preferences
- **Statement recipients** - Who receives financial/order statements
- **User types** - Role classifications from legacy system

### Migration Audit Trail
- Maps old admin IDs to new admin IDs
- Tracks email consistency
- Documents restaurant access changes

## Safety Features

### Pre-execution Checks
- ✅ Verifies archive table exists
- ✅ Confirms record counts match
- ✅ Checks for foreign key dependencies
- ✅ Validates time elapsed since deprecation

### Rollback Capability
- Archive table allows full data recovery
- Deprecation phase is reversible (rename back)
- Deletion only after 6+ months of verification

### No Data Loss
- All data copied to archive before any changes
- Multiple snapshots taken at each phase
- Preferences migrated to permanent table

## Before Deleting: Verify These Items

- [ ] All migration audit reports show 100% success
- [ ] New admin system is working correctly
- [ ] Email notifications using `admin_user_preferences` table
- [ ] No foreign key references to legacy table
- [ ] Archive table has been backed up externally
- [ ] At least 6 months have passed since deprecation
- [ ] No rollback scenarios anticipated

## Troubleshooting

### "Table already exists" error
The script checks for existing tables and uses `IF NOT EXISTS`. Safe to re-run.

### Record count mismatch
If archive doesn't match original, investigate data changes. The script will halt.

### Foreign key violations
If other tables reference `restaurant_admin_users`, migration is incomplete. Check constraints.

### Permission denied
Ensure you're using the correct database credentials and have admin privileges.

## Timeline Recommendation

| Phase | Action | When | Duration |
|-------|--------|------|----------|
| 1 | Archive & Extract | Now | Immediate |
| 2 | Monitor | - | 1-3 months |
| 3 | Deprecate Table | After Phase 2 | Immediate |
| 4 | Monitor | - | 6 months |
| 5 | Final Deletion | After Phase 4 | Immediate |

**Total Timeline: 7-9 months** from archive to final deletion

## File Structure

```
archive-scripts/
├── README.md                           # This file
├── 00-MASTER-EXECUTE-ALL.sql          # Master execution script
├── 01-create-archive-backup.sql       # Phase 1: Backup
├── 02-migration-audit-report.sql      # Phase 1: Audit
├── 03-historical-analytics.sql        # Phase 1: Analytics
├── 04-user-preferences-extraction.sql # Phase 1: Preferences
├── 05-deprecate-table.sql             # Phase 2: Deprecate
├── 06-final-deletion.sql              # Phase 3: Delete
└── execute-archive.ps1                # PowerShell helper (Windows)
```

## Support & Questions

For questions or issues:
1. Review the audit reports generated by script 02
2. Check `table_deprecation_log` table for action history
3. Verify archive tables exist and have correct record counts
4. Consult with database administrator before final deletion

## Best Practices

1. **Run during low-traffic hours** - Archive creation may take a few minutes
2. **Review all output** - Check for warnings or errors in reports
3. **Export reports externally** - Save audit results outside database
4. **Test rollback procedure** - Before deprecation, verify you can restore if needed
5. **Coordinate with team** - Ensure all stakeholders aware of timeline

## License & Responsibility

These scripts are provided for data migration and archival purposes. Always:
- Test in non-production environment first
- Take full database backup before execution
- Review all output before proceeding to next phase
- Maintain archive tables indefinitely for compliance

---

**Created:** 2025-10-27
**Last Updated:** 2025-10-27
**Status:** Phase 1 Ready for Execution
**Next Action:** Run `00-MASTER-EXECUTE-ALL.sql`
