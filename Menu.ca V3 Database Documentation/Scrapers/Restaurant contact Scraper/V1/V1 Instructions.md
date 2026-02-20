The purpose of this scraper is to scrape the restaurant contact information from the V1 CRM and store it in the menuca_v3.restaurant_locations table.

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

## Scrape Restaurant contacts
The URL to access the Account info for each restaurant is 
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=781

Where:
- restaurant=781 references the legacy_v1_id of each restaurant (For this example we are referencing Aahar The Taste of India v3 id 561).

Search for this form element:
<form action="?p=restaurants&amp;display=editRestaurant&amp;action=updateRestaurant&amp;load=ri" method="post" enctype="multipart/form-data">

restaurant_locations.phone: <li><label for="phone">Phone</label><input class="long" type="text" name="phone" id="phone" value="(613) 422-6644"></li>

restaurant_locations.email: <li><label for="mainEmail">Email address</label><input class="long" type="text" name="mainEmail" id="mainEmail" value="rupinder.pal@hotmail.com"></li>

If the current value of restaurant_locations.phone or restaurant_locations.email is not the same as the value in the form, update the value in the database. Otherwise, skip the update.