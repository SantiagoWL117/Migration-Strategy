# TICKET: Phase 0 - Real-Time Inventory System

**Ticket ID:** PHASE_0_02_INVENTORY_SYSTEM  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 4-5 hours  
**Dependencies:** None  
**Assignee:** Builder Agent  
**Database:** Apply to production (cursor-build inherits)

---

## Requirement

Create a real-time inventory tracking system to prevent customers from ordering items that are unavailable. When a dish runs out of stock or is temporarily unavailable ("86'd" in restaurant terminology), customers must be notified before checkout.

---

## Problem Statement

**Current Plan:** No inventory tracking - items can be ordered even if unavailable

**Impact:**
- Orders fail after payment when restaurant can't fulfill
- Customer frustration and refund requests
- Restaurant can't "86" items during rush
- No way to mark items temporarily unavailable

**Solution:** Track dish availability in real-time with reason codes and automatic expiry

---

## Acceptance Criteria

### Database Changes
- [ ] Create `menuca_v3.dish_inventory` table
- [ ] Track availability status per dish
- [ ] Support temporary unavailability with auto-expiry
- [ ] Store reason for unavailability
- [ ] Add indexes for fast lookups

### SQL Functions
- [ ] Create `check_cart_availability(p_cart_items JSONB)` function
- [ ] Function returns list of unavailable items
- [ ] Function checks against dish_inventory table
- [ ] Handles NULL (no entry = available)

### Functionality
- [ ] Dishes default to available (no inventory record needed)
- [ ] Can mark dish unavailable with reason
- [ ] Can set auto-expiry time (e.g., available again at 6 PM)
- [ ] Can mark available again manually
- [ ] Frontend can check entire cart before checkout

---

## Technical Details

### Database Schema

```sql
-- Create dish_inventory table
CREATE TABLE menuca_v3.dish_inventory (
  dish_id BIGINT PRIMARY KEY REFERENCES menuca_v3.dishes(id) ON DELETE CASCADE,
  is_available BOOLEAN DEFAULT TRUE NOT NULL,
  unavailable_until TIMESTAMPTZ,
  reason TEXT,
  marked_unavailable_at TIMESTAMPTZ DEFAULT NOW(),
  marked_unavailable_by BIGINT REFERENCES menuca_v3.admin_users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_dish_inventory_unavailable 
  ON menuca_v3.dish_inventory(dish_id) 
  WHERE is_available = FALSE;

CREATE INDEX idx_dish_inventory_auto_expiry 
  ON menuca_v3.dish_inventory(unavailable_until) 
  WHERE unavailable_until IS NOT NULL AND is_available = FALSE;

-- Comments
COMMENT ON TABLE menuca_v3.dish_inventory IS 
  'Tracks real-time availability of dishes. No record = available.';
  
COMMENT ON COLUMN menuca_v3.dish_inventory.is_available IS 
  'FALSE if dish cannot be ordered. TRUE = can order.';
  
COMMENT ON COLUMN menuca_v3.dish_inventory.unavailable_until IS 
  'If set, dish automatically becomes available again at this time.';
  
COMMENT ON COLUMN menuca_v3.dish_inventory.reason IS 
  'Why unavailable: out_of_stock, prepping, 86ed, seasonal, etc.';
```

---

### SQL Function: check_cart_availability()

```sql
CREATE OR REPLACE FUNCTION menuca_v3.check_cart_availability(
  p_cart_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSONB;
  v_unavailable_items JSONB;
  v_item JSONB;
  v_dish_id BIGINT;
  v_is_available BOOLEAN;
  v_reason TEXT;
BEGIN
  -- Initialize unavailable items array
  v_unavailable_items := '[]'::JSONB;
  
  -- Loop through cart items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_cart_items)
  LOOP
    -- Extract dish_id from cart item
    v_dish_id := (v_item->>'dish_id')::BIGINT;
    
    -- Check availability
    -- No record = available (default)
    -- Record with is_available = FALSE = unavailable
    -- If unavailable_until passed, auto-mark available
    SELECT 
      CASE 
        WHEN di.is_available = FALSE AND 
             (di.unavailable_until IS NULL OR di.unavailable_until > NOW()) 
        THEN FALSE
        ELSE TRUE
      END,
      di.reason
    INTO v_is_available, v_reason
    FROM menuca_v3.dish_inventory di
    WHERE di.dish_id = v_dish_id;
    
    -- If no record found, dish is available (NULL = available)
    IF NOT FOUND THEN
      v_is_available := TRUE;
    END IF;
    
    -- If unavailable, add to list
    IF v_is_available = FALSE THEN
      v_unavailable_items := v_unavailable_items || 
        jsonb_build_object(
          'dish_id', v_dish_id,
          'dish_name', v_item->>'dish_name',
          'reason', COALESCE(v_reason, 'temporarily_unavailable')
        );
    END IF;
  END LOOP;
  
  -- Build result
  v_result := jsonb_build_object(
    'all_available', (jsonb_array_length(v_unavailable_items) = 0),
    'unavailable_items', v_unavailable_items,
    'checked_at', NOW()
  );
  
  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION menuca_v3.check_cart_availability IS 
  'Checks if all items in cart are currently available. Returns list of unavailable items.';
```

