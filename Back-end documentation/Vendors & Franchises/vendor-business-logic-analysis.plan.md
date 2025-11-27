<!-- 2d0edcc6-640f-41d3-aead-741b3ec7d4de 05701b28-44e3-408c-bb96-b09eb85e7af6 -->
# Vendors & Franchises - Data Migration to V3

## Overview

Migrate active vendor system from V1/V2 to V3 with security improvements. The vendor model is **ACTIVE** and must maintain full functionality for commission splitting and report generation.

---

## Critical Requirements

**Must Migrate:**

- Active vendor users (admin_users where group = 12)
- **Commission split templates: BOTH templates** 
  - `percent_commission` (template ID 2) - Net-based commission split
  - `mazen_milanos` (template ID 1) - Gross-based commission split with 30% vendor share
- Restaurant-vendor assignments (excluding test restaurant 1595)
- Statement numbers (tracking per vendor)
- **Recent historical reports (last 12 months only)**

**EXCLUDED from Migration:**

- **Test restaurant 1595** - Testing account
- Historical vendor reports older than 12 months (V2 dump serves as backup)
- Historical reports will be accessible via V2 read-only backup if needed

**Must Refactor:**
- Remove `eval()` security vulnerability from commission templates
- Convert BOTH templates to **Supabase Edge Functions** (TypeScript/Deno)
  - `percent_commission`: Net-based calculation
  - `mazen_milanos`: Gross-based calculation with 30% vendor share
- Store template metadata in PostgreSQL as JSONB
- Maintain exact commission calculation accuracy for both formulas

**Exclusions:**

- Test accounts (filter by active status)
- Vendors with zero restaurant assignments
- V1 `vendors` table (deprecated, BLOB-based)
- V1 `vendor_users` table (replaced by admin_users in V2)

**Migration Notes:**

- ⚠️ **Duplicate vendor assignments detected**: Vendor user #2 (Menu Ottawa) and user #65 (Darrell Corcoran) both manage the same 9 restaurants. Left as-is for post-migration clarification.

---

## Phase 1: V1 Legacy Analysis (Read-Only)

### 1.1 Identify V1 Vendor Tables

**V1 Tables Found:**

```
vendors (DEPRECATED - BLOB columns, not used in V2)
├── id, name, restaurants (BLOB), phone (BLOB), website (BLOB)
├── orderFee, address, logo, contacts (BLOB)
└── Status: COMMENTED OUT in defines.php, superseded by V2

vendor_users (DEPRECATED)
├── id, fname, lname, password, email
├── company, activeUser
└── Status: Replaced by admin_users (group=12) in V2

vendors_restaurants (V1 junction table)
├── id, vendor_id, restaurant_id
└── Status: Replaced by admin_users_restaurants in V2

vendors_reports (V1 reports)
├── id, vendor_id, file, start, stop, generated
├── type (stat/inv), number
└── Status: Format differs from V2, check if any active

vendors_payableto (V1 billing info)
├── id, payableto (BLOB), vendor (smallint)
└── Status: Replaced by admin_users.billing_info in V2
```

**Decision:** Skip V1 vendor tables entirely - they are deprecated and data was migrated to V2 admin_users system.
---

## Phase 2: V2 Data Extraction to CSV

### 2.1 Extract Vendor Users to CSV

**Source:** menuca_v2.admin_users WHERE group = 12

**MySQL Query (run in MySQL Workbench or CLI):**

```sql
SELECT id, fname, lname, email, password, billing_info, active, phone,
       preferred_language, receive_statements, settings, 
       created_at, created_by, disabled_at, disabled_by, last_activity
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_vendor_users.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM menuca_v2.admin_users
WHERE `group` = 12 AND active = 'y';
```

**Alternative (if OUTFILE not allowed):**

```sql
-- Copy results manually from MySQL Workbench
-- File → Export Results → CSV
SELECT id, fname, lname, email, password, billing_info, active, phone,
       preferred_language, receive_statements, settings, 
       created_at, created_by, disabled_at, disabled_by, last_activity
FROM menuca_v2.admin_users
WHERE `group` = 12 AND active = 'y';
```

**Output:** `Database/Vendors & Franchises/CSV/v2_vendor_users.csv`

**Expected:** Unknown count (need to query)

**Notes:**

- These are NOT separate vendor users - they ARE admin users
- Distinguished only by `group = 12`
- `billing_info` field contains vendor invoice details (TEXT field)
- Must preserve authentication credentials (password column)
- V2 does NOT have `updated_at`, `username`, or `password_updated_at` columns
- Actual columns: `id`, `fname`, `lname`, `email`, `password`, `billing_info`, `active`, `phone`, `preferred_language`, `receive_statements`, `settings`, `created_at`, `created_by`, `disabled_at`, `disabled_by`, `last_activity`

---

### 2.2 Extract Restaurant-Vendor Assignments to CSV

**Source:** menuca_v2.admin_users_restaurants

**MySQL Query:**

```sql
SELECT aur.id, aur.user_id, aur.restaurant_id, 
       au.fname, au.lname, r.name as restaurant_name
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_vendor_restaurant_assignments.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM menuca_v2.admin_users_restaurants aur
JOIN menuca_v2.admin_users au ON aur.user_id = au.id
JOIN menuca_v2.restaurants r ON aur.restaurant_id = r.id
WHERE au.`group` = 12 AND au.active = 'y'
  AND r.active = 'y'
  AND aur.restaurant_id != 1595;  -- Exclude test restaurant
```

**Alternative (manual export):**

```sql
SELECT aur.id, aur.user_id, aur.restaurant_id, 
       au.fname, au.lname, r.name as restaurant_name
FROM menuca_v2.admin_users_restaurants aur
JOIN menuca_v2.admin_users au ON aur.user_id = au.id
JOIN menuca_v2.restaurants r ON aur.restaurant_id = r.id
WHERE au.`group` = 12 AND au.active = 'y'
  AND r.active = 'y'
  AND aur.restaurant_id != 1595;  -- Exclude test restaurant
```

**Output:** `Database/Vendors & Franchises/CSV/v2_vendor_restaurant_assignments.csv`

