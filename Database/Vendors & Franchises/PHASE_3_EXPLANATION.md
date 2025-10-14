# Phase 3: Template Code Analysis & Conversion - DETAILED EXPLANATION

## Overview

**Purpose**: Convert the insecure PHP `eval()` template from V2 into a safe, type-checked Supabase Edge Function (TypeScript/Deno).

**Status**: Ready to implement after CSV data extraction is complete.

---

## What Phase 3 Accomplishes

1. **Eliminates Security Vulnerability**: Removes the `eval()` call that executes arbitrary PHP code from the database
2. **Modernizes Calculation Logic**: Converts PHP to TypeScript/Deno for Supabase
3. **Maintains Calculation Accuracy**: Preserves exact commission calculation formulas
4. **Provides Testing Framework**: Includes validation tests to ensure accuracy

---

## Sub-Phases Breakdown

### **3.1: Extract Existing Template** (Analysis Phase)

**What it does**: Documents the current V2 PHP template code for reference.

**Your tasks**:
- ✅ **READ ONLY** - No action required
- Review the documented PHP code to understand current logic
- Compare with CSV data from `v2_vendor_splits_templates.csv`

**Key Information**:

**Template #1: `mazen_milanos` (ID: 1)** ✅ ACTIVE
- **Calculation Type**: Gross-based commission
- **Vendor Share**: 30% of total upfront
- **Collection**: Based on convenience fee multiplier (typically 2.0×)
- **Menu.ca Share**: Half of (collection - vendor 30% - $80 fixed)

