# Both Templates Migration - Update Summary

## Date: October 14, 2025

---

## What Changed

After reviewing with colleagues, confirmed that **BOTH commission templates are ACTIVE** and must be migrated.

### Previous Plan:
- ❌ Only `percent_commission` (ID 2)
- ❌ Excluded `mazen_milanos` (ID 1) - assumed only used by suspended restaurant

### Updated Plan:
- ✅ **BOTH templates** must be migrated
  - `mazen_milanos` (ID 1) - Gross-based calculation
  - `percent_commission` (ID 2) - Net-based calculation

---

## Template Comparison

| Aspect | `mazen_milanos` | `percent_commission` |
|--------|-----------------|---------------------|
| **ID** | 1 | 2 |
| **Basis** | GROSS (total with fees) | NET (commission only) |
| **Vendor Share** | 30% of total upfront | 46% of commission (after split) |
| **Calculation** | Collection-based | Percentage-based |
| **Variables** | `restaurant_convenience_fee` | `restaurant_commission` |
| **Example** ($10k) | Vendor: $3,000 | Vendor: $460 |
| **Menu.ca** ($10k) | $8,540 | $540 |

---

## mazen_milanos Formula

```
Step 1: Vendor = Total × 30%
Step 2: Collection = Total × Convenience Fee Multiplier  
Step 3: Menu.ca = (Collection - Vendor - $80 fixed) ÷ 2

Example ($10,000 with 2.0× multiplier):
- Vendor: $10,000 × 0.30 = $3,000
- Collection: $10,000 × 2.00 = $20,000
- Menu.ca: ($20,000 - $3,000 - $80) ÷ 2 = $8,460
- Total: Menu.ca gets $80 + $8,460 = $8,540
```

---

## Files Updated

### 1. `vendor-business-logic-analysis.plan.md` (Main Plan)

**Critical Requirements**:
- ✅ Added both templates to "Must Migrate" section
- ✅ Removed `mazen_milanos` from exclusions
- ✅ Updated Phase 2.3 query to export both templates
- ✅ Updated Phase 2.4 query to include all template assignments
- ✅ Updated Phase 3.1 to document both templates
- ✅ Updated Phase 3.2 Edge Function code to handle both templates
- ✅ Added validation tests for both templates

**Key Code Changes**:
```typescript
// Now handles BOTH templates
if (input.template_name === 'percent_commission') {
  result = calculatePercentCommission(input)
} else if (input.template_name === 'mazen_milanos') {
  result = calculateMazenMilanos(input)
}
```

### 2. `PHASE_3_EXPLANATION.md`

- ✅ Updated key information to describe both templates
- ✅ Added example calculations for both formulas
- ✅ Updated code structure to show both functions
- ✅ Updated validation tasks to cover both templates
- ✅ Updated accuracy comparison tables

### 3. New File: `MAZEN_MILANOS_EXPLAINED.md`

Created comprehensive plain-English explanation of the `mazen_milanos` formula:
- Step-by-step calculation
- Visual breakdown
- Real-world examples
- Comparison with `percent_commission`
- V2 vs V3 code comparison

---

## TypeScript Implementation

### Interface (Updated):

```typescript
interface CommissionInput {
  template_name: string
  total: number
  restaurant_commission?: number  // Optional: for percent_commission
  restaurant_convenience_fee?: number  // Optional: for mazen_milanos
  menuottawa_share: number
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
}
```

### Function #1: mazen_milanos

```typescript
function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  // GROSS basis calculation
  const forVendor = data.total * 0.3  // 30% upfront
  const collection = data.total * (data.restaurant_convenience_fee ?? 2.00)
  const forMenuca = (collection - forVendor - data.menuottawa_share) / 2
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menuca: Math.round(forMenuca * 100) / 100
  }
}
```

### Function #2: percent_commission

```typescript
function calculatePercentCommission(data: CommissionInput): CommissionResult {
  // NET basis calculation
  const totalCommission = data.total * ((data.restaurant_commission ?? 10) / 100)
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenuca = afterFixedFee / 2
  
  return {
    vendor_id: data.vendor_id,
    restaurant_id: data.restaurant_id,
    restaurant_name: data.restaurant_name,
    restaurant_address: data.restaurant_address,
    use_total: Math.round(data.total * 100) / 100,
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menuca: Math.round(forMenuca * 100) / 100
  }
}
```

---

## Validation Tests

### Test #1: mazen_milanos
```typescript
Deno.test("mazen_milanos calculation accuracy", () => {
  const testData = {
    template_name: 'mazen_milanos',
    total: 10000.00,
    restaurant_convenience_fee: 2.00,
    menuottawa_share: 80.00,
    vendor_id: 1,
    restaurant_id: 1171,
    restaurant_name: 'Pho Dau Bo',
    restaurant_address: '456 King St'
  }
  
  const result = calculateMazenMilanos(testData)
  
  // Expected: 
  // forVendor = 10000 * 0.30 = 3000
  // collection = 10000 * 2.00 = 20000
  // forMenuca = (20000 - 3000 - 80) / 2 = 8460
  assertEquals(result.for_vendor, 3000.00)
  assertEquals(result.for_menuca, 8460.00)
})
```

### Test #2: percent_commission
```typescript
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
  
  // Expected: (10000 * 0.10 - 80) / 2 = 460
  assertEquals(result.for_vendor, 460.00)
  assertEquals(result.for_menuca, 460.00)
})
```

---

## Phase 2 Query Updates

### 2.3: Export Templates (BOTH)

**Before**:
```sql
WHERE enabled = 'y'
  AND id = 2;  -- Only percent_commission
```

**After**:
```sql
WHERE enabled = 'y';  -- BOTH templates
```

### 2.4: Export Commission Assignments (ALL)

**Before**:
```sql
WHERE vst.enabled = 'y' 
  AND r.active = 'y'
  AND vs.template_id = 2  -- Only percent_commission
```

**After**:
```sql
WHERE vst.enabled = 'y' 
  AND r.active = 'y'  -- Both templates included
```

---

## Migration Impact

### ✅ No Impact On:
- Vendor user migration
- Restaurant assignments migration
- Statement numbers migration
- Historical reports migration
- Database schema design

### ⚠️ Impacts:
- **CSV Re-export Required**: Phase 2 queries must be re-run to capture both templates
- **Edge Function**: Now routes to two calculation functions
- **Testing**: Must validate both formulas
- **Documentation**: Three explanation files created

---

## Next Steps

### 1. Re-run Phase 2 CSV Exports (if needed)

If the current CSV files only have `percent_commission`, re-export with updated queries:

```bash
# 2.3: Templates (both)
SELECT * FROM vendor_splits_templates WHERE enabled = 'y'

# 2.4: Assignments (all active)
SELECT * FROM vendor_splits vs
WHERE vs.restaurant_id != 1595  -- Exclude only test restaurant
```

### 2. Proceed with Phase 3 Implementation

Using the updated code that handles both templates:
- Create single Edge Function with routing
- Deploy to Supabase
- Test both calculation paths
- Validate against V2 historical data

---

## Summary

✅ **Both templates confirmed ACTIVE**
✅ **mazen_milanos re-included** in migration strategy
✅ **Edge Function updated** to handle both calculation types
✅ **Documentation complete** for both formulas
✅ **Validation tests** cover both templates
✅ **All queries updated** to include both templates

**Key Difference**:
- `mazen_milanos`: Vendor gets **30% of gross** ($3,000 on $10k)
- `percent_commission`: Vendor gets **46% of net commission** ($460 on $10k with 10% commission)

Both formulas are now safely implemented in TypeScript with no `eval()` security vulnerabilities!

