# Commission Formula Update - Summary of Changes

## Date: October 14, 2025

---

## What Changed

The `percent_commission` formula was simplified from a **3-way split** to a **2-way split**.

### Old Formula (Before):
```
$10,000 × 10% = $1,000 (commission)
$1,000 - $80 = $920 (after fixed fee)
$920 ÷ 2 = $460 → Vendor
$460 ÷ 2 = $230 → James
$460 ÷ 2 = $230 → Menu.ca

Result:
- Vendor: $460 (46%)
- James: $230 (23%)
- Menu.ca: $310 ($80 + $230 = 31%)
```

### New Formula (After):
```
$10,000 × 10% = $1,000 (commission)
$1,000 - $80 = $920 (after fixed fee)
$920 ÷ 2 = $460 → Vendor (Menu Ottawa)
$920 ÷ 2 = $460 → Menu.ca

Result:
- Vendor (Menu Ottawa): $460 (46%)
- Menu.ca: $540 ($80 + $460 = 54%)
```

---

## Key Differences

| Aspect | Old Formula | New Formula |
|--------|-------------|-------------|
| **Splits** | 3-way (Vendor, James, Menu.ca) | 2-way (Vendor, Menu.ca) |
| **Vendor Share** | $460 (46%) | $460 (46%) ✅ UNCHANGED |
| **Menu.ca Share** | $310 (31%) | $540 (54%) ⬆️ INCREASED |
| **James Share** | $230 (23%) | $0 (removed) ❌ ELIMINATED |
| **Code Complexity** | 4 calculation steps | 3 calculation steps |

---

## Files Updated

All three documentation files were updated to reflect the new formula:

### 1. `PERCENT_COMMISSION_EXPLAINED.md`
- ✅ Updated step-by-step calculation (removed Step 4)
- ✅ Updated final distribution table
- ✅ Updated visual breakdown
- ✅ Updated all 3 examples (small, large, different rate)
- ✅ Updated formulas and math sections
- ✅ Removed all "James" references
- ✅ Updated comparison with V2
- ✅ Updated summary sentence

### 2. `PHASE_3_EXPLANATION.md`
- ✅ Updated calculation description
- ✅ Updated example calculation
- ✅ Updated TypeScript code structure
- ✅ Updated expected API response
- ✅ Updated security comparison
- ✅ Updated calculation accuracy table

### 3. `vendor-business-logic-analysis.plan.md` (Main Plan)
- ✅ Updated Phase 3.1 V2 PHP code example
- ✅ Updated Phase 3.2 TypeScript Edge Function code
- ✅ Updated `CommissionResult` interface (removed `for_james`, added `for_menuca`)
- ✅ Updated validation test expectations
- ✅ Updated metadata description
- ✅ Updated sample JSON result
- ✅ Updated all critical security issue examples

---

## Code Changes Summary

### TypeScript Interface Changes

**Before:**
```typescript
interface CommissionResult {
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
  use_total: number
  for_vendor: number
  for_james: number  // ❌ Removed
}
```

**After:**
```typescript
interface CommissionResult {
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
  use_total: number
  for_vendor: number
  for_menuca: number  // ✅ Added
}
```

### Calculation Logic Changes

**Before:**
```typescript
const tenPercent = data.total * (data.restaurant_commission / 100)
const firstSplit = tenPercent - data.menuottawa_share
const forVendor = firstSplit / 2
const forJames = forVendor / 2  // ❌ Removed

return {
  for_vendor: Math.round(forVendor * 100) / 100,
  for_james: Math.round(forJames * 100) / 100  // ❌ Removed
}
```

**After:**
```typescript
const totalCommission = data.total * (data.restaurant_commission / 100)
const afterFixedFee = totalCommission - data.menuottawa_share
const forVendor = afterFixedFee / 2
const forMenuca = afterFixedFee / 2  // ✅ Added

return {
  for_vendor: Math.round(forVendor * 100) / 100,
  for_menuca: Math.round(forMenuca * 100) / 100  // ✅ Added
}
```

---

## Impact on V3 Migration

### No Impact on:
- ✅ CSV extraction (Phase 2) - already complete
- ✅ Data counts - same number of restaurants, vendors, templates
- ✅ Vendor share calculation - still $460 for $10,000 example
- ✅ Database schema design (Phase 5)
- ✅ Migration scripts (Phase 6)

### Impacts:
- ⚠️ **Edge Function implementation** - must use new 2-way split logic
- ⚠️ **Validation tests** - must check `for_menuca` instead of `for_james`
- ⚠️ **API responses** - JSON will have `for_menuca` field instead of `for_james`
- ⚠️ **Report generation** - PDF reports will show 2 parties instead of 3

---

## Testing Requirements

When implementing Phase 3, ensure:

1. **Unit Test Update**:
   ```typescript
   // Expected: (10000 * 0.10 - 80) / 2 = 920 / 2 = 460
   assertEquals(result.for_vendor, 460.00, 'Vendor amount calculation failed')
   assertEquals(result.for_menuca, 460.00, 'Menu.ca amount calculation failed')
   // ❌ Remove: assertEquals(result.for_james, 230.00)
   ```

2. **API Response Validation**:
   ```json
   {
     "for_vendor": 460.00,
     "for_menuca": 460.00
   }
   ```

3. **Historical Accuracy**:
   - Verify vendor amounts match V2 historical data ($460 in example)
   - Menu.ca total increases from $310 to $540 (expected change)

---

## Migration Phase Status

| Phase | Status | Impact from Formula Change |
|-------|--------|---------------------------|
| Phase 1: V1 Analysis | ✅ Complete | None |
| Phase 2: CSV Extraction | ✅ Complete | None |
| Phase 3: Template Conversion | 🔄 Ready to implement | ✅ Updated with new formula |
| Phase 4: Staging Tables | ⏳ Pending | None |
| Phase 5: V3 Schema | ⏳ Pending | None |
| Phase 6: Migration Scripts | ⏳ Pending | None |

---

## Summary

✅ **Formula simplified**: From 3-way to 2-way split
✅ **Vendor share unchanged**: Still receives $460 on $10,000 example
✅ **Menu.ca share increased**: From $310 to $540 on $10,000 example
✅ **"James" eliminated**: No longer part of commission split
✅ **All documentation updated**: 3 files fully synchronized
✅ **Code ready for Phase 3**: TypeScript Edge Function reflects new logic

**Next Step**: Proceed with Phase 3 implementation using the updated 2-way split formula.