**Expected:** ~17 assignments (excluding test restaurant 1595)

**Validation:**

- Exclude vendors with zero restaurant assignments
- Verify restaurant_id exists
- Verify user_id exists
- ⚠️ **Note**: Duplicate assignments exist (vendor user #2 and #65 both manage same restaurants) - left as-is for clarification

---

### 2.3 Extract Commission Split Templates to CSV

**Source:** menuca_v2.vendor_splits_templates

**MySQL Query:**

```sql
SELECT id, name, commission_from, menuottawa_share, 
       breakdown, return_info, file, enabled, added_by, added_at
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_vendor_splits_templates.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM menuca_v2.vendor_splits_templates 
WHERE enabled = 'y';  -- Export BOTH active templates
```

**Alternative (manual export):**

```sql
SELECT id, name, commission_from, menuottawa_share, 
       breakdown, return_info, file, enabled, added_by, added_at
FROM menuca_v2.vendor_splits_templates 
WHERE enabled = 'y';  -- Export BOTH active templates
```

**Output:** `Database/Vendors & Franchises/CSV/v2_vendor_splits_templates.csv`

**Expected:** 2 active templates (both `percent_commission` and `mazen_milanos`)

**Critical Security Issue:**

- `breakdown` and `return_info` contain PHP code executed via `eval()`
- CSV export will preserve this code for analysis
- Example from template #1 (mazen_milanos):
  ```php
  $forVendor = ##total## * 0.3;
  $collection = ##total## * ##restaurant_convenience_fee##;
  $forMenuca = ($collection - $forVendor - ##menuottawa_share##) / 2;
  ```
- Example from template #2 (percent_commission):
  ```php
  $totalCommission = ##total##*(##restaurant_commission## / 100);
  $afterFixedFee = $totalCommission - ##menuottawa_share##;
  $forVendor = $afterFixedFee / 2;
  $forMenuca = $afterFixedFee / 2;
  ```

**Migration Strategy:** Convert BOTH templates to Supabase Edge Functions (TypeScript) - see Phase 3

---

### 2.4 Commission Template Configuration (Moved to V3 Schema)

**Note:** Commission template assignments (`vendor_splits`) are no longer extracted to CSV. Instead, commission configuration is stored directly in the V3 `vendor_restaurants` table with the following fields:

- `commission_template` - 'percent_commission' or 'mazen_milanos'
- `commission_rate` - Variable percentage per restaurant
- `commission_type` - 'percentage' or 'fixed'
- `fixed_platform_fee` - Menu.ca fixed fee (default $80)
- `delivery_commission_extra` - Extra % for delivery orders

This configuration is passed directly to the Supabase Edge Function at runtime, eliminating the need for a separate commission assignments table.

---

### 2.5 Extract Historical Vendor Reports to CSV (Last 12 Months Only)

**Source:** menuca_v2.vendor_reports

**MySQL Query:**

```sql
SELECT vr.id, vr.restaurant_id, vr.result, vr.vendor_id, 
       vr.statement_no, vr.start, vr.stop, vr.date_added,
       au.fname, au.lname, r.name as restaurant_name
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_vendor_reports_recent.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM menuca_v2.vendor_reports vr
LEFT JOIN menuca_v2.admin_users au ON vr.vendor_id = au.id
LEFT JOIN menuca_v2.restaurants r ON vr.restaurant_id = r.id
WHERE vr.date_added >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
ORDER BY vr.date_added DESC;
```

**Alternative (manual export):**

```sql
SELECT vr.id, vr.restaurant_id, vr.result, vr.vendor_id, 
       vr.statement_no, vr.start, vr.stop, vr.date_added,
       au.fname, au.lname, r.name as restaurant_name
FROM menuca_v2.vendor_reports vr
LEFT JOIN menuca_v2.admin_users au ON vr.vendor_id = au.id
LEFT JOIN menuca_v2.restaurants r ON vr.restaurant_id = r.id
WHERE vr.date_added >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
ORDER BY vr.date_added DESC;
```

**Output:** `Database/Vendors & Franchises/CSV/v2_vendor_reports_recent.csv`

**Expected:** ~40-50 recent reports (out of 493 total)

**Sample JSON Result:**

```json
{
  "interval": "2024-01-01 - 2024-01-31",
  "vendor_id": 5,
  "restaurant_id": 123,
  "restaurant_name": "Pizza Place",
  "restaurant_address": "123 Main St",
  "useTotal": 10000.00,
  "forVendor": 460.00,
  "forMenuca": 460.00,
  "save_to_file": "vendor_report",
  "server_file": "vendor_report_2024-01-01_2024-01-31.pdf"
}
```

**Rationale for 12-month limit:**

- Reduces migration complexity and data volume
- Recent reports are most valuable for vendors
- Historical reports (493 total) remain accessible in V2 read-only backup
- Typical business retention for operational reports is 12-18 months

---

### 2.6 Extract Statement Numbers to CSV

**Source:** menuca_v2.vendor_reports_numbers

**MySQL Query:**

```sql
SELECT vrn.id, vrn.statement_no, vrn.vendor_id, vrn.file,
       au.fname, au.lname
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/v2_vendor_reports_numbers.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM menuca_v2.vendor_reports_numbers vrn
JOIN menuca_v2.admin_users au ON vrn.vendor_id = au.id
WHERE au.active = 'y';
```

**Alternative (manual export):**

```sql
SELECT vrn.id, vrn.statement_no, vrn.vendor_id, vrn.file,
       au.fname, au.lname
FROM menuca_v2.vendor_reports_numbers vrn
JOIN menuca_v2.admin_users au ON vrn.vendor_id = au.id
WHERE au.active = 'y';
```

**Output:** `Database/Vendors & Franchises/CSV/v2_vendor_reports_numbers.csv`

**Expected:** 2 records (one per active vendor/template combo)

**Purpose:** Track incremental statement numbers per vendor

**Note:** The `vendor_commission_extra` field from `restaurants_fees` was evaluated but excluded from migration as it only contains values for test restaurant 1595, which is excluded from migration.

---


## Phase 3: Template Code Analysis & Conversion

### 3.1 Extract Existing Templates (Both Templates Migration)

**Template #1: "mazen_milanos"** ✅ ACTIVE - Commission-based with 30% vendor share

```php
// V2 breakdown (executed via eval - INSECURE):
// CORRECTED FORMULA:
$totalCommission = ##total## * (##restaurant_commission## / 100);  // Variable % commission
$forVendor = $totalCommission * 0.3;  // Vendor gets 30% of commission
$afterVendorShare = $totalCommission - $forVendor;
$afterFixedFee = $afterVendorShare - ##menuottawa_share##;  // Subtract $80
$forMenuOttawa = $afterFixedFee / 2;  // Menu Ottawa gets half
$forMenuca = $afterFixedFee / 2;  // Menu.ca gets half

// return_info:
vendor_id => ##vendor_id##
restaurant_address => ##restaurant_address##
restaurant_name => ##restaurant_name##
restaurant_id => ##restaurant_id##
restaurant_commission => ##restaurant_commission##
forVendor => $forVendor
forMenuOttawa => $forMenuOttawa
```

**Calculation Type**: Commission-based (NET basis with 30% vendor priority)
- Variable commission % calculated from order total (per-restaurant setting)
- Vendor (Mazen) gets 30% of that commission upfront
- Menu.ca takes fixed $80 from remaining commission
- Menu Ottawa and Menu.ca split the rest 50/50

---

**Template #2: "percent_commission"** ✅ ACTIVE - Net-based commission

```php
// V2 breakdown (executed via eval - INSECURE):
$totalCommission = ##total##*(##restaurant_commission## / 100);
$afterFixedFee = $totalCommission - ##menuottawa_share##;
$forVendor = $afterFixedFee / 2;
$forMenuca = $afterFixedFee / 2;

// return_info:
vendor_id => ##vendor_id##
restaurant_address => ##restaurant_address##
restaurant_name => ##restaurant_name##
restaurant_id => ##restaurant_id##
useTotal=> ##total##
forVendor => $forVendor
forMenuca => $forMenuca
```

**Calculation Type**: NET basis
- Commission calculated from restaurant percentage
- After fixed fee, split 50/50 between vendor and Menu.ca

### 3.2 Convert to Supabase Edge Function (TypeScript/Deno)

**Strategy**: Deploy BOTH commission templates as a single Supabase Edge Function with template metadata stored in PostgreSQL.

**Advantages**:
- ✅ No eval() security vulnerability
- ✅ Native Supabase integration
- ✅ Serverless, auto-scaling
- ✅ Type-safe (TypeScript)
- ✅ Easy to test via Supabase CLI
- ✅ Integrates with RLS and PostgreSQL functions
- ✅ Both templates in one function (efficient, maintainable)

**Implementation**:

**A. Supabase Edge Function** (`supabase/functions/calculate-vendor-commission/index.ts`):

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

interface CommissionInput {
  template_name: string
  total: number
  restaurant_commission: number  // Required: used by BOTH templates (variable % per restaurant)
  menuottawa_share: number
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
}

interface CommissionResult {
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
  use_total: number
  for_vendor: number
  for_menuca: number
}

function calculatePercentCommission(data: CommissionInput): CommissionResult {
  // Template: percent_commission (NET basis)
  // Replaces V2 eval() call with safe, typed calculation
  
  const totalCommission = data.total * ((data.restaurant_commission ?? 10) / 100)
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menuca: Math.round(forMenucaTotal * 100) / 100
  }
}

