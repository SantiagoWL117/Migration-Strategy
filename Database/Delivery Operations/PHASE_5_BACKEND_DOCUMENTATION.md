# Phase 5 Backend Documentation: Soft Delete & Audit Trails
## Delivery Operations Entity - For Backend Development

**Created:** January 17, 2025  
**Developer:** Brian (Database) → Santiago (Backend)  
**Phase:** 5 of 7 - Soft Delete, Audit Logging, and Data Recovery  
**Status:** ✅ COMPLETE - Ready for Backend Implementation

---

## 📋 **SANTIAGO'S QUICK REFERENCE**

### **Business Problem Summary**
Enterprise systems need **data protection** and **audit compliance**:
- **Accidental deletions** happen - need recovery mechanisms
- **Regulatory compliance** (GDPR, SOX) requires audit trails
- **Financial records** must be immutable with change tracking
- **Support tickets** need historical data to investigate issues
- **Legal disputes** require proof of who changed what and when

**Impact:** Without these safeguards, we risk permanent data loss, failed audits, unresolved disputes, and potential legal liability.

---

### **The Solution**
Implement **soft delete** + **comprehensive audit logging**:
1. **Soft delete** - Mark records as deleted without removing them
2. **Audit log table** - Track every change to critical tables
3. **Automatic triggers** - Log changes without manual intervention
4. **Recovery functions** - Restore deleted records with audit trail
5. **Compliance views** - Easy reporting for audits and investigations
6. **GDPR cleanup** - Permanently delete old records after retention period

This creates a **"time machine database"** where nothing is truly lost and everything is tracked.

---

### **Gained Business Logic Components**

#### **1. Soft Delete Infrastructure**
✅ **What Changed:** Records can be "deleted" without losing data  
✅ **Why:** Recovery from mistakes, regulatory compliance, historical tracking  
✅ **Backend Impact:** Use views instead of direct table queries

**How Soft Delete Works:**
```sql
-- Instead of DELETE (permanent)
DELETE FROM menuca_v3.drivers WHERE id = 123;

-- Use soft delete (recoverable)
UPDATE menuca_v3.drivers 
SET 
  deleted_at = NOW(),
  deleted_by = current_admin_id,
  driver_status = 'blocked'
WHERE id = 123;
```

**Active-Only Views (Use These!):**
- `active_drivers` - Only non-deleted drivers
- `active_delivery_zones` - Only non-deleted zones  
- `active_deliveries` - Only non-deleted deliveries

**Backend Best Practice:**
```typescript
// ❌ BAD - Returns deleted records
const { data } = await supabase
  .from('drivers')
  .select('*');

// ✅ GOOD - Only returns active records
const { data } = await supabase
  .from('active_drivers')
  .select('*');
```

---

#### **2. Soft Delete Functions**
✅ **Function:** `soft_delete_driver(driver_id, reason)`  
✅ **Function:** `restore_driver(driver_id, reason)`  
✅ **Function:** `soft_delete_delivery_zone(zone_id, reason)`

**Safety Rules Enforced:**
- ✅ Cannot delete driver with active deliveries (must complete/reassign first)
- ✅ Only super admins can delete/restore drivers
- ✅ Restaurant admins can only delete their own zones
- ✅ All deletions require a reason (audit trail)
- ✅ Deleted drivers are automatically set to 'blocked' status

**Backend Implementation:**
```typescript
// Delete driver API endpoint
// POST /api/admin/drivers/:id/delete
export async function deleteDriver(req, res) {
  const { driverId } = req.params;
  const { reason } = req.body;

  // Validate reason is provided
  if (!reason || reason.trim().length < 10) {
    return res.status(400).json({
      error: 'Deletion reason required (minimum 10 characters)'
    });
  }

  // Call soft delete function
  const { data, error } = await supabase.rpc('soft_delete_driver', {
    p_driver_id: parseInt(driverId),
    p_reason: reason
  });

  if (error) {
    // Handle business rule violations
    if (error.message.includes('active deliveries')) {
      return res.status(409).json({
        error: 'Cannot delete driver with active deliveries',
        message: error.message
      });
    }

    if (error.message.includes('Only super admins')) {
      return res.status(403).json({
        error: 'Permission denied',
        message: 'Only super admins can delete drivers'
      });
    }

    return res.status(500).json({ error: error.message });
  }

  res.json({
    success: true,
    ...data,
    message: 'Driver soft-deleted successfully. Can be restored within 90 days.'
  });
}

// Restore driver API endpoint
// POST /api/admin/drivers/:id/restore
export async function restoreDriver(req, res) {
  const { driverId } = req.params;
  const { reason } = req.body;

  const { data, error } = await supabase.rpc('restore_driver', {
    p_driver_id: parseInt(driverId),
    p_reason: reason || 'Restoration requested'
  });

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json({
    success: true,
    ...data,
    message: 'Driver restored. Status set to inactive - requires re-activation.'
  });
}
```

