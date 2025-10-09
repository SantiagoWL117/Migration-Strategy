# 📱 DEVICES & INFRASTRUCTURE ENTITY - AGENT HANDOFF BRIEF

**Entity Priority:** LOW  
**Estimated Timeline:** 2-3 days  
**Complexity:** MEDIUM (BLOB deserialization required)  
**Dependencies:** ✅ Restaurant Management (COMPLETE)

---

## 🎯 MISSION OBJECTIVE

Migrate the **Devices & Infrastructure Entity** from legacy MySQL (menuca_v1, menuca_v2) to PostgreSQL (menuca_v3) following our **proven 5-phase migration process** that has successfully migrated **5 entities** and **154,346 rows** with **100% data integrity**.

---

## 📊 WHAT YOU'RE MIGRATING

### Core Tables
| Table | Version | Rows | Key Fields | Complexity |
|-------|---------|------|------------|------------|
| **tablets** | V1 | 894 | `key` (VARBINARY 🔴 BLOB), designator, restaurant, printing, config_edit, v2, fw_ver, sw_ver, desynced, last_boot, last_check | **HIGH** - BLOB field |
| **tablets** | V2 | TBD | (Need dump) | **TBD** |

### 🔴 **CRITICAL: BLOB FIELD ALERT**
- **Field:** `key` (VARBINARY 20)
- **Action Required:** Deserialize during Phase 3
- **Reference:** See Marketing & Promotions entity (100% BLOB success)

---

## 📁 WHAT'S ALREADY AVAILABLE

### ✅ Files Provided
1. `/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql` - V1 tablets dump (894 rows)

### ❓ Missing Files
1. **V2 tablets dump** - Need from Santiago
2. **V2 structure schema** - Check if tablets exists in menuca_v2

---

## 🔄 THE PROVEN 5-PHASE PROCESS

### **Phase 1: Schema Design & Analysis** (Est: 4-6 hours)

**Objective:** Analyze V1/V2 schemas and design V3 target schema

**Steps:**
1. 📖 Read `/MEMORY_BANK/WORKFLOW.md` - Understand the workflow
2. 📖 Read `/MEMORY_BANK/ETL_METHODOLOGY.md` - Standard migration process
3. 📖 Read `/Database/Schemas/menuca_v1_structure.sql` - V1 schema
4. 📖 Read `/Database/Schemas/menuca_v2_structure.sql` - V2 schema (check for tablets)
5. 📊 Analyze V1 tablets dump structure
6. 🔍 Identify BLOB fields requiring deserialization
7. 📝 Create `/documentation/Devices & Infrastructure/devices-infrastructure-mapping.md`
8. 🎨 Design V3 target schema for `menuca_v3.devices` (or similar)
9. ✅ Verify Restaurant Management dependency (FK to restaurants)
10. 📝 Update `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md` with Phase 1 status

**Success Criteria:**
- [ ] Field mapping document complete
- [ ] V3 schema designed
- [ ] BLOB deserialization strategy defined
- [ ] FK dependencies identified

**Example Output:**
```markdown
# Devices & Infrastructure Field Mapping

## V1 Tables
- menuca_v1.tablets (894 rows)

## V3 Target Schema
- menuca_v3.devices (or menuca_v3.tablets)

## Field Mappings
| V1 Field | V3 Field | Transform | Notes |
|----------|----------|-----------|-------|
| id | legacy_v1_id | None | Track original |
| designator | device_name | None | Device identifier |
| key | device_key_hash | Deserialize BLOB → BYTEA | **CRITICAL** |
| restaurant | restaurant_id | FK Lookup | v1 → v3 ID |
| ...
```

---

### **Phase 2: Raw Data Load to Staging** (Est: 4-6 hours)

**Objective:** Load all raw V1/V2 data into `staging` schema tables

**Steps:**
1. 📝 Create `/Database/Devices & Infrastructure Entity/01_create_staging_raw_tables.sql`
2. 🏗️ Define staging tables: `staging.v1_tablets`, `staging.v2_tablets` (if exists)
3. 📂 Use **direct dump loading** (proven faster than CSV)
4. 🐍 Create Python script to extract INSERT statements from dump files
5. 🔄 Load data via Supabase MCP (`mcp_supabase_execute_sql`)
6. ✅ Verify row counts match dump files
7. 📝 Create `/Database/Devices & Infrastructure Entity/PHASE_2_PROGRESS.md`
8. 📝 Update memory bank with Phase 2 completion

