# Deal Eligibility Validation - Replit Agent Handoff

> **Last Updated:** February 2, 2026  
> **Schema:** `menuca_v3`  
> **Function:** `validate_deal_eligibility()`

---

## Overview

The `validate_deal_eligibility` function validates whether a customer is eligible for a promotional deal before applying it to their order. It handles:

- **Deal existence and active status**
- **Minimum purchase requirements**
- **Service type restrictions** (pickup/delivery)
- **First-order-only deals** (per-restaurant, checks both logged-in users and guest emails)

**Primary Use Case:** Call this function during checkout, before applying any deal discount, to ensure the customer qualifies.

---

## Function Signature

```sql
menuca_v3.validate_deal_eligibility(
    p_deal_id bigint,                    -- Required: Deal ID to validate
    p_order_total numeric,               -- Required: Order subtotal before discount
    p_service_type varchar DEFAULT NULL, -- Optional: 'pickup' or 'delivery'
    p_customer_id bigint DEFAULT NULL,   -- Optional: User ID if logged in
    p_customer_email varchar DEFAULT NULL -- Optional: Customer email (guest or registered)
)
RETURNS TABLE(eligible boolean, reason varchar)
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `p_deal_id` | bigint | ✅ Yes | The ID of the promotional deal to validate |
| `p_order_total` | numeric | ✅ Yes | The order subtotal (before discounts/taxes) |
| `p_service_type` | varchar | ❌ No | Service type: `'pickup'`, `'delivery'`, or `NULL` |
| `p_customer_id` | bigint | ❌ No | The `users.id` if customer is logged in |
| `p_customer_email` | varchar | ❌ No | Customer's email address (for first-order validation) |

### Important Notes on Parameters

1. **For first-order deals:** You MUST provide either `p_customer_id` OR `p_customer_email` (or both)
2. **Email is case-insensitive:** `John@Example.com` matches `john@example.com`
3. **Guest checkout:** Pass `p_customer_email` even without `p_customer_id`

---

## Return Values

The function returns a single row with two columns:

| Column | Type | Description |
|--------|------|-------------|
| `eligible` | boolean | `true` if customer can use the deal, `false` otherwise |
| `reason` | varchar | Status code explaining the result |

### Reason Codes

| Code | Meaning | Customer Message Suggestion |
|------|---------|----------------------------|
| `ELIGIBLE` | ✅ Deal can be applied | - |
| `DEAL_NOT_FOUND` | Deal ID doesn't exist | "This promotion is no longer available" |
| `DEAL_INACTIVE` | Deal exists but not currently active | "This promotion has expired" |
| `MIN_ORDER_NOT_MET` | Order total below minimum | "Add $X more to qualify for this deal" |
| `SERVICE_TYPE_NOT_ELIGIBLE` | Deal not valid for pickup/delivery | "This deal is only valid for [pickup/delivery]" |
| `FIRST_ORDER_ONLY` | Customer has previous orders at this restaurant | "This deal is for first-time customers only" |
| `EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL` | First-order deal requires email to validate | "Please enter your email to use this deal" |

---

## Frontend Integration

### JavaScript/TypeScript (Supabase Client)

```typescript
interface DealValidationResult {
  eligible: boolean;
  reason: string;
}

async function validateDeal(
  dealId: number,
  orderTotal: number,
  serviceType?: 'pickup' | 'delivery',
  customerId?: number,
  customerEmail?: string
): Promise<DealValidationResult> {
  const { data, error } = await supabase.rpc('validate_deal_eligibility', {
    p_deal_id: dealId,
    p_order_total: orderTotal,
    p_service_type: serviceType ?? null,
    p_customer_id: customerId ?? null,
    p_customer_email: customerEmail ?? null
  });

  if (error) {
    console.error('Deal validation error:', error);
    throw new Error('Failed to validate deal');
  }

  // Function returns array with single row
  return data[0];
}
```

### Usage Examples

#### Example 1: Guest Checkout with First-Order Deal

```typescript
const result = await validateDeal(
  404,                    // deal_id (First Order 15% Off)
  45.99,                  // order total
  'delivery',             // service type
  null,                   // no customer_id (guest)
  'guest@example.com'     // guest email
);

