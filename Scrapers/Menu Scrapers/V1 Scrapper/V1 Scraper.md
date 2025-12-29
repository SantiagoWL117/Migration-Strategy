# This scraper will have two phases:

## Phase 1: 
Go over the v1 restaurants in the menuca_v3.restaurants table, verify if it they have modifier groups and if it does store all the modifier groups, modifiers, and modifier_prices for each restaurant.

## Phase 2:
Go over each dish for each restaurant and verify if it is a combo dish. If it is it skip it and continue with the next dish. If it isn't link it to the right modifier_groups and extract its modifier_group_details.

# Mapping for the scraping process:
We will use the legacy V1 CRM to scrape the data. Each restaurant in the phase 1 has a legacy_v1_id. This should be our primary criteria to determine which restaurant should be scraped in the v1 scraper.



# Restaurants to be scraped:

| V3 ID | Name | Legacy V1 ID |
|-------|------|--------------|
| 91 | Milano | 207 |
| 730 | Friendly Restaurant and Pizzeria | 968 |
| 1009 | Econo Pizza | 1095 |
| 561 | Aahar The Taste of India | 781 |
| 833 | All Out Burger | 1080 |
| 841 | All Out Burger | 1088 |
924     All Out Burger Bank St.     1013 
948     All Out Burger Gladstone    1038 
949     All Out Burger Montreal Rd  1071 
| 735 | Amicci Pizza | 973 |
| 630 | Asia Garden Ottawa | 856 |
| 69 | Aylmer BBQ | 183 |
| 241 | Beneci Pizza | 383 |
| 45 | Bobbie's Pizza & Subs | 143 |
| 124 | Carlo's Pizza | 246 |
| 72 | Cathay Restaurants | 187 |
| 131 | Centertown Donair & Pizza | 255 |
| 943 | Charm Thai Cuisine | 323 |
| 641 | China Moon | 869 |
| 196 | Colonnade Pizza | 334 |
| 783 | Colonnade Pizza | 1025 |
| 784 | Colonnade Pizza | 1027 |
| 785 | Colonnade Pizza | 1028 |
| 584 | Crispy's | 805 |
| 806 | Crispy's Bank Street | 1050 |
| 638 | Digby's Restaurant | 865 |
| 792 | Dumpling Bowl | 1035 |
| 28 | Eastview Pizza | 124 |
| 511 | Egg Roll Factory | 716 |
| 211 | Erman Pizza | 350 |
| 815 | Golden Center Pizza | 1059 |
| 736 | Greber Pizza et Shawarma | 974 |
| 519 | HaNoi Pho | 727 |
| 22 | House of Lasagna | 117 |
| 479 | iCook Pho You | 669 |
| 7 | Imilio's Pizzeria | 89 |
| 180 | Indian Punjabi Clay Oven | 318 |
| 646 | JC Royal Thai Cuisine | 874 |
| 328 | JN Pizza | 489 |
| 636 | Joes Family Pizzeria | 863 |
| 798 | Kabylie Pizza | 1042 |
| 44 | Kiki Lebanese Pineview Pizza | 142 |
| 984 | La Famiglia on the Danforth | 364 |
| 727 | La Maison du Burger | 965 |
| 721 | La Maison Pho | 959 |
| 715 | La Poutinerie Ogilvie | 952 |
| 1010 | Lemongrass Thai Cuisine | 219 |
| 756 | Little Gyros Greek Grill | 998 |
| 77 | Lorenzo's Pizzeria - Vanier | 192 |
| 267 | Lucky Fortune | 413 |
| 174 | Lucky King Take Out | 312 |
| 12 | Mama Rosa | 94 |
| 118 | Mano City Pizza | 238 |
| 614 | Marina Pizza des Flandres | 838 |
| 48 | Merivale Pizza & Wings | 146 |
| 31 | Milano | 127 |
| 55 | Milano | 161 |
| 57 | Milano | 164 |
| 59 | Milano | 172 |
| 75 | Milano | 190 |
| 88 | Milano | 204 |
| 89 | Milano | 205 |
| 90 | Milano | 206 |
| 92 | Milano | 208 |
| 93 | Milano | 209 |
| 95 | Milano | 211 |
| 97 | Milano | 213 |
| 123 | Milano | 245 |
| 126 | Milano | 248 |
| 190 | Milano | 328 |
| 265 | Milano | 411 |
| 349 | Milano | 512 |
| 350 | Milano | 513 |
| 565 | Milano | 785 |
| 569 | Milano | 789 |
| 586 | Milano | 807 |
| 593 | Milano | 815 |
| 601 | Milano | 824 |
| 624 | Milano | 850 |
| 651 | Milano | 879 |
| 660 | Milano | 889 |
| 680 | Milano | 913 |
| 701 | Milano | 937 |
| 749 | Milano | 987 |
| 751 | Milano | 989 |
| 818 | Milano | 1062 |
| 819 | Milano | 1063 |
| 821 | Milano | 1065 |
| 835 | Milano | 1082 |
| 837 | Milano | 1084 |
| 840 | Milano | 1087 |
| 842 | Milano | 1089 |
| 205 | Mont Liban Bakery & Shawarma | 344 |
| 1011 | Mozza Pizza Gatineau | 132 |
| 644 | Mozza Pizza Hull | 872 |
| 47 | Mr Mozzarella - Nepean | 145 |
| 801 | Nachos Loco Gatineau | 1045 |
| 790 | Nachos Loco Hull | 1033 |
| 515 | Napolis | 721 |
| 15 | New Mee Fung Restaurant | 101 |
| 65 | Number One Chinese Take Out | 179 |
| 714 | Ogilvie Pizza | 951 |
| 807 | Oh My Grill | 1051 |
| 681 | Oka's Hull | 914 |
| 245 | Orchid Sushi | 387 |
| 521 | Palermo Pizzeria | 729 |
| 797 | Papa Burger | 1041 |
| 822 | Papa Burger Maloney | 1066 |
| 810 | Papa Grecque Cantley | 1054 |
| 540 | Papa Grecque des Flandres | 758 |
| 616 | Papa Grecque Maloney | 840 |
| 437 | Papa Joe's Fried Chicken - Downtown | 612 |
| 13 | Papa Joe's Pizza - Downtown | 95 |
| 70 | Papa Pizza - Hull | 184 |
| 602 | Papa Pizza Cantley | 825 |
| 795 | Papa Pizza Chem. de Masson | 1039 |
| 1012 | Papa Pizza Des Flandres | 231 |
| 1013 | Papa Pizza Maloney | 346 |
| 1014 | Papa Pizza Val-Des-Monts | 703 |
| 712 | Patate Lou Lou | 948 |
| 199 | Pho Bo Ga King - Somerset | 337 |
| 139 | Pizza Bravo | 264 |
| 562 | Pizza des Hautes Plaines | 782 |
| 726 | Pizza Joanna | 964 |
| 507 | Pizza Lovers Hunt Club | 712 |
| 696 | Pizza Maisonneuve | 930 |
| 829 | Pizzalicious | 1074 |
| 716 | PizzaRama | 953 |
| 1015 | Poutinerie Québecurds Gatineau | 1046 |
| 789 | Poutinerie Québecurds Hull | 1032 |
| 824 | Prima Pizza | 1069 |
| 497 | Rangoli | 701 |
| 109 | Restaurant Chez Gerry | 228 |
| 106 | Restaurant Le Choix | 225 |
| 1016 | Roulas Grecque et Pizza | 173 |
| 745 | Sala Thai | 983 |
| 83 | Season's Pizza | 199 |
| 836 | Souvlaki Souvlaki | 1083 |
| 595 | Supreme Pizzeria | 817 |
| 711 | Supreme Pizzeria | 947 |
| 1017 | Sushi Express Chambly | 511 |
| 596 | Sushi Fleury | 818 |
| 847 | Sushiyana | 1094 |
| 84 | The Original Georgie's | 200 |
| 941 | Ting's Kitchen | 694 |
| 143 | Tony's Pizza | 275 |
| 62 | Vanier Pizza & Subs | 175 |
| 820 | Vieux Hull Pizza | 1064 |
| 367 | Xtreme Pizza | 532 |
| 985 | Yorgo's - Nepean | 547 |


# V3 Dish modifier schema:

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              DISH MODIFIER SCHEMA v4 (FINAL)                                 │
│                           Single Purpose Per Table                                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


                    RESTAURANT LEVEL                              DISH LEVEL
                  (Shared within restaurant)                  (Dish-specific)
                ════════════════════════════                ════════════════════════════

