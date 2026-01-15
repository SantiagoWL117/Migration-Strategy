"""
Update dish prices for restaurant ID 147 from HTML markup.

This script:
1. Parses HTML markup to extract dish names, sizes, and prices
2. Matches dishes by name to existing dishes in menuca_v3.dishes
3. Updates prices in menuca_v3.dish_prices table
"""

import os
import sys
import logging
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from bs4 import BeautifulSoup
import psycopg2
from psycopg2.extras import RealDictCursor

# Add parent directory to path to import config
sys.path.insert(0, str(Path(__file__).parent))
from config import DB_CONNECTION_STRING, SCHEMA

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

RESTAURANT_ID = 147

# HTML markup provided by user
HTML_MARKUP = """
<div class="row">
    <div class="col-sm-12">
        <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false" data-widget-custombutton="false" data-widget-sortable="false" role="widget">
            <header role="heading">
                <h2>Appetizers</h2>
            </header>
            <div role="content">
                <div class="widget-body">
                    <table class="table table-bordered show-dishes">
                        <tbody class="ui-sortable">
                            <tr class="sort" data-id="4570" style="" data-dish="101." data-display_order="0">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4570]" value="101." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4570]" value="Egg Roll (2)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4570]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4570]" value="6.25,11.00" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4570"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4571" style="" data-dish="102." data-display_order="1">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4571]" value="102." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4571]" value="Shrimp Roll (2)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4571]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4571]" value="6.25,11.00" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4571"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4572" style="" data-dish="103." data-display_order="2">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4572]" value="103." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4572]" value="Vegetable Roll (2)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4572]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4572]" value="5.50,9.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4572"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4573" style="" data-dish="104." data-display_order="3">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4573]" value="104." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4573]" value="Chicken Roll (2)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4573]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4573]" value="6.25,11.00" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4573"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4574" style="" data-dish="105." data-display_order="4">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4574]" value="105." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4574]" value="Pork Roll (2)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4574]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4574]" value="6.25,11.00" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4574"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4575" style="" data-dish="106." data-display_order="5">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4575]" value="106." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4575]" value="Fried Wonton (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4575]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4575]" value="6.50,11.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4575"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4576" style="" data-dish="107." data-display_order="6">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4576]" value="107." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4576]" value="Chicken Wings (8)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4576]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4576]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4576"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4577" style="" data-dish="108." data-display_order="7">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4577]" value="108." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4577]" value="Honey Garlic Spare Ribs" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4577]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4577]" value="9.00,16.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4577"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4578" style="" data-dish="109." data-display_order="8">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4578]" value="109." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4578]" value="Chicken Fingers (8)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4578]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4578]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4578"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4579" style="" data-dish="110." data-display_order="9">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4579]" value="110." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4579]" value="Chicken Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4579]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4579]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4579"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4580" style="" data-dish="111." data-display_order="10">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4580]" value="111." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4580]" value="Beef Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4580]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4580]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4580"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4581" style="" data-dish="112." data-display_order="11">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4581]" value="112." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4581]" value="Shrimp Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4581]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4581]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4581"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4582" style="" data-dish="113." data-display_order="12">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4582]" value="113." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4582]" value="Breaded Shrimp (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4582]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4582]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4582"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4583" style="" data-dish="114." data-display_order="13">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4583]" value="114." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4583]" value="Butterfly Shrimp (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4583]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4583]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4583"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4584" style="" data-dish="115." data-display_order="14">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4584]" value="115." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4584]" value="Dry Garlic Spare Ribs" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4584]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4584]" value="9.00,16.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4584"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4585" style="" data-dish="116." data-display_order="15">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4585]" value="116." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4585]" value="Dry Garlic Chicken Wings (8)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4585]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4585]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4585"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4586" style="" data-dish="117." data-display_order="16">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4586]" value="117." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4586]" value="Dry Garlic Chicken Fingers (8)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4586]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4586]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4586"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4587" style="" data-dish="118." data-display_order="17">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4587]" value="118." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4587]" value="Dry Garlic Chicken Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4587]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4587]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4587"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4588" style="" data-dish="119." data-display_order="18">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4588]" value="119." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4588]" value="Dry Garlic Beef Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4588]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4588]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4588"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4589" style="" data-dish="120." data-display_order="19">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4589]" value="120." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4589]" value="Dry Garlic Shrimp Balls (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4589]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4589]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4589"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4590" style="" data-dish="121." data-display_order="20">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4590]" value="121." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4590]" value="Dry Garlic Breaded Shrimp (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4590]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4590]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4590"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4591" style="" data-dish="122." data-display_order="21">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4591]" value="122." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4591]" value="Dry Garlic Butterfly Shrimp (10)" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4591]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4591]" value="8.50,15.50" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4591"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="jarviswidget" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false" data-widget-custombutton="false" data-widget-sortable="false" role="widget">
            <header role="heading">
                <h2>Soups</h2>
            </header>
            <div role="content">
                <div class="widget-body">
                    <table class="table table-bordered show-dishes">
                        <tbody class="ui-sortable">
                            <tr class="sort" data-id="4592" style="" data-dish="201." data-display_order="0">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4592]" value="201." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4592]" value="Wonton Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4592]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4592]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4592"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4593" style="" data-dish="202." data-display_order="1">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4593]" value="202." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4593]" value="Egg Drop Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4593]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4593]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4593"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4594" style="" data-dish="203." data-display_order="2">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4594]" value="203." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4594]" value="Chicken Corn Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4594]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4594]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4594"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4595" style="" data-dish="204." data-display_order="3">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4595]" value="204." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4595]" value="Chicken Rice Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4595]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4595]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4595"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4596" style="" data-dish="205." data-display_order="4">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4596]" value="205." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4596]" value="Chicken Noodle Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4596]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4596]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4596"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4597" style="" data-dish="206." data-display_order="5">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4597]" value="206." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4597]" value="Hot &amp; Sour Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4597]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4597]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4597"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                            <tr class="sort" data-id="4598" style="" data-dish="207." data-display_order="6">
                                <td class="text-center" style="width: 5%"><i class="fa fa-arrows-v"></i></td>
                                <td style="width: 25%">
                                    <input type="text" name="name[4598]" value="207." class="form-control">
                                </td>
                                <td style="width: 35%">
                                    <input type="text" name="desc[4598]" value="Chicken Vegetable Soup" class="form-control">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="size[4598]" value="Small,Large" class="form-control size">
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="price[4598]" value="4.25,7.75" class="form-control price">
                                </td>
                                <td class="text-center" style="width: 5%">
                                    <a href="#" class="btn btn-danger btn-xs delete-dish" data-id="4598"><i class="fa fa-trash-o"></i></a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
"""