if (result.eligible) {
  applyDeal(404);
} else {
  showError(getErrorMessage(result.reason));
}
```

#### Example 2: Logged-In User

```typescript
const result = await validateDeal(
  404,                    // deal_id
  45.99,                  // order total
  'pickup',               // service type
  currentUser.id,         // logged-in user ID
  currentUser.email       // user email (extra validation)
);
```

#### Example 3: Simple Deal (No First-Order Restriction)

```typescript
// For deals without first-order restriction, email/customer_id are optional
const result = await validateDeal(
  500,                    // deal_id (10% Off Everything)
  25.00,                  // order total
  'delivery'              // service type
);
```

---

## Error Handling

```typescript
function getErrorMessage(reason: string): string {
  const messages: Record<string, string> = {
    'DEAL_NOT_FOUND': 'This promotion is no longer available.',
    'DEAL_INACTIVE': 'This promotion has expired or is not currently active.',
    'MIN_ORDER_NOT_MET': 'Your order does not meet the minimum purchase requirement.',
    'SERVICE_TYPE_NOT_ELIGIBLE': 'This deal is not available for your selected service type.',
    'FIRST_ORDER_ONLY': 'This deal is exclusively for first-time customers.',
    'EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL': 'Please provide your email to use this first-order deal.'
  };
  
  return messages[reason] ?? 'Unable to apply this promotion.';
}
```

---

## Validation Logic Flow

```
┌─────────────────────────────────────────┐
│        validate_deal_eligibility()       │
└─────────────────────────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────┐
    │   1. Does deal exist?         │
    │   SELECT FROM promotional_deals│
    └───────────────────────────────┘
                    │
           NO ◄─────┴─────► YES
            │                │
            ▼                ▼
    ┌──────────────┐  ┌─────────────────────┐
    │DEAL_NOT_FOUND│  │ 2. Is deal active?  │
    └──────────────┘  │ is_deal_active_now()│
                      └─────────────────────┘
                               │
                      NO ◄─────┴─────► YES
                       │                │
                       ▼                ▼
               ┌──────────────┐  ┌─────────────────────┐
               │DEAL_INACTIVE │  │ 3. Min purchase met?│
               └──────────────┘  │ p_order_total >= min│
                                 └─────────────────────┘
                                          │
                                 NO ◄─────┴─────► YES
                                  │                │
                                  ▼                ▼
                          ┌────────────────┐ ┌───────────────────┐
                          │MIN_ORDER_NOT_MET│ │4. Service type OK?│
                          └────────────────┘ │pickup/delivery    │
                                             └───────────────────┘
                                                      │
                                             NO ◄─────┴─────► YES
                                              │                │
                                              ▼                ▼
                                    ┌─────────────────────┐ ┌────────────────┐
                                    │SERVICE_TYPE_NOT_    │ │5. First order? │
                                    │ELIGIBLE             │ │is_first_order_ │
                                    └─────────────────────┘ │only = true?    │
                                                            └────────────────┘
                                                                   │
                                                          NO ◄─────┴─────► YES
                                                           │                │
                                                           ▼                ▼
                                                    ┌──────────┐  ┌─────────────────┐
                                                    │ ELIGIBLE │  │6. Has identifier?│
                                                    └──────────┘  │customer_id OR   │
                                                                  │email provided?  │
                                                                  └─────────────────┘
                                                                          │
                                                                 NO ◄─────┴─────► YES
                                                                  │                │
                                                                  ▼                ▼
                                                          ┌────────────────┐ ┌───────────────────┐
                                                          │EMAIL_REQUIRED_ │ │7. Previous orders │
                                                          │FOR_FIRST_ORDER_│ │at THIS restaurant?│
                                                          │DEAL            │ └───────────────────┘
                                                          └────────────────┘          │
                                                                             YES ◄────┴────► NO
                                                                              │              │
                                                                              ▼              ▼
                                                                      ┌────────────┐  ┌──────────┐
                                                                      │FIRST_ORDER_│  │ ELIGIBLE │
                                                                      │ONLY        │  └──────────┘
                                                                      └────────────┘
```

---

## First-Order Validation Details

### Per-Restaurant Logic

First-order deals are validated **per restaurant**, not globally:

| Scenario | Restaurant A | Restaurant B |
|----------|--------------|--------------|
| Customer's first order ever | ✅ Eligible | ✅ Eligible |
| Customer ordered from A before | ❌ Not eligible | ✅ Eligible |
| Customer ordered from B before | ✅ Eligible | ❌ Not eligible |

### Dual Validation (User ID + Email)

The function checks BOTH:

1. **User ID check:** Has `user_id` placed orders at this restaurant?
2. **Email check:** Has this email placed orders at this restaurant (as guest OR registered)?

This prevents:
- Logged-in users from getting multiple first-order deals
- Guest users from repeatedly using first-order deals with the same email

### Email Sources Checked

```sql
-- Both columns are checked (case-insensitive)
WHERE LOWER(o.customer_email) = LOWER(p_customer_email)
   OR LOWER(o.guest_email) = LOWER(p_customer_email)
