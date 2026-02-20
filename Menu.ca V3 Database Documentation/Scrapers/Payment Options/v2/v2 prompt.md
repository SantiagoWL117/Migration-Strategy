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

The URL to access the Payment options is 
https://aggregator-admin.menu.ca/index.php/restaurants/edit/[legacy_V2_id]/info

Use the legacy_v2_id of each v2 restaurant to access this url

Search for this element:
<div class="jarviswidget jarviswidget-color-darken jarviswidget-sortable" id="payment-info" role="widget">
    <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
        <h2>Payment options</h2>
    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
    <div role="content">
        <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurants/setPaymentOptions" method="post" id="form-payment">
            <input type="hidden" name="restaurant_id" id="payment_restaurant_id" value="1611">
            <table class="table table-condensed table-stripped table-bordered">
                <colgroup><col width="30%">
                <col width="35%">
                <col width="35%">
                </colgroup><thead>
                <tr>
                    <th>&nbsp;</th>
                    <th colspan="2" class="text-center">Override texts</th>
                </tr>
                <tr>
                    <th>Choose options</th>
                    <th>English</th>
                    <th>French</th>
                </tr>
                </thead>
                <tbody>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][1]" value="1" class="" checked="&quot;checked&quot;">
                                <span>Cash</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][1]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][1]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][2]" value="2" class="">
                                <span>Credit card</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][2]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][2]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][3]" value="3" class="">
                                <span>Interac</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][3]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][3]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][4]" value="4" class="">
                                <span>Credit or debit at door</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][4]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][4]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][904]" value="904" class="">
                                <span>Credit at door</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][904]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][904]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                    <tr>
                        <td>
                            <label>
                                <input type="checkbox" name="payment[options][905]" value="905" class="">
                                <span>Debit at door</span>
                            </label>
                        </td>
                        <td><input type="text" name="payment[name][1][905]" class="form-control input-xs" value="">
                        </td>
                        <td><input type="text" name="payment[name][2][905]" class="form-control input-xs" value="">
                        </td>
                    </tr>
                                                </tbody>
            </table>
            <div class="form-group text-right">
                <button type="submit" class="btn btn-primary">Update</button>
            </div>
        </form>
    </div>
</div>


restaurant_payment_options.payment_method: 
<td>
    <label>
        <input type="checkbox" name="payment[options][1]" value="1" class="" checked="&quot;checked&quot;">
        <span>Cash</span>
    </label>
</td>

restaurant_payment_options.english_label:
<td>
    <label>
        <input type="checkbox" name="payment[options][1]" value="1" class="" checked="&quot;checked&quot;">
        <span>Cash</span>
    </label>
</td>

restaurant_payment_options.display_order: 
Use the attribute name="paymentOption[en][display][1]" to extract the display order of each payment option.

restaurant_payment_options.is_enabled:
Some payment options are enabled and others are not. You should scrape all the options under
<header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                        <h2>Payment options</h2>
                    <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header> 


check for the checked="" attribute. Any payment option that is checked will look like this and therefore you must set the value of is_enabled to true :<tr>
<td>
        <label>
            <input type="checkbox" name="payment[options][1]" value="1" class="" checked="&quot;checked&quot;">
            <span>Cash</span>
        </label>
    </td>
    <td><input type="text" name="payment[name][1][1]" class="form-control input-xs" value="">
    </td>
    <td><input type="text" name="payment[name][2][1]" class="form-control input-xs" value="">
    </td>
</tr>

A payment option that is not checked will look like this:
<tr>
    <td>
        <label>
            <input type="checkbox" name="payment[options][2]" value="2" class="">
            <span>Credit card</span>
        </label>
    </td>
    <td><input type="text" name="payment[name][1][2]" class="form-control input-xs" value="">
    </td>
    <td><input type="text" name="payment[name][2][2]" class="form-control input-xs" value="">
    </td>
</tr>

restaurant_payment_options.french_label:
You won't find a value for restaurant_payment_options.french_label. Use these translations for each scraped option:
Cash -> Comptant
Credit Card -> Carte de crédit
Interac -> Interac 
Credit or debit at door -> Carte de crédit ou de débit à l'entrée
Credit at door -> Carte de crédit à l'entrée
Debit at door -> Débit à l'entrée