**Template #2: `percent_commission` (ID: 2)** ✅ ACTIVE  
- **Used by**: 12+ active restaurants
- **Calculation Type**: Net-based commission split
- **Process**:
  - Takes 10% of order total (configurable per restaurant)
  - Subtracts fixed $80 fee (Menu.ca's share)
  - Splits remainder 50/50 between vendor (Menu Ottawa) and Menu.ca

**Example Calculation #1 (mazen_milanos)**:
```
Order Total: $10,000
Convenience Fee Multiplier: 2.0×

Step 1: $10,000 × 30% = $3,000 (vendor gets this upfront)
Step 2: $10,000 × 2.0 = $20,000 (collection from convenience fees)
Step 3: ($20,000 - $3,000 - $80) ÷ 2 = $8,460 (Menu.ca gets this)

Result:
- Vendor receives: $3,000
- Menu.ca receives: $8,540 ($80 fixed + $8,460)
- Total distributed: $11,540 (exceeds order due to convenience fees)
```

**Example Calculation #2 (percent_commission)**:
```
Order Total: $10,000
Restaurant Commission: 10%

Step 1: $10,000 × 10% = $1,000
Step 2: $1,000 - $80 (fixed fee) = $920
Step 3: $920 ÷ 2 = $460 (for vendor - Menu Ottawa)
        $920 ÷ 2 = $460 (for Menu.ca)

Result:
- Vendor (Menu Ottawa) receives: $460
- Menu.ca receives: $540 ($80 fixed + $460)
- Total distributed: $1,000
```

**Critical Note**: The V2 code uses `eval()` to execute this calculation, which is a severe security risk:
```php
// V2 INSECURE CODE (DON'T USE):
eval($breakdown);  // Executes arbitrary code from database!
```

---

### **3.2: Convert to Supabase Edge Function** (Implementation Phase)

**What it does**: Creates a new TypeScript-based serverless function on Supabase to replace the PHP template.

**Your tasks**:

#### **Task A: Create Edge Function File**

1. **Location**: `supabase/functions/calculate-vendor-commission/index.ts`
2. **Action**: Copy the provided TypeScript code (see plan section 3.2.A)
3. **What it does**:
   - Accepts commission calculation requests via HTTP POST
   - Validates input (template name must be 'percent_commission' OR 'mazen_milanos')
   - Routes to appropriate calculation function
   - Performs type-safe calculation
   - Returns JSON result

**Code Structure**:
```typescript
// Defines input data structure
interface CommissionInput { 
  template_name: string
  total: number
  restaurant_commission?: number  // For percent_commission
  restaurant_convenience_fee?: number  // For mazen_milanos
  menuottawa_share: number
  // ... other fields
}

// Defines output data structure  
interface CommissionResult { ... }

// Calculation function #1: percent_commission (NET basis)
function calculatePercentCommission(data: CommissionInput): CommissionResult {
  const totalCommission = data.total * (data.restaurant_commission / 100)
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenuca = afterFixedFee / 2
  return { /* results */ }
}

// Calculation function #2: mazen_milanos (GROSS basis)
function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  const forVendor = data.total * 0.3  // 30% upfront
  const collection = data.total * (data.restaurant_convenience_fee ?? 2.00)
  const forMenuca = (collection - forVendor - data.menuottawa_share) / 2
  return { /* results */ }
}

// HTTP server handler with routing
serve(async (req) => {
  if (template_name === 'percent_commission') {
    result = calculatePercentCommission(input)
  } else if (template_name === 'mazen_milanos') {
    result = calculateMazenMilanos(input)
  }
  // ... return result
})
```

#### **Task B: Create PostgreSQL Wrapper Function** (OPTIONAL)

1. **Purpose**: Allows database triggers or RPC calls to invoke the Edge Function
2. **Action**: Run the SQL script (see plan section 3.2.B) in Supabase SQL Editor
3. **What it does**:
   - Provides a PostgreSQL function interface
   - Calls the Edge Function via HTTP using `pg_net` extension
   - Returns JSONB result

**When to use**:
- If you need to call commission calculations from database triggers
- If you want to generate reports directly via SQL queries
- If other database functions need commission calculations

**When to skip**:
- If you only call commission calculations from your backend API
- If you prefer direct HTTP calls to the Edge Function

#### **Task C: Update Template Metadata**

1. **Purpose**: Store template configuration in PostgreSQL
2. **Action**: When creating the V3 `vendor_commission_templates` table, insert this JSONB metadata
3. **What it does**:
   - Links template record to Edge Function
   - Documents calculation logic for future reference
   - Stores fixed parameters (e.g., `menuottawa_share: 80.00`)

**Example INSERT** (will be in Phase 5):
```sql
INSERT INTO menuca_v3.vendor_commission_templates (
  id, name, commission_from, menuottawa_share, 
  enabled, metadata, created_at
) VALUES (
  2, 
  'percent_commission', 
  'net', 
  80.00, 
  true,
  '{
    "edge_function": "calculate-vendor-commission",
    "description": "10% commission split 50/50 between vendor and platform after $80 fixed fee",
    "calculation_notes": "forVendor = (total * commission% - fixed_fee) / 2 / 2"
  }'::jsonb,
  NOW()
);
```

#### **Task D: Create Validation Tests**

1. **Purpose**: Ensure calculation accuracy matches V2 behavior
2. **Action**: Create test file `supabase/functions/calculate-vendor-commission/test_commission_calculator.ts`
3. **What it does**:
   - Tests calculation with known inputs
   - Verifies output matches expected values
   - Catches regression errors

**How to run**:
```bash
cd supabase/functions/calculate-vendor-commission
deno test test_commission_calculator.ts
```

**Expected output**:
```
running 1 test from ./test_commission_calculator.ts
percent_commission calculation accuracy ... ok (2ms)

ok | 1 passed | 0 failed (5ms)
```

#### **Task E: Deploy Edge Function**

1. **Prerequisites**:
   - Supabase CLI installed
   - Logged into your Supabase project
   
2. **Commands**:

```bash
# Test locally first
supabase functions serve calculate-vendor-commission

# In another terminal, test with curl:
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "template_name": "percent_commission",
    "total": 10000,
    "restaurant_commission": 10,
    "menuottawa_share": 80,
    "vendor_id": 2,
    "restaurant_id": 123,
    "restaurant_name": "Test Restaurant",
    "restaurant_address": "123 Main St"
  }'

# Expected response:
# {
#   "vendor_id": 2,
#   "restaurant_id": 123,
#   "restaurant_name": "Test Restaurant",
#   "restaurant_address": "123 Main St",
#   "use_total": 10000.00,
#   "for_vendor": 460.00,
#   "for_menuca": 460.00
# }

# If test passes, deploy to production:
supabase functions deploy calculate-vendor-commission
```

3. **Production URL** (after deployment):
```
https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-vendor-commission
```

---

## Phase 3 Checklist

### Analysis (3.1)
- [ ] Review documented V2 template code for BOTH templates
- [ ] Verify CSV extraction captured both templates correctly
- [ ] Confirm template ID 1 (mazen_milanos) is active
- [ ] Confirm template ID 2 (percent_commission) is active

### Implementation (3.2)
- [ ] **Task A**: Create Edge Function file (`index.ts`)
- [ ] **Task B** (Optional): Create PostgreSQL wrapper function
- [ ] **Task C**: Prepare template metadata JSONB
- [ ] **Task D**: Create validation test file
- [ ] **Task E**: Test Edge Function locally
- [ ] **Task E**: Deploy Edge Function to Supabase

### Verification
- [ ] Local test passes with expected values
- [ ] Production Edge Function responds correctly
- [ ] Function logs show no errors in Supabase dashboard

---

## Important Notes

### ⚠️ Important Notes

1. **Both templates are ACTIVE**:
   - `mazen_milanos` (ID 1) - Gross-based calculation (30% vendor share)
   - `percent_commission` (ID 2) - Net-based calculation (50/50 split)

2. **Test restaurant excluded**:
   - Restaurant 1595 is excluded from all queries

3. **Duplicate assignments noted**:
   - Vendor user #2 (Menu Ottawa) and #65 (Darrell Corcoran) both manage same restaurants
   - Left as-is for post-migration clarification

### 🔐 Security Improvements

**Before (V2)**:
```php
// INSECURE - executes arbitrary code
$breakdown = "##total## * 0.5";  // Stored in database
eval($breakdown);  // 💀 DANGER!
```

**After (V3)**:
```typescript
// SECURE - type-safe, explicit code
function calculatePercentCommission(data: CommissionInput): CommissionResult {
  const totalCommission = data.total * (data.restaurant_commission / 100)
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenuca = afterFixedFee / 2
  return { for_vendor: forVendor, for_menuca: forMenuca };  // ✅ SAFE
}
```

### 📊 Calculation Accuracy

The Edge Function implements the **EXACT** same calculation logic as V2:

**percent_commission Template**:

| Step | V2 PHP | V3 TypeScript |
|------|--------|---------------|
| 1. Calculate commission | `##total##*(##restaurant_commission## / 100)` | `data.total * (data.restaurant_commission / 100)` |
| 2. Subtract fixed fee | `$totalCommission - ##menuottawa_share##` | `totalCommission - data.menuottawa_share` |
| 3. Split vendor share | `$afterFixedFee / 2` | `afterFixedFee / 2` |
| 4. Split Menu.ca share | `$afterFixedFee / 2` | `afterFixedFee / 2` |

**mazen_milanos Template**:

| Step | V2 PHP | V3 TypeScript |
|------|--------|---------------|
| 1. Vendor 30% upfront | `##total## * 0.3` | `data.total * 0.3` |
| 2. Calculate collection | `##total## * ##restaurant_convenience_fee##` | `data.total * (data.restaurant_convenience_fee ?? 2.00)` |
| 3. Menu.ca share | `($collection - $forVendor - ##menuottawa_share##) / 2` | `(collection - forVendor - data.menuottawa_share) / 2` |

**Validation**: The test suite ensures calculations match V2 output to the penny.

---

## After Phase 3

Once Phase 3 is complete, you'll have:

1. ✅ Secure commission calculation logic deployed to Supabase
2. ✅ No more `eval()` security vulnerabilities
3. ✅ Verified calculation accuracy
4. ✅ Foundation for Phase 4 (staging tables) and Phase 5 (V3 schema)

**Next Step**: Proceed to Phase 4 (Create Staging Tables in PostgreSQL)

