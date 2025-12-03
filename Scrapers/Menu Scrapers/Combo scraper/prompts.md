Ok, let's build the scraper for the Phase 1. 

We will use the legacy CRMs to scrape the data. We need to build two scrapers one for the v1 CRM and another for the v2 CRM. We should go over all the restaurants stored in menuca_v3.restaurants. Each restaurant has a legacy_v1_id or a legacy_v2_id. This should be our primary criteria to determine which restaurant will be scraped in the v1 scraper and which restaurant should be scraped in the v2 scraper. 

All the required credentials are in this folder, read 

- Instructions: 
1. In the landing page you will find the v1 restaurants under an <ul id="active"> element. Each V1 restaurant is stored in an <li> element:


Each <li> element has an <a> element containing a link to the details page of each restaurant. This <a> element also contians the unique v1 id that identifies each restaurant. For instance the restaurant Aahar The Taste of India the a element contains its v1 id (781) in the href parameter href="/?p=restaurants&amp;display=editRestaurant&amp;restaurant=781". You should use this element to both identify the v1 restaurants that must be scraped and access its details page where the data that needs to be scrapped is located.

2. Once you get to the details page of each restaurant you will find 