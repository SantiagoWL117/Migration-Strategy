# 🚀 Delivery Entity Cleanup - Quick Start Guide

**Target:** menuca_v3 Database  
**Goal:** Consolidate 6 tables → 3 tables, eliminate duplication  
**Timeline:** 3 weeks  
**Impact:** ~50% reduction in complexity

---

## ⚡ TL;DR

```bash
# Week 1: Consolidate data
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase1_data_consolidation.sql

# Week 2: Update schema
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase2_schema_updates.sql

# Week 3: Archive & monitor
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase3_archive_deprecated.sql

# After 30 days: Drop archives (uncomment final section in phase3 script)
```

---

## 📋 Pre-Flight Checklist

### Before Starting

- [ ] **Backup database** - Full backup of menuca_v3
- [ ] **Read full plan** - Review `DELIVERY_ENTITY_CLEANUP_PLAN.md`
- [ ] **Check dependencies** - No active dev work on delivery features
- [ ] **Notify team** - Schedule maintenance window
- [ ] **Test environment** - Run on staging first

### Required Access

- [ ] Database admin privileges
- [ ] Ability to run ALTER TABLE statements
- [ ] Ability to create/drop schemas
- [ ] Access to monitoring tools

---

## 🎯 The Problem

Your delivery system currently has:

| Issue | Impact |
|-------|--------|
| **3 overlapping delivery systems** | Confusion, bugs, inconsistent data |
| **45+ duplicate data points** | Data conflicts, hard to maintain |
| **3 unused/legacy tables** | Wasted storage, developer confusion |
| **Configuration conflicts** | Method='radius' but no radius set |
| **Mixed responsibilities** | Delivery + takeout + language settings in one table |

---

## ✅ The Solution

Consolidate to **3 core tables** with clear responsibilities:

```
restaurants
    ↓
┌─────────────────────────────────────────┐
│  restaurant_delivery_config             │  High-level delivery settings
│  - delivery_method (zones | disabled)   │  - Partner integrations
│  - active_partners (JSONB)              │  - Temporary suspension
│  - disable_delivery_until               │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  restaurant_delivery_zones              │  PostGIS zones (PRIMARY)
│  - zone_geometry (PostGIS Polygon)      │  - Per-zone pricing
│  - delivery_fee_cents                   │  - Per-zone minimums
│  - minimum_order_cents                  │  - Spatial queries
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  restaurant_service_settings            │  Service-level settings
│  - has_delivery_enabled                 │  - Takeout settings
│  - delivery_time_minutes                │  - Preorder settings
│  - takeout_enabled                      │  - Language settings
└─────────────────────────────────────────┘
```

---

## 🔄 Migration Phases

### **Phase 1: Data Consolidation** (Week 1)

**What it does:**
- Migrates 16 polygon areas → `restaurant_delivery_zones`
- Migrates 43 fee tiers → `restaurant_delivery_zones`
- Consolidates 15 delivery companies → JSONB in `restaurant_delivery_config`

**Run:**
```sql
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase1_data_consolidation.sql
```

**Validation:**
```sql
-- Should show all records migrated
SELECT * FROM v_delivery_migration_comparison;

-- Should show 0 failed migrations
SELECT migration_status, COUNT(*) 
FROM v_delivery_migration_comparison 
GROUP BY migration_status;
```

**Expected Output:**
```
✅ Legacy Areas Migrated: 16 of 16
✅ Fee Tiers Migrated: 43 of 43
✅ Companies Migrated: 15 restaurants
✅ New Zones Created: 59
```

---

### **Phase 2: Schema Updates** (Week 2)

**What it does:**
- Creates new `restaurant_service_settings` table
- Removes 13 duplicate/deprecated columns from `restaurant_delivery_config`
- Simplifies `delivery_method` enum to 2 values
- Creates helper functions for distance/minimum calculations

**Run:**
```sql
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase2_schema_updates.sql
```

**Validation:**
```sql
-- Should match old table count
SELECT 
    (SELECT COUNT(*) FROM restaurant_service_settings) AS new_count,
    (SELECT COUNT(*) FROM restaurant_service_configs) AS old_count;

-- Should show no restaurants using deprecated columns
SELECT COUNT(*) 
FROM restaurant_delivery_config
WHERE _deprecated_delivery_radius_km IS NOT NULL;
```

**Expected Output:**
```
✅ Service Settings Records: 175
✅ Service Configs Records: 175
✅ Match: YES
✅ Deprecated Columns in Use: 0
```

---

### **Phase 3: Archive & Cleanup** (Week 3)

**What it does:**
- Moves 4 old tables to `_archived` schema
- Drops deprecated columns from `restaurant_delivery_config`
- Enables prevention triggers
- Creates cleanup reminder (drop after 30 days)