┌───────────────┐
│  restaurants  │
├───────────────┤
│ id            │
│ name          │
└───────┬───────┘
        │
        │ 1:N
        ▼
┌───────────────────────────┐                           ┌─────────────────────────────────┐
│     modifier_groups       │                           │         dishes                  │
│  (NEW - restaurant-level) │                           ├─────────────────────────────────┤
├───────────────────────────┤                           │ id                              │
│ id            PK          │                           │ name                            │
│ restaurant_id FK          │                           │ ...                             │
│ name                      │                           └────────────────┬────────────────┘
│ category                  │                                            │
│ source_system             │                                            │
│ created_at                │                                            │
│ updated_at                │         ┌──────────────────────────────────┘
│ deleted_at                │         │
└───────────┬───────────────┘         │
            │                         │
            │ 1:N                     │
            ▼                         ▼
┌───────────────────────────┐       ┌─────────────────────────────────┐
│       modifiers           │       │     dish_modifier_groups        │
│  (NEW - shared items)     │       │  (NEW - junction table)         │
├───────────────────────────┤       ├─────────────────────────────────┤
│ id            PK          │       │ id              PK              │
│ modifier_group_id FK ─────┼──►    │ dish_id         FK ─────────────┼──► dishes
│ name                      │       │ modifier_group_id FK ───────────┼──► modifier_groups
│ display_order             │       │                                 │
│ is_active      ⭐         │       │ created_at                      │
│ created_at                │       │ updated_at                      │
│ updated_at                │       │ deleted_at                      │
│ deleted_at                │       │                                 │
└───────────┬───────────────┘       │ UNIQUE(dish_id, modifier_grp_id)│
            │                       └────────────────┬────────────────┘
            │ 1:N                                    │
            ▼                                        │ 1:1
┌───────────────────────────┐                        ▼
│    modifier_prices        │       ┌─────────────────────────────────┐
│    (NEW - shared prices)  │       │   modifier_group_details        │
├───────────────────────────┤       │ (EXISTING - PRESERVED settings) │
│ id            PK          │       ├─────────────────────────────────┤
│ modifier_id   FK ─────────┼──►    │ id              PK              │
│ size_variant              │       │ dish_modifier_group_id FK ──────┼──► dish_modifier_groups
│ price                     │       │                                 │
│ display_order             │       │ name            ✅ PRESERVED     │
│ created_at                │       │ min_selections  ✅ PRESERVED     │
│ updated_at                │       │ max_selections  ✅ PRESERVED     │
│ deleted_at                │       │ free_items      ✅ PRESERVED     │
└───────────────────────────┘       │ display_order   ✅ PRESERVED     │
                                    │                                 │
                                    │ created_at                      │
                                    │ updated_at                      │
                                    │ deleted_at                      │
                                    └─────────────────────────────────┘



# Sort the restaurants to be scraped by French and English menu:
Step 1. 
Login to the CRM:
<body>
	<div id="loader" style="color: #f00;position: absolute; top:0; left:0;background-color: #fff;z-index:2;display: none;width:100%">Loading ...</div>
	<div class="wraper">
		<div class="contain" style="margin-top:2px;clear:both;position:relative">
			<form action="/?p=login&amp;action=login" method="post" class="login" id="loginForm">
	<ul style="list-style-type: none">
				<li><label for="username">Username</label><input class="long" type="text" name="username" id="username" value=""></li>
		<li><label for="password">Password</label><input class="long" type="password" name="password" id="password" value=""></li>
		<li style="text-align: right; padding-right:10px">
			<input type="submit" value="Login">
							<input type="hidden" name="redirect" value="p=restaurants&amp;display=editRestaurant&amp;restaurant=132&amp;load=ingredientGroups&amp;showLang=fr">
					</li>
	</ul>
</form>

</body>

Step 2. 
Access this url https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=[restaurant legacy_v1_id]&load=menu&showLang=en using the legacy_V1_id of each of the restaurants to be scraped.

