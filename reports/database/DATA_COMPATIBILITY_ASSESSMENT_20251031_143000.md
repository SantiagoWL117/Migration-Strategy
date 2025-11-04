# Data Compatibility Assessment - STOP & PLAN

**Date:** October 31, 2025  
**Status:** 🛑 **ASSESSMENT PHASE - NO ACTIONS TAKEN**  
**Critical:** One month of DB work completed, but data may be incompatible/unusable. Need full assessment before any fixes.

---

## 🚨 **The Situation**

**What Happened:**
- ✅ 1 month of database refactoring work completed (Phases 1-14)
- ✅ Schema changes implemented
- ✅ Data migrations executed
- ❌ **DISCOVERED:** Data quality issues make data incompatible/unusable
- ❌ **DISCOVERED:** Restaurant-specific issues not caught during verification

**User's Concern:**
- Don't want to rush into fixes and make things worse
- Need project to be built, but can't proceed with incompatible data
- Need proper plan before any actions

**Our Approach:**
- 🛑 **STOP** - No actions until full assessment complete
- 📋 **ASSESS** - Understand full scope of issues
- 📝 **PLAN** - Create comprehensive fix strategy
- ✅ **VERIFY** - Confirm plan before execution

---

## 🔍 **What We Know So Far**

### **Known Issues:**

1. **Capri Pizza (restaurant_id: 977)**
   - ALL 86 dishes have NULL course_id (but 11 courses exist)
   - Every dish has exactly 704 modifiers (should be ~10-50)
   - Total: 60,544 modifier records (should be ~500-4,000)
   - Illogical modifiers (desserts with pizza toppings)
   - No modifier group structure

2. **Potential Systemic Issues:**
   - Phase 2 modifier migration may have created cartesian join bugs
   - V2 recovery (Oct 28) may have skipped course assignments
   - Aggregate verification masked restaurant-specific problems

### **Unknown (Need to Assess):**

1. **Scale of Issues:**
   - How many restaurants have similar problems?
   - Which restaurants are affected?
   - What's the pattern?

2. **Root Causes:**
   - What exactly went wrong in Phase 2 migration?
   - What went wrong in V2 recovery?
   - Are there other migration bugs?

3. **Data Integrity:**
   - Is the data fixable?
   - What's the recovery strategy?
   - What's the risk of making things worse?

---

## 📋 **Assessment Plan**

### **Phase 1: Discovery (NO FIXES)**

**Objective:** Understand the full scope of issues without making any changes.

#### **Step 1.1: Restaurant-Level Audit**

**Query:** Run verification query on ALL restaurants to identify:
- Restaurants with NULL course_id issues
- Restaurants with excessive modifiers (> 100 per dish)
- Restaurants with missing pricing
- Restaurants with other data quality issues

**Deliverable:** List of affected restaurants with issue types

**Status:** ⏳ PENDING - Need to run queries

---

#### **Step 1.2: Pattern Analysis**

**Query:** Analyze patterns to understand:
- Which restaurants are affected?
- What's the correlation with migration dates?
- Are issues systematic or random?
- Are there migration batch patterns?

**Deliverable:** Pattern analysis report

**Status:** ⏳ PENDING - Need to analyze results

---

#### **Step 1.3: Root Cause Investigation**

**Investigation:**
- Review Phase 2 migration SQL (check for cartesian joins)
- Review V2 recovery process (check course assignment logic)
- Review other migration phases for similar bugs
- Identify all migration points that could cause issues

**Deliverable:** Root cause analysis report

**Status:** ⏳ PENDING - Need to review migration code

---

#### **Step 1.4: Data Integrity Assessment**

**Assessment:**
- Can we identify correct data for affected restaurants?
- Is source data available (V1/V2 staging)?
- Can we distinguish good data from bad data?
- What's the recovery strategy?

**Deliverable:** Data integrity assessment report

**Status:** ⏳ PENDING - Need to check source data availability

---

### **Phase 2: Planning (NO FIXES)**

**Objective:** Create comprehensive fix strategy before any actions.

#### **Step 2.1: Issue Prioritization**

**Prioritize:**
- Critical issues (blocks functionality)
- High-impact issues (affects many restaurants)
- Low-impact issues (cosmetic)
- Create priority matrix

**Deliverable:** Prioritized issue list

**Status:** ⏳ PENDING - Need assessment results

---

#### **Step 2.2: Fix Strategy**

**Plan:**
- For each issue type, create fix strategy
- Define rollback plan
- Define verification plan
- Define testing plan

