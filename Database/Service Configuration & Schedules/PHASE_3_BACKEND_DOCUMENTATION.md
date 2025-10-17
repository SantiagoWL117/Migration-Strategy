# Phase 3: Schema Optimization - Backend Documentation

**Phase:** 3 of 7  
**Focus:** Audit Trails, Soft Delete, Schedule Validation  
**Status:** ✅ COMPLETE  
**Date:** January 16, 2025  
**Developer:** Brian + AI Assistant  

---

## 🎯 **BUSINESS LOGIC OVERVIEW**

Phase 3 implements **enterprise-grade data integrity** for schedule management. This phase adds complete audit trails, soft delete recovery, and schedule conflict prevention to ensure data quality and operational safety.

### **Key Business Requirements**
1. **Audit Trails:** Track who created/modified schedules and when
2. **Soft Delete:** Never lose data - mark as deleted instead of removing
3. **Conflict Prevention:** Automatically prevent overlapping schedules
4. **Admin Tools:** Helper functions for schedule management
5. **Data Recovery:** Restore accidentally deleted schedules

---

## 🏗️ **SCHEMA ENHANCEMENTS**

### **Audit Columns Added**

All 4 schedule tables now have complete audit trails:

```sql
-- Audit columns on every table
created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
created_by    INTEGER                              -- User who created
updated_at    TIMESTAMPTZ                          -- Auto-updated on change
updated_by    INTEGER                              -- User who modified
deleted_at    TIMESTAMPTZ                          -- Soft delete timestamp
deleted_by    BIGINT                               -- User who deleted
```

**Tables Enhanced:**
- ✅ `restaurant_schedules`
- ✅ `restaurant_service_configs`
- ✅ `restaurant_special_schedules`
- ✅ `restaurant_time_periods`

---

## 🤖 **AUTO-UPDATE TRIGGERS**

### **Automatic Audit Trail**

Every update automatically records timestamp and user:

```sql
-- Trigger function (applied to all 4 tables)
CREATE TRIGGER trg_restaurant_schedules_updated_at
    BEFORE UPDATE ON restaurant_schedules
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();
```

**What It Does:**
- Sets `updated_at = NOW()` on every update
- Extracts `user_id` from JWT and sets `updated_by`
- Automatic - no code changes needed

**Example:**
```typescript
// Santiago just updates normally
await supabase
  .from('restaurant_schedules')
  .update({ is_enabled: false })
  .eq('id', 123);

// Database automatically sets:
// updated_at = '2025-01-16 18:45:00'
// updated_by = 45 (from JWT)
```

---

## 🛡️ **SCHEDULE CONFLICT PREVENTION**

### **Overlap Validation Trigger**

Automatically prevents overlapping schedules for the same restaurant and service type:

```sql
CREATE TRIGGER trg_restaurant_schedules_no_overlap
    BEFORE INSERT OR UPDATE ON restaurant_schedules
    FOR EACH ROW
    EXECUTE FUNCTION check_schedule_overlap();
```

### **What Gets Validated**

**Conflict Conditions:**
1. Same `restaurant_id` + `tenant_id`
2. Same `service_type` (delivery or takeout)
3. Overlapping day ranges
4. Overlapping time ranges
5. Both schedules `is_enabled = true`
6. Neither schedule soft-deleted

**Example Conflict:**
```typescript
// Existing schedule
{
  restaurant_id: 950,
  type: 'delivery',
  day_start: 1,  // Monday
  day_stop: 5,   // Friday
  time_start: '11:00',
  time_stop: '22:00'
}

// ❌ This would FAIL (overlaps Monday-Friday, 12:00-20:00)
await supabase.from('restaurant_schedules').insert({
  restaurant_id: 950,
  type: 'delivery',
  day_start: 1,
  day_stop: 3,
  time_start: '12:00',
  time_stop: '20:00'
});

// Error: "Schedule overlaps with existing schedule for delivery on day 1"
```

---

## 🔧 **ADMIN HELPER FUNCTIONS**

### **Summary**

| Function | Purpose | Use Case |
|----------|---------|----------|
| `soft_delete_schedule()` | Mark schedule as deleted | Safely remove schedules |
| `restore_schedule()` | Undelete schedule | Recover mistakes |
| `has_schedule_conflict()` | Check for conflicts | Validate before insert |
| `bulk_toggle_schedules()` | Enable/disable all | Quick service on/off |
| `clone_schedule_to_day()` | Duplicate schedule | Copy Mon hours to Tue |

---

### **1. soft_delete_schedule()**

