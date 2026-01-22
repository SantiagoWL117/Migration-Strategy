
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

# Scrape Restaurant commissions:
The URL to access the commissions data for each v1 restaurant is:
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=781&load=cfg&showLang=en

Where:
- restaurant=781 references the legacy_v1_id of each restaurant (For this example we are referencing Aahar The Taste of India v3 id 561).

Search for this elements:
For restaurant_commission_configs.commission_rate:
<tr>
    <td><label style="display: block" for="commission">Commission value (%)</label><input type="text" name="commission" value="7" id="commission">
    </td>
</tr>

For restaurant_commission_configs.commission_base (select the checked option):
<td><label style="display: block">Take commission from</label>
    <input type="radio" name="commission_from" value="g" id="commission_g"><label for="commission_g">Gross value</label>
    <input type="radio" name="commission_from" value="n" id="commission_n" checked=""><label for="commission_n">Net value</label>
</td>



