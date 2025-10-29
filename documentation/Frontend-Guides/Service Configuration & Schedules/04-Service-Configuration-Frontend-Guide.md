# Service Configuration & Schedules - Frontend Developer Guide

**Status:** ✅ BACKEND COMPLETE
**Last Updated:** 2025-10-29
**Testing:** 15/15 Tests Passed (100%)
**Platform:** Supabase PostgreSQL
**Project:** nthpbtdjhhnwfxqsxbvy.supabase.co

---

## Purpose

Manage restaurant operating hours, service availability, special schedules (holidays, vacations), and real-time open/closed status. Supports delivery and takeout services with timezone-aware scheduling.

---

## Quick Stats

- **SQL Functions:** 11
- **Edge Functions:** 0 (all logic in SQL)
- **Tables:** 4 (schedules, special_schedules, service_configs, time_periods)
- **Languages:** EN, ES, FR
- **Performance:** 4-16ms (all queries)

---

## Setup

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co',
  'YOUR_ANON_KEY'
);
```

---

## Core Operations

### 1. Real-Time Status Checks (2 Functions)

**Check if Restaurant is Open Now:**
```typescript
const { data: isOpen, error } = await supabase.rpc('is_restaurant_open_now', {
  p_restaurant_id: 379,
  p_service_type: 'delivery', // or 'takeout'
  p_check_time: new Date().toISOString()
});
// Returns: boolean (true = open, false = closed)
// Performance: 4.3ms
```

**Get Current Service Configuration:**
```typescript
const { data: config, error } = await supabase.rpc('get_current_service_config', {
  p_restaurant_id: 379,
  p_service_type: 'delivery'
});
// Returns: { is_enabled, has_special_schedule, is_currently_open, next_change_at }
```

---

### 2. Schedule Display (2 Functions)

**Get Restaurant Hours (Customer View):**
```typescript
const { data: hours, error } = await supabase.rpc('get_restaurant_hours', {
  p_restaurant_id: 379,
  p_service_type: 'delivery',
  p_language_code: 'en' // 'en', 'es', or 'fr'
});
// Returns: Array of { day_name, opens_at, closes_at, is_open, display_text }
// Example: [{ day_name: 'Monday', opens_at: '11:30:00', closes_at: '21:00:00', is_open: true, display_text: 'Monday: 11:30 AM - 9:00 PM' }]
```

**Get Multi-Language Hours:**
```typescript
const { data: hoursI18n, error } = await supabase.rpc('get_restaurant_hours_i18n', {
  p_restaurant_id: 379,
  p_language_code: 'es'
});
// Returns: [{ day_name: 'Lunes', opens_at: '11:30:00', closes_at: '21:00:00', display_text: 'Lunes: 11:30 - 21:00' }]
```

---

### 3. Special Schedules (2 Functions)

**Get Active Special Schedules (Holidays, Vacations):**
```typescript
const { data: specials, error } = await supabase.rpc('get_active_special_schedules', {
  p_restaurant_id: 379,
  p_service_type: 'delivery'
});
// Returns: Array of { schedule_name, start_date, end_date, is_closed, custom_hours }
```

**Get Upcoming Schedule Changes:**
```typescript
const { data: upcoming, error } = await supabase.rpc('get_upcoming_schedule_changes', {
  p_restaurant_id: 379,
  p_hours_ahead: 168 // Next 7 days
});
// Returns: [{ change_type, change_time, service_type, schedule_name, new_status }]
```

---

### 4. Admin Management (5 Functions)

**Bulk Toggle Schedules (Enable/Disable Service):**
```typescript
const { data: affectedCount, error } = await supabase.rpc('bulk_toggle_schedules', {
  p_restaurant_id: 379,
  p_service_type: 'delivery',
  p_is_active: false // Disable all delivery schedules
});
// Returns: integer (number of schedules toggled)
```

**Copy Schedules Between Restaurants:**
```typescript
const { data: copiedCount, error } = await supabase.rpc('copy_schedules_between_restaurants', {
  p_source_restaurant_id: 379,
  p_target_restaurant_id: 950,
  p_service_type: 'delivery',
  p_overwrite_existing: true
});
// Returns: integer (number of schedules copied)
```

**Detect Schedule Conflicts:**
```typescript
const { data: hasConflict, error } = await supabase.rpc('has_schedule_conflict', {
  p_restaurant_id: 379,
  p_tenant_id: '325c1fc0-f3ac-4e52-b454-f900c96f3a2d',
  p_service_type: 'delivery',
  p_day_of_week: 1, // Monday (0=Sunday, 6=Saturday)
  p_effective_day: 1,
  p_opens_at: '11:30:00',
  p_closes_at: '21:00:00',
  p_exclude_schedule_id: null
});
// Returns: boolean (true = conflict detected)
```

**Validate Schedule Data:**
```typescript
const { data: isValid, error } = await supabase.rpc('validate_schedule_times', {
  p_opens_at: '09:00:00',
  p_closes_at: '22:00:00',
  p_allow_overnight: true
});
// Returns: boolean (true = valid)
```

**Get Day Name (Localization Helper):**
```typescript
const { data: dayName, error } = await supabase.rpc('get_day_name', {
  p_day_number: 1, // 0=Sunday, 1=Monday, ..., 6=Saturday
  p_language_code: 'es'
});
// Returns: string ('Lunes')
// Supported: 'en', 'es', 'fr'
```

---

## Real-Time Updates

Subscribe to schedule changes using Supabase Realtime:

```typescript
// Listen to schedule updates
const scheduleChannel = supabase
  .channel('schedule_changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'menuca_v3',
      table: 'restaurant_schedules',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      console.log('Schedule changed:', payload);
      // Refresh restaurant hours
    }
  )
  .subscribe();

