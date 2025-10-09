# 🚀 DEVICES & INFRASTRUCTURE - QUICK START CHECKLIST

**New Agent? Start here!** This is your first-day action plan.

---

## ✅ PRE-MIGRATION SETUP (30 mins)

### 1. Read Required Documentation
- [ ] Read `/Database/Devices & Infrastructure Entity/HANDOFF_AGENT_BRIEF.md` (THIS IS CRITICAL!)
- [ ] Read `/MEMORY_BANK/WORKFLOW.md` (Standard workflow)
- [ ] Read `/MEMORY_BANK/ETL_METHODOLOGY.md` (Migration process)
- [ ] Skim `/MEMORY_BANK/PROJECT_STATUS.md` (Project overview)

### 2. Review Recent Success
- [ ] Read `/MEMORY_BANK/ENTITIES/07_MARKETING_PROMOTIONS.md` (Latest entity with BLOB)
- [ ] Skim `/MEMORY_BANK/COMPLETED/MARKETING_PROMOTIONS_COMPLETE.md` (Complete example)
- [ ] Note: Marketing had 100% BLOB success - you can too!

### 3. Verify Resources
- [ ] Confirm dump file exists: `/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql`
- [ ] Check if V2 tablets exists: Search in `/Database/Schemas/menuca_v2_structure.sql`
- [ ] Verify Supabase MCP access: Try `mcp_supabase_list_tables`

---

## 🔍 PHASE 1: SCHEMA DESIGN (Day 1, 4-6 hours)

### Step 1: Analyze Source Data (1 hour)
- [ ] Open `/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql`
- [ ] Review table structure (lines 25-42)
- [ ] Identify BLOB field: `key` VARBINARY(20)
- [ ] Count rows: 894 tablets
- [ ] Note FK: `restaurant` → menuca_v3.restaurants

### Step 2: Check V2 Schema (30 mins)
- [ ] Open `/Database/Schemas/menuca_v2_structure.sql`
- [ ] Search for "tablets" table
- [ ] If exists: Note differences from V1
- [ ] If not exists: V1-only migration (simpler!)

### Step 3: Design V3 Schema (2 hours)
- [ ] Create mapping document: `/documentation/Devices & Infrastructure/devices-infrastructure-mapping.md`
- [ ] Design table name: `menuca_v3.devices` (or `tablets`)
- [ ] Map all V1 fields → V3 fields
- [ ] Define BLOB handling: `key` → `device_key_hash` (BYTEA)
- [ ] Plan timestamp conversions (Unix → TIMESTAMPTZ)
- [ ] Plan boolean conversions (tinyint → boolean)

**Template for mapping doc:**
```markdown
# Devices & Infrastructure Field Mapping

## V1 Source: menuca_v1.tablets (894 rows)

| V1 Field | Type | V3 Field | Type | Transform |
|----------|------|----------|------|-----------|
| id | int | legacy_v1_id | INTEGER | Track original |
| designator | tinytext | device_name | VARCHAR(255) | Direct |
| key | varbinary(20) | device_key_hash | BYTEA | 🔴 BLOB → binary |
| restaurant | int | restaurant_id | INTEGER | FK lookup |
| printing | tinyint | supports_printing | BOOLEAN | (field = 1) |
| config_edit | tinyint | allows_config_edit | BOOLEAN | (field = 1) |
| v2 | tinyint | is_v2_device | BOOLEAN | (field = 1) |
| fw_ver | tinyint | firmware_version | INTEGER | Direct |
| sw_ver | tinyint | software_version | INTEGER | Direct |
| desynced | tinyint | is_desynced | BOOLEAN | (field = 1) |
| last_boot | int | last_boot_at | TIMESTAMPTZ | to_timestamp() |
| last_check | int | last_check_at | TIMESTAMPTZ | to_timestamp() |
| created_at | int | created_at | TIMESTAMPTZ | to_timestamp() |
| modified_at | int | updated_at | TIMESTAMPTZ | to_timestamp() |
```

### Step 4: Update Memory Bank (30 mins)
- [ ] Update `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md`
- [ ] Mark Phase 1 steps as complete
- [ ] Document any findings

---

## 📦 PHASE 2: RAW DATA LOAD (Day 1-2, 4-6 hours)

### Step 1: Create Staging Tables (1 hour)
- [ ] Create `/Database/Devices & Infrastructure Entity/01_create_staging_raw_tables.sql`
- [ ] Define `staging.v1_tablets` (exact structure as V1)
- [ ] Define `staging.v2_tablets` (if V2 exists)
- [ ] Execute via MCP: `mcp_supabase_execute_sql`