---

#### **3. Comprehensive Audit Log**
✅ **Table:** `audit_log` - Tracks all changes to critical tables  
✅ **Automatic:** Triggers fire on every INSERT/UPDATE/DELETE  
✅ **Fields:** Who, What, When, Why, Before/After values

**Audit Log Structure:**
```typescript
interface AuditLogEntry {
  id: number;
  table_name: string;          // 'drivers', 'deliveries', 'driver_earnings'
  record_id: number;            // ID of the changed record
  action: string;               // 'insert', 'update', 'delete', 'soft_delete', 'restore'
  old_values: any;              // Previous values (JSON)
  new_values: any;              // New values (JSON)
  changed_by: number;           // Admin user ID
  changed_at: Date;             // Timestamp
  change_reason: string;        // Why the change was made
  ip_address: string;           // Optional: IP of requester
  user_agent: string;           // Optional: Browser/app info
}
```

**What Gets Audited Automatically:**
- ✅ **Drivers** - ALL changes (registration, status, deletions)
- ✅ **Deliveries** - Status changes, driver assignments, fee modifications
- ✅ **Driver Earnings** - ALL changes (CRITICAL financial audit)

**Backend Usage - Add IP/User Agent:**
```typescript
// middleware/auditContext.ts
export async function setAuditContext(req, res, next) {
  // Set PostgreSQL session variables for audit logging
  const ipAddress = req.ip || req.connection.remoteAddress;
  const userAgent = req.get('User-Agent');

  await supabase.rpc('set_audit_context', {
    p_ip_address: ipAddress,
    p_user_agent: userAgent
  });

  next();
}

// Apply to all routes
app.use(setAuditContext);
```

---

#### **4. Audit Reporting Views**
✅ **View:** `recent_audit_activity` - Last 7 days of all changes  
✅ **View:** `driver_audit_history` - Complete history for all drivers  
✅ **View:** `earnings_audit_trail` - Financial audit (CRITICAL for compliance)

**Admin Dashboard - Audit Log Viewer:**
```typescript
// GET /api/admin/audit/recent
export async function getRecentAudit() {
  const { data, error } = await supabase
    .from('recent_audit_activity')
    .select('*')
    .limit(100);

  return res.json(data);
}

// GET /api/admin/audit/driver/:id
export async function getDriverAuditHistory(req, res) {
  const { driverId } = req.params;

  const { data, error } = await supabase.rpc(
    'get_record_audit_history',
    {
      p_table_name: 'drivers',
      p_record_id: parseInt(driverId),
      p_limit: 100
    }
  );

  res.json({
    driver_id: driverId,
    audit_history: data,
    total_changes: data.length
  });
}

// GET /api/admin/audit/earnings
export async function getEarningsAudit() {
  const { data, error } = await supabase
    .from('earnings_audit_trail')
    .select('*')
    .order('changed_at', { ascending: false })
    .limit(500); // Financial records - keep more history

  return res.json(data);
}
```

---

#### **5. Financial Audit Compliance**
✅ **Critical:** Driver earnings table has **FULL AUDIT** - every change logged

**Why This Matters:**
- SOX compliance (Sarbanes-Oxley for financial records)
- Tax audits (prove driver payments)
- Dispute resolution (driver claims incorrect payment)
- Fraud detection (unauthorized earnings modifications)

**What Gets Logged:**
```json
{
  "audit_id": 12345,
  "table_name": "driver_earnings",
  "record_id": 789,
  "action": "update",
  "old_values": {
    "total_earning": "25.00",
    "payment_status": "pending"
  },
  "new_values": {
    "total_earning": "30.00",
    "payment_status": "pending"
  },
  "changed_by": 42,
  "changed_at": "2025-01-17T10:30:00Z",
  "change_reason": "Financial record modification - requires approval"
}
```

