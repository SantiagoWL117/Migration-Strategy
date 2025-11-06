# Restaurant Data Audit Report

**Generated:** November 5, 2025 - 5:40 PM EST
**Database:** menuca_v3 (Supabase)
**Total Active Restaurants Audited:** 179

---

## Summary of Issues Found

- **Missing restaurant_locations:** 4 restaurants
- **Missing restaurant_contacts:** 52 restaurants
- **Missing restaurant_schedules:** 147 restaurants
- **Missing restaurant_delivery_config:** 28 restaurants
- **Missing restaurant_service_configs:** 0 restaurants (all have configs)
- **Active without activation date (activated_at IS NULL):** 123 restaurants
- **Missing or empty email in restaurant_locations:** 50 restaurants
- **Invalid timezone values:** 0 (all use valid North American timezones)
- **Missing slug values:** 0 (all have slugs)

---

## Critical Findings

### 1. restaurant_locations (COMPLETELY MISSING)

**4 restaurants have NO location record at all:**

**Restaurant ID: 982 - Name: Pho Xua**
- street_address: NULL
- city_id: NULL
- latitude: NULL
- longitude: NULL
- phone: NULL
- email: NULL
- timezone: America/Toronto
- slug: pho-xua-982
- activated_at: NULL

**Restaurant ID: 983 - Name: Pizza Lime**
- street_address: NULL
- city_id: NULL
- latitude: NULL
- longitude: NULL
- phone: NULL
- email: NULL
- timezone: America/Toronto
- slug: pizza-lime-983
- activated_at: NULL

**Restaurant ID: 984 - Name: La Famiglia on the Danforth**
- street_address: NULL
- city_id: NULL
- latitude: NULL
- longitude: NULL
- phone: NULL
- email: NULL
- timezone: America/Toronto
- slug: la-famiglia-on-the-danforth-984
- activated_at: NULL

**Restaurant ID: 985 - Name: Yorgo's - Nepean**
- street_address: NULL
- city_id: NULL
- latitude: NULL
- longitude: NULL
- phone: NULL
- email: NULL
- timezone: America/Toronto
- slug: yorgos-nepean-985
- activated_at: NULL

---

### 2. restaurant_contacts (MISSING)

**52 restaurants have NO contact records in restaurant_contacts table:**

- ID: 981 - Al-s Drive In
- ID: 833 - All Out Burger
- ID: 841 - All Out Burger
- ID: 924 - All Out Burger Bank St.
- ID: 948 - All Out Burger Gladstone
- ID: 949 - All Out Burger Montreal Rd
- ID: 973 - Capital Bites
- ID: 977 - Capri Pizza
- ID: 943 - Charm Thai Cuisine
- ID: 980 - Chef Rad Halal Pizza & Burgers
- ID: 962 - Chicco Pizza & Shawarma Buckingham
- ID: 966 - Chicco Pizza de l'Hopital
- ID: 964 - Chicco Pizza Maloney
- ID: 963 - Chicco Pizza Shawarma Anger
- ID: 967 - Chicco Pizza St-Louis
- ID: 961 - Chicco Shawarma Cantley
- ID: 965 - Chicco Shawarma Maloney
- ID: 957 - Cosenza
- ID: 786 - Cousin Vinny's Pizzeria
- ID: 960 - Cuisine Bombay Indienne
- ID: 743 - FJ Pizzeria
- ID: 815 - Golden Center Pizza
- ID: 950 - Kirkwood Pizza
- ID: 984 - La Famiglia on the Danforth
- ID: 955 - La Nawab
- ID: 971 - Little Gyros Greek Grill
- ID: 840 - Milano
- ID: 821 - Milano
- ID: 837 - Milano
- ID: 801 - Nachos Loco Gatineau
- ID: 790 - Nachos Loco Hull
- ID: 843 - Oh My Grill Gatineau
- ID: 974 - Pachino Pizza
- ID: 822 - Papa Burger Maloney
- ID: 438 - Papa Joe's Fried Chicken Walkley
- ID: 647 - Papaye Verte Call Centre
- ID: 768 - Pho Bo Ga 2
- ID: 982 - Pho Xua
- ID: 983 - Pizza Lime
- ID: 976 - Pizza Marie
- ID: 802 - Poutinerie Québecurds Gatineau
- ID: 789 - Poutinerie Québecurds Hull
- ID: 952 - River Pizza
- ID: 978 - Riverside Pizzeria
- ID: 777 - Roulas Jus et Gelato
- ID: 979 - Routine Poutine
- ID: 800 - The Cupboard
- ID: 929 - Tony's Pizza
- ID: 820 - Vieux Hull Pizza
- ID: 954 - Wandee Thai
- ID: 985 - Yorgo's - Nepean
- ID: 968 - Zait and Zaatar