**Script structure:**
```sql
-- Create staging schema if not exists
CREATE SCHEMA IF NOT EXISTS staging;

-- Drop if exists for idempotent migration
DROP TABLE IF EXISTS staging.v1_tablets;

-- Create V1 tablets staging (EXACT V1 structure)
CREATE TABLE staging.v1_tablets (
  id INTEGER PRIMARY KEY,
  designator VARCHAR(255) NOT NULL,
  key BYTEA,  -- BLOB field
  restaurant INTEGER NOT NULL DEFAULT 0,
  printing SMALLINT NOT NULL DEFAULT 0,
  config_edit SMALLINT NOT NULL DEFAULT 0,
  v2 SMALLINT NOT NULL DEFAULT 0,
  fw_ver SMALLINT NOT NULL DEFAULT 0,
  sw_ver SMALLINT NOT NULL DEFAULT 0,
  desynced SMALLINT NOT NULL DEFAULT 0,
  last_boot INTEGER NOT NULL DEFAULT 0,
  last_check INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT 0,
  modified_at INTEGER NOT NULL DEFAULT 0
);
```

### Step 2: Extract INSERT Statements (1 hour)
- [ ] Create Python script: `/Database/Devices & Infrastructure Entity/extract_inserts.py`
- [ ] Extract INSERT statements from dump file
- [ ] Handle binary BLOB encoding
- [ ] Output to: `/Database/Devices & Infrastructure Entity/staging_inserts/`

**Reference:** Marketing entity's `extract_inserts_fixed.py`

### Step 3: Load Data via MCP (2-3 hours)
- [ ] Split large INSERT into batches (20-50 rows each)
- [ ] Load each batch: `mcp_supabase_execute_sql`
- [ ] Track progress: Create `PHASE_2_PROGRESS.md`
- [ ] Verify row count after each batch

**Pro tip:** Marketing loaded 927 rows this way - proven method!

### Step 4: Verify Load (30 mins)
- [ ] Query: `SELECT COUNT(*) FROM staging.v1_tablets;` (expect: 894)
- [ ] Check BLOB field: `SELECT id, designator, key FROM staging.v1_tablets LIMIT 5;`
- [ ] Verify restaurant FKs exist: Check for invalid restaurant IDs

### Step 5: Update Memory Bank (30 mins)
- [ ] Create `/Database/Devices & Infrastructure Entity/PHASE_2_COMPLETION_SUMMARY.md`
- [ ] Update entity tracking with Phase 2 complete
- [ ] Document any issues found

---

## 🔬 PHASE 3: BLOB DESERIALIZATION (Day 2, 6-8 hours)

### Step 1: Analyze BLOB Structure (1 hour)
- [ ] Query sample BLOB: `SELECT id, designator, encode(key, 'hex') FROM staging.v1_tablets LIMIT 10;`
- [ ] Determine if hex, base64, or raw binary
- [ ] Document BLOB structure findings

### Step 2: Create Deserialization Script (2 hours)
- [ ] Create `/Database/Devices & Infrastructure Entity/deserialize_tablets_blobs.py`
- [ ] Write function to handle binary key conversion
- [ ] Test on 3-5 sample records

**Example approach:**
```python
def process_device_key(blob_bytes):
    """Convert VARBINARY key to hex string for PostgreSQL BYTEA"""
    if not blob_bytes or len(blob_bytes) == 0:
        return None
    
    # Return as hex string (PostgreSQL can store as BYTEA)
    return blob_bytes.hex()
```

### Step 3: Test on Sample (1 hour)
- [ ] Add column: `ALTER TABLE staging.v1_tablets ADD COLUMN key_processed BYTEA;`
- [ ] Run script on 10 tablets
- [ ] Verify results manually
- [ ] Adjust script if needed

### Step 4: Full Deserialization (2 hours)
- [ ] Run script on all 894 tablets
- [ ] Generate UPDATE statements in batches
- [ ] Execute via MCP
- [ ] Monitor success rate

### Step 5: Verify Deserialization (1 hour)
- [ ] Check success rate: `SELECT COUNT(*) FROM staging.v1_tablets WHERE key_processed IS NOT NULL;`
- [ ] Target: 98%+ (Marketing achieved 100%!)
- [ ] Sample review: Compare original vs processed
- [ ] Create verification report

### Step 6: Update Memory Bank (30 mins)
- [ ] Create `BLOB_DESERIALIZATION_COMPLETE.md`
- [ ] Update entity tracking with Phase 3 complete

---

## 🔄 PHASE 4: TRANSFORMATION (Day 2-3, 6-8 hours)

### Step 1: Create V3 Staging Tables (1 hour)
- [ ] Create `/Database/Devices & Infrastructure Entity/02_create_v3_staging_tables.sql`
- [ ] Define `staging.devices` with V3 schema
- [ ] Execute via MCP

### Step 2: Write Transformation SQL (2 hours)
- [ ] Create `/Database/Devices & Infrastructure Entity/03_transform_v1_tablets_to_v3.sql`
- [ ] Map restaurant FK (use `menuca_v3.restaurants_id_map`)
- [ ] Convert timestamps: `to_timestamp()`
- [ ] Convert booleans: `(field = 1)`
- [ ] Handle BLOB: Use `key_processed`

