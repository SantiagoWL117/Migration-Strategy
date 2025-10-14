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

## Source Code Analysis

### 🔍 V1 & V2 Business Logic Deep Dive

**Analysis Date**: January 10, 2025  
**Code Reviewed**: menuca_v1 & menuca_v2 application source  
**Purpose**: Understand how vendors/franchises actually work in the current system

---

### System Architecture Discovery

**Critical Finding**: Vendors are **NOT a separate user type**. They are represented as:
```
admin_users WHERE group = 12 AND active = 'y'
```

This means:
- Vendors use the same `admin_users` table as restaurant owners and staff
- Distinguished only by `group = 12` field
- Have special `billing_info` field for invoicing
- Linked to restaurants via `admin_users_restaurants` junction table

**No separate vendor tables in V2** - The V1 `vendors` table was **deprecated**!

---

### V2 Active Business Logic

#### 1. Vendor User Management

**Location**: `menuca_v2/mca/application/models/Accounting_model.php` (Lines 970-996)

**Function**: `get_vendors()`
```php
public function get_vendors(): array
{
    $data = $this->db->query(
        "select `id`,`fname`,`lname`, `billing_info` 
         from `admin_users` 
         where `group` = 12 and `active`='y'"
    )->result();
    
    return $return;
}
```

**How It Works**:
- Vendors are admin users with `group = 12`
- Have `fname`, `lname` for identification
- `billing_info` field stores invoice details (name, address, etc.)
- Can manage multiple restaurants via `admin_users_restaurants` table

**Restaurants Without Vendors**:
```php
public function not_assigned_restaurants(): array
{
    return $this->db->query(
        "select `id`, `name`, `address`
         from `restaurants`
         where `active` = 'y'
           and id not in (
               select restaurant_id from admin_users_restaurants
               join admin_users on admin_users_restaurants.user_id = admin_users.id
               where admin_users.`group` = 12
           )"
    )->result();
}
```

---

#### 2. Commission Split Templates

**Location**: `menuca_v2/mca/application/models/Accounting_model.php` (Lines 1002-1081)

**Purpose**: Define how revenue is split between restaurant, vendor, and platform

**Template Structure**:
```sql
CREATE TABLE vendor_splits_templates (
  id int AUTO_INCREMENT,
  name varchar(125),                    -- Template name (e.g., "percent_commission")
  commission_from char(15),             -- 'gross', 'net', or 'net_delivery'
  menuottawa_share decimal(5,2),        -- Platform fixed fee
  breakdown text,                        -- ⚠️ EXECUTABLE PHP CODE
  return_info text,                      -- ⚠️ EXECUTABLE PHP CODE
  file varchar(125),                     -- PDF filename suffix
  enabled enum('y','n'),
  added_by int,
  added_at datetime
);
```

**Template Placeholders**:
- `##total##` - Order total (varies by commission_from)
- `##restaurant_commission##` - Restaurant's commission %
- `##restaurant_convenience_fee##` - Convenience fee value
- `##menuottawa_share##` - MenuOttawa/menu.ca fixed share
- `##vendor_id##` - Vendor ID
- `##restaurant_address##`, `##restaurant_name##`, `##restaurant_id##` - Restaurant info

**Example Template** (from database):
```php
// Template: "percent_commission"
// commission_from: 'net'
// menuottawa_share: 80.00

// breakdown field (EXECUTABLE PHP):
$tenPercent = ##total##*(##restaurant_commission## / 100);
$firstSplit = $tenPercent - ##menuottawa_share##;
$forVendor_0= $firstSplit / 2;
$forJames=$forVendor_0 / 2;

// return_info field (EXECUTABLE PHP):
vendor_id => ##vendor_id##
restaurant_address => ##restaurant_address##
restaurant_name => ##restaurant_name##
restaurant_id => ##restaurant_id##
useTotal=> ##total##,
forVendor => $forVendor_0
forJames=>$forJames
```

