V1 CRM

- URL: https://menuadmin.menu.ca/?p=restaurants

- Instructions: 
1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:
<li style="background: rgb(204, 204, 204);" onmouseover="this.style.background='#ff9'" onmouseout="this.style.background='#ccc'">
					<ul class="ulrestaurant">
						<li style="padding: 0 10px 0 2px">
															<a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781">Edit</a>
													</li>
						<li class="restoName">Aahar The Taste of India</li>
						<li class="restoAddress">1573 Alta Vista Drive</li>
						<li class="actions">
							<!-- <a href="#" onclick="return false;">Actions</a>
							<!-- <div id="div_781">
								<a onclick="return confirm('Are you sure you want make it inactive?')" href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;action=disable">Inactive</a>
																	| <a href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781&amp;action=pend" href="#" onclick="return confirm('Are you sure you want to set to pending?')" >Pending</a>
								 -->
																  	<a href="#" id="editMap_781">Set delivery area</a>
									<script type="text/javascript">
										$('editMap_781').observe('click', function(){
											window.open('ajax/setDeliveryLocations.php?restaurant=781&latitude=45.4084149&longitude=-75.65822930000002','','width=1000,height=800,scrollbars=yes');
											event.stop();
										});
									</script>
															<!-- </div> -->
						</li>
					</ul>
				</li>

Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Aahar The Taste of India the a element contains its v1 id (781) in the href parameter href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781". You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you must click on
<a href="?p=restaurants&amp;display=editRestaurant&amp;restaurant=203&amp;load=delivery&amp;showLang=en">Delivery</a>

this will take you to the distance-based delivery fees details page URL: https://menuadmin.menu.ca/?p=restaurants&display=editRestaurant&restaurant=203&load=delivery&showLang=en

3. Once you are in the delivery page check if the <input> element with name="sendToDelivery" is checked. If it is not continue with the next restaurant. If it is checked, set the flagfor restaurant_delivery_areas.distance_based_delivery_fee to true and proceed to scrap the page.

Example for the restaurant Aahar The Taste of India : <input type="radio" name="sendToDelivery" value="y" id="sendToDelivery_y">

Example for Centertown Donair & Pizza: <input type="radio" name="sendToDelivery" value="y" id="sendToDelivery_y" checked>

Example for Centertown Donair & Pizza:

- restaurant_delivery_companies.sends_to_delivery: <input type="radio" name="sendToDelivery" value="y" id="sendToDelivery_y" checked="">

- restaurant_delivery_companies.company_email_id: 
<input type="text" name="email" id="sendToDelivery_email" value="Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com" style="width: 300px;"> 
map the email values with the emails in delivery_company_emails to extract their id. If the email does no exist creat it. 

- restaurant_delivery_companies.commission: <input type="text" name="commission" id="commission" value="15.00">

- restaurant_delivery_companies.restaurant_pays_difference: <input type="text" name="rpd" id="rpd" value="0.00">

- restaurant_distance_based_delivery_fees distance_in_km, driver_earning, restaurant_pays, vendor_pays, total_delivery_fee (defined as Delivery fee in the CRM):
<table>
        <caption style="font-weight: bold; text-align: left; margin: 10px 0; font-size: 14px;">Distance based fees</caption>
        <thead>
        <tr>
            <th>Distance</th>
            <th>Driver earnings</th>
            <th>Restaurant pays</th>
            <th>Vendor pays</th>
            <th>Delivery fee</th>
        </tr>
        </thead>


        <tbody>
                    <tr>
                <td>5 km.</td>
                <td><input type="number" name="driver_earning[5]" id="driver_earning_5" value="7.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[5]" id="restaurant_pays_5" value="7.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[5]" id="vendor_pays5" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[5]" id="delivery_fee5" value="7.00"></td>
            </tr>
                    <tr>
                <td>6 km.</td>
                <td><input type="number" name="driver_earning[6]" id="driver_earning_6" value="8.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[6]" id="restaurant_pays_6" value="8.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[6]" id="vendor_pays6" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[6]" id="delivery_fee6" value="8.00"></td>
            </tr>
                    <tr>
                <td>7 km.</td>
                <td><input type="number" name="driver_earning[7]" id="driver_earning_7" value="9.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[7]" id="restaurant_pays_7" value="9.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[7]" id="vendor_pays7" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[7]" id="delivery_fee7" value="9.00"></td>
            </tr>
                    <tr>
                <td>8 km.</td>
                <td><input type="number" name="driver_earning[8]" id="driver_earning_8" value="10.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[8]" id="restaurant_pays_8" value="10.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[8]" id="vendor_pays8" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[8]" id="delivery_fee8" value="10.00"></td>
            </tr>
                    <tr>
                <td>9 km.</td>
                <td><input type="number" name="driver_earning[9]" id="driver_earning_9" value="11.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[9]" id="restaurant_pays_9" value="11.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[9]" id="vendor_pays9" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[9]" id="delivery_fee9" value="11.00"></td>
            </tr>
                    <tr>
                <td>10 km.</td>
                <td><input type="number" name="driver_earning[10]" id="driver_earning_10" value="12.00" min="0" step=".01"></td>
                <td><input type="number" name="restaurant_pays[10]" id="restaurant_pays_10" value="12.00" min="0" step=".01"></td>
                <td><input type="number" name="vendor_pays[10]" id="vendor_pays10" value="0.00" min="0" step=".01"></td>
                <td><input type="text" name="delivery_fee[10]" id="delivery_fee10" value="12.00"></td>
            </tr>
        
        <tr>
            <td>Maximum distance</td>
            <td colspan=""><input type="number" name="max_distance" id="max_distance" value="10" style="text-align: right;"></td>
            <td></td>
            <td>Restaurant id</td>
            <td><input type="number" name="delivery_restaurant_id" id="" value="235"></td>
        </tr>
        </tbody>

        <tfoot>
        <tr>
            <td colspan="5" style="text-align: right;">
                <button type="submit">Save</button>
            </td>
        </tr>
        </tfoot>
    </table>