// Listen to service config updates
const configChannel = supabase
  .channel('config_changes')
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'menuca_v3',
      table: 'restaurant_service_configs',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      console.log('Service config changed:', payload);
      // Re-check if restaurant is open
    }
  )
  .subscribe();
```

---

## Complete Code Examples

### Customer View: Restaurant Page

```typescript
import { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';

interface RestaurantHours {
  day_name: string;
  opens_at: string;
  closes_at: string;
  is_open: boolean;
  display_text: string;
}

export function RestaurantHours({ restaurantId, serviceType = 'delivery' }) {
  const [isOpen, setIsOpen] = useState<boolean | null>(null);
  const [hours, setHours] = useState<RestaurantHours[]>([]);
  const [loading, setLoading] = useState(true);

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  useEffect(() => {
    async function fetchSchedule() {
      // Check if currently open
      const { data: openStatus } = await supabase.rpc('is_restaurant_open_now', {
        p_restaurant_id: restaurantId,
        p_service_type: serviceType,
        p_check_time: new Date().toISOString()
      });

      setIsOpen(openStatus);

      // Get weekly hours
      const { data: weeklyHours } = await supabase.rpc('get_restaurant_hours_i18n', {
        p_restaurant_id: restaurantId,
        p_language_code: navigator.language.split('-')[0] || 'en'
      });

      setHours(weeklyHours || []);
      setLoading(false);
    }

    fetchSchedule();

    // Subscribe to real-time changes
    const channel = supabase
      .channel('hours_updates')
      .on(
        'postgres_changes',
        { event: '*', schema: 'menuca_v3', table: 'restaurant_schedules', filter: `restaurant_id=eq.${restaurantId}` },
        () => fetchSchedule()
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [restaurantId, serviceType]);

  if (loading) return <div>Loading hours...</div>;

  return (
    <div>
      <div className={`status ${isOpen ? 'open' : 'closed'}`}>
        {isOpen ? '🟢 Open Now' : '🔴 Closed'}
      </div>
      <div className="hours-list">
        {hours.map((day) => (
          <div key={day.day_name} className="day-row">
            <span className="day">{day.day_name}</span>
            <span className="time">{day.display_text}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

### Admin View: Schedule Manager

```typescript
import { useState } from 'react';
import { createClient } from '@supabase/supabase-js';

export function ScheduleManager({ restaurantId }) {
  const [serviceType, setServiceType] = useState<'delivery' | 'takeout'>('delivery');
  const [isEnabled, setIsEnabled] = useState(true);

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  async function toggleService() {
    const newStatus = !isEnabled;

    const { data: affectedCount, error } = await supabase.rpc('bulk_toggle_schedules', {
      p_restaurant_id: restaurantId,
      p_service_type: serviceType,
      p_is_active: newStatus
    });

    if (error) {
      console.error('Failed to toggle service:', error);
      return;
    }

    setIsEnabled(newStatus);
    console.log(`Toggled ${affectedCount} schedules`);
  }

  async function copySchedules(targetRestaurantId: number) {
    const { data: copiedCount, error } = await supabase.rpc('copy_schedules_between_restaurants', {
      p_source_restaurant_id: restaurantId,
      p_target_restaurant_id: targetRestaurantId,
      p_service_type: serviceType,
      p_overwrite_existing: true
    });

    if (error) {
      console.error('Failed to copy schedules:', error);
      return;
    }

    alert(`Copied ${copiedCount} schedules successfully`);
  }

  async function checkConflicts(scheduleData) {
    const { data: hasConflict, error } = await supabase.rpc('has_schedule_conflict', {
      p_restaurant_id: restaurantId,
      p_tenant_id: scheduleData.tenant_id,
      p_service_type: serviceType,
      p_day_of_week: scheduleData.day_of_week,
      p_effective_day: scheduleData.effective_day,
      p_opens_at: scheduleData.opens_at,
      p_closes_at: scheduleData.closes_at,
      p_exclude_schedule_id: scheduleData.id || null
    });

    if (hasConflict) {
      alert('Schedule conflict detected! Please adjust times.');
      return false;
    }

    return true;
  }

  return (
    <div className="schedule-manager">
      <h2>Schedule Management</h2>

      <select value={serviceType} onChange={(e) => setServiceType(e.target.value as any)}>
        <option value="delivery">Delivery</option>
        <option value="takeout">Takeout</option>
      </select>

      <button onClick={toggleService}>
        {isEnabled ? 'Disable Service' : 'Enable Service'}
      </button>

      <button onClick={() => copySchedules(950)}>
        Copy to Another Location
      </button>
    </div>
  );
}
```

---

## Database Tables

### restaurant_schedules
| Column | Type | Description |
|--------|------|-------------|
| id | bigint | Primary key |
| tenant_id | uuid | Multi-tenant isolation |
| restaurant_id | bigint | FK to restaurants |
| service_type | enum | 'delivery' or 'takeout' |
| day_of_week | smallint | 0=Sunday, 6=Saturday |
| opens_at | time | Opening time |
| closes_at | time | Closing time |
| is_active | boolean | Enable/disable |

### restaurant_special_schedules
| Column | Type | Description |
|--------|------|-------------|
| id | bigint | Primary key |
| restaurant_id | bigint | FK to restaurants |
| service_type | enum | Service affected |
| schedule_name | varchar | Holiday/vacation name |
| start_date | date | Start date |
| end_date | date | End date |
| is_closed | boolean | Fully closed? |
| custom_opens_at | time | Custom hours (optional) |

### restaurant_service_configs
| Column | Type | Description |
|--------|------|-------------|
| id | bigint | Primary key |
| restaurant_id | bigint | FK to restaurants |
| service_type | enum | Service type |
| is_enabled | boolean | Service available? |
| allow_scheduling | boolean | Accept future orders? |
| default_prep_time_minutes | integer | Prep time estimate |

### restaurant_time_periods
Reference table for time period definitions (lunch, dinner, etc.)

---

## Authentication & Security

**Authentication:** JWT via Supabase Auth (`auth.uid()`)

**RLS Policies:**
- **Public Read:** Authenticated users can view schedules for active restaurants
- **Tenant Isolation:** All write operations enforce `tenant_id` matching JWT claim
- **Admin Only:** Schedule management requires admin role
- **Service-Level Access:** Operators can only modify schedules for their assigned restaurants

**Multi-Tenant Security:**
```typescript
// RLS automatically enforces tenant isolation
// JWT must include: { tenant_id: 'uuid', role: 'admin' }

// Example: This will only affect schedules owned by JWT's tenant_id
await supabase.rpc('bulk_toggle_schedules', {
  p_restaurant_id: 379,
  p_service_type: 'delivery',
  p_is_active: false
});
```

---

## Performance

All queries tested and optimized:

| Operation | Avg Time | Target | Status |
|-----------|----------|--------|--------|
| `is_restaurant_open_now` | 4.3ms | <50ms | ✅ |
| `get_restaurant_hours` | 6.8ms | <50ms | ✅ |
| `get_current_service_config` | 5.2ms | <50ms | ✅ |
| `bulk_toggle_schedules` | 12.1ms | <50ms | ✅ |
| `copy_schedules_between_restaurants` | 15.7ms | <50ms | ✅ |

**Optimization Details:**
- All queries use index scans (no seq scans)
- 32 indexes on schedules, service configs, special schedules
- GiST indexes for date range queries
- Composite indexes for (restaurant_id, service_type, day_of_week)

---

## Common Errors

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `23503` | Foreign key violation | Verify restaurant_id exists |
| `23505` | Duplicate schedule | Check for existing schedule on same day/time |
| `42501` | Insufficient permissions | Verify JWT has admin role and correct tenant_id |
| `22007` | Invalid time format | Use 'HH:MM:SS' format (e.g., '09:00:00') |
| `P0001` | Business logic error | Check error message for specific validation failure |

**Common Issues:**

**Conflict Detection:**
```typescript
// Always validate before creating schedules
const { data: isValid } = await supabase.rpc('validate_schedule_times', {
  p_opens_at: '09:00:00',
  p_closes_at: '22:00:00',
  p_allow_overnight: true
});

if (!isValid) {
  alert('Invalid schedule times. Closes_at must be after opens_at.');
}
```

**Timezone Handling:**
```typescript
// All times are stored in restaurant's local timezone
// Use restaurant.timezone from restaurant_locations table
const checkTime = new Date().toLocaleString('en-US', {
  timeZone: restaurant.timezone
});
```

---

## Testing Checklist

**Completed:** 15/15 Tests (100%)

✅ **Security (3/3):**
- Tenant isolation verified (cannot access other tenant's schedules)
- Admin-only operations enforced
- Public read access works for active restaurants

✅ **Functionality (5/5):**
- Real-time status check: 4.3ms response
- Weekly hours retrieval with formatted display
- Special schedules support holidays/vacations
- Bulk toggle: 6 schedules toggled successfully
- Conflict detection: Correctly identifies overlaps

✅ **Multi-Language (2/2):**
- English, Spanish, French day names verified
- Display text formatting respects locale

✅ **Performance (2/2):**
- All queries < 50ms target (4-16ms actual)
- Index usage verified via EXPLAIN ANALYZE

✅ **Audit Trail (3/3):**
- `updated_at` triggers fire on all changes
- Soft delete support (deleted_at, deleted_by)
- Real-time notifications via pg_notify

---

## Best Practices

1. **Always Check Conflicts:** Use `has_schedule_conflict()` before creating/updating schedules
2. **Validate Times:** Use `validate_schedule_times()` to ensure logical hours
3. **Cache Status:** Cache `is_restaurant_open_now` for 5-10 minutes to reduce DB load
4. **Real-Time Updates:** Subscribe to schedule changes for live status updates
5. **Handle Timezones:** Store all times in restaurant's local timezone, convert on display
6. **Special Schedules:** Check `get_active_special_schedules()` before showing regular hours
7. **Multi-Language:** Use `get_restaurant_hours_i18n()` for localized day names
8. **Performance:** All functions are optimized (<20ms), safe to call frequently

---

**Last Updated:** 2025-10-29
**Backend Status:** ✅ COMPLETE (All 11 functions deployed and tested)
**Testing:** 15/15 Passed (Security, Functionality, Multi-language, Performance, Audit Trail)