**Backend Enforcement:**
```typescript
// Financial records should NEVER be modified without audit trail
// Add extra validation for earnings changes
export async function updateDriverEarnings(req, res) {
  const { earningId } = req.params;
  const { new_amount, reason } = req.body;

  // Require super admin
  const isSuperAdmin = await checkIsSuperAdmin(req.user.id);
  if (!isSuperAdmin) {
    return res.status(403).json({
      error: 'Only super admins can modify earnings records'
    });
  }

  // Require detailed reason
  if (!reason || reason.length < 50) {
    return res.status(400).json({
      error: 'Detailed reason required for financial modifications (min 50 characters)'
    });
  }

  // Make the change (audit logged automatically)
  const { data, error } = await supabase
    .from('driver_earnings')
    .update({ total_earning: new_amount })
    .eq('id', earningId)
    .select()
    .single();

  // Verify audit log entry was created
  const { data: auditEntry } = await supabase
    .from('audit_log')
    .select('*')
    .eq('table_name', 'driver_earnings')
    .eq('record_id', earningId)
    .order('changed_at', { ascending: false })
    .limit(1)
    .single();

  res.json({
    success: true,
    earning: data,
    audit_entry: auditEntry,
    message: 'Earnings updated - change logged for compliance'
  });
}
```

---

#### **6. GDPR Compliance - Data Retention**
✅ **Function:** `purge_old_deleted_records(days_old)`  
✅ **Default:** 90 days retention for soft-deleted records  
✅ **Schedule:** Run monthly via cron

**GDPR Requirements:**
- ✅ Soft-deleted records must be permanently deleted after retention period
- ✅ GPS location data deleted after 30 days (Phase 4)
- ✅ Users can request full account deletion ("right to be forgotten")

**Automated Cleanup:**
```typescript
// Schedule monthly cleanup
// Run via cron job or scheduled function
export async function scheduledDataPurge() {
  // Run on 1st of every month at 2 AM
  const { data, error } = await supabase.rpc(
    'purge_old_deleted_records',
    { p_days_old: 90 }
  );

  if (error) {
    console.error('Data purge failed:', error);
    // Alert admins
    await sendAdminAlert({
      title: 'GDPR Data Purge Failed',
      error: error.message
    });
    return;
  }

  // Log results
  console.log('GDPR data purge completed:', data);
  
  // Notify admins of successful purge
  await sendAdminNotification({
    title: 'Monthly Data Purge Completed',
    deleted_drivers: data.deleted_drivers,
    deleted_zones: data.deleted_zones,
    cutoff_date: data.cutoff_date
  });
}
```

**Manual GDPR Deletion Request:**
```typescript
// POST /api/admin/gdpr/delete-user-data
export async function deleteUserDataGDPR(req, res) {
  const { driverId, confirm } = req.body;

  if (confirm !== 'PERMANENTLY_DELETE') {
    return res.status(400).json({
      error: 'Must confirm permanent deletion'
    });
  }

  // 1. Soft delete driver first
  await supabase.rpc('soft_delete_driver', {
    p_driver_id: driverId,
    p_reason: 'GDPR right to be forgotten request'
  });

  // 2. Anonymize historical deliveries (can't delete - financial records)
  await supabase
    .from('deliveries')
    .update({
      driver_id: null, // Unlink from driver
      delivery_notes: 'Driver data removed - GDPR request'
    })
    .eq('driver_id', driverId);

  // 3. Delete all location history immediately
  await supabase
    .from('driver_locations')
    .delete()
    .eq('driver_id', driverId);

  // 4. Anonymize earnings records
  await supabase
    .from('driver_earnings')
    .update({
      // Keep financial totals (legal requirement)
      // But remove identifiable info
      driver_id: null
    })
    .eq('driver_id', driverId);

  res.json({
    success: true,
    message: 'Driver data deleted/anonymized per GDPR compliance',
    note: 'Financial records retained (anonymized) for legal compliance'
  });
}
```

---

### **Backend Functionality Required for This Phase**

#### **Priority 1: Soft Delete UI** ✅ CRITICAL
**Why:** Admins need safe way to delete records with recovery option

**Admin UI Components:**
1. **Delete confirmation modal** with reason field
2. **"Deleted Items" view** showing soft-deleted records
3. **Restore button** on deleted items
4. **Permanent delete warning** (90-day retention)