---

### 3. restaurant_schedules (MISSING)

**147 restaurants have NO schedule records:**

This is a critical issue affecting 82% of active restaurants. Without schedules, customers cannot see operating hours.

Sample of affected restaurants:
- ID: 561 - Aahar The Taste of India
- ID: 841 - All Out Burger
- ID: 833 - All Out Burger
- ID: 735 - Amicci Pizza
- ID: 774 - Argos Greek & Pizza
- ID: 607 - Aroy Thai
- ID: 630 - Asia Garden Ottawa
- ID: 69 - Aylmer BBQ
- ID: 776 - Bank Shawarma and Poutine
- ID: 241 - Beneci Pizza
- ID: 546 - Burger Lovers
- ID: 124 - Carlo's Pizza
- ID: 72 - Cathay Restaurants
- ID: 131 - Centertown Donair & Pizza
- ID: 603 - Centre Pizza
- ID: 87 - Champa Thai Food
- ID: 943 - Charm Thai Cuisine
- ID: 641 - China Moon
- ... (and 129 more restaurants)

---

### 4. restaurant_delivery_config (MISSING)

**28 restaurants have NO delivery configuration:**

- ID: 981 - Al-s Drive In
- ID: 924 - All Out Burger Bank St.
- ID: 948 - All Out Burger Gladstone
- ID: 949 - All Out Burger Montreal Rd
- ID: 973 - Capital Bites
- ID: 977 - Capri Pizza
- ID: 943 - Charm Thai Cuisine
- ID: 980 - Chef Rad Halal Pizza & Burgers
- ID: 962 - Chicco Pizza & Shawarma Buckingham
- ID: 966 - Chicco Pizza de l'Hopital
- ID: 964 - Chicco Pizza Maloney
- ID: 963 - Chicco Pizza Shawarma Anger
- ID: 967 - Chicco Pizza St-Louis
- ID: 961 - Chicco Shawarma Cantley
- ID: 965 - Chicco Shawarma Maloney
- ID: 957 - Cosenza
- ID: 960 - Cuisine Bombay Indienne
- ID: 950 - Kirkwood Pizza
- ID: 955 - La Nawab
- ID: 971 - Little Gyros Greek Grill
- ID: 974 - Pachino Pizza
- ID: 976 - Pizza Marie
- ID: 952 - River Pizza
- ID: 978 - Riverside Pizzeria
- ID: 979 - Routine Poutine
- ID: 929 - Tony's Pizza
- ID: 954 - Wandee Thai
- ID: 968 - Zait and Zaatar

---

### 5. restaurant_locations (MISSING EMAIL)

**50 restaurants have locations but are missing email addresses:**

Sample findings:
- ID: 833 - All Out Burger (phone: (613) 443-9111, email: NULL)
- ID: 841 - All Out Burger (phone: (613) 825-8283, email: NULL)
- ID: 74 - Andiamo Pizzeria (phone: (613) 726-0726, email: NULL)
- ID: 774 - Argos Greek & Pizza (phone: (613) 825-7755, email: NULL)
- ID: 776 - Bank Shawarma and Poutine (phone: (613) 733-6161, email: NULL)
- ID: 785 - Colonnade Pizza (phone: (613) 825-8100, email: NULL)
- ID: 784 - Colonnade Pizza (phone: (613) 729-7000, email: NULL)
- ID: 786 - Cousin Vinny's Pizzeria (phone: (613) 838-5112, email: NULL)
- ID: 815 - Golden Center Pizza (phone: (613) 789-2020, email: NULL)
- ID: 781 - Golden Crust (phone: (613) 695-9955, email: NULL)
- ID: 765 - HanaHana Korean Food and Sushi Takeout (phone: (613) 831-0525, email: NULL)
- ID: 7 - Imilio's Pizzeria (phone: (613) 834-0222, email: NULL)
- ID: 838 - L'Hibou Qui Rit (phone: (819) 772-9883, email: NULL)
- ID: 825 - La Nawab V2 (phone: (819) 775-4343, email: NULL)
- ID: 827 - Lucky Key (phone: (613) 695-9988, email: NULL)
- ... (and 35 more restaurants)