Step 3. 
If the current restaurant does have an English menu you will see this html markup:
<div style="width:500px; float: left;">
			<ul style="list-style-type: none" id="course_0"><li style="position: relative;"><h3>Super Special</h3></li><li style="margin-left: 10px; position: relative;" id="li_106129">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=106129">Large Pizza &amp; Wings</a> - 1 large pizza choice of menu, 10 wings, 1 garlic dip.											</li><li style="margin-left: 10px; position: relative;" id="li_106130">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=106130">Medium Pizza &amp; Wings</a> - 1 medium pizza choice of menu, 10 wings, 1 garlic dip.											</li><li style="margin-left: 10px; position: relative;" id="li_106131">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=106131">Small Pizza &amp; Wings</a> - 1 small pizza choice of menu, 10 wings, 1 garlic dip.											</li></ul>	
			<ul style="list-style-type: none" id="course_1"><li style="position: relative;"><h3>Pizzas</h3></li><li style="margin-left: 10px; position: relative;" id="li_105963">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105963">Cheese Pizza</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105965">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105965">Combination Pizza</a> - Pepperoni, mushrooms, green peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105966">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105966">Vegetarian Pizza</a> - Mushrooms, green peppers, onions, olives, tomatoes.											</li><li style="margin-left: 10px; position: relative;" id="li_105967">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105967">Hawaiian Pizza</a> - Ham, pineapple.											</li><li style="margin-left: 10px; position: relative;" id="li_105974">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105974">Taco Pizza</a> - Taco style pizza with ground beef, onions, peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_122858">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=122858">Shawarma Pizza</a> - Shawarma chicken, peppers, onions, garlic sauce.											</li><li style="margin-left: 10px; position: relative;" id="li_105972">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105972">House Special Pizza</a> - Pepperoni, bacon, mushrooms, green peppers, onions, olives.											</li><li style="margin-left: 10px; position: relative;" id="li_105973">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105973">Meat Lovers Pizza</a> - Pepperoni, bacon,ham, Italian sausage.											</li><li style="margin-left: 10px; position: relative;" id="li_105969">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105969">The Senators Pizza</a> - Pepperoni, bacon, olives.											</li><li style="margin-left: 10px; position: relative;" id="li_105968">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105968">Canadian Pizza</a> - Pepperoni, bacon, mushrooms.											</li><li style="margin-left: 10px; position: relative;" id="li_105975">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105975">BBQ Chicken Pizza</a> - Chicken, black olives, onions.											</li><li style="margin-left: 10px; position: relative;" id="li_105970">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105970">Greek Pizza</a> - Tomatoes, onions, black olives, fresh garlic, feta cheese.											</li><li style="margin-left: 10px; position: relative;" id="li_105971">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105971">Garden Pizza</a> - Cauliflower, broccoli, onions &amp; tomatoes.											</li><li style="margin-left: 10px; position: relative;" id="li_105964">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=105964">1 Topping Pizza HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_2"><li style="position: relative;"><h3>Twins Special</h3></li><li style="margin-left: 10px; position: relative;" id="li_106127">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=106127">2 Large Pizzas</a> - Choice of menu.											</li><li style="margin-left: 10px; position: relative;" id="li_106128">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editCombo&amp;showLang=en&amp;combo=106128">2 Medium Pizzas</a> - Choice of menu.											</li></ul>					
			<ul style="list-style-type: none" id="course_3"><li style="position: relative;"><h3>Wings</h3></li><li style="margin-left: 10px; position: relative;" id="li_105887">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105887">10 Jumbo Chicken Wings</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105888">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105888">15 Jumbo Chicken Wings</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105889">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105889">20 Jumbo Chicken Wings</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_4"><li style="position: relative;"><h3>Salads</h3></li><li style="margin-left: 10px; position: relative;" id="li_105894">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105894">Michel Salad</a> - Tomatoes, cucumbers, onions, peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105892">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105892">Fattouch Salad</a> - Zaatar, pita, tomatoes, cucumbers, onions, peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105891">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105891">Greek Salad</a> - Olives, feta, tomatoes, cucumbers, onions, peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105895">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105895">Caesar Salad</a> - Bacon, mozzarella, croutons.											</li><li style="margin-left: 10px; position: relative;" id="li_105890">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105890">Amicci Salad</a> - Chicken, ham, pepperoni, mozzarella, tomatoes, cucumbers, onions, peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105893">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105893">Feta Salad HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_5"><li style="position: relative;"><h3>Wraps</h3></li><li style="margin-left: 10px; position: relative;" id="li_105900">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105900">Chicken Shawarma</a> - Tomatoes, turnips, lettuce &amp; garlic sauce.											</li><li style="margin-left: 10px; position: relative;" id="li_105901">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105901">Beef Donair</a> - Tomatoes, pickles, lettuce &amp; garlic sauce.											</li><li style="margin-left: 10px; position: relative;" id="li_105896">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105896">Chicken Souvlaki Wrap</a> - Red onions, tomatoes, lettuce &amp; tzatziki.											</li><li style="margin-left: 10px; position: relative;" id="li_105897">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105897">Pork Souvlaki Wrap</a> - Red onions, tomatoes, lettuce &amp; tzatziki.											</li><li style="margin-left: 10px; position: relative;" id="li_105898">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105898">Beef Kafta Wrap</a> - Onions, tomatoes, pickles, lettuce &amp; hummus.											</li><li style="margin-left: 10px; position: relative;" id="li_105899">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105899">Filet Mignon Wrap</a> - Onions, tomatoes, lettuce &amp; tzatziki.											</li><li style="margin-left: 10px; position: relative;" id="li_106132">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=106132">Trio Shawarma</a> - Large shawarma sandwich, chicken or beef, fries or Greek potatoes and 1 can.											</li><li style="margin-left: 10px; position: relative;" id="li_106133">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=106133">Trio Souvlaki</a> - Large souvlaki sandwich, chicken or pork, fries or Greek potatoes and 1 can.											</li></ul>					
			<ul style="list-style-type: none" id="course_6"><li style="position: relative;"><h3>Appetizers</h3></li><li style="margin-left: 10px; position: relative;" id="li_105906">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105906">Rice</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105903">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105903">Dolmades (7)</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105907">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105907">Hummus</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105904">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105904">Tzatziki</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105905">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105905">Greek Potatoes</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105902">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105902">Fried Calmars</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_7"><li style="position: relative;"><h3>Greek Platters</h3></li><li style="margin-left: 10px; position: relative;" id="li_105908">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105908">Chicken Shawarma Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105910">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105910">Chicken Skewer Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105911">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105911">Pork Skewer Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105909">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105909">Marinated Chicken Breast Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105912">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105912">Kafta Beef Skewer Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105914">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105914">Filet Mignon Plate</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105913">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105913">Butterfly Shrimp Plate (8)</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105915">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105915">Chicken Shrimp Combo (4)</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105916">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105916">Filet mignon and Shrimps Skewers Combo (4)</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_8"><li style="position: relative;"><h3>Italian Dishes</h3></li><li style="margin-left: 10px; position: relative;" id="li_105922">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105922">Meat Ravioli</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105917">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105917">Spaghetti Bolognese</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105919">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105919">Meatball Spaghetti</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105920">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105920">Meat Lasagna</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105923">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105923">Meat Canneloni</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105924">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105924">Spinach Canneloni</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105925">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105925">Chicken Parmesan</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105918">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105918">Neopolitain Spaghetti HIDE</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105921">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105921">Neopolitain Lasagna HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_9"><li style="position: relative;"><h3>Canadian Dishes</h3></li><li style="margin-left: 10px; position: relative;" id="li_105926">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105926">Club Sandwich</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105931">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105931">Chicken Burger Platter</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105930">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105930">Hamburger Platter</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105928">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105928">Hamburger Steak</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105932">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105932">Hot Chicken Sandwich</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105929">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105929">Chicken Fingers</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105947">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105947">Fish N Chips</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105933">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105933">Fries</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105934">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105934">Onion Rings</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105940">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105940">Nachos</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105942">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105942">Garlic Bread HIDE</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105943">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105943">Garlic Cheese Bread</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105944">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105944">Cheese Sticks</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105945">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105945">Deep Fried Pickles</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105941">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105941">Fried Zucchini</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105946">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105946">Amicci Platter</a> - Fries, onion rings, fried zucchini, cheese sticks.											</li><li style="margin-left: 10px; position: relative;" id="li_105927">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105927">Club Poutine HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_10"><li style="position: relative;"><h3>Poutine</h3></li><li style="margin-left: 10px; position: relative;" id="li_105935">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105935">Regular Poutine</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105936">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105936">Italian Poutine</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105937">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105937">Chicken Shawarma Poutine</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105938">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105938">Bacon Poutine</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105939">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105939">Senator’s Poutine</a> - Beef, onions.											</li></ul>					
			<ul style="list-style-type: none" id="course_11"><li style="position: relative;"><h3>Subs</h3></li><li style="margin-left: 10px; position: relative;" id="li_105951">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105951">Steak Philly Sub</a> - Onions, green peppers, Swiss cheese.											</li><li style="margin-left: 10px; position: relative;" id="li_105949">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105949">Steak Pepperoni Sub</a> - Onions, green peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105950">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105950">Steak Bacon Sub</a> - Onions, green peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105952">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105952">Meatballs Sub</a> - Meat sauce, cheese.											</li><li style="margin-left: 10px; position: relative;" id="li_105953">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105953">Club Sub</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105948">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105948">Steak Sub HIDE</a> - Onions, green peppers.											</li><li style="margin-left: 10px; position: relative;" id="li_105954">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105954">Pepperoni Sub HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_12"><li style="position: relative;"><h3>Desserts</h3></li><li style="margin-left: 10px; position: relative;" id="li_105955">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105955">Cheesecake</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105956">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105956">Baklava (1)</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_113284">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=113284">Truffles (4) HIDE</a> - 											</li></ul>					
			<ul style="list-style-type: none" id="course_13"><li style="position: relative;"><h3>Drinks</h3></li><li style="margin-left: 10px; position: relative;" id="li_105957">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105957">Pepsi</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105958">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105958">Coke</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105959">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105959">7Up</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105960">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105960">Sprite</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105961">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105961">Ginger Ale</a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_105962">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=editDish&amp;showLang=en&amp;menuEntry=105962">Bottled Water</a> - 											</li></ul>					
	</div>

If the current restaurant has a french menu you will see either:
a. This empty <div style="width:500px; float: left;"></div>
b. This html markup:
<div style="width:500px; float: left;">
			<ul style="list-style-type: none" id="course_1000"><li style="position: relative;"><h3>No Course</h3></li><li style="margin-left: 10px; position: relative;" id="li_124966">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124966"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124967">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editCombo&amp;showLang=en&amp;combo=124967"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124968">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editCombo&amp;showLang=en&amp;combo=124968"></a> - 											</li><li style="margin-left: 10px; position: relative; z-index: 0; top: 0px; left: 0px;" id="li_124969">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124969"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124970">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124970"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124971">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124971"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124972">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124972"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124973">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124973"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124974">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124974"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124975">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124975"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124976">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124976"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124977">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124977"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124978">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124978"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124979">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124979"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124980">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124980"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124981">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124981"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124982">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124982"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124983">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124983"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124984">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124984"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124985">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124985"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124986">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124986"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124988">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124988"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124990">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124990"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124991">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124991"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124992">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124992"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124993">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124993"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124994">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124994"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124995">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editCombo&amp;showLang=en&amp;combo=124995"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124996">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124996"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124997">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124997"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124998">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124998"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_124999">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=124999"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125000">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125000"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125001">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125001"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125002">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125002"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125003">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125003"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125004">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editCombo&amp;showLang=en&amp;combo=125004"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125005">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125005"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125006">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editCombo&amp;showLang=en&amp;combo=125006"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125007">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125007"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125008">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125008"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125009">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125009"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125010">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125010"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125011">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125011"></a> - 											</li><li style="margin-left: 10px; position: relative;" id="li_125012">
						<img src="../images/css_move.gif" alt="Sort" style="vertical-align: middle; width:15px; height:15px;cursor: move">
													<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=1095&amp;load=editDish&amp;showLang=en&amp;menuEntry=125012"></a> - 											</li></ul>
					</div>

Step 4.
If you the current restaurant has an English menu mark it as English Menu restaurant in the log. If it has a french menu mark it as a french menu in the log




# Instructions: 
Now, instead of me giving you detailed instructions about how to navigate the V1 CRM I want you leverage on the URLs for modifier groups and dishes. 

