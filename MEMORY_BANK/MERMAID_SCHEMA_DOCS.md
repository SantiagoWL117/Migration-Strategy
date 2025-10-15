# Mermaid Schema Documentation

**Created:** 2025-10-15  
**Status:** ✅ COMPLETE  
**Purpose:** Visual entity-relationship diagrams for menuca_v3 schema

---

## 📊 What Was Created

### Master Documentation
- **[V3_MERMAID_SCHEMA.md](../Database/V3_MERMAID_SCHEMA.md)** - Complete schema documentation
  - Entity-relationship diagrams
  - Common query patterns
  - Performance tips
  - Migration history
  - Schema standards

### Mermaid Diagrams Directory
- **Location:** `/Database/Mermaid_Diagrams/`
- **Integration:** Compatible with [MermaidChart.com](https://www.mermaidchart.com/)
- **Format:** `.mmd` files (Mermaid syntax)

---

## 📁 Diagram Files Created

### ✅ Completed Entities (5)

1. **[location_geography.mmd](../Database/Mermaid_Diagrams/location_geography.mmd)**
   - provinces, cities
   - 2 tables, ~140 rows
   - Completed: 2025-09-30

2. **[restaurant_management.mmd](../Database/Mermaid_Diagrams/restaurant_management.mmd)**
   - 9 restaurant tables
   - 944 restaurants + related data
   - Completed: 2025-10-06

3. **[menu_catalog.mmd](../Database/Mermaid_Diagrams/menu_catalog.mmd)**
   - 8 menu tables
   - 121,149 rows (80,610 orphaned excluded)
   - Completed: 2025-10-03

4. **[users_access.mmd](../Database/Mermaid_Diagrams/users_access.mmd)**
   - 4 user tables
   - 32,400+ users
   - Completed: 2025-10-06

5. **[marketing_promotions.mmd](../Database/Mermaid_Diagrams/marketing_promotions.mmd)**
   - 4 marketing tables
   - 848 rows
   - Completed: 2025-10-08

### 🔄 In Progress (1)

6. **[orders_checkout.mmd](../Database/Mermaid_Diagrams/orders_checkout.mmd)** *(scaffold)*
   - To be updated during migration

### ⏳ Not Started (6)

7. **[service_schedules.mmd](../Database/Mermaid_Diagrams/service_schedules.mmd)** *(scaffold)*
8. **[delivery_operations.mmd](../Database/Mermaid_Diagrams/delivery_operations.mmd)** *(scaffold)*
9. **[payments.mmd](../Database/Mermaid_Diagrams/payments.mmd)** *(scaffold)*
10. **[accounting_reporting.mmd](../Database/Mermaid_Diagrams/accounting_reporting.mmd)** *(scaffold)*
11. **[vendors_franchises.mmd](../Database/Mermaid_Diagrams/vendors_franchises.mmd)** *(scaffold)*
12. **[devices_infrastructure.mmd](../Database/Mermaid_Diagrams/devices_infrastructure.mmd)** *(scaffold)*

### 🗺️ Master Overview

13. **[master_schema.mmd](../Database/Mermaid_Diagrams/master_schema.mmd)**
    - Complete system overview
    - All entities and relationships
    - High-level architecture

---

## 🎯 How to Use

### In GitHub/Markdown Viewers
All `.mmd` files render automatically in GitHub and most markdown viewers. The diagrams will display as visual ERDs.

### In MermaidChart.com
1. Copy contents of any `.mmd` file
2. Go to [MermaidChart.com](https://www.mermaidchart.com/app/dashboard)
3. Create new diagram → Paste code
4. Edit visually with drag-and-drop
5. Export back to repo (keep repo as source of truth)

### In Cursor/VS Code
Install Mermaid preview extension to view diagrams inline while editing.

---

## 📋 Diagram Conventions

### Entity Status in Documentation
- 🟢 **Green** - Complete entity with full data
- 🟡 **Yellow** - In progress / partial data
- 🔴 **Red** - Not started / blocked

### Relationship Cardinality
- `||--||` - One to one
- `||--o{` - One to many (most common)
- `}o--o{` - Many to many
- `||--o|` - One to zero or one

### Field Annotations
- `PK` - Primary Key
- `FK` - Foreign Key
- `UK` - Unique Key
- `→ table.column` - References target table/column

---

## 📚 Documentation Features

### V3_MERMAID_SCHEMA.md Includes:

1. **Entity Diagrams** - Visual ERDs for each business domain
2. **Common Query Patterns** - Practical SQL examples
   - Location queries
   - Menu queries
   - User queries
   - Restaurant management queries
3. **Performance Tips** - Optimization strategies
   - Indexing strategy
   - Query optimization
   - JSONB performance
4. **Migration History** - Complete project timeline
   - Phase 1: Location & Geography
   - Phase 2: Restaurant Management
   - Phase 3: Menu & Catalog
   - Phase 4: Users & Access
   - Phase 5: Marketing & Promotions
   - Phase 6: V3 Schema Optimization
5. **Schema Standards** - Naming conventions
   - Table naming
   - Column naming
   - Data types
   - JSONB standards
   - Audit fields
   - Status enums

---

## 🔗 Integration with Project

### Memory Bank Files
- [MEMORY_BANK/README.md](./README.md) - Navigation guide
- [MEMORY_BANK/PROJECT_STATUS.md](./PROJECT_STATUS.md) - Current progress
- [MEMORY_BANK/ENTITIES/](./ENTITIES/) - Individual entity status

### Schema Files
- [Database/Schemas/menuca_v3.sql](../Database/Schemas/menuca_v3.sql) - SQL schema
- [Database/V3_COMPLETE_TABLE_AUDIT.md](../Database/V3_COMPLETE_TABLE_AUDIT.md) - Table audit

---

## 📝 Maintenance

### When to Update Diagrams

1. **New entity migration starts** - Update scaffold `.mmd` file with actual schema
2. **Schema changes** - Reflect modifications in relevant diagram
3. **New tables added** - Add to entity diagram and master schema
4. **Relationships change** - Update cardinality and foreign keys
5. **Migration completes** - Update status comments and row counts

### Update Process

1. Edit `.mmd` file directly (or use MermaidChart)
2. Update V3_MERMAID_SCHEMA.md if needed
3. Commit with descriptive message
4. Keep diagrams in sync with actual schema

---

## 🎨 Benefits

### For Developers
- ✅ Visual understanding of schema relationships
- ✅ Quick reference for foreign keys
- ✅ Common query patterns documented
- ✅ Performance optimization guidance

### For Planning
- ✅ Clear dependency visualization
- ✅ Migration status tracking
- ✅ Entity scope definition
- ✅ Relationship identification

### For Documentation
- ✅ Living documentation (updates with schema)
- ✅ Visual aids for technical docs
- ✅ Onboarding new developers
- ✅ Stakeholder communication

---

## 🚀 Future Enhancements

### Potential Additions
- [ ] Interactive diagrams (MermaidChart exports)
- [ ] Table-level detail diagrams (individual table breakdown)
- [ ] Index visualization (what's indexed where)
- [ ] Query execution plan diagrams
- [ ] Data flow diagrams (for ETL processes)
- [ ] State transition diagrams (order status, restaurant status)

---

## 📞 Questions?

- See [README.md](../Database/Mermaid_Diagrams/README.md) in Mermaid_Diagrams folder
- Check [V3_MERMAID_SCHEMA.md](../Database/V3_MERMAID_SCHEMA.md) for examples
- Review [MermaidChart documentation](https://www.mermaidchart.com/docs)
- Ask Brian Lapp for assistance

---

**Status:** Documentation complete, ready for use  
**Maintained By:** Brian Lapp (Junior Developer)  
**Last Updated:** 2025-10-15