**How Templates Are Applied**:
1. Admin assigns template to restaurant via `vendor_splits` table
2. Monthly report generation queries `vendor_splits_templates` JOIN `vendor_splits`
3. System replaces placeholders with actual values
4. **Uses `eval()` to execute PHP code** (see security section below)

**Functions**:
```php
// Add/edit template
public function handle_vendor_split_templates(array $postData)

// Assign template to restaurant
public function add_vendor_split(array $postData)

// Get current template for restaurant
public function get_current_vendor_split(int $restaurant_id)

// Get all templates
public function get_vendor_splits_templates(): array
```

---

#### 3. Vendor Report Generation

**Location**: `menuca_v2/mca/application/models/Accounting_model.php` (Lines 1086-1343)

**Function**: `calculate_vendor_reports(array $options = [])`

**Execution**: Monthly cron job on 1st of month for previous month

**Workflow**:

**Step 1: Data Collection**
```php
// Get vendors and their restaurants
$subquery = "select admin_users.fname, admin_users.lname, admin_users.id, 
                    admin_users_restaurants.restaurant_id
             from admin_users
             join admin_users_restaurants on admin_users.id = admin_users_restaurants.user_id
             where `admin_users`.`group` = 12 and `admin_users`.`active` = 'y'";

// Get order totals for period
$query = "select r.id, r.name, r.address, vendors.vendor_id,
                 round(numbers.total_orders_value + if(rc.charges_value is null,0, rc.charges_value), 2) as `total_orders_value`,
                 round(numbers.total_food_value + if(rc.charges_value is null,0, rc.charges_value), 2) as `total_food_value`,
                 split.commission_from, split.menuottawa_share, split.breakdown, split.return_info,
                 fees.convenienceFeeValue, fees.commissionValue
          from restaurants r
          join (" . $subquery . ") vendors on r.id = vendors.restaurant_id
          left join (select sum(`total`) as `total_orders_value`,
                            sum(`food_value`) as `total_food_value`,
                            restaurant_id
                     from `order_details`
                     where `status` = 'accepted' and `midnight` between ? and ?
                     group by `restaurant_id`) numbers on r.id = numbers.restaurant_id
          left join (select commission_from, menuottawa_share, breakdown, return_info, restaurant_id, file
                     from vendor_splits_templates 
                     join vendor_splits on vendor_splits_templates.id = vendor_splits.template_id
                     where `enabled` = 'y') split on r.id = split.restaurant_id";
```

**Step 2: Commission Calculation** (⚠️ CRITICAL SECURITY ISSUE)
```php
foreach ($data as $restaurant) {
    // Determine which total to use
    switch ($restaurant->commission_from) {
        case 'gross':
            $totalValue = $restaurant->total_orders_value ?? 0;  // Full order total
            break;
        case 'net_delivery':
            $totalValue = $restaurant->total_fv_df ?? 0;         // Food + delivery
            break;
        default:
            $totalValue = $restaurant->total_food_value ?? 0;    // Food only
            break;
    }
    
    // Replace placeholders in template
    $breakdown = str_replace(
        ['##total##', '##restaurant_commission##', '##restaurant_convenience_fee##', 
         '##menuottawa_share##', '##vendor_id##', '##restaurant_address##', 
         '##restaurant_name##', '##restaurant_id##'],
        [$totalValue, $restaurant->commissionValue, $restaurant->convenienceFeeValue, 
         $restaurant->menuottawa_share, $restaurant->vendor_id, $restaurant->address, 
         $restaurant->name, $restaurant->id],
        $restaurant->breakdown
    );
    
    // ⚠️ EXECUTE ARBITRARY PHP CODE FROM DATABASE
    $formulas = explode("\n", $breakdown);
    foreach ($formulas as $formula) {
        eval($formula); // Line 1200 - CRITICAL SECURITY VULNERABILITY
    }
    
    // Process return_info to extract calculated values
    $return = str_replace([/* same placeholders */], [/* same values */], $restaurant->return_info);
    
    foreach (explode("\n", $return) as $item) {
        if (stripos($item, '=') !== false) {
            list($key, $value) = explode('=>', $item);
            if (strpos($value, '$') !== false) {
                eval("\$tmp = " . trim($value) . ';'); // Line 1226 - ANOTHER eval()
                $_return[trim($key)] = $tmp > 0 ? $tmp : 0;
            }
        }
    }
}
```

