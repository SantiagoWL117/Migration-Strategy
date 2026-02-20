# menuca_v3 Schema — Project Documentation

> **Single Source of Truth** for the Menu.ca V3 database schema (`menuca_v3`)

---

## 📋 Purpose

This repository documents the **menuca_v3** PostgreSQL schema hosted on Supabase (project: `menu-rebuild-vo`). It enables developers and agents to:

1. Understand the current database schema and business entities
2. Run queries and manage Edge Functions against the live database
3. Reference legacy CRM scrapers used during data migration
4. Review audits and feature handoff documents

---

## 🗂️ Project Structure

```
Migration Strategy/
├── .env                                    ← Credentials (gitignored)
├── .gitignore
├── LICENSE
├── README.md                               ← You are here
│
└── Menu.ca V3 Database Documentation/
    │
    ├── entities/                            ← Core schema documentation (10 docs)
    │   ├── 01-restaurant-entity.md          Profile, config, hours, payment methods
    │   ├── 02-delivery-zones-entity.md      Scheduling & delivery management
    │   ├── 03-menu-management-entity.md     Categories, dishes, modifiers, caching
    │   ├── 04-order-management-entity.md    Orders, order items, status history
    │   ├── 05-user-entity.md               Customers, addresses, favorites
    │   ├── 06-admin-entity.md              Admin users, roles, permissions
    │   ├── 07-marketing-entity.md          Promotions, deals, tags
    │   ├── 08-geography-entity.md          Cities, provinces, cuisine types
    │   ├── 09-vendor-entity.md             Vendors, commissions, statements
    │   └── 10-system-entity.md             Audit log, auth tokens, cart, payments
    │
    ├── Audits/
    │   ├── Audits 1/                        ← Initial V3 rollout audit (8 docs)
    │   └── audit_followup_db_2026-02-17/    ← DB health follow-up audit (6 docs)
    │
    ├── Handoffs/                            ← Feature handoff documents (9 docs)
    │   ├── ADMIN_PROFILE_UPDATE_HANDOFF.md
    │   ├── BILINGUAL_MENU_HANDOFF.md
    │   ├── COMBO_MODIFIER_GROUPS_HANDOFF.md
    │   ├── DEAL_ELIGIBILITY_VALIDATION_HANDOFF.md
    │   ├── DELIVERY_PROVIDERS_HANDOFF.md
    │   ├── DISTANCE_BASED_RESTAURANTS_HANDOFF.md
    │   ├── RESTAURANT_ADMIN_ACCESS_HANDOFF.md
    │   ├── RESTOZONE_TABLET_API_HANDOFF.md
    │   └── SIZE_PRICE_MATCHING_HANDOFF.md
    │
    ├── Scrapers/                            ← Python scrapers (legacy CRM → V3)
    │   ├── Commission rates/                V1 & V2 commission rate scrapers
    │   ├── Delivery and Schedule scraper/   Delivery fees, schedules, distance-based
    │   ├── Menu Scrapers/                   Menu items, combos, modifiers, prices
    │   ├── Payment Options/                 V1 & V2 payment option scrapers
    │   ├── Restaurant Admin Scrapers/       V1 & V2 admin contact scrapers
    │   └── Restaurant contact Scraper/      V1 & V2 restaurant contact scrapers
    │
    └── Supabase Connection/                 ← Connection setup scripts & guides
        ├── README.md                        Comprehensive connection guide
        ├── SUPABASE-QUICKSTART-CONNECTION.md Agent quick-start
        ├── windows_setup_supabase_session.ps1
        └── mac_setup_supabase_session.sh
```

---

## 📖 Key Folders

### `entities/` — Schema Documentation

Each entity document covers one business domain and contains:

| Section | Content |
|---------|---------|
| **Tables** | Columns, types, row counts, constraints |
| **SQL Functions** | Database functions with signatures |
| **Indexes** | All indexes with definitions |
| **RLS Policies** | Row Level Security policies |
| **Triggers** | Trigger definitions and purposes |
| **Data Integrity Issues** | Known issues and planned fixes |

Entities are numbered by dependency order — `01` (restaurants) through `10` (system infrastructure).

### `Audits/` — Schema Health Reports

