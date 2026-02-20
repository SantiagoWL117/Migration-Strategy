


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
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=781&load=account_information&showLang=en

Where:
- restaurant=781 references the legacy_v1_id of each restaurant (For this example we are referencing Aahar The Taste of India v3 id 561).

Search for this html element:
<fieldset style="border: 1px solid #000; padding: 5px;">
    <legend style="margin-left: 10px; padding: 0 2px;">Restaurant Contacts</legend>
    <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;load=account_information&amp;action=addContact" method="post">
	<ul class="account_information">
	    <li><label for="contact">Contact Name</label><input type="text" name="contact" id="contact"></li>
	    <li><label for="title">Title</label><select name="title" id="title"><option value="owner">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone">Phone</label><input type="text" name="phone" id="phone"></li>
	    <li><label for="email">Email</label><input type="text" name="email" id="email"></li>
	    <li>
		<input type="submit" value="Save">
		<input type="hidden" name="restaurant" value="781">
	    </li>
	</ul>
    </form>
    <hr style="margin: 5px 0;">
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_651">Contact Name</label><input type="text" name="contact" id="contact_651" value="Rupinder Pal"></li>
	    <li><label for="title_651">Title</label><select name="title" id="title_651"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_651">Phone</label><input type="text" name="phone" id="phone_651" value="613-794-3444"></li>
	    <li><label for="email_651">Email</label><input type="text" name="email" id="email_651" value="rupinder.pal@hotmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;load=account_information&amp;action=deleteContact&amp;contact=651">Delete</a>
		<input type="hidden" name="id" value="651">
		<input type="hidden" name="restaurant" value="781">
	    </li>
	</ul>
    </form>
    </fieldset>

admin_users.email: <li><label for="email_651">Email</label><input type="text" name="email" id="email_651" value="rupinder.pal@hotmail.com"></li>

admin_users.first_name and admin_users.last_name: <li><label for="contact_651">Contact Name</label><input type="text" name="contact" id="contact_651" value="Rupinder Pal"></li>

For the first_name and last_name values take the first string of the value attribute and set it as first_name and take the second part as last name

admin_users.phone: <li><label for="phone_651">Phone</label><input type="text" name="phone" id="phone_651" value="613-794-3444"></li>

set admin_users.staus to active
 

# Edge cases:
## Restaurants with no contact information: 
The restaurant id 833 has no contact information and should be skiped:
<fieldset style="border: 1px solid #000; padding: 5px;">
    <legend style="margin-left: 10px; padding: 0 2px;">Restaurant Contacts</legend>
    <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=1080&amp;load=account_information&amp;action=addContact" method="post">
	<ul class="account_information">
	    <li><label for="contact">Contact Name</label><input type="text" name="contact" id="contact"></li>
	    <li><label for="title">Title</label><select name="title" id="title"><option value="owner">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone">Phone</label><input type="text" name="phone" id="phone"></li>
	    <li><label for="email">Email</label><input type="text" name="email" id="email"></li>
	    <li>
		<input type="submit" value="Save">
		<input type="hidden" name="restaurant" value="1080">
	    </li>
	</ul>
    </form>
    <hr style="margin: 5px 0;">
    </fieldset>

## Restaurants with contacts with the same email:
Get the first record
<fieldset style="border: 1px solid #000; padding: 5px;">
    <legend style="margin-left: 10px; padding: 0 2px;">Restaurant Contacts</legend>
    <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=383&amp;load=account_information&amp;action=addContact" method="post">
	<ul class="account_information">
	    <li><label for="contact">Contact Name</label><input type="text" name="contact" id="contact"></li>
	    <li><label for="title">Title</label><select name="title" id="title"><option value="owner">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone">Phone</label><input type="text" name="phone" id="phone"></li>
	    <li><label for="email">Email</label><input type="text" name="email" id="email"></li>
	    <li>
		<input type="submit" value="Save">
		<input type="hidden" name="restaurant" value="383">
	    </li>
	</ul>
    </form>
    <hr style="margin: 5px 0;">
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=383&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_288">Contact Name</label><input type="text" name="contact" id="contact_288" value="Natalie Agha"></li>
	    <li><label for="title_288">Title</label><select name="title" id="title_288"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_288">Phone</label><input type="text" name="phone" id="phone_288" value="613-739-7777"></li>
	    <li><label for="email_288">Email</label><input type="text" name="email" id="email_288" value="benecipizzeria@gmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=383&amp;load=account_information&amp;action=deleteContact&amp;contact=288">Delete</a>
		<input type="hidden" name="id" value="288">
		<input type="hidden" name="restaurant" value="383">
	    </li>
	</ul>
    </form>
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=383&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_289">Contact Name</label><input type="text" name="contact" id="contact_289" value="Natalie Agha"></li>
	    <li><label for="title_289">Title</label><select name="title" id="title_289"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_289">Phone</label><input type="text" name="phone" id="phone_289" value="613-402-6875"></li>
	    <li><label for="email_289">Email</label><input type="text" name="email" id="email_289" value="benecipizzeria@gmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=383&amp;load=account_information&amp;action=deleteContact&amp;contact=289">Delete</a>
		<input type="hidden" name="id" value="289">
		<input type="hidden" name="restaurant" value="383">
	    </li>
	</ul>
    </form>
    </fieldset>