## Login to V1 CRM
<body>
	<div id="loader" style="color: #f00;position: absolute; top:0; left:0;background-color: #fff;z-index:2;display: none;width:100%">Loading ...</div>
	<div class="wraper">
		<div class="contain" style="margin-top:2px;clear:both;position:relative">
			<form action="/?p=login&amp;action=login" method="post" class="login" id="loginForm">
	<ul style="list-style-type: none">
				<li><label for="username">Username</label><input class="long" type="text" name="username" id="username" value=""></li>
		<li><label for="password">Password</label><input class="long" type="password" name="password" id="password" value=""></li>
		<li style="text-align: right; padding-right:10px">
			<input type="submit" value="Login">
							<input type="hidden" name="redirect" value="p=restaurants&amp;display=editRestaurant&amp;restaurant=132&amp;load=ingredientGroups&amp;showLang=fr">
					</li>
	</ul>
</form>
</body>


## Scrape English modifier groups

The URL for each modifier group of each restaurant is composed by the following:
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=973&load=ingredientGroups&showLang=en

Where:
- restaurant=973 references the legacy_v1_id of each restaurant (For this example we are referencing Amicci Pizza (V3 Id 735)).
-  showLang=en indicates that the menu is in English 


Access this url using the legacy_V1_id of each of the English restaurants to be scraped. Each modifier group is stored in a <p> element like this:
<p style="margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa"><a href="#" onclick="$('div_9872').toggle();return false;">Wings Sauces</a></p>
- modifier_groups.name = Wings Sauces

the modifiers and their respective prices for this modifier group are in this <div> element
<div id="div_9872" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); padding: 1px;">
			<form id="addGroupForm_9872" action="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=ingredientGroups&amp;showLang=en&amp;action=update" method="post">
				<input type="text" name="name" id="name_9872" value="Wings Sauces" style="height:20px; line-height:20px;margin:2px; border:1px solid #aaa;width:220px">
				<select name="type" id="type_9872">
					<option value="">Choose group type</option>
					<option value="ci">Custom Ingredients</option>
					<option value="d">Drinks</option>
					<option value="dr">Dressings</option>
					<option value="e">Extras</option>
					<option value="br">Bread / Crust</option>
					<option value="sa" selected="">Sauces</option>
					<option value="sd">Side Dishes</option>
					<option value="cm">Side Dishes</option>
				</select>
				<select name="course" id="course_9872">
					<option value="">-- Choose Course --</option>
											<option value="13811">Super Special</option>
											<option value="13794">Pizzas</option>
											<option value="13810">Twins Special</option>
											<option value="13784">Wings</option>
											<option value="13785">Salads</option>
											<option value="13786">Wraps</option>
											<option value="13787">Appetizers</option>
											<option value="13788">Greek Platters</option>
											<option value="13789">Italian Dishes</option>
											<option value="13790">Canadian Dishes</option>
											<option value="15709">Poutine</option>
											<option value="13791">Subs</option>
											<option value="13792">Desserts</option>
											<option value="13793">Drinks</option>
									</select>
				<a href="#" id="checkall_9872">Check All</a>
				<ul id="fillme_9872" style="list-style-type: none;overflow: hidden;margin:5px 0"><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_45093" value="45093"><label for="sauce__9872_45093"> Marinara</label><input type="text" name="price[45093]" id="price__9872_45093" value="1.55"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_45094" value="45094"><label for="sauce__9872_45094"> Ranch</label><input type="text" name="price[45094]" id="price__9872_45094" value="1.55"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_45095" value="45095"><label for="sauce__9872_45095"> Garlic</label><input type="text" name="price[45095]" id="price__9872_45095" value="1.55"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_45102" value="45102"><label for="sauce__9872_45102"> Hummus</label><input type="text" name="price[45102]" id="price__9872_45102" value="1.55"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_45103" value="45103"><label for="sauce__9872_45103"> Tzatziki</label><input type="text" name="price[45103]" id="price__9872_45103" value="1.55"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44950" value="44950"><label for="sauce__9872_44950"> BBQ</label><input type="text" name="price[44950]" id="price__9872_44950" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44951" value="44951"><label for="sauce__9872_44951"> Hot</label><input type="text" name="price[44951]" id="price__9872_44951" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44952" value="44952"><label for="sauce__9872_44952"> Honey Garlic</label><input type="text" name="price[44952]" id="price__9872_44952" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44953" value="44953"><label for="sauce__9872_44953"> Sour Cream</label><input type="text" name="price[44953]" id="price__9872_44953" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44954" value="44954"><label for="sauce__9872_44954"> No Sauce</label><input type="text" name="price[44954]" id="price__9872_44954" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44958" value="44958"><label for="sauce__9872_44958"> Garlic Sauce</label><input type="text" name="price[44958]" id="price__9872_44958" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="sauce__9872_44959" value="44959"><label for="sauce__9872_44959"> Mayo</label><input type="text" name="price[44959]" id="price__9872_44959" value="0.00"></li></ul>
				<input type="submit" id="submit_9872">
				<input type="hidden" name="id" value="9872">
				<input type="hidden" name="restaurant" value="973">
				<input type="hidden" name="lang" value="en">
				<a onclick="return confirm('Really delete?')" id="del_9872" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=973&amp;load=ingredientGroups&amp;showLang=en&amp;action=delete&amp;group=9872">Delete</a>
			</form>
		</div>

- modifier_groups.category = 	<option value="sa" selected="">Sauces</option>
- modifier.group.source_system: 9872 in <a href="#" onclick="$('div_9872').toggle();return false;">Wings Sauces</a>

### IMPORTANT: Expand Modifier Groups Before Scraping

By default, modifier group divs are **collapsed** with `display: none`. You must click each modifier group header to expand it before scraping.

**The Problem:**
```html
<div id="div_9872" style="... display: none;">
  <!-- Modifiers are hidden and cannot be scraped -->
</div>
```

**The Solution:**
Click the `<a>` element in the `<p>` header to toggle visibility:

```html
<p style="...">
  <a href="#" onclick="$('div_9872').toggle();return false;">Wings Sauces</a>
</p>
```

**Playwright Implementation:**

```python
# For each modifier group, click to expand before scraping
for group_header in await page.query_selector_all('p > a[onclick*="toggle"]'):
    await group_header.click()
    await page.wait_for_timeout(100)  # Small delay for DOM update
```

**Alternative: Force visibility via JavaScript** (faster, no clicking needed):

```python
# Remove display:none from all modifier group divs
await page.evaluate('''
    document.querySelectorAll('div[id^="div_"]').forEach(div => {
        div.style.display = 'block';
    });
''')
```

---

### Instruction for extracting active modifiers:
#### Key Concept: Checkboxes Are Set by JavaScript, Not HTML

The HTML renders ALL available modifiers for each group type with **unchecked checkboxes**. JavaScript dynamically checks specific modifiers based on `objItem{group_id}` arrays embedded in the page.

##### Step 1: Extract Active Modifier IDs from JavaScript

Look for JavaScript arrays in the page source that follow this pattern:

```javascript
var objItem9872 = ["44950","44951","44952","44953","44954"]; // Selected/active items
var objPrice9872 = {"44950":"0.00","44951":"0.00",...};      // Prices per item
```

**Key:** Only modifier IDs that appear in `objItem{group_id}` are **ACTIVE** (checked) for that modifier group.

##### Step 2: Parse the HTML for Modifier Details

Each modifier in the `<ul id="fillme_{group_id}">` contains:

```html
<li>
  <input type="checkbox" name="item[]" id="sauce__9872_45093" value="45093">  <!-- Modifier ID -->
  <label for="sauce__9872_45093"> Marinara</label>                            <!-- Modifier Name -->
  <input type="text" name="price[45093]" id="price__9872_45093" value="1.55"> <!-- Price(s) -->
</li>
```

##### Step 3: Cross-Reference to Determine Active Status

For each modifier found in HTML:
1. Get `modifier_id` from checkbox `value` attribute
2. Check if `modifier_id` exists in `objItem{group_id}` JavaScript array
3. If YES → `is_active = true` (modifier is checked)
4. If NO → `is_active = false` (modifier is unchecked, skip for scraping)

###### Example: Wings Sauces (Group 9872)

**JavaScript:**
```javascript
var objItem9872 = ["44950","44951","44952","44953","44954"];
```

**Result:**
| Modifier ID | Name | In objItem9872? | is_active |
|-------------|------|-----------------|-----------|
| 45093 | Marinara | ❌ No | false (SKIP) |
| 45094 | Ranch | ❌ No | false (SKIP) |
| 45095 | Garlic | ❌ No | false (SKIP) |
| 44950 | BBQ | ✅ Yes | **true** |
| 44951 | Hot | ✅ Yes | **true** |
| 44952 | Honey Garlic | ✅ Yes | **true** |
| 44953 | Sour Cream | ✅ Yes | **true** |
| 44954 | No Sauce | ✅ Yes | **true** |