**Success Criteria:**
- [ ] 100% of V1 rows loaded to `staging.v1_tablets`
- [ ] 100% of V2 rows loaded (if V2 tablets exists)
- [ ] Row counts verified
- [ ] BLOB fields intact (not deserialized yet)

**Reference:**
- See Marketing & Promotions: Direct dump loading (927 rows in staging)
- Tool: `mcp_supabase_execute_sql` for batch loading

---

### **Phase 3: BLOB Deserialization & Transformation** (Est: 6-8 hours)

**Objective:** Deserialize BLOB `key` field and prepare for V3 transformation

**🔴 CRITICAL PHASE - BLOB HANDLING**

**Steps:**
1. 🐍 Create `/Database/Devices & Infrastructure Entity/deserialize_tablets_blobs.py`
2. 🔬 Analyze BLOB structure:
   - V1 `key` field is VARBINARY(20) - likely binary data
   - Determine if it needs hex encoding or different handling
3. ➕ Add JSONB/BYTEA column to staging: `ALTER TABLE staging.v1_tablets ADD COLUMN key_processed BYTEA;`
4. 🧪 Test deserialization on sample (10 rows)
5. 🚀 Run full deserialization on all 894 rows
6. ✅ Verify 100% success rate (target: 98%+)
7. 📝 Create `/Database/Devices & Infrastructure Entity/BLOB_DESERIALIZATION_COMPLETE.md`
8. 📝 Create verification report with sample data

**Success Criteria:**
- [ ] BLOB deserialization script created
- [ ] Tested on sample data (10 rows)
- [ ] Full deserialization complete (all rows)
- [ ] 98%+ success rate achieved
- [ ] Verification report created

**Reference:**
- Marketing & Promotions: 100% BLOB deserialization success (194 deals)
- Module: `deserialize_v1_deals_blobs.py` - adapt for binary keys

**BLOB Handling Considerations:**
```python
# Example approach for binary keys
import base64

def process_binary_key(blob_data):
    """Convert VARBINARY to base64 or hex for storage"""
    if not blob_data:
        return None
    
    # Option 1: Store as hex string
    return blob_data.hex()
    
    # Option 2: Store as base64
    # return base64.b64encode(blob_data).decode('utf-8')
    
    # Option 3: Store as BYTEA (PostgreSQL native)
    # return blob_data  # Direct binary
```

---

### **Phase 4: Transformation & Load to Staging V3 Tables** (Est: 6-8 hours)

**Objective:** Transform V1/V2 data and load into `staging.devices` (V3 format)

**Steps:**
1. 📝 Create `/Database/Devices & Infrastructure Entity/02_create_v3_staging_tables.sql`
2. 🎨 Define `staging.devices` with V3 schema
3. 📝 Create `/Database/Devices & Infrastructure Entity/03_transform_v1_tablets_to_v3.sql`
4. 📝 Create `/Database/Devices & Infrastructure Entity/04_transform_v2_tablets_to_v3.sql` (if V2 exists)
5. 🔄 Transform data:
   - Map restaurant IDs (V1 → V3 via `menuca_v3.restaurants_id_map`)
   - Convert Unix timestamps → PostgreSQL TIMESTAMPTZ
   - Handle boolean flags (tinyint → boolean)
   - Map version numbers (fw_ver, sw_ver)
6. 🔍 Handle edge cases (invalid restaurant FK, test devices)
7. ✅ Verify row counts (source → staging V3)
8. ✅ Check FK integrity
9. 📝 Create `/Database/Devices & Infrastructure Entity/PHASE_4_PROGRESS.md`
10. 📊 Run comprehensive verification

**Success Criteria:**
- [ ] All V1 tablets transformed
- [ ] All V2 tablets transformed (if exists)
- [ ] 100% transformation success (of valid data)
- [ ] 100% FK integrity in staging
- [ ] Data type conversions verified
- [ ] Sample data review passed