---

### Helper Function: Auto-Expire Unavailable Items

```sql
CREATE OR REPLACE FUNCTION menuca_v3.auto_expire_unavailable_dishes()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_updated_count INTEGER;
BEGIN
  -- Mark dishes as available if unavailable_until has passed
  UPDATE menuca_v3.dish_inventory
  SET 
    is_available = TRUE,
    updated_at = NOW()
  WHERE 
    is_available = FALSE
    AND unavailable_until IS NOT NULL
    AND unavailable_until <= NOW();
  
  GET DIAGNOSTICS v_updated_count = ROW_COUNT;
  
  RETURN v_updated_count;
END;
$$;

COMMENT ON FUNCTION menuca_v3.auto_expire_unavailable_dishes IS 
  'Automatically marks dishes as available when unavailable_until time has passed. Run via cron.';
```

---

## Usage Examples

### Mark Dish Unavailable (Out of Stock)

```sql
-- Insert or update inventory record
INSERT INTO menuca_v3.dish_inventory (
  dish_id,
  is_available,
  reason,
  marked_unavailable_by,
  notes
) VALUES (
  123,  -- dish_id
  FALSE,
  'out_of_stock',
  456,  -- admin_user_id
  'Ran out during lunch rush'
)
ON CONFLICT (dish_id) 
DO UPDATE SET
  is_available = FALSE,
  reason = EXCLUDED.reason,
  marked_unavailable_at = NOW(),
  marked_unavailable_by = EXCLUDED.marked_unavailable_by,
  notes = EXCLUDED.notes,
  updated_at = NOW();
```

### Mark Unavailable Until Specific Time

```sql
-- Mark unavailable until 6 PM today
INSERT INTO menuca_v3.dish_inventory (
  dish_id,
  is_available,
  unavailable_until,
  reason,
  notes
) VALUES (
  123,
  FALSE,
  CURRENT_DATE + INTERVAL '18 hours',  -- 6 PM today
  'prepping',
  'Fresh batch ready at 6 PM'
)
ON CONFLICT (dish_id)
DO UPDATE SET
  is_available = FALSE,
  unavailable_until = EXCLUDED.unavailable_until,
  reason = EXCLUDED.reason,
  notes = EXCLUDED.notes,
  updated_at = NOW();
```

### Mark Dish Available Again

```sql
-- Manual mark as available
UPDATE menuca_v3.dish_inventory
SET 
  is_available = TRUE,
  unavailable_until = NULL,
  updated_at = NOW()
WHERE dish_id = 123;

-- Or delete record (no record = available)
DELETE FROM menuca_v3.dish_inventory
WHERE dish_id = 123;
```

### Check Cart Availability (Frontend)

```typescript
// Frontend call before checkout
const cartItems = [
  { dish_id: 123, dish_name: 'Pizza Margherita', quantity: 2 },
  { dish_id: 456, dish_name: 'Caesar Salad', quantity: 1 }
];

const { data, error } = await supabase.rpc('check_cart_availability', {
  p_cart_items: cartItems
});

if (!data.all_available) {
  // Show warning
  alert(`These items are no longer available: ${
    data.unavailable_items.map(item => item.dish_name).join(', ')
  }`);
  
  // Remove unavailable items from cart
  data.unavailable_items.forEach(unavailableItem => {
    removeFromCart(unavailableItem.dish_id);
  });
}
```

---

## Verification Queries

```sql
-- Verify table created
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
  AND table_name = 'dish_inventory'
ORDER BY ordinal_position;

-- Verify indexes
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3'
  AND tablename = 'dish_inventory';

-- Verify function exists
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'menuca_v3'
  AND routine_name IN ('check_cart_availability', 'auto_expire_unavailable_dishes');

-- Test check_cart_availability function
SELECT menuca_v3.check_cart_availability('[
  {"dish_id": 1, "dish_name": "Test Dish", "quantity": 1}
]'::JSONB);
-- Expected: {"all_available": true, "unavailable_items": [], ...}
```

---

## Testing Requirements

