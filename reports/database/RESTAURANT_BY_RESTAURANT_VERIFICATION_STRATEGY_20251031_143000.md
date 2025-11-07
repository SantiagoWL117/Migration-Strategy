# Restaurant-by-Restaurant Verification Strategy

**Date:** October 31, 2025  
**Status:** 📋 **PROPOSED APPROACH**  
**Rationale:** Aggregate verification masked restaurant-specific issues. Need granular, restaurant-level checks.

---

## 🎯 **Problem Statement**

**What Happened:**
- Menu & Catalog refactoring verified **aggregate patterns** (e.g., "7,266 dishes have NULL course_id")
- But **missed restaurant-specific issues** (e.g., "Restaurant 977: ALL 86 dishes have NULL course_id")
- Scope was too large for comprehensive verification

**Root Cause:**
- Aggregate statistics looked fine (32% NULL is "acceptable")
- But didn't detect **systematic issues per restaurant**
- Need **restaurant-level GROUP BY** queries to catch these

**Example:**
- ✅ Verified: "7,266 dishes (32%) have NULL course_id" → Conclusion: VALID
- ❌ **MISSED:** "Restaurant 977: ALL 86 dishes (100%) have NULL course_id, but 11 courses exist" → Conclusion: MIGRATION BUG

---

## 📋 **New Strategy: Restaurant-by-Restaurant Verification**

### **Approach:**
1. **Start Small:** Verify one restaurant at a time
2. **Deep Dive:** Check all aspects per restaurant
3. **Pattern Detection:** Identify systematic issues
4. **Fix & Verify:** Fix issues, then verify again
5. **Scale Up:** Apply pattern to next restaurant

### **Benefits:**
- ✅ Catch restaurant-specific issues early
- ✅ Easier to debug (smaller scope)
- ✅ Better verification coverage
- ✅ Faster iteration cycles
- ✅ Can parallelize across multiple agents/developers

---

## 🔍 **Restaurant Verification Checklist**

### **Per Restaurant, Verify:**

#### **1. Basic Structure** ✅
- [ ] Restaurant exists and is active
- [ ] Has at least 1 course defined
- [ ] Has at least 1 dish defined
- [ ] Has pricing for all active dishes

#### **2. Course Assignment** ✅
- [ ] All dishes assigned to courses (or NULL is intentional)
- [ ] No dishes with NULL course_id when courses exist
- [ ] Course structure makes sense (Appetizers, Mains, Desserts, etc.)

#### **3. Modifier Structure** ✅
- [ ] Modifier counts are reasonable (10-50 per dish, not 700+)
- [ ] Modifiers are logically assigned (pizza dishes have pizza modifiers)
- [ ] Modifier groups are properly structured
- [ ] No duplicate modifiers across dishes (unless intentional)

#### **4. Data Quality** ✅
- [ ] Dish names are standardized (no leading/trailing whitespace)
- [ ] Prices are valid (non-negative, reasonable ranges)
- [ ] No orphaned records (dishes without restaurants, modifiers without dishes)
- [ ] Foreign keys are valid