class DishData:
    """Represents a dish extracted from HTML."""
    def __init__(self, v1_id: str, name: str, description: str, sizes: List[str], prices: List[float]):
        self.v1_id = v1_id
        self.name = name.strip()
        self.description = description.strip()
        self.sizes = [s.strip() for s in sizes]
        self.prices = prices


def parse_html_dishes() -> List[DishData]:
    """
    Parse HTML markup to extract dish data.
    
    Returns:
        List of DishData objects
    """
    logger.info("Parsing HTML markup...")
    soup = BeautifulSoup(HTML_MARKUP, 'html.parser')
    dishes = []
    
    # Find all dish rows
    rows = soup.find_all('tr', class_='sort')
    
    for row in rows:
        try:
            v1_id = row.get('data-id')
            
            # Extract name
            name_input = row.find('input', {'name': lambda x: x and x.startswith('name[')})
            name = name_input.get('value', '') if name_input else ''
            
            # Extract description
            desc_input = row.find('input', {'name': lambda x: x and x.startswith('desc[')})
            description = desc_input.get('value', '') if desc_input else ''
            
            # Extract sizes
            size_input = row.find('input', {'name': lambda x: x and x.startswith('size[')})
            size_str = size_input.get('value', '') if size_input else ''
            sizes = [s.strip() for s in size_str.split(',') if s.strip()]
            
            # Extract prices
            price_input = row.find('input', {'name': lambda x: x and x.startswith('price[')})
            price_str = price_input.get('value', '') if price_input else ''
            prices = [float(p.strip()) for p in price_str.split(',') if p.strip()]
            
            if name and sizes and prices:
                dish = DishData(v1_id, name, description, sizes, prices)
                dishes.append(dish)
                logger.debug(f"Parsed dish: {name} with {len(sizes)} sizes and {len(prices)} prices")
        
        except Exception as e:
            logger.error(f"Error parsing row {row.get('data-id')}: {e}")
            continue
    
    logger.info(f"Found {len(dishes)} dishes in HTML markup")
    return dishes


def match_dish_by_name(html_name: str, v3_dishes: List[Dict]) -> Optional[int]:
    """
    Match HTML dish name to V3 dish by exact name_en match.
    
    Args:
        html_name: Dish name from HTML
        v3_dishes: List of V3 dishes with id and name_en
    
    Returns:
        dish_id or None if no match found
    """
    html_name_clean = html_name.strip()
    for dish in v3_dishes:
        if dish['name_en'].strip() == html_name_clean:
            return dish['id']
    return None


