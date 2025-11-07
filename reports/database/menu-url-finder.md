# Menu URL Finder - Pattern Analysis & Batch Search

## URL Patterns Identified

From completed audits, here are the URL patterns we've found:

### Pattern 1: Restaurant name + location + .menu.ca
- `https://orchidsushiottawa.menu.ca/?p=menu`
- `https://mukutorleans.menu.ca/?p=menu`
- `https://newhongkongchinese.ca/?p=menu` (note: .ca not .menu.ca)

### Pattern 2: Mobile subdomain + restaurant name + location + .com
- `https://m.ogilviepizzaottawa.com/menu`

### Pattern 3: Address prefix + restaurant name + .ca
- `https://169york.ohmygrill.ca/?p=menu`

### Pattern 4: Restaurant name (simplified) + .ca
- `https://palermopizzeria.ca/?p=menu`
- `https://no1chinesefoodottawa.com/?p=menu`

### Pattern 5: Restaurant name + ottawa + .com
- `https://no1chinesefoodottawa.com/?p=menu`

## Common Variations
- `.menu.ca/?p=menu` - Most common
- `.ca/?p=menu` - Common
- `.com/?p=menu` - Less common
- `/menu` (no query param) - Less common
- `m.{name}.com/menu` - Mobile subdomain

## URL Construction Strategy

For each restaurant, try these patterns in order:

1. `{restaurant-name-slug}ottawa.menu.ca/?p=menu`
2. `{restaurant-name-slug}.menu.ca/?p=menu`
3. `{restaurant-name-slug}.ca/?p=menu`
4. `{restaurant-name-slug}ottawa.ca/?p=menu`
5. `m.{restaurant-name-slug}ottawa.com/menu`
6. `{restaurant-name-slug}.com/?p=menu`

### Name Normalization Rules:
- Remove: "Pizza", "Restaurant", "Take Out", "&", "and"
- Replace: " " → "", "'" → "", "-" → ""
- Lowercase everything
- Remove accents: é→e, è→e, à→a, etc.

## Remaining Restaurants to Find URLs For

### Brian's Section (B) - Next 20:
1. Papa Burger 22, rue des Flandres
2. Papa Burger Maloney 253 Boul Maloney E
3. Papa Grecque Cantley 393 Montée de la Source
4. Papa Grecque Maloney 253 Boul Maloney
5. Papa Grecque des Flandres 22 rue des flandres
6. Papa Joe's Fried Chicken - Downtown 527 Bronson Ave
7. Papa Joe's Pizza - Downtown 527 Bronson Ave
8. Papa Pizza - Hull 574, boul Saint-Joseph
9. Papa Pizza Cantley 393 Montée de la Source
10. Papa Pizza Chem. de Masson 855 Chem. de Masson
11. Papa Pizza Des Flandres 22, rue des Flandres
12. Papa Pizza Maloney 253, boul Maloney
13. Papa Pizza Val-Des-Monts 1797, rte du Carrefour
14. Parea Authentic Greek 1675 Tenth Line Road
15. Parea Express 540 Montréal Road
16. Patate Lou Lou 29 Chemin Eardley
17. Pho Bo Ga King - Somerset 778 Somerset St W
18. Pho Dau Bo Restaurant - Kitchener 685 Fischer Hallman Rd, Unit G
19. Pizza Bravo 108, boul Lorrain
20. Pizza Joanna 229 Boulevard Saint-René Ouest

## Batch Search Strategy

I can:
1. **Query database for slugs** - Check if restaurants have URL slugs stored
2. **Generate candidate URLs** - Create likely URLs based on patterns
3. **Web search batches** - Search for 5-10 restaurants at a time
4. **Create URL mapping file** - Document found URLs for quick reference

Would you like me to:
- A) Start batch searching for menu URLs now?
- B) First check database for existing slug/URL data?
- C) Create a script to generate candidate URLs for manual verification?

