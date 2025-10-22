# TICKET: Phase 0 - Guest Checkout Support

**Ticket ID:** PHASE_0_01_GUEST_CHECKOUT  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 3-4 hours  
**Dependencies:** None  
**Assignee:** Builder Agent (via Cursor Composer)  
**Database:** Apply to production (cursor-build inherits)

---

## Requirement

Add guest checkout capability to allow customers to place orders without creating an account. This is **critical** for conversion rates - forcing account creation causes 50%+ cart abandonment.

---

## Problem Statement

**Current Plan:** Forces all customers to create accounts before checkout

**Impact:**
- 50%+ of users abandon cart rather than create account
- Lost revenue from impulse purchases
- Poor user experience
- Lower conversion rates

**Solution:** Allow guest checkout with option to create account after order placement

---

## Acceptance Criteria

### Database Changes
- [ ] Add `is_guest_order` BOOLEAN field to `menuca_v3.orders` table
- [ ] Add `guest_email` VARCHAR(255) field to `menuca_v3.orders` table  
- [ ] Add `guest_phone` VARCHAR(20) field to `menuca_v3.orders` table
- [ ] Make `user_id` nullable (allow NULL for guest orders)
- [ ] Add CHECK constraint: if `is_guest_order` = true, `guest_email` must be present
- [ ] Add index on `guest_email` for order lookup

### Functionality
- [ ] Guest orders can be created without `user_id`
- [ ] Guest email/phone stored for order notifications
- [ ] Orders table accepts both: authenticated orders (user_id) and guest orders (guest_email/phone)

### Data Integrity
- [ ] Existing orders unaffected (all have `is_guest_order` = false by default)
- [ ] Foreign key to `users` table remains (but allows NULL)
- [ ] No orphaned data created

### Testing
- [ ] Test creating guest order (user_id = NULL, guest_email populated)
- [ ] Test creating authenticated order (user_id populated, guest_email = NULL)
- [ ] Test CHECK constraint (guest order must have email)
- [ ] Verify existing orders unaffected

---

## Technical Details

### Database Migration SQL

```sql
-- Migration: Add guest checkout support to orders table
-- Date: 2025-10-22
-- Ticket: PHASE_0_01_GUEST_CHECKOUT

BEGIN;

-- Step 1: Add new columns for guest checkout
ALTER TABLE menuca_v3.orders
  ADD COLUMN is_guest_order BOOLEAN DEFAULT FALSE NOT NULL,
  ADD COLUMN guest_email VARCHAR(255),
  ADD COLUMN guest_phone VARCHAR(20);

-- Step 2: Make user_id nullable (allow guest orders)
ALTER TABLE menuca_v3.orders
  ALTER COLUMN user_id DROP NOT NULL;

-- Step 3: Add CHECK constraint - guest orders must have email
ALTER TABLE menuca_v3.orders
  ADD CONSTRAINT orders_guest_email_check 
  CHECK (
    (is_guest_order = FALSE) OR 
    (is_guest_order = TRUE AND guest_email IS NOT NULL)
  );

-- Step 4: Add index for guest email lookups
CREATE INDEX idx_orders_guest_email 
  ON menuca_v3.orders(guest_email) 
  WHERE is_guest_order = TRUE;

-- Step 5: Add comments for documentation
COMMENT ON COLUMN menuca_v3.orders.is_guest_order IS 
  'TRUE if order placed without user account (guest checkout)';
  
COMMENT ON COLUMN menuca_v3.orders.guest_email IS 
  'Email address for guest orders (required if is_guest_order = TRUE)';
  
COMMENT ON COLUMN menuca_v3.orders.guest_phone IS 
  'Phone number for guest orders (optional)';

COMMIT;
```

### Verification Queries

```sql
-- Verify columns added
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3' 
  AND table_name = 'orders'
  AND column_name IN ('is_guest_order', 'guest_email', 'guest_phone', 'user_id');

-- Verify CHECK constraint exists
SELECT 
  constraint_name, 
  check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'menuca_v3' 
  AND constraint_name = 'orders_guest_email_check';

-- Verify index created
SELECT 
  indexname, 
  indexdef
FROM pg_indexes
WHERE schemaname = 'menuca_v3' 
  AND tablename = 'orders'
  AND indexname = 'idx_orders_guest_email';

-- Verify existing orders unaffected
SELECT 
  COUNT(*) as total_orders,
  SUM(CASE WHEN is_guest_order = FALSE THEN 1 ELSE 0 END) as authenticated_orders,
  SUM(CASE WHEN is_guest_order = TRUE THEN 1 ELSE 0 END) as guest_orders,
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as null_user_id
FROM menuca_v3.orders;
-- Expected: All existing orders have is_guest_order = FALSE, user_id NOT NULL
```

---

## Frontend Impact (Future Phases)

**Phase 4 (Checkout Flow) will need:**

1. **Guest Checkout UI**
   ```typescript
   // Guest checkout form fields:
   - Full Name (required)
   - Email (required)
   - Phone (required)
   - Delivery Address (required)
   - Payment Method
   ```

2. **Post-Order Account Creation**
   ```typescript
   // After successful order:
   "Order confirmed! Would you like to save your info for faster checkout next time?"
   [Create Account] [No Thanks]
   ```

