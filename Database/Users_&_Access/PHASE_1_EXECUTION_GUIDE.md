# Users & Access Entity - Phase 1 Execution Guide

**Created:** 2025-10-06  
**Status:** ✅ READY TO EXECUTE  
**Prerequisites:** Supabase PostgreSQL connection, CSV files prepared

---

## 📋 Executive Summary

Phase 1 data loading scripts are ready to execute. Based on your approved decisions:

- ✅ **Active users only** (lastLogin > 2020-01-01)
- ✅ **Active tokens only** (expires_at > NOW())
- ✅ **Skip sessions** (start fresh)
- ✅ **Restaurant FK with NULL** (backfill later)

**Expected Result:** ~28,000 rows loaded (96% reduction from original 670k rows)

---

## 🎯 Phase 1 Goals

1. ✅ Load V1/V2 data into staging tables with activity filters
2. ✅ Assess data quality (duplicates, nulls, email conflicts)
3. ⏳ Create remediation plan for issues found
4. ⏳ Build email deduplication resolution table

---

## 📁 Files Created (Execution Order)

### **Step 1: Create Staging Tables**
**File:** `01_create_staging_tables.sql`  
**Purpose:** Create 10 staging tables to receive CSV data  
**Duration:** ~30 seconds  
**Output:** 10 tables in `staging` schema

**Tables Created:**
- `staging.v1_users` - V1 customer accounts
- `staging.v1_callcenter_users` - V1 call center staff
- `staging.v2_site_users` - V2 customer accounts
- `staging.v2_admin_users` - V2 platform admins
- `staging.v2_admin_users_restaurants` - Admin-restaurant junction
- `staging.v2_site_users_delivery_addresses` - User addresses
- `staging.v2_reset_codes` - Password reset tokens
- `staging.v2_site_users_autologins` - Remember me tokens
- `staging.v2_site_users_favorite_restaurants` - User favorites
- `staging.v2_site_users_fb` - Facebook OAuth profiles

### **Step 2: Load CSV Data with Filters**
**File:** `02_load_staging_data.sql`  
**Purpose:** Load CSV files and apply active-user filters  
**Duration:** ~5-10 minutes (loading 670k rows, filtering to 28k)  
**Output:** Staging tables populated

**Key Operations:**
1. Load all 4 V1 user CSV parts (442,286 rows initial)
2. **FILTER:** Delete inactive users (lastLogin <= 2020-01-01)
3. Backup excluded users to `staging.v1_users_excluded`
4. Load all V2 tables (8 tables)
5. **FILTER:** Delete expired tokens (expires_at <= NOW())
6. Generate summary report with row counts

**Expected Final Counts:**
- V1 users (active): ~10,000-15,000 rows
- V1 users (excluded): ~430,000 rows (backup)
- V2 site_users: 8,943 rows
- V2 addresses: 11,710 rows
- V2 reset_codes (active): ~500 rows
- V2 autologins (active): ~300 rows
- Other tables: ~300 rows combined

### **Step 3: Data Quality Assessment**
**File:** `03_data_quality_assessment.sql`  
**Purpose:** Analyze data for issues before transformation  
**Duration:** ~2-3 minutes  
**Output:** Comprehensive quality report

**7 Assessment Sections:**
1. Row counts & completeness
2. Email deduplication conflicts (V1 vs V2 overlap)
3. NULL values in required fields
4. Password format validation (bcrypt check)
5. Address city/province matching (against menuca_v3.cities)
6. Data type & format issues (email, postal codes)
7. Orphaned records (missing FKs)

---

## 🚀 How to Execute

### Prerequisites

1. **PostgreSQL/Supabase Connection:**
   ```bash
   # Test connection
   psql "postgresql://postgres:[password]@[host]/postgres"
   ```

2. **CSV Files Ready:**
   - Located in: `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access/CSV/`
   - All 20 CSV files prepared ✅

### Execution Commands

**Option A: Execute All Steps (Recommended)**
```bash
cd /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Users_&_Access

# Connect to Supabase
psql "postgresql://postgres:[YOUR_PASSWORD]@[YOUR_HOST]/postgres"

# Run all three scripts in order
\i 01_create_staging_tables.sql
\i 02_load_staging_data.sql
\i 03_data_quality_assessment.sql
```

