The purpose of this scraper is to rescrape the prices of each dish of the restaurant id 147. This restaurant has no combo dishes, only normal dishes. 


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

### Go to the menu details site of the restaurant

The URL for the menu details of each English restaurant is: 
https://aggregator-admin.menu.ca/index.php/restaurants/edit/1171/menu/restaurant


<div class="col-sm-12" id="sortable">                                       <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_606" data-id="606" data-course="Appetizers" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="606" title="click to rename this course" style="color: #fff">
                                        Appetizers
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_606" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="606">
                                    <div class="form-group">
                                        <label for="course_desc_606">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_606" cols="1" rows="3" class="form-control">Khai Vị</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                               
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="606">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_606">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="606" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="606" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="606" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/606/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="606">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/606/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="606" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="606" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/606/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="606">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/606/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="606" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/606" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="606">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_606" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/606" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="606">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4570" style="" data-dish="101." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4570/1171/1" data-dish="4570" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="101.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4570" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4570]" value="101." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4570]" value="Chả Giò.&lt;br&gt;Vietnamese Style Spring Roll with chicken, shrimp, veggie." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4570]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4570]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4570]" value="4570">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4570/1171/1" data-dish="4570" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="101.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4570" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4571" style="" data-dish="103." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4571/1171/1" data-dish="4571" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="103.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4571" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4571]" value="103." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4571]" value="Bì Cuốn (2-4 cuốn).&lt;br&gt;Vietnamese Style Shredded Pork Skin &amp; Salad Rolls (2-4 rolls)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4571]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4571]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4571]" value="4571">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4571/1171/1" data-dish="4571" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="103.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4571" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4572" style="" data-dish="104.A." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4572/1171/1" data-dish="4572" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4572" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4572]" value="104.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4572]" value="Gỏi Cuốn Tôm.&lt;br&gt;Vietnamese Style Shrimp Salad Rolls." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4572]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4572]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4572]" value="4572">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4572/1171/1" data-dish="4572" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4572" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4573" style="" data-dish="104.B." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4573/1171/1" data-dish="4573" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4573" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4573]" value="104.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4573]" value="Gỏi Cuốn Tôm Thịt Heo.&lt;br&gt;Vietnamese Style Shrimp &amp; Pork Salad Rolls." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4573]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4573]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4573]" value="4573">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4573/1171/1" data-dish="4573" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4573" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4574" style="" data-dish="104.C." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4574/1171/1" data-dish="4574" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4574" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4574]" value="104.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4574]" value="Gỏi Cuốn Tôm Thịt Bò.&lt;br&gt;Vietnamese Style Shrimp &amp; Beef Salad Rolls." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4574]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4574]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4574]" value="4574">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4574/1171/1" data-dish="4574" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="104.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4574" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4575" style="" data-dish="105. N/a" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4575/1171/1" data-dish="4575" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="105. N/a">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4575" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4575]" value="105. N/a" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4575]" value="Gỏi Đu Đủ Tôm Thịt.&lt;br&gt;Green Papaya Salad with Shrimp,Pork &amp; Peanut." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4575]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4575]" value="6.50,9.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4575]" value="4575">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4575/1171/1" data-dish="4575" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="105. N/a">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4575" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4576" style="" data-dish="106." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4576/1171/1" data-dish="4576" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="106.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4576" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4576]" value="106." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4576]" value="Chạo Tôm.&lt;br&gt;Minced Shrimp on Sugar Cane" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4576]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4576]" value="7.50,13.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4576]" value="4576">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4576/1171/1" data-dish="4576" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="106.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4576" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4577" style="" data-dish="107." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4577/1171/1" data-dish="4577" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="107.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4577" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4577]" value="107." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4577]" value="Nem Nướng.&lt;br&gt;Grilled Meat Balls." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4577]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4577]" value="7.50,13.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4577]" value="4577">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4577/1171/1" data-dish="4577" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="107.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4577" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4578" style="" data-dish="108." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4578/1171/1" data-dish="4578" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="108.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4578" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4578]" value="108." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4578]" value="Tôm Nướng Sate.&lt;br&gt;Grilled Shrimps with Satay Sauce (16 pcs)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4578]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4578]" value="18.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4578]" value="4578">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4578/1171/1" data-dish="4578" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="108.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4578" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4579" style="" data-dish="109." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4579/1171/1" data-dish="4579" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="109.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4579" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4579]" value="109." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4579]" value="Gà Nướng Sate.&lt;br&gt;Three chicken skewers marinated in satay sauce." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4579]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4579]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4579]" value="4579">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4579/1171/1" data-dish="4579" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="109.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4579" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4580" style="" data-dish="110." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4580/1171/1" data-dish="4580" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="110.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4580" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4580]" value="110." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4580]" value="Bánh Cuốn Nóng Chả Lụa.&lt;br&gt;Steamed Rice Flour Rolls with Ground Pork &amp; Vietnamese Sausage." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4580]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4580]" value="10.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4580]" value="4580">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4580/1171/1" data-dish="4580" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="110.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4580" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4581" style="" data-dish="112." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4581/1171/1" data-dish="4581" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="112.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4581" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4581]" value="112." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4581]" value="Mango Salad with Shrimp &amp; Peanut." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4581]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4581]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4581]" value="4581">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4581/1171/1" data-dish="4581" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="112.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4581" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4582" style="" data-dish="113. N/a" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4582/1171/1" data-dish="4582" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="113. N/a">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4582" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4582]" value="113. N/a" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4582]" value="Mango Platter with Shrimp &amp; Peanut Rolls." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4582]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4582]" value="12.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4582]" value="4582">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4582/1171/1" data-dish="4582" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="113. N/a">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4582" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4583" style="" data-dish="114.A." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4583/1171/1" data-dish="4583" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="114.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4583" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4583]" value="114.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4583]" value="Thai Style Tom Yum Soup (tomato, mushroom, celery, green beans, pineapple) with Chicken." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4583]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4583]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4583]" value="4583">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4583/1171/1" data-dish="4583" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="114.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4583" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4584" style="" data-dish="114.B." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4584/1171/1" data-dish="4584" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="114.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4584" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4584]" value="114.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4584]" value="Thai Style Tom Yum Soup (tomato, mushroom, celery, green beans, pineapple) with Shrimps." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4584]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4584]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4584]" value="4584">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4584/1171/1" data-dish="4584" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="114.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4584" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4585" style="" data-dish="115.A." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4585/1171/1" data-dish="4585" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="115.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4585" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4585]" value="115.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4585]" value="Thai Tom Kha Kai Coconut Sour Soup (tomato, mushroom, celery, green beans, pineapple) with Chicken." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4585]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4585]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4585]" value="4585">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4585/1171/1" data-dish="4585" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="115.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4585" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4586" style="" data-dish="115.B." data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4586/1171/1" data-dish="4586" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="115.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4586" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4586]" value="115.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4586]" value="Thai Tom Kha Kai Coconut Sour Soup (tomato, mushroom, celery, green beans, pineapple) with Shrimps." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4586]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4586]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4586]" value="4586">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4586/1171/1" data-dish="4586" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="115.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4586" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_605" data-id="605" data-course="Clear &amp; Egg Noodle" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="605" title="click to rename this course" style="color: #fff">
                                        Clear &amp; Egg Noodle
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_605" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="605">
                                    <div class="form-group">
                                        <label for="course_desc_605">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_605" cols="1" rows="3" class="form-control">Hủ Tiếu Mì</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="605">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_605">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="605" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="605" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="605" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/605/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="605">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/605/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="605" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="605" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/605/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="605">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/605/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="605" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/605" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="605">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_605" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/605" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="605">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4587" style="" data-dish="212." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4587/1171/1" data-dish="4587" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="212.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4587" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4587]" value="212." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4587]" value="“My Tho“ Style Seafood &amp; BBQ Pork Clear Noodle Soup (or soup on the side).&lt;br&gt;Hủ Tiếu Mỷ Tho (nước hoặc khô)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4587]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4587]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4587]" value="4587">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4587/1171/1" data-dish="4587" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="212.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4587" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4588" style="" data-dish="213." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4588/1171/1" data-dish="4588" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="213.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4588" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4588]" value="213." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4588]" value="Special Seafood, BBQ Pork &amp; Egg Noodle Soup (or soup on the side).&lt;br&gt;Mì Đặc Biệt (nước hoặc khô)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4588]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4588]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4588]" value="4588">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4588/1171/1" data-dish="4588" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="213.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4588" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4589" style="" data-dish="214." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4589/1171/1" data-dish="4589" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="214.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4589" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4589]" value="214." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4589]" value="Special Seafood &amp; BBQ Pork Clear Noodle &amp; Egg Noodle Soup (or soup on the side).&lt;br&gt;Hủ Tiếu Mì (nước hoặc khô)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4589]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4589]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4589]" value="4589">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4589/1171/1" data-dish="4589" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="214.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4589" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4590" style="" data-dish="215." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4590/1171/1" data-dish="4590" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="215.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4590" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4590]" value="215." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4590]" value="“Hue“ Style Beef, Pork Blood with Vermicelli in Spicy Soup (Mild, Less Spicy or Spicy).&lt;br&gt;Bún Bò Huế (không cay/ ít cay/ cay)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4590]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4590]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4590]" value="4590">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4590/1171/1" data-dish="4590" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="215.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4590" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4591" style="" data-dish="216." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4591/1171/1" data-dish="4591" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="216.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4591" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4591]" value="216." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4591]" value="Tapioca Style Noodle Soup with Seafood &amp; BBQ Pork.&lt;br&gt;Bánh Canh." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4591]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4591]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4591]" value="4591">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4591/1171/1" data-dish="4591" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="216.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4591" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4592" style="" data-dish="217.A." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4592/1171/1" data-dish="4592" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="217.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4592" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4592]" value="217.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4592]" value="Wonton Soup." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4592]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4592]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4592]" value="4592">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4592/1171/1" data-dish="4592" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="217.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4592" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4593" style="" data-dish="217.B." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4593/1171/1" data-dish="4593" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="217.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4593" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4593]" value="217.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4593]" value="Wonton Egg Noodle Soup." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4593]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4593]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4593]" value="4593">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4593/1171/1" data-dish="4593" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="217.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4593" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4594" style="" data-dish="218.A." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4594/1171/1" data-dish="4594" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4594" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4594]" value="218.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4594]" value="Thin Vermicelli with Grilled Pork, Minced Shrimp on Sugar Cane &amp; Vegetables.&lt;br&gt;Thịt Nướng Chạo Tôm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4594]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4594]" value="19.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4594]" value="4594">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4594/1171/1" data-dish="4594" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.A.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4594" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4595" style="" data-dish="218.B." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4595/1171/1" data-dish="4595" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4595" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4595]" value="218.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4595]" value="Thin Vermicelli with Grilled Pork, Spring Roll &amp; Vegetable.&lt;br&gt;Thịt Nướng Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4595]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4595]" value="18.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4595]" value="4595">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4595/1171/1" data-dish="4595" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4595" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4596" style="" data-dish="218.C." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4596/1171/1" data-dish="4596" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4596" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4596]" value="218.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4596]" value="Thin Vermicelli with Grilled Pork, Grilled Meat Balls &amp; Vegetable.&lt;br&gt;Thịt Nướng Nem Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4596]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4596]" value="18.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4596]" value="4596">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4596/1171/1" data-dish="4596" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.C.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4596" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4597" style="" data-dish="218.D." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4597/1171/1" data-dish="4597" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4597" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4597]" value="218.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4597]" value="Thin Vermicelli with Grilled Meat Balls, Spring Roll &amp; Vegetable.&lt;br&gt;Nem Nướng Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4597]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4597]" value="18.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4597]" value="4597">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4597/1171/1" data-dish="4597" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="218.D.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4597" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_604" data-id="604" data-course="Stir Fried Rice Noodle" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="604" title="click to rename this course" style="color: #fff">
                                        Stir Fried Rice Noodle
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_604" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="604">
                                    <div class="form-group">
                                        <label for="course_desc_604">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_604" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="604">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_604">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="604" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="604" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="604" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/604/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="604">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/604/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="604" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="604" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/604/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="604">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/604/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="604" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/604" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="604">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_604" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/604" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="604">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4598" style="" data-dish="219.A." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4598/1171/1" data-dish="4598" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4598" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4598]" value="219.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4598]" value="Stir Fried Rice Noodle, Mixed Vegetable with Chicken.&lt;br&gt;Hủ Tiếu Xào Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4598]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4598]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4598]" value="4598">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4598/1171/1" data-dish="4598" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4598" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4599" style="" data-dish="219.B." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4599/1171/1" data-dish="4599" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4599" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4599]" value="219.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4599]" value="Stir Fried Rice Noodle, Mixed Vegetable with Beef.&lt;br&gt;Hủ Tiếu Xào Bò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4599]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4599]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4599]" value="4599">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4599/1171/1" data-dish="4599" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4599" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4600" style="" data-dish="219.C." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4600/1171/1" data-dish="4600" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4600" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4600]" value="219.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4600]" value="Stir Fried Rice Noodle, Mixed Vegetable with Shrimps.&lt;br&gt;Hủ Tiếu Xào Tôm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4600]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4600]" value="16.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4600]" value="4600">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4600/1171/1" data-dish="4600" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4600" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4601" style="" data-dish="219.D." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4601/1171/1" data-dish="4601" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4601" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4601]" value="219.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4601]" value="Stir Fried Rice Noodle, Mixed Vegetable with Seafood.&lt;br&gt;Hủ Tiếu Xào Đồ Biển." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4601]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4601]" value="16.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4601]" value="4601">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4601/1171/1" data-dish="4601" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="219.D.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4601" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_603" data-id="603" data-course="Beef Rice Noodle Soup" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="603" title="click to rename this course" style="color: #fff">
                                        Beef Rice Noodle Soup
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_603" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="603">
                                    <div class="form-group">
                                        <label for="course_desc_603">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_603" cols="1" rows="3" class="form-control">Phở</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                       
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="603">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_603">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="603" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="603" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="603" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/603/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="603">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/603/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="603" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="603" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/603/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="603">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/603/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="603" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/603" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="603">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_603" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/603" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="603">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4602" style="" data-dish="314." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4602/1171/1" data-dish="4602" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="314.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4602" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4602]" value="314." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4602]" value="Vegetable Rice Noodle Soup.&lt;br&gt;Phở Rau Cải." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4602]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4602]" value="9.50,10.50,11.00,12.75" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4602]" value="4602">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4602/1171/1" data-dish="4602" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="314.">
                                                                 edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4602" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4603" style="" data-dish="315." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4603/1171/1" data-dish="4603" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="315.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4603" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4603]" value="315." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4603]" value="Shrimps Rice Noodle Soup.&lt;br&gt;Phở Tôm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4603]" value="Small,Medium,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4603]" value="10.00,11.00,12.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4603]" value="4603">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4603/1171/1" data-dish="4603" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="315.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4603" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4604" style="" data-dish="316." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4604/1171/1" data-dish="4604" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="316.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4604" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4604]" value="316." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4604]" value="Plain Rice Noodle Soup.&lt;br&gt;Phở Không." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4604]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4604]" value="7.00,8.00,9.00,10.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4604]" value="4604">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4604/1171/1" data-dish="4604" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="316.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4604" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4605" style="" data-dish="317." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4605/1171/1" data-dish="4605" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="317.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4605" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4605]" value="317." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4605]" value="Tendon Brisket Rice Noodle Soup.&lt;br&gt;Phở Bò Vè." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4605]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4605]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4605]" value="4605">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4605/1171/1" data-dish="4605" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="317.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4605" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4606" style="" data-dish="318." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4606/1171/1" data-dish="4606" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="318.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4606" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4606]" value="318." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4606]" value="Rare Beef Rice Noodle Soup.&lt;br&gt;Phở Tái." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4606]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4606]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4606]" value="4606">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4606/1171/1" data-dish="4606" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="318.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4606" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4607" style="" data-dish="319." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4607/1171/1" data-dish="4607" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="319.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4607" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4607]" value="319." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4607]" value="Rare &amp; Well-Done Beef Rice Noodle Soup.&lt;br&gt;Phở Tái Chín." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4607]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4607]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4607]" value="4607">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4607/1171/1" data-dish="4607" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="319.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4607" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4608" style="" data-dish="320." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4608/1171/1" data-dish="4608" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="320.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4608" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4608]" value="320." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4608]" value="Rare Beef &amp; Well-Done Flank Rice Noodle Soup.&lt;br&gt;Phở Tái Nạm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4608]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4608]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4608]" value="4608">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4608/1171/1" data-dish="4608" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="320.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4608" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4609" style="" data-dish="321." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4609/1171/1" data-dish="4609" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="321.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4609" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4609]" value="321." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4609]" value="Rare Beef &amp; Beef Balls Rice Noodle Soup.&lt;br&gt;Phở Tái Bò Viên." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4609]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4609]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4609]" value="4609">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4609/1171/1" data-dish="4609" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="321.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4609" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4610" style="" data-dish="322." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4610/1171/1" data-dish="4610" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="322.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4610" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4610]" value="322." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4610]" value="Rare Beef &amp; Brisket Rice Noodle Soup.&lt;br&gt;Phở Tái Gầu." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4610]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4610]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4610]" value="4610">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4610/1171/1" data-dish="4610" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="322.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4610" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4611" style="" data-dish="323." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4611/1171/1" data-dish="4611" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="323.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4611" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4611]" value="323." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4611]" value="Rare Beef &amp; Soft Tendon Rice Noodle Soup.&lt;br&gt;Phở Tái Gân." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4611]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4611]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4611]" value="4611">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4611/1171/1" data-dish="4611" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="323.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4611" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4612" style="" data-dish="324." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4612/1171/1" data-dish="4612" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="324.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4612" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4612]" value="324." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4612]" value="Rare Beef &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Tái Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4612]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4612]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4612]" value="4612">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4612/1171/1" data-dish="4612" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="324.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4612" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4613" style="" data-dish="325." data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4613/1171/1" data-dish="4613" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="325.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4613" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4613]" value="325." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4613]" value="Rare Beef, Well-Done Flank &amp; Beef Balls Rice Noodle Soup.&lt;br&gt;Phở Tái Nạm Bò Viên." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4613]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4613]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4613]" value="4613">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4613/1171/1" data-dish="4613" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="325.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4613" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4614" style="" data-dish="326." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4614/1171/1" data-dish="4614" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="326.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4614" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4614]" value="326." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4614]" value="Rare Beef, Well-Done Flank &amp; Soft Tendon Rice Noodle Soup.&lt;br&gt;Phở Tái Nạm Gân." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4614]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4614]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4614]" value="4614">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4614/1171/1" data-dish="4614" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="326.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4614" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4615" style="" data-dish="327." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4615/1171/1" data-dish="4615" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="327.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4615" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4615]" value="327." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4615]" value="Rare Beef, Well-Done Flank &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Tái Nạm Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4615]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4615]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4615]" value="4615">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4615/1171/1" data-dish="4615" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="327.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4615" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4616" style="" data-dish="328." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4616/1171/1" data-dish="4616" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="328.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4616" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4616]" value="328." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4616]" value="Well-Done Flank Rice Noodle Soup.&lt;br&gt;Phở Nạm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4616]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4616]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4616]" value="4616">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4616/1171/1" data-dish="4616" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="328.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4616" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4617" style="" data-dish="329." data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4617/1171/1" data-dish="4617" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="329.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4617" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4617]" value="329." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4617]" value="Well-Done Flank &amp; Beef Balls Rice Noodle Soup.&lt;br&gt;Phở Nạm Bò Viên." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4617]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4617]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4617]" value="4617">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4617/1171/1" data-dish="4617" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="329.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4617" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4618" style="" data-dish="330." data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4618/1171/1" data-dish="4618" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="330.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4618" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4618]" value="330." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4618]" value="Well-Done Flank &amp; Brisket Rice Noodle Soup.&lt;br&gt;Phở Nạm Gầu." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4618]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4618]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4618]" value="4618">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4618/1171/1" data-dish="4618" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="330.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4618" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4619" style="" data-dish="331." data-display_order="18">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4619/1171/1" data-dish="4619" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="331.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4619" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4619]" value="331." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4619]" value="Well-Done Flank &amp; Soft Tendon Rice Noodle Soup.&lt;br&gt;Phở Nạm Gân." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4619]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4619]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4619]" value="4619">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4619/1171/1" data-dish="4619" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="331.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4619" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4620" style="" data-dish="332." data-display_order="19">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4620/1171/1" data-dish="4620" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="332.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4620" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4620]" value="332." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4620]" value="Well-Done Flank &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Nạm Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4620]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4620]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4620]" value="4620">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4620/1171/1" data-dish="4620" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="332.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4620" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4621" style="" data-dish="333." data-display_order="20">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4621/1171/1" data-dish="4621" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="333.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4621" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4621]" value="333." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4621]" value="Well-Done Flank, Soft Tendon &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Nạm Gân Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4621]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4621]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4621]" value="4621">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4621/1171/1" data-dish="4621" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="333.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4621" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4622" style="" data-dish="334." data-display_order="21">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4622/1171/1" data-dish="4622" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="334.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4622" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4622]" value="334." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4622]" value="Well-Done Beef Rice Noodle Soup.&lt;br&gt;Phở Chín." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4622]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4622]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4622]" value="4622">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4622/1171/1" data-dish="4622" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="334.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4622" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4623" style="" data-dish="335." data-display_order="22">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4623/1171/1" data-dish="4623" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="335.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4623" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4623]" value="335." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4623]" value="Well-Done Beef &amp; Beef Balls Rice Noodle Soup.&lt;br&gt;Phở Chín Bò Viên." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4623]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4623]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4623]" value="4623">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4623/1171/1" data-dish="4623" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="335.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4623" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4624" style="" data-dish="336." data-display_order="23">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4624/1171/1" data-dish="4624" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="336.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4624" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4624]" value="336." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4624]" value="Well-Done Beef &amp; Brisket Rice Noodle Soup.&lt;br&gt;Phở Chín Gầu." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4624]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4624]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4624]" value="4624">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4624/1171/1" data-dish="4624" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="336.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4624" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4625" style="" data-dish="337." data-display_order="24">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4625/1171/1" data-dish="4625" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="337.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4625" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4625]" value="337." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4625]" value="Well-Done Beef &amp; Soft Tendon Rice Noodle Soup.&lt;br&gt;Phở Chín Gân." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4625]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4625]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4625]" value="4625">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4625/1171/1" data-dish="4625" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="337.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4625" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4626" style="" data-dish="338." data-display_order="25">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4626/1171/1" data-dish="4626" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="338.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4626" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4626]" value="338." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4626]" value="Well-Done Beef &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Chín Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4626]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4626]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4626]" value="4626">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4626/1171/1" data-dish="4626" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="338.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4626" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4627" style="" data-dish="339." data-display_order="26">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4627/1171/1" data-dish="4627" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="339.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4627" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4627]" value="339." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4627]" value="Well-Done Beef, Soft Tendon &amp; Beef Tripe Rice Noodle Soup.&lt;br&gt;Phở Chín Gân Sách." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4627]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4627]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4627]" value="4627">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4627/1171/1" data-dish="4627" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="339.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4627" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4628" style="" data-dish="340." data-display_order="27">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4628/1171/1" data-dish="4628" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="340.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4628" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4628]" value="340." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4628]" value="Beef Balls Soup (without rice noodle).&lt;br&gt;Súp Bò Viên (không bánh phở)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4628]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4628]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4628]" value="4628">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4628/1171/1" data-dish="4628" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="340.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4628" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4630" style="" data-dish="342." data-display_order="28">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4630/1171/1" data-dish="4630" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="342.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4630" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4630]" value="342." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4630]" value="Special Assorted Beef Rice Noodle Soup (rare beef, well-done flank, soft tendon, beef tripe &amp; beef balls).&lt;br&gt;Phở Đặc Biệt (tái nạm gân sách bò viên)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4630]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4630]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4630]" value="4630">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4630/1171/1" data-dish="4630" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="342.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4630" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4631" style="" data-dish="343." data-display_order="29">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4631/1171/1" data-dish="4631" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="343.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4631" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4631]" value="343." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4631]" value="Chicken Rice Noodle Soup.&lt;br&gt;Phở Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4631]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4631]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4631]" value="4631">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4631/1171/1" data-dish="4631" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="343.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4631" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4632" style="" data-dish="344." data-display_order="30">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4632/1171/1" data-dish="4632" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="344.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4632" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4632]" value="344." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4632]" value="Beef &amp; Chicken Rice Noodle Soup (Rare beef, flank, soft tendon, tripe, beef balls &amp; chicken).&lt;br&gt;Phở Bò Gà (tái nạm gân sách bò viên gà)" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4632]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4632]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4632]" value="4632">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4632/1171/1" data-dish="4632" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="344.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4632" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4633" style="" data-dish="345." data-display_order="31">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4633/1171/1" data-dish="4633" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="345.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4633" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4633]" value="345." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4633]" value="Rare Beef &amp; Chicken Rice Noodle Soup.&lt;br&gt;Phở Tái Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4633]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4633]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4633]" value="4633">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4633/1171/1" data-dish="4633" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="345.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4633" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4634" style="" data-dish="346." data-display_order="32">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4634/1171/1" data-dish="4634" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="346.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4634" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4634]" value="346." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4634]" value="Well-Done Flank &amp; Chicken Rice Noodle Soup.&lt;br&gt;Phở Nạm Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4634]" value="Small,Medium,Large,X-Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4634]" value="9.50,11.00,12.50,14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4634]" value="4634">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4634/1171/1" data-dish="4634" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="346.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4634" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4629" style="" data-dish="347." data-display_order="33">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4629/1171/1" data-dish="4629" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="347.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4629" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4629]" value="347." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4629]" value="Special Beef Rib Rice Noodle Soup.&lt;br&gt;PHỞ SƯỜN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4629]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4629]" value="19.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4629]" value="4629">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4629/1171/1" data-dish="4629" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="347.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4629" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_602" data-id="602" data-course="Vermicelli" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="602" title="click to rename this course" style="color: #fff">
                                        Vermicelli
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_602" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="602">
                                    <div class="form-group">
                                        <label for="course_desc_602">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_602" cols="1" rows="3" class="form-control">Bún</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="602">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_602">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="602" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="602" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="602" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/602/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="602">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/602/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="602" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="602" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/602/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="602">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/602/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="602" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/602" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="602">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_602" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/602" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="602">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4635" style="" data-dish="447." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4635/1171/1" data-dish="4635" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="447.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4635" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4635]" value="447." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4635]" value="Grilled pork, shredded pork skin and Vietnamese springroll on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts.&lt;br&gt;Bún Thịt Nướng Chả Giò Bì." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4635]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4635]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4635]" value="4635">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4635/1171/1" data-dish="4635" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="447.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4635" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4636" style="" data-dish="448." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4636/1171/1" data-dish="4636" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="448.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4636" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4636]" value="448." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4636]" value="Grilled pork and Vietnamese springroll on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts..&lt;br&gt;Bún Thịt Nướng Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4636]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4636]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4636]" value="4636">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4636/1171/1" data-dish="4636" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="448.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4636" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4637" style="" data-dish="449." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4637/1171/1" data-dish="4637" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="449.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4637" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4637]" value="449." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4637]" value="Grilled pork and shredded pork skin on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts.&lt;br&gt;Bún Thịt Nướng Bì." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4637]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4637]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4637]" value="4637">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4637/1171/1" data-dish="4637" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="449.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4637" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4638" style="" data-dish="451." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4638/1171/1" data-dish="4638" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="451.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4638" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4638]" value="451." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4638]" value="Vermicelli (no shredded pork skin) with spring roll &amp; peanuts.&lt;br&gt;Bún Chả Giò" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4638]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4638]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4638]" value="4638">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4638/1171/1" data-dish="4638" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="451.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4638" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4639" style="background-color: #a90329" data-dish="451." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4639/1171/1" data-dish="4639" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="451.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4639" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4639]" value="451." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4639]" value="Vermicelli with Spring Roll &amp; Peanut.&lt;br&gt;Bún Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4639]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4639]" value="8.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4639]" value="4639">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4639/1171/1" data-dish="4639" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="451.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4639" class="btn btn-success remove_dish" title="enable dish">
                                                                enable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4640" style="" data-dish="452." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4640/1171/1" data-dish="4640" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="452.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4640" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4640]" value="452." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4640]" value="Stir fried spicy lemon grass beef on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts.&lt;br&gt;Bún Bò Xào Xã Ớt." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4640]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4640]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4640]" value="4640">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4640/1171/1" data-dish="4640" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="452.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4640" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4641" style="" data-dish="453." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4641/1171/1" data-dish="4641" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="453.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4641" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4641]" value="453." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4641]" value="Vermicelli with Grilled Chicken &amp; Peanut.&lt;br&gt;Bún Gà Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4641]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4641]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4641]" value="4641">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4641/1171/1" data-dish="4641" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="453.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4641" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4642" style="" data-dish="454.A." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4642/1171/1" data-dish="4642" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4642" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4642]" value="454.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4642]" value="Grilled meatballs on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Pork.&lt;br&gt;Bún Nem Nướng Thịt Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4642]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4642]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4642]" value="4642">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4642/1171/1" data-dish="4642" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4642" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4643" style="" data-dish="454.B." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4643/1171/1" data-dish="4643" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4643" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4643]" value="454.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4643]" value="Grilled meatballs on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Spring Roll.&lt;br&gt;Bún Nem Nướng Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4643]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4643]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4643]" value="4643">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4643/1171/1" data-dish="4643" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4643" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4644" style="" data-dish="454.C." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4644/1171/1" data-dish="4644" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4644" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4644]" value="454.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4644]" value="Grilled meatballs on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Chicken.&lt;br&gt;Bún Nem Nướng Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4644]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4644]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4644]" value="4644">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4644/1171/1" data-dish="4644" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="454.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4644" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4645" style="" data-dish="455.A." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4645/1171/1" data-dish="4645" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4645" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4645]" value="455.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4645]" value="Grilled shrimps marinated in satay sauce on on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Pork.&lt;br&gt;Bún Tôm Nướng Thịt Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4645]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4645]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4645]" value="4645">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4645/1171/1" data-dish="4645" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4645" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4646" style="" data-dish="455.B." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4646/1171/1" data-dish="4646" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4646" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4646]" value="455.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4646]" value="Grilled shrimps marinated in satay sauce on on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Spring Roll.&lt;br&gt;Bún Tôm Nướng Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4646]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4646]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4646]" value="4646">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4646/1171/1" data-dish="4646" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4646" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4647" style="" data-dish="455.C." data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4647/1171/1" data-dish="4647" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4647" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4647]" value="455.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4647]" value="Grilled shrimps marinated in satay sauce on on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Chicken.&lt;br&gt;Bún Tôm Nướng Gà." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4647]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4647]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4647]" value="4647">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4647/1171/1" data-dish="4647" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4647" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4648" style="" data-dish="455.D." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4648/1171/1" data-dish="4648" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4648" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4648]" value="455.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4648]" value="Grilled shrimps marinated in satay sauce on on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Tiger Shrimps (10 pcs).&lt;br&gt;Bún Tôm Nướng Tôm Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4648]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4648]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4648]" value="4648">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4648/1171/1" data-dish="4648" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="455.D.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4648" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4649" style="" data-dish="456.A." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4649/1171/1" data-dish="4649" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4649" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4649]" value="456.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4649]" value="Minced shrimp on sugar cane on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Pork.&lt;br&gt;Bún Chạo Tôm Thịt Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4649]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4649]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4649]" value="4649">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4649/1171/1" data-dish="4649" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4649" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4650" style="" data-dish="456.B." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4650/1171/1" data-dish="4650" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4650" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4650]" value="456.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4650]" value="Minced shrimp on sugar cane on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Spring Roll.&lt;br&gt;Bún Chạo Tôm Chả Giò." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4650]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4650]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4650]" value="4650">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4650/1171/1" data-dish="4650" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.B.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4650" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4651" style="" data-dish="456.C." data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4651/1171/1" data-dish="4651" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4651" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4651]" value="456.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4651]" value="Minced shrimp on sugar cane on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Chicken.&lt;br&gt;Bún Chạo Tôm Gà Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4651]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4651]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4651]" value="4651">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4651/1171/1" data-dish="4651" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4651" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4652" style="" data-dish="456.D." data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4652/1171/1" data-dish="4652" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4652" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4652]" value="456.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4652]" value="Minced shrimp on sugar cane on vermicelli noodles, lettuce, beansprout, cucumber and picked vegetables. Topped with crushed peanuts and Grilled Meat Balls.&lt;br&gt;Bún Chạo Tôm Nem Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4652]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4652]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4652]" value="4652">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4652/1171/1" data-dish="4652" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="456.D.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4652" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_601" data-id="601" data-course="Steamed Rice" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="601" title="click to rename this course" style="color: #fff">
                                        Steamed Rice
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_601" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="601">
                                    <div class="form-group">
                                        <label for="course_desc_601">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_601" cols="1" rows="3" class="form-control">Cơm Tấm</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="601">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_601">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="601" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="601" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="601" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/601/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="601">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/601/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="601" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="601" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/601/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="601">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/601/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="601" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/601" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="601">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_601" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/601" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="601">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4653" style="" data-dish="501." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4653/1171/1" data-dish="4653" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="501.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4653" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4653]" value="501." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4653]" value="Grilled Pork Chop with Steamed Rice + any 2 items of A,B,C.&lt;br&gt;Cơm Sườn Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4653]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4653]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4653]" value="4653">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4653/1171/1" data-dish="4653" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="501.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4653" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4654" style="" data-dish="502." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4654/1171/1" data-dish="4654" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="502.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4654" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4654]" value="502." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4654]" value="Grilled Chicken with Steamed Rice + any 2 items of A,B,C.&lt;br&gt;Cơm Gà Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4654]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4654]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4654]" value="4654">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4654/1171/1" data-dish="4654" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="502.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4654" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4655" style="" data-dish="503." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4655/1171/1" data-dish="4655" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="503.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4655" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4655]" value="503." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4655]" value="Two Grilled Pork Chop with Steamed Rice.Cơm Sườn Nướng(2)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4655]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4655]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4655]" value="4655">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4655/1171/1" data-dish="4655" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="503.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4655" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4656" style="" data-dish="504." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4656/1171/1" data-dish="4656" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="504.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4656" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4656]" value="504." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4656]" value="Two Grilled Chicken with Steamed Rice.Cơm Gà Nướng (2)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4656]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4656]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4656]" value="4656">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4656/1171/1" data-dish="4656" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="504.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4656" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4657" style="" data-dish="505." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4657/1171/1" data-dish="4657" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="505.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4657" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4657]" value="505." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4657]" value="Grilled Chicken, Grilled Pork Chop &amp; Fried Egg with Steamed Rice.&lt;br&gt;Cơm Gà Nướng Sườn Nướng Opla." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4657]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4657]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4657]" value="4657">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4657/1171/1" data-dish="4657" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="505.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4657" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4658" style="" data-dish="506." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4658/1171/1" data-dish="4658" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="506.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4658" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4658]" value="506." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4658]" value="Special Steamed Rice with Pork Chop, Chicken, Fried Egg, Steamed Egg, Shredded Pork.&lt;br&gt;Cơm Thập Cẩm." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4658]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4658]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4658]" value="4658">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4658/1171/1" data-dish="4658" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="506.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4658" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4659" style="" data-dish="507." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4659/1171/1" data-dish="4659" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="507.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4659" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4659]" value="507." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4659]" value="Grilled Beef with Steamed Rice.&lt;br&gt;Cơm Bò Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4659]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4659]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4659]" value="4659">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4659/1171/1" data-dish="4659" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="507.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4659" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4660" style="" data-dish="508.A." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4660/1171/1" data-dish="4660" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4660" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4660]" value="508.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4660]" value="Grilled Jumbo Shrimp with Steamed Rice &amp; Grilled Chicken.&lt;br&gt;Cơm Tôm Nướng Gà Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4660]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4660]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4660]" value="4660">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4660/1171/1" data-dish="4660" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4660" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4661" style="" data-dish="508.B." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4661/1171/1" data-dish="4661" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4661" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4661]" value="508.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4661]" value="Grilled Jumbo Shrimp with Steamed Rice &amp; Grilled Pork Chop.&lt;br&gt;Sườn Nướng Sườn Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4661]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4661]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4661]" value="4661">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4661/1171/1" data-dish="4661" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4661" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4662" style="" data-dish="508.C." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4662/1171/1" data-dish="4662" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4662" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4662]" value="508.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4662]" value="Grilled Jumbo Shrimp with Steamed Rice &amp; Grilled Tiger Shrimps (10 pcs).&lt;br&gt;Cơm Tôm Nướng Tôm Nướng." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4662]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4662]" value="15.75" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4662]" value="4662">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4662/1171/1" data-dish="4662" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="508.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4662" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_600" data-id="600" data-course="Fried Rice" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="600" title="click to rename this course" style="color: #fff">
                                        Fried Rice
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_600" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="600">
                                    <div class="form-group">
                                        <label for="course_desc_600">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_600" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="600">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_600">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="600" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="600" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="600" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/600/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="600">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/600/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="600" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="600" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/600/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="600">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/600/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="600" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/600" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="600">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_600" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/600" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="600">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4663" style="" data-dish="509.A." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4663/1171/1" data-dish="4663" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4663" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4663]" value="509.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4663]" value="Fried Rice + Grilled Chicken.&lt;br&gt;GÀ NƯỚNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4663]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4663]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4663]" value="4663">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4663/1171/1" data-dish="4663" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4663" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4664" style="" data-dish="509.B." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4664/1171/1" data-dish="4664" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4664" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4664]" value="509.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4664]" value="Fried Rice + Grilled Pork Chop.&lt;br&gt;SƯỜN NƯỚNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4664]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4664]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4664]" value="4664">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4664/1171/1" data-dish="4664" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4664" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4665" style="" data-dish="509.C." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4665/1171/1" data-dish="4665" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4665" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4665]" value="509.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4665]" value="Fried Rice + Grilled Tiger Shrimps.&lt;br&gt;TÔM NƯỚNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4665]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4665]" value="16.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4665]" value="4665">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4665/1171/1" data-dish="4665" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4665" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4666" style="" data-dish="509.D." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4666/1171/1" data-dish="4666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4666]" value="509.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4666]" value="Fried Rice + Grilled Chicken and Pork Chop.&lt;br&gt;GÀ NƯỚNG &amp; SƯỜN NƯỚNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4666]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4666]" value="15.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4666]" value="4666">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4666/1171/1" data-dish="4666" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.D.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4666" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4667" style="" data-dish="509.E." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4667/1171/1" data-dish="4667" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.E.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4667" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4667]" value="509.E." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4667]" value="Fried Rice + Grilled Beef.&lt;br&gt;BÒ NƯỚNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4667]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4667]" value="15.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4667]" value="4667">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4667/1171/1" data-dish="4667" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="509.E.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4667" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4668" style="" data-dish="510." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4668/1171/1" data-dish="4668" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="510.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4668" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4668]" value="510." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4668]" value="Yang Chow Fried Rice.&lt;br&gt;CƠM CHIÊN DỦỎNG CHU." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4668]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4668]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4668]" value="4668">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4668/1171/1" data-dish="4668" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="510.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4668" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4669" style="" data-dish="511.A." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4669/1171/1" data-dish="4669" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4669" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4669]" value="511.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4669]" value="Fried Rice Mixed with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4669]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4669]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4669]" value="4669">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4669/1171/1" data-dish="4669" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.A.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4669" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4670" style="" data-dish="511.B." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4670/1171/1" data-dish="4670" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4670" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4670]" value="511.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4670]" value="Fried Rice Mixed with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4670]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4670]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4670]" value="4670">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4670/1171/1" data-dish="4670" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.B.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4670" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4671" style="" data-dish="511.C." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4671/1171/1" data-dish="4671" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4671" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4671]" value="511.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4671]" value="Fried Rice Mixed with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4671]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4671]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4671]" value="4671">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4671/1171/1" data-dish="4671" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.C.">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4671" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4672" style="" data-dish="511.D." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4672/1171/1" data-dish="4672" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4672" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4672]" value="511.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4672]" value="Fried Rice Mixed with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4672]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4672]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4672]" value="4672">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4672/1171/1" data-dish="4672" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="511.D.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4672" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_599" data-id="599" data-course="Vegetarian" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="599" title="click to rename this course" style="color: #fff">
                                        Vegetarian
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_599" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="599">
                                    <div class="form-group">
                                        <label for="course_desc_599">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_599" cols="1" rows="3" class="form-control">Thức Ăn Chay</textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                               
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="599">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_599">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="599" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="599" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="599" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/599/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="599">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/599/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="599" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="599" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/599/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="599">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/599/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="599" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/599" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="599">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_599" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/599" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="599">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4673" style="" data-dish="601." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4673/1171/1" data-dish="4673" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="601.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4673" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4673]" value="601." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4673]" value="Vegetable and Tofu Rolls.&lt;br&gt;GỎI CUỐN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4673]" value="Small (2 rolls),Large (4 rolls)" class="form-control size"></td>
                                                        <td><input type="text" name="price[4673]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4673]" value="4673">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4673/1171/1" data-dish="4673" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="601.">
                                                                   edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4673" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4674" style="" data-dish="602." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4674/1171/1" data-dish="4674" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="602.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4674" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4674]" value="602." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4674]" value="Vegetable Spring Rolls.&lt;br&gt;CHẢ GIÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4674]" value="Small (2 rolls),Large (4 rolls)" class="form-control size"></td>
                                                        <td><input type="text" name="price[4674]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4674]" value="4674">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4674/1171/1" data-dish="4674" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="602.">
                                                                    edit
                                                                </a>                       
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4674" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4675" style="" data-dish="603. N/a" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4675/1171/1" data-dish="4675" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="603. N/a">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4675" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4675]" value="603. N/a" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4675]" value="Deep Fried Tofu.&lt;br&gt;ĐẬU HỦ CHIÊN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4675]" value="Small (2 rolls),Large (4 rolls)" class="form-control size"></td>
                                                        <td><input type="text" name="price[4675]" value="6.00,9.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4675]" value="4675">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4675/1171/1" data-dish="4675" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="603. N/a">
                                                                    edit
                                                                </a>                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4675" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4676" style="" data-dish="604." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4676/1171/1" data-dish="4676" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="604.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4676" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4676]" value="604." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4676]" value="Stir Fried Rice Noodle with Vegetable and Tofu.&lt;br&gt;HỦ TIẾU XÀO." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4676]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4676]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4676]" value="4676">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4676/1171/1" data-dish="4676" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="604.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4676" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4677" style="" data-dish="605." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4677/1171/1" data-dish="4677" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="605.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4677" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4677]" value="605." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4677]" value="Fried Rice with egg and Tofu.&lt;br&gt;CƠM CHIÊN VỚI TRỨNG ĐẬU HỦ" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4677]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4677]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4677]" value="4677">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4677/1171/1" data-dish="4677" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="605.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4677" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4678" style="" data-dish="606." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4678/1171/1" data-dish="4678" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="606.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4678" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4678]" value="606." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4678]" value="Fried Rice with egg and Mushrooms.&lt;br&gt;CƠM CHIÊN VỚI TRỨNG NẤM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4678]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4678]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4678]" value="4678">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4678/1171/1" data-dish="4678" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="606.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4678" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4679" style="" data-dish="607." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4679/1171/1" data-dish="4679" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="607.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4679" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4679]" value="607." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4679]" value="Fried Rice with egg and Vegetable.&lt;br&gt;CƠM CHIÊN VỚI TRỨNG RAU CẢI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4679]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4679]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4679]" value="4679">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4679/1171/1" data-dish="4679" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="607.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4679" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4680" style="" data-dish="608." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4680/1171/1" data-dish="4680" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="608.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4680" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4680]" value="608." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4680]" value="Fried Rice with Curry Tofu.&lt;br&gt;CƠM CHIÊN VỚI TRỨNG CÀRI ĐẬU HỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4680]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4680]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4680]" value="4680">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4680/1171/1" data-dish="4680" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="608.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4680" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4681" style="" data-dish="609." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4681/1171/1" data-dish="4681" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="609.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4681" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4681]" value="609." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4681]" value="Stir Fried Broccoli with Tofu, Steamed Rice.&lt;br&gt;BÔNG CẢI XANH XÀO ĐẬU HỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4681]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4681]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4681]" value="4681">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4681/1171/1" data-dish="4681" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="609.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4681" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4682" style="" data-dish="610." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4682/1171/1" data-dish="4682" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="610.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4682" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4682]" value="610." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4682]" value="Stir Fried Bok Choy with Tofu, Steamed Rice.&lt;br&gt;CẢI BẮC THẢO XÀO ĐẬU HỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4682]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4682]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4682]" value="4682">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4682/1171/1" data-dish="4682" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="610.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4682" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4683" style="" data-dish="611." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4683/1171/1" data-dish="4683" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="611.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4683" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4683]" value="611." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4683]" value="Stir fried mushroom, tofu and tomato with sweet and sour sauce. Served with steamed rice.&lt;br&gt;NẤM, CÀ CHUA XÀO ĐẬU HỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4683]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4683]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4683]" value="4683">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4683/1171/1" data-dish="4683" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="611.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4683" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4684" style="" data-dish="612." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4684/1171/1" data-dish="4684" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="612.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4684" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4684]" value="612." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4684]" value="Stir Fried Mixed Vegetable with Tofu, Steamed Rice.&lt;br&gt;RAU CẢI XÀO ĐẬU HỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4684]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4684]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4684]" value="4684">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4684/1171/1" data-dish="4684" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="612.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4684" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4685" style="" data-dish="613." data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4685/1171/1" data-dish="4685" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="613.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4685" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4685]" value="613." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4685]" value="Singapore style stir fried vermicelli noodle with brocolli, bokchoy, and egg.&lt;br&gt;BÚN XÀO KIỂU SINGAPORE (CÓ TRỨNG)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4685]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4685]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4685]" value="4685">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4685/1171/1" data-dish="4685" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="613.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4685" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4686" style="" data-dish="614." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4686/1171/1" data-dish="4686" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="614.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4686" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4686]" value="614." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4686]" value="Stir Fried Vegetable with Curry, Steamed Rice.&lt;br&gt;RAU CẢI XÀO CÀRI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4686]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4686]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4686]" value="4686">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4686/1171/1" data-dish="4686" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="614.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4686" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4687" style="" data-dish="615." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4687/1171/1" data-dish="4687" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="615.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4687" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4687]" value="615." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4687]" value="Stir Fried Chow Mein with Vegetable and Tofu.&lt;br&gt;MÌ XÀO RAU CẢI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4687]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4687]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4687]" value="4687">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4687/1171/1" data-dish="4687" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="615.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4687" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4688" style="" data-dish="616." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4688/1171/1" data-dish="4688" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="616.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4688" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4688]" value="616." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4688]" value="Pad Thai Vegetable, Egg and Tofu.&lt;br&gt;PAD THAI RAU CẢI (CÓ TRỨNG)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4688]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4688]" value="12.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4688]" value="4688">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4688/1171/1" data-dish="4688" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="616.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4688" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_598" data-id="598" data-course="Thai Food" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="598" title="click to rename this course" style="color: #fff">
                                        Thai Food
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>
                            <div id="course_598" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="598">
                                    <div class="form-group">
                                        <label for="course_desc_598">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_598" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>                              
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="598">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_598">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">
                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="598" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="598" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="598" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/598/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="598">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/598/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="598" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="598" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/598/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="598">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/598/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="598" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/598" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="598">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_598" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/598" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="598">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="4689" style="" data-dish="617.A." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4689/1171/1" data-dish="4689" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4689" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4689]" value="617.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4689]" value="Red Curry Chicken. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style red curry sauce. Mild hot.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4689]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4689]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4689]" value="4689">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4689/1171/1" data-dish="4689" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4689" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4690" style="" data-dish="617.B." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4690/1171/1" data-dish="4690" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4690" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4690]" value="617.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4690]" value="Red Curry Beef. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style red curry sauce. Mild hot.&lt;br&gt;BÒ" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4690]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4690]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4690]" value="4690">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4690/1171/1" data-dish="4690" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.B.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4690" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4691" style="" data-dish="617.C." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4691/1171/1" data-dish="4691" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4691" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4691]" value="617.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4691]" value="Red Curry Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style red curry sauce. Mild hot.&lt;br&gt;TÔM" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4691]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4691]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4691]" value="4691">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4691/1171/1" data-dish="4691" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.C.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4691" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4692" style="" data-dish="617.D." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4692/1171/1" data-dish="4692" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4692" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4692]" value="617.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4692]" value="Red Curry Seafood. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style red curry sauce. Mild hot.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4692]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4692]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4692]" value="4692">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4692/1171/1" data-dish="4692" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.D.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4692" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4693" style="" data-dish="617.E." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4693/1171/1" data-dish="4693" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.E.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4693" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4693]" value="617.E." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4693]" value="Red Curry Chicken &amp; Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style red curry sauce. Mild hot.&lt;br&gt;GÀ &amp; TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4693]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4693]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4693]" value="4693">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4693/1171/1" data-dish="4693" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="617.E.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4693" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4694" style="" data-dish="618.A." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4694/1171/1" data-dish="4694" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4694" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4694]" value="618.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4694]" value="Green Curry Chicken. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style green curry sauce. Hot.&lt;br&gt;GÀ" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4694]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4694]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4694]" value="4694">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4694/1171/1" data-dish="4694" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.A.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4694" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4695" style="" data-dish="618.B." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4695/1171/1" data-dish="4695" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4695" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4695]" value="618.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4695]" value="Green Curry Beef. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style green curry sauce. Hot.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4695]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4695]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4695]" value="4695">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4695/1171/1" data-dish="4695" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.B.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4695" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4696" style="" data-dish="618.C." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4696/1171/1" data-dish="4696" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4696" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4696]" value="618.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4696]" value="Green Curry Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style green curry sauce. Hot.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4696]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4696]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4696]" value="4696">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4696/1171/1" data-dish="4696" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.C.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4696" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4697" style="" data-dish="618.D." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4697/1171/1" data-dish="4697" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4697" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4697]" value="618.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4697]" value="Green Curry Seafood. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style green curry sauce. Hot.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4697]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4697]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4697]" value="4697">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4697/1171/1" data-dish="4697" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.D.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4697" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4698" style="" data-dish="618.E." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4698/1171/1" data-dish="4698" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.E.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4698" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4698]" value="618.E." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4698]" value="Green Curry Chicken &amp; Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style green curry sauce. Hot.&lt;br&gt;GÀ &amp; TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4698]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4698]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4698]" value="4698">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4698/1171/1" data-dish="4698" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="618.E.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4698" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4699" style="" data-dish="619.A." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4699/1171/1" data-dish="4699" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4699" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4699]" value="619.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4699]" value="Yellow Curry Chicken. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style yellow curry sauce. Sweet.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4699]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4699]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4699]" value="4699">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4699/1171/1" data-dish="4699" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.A.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4699" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4700" style="" data-dish="619.B." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4700/1171/1" data-dish="4700" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4700" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4700]" value="619.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4700]" value="Yellow Curry Beef. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style yellow curry sauce. Sweet.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4700]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4700]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4700]" value="4700">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4700/1171/1" data-dish="4700" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.B.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4700" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4701" style="" data-dish="619.C." data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4701/1171/1" data-dish="4701" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4701" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4701]" value="619.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4701]" value="Yellow Curry Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style yellow curry sauce. Sweet.&lt;br&gt;TÔM" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4701]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4701]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4701]" value="4701">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4701/1171/1" data-dish="4701" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.C.">
                                                                    edit
                                                                </a>                                                       
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4701" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4702" style="" data-dish="619.D." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4702/1171/1" data-dish="4702" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4702" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4702]" value="619.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4702]" value="Yellow Curry Seafood. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style yellow curry sauce. Sweet.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4702]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4702]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4702]" value="4702">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4702/1171/1" data-dish="4702" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.D.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4702" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4703" style="" data-dish="619.E." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4703/1171/1" data-dish="4703" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.E.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4703" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4703]" value="619.E." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4703]" value="Yellow Curry Chicken &amp; Shrimps. Potato, carrot, long bean, bamboo shoot, egg plant and basil served with Thai style yellow curry sauce. Sweet.&lt;br&gt;GÀ &amp; TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4703]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4703]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4703]" value="4703">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4703/1171/1" data-dish="4703" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="619.E.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4703" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4704" style="" data-dish="620.A." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4704/1171/1" data-dish="4704" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4704" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4704]" value="620.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4704]" value="Pad Kee Mau (stir fried flat rice noodles with cauliflower, bokchoy, tomato and snowpeas in our spicy basil sauce) with Chicken.&lt;br&gt;GÀ" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4704]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4704]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4704]" value="4704">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4704/1171/1" data-dish="4704" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.A.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4704" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4705" style="" data-dish="620.B." data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4705/1171/1" data-dish="4705" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4705" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4705]" value="620.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4705]" value="Pad Kee Mau (stir fried flat rice noodles with cauliflower, bokchoy, tomato and snowpeas in our spicy basil sauce) with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4705]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4705]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4705]" value="4705">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4705/1171/1" data-dish="4705" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.B.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4705" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4706" style="" data-dish="620.C." data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4706/1171/1" data-dish="4706" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4706" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4706]" value="620.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4706]" value="Pad Kee Mau (stir fried flat rice noodles with cauliflower, bokchoy, tomato and snowpeas in our spicy basil sauce) with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4706]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4706]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4706]" value="4706">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4706/1171/1" data-dish="4706" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.C.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4706" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4707" style="" data-dish="620.D." data-display_order="18">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4707/1171/1" data-dish="4707" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4707" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4707]" value="620.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4707]" value="Pad Kee Mau stir fried flat rice noodles with cauliflower, bokchoy, tomato and snowpeas in our spicy basil sauce) with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4707]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4707]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4707]" value="4707">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4707/1171/1" data-dish="4707" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="620.D.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4707" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4708" style="" data-dish="621." data-display_order="19">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4708/1171/1" data-dish="4708" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="621.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4708" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4708]" value="621." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4708]" value="Singapore Noodle. Stir fried Singapore style vermicelli with chicken, BBQ pork and vegetables." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4708]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4708]" value="14.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4708]" value="4708">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4708/1171/1" data-dish="4708" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="621.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4708" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4709" style="" data-dish="622.A." data-display_order="20">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4709/1171/1" data-dish="4709" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4709" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4709]" value="622.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4709]" value="Crispy egg noodles served with stir fried vegetables andChicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4709]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4709]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4709]" value="4709">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4709/1171/1" data-dish="4709" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.A.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4709" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4710" style="" data-dish="622.B." data-display_order="21">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4710/1171/1" data-dish="4710" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4710" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4710]" value="622.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4710]" value="Crispy egg noodles served with stir fried vegetables and Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4710]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4710]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4710]" value="4710">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4710/1171/1" data-dish="4710" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.B.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4710" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4711" style="" data-dish="622.C." data-display_order="22">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4711/1171/1" data-dish="4711" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4711" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4711]" value="622.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4711]" value="Crispy egg noodles served with stir fried vegetables and Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4711]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4711]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4711]" value="4711">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4711/1171/1" data-dish="4711" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.C.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4711" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4712" style="" data-dish="622.D." data-display_order="23">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4712/1171/1" data-dish="4712" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4712" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4712]" value="622.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4712]" value="Crispy egg noodles served with stir fried vegetables and Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4712]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4712]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4712]" value="4712">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4712/1171/1" data-dish="4712" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="622.D.">
                                                                    edit
                                                                </a>                                                       
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4712" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4713" style="" data-dish="623.A." data-display_order="24">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4713/1171/1" data-dish="4713" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4713" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4713]" value="623.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4713]" value="Stir Fried Chowmein. Stir fried chowmein with broccoli and bokchoy with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4713]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4713]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4713]" value="4713">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4713/1171/1" data-dish="4713" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.A.">
                                                                    edit
                                                                </a>                                                     
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4713" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4714" style="" data-dish="623.B." data-display_order="25">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4714/1171/1" data-dish="4714" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4714" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4714]" value="623.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4714]" value="Stir Fried Chowmein. Stir fried chowmein with broccoli and bokchoy with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4714]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4714]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4714]" value="4714">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4714/1171/1" data-dish="4714" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.B.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4714" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4715" style="" data-dish="623.C." data-display_order="26">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4715/1171/1" data-dish="4715" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4715" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4715]" value="623.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4715]" value="Stir Fried Chowmein. Stir fried chowmein with broccoli and bokchoy with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4715]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4715]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4715]" value="4715">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4715/1171/1" data-dish="4715" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.C.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4715" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4716" style="" data-dish="623.D." data-display_order="27">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4716/1171/1" data-dish="4716" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4716" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4716]" value="623.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4716]" value="Stir Fried Chowmein. Stir fried chowmein with broccoli and bokchoy with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4716]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4716]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4716]" value="4716">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4716/1171/1" data-dish="4716" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="623.D.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4716" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4717" style="" data-dish="624.A." data-display_order="28">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4717/1171/1" data-dish="4717" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4717" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4717]" value="624.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4717]" value="Pad Thai (tofu, carrot &amp; snow bean) with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4717]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4717]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4717]" value="4717">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4717/1171/1" data-dish="4717" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.A.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4717" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4718" style="" data-dish="624.B." data-display_order="29">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4718/1171/1" data-dish="4718" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4718" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4718]" value="624.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4718]" value="Pad Thai (tofu, carrot &amp; snow bean) with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4718]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4718]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4718]" value="4718">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4718/1171/1" data-dish="4718" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.B.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4718" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4719" style="" data-dish="624.C." data-display_order="30">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4719/1171/1" data-dish="4719" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4719" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4719]" value="624.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4719]" value="Pad Thai (tofu, carrot &amp; snow bean) with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4719]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4719]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4719]" value="4719">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4719/1171/1" data-dish="4719" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.C.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4719" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4720" style="" data-dish="624.D." data-display_order="31">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4720/1171/1" data-dish="4720" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4720" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4720]" value="624.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4720]" value="Pad Thai (tofu, carrot &amp; snow bean) with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4720]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4720]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4720]" value="4720">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4720/1171/1" data-dish="4720" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="624.D.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4720" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4721" style="" data-dish="625.A." data-display_order="32">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4721/1171/1" data-dish="4721" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4721" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4721]" value="625.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4721]" value="Chef's Signature (stir fried mixed vegetable with steamed rice) and Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4721]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4721]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4721]" value="4721">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4721/1171/1" data-dish="4721" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.A.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4721" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4722" style="" data-dish="625.B." data-display_order="33">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4722/1171/1" data-dish="4722" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4722" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4722]" value="625.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4722]" value="Chef's Signature (stir fried mixed vegetable with steamed rice) and Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4722]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4722]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4722]" value="4722">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4722/1171/1" data-dish="4722" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.B.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4722" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4723" style="" data-dish="625.C." data-display_order="34">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4723/1171/1" data-dish="4723" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4723" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4723]" value="625.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4723]" value="Chef's Signature (stir fried mixed vegetable with steamed rice) and Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4723]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4723]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4723]" value="4723">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4723/1171/1" data-dish="4723" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.C.">
                                                                    edit
                                                                </a>                                                         
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4723" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4724" style="" data-dish="625.D." data-display_order="35">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4724/1171/1" data-dish="4724" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4724" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4724]" value="625.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4724]" value="Chef's Signature (stir fried mixed vegetable with steamed rice) and Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4724]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4724]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4724]" value="4724">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4724/1171/1" data-dish="4724" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="625.D.">
                                                                    edit
                                                                </a>                                                        
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4724" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4725" style="" data-dish="626.A." data-display_order="36">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4725/1171/1" data-dish="4725" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4725" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4725]" value="626.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4725]" value="Stir Fried Lemon Grass, Red &amp; Green Pepper, Chili, Pineapple, Onion with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4725]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4725]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4725]" value="4725">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4725/1171/1" data-dish="4725" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.A.">
                                                                    edit
                                                                </a>                                                       
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4725" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4726" style="" data-dish="626.B." data-display_order="37">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4726/1171/1" data-dish="4726" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4726" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4726]" value="626.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4726]" value="Stir Fried Lemon Grass, Red &amp; Green Pepper, Chili, Pineapple, Onion with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4726]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4726]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4726]" value="4726">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4726/1171/1" data-dish="4726" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.B.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4726" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4727" style="" data-dish="626.C." data-display_order="38">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4727/1171/1" data-dish="4727" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4727" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4727]" value="626.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4727]" value="Stir Fried Lemon Grass, Red &amp; Green Pepper, Chili, Pineapple, Onion with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4727]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4727]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4727]" value="4727">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4727/1171/1" data-dish="4727" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.C.">
                                                                    edit
                                                                </a>                                                          
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4727" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4728" style="" data-dish="626.D." data-display_order="39">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4728/1171/1" data-dish="4728" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4728" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4728]" value="626.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4728]" value="Stir Fried Lemon Grass, Red &amp; Green Pepper, Chili, Pineapple, Onion with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4728]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4728]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4728]" value="4728">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4728/1171/1" data-dish="4728" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="626.D.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4728" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4729" style="" data-dish="627.A." data-display_order="40">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4729/1171/1" data-dish="4729" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4729" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4729]" value="627.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4729]" value="Stir Fried Basil, Red &amp; Green Peppers, Onion with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4729]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4729]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4729]" value="4729">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4729/1171/1" data-dish="4729" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4729" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4730" style="" data-dish="627.B." data-display_order="41">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4730/1171/1" data-dish="4730" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4730" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4730]" value="627.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4730]" value="Stir Fried Basil, Red &amp; Green Peppers, Onion with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4730]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4730]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4730]" value="4730">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4730/1171/1" data-dish="4730" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.B.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4730" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4731" style="" data-dish="627.C." data-display_order="42">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4731/1171/1" data-dish="4731" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4731" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4731]" value="627.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4731]" value="Stir Fried Basil, Red &amp; Green Peppers, Onion with Shrimps.&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4731]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4731]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4731]" value="4731">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4731/1171/1" data-dish="4731" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.C.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4731" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4732" style="" data-dish="627.D." data-display_order="43">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4732/1171/1" data-dish="4732" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4732" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4732]" value="627.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4732]" value="Stir Fried Basil, Red &amp; Green Peppers, Onion with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4732]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4732]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4732]" value="4732">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4732/1171/1" data-dish="4732" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="627.D.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4732" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4733" style="" data-dish="628.A." data-display_order="44">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4733/1171/1" data-dish="4733" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4733" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4733]" value="628.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4733]" value="Cashew Nut Stir Fried, Baby Corn, Carrot, Red &amp; Green Peppers, Onion with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4733]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4733]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4733]" value="4733">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4733/1171/1" data-dish="4733" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.A.">
                                                                    edit
                                                                </a>                                                           
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4733" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4734" style="" data-dish="628.B." data-display_order="45">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4734/1171/1" data-dish="4734" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4734" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4734]" value="628.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4734]" value="Cashew Nut Stir Fried, Baby Corn, Carrot, Red &amp; Green Peppers, Onion with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4734]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4734]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4734]" value="4734">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4734/1171/1" data-dish="4734" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.B.">
                                                                    edit
                                                                </a>                                                      
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4734" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4735" style="" data-dish="628.C." data-display_order="46">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4735/1171/1" data-dish="4735" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4735" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4735]" value="628.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4735]" value="Cashew Nut Stir Fried, Baby Corn, Carrot, Red &amp; Green Peppers, Onion with Shrimps.&lt;br&gt;" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4735]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4735]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4735]" value="4735">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4735/1171/1" data-dish="4735" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="628.C.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4735" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4736" style="" data-dish="629.A." data-display_order="47">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4736/1171/1" data-dish="4736" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4736" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4736]" value="629.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4736]" value="Mango Stir Fried, Red &amp; Green Peppers, Basil, Onion with Chicken.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4736]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4736]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4736]" value="4736">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4736/1171/1" data-dish="4736" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.A.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4736" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4737" style="" data-dish="629.B." data-display_order="48">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4737/1171/1" data-dish="4737" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4737" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4737]" value="629.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4737]" value="Mango Stir Fried, Red &amp; Green Peppers, Basil, Onion with Beef.&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4737]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4737]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4737]" value="4737">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4737/1171/1" data-dish="4737" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.B.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4737" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4738" style="" data-dish="629.C." data-display_order="49">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4738/1171/1" data-dish="4738" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4738" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4738]" value="629.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4738]" value="Mango Stir Fried, Red &amp; Green Peppers, Basil, Onion with Shrimps.&lt;br&gt;TÔM.TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4738]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4738]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4738]" value="4738">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4738/1171/1" data-dish="4738" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.C.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4738" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4739" style="" data-dish="629.D." data-display_order="50">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4739/1171/1" data-dish="4739" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.D.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4739" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4739]" value="629.D." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4739]" value="Mango Stir Fried, Red &amp; Green Peppers, Basil, Onion with Seafood.&lt;br&gt;ĐỒ BIỂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4739]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4739]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4739]" value="4739">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4739/1171/1" data-dish="4739" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="629.D.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4739" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4740" style="" data-dish="630." data-display_order="51">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4740/1171/1" data-dish="4740" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="630.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4740" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4740]" value="630." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4740]" value="Spicy Chicken (serve with steamed rice). Stir fried red &amp; green peppers, carrot, pineapple, onion." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4740]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4740]" value="12.75" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4740]" value="4740">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4740/1171/1" data-dish="4740" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="630.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4740" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4741" style="" data-dish="631." data-display_order="52">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4741/1171/1" data-dish="4741" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="631.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4741" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4741]" value="631." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4741]" value="Spicy Beef (serve with steamed rice). Stir fried red &amp; green peppers, carrot, pineapple, onion." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4741]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4741]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4741]" value="4741">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4741/1171/1" data-dish="4741" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="631.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4741" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4742" style="" data-dish="632." data-display_order="53">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4742/1171/1" data-dish="4742" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="632.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4742" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4742]" value="632." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4742]" value="Spicy Squid (serve with steamed rice). Stir fried red &amp; green peppers, carrot, pineapple, onion." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4742]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4742]" value="13.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4742]" value="4742">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4742/1171/1" data-dish="4742" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="632.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4742" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4743" style="" data-dish="633.A." data-display_order="54">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4743/1171/1" data-dish="4743" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4743" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4743]" value="633.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4743]" value="Black Bean Stir Fried Red &amp; Green Peppers, Celery, Onion with Chicken (serve with steamed rice).&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4743]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4743]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4743]" value="4743">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4743/1171/1" data-dish="4743" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.A.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4743" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4744" style="" data-dish="633.B." data-display_order="55">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4744/1171/1" data-dish="4744" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4744" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4744]" value="633.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4744]" value="Black Bean Stir Fried Red &amp; Green Peppers, Celery, Onion with Beef (serve with steamed rice).&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4744]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4744]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4744]" value="4744">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4744/1171/1" data-dish="4744" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.B.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4744" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4745" style="" data-dish="633.C." data-display_order="56">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4745/1171/1" data-dish="4745" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4745" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4745]" value="633.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4745]" value="Black Bean Stir Fried Red &amp; Green Peppers, Celery, Onion with Shrimps (serve with steamed rice).&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4745]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4745]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4745]" value="4745">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4745/1171/1" data-dish="4745" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="633.C.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4745" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4746" style="" data-dish="634." data-display_order="57">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4746/1171/1" data-dish="4746" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="634.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4746" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4746]" value="634." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4746]" value="Ginger Chicken (serve with steamed rice). Stir fried with red &amp; green peppers, lemon grass, ginger, pineapple, onion." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4746]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4746]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4746]" value="4746">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4746/1171/1" data-dish="4746" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="634.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4746" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4747" style="" data-dish="635.A." data-display_order="58">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4747/1171/1" data-dish="4747" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="635.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4747" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4747]" value="635.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4747]" value="Spicy Peanut with Chicken (serve with steamed rice). Stir fried with red &amp; green peppers, celery, onion.&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4747]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4747]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4747]" value="4747">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4747/1171/1" data-dish="4747" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="635.A.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4747" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4748" style="" data-dish="635.B." data-display_order="59">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4748/1171/1" data-dish="4748" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="635.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4748" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4748]" value="635.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4748]" value="Spicy Peanut with Beef. Stir fried with red &amp; green peppers, celery, onion (serve with steamed rice).&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4748]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4748]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4748]" value="4748">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4748/1171/1" data-dish="4748" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="635.B.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4748" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4749" style="" data-dish="636." data-display_order="60">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4749/1171/1" data-dish="4749" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="636.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4749" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4749]" value="636." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4749]" value="Deep Fried Shrimps in Spicy Salt Salad &amp; Onion (serve with steamed rice)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4749]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4749]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4749]" value="4749">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4749/1171/1" data-dish="4749" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="636.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4749" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4750" style="" data-dish="637." data-display_order="61">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4750/1171/1" data-dish="4750" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="637.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4750" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4750]" value="637." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4750]" value="Deep Fried Squid (serve with steamed rice)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4750]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4750]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4750]" value="4750">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4750/1171/1" data-dish="4750" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="637.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4750" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4751" style="" data-dish="638." data-display_order="62">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4751/1171/1" data-dish="4751" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="638.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4751" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4751]" value="638." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4751]" value="Deep Fried Chicken Wings." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4751]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4751]" value="14.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4751]" value="4751">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4751/1171/1" data-dish="4751" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="638.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4751" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4752" style="" data-dish="639." data-display_order="63">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4752/1171/1" data-dish="4752" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="639.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4752" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4752]" value="639." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4752]" value="Beef Stir Fried with Chinese Broccoli &amp; Onion. Serve with Steamed Rice." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4752]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4752]" value="12.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4752]" value="4752">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4752/1171/1" data-dish="4752" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="639.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4752" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4753" style="" data-dish="640.A." data-display_order="64">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4753/1171/1" data-dish="4753" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.A.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4753" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4753]" value="640.A." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4753]" value="Broccoli and Baby Bok Choy with Chicken (serve with steamed rice).&lt;br&gt;GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4753]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4753]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4753]" value="4753">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4753/1171/1" data-dish="4753" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.A.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4753" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4754" style="" data-dish="640.B." data-display_order="65">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4754/1171/1" data-dish="4754" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.B.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4754" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4754]" value="640.B." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4754]" value="Broccoli and Baby Bok Choy with Beef (serve with steamed rice).&lt;br&gt;BÒ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4754]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4754]" value="13.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4754]" value="4754">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4754/1171/1" data-dish="4754" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.B.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4754" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4755" style="" data-dish="640.C." data-display_order="66">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4755/1171/1" data-dish="4755" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.C.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4755" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4755]" value="640.C." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4755]" value="Broccoli and Baby Bok Choy with Shrimps (serve with steamed rice).&lt;br&gt;TÔM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4755]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4755]" value="15.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4755]" value="4755">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4755/1171/1" data-dish="4755" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="640.C.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4755" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="4756" style="" data-dish="642." data-display_order="67">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4756/1171/1" data-dish="4756" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="642.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4756" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4756]" value="642." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4756]" value="Basil Mussels (serve with steamed rice)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4756]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[4756]" value="18.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4756]" value="4756">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4756/1171/1" data-dish="4756" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="642.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4756" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_925" data-id="925" data-course="Side Orders (Extra Small)" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="925" title="click to rename this course" style="color: #fff">
                                        Side Orders (Extra Small)
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_925" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="925">
                                    <div class="form-group">
                                        <label for="course_desc_925">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_925" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="925">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_925">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="925" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="925" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="925" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/925/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="925">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/925/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="925" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="925" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/925/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="925">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/925/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="925" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/925" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="925">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_925" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/925" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="925">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7476" style="" data-dish="01." data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7476/1171/1" data-dish="7476" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="01.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7476" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7476]" value="01." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7476]" value="Bowl of rare beef.&lt;br&gt;DĨA TÁI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7476]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7476]" value="4.90" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7476]" value="7476">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7476/1171/1" data-dish="7476" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="01.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7476" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7477" style="" data-dish="02." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7477/1171/1" data-dish="7477" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="02.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7477" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7477]" value="02." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7477]" value="Bowl of well-done flank.&lt;br&gt;CHÉN NẠM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7477]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7477]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7477]" value="7477">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7477/1171/1" data-dish="7477" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="02.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7477" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7478" style="" data-dish="03." data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7478/1171/1" data-dish="7478" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="03.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7478" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7478]" value="03." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7478]" value="Bowl of beef balls.&lt;br&gt;CHÉN BÒ VIÊN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7478]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7478]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7478]" value="7478">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7478/1171/1" data-dish="7478" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="03.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7478" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7479" style="" data-dish="04." data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7479/1171/1" data-dish="7479" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="04.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7479" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7479]" value="04." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7479]" value="Bowl of soft tendon.&lt;br&gt;CHÉN GÂN." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7479]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7479]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7479]" value="7479">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7479/1171/1" data-dish="7479" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="04.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7479" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7480" style="" data-dish="05." data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7480/1171/1" data-dish="7480" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="05.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7480" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7480]" value="05." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7480]" value="Bowl of beef tripe.&lt;br&gt;CHÉN SÁCH." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7480]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7480]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7480]" value="7480">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7480/1171/1" data-dish="7480" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="05.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7480" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7481" style="" data-dish="06." data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7481/1171/1" data-dish="7481" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="06.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7481" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7481]" value="06." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7481]" value="Bowl of rice noodle.&lt;br&gt;CHÉN PHỞ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7481]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7481]" value="3.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7481]" value="7481">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7481/1171/1" data-dish="7481" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="06.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7481" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7482" style="" data-dish="07." data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7482/1171/1" data-dish="7482" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="07.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7482" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7482]" value="07." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7482]" value="Shrimp.&lt;br&gt;TÔM (5)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7482]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7482]" value="6.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7482]" value="7482">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7482/1171/1" data-dish="7482" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="07.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7482" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7483" style="" data-dish="08." data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7483/1171/1" data-dish="7483" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="08.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7483" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7483]" value="08." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7483]" value="Grilled chicken.&lt;br&gt;GẢ NƯỚNG (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7483]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7483]" value="6.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7483]" value="7483">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7483/1171/1" data-dish="7483" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="08.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7483" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7484" style="" data-dish="09." data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7484/1171/1" data-dish="7484" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="09.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7484" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7484]" value="09." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7484]" value="Grilled pork chop.&lt;br&gt;SƯỜN NƯỚNG (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7484]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7484]" value="6.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7484]" value="7484">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7484/1171/1" data-dish="7484" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="09.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7484" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7485" style="" data-dish="10." data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7485/1171/1" data-dish="7485" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="10.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7485" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7485]" value="10." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7485]" value="Fried egg.&lt;br&gt;TRỨNG ỐP LA (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7485]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7485]" value="2.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7485]" value="7485">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7485/1171/1" data-dish="7485" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="10.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7485" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7486" style="" data-dish="11." data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7486/1171/1" data-dish="7486" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="11.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7486" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7486]" value="11." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7486]" value="Bowl of shredded pork skin.&lt;br&gt;CHÉN BÌ (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7486]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7486]" value="2.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7486]" value="7486">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7486/1171/1" data-dish="7486" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="11.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7486" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7487" style="" data-dish="12." data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7487/1171/1" data-dish="7487" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7487" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7487]" value="12." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7487]" value="Steamed egg.&lt;br&gt;CHẢ TRỨNG (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7487]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7487]" value="2.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7487]" value="7487">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7487/1171/1" data-dish="7487" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="12.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7487" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7488" style="" data-dish="13." data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7488/1171/1" data-dish="7488" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="13.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7488" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7488]" value="13." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7488]" value="Bowl of steamed rice.&lt;br&gt;CHÉN CƠM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7488]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7488]" value="3.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7488]" value="7488">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7488/1171/1" data-dish="7488" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="13.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7488" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7489" style="" data-dish="14." data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7489/1171/1" data-dish="7489" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="14.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7489" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7489]" value="14." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7489]" value="Deep fried spring roll.&lt;br&gt;CHẢ GIÒ (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7489]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7489]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7489]" value="7489">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7489/1171/1" data-dish="7489" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="14.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7489" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7490" style="" data-dish="15." data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7490/1171/1" data-dish="7490" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="15.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7490" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7490]" value="15." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7490]" value="Grilled shrimp on sugar cane.&lt;br&gt;CHẠO TÔM (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7490]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7490]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7490]" value="7490">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7490/1171/1" data-dish="7490" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="15.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7490" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7491" style="" data-dish="16." data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7491/1171/1" data-dish="7491" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="16.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7491" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7491]" value="16." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7491]" value="Grilled meatball.&lt;br&gt;NEM NƯỚNG (1)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7491]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7491]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7491]" value="7491">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7491/1171/1" data-dish="7491" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="16.">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7491" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>
                                            <div class="jarviswidget jarviswidget-color-darken course-listing jarviswidget-sortable" id="c_926" data-id="926" data-course="Beverages" role="widget">
                            <header role="heading"><div class="jarviswidget-ctrls" role="menu">    <a href="javascript:void(0);" class="button-icon jarviswidget-toggle-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Collapse"><i class="fa fa-minus "></i></a>  </div>
                                <h2>
                                    <a href="#" class="rename" data-course-id="926" title="click to rename this course" style="color: #fff">
                                        Beverages
                                    </a>
                                </h2>
                            <span class="jarviswidget-loader"><i class="fa fa-refresh fa-spin"></i></span></header>

                            <div id="course_926" class="widget-body" role="content">
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_course_description" method="post" class="form_update_course">
                                    <input type="hidden" name="course_id" value="926">
                                    <div class="form-group">
                                        <label for="course_desc_926">course description</label>
                                        <div class="input-group input-group-sm">
                                            <textarea name="desc" id="course_desc_926" cols="1" rows="3" class="form-control"></textarea>
                                            <span class="input-group-btn">
										<button class="btn btn-primary">Update course description</button>
									</span>
                                        </div>
                                    </div>
                                </form>
                                
                                                                <form action="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/update_dishes" method="post" class="form_update_course">
                                    <div class="table-responsive">
                                        <input type="hidden" name="course" value="926">
                                        <table class="table table-bordered table-striped table-condensed show-dishes" id="table_926">
                                            <thead>
                                            <tr>
                                                <td colspan="3" class="text-right">

                                                                                                    </td>
                                                <td colspan="2" class="text-right">
                                                    <span class="form-control-static">course available for - if none chosen, course will not show: </span>&nbsp;
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[1]" value="1" data-name="1" data-course="926" checked="">
                                                            Takeout
                                                        </label>
                                                                                                            <label class="checkbox-inline">
                                                            <input type="checkbox" name="available_for[2]" value="2" data-name="2" data-course="926" checked="">
                                                            Delivery
                                                        </label>
                                                                                                        <button type="button" class="btn btn-default btn-xs available_for">
                                                        update
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th class="dish-actions visible-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="926" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/926/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="926">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/926/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="926" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                                <th class="dish-name">name</th>
                                                <th class="dish-desc">description</th>
                                                <th class="dish-size">size(s)</th>
                                                <th class="dish-price">price(s)</th>
                                                <th class="text-center dish-actions hidden-xs">
                                                    <div class="btn-group">
                                                        <button class="btn btn-default  dropdown-toggle" data-toggle="dropdown">
                                                            add dish <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="#mod_add_dish" class="add-dish-modal" data-course="926" data-toggle="modal">
                                                                    regular dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showCreateCombo/926/1171" data-target="#mod_create_combo" data-toggle="modal" data-backdrop="static" data-keyboard="true" data-course="926">
                                                                    combo dish
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/showImportDish/926/1171" data-target="#mod_import_dish" class="add-dish-modal" data-course="926" data-toggle="modal" data-backdrop="static" data-keyboard="true">
                                                                    import dishes
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </th>
                                            </tr>
                                            </thead>
                                            <tfoot>
                                            <tr>
                                                <td class="visible-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/926" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="926">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                                <td colspan="2">
                                                    <div class="input-group">
												<span class="input-group-btn">
													<a href="#" data-update-type="value" class="btn btn-default update-prices">value</a>
												</span>
                                                        <input type="number" name="update_prices_by" id="update_prices_by_926" class="form-control update_prices_by" value="0" placeholder="update prices by" min="0" step="0.1">
                                                        <span class="input-group-btn">
													<a href="#" data-update-type="percent" class="btn btn-default update-prices">percent</a>
												</span>
                                                    </div>
                                                </td>
                                                <td colspan="2"></td>
                                                <td class="text-right hidden-xs">
                                                    <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/manage_dishes/926" data-backdrop="static" data-keyboard="true" data-toggle="modal" data-target="#mod_manage_dishes" class="sort_dishes btn btn-default" data-course="926">dish order</a>
                                                    <button type="submit" class="btn btn-primary ">
                                                        Update
                                                    </button>
                                                </td>
                                            </tr>
                                            </tfoot>
                                            <tbody>
                                                                                                                                                <tr class="sort" data-id="7492" style="" data-dish="776. Ice Tea" data-display_order="0">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7492/1171/1" data-dish="7492" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="776. Ice Tea">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7492" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7492]" value="776. Ice Tea" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7492]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7492]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7492]" value="1.75" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7492]" value="7492">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7492/1171/1" data-dish="7492" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="776. Ice Tea">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7492" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7493" style="" data-dish="777. Bubble Tea" data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7493/1171/1" data-dish="7493" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="777. Bubble Tea">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7493" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7493]" value="777. Bubble Tea" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7493]" value="" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7493]" value="Taro,Red bean,Peach,Honeydew,Blueberry,Mango,Pineapple,Lychee,Strawberry,Passionfruit,BBT coffee" class="form-control size"></td>
                                                        <td><input type="text" name="price[7493]" value="6.00,6.00,6.00,6.00,6.00,6.00,6.00,6.00,6.00,6.00,6.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7493]" value="7493">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7493/1171/1" data-dish="7493" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="777. Bubble Tea">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7493" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7494" style="" data-dish="778. Filtered coffee with ice" data-display_order="2">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7494/1171/1" data-dish="7494" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="778. Filtered coffee with ice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7494" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7494]" value="778. Filtered coffee with ice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7494]" value="CÀ PHÊ ĐEN ĐÁ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7494]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7494]" value="3.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7494]" value="7494">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7494/1171/1" data-dish="7494" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="778. Filtered coffee with ice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7494" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7495" style="" data-dish="779. Filtered coffee with condensed milk" data-display_order="3">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7495/1171/1" data-dish="7495" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="779. Filtered coffee with condensed milk">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7495" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7495]" value="779. Filtered coffee with condensed milk" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7495]" value="CÀ PHÊ SỮA NÓNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7495]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7495]" value="3.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7495]" value="7495">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7495/1171/1" data-dish="7495" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="779. Filtered coffee with condensed milk">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7495" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7496" style="" data-dish="780. Filtered coffee with condensed milk &amp; ice" data-display_order="4">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7496/1171/1" data-dish="7496" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="780. Filtered coffee with condensed milk &amp; ice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7496" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7496]" value="780. Filtered coffee with condensed milk &amp; ice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7496]" value="CÀ PHÊ SỮA ĐÁ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7496]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7496]" value="2.75" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7496]" value="7496">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7496/1171/1" data-dish="7496" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="780. Filtered coffee with condensed milk &amp; ice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7496" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7497" style="" data-dish="781. Soft drinks" data-display_order="5">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7497/1171/1" data-dish="7497" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="781. Soft drinks">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7497" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7497]" value="781. Soft drinks" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7497]" value="NƯỚC NGỌT CÁC LOẠI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7497]" value="Coke,7UP,Orange" class="form-control size"></td>
                                                        <td><input type="text" name="price[7497]" value="1.50,1.50,1.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7497]" value="7497">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7497/1171/1" data-dish="7497" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="781. Soft drinks">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7497" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7498" style="" data-dish="783. Fresh squeezed lime juice with ice" data-display_order="6">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7498/1171/1" data-dish="7498" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="783. Fresh squeezed lime juice with ice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7498" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7498]" value="783. Fresh squeezed lime juice with ice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7498]" value="NƯỚC ĐÁ CHANH TƯƠI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7498]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7498]" value="4.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7498]" value="7498">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7498/1171/1" data-dish="7498" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="783. Fresh squeezed lime juice with ice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7498" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7499" style="" data-dish="784. Fresh squeezed lime juice with soda, sugar &amp; ice" data-display_order="7">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7499/1171/1" data-dish="7499" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="784. Fresh squeezed lime juice with soda, sugar &amp; ice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7499" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7499]" value="784. Fresh squeezed lime juice with soda, sugar &amp; ice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7499]" value="SODA CHANH TƯƠI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7499]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7499]" value="4.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7499]" value="7499">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7499/1171/1" data-dish="7499" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="784. Fresh squeezed lime juice with soda, sugar &amp; ice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7499" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7500" style="" data-dish="785. Fresh whipped with condensed milk &amp; egg yolk" data-display_order="8">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7500/1171/1" data-dish="7500" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="785. Fresh whipped with condensed milk &amp; egg yolk">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7500" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7500]" value="785. Fresh whipped with condensed milk &amp; egg yolk" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7500]" value="SODA SỮA HỘT GÀ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7500]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7500]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7500]" value="7500">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7500/1171/1" data-dish="7500" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="785. Fresh whipped with condensed milk &amp; egg yolk">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7500" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7501" style="" data-dish="786. Sweet jelly and white kidney bean in coconut milk with ice" data-display_order="9">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7501/1171/1" data-dish="7501" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="786. Sweet jelly and white kidney bean in coconut milk with ice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7501" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7501]" value="786. Sweet jelly and white kidney bean in coconut milk with ice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7501]" value="THẠCH CHÈ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7501]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7501]" value="6.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7501]" value="7501">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7501/1171/1" data-dish="7501" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="786. Sweet jelly and white kidney bean in coconut milk with ice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7501" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7502" style="" data-dish="789. Three combination bean pudding with coconut milk" data-display_order="10">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7502/1171/1" data-dish="7502" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="789. Three combination bean pudding with coconut milk">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7502" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7502]" value="789. Three combination bean pudding with coconut milk" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7502]" value="CHÈ 3 MÀU." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7502]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7502]" value="6.25" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7502]" value="7502">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7502/1171/1" data-dish="7502" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="789. Three combination bean pudding with coconut milk">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7502" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7503" style="" data-dish="790. Fresh squeezed orange juice" data-display_order="11">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7503/1171/1" data-dish="7503" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="790. Fresh squeezed orange juice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7503" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7503]" value="790. Fresh squeezed orange juice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7503]" value="CAM VẰT." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7503]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7503]" value="4.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7503]" value="7503">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7503/1171/1" data-dish="7503" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="790. Fresh squeezed orange juice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7503" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7504" style="" data-dish="791. Strawberry milkshake" data-display_order="12">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7504/1171/1" data-dish="7504" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="791. Strawberry milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7504" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7504]" value="791. Strawberry milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7504]" value="SINH TỐ DÂU." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7504]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7504]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7504]" value="7504">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7504/1171/1" data-dish="7504" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="791. Strawberry milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7504" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7505" style="" data-dish="792. Fresh coconut juice" data-display_order="13">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7505/1171/1" data-dish="7505" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="792. Fresh coconut juice">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7505" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7505]" value="792. Fresh coconut juice" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7505]" value="DỪA XIÊM." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7505]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7505]" value="4.50" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7505]" value="7505">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7505/1171/1" data-dish="7505" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="792. Fresh coconut juice">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7505" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7506" style="" data-dish="793. Coconut milkshake" data-display_order="14">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7506/1171/1" data-dish="7506" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="793. Coconut milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7506" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7506]" value="793. Coconut milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7506]" value="SINH TỐ DỪA TƯƠI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7506]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7506]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7506]" value="7506">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7506/1171/1" data-dish="7506" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="793. Coconut milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7506" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7507" style="" data-dish="794. Soursop milkshake" data-display_order="15">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7507/1171/1" data-dish="7507" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="794. Soursop milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7507" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7507]" value="794. Soursop milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7507]" value="SINH TỐ MÃNG CẦU." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7507]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7507]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7507]" value="7507">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7507/1171/1" data-dish="7507" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="794. Soursop milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7507" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7508" style="" data-dish="795. Jack fruit milkshake" data-display_order="16">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7508/1171/1" data-dish="7508" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="795. Jack fruit milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7508" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7508]" value="795. Jack fruit milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7508]" value="SINH TỐ MÍT." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7508]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7508]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7508]" value="7508">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7508/1171/1" data-dish="7508" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="795. Jack fruit milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7508" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7509" style="" data-dish="796. Durian milkshake" data-display_order="17">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7509/1171/1" data-dish="7509" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="796. Durian milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7509" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7509]" value="796. Durian milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7509]" value="SINH TỐ SẦU RIÊNG." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7509]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7509]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7509]" value="7509">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7509/1171/1" data-dish="7509" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="796. Durian milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7509" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7510" style="" data-dish="797. Avocado milkshake" data-display_order="18">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7510/1171/1" data-dish="7510" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="797. Avocado milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7510" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7510]" value="797. Avocado milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7510]" value="SINH TỐ BƠ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7510]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7510]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7510]" value="7510">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7510/1171/1" data-dish="7510" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="797. Avocado milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7510" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7511" style="" data-dish="798. Mango milkshake" data-display_order="19">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7511/1171/1" data-dish="7511" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="798. Mango milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7511" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7511]" value="798. Mango milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7511]" value="SINH TỐ XOÀI." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7511]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7511]" value="5.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7511]" value="7511">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7511/1171/1" data-dish="7511" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="798. Mango milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7511" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                                                                                <tr class="sort" data-id="7512" style="" data-dish="799. Papaya milkshake" data-display_order="20">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7512/1171/1" data-dish="7512" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="799. Papaya milkshake">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7512" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[7512]" value="799. Papaya milkshake" class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[7512]" value="SINH TỐ ĐU ĐỦ." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[7512]" value="" class="form-control size"></td>
                                                        <td><input type="text" name="price[7512]" value="4.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[7512]" value="7512">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/7512/1171/1" data-dish="7512" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="799. Papaya milkshake">
                                                                    edit
                                                                </a>
                                                            
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="7512" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>
                                                                                                                                        </tbody>
                                        </table>
                                    </div>
                                </form>
                                                            </div>
                        </div>                    
                </div>

