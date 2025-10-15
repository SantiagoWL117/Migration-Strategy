# Calculate Vendor Commission - Supabase Edge Function

## Overview

This Edge Function replaces the insecure `eval()` PHP implementation from V2 with a secure, type-safe TypeScript implementation for calculating vendor commission splits.

## Supported Templates

### 1. `percent_commission`
- **Type**: NET basis
- **Commission**: Variable % per restaurant (e.g., 10%, 12%, 15%) OR fixed amount (e.g., $150.00)
- **Split**: 50/50 between vendor (Menu Ottawa) and Menu.ca after $80 fixed fee
- **Formula**:
  1. Calculate total commission: 
     - If `commission_type = 'percentage'`: `order_total × (commission_percentage / 100)`
     - If `commission_type = 'fixed'`: Use `restaurant_commission` as-is (fixed dollar amount)
  2. Subtract fixed fee: `commission - $80`
  3. Split remainder 50/50
  4. Menu.ca gets: `$80 + their_share`

### 2. `mazen_milanos`
- **Type**: Commission-based with 30% vendor priority
- **Commission**: Variable % per restaurant
- **Split**: 30% to vendor (Mazen) first, then 50/50 between Menu Ottawa and Menu.ca after $80 fixed fee
- **Formula**:
  1. Calculate total commission: `order_total × commission_percentage`
  2. Vendor (Mazen) gets 30% first: `commission × 0.3`
  3. Subtract fixed fee from remainder: `(commission - vendor_share) - $80`
  4. Split remainder 50/50 between Menu Ottawa and Menu.ca
  5. Menu.ca gets: `$80 + their_share`

## API Usage

### Request

**Endpoint**: `POST /calculate-vendor-commission`

**Headers**:
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer YOUR_ANON_KEY"
}
```

**Body (Percentage-based)**:
```json
{
  "template_name": "percent_commission",
  "total": 10000.00,
  "restaurant_commission": 10,
  "commission_type": "percentage",
  "menuottawa_share": 80.00,
  "vendor_id": 2,
  "restaurant_id": 123,
  "restaurant_name": "Test Restaurant",
  "restaurant_address": "123 Main St"
}
```

**Body (Fixed amount)**:
```json
{
  "template_name": "percent_commission",
  "total": 10000.00,
  "restaurant_commission": 1200.00,
  "commission_type": "fixed",
  "menuottawa_share": 80.00,
  "vendor_id": 2,
  "restaurant_id": 123,
  "restaurant_name": "Test Restaurant",
  "restaurant_address": "123 Main St"
}
```

**Note**: `commission_type` is optional and defaults to `'percentage'` if not provided.

### Response

**Success (200)**:
```json
{
  "vendor_id": 2,
  "restaurant_id": 123,
  "restaurant_name": "Test Restaurant",
  "restaurant_address": "123 Main St",
  "use_total": 10000.00,
  "for_vendor": 460.00,
  "for_menuca": 540.00
}
```

**Error (400)**:
```json
{
  "error": "Unknown template: invalid_template",
  "available_templates": ["percent_commission", "mazen_milanos"]
}
```

**Error (500)**:
```json
{
  "error": "Error message",
  "type": "ErrorType"
}
```

## Local Testing

### Run Tests
```bash
cd supabase/functions/calculate-vendor-commission
deno test test_commission_calculator.ts
```

### Serve Locally
```bash
supabase functions serve calculate-vendor-commission
```

### Test with curl
```bash
# Test percent_commission
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

# Test mazen_milanos with 10% commission
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "template_name": "mazen_milanos",
    "total": 10000,
    "restaurant_commission": 10,
    "menuottawa_share": 80,
    "vendor_id": 1,
    "restaurant_id": 1171,
    "restaurant_name": "Pho Dau Bo",
    "restaurant_address": "456 King St"
  }'

# Test mazen_milanos with 15% commission
curl -i --location --request POST 'http://localhost:54321/functions/v1/calculate-vendor-commission' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "template_name": "mazen_milanos",
    "total": 10000,
    "restaurant_commission": 15,
    "menuottawa_share": 80,
    "vendor_id": 1,
    "restaurant_id": 1171,
    "restaurant_name": "Pho Dau Bo",
    "restaurant_address": "456 King St"
  }'
```

## Deployment

```bash
# Deploy to Supabase
supabase functions deploy calculate-vendor-commission
```

## Security Improvements

### V2 (INSECURE) ❌
- Commission calculation logic stored as PHP code in database
- Executed using `eval()` - critical security vulnerability
- Arbitrary code execution possible
- No type safety

### V3 (SECURE) ✅
- Hard-coded, type-safe TypeScript functions
- No dynamic code execution
- Input validation
- Error handling
- Serverless, auto-scaling
- Native Supabase integration

## Calculation Examples

### percent_commission ($10,000 order, 10% commission)
```
Commission Type: percentage
Total Commission: $10,000 × 10% = $1,000
After Fixed Fee: $1,000 - $80 = $920
Vendor Share: $920 ÷ 2 = $460
Menu.ca Total: $80 + $460 = $540
```

### percent_commission ($10,000 order, $1,200 fixed commission)
```
Commission Type: fixed
Total Commission: $1,200 (fixed amount)
After Fixed Fee: $1,200 - $80 = $1,120
Vendor Share: $1,120 ÷ 2 = $560
Menu.ca Total: $80 + $560 = $640
```

### mazen_milanos ($10,000 order, 10% commission)
```
Total Commission: $10,000 × 10% = $1,000
Vendor (Mazen) 30%: $1,000 × 0.3 = $300
After Vendor: $1,000 - $300 = $700
After Fixed Fee: $700 - $80 = $620
Menu Ottawa: $620 ÷ 2 = $310
Menu.ca Total: $80 + $310 = $390
```

### mazen_milanos ($10,000 order, 15% commission)
```
Total Commission: $10,000 × 15% = $1,500
Vendor (Mazen) 30%: $1,500 × 0.3 = $450
After Vendor: $1,500 - $450 = $1,050
After Fixed Fee: $1,050 - $80 = $970
Menu Ottawa: $970 ÷ 2 = $485
Menu.ca Total: $80 + $485 = $565
```

## Notes

- **Menu.ca Always Gets**: Fixed $80 fee + their commission share
- **Commission Rate**: Variable per restaurant (stored in database)
- **Vendor Priority (mazen_milanos only)**: Vendor gets 30% of commission before other splits
- **Rounding**: All monetary values rounded to 2 decimal places

## Migration from V2

This function replaces the V2 templates:
- V2 Template ID 1: `mazen_milanos`
- V2 Template ID 2: `percent_commission`

The calculation logic is **identical** to V2, but implemented securely without `eval()`.

