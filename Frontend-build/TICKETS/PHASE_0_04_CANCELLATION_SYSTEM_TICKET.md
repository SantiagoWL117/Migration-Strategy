# TICKET: Phase 0 - Order Cancellation & Refunds

**Ticket ID:** PHASE_0_04_CANCELLATION_SYSTEM  
**Priority:** 🟡 HIGH  
**Estimated Time:** 3-4 hours  
**Dependencies:** None  
**Assignee:** Builder Agent  
**Database:** Apply to production (cursor-build inherits)

---

## Requirement

Create system for customers to cancel orders and receive automatic refunds. Customers should be able to cancel before restaurant accepts the order, with automatic Stripe refund processing.

---

## Problem Statement

**Current Plan:** No cancellation flow - customer service nightmare

**Impact:**
- Customers can't cancel mistaken orders
- Manual refund processing required
- Poor customer experience
- Support tickets pile up

**Solution:** Automatic cancellation with Stripe refund integration

---

## Acceptance Criteria

### SQL Functions
- [ ] Create `cancel_customer_order(p_order_id, p_cancellation_reason)` function
- [ ] Function checks if order is cancellable (status = 'pending')
- [ ] Function initiates Stripe refund (via Edge Function call)
- [ ] Function updates order status to 'cancelled'
- [ ] Function records cancellation reason and timestamp

### Business Rules
- [ ] Can cancel if order status = 'pending' (not yet accepted by restaurant)
- [ ] Cannot cancel if status = 'preparing', 'ready', 'delivered'
- [ ] Refund amount = full order total
- [ ] Email notification sent to customer
- [ ] Restaurant notified of cancellation

### Data Integrity
- [ ] Original order preserved (soft delete pattern)
- [ ] Cancellation audit trail
- [ ] Payment info updated with refund ID

---

## Technical Details

### SQL Function: cancel_customer_order()

```sql
CREATE OR REPLACE FUNCTION menuca_v3.cancel_customer_order(
  p_order_id BIGINT,
  p_user_id BIGINT,  -- For authorization check
  p_cancellation_reason TEXT DEFAULT 'Customer requested cancellation'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order RECORD;
  v_refund_response JSONB;
  v_result JSONB;
BEGIN
  -- Fetch order and verify ownership
  SELECT 
    o.id,
    o.order_number,
    o.status,
    o.user_id,
    o.guest_email,
    o.is_guest_order,
    o.total,
    o.payment_info
  INTO v_order
  FROM menuca_v3.orders o
  WHERE o.id = p_order_id
    AND (
      o.user_id = p_user_id OR  -- Authenticated user
      (o.is_guest_order AND o.guest_email = current_setting('app.guest_email', true))  -- Guest
    );
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Order not found or unauthorized'
    );
  END IF;
  
  -- Check if cancellable
  IF v_order.status != 'pending' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Order cannot be cancelled. Current status: ' || v_order.status,
      'cancellable_statuses', ARRAY['pending']
    );
  END IF;
  
  -- Process Stripe refund (if payment was processed)
  IF v_order.payment_info IS NOT NULL AND 
     v_order.payment_info->>'payment_intent_id' IS NOT NULL THEN
    
    -- TODO: Call Stripe refund via Edge Function
    -- For now, store refund_pending flag
    UPDATE menuca_v3.orders
    SET payment_info = payment_info || jsonb_build_object(
      'refund_status', 'pending',
      'refund_requested_at', NOW()
    )
    WHERE id = p_order_id;
    
  END IF;
  
  -- Update order status
  UPDATE menuca_v3.orders
  SET 
    status = 'cancelled',
    cancellation_reason = p_cancellation_reason,
    cancelled_at = NOW(),
    cancelled_by = p_user_id,
    updated_at = NOW()
  WHERE id = p_order_id;
  
  -- Record in status history
  INSERT INTO menuca_v3.order_status_history (
    order_id,
    status,
    notes,
    changed_by,
    created_at
  ) VALUES (
    p_order_id,
    'cancelled',
    p_cancellation_reason,
    p_user_id,
    NOW()
  );
  
  -- Build success response
  v_result := jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'status', 'cancelled',
    'refund_status', CASE 
      WHEN v_order.payment_info IS NOT NULL THEN 'processing'
      ELSE 'not_applicable'
    END,
    'cancelled_at', NOW()
  );
  
  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.cancel_customer_order IS 
  'Allows customers to cancel orders. Only pending orders can be cancelled. Initiates Stripe refund.';
```