**Implementation:**
```typescript
// components/DeleteDriverModal.tsx
export function DeleteDriverModal({ driver, onClose, onDeleted }) {
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(false);

  const handleDelete = async () => {
    if (reason.length < 10) {
      alert('Please provide a detailed reason (min 10 characters)');
      return;
    }

    setLoading(true);
    const response = await fetch(`/api/admin/drivers/${driver.id}/delete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ reason })
    });

    const data = await response.json();
    
    if (response.ok) {
      onDeleted(data);
      onClose();
    } else {
      alert(`Error: ${data.error}\n${data.message}`);
    }
    setLoading(false);
  };

  return (
    <Modal>
      <h2>Delete Driver: {driver.name}</h2>
      <Warning>
        This will soft-delete the driver. They can be restored within 90 days.
        After 90 days, the record will be permanently deleted.
      </Warning>
      
      <TextArea
        label="Reason for deletion *"
        value={reason}
        onChange={(e) => setReason(e.target.value)}
        placeholder="Explain why this driver is being deleted..."
        required
        minLength={10}
      />

      <ButtonGroup>
        <Button onClick={onClose}>Cancel</Button>
        <Button 
          onClick={handleDelete} 
          variant="danger"
          loading={loading}
          disabled={reason.length < 10}
        >
          Soft Delete Driver
        </Button>
      </ButtonGroup>
    </Modal>
  );
}
```

---

#### **Priority 2: Audit Log Viewer** ✅ IMPORTANT
**Why:** Admins/support need to investigate issues and track changes

**Features Needed:**
1. **Timeline view** of all changes to a record
2. **Filter by:** table, action, date range, admin
3. **Diff view** showing before/after values
4. **Export** for compliance reports

**Implementation:**
```typescript
// pages/admin/audit-log.tsx
export function AuditLogPage() {
  const [auditLogs, setAuditLogs] = useState([]);
  const [filters, setFilters] = useState({
    table: 'all',
    action: 'all',
    dateFrom: null,
    dateTo: null
  });

  useEffect(() => {
    fetchAuditLogs();
  }, [filters]);

  const fetchAuditLogs = async () => {
    const { data } = await supabase
      .from('recent_audit_activity')
      .select('*')
      .order('changed_at', { ascending: false })
      .limit(100);

    setAuditLogs(data);
  };

  return (
    <div className="audit-log-page">
      <h1>Audit Log</h1>
      
      <FilterBar>
        <Select 
          label="Table"
          value={filters.table}
          onChange={(v) => setFilters({...filters, table: v})}
        >
          <option value="all">All Tables</option>
          <option value="drivers">Drivers</option>
          <option value="deliveries">Deliveries</option>
          <option value="driver_earnings">Driver Earnings</option>
        </Select>

        <Select 
          label="Action"
          value={filters.action}
          onChange={(v) => setFilters({...filters, action: v})}
        >
          <option value="all">All Actions</option>
          <option value="insert">Inserts</option>
          <option value="update">Updates</option>
          <option value="delete">Deletes</option>
          <option value="soft_delete">Soft Deletes</option>
        </Select>

        <DateRangePicker 
          from={filters.dateFrom}
          to={filters.dateTo}
          onChange={(from, to) => setFilters({...filters, dateFrom: from, dateTo: to})}
        />
      </FilterBar>

      <AuditLogTable logs={auditLogs} />
    </div>
  );
}

