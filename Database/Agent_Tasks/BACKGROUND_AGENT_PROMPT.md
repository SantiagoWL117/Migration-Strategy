# 🤖 Background Agent Prompt - Combo Migration

**Copy this entire message to start the background agent:**

---

Hi! I need you to execute a database migration while I'm away from my computer. This is a transactional script that will either succeed completely or rollback with no changes.

## 📋 Your Task

Execute the combo migration script for the MenuCA V3 database. All pre-conditions have been met and verified.

## 📁 Files You Need

Read these files in order:

1. **Task Instructions:**
   - `@Database/Agent_Tasks/RUN_COMBO_MIGRATION.md` - Your quick start guide
   - `@Database/Agent_Tasks/COMBO_MIGRATION_HANDOFF.md` - Full technical details

2. **Migration Script:**
   - `@Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql` - The SQL to execute

3. **Context (if needed):**
   - `@Database/Agent_Tasks/04_STAGING_COMBOS_BLOCKED.md` - Why this migration is needed
   - `@Database/Menu & Catalog Entity/DATA_LOAD_SUCCESS.md` - Data prep that was just completed

## 🎯 What To Do

1. Read `RUN_COMBO_MIGRATION.md` for the step-by-step process
2. Read the migration script: `fix_combo_items_migration.sql`
3. Execute it using `mcp_supabase_execute_sql` tool
4. Save the results to a new file: `Database/Agent_Tasks/COMBO_MIGRATION_RESULT.md`

## ✅ Success Criteria

Look for these in the output:
- "MIGRATION SUCCESSFUL ✓"
- Orphan rate < 1%
- ~16,000 combo items created

## ⏱️ Expected Time

2-5 minutes total

## 🚨 If It Fails

Just document the error in `COMBO_MIGRATION_RESULT.md` and leave it for me to review. The transaction will auto-rollback, so no data will be corrupted.

## 📊 Pre-Conditions (Already Met)

- ✅ staging.menuca_v1_combos loaded (16,461 rows)
- ✅ staging.menuca_v1_menu_full loaded (62,482 rows)  
- ✅ Combo dish coverage: 99.98%
- ✅ Expected orphan rate after migration: < 1%

---

**Please start now and save results when complete. Thanks!**