##### Step 4: Handle Multi-Size Prices

Prices may be comma-separated for dishes with multiple sizes:

```javascript
{"44965":"2.00,3.00,4.00,5.00"}  // Small, Medium, Large, XL
```

Split on comma and create separate `modifier_prices` records:
- `size_variant = "Small"`, `price = 2.00`, `display_order = 0`
- `size_variant = "Medium"`, `price = 3.00`, `display_order = 1`
- `size_variant = "Large"`, `price = 4.00`, `display_order = 2`
- `size_variant = "XL"`, `price = 5.00`, `display_order = 3`

##### Python Extraction Logic

```python
import re

# 1. Get page content
page_content = await page.content()

# 2. Extract objItem arrays (active modifier IDs)
obj_item_pattern = r'var objItem(\d+) = \[(.*?)\];'
for match in re.finditer(obj_item_pattern, page_content):
    group_id = match.group(1)
    active_ids = [id.strip('"\'') for id in match.group(2).split(',') if id.strip()]
    
    # 3. For each modifier in the HTML form
    for checkbox in await page.query_selector_all(f'#fillme_{group_id} input[type="checkbox"]'):
        modifier_id = await checkbox.get_attribute('value')
        
        # 4. Determine active status
        is_active = modifier_id in active_ids
        
        if is_active:
            # Get modifier name from label
            label = await page.query_selector(f'label[for*="_{group_id}_{modifier_id}"]')
            modifier_name = (await label.text_content()).strip()
            
            # Get price from text input
            price_input = await page.query_selector(f'input[name="price[{modifier_id}]"]')
            price_value = await price_input.get_attribute('value')
            
            # Handle multi-size prices
            prices = price_value.split(',')
            # Store each price with size_variant...
```

##### Data to Extract per Active Modifier

| Field | Source | Example |
|-------|--------|---------|
| `modifier_id` (V1) | `checkbox.value` | `44950` |
| `modifier_name` | `label` text | `BBQ` |
| `price(s)` | `input[name="price[{id}]"]` | `0.00` or `2.00,3.00,4.00,5.00` |
| `is_active` | Check if ID in `objItem{group_id}` | `true` |



## Scrape French modifier groups
The URL for each modifier group of each restaurant is composed by the following:
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=132&load=ingredientGroups&showLang=fr
Where: 
- restaurant=132 references the legacy_v1_id of each restaurant (For this example we are referencing   V3 ID 1011  Mozza Pizza Gatineau).
- showLang=fr indicates that the menu is in French

Access this url using the legacy_V1_id of each of the French restaurants to be scraped.

Each modifier group is stored in a <p> element like this:
<p style="margin-top:1px;height:20px;line-height:1.5;background-color: #ccc;padding-left:20px;border:1px solid #aaa"><a href="#" onclick="$('div_1363').toggle();return false;">Pizza Toppings FR</a></p>

- modifier_groups.name = Pizza Toppings FR

the modifiers and their respective prices for this modifier group are in this <div> element
<div id="div_1363" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); padding: 1px; display: none;">
			<form id="addGroupForm_1363" action="?p=restaurants&amp;display=editRestaurant&amp;restaurant=132&amp;load=ingredientGroups&amp;showLang=fr&amp;action=update" method="post">
				<input type="text" name="name" id="name_1363" value="Pizza Toppings FR" style="height:20px; line-height:20px;margin:2px; border:1px solid #aaa;width:220px">
				<select name="type" id="type_1363">
					<option value="">Choose group type</option>
					<option value="ci" selected="">Custom Ingredients</option>
					<option value="d">Drinks</option>
					<option value="dr">Dressings</option>
					<option value="e">Extras</option>
					<option value="br">Bread / Crust</option>
					<option value="sa">Sauces</option>
					<option value="sd">Side Dishes</option>
					<option value="cm">Side Dishes</option>
				</select>
				<select name="course" id="course_1363">
					<option value="">-- Choose Course --</option>
											<option value="1960">Spécial Petites</option>
											<option value="1961">Spécial Moyennes</option>
											<option value="1962">Spécial Grandes</option>
											<option value="1963">Spécial X-Grandes </option>
											<option value="1949">Pizzas</option>
											<option value="1950">Entrées</option>
											<option value="1951">Salades</option>
											<option value="1952">Wraps</option>
											<option value="1953">Pâtes Savoureuses</option>
											<option value="1954">Ailes de Poulet</option>
											<option value="1955">Frites de Poulet</option>
											<option value="1956">Doigts De Poulet</option>
											<option value="1957">Sandwichs Roulés Chauds</option>
											<option value="1959">Sous-Marin Chaud</option>
											<option value="6991">Mega Bouffe</option>
											<option value="1958">Desserts</option>
											<option value="10678">Liqueurs</option>
									</select>
				<a href="#" id="checkall_1363">Check All</a>
				<ul id="fillme_1363" style="list-style-type: none;overflow: hidden;margin:5px 0"><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_39689" value="39689"><label for="ci__1363_39689"> Jambon HIDE</label><input type="text" name="price[39689]" id="price__1363_39689" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_39690" value="39690"><label for="ci__1363_39690"> Poulet HIDE</label><input type="text" name="price[39690]" id="price__1363_39690" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_39691" value="39691"><label for="ci__1363_39691"> Bacon HIDE</label><input type="text" name="price[39691]" id="price__1363_39691" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_49228" value="49228"><label for="ci__1363_49228"> Mozzarella Pizza</label><input type="text" name="price[49228]" id="price__1363_49228" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6859" value="6859"><label for="ci__1363_6859"> Mozzarella</label><input type="text" name="price[6859]" id="price__1363_6859" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6870" value="6870"><label for="ci__1363_6870"> Canadienne</label><input type="text" name="price[6870]" id="price__1363_6870" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_37615" value="37615"><label for="ci__1363_37615"> Au Fromage</label><input type="text" name="price[37615]" id="price__1363_37615" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_36862" value="36862"><label for="ci__1363_36862"> La Western</label><input type="text" name="price[36862]" id="price__1363_36862" value="0.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6465" value="6465"><label for="ci__1363_6465"> Poivrons Verts</label><input type="text" name="price[6465]" id="price__1363_6465" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6466" value="6466"><label for="ci__1363_6466"> Piments Forts</label><input type="text" name="price[6466]" id="price__1363_6466" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6467" value="6467"><label for="ci__1363_6467"> Oignons</label><input type="text" name="price[6467]" id="price__1363_6467" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6468" value="6468"><label for="ci__1363_6468"> Oignons Rouges</label><input type="text" name="price[6468]" id="price__1363_6468" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6469" value="6469"><label for="ci__1363_6469"> Tomate</label><input type="text" name="price[6469]" id="price__1363_6469" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6470" value="6470"><label for="ci__1363_6470"> Olives Vertes</label><input type="text" name="price[6470]" id="price__1363_6470" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6471" value="6471"><label for="ci__1363_6471"> Olives Noires</label><input type="text" name="price[6471]" id="price__1363_6471" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6472" value="6472"><label for="ci__1363_6472"> Champignon</label><input type="text" name="price[6472]" id="price__1363_6472" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6473" value="6473"><label for="ci__1363_6473"> Brocoli</label><input type="text" name="price[6473]" id="price__1363_6473" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6477" value="6477"><label for="ci__1363_6477"> Ananas</label><input type="text" name="price[6477]" id="price__1363_6477" value="1.00,1.50,2.00,2.50"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6474" value="6474"><label for="ci__1363_6474"> Fromage Feta</label><input type="text" name="price[6474]" id="price__1363_6474" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6478" value="6478"><label for="ci__1363_6478"> Double Fromage</label><input type="text" name="price[6478]" id="price__1363_6478" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6460" value="6460"><label for="ci__1363_6460"> Saucisse Italienne</label><input type="text" name="price[6460]" id="price__1363_6460" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6461" value="6461"><label for="ci__1363_6461"> Boulettes de Viande</label><input type="text" name="price[6461]" id="price__1363_6461" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6462" value="6462"><label for="ci__1363_6462"> Poulet</label><input type="text" name="price[6462]" id="price__1363_6462" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6463" value="6463"><label for="ci__1363_6463"> Beef Hachée</label><input type="text" name="price[6463]" id="price__1363_6463" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6457" value="6457"><label for="ci__1363_6457"> Pepperoni</label><input type="text" name="price[6457]" id="price__1363_6457" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6458" value="6458"><label for="ci__1363_6458"> Jambon</label><input type="text" name="price[6458]" id="price__1363_6458" value="1.50,2.50,3.50,4.00"></li><li style="float:left; width:150px;border:1px solid #000;margin: 1px;padding:1px;"><input type="checkbox" name="item[]" id="ci__1363_6459" value="6459"><label for="ci__1363_6459"> Bacon</label><input type="text" name="price[6459]" id="price__1363_6459" value="1.50,2.50,3.50,4.00"></li></ul>
				<input type="submit" id="submit_1363">
				<input type="hidden" name="id" value="1363">
				<input type="hidden" name="restaurant" value="132">
				<input type="hidden" name="lang" value="fr">
				<a onclick="return confirm('Really delete?')" id="del_1363" href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=132&amp;load=ingredientGroups&amp;showLang=fr&amp;action=delete&amp;group=1363">Delete</a>
			</form>
		</div>

