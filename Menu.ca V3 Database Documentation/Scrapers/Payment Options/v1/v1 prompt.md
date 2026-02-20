
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

# Scrape Payment options:
The URL to access the paymnet options for each v1 restaurant is:
https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=781&load=account_information&showLang=en

Where:
- restaurant=781 references the legacy_v1_id of each restaurant (For this example we are referencing Aahar The Taste of India v3 id 561).

Search for this elements:
<fieldset style="border: 1px solid #000; padding: 5px; margin-top: 10px;">
	<legend style="margin-left: 10px; padding: 0 2px">Payment options</legend>
	<form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;load=account_information&amp;action=setPaymentOptions" method="post">
		<input type="hidden" name="restaurant" value="781">
		<table>
			<tbody><tr>
				<td>English</td>
				<td rowspan="7">&nbsp;&nbsp;&nbsp;</td>
				<td>French</td>
				<td rowspan="7">&nbsp;&nbsp;&nbsp;</td>
				<td></td>
			</tr>
			<tr>
				<td>
					<table>
						<tbody><tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][1]" value="1" id="paymentOptionValue_1" checked="">
								<input type="text" name="paymentOption[en][display][1]" value="Cash" id="paymentOptionDisplay_1">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][2]" value="2" id="paymentOptionValue_2" checked="">
								<input type="text" name="paymentOption[en][display][2]" value="Credit Card" id="paymentOptionDisplay_2">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][3]" value="3" id="paymentOptionValue_3">
								<input type="text" name="paymentOption[en][display][3]" value="INTERAC&lt;sup&gt;&amp;reg;&lt;/sup&gt; Online" id="paymentOptionDisplay_3">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][4]" value="4" id="paymentOptionValue_4">
								<input type="text" name="paymentOption[en][display][4]" value="Credit or debit at door" id="paymentOptionDisplay_4">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][904]" value="904" id="paymentOptionValue_904">
								<input type="text" name="paymentOption[en][display][904]" value="Credit at door" id="paymentOptionDisplay_904">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[en][value][905]" value="905" id="paymentOptionValue_905">
								<input type="text" name="paymentOption[en][display][905]" value="Debit at door" id="paymentOptionDisplay_905">
							</td>
						</tr>
					</tbody></table>
				</td>
				<td>
					<table>
						<tbody><tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][1]" value="1" id="paymentOptionValue_1" checked="">
								<input type="text" name="paymentOption[fr][display][1]" value="Comptant" id="paymentOptionDisplay_1">
						</td></tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][2]" value="2" id="paymentOptionValue_2" checked="">
								<input type="text" name="paymentOption[fr][display][2]" value="Carte de crédit" id="paymentOptionDisplay_2">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][3]" value="3" id="paymentOptionValue_3">
								<input type="text" name="paymentOption[fr][display][3]" value="INTERAC&lt;sup&gt;&amp;reg;&lt;/sup&gt; en ligne" id="paymentOptionDisplay_3">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][4]" value="4" id="paymentOptionValue_4">
								<input type="text" name="paymentOption[fr][display][4]" value="Carte de crédit ou de débit à la porte" id="paymentOptionDisplay_4">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][904]" value="904" id="paymentOptionValue_904">
								<input type="text" name="paymentOption[fr][display][904]" value="Carte de crédit à la porte" id="paymentOptionDisplay_904">
							</td>
						</tr>
						<tr>
							<td>
								<input type="checkbox" name="paymentOption[fr][value][905]" value="905" id="paymentOptionValue_905">
								<input type="text" name="paymentOption[fr][display][905]" value="Carte de débit à la porte" id="paymentOptionDisplay_905">
							</td>
						</tr>
					</tbody></table>
				</td>
				<td>
					<table>
						<tbody><tr><td style="line-height:20px">Cash</td></tr>
						<tr><td style="line-height:20px">Credit Card</td></tr>
						<tr><td style="line-height:20px">Interac <sup>®</sup> Online</td></tr>
						<tr><td style="line-height:20px">Credit or debit at door</td></tr>
						<tr><td style="line-height:20px">Credit at door</td></tr>
						<tr><td style="line-height:20px">Debit at door</td></tr>
					</tbody></table>
				</td>
			</tr>
			<tr>
                <td colspan="5">
                    <label for="gateway">Use gateway :</label>
                    <select name="gateway" id="gateway">
                        <!-- <option value="salt" >Salt</option> -->
                        <option value="stripe" selected="">Stripe</option>
                    </select>
                </td>
            </tr>
			<tr>
				<td colspan="5"><input type="submit"></td>
			</tr>
		</tbody></table>
	</form>
</fieldset>


restaurant_payment_options.payment_method: 
<tr>
    <td>
        <input type="checkbox" name="paymentOption[en][value][1]" value="1" id="paymentOptionValue_1" checked="">
        <input type="text" name="paymentOption[en][display][1]" value="Cash" id="paymentOptionDisplay_1">
    </td>
</tr>

restaurant_payment_options.english_label:
<tr>
    <td>
        <input type="checkbox" name="paymentOption[en][value][1]" value="1" id="paymentOptionValue_1" checked="">
        <input type="text" name="paymentOption[en][display][1]" value="Cash" id="paymentOptionDisplay_1">
    </td>
</tr>

restaurant_payment_options.french_label:
<td>
        <input type="checkbox" name="paymentOption[fr][value][1]" value="1" id="paymentOptionValue_1" checked="">
        <input type="text" name="paymentOption[fr][display][1]" value="Comptant" id="paymentOptionDisplay_1">
</td>

restaurant_payment_options.is_enabled:
Some payment options are enabled and others are not. You should scrape all the options under the <form action="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;load=account_information&amp;action=setPaymentOptions" method="post"> and check for the checked="" attribute. Any payment option that is checked will look like this and therefore you must set the value of is_enabled to true :
<td>
    <input type="checkbox" name="paymentOption[en][value][1]" value="1" id="paymentOptionValue_1" checked="">
    <input type="text" name="paymentOption[en][display][1]" value="Cash" id="paymentOptionDisplay_1">
</td>

A payment option that is not checked will look like this:
<tr>
    <td>
        <input type="checkbox" name="paymentOption[en][value][3]" value="3" id="paymentOptionValue_3">
        <input type="text" name="paymentOption[en][display][3]" value="INTERAC&lt;sup&gt;&amp;reg;&lt;/sup&gt; Online" id="paymentOptionDisplay_3">
    </td>
</tr>

restaurant_payment_options.display_order: 
Use the attribute name="paymentOption[en][display][3]" to extract the display order of each payment option.