function AuditLogTable({ logs }) {
  return (
    <Table>
      <thead>
        <tr>
          <th>Time</th>
          <th>Table</th>
          <th>Record ID</th>
          <th>Action</th>
          <th>Changed By</th>
          <th>Reason</th>
          <th>Changes</th>
        </tr>
      </thead>
      <tbody>
        {logs.map(log => (
          <tr key={log.id}>
            <td>{formatDate(log.changed_at)}</td>
            <td><Badge>{log.table_name}</Badge></td>
            <td>
              <Link to={`/${log.table_name}/${log.record_id}`}>
                #{log.record_id}
              </Link>
            </td>
            <td><Badge variant={getActionColor(log.action)}>{log.action}</Badge></td>
            <td>{log.changed_by_name}</td>
            <td>{log.change_reason}</td>
            <td>
              <DiffViewer 
                old={log.old_values}
                new={log.new_values}
              />
            </td>
          </tr>
        ))}
      </tbody>
    </Table>
  );
}
```

---

#### **Priority 3: Driver Audit Timeline** ⚠️ IMPORTANT
**Why:** Support needs to see complete driver history for disputes

**Implementation:**
```typescript
// components/DriverAuditTimeline.tsx
export function DriverAuditTimeline({ driverId }) {
  const [history, setHistory] = useState([]);

  useEffect(() => {
    fetchHistory();
  }, [driverId]);

  const fetchHistory = async () => {
    const { data } = await supabase.rpc('get_record_audit_history', {
      p_table_name: 'drivers',
      p_record_id: driverId,
      p_limit: 100
    });
    setHistory(data);
  };

  return (
    <Timeline>
      {history.map(entry => (
        <TimelineItem key={entry.audit_id}>
          <TimelineDot variant={getActionVariant(entry.action)} />
          <TimelineContent>
            <TimelineTime>{formatDate(entry.changed_at)}</TimelineTime>
            <TimelineTitle>{getActionLabel(entry.action)}</TimelineTitle>
            <TimelineDescription>
              {entry.changed_by_name} - {entry.change_reason}
            </TimelineDescription>
            {entry.old_values && entry.new_values && (
              <ChangesSummary 
                old={entry.old_values}
                new={entry.new_values}
              />
            )}
          </TimelineContent>
        </TimelineItem>
      ))}
    </Timeline>
  );
}

function ChangesSummary({ old, new: newVals }) {
  const changes = Object.keys(newVals).filter(
    key => old[key] !== newVals[key]
  );

  return (
    <div className="changes-summary">
      {changes.map(key => (
        <div key={key} className="change-item">
          <strong>{key}:</strong>
          <span className="old-value">{old[key]}</span>
          <span className="arrow">→</span>
          <span className="new-value">{newVals[key]}</span>
        </div>
      ))}
    </div>
  );
}
```

---

### **Schema Modifications Summary**

#### **New Database Objects Created:**

**Audit Infrastructure:**
- ✅ `audit_log` table - Comprehensive change tracking
- ✅ `audit_drivers_changes()` trigger function
- ✅ `audit_deliveries_changes()` trigger function
- ✅ `audit_earnings_changes()` trigger function (CRITICAL)

**Soft Delete Views:**
- ✅ `active_drivers` - Non-deleted drivers only
- ✅ `active_delivery_zones` - Non-deleted zones only
- ✅ `active_deliveries` - Non-deleted deliveries only

**Audit Reporting Views:**
- ✅ `recent_audit_activity` - Last 7 days of changes
- ✅ `driver_audit_history` - Driver change history
- ✅ `earnings_audit_trail` - Financial audit log (CRITICAL)

**Management Functions:**
- ✅ `soft_delete_driver()` - Safe driver deletion
- ✅ `restore_driver()` - Undo soft deletion
- ✅ `soft_delete_delivery_zone()` - Safe zone deletion
- ✅ `purge_old_deleted_records()` - GDPR compliance cleanup
- ✅ `get_record_audit_history()` - Audit trail retrieval

---

## 🎯 **IMPLEMENTATION PRIORITY**

### **This Week (Critical):**
1. ✅ Create delete confirmation modals with reason fields
2. ✅ Implement "Deleted Items" admin view with restore buttons
3. ✅ Build audit log viewer page
4. ✅ Add audit timeline to driver/delivery detail pages

### **Next Week (Important):**
1. ⚠️ Set up monthly GDPR cleanup cron job
2. ⚠️ Create compliance reports (export audit logs)
3. ⚠️ Build financial audit dashboard
4. ⚠️ Add support ticket integration with audit logs

### **Future (Nice to Have):**
1. 💡 Rollback functionality (restore old versions)
2. 💡 Automated anomaly detection (suspicious changes)
3. 💡 Real-time audit log streaming
4. 💡 Audit log retention policy (archive old logs)

---

## 🚀 **NEXT STEPS**

1. ✅ **Phase 5 Complete** - Audit infrastructure deployed
2. ⏳ **Santiago: Build Audit UI** - Follow this guide
3. ⏳ **Phase 6: Multi-Language** - Internationalization
4. ⏳ **Phase 7: Testing** - Comprehensive validation

---

**Status:** ✅ Audit fortress complete, nothing gets lost, everything tracked!