### Scrape prices and sizes
Each dish can be located in this type of markup: 

<tr class="sort" data-id="4571" style="" data-dish="103." data-display_order="1">
                                                        <td class="visible-xs">
                                                                                                                            <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4571/1171/1" data-dish="4571" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="103.">
                                                                    edit
                                                                </a>
                                                                                                                        <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4571" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                        <td><input type="text" name="name[4571]" value="103." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="desc[4571]" value="Bì Cuốn (2-4 cuốn).&lt;br&gt;Vietnamese Style Shredded Pork Skin &amp; Salad Rolls (2-4 rolls)." class="form-control">
                                                        </td>
                                                        <td><input type="text" name="size[4571]" value="Small,Large" class="form-control size"></td>
                                                        <td><input type="text" name="price[4571]" value="6.25,11.00" class="form-control price"></td>
                                                        <td class="text-center dish-actions hidden-xs">
                                                            <input type="hidden" name="ids[4571]" value="4571">
                                                                                                                                                                                        <a href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/edit_dish/4571/1171/1" data-dish="4571" class="btn btn-primary edit_dish" title="edit dish" data-toggle="modal" data-target="#mod_edit_dish" data-backdrop="static" data-keyboard="true" data-dishname="103.">
                                                                    edit
                                                                </a>                                                     
                                                            <a data-msg="Change status of this dish?" href="https://aggregator-admin.menu.ca/index.php/ajax/restaurant_menu/changeDishStatus" data-dish="4571" class="btn btn-danger remove_dish" title="disable dish">
                                                                disable
                                                            </a>
                                                        </td>
                                                    </tr>

Match HTML dish name to its respective V3 dish by exact name_en match. 

For example the dish id 147785 with dishes.name = 103.
<td>
    <input type="text" name="name[4571]" value="103." class="form-control">
</td>



dish_prices.price:
<td>
    <input type="text" name="price[4571]" value="6.25,11.00" class="form-control price">
</td>

dish_prices.size_variant:
<td>
    <input type="text" name="size[4571]" value="Small,Large" class="form-control size">
</td>

