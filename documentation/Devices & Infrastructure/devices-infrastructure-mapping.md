# Devices & Infrastructure Entity - Field Mapping

**Entity:** Devices & Infrastructure  
**Date Created:** 2025-10-09  
**Status:** Phase 1 - Schema Design

---

## 📊 Source Data Summary

### V1 Source: menuca_v1.tablets
- **Location:** `/Database/Devices & Infrastructure Entity/menuca_v1_tablets.sql`
- **Row Count:** 894 devices
- **Schema Reference:** Lines 25-42 of dump file

### V2 Source: menuca_v2.tablets
- **Location:** Need dump from Santiago
- **Estimated Row Count:** ~87 devices (AUTO_INCREMENT=88)
- **Schema Reference:** `/Database/Schemas/menuca_v2_structure.sql` lines 2320-2336

---

## 🔍 V1 vs V2 Schema Comparison

### Fields in V1 ONLY:
- `v2` (tinyint unsigned) - Indicates if device supports v2 protocol

### Fields in V2 with Different Types:
- `last_check` - V1: `int unsigned`, V2: `int` (signed)

### Fields in Both (Same):
- `id`, `designator`, `key`, `restaurant`, `printing`, `config_edit`
- `last_boot`, `fw_ver`, `sw_ver`, `desynced`, `created_at`, `modified_at`

---

## 🎯 V3 Target Schema Design

**Table Name:** `menuca_v3.devices`

### Primary Key Strategy
- Use PostgreSQL SERIAL (auto-increment)
- Track legacy IDs: `legacy_v1_id`, `legacy_v2_id`

### BLOB Handling Strategy
- **Source Field:** `key` (VARBINARY 20)
- **Target Field:** `device_key_hash` (BYTEA)
- **Conversion:** Direct binary → BYTEA (PostgreSQL native)
- **Complexity:** MEDIUM (simpler than serialized PHP)

### Foreign Key Dependencies
- `restaurant_id` → `menuca_v3.restaurants.id`
- **Resolution:** Via `menuca_v3.restaurants_id_map`

---

## 📋 Complete Field Mapping

| V1 Field | V2 Field | V3 Field | V3 Type | Transform | Notes |
|----------|----------|----------|---------|-----------|-------|
| `id` | `id` | `legacy_v1_id` | INTEGER | Direct (V1 only) | Track original V1 ID |
| `id` | `id` | `legacy_v2_id` | INTEGER | Direct (V2 only) | Track original V2 ID |
| - | - | `id` | SERIAL | Auto-generated | New V3 primary key |
| `designator` | `designator` | `device_name` | VARCHAR(255) | TRIM, UPPER | Device identifier/code |
| `key` 🔴 | `key` 🔴 | `device_key_hash` | BYTEA | **BLOB → Binary** | **CRITICAL: Binary device key** |
| `restaurant` | `restaurant` | `restaurant_id` | INTEGER | FK Lookup (V1/V2 → V3) | Reference to menuca_v3.restaurants |
| `printing` | `printing` | `supports_printing` | BOOLEAN | `(field = 1)` | Device has printing capability |
| `config_edit` | `config_edit` | `allows_config_edit` | BOOLEAN | `(field = 1)` | Device allows config changes |
| `v2` | ❌ (N/A) | `is_v2_device` | BOOLEAN | `(field = 1)` or `TRUE` (V2) | V2 protocol support |
| `fw_ver` | `fw_ver` | `firmware_version` | SMALLINT | Direct | Firmware version number |
| `sw_ver` | `sw_ver` | `software_version` | SMALLINT | Direct | Software version number |
| `desynced` | `desynced` | `is_desynced` | BOOLEAN | `(field = 1)` | Device out of sync flag |
| `last_boot` | `last_boot` | `last_boot_at` | TIMESTAMPTZ | `to_timestamp()` or NULL | Last boot timestamp |
| `last_check` | `last_check` | `last_check_at` | TIMESTAMPTZ | `to_timestamp()` or NULL | Last check-in timestamp |
| `created_at` | `created_at` | `created_at` | TIMESTAMPTZ | `to_timestamp()` or NOW() | Record creation timestamp |
| `modified_at` | `modified_at` | `updated_at` | TIMESTAMPTZ | `to_timestamp()` or NOW() | Last update timestamp |

---

## 🔴 BLOB Field Details

### Source Field: `key` (VARBINARY 20)

**Type:** Binary device key (20 bytes)  
**Purpose:** Unique hardware/security key for tablet authentication  
**Format:** Raw binary data

