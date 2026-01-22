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

# Scrape restaurants commissions

The URL to access the commissions data for each v2 restaurant is:
https://aggregator-admin.menu.ca/index.php/restaurants/edit/[legacy_v2_id]/configs
Where:

restaurant_commission_configs.commission_enabled:
<div class="form-group">
    <label style="display: block;">Commission</label>
    <label class="radio-inline">
        <input type="radio" name="commission" id="commission_y" class="" value="y" checked="&quot;checked&quot;">
        <span>Yes</span>
    </label>
    <label class="radio-inline">
        <input type="radio" name="commission" id="commission_y" class="" value="n">
        <span>No</span>
    </label>
</div>


Search for this elements:
For restaurant_commission_configs.commission_rate:
<tr>
    <td><label style="display: block" for="commission">Commission value (%)</label><input type="text" name="commission" value="7" id="commission">
    </td>
</tr>

For restaurant_commission_configs.commission_base (select the checked="&quot;checked&quot;" option):
<div class="form-group" style="" id="div_takeCommissionFrom">
    <label style="display: block;">Take commission from</label>
    <label class="radio-inline">
        <input type="radio" name="commissionFrom" id="commission_g" class="" value="g">
        <span>Gross</span>
    </label>
    <label class="radio-inline">
        <input type="radio" name="commissionFrom" id="commission_n" class="" value="n" checked="&quot;checked&quot;">
        <span>Net</span>
    </label>
</div>


For restaurant_commission_configs.commission_rate
<div class="form-group" style="" id="div_commissionValue">
    <label for="commissionValue">Commission value</label>
    <div class="input-group">
        <input data-currency="true" type="text" name="commissionValue" id="commissionValue" class="form-control" value="10.00">
        <span class="input-group-addon">%</span>
    </div>
</div>