- **Audits 1/**: V3 rollout scorecard, API inventory, order state machine, security notes, incident runbook
- **audit_followup_db_2026-02-17/**: Health metrics, stuck orders forensics, Stripe reconciliation, kill switches, RPC/RLS audit

### `Handoffs/` — Feature Implementation Guides

Handoff documents for features requiring frontend/backend coordination (admin profiles, bilingual menus, combos, delivery providers, tablet API, etc.).

### `Scrapers/` — Legacy Data Migration

Python scripts (Playwright + BeautifulSoup) used to scrape data from V1/V2 legacy CRM systems into the `menuca_v3` schema. Each scraper has a markdown prompt and runner script.

### `Supabase Connection/` — Database Access

Setup scripts and guides for connecting agents to the Supabase project. See the [Connection Details](#-connection-details) section below.

---

## 🤖 Agent Guidelines

### Role

You are a **Senior Database Administrator** with expertise in PostgreSQL and Supabase.

### Database Query Protocol

**CRITICAL: Use this EXACT psql command for ALL menuca_v3 queries:**

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:<DB_PASSWORD>@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
```

Replace `<DB_PASSWORD>` with the value of `SUPABASE_DB_PASSWORD` from the `.env` file.

**Why each component is required:**

| Component | Purpose |
|-----------|---------|
| `$env:PGCLIENTENCODING="UTF8"` | Handles special characters (é, è, ñ) in restaurant names |
| `$env:PAGER=""` | Disables system pager to prevent hangs |
| `--pset pager=off` | Disables psql pager to prevent `-- More --` infinite hangs |

**Without all three components, queries WILL hang on large result sets (>20-50 rows).**

### Supabase CLI

```powershell
$env:SUPABASE_ACCESS_TOKEN="<SUPABASE_ACCESS_TOKEN>"; supabase [command]
```

Replace `<SUPABASE_ACCESS_TOKEN>` with the value from the `.env` file.

### Recommended Actions Format

1. **Always use LIST format** — never a single massive SQL script
2. **Each action must be separate** with description and individual SQL
3. **Number each action** for easy reference
4. **Include impact assessment** (Low / Medium / High)

**Example:**

1. **Delete unused column** (Impact: Low)
   ```sql
   ALTER TABLE menuca_v3.restaurants DROP COLUMN is_featured;
   ```

2. **Create missing index** (Impact: Medium)
   ```sql
   CREATE INDEX idx_orders_guest_email ON menuca_v3.orders(guest_email);
   ```

### Documentation Update Protocol

When making schema changes:

1. **Update the relevant entity document** with new tables, columns, functions, RLS policies, or removed functionality
2. **Add entry to the Data Integrity Issues or Schema Fixes Applied section** with date, description, reason, and SQL used

### Documentation Rules

1. **Do NOT create additional documentation files** unless the user explicitly requests it
2. **All schema changes MUST be tracked in the respective entity document** (`entities/*.md`)
3. **Never create separate files** for notes, summaries, or change logs
4. **Entity documents must stay under 750 lines** so agents can read them accurately

---

## 🔗 Connection Details

| Detail | Value |
|--------|-------|
| **Project Name** | `menu-rebuild-vo` |
| **Project Ref** | `nthpbtdjhhnwfxqsxbvy` |
| **Host** | `db.nthpbtdjhhnwfxqsxbvy.supabase.co` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **Schema** | `menuca_v3` |
| **Project URL** | `https://nthpbtdjhhnwfxqsxbvy.supabase.co` |

### Credentials

All credentials are stored in the `.env` file at the project root (gitignored).

| Variable | Purpose |
|----------|---------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_KEY` | Service role key (bypasses RLS) |
| `SUPABASE_ACCESS_TOKEN` | CLI authentication token |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role API key |
| `SUPABASE_DB_PASSWORD` | Database password |
| `DB_CONNECTION_STRING` | Full PostgreSQL connection string |
| `CRM_BASE_URL` | Legacy CRM admin URL |
| `CRM_USERNAME` | Legacy CRM username |
| `CRM_PASSWORD` | Legacy CRM password |

> **NEVER hardcode credentials in any file. Always load from `.env`.**

### Windows psql Template

```powershell
$env:PGCLIENTENCODING="UTF8"; $env:PAGER=""; & "C:\Program Files\PostgreSQL\17\bin\psql.exe" "postgresql://postgres:<DB_PASSWORD>@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
```

### Mac/Linux psql Template

```bash
PGCLIENTENCODING=UTF8 PAGER="" psql "postgresql://postgres:<DB_PASSWORD>@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres" --pset pager=off -c "YOUR_SQL_HERE"
```

### Supabase CLI Template

```powershell
$env:SUPABASE_ACCESS_TOKEN="<SUPABASE_ACCESS_TOKEN>"; supabase [command]
```

---

## 🔧 Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Query hangs at `-- More --` | Missing `--pset pager=off` | Use the full command template above |
| Encoding error (WIN1252) | Missing `$env:PGCLIENTENCODING="UTF8"` | Include encoding variable at start |
| Query times out | Pager hang or slow query | Ensure `$env:PAGER=""` and `--pset pager=off` are present |
| Incomplete results | Pager triggered | Verify all three components in command template |

---

## 📊 Schema Overview

| Metric | Value |
|--------|-------|
| **Entities** | 10 business domains |
| **Primary Key Type** | `bigint` (with UUID for external APIs) |
| **Partitioned Tables** | `orders`, `order_items`, `audit_log` |
| **Bilingual Support** | `_en` / `_fr` column pairs |
| **Soft Deletion** | `deleted_at` timestamp pattern |

---

**Last Updated:** 2026-02-17
