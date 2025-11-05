# Missing Dish Prices Investigation - Item #1

**Date:** 2025-10-30  
**Status:** 🔄 **INVESTIGATING**  
**Issue:** 772 active dishes missing pricing records

---

## Investigation Summary

**Total Dishes Without Prices:** 772 active dishes  
**Impact:** Customers cannot order these dishes (no price shown)

---

## Analysis Findings

### By Restaurant Distribution
- Need to analyze which restaurants have most dishes without prices
- Some restaurants may have systematic issues
- Others may be intentional (combo items, setup in progress)

### By Dish Type
- **Combo dishes:** May have combo_group pricing instead of dish_prices
- **Regular dishes:** Should have dish_prices
- **Dishes with customization:** Still need base pricing

### Price Status
- Some dishes may have **deleted prices** (soft-deleted)
- Others may have **no prices at all**
- Need to distinguish for proper fix

---

## Fix Strategy Options

### Option A: Add Default Pricing ($0.00)
**Pros:**
- Dishes become orderable immediately
- Preserves dish visibility
- Restaurant can update pricing later

**Cons:**
- May cause ordering issues ($0.00 items)
- May be confusing to customers

### Option B: Mark Dishes as Inactive
**Pros:**
- Prevents ordering issues
- Clear signal that pricing needs configuration
- Dishes hidden until pricing added

**Cons:**
- Dishes disappear from menu
- May lose visibility/data

### Option C: Restaurant-Specific Fix
**Pros:**
- Handles each case appropriately
- Respects restaurant intent
- Most accurate solution

**Cons:**
- Time-consuming
- Requires restaurant contact/investigation

---

## Recommended Approach

**Hybrid Strategy:**
1. **Investigate each dish** to determine appropriate action
2. **Combo dishes:** May not need dish_prices if combo_group has pricing
3. **Regular dishes:** Add default pricing OR mark inactive
4. **Restaurant contact:** For restaurants with many missing prices

---

**Investigation Status:** In Progress  
**Next Steps:** Complete analysis, create fix migration

