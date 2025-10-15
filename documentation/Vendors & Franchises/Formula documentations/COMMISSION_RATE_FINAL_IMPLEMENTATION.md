# Commission Rate Implementation: Final Architecture

**Date:** October 15, 2025  
**Status:** ✅ IMPLEMENTED  
**Model:** Client-provided with intelligent fallback

---

## 🎯 Final Decision

**Commission rates are provided by the client at calculation time, with a fallback to the last used rate.**

---

## 📊 Database Schema (Implemented)

### `menuca_v3.vendor_restaurants`

```sql
CREATE TABLE menuca_v3.vendor_restaurants (
    id UUID PRIMARY KEY,
    vendor_id UUID NOT NULL,
    restaurant_uuid UUID NOT NULL,
    commission_template VARCHAR(50) NOT NULL,
    
    -- Last used rate (reference and fallback)
    last_commission_rate_used DECIMAL(10,2),
    last_commission_type_used commission_rate_type DEFAULT 'percentage',
    
    is_active BOOLEAN DEFAULT true,
    assignment_start_date DATE,
    assignment_end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Fields:**
- ✅ `commission_template` - Which formula to use
- ✅ `last_commission_rate_used` - Last used rate (for UI pre-fill and fallback)
- ✅ `last_commission_type_used` - Last used type (percentage or fixed)

---

### `menuca_v3.vendor_commission_reports`

```sql
CREATE TABLE menuca_v3.vendor_commission_reports (
    id UUID PRIMARY KEY,
    vendor_id UUID NOT NULL,
    restaurant_uuid UUID NOT NULL,
    statement_number INTEGER NOT NULL,
    
    -- Historical rate tracking
    commission_rate_used DECIMAL(10,2),
    commission_type_used commission_rate_type DEFAULT 'percentage',
    
    -- Amounts and calculation results
    total_order_amount DECIMAL(10,2),
    vendor_commission_amount DECIMAL(10,2),
    platform_fee_amount DECIMAL(10,2),
    calculation_input JSONB,
    calculation_result JSONB,
    
    report_status TEXT DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Fields:**
- ✅ `commission_rate_used` - The actual rate used for THIS specific report (audit trail)
- ✅ `commission_type_used` - The actual type used for THIS specific report

---

## 🔄 Automatic Rate Update (Trigger)

```sql
-- Trigger function
CREATE OR REPLACE FUNCTION menuca_v3.update_last_commission_rate()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE menuca_v3.vendor_restaurants
  SET 
    last_commission_rate_used = NEW.commission_rate_used,
    last_commission_type_used = NEW.commission_type_used,
    updated_at = NOW()
  WHERE vendor_id = NEW.vendor_id
    AND restaurant_uuid = NEW.restaurant_uuid
    AND is_active = true;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trg_update_last_commission_rate
  AFTER INSERT OR UPDATE OF commission_rate_used
  ON menuca_v3.vendor_commission_reports
  FOR EACH ROW
  WHEN (NEW.commission_rate_used IS NOT NULL)
  EXECUTE FUNCTION menuca_v3.update_last_commission_rate();
```

**What it does:**
1. When a report is saved with `commission_rate_used = 15`
2. Trigger automatically fires
3. Updates `vendor_restaurants.last_commission_rate_used = 15`
4. Next report generation will pre-fill with 15

---

## 🔧 Complete Workflow

### Step 1: Backend Provides Assignment Info

```typescript
// Backend API: GET /api/vendor-restaurants/:id/commission-info
{
  "vendor_id": "uuid",
  "restaurant_uuid": "uuid",
  "restaurant_name": "River Pizza",
  "commission_template": "percent_commission",
  "last_commission_rate_used": 10.0,        // ← Client uses this
  "last_commission_type_used": "percentage",
  "next_statement_number": 22
}
```

**Backend must provide `last_commission_rate_used` so the user knows what was used last time.**

---

### Step 2: Client UI Pre-fills with Last Used Rate

```typescript
// Frontend: Commission report generation UI
const reportForm = {
  restaurant: "River Pizza",
  orderTotal: 10000.00,
  
  // Pre-fill with last used rate
  commissionRate: assignmentInfo.last_commission_rate_used || 10.0,
  commissionType: assignmentInfo.last_commission_type_used || 'percentage'
};

// User can see and modify the rate before generating
```

---

### Step 3: Calculate Commission

```typescript
// Client calls Edge Function with rate
const calculation = await fetch('/functions/v1/calculate-vendor-commission', {
  method: 'POST',
  body: JSON.stringify({
    template_name: 'percent_commission',
    total: 10000.00,
    restaurant_commission: reportForm.commissionRate,  // ← Client provides
    commission_type: reportForm.commissionType,
    menuottawa_share: 80.00,
    vendor_id: assignmentInfo.vendor_id,
    restaurant_id: assignmentInfo.restaurant_uuid,
    restaurant_name: assignmentInfo.restaurant_name,
    restaurant_address: "..."
  })
});

// Returns: { use_total, for_vendor, for_menuca, ... }
```

**If client doesn't provide rate, backend can use fallback:**
```typescript
const rateToUse = input.restaurant_commission || 
                  assignmentInfo.last_commission_rate_used || 
                  10.0;
```

---

### Step 4: Save Report (Automatic Update)

```typescript
// Save commission report
const report = await supabase
  .from('vendor_commission_reports')
  .insert({
    vendor_id: assignmentInfo.vendor_id,
    restaurant_uuid: assignmentInfo.restaurant_uuid,
    statement_number: 22,
    
    // Store the rate that was actually used
    commission_rate_used: reportForm.commissionRate,
    commission_type_used: reportForm.commissionType,
    
    // Store calculation details
    calculation_input: inputData,
    calculation_result: calculation,
    total_order_amount: 10000.00,
    vendor_commission_amount: calculation.for_vendor,
    platform_fee_amount: 80.00,
    
    report_status: 'finalized',
    report_generated_at: new Date()
  });

// ✅ Trigger fires automatically
// ✅ Updates vendor_restaurants.last_commission_rate_used
// ✅ Next report will show this rate
```

---

## ✅ Benefits of This Approach

### 1. **User Experience**
- ✅ User sees what rate was used last time
- ✅ UI pre-fills with intelligent default
- ✅ Easy to keep same or change rate
- ✅ No manual lookup required

### 2. **Flexibility**
- ✅ Rates can change month-to-month
- ✅ Client has full control over rate
- ✅ Override capability for special cases

### 3. **Safety & Audit**
- ✅ Fallback prevents missing rates
- ✅ Complete historical audit trail
- ✅ Every report records actual rate used

### 4. **Automation**
- ✅ Trigger automatically tracks last used rate
- ✅ No manual updates required
- ✅ Always in sync with latest report

---

## 📋 Migration Status

### Applied to Production ✅

- [x] Added `last_commission_rate_used` column to `vendor_restaurants`
- [x] Added `last_commission_type_used` column to `vendor_restaurants`
- [x] Populated with default 10% for all 30 existing assignments
- [x] Added `commission_rate_used` column to `vendor_commission_reports`
- [x] Added `commission_type_used` column to `vendor_commission_reports`
- [x] Populated all 286 V2 reports with inferred 10% rate
- [x] Created trigger function `update_last_commission_rate()`
- [x] Created trigger `trg_update_last_commission_rate`
- [x] Updated view `v_active_vendor_restaurants` to include rate fields

### Updated Documentation ✅

- [x] `COMMISSION_RATE_ARCHITECTURE.md` - Complete architecture
- [x] `COMMISSION_RATE_WORKFLOW.md` - Step-by-step workflow
- [x] `COMMISSION_RATE_FINAL_IMPLEMENTATION.md` - This document
- [x] `PHASE_6_ARCHITECTURE_UPDATES.md` - Change summary
- [x] `phase5_create_v3_schema.sql` - Updated schema definition

---

## 🎯 Backend Implementation Requirements

### Required Endpoints

```typescript
// 1. Get assignment info with last used rate
GET /api/vendor-restaurants/:restaurantId/commission-info
Response: {
  vendor_id, 
  restaurant_uuid, 
  commission_template,
  last_commission_rate_used,  // ← Must provide this
  last_commission_type_used,
  next_statement_number
}

// 2. Create commission report
POST /api/commission-reports
Body: {
  vendor_id,
  restaurant_uuid,
  commission_rate_used,  // ← Must save this
  commission_type_used,
  total_order_amount,
  vendor_commission_amount,
  calculation_input,
  calculation_result
}
// ✅ Trigger will auto-update last_commission_rate_used

// 3. Calculate commission (Edge Function)
POST /functions/v1/calculate-vendor-commission
Body: {
  template_name,
  total,
  restaurant_commission,  // ← Client provides (or backend uses fallback)
  commission_type,
  menuottawa_share
}
```

---

## 🔍 Example Scenarios

### Scenario 1: First Report Ever

```typescript
// Initial state
last_commission_rate_used = null

// Client provides rate
commission_rate = 10.0

// After saving report:
// → last_commission_rate_used = 10.0 (via trigger)

// Next month:
// → UI pre-fills with 10.0
```

---

### Scenario 2: Rate Changes Monthly

```typescript
// January report
last_commission_rate_used = 10.0
commission_rate_used = 10.0
// → last_commission_rate_used = 10.0

// February (special promotion)
last_commission_rate_used = 10.0  // Shows last month's rate
commission_rate_used = 15.0       // User changes to 15%
// → last_commission_rate_used = 15.0 (updated by trigger)

// March (back to normal)
last_commission_rate_used = 15.0  // Shows February's rate
commission_rate_used = 10.0       // User changes back to 10%
// → last_commission_rate_used = 10.0 (updated by trigger)
```

---

### Scenario 3: Client Doesn't Provide Rate (Fallback)

```typescript
// Backend fallback logic
const rateToUse = input.restaurant_commission || 
                  assignment.last_commission_rate_used || 
                  10.0;  // Ultimate fallback

// Edge Function is called with fallback rate
// Report is saved with actual rate used
// Trigger updates last_commission_rate_used
```

---

## 🎉 Summary

### What We Built

A **hybrid approach** that combines:
- ✅ **Dynamic rates** (client-provided, can change monthly)
- ✅ **Intelligent defaults** (last used rate for UI pre-fill)
- ✅ **Automatic tracking** (trigger updates reference value)
- ✅ **Complete audit trail** (every report records actual rate)
- ✅ **Fallback safety** (prevents missing rates)

### Key Components

1. **Database Schema** - Stores last used rate as reference
2. **Automatic Trigger** - Updates last used rate after each report
3. **Edge Function** - Stateless calculation with rate parameter
4. **Backend API** - Provides last used rate to client
5. **Client UI** - Pre-fills with last used rate, allows changes

### Result

A flexible, user-friendly commission system that:
- Shows users what rate was used previously
- Allows easy rate changes when needed
- Maintains complete historical accuracy
- Works seamlessly with automatic updates

**Status: ✅ FULLY IMPLEMENTED AND TESTED**

---

## 📚 Reference

- **Workflow Guide:** `COMMISSION_RATE_WORKFLOW.md`
- **Architecture Overview:** `COMMISSION_RATE_ARCHITECTURE.md`
- **Schema Definition:** `phase5_create_v3_schema.sql`
- **Edge Function:** `supabase/functions/calculate-vendor-commission/`