**Step 3: Store Results**
```php
$_insertData[$restaurant->vendor_id]['to_db'][] = [
    'restaurant_id' => $restaurant->id,
    'result' => json_encode($_return),  // JSON with all calculated values
    'date_added' => $this->calendar->format('Y-m-d'),
    'vendor_id' => $restaurant->vendor_id,
    'statement_no' => $statementNumbers[$restaurant->vendor_id] + 1,
    'start' => $start,
    'stop' => $stop,
];

$this->db->insert_batch('vendor_reports', $insert['to_db']);
```

**Step 4: Generate PDF**
```php
// Create PDF report for each vendor
$filename = $insert['to_file']['file'] . '_' . $start . '_' . $stop . '.pdf';
$template = file_get_contents(VIEWPATH . 'layout/pdf/vendor_reports.twig');

// Build table of restaurants and commissions
foreach ($insert['to_file']['data'] as $d) {
    $table .= '<tr><td>' . implode('</td><td>', $d) . '</td></tr>';
    $total += $d['commission'];
}

$page = str_replace(
    ['<!-- data -->', '##vendor##', '##statementno##', '##start##', '##stop##', '##total##'],
    [$table, $insert['to_file']['vendor'], $statementNo, $start, $stop, number_format($total, 2)],
    $template
);

$this->Mpdf->createPdf(['body' => $page], $filename);
```

**Step 5: Update Statement Numbers**
```php
$this->db->query(
    "insert into `vendor_reports_numbers`(`statement_no`, `vendor_id`, `file`)
     values (?, ?, ?)
     on duplicate key update `statement_no` = ?",
    [$statementNo, $vendorId, $insert['to_file']['file'], $statementNo]
);
```

**Output**:
- JSON data stored in `vendor_reports` table
- PDF files: `/vendors/{vendor_file}_{start}_{stop}.pdf`
- Statement numbers incremented per vendor
- Results can be viewed in admin interface

---

#### 4. Additional Vendor Features

**Vendor Extra Report** (Lines 1772-1904):
- Calculates extra commission for delivery orders
- Uses `vendor_commission_extra` field from `restaurants_fees`
- Formula: `commission = food_value * (vendor_commission_extra / 100)`
- Generates separate PDF: `vendor_extra_{start}_{stop}.pdf`

**Tips and Fees Report** (Lines 1661-1769):
- Not vendor-specific, but related
- Calculates delivery fees and driver tips
- For restaurants using delivery companies

**Invoice Generation** (Lines 1421-1499):
- Create invoices for vendors (`invoice_type = 'vendor'`)
- Create invoices for menu.ca (`invoice_type = 'menu'`)
- Stores in `vendor_invoices` table
- Links to vendor reports via statement number

---

### V1 Legacy Code

**Location**: `menuca_v1/menu-v1/defines.php` (Lines 172-186)

**Remnants Found**:
```php
// Commented out code showing V1 vendor structure
/*$vendor = $db->fetch($db->query("select `name`,`logo`,`restaurants`,`website` from `vendors`"));
foreach($vendor as $v){
    $vendorResto = @unserialize($v['restaurants']);  // BLOB deserialization
    if(in_array($restoInfo['id'], $vendorResto)){
        $restoInfo['vendorName'] = $v['name'];
        $websites = @unserialize($v['website']);      // BLOB deserialization
        if(is_array($websites)){
            $restoInfo['vendorUrl'] = $websites['url'][$websites['default']];
        }
    }
}*/
```

