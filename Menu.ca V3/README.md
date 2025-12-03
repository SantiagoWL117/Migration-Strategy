# menuca_v3 Schema Documentation

> **Single Source of Truth** for the Menu.ca V3 database schema

---

## 📋 Purpose

This documentation structure serves as the **definitive reference** for the entire menuca_v3 schema project. It enables developers and agents to:

1. **Understand** the current state of the database schema
2. **Review** each business entity systematically
3. **Clean up** unnecessary tables, columns, functions, triggers, and RLS policies
4. **Create** new necessary functionalities
5. **Fill** data gaps and ensure data integrity
6. **Track** schema changes and improvements over time

---

## 🗂️ Documentation Structure

```
/docs
├─ README.md                          ← You are here
│
├─ /entities                          ← Core business domain documentation
│  ├─ 01-restaurant-entity.md         (Profile & configuration)
│  ├─ 02-delivery-zones-entity.md     (Scheduling & delivery management)
│  ├─ 03-menu-management-entity.md    (Product catalog)
│  ├─ 04-order-management-entity.md   (Transactions)
│  ├─ 05-user-entity.md               (Customers)
│  ├─ 06-admin-entity.md              (Internal users)
│  ├─ 07-marketing-entity.md          (Promotions)
│  ├─ 08-geography-entity.md          (Location data)
│  ├─ 09-vendor-entity.md             (B2B platform)
│  └─ 10-system-entity.md             (Infrastructure)
│
├─ /relationships                     ← Cross-entity relationship documentation
│  ├─ restaurant-hub.md               (Central entity connections)
│  ├─ delivery-validation-flow.md     (Delivery eligibility logic)
│  ├─ menu-relationships.md           (Menu hierarchy & customization)
│  └─ order-flow.md                   (Order processing pipeline)
│
└─ /patterns                          ← Design patterns & conventions
   ├─ partitioning-strategy.md        (Time-series data partitioning)
   ├─ soft-deletion.md                (Soft delete implementation)
   └─ multi-language.md               (Internationalization approach)
```

---

## 📖 How to Interpret This Structure

### Entity Documents (`/entities`)

Each entity document represents a **core business domain** and contains:

| Section | Description |
|---------|-------------|
| **Purpose** | What this entity represents and its role in the system |
| **Index** | Navigation links to each section within the document |
| **Tables** | Complete list of tables, columns, and their purposes |
| **SQL Functions** | Database functions that operate on this entity |
| **Edge Functions** | Supabase Edge Functions related to this entity |
| **Indexes** | Performance indexes and their rationale |
| **RLS Policies** | Row Level Security policies and access patterns |
| **Triggers** | Database triggers and their purposes |
| **Removed Functionalities** | Deprecated/removed features (for historical context) |
| **New Functionalities** | Planned or recently added features |
| **Schema Fixes Applied** | Bug fixes and corrections made to the schema |

### Relationship Documents (`/relationships`)

These documents explain **how entities connect** and **data flows** between them:

- **Data dependencies** between entities
- **Foreign key relationships** and cascading behavior
- **Business logic flows** that span multiple entities
- **Validation rules** that involve cross-entity checks

### Pattern Documents (`/patterns`)

These documents describe **design patterns** and **conventions** used throughout the schema:

- **Implementation details** of each pattern
- **When to use** each pattern
- **Examples** from the codebase
- **Best practices** for extending patterns

---

## 🔢 Entity Numbering Convention

Entities are numbered by **dependency order**:

1. **01-restaurant** - Core entity, minimal dependencies
2. **02-delivery-zones** - Depends on restaurants
3. **03-menu-management** - Depends on restaurants
4. **04-order-management** - Depends on restaurants, menus, users
5. **05-user** - Core entity, minimal dependencies
6. **06-admin** - Internal system, depends on restaurants
7. **07-marketing** - Depends on restaurants
8. **08-geography** - Reference data, no dependencies
9. **09-vendor** - Depends on restaurants
10. **10-system** - Infrastructure, supports all entities

---

## 🤖 Agent Guidelines

### Role:
You are a Senior Database Administrator with expertise in PostgreSQL and Supabase.

### Database Query Protocol

**When User Requests: "Give me a query that..."**

1. **Always return executable PostgreSQL/Supabase queries** - Not descriptions, not summaries, actual SQL

2. **CRITICAL: Use this EXACT psql command for ALL menuca_v3 schema queries:**
   ```powershell
   $env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
   ```
   
   **Why each component is required:**
   - `$env:PGCLIENTENCODING="UTF8"` - Handles special characters (é, è, ñ) in restaurant names/addresses
   - `$env:PAGER=""` - Disables system pager to prevent hangs
   - `--pset pager=off` - Disables psql pager to prevent `-- More --` prompts that cause infinite hangs
   
   **❌ DO NOT use simplified commands - they will hang on large result sets!**
3. **Use Supabase CLI for function/Edge Function operations:**
   ```bash
   export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase [command]
   ```
4. **Query Format Requirements:**
   - Must be copy-paste ready for immediate execution
   - Include proper formatting and comments
   - Use actual table/column names from menuca_v3 schema
   - Return results in human-readable format

**Example Request:** "Give me a query that returns all delivery zones for restaurant 105"

