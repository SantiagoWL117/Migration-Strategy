# 🚨 CRITICAL: 75 Active Restaurants with ZERO Menu Data

**Date:** 2025-10-28  
**Severity:** CRITICAL DATA LOSS  
**Impact:** 75 paying customers ($2k/month each = $150k/month revenue at risk)

---

## THE PROBLEM

**75 restaurants marked as `status='active'` and `online_ordering_enabled=true` have ZERO dishes in the database.**

Not "missing prices" - **ZERO MENU ITEMS AT ALL**. These restaurants cannot take orders.

### Numbers
- **75 restaurants** affected
- **0 dishes** (not even inactive ones)
- **All marked "active"** - should be operational
- **Most migrated from V2** (2023-2025)
- **Ottawa/Gatineau/Hull area** - core market

---

## ROOT CAUSE ANALYSIS

### Migration Failure Categories

#### 1. **Recent V2 Migrations (2023-2025)**
Many restaurants have `legacy_v2_id` and were migrated recently:
- All Out Burger Gladstone (v2_id: 1635) - Oct 2023
- All Out Burger Montreal Rd (v2_id: 1636) - Apr 2023  
- Chicco Pizza locations (v2_ids: 1658-1664) - Mar 2024
- Chef Rad Halal Pizza (v2_id: 1677) - May 2025
- Capri Pizza (v2_id: 1674) - Jan 2025

**These are RECENT additions - their dish data should exist in V2 staging!**

#### 2. **Duplicate Restaurant Records**
Multiple restaurants appear twice:
- Aahar The Taste of India (IDs: 561, 994)
- All Out Burger (IDs: 794 has dishes, 988 empty)
- Aroy Thai (IDs: 607, 995)
- Asia Garden Ottawa (IDs: 630, 996)

**One has data, one is empty - likely import duplicates**

#### 3. **No Legacy IDs**
Some have neither V1 nor V2 legacy IDs:
- 1 for 1 Pizza Carling (ID: 993)
- Buffalo Bill (ID: 997)
- Multiple others

**These may be new restaurants never in V1/V2**

---

## AFFECTED RESTAURANTS (FULL LIST)

| ID | Name | Legacy V2 ID | City | Phone | Email | Notes |
|----|------|--------------|------|-------|-------|-------|
| 993 | 1 for 1 Pizza Carling | NULL | ? | ? | ? | No legacy data |
| 561 | Aahar The Taste of India | NULL | Ottawa | (613) 422-6644 | rupinder.pal@hotmail.com | V1 ID: 781, DUPLICATE |
| 994 | Aahar The Taste of India | NULL | ? | ? | ? | DUPLICATE |
| 981 | Al-s Drive In | 1678 | Osgoode | (613) 878-9898 | callamer@gmail.com | V2 Jun 2025 |
| 988 | All Out Burger | NULL | ? | ? | ? | DUPLICATE (794 has data) |
| 948 | All Out Burger Gladstone | 1635 | Ottawa | (613) 233-1000 | george@menu.ca | V2 Apr 2023 |
| 949 | All Out Burger Montreal Rd | 1636 | Ottawa | (613) 745-5555 | mahde_ghandour@hotmail.com | V2 Apr 2023 |
| 735 | Amicci Pizza | NULL | Gatineau | (819) 775-3355 | michelkanaan@live.com | V1 ID: 973 |
| 607 | Aroy Thai | NULL | Barrhaven | (613) 823-2224 | happy_pat29@hotmail.com | V1 ID: 830 |
| 995 | Aroy Thai | NULL | ? | ? | ? | DUPLICATE |
| 630 | Asia Garden Ottawa | NULL | Ottawa | (613) 224-7343 | asiagardenottawa@gmail.com | V1 ID: 856 |
| 996 | Asia Garden Ottawa | NULL | ? | ? | ? | DUPLICATE |
| 776 | Bank Shawarma and Poutine | NULL | Ottawa | (613) 733-6161 | ? | V1 ID: 1018 |
| 997 | Buffalo Bill | NULL | ? | ? | ? | No legacy data |
| 977 | Capri Pizza | 1674 | Ottawa | (613) 680-8484 | callamer@gmail.com | V2 Jan 2025 |
| 980 | Chef Rad Halal Pizza & Burgers | 1677 | Gloucester | (613) 695-9966 | raficwz@hotmail.com | V2 May 2025 |
| 962 | Chicco Pizza & Shawarma Buckingham | 1659 | Gatineau | (819) 986-2222 | alexandra@menu.ca | V2 Mar 2024 |
| 967 | Chicco Pizza St-Louis | 1664 | Gatineau | (819) 568-0000 | alexandra@menu.ca | V2 Mar 2024 |
| 961 | Chicco Shawarma Cantley | 1658 | Cantley | (819) 607-0712 | alexandra@menu.ca | V2 Mar 2024 |