```

---

## Related Tables

| Table | Purpose |
|-------|---------|
| `promotional_deals` | Deal definitions (discount, min purchase, restrictions) |
| `orders` | Order history for first-order validation |
| `users` | User accounts (linked via `user_id`) |

### promotional_deals Relevant Columns

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `restaurant_id` | bigint | Restaurant this deal belongs to |
| `minimum_purchase` | numeric | Minimum order amount required |
| `availability_types` | jsonb | Array: `["pickup"]`, `["delivery"]`, or `["pickup","delivery"]` |
| `is_first_order_only` | boolean | If `true`, only first-time customers qualify |

---

## Testing the Function

### SQL Test Queries

```sql
-- Test 1: Valid deal, meets all requirements
SELECT * FROM menuca_v3.validate_deal_eligibility(
    404,        -- deal_id
    50.00,      -- order_total
    'delivery', -- service_type
    NULL,       -- no customer_id
    'new@example.com'  -- new email
);
-- Expected: (true, 'ELIGIBLE')

-- Test 2: Order total below minimum
SELECT * FROM menuca_v3.validate_deal_eligibility(
    404,        -- deal_id with $20 minimum
    15.00,      -- below minimum
    'delivery',
    NULL,
    'test@example.com'
);
-- Expected: (false, 'MIN_ORDER_NOT_MET')

-- Test 3: First-order deal without email
SELECT * FROM menuca_v3.validate_deal_eligibility(
    404,        -- first-order deal
    50.00,
    'delivery',
    NULL,       -- no customer_id
    NULL        -- no email
);
-- Expected: (false, 'EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL')
```

### JavaScript Test

```typescript
// Test in browser console or Node.js
async function testDealValidation() {
  const tests = [
    { dealId: 404, total: 50, email: 'new@test.com', expected: 'ELIGIBLE' },
    { dealId: 404, total: 10, email: 'new@test.com', expected: 'MIN_ORDER_NOT_MET' },
    { dealId: 404, total: 50, email: null, expected: 'EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL' },
  ];

  for (const test of tests) {
    const result = await validateDeal(
      test.dealId,
      test.total,
      'delivery',
      null,
      test.email
    );
    console.log(
      `Deal ${test.dealId}, $${test.total}, email=${test.email}:`,
      result.reason === test.expected ? '✅ PASS' : `❌ FAIL (got ${result.reason})`
    );
  }
}
```

---

## Implementation Checklist

- [ ] Call `validate_deal_eligibility()` before applying any deal discount
- [ ] Always pass `p_customer_email` for first-order deals (even for guests)
- [ ] Pass both `p_customer_id` AND `p_customer_email` when user is logged in
- [ ] Handle all reason codes with appropriate user messages
- [ ] Show minimum purchase requirement in error message when `MIN_ORDER_NOT_MET`
- [ ] Prompt for email if `EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL` is returned
- [ ] Re-validate if order total changes (items added/removed)

---

## Common Pitfalls

### 1. Forgetting Email for First-Order Deals

❌ **Wrong:**
```typescript
// Guest checkout without email
const result = await validateDeal(404, 50, 'delivery');
// Returns: EMAIL_REQUIRED_FOR_FIRST_ORDER_DEAL
```

✅ **Correct:**
```typescript
// Always pass email for first-order deals
const result = await validateDeal(404, 50, 'delivery', null, guestEmail);
```

### 2. Not Re-validating After Cart Changes

❌ **Wrong:**
```typescript
// Validate once at page load
const dealValid = await validateDeal(404, initialTotal);
// Cart changes... total drops below minimum
applyDeal(); // Applies invalid deal!
```

✅ **Correct:**
```typescript
// Re-validate before final checkout
async function onCheckout() {
  const result = await validateDeal(404, currentTotal, serviceType, userId, email);
  if (!result.eligible) {
    showError(getErrorMessage(result.reason));
    return;
  }
  proceedToPayment();
}
```

### 3. Assuming Deal is Restaurant-Agnostic

❌ **Wrong:**
```typescript
// Checking first-order globally
if (user.hasAnyPreviousOrder) {
  disableFirstOrderDeals();
}
```

✅ **Correct:**
```typescript
// Let the function handle per-restaurant logic
const result = await validateDeal(dealId, total, service, userId, email);
// Function checks orders for THIS restaurant only
```

---

## Performance Notes

| Operation | Expected Time |
|-----------|---------------|
| Single validation call | < 50ms |
| Validation with first-order check | < 100ms |

The function is marked `STABLE` and `SECURITY DEFINER` for performance and proper access to the orders table.

---

## Related Documentation

| Document | Description |
|----------|-------------|
| `../entities/07-marketing-entity.md` | Full marketing entity schema |
| `BILINGUAL_MENU_HANDOFF.md` | Menu data and language handling |

---

**Document Created:** February 2, 2026