**Deliverable:** Comprehensive fix strategy document

**Status:** ⏳ PENDING - Need to understand all issues first

---

#### **Step 2.3: Risk Assessment**

**Assess:**
- What's the risk of making things worse?
- What's the risk of NOT fixing?
- What's the recovery plan if fixes fail?
- What's the rollback strategy?

**Deliverable:** Risk assessment document

**Status:** ⏳ PENDING - Need to understand fixes first

---

#### **Step 2.4: Execution Plan**

**Plan:**
- Step-by-step execution plan
- Dependencies
- Verification checkpoints
- Success criteria

**Deliverable:** Detailed execution plan

**Status:** ⏳ PENDING - Need fix strategy first

---

### **Phase 3: Verification (NO FIXES)**

**Objective:** Verify plan is correct before execution.

#### **Step 3.1: Plan Review**

**Review:**
- Is plan comprehensive?
- Are risks addressed?
- Are rollback plans in place?
- Are verification plans clear?

**Deliverable:** Plan review checklist

**Status:** ⏳ PENDING - Need plan first

---

#### **Step 3.2: Test Strategy**

**Plan:**
- How to test fixes?
- How to verify fixes worked?
- How to detect regressions?
- What's the acceptance criteria?

**Deliverable:** Test strategy document

**Status:** ⏳ PENDING - Need fix strategy first

---

## 📊 **Assessment Queries Needed**

### **Query 1: Restaurant-Level Issue Detection**

```sql
-- Run on ALL restaurants to identify issues
-- NO FIXES - Just discovery
SELECT 
    r.id,
    r.name,
    r.status,
    COUNT(DISTINCT c.id) as courses,
    COUNT(DISTINCT d.id) as dishes,
    COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) as dishes_null_course,
    COUNT(DISTINCT mg.id) as modifier_groups,
    COUNT(DISTINCT dm.id) as modifiers,
    ROUND(COUNT(DISTINCT dm.id)::NUMERIC / NULLIF(COUNT(DISTINCT d.id), 0), 2) as avg_modifiers_per_dish,
    COUNT(DISTINCT dp.id) as prices,
    COUNT(DISTINCT d.id) FILTER (WHERE dp.id IS NULL) as dishes_without_prices,
    CASE 
        WHEN COUNT(DISTINCT c.id) > 0 
            AND COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) = COUNT(DISTINCT d.id)
        THEN 'ALL_NULL_COURSE'
        WHEN COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) > COUNT(DISTINCT d.id) * 0.5
        THEN 'MOSTLY_NULL_COURSE'
        ELSE 'OK'
    END as course_issue,
    CASE 
        WHEN COUNT(DISTINCT dm.id) / NULLIF(COUNT(DISTINCT d.id), 0) > 100
        THEN 'EXCESSIVE_MODIFIERS'
        WHEN COUNT(DISTINCT dm.id) / NULLIF(COUNT(DISTINCT d.id), 0) > 50
        THEN 'HIGH_MODIFIERS'
        ELSE 'OK'
    END as modifier_issue,
    CASE 
        WHEN COUNT(DISTINCT d.id) FILTER (WHERE dp.id IS NULL) > 0
        THEN 'MISSING_PRICES'
        ELSE 'OK'
    END as pricing_issue
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id AND c.deleted_at IS NULL
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
LEFT JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id AND dp.deleted_at IS NULL
WHERE r.deleted_at IS NULL
GROUP BY r.id, r.name, r.status
ORDER BY 
    CASE 
        WHEN COUNT(DISTINCT c.id) > 0 
            AND COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) = COUNT(DISTINCT d.id)
        THEN 1
        WHEN COUNT(DISTINCT dm.id) / NULLIF(COUNT(DISTINCT d.id), 0) > 100
        THEN 2
        ELSE 3
    END,
    avg_modifiers_per_dish DESC;
```

**Purpose:** Identify ALL restaurants with issues
**Action:** Run query, save results, analyze patterns
**NO FIXES:** Just discovery

---

### **Query 2: Modifier Duplication Pattern**