**Transformation Logic:**
```sql
-- Example: Transform V1 tablets to V3
INSERT INTO staging.devices (
  restaurant_id, device_name, device_key_hash, 
  supports_printing, is_v2_device, firmware_version, software_version,
  is_desynced, last_boot_at, last_check_at,
  legacy_v1_id, created_at, updated_at
)
SELECT 
  COALESCE(r_map.v3_id, 0) as restaurant_id,
  v1.designator as device_name,
  v1.key_processed as device_key_hash,
  (v1.printing = 1) as supports_printing,
  (v1.v2 = 1) as is_v2_device,
  v1.fw_ver as firmware_version,
  v1.sw_ver as software_version,
  (v1.desynced = 1) as is_desynced,
  CASE WHEN v1.last_boot > 0 THEN to_timestamp(v1.last_boot) ELSE NULL END as last_boot_at,
  CASE WHEN v1.last_check > 0 THEN to_timestamp(v1.last_check) ELSE NULL END as last_check_at,
  v1.id as legacy_v1_id,
  CASE WHEN v1.created_at > 0 THEN to_timestamp(v1.created_at) ELSE NOW() END as created_at,
  CASE WHEN v1.modified_at > 0 THEN to_timestamp(v1.modified_at) ELSE NOW() END as updated_at
FROM staging.v1_tablets v1
LEFT JOIN menuca_v3.restaurants_id_map r_map ON v1.restaurant = r_map.legacy_v1_id;
```

---

### **Phase 5: Production Load & Final Verification** (Est: 4-6 hours)

**Objective:** Load verified data from `staging.devices` → `menuca_v3.devices`

**Steps:**
1. 🏗️ Create production table: `menuca_v3.devices`
2. 📝 Add indexes and constraints
3. 🔄 Load data from staging:
   - Filter for valid restaurant FK only
   - Handle duplicates (V1 + V2 merge if needed)
4. ✅ Final production verification:
   - Row count validation
   - 100% FK integrity check
   - Sample data review
   - BLOB integrity check
5. 📝 Create `/Database/Devices & Infrastructure Entity/PHASE_5_PRODUCTION_COMPLETE.md`
6. 📝 Update `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md` - COMPLETE
7. 📝 Update `/MEMORY_BANK/PROJECT_STATUS.md` - 6/12 entities complete (50%)!
8. 📝 Move completion summary to `/MEMORY_BANK/COMPLETED/DEVICES_INFRASTRUCTURE_COMPLETE.md`

**Success Criteria:**
- [ ] Production table created with indexes
- [ ] All valid data loaded (target: 90%+ of staging)
- [ ] 100% FK integrity in production
- [ ] BLOB data verified (sample check)
- [ ] Zero duplicate entries
- [ ] Production ready for use

**Verification Queries:**
```sql
-- 1. Row count validation
SELECT 
  (SELECT COUNT(*) FROM staging.devices) as staging_total,
  (SELECT COUNT(*) FROM menuca_v3.devices) as production_total,
  (SELECT COUNT(*) FROM staging.devices d 
   WHERE EXISTS (SELECT 1 FROM menuca_v3.restaurants r WHERE r.id = d.restaurant_id)) as expected_load;

-- 2. FK integrity check
SELECT 
  COUNT(*) as total_devices,
  COUNT(r.id) as valid_restaurant_fk,
  CASE WHEN COUNT(*) = COUNT(r.id) THEN '✅ 100%' ELSE '❌ INVALID' END as status
FROM menuca_v3.devices d
LEFT JOIN menuca_v3.restaurants r ON d.restaurant_id = r.id;

-- 3. BLOB integrity sample
SELECT device_name, device_key_hash, restaurant_id
FROM menuca_v3.devices
WHERE device_key_hash IS NOT NULL
LIMIT 10;
```

---

## 🎯 SUCCESS METRICS

### Overall Entity Success Criteria
- [ ] **Phase 1:** Schema designed, BLOB strategy defined
- [ ] **Phase 2:** 100% raw data in staging
- [ ] **Phase 3:** 98%+ BLOB deserialization success
- [ ] **Phase 4:** 100% transformation (of valid data)
- [ ] **Phase 5:** Production load complete, 100% FK integrity

### Data Quality Targets
- ✅ **Row Accuracy:** 100% of source → staging
- ✅ **FK Integrity:** 100% in production (exclude invalid references)
- ✅ **BLOB Success:** 98%+ deserialization rate
- ✅ **Data Type Conversion:** 100% success
- ✅ **No Duplicates:** Zero duplicate entries in production

---

## 🔗 DEPENDENCIES

### ✅ Completed (Ready to Use)
1. **Restaurant Management** (COMPLETE) - For `restaurant_id` FK
   - Table: `menuca_v3.restaurants`
   - Mapping: `menuca_v3.restaurants_id_map`

