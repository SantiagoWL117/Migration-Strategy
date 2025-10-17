# Phase 3 Backend Documentation: Schema Optimization
## Marketing & Promotions Entity - For Backend Development

**Created:** January 17, 2025  
**Phase:** 3 of 7 - Audit Trails, Soft Delete, Data Validation  
**Status:** ✅ COMPLETE - Ready for Backend Implementation

---

## 🚨 **BUSINESS PROBLEM**

Marketing & Promotions need **data integrity and recoverability**:
- **No Audit Trail:** Can't track who created or modified deals/coupons
- **Permanent Deletes:** Accidental deletion of active promotions
- **Invalid Data:** Bad dates, malformed coupon codes slip through
- **No Recovery:** Deleted deals are gone forever
- **Compliance Risk:** Can't prove who approved what

**Impact:** Revenue loss from deleted campaigns, compliance failures, and inability to recover from mistakes.

---

## ✅ **THE SOLUTION**

Implement **complete data lifecycle management**:
1. **Auto-Update Triggers** - Track every change automatically
2. **Validation Triggers** - Prevent invalid data at database level
3. **Soft Delete System** - Mark as deleted, keep data
4. **Restore Functions** - Recover deleted items
5. **Admin Helper Functions** - Clone, bulk enable/disable
6. **Active-Only Views** - Filter soft-deleted records

---

## 🧩 **GAINED BUSINESS LOGIC COMPONENTS**

### **1. Automatic Audit Tracking**

**Trigger Function:** `update_updated_at_column()`

**Applied To:**
- `promotional_deals`
- `promotional_coupons`
- `marketing_tags`

**What It Does:**
- Auto-sets `updated_at` timestamp
- Auto-sets `updated_by` user ID
- Triggers on every UPDATE operation

**Backend Benefit:**
```typescript
// No manual tracking needed!
await supabase
  .from('promotional_deals')
  .update({ title: 'New Title' })
  .eq('id', dealId);

// Database automatically sets:
// - updated_at = NOW()
// - updated_by = current_admin_user_id
```

---

### **2. Data Validation Triggers**

#### **Trigger 1: Validate Deal Dates**

**Function:** `validate_deal_dates()`

**Validation Rules:**
- ✅ `start_date` must be before `end_date`
- ⚠️ Warning if `end_date` is in the past

**Error Example:**
```typescript
// This will fail:
await supabase
  .from('promotional_deals')
  .insert({
    start_date: '2025-12-31',
    end_date: '2025-01-01', // BEFORE start!
    // ...
  });

// Error: "Deal start_date must be before end_date"
```

---

#### **Trigger 2: Validate Coupon Data**

**Function:** `validate_coupon_data()`

**Validation Rules:**
- ✅ `valid_from` must be before `valid_until`
- ✅ Auto-converts code to UPPERCASE
- ✅ Code format: `^[A-Z0-9_-]+$` (alphanumeric, underscore, hyphen only)

**Examples:**
```typescript
// This works:
await supabase
  .from('promotional_coupons')
  .insert({
    code: 'summer20', // Auto-converted to 'SUMMER20'
    valid_from: '2025-06-01',
    valid_until: '2025-08-31'
  });

// This fails:
await supabase
  .from('promotional_coupons')
  .insert({
    code: 'summer 20!', // Spaces and special chars not allowed
    // Error: "Coupon code must contain only uppercase letters, numbers, underscores, and hyphens"
  });
```

---

#### **Trigger 3: Check Coupon Code Uniqueness**

**Function:** `check_coupon_code_uniqueness()`

**Validation:** No duplicate coupon codes (case-insensitive)

**Example:**
```typescript
// First coupon: 'WELCOME10' created ✅

// Try to create duplicate:
await supabase
  .from('promotional_coupons')
  .insert({
    code: 'welcome10', // Same as 'WELCOME10'
    // ...
  });

// Error: 'Coupon code "welcome10" already exists'
```

---

### **3. Soft Delete Functions**

#### **Function: Soft Delete Deal**

**Signature:**
```sql
menuca_v3.soft_delete_deal(
    p_deal_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
```

**What It Does:**
- Sets `deleted_at` = NOW()
- Sets `deleted_by` = current admin user
- Sets `is_active` = false
- **Keeps all data** for recovery

**Backend API:**
```typescript
// DELETE /api/admin/restaurants/:rid/deals/:did
export async function softDeleteDeal(req, res) {
  const { did: dealId } = req.params;
  const { reason } = req.body;

  // Soft delete (NOT permanent!)
  const { data: result } = await supabase.rpc('soft_delete_deal', {
    p_deal_id: dealId,
    p_reason: reason || 'User requested deletion'
  });

  if (!result.success) {
    return res.status(404).json({ error: result.message });
  }

  res.json({
    message: 'Deal deleted successfully',
    deal_id: dealId,
    recoverable: true,
    deleted_at: result.deleted_at
  });
}
```