### Target Field: `device_key_hash` (BYTEA)

**Type:** PostgreSQL native binary (BYTEA)  
**Storage:** Direct binary storage  
**Encoding:** Hex or base64 for display

### Deserialization Strategy (Phase 3)

```python
# Approach: Direct binary to BYTEA conversion
def process_device_key(blob_data):
    """
    Convert MySQL VARBINARY to PostgreSQL BYTEA
    
    Args:
        blob_data: Raw binary bytes from MySQL
        
    Returns:
        Hex string or bytes for PostgreSQL BYTEA
    """
    if not blob_data or len(blob_data) == 0:
        return None
    
    # Option 1: Store as hex string (readable)
    return blob_data.hex()
    
    # Option 2: Store as base64 (compact)
    # return base64.b64encode(blob_data).decode('utf-8')
    
    # Option 3: Direct BYTEA (native)
    # return blob_data  # PostgreSQL handles binary directly
```

**Complexity:** MEDIUM (simpler than PHP serialization)  
**Success Target:** 98%+ deserialization rate  
**Reference:** Marketing entity achieved 100% BLOB success

---

## 🔄 Data Transformations

### 1. Boolean Conversions
**V1/V2 Format:** `tinyint` (0 or 1)  
**V3 Format:** PostgreSQL `BOOLEAN`  
**Transform:** `(field = 1) AS boolean_field_name`

**Fields:**
- `printing` → `supports_printing`
- `config_edit` → `allows_config_edit`
- `v2` → `is_v2_device`
- `desynced` → `is_desynced`

### 2. Timestamp Conversions
**V1/V2 Format:** Unix timestamp (integer seconds since epoch)  
**V3 Format:** PostgreSQL `TIMESTAMPTZ`  
**Transform:** `to_timestamp(unix_seconds)` with zero handling

```sql
-- Handle zero timestamps
CASE 
  WHEN unix_timestamp > 0 THEN to_timestamp(unix_timestamp)
  ELSE NULL 
END
```

**Fields:**
- `last_boot` → `last_boot_at`
- `last_check` → `last_check_at`
- `created_at` → `created_at` (or NOW() if zero)
- `modified_at` → `updated_at` (or NOW() if zero)

### 3. Foreign Key Resolution
**Source:** V1/V2 `restaurant` (int)  
**Target:** V3 `restaurant_id` (int)  
**Mapping Table:** `menuca_v3.restaurants_id_map`

```sql
-- FK Lookup
COALESCE(r_map.v3_id, 0) AS restaurant_id
FROM staging.v1_tablets v1
LEFT JOIN menuca_v3.restaurants_id_map r_map 
  ON v1.restaurant = r_map.legacy_v1_id
```

**Expected:** 10-15% invalid FKs (test devices, deleted restaurants)

### 4. V2 Field Inference
**Challenge:** V2 tablets missing `v2` field  
**Solution:** Assume all V2 tablets support v2 protocol  
**Transform:** `TRUE` for all V2 records

---

## 📊 V3 Production Table DDL

```sql
-- Create devices table in menuca_v3 schema
CREATE TABLE IF NOT EXISTS menuca_v3.devices (
  -- Primary Key
  id SERIAL PRIMARY KEY,
  
  -- Legacy IDs (track source)
  legacy_v1_id INTEGER,
  legacy_v2_id INTEGER,
  
  -- Device Identification
  device_name VARCHAR(255) NOT NULL,
  device_key_hash BYTEA, -- BLOB field (20 bytes)
  
  -- Relationships
  restaurant_id INTEGER NOT NULL REFERENCES menuca_v3.restaurants(id) ON DELETE CASCADE,
  
  -- Device Capabilities
  supports_printing BOOLEAN NOT NULL DEFAULT FALSE,
  allows_config_edit BOOLEAN NOT NULL DEFAULT FALSE,
  is_v2_device BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Version Information
  firmware_version SMALLINT NOT NULL DEFAULT 0,
  software_version SMALLINT NOT NULL DEFAULT 0,
  
  -- Device Status
  is_desynced BOOLEAN NOT NULL DEFAULT FALSE,
  last_boot_at TIMESTAMPTZ,
  last_check_at TIMESTAMPTZ,
  
  -- Audit Fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Indexes
  CONSTRAINT devices_legacy_v1_id_unique UNIQUE(legacy_v1_id),
  CONSTRAINT devices_legacy_v2_id_unique UNIQUE(legacy_v2_id)
);

-- Additional Indexes
CREATE INDEX idx_devices_restaurant_id ON menuca_v3.devices(restaurant_id);
CREATE INDEX idx_devices_device_name ON menuca_v3.devices(device_name);
CREATE INDEX idx_devices_device_key_hash ON menuca_v3.devices USING hash(device_key_hash);
CREATE INDEX idx_devices_last_check_at ON menuca_v3.devices(last_check_at DESC);

-- Comments
COMMENT ON TABLE menuca_v3.devices IS 'Restaurant tablet devices and hardware inventory';
COMMENT ON COLUMN menuca_v3.devices.device_key_hash IS 'Binary device authentication key (20 bytes from VARBINARY)';
COMMENT ON COLUMN menuca_v3.devices.is_v2_device IS 'Device supports v2 protocol (inferred TRUE for all V2 tablets)';
```