```sql
-- Check for restaurants where all dishes have identical modifier counts
-- This indicates bulk assignment bug
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT d.id) as dishes_count,
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT (SELECT COUNT(DISTINCT dm2.id) 
                    FROM menuca_v3.dish_modifiers dm2
                    JOIN menuca_v3.modifier_groups mg2 ON mg2.id = dm2.modifier_group_id
                    WHERE mg2.dish_id = d.id)) as unique_modifier_counts_per_dish
FROM menuca_v3.restaurants r
JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
WHERE r.deleted_at IS NULL
GROUP BY r.id, r.name
HAVING COUNT(DISTINCT d.id) > 0
    AND COUNT(DISTINCT (SELECT COUNT(DISTINCT dm2.id) 
                        FROM menuca_v3.dish_modifiers dm2
                        JOIN menuca_v3.modifier_groups mg2 ON mg2.id = dm2.modifier_group_id
                        WHERE mg2.dish_id = d.id)) = 1  -- All dishes have same count
ORDER BY total_modifiers DESC;
```

**Purpose:** Identify restaurants with bulk assignment bugs
**Action:** Run query, save results, analyze pattern
**NO FIXES:** Just discovery

---

### **Query 3: Migration Timeline Correlation**

```sql
-- Check if issues correlate with migration dates
SELECT 
    r.id,
    r.name,
    r.created_at as restaurant_created,
    MIN(d.created_at) as first_dish_created,
    MAX(d.created_at) as last_dish_created,
    MIN(d.updated_at) as first_dish_updated,
    MAX(d.updated_at) as last_dish_updated,
    r.legacy_v1_id,
    r.legacy_v2_id,
    COUNT(DISTINCT d.id) as dishes,
    COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) as dishes_null_course,
    COUNT(DISTINCT dm.id) as modifiers,
    ROUND(COUNT(DISTINCT dm.id)::NUMERIC / NULLIF(COUNT(DISTINCT d.id), 0), 2) as avg_modifiers_per_dish
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
WHERE r.deleted_at IS NULL
GROUP BY r.id, r.name, r.created_at, r.legacy_v1_id, r.legacy_v2_id
ORDER BY 
    CASE 
        WHEN MAX(d.updated_at) >= '2025-10-30'::timestamp THEN 1  -- Phase 2 migration period
        WHEN MAX(d.created_at) >= '2025-10-28'::timestamp THEN 2  -- V2 recovery period
        ELSE 3
    END,
    avg_modifiers_per_dish DESC;
```

**Purpose:** Identify correlation between migration dates and issues
**Action:** Run query, save results, analyze correlation
**NO FIXES:** Just discovery

---

## 🛑 **Current Status: ASSESSMENT ONLY**

**What We're Doing:**
- ✅ Creating assessment plan
- ✅ Identifying what queries to run
- ✅ Documenting known issues
- ⏳ **WAITING** for your approval before running queries

**What We're NOT Doing:**
- ❌ No fixes
- ❌ No migrations
- ❌ No data changes
- ❌ No rushing

**Next Steps (Pending Your Approval):**
1. Run assessment queries (read-only, no changes)
2. Analyze results
3. Create comprehensive plan
4. Get your approval before any fixes

---

## 📋 **Assessment Deliverables**

### **Deliverable 1: Issue Inventory**
- List of ALL restaurants with issues
- Issue types per restaurant
- Severity assessment

### **Deliverable 2: Root Cause Analysis**
- What went wrong?
- When did it go wrong?
- Why wasn't it caught?

### **Deliverable 3: Data Integrity Assessment**
- Can we fix it?
- What's the recovery strategy?
- What's the risk?

### **Deliverable 4: Fix Strategy**
- Step-by-step fix plan
- Risk mitigation
- Rollback plan
- Verification plan

### **Deliverable 5: Execution Plan**
- Timeline
- Dependencies
- Checkpoints
- Success criteria

---

## 🎯 **Success Criteria**

**Assessment Complete When:**
- ✅ All issues identified
- ✅ Root causes understood
- ✅ Data integrity assessed
- ✅ Fix strategy created
- ✅ Risk assessment complete
- ✅ Execution plan ready
- ✅ **YOUR APPROVAL** received

**Then:**
- 🛑 **STILL NO ACTIONS** until you approve plan
- 📋 Review plan together
- ✅ Execute only after approval

---

## 🚨 **CRITICAL: No Actions Until Approval**

**Current Status:** Assessment planning only

**What We Need From You:**
1. Approval to run assessment queries (read-only, no changes)
2. Time to analyze results
3. Approval of fix strategy before execution
4. Approval of execution plan before fixes

**We Will NOT:**
- Make any data changes
- Run any migrations
- Fix anything
- Rush into anything

**We Will:**
- Assess thoroughly
- Plan comprehensively
- Get your approval
- Execute carefully

---

**Report Generated:** October 31, 2025  
**Status:** 🛑 **ASSESSMENT PHASE - NO ACTIONS**  
**Next:** Awaiting approval to run assessment queries (read-only)