def get_v3_dishes(conn) -> List[Dict]:
    """
    Query all dishes for restaurant_id = 147.
    
    Returns:
        List of dicts with id and name_en
    """
    logger.info(f"Querying dishes for restaurant_id = {RESTAURANT_ID}...")
    
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(f"""
            SELECT id, name_en
            FROM {SCHEMA}.dishes
            WHERE restaurant_id = %s
            ORDER BY name_en
        """, (RESTAURANT_ID,))
        
        dishes = cur.fetchall()
        logger.info(f"Found {len(dishes)} dishes in V3 database")
        return dishes


def get_size_variant_id(conn, size_name: str) -> Optional[int]:
    """
    Query dish_size_variants by name_en to get variant ID.
    
    Args:
        conn: Database connection
        size_name: Size variant name (e.g., "Small", "Large")
    
    Returns:
        Size variant ID or None if not found
    """
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(f"""
            SELECT id
            FROM {SCHEMA}.dish_size_variants
            WHERE name_en = %s
        """, (size_name,))
        
        result = cur.fetchone()
        return result['id'] if result else None


def update_dish_prices(conn, dish_id: int, html_dish: DishData) -> Tuple[int, int]:
    """
    Update prices for a single dish.
    
    Args:
        conn: Database connection
        dish_id: V3 dish ID
        html_dish: DishData object with sizes and prices
    
    Returns:
        Tuple of (deleted_count, inserted_count)
    """
    with conn.cursor() as cur:
        # Delete existing prices
        cur.execute(f"""
            DELETE FROM {SCHEMA}.dish_prices
            WHERE dish_id = %s
        """, (dish_id,))
        deleted_count = cur.rowcount
        
        # Insert new prices
        inserted_count = 0
        for size, price in zip(html_dish.sizes, html_dish.prices):
            # Get size variant ID
            size_variant_id = get_size_variant_id(conn, size)
            
            if size_variant_id is None:
                logger.warning(f"  ⚠ Size variant '{size}' not found in database, skipping")
                continue
            
            # Insert price
            cur.execute(f"""
                INSERT INTO {SCHEMA}.dish_prices (dish_id, dish_size_variant_id, price)
                VALUES (%s, %s, %s)
            """, (dish_id, size_variant_id, price))
            inserted_count += 1
        
        return deleted_count, inserted_count


def main():
    """Main execution function."""
    logger.info("=" * 80)
    logger.info(f"Starting price update for restaurant ID {RESTAURANT_ID}")
    logger.info("=" * 80)
    
    # Parse HTML
    html_dishes = parse_html_dishes()
    
    # Connect to database
    logger.info("Connecting to database...")
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    conn.autocommit = False  # Use transactions
    
    try:
        # Get V3 dishes
        v3_dishes = get_v3_dishes(conn)
        
        # Statistics
        matched_count = 0
        unmatched_count = 0
        total_deleted = 0
        total_inserted = 0
        
        logger.info("")
        logger.info("Matching and updating dishes...")
        logger.info("-" * 80)
        
        # Process each HTML dish
        for html_dish in html_dishes:
            # Try to match by name
            dish_id = match_dish_by_name(html_dish.name, v3_dishes)
            
            if dish_id is None:
                logger.warning(f"✗ Unmatched: '{html_dish.name}' (not found in V3)")
                unmatched_count += 1
                continue
            
            # Update prices
            deleted, inserted = update_dish_prices(conn, dish_id, html_dish)
            total_deleted += deleted
            total_inserted += inserted
            matched_count += 1
            
            logger.info(f"✓ Dish {dish_id} ('{html_dish.name}'): Deleted {deleted} old prices, inserted {inserted} new prices")
        
        # Commit transaction
        conn.commit()
        logger.info("")
        logger.info("=" * 80)
        logger.info("SUMMARY")
        logger.info("=" * 80)
        logger.info(f"Total HTML dishes: {len(html_dishes)}")
        logger.info(f"Successfully matched: {matched_count}")
        logger.info(f"Unmatched (skipped): {unmatched_count}")
        logger.info(f"Total prices deleted: {total_deleted}")
        logger.info(f"Total prices inserted: {total_inserted}")
        logger.info("=" * 80)
        logger.info("✓ Price update completed successfully!")
        
    except Exception as e:
        conn.rollback()
        logger.error(f"Error during update: {e}")
        logger.error("Transaction rolled back")
        raise
    
    finally:
        conn.close()


if __name__ == '__main__':
    main()