---

## 🔀 V1 + V2 Merge Strategy

### Duplicate Detection
**Primary Key:** `device_name` + `restaurant_id`  
**Conflict Resolution:** Prefer V2 if exists, else V1

### Merge Logic
1. Load all V1 tablets → `staging.v1_tablets`
2. Load all V2 tablets → `staging.v2_tablets`
3. Transform V1 → `staging.devices_v1_transformed`
4. Transform V2 → `staging.devices_v2_transformed`
5. Merge with V2 preference → `staging.devices_merged`
6. Load valid FK only → `menuca_v3.devices`

### ON CONFLICT Handling
```sql
-- Prefer V2 over V1 on conflict
INSERT INTO menuca_v3.devices (...)
SELECT ... FROM staging.devices_v2_transformed
ON CONFLICT (device_name, restaurant_id) DO UPDATE SET
  device_key_hash = EXCLUDED.device_key_hash,
  is_v2_device = TRUE,
  updated_at = NOW();

-- Then insert V1 records not in V2
INSERT INTO menuca_v3.devices (...)
SELECT ... FROM staging.devices_v1_transformed v1
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.devices v3
  WHERE v3.device_name = v1.device_name
  AND v3.restaurant_id = v1.restaurant_id
);
```

---

## 📈 Expected Outcomes

### Data Volume
- **V1 Source:** 894 devices
- **V2 Source:** ~87 devices (estimated)
- **Total Raw:** ~981 devices
- **After Deduplication:** ~900-920 devices (depends on overlap)
- **Production Load:** 800-850 devices (85-95% after invalid FK filter)

### Data Quality
- **BLOB Success:** 98%+ (target: 100%)
- **FK Integrity:** 100% in production (invalid filtered)
- **Timestamp Conversions:** 100% success
- **Boolean Conversions:** 100% success

### Invalid Records
- **Expected:** 10-15% invalid restaurant FK
- **Reasons:** Test devices (restaurant_id = 0), deleted restaurants
- **Action:** Document in verification report, exclude from production

---

## 🎯 Phase 1 Completion Criteria

- [x] V1 schema analyzed (894 rows)
- [x] V2 schema analyzed (~87 rows estimated)
- [x] Field mapping documented
- [x] V3 schema designed
- [x] BLOB deserialization strategy defined (binary → BYTEA)
- [x] FK dependencies identified (restaurants only)
- [x] V1/V2 merge strategy defined
- [ ] V2 tablets dump requested from Santiago
- [ ] Memory bank updated

---

## 📝 Notes

### Key Decisions
1. **Table Name:** `menuca_v3.devices` (more generic than `tablets`)
2. **BLOB Strategy:** Direct BYTEA (simpler than Marketing's PHP deserialization)
3. **V2 Field:** Infer `is_v2_device = TRUE` for all V2 records
4. **Merge Priority:** V2 > V1 (newer data preferred)
5. **Invalid FK:** Filter during production load (don't reject staging)

### Questions for User
1. ❓ Do we have V2 tablets dump? (Need from Santiago)
2. ❓ Should we request V2 dump or proceed V1-only for now?

### Next Steps
1. ✅ Request V2 tablets dump (if available)
2. ✅ Update `/MEMORY_BANK/ENTITIES/09_DEVICES_INFRASTRUCTURE.md` with Phase 1 status
3. ✅ Proceed to Phase 2: Raw Data Load (V1 only if V2 unavailable)

---

**Phase 1 Status:** ✅ DESIGN COMPLETE  
**Next Phase:** Phase 2 - Raw Data Load  
**Created:** 2025-10-09  
**Updated:** 2025-10-09