**Correct Response:**
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT id, zone_name, delivery_fee_cents, minimum_order_cents
FROM menuca_v3.restaurant_delivery_zones
WHERE restaurant_id = 105;
"
```

**Incorrect Responses:** 
- ❌ "You can query the restaurant_delivery_zones table..."
- ❌ Providing SQL without the full psql command wrapper
- ❌ Omitting `$env:PGCLIENTENCODING="UTF8"` or `$env:PAGER=""` or `--pset pager=off`

5. **Agent's role: Senior Database Administrator**

---

### 🚨 Enforcing Standard Query Protocol Across All Agents

**To ensure ALL agents use the correct command:**

1. **Include this README in agent context** by mentioning it in prompts:
   ```
   Follow the database query protocol in @Menu.ca V3/README.md
   ```

2. **Add to agent system prompts:**
   ```
   CRITICAL: Always use the EXACT psql command from Menu.ca V3/README.md for database queries.
   Never simplify or omit any part of the command.
   ```

3. **In agent prompts, reference the standard:**
   ```
   Execute this query using the standard command from README.md:
   [your SQL here]
   ```

4. **Create agent templates** that include the full command by default

5. **When agents provide queries:**
   - They must include the full command wrapper
   - Not just the SQL query
   - All environment variables and flags included

**Example of proper agent response:**
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "
SELECT id, name, status 
FROM menuca_v3.restaurants 
WHERE deleted_at IS NULL 
ORDER BY name;
"
```

---

### Recommended Actions Format

**When Presenting Recommended Actions:**

1. **Always use LIST format** - Never present as a single long SQL query
2. **Each action must be separate** with clear description and individual SQL
3. **Number each action** for easy reference and execution
4. **Include impact assessment** for each action (Low/Medium/High)

**Example - Correct Format:**

**Recommended Actions:**

1. **Delete unused column** (Impact: Low)
   ```sql
   ALTER TABLE menuca_v3.restaurants DROP COLUMN is_featured;
   ```

2. **Update function** (Impact: Medium)
   ```sql
   CREATE OR REPLACE FUNCTION menuca_v3.search_restaurants(...)
   -- Updated function body
   ```

3. **Create missing records** (Impact: High)
   ```sql
   INSERT INTO menuca_v3.restaurant_service_configs (restaurant_id, ...)
   SELECT ... FROM menuca_v3.restaurants ...
   ```

**Incorrect Format:** ❌ Single massive SQL script with multiple operations

### Documentation Update Protocol

When making schema changes:

1. **Update the relevant entity document** with:
   - New tables/columns added
   - Functions created or modified
   - RLS policies changed
   - Any removed functionality

2. **Add entry to Schema Fixes Applied** section with:
   - Date of change
   - Description of what was changed
   - Reason for the change
   - SQL used (if applicable)

3. **Update relationship documents** if cross-entity changes are made

### Documentation Creation Rules

⚠️ **IMPORTANT:**

1. **Do NOT create any additional documentation files** unless the user explicitly requests it
2. **All cleanup/fill-up processes MUST use the respective entity document** to track and document changes
3. Use the existing entity documents (`/entities/*.md`) as the single place to record:
   - Schema fixes applied
   - Removed functionalities
   - New functionalities
   - Any modifications to tables, columns, functions, triggers, or RLS policies
4. **Never create separate markdown files** for notes, summaries, or change logs - update the entity documents instead

---

## 🔗 Quick Reference: Connection Details

| Detail | Value |
|--------|-------|
| **Host** | `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **Schema** | `menuca_v3` |
| **Project Ref** | `nthpbtdjhhnwfxqsxbvy` |
| **Project URL** | `https://nthpbtdjhhnwfxqsxbvy.supabase.co` |

### Windows psql Command Template
```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:Gz35CPTom1RnsmGM@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
```

> **CRITICAL:** This command MUST be used exactly as shown:
> - `$env:PGCLIENTENCODING="UTF8"` - Required for special characters
> - `$env:PAGER=""` - Required to prevent system pager hangs
> - `--pset pager=off` - Required to prevent `-- More --` prompts that cause infinite hangs
> 
> **Without all three components, queries will hang on large result sets (>20-50 rows)**

### Supabase CLI Command Template
```bash
export SUPABASE_ACCESS_TOKEN="sbp_c6c07320cadc875cfd087fd8f8edd03769c8b2b9" && supabase [command]
```

---

## 🔧 Troubleshooting

### Query Hangs at "-- More --"
**Problem:** Query stops and shows `-- More --` prompt  
**Cause:** Missing `--pset pager=off` flag  
**Fix:** Use the complete command from the template above

### Encoding Error (WIN1252)
**Problem:** `ERROR: character with byte sequence 0xef in encoding "UTF8" has no equivalent in encoding "WIN1252"`  
**Cause:** Missing `$env:PGCLIENTENCODING="UTF8"`  
**Fix:** Include encoding variable at the start of command

### Query Times Out
**Problem:** Command times out before completion  
**Cause:** Query taking >15 minutes or pager causing hang  
**Fix:** 
- Ensure `$env:PAGER=""` and `--pset pager=off` are included
- For very long queries (>15 min), use async script: `.\scripts\run_psql_async.ps1`

### Incomplete Results
**Problem:** Only partial results returned  
**Cause:** Pager was triggered and results were cut off  
**Fix:** Verify all three components in command template are present

---

## 📊 Schema Statistics

| Metric | Value |
|--------|-------|
| **Total Tables** | 103 |
| **Total Entities** | 10 |
| **Partitioned Tables** | orders, order_items, audit_log |
| **Total Size** | ~750 MB |
| **Primary Key Type** | bigint (with UUID for external APIs) |

---

## 📅 Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-11-27 | 1.0.0 | Initial documentation structure created |

---

## 👥 Contributors

- Initial structure created via AI-assisted documentation
- Maintained by Menu.ca development team

---

**Last Updated:** 2025-11-27

