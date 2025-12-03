# V1 Delivery Fees Extraction Report

**Generated:** 2025-12-03 09:54:03

## Summary

| Metric | Value |
|--------|-------|
| Restaurants in Dump | 40 |
| Restaurants Mapped | 40 |
| Restaurants with Fees | 36 |
| Total UPDATE Statements | 79 |

## Extracted Fees

| V1 ID | V3 ID | Restaurant | Area 1 | Area 2 | Area 3+ |
|-------|-------|------------|--------|--------|---------|
| 203 | 87 | Champa Thai Cuisine | $3.00 | - | - |
| 225 | 106 | Restaurant Le Choix | $3 | $4 | - |
| 231 | 1012 | Papa Pizza Des Flandres | $3 | - | - |
| 346 | 1013 | Papa Pizza Maloney | $3.50 | - | - |
| 364 | 984 | La Famiglia on the Danforth | $5 | - | - |
| 387 | 245 | Orchid Sushi | $3 | - | - |
| 511 | 1017 | Sushi Express Chambly | $2 | $3 | - |
| 694 | 941 | Ting's Kitchen | $2.99 | - | - |
| 789 | 569 | Milano | $2.50 | $2.50 | - |
| 805 | 584 | Crispy's | $2.99 | - | - |
| 807 | 586 | Milano | $1.99 | $4.99 | $6.99, $9.99 |
| 818 | 596 | Sushi Fleury | $2.5 | $3.5 | - |
| 824 | 601 | Milano | $2.50 | $5.00 | - |
| 856 | 630 | Asia Garden Ottawa | $3.50 | $3.50 | - |
| 863 | 636 | Joes Family Pizzeria | $4.99 | $6.99 | - |
| 865 | 638 | Digby's Restaurant | $1.50 | - | - |
| 874 | 646 | JC Royal Thai Cuisine | $5<40,0>40 | - | - |
| 889 | 660 | Milano | $0 | - | - |
| 913 | 680 | Milano | $2.99 | $3.99 | $4.99, $3.99, $4.99 |
| 914 | 681 | Oka's Hull | $2.00 | $3.00 | - |
| 937 | 701 | Milano | $0.00 | $5.00 | - |
| 953 | 716 | PizzaRama | $3.00 | $3.00 | - |
| 964 | 726 | Pizza Joanna | $2.50 | $4.00 | $5.00 |
| 968 | 730 | Friendly Restaurant and Pizzeria | $3.00 | $6.50 | $8.50 |
| 973 | 735 | Amicci Pizza | $2.50 | $3.00 | - |
| 1042 | 798 | Kabylie Pizza | $4.00 | $4.50 | - |
| 1045 | 801 | Nachos Loco Gatineau | $2.99 | $3.99 | $4.99, $3.99, $4.99 |
| 1046 | 1015 | Poutinerie Québecurds Gatineau | $2.99 | $3.99 | $4.99, $3.99, $4.99 |
| 1050 | 806 | Crispy's Bank Street | $2.99 | - | - |
| 1060 | 816 | Dépanneur Généreux | $4.99 | $7 | - |
| 1062 | 818 | Milano | $2.99 | $6.00 | $7.00, $9.00, $13, $16, $28, $32, $40 |
| 1063 | 819 | Milano | $2.99 | $5.99 | - |
| 1066 | 822 | Papa Burger Maloney | $3.00 | - | - |
| 1080 | 833 | All Out Burger | $2.50 | $5.00 | - |
| 1092 | 845 | Mykonos Greek Grill | $2.99 | $5.99 | - |
| 1093 | 846 | Mykonos Greek Grill | $2.99 | $5.99 | - |

## Files Generated

| File | Description |
|------|-------------|
| `id_mappings.json` | V1 to V3 ID mappings |
| `extracted_fees.json` | Parsed fee data |
| `fees_migration.sql` | UPDATE statements |

## Next Steps

1. Review the extracted data in `extracted_fees.json`
2. Execute `fees_migration.sql` against menuca_v3 database
3. Verify delivery_fee values were updated correctly