---

### 6. restaurants (Core Table - Activation Issues)

**123 restaurants are active but have NULL activated_at timestamps:**

This represents 69% of all active restaurants. These restaurants should have an activation timestamp recorded when they were first set to 'active' status.

Sample of affected restaurants:
- ID: 561 - Aahar The Taste of India (timezone: America/Edmonton)
- ID: 833 - All Out Burger (timezone: America/Edmonton)
- ID: 841 - All Out Burger (timezone: America/Edmonton)
- ID: 735 - Amicci Pizza (timezone: America/Toronto)
- ID: 607 - Aroy Thai (timezone: America/Edmonton)
- ID: 630 - Asia Garden Ottawa (timezone: America/Edmonton)
- ID: 776 - Bank Shawarma and Poutine (timezone: America/Edmonton)
- ID: 603 - Centre Pizza (timezone: America/Edmonton)
- ... (and 115 more restaurants)

---

## Data Integrity Assessment

### POSITIVE FINDINGS:
1. **All 179 active restaurants have:**
   - Valid slug values (no NULLs)
   - Valid timezone values (America/Toronto or America/Edmonton)
   - restaurant_service_configs records (100% coverage)

2. **Most restaurants (151/179 = 84%) have:**
   - restaurant_delivery_config records configured

3. **175 restaurants (98%) have:**
   - Complete location records with address, city_id, and coordinates

### CRITICAL GAPS:
1. **restaurant_schedules:** 147 restaurants (82%) have no operating hours defined
2. **activated_at timestamps:** 123 restaurants (69%) missing activation timestamps
3. **restaurant_contacts:** 52 restaurants (29%) have no contact records
4. **Email addresses:** 50 restaurants (28%) missing email in locations table
5. **Complete location data:** 4 restaurants (2%) completely missing location records

---

## Recommendations

### PRIORITY 1 - IMMEDIATE ACTION REQUIRED:

1. **Complete Missing Location Records (4 restaurants):**
   - Pho Xua (ID: 982)
   - Pizza Lime (ID: 983)
   - La Famiglia on the Danforth (ID: 984)
   - Yorgo's - Nepean (ID: 985)

   **Action:** Contact restaurant owners to obtain complete address, phone, email, and coordinate data. These restaurants cannot be found by customers without location data.

2. **Create restaurant_schedules for 147 restaurants:**
   - This is the most critical gap affecting customer experience
   - Customers cannot see when restaurants are open
   - **Action:** Implement bulk schedule import process or contact each restaurant for operating hours

3. **Populate activated_at for 123 restaurants:**
   - **Action:** Run SQL update to set activated_at to created_at or earliest order date as best estimate:
   ```sql
   UPDATE menuca_v3.restaurants
   SET activated_at = created_at
   WHERE status = 'active'
   AND activated_at IS NULL
   AND deleted_at IS NULL;
   ```

### PRIORITY 2 - IMPORTANT:

4. **Add restaurant_contacts for 52 restaurants:**
   - **Action:** Extract contact information from restaurant_locations.phone/email and create proper contact records
   - This enables proper communication channels for orders, billing, and support

5. **Add email addresses for 50 restaurants in restaurant_locations:**
   - **Action:** Contact restaurant owners or extract from existing restaurant_contacts if available

6. **Create delivery configs for 28 restaurants:**
   - **Action:** Set default delivery method to 'disabled' or configure delivery areas based on location

### PRIORITY 3 - HOUSEKEEPING:

7. **Verify timezone accuracy:**
   - Many Ottawa-area restaurants are set to America/Edmonton instead of America/Toronto
   - **Action:** Audit and correct timezone settings based on actual restaurant location

---

## Notes

- The menuca_v3 schema is well-structured with proper foreign keys and soft deletes
- restaurant_service_configs has 100% coverage (excellent)
- restaurant_delivery_config has 84% coverage (good)
- The main gaps are in restaurant_schedules (82% missing) and activation timestamps (69% missing)
- Contact information exists in restaurant_locations for most restaurants, but needs to be duplicated to restaurant_contacts table for proper separation of concerns

---

**End of Audit Report**