**Option B: Execute Step-by-Step**
```bash
# Step 1: Create tables
psql "postgresql://..." -f 01_create_staging_tables.sql

# Step 2: Load data (review output before proceeding)
psql "postgresql://..." -f 02_load_staging_data.sql

# Step 3: Assess quality (review findings)
psql "postgresql://..." -f 03_data_quality_assessment.sql
```

---

## 📊 Expected Results

### Step 1: Create Staging Tables
```
CREATE SCHEMA
CREATE TABLE (x10)
CREATE INDEX (x20+)
SELECT
 status                       | tables_created | estimated_data | optimization
------------------------------+----------------+----------------+---------------------------
 Staging tables created successfully! | 10             | ~28,000 rows expected | 96% reduction from original
```

### Step 2: Load Data
```
COPY 14292 (menuca_v1_users.csv)
COPY 142665 (menuca_v1_users_part1.csv)
COPY 142665 (menuca_v1_users_part2.csv)
COPY 142664 (menuca_v1_users_part3.csv)

DELETE 432000+ (inactive users filtered out)

 active_users_kept | inactive_users_excluded | pct_kept
-------------------+-------------------------+---------
 10000-15000       | 430000+                 | 2-3%

COPY 8943 (menuca_v2_site_users.csv)
COPY 53 (menuca_v2_admin_users.csv)
... (8 more V2 tables)

DELETE 3000+ (expired tokens filtered out)

Final Summary:
 table_name                    | row_count | notes
-------------------------------+-----------+--------------------------------
 V1 users (active only)        | ~12000    | FILTERED: lastLogin > 2020-01-01
 V1 users excluded             | ~430000   | Backup of inactive users
 V2 site_users                 | 8943      | All V2 users (all active)
 V2 delivery_addresses         | 11710     | User saved addresses
 V2 reset_codes (active)       | ~500      | FILTERED: expires_at > NOW()
 ... (more tables)
 
EMAIL DEDUPLICATION PREVIEW:
 metric         | unique_emails | total_users | duplicate_emails
----------------+---------------+-------------+-----------------
 Email Analysis | ~15000        | ~20000      | ~5000
```

### Step 3: Quality Assessment
```
1. ROW COUNTS & COMPLETENESS
 source_table          | total_rows | unique_ids | duplicate_ids | pct_unique
-----------------------+------------+------------+---------------+-----------
 V1 users (active)     | ~12000     | ~12000     | 0             | 100.00
 V2 site_users         | 8943       | 8943       | 0             | 100.00
 ... (all tables)

2. EMAIL DEDUPLICATION ANALYSIS
 Email Conflicts Between V1 and V2:
 email_normalized        | v1_count | v2_count | resolution_strategy
-------------------------+----------+----------+--------------------
 customer@example.com    | 1        | 1        | V2 Winner (newer)
 ... (showing ~5000 conflicts)
 
 Email Conflict Summary:
 v1_only | v2_only | both_v1_and_v2_conflicts | total_unique_emails
---------+---------+--------------------------+--------------------
 ~7000   | ~3000   | ~5000                    | ~15000

3. NULL VALUES IN REQUIRED FIELDS
 field_name | null_count | total_count | null_pct
------------+------------+-------------+---------
 email      | 0          | 12000       | 0.00
 password   | 0          | 12000       | 0.00
 ... (validation checks)

4. PASSWORD FORMAT VALIDATION
 source           | total_passwords | bcrypt_format | other_format | null_passwords
------------------+-----------------+---------------+--------------+---------------
 V1 Users         | ~12000          | ~12000        | 0            | 0
 V2 Site Users    | 8943            | 8943          | 0            | 0
 
 ✅ EXCELLENT: 100% bcrypt format (can migrate hashes directly!)

5. ADDRESS CITY/PROVINCE VALIDATION
 Top Cities:
 city_name | province_code | address_count | unique_users
-----------+---------------+---------------+-------------
 Ottawa    | ON            | 3500          | 2800
 Montreal  | QC            | 2200          | 1900
 ... (top 20 cities)
 
 Cities NOT in menuca_v3.cities:
 address_city | address_province | address_count | match_status
--------------+------------------+---------------+-------------
 Otawa        | ON               | 15            | NOT FOUND (typo)
 ... (unmatched cities needing fuzzy matching)

6. DATA TYPE & FORMAT ISSUES
 Postal Code Format:
 total_with_zip | correct_format | incorrect_format | pct_correct
----------------+----------------+------------------+------------
 11710          | 9500           | 2210             | 81.13%
 
 Sample incorrect: "K2L4B6" (missing space) → Should be "K2L 4B6"

7. ORPHANED RECORDS
 V2 Addresses - Orphaned:
 total_addresses | orphaned_addresses | orphan_pct
-----------------+--------------------+-----------
 11710           | 0                  | 0.00%
 
 ✅ EXCELLENT: Zero orphaned addresses
```