### Test Case 1: Default Availability
```sql
-- Dish with no inventory record should be available
SELECT menuca_v3.check_cart_availability('[
  {"dish_id": 999999, "dish_name": "Non-existent Dish", "quantity": 1}
]'::JSONB);
-- Expected: all_available = true
```

### Test Case 2: Mark Unavailable
```sql
-- Mark dish unavailable
INSERT INTO menuca_v3.dish_inventory (dish_id, is_available, reason)
VALUES (1, FALSE, 'out_of_stock');

-- Check cart with unavailable dish
SELECT menuca_v3.check_cart_availability('[
  {"dish_id": 1, "dish_name": "Test Dish", "quantity": 1}
]'::JSONB);
-- Expected: all_available = false, unavailable_items includes dish_id 1
```

### Test Case 3: Auto-Expiry
```sql
-- Mark unavailable until 1 second ago (should auto-expire)
INSERT INTO menuca_v3.dish_inventory (
  dish_id, 
  is_available, 
  unavailable_until
) VALUES (
  2, 
  FALSE, 
  NOW() - INTERVAL '1 second'
);

-- Check cart (should be available despite is_available = FALSE)
SELECT menuca_v3.check_cart_availability('[
  {"dish_id": 2, "dish_name": "Test Dish 2", "quantity": 1}
]'::JSONB);
-- Expected: all_available = true (unavailable_until passed)
```

### Test Case 4: Run Auto-Expire Function
```sql
-- Mark several dishes with expired unavailable_until
INSERT INTO menuca_v3.dish_inventory (dish_id, is_available, unavailable_until)
VALUES 
  (3, FALSE, NOW() - INTERVAL '1 hour'),
  (4, FALSE, NOW() - INTERVAL '2 hours');

-- Run auto-expire
SELECT menuca_v3.auto_expire_unavailable_dishes();
-- Expected: returns 2 (updated 2 dishes)

-- Verify dishes now available
SELECT dish_id, is_available FROM menuca_v3.dish_inventory
WHERE dish_id IN (3, 4);
-- Expected: both is_available = TRUE
```

---

## Frontend Impact (Future Phases)

**Phase 3 (Cart System) will need:**
- Check availability before adding to cart
- Show "Unavailable" badge on menu
- Remove unavailable items from cart automatically

**Phase 4 (Checkout) will need:**
- Final availability check before payment
- Show warning if items became unavailable
- Allow customer to proceed without unavailable items

---

## Security Considerations

### RLS Policies Needed (Phase 8)

```sql
-- Public can read (to check availability)
CREATE POLICY dish_inventory_select_policy 
  ON menuca_v3.dish_inventory
  FOR SELECT
  USING (true);  -- Anyone can check availability

-- Only restaurant admins can modify
CREATE POLICY dish_inventory_modify_policy
  ON menuca_v3.dish_inventory
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM menuca_v3.admin_user_restaurants aur
      JOIN menuca_v3.dishes d ON d.restaurant_id = aur.restaurant_id
      WHERE aur.admin_user_id = auth.uid()
        AND d.id = dish_inventory.dish_id
    )
  );
```

---

## Cron Job Setup (Post-Launch)

```sql
-- Add pg_cron extension (if not exists)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule auto-expire every 5 minutes
SELECT cron.schedule(
  'auto-expire-dishes',
  '*/5 * * * *',  -- Every 5 minutes
  $$SELECT menuca_v3.auto_expire_unavailable_dishes()$$
);
```

---

## Expected Outcome

After implementation:
- ✅ `dish_inventory` table tracks availability
- ✅ No record = available (default behavior)
- ✅ Can mark items unavailable with reason
- ✅ Auto-expiry prevents stale unavailability
- ✅ `check_cart_availability()` function ready for frontend
- ✅ Fast lookups via indexes
- ✅ Foundation ready for Phase 3 cart system

---

## Rollback Plan

```sql
BEGIN;

-- Drop functions
DROP FUNCTION IF EXISTS menuca_v3.check_cart_availability(JSONB);
DROP FUNCTION IF EXISTS menuca_v3.auto_expire_unavailable_dishes();

-- Drop table
DROP TABLE IF EXISTS menuca_v3.dish_inventory;

COMMIT;
```

---

## References

- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #1: Real-Time Inventory Missing)
- **Cognition Wheel:** Identified orders failing when items run out
- **Database Schema:** `/Database/Schemas/menuca_v3.sql`

---

**Status:** ⏳ READY FOR ASSIGNMENT  
**Created:** 2025-10-22 by Orchestrator Agent  
**Next Step:** Assign after Ticket 01 completion