- modifier_groups.category = <option value="ci" selected="">Custom Ingredients</option>
- Source system= 1363 in <a href="#" onclick="$('div_1363').toggle();return false;">Pizza Toppings FR</a>

### French Modifier Groups: JavaScript Data Analysis

The French modifier groups page works **identically** to the English version. Active modifiers are determined by JavaScript arrays, not HTML checkbox states.

#### JavaScript Arrays for Mozza Pizza Gatineau (V1 ID 132)

| Group ID | Name | Category | Active Modifier IDs |
|----------|------|----------|---------------------|
| 1363 | Pizza Toppings FR | ci | 6465, 6466, 6467, 6468, 6469, 6470, 6471, 6472, 6473, 6477, 6474, 6478, 6460, 6461, 6462, 6463, 6457, 6458, 6459 |
| 1364 | Pizza Toppings without Premium | ci | 6465, 6466, 6467, 6468, 6469, 6470, 6471, 6472, 6473, 6477 |
| 1365 | Premium Toppings | ci | 6474, 6478, 6460, 6461, 6462, 6463, 6457, 6458, 6459 |
| 1366 | Pizza Crust Type | br | 6840, 6479, 6483, 6481, 6482 |
| 1367 | Pizza Crust Type without Stuffed crust | br | 6840, 6479, 6483, 39688 |
| 1368 | Pizza Dips | sa | 6484, 6485, 6486, 6487 |
| 1369 | Wings Sauces Fr | sa | 6488, 6489, 6490 |
| 1370 | Wings Poutine | e | 6491 |

#### Key Pattern: `objItem{group_id}` and `objPrice{group_id}`

```javascript
// Example: Pizza Toppings FR (Group 1363)
var objItem1363 = ["6465","6466","6467","6468","6469","6470","6471","6472","6473","6477","6474","6478","6460","6461","6462","6463","6457","6458","6459"];
var objPrice1363 = {"6465":"1.00,1.50,2.00,2.50","6466":"1.00,1.50,2.00,2.50",...};

// Example: Pizza Dips (Group 1368)
var objItem1368 = ["6484","6485","6486","6487"];
var objPrice1368 = {"6484":"1.99","6485":"1.99","6486":"1.99","6487":"1.99"};
```

#### French Multi-Size Pricing

French menus commonly have 4 pizza sizes (matching course options):
- **Petite** (Small)
- **Moyenne** (Medium)  
- **Grande** (Large)
- **X-Grande** (Extra-Large)

Price format: `"1.00,1.50,2.00,2.50"` → Small, Medium, Large, XL

```python
# Example extraction for modifier 6465 (Poivrons Verts)
prices = "1.00,1.50,2.00,2.50".split(",")
# Result: 
#   size_variant="Petite", price=1.00, display_order=0
#   size_variant="Moyenne", price=1.50, display_order=1
#   size_variant="Grande", price=2.00, display_order=2
#   size_variant="X-Grande", price=2.50, display_order=3
```

#### Edge Case: Sparse Pricing

Some modifiers have sparse prices with empty values:

```javascript
// Group 1367 has sparse pricing
var objPrice1367 = {"6840":"0.00","6479":"0.00","6483":"0.00","39688":",3.99,,"};
```

For modifier 39688 with price `",3.99,,"`:
- Index 0 (Petite): empty → use `0.00` or skip
- Index 1 (Moyenne): `3.99`
- Index 2 (Grande): empty → use `0.00` or skip
- Index 3 (X-Grande): empty → use `0.00` or skip

#### Expand French Modifier Groups Before Scraping

Same as English - divs are collapsed by default:

```html
<div id="div_1363" style="... display: none;">
```

**Solution:**
```python
# Force visibility for all French modifier group divs
await page.evaluate('''
    document.querySelectorAll('div[id^="div_"]').forEach(div => {
        div.style.display = 'block';
    });
''')
```

#### Cross-Reference Active Status (Same as English)

For each modifier in HTML, check if its ID exists in the corresponding `objItem{group_id}` array:

```python
import re

# Extract all objItem arrays from page
page_content = await page.content()
obj_item_pattern = r'var objItem(\d+) = \[(.*?)\];'

for match in re.finditer(obj_item_pattern, page_content):
    group_id = match.group(1)
    active_ids = [id.strip('"\'') for id in match.group(2).split(',') if id.strip()]
    
    # Only scrape modifiers whose ID is in active_ids
```

#### Example: Pizza Toppings FR (Group 1363)

| Modifier ID | Name | In objItem1363? | Price(s) | is_active |
|-------------|------|-----------------|----------|-----------|
| 39689 | Jambon HIDE | ❌ No | 0.00 | false (SKIP) |
| 39690 | Poulet HIDE | ❌ No | 0.00 | false (SKIP) |
| 6465 | Poivrons Verts | ✅ Yes | 1.00,1.50,2.00,2.50 | **true** |
| 6466 | Piments Forts | ✅ Yes | 1.00,1.50,2.00,2.50 | **true** |
| 6457 | Pepperoni | ✅ Yes | 1.50,2.50,3.50,4.00 | **true** |

#### Data Mapping Summary (French)

| V3 Table | Column | Source | Example |
|----------|--------|--------|---------|
| modifier_groups | name | `input[name="name"]` | `Pizza Toppings FR` |
| modifier_groups | category | `select[name="type"] option[selected]` | `ci` |
| modifier_groups | source_system | `div` id suffix | `1363` |
| modifiers | name | `label` text | `Poivrons Verts` |
| modifiers | is_active | ID in `objItem{group_id}` | `true` |
| modifier_prices | price | `objPrice{group_id}[id]` or `input[name="price[id]"]` | `1.00` |
| modifier_prices | size_variant | Position in comma-separated price | `Petite` |

---

## Link English dishes to modifier groups and get modifier group details
  c. For each dish:
      - Scrape assigned modifier groups → INSERT INTO dish_modifier_groups
      - Link existing modifier_group_details → UPDATE dish_modifier_group_id

The URL for each dish of each restaurant is composed by:

https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=973&load=editDish&showLang=en&menuEntry=105963

Where: 
- restaurant=973 references the legacy_v1_id of each restaurant (For this example we are referencing Amicci Pizza (Id 735)).
-  showLang=en indicates that the menu is in English 
-  menuEntry=105963 references the source_id of each dish (For this example we are referencing the dish Cheese Pizza (V3 ID 132351))

Access this url using:
- restaurant= legacy_V1_id of each of the English restaurants to be scraped 
- menuEntry= menuca_V3.dishes.source_id of each dish for the current restaurant to be scraped

### Link modifier groups to each dish:
All modifier groups and their categories are stored in this div element:

<div style="margin-left:300px" id="groups">



Each modifier group is logically organized by category. For example, one of the modifier groups for the Cheese Pizza dish is Pizza Toppings (v3 id 28 source_system 9876):
This modifier group is located under the Custom Ingredients category:
<p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px">Custom Ingredients</p>