3. **Order Lookup for Guests**
   ```typescript
   // Allow guests to check order status:
   "Track your order: Enter email and order number"
   ```

**This ticket:** Database foundation only. Frontend in Phase 4.

---

## Security Considerations

### Email Validation
- Frontend must validate email format before submission
- Backend should also validate email format
- Consider email verification for account creation (not required for guest orders)

### Phone Validation
- Optional field, but validate format if provided
- Consider SMS notifications for order updates

### PII Handling
- `guest_email` and `guest_phone` are PII
- Ensure RLS policies protect guest order data
- Only show orders matching session email or authenticated user

### Future RLS Policy Needed
```sql
-- Policy: Users can only see their own orders (authenticated or guest)
CREATE POLICY orders_select_policy ON menuca_v3.orders
  FOR SELECT
  USING (
    user_id = auth.uid() OR  -- Authenticated user's orders
    (is_guest_order = TRUE AND guest_email = current_setting('app.guest_email', true))  -- Guest's orders
  );
```

**Note:** RLS policy implementation is a separate ticket (Phase 8: Security).

---

## Testing Requirements

### Unit Tests (SQL Level)
```sql
-- Test 1: Insert guest order (should succeed)
INSERT INTO menuca_v3.orders (
  restaurant_id, 
  order_number, 
  is_guest_order, 
  guest_email, 
  guest_phone, 
  status
) VALUES (
  1, 
  'TEST-GUEST-001', 
  TRUE, 
  'test@example.com', 
  '+1234567890', 
  'pending'
);

-- Test 2: Insert guest order without email (should FAIL)
INSERT INTO menuca_v3.orders (
  restaurant_id, 
  order_number, 
  is_guest_order, 
  status
) VALUES (
  1, 
  'TEST-GUEST-002', 
  TRUE, 
  'pending'
);
-- Expected: CHECK constraint violation

-- Test 3: Insert authenticated order (should succeed)
INSERT INTO menuca_v3.orders (
  restaurant_id, 
  order_number, 
  user_id, 
  is_guest_order, 
  status
) VALUES (
  1, 
  'TEST-AUTH-001', 
  1, 
  FALSE, 
  'pending'
);

-- Test 4: Verify existing orders unchanged
SELECT 
  COUNT(*) as unchanged_orders
FROM menuca_v3.orders
WHERE is_guest_order = FALSE 
  AND user_id IS NOT NULL;
-- Expected: Count matches total orders before migration
```

### Integration Tests (Future - Phase 4)
- Test guest checkout flow end-to-end
- Test post-order account creation
- Test order lookup by email

---

## Expected Outcome

After implementation:
- ✅ `menuca_v3.orders` table supports both guest and authenticated orders
- ✅ All existing orders preserved with `is_guest_order` = FALSE
- ✅ Guest orders can be created with email/phone instead of user_id
- ✅ CHECK constraint prevents invalid guest orders (missing email)
- ✅ Index enables fast guest order lookups
- ✅ No breaking changes to existing functionality
- ✅ Foundation ready for Phase 4 guest checkout UI

---

## Rollback Plan

If issues arise:

```sql
BEGIN;

-- Remove index
DROP INDEX IF EXISTS menuca_v3.idx_orders_guest_email;

-- Remove CHECK constraint
ALTER TABLE menuca_v3.orders 
  DROP CONSTRAINT IF EXISTS orders_guest_email_check;

-- Make user_id NOT NULL again (only if no guest orders exist!)
ALTER TABLE menuca_v3.orders 
  ALTER COLUMN user_id SET NOT NULL;

-- Remove columns
ALTER TABLE menuca_v3.orders
  DROP COLUMN IF EXISTS is_guest_order,
  DROP COLUMN IF EXISTS guest_email,
  DROP COLUMN IF EXISTS guest_phone;

COMMIT;
```

**Warning:** Only rollback if no guest orders have been created!

---

## References

- **Gap Analysis:** `/FRONTEND_BUILD_START_HERE.md` (Gap #2: Guest Checkout Missing)
- **Cognition Wheel Review:** Found this as critical conversion killer
- **Build Plan:** `/CUSTOMER_ORDERING_APP_BUILD_PLAN.md` (Phase 4: Checkout)
- **Database Schema:** `/Database/Schemas/menuca_v3.sql`

---

## Notes for Builder

1. **Apply to production branch** - cursor-build will inherit automatically
2. **Test thoroughly** - This affects all future orders
3. **Verify existing data** - Must not break current orders
4. **Document in handoff** - Explain any decisions made
5. **Consider edge cases** - What if email is invalid format?

---

## Notes for Auditor

Please verify:
1. ✅ CHECK constraint logic is correct (prevents invalid guest orders)
2. ✅ Existing orders completely unaffected
3. ✅ NULL handling correct (user_id can be NULL for guests)
4. ✅ Index will improve query performance for guest lookups
5. ✅ Migration is reversible (rollback plan valid)
6. ✅ No SQL injection risks
7. ✅ Comments and documentation adequate

---

**Status:** ⏳ READY FOR ASSIGNMENT  
**Created:** 2025-10-22 by Orchestrator Agent  
**Next Step:** Assign to Builder Agent for implementation

