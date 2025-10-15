# How the `percent_commission` Template Works
## Plain English Explanation

---

## The Business Model

**What is this?**
A revenue-sharing agreement where Menu.ca (the platform) splits commission earnings with a vendor (a third-party company that manages restaurants).

**Who gets paid?**
1. **The Restaurant** - Gets most of the order total (keeps their revenue)
2. **Menu.ca Platform** - Gets a fixed $80 fee + half of remaining commission
3. **The Vendor** (Menu Ottawa) - Gets half of remaining commission for managing the restaurant

---

## Step-by-Step Calculation

Let's use a **real example** from a typical order:

### Given Information:
- **Order Total**: $10,000 (total sales for the period)
- **Restaurant Commission Rate**: 10% (how much the restaurant pays to the platform)
- **Menu.ca Fixed Share**: $80 (platform's fixed fee per period)

---

### **STEP 1: Calculate the Total Commission**

The restaurant pays 10% of their sales as commission:

```
$10,000 × 10% = $1,000
```

**Result**: The restaurant owes $1,000 in commission.

💡 **In real terms**: If a restaurant made $10,000 in sales, they owe $1,000 to be split between the platform and vendor.

---

### **STEP 2: Subtract Menu.ca's Fixed Fee**

Menu.ca takes a fixed $80 first (for operational costs):

```
$1,000 - $80 = $920
```

**Result**: After Menu.ca takes their $80 fixed fee, **$920 remains** to be split.

💡 **In real terms**: Menu.ca always gets $80 off the top, leaving $920 to divide between vendor and another party.

---

### **STEP 3: Split What's Left in Half (50/50)**

The remaining $920 is split 50/50:

```
$920 ÷ 2 = $460
```

**Result**: 
- **First half ($460)** → Goes to the **Vendor** (Menu Ottawa)
- **Second half ($460)** → Goes to **Menu.ca**

💡 **In real terms**: The vendor and Menu.ca split what's left equally after the fixed fee.

---

## Final Distribution

From the original **$1,000 commission**:

| Party | Amount | Calculation | Percentage of Commission |
|-------|--------|-------------|-------------------------|
| **Vendor (Menu Ottawa)** | $460 | Half of ($1,000 - $80) | 46% |
| **Menu.ca Total** | **$540** | **$80 fixed + $460 share** | **54%** |
| **Total** | $1,000 | | 100% |

✅ **Important**: Menu.ca receives $540 which includes BOTH the $80 fixed fee AND their $460 share of the split.

---

## Visual Breakdown

```
Order Total: $10,000
    ↓ (10% commission)
Total Commission: $1,000
    ↓
    ├─ Menu.ca Fixed Fee: $80
    └─ Remaining: $920
           ↓ (split 50/50)
           ├─ Vendor (Menu Ottawa): $460 ✅
           └─ Menu.ca: $460 ✅

FINAL:
- Vendor (Menu Ottawa) gets: $460
- Menu.ca gets: $540 (includes $80 fixed + $460 share) ✅
```

---

## Real-World Examples

### Example 1: Small Restaurant (Lower Sales)

**Order Total**: $5,000
**Commission Rate**: 10%

```
Step 1: $5,000 × 10% = $500 (total commission)
Step 2: $500 - $80 = $420 (after fixed fee)
Step 3: $420 ÷ 2 = $210 (vendor gets this)
        $420 ÷ 2 = $210 (Menu.ca gets this)
```

**Distribution**:
- Vendor (Menu Ottawa): $210
- Menu.ca: $80 + $210 = $290

---

### Example 2: Large Restaurant (Higher Sales)

**Order Total**: $50,000
**Commission Rate**: 10%

```
Step 1: $50,000 × 10% = $5,000 (total commission)
Step 2: $5,000 - $80 = $4,920 (after fixed fee)
Step 3: $4,920 ÷ 2 = $2,460 (vendor gets this)
        $4,920 ÷ 2 = $2,460 (Menu.ca gets this)
```

**Distribution**:
- Vendor (Menu Ottawa): $2,460
- Menu.ca: $80 + $2,460 = $2,540

---

### Example 3: Different Commission Rate

**Order Total**: $10,000
**Commission Rate**: 15% (higher rate)

```
Step 1: $10,000 × 15% = $1,500 (total commission)
Step 2: $1,500 - $80 = $1,420 (after fixed fee)
Step 3: $1,420 ÷ 2 = $710 (vendor gets this)
        $1,420 ÷ 2 = $710 (Menu.ca gets this)
```

**Distribution**:
- Vendor (Menu Ottawa): $710
- Menu.ca: $80 + $710 = $790

---

## Key Variables

The calculation uses these inputs:

1. **`total`**: Total order amount for the reporting period
   - Example: $10,000

2. **`restaurant_commission`**: The commission percentage the restaurant pays
   - Example: 10 (means 10%)
   - Different restaurants may have different rates (8%, 10%, 12%, etc.)

3. **`menuottawa_share`**: Fixed fee that Menu.ca always takes first
   - Always: $80.00
   - This is hardcoded and doesn't change

4. **`vendor_id`**: Which vendor is managing this restaurant
   - Example: 2 (Menu Ottawa)

5. **`restaurant_id`**: Which restaurant this calculation is for
   - Example: 1639 (River Pizza)

---

## The Math Formula

If you want to calculate it in one go:

```
Total Commission = Order Total × (Commission Rate ÷ 100)

After Fixed Fee = Total Commission - $80

Vendor Amount = After Fixed Fee ÷ 2

Menu.ca Amount = After Fixed Fee ÷ 2

Menu.ca Total = Fixed Fee + Menu.ca Amount
```

Or in a single formula:

```
Vendor = ((Order Total × Commission%) - $80) ÷ 2
Menu.ca = $80 + ((Order Total × Commission%) - $80) ÷ 2
```

---

## Why This Structure?

This split structure represents:

1. **Fixed Fee ($80)**: Covers Menu.ca's basic operational costs (hosting, payment processing, support)

2. **Vendor Share (46%)**: Rewards the vendor company for:
   - Managing the restaurant relationship
   - Providing customer support
   - Marketing and promotion
   - Technical integration

3. **Menu.ca Additional (46%)**: Platform's profit margin beyond fixed costs - equal split with vendor

---

## Important Notes

### ✅ What Changes Between Restaurants:
- **Order totals** vary (sales performance)
- **Commission rates** can be different (8%, 10%, 12%, 15%, etc.)

### 🔒 What Stays the Same:
- **Fixed fee**: Always $80
- **Split ratio**: Always 50/50 between vendor and Menu.ca
- **Who gets paid**: Always vendor (Menu Ottawa) and Menu.ca

### 🧮 The Formula Never Changes:
No matter the restaurant or order size, the calculation steps are identical. Only the input numbers change.

---

## Comparison with V2's Insecure Method

### V2 (Old - INSECURE):
```php
// Stored in database as text:
$tenPercent = ##total##*(##restaurant_commission## / 100);
$afterFixedFee = $tenPercent - ##menuottawa_share##;
$forVendor = $afterFixedFee / 2;
$forMenuca = $afterFixedFee / 2;

// Then executed with eval() - DANGEROUS!
eval($breakdown);
```

### V3 (New - SECURE):
```typescript
// Hard-coded, type-safe function:
function calculatePercentCommission(data: CommissionInput): CommissionResult {
  const totalCommission = data.total * (data.restaurant_commission / 100)
  const afterFixedFee = totalCommission - data.menuottawa_share
  const forVendor = afterFixedFee / 2
  const forMenucaShare = afterFixedFee / 2
  const forMenucaTotal = data.menuottawa_share + forMenucaShare  // $80 + share ✅
  
  return { for_vendor: forVendor, for_menuca: forMenucaTotal }
}
```

**Same math, but secure and type-safe!**

---

## Quick Reference

### Who Are the Players?

1. **Menu.ca (the platform)**: 
   - Your company
   - Provides the ordering system
   - Gets $80 fixed + a share

2. **Vendor (e.g., "Menu Ottawa")**:
   - Third-party company
   - Manages multiple restaurants on your behalf
   - Gets an equal share with Menu.ca (46%)

3. **The Restaurant**:
   - Pays the commission
   - Keeps the rest of their sales

### Real Restaurant Example from Your Data:

**River Pizza** (restaurant ID: 1639)
- Managed by: Vendor #2 (Menu Ottawa)
- Uses: `percent_commission` template
- If they made $20,000 in sales at 10% commission:
  - They pay: $2,000
  - Vendor (Menu Ottawa) gets: $960
  - Menu.ca gets: $1,040 ($80 fixed + $960)

---

## Summary in One Sentence

**Take 10% of sales, subtract $80 for Menu.ca, then split the rest 50/50 between the vendor (Menu Ottawa) and Menu.ca.**

That's it! Simple as that. 🎯

