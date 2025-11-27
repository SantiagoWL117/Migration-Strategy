# `percent_commission` Formula Update - Support for Fixed Commission Amounts

## Summary of Changes

The `percent_commission` formula has been updated to support **BOTH** commission calculation methods:

1. **Percentage-based** (original): Commission calculated as % of order total
2. **Fixed amount** (new): Commission is a fixed dollar amount

---

## Why This Change?

Not all restaurants pay commission as a percentage. Some restaurants have negotiated **fixed commission amounts** per order or per period. The formula now supports both scenarios:

- **Restaurant A**: Pays 10% commission → Use `commission_type: 'percentage'`
- **Restaurant B**: Pays $150 fixed commission → Use `commission_type: 'fixed'`

---

## How It Works

### New Parameter: `commission_type`

**Type**: `'percentage' | 'fixed'` (optional, defaults to `'percentage'`)

**Usage**:
- If `commission_type = 'percentage'` (or omitted): Calculate commission as `total × (restaurant_commission / 100)`
- If `commission_type = 'fixed'`: Use `restaurant_commission` as the commission amount directly

---

## Example Calculations

### Example 1: Percentage-based Commission (Original Behavior)

**Input**:
```json
{
  "template_name": "percent_commission",
  "total": 10000.00,
  "restaurant_commission": 10,
  "commission_type": "percentage",
  "menuottawa_share": 80.00
}
```

**Calculation**:
```
Step 1: Calculate commission
  → $10,000 × 10% = $1,000

Step 2: Subtract fixed fee
  → $1,000 - $80 = $920

Step 3: Split 50/50
  → Vendor: $920 ÷ 2 = $460
  → Menu.ca share: $920 ÷ 2 = $460

Step 4: Add fixed fee to Menu.ca
  → Menu.ca total: $80 + $460 = $540
```

**Result**:
- Vendor: $460
- Menu.ca: $540

---

### Example 2: Fixed Commission Amount (New Feature)

**Input**:
```json
{
  "template_name": "percent_commission",
  "total": 10000.00,
  "restaurant_commission": 1200.00,
  "commission_type": "fixed",
  "menuottawa_share": 80.00
}
```

**Calculation**:
```
Step 1: Use fixed commission
  → Commission = $1,200 (NOT calculated, just used as-is)

Step 2: Subtract fixed fee
  → $1,200 - $80 = $1,120

Step 3: Split 50/50
  → Vendor: $1,120 ÷ 2 = $560
  → Menu.ca share: $1,120 ÷ 2 = $560

Step 4: Add fixed fee to Menu.ca
  → Menu.ca total: $80 + $560 = $640
```

**Result**:
- Vendor: $560
- Menu.ca: $640

---

### Example 3: Small Fixed Commission

**Input**:
```json
{
  "template_name": "percent_commission",
  "total": 5000.00,
  "restaurant_commission": 250.00,
  "commission_type": "fixed",
  "menuottawa_share": 80.00
}
```

**Calculation**:
```
Step 1: Use fixed commission
  → Commission = $250

Step 2: Subtract fixed fee
  → $250 - $80 = $170

Step 3: Split 50/50
  → Vendor: $170 ÷ 2 = $85
  → Menu.ca share: $170 ÷ 2 = $85

Step 4: Add fixed fee to Menu.ca
  → Menu.ca total: $80 + $85 = $165
```

**Result**:
- Vendor: $85
- Menu.ca: $165

---

## Comparison Table

| Order Total | Commission Input | Type | Commission Amount | Vendor Gets | Menu.ca Gets |
|-------------|------------------|------|-------------------|-------------|--------------|
| $10,000 | 10 | percentage | $1,000 | $460 | $540 |
| $10,000 | 1200.00 | fixed | $1,200 | $560 | $640 |
| $5,000 | 12 | percentage | $600 | $260 | $340 |
| $5,000 | 250.00 | fixed | $250 | $85 | $165 |
| $20,000 | 10 | percentage | $2,000 | $960 | $1,040 |
| $20,000 | 800.00 | fixed | $800 | $360 | $440 |

---

## Code Changes

### TypeScript Interface Update