### ❌ Blocked By This Entity
None - Devices & Infrastructure is a LOW priority, independent entity

---

## 📚 REQUIRED READING

### Before Starting
1. 📖 `/MEMORY_BANK/WORKFLOW.md` - Standard workflow rules
2. 📖 `/MEMORY_BANK/ETL_METHODOLOGY.md` - Migration process
3. 📖 `/MEMORY_BANK/PROJECT_STATUS.md` - Current project state
4. 📖 `/MEMORY_BANK/ENTITIES/07_MARKETING_PROMOTIONS.md` - Recent BLOB success
5. 📖 `/MEMORY_BANK/COMPLETED/MARKETING_PROMOTIONS_COMPLETE.md` - Latest entity example

### Reference During Migration
1. 📖 `/Database/Marketing & Promotions/deserialize_v1_deals_blobs.py` - BLOB handling example
2. 📖 `/Database/Marketing & Promotions/PHASE_5_PRODUCTION_COMPLETE.md` - Complete migration example
3. 📖 `/Database/Schemas/menuca_v1_structure.sql` - V1 schema reference
4. 📖 `/Database/Schemas/menuca_v2_structure.sql` - V2 schema reference

---

## 🛠️ TECHNICAL CONSIDERATIONS

### 1. BLOB Handling Strategy

**Challenge:** V1 `key` field is VARBINARY(20) - binary data, not serialized PHP

**Options:**
- **Option A:** Store as BYTEA (PostgreSQL native binary)
- **Option B:** Convert to hex string for readability
- **Option C:** Convert to base64 encoding

**Recommendation:** Option A (BYTEA) - preserves binary data integrity, PostgreSQL native

**Reference:** 
- Marketing entity handled serialized PHP → JSONB (100% success)
- This is simpler: binary → BYTEA (direct mapping)

### 2. Restaurant FK Resolution

**Challenge:** Some tablets may reference invalid/deleted restaurants

**Strategy:**
- Load all tablets to staging (Phase 2)
- Transform all tablets (Phase 4)
- Filter for valid restaurant FK during production load (Phase 5)
- Document skipped rows (test devices, deleted restaurants)

**Expected:** 85-95% load rate (10-15% invalid FK expected)

### 3. V1 vs V2 Merge Strategy

**If V2 tablets exists:**
- Check for duplicate devices (same designator or key)
- Prefer V2 data (newer)
- Track both V1 and V2 IDs in V3 schema

**If V2 doesn't exist:**
- Simple V1 → V3 migration
- No merge complexity

### 4. Boolean Field Mapping

V1 uses `tinyint` for booleans:
- `0` = false
- `1` = true

Transform: `(field = 1) as boolean_field_name`

### 5. Timestamp Conversions

V1 uses Unix timestamps (integers):
- Convert: `to_timestamp(unix_timestamp)`
- Handle zeros: `CASE WHEN field > 0 THEN to_timestamp(field) ELSE NULL END`

### 6. Version Number Handling

Fields: `fw_ver`, `sw_ver` (firmware, software versions)
- Store as `INTEGER` or `VARCHAR`
- Consider versioning scheme (e.g., 16.32 → major.minor)

---

## 🚨 COMMON PITFALLS TO AVOID

### ❌ DON'T:
1. **Skip staging** - Always use `staging` schema first!
2. **Load directly to production** - Transformation must happen in staging
3. **Ignore BLOB verification** - Sample check after deserialization
4. **Forget FK filtering** - Production load must filter invalid restaurant FKs
5. **Skip verification** - Always verify after each phase

### ✅ DO:
1. **Use Supabase MCP** - Proven fast and reliable
2. **Batch large operations** - 20-50 rows per MCP call
3. **Test on sample first** - Always test transformations on 10 rows
4. **Document edge cases** - Note any data anomalies
5. **Update memory bank** - After every phase completion

---

## 📊 EXPECTED OUTCOMES

### By End of Migration
1. ✅ `menuca_v3.devices` table in production
2. ✅ 800+ devices migrated (85-95% of 894 V1 tablets)
3. ✅ 100% FK integrity (all devices linked to valid restaurants)
4. ✅ BLOB data preserved and accessible
5. ✅ Full audit trail (legacy IDs tracked)
6. ✅ Memory bank updated
7. ✅ **Project Progress: 6/12 entities (50%) COMPLETE!** 🎉