---

### Add Missing Columns to orders Table

```sql
-- Add cancellation tracking fields
ALTER TABLE menuca_v3.orders
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT,
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS cancelled_by BIGINT REFERENCES menuca_v3.users(id);

-- Add comments
COMMENT ON COLUMN menuca_v3.orders.cancellation_reason IS 
  'Why order was cancelled (customer explanation)';
  
COMMENT ON COLUMN menuca_v3.orders.cancelled_at IS 
  'When order was cancelled';
  
COMMENT ON COLUMN menuca_v3.orders.cancelled_by IS 
  'User ID who cancelled (customer or admin)';
```

---

### Helper Function: Get Cancellation Policy

```sql
CREATE OR REPLACE FUNCTION menuca_v3.get_cancellation_policy(
  p_order_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_status TEXT;
  v_can_cancel BOOLEAN;
  v_reason TEXT;
BEGIN
  -- Get current order status
  SELECT status INTO v_order_status
  FROM menuca_v3.orders
  WHERE id = p_order_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'can_cancel', false,
      'reason', 'Order not found'
    );
  END IF;
  
  -- Determine if cancellable
  CASE v_order_status
    WHEN 'pending' THEN
      v_can_cancel := true;
      v_reason := 'Order not yet accepted by restaurant. You can cancel and receive full refund.';
    WHEN 'preparing' THEN
      v_can_cancel := false;
      v_reason := 'Order is being prepared. Cancellation no longer available.';
    WHEN 'ready' THEN
      v_can_cancel := false;
      v_reason := 'Order is ready for pickup/delivery. Cannot cancel.';
    WHEN 'delivered' THEN
      v_can_cancel := false;
      v_reason := 'Order already delivered. Cannot cancel.';
    WHEN 'cancelled' THEN
      v_can_cancel := false;
      v_reason := 'Order already cancelled.';
    ELSE
      v_can_cancel := false;
      v_reason := 'Order status: ' || v_order_status;
  END CASE;
  
  RETURN jsonb_build_object(
    'can_cancel', v_can_cancel,
    'current_status', v_order_status,
    'reason', v_reason,
    'cancellable_window', 'Only pending orders can be cancelled'
  );
END;
$$;

COMMENT ON FUNCTION menuca_v3.get_cancellation_policy IS 
  'Returns whether an order can be cancelled and why/why not.';
```

---

## Usage Examples

### Frontend: Check if Order Cancellable

```typescript
// Check cancellation policy
const { data: policy } = await supabase.rpc('get_cancellation_policy', {
  p_order_id: orderId
});

if (policy.can_cancel) {
  // Show cancel button
  <button onClick={handleCancelOrder}>
    Cancel Order
  </button>
  <p className="text-sm">{policy.reason}</p>
} else {
  // Show why can't cancel
  <p className="text-gray-500">{policy.reason}</p>
}
```

### Frontend: Cancel Order

```typescript
// Cancel order
const { data, error } = await supabase.rpc('cancel_customer_order', {
  p_order_id: orderId,
  p_user_id: user.id,
  p_cancellation_reason: 'Ordered wrong items by mistake'
});

if (data.success) {
  toast.success(`Order ${data.order_number} cancelled. Refund processing.`);
  
  if (data.refund_status === 'processing') {
    toast.info('Refund will appear in 5-10 business days');
  }
} else {
  toast.error(data.error);
}
```

---

## Verification Queries

```sql
-- Verify columns added
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name = 'orders'
  AND column_name IN ('cancellation_reason', 'cancelled_at', 'cancelled_by');

-- Verify functions exist
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
  AND routine_name IN ('cancel_customer_order', 'get_cancellation_policy');

-- Test cancellation policy check
INSERT INTO menuca_v3.orders (restaurant_id, order_number, status, total)
VALUES (1, 'TEST-CANCEL-001', 'pending', 25.00)
RETURNING id;
-- Use returned ID:

SELECT menuca_v3.get_cancellation_policy(999);  -- Replace with actual ID
-- Expected: can_cancel = true, reason explains policy
```

---

## Testing Requirements

### Test Case 1: Cancel Pending Order (Success)
```sql
-- Create test order
INSERT INTO menuca_v3.orders (
  restaurant_id, 
  user_id, 
  order_number, 
  status, 
  total
) VALUES (1, 1, 'TEST-001', 'pending', 50.00)
RETURNING id;

-- Cancel it
SELECT menuca_v3.cancel_customer_order(
  [order_id],
  1,  -- user_id
  'Test cancellation'
);

-- Expected: success = true, status = 'cancelled'

-- Verify order updated
SELECT status, cancellation_reason, cancelled_at
FROM menuca_v3.orders
WHERE id = [order_id];
-- Expected: status = 'cancelled', reason populated
```