```typescript
interface CommissionInput {
  template_name: string
  total: number
  restaurant_commission: number  // Can be % (10) OR fixed amount (1200.00)
  commission_type?: 'percentage' | 'fixed'  // NEW: Optional, defaults to 'percentage'
  menuottawa_share: number
  vendor_id: number
  restaurant_id: number
  restaurant_name: string
  restaurant_address: string
}
```

### Function Logic Update

```typescript
function calculatePercentCommission(data: CommissionInput): CommissionResult {
  let totalCommission: number
  
  // NEW: Determine commission calculation method
  const commissionType = data.commission_type || 'percentage'
  
  if (commissionType === 'fixed') {
    // NEW: Use commission as fixed dollar amount
    totalCommission = data.restaurant_commission
  } else {
    // EXISTING: Calculate commission as percentage
    totalCommission = data.total * (data.restaurant_commission / 100)
  }
  
  // Rest of calculation remains the same
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare
  
  return {
    // ... results
  }
}
```

---

## Test Coverage

Three new test cases added:

1. ✅ **Test 1**: Percentage-based (existing test, validates original behavior)
2. ✅ **Test 2**: Fixed commission - large amount ($1,200)
3. ✅ **Test 3**: Fixed commission - small amount ($250)

---

## Backward Compatibility

✅ **100% Backward Compatible**

- If `commission_type` is **NOT** provided, it defaults to `'percentage'`
- Existing API calls will continue to work exactly as before
- No breaking changes

**Examples**:
```json
// Old call (still works):
{
  "restaurant_commission": 10
}
// Interpreted as: commission_type = 'percentage'

// New call (explicit):
{
  "restaurant_commission": 10,
  "commission_type": "percentage"
}
// Same result as above

// New feature:
{
  "restaurant_commission": 1200.00,
  "commission_type": "fixed"
}
// Interpreted as: $1,200 fixed commission
```

---

## Migration Impact

### Database Schema
No changes needed to the database schema. The `commission_type` is determined at **runtime** based on the restaurant's configuration.

### Storing Commission Configuration
You'll need to track in your database (likely in `restaurants_fees` or `vendor_commission_assignments`):

**Option 1: Separate columns**
```sql
ALTER TABLE restaurants_fees 
ADD COLUMN commission_value DECIMAL(10,2),
ADD COLUMN commission_type VARCHAR(20) DEFAULT 'percentage';
```

**Option 2: JSONB metadata**
```sql
ALTER TABLE restaurants_fees
ADD COLUMN commission_config JSONB;

-- Example data:
{
  "value": 10,
  "type": "percentage"
}

-- Or:
{
  "value": 1200.00,
  "type": "fixed"
}
```

---

## Use Cases

### When to Use Percentage
- Restaurants with variable sales volumes
- Commission scales with revenue
- Standard industry practice (10%, 12%, 15%)

### When to Use Fixed Amount
- Restaurants with consistent order volumes
- Negotiated flat-rate agreements
- Simplified accounting (predictable costs)
- Small restaurants preferring fixed costs

---

## API Examples

### curl Test - Percentage
```bash
curl -X POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  -H 'Content-Type: application/json' \
  -d '{
    "template_name": "percent_commission",
    "total": 10000,
    "restaurant_commission": 10,
    "commission_type": "percentage",
    "menuottawa_share": 80,
    "vendor_id": 2,
    "restaurant_id": 123,
    "restaurant_name": "Percentage Restaurant",
    "restaurant_address": "123 Main St"
  }'
```

### curl Test - Fixed
```bash
curl -X POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  -H 'Content-Type: application/json' \
  -d '{
    "template_name": "percent_commission",
    "total": 10000,
    "restaurant_commission": 1200.00,
    "commission_type": "fixed",
    "menuottawa_share": 80,
    "vendor_id": 2,
    "restaurant_id": 456,
    "restaurant_name": "Fixed Commission Restaurant",
    "restaurant_address": "456 Oak Ave"
  }'
```

---

## Summary

✅ **Feature Added**: Support for fixed commission amounts
✅ **Backward Compatible**: Existing calls continue to work
✅ **Type Safe**: TypeScript ensures correct types
✅ **Tested**: 3 test cases covering both scenarios
✅ **Flexible**: Supports both percentage and fixed amount per restaurant
✅ **Menu.ca Still Gets**: $80 fixed + their share (unchanged)

The formula now handles the real-world scenario where different restaurants have different commission structures!


