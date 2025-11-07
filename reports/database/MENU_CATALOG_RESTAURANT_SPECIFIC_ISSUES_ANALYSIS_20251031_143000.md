# Menu & Catalog - Restaurant-Specific Data Quality Issues Analysis

**Date:** October 31, 2025  
**Status:** 🔴 **CRITICAL ISSUES FOUND**  
**Restaurant:** Capri Pizza (restaurant_id: 977)

---

## 🚨 **Executive Summary**

During the Menu & Catalog refactoring (Phases 1-14), we focused on **schema-level** and **aggregate-level** data quality. However, **restaurant-specific** data quality issues were not identified. Santiago has now discovered systematic data integrity issues at the restaurant level that require immediate attention.

---

## 📊 **What Was Verified During Refactoring**

### ✅ **What We Checked:**

1. **Aggregate NULL course_id Analysis** ✅
   - Found: 7,266 dishes (32%) have NULL course_id **across all restaurants**
   - Conclusion: NULL course_id is VALID (modifiers work correctly)
   - **Report:** `/reports/database/MENU_CATALOG_NULL_COURSE_ID_ANALYSIS.md`

2. **General Modifier Pricing** ✅
   - Found: 426,483 modifiers (99.7%) have $0 price **across all restaurants**
   - Conclusion: $0 prices are INTENTIONAL (free/included modifiers)
   - **Report:** `/reports/database/MENU_CATALOG_MODIFIER_PRICING_ANALYSIS.md`

3. **Duplicate Dish Names** ✅
   - Found: Some restaurants have duplicate names **across all restaurants**
   - Conclusion: Some intentional (different courses), some need review
   - **Report:** `/reports/database/MENU_CATALOG_DUPLICATE_NAMES_ANALYSIS.md`

### ❌ **What We MISSED:**

1. **Restaurant-Specific NULL course_id** ❌
   - **NOT CHECKED:** Restaurants where ALL dishes have NULL course_id
   - **NOT CHECKED:** Restaurants with courses defined but dishes not assigned

2. **Modifier Duplication** ❌
   - **NOT CHECKED:** Restaurants with massive modifier duplication
   - **NOT CHECKED:** Restaurants where every dish has identical modifier counts

3. **Illogical Modifier Assignments** ❌
   - **NOT CHECKED:** Modifiers assigned to wrong dish types (desserts with pizza modifiers)

4. **Missing Modifier Group Structure** ❌
   - **NOT CHECKED:** Restaurants with zero modifier groups configured

---

## 🔍 **Current Issues - Capri Pizza (restaurant_id: 977)**

### Issue #1: NULL Course Assignments 🔴

**Problem:**
- **ALL 86 dishes** have NULL `course_id` values
- **11 courses** are properly defined (Appetizers, Desserts, Pizzas, etc.)
- **But NO dishes** are assigned to any course

**Impact:**
- Dishes appear unorganized in menu
- Cannot display dishes by course
- Menu structure broken

**Root Cause:**
- Migration likely failed to link dishes to courses during V1/V2 → V3 migration
- Course IDs exist but foreign key not populated

**Action Required:**
- Map dishes to appropriate courses based on dish names/types
- Update `dishes.course_id` for all 86 dishes

---

### Issue #2: Massive Modifier Duplication 🔴

**Problem:**
- **Every dish** has exactly **704 modifiers** assigned
- **Total: 60,544 modifier records** (86 dishes × 704 = 60,544)
- **Expected:** ~500-4,000 modifiers total for a typical restaurant

**Impact:**
- Massive data bloat
- Performance degradation
- Impossible to manage modifiers
- Confusing for restaurant staff

**Root Cause:**
- Likely bulk-assignment bug during migration
- Same modifier set assigned to every dish without validation
- Possible Cartesian join issue during ETL

**Action Required:**
- Identify correct modifiers per dish
- Remove duplicate assignments
- Implement validation to prevent bulk assignment errors

---

### Issue #3: Illogical Modifier Assignments 🔴

**Problem:**
- **Desserts** like "3 Layer Mouse Cake" have:
  - BBQ Sauce
  - Pizza Sauce
  - Pepperoni
  - Ham
  - Donair Meat
- Modifiers appear to be **bulk-assigned without validation**

**Impact:**
- Menu shows incorrect customization options
- Customer confusion
- Order errors

**Root Cause:**
- Same as Issue #2 - bulk assignment without dish-type validation
- No business logic to prevent dessert modifiers on pizza dishes

**Action Required:**
- Remove inappropriate modifiers from dishes
- Implement dish-type validation
- Create modifier assignment rules

---

### Issue #4: No Modifier Group Structure 🔴

**Problem:**
- **Zero modifier groups** are configured
- All modifiers are **flat, unorganized**
- Cannot enforce selection rules (required vs optional, min/max)

**Impact:**
- Cannot organize modifiers logically
- Cannot enforce business rules (e.g., "must select crust")
- Poor user experience

**Root Cause:**
- Migration likely created modifiers but not modifier groups
- Modifier groups (Phase 2) not properly migrated for this restaurant

**Action Required:**
- Create modifier groups based on modifier types
- Organize modifiers into logical groups
- Assign groups to dishes with proper rules

---

## 🔍 **Why These Issues Were Missed**

### **Analysis Approach:**

**During Refactoring:**
- ✅ Checked **aggregate statistics** (e.g., "7,266 dishes have NULL course_id")
- ✅ Verified **schema integrity** (FKs valid, no orphaned records)
- ✅ Verified **general patterns** (modifiers work with NULL course_id)