**Purpose:** Safely delete a schedule without losing data

```sql
menuca_v3.soft_delete_schedule(
    p_schedule_id BIGINT,
    p_deleted_by INTEGER DEFAULT NULL
)
RETURNS BOOLEAN
```

**TypeScript Integration:**

```typescript
export async function softDeleteSchedule(
  scheduleId: number,
  deletedBy?: number
): Promise<boolean> {
  const { data, error } = await supabase.rpc('soft_delete_schedule', {
    p_schedule_id: scheduleId,
    p_deleted_by: deletedBy
  });

  if (error) throw error;
  return data;
}

// Usage
const deleted = await softDeleteSchedule(123, 45);
if (deleted) {
  console.log('Schedule soft-deleted successfully');
}
```

**REST API Wrapper:**

```typescript
// DELETE /api/admin/restaurants/:rid/schedules/:sid
app.delete('/api/admin/restaurants/:rid/schedules/:sid', async (req, res) => {
  const scheduleId = parseInt(req.params.sid);
  const userId = req.user.id;  // From auth middleware

  try {
    const deleted = await softDeleteSchedule(scheduleId, userId);
    
    if (!deleted) {
      return res.status(404).json({ error: 'Schedule not found' });
    }
    
    res.json({ 
      message: 'Schedule deleted successfully',
      recoverable: true
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete schedule' });
  }
});
```

---

### **2. restore_schedule()**

**Purpose:** Recover a soft-deleted schedule

```sql
menuca_v3.restore_schedule(p_schedule_id BIGINT)
RETURNS BOOLEAN
```

**TypeScript Integration:**

```typescript
export async function restoreSchedule(
  scheduleId: number
): Promise<boolean> {
  const { data, error } = await supabase.rpc('restore_schedule', {
    p_schedule_id: scheduleId
  });

  if (error) throw error;
  return data;
}

// Usage
const restored = await restoreSchedule(123);
if (restored) {
  console.log('Schedule restored successfully');
}
```

**REST API Wrapper:**

```typescript
// POST /api/admin/restaurants/:rid/schedules/:sid/restore
app.post('/api/admin/restaurants/:rid/schedules/:sid/restore', async (req, res) => {
  const scheduleId = parseInt(req.params.sid);

  try {
    const restored = await restoreSchedule(scheduleId);
    
    if (!restored) {
      return res.status(404).json({ 
        error: 'Schedule not found or already active' 
      });
    }
    
    res.json({ message: 'Schedule restored successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to restore schedule' });
  }
});
```

---

### **3. has_schedule_conflict()**

**Purpose:** Check for conflicts before inserting/updating

```sql
menuca_v3.has_schedule_conflict(
    p_restaurant_id BIGINT,
    p_tenant_id UUID,
    p_service_type service_type,
    p_day_start SMALLINT,
    p_day_stop SMALLINT,
    p_time_start TIME,
    p_time_stop TIME,
    p_exclude_schedule_id BIGINT DEFAULT NULL
)
RETURNS BOOLEAN
```

**TypeScript Integration:**

```typescript
export async function hasScheduleConflict(params: {
  restaurantId: number;
  tenantId: string;
  serviceType: 'delivery' | 'takeout';
  dayStart: number;
  dayStop: number;
  timeStart: string;
  timeStop: string;
  excludeScheduleId?: number;
}): Promise<boolean> {
  const { data, error } = await supabase.rpc('has_schedule_conflict', {
    p_restaurant_id: params.restaurantId,
    p_tenant_id: params.tenantId,
    p_service_type: params.serviceType,
    p_day_start: params.dayStart,
    p_day_stop: params.dayStop,
    p_time_start: params.timeStart,
    p_time_stop: params.timeStop,
    p_exclude_schedule_id: params.excludeScheduleId || null
  });

  if (error) throw error;
  return data;
}

// Usage: Check before insert
const hasConflict = await hasScheduleConflict({
  restaurantId: 950,
  tenantId: 'uuid-here',
  serviceType: 'delivery',
  dayStart: 1,
  dayStop: 5,
  timeStart: '11:00:00',
  timeStop: '22:00:00'
});

if (hasConflict) {
  alert('This schedule overlaps with an existing one');
} else {
  // Safe to insert
  await insertSchedule(...);
}
```

**REST API Wrapper:**

