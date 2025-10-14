# How the `mazen_milanos` Template Works
## Plain English Explanation

---

## The Business Model

**What is this?**
A **gross-based** revenue-sharing agreement where commission is calculated on the total order amount (including all fees), then split between the vendor and Menu.ca.

**Key Difference from `percent_commission`:**
- `percent_commission` = **NET basis** (calculates on restaurant's net sales)
- `mazen_milanos` = **GROSS basis** (calculates on customer's total payment including fees)

**Who gets paid?**
1. **The Restaurant** - Gets most of the order total
2. **Menu.ca Platform** - Gets a fixed $80 fee + half of collection
3. **The Vendor** (Mazen's group) - Gets 30% of total upfront

---

## Step-by-Step Calculation

Let's use a **real example**:

### Given Information:
- **Order Total**: $10,000 (total customer payments for the period)
- **Restaurant Convenience Fee**: 2.00 (multiplier, typically 2x or 200%)
- **Menu.ca Fixed Share**: $80 (platform's fixed fee per period)

---

### **STEP 1: Calculate Vendor's 30% Share**

The vendor gets 30% of the gross total upfront:

```
$10,000 × 30% = $3,000
```

**Result**: Vendor receives **$3,000** (30% of gross).

💡 **In real terms**: The vendor gets a fixed 30% of all customer payments, regardless of fees.

---

### **STEP 2: Calculate the Collection Amount**

The "collection" is the total convenience fees charged:

```
$10,000 × 2.00 = $20,000
```

**Result**: Total collection = **$20,000**

💡 **In real terms**: If the convenience fee multiplier is 2.00, the collection is 2× the order total.

---

### **STEP 3: Calculate Menu.ca's Share**

Menu.ca gets half of what's left after vendor's 30% and fixed fee:

```
Formula: ($collection - $forVendor - $fixedFee) ÷ 2

$20,000 - $3,000 - $80 = $16,920
$16,920 ÷ 2 = $8,460
```

**Result**: Menu.ca receives **$8,460**

💡 **In real terms**: After vendor takes 30% and fixed $80 is deducted, Menu.ca gets half of the remainder.

---

## Final Distribution

From the original **$10,000 order total** with **$20,000 collection**:

| Party | Amount | Calculation | Percentage of Total |
|-------|--------|-------------|---------------------|
| **Vendor (Mazen)** | $3,000 | 30% of $10,000 | 30% |
| **Menu.ca** | $8,540 | $80 fixed + $8,460 share | 85.4% |
| **Total Distributed** | $11,540 | | 115.4% of order |

⚠️ **Note**: Total exceeds order amount because collection is 2× (convenience fees from customers cover this).

---

## Visual Breakdown

```
Order Total: $10,000
    ↓
Calculate Collection: $10,000 × 2.00 = $20,000
    ↓
    ├─ Vendor (30%): $10,000 × 0.30 = $3,000 ✅
    └─ Remaining for Menu.ca calculation:
           $20,000 (collection)
           - $3,000 (vendor)
           - $80 (fixed)
           = $16,920
           ↓ (÷ 2)
           Menu.ca: $8,460 ✅

FINAL:
- Vendor (Mazen): $3,000
- Menu.ca: $80 + $8,460 = $8,540
```

---

## Real-World Examples

### Example 1: Small Restaurant (Lower Sales)

**Order Total**: $5,000
**Convenience Fee Multiplier**: 2.00
**Fixed Fee**: $80

```
Step 1: $5,000 × 30% = $1,500 (vendor)
Step 2: $5,000 × 2.00 = $10,000 (collection)
Step 3: ($10,000 - $1,500 - $80) ÷ 2 = $8,420 ÷ 2 = $4,210 (Menu.ca share)
```

**Distribution**:
- Vendor (Mazen): $1,500
- Menu.ca: $80 + $4,210 = $4,290

---

### Example 2: Large Restaurant (Higher Sales)

**Order Total**: $50,000
**Convenience Fee Multiplier**: 2.00
**Fixed Fee**: $80

```
Step 1: $50,000 × 30% = $15,000 (vendor)
Step 2: $50,000 × 2.00 = $100,000 (collection)
Step 3: ($100,000 - $15,000 - $80) ÷ 2 = $84,920 ÷ 2 = $42,460 (Menu.ca share)
```

**Distribution**:
- Vendor (Mazen): $15,000
- Menu.ca: $80 + $42,460 = $42,540

---

### Example 3: Different Convenience Fee

**Order Total**: $10,000
**Convenience Fee Multiplier**: 1.50
**Fixed Fee**: $80

```
Step 1: $10,000 × 30% = $3,000 (vendor)
Step 2: $10,000 × 1.50 = $15,000 (collection)
Step 3: ($15,000 - $3,000 - $80) ÷ 2 = $11,920 ÷ 2 = $5,960 (Menu.ca share)
```

**Distribution**:
- Vendor (Mazen): $3,000
- Menu.ca: $80 + $5,960 = $6,040

---

## Key Variables

The calculation uses these inputs:

1. **`total`**: Total order amount for the reporting period
   - Example: $10,000

2. **`restaurant_convenience_fee`**: The convenience fee multiplier
   - Example: 2.00 (means 2× or 200%)
   - This varies by restaurant agreement

3. **`menuottawa_share`**: Fixed fee that Menu.ca always takes first
   - Always: $80.00
   - This is hardcoded and doesn't change

4. **`vendor_id`**: Which vendor is managing this restaurant
   - Example: Mazen's vendor ID

5. **`restaurant_id`**: Which restaurant this calculation is for
   - Example: 1171 (Pho Dau Bo - Kitchener)

---

## The Math Formula

If you want to calculate it in one go:

```
Vendor Amount = Total × 0.30

Collection = Total × Convenience Fee Multiplier

Menu.ca Share = (Collection - Vendor Amount - Fixed Fee) ÷ 2

Menu.ca Total = Fixed Fee + Menu.ca Share
```

Or in a single formula:

```
Vendor = Total × 0.30
Menu.ca = $80 + ((Total × ConvenienceFee - (Total × 0.30) - $80) ÷ 2)
```

---

## Why This Structure?

This split structure represents:

1. **Fixed Vendor Share (30%)**: Simple, predictable share for the vendor based on gross sales

2. **Collection-Based Split**: Menu.ca's share depends on the convenience fees collected from customers

3. **Fixed Fee ($80)**: Covers Menu.ca's basic operational costs

4. **Remaining Split**: Half of what's left after vendor's 30% and fixed fee goes to Menu.ca

---

## Important Notes

### ✅ What Changes Between Restaurants:
- **Order totals** vary (sales performance)
- **Convenience fee multipliers** can be different (1.5×, 2.0×, etc.)

### 🔒 What Stays the Same:
- **Fixed fee**: Always $80
- **Vendor percentage**: Always 30%
- **Menu.ca split**: Always half of (collection - vendor - fixed)

### 🧮 The Formula Never Changes:
No matter the restaurant or order size, the calculation steps are identical. Only the input numbers change.

---

## Comparison: `mazen_milanos` vs `percent_commission`

| Aspect | `mazen_milanos` | `percent_commission` |
|--------|-----------------|---------------------|
| **Basis** | Gross (total with fees) | Net (commission only) |
| **Vendor Share** | 30% of total ($3,000 on $10k) | 46% of commission ($460 on $10k) |
| **Commission Calc** | Based on collection (fees) | Based on restaurant commission % |
| **Complexity** | 3 steps | 3 steps |
| **Fee Multiplier** | Variable (e.g., 2.0×) | N/A |

**Example Comparison** ($10,000 order, 10% commission):

| Template | Vendor Gets | Menu.ca Gets |
|----------|-------------|--------------|
| `percent_commission` | $460 | $540 |
| `mazen_milanos` | $3,000 | $8,540 |

⚠️ **MUCH higher vendor share** with `mazen_milanos` due to gross-based calculation!

---

## V2 Code (INSECURE)

```php
// Stored in database as text:
$forVendor = ##total## * .3;
$collection = ##total## * ##restaurant_convenience_fee##;
$forMenuOttawa = ($collection - $forVendor - ##menuottawa_share##) / 2;

// Then executed with eval() - DANGEROUS!
eval($breakdown);
```

## V3 Code (SECURE)

```typescript
// Hard-coded, type-safe function:
function calculateMazenMilanos(data: CommissionInput): CommissionResult {
  const forVendor = data.total * 0.3
  const collection = data.total * (data.restaurant_convenience_fee ?? 2.00)
  const forMenuca = (collection - forVendor - data.menuottawa_share) / 2
  
  return { 
    for_vendor: forVendor, 
    for_menuca: forMenuca 
  }
}
```

**Same math, but secure and type-safe!**

---

## Which Restaurants Use This?

Based on your confirmation, this template is **ACTIVE** and used by certain restaurants (to be determined after re-export of CSV data without filters).

---

## Summary in One Sentence

**Take 30% of gross sales for the vendor, calculate collection based on convenience fee multiplier, subtract vendor's 30% and $80 fixed, then split the remainder in half for Menu.ca.**

That's it! 🎯

