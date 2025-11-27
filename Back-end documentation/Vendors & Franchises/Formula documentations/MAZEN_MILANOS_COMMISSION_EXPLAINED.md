# How the `mazen_milanos` Template Works
## Plain English Explanation

---

## The Business Model

**What is this?**
A **commission-based** revenue-sharing agreement where a 10% commission is calculated on order totals, then distributed in a specific priority order among three parties.

**Key Difference from `percent_commission`:**
- `percent_commission` = Simple 50/50 split after $80 fixed fee
- `mazen_milanos` = 30% vendor priority, then $80 fixed, then 50/50 split of remainder

**Who gets paid (in order)?**
1. **Vendor (Mazen)** - Gets 30% of the commission FIRST
2. **Menu.ca Platform** - Takes fixed $80 fee SECOND
3. **Menu Ottawa & Menu.ca** - Split the remaining commission 50/50

---

## Step-by-Step Calculation

Let's use a **real example** from a typical order:

### Given Information:
- **Order Total**: $10,000 (total sales for the period)
- **Commission Rate**: 10% (varies by restaurant - can be 8%, 10%, 12%, 15%, etc.)
- **Menu.ca Fixed Share**: $80 (platform's fixed fee)

---

### **STEP 1: Calculate Total Commission**

First, calculate 10% commission on the order total:

```
$10,000 × 10% = $1,000
```

**Result**: Total commission to distribute = **$1,000**

💡 **In real terms**: From $10,000 in sales, $1,000 is owed as commission.

---

### **STEP 2: Pay Vendor (Mazen) 30% of Commission**

Mazen gets 30% of the commission amount first:

```
$1,000 × 30% = $300
```

**Result**: Vendor (Mazen) receives **$300** (30% of commission, paid first)

💡 **In real terms**: Before anyone else gets paid, Mazen takes $300 off the top of the commission.

---

### **STEP 3: Calculate Remaining Commission**

Subtract Mazen's share from the total commission:

```
$1,000 - $300 = $700
```

**Result**: **$700** remains to be distributed

💡 **In real terms**: After Mazen's cut, $700 of commission is left.

---

### **STEP 4: Pay Menu.ca Fixed Fee**

Menu.ca takes their fixed $80 operational fee:

```
$700 - $80 = $620
```

**Result**: **$620** remains after fixed fee

💡 **In real terms**: Menu.ca takes their guaranteed $80, leaving $620 to split.

---

### **STEP 5: Split Remainder 50/50**

The remaining $620 is split equally between Menu Ottawa and Menu.ca:

```
$620 ÷ 2 = $310 (Menu Ottawa)
$620 ÷ 2 = $310 (Menu.ca)
```

**Result**: 
- **Menu Ottawa receives**: $310
- **Menu.ca receives**: $310

💡 **In real terms**: The final $620 is split evenly between the two remaining parties.

---

## Final Distribution

From the original **$1,000 commission** (10% of $10,000):

| Party | Amount | Calculation | Percentage of Commission |
|-------|--------|-------------|-------------------------|
| **Vendor (Mazen)** | $300 | 30% of $1,000 (paid 1st) | 30% |
| **Menu Ottawa** | $310 | Half of ($1,000 - $300 - $80) | 31% |
| **Menu.ca Total** | **$390** | **$80 fixed + $310 share** | **39%** |
| **Total** | $1,000 | | 100% |

✅ **Important**: Menu.ca receives $390 which includes BOTH the $80 fixed fee AND their $310 share of the split.

---

## Visual Breakdown

```
Order Total: $10,000
    ↓ (10% commission)
Total Commission: $1,000
    ↓
    ├─ FIRST: Vendor (Mazen) 30%: $1,000 × 0.3 = $300 ✅
    └─ Remaining: $1,000 - $300 = $700
           ↓
           ├─ SECOND: Menu.ca Fixed Fee: $80 ✅
           └─ Remaining: $700 - $80 = $620
                  ↓ (split 50/50)
                  ├─ Menu Ottawa: $620 ÷ 2 = $310 ✅
                  └─ Menu.ca: $620 ÷ 2 = $310 ✅

FINAL:
- Vendor (Mazen) gets: $300
- Menu Ottawa gets: $310
- Menu.ca gets: $390 (includes $80 fixed + $310 share) ✅
```

---

## Real-World Examples

### Example 1: Small Restaurant (Lower Sales)

**Order Total**: $5,000
**Commission Rate**: 10%

```
Step 1: $5,000 × 10% = $500 (total commission)
Step 2: $500 × 30% = $150 (Mazen gets 30%)
Step 3: $500 - $150 = $350 (remaining)
Step 4: $350 - $80 = $270 (after fixed fee)
Step 5: $270 ÷ 2 = $135 (Menu Ottawa)
        $270 ÷ 2 = $135 (Menu.ca)
```

**Distribution**:
- Vendor (Mazen): $150
- Menu Ottawa: $135
- Menu.ca: $80 + $135 = $215

---

### Example 2: Large Restaurant (Higher Sales)

**Order Total**: $50,000
**Commission Rate**: 10%

```
Step 1: $50,000 × 10% = $5,000 (total commission)
Step 2: $5,000 × 30% = $1,500 (Mazen gets 30%)
Step 3: $5,000 - $1,500 = $3,500 (remaining)
Step 4: $3,500 - $80 = $3,420 (after fixed fee)
Step 5: $3,420 ÷ 2 = $1,710 (Menu Ottawa)
        $3,420 ÷ 2 = $1,710 (Menu.ca)
```

**Distribution**:
- Vendor (Mazen): $1,500
- Menu Ottawa: $1,710
- Menu.ca: $80 + $1,710 = $1,790

---

### Example 3: Medium Restaurant

**Order Total**: $25,000
**Commission Rate**: 10%

```
Step 1: $25,000 × 10% = $2,500 (total commission)
Step 2: $2,500 × 30% = $750 (Mazen gets 30%)
Step 3: $2,500 - $750 = $1,750 (remaining)
Step 4: $1,750 - $80 = $1,670 (after fixed fee)
Step 5: $1,670 ÷ 2 = $835 (Menu Ottawa)
        $1,670 ÷ 2 = $835 (Menu.ca)
```

**Distribution**:
- Vendor (Mazen): $750
- Menu Ottawa: $835
- Menu.ca: $80 + $835 = $915

---

## Key Variables

The calculation uses these inputs:

1. **`total`**: Total order amount for the reporting period
   - Example: $10,000
   - This is the total sales the restaurant made

2. **`restaurant_commission`**: The commission percentage (VARIABLE per restaurant)
   - Example: 10 (means 10%)
   - Can be 8%, 10%, 12%, 15%, or any agreed-upon rate
   - Set individually per restaurant in their contract

3. **`vendor_commission_priority`**: Vendor's share of commission (FIXED at 30%)
   - Always: 30%
   - Mazen always gets 30% of the commission first

4. **`menuottawa_share`**: Fixed fee that Menu.ca takes (FIXED at $80)
   - Always: $80.00
   - This is hardcoded and doesn't change

5. **`vendor_id`**: Which vendor is managing this restaurant
   - Example: Mazen's vendor ID

6. **`restaurant_id`**: Which restaurant this calculation is for
   - Example: 1171 (Pho Dau Bo Restaurant - Kitchener)

---

## The Math Formula

If you want to calculate it in one go:

```
Total Commission = Order Total × 0.10

Vendor (Mazen) Amount = Total Commission × 0.30

After Vendor = Total Commission - Vendor Amount

After Fixed Fee = After Vendor - $80

Menu Ottawa Amount = After Fixed Fee ÷ 2

Menu.ca Amount = After Fixed Fee ÷ 2

Menu.ca Total = $80 + Menu.ca Amount
```

Or in a single formula:

```
Commission = Total × 0.10
Mazen = Commission × 0.30
MenuOttawa = ((Commission - (Commission × 0.30)) - $80) ÷ 2
Menu.ca = $80 + ((Commission - (Commission × 0.30)) - $80) ÷ 2
```

---

## Why This Structure?

This split structure represents a **priority waterfall payment**:

1. **Priority 1 - Vendor (30%)**: 
   - Mazen gets paid FIRST
   - Ensures vendor gets their guaranteed share
   - Based on commission, not gross sales
   - Predictable and fair

2. **Priority 2 - Fixed Fee ($80)**: 
   - Menu.ca's operational costs covered
   - Hosting, payment processing, customer support
   - Guaranteed minimum platform revenue

3. **Priority 3 - Equal Split (50/50)**: 
   - Remaining commission split fairly
   - Menu Ottawa compensated for vendor management
   - Menu.ca gets additional profit beyond fixed fee

---

## Important Notes

### ✅ What Changes Between Restaurants:
- **Order totals** vary (sales performance)
- **Commission rate** varies (8%, 10%, 12%, 15%, etc. - set per restaurant contract)

### 🔒 What Stays the Same:
- **Vendor priority**: Always 30% of commission (paid first)
- **Fixed fee**: Always $80 (paid second)
- **Final split**: Always 50/50 between Menu Ottawa and Menu.ca

### 🧮 The Formula Never Changes:
No matter the restaurant or order size, the calculation steps are identical. Only the order total and commission percentage change.

---

## Comparison: `mazen_milanos` vs `percent_commission`

Using the same **$10,000 in sales**:

| Aspect | `mazen_milanos` | `percent_commission` |
|--------|-----------------|---------------------|
| **Commission Calculated** | $1,000 (10%) | $1,000 (10%) |
| **Vendor (Mazen) Gets** | $300 (30% first) | $0 (no Mazen in this template) |
| **Menu Ottawa Gets** | $310 (50% of remainder) | $460 (50% of remainder) |
| **Menu.ca Gets** | $390 ($80 + $310) | $540 ($80 + $460) |
| **Total Distributed** | $1,000 | $1,000 |
| **Key Difference** | 3-way split with vendor priority | 2-way split (no vendor priority) |

### Why the Difference?

**`mazen_milanos`**:
- Includes a third party (Mazen) who gets 30% priority
- Remaining pool ($700) is smaller after Mazen's cut
- Menu Ottawa and Menu.ca split the smaller remainder

**`percent_commission`**:
- Only two parties splitting
- No vendor priority payment
- Larger pool ($920) to split after fixed fee

---

## Comparison with V2's Insecure Method

### V2 (Old - INSECURE - WRONG FORMULA):
```php
// INCORRECT V2 code (stored in database):
$forVendor = ##total## * .3;  // WRONG: 30% of TOTAL, not commission!
$collection = ##total## * ##restaurant_convenience_fee##;
$forMenuOttawa = ($collection - $forVendor - ##menuottawa_share##) / 2;

// Then executed with eval() - DANGEROUS!
eval($breakdown);
```

### V2 (CORRECTED FORMULA):
```php
// CORRECT formula:
$totalCommission = ##total## * (##restaurant_commission## / 100);  // Variable % commission
$forVendor = $totalCommission * 0.3;  // 30% of COMMISSION
$afterVendorShare = $totalCommission - $forVendor;
$afterFixedFee = $afterVendorShare - ##menuottawa_share##;
$forMenuOttawa = $afterFixedFee / 2;
$forMenuca = $afterFixedFee / 2;
```

### V3 (New - SECURE):
```typescript
// Hard-coded, type-safe function:
function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  const totalCommission = data.total * (data.restaurant_commission / 100)  // Variable %
  const forVendor = totalCommission * 0.3  // Vendor gets 30% of commission
  const afterVendorShare = totalCommission - forVendor
  const afterFixedFee = afterVendorShare - data.menuottawa_share
  const forMenuOttawa = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share ✅
  
  return { 
    for_vendor: Math.round(forVendor * 100) / 100,
    for_menu_ottawa: Math.round(forMenuOttawa * 100) / 100,
    for_menuca: Math.round(forMenucaTotal * 100) / 100
  }
}
```

**Same CORRECT math, but secure and type-safe!**

---

## Quick Reference

### Who Are the Players?

1. **Menu.ca (the platform)**: 
   - Your company
   - Provides the ordering system
   - Gets $80 fixed + 50% of final remainder

2. **Vendor (Mazen)**:
   - Third-party partner
   - Gets 30% of commission FIRST (priority payment)
   - Manages specific restaurant(s)

3. **Menu Ottawa**:
   - Vendor management company
   - Gets 50% of final remainder (after Mazen and fixed fee)
   - Provides operational support

4. **The Restaurant**:
   - Pays the 10% commission
   - Keeps the rest of their sales ($9,000 out of $10,000)

### Real Restaurant Example:

**Pho Dau Bo Restaurant - Kitchener** (restaurant ID: 1171)
- Uses: `mazen_milanos` template
- If they made $20,000 in sales at 10% commission:
  - Total commission: $2,000
  - Vendor (Mazen) gets: $600 (30% of $2,000)
  - Remaining: $1,400
  - After fixed fee: $1,320 ($1,400 - $80)
  - Menu Ottawa gets: $660 (50% of $1,320)
  - Menu.ca gets: $740 ($80 + $660)

---

## Summary in One Sentence

**Take 10% commission, give Mazen 30% of that commission first, then Menu.ca takes $80, then split what's left 50/50 between Menu Ottawa and Menu.ca.**

That's it! 🎯

---

## Why This Formula Exists

This template is used for:

1. **Strategic Partnerships**: Mazen brings valuable business, gets priority payment
2. **Fair Distribution**: Everyone gets a clear, predictable share
3. **Vendor Incentive**: 30% priority ensures vendor commitment
4. **Operational Coverage**: $80 fixed fee covers platform costs
5. **Equal Final Split**: Menu Ottawa and Menu.ca share remaining profit fairly

**Business Strategy**: The 30% vendor priority recognizes Mazen's strategic importance while maintaining fair distribution among all parties.

---

## Common Questions

**Q: Why does Mazen get paid first?**
A: Priority payment ensures vendor commitment and recognizes their strategic value.

**Q: Why 30% and not 50%?**
A: 30% of commission (not total sales) is substantial but leaves enough for platform operations and Menu Ottawa.

**Q: What if commission is less than $380?**
A: Math still works, but Menu Ottawa/Menu.ca shares get very small. Example:
- Commission: $380
- Mazen: $114 (30%)
- After Mazen: $266
- After fixed: $186
- Each gets: $93

**Q: Can the commission percentage change?**
A: Yes! Each restaurant has their own commission percentage set in their contract (stored in the database). The 30% vendor priority, $80 fixed fee, and 50/50 split are the constants that never change.

**Q: What if two restaurants have different commission rates?**
A: That's expected! Restaurant A might have 10% commission, Restaurant B might have 15%. The calculation uses each restaurant's specific rate:
- Restaurant A ($10k sales, 10%): $1,000 commission → Mazen gets $300
- Restaurant B ($10k sales, 15%): $1,500 commission → Mazen gets $450
