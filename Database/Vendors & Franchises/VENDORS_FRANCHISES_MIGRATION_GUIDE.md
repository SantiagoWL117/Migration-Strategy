# Vendors & Franchises - Migration Analysis & Strategy

**Entity**: Vendors & Franchises  
**Date**: January 10, 2025  
**Status**: 🔍 **ANALYSIS PHASE - REQUIRES BUSINESS REVIEW**

---

## ⚠️ CRITICAL: Migration Decision Required

This entity requires **business decision** before migration. Key questions:

1. **Is the vendor/franchise model still active?**
   - Last activity: January 2024 (vendor_reports)
   - Are menu.ca and MenuOttawa still operating as vendors?
   
2. **Is commission splitting still in use?**
   - Only 2 split templates exist
   - Only 19 restaurants using splits
   
3. **Are vendor reports still being generated?**
   - System generates financial reports with JSON data
   - File generation system present

**Recommendation**: **PAUSE migration until business confirms requirements**

---

## Executive Summary

### Data Overview

| Table | V1 | V2 | Total Rows | BLOB Columns | Status |
|-------|----|----|------------|--------------|--------|
| `vendors` | ✅ | ❌ | 5 | 3 (restaurants, phone, website, contacts) | ⚠️ Complex |
| `vendor_users` | ✅ | ❌ | 3 | 0 | ✅ Simple |
| `vendors_restaurants` | ✅ | ❌ | 587 | 0 | ⚠️ Junction table |
| `vendor_reports` | ❌ | ✅ | 493 | 0 (JSON) | ⚠️ Financial data |
| `vendor_reports_numbers` | ❌ | ✅ | 2 | 0 | ✅ Simple |
| `vendor_splits` | ❌ | ✅ | 19 | 0 | ✅ Simple |
| `vendor_splits_templates` | ❌ | ✅ | 2 | 0 (TEXT) | ⚠️ Code templates |

**Total Records**: ~1,109 rows across 7 tables

---

## Business Context

### What Are Vendors/Franchises?

**Definition**: Third-party companies that manage multiple restaurants under a revenue-sharing model.

**Known Vendors** (from V1 data):
1. **menu.ca** (vendor_id: 1)
   - 39 restaurants
   - Commission: 0% (internal)
   
2. **MenuOttawa** (vendor_id: 2)
   - 249 restaurants
   - Commission: 10%
   - Contacts: Darrell, Matt
   
3. **Test Accounts** (vendor_id: 3)
   - 9 test restaurants
   
4. **MenuOttawa Call Center** (vendor_id: 13)
   - 0 restaurants (empty)
   
5. **as** (vendor_id: 14)
   - 0 restaurants (test/invalid)

### Revenue Sharing Model

**Commission Flow**:
```
Order Total → Restaurant gets base amount
           → Vendor gets commission %
           → MenuOttawa/menu.ca gets platform fee
           → Split calculations via templates
```

**Example** (from `vendor_splits_templates`):
- Template: "percent_commission"
- MenuOttawa Share: 80%
- Commission: 10% of net
- Calculated via PHP code stored in `breakdown` field

---

## Schema Analysis

### V1 Tables (Legacy - 2021 era)

#### 1. `vendors`

**Purpose**: Master vendor/franchise records

**Schema**:
```sql
CREATE TABLE `vendors` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) NOT NULL,
  `restaurants` blob NOT NULL,           -- ⚠️ BLOB: PHP serialized array
  `orderFee` float NOT NULL,
  `address` text NOT NULL,
  `phone` blob NOT NULL,                 -- ⚠️ BLOB: PHP serialized
  `logo` varchar(255) NOT NULL,
  `website` blob NOT NULL,               -- ⚠️ BLOB: PHP serialized
  `contacts` blob NOT NULL,              -- ⚠️ BLOB: PHP serialized
  PRIMARY KEY (`id`)
);
```

**BLOB Structures** (from sample data):

**`restaurants` BLOB**:
```php
a:39:{
  i:0;s:2:"79";
  i:1;s:2:"81";
  ...
}
// PHP array of restaurant IDs
```

**`phone` BLOB**:
```php
a:2:{
  s:3:"url";a:1:{i:0;s:14:"http://menu.ca";}
  s:7:"default";s:1:"0";
}
```

