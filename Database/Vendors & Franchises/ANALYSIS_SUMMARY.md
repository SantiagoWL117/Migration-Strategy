# Vendors & Franchises - Quick Analysis Summary

**Date**: January 10, 2025  
**Status**: ⚠️ **REQUIRES BUSINESS DECISION BEFORE MIGRATION**

---

## 📊 What I Found

### Data Volume
- **7 tables** across V1 & V2 systems
- **~1,109 total records**
- **49% orphaned data** (vendor_id=0 or restaurant_id=0)
- **493 financial reports** (last activity: Jan 2024)

### Key Tables

**V1 (Legacy)**:
- `vendors` (5 records, 3 BLOB columns) - menu.ca, MenuOttawa, etc.
- `vendor_users` (3 records) - Stefan, Yazdan, Matt
- `vendors_restaurants` (587 records, 290 orphaned)

**V2 (Current)**:
- `vendor_reports` (493 records) - Financial reports with JSON
- `vendor_splits` (19 records) - Only 2% of restaurants
- `vendor_splits_templates` (2 records) - ⚠️ **Contains executable PHP code**

---

## 🔴 Critical Findings

### 1. **Business Model Unclear**
- Last vendor activity: January 2024
- Only 19 restaurants (out of 944) use commission splits
- Unknown if menu.ca and MenuOttawa still operate as vendors

### 2. **Executable Code in Database** 🚨
```php
// Stored in vendor_splits_templates.breakdown:
$forVendor = ##total## * .3;
$collection = ##total## * ##restaurant_convenience_fee##;
$forMenuOttawa = ($collection - $forVendor - ##menuottawa_share##) / 2;
```
**This is a MAJOR security and maintenance risk!**

### 3. **Data Quality Issues**
- 49% of vendor-restaurant links are orphaned (vendor_id=0)
- Test accounts mixed with production data
- Weak password hashes (SHA1)

---

## 🎯 Three Migration Options

### Option A: Full Migration (if vendor model is active)
- **Effort**: 40-60 hours
- **Scope**: Migrate all data, refactor PHP templates to code
- **Risk**: HIGH (business logic unclear, financial calculations)

### Option B: Archive-Only (if deprecated < 6 months)
- **Effort**: 8-16 hours
- **Scope**: Read-only historical data preservation
- **Risk**: LOW (no active features)

### Option C: No Migration (if deprecated > 6 months)
- **Effort**: 2 hours (documentation only)
- **Scope**: Keep in legacy dumps only
- **Risk**: NONE

---

## ❓ Questions That Must Be Answered

### Before ANY migration work:

1. **Is the vendor/franchise model still active?**
   - When was the last vendor payout?
   - Are new vendors being onboarded?

2. **Is MenuOttawa still operating?**
   - Is it a franchise or independent?
   - What's the current commission structure?

3. **Are commission splits still calculated?**
   - Why only 19 restaurants out of 944?
   - Are templates still being modified?

4. **Are vendor reports still generated?**
   - Who uses these reports?
   - Where are the PDF files stored?

5. **Does V3 already have vendor tables?**
   - Need to audit V3 schema first
   - Check if vendors are represented differently

---

## 🚦 Recommended Next Steps

### Step 1: Business Review Meeting (1-2 hours)
- [ ] Schedule meeting with Product Owner, Finance, Operations
- [ ] Present findings from this analysis
- [ ] Answer the 5 critical questions above
- [ ] Decision: Choose Option A, B, or C

### Step 2: V3 Schema Audit (30 minutes)
- [ ] Check if vendor tables exist in V3
- [ ] Check if restaurants have vendor_id foreign key
- [ ] Document current V3 vendor representation

### Step 3: Proceed Based on Decision
- **If Option A**: Full migration planning (40-60 hours)
- **If Option B**: Archive-only approach (8-16 hours)
- **If Option C**: Documentation only (2 hours)

---

## 📋 What's in the Full Guide

I've created a comprehensive migration guide: `VENDORS_FRANCHISES_MIGRATION_GUIDE.md`

**Contents**:
- ✅ Complete schema analysis (all 7 tables)
- ✅ Data quality assessment
- ✅ BLOB structure documentation
- ✅ Migration challenges identified
- ✅ Three detailed migration options
- ✅ Risk assessment
- ✅ Stakeholder questions
- ✅ Effort estimates
- ✅ Sample data and JSON structures

---

## ⚠️ **CRITICAL: DO NOT PROCEED WITH MIGRATION YET**

**Reason**: The business model status is unknown, and migrating financial/commission data without understanding current requirements could:
- Waste 40-60 hours of effort
- Introduce incorrect commission calculations
- Migrate deprecated functionality
- Create security issues (executable code)

**Next Action**: Schedule business review meeting FIRST

---

**Analysis Complete**: ✅  
**Migration Planning**: ⏸️ **PAUSED - Awaiting Business Input**  
**Full Documentation**: `VENDORS_FRANCHISES_MIGRATION_GUIDE.md`

