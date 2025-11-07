/**
 * Test the simple V1 scraper on Papa Burger
 */

import { scrapeV1RestaurantSimple } from './v1-simple-scraper';

async function main() {
  console.log('\n🍔 Testing SIMPLE V1 Scraper on Papa Burger\n');

  const result = await scrapeV1RestaurantSimple({
    restaurantName: 'Papa Burger',
    baseUrl: 'https://papaburger.ca/?p=menu',
    version: 'v1',
    headless: false,
    screenshotsDir: './screenshots/papa-burger-simple',
    outputDir: './scraped-data/papa-burger-simple'
  });

  console.log('\n✅ Test complete!');
  console.log(`Check output in: ./scraped-data/papa-burger-simple/`);
  console.log(`Screenshots in: ./screenshots/papa-burger-simple/`);
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