```typescript
// POST /api/admin/restaurants/:id/schedules/check-conflict
app.post('/api/admin/restaurants/:id/schedules/check-conflict', async (req, res) => {
  const restaurantId = parseInt(req.params.id);
  const { 
    tenant_id, 
    service_type, 
    day_start, 
    day_stop, 
    time_start, 
    time_stop,
    exclude_schedule_id 
  } = req.body;

  try {
    const hasConflict = await hasScheduleConflict({
      restaurantId,
      tenantId: tenant_id,
      serviceType: service_type,
      dayStart: day_start,
      dayStop: day_stop,
      timeStart: time_start,
      timeStop: time_stop,
      excludeScheduleId: exclude_schedule_id
    });
    
    res.json({ 
      has_conflict: hasConflict,
      can_insert: !hasConflict
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to check conflict' });
  }
});
```

---

### **4. bulk_toggle_schedules()**

**Purpose:** Enable or disable all schedules for a service type

```sql
menuca_v3.bulk_toggle_schedules(
    p_restaurant_id BIGINT,
    p_service_type service_type,
    p_enabled BOOLEAN
)
RETURNS INTEGER  -- Number of schedules updated
```

**TypeScript Integration:**

```typescript
export async function bulkToggleSchedules(
  restaurantId: number,
  serviceType: 'delivery' | 'takeout',
  enabled: boolean
): Promise<number> {
  const { data, error } = await supabase.rpc('bulk_toggle_schedules', {
    p_restaurant_id: restaurantId,
    p_service_type: serviceType,
    p_enabled: enabled
  });

  if (error) throw error;
  return data;
}

// Usage: Turn off all delivery temporarily
const updatedCount = await bulkToggleSchedules(950, 'delivery', false);
console.log(`${updatedCount} delivery schedules disabled`);
```

**REST API Wrapper:**

```typescript
// PATCH /api/admin/restaurants/:id/schedules/bulk-toggle
app.patch('/api/admin/restaurants/:id/schedules/bulk-toggle', async (req, res) => {
  const restaurantId = parseInt(req.params.id);
  const { service_type, enabled } = req.body;

  try {
    const updatedCount = await bulkToggleSchedules(
      restaurantId, 
      service_type, 
      enabled
    );
    
    res.json({ 
      message: `${updatedCount} schedules ${enabled ? 'enabled' : 'disabled'}`,
      updated_count: updatedCount
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to toggle schedules' });
  }
});
```

---

### **5. clone_schedule_to_day()**

**Purpose:** Duplicate a schedule to another day

```sql
menuca_v3.clone_schedule_to_day(
    p_schedule_id BIGINT,
    p_new_day_start SMALLINT,
    p_new_day_stop SMALLINT DEFAULT NULL
)
RETURNS BIGINT  -- New schedule ID
```

**TypeScript Integration:**

```typescript
export async function cloneScheduleToDay(
  scheduleId: number,
  newDayStart: number,
  newDayStop?: number
): Promise<number> {
  const { data, error } = await supabase.rpc('clone_schedule_to_day', {
    p_schedule_id: scheduleId,
    p_new_day_start: newDayStart,
    p_new_day_stop: newDayStop || newDayStart
  });

  if (error) throw error;
  return data;
}

// Usage: Copy Monday hours to Tuesday
const newScheduleId = await cloneScheduleToDay(123, 2);
console.log(`Cloned schedule, new ID: ${newScheduleId}`);
```

**REST API Wrapper:**

```typescript
// POST /api/admin/restaurants/:rid/schedules/:sid/clone
app.post('/api/admin/restaurants/:rid/schedules/:sid/clone', async (req, res) => {
  const scheduleId = parseInt(req.params.sid);
  const { day_start, day_stop } = req.body;

  try {
    const newId = await cloneScheduleToDay(scheduleId, day_start, day_stop);
    
    res.status(201).json({ 
      message: 'Schedule cloned successfully',
      new_schedule_id: newId
    });
  } catch (error) {
    if (error.message.includes('not found')) {
      return res.status(404).json({ error: 'Source schedule not found' });
    }
    if (error.message.includes('overlaps')) {
      return res.status(409).json({ error: 'Cloned schedule would conflict' });
    }
    res.status(500).json({ error: 'Failed to clone schedule' });
  }
});
```

---

## 🧪 **TESTING & VALIDATION**

### **Validation Tests Performed**

✅ **Test 1: Audit Trigger**
- Update schedule → `updated_at` auto-updates
- User ID from JWT → `updated_by` auto-populates

✅ **Test 2: Conflict Detection**
- `has_schedule_conflict()` correctly detects overlaps
- Same day + overlapping time = conflict