**Key transformation logic:**
```sql
INSERT INTO staging.devices (
  restaurant_id, device_name, device_key_hash,
  supports_printing, is_v2_device, firmware_version, software_version,
  is_desynced, last_boot_at, last_check_at,
  legacy_v1_id, created_at, updated_at
)
SELECT 
  COALESCE(r_map.v3_id, 0),
  v1.designator,
  v1.key_processed,
  (v1.printing = 1),
  (v1.v2 = 1),
  v1.fw_ver,
  v1.sw_ver,
  (v1.desynced = 1),
  CASE WHEN v1.last_boot > 0 THEN to_timestamp(v1.last_boot) ELSE NULL END,
  CASE WHEN v1.last_check > 0 THEN to_timestamp(v1.last_check) ELSE NULL END,
  v1.id,
  CASE WHEN v1.created_at > 0 THEN to_timestamp(v1.created_at) ELSE NOW() END,
  CASE WHEN v1.modified_at > 0 THEN to_timestamp(v1.modified_at) ELSE NOW() END
FROM staging.v1_tablets v1
LEFT JOIN menuca_v3.restaurants_id_map r_map ON v1.restaurant = r_map.legacy_v1_id;
```

### Step 3: Execute Transformation (1 hour)
- [ ] Run transformation SQL via MCP
- [ ] Monitor for errors
- [ ] Check row counts

### Step 4: Comprehensive Verification (2 hours)
- [ ] Row counts: Source (894) vs Target
- [ ] FK integrity: Check restaurant_id mapping
- [ ] Sample data review: 10 random devices
- [ ] BLOB integrity: Verify key_processed
- [ ] Timestamp conversions: Spot check dates

### Step 5: Update Memory Bank (30 mins)
- [ ] Create `PHASE_4_VERIFICATION_COMPLETE.md`
- [ ] Update entity tracking with Phase 4 complete

---

## 🚀 PHASE 5: PRODUCTION LOAD (Day 3, 4-6 hours)

### Step 1: Create Production Table (1 hour)
- [ ] Define `menuca_v3.devices` with indexes
- [ ] Add FK constraint to restaurants
- [ ] Execute via MCP

### Step 2: Load to Production (1 hour)
- [ ] Filter for valid restaurant FK only
- [ ] Execute INSERT from staging
- [ ] Monitor load

**Pro tip:** Use INNER JOIN on restaurants to auto-filter invalid FKs

### Step 3: Final Verification (1 hour)
- [ ] Row count: Staging vs Production
- [ ] FK integrity: 100% check
- [ ] BLOB sample: Verify 10 devices
- [ ] No duplicates check

### Step 4: Create Completion Report (1 hour)
- [ ] Create `/Database/Devices & Infrastructure Entity/PHASE_5_PRODUCTION_COMPLETE.md`
- [ ] Document final metrics
- [ ] Note any skipped rows (invalid FK)

### Step 5: Update Memory Bank (1 hour)
- [ ] Update `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md` - COMPLETE
- [ ] Update `/MEMORY_BANK/PROJECT_STATUS.md` - 6/12 entities (50%)!
- [ ] Move summary to `/MEMORY_BANK/COMPLETED/DEVICES_INFRASTRUCTURE_COMPLETE.md`

---

## ✅ FINAL CHECKLIST

### Migration Complete When:
- [ ] All 5 phases complete
- [ ] 800+ devices in production (85-95% of 894)
- [ ] 100% FK integrity verified
- [ ] BLOB data accessible
- [ ] Memory bank fully updated
- [ ] Completion report created

### Success Metrics:
- [ ] **Row Accuracy:** 100% staging load
- [ ] **FK Integrity:** 100% in production
- [ ] **BLOB Success:** 98%+ deserialization
- [ ] **Load Rate:** 85-95% to production (filtered for valid FK)

---

## 🆘 NEED HELP?

### Quick References:
1. **BLOB Help:** `/Database/Marketing & Promotions/deserialize_v1_deals_blobs.py`
2. **Transformation Help:** `/Database/Marketing & Promotions/04_transform_v1_deals_to_v3.sql`
3. **Verification Help:** `/Database/Marketing & Promotions/PHASE_5_PRODUCTION_COMPLETE.md`
4. **Process Help:** `/MEMORY_BANK/ETL_METHODOLOGY.md`

### Common Issues:
- **BLOB not deserializing?** Check binary encoding (hex vs base64)
- **FK violations?** Filter for valid restaurants during production load
- **MCP timeouts?** Reduce batch size (20 rows instead of 50)
- **Timestamp errors?** Handle zeros: `CASE WHEN field > 0 THEN ... ELSE NULL END`

---

## 🎯 PRO TIPS

1. **Always test on 10 rows first** before running full transformations
2. **Use Supabase MCP** for all loads (proven fastest method)
3. **Update memory bank after EVERY phase** (don't lose context!)
4. **Verify immediately after each step** (catch errors early)
5. **Document edge cases** as you find them

---

## 🔥 YOU'RE READY!

You have:
- ✅ Proven 5-phase process
- ✅ Complete handoff documentation
- ✅ Reference implementations
- ✅ Smaller dataset than previous entities
- ✅ Simpler BLOB handling
- ✅ Only one FK dependency

**This is your roadmap. Follow it phase by phase. You'll complete this in 2-3 days!**

**Let's make this entity #6 complete! 🚀**

---

**Created:** 2025-10-08  
**Estimated Time:** 2-3 days (24-30 hours)  
**Success Rate:** 100% (based on 5 previous entities)