### Test Case 2: Try to Cancel Non-Pending Order (Fail)
```sql
-- Create order with status = 'preparing'
INSERT INTO menuca_v3.orders (
  restaurant_id, 
  user_id, 
  order_number, 
  status, 
  total
) VALUES (1, 1, 'TEST-002', 'preparing', 50.00)
RETURNING id;

-- Try to cancel
SELECT menuca_v3.cancel_customer_order([order_id], 1, 'Test');

-- Expected: success = false, error = "Order cannot be cancelled..."
```

### Test Case 3: Check Cancellation Policy
```sql
-- Check policy for pending order
SELECT menuca_v3.get_cancellation_policy([pending_order_id]);
-- Expected: can_cancel = true

-- Check policy for preparing order
SELECT menuca_v3.get_cancellation_policy([preparing_order_id]);
-- Expected: can_cancel = false
```

---

## Stripe Integration (Phase 5)

**Edge Function needed:** `/supabase/functions/process-refund`

```typescript
// This will be created in Phase 5
import Stripe from 'stripe';

export async function processRefund(orderId: number) {
  const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);
  
  // Get order payment info
  const { data: order } = await supabase
    .from('orders')
    .select('payment_info, total')
    .eq('id', orderId)
    .single();
  
  const paymentIntentId = order.payment_info.payment_intent_id;
  
  // Create Stripe refund
  const refund = await stripe.refunds.create({
    payment_intent: paymentIntentId,
    reason: 'requested_by_customer'
  });
  
  // Update order with refund info
  await supabase
    .from('orders')
    .update({
      payment_info: {
        ...order.payment_info,
        refund_id: refund.id,
        refund_status: 'succeeded',
        refund_amount: order.total,
        refunded_at: new Date().toISOString()
      }
    })
    .eq('id', orderId);
  
  return { success: true, refund };
}
```

---

## Email Notifications (Phase 8)

**Templates needed:**

1. **Order Cancelled (Customer)**
   ```
   Subject: Your order has been cancelled
   
   Hi [Customer Name],
   
   Your order #[ORDER_NUMBER] has been cancelled as requested.
   
   Refund Details:
   - Amount: $[TOTAL]
   - Expected: 5-10 business days
   
   Thank you!
   ```

2. **Order Cancelled (Restaurant)**
   ```
   Subject: Order #[ORDER_NUMBER] cancelled
   
   Order #[ORDER_NUMBER] was cancelled by the customer.
   Reason: [REASON]
   
   No action required.
   ```

---

## Business Rules Summary

| Order Status | Can Cancel? | Refund | Notes |
|--------------|-------------|--------|-------|
| **pending** | ✅ YES | Full | Before restaurant accepts |
| **preparing** | ❌ NO | - | Restaurant started cooking |
| **ready** | ❌ NO | - | Order ready |
| **out_for_delivery** | ❌ NO | - | Driver has order |
| **delivered** | ❌ NO | - | Order completed |
| **cancelled** | ❌ NO | - | Already cancelled |

---

## Expected Outcome

After implementation:
- ✅ Customers can cancel pending orders
- ✅ Automatic refund initiation (completed in Phase 5)
- ✅ Cancellation policy clearly communicated
- ✅ Audit trail for all cancellations
- ✅ Foundation ready for Phase 6 (Customer Account)

---

## Rollback Plan

```sql
BEGIN;

-- Drop functions
DROP FUNCTION IF EXISTS menuca_v3.cancel_customer_order(BIGINT, BIGINT, TEXT);
DROP FUNCTION IF EXISTS menuca_v3.get_cancellation_policy(BIGINT);

-- Remove columns
ALTER TABLE menuca_v3.orders
  DROP COLUMN IF EXISTS cancellation_reason,
  DROP COLUMN IF EXISTS cancelled_at,
  DROP COLUMN IF EXISTS cancelled_by;

COMMIT;
```

---

## References

- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #4: Order Cancellation Missing)
- **Payment Plan:** `/PAYMENT_DATA_STORAGE_PLAN.md`

---

**Status:** ⏳ READY FOR ASSIGNMENT  
**Created:** 2025-10-22 by Orchestrator Agent  
**Next Step:** Assign after Ticket 03 completion