---

#### **Function: Restore Deal**

**Signature:**
```sql
menuca_v3.restore_deal(p_deal_id UUID)
RETURNS JSONB
```

**What It Does:**
- Clears `deleted_at` and `deleted_by`
- **Does NOT** re-activate (stays `is_active = false`)
- Allows admin to review before re-activating

**Backend API:**
```typescript
// POST /api/admin/restaurants/:rid/deals/:did/restore
export async function restoreDeal(req, res) {
  const { did: dealId } = req.params;

  const { data: result } = await supabase.rpc('restore_deal', {
    p_deal_id: dealId
  });

  if (!result.success) {
    return res.status(404).json({ error: result.message });
  }

  res.json({
    message: 'Deal restored successfully',
    deal_id: dealId,
    note: 'Deal is inactive. Use toggle_deal_status to activate.'
  });
}
```

---

#### **Function: Soft Delete Coupon**

**Signature:**
```sql
menuca_v3.soft_delete_coupon(p_coupon_id UUID)
RETURNS JSONB
```

**Similar to soft_delete_deal** but for coupons.

---

#### **Function: Restore Coupon**

**Signature:**
```sql
menuca_v3.restore_coupon(p_coupon_id UUID)
RETURNS JSONB
```

**Backend API:**
```typescript
// POST /api/admin/coupons/:id/restore
export async function restoreCoupon(req, res) {
  const { id: couponId } = req.params;

  const { data: result } = await supabase.rpc('restore_coupon', {
    p_coupon_id: couponId
  });

  res.json(result);
}
```

---

### **4. Admin Helper Functions**

#### **Function: Clone Deal**

**Signature:**
```sql
menuca_v3.clone_deal(
    p_source_deal_id UUID,
    p_target_restaurant_id BIGINT,
    p_new_title VARCHAR(200) DEFAULT NULL
)
RETURNS JSONB
```

**Purpose:** Duplicate a deal to another restaurant (or same restaurant)

**Use Cases:**
- Franchise owners: Clone successful deals across locations
- Platform admins: Roll out promotions to multiple restaurants
- Restaurant managers: Repeat seasonal campaigns

**Backend API:**
```typescript
// POST /api/admin/deals/:id/clone
export async function cloneDeal(req, res) {
  const { id: sourceDealId } = req.params;
  const { target_restaurant_id, new_title } = req.body;

  const { data: result } = await supabase.rpc('clone_deal', {
    p_source_deal_id: sourceDealId,
    p_target_restaurant_id: target_restaurant_id,
    p_new_title: new_title || null
  });

  if (!result.success) {
    return res.status(400).json({ error: result.message });
  }

  res.json({
    message: 'Deal cloned successfully',
    source_deal_id: sourceDealId,
    new_deal_id: result.new_deal_id,
    target_restaurant_id: target_restaurant_id,
    note: 'Cloned deal starts inactive. Review and activate when ready.'
  });
}
```

---

#### **Function: Bulk Disable Deals**

**Signature:**
```sql
menuca_v3.bulk_disable_deals(p_restaurant_id BIGINT)
RETURNS JSONB
```

**Purpose:** Emergency shutoff - disable all deals for a restaurant

**Use Cases:**
- Restaurant closed temporarily
- Deal budget exceeded
- Emergency situation

**Backend API:**
```typescript
// POST /api/admin/restaurants/:id/deals/bulk-disable
export async function bulkDisableDeals(req, res) {
  const { id: restaurantId } = req.params;

  const { data: result } = await supabase.rpc('bulk_disable_deals', {
    p_restaurant_id: parseInt(restaurantId)
  });

  res.json({
    message: result.message,
    affected_count: result.affected_count,
    restaurant_id: restaurantId
  });
}
```

---

#### **Function: Bulk Enable Deals**

**Signature:**
```sql
menuca_v3.bulk_enable_deals(
    p_restaurant_id BIGINT,
    p_deal_ids UUID[] DEFAULT NULL
)
RETURNS JSONB
```

**Purpose:** Enable all deals or specific deals for a restaurant

**Backend API:**
```typescript
// POST /api/admin/restaurants/:id/deals/bulk-enable
export async function bulkEnableDeals(req, res) {
  const { id: restaurantId } = req.params;
  const { deal_ids } = req.body; // Optional: specific deals

  const { data: result } = await supabase.rpc('bulk_enable_deals', {
    p_restaurant_id: parseInt(restaurantId),
    p_deal_ids: deal_ids || null // null = enable all
  });

  res.json({
    message: result.message,
    affected_count: result.affected_count
  });
}
```