**What This Tells Us**:
- V1 used `vendors` table with BLOB columns
- BLOBs contained serialized PHP arrays
- `restaurants` BLOB: Array of restaurant IDs
- `website` BLOB: Array of URLs with default index
- This code is **commented out** in production (inactive)
- V1 vendor system was **deprecated** when V2 was built

**V1 to V2 Migration**:
- V1: Separate `vendors` table with BLOBs
- V2: Vendors as `admin_users` (group 12) with junction table
- Data was likely migrated manually (no migration script found)

---

### UI Components Analysis

#### Admin Interface: Vendor Split Settings

**File**: `menuca_v2/mca/application/views/restaurants/vendor_split.twig`

**Features**:
1. **Assign Template to Restaurant**:
   - Dropdown of available templates
   - One-click assignment
   - AJAX submission

2. **Create/Edit Templates**:
   - Template name input
   - Commission source selection (gross/net/net_delivery)
   - MenuOttawa share (decimal)
   - **Breakdown textarea** - Enter raw PHP code with placeholders
   - **Return info textarea** - Enter PHP variable assignments
   - File suffix for PDFs
   - JavaScript loads existing template data for editing

**Security Note**: UI allows admins to enter **arbitrary PHP code** that will be executed via `eval()`.

#### Admin Interface: Vendor Reports

**File**: `menuca_v2/mca/application/views/accounting/vendor_reports_interface.twig`

**Features**:
- View existing vendor reports (by date range)
- Generate new reports (manual or scheduled)
- Download PDF statements
- Create invoices for vendors
- View statement numbers per vendor

**JavaScript**: `menuca_v2/mca/public/assets/js/mc/src/vendor_reports_interface.js`
- Province-based tax calculation
- Invoice generation forms
- Dynamic charge/tax row addition

---

### Security Vulnerabilities Found

#### 🔴 CRITICAL: Arbitrary Code Execution

**Location**: `Accounting_model.php` Lines 1200, 1226

**Vulnerability**:
```php
eval($formula); //eval is evil, but there's no other way
```

**Risk Level**: **CRITICAL**

**Attack Vector**:
1. Attacker gains access to admin account (or account is compromised)
2. Edits vendor split template via UI
3. Injects malicious PHP code in `breakdown` field
4. Code executes when monthly report runs (or manual generation)

**Example Exploit**:
```php
// Injected in breakdown field:
$forVendor = 0; 
shell_exec('rm -rf /var/www/html/*');  // Delete all files
file_put_contents('/tmp/backdoor.php', '<?php system($_GET["cmd"]); ?>');
```

**Potential Impact**:
- Remote code execution on server
- Database manipulation
- File system access
- Data exfiltration
- Server compromise

**Current Mitigation**: None (relies on admin account security only)

**Why This Exists**:
- Developer comment: "eval is evil, but there's no other way"
- Templates need dynamic calculation logic
- No safe calculation engine was implemented
- Technical debt from rapid development

---

#### 🟡 MEDIUM: SQL Injection Risk

**Location**: Template placeholder replacement

