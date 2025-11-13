# Menu Tables Documentation

**📍 You are here:** `reports/database/`  
**🎯 Purpose:** Complete documentation for all menu-related database tables  
**✅ Status:** Documentation complete and verified

---

## 🚀 Quick Start

**New to the menu system?** Start with the **[MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md)**

**Need a quick answer?** Check the **[MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md)**

**Want to see real data?** View **[MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md)**

**Need technical details?** See **[MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md)**

---

## 📚 Documentation Files

| File | Purpose | Who Should Read |
|------|---------|-----------------|
| **[MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md)** | Master index & overview | Everyone (start here!) |
| **[MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md)** | Complete technical specs | Database admins, backend devs |
| **[MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md)** | Quick lookup & common queries | Frontend devs, testers |
| **[MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md)** | Real data examples | Product managers, QA, new devs |

---

## 🗂️ What's Covered

### Tables Documented (11 Total)

**Core Menu Tables (6):**
1. `courses` - Menu categories/sections
2. `dishes` - Individual menu items
3. `dish_prices` - Dish pricing with size variants
4. `modifier_groups` - Modifier organization
5. `dish_modifiers` - Individual customization options
6. `dish_modifier_prices` - Modifier pricing by size

**Translation Tables (4):**
7. `course_translations` - Multi-language course names
8. `dish_translations` - Multi-language dish details
9. `modifier_group_translations` - Multi-language group names
10. `dish_modifier_translations` - Multi-language modifier names

**Advanced Features (1):**
11. `dish_size_options` - Advanced size configuration with nutrition

---

## 📊 At a Glance

| Metric | Value |
|--------|-------|
| **Total Records** | 574,478 |
| **Active Courses** | 2,309 |
| **Active Dishes** | 22,504 |
| **Dish Prices** | 21,431 |
| **Modifiers** | 188,990 |
| **Modifier Prices** | 327,436 |
| **Modifier Groups** | 11,104 |

---

## 🎯 Find What You Need

### "I need to understand..."

| What You Need | Go To |
|---------------|-------|
| **How the menu system works overall** | [MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md) |
| **Table schemas and relationships** | [MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md) |
| **Quick SQL queries** | [MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md) |
| **Real-world pricing examples** | [MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md) |
| **How to connect to database** | `../../.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md` |

### "I want to..."

| Task | Documentation Section |
|------|----------------------|
| **Display a restaurant menu** | Quick Reference → Common Queries |
| **Calculate order total** | Real World Examples → Order Calculation |
| **Add a new dish** | Data Structure → Dishes Table |
| **Update prices** | Quick Reference → Update Operations |
| **Understand modifiers** | Complete Guide → Pricing Structure |
| **Test the database** | Connection Guide → Testing Methods |

---

## 🏗️ System Overview

```
Restaurant
  ↓
Courses (Categories)
  ↓
Dishes (Menu Items)
  ↓
  ├─→ Dish Prices (Base pricing)
  └─→ Modifier Groups
       ↓
       Dish Modifiers (Options)
         ↓
         Dish Modifier Prices (Option pricing)
```

**Key Insight:** Modifiers have their own pricing that varies by dish size, allowing for sophisticated pricing strategies like:
- Free preferences (No onions: $0.00)
- Fixed add-ons (Bacon: +$0.99)
- Size-scaled upgrades (Extra cheese: Small +$1.50, Large +$2.50)

---

## 🔑 Key Concepts

### Size Variants
- Used in both `dish_prices` and `dish_modifier_prices`
- Examples: "Small", "Medium", "Large", "1/2 Lb", "standard"
- NULL = single-size item
- Must match between base price and modifier prices

### Modifier Groups
Organize modifiers with selection rules:
- `is_required` - Must customer select?
- `min_selections` - Minimum picks
- `max_selections` - Maximum picks

Example: "Choose Size" (required, min=1, max=1)

### Soft Deletes
All tables use `deleted_at` timestamp:
- Never use `DELETE FROM`
- Always use `UPDATE SET deleted_at = NOW()`
- Always filter `WHERE deleted_at IS NULL`

---

## 💡 Quick Examples

### Single-Size Dish
```
Dish: Caesar Salad
Price: $12.99 (size_variant: NULL)
```

### Multi-Size Dish with Modifiers
```
Dish: Margherita Pizza
Prices:
  - Small: $12.99
  - Large: $18.99

Modifiers:
  - Extra Cheese: Small +$1.50, Large +$2.50
  - No Onions: $0.00 (all sizes)
```

### Order Calculation
```
Large Pizza: $18.99
+ Extra Cheese (Large): $2.50
= Total: $21.49
```

---

## 🔒 Security Notes

### Row-Level Security (RLS)
All tables have RLS policies:
- **Public:** Read-only access to active records
- **Restaurant Admin:** CRUD for their restaurants
- **Service Role:** Full access

### Testing Requirements
✅ **USE:** Supabase REST API with JWT tokens  
❌ **DON'T USE:** Direct psql (bypasses RLS, breaks auth)

---

## 🧪 Quick Test

Verify your database connection:

```bash
# Windows
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" ^
  "postgresql://postgres:PASSWORD@db.PROJECT.supabase.co:5432/postgres" ^
  -c "SELECT COUNT(*) as total_dishes FROM menuca_v3.dishes WHERE deleted_at IS NULL;"
```

Expected result: `22504` (or similar number)

---

## 📦 Related Documentation

### In This Directory
- ✅ [MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md)
- ✅ [MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md)
- ✅ [MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md)
- ✅ [MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md)
- ✅ [BILLING_LIST_VERIFICATION_REPORT.md](BILLING_LIST_VERIFICATION_REPORT.md)
- ✅ [Restaurants-active.md](Restaurants-active.md)

### Other Locations
- **Connection Guide:** `../../.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`
- **V3 Schema Docs:** `../../Database/V3_MERMAID_SCHEMA.md`
- **Project Overview:** `../../MEMORY_BANK/PROJECT_CONTEXT.md`

---

## 🚦 Status

| Component | Status |
|-----------|--------|
| Documentation | ✅ Complete |
| Database Connection | ✅ Verified |
| Sample Queries | ✅ Tested |
| Real Data Examples | ✅ Extracted |
| Translation System | ⚠️ Schema ready, no data |
| Dish Size Options | ⚠️ Not yet in use |

---

## 📅 Last Updated

**Date:** 2025-11-11  
**Database:** menuca_v3 (PostgreSQL 17.4 on Supabase)  
**Project Ref:** nthpbtdjhhnwfxqsxbvy

---

## 🎓 Recommended Reading Order

### For New Team Members
1. Start: [MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md) (overview)
2. Then: [MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md) (see it in action)
3. Finally: [MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md) (bookmark for daily use)

### For Technical Deep Dive
1. [MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md) (full specs)
2. Connection Guide (testing & security)
3. [MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md) (validation)

### For Quick Answers
1. [MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md) (common queries)
2. [MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md) (use case section)

---

**Questions?** Refer to the [MENU_SYSTEM_COMPLETE_GUIDE.md](MENU_SYSTEM_COMPLETE_GUIDE.md) index for specific topics.

---

*Documentation package for Menu.ca V3 database tables*