---

### **5. Active-Only Views**

**Purpose:** Simplify queries by auto-filtering soft-deleted records

**Views Created:**
- `menuca_v3.active_deals`
- `menuca_v3.active_coupons`
- `menuca_v3.active_tags`

**Backend Usage:**
```typescript
// Instead of:
const { data: deals } = await supabase
  .from('promotional_deals')
  .select('*')
  .is('deleted_at', null); // Manual filter

// Use views:
const { data: deals } = await supabase
  .from('active_deals')
  .select('*'); // Auto-filtered!
```

**Note:** Views still respect RLS policies

---

## 💻 **BACKEND FUNCTIONALITY REQUIRED**

### **Priority 1: Implement Soft Delete in UI** ✅ CRITICAL

**Delete Button Logic:**
```typescript
// Admin dashboard - Delete Deal button
async function handleDeleteDeal(dealId: string) {
  // Confirm with user
  const confirmed = await confirmDialog({
    title: 'Delete Deal?',
    message: 'This deal will be archived and can be restored later.',
    confirmText: 'Delete',
    cancelText: 'Cancel'
  });

  if (!confirmed) return;

  // Soft delete
  const response = await fetch(`/api/admin/deals/${dealId}`, {
    method: 'DELETE',
    body: JSON.stringify({
      reason: 'User requested deletion'
    })
  });

  if (response.ok) {
    showSuccess('Deal deleted. You can restore it from the archive.');
    refreshDealsList();
  }
}
```

---

### **Priority 2: Build Restore UI** ⚠️ IMPORTANT

**Archive/Trash View:**
```typescript
// GET /api/admin/restaurants/:id/deals/deleted
export async function getDeletedDeals(req, res) {
  const { id: restaurantId } = req.params;

  // Query soft-deleted deals
  const { data: deletedDeals } = await supabase
    .from('promotional_deals')
    .select('*')
    .eq('restaurant_id', restaurantId)
    .not('deleted_at', 'is', null)
    .order('deleted_at', { ascending: false });

  res.json({
    deleted_deals: deletedDeals,
    count: deletedDeals.length
  });
}

// Frontend component
function DeletedDealsArchive() {
  const [deletedDeals, setDeletedDeals] = useState([]);

  return (
    <div className="archive">
      <h2>Deleted Deals (Recoverable)</h2>
      {deletedDeals.map(deal => (
        <div key={deal.id} className="deleted-deal">
          <span>{deal.title}</span>
          <span>Deleted: {formatDate(deal.deleted_at)}</span>
          <button onClick={() => restoreDeal(deal.id)}>
            Restore
          </button>
        </div>
      ))}
    </div>
  );
}
```

---

### **Priority 3: Auto-Cleanup Old Soft Deletes** 💡 NICE TO HAVE

**Scheduled Job:**
```typescript
// Run weekly: Permanently delete records soft-deleted > 90 days ago
import cron from 'node-cron';

cron.schedule('0 2 * * 0', async () => {
  // Every Sunday at 2 AM
  console.log('Running soft-delete cleanup...');

  const { data } = await supabase
    .from('promotional_deals')
    .delete()
    .lt('deleted_at', new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString())
    .not('deleted_at', 'is', null);

  console.log(`Permanently deleted ${data?.length || 0} old deals`);
});
```

---

## 🗄️ **SCHEMA MODIFICATIONS**

**Triggers Created:** 5
- `update_deals_updated_at`
- `update_coupons_updated_at`
- `update_tags_updated_at`
- `validate_deal_dates_trigger`
- `validate_coupon_data_trigger`
- `check_coupon_code_uniqueness_trigger`

**Functions Created:** 7
- `soft_delete_deal()`
- `restore_deal()`
- `soft_delete_coupon()`
- `restore_coupon()`
- `clone_deal()`
- `bulk_disable_deals()`
- `bulk_enable_deals()`

**Views Created:** 3
- `active_deals`
- `active_coupons`
- `active_tags`

---

## 🎯 **IMPLEMENTATION PRIORITY**

### **Week 1:**
1. Implement soft delete in admin UI
2. Add confirmation dialogs
3. Test restore functionality
4. Build deleted items archive view

### **Week 2:**
1. Implement deal cloning feature
2. Add bulk enable/disable controls
3. Create auto-cleanup job
4. Test all validation triggers

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 3 Complete** - Data integrity and recovery ready
2. ⏳ **Santiago: Build Admin Tools** - Soft delete UI, restore, clone
3. ⏳ **Phase 4: Real-Time Updates** - Live promotion notifications
4. ⏳ **Phase 5: Multi-Language** - Translations for deals/coupons

---

**Status:** ✅ Schema optimization complete, data recovery system ready! 🔄