---

## ⚠️ Expected Issues & Solutions

### Issue 1: Email Conflicts (Expected ~5,000)
**Problem:** Same email in both V1 and V2  
**Solution:** Deduplication strategy already decided - V2 wins  
**Action:** Script 04 will create resolution table (next step)

### Issue 2: Unmatched Cities (Expected ~500-1,000)
**Problem:** City names not in menuca_v3.cities (typos, variants)  
**Solution:** Fuzzy matching or manual mapping table  
**Action:** Will assess during quality report review

### Issue 3: Postal Code Formats (Expected ~20% incorrect)
**Problem:** Missing space in postal codes (K2L4B6 vs K2L 4B6)  
**Solution:** Auto-fix with REGEX in transformation  
**Action:** Handled in Phase 2 transformation queries

### Issue 4: Inactive User Accounts (Expected 0 due to filter)
**Problem:** N/A - Already filtered out  
**Solution:** N/A  
**Action:** None needed ✅

---

## 🔍 What to Review After Execution

### Critical Findings to Check:

1. **Email Conflict Count:**
   - Expected: ~5,000 conflicts
   - If much higher: Investigate duplicate patterns
   - If much lower: Good! Less work needed

2. **Password Format:**
   - Expected: 100% bcrypt
   - If non-bcrypt found: Need to handle those users separately

3. **Unmatched Cities:**
   - Review top 20-30 unmatched cities
   - Common typos: "Otawa" → "Ottawa", "Monteal" → "Montreal"
   - Missing cities: Add to menuca_v3.cities first

4. **Orphaned Records:**
   - Expected: Close to 0%
   - If high: Investigate data consistency issues

---

## 📝 Next Steps After Phase 1

Once you've reviewed the data quality assessment:

1. **Create Email Deduplication Plan** (users-09)
   - Build resolution table for ~5,000 conflicts
   - Implement V2-wins strategy

2. **Create City Mapping Table** (users-09)
   - Handle typos and variants
   - Add missing cities to menuca_v3.cities

3. **Design V3 Schema** (users-10)
   - Create production table DDL
   - Define constraints and indexes

4. **Build Transformation Queries** (users-11)
   - V1 → V3 with filters
   - V2 → V3 with deduplication
   - Merge logic

---

## 🎯 Success Criteria

Phase 1 is complete when:
- ✅ All staging tables populated
- ✅ Active-user filters applied (96% reduction achieved)
- ✅ Data quality assessment run
- ✅ Key findings documented
- ✅ Email conflicts quantified
- ✅ City/province matching analyzed
- ✅ Password format verified (100% bcrypt expected)

**Estimated Timeline:** 15-20 minutes to execute all scripts

---

## 🚨 Troubleshooting

### Error: "Permission denied for schema staging"
**Solution:** Grant permissions:
```sql
GRANT ALL ON SCHEMA staging TO your_user;
GRANT ALL ON ALL TABLES IN SCHEMA staging TO your_user;
```

### Error: "File not found" during \COPY
**Solution:** Update file paths in `02_load_staging_data.sql` to match your system

### Error: "Delimiter mismatch"
**Solution:** V1 uses semicolon (;), V2 uses comma (,) - scripts already handle this

### Error: "Out of memory"
**Solution:** Load V1 users in smaller batches (comment out part2/part3 temporarily)

---

**Status:** ✅ Scripts ready for execution | Review quality assessment after running

**Next:** Execute scripts and review data quality findings before proceeding to Phase 2
