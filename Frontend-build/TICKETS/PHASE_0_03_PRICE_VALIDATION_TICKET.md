# TICKET: Phase 0 - Server-Side Price Validation

**Ticket ID:** PHASE_0_03_PRICE_VALIDATION  
**Priority:** 🔴 CRITICAL - SECURITY  
**Estimated Time:** 4-5 hours  
**Dependencies:** None  
**Assignee:** Builder Agent  
**Database:** Apply to production (cursor-build inherits)

---

## Requirement

Create server-side order total calculation to prevent price manipulation. **NEVER trust client-sent prices** - clients can modify JavaScript and pay $0.01 for orders. This is a critical security vulnerability.

---

## Problem Statement

**Current Plan:** Client calculates total and sends to server

**Security Risk:**
- Users can open browser DevTools
- Modify JavaScript to change cart total
- Pay $0.01 for $100 order
- CRITICAL REVENUE LOSS

**Solution:** Server recalculates total from dish IDs, never trust client prices

---

## Acceptance Criteria

### SQL Functions
- [ ] Create `calculate_order_total(p_items JSONB, p_restaurant_id BIGINT)` function
- [ ] Function fetches current prices from database
- [ ] Function calculates: subtotal + tax + delivery fee + tip
- [ ] Function validates all items belong to same restaurant
- [ ] Function returns detailed breakdown

### Security
- [ ] Never use client-sent prices
- [ ] Always fetch from database
- [ ] Validate items exist and are from correct restaurant
- [ ] Return error if manipulation detected

### Functionality
- [ ] Calculate item subtotals (price × quantity)
- [ ] Add modifier prices
- [ ] Apply restaurant tax rate
- [ ] Add delivery fee (if applicable)
- [ ] Add tip (if provided)
- [ ] Return itemized breakdown

---

## Technical Details

### SQL Function: calculate_order_total()

```sql
CREATE OR REPLACE FUNCTION menuca_v3.calculate_order_total(
  p_items JSONB,
  p_restaurant_id BIGINT,
  p_delivery_fee NUMERIC(10,2) DEFAULT 0,
  p_tip NUMERIC(10,2) DEFAULT 0,
  p_coupon_code TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subtotal NUMERIC(10,2) := 0;
  v_tax NUMERIC(10,2) := 0;
  v_tax_rate NUMERIC(5,4);
  v_discount NUMERIC(10,2) := 0;
  v_total NUMERIC(10,2);
  v_item JSONB;
  v_dish_id BIGINT;
  v_quantity INTEGER;
  v_dish_price NUMERIC(10,2);
  v_item_total NUMERIC(10,2);
  v_modifier JSONB;
  v_modifier_price NUMERIC(10,2);
  v_items_breakdown JSONB := '[]'::JSONB;
BEGIN
  -- Get restaurant tax rate
  SELECT COALESCE(tax_rate, 0.13) INTO v_tax_rate
  FROM menuca_v3.restaurants
  WHERE id = p_restaurant_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found: %', p_restaurant_id;
  END IF;
  
  -- Loop through items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_dish_id := (v_item->>'dish_id')::BIGINT;
    v_quantity := (v_item->>'quantity')::INTEGER;
    
    -- Fetch CURRENT price from database (never trust client!)
    SELECT price INTO v_dish_price
    FROM menuca_v3.dishes
    WHERE id = v_dish_id
      AND restaurant_id = p_restaurant_id  -- Security: verify restaurant match
      AND is_deleted = FALSE;
    
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Dish % not found or not from restaurant %', v_dish_id, p_restaurant_id;
    END IF;
    
    -- Calculate item subtotal (base price × quantity)
    v_item_total := v_dish_price * v_quantity;
    
    -- Add modifier prices
    IF v_item ? 'modifiers' THEN
      FOR v_modifier IN SELECT * FROM jsonb_array_elements(v_item->'modifiers')
      LOOP
        -- Fetch modifier price from database
        SELECT price INTO v_modifier_price
        FROM menuca_v3.dish_modifiers
        WHERE id = (v_modifier->>'modifier_id')::BIGINT;
        
        IF FOUND AND v_modifier_price IS NOT NULL THEN
          v_item_total := v_item_total + (v_modifier_price * v_quantity);
        END IF;
      END LOOP;
    END IF;
    
    -- Add to subtotal
    v_subtotal := v_subtotal + v_item_total;
    
    -- Add to breakdown
    v_items_breakdown := v_items_breakdown || jsonb_build_object(
      'dish_id', v_dish_id,
      'quantity', v_quantity,
      'unit_price', v_dish_price,
      'item_total', v_item_total
    );
  END LOOP;
  
  -- Apply coupon discount (if provided)
  IF p_coupon_code IS NOT NULL THEN
    -- Fetch coupon discount
    -- TODO: Implement coupon validation in separate function
    -- For now, set to 0
    v_discount := 0;
  END IF;
  
  -- Calculate tax (on subtotal after discount)
  v_tax := ROUND((v_subtotal - v_discount) * v_tax_rate, 2);
  
  -- Calculate total
  v_total := v_subtotal - v_discount + v_tax + p_delivery_fee + p_tip;
  
  -- Return detailed breakdown
  RETURN jsonb_build_object(
    'subtotal', v_subtotal,
    'discount', v_discount,
    'tax', v_tax,
    'tax_rate', v_tax_rate,
    'delivery_fee', p_delivery_fee,
    'tip', p_tip,
    'total', v_total,
    'items_breakdown', v_items_breakdown,
    'calculated_at', NOW()
  );
END;
$$;

COMMENT ON FUNCTION menuca_v3.calculate_order_total IS 
  'Calculates order total from dish IDs. NEVER trusts client prices. Returns itemized breakdown.';
```

