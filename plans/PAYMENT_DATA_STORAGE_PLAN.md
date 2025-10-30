# Payment Data Storage Plan - MenuCA V3

**Created:** October 21, 2025  
**Status:** 📋 DOCUMENTED  
**Purpose:** Define what payment information is stored in database vs handled by Stripe

---

## 🎯 EXECUTIVE SUMMARY

MenuCA V3 follows **PCI-DSS compliant architecture** where:
- ✅ **Sensitive card data** → Stored ONLY by Stripe (never in our database)
- ✅ **Payment tokens & metadata** → Stored in our database
- ✅ **Transaction records** → Stored for reconciliation and reporting

---

## 📊 PAYMENT-RELATED TABLES

### **CURRENT STATE (✅ Exists in V3)**

#### **1. `menuca_v3.orders` (Main Order Table)**

**Payment Fields:**
```sql
-- Type of payment used
payment_method VARCHAR(50)  
-- Values: 'credit_card', 'cash', 'debit', 'apple_pay', 'google_pay', etc.

-- Payment processing status
payment_status VARCHAR(20) DEFAULT 'pending'
-- Values: 'pending', 'completed', 'failed', 'refunded', 'partially_refunded'

-- Stripe response data (tokens, NOT card numbers)
payment_info JSONB
-- Example: {
--   "payment_method_id": "pm_1234567890",     // Stripe token
--   "stripe_charge_id": "ch_1234567890",      // Stripe charge ID
--   "last4": "4242",                           // Last 4 digits
--   "brand": "visa",                           // Card brand
--   "exp_month": 12,                           // Expiration month
--   "exp_year": 2025                           // Expiration year
-- }
```

**Financial Fields (Order Totals):**
```sql
subtotal DECIMAL(10,2)           -- Items before fees/discounts
tax_total DECIMAL(10,2)          -- Total taxes
delivery_fee DECIMAL(10,2)       -- Delivery charge
convenience_fee DECIMAL(10,2)    -- Convenience charge
service_fee DECIMAL(10,2)        -- Service charge
driver_tip DECIMAL(10,2)         -- Tip amount
discount_total DECIMAL(10,2)     -- Total discounts
grand_total DECIMAL(10,2)        -- FINAL AMOUNT CHARGED
```

**Location:** `/Database/Orders_&_Checkout/01_create_v3_order_schema.sql` (Lines 58-61)

---

### **PLANNED STATE (⏳ Not Yet Implemented)**

#### **2. `menuca_v3.payments` (Separate Payments Table)**

**Status:** ⏳ **NOT YET CREATED** (Documented in `/Database/Mermaid_Diagrams/payments.mmd`)

**Purpose:** Track individual payment transactions separately from orders

