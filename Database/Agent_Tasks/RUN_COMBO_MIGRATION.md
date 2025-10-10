# ⚡ QUICK START - Run Combo Migration

**FOR BACKGROUND AGENT:** This is your task while Brian drives home!

---

## 🎯 ONE-LINE SUMMARY

Execute the combo migration script via Supabase MCP tool - it's a single transaction that will either succeed completely or rollback with no changes.

---

## 📋 STEP-BY-STEP (Simple)

### 1. Read the Migration Script

Use `read_file` tool:
```
target_file: /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql
```

### 2. Execute via MCP

Use `mcp_supabase_execute_sql` tool with the entire script contents.

### 3. Check Results

Look for:
- ✅ "MIGRATION SUCCESSFUL"
- ✅ Orphan rate < 1%
- ✅ ~16,000 combo items created

### 4. Save Results

Create a file `COMBO_MIGRATION_RESULT.md` with the output.

---

## ✅ Success Looks Like

```
=== POST-MIGRATION STATE ===
Total combo_items: 16XXX
Combo groups WITH items: 8XXX
Orphaned combo groups: XX (< 1%)
Orphan rate: 0.XX%
MIGRATION SUCCESSFUL ✓
```

---

## ❌ Failure Looks Like

```
ERROR: [some error message]
Transaction rolled back
No data was changed
```

If this happens: Just document the error in a file and leave it for Brian.

---

## 🎯 That's It!

- Transaction-safe
- Auto-rollback on error
- Expected runtime: 2-5 minutes
- No user interaction needed

**GO FOR IT!** 🚀