---

## Usage Examples

### Frontend: Create Payment Intent (Correct Way)

```typescript
// ✅ CORRECT: Send items, server calculates
const { data, error } = await fetch('/api/create-payment-intent', {
  method: 'POST',
  body: JSON.stringify({
    items: [
      { dish_id: 123, quantity: 2, modifiers: [...] },
      { dish_id: 456, quantity: 1, modifiers: [] }
    ],
    restaurant_id: 789,
    delivery_fee: 5.00,
    tip: 3.00
  })
});

// Backend recalculates total:
export async function POST(request) {
  const { items, restaurant_id, delivery_fee, tip } = await request.json();
  
  // ✅ Calculate on server (secure!)
  const { data: orderTotal } = await supabase.rpc('calculate_order_total', {
    p_items: items,
    p_restaurant_id: restaurant_id,
    p_delivery_fee: delivery_fee,
    p_tip: tip
  });
  
  // ✅ Use SERVER-calculated total for Stripe
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(orderTotal.total * 100),  // Server total, not client!
    currency: 'cad',
    metadata: {
      restaurant_id,
      calculated_total: orderTotal.total
    }
  });
  
  return Response.json({ clientSecret: paymentIntent.client_secret });
}
```

### ❌ WRONG WAY (Security Vulnerability)

```typescript
// ❌ NEVER DO THIS:
const clientTotal = calculateTotalOnClient(cartItems);  // ❌ Client calculates

const { data, error } = await fetch('/api/create-payment-intent', {
  method: 'POST',
  body: JSON.stringify({
    amount: clientTotal  // ❌ Client sends amount!
  })
});

// Backend TRUSTS client (VULNERABLE!)
export async function POST(request) {
  const { amount } = await request.json();  // ❌ Trusting client!
  
  // ❌ User could have modified amount to $0.01!
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100),  // ❌ Using client amount!
    currency: 'cad'
  });
}
```

---

## Verification Queries

```sql
-- Verify function exists
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
  AND routine_name = 'calculate_order_total';

-- Test with sample data (replace dish_ids with real ones)
SELECT menuca_v3.calculate_order_total(
  '[
    {"dish_id": 1, "quantity": 2},
    {"dish_id": 2, "quantity": 1}
  ]'::JSONB,
  1,  -- restaurant_id
  5.00,  -- delivery_fee
  3.00   -- tip
);

-- Expected output example:
-- {
--   "subtotal": 25.00,
--   "discount": 0,
--   "tax": 3.25,
--   "tax_rate": 0.13,
--   "delivery_fee": 5.00,
--   "tip": 3.00,
--   "total": 36.25,
--   "items_breakdown": [...],
--   "calculated_at": "2025-10-22T..."
-- }
```

---

## Testing Requirements

### Test Case 1: Basic Calculation
```sql
-- Insert test dishes
INSERT INTO menuca_v3.dishes (id, restaurant_id, name, price, is_deleted)
VALUES 
  (99991, 1, 'Test Dish 1', 10.00, FALSE),
  (99992, 1, 'Test Dish 2', 15.00, FALSE);

-- Calculate total
SELECT menuca_v3.calculate_order_total(
  '[
    {"dish_id": 99991, "quantity": 2},
    {"dish_id": 99992, "quantity": 1}
  ]'::JSONB,
  1,
  0,  -- no delivery fee
  0   -- no tip
);

-- Expected:
-- subtotal: 35.00 (10×2 + 15×1)
-- tax: 4.55 (35 × 0.13)
-- total: 39.55
```

