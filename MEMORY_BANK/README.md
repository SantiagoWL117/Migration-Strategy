# Memory Bank - menuca_v3 Migration Project

**Last Updated:** 2025-09-30  
**Git Branch:** Brian ✅  
**Developer:** Junior Software Developer  
**Project:** Migrate menuca_v1 + menuca_v2 → menuca_v3 (Supabase/PostgreSQL)

---

## 📁 Memory Bank Structure

This memory bank is organized into focused, manageable files:

### Core Files
- **[WORKFLOW.md](WORKFLOW.md)** - ⭐ **START HERE** - How to use memory bank (BEFORE/AFTER checklist)
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - Overall project status, entity overview, dependencies
- **[ETL_METHODOLOGY.md](ETL_METHODOLOGY.md)** - Standard ETL process for all migrations
- **[NEXT_STEPS.md](NEXT_STEPS.md)** - Immediate next actions and pending tasks

### Entity Details (ENTITIES/)
Each entity has its own focused file with source analysis, mapping strategy, and status:

1. **[RESTAURANT_MANAGEMENT.md](ENTITIES/01_RESTAURANT_MANAGEMENT.md)** - In Progress (Other Dev)
2. **[LOCATION_GEOGRAPHY.md](ENTITIES/02_LOCATION_GEOGRAPHY.md)** - ✅ COMPLETE
3. **[SERVICE_SCHEDULES.md](ENTITIES/03_SERVICE_SCHEDULES.md)** - Not Started
4. **[DELIVERY_OPERATIONS.md](ENTITIES/04_DELIVERY_OPERATIONS.md)** - Not Started
5. **[MENU_CATALOG.md](ENTITIES/05_MENU_CATALOG.md)** - Not Started
6. **[ORDERS_CHECKOUT.md](ENTITIES/06_ORDERS_CHECKOUT.md)** - Not Started
7. **[PAYMENTS.md](ENTITIES/07_PAYMENTS.md)** - Not Started
8. **[USERS_ACCESS.md](ENTITIES/08_USERS_ACCESS.md)** - Not Started
9. **[MARKETING_PROMOTIONS.md](ENTITIES/09_MARKETING_PROMOTIONS.md)** - Not Started
10. **[ACCOUNTING_REPORTING.md](ENTITIES/10_ACCOUNTING_REPORTING.md)** - Not Started
11. **[VENDORS_FRANCHISES.md](ENTITIES/11_VENDORS_FRANCHISES.md)** - Not Started
12. **[DEVICES_INFRASTRUCTURE.md](ENTITIES/12_DEVICES_INFRASTRUCTURE.md)** - Not Started

### Completed Migrations (COMPLETED/)
- **[LOCATION_GEOGRAPHY_SUMMARY.md](COMPLETED/LOCATION_GEOGRAPHY_SUMMARY.md)** - Migration summary and lessons learned

---

## 🚀 Quick Reference

### Current Focus
**Entity:** Location & Geography - ✅ COMPLETE  
**Next Entity:** TBD - See [NEXT_STEPS.md](NEXT_STEPS.md)

### Completed Entities
1. ✅ Location & Geography (provinces, cities)

### Blocked/Waiting
- Restaurant Management waiting to complete `restaurant_locations`
- Delivery Operations can now start (unblocked)
- Users & Access can now start (unblocked)

---

## 📊 Progress Overview

| Entity | Status | Tables | Priority |
|--------|--------|--------|----------|
| Restaurant Management | 🔄 In Progress | 6+ tables | HIGH |
| Location & Geography | ✅ Complete | 2 tables | HIGH |
| Service Schedules | ⏳ Not Started | TBD | MEDIUM |
| Delivery Operations | ⏳ Not Started | TBD | MEDIUM |
| Menu & Catalog | ⏳ Not Started | TBD | MEDIUM |
| Orders & Checkout | ⏳ Not Started | TBD | HIGH |
| Payments | ⏳ Not Started | TBD | HIGH |
| Users & Access | ⏳ Not Started | TBD | HIGH |
| Marketing & Promotions | ⏳ Not Started | TBD | LOW |
| Accounting & Reporting | ⏳ Not Started | TBD | MEDIUM |
| Vendors & Franchises | ⏳ Not Started | TBD | LOW |
| Devices & Infrastructure | ⏳ Not Started | TBD | LOW |

---

## 🔗 Key Project Files

### Schemas
- `/Database/Legacy schemas/menuca_v1_structure.sql` - V1 MySQL schema
- `/Database/Legacy schemas/menuca_v2_structure.sql` - V2 MySQL schema
- `/Database/Legacy schemas/menuca_v3.sql` - V3 PostgreSQL/Supabase schema

### Documentation
- `/documentation/core-business-entities.md` - Entity definitions
- `/documentation/migration-steps.md` - ETL process overview
- `/documentation/Location & Geography/` - Completed entity docs
- `/documentation/Restaurants/` - Restaurant Management docs

### Scripts
- `/scripts/` - PowerShell and PHP helper scripts

---

## 📝 How to Use This Memory Bank

**⭐ FIRST TIME?** → Read [WORKFLOW.md](WORKFLOW.md) for complete BEFORE/AFTER checklist

**Quick Access:**
1. **Starting ANY task?** → Follow [WORKFLOW.md](WORKFLOW.md) checklist ✅
2. **Check what to work on?** → Read [NEXT_STEPS.md](NEXT_STEPS.md)
3. **Working on an entity?** → Open that entity's file in `ENTITIES/`
4. **Need ETL guidance?** → Reference [ETL_METHODOLOGY.md](ETL_METHODOLOGY.md)
5. **Check overall status?** → See [PROJECT_STATUS.md](PROJECT_STATUS.md)
6. **Completed something?** → Follow [WORKFLOW.md](WORKFLOW.md) update checklist ✅

---

## 🎯 Golden Rules

1. **PLAN then ACT** - Always read full context before starting
2. **Stay on Brian branch** - Don't switch branches
3. **Update after every milestone** - Keep memory bank current
4. **One entity at a time** - Complete before moving on
5. **Verify everything** - Run validation queries after every migration

---

**Navigation:** Each file in this memory bank is standalone and focused. Start with the file you need.