**`website` BLOB**:
```php
a:2:{
  s:3:"url";a:1:{i:0;s:14:"http://menu.ca";}
  s:7:"default";s:1:"0";
}
```

**`contacts` BLOB**:
```php
a:3:{
  s:4:"type";a:1:{i:0;s:1:"0";}
  s:6:"number";a:1:{i:0;s:12:"613-864-2426";}
  s:5:"email";a:1:{i:0;s:13:"chris@menu.ca";}
}
```

**Data Quality Issues**:
- ❌ Duplicated data: `restaurants` BLOB vs `vendors_restaurants` table
- ❌ Inconsistent structure: website stored in `phone` BLOB
- ❌ Empty records: vendors 13 & 14 have no restaurants
- ❌ Test data mixed with production

---

#### 2. `vendor_users`

**Purpose**: Admin users for vendor management

**Schema**:
```sql
CREATE TABLE `vendor_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `fname` varchar(45) NOT NULL,
  `lname` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,        -- ⚠️ SHA1 hash (weak)
  `email` varchar(45) NOT NULL,
  `trelloAddress` varchar(125) NOT NULL,
  `company` varchar(45) NOT NULL,
  `activeUser` enum('1','0') NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
);
```

**Sample Data**:
```
1. Stefan Dragos - stefan@adjump.com - menu.ca
2. Yazdan Rabadi - yazdan.rabadi@menu.ca - Menu.ca
3. Matt Blake - matt@menuottawa.com - Menu Ottawa
```

**Security Issues**:
- ❌ Passwords stored as SHA1 (compromised algorithm)
- ⚠️ Need password reset if migrating these users

---

#### 3. `vendors_restaurants`

**Purpose**: Junction table linking vendors to restaurants

**Schema**:
```sql
CREATE TABLE `vendors_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vendor_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

**Data Quality Issues**:
- ❌ **290 records have `vendor_id = 0`** (orphaned/invalid)
- ❌ **290 records have `restaurant_id = 0`** (orphaned/invalid)
- ✅ **297 valid records** (vendor_id > 0 AND restaurant_id > 0)

**Valid Distribution**:
- Vendor 1 (menu.ca): ~130 restaurants
- Vendor 2 (MenuOttawa): ~360 restaurants
- Vendor 3 (Test): 6 restaurants
- Others: ~10 restaurants

---

### V2 Tables (Current - 2024 era)

#### 4. `vendor_reports`

**Purpose**: Financial reports for vendor payouts

**Schema**:
```sql
CREATE TABLE `vendor_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `result` json DEFAULT NULL,           -- ⚠️ Financial calculation results
  `vendor_id` int DEFAULT NULL,
  `statement_no` tinyint unsigned DEFAULT '1',
  `start` date DEFAULT NULL,
  `stop` date DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

**JSON Structure** (from sample):
```json
{
  "interval": "2024-01-01 - 2024-01-31",
  "useTotal": "2066.55,",
  "forVendor": 63.327500000000015,
  "vendor_id": "2",
  "server_file": "_percent_2024-01-01_2024-01-31.pdf",
  "save_to_file": "_percent",
  "restaurant_id": "1639",
  "restaurant_name": "River Pizza",
  "restaurant_address": "4042 Innes Road"
}
```

**Business Logic**:
- Reports generated monthly
- Calculations based on templates
- PDF files generated and stored
- Last activity: January 2024

**Data Volume**: 493 reports

**🔴 CRITICAL QUESTION**: Are these reports still being generated?

---

#### 5. `vendor_reports_numbers`

**Purpose**: Track statement numbers per vendor/file combination

**Schema**:
```sql
CREATE TABLE `vendor_reports_numbers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `statement_no` tinyint unsigned DEFAULT '1',
  `vendor_id` int DEFAULT NULL,
  `file` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_file` (`vendor_id`,`file`)
);
```

**Sample Data**:
```
(1, 21, 2, '_percent')   -- Statement #21 for vendor 2, _percent template
(2, 21, 65, '_percent')  -- Statement #21 for vendor 65, _percent template
```

**Purpose**: Auto-increment statement numbers for each vendor's report series

**Data Volume**: 2 records

---

#### 6. `vendor_splits`

**Purpose**: Assign split templates to restaurants

**Schema**:
```sql
CREATE TABLE `vendor_splits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id` (`restaurant_id`)
);
```

**Sample Data**:
```
Restaurant 1609 → Template 1 (mazen_milanos)
Restaurants 1634, 1171, 1639... → Template 2 (percent_commission)
```

**Data Volume**: 19 restaurants (out of 944 total)

**Business Question**: Why so few? Is this feature deprecated?

---

#### 7. `vendor_splits_templates`

**Purpose**: Define revenue split calculation formulas

**Schema**:
```sql
CREATE TABLE `vendor_splits_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL,
  `commission_from` char(15) DEFAULT NULL,    -- 'gross' or 'net'
  `menuottawa_share` decimal(5,2) DEFAULT NULL,
  `breakdown` text,                            -- ⚠️ PHP CODE
  `return_info` text,                          -- ⚠️ PHP CODE
  `file` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

**⚠️ CRITICAL: Contains Executable PHP Code**

**Template 1** (mazen_milanos):
```php
// breakdown:
$forVendor = ##total## * .3;
$collection = ##total## * ##restaurant_convenience_fee##;
$forMenuOttawa = ($collection - $forVendor - ##menuottawa_share##) / 2;

// return_info:
vendor_id => ##vendor_id##
restaurant_address => ##restaurant_address##
restaurant_name => ##restaurant_name##
restaurant_id => ##restaurant_id##
restaurant_commission => ##restaurant_commission##,
forVendor => $forVendor
```

**Template 2** (percent_commission):
```php
// breakdown:
$tenPercent = ##total##*(##restaurant_commission## / 100);
$firstSplit = $tenPercent - ##menuottawa_share##;
$forVendor_0= $firstSplit / 2;
$forJames=$forVendor_0 / 2;

// return_info:
vendor_id => ##vendor_id##
restaurant_address => ##restaurant_address##
restaurant_name => ##restaurant_name##
restaurant_id => ##restaurant_id##
useTotal=> ##total##,
forVendor => $forVendor_0
forJames=>$forJames
```

**Security & Maintenance Concerns**:
- 🔴 **Executable code in database** - Extremely dangerous
- 🔴 **No version control** - Hard to audit changes
- 🔴 **Business logic scattered** - Not in application code
- 🔴 **Hard to test** - Template placeholders (`##variable##`)

**Data Volume**: 2 templates

---

## Migration Challenges

### 🔴 Critical Issues

1. **Business Model Uncertainty**
   - Is vendor/franchise model still active?
   - Last reports: January 2024
   - Only 19 restaurants using splits (2% of total)
   - Need business confirmation before proceeding

2. **Executable Code in Database**
   - PHP code stored in `vendor_splits_templates`
   - Security risk, maintenance nightmare
   - Should be refactored to application logic

3. **Data Duplication**
   - `vendors.restaurants` BLOB vs `vendors_restaurants` table
   - Which is source of truth?

4. **Data Quality**
   - 290 orphaned records in `vendors_restaurants`
   - Empty/test vendors (IDs 13, 14)
   - Weak password hashes (SHA1)

5. **Financial Data Complexity**
   - 493 reports with JSON calculations
   - PDF files generated (storage location unknown)
   - Commission calculations via templates

### ⚠️ Medium Issues

6. **BLOB Deserialization**
   - 3 BLOB columns in `vendors` table
   - PHP serialized data (similar to Menu & Catalog entity)
   - Need PHP script to deserialize

7. **Schema Mismatch**
   - V1 has `vendors`, `vendor_users`, `vendors_restaurants`
   - V2 has `vendor_reports`, `vendor_reports_numbers`, `vendor_splits`, `vendor_splits_templates`
   - **No overlap** - completely different concerns

8. **FK Integrity Unknown**
   - Does V3 schema have vendor tables?
   - Need to check if vendors exist in current system

---

## V3 Schema Status

### 🔍 Need to Verify

**Questions**:
1. Does `menuca_v3` schema include vendor tables?
2. Are vendors represented differently in V3?
3. Is the franchise model still in use?

**Action Required**: Check V3 schema for vendor-related tables

---

## Migration Options

### Option A: Full Migration (if vendor model active)

**Scope**: Migrate all vendor data and functionality

**Tables to Create**:
```sql
-- Core vendor data
menuca_v3.vendors
menuca_v3.vendor_users
menuca_v3.vendor_restaurant_assignments

-- Financial reporting
menuca_v3.vendor_reports
menuca_v3.vendor_report_statements

-- Commission splits (REFACTORED)
menuca_v3.vendor_commission_rules
menuca_v3.vendor_commission_calculations
```

**Estimated Effort**: 40-60 hours
- BLOB deserialization: 8 hours
- Schema design: 8 hours
- Data transformation: 16 hours
- Code refactoring (templates → logic): 20 hours
- Testing & validation: 8 hours

**Risks**: HIGH
- Business logic unclear
- Executable code in database
- Financial calculations sensitive

---

### Option B: Archive-Only (if vendor model deprecated)

**Scope**: Preserve historical data without active functionality

**Approach**:
1. Create archive tables in V3
2. Load historical data as-is
3. No active features or calculations
4. Read-only access for historical reports

**Tables to Create**:
```sql
menuca_v3.vendors_archive
menuca_v3.vendor_reports_archive
menuca_v3.vendor_splits_archive
```

**Estimated Effort**: 8-16 hours
- Schema creation: 2 hours
- Data load: 4 hours
- BLOB deserialization: 4 hours
- Validation: 4 hours

**Risks**: LOW
- No business logic required
- No active calculations
- Simple data preservation

---

### Option C: No Migration (if fully deprecated)

**Scope**: Keep vendor data in legacy systems only

**Approach**:
1. Document vendor model for historical reference
2. Keep V1/V2 dumps as backup
3. No V3 tables created
4. Access via legacy database if needed

**Estimated Effort**: 2 hours
- Documentation: 2 hours

**Risks**: NONE
- No migration effort
- Legacy data preserved

---

## Recommended Approach

### 🎯 STEP-BY-STEP STRATEGY

**Step 1: Business Discovery** (1-2 hours)
- [ ] Interview stakeholders
- [ ] Questions to ask:
  - Is menu.ca still operating as a vendor?
  - Is MenuOttawa still a franchise?
  - Are commission splits still calculated?
  - Are vendor reports still generated?
  - When was the last vendor payout?
  - Are new vendors being onboarded?

**Step 2: V3 Schema Audit** (30 minutes)
- [ ] Check if vendor tables exist in V3
- [ ] Check if restaurants have vendor_id FK
- [ ] Check if commission calculations exist

**Step 3: Decision Gate**

**IF Active → Option A** (Full Migration)
- Proceed with full schema design
- Refactor templates to application code
- Migrate all data

**IF Deprecated (< 6 months) → Option B** (Archive)
- Create archive tables
- Load historical data
- No active features

**IF Fully Deprecated (> 6 months) → Option C** (No Migration)
- Document and archive
- No V3 tables

**Step 4: Execution** (based on option chosen)

---

## Data Quality Assessment

### Records by Quality

| Category | Count | % | Action |
|----------|-------|---|--------|
| **V1 vendors** | | | |
| Valid vendors | 3 | 60% | Migrate if active |
| Test/empty vendors | 2 | 40% | Exclude |
| **vendor_users** | | | |
| Valid users | 3 | 100% | Migrate (reset passwords) |
| **vendors_restaurants** | | | |
| Valid links | 297 | 51% | Migrate |
| Orphaned (vendor_id=0) | 290 | 49% | Exclude |
| **V2 vendor_reports** | | | |
| Valid reports | 493 | 100% | Archive or migrate |
| **vendor_splits** | | | |
| Active splits | 19 | 2% of restaurants | Migrate if active |

### BLOB Columns to Deserialize

| Table | Column | Records | Complexity |
|-------|--------|---------|------------|
| vendors | restaurants | 3 | LOW (array of IDs) |
| vendors | phone | 3 | MEDIUM (nested structure) |
| vendors | website | 3 | MEDIUM (nested structure) |
| vendors | contacts | 3 | MEDIUM (nested structure) |

**Total BLOB cells**: 12 (manageable volume)

---

## Migration Scripts Needed

### If Proceeding with Migration

**PHP Scripts** (BLOB deserialization):
```
1. deserialize_vendors_blobs.php
   - Extract: restaurants, phone, website, contacts
   - Output: CSV files per BLOB column

2. validate_vendor_restaurant_mapping.php
   - Compare BLOB data vs vendors_restaurants table
   - Identify source of truth
```

**SQL Scripts** (data transformation):
```
1. create_v3_vendor_schema.sql
   - Create vendor tables in V3
   - Design normalized structure

2. load_v1_vendors.sql
   - Load vendor master data
   - Map to V3 structure

3. load_vendor_restaurant_assignments.sql
   - Load valid links only (exclude orphans)
   - Use `legacy_v1_id` for tracking

4. load_v2_vendor_reports.sql
   - Load financial reports
   - Parse JSON data

5. refactor_vendor_splits.sql
   - Convert templates to rules table
   - Extract calculation logic
```

**Code Refactoring** (templates → logic):
```
1. VendorCommissionCalculator.php
   - Implement template logic in code
   - Remove executable code from database
   - Add unit tests

2. VendorReportGenerator.php
   - Implement report generation
   - Replace PHP template system
```

---

## Questions for Stakeholders

### Business Questions

1. **Vendor Model Status**
   - [ ] Is the vendor/franchise model still active?
   - [ ] When was the last vendor payout processed?
   - [ ] Are new vendors being onboarded?
   
2. **MenuOttawa Status**
   - [ ] Is MenuOttawa still operating?
   - [ ] Is it a franchise or fully independent?
   - [ ] What is the current commission structure?

3. **Commission Splits**
   - [ ] Are commission splits still calculated?
   - [ ] How many restaurants currently use splits?
   - [ ] Are templates still being modified?

4. **Reporting**
   - [ ] Are vendor reports still generated?
   - [ ] Who consumes these reports?
   - [ ] What format do they need (PDF, JSON, dashboard)?

5. **Future Plans**
   - [ ] Will the vendor model continue?
   - [ ] Are there plans to expand franchises?
   - [ ] Should this feature be modernized or deprecated?

### Technical Questions

6. **V3 Schema**
   - [ ] Does V3 already have vendor tables?
   - [ ] How are vendors represented in V3?
   - [ ] Are commission calculations in V3?

7. **File Storage**
   - [ ] Where are vendor report PDFs stored?
   - [ ] Are these files still needed?
   - [ ] Should they be migrated?

8. **User Accounts**
   - [ ] Are vendor_users still active?
   - [ ] Do they need V3 accounts?
   - [ ] What permissions should they have?

---

## Next Steps

### Immediate Actions (Before Migration)

1. **⏸️ PAUSE Migration** - Do NOT proceed until business review complete

2. **📋 Schedule Business Review** (1-2 hours)
   - Invite: Product Owner, Finance, Operations
   - Agenda: Answer questions above
   - Output: Decision (Option A, B, or C)

3. **🔍 Audit V3 Schema** (30 minutes)
   - Check for existing vendor tables
   - Check restaurant.vendor_id FK
   - Document current state

4. **📊 Generate Data Reports** (1 hour)
   - Vendor activity timeline
   - Commission split usage
   - Report generation frequency
   - Last activity dates

5. **✅ Decision Gate**
   - Based on business review, choose migration option
   - Document decision and rationale
   - Proceed with chosen approach

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Business model deprecated | MEDIUM | LOW | Archive-only (Option B) |
| Commission logic unclear | HIGH | HIGH | Business review + code audit |
| Data quality poor | MEDIUM | MEDIUM | Exclude orphaned records |
| V3 schema mismatch | LOW | HIGH | Schema audit first |
| Financial calculations wrong | LOW | CRITICAL | Thorough testing + validation |
| User access issues | LOW | MEDIUM | Password reset, permission review |

---

## Summary

**Current Status**: ⏸️ **BLOCKED - AWAITING BUSINESS REVIEW**

**Key Findings**:
- 7 tables across V1 & V2
- ~1,109 total records
- 290 orphaned vendor-restaurant links (49%)
- Only 19 restaurants (2%) using commission splits
- Last activity: January 2024
- Executable PHP code in database (security risk)

**Critical Unknowns**:
- Is vendor model still active?
- Are reports still generated?
- Is MenuOttawa still a franchise?

**Recommended Next Action**:
1. Schedule business review (1-2 hours)
2. Audit V3 schema (30 min)
3. Choose migration option (A, B, or C)
4. Proceed accordingly

**Do NOT migrate** until business confirms requirements and V3 schema is audited.

---

**Document Created**: January 10, 2025  
**Created By**: Santiago  
**Status**: 🔍 **ANALYSIS COMPLETE - AWAITING DECISION**

**Next Update**: After business review and V3 schema audit