function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  // Template: mazen_milanos (Commission-based with 30% vendor priority)
  // Replaces V2 eval() call with safe, typed calculation
  
  const totalCommission = data.total * (data.restaurant_commission / 100)  // Variable % per restaurant
  const forVendor = totalCommission * 0.3  // Vendor gets 30% of commission
  const afterVendorShare = totalCommission - forVendor
  const afterFixedFee = afterVendorShare - data.menuottawa_share  // Subtract $80
  const forMenuOttawa = afterFixedFee / 2  // Menu Ottawa gets half
  const forMenucaShare = afterFixedFee / 2  // Menu.ca gets half
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menu_ottawa: Math.round(forMenuOttawa * 100) / 100,
    for_menuca: Math.round(forMenucaTotal * 100) / 100
  }
}

serve(async (req) => {
  try {
    const input: CommissionInput = await req.json()
    
    // Route to appropriate calculation based on template name
    let result: CommissionResult
    
    if (input.template_name === 'percent_commission') {
      result = calculatePercentCommission(input)
    } else if (input.template_name === 'mazen_milanos') {
      result = calculateMazenMilanos(input)
    } else {
      return new Response(
        JSON.stringify({ error: `Unknown template: ${input.template_name}` }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }
    
    return new Response(
      JSON.stringify(result),
      { headers: { "Content-Type": "application/json" } }
    )
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})
```

**B. PostgreSQL Function Wrapper** (for database-side calls):

```sql
-- Create a PostgreSQL function that calls the Edge Function
CREATE OR REPLACE FUNCTION public.calculate_vendor_commission(
  p_template_name TEXT,
  p_total NUMERIC,
  p_restaurant_commission NUMERIC,
  p_menuottawa_share NUMERIC,
  p_vendor_id INTEGER,
  p_restaurant_id INTEGER,
  p_restaurant_name TEXT,
  p_restaurant_address TEXT
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSONB;
BEGIN
  -- Call Supabase Edge Function via pg_net extension
  SELECT content::jsonb INTO v_result
  FROM http((
    'POST',
    current_setting('app.edge_function_url') || '/calculate-vendor-commission',
    ARRAY[http_header('Authorization', 'Bearer ' || current_setting('app.service_role_key'))],
    'application/json',
    jsonb_build_object(
      'template_name', p_template_name,
      'total', p_total,
      'restaurant_commission', p_restaurant_commission,
      'menuottawa_share', p_menuottawa_share,
      'vendor_id', p_vendor_id,
      'restaurant_id', p_restaurant_id,
      'restaurant_name', p_restaurant_name,
      'restaurant_address', p_restaurant_address
    )::text
  )::http_request);
  
  RETURN v_result;
END;
$$;
```

**C. Template Metadata Storage** (in PostgreSQL):

```json
-- Stored in vendor_commission_templates.metadata (JSONB column)
{
  "template_id": 2,
  "name": "percent_commission",
  "commission_from": "net",
  "menuottawa_share": 80.00,
  "edge_function": "calculate-vendor-commission",
  "description": "10% commission split 50/50 between vendor and Menu.ca after $80 fixed fee",
  "calculation_notes": "forVendor = (total * commission% - fixed_fee) / 2; forMenuca = (total * commission% - fixed_fee) / 2"
}
```

**D. Validation Tests** (Deno test):

```typescript
// test_commission_calculator.ts
import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts"

Deno.test("percent_commission calculation accuracy", () => {
  const testData = {
    template_name: 'percent_commission',
    total: 10000.00,
    restaurant_commission: 10,
    menuottawa_share: 80.00,
    vendor_id: 2,
    restaurant_id: 123,
    restaurant_name: 'Test Restaurant',
    restaurant_address: '123 Main St'
  }
  
  const result = calculatePercentCommission(testData)
  
  // Expected: 
  // totalCommission = 10000 * 0.10 = 1000
  // afterFixedFee = 1000 - 80 = 920
  // forVendor = 920 / 2 = 460
  // forMenucaShare = 920 / 2 = 460
  // forMenucaTotal = 80 + 460 = 540
  assertEquals(result.for_vendor, 460.00, 'Vendor amount calculation failed')
  assertEquals(result.for_menuca, 540.00, 'Menu.ca total (fixed + share) calculation failed')
})

Deno.test("mazen_milanos calculation accuracy - 10% commission", () => {
  const testData = {
    template_name: 'mazen_milanos',
    total: 10000.00,
    restaurant_commission: 10,  // 10% commission rate
    menuottawa_share: 80.00,
    vendor_id: 1,
    restaurant_id: 1171,
    restaurant_name: 'Pho Dau Bo',
    restaurant_address: '456 King St'
  }
  
  const result = calculateMazenMilanos(testData)
  
  // Expected: 
  // totalCommission = 10000 * (10 / 100) = 1000
  // forVendor = 1000 * 0.30 = 300 (Mazen gets 30% of commission)
  // afterVendorShare = 1000 - 300 = 700
  // afterFixedFee = 700 - 80 = 620
  // forMenuOttawa = 620 / 2 = 310
  // forMenucaShare = 620 / 2 = 310
  // forMenucaTotal = 80 + 310 = 390
  assertEquals(result.for_vendor, 300.00, 'Vendor (Mazen) amount calculation failed')
  assertEquals(result.for_menu_ottawa, 310.00, 'Menu Ottawa amount calculation failed')
  assertEquals(result.for_menuca, 390.00, 'Menu.ca total (fixed + share) calculation failed')
})

Deno.test("mazen_milanos calculation accuracy - 15% commission", () => {
  const testData = {
    template_name: 'mazen_milanos',
    total: 10000.00,
    restaurant_commission: 15,  // 15% commission rate
    menuottawa_share: 80.00,
    vendor_id: 1,
    restaurant_id: 1171,
    restaurant_name: 'Pho Dau Bo',
    restaurant_address: '456 King St'
  }
  
  const result = calculateMazenMilanos(testData)
  
  // Expected: 
  // totalCommission = 10000 * (15 / 100) = 1500
  // forVendor = 1500 * 0.30 = 450
  // afterVendorShare = 1500 - 450 = 1050
  // afterFixedFee = 1050 - 80 = 970
  // forMenuOttawa = 970 / 2 = 485
  // forMenucaShare = 970 / 2 = 485
  // forMenucaTotal = 80 + 485 = 565
  assertEquals(result.for_vendor, 450.00, 'Vendor (Mazen) amount calculation failed')
  assertEquals(result.for_menu_ottawa, 485.00, 'Menu Ottawa amount calculation failed')
  assertEquals(result.for_menuca, 565.00, 'Menu.ca total (fixed + share) calculation failed')
})
```

**E. Deployment Commands**:

```bash
# Deploy Edge Function
supabase functions deploy calculate-vendor-commission

# Test locally
supabase functions serve calculate-vendor-commission

# Test with curl
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"template_name":"percent_commission","total":10000,"restaurant_commission":10,"menuottawa_share":80,"vendor_id":2,"restaurant_id":123,"restaurant_name":"Test Restaurant","restaurant_address":"123 Main St"}'

# Test mazen_milanos with 10% commission:
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"template_name":"mazen_milanos","total":10000,"restaurant_commission":10,"menuottawa_share":80,"vendor_id":1,"restaurant_id":1171,"restaurant_name":"Pho Dau Bo","restaurant_address":"456 King St"}'

# Test mazen_milanos with 15% commission:
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"template_name":"mazen_milanos","total":10000,"restaurant_commission":15,"menuottawa_share":80,"vendor_id":1,"restaurant_id":1171,"restaurant_name":"Pho Dau Bo","restaurant_address":"456 King St"}'
```

---

## Phase 4: Create Staging Tables

### 4.1 Staging Schema Design

```sql
-- Create staging schema if not exists
CREATE SCHEMA IF NOT EXISTS staging;

-- 1. Staging: Vendor Users
CREATE TABLE staging.v2_vendor_users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(100),
    lname VARCHAR(100),
    email VARCHAR(255),
    billing_info TEXT,
    active CHAR(1),
    phone VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    username VARCHAR(100),
    password VARCHAR(255),
    password_updated_at TIMESTAMP,
    
    -- ETL metadata
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Staging: Vendor-Restaurant Assignments
CREATE TABLE staging.v2_vendor_restaurant_assignments (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    restaurant_id INTEGER,
    fname VARCHAR(100),
    lname VARCHAR(100),
    restaurant_name VARCHAR(255),
    
    -- ETL metadata
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Staging: Commission Templates
CREATE TABLE staging.v2_vendor_splits_templates (
    id INTEGER PRIMARY KEY,
    name VARCHAR(125),
    commission_from VARCHAR(20),
    menuottawa_share DECIMAL(10,2),
    breakdown TEXT,
    return_info TEXT,
    file VARCHAR(125),
    enabled CHAR(1),
    added_by INTEGER,
    added_at TIMESTAMP,
    
    -- ETL metadata
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Commission Assignments - NO LONGER NEEDED
-- Commission configuration stored directly in menuca_v3.vendor_restaurants table

-- 5. Staging: Historical Reports (Recent 12 months)
CREATE TABLE staging.v2_vendor_reports_recent (
    id INTEGER PRIMARY KEY,
    restaurant_id INTEGER,
    result TEXT,  -- JSON as text initially
    vendor_id INTEGER,
    statement_no SMALLINT,
    start DATE,
    stop DATE,
    date_added DATE,
    fname VARCHAR(100),
    lname VARCHAR(100),
    restaurant_name VARCHAR(255),
    
    -- ETL metadata
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Staging: Statement Numbers
CREATE TABLE staging.v2_vendor_reports_numbers (
    id INTEGER PRIMARY KEY,
    statement_no SMALLINT,
    vendor_id INTEGER,
    file VARCHAR(125),
    fname VARCHAR(100),
    lname VARCHAR(100),
    
    -- ETL metadata
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Staging: Vendor Commission Extra - EXCLUDED FROM MIGRATION
-- Reason: Only contains data for test restaurant 1595 (excluded from migration)
-- See: VENDOR_COMMISSION_EXTRA_EXCLUSION.md
```

---

## Phase 5: V3 Schema Design

### 5.1 Required V3 Tables

```sql
-- 1. Vendors as admin_users (NO CHANGES - already exists)
-- admin_users table handles vendors via group = 12

-- 2. Commission Templates - NO LONGER STORED IN DATABASE
-- Templates implemented as Supabase Edge Functions (TypeScript/Deno):
--   - calculate-vendor-commission (handles both percent_commission and mazen_milanos)

-- 3. Commission Configuration - NO LONGER A SEPARATE TABLE
-- Configuration stored directly in menuca_v3.vendor_restaurants:
--   - commission_template (VARCHAR)
--   - commission_rate (DECIMAL)
--   - commission_type (VARCHAR)
--   - fixed_platform_fee (DECIMAL)
--   - delivery_commission_extra (DECIMAL)

-- 4. Historical Reports Archive (NEW - replaces vendor_reports)
CREATE TABLE menuca_v3.vendor_reports_archive (
    id BIGSERIAL PRIMARY KEY,
    vendor_user_id BIGINT REFERENCES menuca_v3.admin_users(id),
    restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id),
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    statement_number INTEGER NOT NULL,
    calculation_results JSONB NOT NULL,    -- V2 JSON results
    pdf_filename VARCHAR(255),
    generated_at DATE,
    
    -- Legacy tracking
    legacy_v2_id INTEGER,
    source_system VARCHAR(10) DEFAULT 'v2',
    
    -- Indexing
    INDEX idx_vendor_reports_vendor (vendor_user_id),
    INDEX idx_vendor_reports_period (report_period_start, report_period_end),
    INDEX idx_vendor_reports_restaurant (restaurant_id)
);

-- 5. Statement Number Tracking (NEW - replaces vendor_reports_numbers)
CREATE TABLE menuca_v3.vendor_statement_numbers (
    vendor_user_id BIGINT PRIMARY KEY REFERENCES menuca_v3.admin_users(id),
    current_number INTEGER NOT NULL DEFAULT 0,
    last_generated_at TIMESTAMPTZ,
    pdf_file_prefix VARCHAR(125)
);

-- Note: vendor_commission_extra field from restaurants_fees is NOT migrated
-- as it only contains values for test restaurant 1595 (excluded from migration)
```

---

## Phase 6: Migration Scripts (Staging → V3)

### 6.1 Pre-Migration Validation

**Script:** `validate_vendor_data.sql`

```sql
-- Check staging data counts
SELECT 'Active Vendors' as entity, COUNT(*) as count
FROM staging.v2_vendor_users 
WHERE active = 'y'

UNION ALL

SELECT 'Vendor-Restaurant Assignments', COUNT(*)
FROM staging.v2_vendor_restaurant_assignments

UNION ALL

SELECT 'Active Templates', COUNT(*)
FROM staging.v2_vendor_splits_templates
WHERE enabled = 'y'

UNION ALL


SELECT 'Recent Historical Reports (12mo)', COUNT(*)
FROM staging.v2_vendor_reports_recent

UNION ALL

SELECT 'Statement Numbers', COUNT(*)
FROM staging.v2_vendor_reports_numbers;
```

**Expected Output:**

```
Active Vendors: ? (unknown)
Vendor-Restaurant Assignments: ~19
Active Templates: 2
Recent Historical Reports: ~40-50 (was 493 total)
Statement Numbers: 2
```

---

### 6.2 Migration Order (CRITICAL)

**MUST follow this sequence to avoid FK violations:**

1. **Vendor Users** → menuca_v3.vendors
2. **Vendor-Restaurant Assignments** → menuca_v3.vendor_restaurants (includes commission config)
3. **Statement Numbers** → menuca_v3.vendor_statement_numbers
4. **Historical Reports** → menuca_v3.vendor_commission_reports

---

### 6.3 Script 1: Migrate Vendor Users (Staging → V3)

**File:** `01_migrate_vendor_users.sql`

```sql
-- Purpose: Migrate vendor users from staging to V3
-- Source: staging.v2_vendor_users
-- Target: menuca_v3.admin_users

BEGIN;

-- Insert vendor admin users
INSERT INTO menuca_v3.admin_users (
    username, password, password_updated_at,
    first_name, last_name, email, phone,
    user_group, active, billing_info,
    created_at, updated_at,
    legacy_v2_id, source_system
)
SELECT 
    username,
    password,
    password_updated_at,
    fname,
    lname,
    email,
    phone,
    12 as user_group,  -- Vendor group
    CASE WHEN active = 'y' THEN true ELSE false END,
    billing_info,  -- Invoice details
    created_at,
    updated_at,
    id as legacy_v2_id,
    'v2' as source_system
FROM staging.v2_vendor_users
WHERE active = 'y'
  -- Exclude vendors with no restaurant assignments
  AND EXISTS (
      SELECT 1 FROM staging.v2_vendor_restaurant_assignments aur
      WHERE aur.user_id = v2_vendor_users.id
  )
ON CONFLICT (legacy_v2_id, source_system) DO NOTHING;

-- Verification
SELECT 
    COUNT(*) as migrated_vendors,
    COUNT(DISTINCT legacy_v2_id) as unique_v2_ids
FROM menuca_v3.admin_users 
WHERE user_group = 12 AND source_system = 'v2';

COMMIT;
```

---

### 6.4 Script 2: Commission Templates (No Migration Needed)

**Note:** Commission templates are now implemented as Supabase Edge Functions (TypeScript/Deno), not stored in the database. The two active templates are:

1. **`percent_commission`** - Deployed in Edge Function `calculate-vendor-commission`
2. **`mazen_milanos`** - Deployed in Edge Function `calculate-vendor-commission`

Template configuration is stored per-restaurant in the `menuca_v3.vendor_restaurants` table via the `commission_template` column.

**No migration script needed for this step.**

---

### 6.5 Script 3: Migrate Restaurant-Vendor Links (Staging → V3)

**File:** `03_migrate_restaurant_vendor_links.sql`

```sql
-- Purpose: Migrate restaurant-vendor assignments from staging to V3
-- Source: staging.v2_vendor_restaurant_assignments
-- Target: menuca_v3.admin_users_restaurants

BEGIN;

INSERT INTO menuca_v3.admin_users_restaurants (
    user_id, restaurant_id, created_at,
    legacy_v2_id, source_system
)
SELECT 
    v3_admin.id as user_id,
    v3_resto.id as restaurant_id,
    NOW() as created_at,
    aur.id as legacy_v2_id,
    'v2' as source_system
FROM staging.v2_vendor_restaurant_assignments aur
-- Map to V3 vendor
JOIN menuca_v3.admin_users v3_admin 
    ON aur.user_id = v3_admin.legacy_v2_id
    AND v3_admin.source_system = 'v2'
    AND v3_admin.user_group = 12
-- Map to V3 restaurant
JOIN menuca_v3.restaurants v3_resto
    ON aur.restaurant_id = v3_resto.legacy_v2_id
    AND v3_resto.source_system = 'v2'
ON CONFLICT DO NOTHING;

-- Verification
SELECT COUNT(*) as vendor_restaurant_links
FROM menuca_v3.admin_users_restaurants aur
JOIN menuca_v3.admin_users au ON aur.user_id = au.id
WHERE au.user_group = 12;

COMMIT;
```

---

### 6.6 Script 4: Commission Configuration (No Separate Migration)

**Note:** Commission configuration is now stored directly in the `menuca_v3.vendor_restaurants` table during the vendor-restaurant assignment migration (Script 3). Each vendor-restaurant relationship includes:

- `commission_template` - Which Edge Function template to use
- `commission_rate` - The commission percentage for that restaurant
- `commission_type` - Whether it's a percentage or fixed amount
- `fixed_platform_fee` - Fixed fee (default $80)
- `delivery_commission_extra` - Extra % for delivery

**No separate migration script needed for this step.**

---

### 6.7 Script 5: Migrate Statement Numbers (Staging → V3)

**File:** `05_migrate_statement_numbers.sql`

```sql
-- Purpose: Migrate statement numbers from staging to V3
-- Source: staging.v2_vendor_reports_numbers
-- Target: menuca_v3.vendor_statement_numbers

BEGIN;

INSERT INTO menuca_v3.vendor_statement_numbers (
    vendor_user_id, current_number, pdf_file_prefix
)
SELECT 
    v3_vendor.id as vendor_user_id,
    vrn.statement_no as current_number,
    vrn.file as pdf_file_prefix
FROM staging.v2_vendor_reports_numbers vrn
-- Map to V3 vendor
JOIN menuca_v3.admin_users v3_vendor
    ON vrn.vendor_id = v3_vendor.legacy_v2_id
    AND v3_vendor.source_system = 'v2'
    AND v3_vendor.user_group = 12
ON CONFLICT (vendor_user_id) DO UPDATE
    SET current_number = EXCLUDED.current_number,
        pdf_file_prefix = EXCLUDED.pdf_file_prefix;

-- Verification
SELECT * FROM menuca_v3.vendor_statement_numbers;

COMMIT;
```

---

### 6.8 Script 6: Migrate Historical Reports (Staging → V3)

**File:** `06_migrate_historical_reports.sql`

```sql
-- Purpose: Migrate recent historical reports (12 months) from staging to V3
-- Source: staging.v2_vendor_reports_recent
-- Target: menuca_v3.vendor_reports_archive

BEGIN;

INSERT INTO menuca_v3.vendor_reports_archive (
    vendor_user_id, restaurant_id,
    report_period_start, report_period_end,
    statement_number, calculation_results,
    pdf_filename, generated_at,
    legacy_v2_id, source_system
)
SELECT 
    v3_vendor.id as vendor_user_id,
    v3_resto.id as restaurant_id,
    vr.start as report_period_start,
    vr.stop as report_period_end,
    vr.statement_no as statement_number,
    vr.result::jsonb as calculation_results,
    CONCAT(
        (vr.result::jsonb->>'server_file')
    ) as pdf_filename,
    vr.date_added as generated_at,
    vr.id as legacy_v2_id,
    'v2' as source_system
FROM staging.v2_vendor_reports_recent vr
-- Map vendor
LEFT JOIN menuca_v3.admin_users v3_vendor
    ON vr.vendor_id = v3_vendor.legacy_v2_id
    AND v3_vendor.source_system = 'v2'
    AND v3_vendor.user_group = 12
-- Map restaurant
LEFT JOIN menuca_v3.restaurants v3_resto
    ON vr.restaurant_id = v3_resto.legacy_v2_id
    AND v3_resto.source_system = 'v2'
WHERE vr.result IS NOT NULL
ON CONFLICT (legacy_v2_id) DO NOTHING;

-- Verification
SELECT 
    COUNT(*) as total_reports,
    MIN(report_period_start) as earliest_report,
    MAX(report_period_end) as latest_report,
    COUNT(DISTINCT vendor_user_id) as unique_vendors
FROM menuca_v3.vendor_reports_archive;

-- Confirm only recent reports (12 months)
SELECT 
    'Reports older than 12 months' as check,
    COUNT(*) as count
FROM menuca_v3.vendor_reports_archive
WHERE report_period_end < CURRENT_DATE - INTERVAL '12 months';
-- Expected: 0 rows

COMMIT;
```

---

## Phase 7: Post-Migration Validation

### 7.1 Row Count Verification

**Script:** `validate_migration.sql`

```sql
-- Compare Staging vs V3 counts
SELECT 
    'Vendor Users' as entity,
    (SELECT COUNT(*) FROM staging.v2_vendor_users 
     WHERE active = 'y') as staging_count,
    (SELECT COUNT(*) FROM menuca_v3.admin_users 
     WHERE user_group = 12 AND source_system = 'v2') as v3_count
     
UNION ALL

-- Commission Templates validation skipped - now implemented as Edge Functions
-- SELECT 
--     'Commission Templates',
--     (SELECT COUNT(*) FROM staging.v2_vendor_splits_templates 
--      WHERE enabled = 'y'),
--     (SELECT COUNT(*) FROM menuca_v3.vendor_commission_templates 
--      WHERE source_system = 'v2' AND enabled = true)
--      
-- UNION ALL

SELECT 
    'Recent Historical Reports (12mo)',
    (SELECT COUNT(*) FROM staging.v2_vendor_reports_recent),
    (SELECT COUNT(*) FROM menuca_v3.vendor_reports_archive 
     WHERE source_system = 'v2')
     
UNION ALL

SELECT 
    'Statement Numbers',
    (SELECT COUNT(*) FROM staging.v2_vendor_reports_numbers),
    (SELECT COUNT(*) FROM menuca_v3.vendor_statement_numbers);
```

**Expected:** All staging_count = v3_count

---

### 7.2 FK Integrity Check

```sql
-- Check for orphaned records
-- Note: vendor_commission_assignments and vendor_commission_templates tables
-- no longer exist - commission config stored in vendor_restaurants table

SELECT 'Orphaned Reports',
       COUNT(*) as count
FROM menuca_v3.vendor_reports_archive vra
WHERE (vra.vendor_user_id IS NOT NULL 
       AND NOT EXISTS (
           SELECT 1 FROM menuca_v3.admin_users au 
           WHERE au.id = vra.vendor_user_id
       ))
   OR (vra.restaurant_id IS NOT NULL 
       AND NOT EXISTS (
           SELECT 1 FROM menuca_v3.restaurants r 
           WHERE r.id = vra.restaurant_id
       ));
```

**Expected:** All counts = 0

---

### 7.3 Calculation Accuracy Test

**Script:** `test_calculation_accuracy.php`

```php
<?php
// Test V3 calculation engine against V2 historical results

require_once 'VendorCommissionCalculator.php';

$calculator = new VendorCommissionCalculator();

$testCases = [
    // Sample from vendor_reports
    [
        'v2_report_id' => 100,
        'template' => 'percent_commission',
        'total' => 10000.00,
        'restaurant_commission' => 10,
        'menuottawa_share' => 80.00,
        'expected_vendor' => 460.00,
        'expected_james' => 230.00
    ],
    // Add more test cases...
];

foreach ($testCases as $test) {
    $v3Result = $calculator->calculate($test['template'], [
        'total' => $test['total'],
        'restaurant_commission' => $test['restaurant_commission'],
        'menuottawa_share' => $test['menuottawa_share'],
        'vendor_id' => 1,
        'restaurant_id' => 1,
        'restaurant_name' => 'Test',
        'restaurant_address' => 'Test'
    ]);
    
    $vendorDiff = abs($v3Result['forVendor'] - $test['expected_vendor']);
    $jamesDiff = abs($v3Result['forJames'] - $test['expected_james']);
    
    if ($vendorDiff > 0.01 || $jamesDiff > 0.01) {
        echo "FAIL: Report {$test['v2_report_id']}\n";
        echo "  Expected: vendor={$test['expected_vendor']}, james={$test['expected_james']}\n";
        echo "  Got: vendor={$v3Result['forVendor']}, james={$v3Result['forJames']}\n";
    } else {
        echo "PASS: Report {$test['v2_report_id']}\n";
    }
}
```

---

## Phase 8: Migration Execution Guide

### 8.1 Pre-Requisites Checklist

- [ ] V3 database exists and is accessible
- [ ] V3 `admin_users` table exists
- [ ] V3 `restaurants` table has V2 data migrated
- [ ] V3 `restaurants_fees` table has V2 data migrated
- [ ] VendorCommissionCalculator PHP class implemented and tested
- [ ] Database backup completed
- [ ] Read-only replica available for V2 queries

---

### 8.2 Execution Steps (In Order)

1. **Extract V2 Data to CSV**
   ```bash
   # Run extraction queries via mysqldump or custom scripts
   # Output to Database/Vendors & Franchises/CSV/
   ```

2. **Load CSV to Staging Tables**
   ```bash
   psql menuca_v3 < create_staging_tables.sql
   # Use COPY or \copy to load CSVs
   ```

3. **Run Pre-Migration Validation**
   ```bash
   psql -f validate_vendor_data.sql
   # Review counts, ensure no surprises
   ```

4. **Create V3 Schema**
   ```bash
   psql menuca_v3 < create_vendor_tables.sql
   # Creates all 5 vendor-specific tables
   ```

5. **Migrate Vendor Users**
   ```bash
   psql menuca_v3 < 01_migrate_vendor_users.sql
   # Expected: ~? vendors migrated
   ```

6. **Deploy Edge Functions** (Replaces template migration)
   ```bash
   # Commission templates deployed as Supabase Edge Functions
   supabase functions deploy calculate-vendor-commission
   # Templates: percent_commission, mazen_milanos
   ```

7. **Migrate Restaurant-Vendor Links (includes commission config)**
   ```bash
   psql menuca_v3 < 03_migrate_restaurant_vendor_links.sql
   # Expected: ~19 links with commission configuration
   ```

8. **Migrate Statement Numbers**
   ```bash
   psql menuca_v3 < 05_migrate_statement_numbers.sql
   # Expected: 2 records
   ```

9. **Migrate Historical Reports (12 months only)**
    ```bash
    psql menuca_v3 < 06_migrate_historical_reports.sql
    # Expected: ~40-50 reports (not 493)
    ```

11. **Run Post-Migration Validation**
    ```bash
    psql -f validate_migration.sql
    # All counts must match
    
    psql -f check_fk_integrity.sql
    # Zero orphans allowed
    
    php test_calculation_accuracy.php
    # All calculations must pass within $0.01
    ```

---

## Phase 9: Risk Assessment & Mitigation

### 9.1 Critical Risks

**Risk #1: Template Conversion Accuracy**

- **Impact:** HIGH - Incorrect commission calculations = financial errors
- **Probability:** LOW (hard-coded functions, extensively tested)
- **Mitigation:**
  - Extensive testing against historical data
  - Manual review of converted templates
  - Parallel run V2/V3 for 1 month
  - Rollback plan if discrepancies > $0.01

**Risk #2: Missing Recent Historical Reports**

- **Impact:** MEDIUM - Vendors lose visibility into recent activity
- **Probability:** LOW
- **Mitigation:**
  - 12-month filter captures all operationally relevant reports
  - V2 backup remains accessible for older reports
  - Vendor notification about report availability

**Risk #3: Missing Vendor Users**

- **Impact:** MEDIUM - Vendors can't access system
- **Probability:** LOW
- **Mitigation:**
  - Pre-migration query to identify all active vendors
  - Validate email addresses work
  - Test login before go-live

**Risk #4: Orphaned Restaurant Assignments**

- **Impact:** MEDIUM - Missing commission calculations
- **Probability:** LOW
- **Mitigation:**
  - FK integrity checks after each script
  - Rollback on any orphan detection

---

### 9.2 Rollback Plan

**If migration fails at any step:**

1. **DROP all V3 vendor tables**
   ```sql
   DROP TABLE IF EXISTS menuca_v3.vendor_commission_reports CASCADE;
   DROP TABLE IF EXISTS menuca_v3.vendor_statement_numbers CASCADE;
   DROP TABLE IF EXISTS menuca_v3.vendor_restaurants CASCADE;
   DROP TABLE IF EXISTS menuca_v3.vendors CASCADE;
   -- Note: Commission templates are Edge Functions (not database tables)
   -- Do NOT drop admin_users (shared table)
   ```

2. **Re-run from failed step**
   - Fix script error
   - Re-create tables
   - Resume from failing script

3. **Validate V2 data still intact**
   ```sql
   SELECT COUNT(*) FROM menuca_v2.admin_users WHERE `group` = 12;
   -- Should be unchanged
   ```

---

## Summary

**Data to Migrate:**

| Entity | Source | Staging Table | V3 Table | Est. Rows |
|--------|--------|---------------|----------|-----------|
| Vendor Users | V2 admin_users (group=12) | staging.v2_vendor_users | menuca_v3.vendors | ? |
| Restaurant Links + Commission Config | V2 admin_users_restaurants + vendor_splits | staging.v2_vendor_restaurant_assignments | menuca_v3.vendor_restaurants | ~19 |
| Commission Templates | - | - | Edge Function (TypeScript) | 2 |
| Statement Numbers | V2 vendor_reports_numbers | staging.v2_vendor_reports_numbers | menuca_v3.vendor_statement_numbers | 2 |
| Historical Reports | V2 vendor_reports (12mo filter) | staging.v2_vendor_reports_recent | menuca_v3.vendor_commission_reports | ~40-50 |

**Note:** `vendor_commission_extra` from `restaurants_fees` is excluded (only applies to test restaurant 1595).

**NOT Migrating:**

- V1 `vendors` table (deprecated, BLOB-based)
- V1 `vendor_users` table (replaced in V2)
- V1 `vendors_restaurants` (replaced in V2)
- V1 `vendors_reports` (different format)
- V1 `vendors_payableto` (replaced by billing_info)
- Historical reports older than 12 months (available in V2 backup)
- Test accounts (filtered by active='y')
- Vendors with zero restaurants
- `vendor_commission_extra` from `restaurants_fees` (only applies to test restaurant 1595)

**Key Decisions:**

- ✅ **Historical Reports**: Only migrate last 12 months (~40-50 reports vs 493 total)
- ✅ **CSV Staging**: Add CSV extraction and staging phases before V3 migration
- ✅ **Template Conversion**: Hard-code the 2 templates as PHP functions (safest, simplest)
- ✅ **Phase 5 Migration**: Migrate from staging tables, NOT directly from menuca_v2

**Effort Estimate:**

- CSV extraction: 2-4 hours
- Staging table setup: 2-3 hours
- Schema design: 4-6 hours
- Script development: 10-14 hours
- Template PHP implementation: 6-8 hours
- Testing & validation: 8-12 hours
- **Total: 32-47 hours**

**Go/No-Go Criteria:**

- ✅ All row counts match staging
- ✅ Zero orphaned FK records
- ✅ All calculations accurate within $0.01
- ✅ Templates converted and validated
- ✅ Test vendor can log in and view reports
- ✅ 12-month report filter validated

### Migration Phases Summary

```
V2 Database → CSV Files → Staging Tables → V3 Production
              (Phase 2)    (Phase 4)        (Phase 6)
```

1. **Phase 1**: Analyze V1 legacy (read-only, documentation)
2. **Phase 2**: Extract V2 → CSV (with filters: active='y', 12-month reports)
3. **Phase 3**: Analyze & convert templates (hard-code as PHP functions)
4. **Phase 4**: Create staging tables (load CSVs)
5. **Phase 5**: Design V3 schema (vendor_commission_*, vendor_reports_archive)
6. **Phase 6**: Migrate staging → V3 (6 migration scripts)
7. **Phase 7**: Post-migration validation (row counts, FK integrity, calc accuracy)
8. **Phase 8**: Execution guide (step-by-step)
9. **Phase 9**: Risk assessment & rollback plan