<div class="ingredientGroups" id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">
    	    <ul id="ulci" style="list-style-type:none;overflow: hidden">		    		    
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9876').show();}" type="radio" name="ci_radio" value="9876" id="radio_ci_9876">
	    			<label for="radio_ci_9876">Pizza Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:" id="list_ci_9876">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9876][44965]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9876][44966]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9876][44967]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9876][44968]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Olives					    					    <input type="text" size="5" name="ci[9876][44969]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9876][44970]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9876][44971]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9876][44972]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9876][44973]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9876][44974]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fresh Garlic					    					    <input type="text" size="5" name="ci[9876][44975]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cauliflower					    					    <input type="text" size="5" name="ci[9876][44976]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Broccoli					    					    <input type="text" size="5" name="ci[9876][44977]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9876][44978]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Shrimp					    					    <input type="text" size="5" name="ci[9876][44979]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Scallops					    					    <input type="text" size="5" name="ci[9876][44980]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9876][44981]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[9876][44982]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[9876][44983]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>			
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9877').show();}" type="radio" name="ci_radio" value="9877" id="radio_ci_9877">
	    			<label for="radio_ci_9877">Pizza Toppings without Premium</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9877">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9877][44965]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9877][44966]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9877][44967]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9877][44968]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Olives					    					    <input type="text" size="5" name="ci[9877][44969]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9877][44970]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9877][44971]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9877][44972]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9877][44973]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9877][44974]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fresh Garlic					    					    <input type="text" size="5" name="ci[9877][44975]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cauliflower					    					    <input type="text" size="5" name="ci[9877][44976]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Broccoli					    					    <input type="text" size="5" name="ci[9877][44977]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9877][44978]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Shrimp					    					    <input type="text" size="5" name="ci[9877][44979]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Scallops					    					    <input type="text" size="5" name="ci[9877][44980]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9877][44981]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>						    
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9878').show();}" type="radio" name="ci_radio" value="9878" id="radio_ci_9878">
	    			<label for="radio_ci_9878">Premium Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9878">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[9878][44982]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[9878][44983]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>
					        	   </ul>
    	</div>

Notice that the <input> element for Pizza Toppings (v3 id 28 source_system 9876) is checked (checked=""):
<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9876').show();}" type="radio" name="ci_radio" value="9876" id="radio_ci_9876">

This is your main way of identifying which modifier groups are active for a given dish and therefore should be linked to the Cheese Pizza dish throguh the dish_modifier_groups junction table. The Custom Ingredients category have 2 other modifier groups:
<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9877').show();}" type="radio" name="ci_radio" value="9877" id="radio_ci_9877">
	    			<label for="radio_ci_9877">Pizza Toppings without Premium</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9877">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9877][44965]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9877][44966]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9877][44967]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9877][44968]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Olives					    					    <input type="text" size="5" name="ci[9877][44969]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9877][44970]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9877][44971]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9877][44972]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9877][44973]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9877][44974]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fresh Garlic					    					    <input type="text" size="5" name="ci[9877][44975]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cauliflower					    					    <input type="text" size="5" name="ci[9877][44976]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Broccoli					    					    <input type="text" size="5" name="ci[9877][44977]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9877][44978]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Shrimp					    					    <input type="text" size="5" name="ci[9877][44979]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Scallops					    					    <input type="text" size="5" name="ci[9877][44980]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9877][44981]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>

<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9878').show();}" type="radio" name="ci_radio" value="9878" id="radio_ci_9878">
	    			<label for="radio_ci_9878">Premium Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9878">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[9878][44982]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[9878][44983]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>

Notice how the input element of these modifier groups is not checked, therefore they should not be assigned to the Cheese Pizza dish. 

Do this proces for each category and modifier group inside <div style="margin-left:300px" id="groups">

### Get the modifier_group_details:
The data that we need to scrape for the modifier_group_details (min_selections, max_selections, free_items, display_order) is located within this html section:

<li>
		<p><input type="checkbox" id="hasBread" name="hasBread" value="Y" onclick="if(this.checked){ $('breadNo').show();$('br_id').appear() } else { $('br_id').fade(); $('breadNo').hide() }"> <label for="hasBread">Has Bread</label></p>
		<p id="breadNo" style="display: none;padding-left:20px">
			<label for="breadHeader">Use this title</label><input type="text" name="breadHeader" id="breadHeader" value="Bread Selection"><br>
		    <label for="displayOrderBread">Display Order</label><input type="text" name="displayOrderBread" id="displayOrderBread" value="1" size="3">
		</p>
		<p><input type="checkbox" id="hasCustomisation" name="hasCustomisation" checked="" value="Y" onclick="if(this.checked){ $('ciNo').show();$('ci_id').appear() } else { $('ci_id').fade(); $('ciNo').hide() }"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
		<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="Add more toppings"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
		</p>
		<p><input type="checkbox" id="hasDressing" name="hasDressing" value="Y" onclick="if(this.checked){ $('dressingNo').show();$('dr_id').appear() } else { $('dr_id').fade(); $('dressingNo').hide() }"> <label for="hasDressing">Has Dressing</label></p>
		<p id="dressingNo" style="display: none;padding-left:20px">
			<label for="dressingHeader">Use this title</label><input type="text" name="dressingHeader" id="dressingHeader" value="Dressing"><br>
		    <label for="minDressing" style="display: inline">Min dressings: </label><input type="text" name="mindressing" id="minDressing" size="3" value="1"><br>
		    <label for="maxDressing" style="display: inline">Max dressings: </label><input type="text" name="maxdressing" id="maxDressing" size="3" value="1"><br>
		    <label for="freeDressing" style="display: inline">Free items: </label><input type="text" name="freeDressing" id="freeDressing" size="3" value="0"><br>
		    <label for="displayOrderDressing">Display Order</label><input type="text" name="displayOrderDressing" id="displayOrderDressing" value="3" size="3">
		</p>
		<p><input type="checkbox" id="hasSauce" name="hasSauce" checked="" value="Y" onclick="if(this.checked){ $('sauceNo').show();$('sa_id').appear() } else { $('sa_id').fade(); $('sauceNo').hide() }"> <label for="hasSauce">Has Sauce</label></p>
		<p id="sauceNo" style="padding-left: 20px;">
			<label for="sauceHeader">Use this title</label><input type="text" name="sauceHeader" id="sauceHeader" value="Dips"><br>
		    <label for="minSauce" style="display: inline">Min sauces: </label><input type="text" name="minsauce" id="minSauce" size="3" value="0"><br>
		    <label for="maxSauce" style="display: inline">Max sauces: </label><input type="text" name="maxsauce" id="maxSauce" size="3" value="0"><br>
		    <label for="freeSauce" style="display: inline">Free items: </label><input type="text" name="freeSauce" id="freeSauce" size="3" value="0"><br>
		    <label for="displayOrderSauce">Display Order</label><input type="text" name="displayOrderSauce" id="displayOrderSauce" value="4" size="3">
		</p>
		<p><input type="checkbox" id="hasSideDish" name="hasSideDish" onclick="if(this.checked){ $('sdNo').show();$('sd_id').appear() } else { $('sd_id').fade(); $('sdNo').hide() }" value="Y"> <label for="hasSideDish">Has Side Dishes</label></p>
		<p id="sdNo" style="display: none;padding-left:20px">
			<label for="sideDishHeader">Use this title</label><input type="text" name="sideDishHeader" id="sideDishHeader" value="Side Dish"><br>
		    <label for="minSD" style="display: inline">Min side dishes: </label><input type="text" name="minsd" id="minSD" size="3" value="1"><br>
		    <label for="maxSD" style="display: inline">Max side dishes: </label><input type="text" name="maxsd" id="maxSD" size="3" value="1"><br>
		    <label for="freeSD" style="display: inline">Free items: </label><input type="text" name="freeSD" id="freeSD" size="3" value="0"><br>
		    <label for="displayOrderSD">Display Order</label><input type="text" name="displayOrderSD" id="displayOrderSD" value="5" size="3">
		</p>
		<p><input type="checkbox" id="hasDrinks" name="hasDrinks" onclick="if(this.checked){ $('d_id').appear();$('drinksNo').show(); } else { $('d_id').fade();$('drinksNo').hide() }" value="Y"> <label for="hasDrinks">Has Drinks</label></p>
		<p id="drinksNo" style="display: none;padding-left:20px">
			<label for="drinksHeader">Use this title</label><input type="text" name="drinksHeader" id="drinksHeader" value="Drinks"><br>
		    <label for="minDrink" style="display: inline">Min drinks: </label><input type="text" name="mindrink" id="minDrink" size="3" value="1"><br>
		    <label for="maxDrink" style="display: inline">Max drinks: </label><input type="text" name="maxdrink" id="maxDrink" size="3" value="1"><br>
		    <label for="freeDrink" style="display: inline">Free items: </label><input type="text" name="freeDrink" id="freeDrink" size="3" value="0"><br>
		    <label for="displayOrderDrink">Display Order</label><input type="text" name="displayOrderDrink" id="displayOrderDrink" value="6" size="3">
		</p>
		<p><input type="checkbox" id="hasExtras" name="hasExtras" value="Y" onclick="if(this.checked){ $('extraNo').show();$('e_id').appear() } else { $('e_id').fade(); $('extraNo').hide() }"> <label for="hasExtras">Has Extras</label></p>
		<p id="extraNo" style="display: none;padding-left:20px">
			<label for="extraHeader">Use this title</label><input type="text" name="extraHeader" id="extraHeader" value="Extras"><br>
		    <label for="minExtra" style="display: inline">Min extras: </label><input type="text" name="minextras" id="minExtra" size="3" value="1"><br>
		    <label for="maxExtra" style="display: inline">Max extras: </label><input type="text" name="maxextras" id="maxExtra" size="3" value="1"><br>
		    <label for="freeExtra" style="display: inline">Free items: </label><input type="text" name="freeExtra" id="freeExtra" size="3" value="0"><br>
		    <label for="displayOrderExtras">Display Order</label><input type="text" name="displayOrderExtras" id="displayOrderExtras" value="7" size="3">
		</p>
		<p><input type="checkbox" id="hasCookMethod" name="hasCookMethod" value="Y" onclick="if(this.checked){ $('cmNo').show();$('cm_id').appear(); } else { $('cm_id').fade(); $('cmNo').hide() }"> <label for="hasCookMethod">Has Cooking Method</label></p>
		<p id="cmNo" style="display: none;padding-left:20px">
			<label for="cmHeader">Use this title</label><input type="text" name="cmHeader" id="cmHeader" value="Cooking Method"><br>
		    <label for="displayOrderCM">Display Order</label><input type="text" name="displayOrderCM" id="displayOrderCM" value="8" size="3">
		</p>
		<p>
		    <input type="checkbox" id="showPizzaIcons" value="Y" name="showPizzaIcons" checked=""> <label for="showPizzaIcons">Show Pizza Icons</label>
		</p>
		<p>
		    <input type="checkbox" id="showInMenu" value="Y" name="showInMenu" checked=""> <label for="showInMenu">Show dish in menu</label>
		</p>
                <p>
                    <input type="checkbox" id="checkoutItems" value="Y" name="checkoutItems"> <label for="checkoutItems">Checkout Items</label>
                </p>
        <p>
        	<input type="checkbox" id="upsell" value="y" name="upsell"> <label for="upsell">Upsell</label>
        </p>
		<p>
		    <a href="#" id="attachCourse">Attach course name to dish name</a>
		</p>
	    </li>