**Planned Fields:**
```sql
CREATE TABLE menuca_v3.payments (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    
    -- Link to order
    order_id BIGINT NOT NULL,  -- FK → orders.id
    
    -- Payment details
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50),           -- 'credit_card', 'debit', 'cash', 'online'
    payment_status VARCHAR(20),           -- 'pending', 'completed', 'failed', 'refunded'
    
    -- Gateway integration (TOKENS ONLY, NO CARD DATA)
    transaction_id VARCHAR(255),          -- Stripe charge ID (ch_xxxx)
    gateway_name VARCHAR(50),             -- 'Stripe', 'PayPal', etc.
    gateway_response JSONB,               -- Full Stripe response (tokens only)
    
    -- Timestamps
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Note:** This table is mentioned in audit reports but hasn't been migrated from V1/V2 yet.

---

#### **3. `menuca_v3.payment_refunds` (Refund Tracking)**

**Status:** ⏳ **NOT YET CREATED** (Documented in `/Database/Mermaid_Diagrams/payments.mmd`)

**Purpose:** Track refund transactions

**Planned Fields:**
```sql
CREATE TABLE menuca_v3.payment_refunds (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4(),
    
    -- Link to payment
    payment_id BIGINT NOT NULL,  -- FK → payments.id
    
    -- Refund details
    refund_amount NUMERIC(10,2) NOT NULL,
    refund_reason TEXT,
    refund_status VARCHAR(20),            -- 'pending', 'completed', 'failed'
    refund_transaction_id VARCHAR(255),   -- Stripe refund ID (re_xxxx)
    
    -- Audit trail
    processed_at TIMESTAMPTZ,
    processed_by BIGINT,                  -- FK → users.id (admin who processed)
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

#### **4. `menuca_v3.payment_transactions` (Transaction Log)**

**Status:** ⏳ **MENTIONED** in audit reports but not fully documented

**Purpose:** Comprehensive transaction log for reconciliation

**Likely Fields:**
```sql
CREATE TABLE menuca_v3.payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT,
    payment_id BIGINT,
    transaction_type VARCHAR(50),         -- 'charge', 'refund', 'transfer', 'payout'
    amount NUMERIC(10,2),
    stripe_event_id VARCHAR(255),         -- Stripe webhook event ID (evt_xxxx)
    event_data JSONB,                     -- Full webhook payload
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔒 PCI-DSS COMPLIANCE: WHAT IS **NEVER** STORED

### ❌ NEVER Store in Database:

1. **Full Card Number** (PAN - Primary Account Number)
   - ❌ `4242 4242 4242 4242` → NEVER stored
   - ✅ Only last 4 digits: `4242` → Safe to store

2. **CVV/CVC Code** (Card Security Code)
   - ❌ `123` → NEVER stored (even by Stripe after validation)
   
3. **Magnetic Stripe Data** (Track Data)
   - ❌ Raw magnetic stripe data → NEVER stored

4. **PIN Numbers**
   - ❌ Debit card PINs → NEVER stored

### ✅ SAFE to Store (Tokens & Metadata):

1. **Stripe Payment Method ID**
   - ✅ `pm_1234567890` → Stripe token (safe)

2. **Stripe Charge ID**
   - ✅ `ch_1234567890` → Transaction reference (safe)

3. **Last 4 Digits**
   - ✅ `4242` → For display purposes (safe)

4. **Card Brand**
   - ✅ `visa`, `mastercard`, `amex` → For UI icons (safe)

5. **Expiration Date**
   - ✅ `12/2025` → For renewal reminders (safe)

6. **Full Stripe Response (JSONB)**
   - ✅ Stripe's complete response → Contains only tokens and metadata (safe)

---

## 🔄 PAYMENT FLOW ARCHITECTURE

### **Order Creation → Payment Processing:**

```
1. FRONTEND: User enters card info
   ↓
2. STRIPE.JS: Tokenizes card → Returns payment_method_id (pm_xxxx)
   ↓
3. BACKEND: Receives pm_xxxx (never sees real card)
   ↓
4. BACKEND → STRIPE API: Creates charge with pm_xxxx
   ↓
5. STRIPE: Returns charge_id (ch_xxxx) + metadata
   ↓
6. BACKEND → DATABASE: Stores:
   - payment_method: 'credit_card'
   - payment_status: 'completed'
   - payment_info: { pm_xxxx, ch_xxxx, last4, brand, exp }
```

### **Key Security Points:**

- ✅ **Card data never touches our servers** - Tokenized by Stripe.js in browser
- ✅ **Only tokens stored** - payment_method_id, charge_id
- ✅ **Stripe manages sensitive data** - We just reference it via tokens
- ✅ **PCI-DSS Level 1 compliant** - Stripe handles all card data
- ✅ **We store reconciliation data** - Transaction IDs, amounts, timestamps

---

## 📝 SQL FUNCTIONS FOR PAYMENT PROCESSING

### **Current Functions (✅ Implemented):**

1. **`process_payment(order_id, payment_method_id, payment_info)`**
   - **Location:** `/Database/Orders_&_Checkout/PHASE_5_MIGRATION_SCRIPT.sql`
   - **Purpose:** Process payment with Stripe token
   - **Stores:** `payment_method`, `payment_status`, `payment_info` (tokens only)

2. **`process_refund(order_id, refund_amount, reason)`**
   - **Location:** `/Database/Orders_&_Checkout/PHASE_5_MIGRATION_SCRIPT.sql`
   - **Purpose:** Process refund via Stripe
   - **Stores:** Updates `payment_status` to 'refunded', sets `is_refund` flag

3. **`update_order_tip(order_id, tip_amount)`**
   - **Location:** `/Database/Orders_&_Checkout/PHASE_5_MIGRATION_SCRIPT.sql`
   - **Purpose:** Update tip amount post-delivery
   - **Stores:** Updates `driver_tip` field

---

## 🔍 WHERE IS THIS DOCUMENTED?

### **Primary Sources:**

1. **Schema Definition:**
   - `/Database/Orders_&_Checkout/01_create_v3_order_schema.sql` (Lines 58-61)
   - Shows `payment_method`, `payment_status`, `payment_info` fields

2. **Payment Integration Guide:**
   - `/Database/Orders_&_Checkout/PHASE_5_BACKEND_DOCUMENTATION.md`
   - `/Database/Orders_&_Checkout/PHASE_5_MIGRATION_SCRIPT.sql`
   - Documents Stripe integration functions

3. **Planned Architecture:**
   - `/Database/Mermaid_Diagrams/payments.mmd`
   - Shows future `payments` and `payment_refunds` tables

4. **Backend Integration:**
   - `/documentation/Orders & Checkout/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`
   - Shows API endpoints for payment processing

5. **Completion Report:**
   - `/Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md`
   - Documents payment workflow and Stripe integration points

---

## 🎯 SUMMARY

### **Current Implementation (V3 Active):**
- ✅ Payment data stored in `orders.payment_info` (JSONB)
- ✅ Only Stripe tokens stored (pm_xxxx, ch_xxxx)
- ✅ PCI-DSS compliant (no card data)
- ✅ Payment functions implemented (stubs ready for Stripe API)

### **Future Expansion (Planned):**
- ⏳ Separate `payments` table (not yet created)
- ⏳ Separate `payment_refunds` table (not yet created)
- ⏳ `payment_transactions` table (mentioned but not specified)

### **What Stripe Handles (Never in Our DB):**
- ❌ Full card numbers (PAN)
- ❌ CVV/CVC codes
- ❌ Magnetic stripe data
- ❌ PIN numbers

### **Compliance Status:**
- ✅ **PCI-DSS Level 1** - Stripe certified
- ✅ **GDPR compliant** - Customer payment data isolated via RLS
- ✅ **Audit trail** - All payment changes tracked in `order_status_history`

---

## 📞 IMPLEMENTATION NOTES

### **For Backend Integration (Santiago):**

1. **Use Stripe.js on frontend** - Never send raw card data to backend
2. **Receive only payment_method_id** - Token from Stripe
3. **Call Stripe API from backend** - Process charge with token
4. **Store response in payment_info** - Stripe metadata only
5. **Webhook for async events** - Handle payment confirmations

### **Backend API Pattern:**

```typescript
// POST /api/orders/:id/payment
export async function processPayment(req, res) {
  const { payment_method_id } = req.body;  // pm_xxxx from Stripe.js
  
  // 1. Call Stripe API (backend only)
  const stripe_result = await stripe.charges.create({
    amount: orderTotal,
    currency: 'cad',
    payment_method: payment_method_id,  // Token from frontend
    confirm: true
  });
  
  // 2. Store Stripe response (tokens only)
  const { data } = await supabase.rpc('process_payment', {
    p_order_id: orderId,
    p_payment_method_id: payment_method_id,
    p_payment_info: {
      stripe_charge_id: stripe_result.id,    // ch_xxxx
      last4: stripe_result.payment_method_details.card.last4,
      brand: stripe_result.payment_method_details.card.brand,
      // NO card number, NO CVV
    }
  });
}
```

---

**Status:** ✅ DOCUMENTED  
**Next Steps:** Create separate `payments` and `payment_refunds` tables when needed for advanced features

---

*Last Updated: October 21, 2025*

