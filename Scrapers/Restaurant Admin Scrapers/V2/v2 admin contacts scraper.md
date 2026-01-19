Now, instead of me giving you detailed instructions about how to navigate the V2 CRM I want you leverage on the URLs for modifier groups and dishes. 

# Restaurants to scrape:
V3 ID	Restaurant Name	V2 ID
147	Pho Dau Bo Restaurant - Kitchener	1171
1020	Sushi Presse	1285
950	Kirkwood Pizza	1637
952	River Pizza	1639
954	Wandee Thai	1641
825	La Nawab	1642
957	Cosenza	1654
960	Cuisine Bombay Indienne	1657
961	Chicco Shawarma Cantley	1658
963	Chicco Pizza Shawarma Anger	1660
964	Chicco Pizza Maloney	1661
965	Chicco Shawarma Maloney	1662
966	Chicco Pizza de l'Hopital	1663
967	Chicco Pizza St-Louis	1664
971	Little Gyros Greek Grill	1668
973	Capital Bites	1670
974	Pachino Pizza	1671
976	Pizza Marie	1673
977	Capri Pizza	1674
981	Al-s Drive In	1678

# Instructions:
## Login to the V2 CRM:
<form action="https://aggregator-admin.menu.ca/index.php/auth/index" id="loginForm" autocomplete="off" method="post" accept-charset="utf-8">
	<h2 class="text-center mb-4">Sign in to your account</h2>
	<p class="mb-1">Enter your <span class="font-weight-bold">email address</span> and <span class="font-weight-bold">password</span>.</p>
	<div class="form-group has-feedback">
		<input placeholder="email address" type="email" class="form-control form-control-lg" name="email">
	</div>
	<div class="form-group has-feedback">
		<input placeholder="password" type="password" name="password" class="form-control form-control-lg">
	</div>
	<div class="form-group">
		<button type="submit" class="btn btn-danger btn-block">Sign in</button>
	</div>
</form>

## Scrape Restaurant contacts
The URL to access the Account info for each restaurant is 
https://aggregator-admin.menu.ca/index.php/restaurants/edit/[legacy_v2_id]/info



Search for this html element:
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" id="owner-info" style="" role="widget">
    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
        <h2>Owner info</h2>
    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
    <div role="content">
        <div class="widget-body" style="overflow-y: hidden">
                                            <table class="table table-condensed table-striped">
                    <thead>
                    <tr>
                        <th></th>
                        <th>Name</th>
                        <th>Email address</th>
                        <th nowrap="">Phone number</th>
                        <th>Statements</th>
                    </tr>
                    </thead>
                    <tfoot>
                                                            <tr>
                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/77" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                            </td>
                            <td>Mohammed Amer</td>
                            <td>callamer@gmail.com</td>
                            <td nowrap=""><a href="tel:(613) 612-1478">(613) 612-1478</a></td>
                            <td>Yes</td>
                        </tr>
                                                        </tfoot>
                </table>
            
        </div>
    </div>
</div>

admin_users.email: <td>callamer@gmail.com</td>

admin_users.first_name and admin_users.last_name: <td>Mohammed Amer</td>

For the first_name and last_name values take the first string of the value attribute and set it as first_name and take the second part as last name

admin_users.phone: <td nowrap=""><a href="tel:(613) 612-1478">(613) 612-1478</a></td>

set admin_users.staus to active
 

# Edge cases:
## Restaurants with no contact information: 
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" id="owner-info" role="widget">
                    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                        <h2>Owner info</h2>
                    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                    <div role="content">
                        <div class="widget-body" style="overflow-y: hidden">
                            
                        </div>
                    </div>
                </div>


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

## Restaurants with two or more Restaurant contacts with different email:
Create separate records and link both records to the same restaurant:
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" id="owner-info" role="widget">
    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
        <h2>Owner info</h2>
    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
    <div role="content">
        <div class="widget-body" style="overflow-y: hidden">
                                            <table class="table table-condensed table-striped">
                    <thead>
                    <tr>
                        <th></th>
                        <th>Name</th>
                        <th>Email address</th>
                        <th nowrap="">Phone number</th>
                        <th>Statements</th>
                    </tr>
                    </thead>
                    <tfoot>
                                                            <tr>
                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/50" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                            </td>
                            <td>alex nico</td>
                            <td>alexandra.nicolae000@gmail.com</td>
                            <td nowrap=""><a href="tel:"></a></td>
                            <td>Yes</td>
                        </tr>
                                                            <tr>
                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/56" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                            </td>
                            <td>Laura Paniagua</td>
                            <td>laura_paniagua513@hotmail.com</td>
                            <td nowrap=""><a href="tel:(514) 447-2982">(514) 447-2982</a></td>
                            <td>Yes</td>
                        </tr>
                                                            <tr>
                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/85" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                            </td>
                            <td>Sushi Presse</td>
                            <td>sushipressebeaubien@hotmail.com</td>
                            <td nowrap=""><a href="tel:(514) 313-6291">(514) 313-6291</a></td>
                            <td>Yes</td>
                        </tr>
                                                        </tfoot>
                </table>
        </div>
    </div>
</div>

## Do not scrape contacts that include the word test in their email or address
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" id="owner-info" role="widget">
                    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                        <h2>Owner info</h2>
                    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                    <div role="content">
                        <div class="widget-body" style="overflow-y: hidden">
                                                            <table class="table table-condensed table-striped">
                                    <thead>
                                    <tr>
                                        <th></th>
                                        <th>Name</th>
                                        <th>Email address</th>
                                        <th nowrap="">Phone number</th>
                                        <th>Statements</th>
                                    </tr>
                                    </thead>
                                    <tfoot>
                                                                            <tr>
                                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/48" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                                            </td>
                                            <td>test alex</td>
                                            <td>alexandra9nicolae@gmail.com</td>
                                            <td nowrap=""><a href="tel:"></a></td>
                                            <td>Yes</td>
                                        </tr>
                                                                            <tr>
                                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/76" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                                            </td>
                                            <td>Chem Kirwood</td>
                                            <td>kirkwoodottawapizza@gmail.com</td>
                                            <td nowrap=""><a href="tel:(613) 255-2323">(613) 255-2323</a></td>
                                            <td>Yes</td>
                                        </tr>
                                                                            <tr>
                                            <td><a href="https://aggregator-admin.menu.ca/index.php/users/useredit/72" class="btn btn-default btn-xs"><i class="fa fa-fw fa-edit"></i></a>
                                            </td>
                                            <td>TEST ALEX</td>
                                            <td>alexandra9nicolae@gmail.com</td>
                                            <td nowrap=""><a href="tel:"></a></td>
                                            <td>No</td>
                                        </tr>
                                                                        </tfoot>
                                </table>
                        </div>
                    </div>
                </div>