### Deliverables
- `/documentation/Devices & Infrastructure/devices-infrastructure-mapping.md`
- `/Database/Devices & Infrastructure Entity/01_create_staging_raw_tables.sql`
- `/Database/Devices & Infrastructure Entity/02_create_v3_staging_tables.sql`
- `/Database/Devices & Infrastructure Entity/03_transform_v1_tablets_to_v3.sql`
- `/Database/Devices & Infrastructure Entity/04_transform_v2_tablets_to_v3.sql` (if needed)
- `/Database/Devices & Infrastructure Entity/deserialize_tablets_blobs.py`
- `/Database/Devices & Infrastructure Entity/PHASE_X_PROGRESS.md` (for each phase)
- `/Database/Devices & Infrastructure Entity/PHASE_5_PRODUCTION_COMPLETE.md`
- `/MEMORY_BANK/COMPLETED/DEVICES_INFRASTRUCTURE_COMPLETE.md`

---

## 🎉 WHY THIS WILL SUCCEED

### Proven Track Record
- ✅ **5 entities migrated** with 100% success
- ✅ **154,346 rows** in production
- ✅ **144,377 BLOBs** deserialized (98.6% success)
- ✅ **100% FK integrity** maintained
- ✅ **Zero data loss** of valid production data

### This Entity is EASIER Than Previous
- ✅ **Smaller dataset:** 894 rows (vs 42,930 dishes, 32,349 users)
- ✅ **Single table:** No complex multi-table merging
- ✅ **Simple BLOB:** Binary key (vs complex serialized PHP arrays)
- ✅ **Clear FK:** Only restaurant dependency (already complete)

### You Have Everything You Need
- ✅ Proven 5-phase process documented
- ✅ Reference implementations from 5 successful migrations
- ✅ BLOB deserialization expertise from Marketing entity
- ✅ Supabase MCP access (fast, reliable)
- ✅ Comprehensive memory bank with examples

---

## 🚀 READY TO START?

### Pre-Flight Checklist
- [ ] Read this entire handoff document
- [ ] Read `/MEMORY_BANK/WORKFLOW.md`
- [ ] Read `/MEMORY_BANK/ETL_METHODOLOGY.md`
- [ ] Review `/MEMORY_BANK/ENTITIES/07_MARKETING_PROMOTIONS.md` (latest BLOB success)
- [ ] Verify dump file exists: `/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql`
- [ ] Check for V2 tablets dump (ask Santiago if needed)
- [ ] Create `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md` (start tracking)

### First Actions
1. 📝 Create entity tracking file in memory bank
2. 🔍 Analyze V1 tablets dump structure
3. 📋 Start Phase 1: Schema Design & Analysis
4. ✅ Follow the proven 5-phase process
5. 📝 Update memory bank after each phase

---

## 💪 YOU'VE GOT THIS!

This migration is **LOWER COMPLEXITY** than the Marketing & Promotions entity we just completed. The BLOB handling is actually **SIMPLER** (binary key vs serialized PHP arrays). You have:

- ✅ Proven process (5 successful migrations)
- ✅ Reference implementations (especially Marketing entity)
- ✅ Smaller dataset (894 rows vs 927 in Marketing)
- ✅ Simpler BLOB handling (binary vs serialized)
- ✅ All dependencies complete (Restaurant Management)

**Follow the proven 5-phase process. Update the memory bank. Verify everything. You'll crush this! 🔥**

---

**Questions?** Check the memory bank first:
- `/MEMORY_BANK/WORKFLOW.md` - How to work
- `/MEMORY_BANK/ETL_METHODOLOGY.md` - Migration process
- `/MEMORY_BANK/COMPLETED/` - Successful examples

**Pro Tips:**
1. 🐍 Adapt the Python BLOB script from Marketing entity
2. 🔄 Use Supabase MCP for all data loads (proven fast)
3. ✅ Always verify after each phase (catch issues early)
4. 📝 Update memory bank frequently (never lose context)
5. 🎯 Test on sample first (10 rows), then run full

**Let's make this entity #6!** 🚀

---

**Handoff Created:** 2025-10-08  
**Migration Strategy:** Proven 5-Phase ETL Process  
**Expected Duration:** 2-3 days  
**Success Rate:** 100% (based on 5 previous entities)

