# Commission Rate Workflow

**Last Updated:** October 15, 2025  
**Status:** Implemented ✅

---

## 🎯 How Commission Rates Work

### Key Principle

**Commission rates are provided by the client, with a fallback to the last used rate.**

---

## 🔄 Complete Workflow

### Step 1: Get Vendor-Restaurant Assignment (with last used rate)

```typescript
// Backend API endpoint: GET /api/vendor-restaurants/:id
const assignment = await supabase
  .from('v_active_vendor_restaurants')
  .select('*')
  .eq('restaurant_uuid', restaurantId)
  .single();

// Returns:
{
  id: "uuid",
  vendor_id: "uuid",
  restaurant_uuid: "uuid",
  restaurant_name: "River Pizza",
  commission_template: "percent_commission",
  last_commission_rate_used: 10.0,        // ← For UI pre-fill
  last_commission_type_used: "percentage"  // ← For UI pre-fill
}
```

**Backend should provide this data when client is creating a commission report.**

---

### Step 2: Client Prepares Commission Calculation

```typescript
// Frontend: Report generation UI
const reportForm = {
  restaurant: assignment.restaurant_name,
  orderTotal: 10000.00,
  
  // Pre-fill with last used rate
  commissionRate: assignment.last_commission_rate_used || 10.0,
  commissionType: assignment.last_commission_type_used || 'percentage',
  
  // User can override if needed
  template: assignment.commission_template
};

// User can edit the rate before generating report
```

---

### Step 3: Calculate Commission (with rate provided or fallback)

```typescript
// Client calls Edge Function
const response = await fetch('/functions/v1/calculate-vendor-commission', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    template_name: assignment.commission_template,
    total: 10000.00,
    
    // Use provided rate OR fallback to last used
    restaurant_commission: reportForm.commissionRate || assignment.last_commission_rate_used,
    commission_type: reportForm.commissionType || assignment.last_commission_type_used,
    
    menuottawa_share: 80.00,
    vendor_id: assignment.vendor_id,
    restaurant_id: assignment.restaurant_uuid,
    restaurant_name: assignment.restaurant_name,
    restaurant_address: "..." // from restaurant data
  })
});

const calculation = await response.json();
// Returns: { use_total, for_vendor, for_menuca, ... }
```

---

### Step 4: Save Report (automatically updates last used rate)

```typescript
// Save commission report
const { data: report } = await supabase
  .from('vendor_commission_reports')
  .insert({
    vendor_id: assignment.vendor_id,
    restaurant_uuid: assignment.restaurant_uuid,
    statement_number: nextStatementNumber,
    report_period_start: '2025-01-01',
    report_period_end: '2025-01-31',
    calculation_template: assignment.commission_template,
    calculation_input: inputData,
    calculation_result: calculation,
    total_order_amount: 10000.00,
    vendor_commission_amount: calculation.for_vendor,
    platform_fee_amount: 80.00,
    
    // Store the rate used
    commission_rate_used: reportForm.commissionRate,
    commission_type_used: reportForm.commissionType,
    
    report_status: 'finalized',
    report_generated_at: new Date()
  })
  .select()
  .single();

// ✅ Trigger automatically updates vendor_restaurants.last_commission_rate_used
// ✅ Next time this UI is loaded, it will show the rate used in this report
```

---

## 🔧 Database Trigger (Automatic)

```sql
-- Automatically runs when a report is saved
CREATE TRIGGER trg_update_last_commission_rate
  AFTER INSERT OR UPDATE OF commission_rate_used
  ON menuca_v3.vendor_commission_reports
  FOR EACH ROW
  EXECUTE FUNCTION menuca_v3.update_last_commission_rate();

-- What it does:
-- 1. Report is saved with commission_rate_used = 15
-- 2. Trigger fires automatically
-- 3. Updates vendor_restaurants.last_commission_rate_used = 15
-- 4. Next report generation will show 15 as the last used rate
```

---

## 📊 Backend API Response Format

### GET /api/vendor-restaurants/:restaurantId/commission-info

```json
{
  "success": true,
  "data": {
    "vendor": {
      "id": "uuid",
      "business_name": "Menu Ottawa",
      "email": "vendor@example.com"
    },
    "restaurant": {
      "uuid": "uuid",
      "name": "River Pizza",
      "address": "123 Main St"
    },
    "commission_config": {
      "template": "percent_commission",
      "last_rate_used": 10.0,
      "last_type_used": "percentage",
      "last_updated": "2025-01-15T10:00:00Z"
    },
    "next_statement_number": 22
  }
}
```