## Restaurants with two or more contacts but only one email:
<fieldset style="border: 1px solid #000; padding: 5px;">
    <legend style="margin-left: 10px; padding: 0 2px;">Restaurant Contacts</legend>
    <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=addContact" method="post">
	<ul class="account_information">
	    <li><label for="contact">Contact Name</label><input type="text" name="contact" id="contact"></li>
	    <li><label for="title">Title</label><select name="title" id="title"><option value="owner">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone">Phone</label><input type="text" name="phone" id="phone"></li>
	    <li><label for="email">Email</label><input type="text" name="email" id="email"></li>
	    <li>
		<input type="submit" value="Save">
		<input type="hidden" name="restaurant" value="255">
	    </li>
	</ul>
    </form>
    <hr style="margin: 5px 0;">
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_136">Contact Name</label><input type="text" name="contact" id="contact_136" value="Scott Budden"></li>
	    <li><label for="title_136">Title</label><select name="title" id="title_136"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_136">Phone</label><input type="text" name="phone" id="phone_136" value="613-252-7414"></li>
	    <li><label for="email_136">Email</label><input type="text" name="email" id="email_136" value="scottd.budden@gmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=deleteContact&amp;contact=136">Delete</a>
		<input type="hidden" name="id" value="136">
		<input type="hidden" name="restaurant" value="255">
	    </li>
	</ul>
    </form>
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_947">Contact Name</label><input type="text" name="contact" id="contact_947" value="Terry-lynn"></li>
	    <li><label for="title_947">Title</label><select name="title" id="title_947"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_947">Phone</label><input type="text" name="phone" id="phone_947" value="819-923-8985"></li>
	    <li><label for="email_947">Email</label><input type="text" name="email" id="email_947" value=""></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=deleteContact&amp;contact=947">Delete</a>
		<input type="hidden" name="id" value="947">
		<input type="hidden" name="restaurant" value="255">
	    </li>
	</ul>
    </form>
    </fieldset>

Pick only the record with an email:
<ul class="account_information">
	    <li><label for="contact_136">Contact Name</label><input type="text" name="contact" id="contact_136" value="Scott Budden"></li>
	    <li><label for="title_136">Title</label><select name="title" id="title_136"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_136">Phone</label><input type="text" name="phone" id="phone_136" value="613-252-7414"></li>
	    <li><label for="email_136">Email</label><input type="text" name="email" id="email_136" value="scottd.budden@gmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=255&amp;load=account_information&amp;action=deleteContact&amp;contact=136">Delete</a>
		<input type="hidden" name="id" value="136">
		<input type="hidden" name="restaurant" value="255">
	    </li>
	</ul>

## Restaurants with two Restaurant contacts with different email:
Create two separate records and link both records to the same restaurant:
<fieldset style="border: 1px solid #000; padding: 5px;">
    <legend style="margin-left: 10px; padding: 0 2px;">Restaurant Contacts</legend>
    <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=489&amp;load=account_information&amp;action=addContact" method="post">
	<ul class="account_information">
	    <li><label for="contact">Contact Name</label><input type="text" name="contact" id="contact"></li>
	    <li><label for="title">Title</label><select name="title" id="title"><option value="owner">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone">Phone</label><input type="text" name="phone" id="phone"></li>
	    <li><label for="email">Email</label><input type="text" name="email" id="email"></li>
	    <li>
		<input type="submit" value="Save">
		<input type="hidden" name="restaurant" value="489">
	    </li>
	</ul>
    </form>
    <hr style="margin: 5px 0;">
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=489&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_382">Contact Name</label><input type="text" name="contact" id="contact_382" value="Raymond Aouad"></li>
	    <li><label for="title_382">Title</label><select name="title" id="title_382"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_382">Phone</label><input type="text" name="phone" id="phone_382" value="613-745-3377"></li>
	    <li><label for="email_382">Email</label><input type="text" name="email" id="email_382" value="vivo555@hotmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=489&amp;load=account_information&amp;action=deleteContact&amp;contact=382">Delete</a>
		<input type="hidden" name="id" value="382">
		<input type="hidden" name="restaurant" value="489">
	    </li>
	</ul>
    </form>
        <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=489&amp;load=account_information&amp;action=updateContact" method="post">
	<ul class="account_information">
	    <li><label for="contact_383">Contact Name</label><input type="text" name="contact" id="contact_383" value="Raymond Aouad"></li>
	    <li><label for="title_383">Title</label><select name="title" id="title_383"><option value="owner" selected="">Owner</option><option value="manager">Manager</option></select></li>
	    <li><label for="phone_383">Phone</label><input type="text" name="phone" id="phone_383" value="613-265-8131"></li>
	    <li><label for="email_383">Email</label><input type="text" name="email" id="email_383" value="jnray3377@gmail.com"></li>
	    <li>
		<input type="submit" value="Update">
		<a onclick="return confirm('Really delete this contact?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=489&amp;load=account_information&amp;action=deleteContact&amp;contact=383">Delete</a>
		<input type="hidden" name="id" value="383">
		<input type="hidden" name="restaurant" value="489">
	    </li>
	</ul>
    </form>
    </fieldset>