#### **5. Business Logic** ✅
- [ ] Modifiers match dish types (desserts don't have pizza toppings)
- [ ] Required modifiers are marked (e.g., "must select 1 crust type")
- [ ] Pricing logic is correct (base price + modifier prices)
- [ ] Modifier groups have proper min/max selections

---

## 📊 **Verification Query Template**

### **Restaurant-Level Verification Query**

```sql
-- RESTAURANT VERIFICATION TEMPLATE
-- Replace @RESTAURANT_ID@ with actual restaurant ID

WITH restaurant_stats AS (
    SELECT 
        r.id as restaurant_id,
        r.name as restaurant_name,
        r.status,
        
        -- Course stats
        COUNT(DISTINCT c.id) as total_courses,
        COUNT(DISTINCT d.id) as total_dishes,
        COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) as dishes_null_course,
        COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NOT NULL) as dishes_with_course,
        
        -- Modifier stats
        COUNT(DISTINCT mg.id) as total_modifier_groups,
        COUNT(DISTINCT dm.id) as total_modifiers,
        COUNT(DISTINCT dm.id) / NULLIF(COUNT(DISTINCT d.id), 0) as avg_modifiers_per_dish,
        
        -- Pricing stats
        COUNT(DISTINCT dp.id) as total_prices,
        COUNT(DISTINCT d.id) FILTER (WHERE dp.id IS NULL) as dishes_without_prices,
        
        -- Data quality flags
        CASE 
            WHEN COUNT(DISTINCT c.id) > 0 
                AND COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) = COUNT(DISTINCT d.id)
            THEN 'ALL_DISHES_NULL_COURSE'
            ELSE 'OK'
        END as course_assignment_issue,
        
        CASE 
            WHEN COUNT(DISTINCT dm.id) / NULLIF(COUNT(DISTINCT d.id), 0) > 100
            THEN 'EXCESSIVE_MODIFIERS'
            ELSE 'OK'
        END as modifier_count_issue
        
    FROM menuca_v3.restaurants r
    LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id AND c.deleted_at IS NULL
    LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
    LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
    LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
    LEFT JOIN menuca_v3.dish_prices dp ON dp.dish_id = d.id AND dp.deleted_at IS NULL
    WHERE r.id = @RESTAURANT_ID@
        AND r.deleted_at IS NULL
    GROUP BY r.id, r.name, r.status
)
SELECT 
    restaurant_id,
    restaurant_name,
    status,
    total_courses,
    total_dishes,
    dishes_null_course,
    dishes_with_course,
    total_modifier_groups,
    total_modifiers,
    ROUND(avg_modifiers_per_dish, 2) as avg_modifiers_per_dish,
    total_prices,
    dishes_without_prices,
    course_assignment_issue,
    modifier_count_issue,
    CASE 
        WHEN course_assignment_issue != 'OK' OR modifier_count_issue != 'OK' OR dishes_without_prices > 0
        THEN 'ISSUES_FOUND'
        ELSE 'VERIFIED_OK'
    END as verification_status
FROM restaurant_stats;
```

### **Per-Dish Modifier Count Check**

```sql
-- Check modifier counts per dish for a specific restaurant
SELECT 
    d.id as dish_id,
    d.name as dish_name,
    d.course_id,
    c.name as course_name,
    COUNT(DISTINCT mg.id) as modifier_groups_count,
    COUNT(DISTINCT dm.id) as modifiers_count
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.courses c ON c.id = d.course_id
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
WHERE d.restaurant_id = @RESTAURANT_ID@
    AND d.deleted_at IS NULL
GROUP BY d.id, d.name, d.course_id, c.name
ORDER BY modifiers_count DESC;
```

### **Duplicate Modifier Detection**

```sql
-- Check if all dishes have identical modifier counts (indicates bulk assignment bug)
SELECT 
    COUNT(DISTINCT d.id) as dishes_count,
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT COUNT(DISTINCT dm.id)) OVER (PARTITION BY d.restaurant_id) as unique_modifier_counts
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
WHERE d.restaurant_id = @RESTAURANT_ID@
    AND d.deleted_at IS NULL
GROUP BY d.id, d.restaurant_id
HAVING COUNT(DISTINCT COUNT(DISTINCT dm.id)) OVER (PARTITION BY d.restaurant_id) = 1  -- All dishes have same count
LIMIT 1;
```

---

## 📋 **Verification Workflow**

### **Step 1: Prioritize Restaurants**

**Priority 1: High-Value Restaurants**
- Active restaurants with many dishes
- Restaurants with recent migrations
- Restaurants with known issues

**Priority 2: Problem Patterns**
- Restaurants with excessive modifiers (> 100 per dish)
- Restaurants with NULL course_id issues
- Restaurants with missing pricing

**Priority 3: Sample Verification**
- Random sample of restaurants
- Representative across different types (pizza, sushi, etc.)

### **Step 2: Run Verification Query**

```sql
-- Replace @RESTAURANT_ID@ with actual ID
-- Review results:
-- - course_assignment_issue: Should be 'OK'
-- - modifier_count_issue: Should be 'OK'
-- - dishes_without_prices: Should be 0
-- - verification_status: Should be 'VERIFIED_OK'
```

### **Step 3: Deep Dive (If Issues Found)**

**If course_assignment_issue != 'OK':**
- Check course structure
- Verify dishes should be assigned to courses
- Fix course assignments

**If modifier_count_issue != 'OK':**
- Check modifier counts per dish
- Identify duplicate/bulk-assigned modifiers
- Fix modifier assignments

**If dishes_without_prices > 0:**
- Check which dishes are missing prices
- Add pricing or mark dishes inactive

### **Step 4: Fix & Re-Verify**

- Apply fixes
- Run verification query again
- Confirm verification_status = 'VERIFIED_OK'

### **Step 5: Document & Move On**

- Document findings
- Create ticket if needed
- Move to next restaurant

---

## 🎯 **Implementation Plan**

### **Phase 1: Critical Restaurants (This Week)**

**Priority:**
1. Capri Pizza (977) - Known issues
2. Restaurants with excessive modifiers (> 100 per dish)
3. Restaurants with NULL course_id issues

**Action:**
- Run verification query on each
- Fix issues found
- Re-verify

**Deliverable:**
- Verification report per restaurant
- Fix summary
- Verification status: VERIFIED_OK

---

### **Phase 2: High-Value Restaurants (Next Week)**

**Priority:**
- Top 20 restaurants by dish count
- Active restaurants with many orders
- Restaurants with recent migrations

**Action:**
- Run verification query on each
- Fix issues found
- Re-verify

**Deliverable:**
- Verification report per restaurant
- Fix summary
- Verification status: VERIFIED_OK

---

### **Phase 3: Systematic Verification (Ongoing)**

**Approach:**
- Verify restaurants in batches (10-20 at a time)
- Parallelize across multiple agents/developers
- Track progress in shared document

**Deliverable:**
- Verification report per restaurant
- Summary dashboard (X of Y restaurants verified)
- Ongoing monitoring

---

## 📊 **Verification Dashboard Template**

### **Restaurant Verification Status**

| Restaurant ID | Name | Status | Courses | Dishes | Avg Modifiers/Dish | Issues | Verified By | Date |
|---------------|------|--------|---------|--------|-------------------|--------|-------------|------|
| 977 | Capri Pizza | Active | 11 | 86 | 704 🔴 | ALL_NULL_COURSE, EXCESSIVE_MODIFIERS | [Agent] | 2025-10-31 |
| 824 | Prima Pizza | Active | 8 | 140 | 1.3 ✅ | None | [Agent] | 2025-10-27 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

**Legend:**
- ✅ Verified OK
- 🔴 Issues Found
- ⏳ Pending Verification
- ✅ Fixed & Re-Verified

---

## 🔧 **Tools & Automation**

### **Automated Verification Script**

```sql
-- Run verification on multiple restaurants
SELECT 
    r.id,
    r.name,
    -- ... (verification query columns)
FROM menuca_v3.restaurants r
WHERE r.status = 'active'
    AND r.deleted_at IS NULL
ORDER BY r.id
LIMIT 10;  -- Start with 10 restaurants
```

### **Verification Report Generator**

```bash
# Generate verification report for a restaurant
# Usage: ./verify_restaurant.sh <restaurant_id>

RESTAURANT_ID=$1
OUTPUT_FILE="reports/database/RESTAURANT_${RESTAURANT_ID}_VERIFICATION_$(date +%Y%m%d_%H%M%S).md"

# Run verification query
# Generate markdown report
# Save to OUTPUT_FILE
```

---

## 📝 **Best Practices**

### **1. Start Small**
- Verify one restaurant at a time
- Deep dive into issues
- Fix before moving on

### **2. Document Everything**
- Verification results
- Issues found
- Fixes applied
- Re-verification status

### **3. Pattern Recognition**
- Identify common issues
- Create reusable fixes
- Prevent similar issues

### **4. Iterate Quickly**
- Small batches (10-20 restaurants)
- Fast feedback loops
- Continuous improvement

### **5. Parallelize**
- Multiple agents/developers
- Different restaurants
- Shared progress tracking

---

## 🎯 **Success Metrics**

### **Verification Coverage**
- **Target:** 100% of active restaurants verified
- **Current:** 0% (starting fresh)
- **Progress:** Track in dashboard

### **Issue Detection Rate**
- **Target:** Catch 100% of restaurant-specific issues
- **Current:** Missed Capri Pizza issues
- **Improvement:** Restaurant-by-restaurant catches these

### **Fix Quality**
- **Target:** 100% of issues fixed and re-verified
- **Current:** Capri Pizza issues identified, fixing in progress
- **Process:** Fix → Re-verify → Document

---

## 📋 **Next Steps**

### **Immediate (Today):**
1. ✅ Create verification query template
2. ✅ Run verification on Capri Pizza (977)
3. ✅ Document findings
4. ⏳ Fix Capri Pizza issues
5. ⏳ Re-verify Capri Pizza

### **Short-Term (This Week):**
1. ⏳ Verify top 10 high-value restaurants
2. ⏳ Fix issues found
3. ⏳ Create verification dashboard
4. ⏳ Document process

### **Long-Term (This Month):**
1. ⏳ Verify all active restaurants
2. ⏳ Automate verification process
3. ⏳ Add to CI/CD pipeline
4. ⏳ Ongoing monitoring

---

**Report Generated:** October 31, 2025  
**Status:** 📋 **PROPOSED APPROACH**  
**Next Action:** Run verification on Capri Pizza (977) as proof of concept