Use the id of each active modifier to map to its respective details section. For example, The Pizza Toppings modifier group is contained in a <div> element with an id=ci_id:

<div class="ingredientGroups" id="ci_id" style="border-width: 0px 1px 1px; border-style: solid; border-color: rgb(170, 170, 170); margin-bottom: 2px; padding: 1px;">
    	    <ul id="ulci" style="list-style-type:none;overflow: hidden">		    						    
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input checked="" onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9876').show();}" type="radio" name="ci_radio" value="9876" id="radio_ci_9876">
	    			<label for="radio_ci_9876">Pizza Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:" id="list_ci_9876">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9876][44965]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9876][44966]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9876][44967]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9876][44968]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Olives					    					    <input type="text" size="5" name="ci[9876][44969]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9876][44970]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9876][44971]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9876][44972]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9876][44973]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9876][44974]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fresh Garlic					    					    <input type="text" size="5" name="ci[9876][44975]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cauliflower					    					    <input type="text" size="5" name="ci[9876][44976]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Broccoli					    					    <input type="text" size="5" name="ci[9876][44977]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9876][44978]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Shrimp					    					    <input type="text" size="5" name="ci[9876][44979]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Scallops					    					    <input type="text" size="5" name="ci[9876][44980]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9876][44981]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[9876][44982]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[9876][44983]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>						    
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9877').show();}" type="radio" name="ci_radio" value="9877" id="radio_ci_9877">
	    			<label for="radio_ci_9877">Pizza Toppings without Premium</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9877">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pepperoni					    					    <input type="text" size="5" name="ci[9877][44965]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Mushrooms					    					    <input type="text" size="5" name="ci[9877][44966]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Green Peppers					    					    <input type="text" size="5" name="ci[9877][44967]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Onions					    					    <input type="text" size="5" name="ci[9877][44968]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Olives					    					    <input type="text" size="5" name="ci[9877][44969]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Tomatoes					    					    <input type="text" size="5" name="ci[9877][44970]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Ham					    					    <input type="text" size="5" name="ci[9877][44971]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Pineapple					    					    <input type="text" size="5" name="ci[9877][44972]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Bacon					    					    <input type="text" size="5" name="ci[9877][44973]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Black Olives					    					    <input type="text" size="5" name="ci[9877][44974]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Fresh Garlic					    					    <input type="text" size="5" name="ci[9877][44975]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Cauliflower					    					    <input type="text" size="5" name="ci[9877][44976]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Broccoli					    					    <input type="text" size="5" name="ci[9877][44977]" value="1.25,1.75,2.25,2.50">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Italian Sausage					    					    <input type="text" size="5" name="ci[9877][44978]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Shrimp					    					    <input type="text" size="5" name="ci[9877][44979]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Scallops					    					    <input type="text" size="5" name="ci[9877][44980]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Chicken					    					    <input type="text" size="5" name="ci[9877][44981]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>			    
	    		<li>
	    		    <p style="height:20px;line-height:1.5;background-color: #ccc;padding-left:10px;border:1px solid #aaa;margin-top:1px;">
	    			<input onclick="$$('#ulci ul[class=\'ci\']').each(function(u){$(u.id).hide()}); if(this.checked){ $('list_ci_9878').show();}" type="radio" name="ci_radio" value="9878" id="radio_ci_9878">
	    			<label for="radio_ci_9878">Premium Toppings</label>
	    		    </p>
	    		    <ul class="ci" style="list-style-type: none; overflow: hidden;display:none" id="list_ci_9878">
				    					<li style="width:30%; float: left;padding-left:2px">
					    Feta Cheese					    					    <input type="text" size="5" name="ci[9878][44982]" value="2.00,3.00,4.00,5.00">
					</li>
				    					<li style="width:30%; float: left;padding-left:2px">
					    Extra Cheese					    					    <input type="text" size="5" name="ci[9878][44983]" value="2.00,3.00,4.00,5.00">
					</li>
				    	    		    </ul>
	    		</li>
					        	   </ul>
    	</div>

This same id can be found in this element:
<p><input type="checkbox" id="hasCustomisation" name="hasCustomisation" checked="" value="Y" onclick="if(this.checked){ $('ciNo').show();$('ci_id').appear() } else { $('ci_id').fade(); $('ciNo').hide() }"> <label for="hasCustomisation">Has Custom Ingredients</label></p>
<p id="ciNo" style="padding-left: 20px;">
			<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="Add more toppings"><br>
		    <label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>
		    <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>
		    <label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>
		    <label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">
		</p>

modifier_group_details.name:
<label for="ciHeader">Use this title</label><input type="text" name="ciHeader" id="ciHeader" value="Add more toppings">

modifier_group_details.min_selections:
<label for="minci" style="display: inline">Min custom items: </label><input type="text" name="minci" id="minci" size="3" value="0"><br>

modifier_group_details.max_selections:
 <label for="maxci" style="display: inline">Max custom items: </label><input type="text" name="maxci" id="maxci" size="3" value="0"><br>

modifier_group_details.free_items:
<label for="freeCI" style="display: inline">Free items: </label><input type="text" name="freeci" id="freeCI" size="3" value="0"><br>

modifier_group_details.display_order:
<label for="displayOrderCI">Display Order</label><input type="text" name="displayOrderCI" id="displayOrderCI" value="2" size="3">




## Link French dishes to modifier groups and get modifier group details
The URL for each dish of each restaurant is composed by:

https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=132&load=editDish&showLang=fr&menuEntry=13208

Where
- restaurant=132 references the legacy_v1_id of each restaurant (For this example we are referencing   V3 ID 1011  Mozza Pizza Gatineau).
- showLang=fr indicates that the menu is in French
- menuEntry=13208  references the source_id of each dish (For this example we are referencing the dish Mozzarella Pizza (V3 ID 162046))

Access this url using:
- restaurant= legacy_V1_id of each of the English restaurants to be scraped 
- menuEntry= menuca_V3.dishes.source_id of each dish for the current restaurant to be scraped

### Link modifier groups to each dish:
All modifier groups and their categories are stored in this div element:

<div style="margin-left:300px" id="groups">