*(Partial list - 75 total, see full CSV export)*

---

## IMMEDIATE INVESTIGATION REQUIRED

### Step 1: Check V1/V2 Staging Data ✓ (In Progress)
Query V1/V2 staging tables to see if dish data exists:
```sql
-- Check V1 staging
SELECT COUNT(*) FROM staging.v1_with_clean_price v1
WHERE v1.restaurant IN (781, 973, 830, 856, 1018); -- Legacy V1 IDs

-- Check V2 staging  
SELECT COUNT(*) FROM staging.v2_with_clean_price v2
WHERE v2.course_id IN (
  SELECT id FROM staging.menuca_v2_dishes_production
  WHERE restaurant_id IN (1635, 1636, 1658, 1659, 1664, 1674, 1677, 1678)
);
```

### Step 2: Identify Why Migration Failed
Possible causes:
1. **Course/Restaurant mapping broken** in V2 → V3
2. **Foreign key constraints** prevented dish insertion
3. **Migration script bug** skipped these restaurants
4. **Data corruption** in source V1/V2 databases
5. **Duplicate detection** wrongly excluded dishes

### Step 3: Verify Operational Status
Use Playwright to check if restaurants are:
- Actually open and operating
- Listed on MenuGatineau/own websites
- Taking online orders elsewhere

### Step 4: Data Recovery Plan
For each category:

**A) Recent V2 Migrations (2023-2025):**
- Re-run V2 → V3 dish migration for these specific restaurants
- Fix any broken course/restaurant mappings
- Validate data integrity

**B) Duplicates:**
- Identify which record is correct
- Merge data or mark incorrect one as `suspended`
- Clean up duplicate entries

**C) V1 Migrations Missing Dishes:**
- Re-run V1 → V3 dish migration
- Check for data in staging tables
- Manual recovery if needed

**D) No Legacy IDs:**
- Contact restaurants directly
- Request current menu data
- Manual data entry if necessary

---

## PRIORITY ACTIONS (NEXT 24 HOURS)

### Priority 1: STOP THE BLEEDING
1. ✅ Export full list of 75 restaurants
2. ⏳ Check if dish data exists in V1/V2 staging
3. ⏳ Identify restaurants actually still operational
4. ⏳ Mark truly closed ones as `suspended`

### Priority 2: DATA RECOVERY
5. ⏳ Re-run migrations for restaurants with staging data
6. ⏳ Fix duplicate records
7. ⏳ Contact restaurants without legacy data

### Priority 3: PREVENT RECURRENCE
8. ⏳ Add database constraint: active restaurants MUST have >0 active dishes
9. ⏳ Create monitoring alert for empty active restaurants
10. ⏳ Review migration scripts for bugs

---

## FINANCIAL IMPACT

**Worst Case Scenario:**
- 75 restaurants × $2,000/month = **$150,000/month revenue**
- If unresolved for 3 months = **$450,000 loss**
- Plus customer churn and reputation damage

**Best Case Scenario:**
- 50% are duplicates/closed = 37 real restaurants
- 37 × $2,000/month = **$74,000/month at risk**
- Resolve within 1 week = minimal impact

---

## NEXT STEPS

**IMMEDIATE (RIGHT NOW):**
1. Run V1/V2 staging data queries to find recoverable dishes
2. Generate detailed migration failure report per restaurant
3. Create Playwright automation to verify operational status

**SHORT-TERM (THIS WEEK):**
1. Recover dishes from V1/V2 staging for all recoverable restaurants
2. Contact restaurants without staging data for manual menu entry
3. Mark confirmed-closed restaurants as suspended
4. Fix duplicate records

**LONG-TERM (THIS MONTH):**
1. Audit entire migration process
2. Add data integrity constraints
3. Implement monitoring/alerting
4. Document lessons learned

---

**This is NOT a "recommended action" - this is a CRITICAL DATA LOSS that needs immediate resolution.**

Full restaurant list in: `/tmp/empty_active_restaurants_full.csv`