**This endpoint provides everything the client needs to generate a commission report.**

---

## 🎯 Use Cases

### Use Case 1: First Report Ever

```typescript
// No previous rate exists
assignment.last_commission_rate_used = null

// Client provides rate (or uses default 10%)
commissionRate = 10.0

// After saving report:
// → vendor_restaurants.last_commission_rate_used = 10.0
```

---

### Use Case 2: Regular Monthly Report

```typescript
// Last report used 10%
assignment.last_commission_rate_used = 10.0

// UI pre-fills with 10%
// User keeps it the same
commissionRate = 10.0

// After saving report:
// → vendor_restaurants.last_commission_rate_used = 10.0 (unchanged)
```

---

### Use Case 3: Rate Changed This Month

```typescript
// Last report used 10%
assignment.last_commission_rate_used = 10.0

// UI pre-fills with 10%, but user changes it
commissionRate = 15.0  // ← User edited

// After saving report:
// → vendor_restaurants.last_commission_rate_used = 15.0 (updated!)
// → Next month's report will pre-fill with 15%
```

---

### Use Case 4: Client Doesn't Provide Rate (Fallback)

```typescript
// Client calls Edge Function without rate
const response = await fetch('/functions/v1/calculate-vendor-commission', {
  body: JSON.stringify({
    template_name: 'percent_commission',
    total: 10000.00,
    restaurant_commission: null,  // ← Not provided!
    // ...
  })
});

// Backend handles fallback:
const rate = input.restaurant_commission || 
             assignment.last_commission_rate_used || 
             10.0;  // Ultimate fallback
```

---

## ✅ Benefits

### 1. **User Experience**
- ✅ UI pre-fills with last used rate
- ✅ User knows what was used previously
- ✅ Easy to keep same rate or change it
- ✅ No manual rate lookup needed

### 2. **Flexibility**
- ✅ Rates can change month-to-month
- ✅ Override capability for special cases
- ✅ Automatic tracking of rate history

### 3. **Safety**
- ✅ Fallback prevents missing rates
- ✅ Historical audit trail in reports
- ✅ Automatic updates via trigger

### 4. **Developer Experience**
- ✅ Simple API contract
- ✅ Clear data flow
- ✅ Automatic rate tracking

---

## 🔍 Validation Rules

### Rate Validation

```typescript
// Backend should validate commission rate
function validateCommissionRate(rate: number, type: 'percentage' | 'fixed'): boolean {
  if (type === 'percentage') {
    // Percentage should be between 0 and 100
    return rate >= 0 && rate <= 100;
  } else {
    // Fixed amount should be non-negative
    return rate >= 0;
  }
}
```

---

## 📋 Backend Implementation Checklist

### Required Endpoints

- [x] `GET /api/vendor-restaurants/:id/commission-info` - Get assignment with last used rate
- [ ] `POST /api/commission-reports` - Create report (saves rate, trigger updates assignment)
- [ ] `GET /api/vendors/:id/next-statement-number` - Get next statement number for vendor

### Database

- [x] `vendor_restaurants.last_commission_rate_used` column
- [x] `vendor_restaurants.last_commission_type_used` column
- [x] `vendor_commission_reports.commission_rate_used` column
- [x] `vendor_commission_reports.commission_type_used` column
- [x] Trigger to auto-update last_commission_rate_used
- [x] View `v_active_vendor_restaurants` includes last used rate

### Edge Function

- [x] Accepts `restaurant_commission` parameter
- [x] Accepts optional `commission_type` parameter
- [x] Fallback logic for missing rate (handled by client/backend)

---

## 🎉 Summary

**The system provides intelligent defaults while maintaining flexibility:**

1. ✅ Backend provides `last_commission_rate_used` when client requests assignment info
2. ✅ Client uses this to pre-fill UI (user knows what was used last time)
3. ✅ User can keep same rate or change it
4. ✅ Client calls Edge Function with rate (or backend provides fallback)
5. ✅ Report is saved with `commission_rate_used`
6. ✅ Trigger automatically updates `last_commission_rate_used`
7. ✅ Next report generation shows updated rate

**Result:** Seamless workflow with historical context and flexibility for changes.