**Run:**
```sql
psql -d menuca_v3 -f Database/migrations/delivery_cleanup_phase3_archive_deprecated.sql
```

**Validation:**
```sql
-- Should show 4 archived tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = '_archived';

-- Should show current status
SELECT * FROM v_delivery_cleanup_status;
```

**Expected Output:**
```
✅ Active Zones: 59
✅ Active Service Settings: 175
✅ Active Delivery Configs: 153
✅ Archived Tables: 4
🗓️ Can Drop After: 2025-12-25
```

---

## ⚠️ Rollback Procedures

Each migration script includes a rollback section at the bottom (commented out).

### Phase 1 Rollback
```sql
-- Delete migrated zones
DELETE FROM restaurant_delivery_zones
WHERE created_at >= '2025-11-25' AND created_by = 1;

-- Clear migration tracking
UPDATE restaurant_delivery_areas
SET migrated_to_zones_at = NULL, migrated_zone_id = NULL;
```

### Phase 2 Rollback
```sql
-- Drop new table
DROP TABLE restaurant_service_settings CASCADE;

-- Rename deprecated columns back
ALTER TABLE restaurant_delivery_config 
RENAME COLUMN _deprecated_delivery_radius_km TO delivery_radius_km;
```

### Phase 3 Rollback
```sql
-- Move tables back from archive
ALTER TABLE _archived.restaurant_delivery_areas_archived_20251125 SET SCHEMA public;
ALTER TABLE public.restaurant_delivery_areas_archived_20251125 
    RENAME TO restaurant_delivery_areas;
```

---

## 🎯 Success Metrics

### Technical Metrics
- [ ] **Zero duplicate data** - No column storing same data in 2+ places
- [ ] **Zero config conflicts** - `delivery_method` matches actual implementation
- [ ] **100% migration** - All restaurants on unified system
- [ ] **Query performance** - 30%+ improvement in delivery-related queries

### Data Quality Metrics
```sql
-- Should return 0
SELECT COUNT(*) FROM (
    SELECT restaurant_id 
    FROM restaurant_service_settings rss
    WHERE rss.has_delivery_enabled = TRUE
    AND NOT EXISTS (
        SELECT 1 FROM restaurant_delivery_zones rdz
        WHERE rdz.restaurant_id = rss.restaurant_id
        AND rdz.is_active = TRUE
    )
) AS delivery_enabled_without_zones;
```

---

## 🐛 Troubleshooting

### Issue: Phase 1 migration shows failed records

**Solution:**
```sql
-- Check what failed
SELECT 
    restaurant_id,
    area_name,
    geometry IS NULL AS missing_geometry
FROM restaurant_delivery_areas
WHERE migrated_to_zones_at IS NULL;

-- Manual fix for specific restaurant
INSERT INTO restaurant_delivery_zones (...)
SELECT ... FROM restaurant_delivery_areas WHERE restaurant_id = XXX;
```

### Issue: Phase 2 shows mismatched counts

**Solution:**
```sql
-- Find missing records
SELECT r.id, r.name
FROM restaurants r
LEFT JOIN restaurant_service_settings rss ON rss.restaurant_id = r.id
WHERE r.status = 'active' AND rss.id IS NULL;

-- Manual insert
INSERT INTO restaurant_service_settings (restaurant_id, ...)
SELECT id, ... FROM restaurants WHERE id = XXX;
```

### Issue: Edge function returns errors after migration

**Solution:**
1. Check if function references old table names
2. Update to use new tables:
   - `restaurant_service_configs` → `restaurant_service_settings`
   - `restaurant_delivery_areas` → `restaurant_delivery_zones`
3. Redeploy edge function

---

## 📚 Additional Resources

- **Full Plan:** `Database/DELIVERY_ENTITY_CLEANUP_PLAN.md`
- **Visual Diagrams:** `Database/Mermaid_Diagrams/delivery_entity_cleanup.mmd`
- **Migration Scripts:** `Database/migrations/delivery_cleanup_phase*.sql`
- **Current Schema:** `MVP_RESTAURANTS.md` (lines 1803-1847)

---

## 🤝 Support

**Questions?** Contact:
- Database Team: [database-team@menu.ca]
- Migration Lead: [migrations@menu.ca]
- Emergency: [on-call@menu.ca]

---

## ✅ Post-Migration Checklist

After completing all phases:

- [ ] All validation queries pass
- [ ] Edge functions updated and deployed
- [ ] API documentation updated
- [ ] Developer onboarding guide updated
- [ ] Monitoring dashboards updated
- [ ] Team notified of changes
- [ ] Old queries identified and migrated
- [ ] 30-day reminder set for dropping archives

---

**Last Updated:** 2025-11-25  
**Version:** 1.0  
**Status:** Ready for Review

