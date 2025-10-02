# V1 Data Reload - Execution Strategy

**Date:** October 2, 2025  
**Status:** Ready to Execute

---

## Available PostgreSQL-Ready Files

### ✅ Complete Files in `final_pg/` Directory

| File | Rows | Status |
|------|------|--------|
| `menuca_v1_ingredient_groups_final_pg.sql` | 13,450 | ✅ Ready |
| `menuca_v1_ingredients_final_pg.sql` | 53,367 | ✅ Ready |
| `menuca_v1_menu_final_pg.sql` | 138,941 | ✅ Ready |
| `menuca_v1_combo_groups_final_pg.sql` | 62,913 | ✅ Ready |
| `menuca_v1_combos_final_pg.sql` | 16,461 | ✅ Ready (not needed - already complete) |
| `menuca_v1_menuothers_final_pg.sql` | 70,381 | ✅ Ready (not needed - already complete) |

### ❌ Missing File

- **v1_courses**: No complete PostgreSQL file exists (only ~122 rows in converted versions vs 13,238 needed)

---

## Reload Plan

### Tables to Reload (4 tables)

Need to reload only the tables that were incomplete:

1. **v1_ingredient_groups** - Load from `menuca_v1_ingredient_groups_final_pg.sql`
   - Current: 0 rows (truncated)
   - Target: 13,450 rows
   - Method: Single file load

2. **v1_ingredients** - Load from `menuca_v1_ingredients_final_pg.sql`
   - Current: 0 rows (truncated)
   - Target: 53,367 rows
   - Method: File is 2.3MB - may need to check if MCP can handle it

3. **v1_menu** - Load from `menuca_v1_menu_final_pg.sql`
   - Current: 0 rows (truncated)
   - Target: 138,941 rows
   - Method: File is 4.0MB - likely needs batching or split approach

4. **v1_combo_groups** - Load from `menuca_v1_combo_groups_final_pg.sql`
   - Current: 0 rows (truncated)
   - Target: 62,913 rows
   - Method: Check file size, may need batching

### v1_courses Strategy

**Problem:** No complete PostgreSQL file exists

**Options:**
1. Convert fresh from MySQL dump (most reliable)
2. Check if Phase 1 had filtering logic that excluded most courses
3. Investigate why conversion only captured 122 rows

**Decision:** Convert fresh using Python script with MySQL→PostgreSQL conversion patterns from Phase 1

---

## Loading Order

1. v1_ingredient_groups (smallest, test MCP loading)
2. v1_ingredients (test file size limits)
3. v1_combo_groups (test batching if needed)
4. v1_menu (largest - definitely needs strategy)
5. v1_courses (convert + load)

---

## File Size Analysis Needed

Check actual file sizes to determine if files need splitting before loading via MCP.

**MCP Limits:**
- Unknown exact limit, but likely ~5-10MB per call
- May need to split large files