**Missing:**
- ❌ **Restaurant-level analysis** (specific restaurants with systematic issues)
- ❌ **Pattern detection** (restaurants where ALL dishes have same issue)
- ❌ **Business logic validation** (dessert modifiers on desserts, not pizzas)

### **Example:**

**What We Found:**
```
"7,266 dishes have NULL course_id across all restaurants"
→ Conclusion: NULL course_id is VALID
```

**What We SHOULD Have Found:**
```
"Restaurant 977: ALL 86 dishes have NULL course_id, but 11 courses exist"
→ Conclusion: Migration FAILED for this restaurant
```

---

## 📋 **Action Plan**

### **Immediate Actions:**

1. **Create Restaurant-Level Data Quality Audit** 🔴
   - Query to identify restaurants with systematic issues:
     - All dishes NULL course_id (but courses exist)
     - Excessive modifier counts (e.g., > 500 per dish)
     - Zero modifier groups (but modifiers exist)
     - Illogical modifier assignments

2. **Fix Capri Pizza (restaurant_id: 977)** 🔴
   - Assign dishes to courses
   - Remove duplicate modifiers
   - Remove inappropriate modifiers
   - Create modifier groups

3. **Identify Other Affected Restaurants** 🔴
   - Run audit queries on all restaurants
   - Create list of restaurants needing fixes
   - Prioritize by impact (number of dishes, customer-facing issues)

### **Long-Term Actions:**

1. **Add Restaurant-Level Validation** 🟡
   - Business rules validation per restaurant
   - Modifier assignment validation
   - Course assignment validation

2. **Add Data Quality Monitoring** 🟡
   - Automated checks for restaurant-specific issues
   - Alerts on systematic problems
   - Dashboard for data quality metrics

3. **Review Migration Scripts** 🟡
   - Identify why certain restaurants had bulk assignment issues
   - Fix root cause to prevent future issues
   - Test with sample restaurants before full migration

---

## 🔍 **Investigation Queries Needed**

### **Query 1: Restaurants with All NULL course_id (but courses exist)**
```sql
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT c.id) as courses_count,
    COUNT(DISTINCT d.id) as dishes_count,
    COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) as null_course_dishes
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON c.restaurant_id = r.id AND c.deleted_at IS NULL
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
GROUP BY r.id, r.name
HAVING COUNT(DISTINCT c.id) > 0 
    AND COUNT(DISTINCT d.id) FILTER (WHERE d.course_id IS NULL) = COUNT(DISTINCT d.id)
    AND COUNT(DISTINCT d.id) > 0;
```

### **Query 2: Restaurants with Excessive Modifiers**
```sql
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT d.id) as dishes_count,
    COUNT(DISTINCT dm.id) as total_modifiers,
    ROUND(COUNT(DISTINCT dm.id)::NUMERIC / NULLIF(COUNT(DISTINCT d.id), 0), 2) as avg_modifiers_per_dish
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
GROUP BY r.id, r.name
HAVING COUNT(DISTINCT d.id) > 0
    AND ROUND(COUNT(DISTINCT dm.id)::NUMERIC / NULLIF(COUNT(DISTINCT d.id), 0), 2) > 100  -- > 100 modifiers per dish
ORDER BY avg_modifiers_per_dish DESC;
```

### **Query 3: Restaurants with Zero Modifier Groups**
```sql
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT d.id) as dishes_count,
    COUNT(DISTINCT mg.id) as modifier_groups_count,
    COUNT(DISTINCT dm.id) as modifiers_count
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.dishes d ON d.restaurant_id = r.id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.modifier_groups mg ON mg.dish_id = d.id
LEFT JOIN menuca_v3.dish_modifiers dm ON dm.modifier_group_id = mg.id
GROUP BY r.id, r.name
HAVING COUNT(DISTINCT d.id) > 0
    AND COUNT(DISTINCT mg.id) = 0
    AND COUNT(DISTINCT dm.id) > 0  -- Has modifiers but no groups
ORDER BY modifiers_count DESC;
```

---

## 📊 **Lessons Learned**

### **What Went Wrong:**

1. **Aggregate Analysis Masked Restaurant-Specific Issues**
   - Overall statistics looked fine (7,266 NULL course_id is "valid")
   - But didn't catch restaurants where ALL dishes are NULL

2. **Schema Verification ≠ Data Quality**
   - FK integrity verified (no orphaned records)
   - But didn't verify business logic (dishes assigned to courses)

3. **No Restaurant-Level Pattern Detection**
   - Checked general patterns
   - But didn't detect systematic issues per restaurant

### **What Should Be Done:**

1. **Add Restaurant-Level Audits** ✅
   - Run queries per restaurant, not just aggregate
   - Detect systematic patterns (ALL dishes have issue)

2. **Business Logic Validation** ✅
   - Verify modifier assignments make sense
   - Verify dishes assigned to appropriate courses
   - Verify modifier group structure exists

3. **Sample Restaurant Verification** ✅
   - Pick sample restaurants from each category
   - Verify complete data structure
   - Use samples to detect migration issues

---

## ✅ **Conclusion**

**Status:** 🔴 **RESTAURANT-SPECIFIC ISSUES DISCOVERED**

**Root Cause:** Refactoring focused on schema and aggregate statistics, but missed restaurant-level systematic issues.

**Impact:** Some restaurants have broken menu structures, excessive modifiers, and illogical assignments.

**Action Required:** 
1. Create restaurant-level audit queries
2. Fix Capri Pizza (restaurant_id: 977) as priority
3. Identify and fix other affected restaurants
4. Add ongoing restaurant-level validation

---

**Report Generated:** October 31, 2025  
**Issue Found By:** Santiago  
**Analysis By:** Cursor AI Assistant  
**Status:** 🔴 **ACTION REQUIRED**