### Test Case 2: Security - Wrong Restaurant
```sql
-- Try to order dish from different restaurant (should FAIL)
SELECT menuca_v3.calculate_order_total(
  '[{"dish_id": 99991, "quantity": 1}]'::JSONB,
  999,  -- Wrong restaurant_id
  0,
  0
);

-- Expected: EXCEPTION "Dish not found or not from restaurant"
```

### Test Case 3: With Delivery and Tip
```sql
SELECT menuca_v3.calculate_order_total(
  '[{"dish_id": 99991, "quantity": 1}]'::JSONB,
  1,
  5.00,  -- delivery fee
  3.00   -- tip
);

-- Expected:
-- subtotal: 10.00
-- tax: 1.30
-- delivery_fee: 5.00
-- tip: 3.00
-- total: 19.30
```

### Test Case 4: Deleted Dish (should FAIL)
```sql
-- Mark dish as deleted
UPDATE menuca_v3.dishes SET is_deleted = TRUE WHERE id = 99991;

-- Try to order
SELECT menuca_v3.calculate_order_total(
  '[{"dish_id": 99991, "quantity": 1}]'::JSONB,
  1, 0, 0
);

-- Expected: EXCEPTION "Dish not found"
```

---

## Security Best Practices

### 1. Never Trust Client Data
- ❌ Don't trust client-sent prices
- ❌ Don't trust client-sent totals
- ✅ Always fetch prices from database
- ✅ Always recalculate on server

### 2. Validate Restaurant Match
- ✅ Verify all dishes belong to specified restaurant
- ✅ Prevent cross-restaurant ordering
- ✅ Raise exception if mismatch

### 3. Check Item Status
- ✅ Verify dish not deleted
- ✅ Verify dish is active
- ✅ Optional: Check inventory (Ticket 02)

### 4. Audit Trail
- ✅ Log calculated_at timestamp
- ✅ Store calculation in orders table
- ✅ Compare client total vs server total (log discrepancies)

---

## Integration with Payment Flow

```typescript
// Phase 5 (Payment Integration) will use this:

// Step 1: Calculate on server
const orderTotal = await supabase.rpc('calculate_order_total', {
  p_items: cartItems,
  p_restaurant_id: restaurantId,
  p_delivery_fee: deliveryFee,
  p_tip: tip
});

// Step 2: Show breakdown to user
console.log('Subtotal:', orderTotal.subtotal);
console.log('Tax:', orderTotal.tax);
console.log('Delivery:', orderTotal.delivery_fee);
console.log('Tip:', orderTotal.tip);
console.log('Total:', orderTotal.total);

// Step 3: Create Stripe payment intent with SERVER total
const paymentIntent = await stripe.paymentIntents.create({
  amount: Math.round(orderTotal.total * 100),  // Server calculated!
  currency: 'cad'
});

// Step 4: Client completes payment
// Step 5: On success, create order with SERVER total
const order = await supabase.from('orders').insert({
  restaurant_id: restaurantId,
  user_id: userId,
  subtotal: orderTotal.subtotal,
  tax: orderTotal.tax,
  delivery_fee: orderTotal.delivery_fee,
  tip: orderTotal.tip,
  total: orderTotal.total,  // Server calculated!
  payment_status: 'completed'
});
```

---

## Performance Considerations

### Indexes Needed (Already exist)
- `dishes.id` (primary key)
- `dishes.restaurant_id` (foreign key)
- `dish_modifiers.id` (primary key)

### Query Optimization
- Function uses indexed lookups
- No table scans
- Fast even with 100 items in cart

### Caching (Future Enhancement)
- Could cache dish prices for 5 minutes
- Would need cache invalidation on price updates
- Phase 1: No caching (always fetch fresh prices)

---

## Expected Outcome

After implementation:
- ✅ Server-side price calculation function ready
- ✅ Frontend **cannot** manipulate prices
- ✅ Stripe payments use server-calculated totals
- ✅ All items validated against database
- ✅ Security vulnerability eliminated
- ✅ Foundation ready for Phase 5 payment integration

---

## Rollback Plan

```sql
-- Drop function
DROP FUNCTION IF EXISTS menuca_v3.calculate_order_total(
  JSONB, BIGINT, NUMERIC, NUMERIC, TEXT
);
```

---

## References

- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #6: Server-Side Price Validation Missing)
- **Cognition Wheel:** Identified as CRITICAL security vulnerability
- **Payment Plan:** `/PAYMENT_DATA_STORAGE_PLAN.md`

---

**Status:** ⏳ READY FOR ASSIGNMENT  
**Created:** 2025-10-22 by Orchestrator Agent  
**Priority:** 🔴 CRITICAL SECURITY ISSUE  
**Next Step:** Assign after Ticket 02 completion

