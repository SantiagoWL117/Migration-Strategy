# ETL Methodology - Standard Migration Process

**Reference:** `/documentation/migration-steps.md`  
**Applies to:** All menuca_v3 entity migrations

---

## 📋 Overview

Every entity migration follows the same Extract-Transform-Load (ETL) pattern with verification.

---

## 🔄 Phase 1: EXTRACT

### 1. Field Mapping (AI Responsibility)
- Analyze V1 and V2 source schemas
- Map source fields to V3 target schema
- Document data types, transformations needed
- Identify primary sources vs validation sources
- **Output:** Mapping document (e.g., `entity-mapping.md`)

### 2. Review Tables (User Responsibility)
- Verify no other useful tables exist in V1/V2
- Check for related tables that should be included
- Confirm table scope with stakeholders
- **Output:** Confirmed table list

### 3. Add Data Dumps (User Responsibility)
- Based on field mapping, add sample dumps for analysis
- Export representative data from source tables
- **Output:** SQL dump files in `/Database/Entity/dumps/`

### 4. Preconditions (AI Responsibility)
- Verify V3 target tables exist in menuca_v3 schema
- Check foreign key dependencies are satisfied
- Confirm indexes and constraints are in place
- **Output:** Precondition SQL scripts

### 5. Extract to CSV (User Responsibility)
- Export data from tables/columns defined in mapping
- Use SELECT queries from migration plan
- **Output:** CSV files in `/Database/Entity/CSV/`

Example:
```sql
SELECT col1, col2, col3
FROM menuca_v2.source_table
ORDER BY id
INTO OUTFILE '/path/to/export.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

### 6. Build Staging Tables (AI Responsibility)
- Create staging schema if not exists
- Design staging tables matching CSV structure
- Load CSV data into staging tables
- **Output:** Staging tables in `staging` schema

Example:
```sql
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.v2_source_table;
CREATE TABLE staging.v2_source_table (
  legacy_id INTEGER,
  field1 VARCHAR(125),
  field2 TEXT,
  ...
);

\COPY staging.v2_source_table FROM '/path/to/export.csv' CSV HEADER;
```

---

## 🔧 Phase 2: TRANSFORM

### 1. Verify Format Discrepancies
- Check for NULL/empty required fields
- Validate data type conversions (VARCHAR → NUMERIC, etc.)
- Check for invalid foreign key references
- Identify duplicates within source
- Compare V1 vs V2 for conflicts
- **Output:** Data quality report queries

### 2. Data Cleaning
- Normalize text (TRIM, INITCAP, UPPER/LOWER)
- Remove duplicates (keep best record)
- Handle NULL values (set defaults or derive)
- Fix invalid data (out of range, wrong format)
- **Output:** UPDATE/DELETE statements on staging

### 3. Type Conversion
- VARCHAR → NUMERIC for coordinates
- Enum strings → BOOLEAN
- Timestamps (INT/VARCHAR → TIMESTAMPTZ)
- BLOB → JSON (if applicable)
- **Output:** Converted staging data

---

## 📦 Phase 3: LOAD

### 1. Transform and Upsert
- Build INSERT ... ON CONFLICT queries
- Map staging data to V3 schema
- Resolve foreign keys (V1/V2 IDs → V3 IDs)
- Handle conflicts with DO UPDATE or DO NOTHING
- **Output:** Upsert SQL in migration plan

Example:
```sql
INSERT INTO menuca_v3.target_table (col1, col2, col3)
SELECT 
  transformed_col1,
  transformed_col2,
  transformed_col3
FROM staging.source_table
ON CONFLICT (unique_key)
DO UPDATE SET
  col1 = EXCLUDED.col1,
  col2 = COALESCE(EXCLUDED.col2, menuca_v3.target_table.col2);
```

### 2. Handle Conflicts
- Define ON CONFLICT behavior per table
- Decide: UPDATE existing vs SKIP duplicates
- Log conflicts for review if needed
- **Output:** Conflict resolution strategy

### 3. Maintain Referential Integrity
- Verify all FK relationships valid
- Check no orphaned records
- Ensure cascade rules work correctly
- **Output:** FK validation queries

---

## ✅ Phase 4: VERIFICATION

### Required Verification Queries

#### A) Row Count Verification
```sql
SELECT 'V1' as source, COUNT(*) FROM staging.v1_table
UNION ALL
SELECT 'V2' as source, COUNT(*) FROM staging.v2_table
UNION ALL
SELECT 'V3' as source, COUNT(*) FROM menuca_v3.target_table;
```
**Expected:** V3 count = V2 count (or V1+V2 if merged)

#### B) Duplicate Check
```sql
SELECT unique_key, COUNT(*) as cnt
FROM menuca_v3.target_table
GROUP BY unique_key
HAVING COUNT(*) > 1;
```
**Expected:** 0 rows (no duplicates)

#### C) NULL Value Check
```sql
SELECT 
  COUNT(*) FILTER (WHERE required_col IS NULL) as null_count
FROM menuca_v3.target_table;
```
**Expected:** 0 for required fields

#### D) Foreign Key Check
```sql
SELECT t.id, t.fk_column
FROM menuca_v3.target_table t
LEFT JOIN menuca_v3.referenced_table r ON r.id = t.fk_column
WHERE r.id IS NULL;
```
**Expected:** 0 rows (all FKs valid)

#### E) Sample Data Review
```sql
SELECT * FROM menuca_v3.target_table
ORDER BY id LIMIT 20;
```
**Expected:** Data looks correct, properly formatted

---

## 📝 Migration Plan Document Structure

Every entity should have a migration plan following this template:

1. **Purpose** - What and why
2. **Source vs Target Mapping** - Schema evidence with line numbers
3. **Field Mapping Table** - Source → Target with transforms
4. **Data Insights** - Expected counts, quality issues
5. **Preconditions (Step 0)** - Prerequisites
6. **Staging (Step 1)** - Create and load staging
7. **Transform and Upsert (Step 2)** - Idempotent load
8. **Post-load Normalization (Step 3)** - Optional cleanup
9. **Verification (Step 4)** - All verification queries
10. **Execution Order** - Step-by-step guide
11. **Notes** - Important considerations

---

## 🎯 Best Practices

### Idempotency
- All migrations must be re-runnable
- Use ON CONFLICT to handle duplicates
- Never assume clean slate
- Test by running twice

### Data Quality
- Validate before loading
- Document all transformations
- Keep raw data in staging
- Never modify source databases

### Documentation
- Explain every transform
- Include expected outcomes
- Document edge cases
- Note manual interventions

### Version Control
- Commit after each entity complete
- Descriptive commit messages
- Stay on Brian branch
- Don't commit CSV files (too large)

---

## 🚨 Common Pitfalls

❌ **Don't:** Assume V2 is always better than V1  
✅ **Do:** Analyze both, pick best source per field

❌ **Don't:** Ignore validation failures  
✅ **Do:** Fix issues before proceeding

❌ **Don't:** Hard-code IDs in migrations  
✅ **Do:** Use lookups for FK resolution

❌ **Don't:** Skip verification queries  
✅ **Do:** Run ALL verifications every time

❌ **Don't:** Make one huge file  
✅ **Do:** Keep files focused and < 400 lines

---

**Summary:** Extract → Transform → Load → Verify. Document everything. Make it idempotent.