✅ **Test 3: Soft Delete**
- `soft_delete_schedule()` sets `deleted_at` and `deleted_by`
- Schedule hidden from normal queries
- Data preserved in database

✅ **Test 4: Restore**
- `restore_schedule()` clears `deleted_at` and `deleted_by`
- Schedule becomes active again
- No data loss

✅ **Test 5: Overlap Prevention**
- Insert conflicting schedule → Error thrown
- Trigger prevents database corruption
- Clear error message returned

---

## 📋 **IMPLEMENTATION CHECKLIST**

For Santiago's backend integration:

### **Admin Endpoints to Implement**
- [ ] `DELETE /api/admin/restaurants/:id/schedules/:sid` → soft_delete_schedule()
- [ ] `POST /api/admin/restaurants/:id/schedules/:sid/restore` → restore_schedule()
- [ ] `POST /api/admin/restaurants/:id/schedules/check-conflict` → has_schedule_conflict()
- [ ] `PATCH /api/admin/restaurants/:id/schedules/bulk-toggle` → bulk_toggle_schedules()
- [ ] `POST /api/admin/restaurants/:id/schedules/:sid/clone` → clone_schedule_to_day()

### **Frontend UI Enhancements**
- [ ] "Delete" button → Soft delete (show "Deleted" badge)
- [ ] "Restore" button on deleted schedules
- [ ] Conflict warning before saving schedule
- [ ] Bulk on/off toggle for delivery/takeout
- [ ] "Copy to another day" button

### **Error Handling**
- [ ] Catch schedule overlap errors (code 42883 or message contains "overlaps")
- [ ] Show friendly error: "This schedule conflicts with existing hours"
- [ ] Suggest conflict resolution (disable old schedule, adjust times)

---

## 🐛 **ERROR HANDLING GUIDE**

### **Common Errors**

**1. Schedule Overlap Error**
```typescript
try {
  await supabase.from('restaurant_schedules').insert(newSchedule);
} catch (error) {
  if (error.message.includes('overlaps')) {
    // User-friendly message
    throw new Error(
      'This schedule conflicts with existing hours. ' +
      'Please adjust the time range or disable the conflicting schedule.'
    );
  }
  throw error;
}
```

**2. Soft Delete on Already Deleted**
```typescript
const deleted = await softDeleteSchedule(123);
if (!deleted) {
  // Schedule not found or already deleted
  throw new Error('Schedule not found or already deleted');
}
```

**3. Restore on Active Schedule**
```typescript
const restored = await restoreSchedule(123);
if (!restored) {
  // Schedule not found or already active
  throw new Error('Schedule not found or already active');
}
```

---

## 🔒 **SECURITY & PERMISSIONS**

### **Function Access Control**

```sql
-- Admin functions: Authenticated users only
GRANT EXECUTE ON FUNCTION soft_delete_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION restore_schedule TO authenticated;
GRANT EXECUTE ON FUNCTION has_schedule_conflict TO authenticated;
GRANT EXECUTE ON FUNCTION bulk_toggle_schedules TO authenticated;
GRANT EXECUTE ON FUNCTION clone_schedule_to_day TO authenticated;
```

**Important:**
- These functions use `SECURITY DEFINER` (run as owner)
- RLS policies still apply to underlying tables
- Only tenant's own schedules can be modified
- JWT must contain `restaurant_id` for RLS filtering

---

## 📊 **PHASE 3 METRICS**

| Metric | Value |
|--------|-------|
| **Audit Columns Added** | 6 per table |
| **Tables Enhanced** | 4 |
| **Triggers Created** | 5 (4 audit + 1 conflict) |
| **Admin Functions** | 5 |
| **Tests Passed** | 5/5 ✅ |
| **Data Integrity** | 🟢 Enterprise-grade |

---

## 🔄 **NEXT PHASES**

- **Phase 4:** Real-time Schedule Updates (pg_notify, Supabase Realtime)
- **Phase 5:** Soft Delete UI & Recovery Dashboard
- **Phase 6:** Multi-language Support
- **Phase 7:** Comprehensive Testing & Performance Tuning

---

## 📞 **SUPPORT**

**Questions?** Refer to:
- Phase 1 docs: `PHASE_1_BACKEND_DOCUMENTATION.md`
- Phase 2 docs: `PHASE_2_BACKEND_DOCUMENTATION.md`
- Main refactoring plan: `SERVICE_SCHEDULES_V3_REFACTORING_PLAN.md`

---

**Status:** ✅ Production Ready | **Data Integrity:** 🟢 Bulletproof | **Next:** Phase 4 (Real-time Updates)