**Issue**: If template placeholders are not properly escaped before being used in SQL queries (though current code doesn't show direct SQL in templates)

**Mitigation**: Input validation on placeholder values

---

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    VENDOR REPORT WORKFLOW                    │
└─────────────────────────────────────────────────────────────┘

1. CRON TRIGGER (Monthly)
   └─> Accounting::vendor_reports()
       └─> Accounting_model::calculate_vendor_reports()

2. DATA COLLECTION
   ├─> Query admin_users (group = 12) → Vendors
   ├─> Query admin_users_restaurants → Restaurant assignments
   ├─> Query order_details (status='accepted') → Order totals
   ├─> Query vendor_splits → Template assignments
   └─> Query vendor_splits_templates → Calculation formulas

3. CALCULATION (PER RESTAURANT)
   ├─> Determine commission base (gross/net/net+delivery)
   ├─> Replace template placeholders with actual values
   ├─> eval() PHP code from breakdown field ⚠️ SECURITY RISK
   ├─> Extract $forVendor variable
   └─> Store in $_insertData array

4. PERSISTENCE
   ├─> INSERT batch into vendor_reports (JSON results)
   ├─> UPDATE vendor_reports_numbers (increment statement #)
   └─> Generate PDF files → /vendors/{file}_{start}_{stop}.pdf

5. OUTPUT
   ├─> PDF reports available for download
   ├─> JSON data stored for API access
   └─> Admin UI displays report list
```

---

### Commission Calculation Examples

#### Example 1: "percent_commission" Template

**Template Data**:
- `commission_from`: `'net'` (food value only)
- `menuottawa_share`: `80.00`
- Restaurant commission: `10%`

**Monthly Totals**:
- Food value: `$10,000`
- Delivery fees: `$500` (ignored for 'net')

**Calculation**:
```php
$tenPercent = $10000 * (10 / 100);           // = $1,000
$firstSplit = $1000 - 80.00;                 // = $920
$forVendor_0 = $920 / 2;                     // = $460
$forJames = $460 / 2;                        // = $230

// Results:
// - Vendor receives: $460
// - "James" receives: $230 (likely MenuOttawa owner)
// - MenuOttawa platform: $80 (fixed)
// - Restaurant keeps: $9,000 + $230 = $9,230
```

#### Example 2: "mazen_milanos" Template

**Template Data**:
- `commission_from`: `'gross'` (total order value)
- `menuottawa_share`: `80.00`
- Restaurant convenience fee: `$2.00` per order
- 100 orders in month

**Monthly Totals**:
- Gross total: `$15,000`
- Convenience fees collected: `100 * $2.00 = $200`

**Calculation**:
```php
$forVendor = $15000 * 0.3;                              // = $4,500
$collection = $15000 * 2.00;                            // = $30,000 (seems wrong - likely bug)
$forMenuOttawa = ($30000 - $4500 - 80.00) / 2;         // = $12,710

// Note: This template appears to have logic issues
```

---

### Key Business Rules Discovered

1. **Vendor Representation**:
   - Vendors are NOT a separate entity
   - They are admin users with `group = 12`
   - One vendor can manage multiple restaurants
   - One restaurant can have only one vendor (unique constraint on `vendor_splits.restaurant_id`)

2. **Commission Calculation**:
   - Three bases: Gross (full order), Net (food only), Net+Delivery
   - Custom formulas per template (stored as PHP code)
   - MenuOttawa/menu.ca takes fixed platform fee
   - Remaining amount split between vendor and others (often 50/50)

3. **Report Generation**:
   - Runs monthly (cron job on 1st of month)
   - Generates PDF statements
   - Statement numbers increment per vendor per file
   - Historical data stored as JSON in database

4. **Restaurant Assignment**:
   - Only 19 of 944 restaurants (2%) use vendor splits
   - Most restaurants are directly managed (no vendor intermediary)
   - Restaurants without vendors are tracked via `not_assigned_restaurants()`

5. **Financial Tracking**:
   - Separate invoicing system for vendors and platform
   - Invoice numbers auto-increment by type
   - Links to vendor reports via statement number

---

### Migration Decision Tree

```
┌─────────────────────────────────────────────┐
│   Is vendor model still active?             │
│   (Check with business stakeholders)        │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
        YES               NO
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌──────────────────┐
│   ACTIVE        │  │   DEPRECATED     │
│   MIGRATION     │  │   ARCHIVE-ONLY   │
└─────────────────┘  └──────────────────┘
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌──────────────────┐
│ MUST REFACTOR:  │  │ Simple Archive:  │
│                 │  │                  │
│ 1. Remove eval()│  │ 1. Copy vendor   │
│    calls        │  │    reports JSON  │
│                 │  │    to V3         │
│ 2. Design safe  │  │                  │
│    calculation  │  │ 2. Read-only     │
│    engine       │  │    access        │
│                 │  │                  │
│ 3. Convert PHP  │  │ 3. No active     │
│    templates to │  │    features      │
│    JSON rules   │  │                  │
│                 │  │                  │
│ 4. Implement    │  │ Effort: 8-12 hrs │
│    validation   │  └──────────────────┘
│                 │
│ 5. Migrate:     │
│    - Vendor     │
│      users      │
│    - Templates  │
│    - Assignments│
│    - Reports    │
│                 │
│ Effort: 60-80hrs│
│ (inc. security) │
└─────────────────┘
```

---

### Refactoring Requirements (If Migrating)

#### 1. Replace eval() with Safe Calculation Engine

**Option A**: Expression Parser Library
```php
use Symfony\Component\ExpressionLanguage\ExpressionLanguage;

$expressionLanguage = new ExpressionLanguage();

$variables = [
    'total' => $totalValue,
    'restaurant_commission' => $commissionValue,
    'menuottawa_share' => $menuottawaShare,
    // ... other variables
];

// Template stored as safe expression string:
// "total * (restaurant_commission / 100) - menuottawa_share"
$forVendor = $expressionLanguage->evaluate($templateExpression, $variables);
```

**Option B**: JSON Rule Engine
```json
{
  "template_id": 2,
  "name": "percent_commission",
  "rules": [
    {
      "variable": "tenPercent",
      "operation": "multiply",
      "operands": [
        {"type": "var", "value": "total"},
        {"type": "divide", "operands": [
          {"type": "var", "value": "restaurant_commission"},
          {"type": "const", "value": 100}
        ]}
      ]
    },
    {
      "variable": "firstSplit",
      "operation": "subtract",
      "operands": [
        {"type": "var", "value": "tenPercent"},
        {"type": "var", "value": "menuottawa_share"}
      ]
    },
    {
      "variable": "forVendor",
      "operation": "divide",
      "operands": [
        {"type": "var", "value": "firstSplit"},
        {"type": "const", "value": 2}
      ]
    }
  ],
  "return": "forVendor"
}
```

**Option C**: Hard-Code Known Templates
```php
class VendorCommissionCalculator {
    public function calculate(string $templateName, array $data): float {
        switch ($templateName) {
            case 'percent_commission':
                return $this->calculatePercentCommission($data);
            case 'mazen_milanos':
                return $this->calculateMazenMilanos($data);
            default:
                throw new Exception("Unknown template: $templateName");
        }
    }
    
    private function calculatePercentCommission(array $data): float {
        $tenPercent = $data['total'] * ($data['restaurant_commission'] / 100);
        $firstSplit = $tenPercent - $data['menuottawa_share'];
        return $firstSplit / 2;
    }
}
```

**Recommendation**: Option A (Expression Parser) - Flexible yet safe

---

#### 2. V3 Schema Design (If Active)

```sql
-- Vendors as admin users (keep existing structure)
-- No changes to admin_users table needed

-- Commission templates (REFACTORED)
CREATE TABLE menuca_v3.vendor_commission_templates (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(125) NOT NULL UNIQUE,
    commission_from VARCHAR(20) NOT NULL,  -- 'gross', 'net', 'net_delivery'
    platform_share DECIMAL(10,2) NOT NULL,
    calculation_rules JSONB NOT NULL,       -- Safe JSON rules (no code)
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES menuca_v3.admin_users(id),
    
    -- Legacy tracking
    legacy_v2_id INTEGER,
    
    CONSTRAINT valid_commission_from CHECK (commission_from IN ('gross', 'net', 'net_delivery'))
);

-- Template assignments
CREATE TABLE menuca_v3.vendor_commission_assignments (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
    template_id BIGINT NOT NULL REFERENCES menuca_v3.vendor_commission_templates(id),
    vendor_user_id BIGINT NOT NULL REFERENCES menuca_v3.admin_users(id),
    active_from DATE NOT NULL,
    active_until DATE,
    
    UNIQUE(restaurant_id, active_from),  -- One template per restaurant per period
    
    -- Legacy tracking
    legacy_v2_id INTEGER
);

-- Historical reports (archive)
CREATE TABLE menuca_v3.vendor_reports_archive (
    id BIGSERIAL PRIMARY KEY,
    vendor_user_id BIGINT REFERENCES menuca_v3.admin_users(id),
    restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id),
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    statement_number INTEGER NOT NULL,
    calculation_results JSONB NOT NULL,    -- Stored results from V2
    pdf_filename VARCHAR(255),
    generated_at DATE,
    
    -- Legacy tracking
    legacy_v2_id INTEGER,
    source_system VARCHAR(10) DEFAULT 'v2'
);

-- Statement number tracking
CREATE TABLE menuca_v3.vendor_statement_numbers (
    vendor_user_id BIGINT PRIMARY KEY REFERENCES menuca_v3.admin_users(id),
    current_number INTEGER NOT NULL DEFAULT 0,
    last_generated_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_vendor_reports_vendor ON menuca_v3.vendor_reports_archive(vendor_user_id);
CREATE INDEX idx_vendor_reports_period ON menuca_v3.vendor_reports_archive(report_period_start, report_period_end);
CREATE INDEX idx_commission_assignments_restaurant ON menuca_v3.vendor_commission_assignments(restaurant_id);
CREATE INDEX idx_commission_assignments_active ON menuca_v3.vendor_commission_assignments(active_from, active_until);
```

---

#### 3. Migration Scripts Needed (If Active)

**PHP Scripts**:
```
1. extract_vendor_templates.php
   - Read vendor_splits_templates from V2
   - Parse PHP code to understand logic
   - Convert to JSON rules format
   - Output: vendor_templates.json

2. validate_commission_calculations.php
   - Test new calculation engine
   - Compare results with existing V2 reports
   - Ensure accuracy within $0.01
   - Output: validation_report.txt
```

**SQL Scripts**:
```
1. load_vendor_commission_templates.sql
   - Load converted templates into V3
   - Map legacy_v2_id for tracking

2. load_vendor_assignments.sql
   - Load vendor_splits data
   - Link to V3 restaurants and templates

3. load_vendor_reports_archive.sql
   - Load historical vendor_reports
   - Store as read-only JSON

4. verify_vendor_migration.sql
   - Check row counts
   - Validate FK integrity
   - Confirm no orphaned records
```

---

### Summary of Findings

**System Status**:
- ✅ Vendor system is functional in V2
- ⚠️ Only 2% of restaurants use it (19 of 944)
- 🔴 Critical security vulnerability (`eval()` calls)
- 📊 493 historical reports generated
- 💼 2 active commission templates
- 👥 Unknown number of active vendors (group 12 admin users)

**Key Decision Factors**:
1. **Business Activity**: Is vendor model still generating reports?
2. **Security**: Must fix eval() vulnerability before any new development
3. **Complexity**: Templates contain executable code (hard to migrate safely)
4. **Usage**: Very low adoption (2% of restaurants)

**Migration Complexity**:
- **If Active**: HIGH (security refactoring required)
- **If Deprecated**: LOW (archive JSON data only)

**Recommendation**: 
1. **Immediate**: Determine if vendor model is actively used
2. **If Active**: Prioritize security fix before V3 migration
3. **If Deprecated**: Simple archive approach is sufficient

---

**Document Created**: January 10, 2025  
**Code Analysis By**: AI Agent (Claude)  
**Source Code Reviewed**: menuca_v1 & menuca_v2 complete applications  
**Status**: 🔍 **CODE ANALYSIS COMPLETE - BUSINESS DECISION REQUIRED**

**Next Update**: After business confirms vendor model status

