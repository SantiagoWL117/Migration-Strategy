# Mermaid Diagrams - menuca_v3 Schema

**Purpose:** Visual Entity-Relationship Diagrams (ERDs) for menuca_v3 database schema

**Status:** Living documentation that updates as entities are migrated

**Integration:** Compatible with [MermaidChart.com](https://www.mermaidchart.com/) for interactive editing

---

## 📊 How to Use

### In GitHub/Markdown Viewers
All `.mmd` files render automatically in GitHub and most markdown viewers.

### In MermaidChart.com
1. Copy contents of any `.mmd` file
2. Go to [MermaidChart.com](https://www.mermaidchart.com/app/dashboard)
3. Create new diagram → Paste code
4. Edit visually → Export back to repo

### In Cursor/VS Code
Install Mermaid preview extension to view diagrams inline.

---

## 🗂️ Diagram Files

### Master Overview
- **[master_schema.mmd](./master_schema.mmd)** - Complete system overview (all entities)

### ✅ Completed Entities

#### 1. Location & Geography (COMPLETE: 2025-09-30)
- **[location_geography.mmd](./location_geography.mmd)**
- **Tables:** provinces, cities
- **Rows:** ~140 total
- **Blocks:** Restaurant Management, Delivery Operations, Users & Access

#### 2. Restaurant Management (COMPLETE: 2025-10-06)
- **[restaurant_management.mmd](./restaurant_management.mmd)**
- **Tables:** restaurants, restaurant_locations, restaurant_contacts, restaurant_domains, restaurant_admin_users, restaurant_schedules, restaurant_service_configs, restaurant_special_schedules, restaurant_time_periods
- **Rows:** 944 restaurants + related tables
- **Status Correction:** 2025-10-14 (101 restaurants corrected to active)

#### 3. Menu & Catalog (COMPLETE: 2025-10-03)
- **[menu_catalog.mmd](./menu_catalog.mmd)**
- **Tables:** courses, dishes, ingredients, ingredient_groups, combo_groups, combo_items, dish_customizations, dish_modifiers
- **Rows:** 121,149 (80,610 orphaned ghost records excluded)
- **Notable:** Phase 4 BLOB deserialization complete (98.6% success)

#### 4. Users & Access (COMPLETE: 2025-10-06)
- **[users_access.mmd](./users_access.mmd)**
- **Tables:** site_users, user_delivery_addresses, admin_users, admin_user_restaurants
- **Rows:** 32,349 users + 51 admins

#### 5. Marketing & Promotions (COMPLETE: 2025-10-08)
- **[marketing_promotions.mmd](./marketing_promotions.mmd)**
- **Tables:** marketing_tags, restaurant_tag_associations, promotional_deals, promotional_coupons
- **Rows:** 848 total

### 🔄 In Progress Entities

#### 6. Orders & Checkout (IN PROGRESS)
- **[orders_checkout.mmd](./orders_checkout.mmd)** *(scaffold)*
- **Tables:** TBD
- **Dependencies:** Menu ✅, Users ✅, Restaurant ✅

### ⏳ Not Started Entities

#### 7. Service Configuration & Schedules (NOT STARTED)
- **[service_schedules.mmd](./service_schedules.mmd)** *(scaffold)*
- **Blocked By:** Restaurant Management (COMPLETE ✅)

#### 8. Delivery Operations (NOT STARTED)
- **[delivery_operations.mmd](./delivery_operations.mmd)** *(scaffold)*
- **Blocked By:** None - Can start now

#### 9. Payments (NOT STARTED)
- **[payments.mmd](./payments.mmd)** *(scaffold)*
- **Blocked By:** Orders & Checkout

#### 10. Accounting & Reporting (NOT STARTED)
- **[accounting_reporting.mmd](./accounting_reporting.mmd)** *(scaffold)*
- **Blocked By:** Orders, Payments

#### 11. Vendors & Franchises (NOT STARTED)
- **[vendors_franchises.mmd](./vendors_franchises.mmd)** *(scaffold)*
- **Blocked By:** Restaurant Management (COMPLETE ✅)

#### 12. Devices & Infrastructure (NOT STARTED)
- **[devices_infrastructure.mmd](./devices_infrastructure.mmd)** *(scaffold)*
- **Blocked By:** Restaurant Management (COMPLETE ✅)

---

## 📖 Companion Documentation

**Master Documentation File:**
- [V3_MERMAID_SCHEMA.md](../V3_MERMAID_SCHEMA.md) - Complete schema documentation with embedded diagrams, query patterns, performance tips, and migration history

---

## 🔗 Entity Relationships Summary

```
Location & Geography (COMPLETE ✅)
    ├── Restaurant Management (COMPLETE ✅)
    │   ├── Service Schedules (CAN START ✅)
    │   ├── Marketing & Promotions (COMPLETE ✅)
    │   ├── Vendors & Franchises (CAN START ✅)
    │   └── Devices & Infrastructure (CAN START ✅)
    ├── Menu & Catalog (COMPLETE ✅)
    │   └── Orders & Checkout (IN PROGRESS 🔄)
    │       ├── Payments (BLOCKED)
    │       └── Accounting & Reporting (BLOCKED)
    ├── Delivery Operations (CAN START ✅)
    └── Users & Access (COMPLETE ✅)
        └── Orders & Checkout (UNBLOCKED ✅)
```

---

## 🎨 Diagram Conventions

### Entity Status Colors (in documentation)
- 🟢 **Green** - Complete entity with full data
- 🟡 **Yellow** - In progress / partial data
- 🔴 **Red** - Not started / blocked

### Relationship Cardinality
- `||--||` - One to one
- `||--o{` - One to many
- `}o--o{` - Many to many
- `||--o|` - One to zero or one

### Field Annotations
- `PK` - Primary Key
- `FK` - Foreign Key
- `UK` - Unique Key
- `→ table.column` - References target table/column

---

## 📝 Best Practices

1. **Keep Diagrams Updated** - Update `.mmd` files when schema changes
2. **Use Semantic Names** - Clear, descriptive relationship labels
3. **Document Status** - Add completion dates and row counts in comments
4. **Export from MermaidChart** - Keep repo as source of truth
5. **Version Control** - Commit diagram changes with schema migrations

---

**Last Updated:** 2025-10-15  
**Maintained By:** Brian Lapp (Junior Developer)  
**Project:** menuca_v3 Database Migration to Supabase

