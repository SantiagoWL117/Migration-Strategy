/**
 * Test scraper for Papa Burger specifically
 * Uses improved V1 scraper with location gate handling
 */

import { scrapeV1RestaurantImproved } from './v1-scraper-improved';

async function main() {
  console.log('\n🍔 Testing Papa Burger V1 Scraper\n');

  const result = await scrapeV1RestaurantImproved({
    restaurantName: 'Papa Burger',
    baseUrl: 'https://papaburger.ca/?p=menu',
    version: 'v1',
    headless: false, // Watch it work!
    screenshotsDir: './screenshots/papa-burger-test',
    outputDir: './scraped-data/papa-burger-test'
  });

  console.log('\n✅ Test complete!');
  console.log(`Check output in: ./scraped-data/papa-burger-test/`);
  console.log(`Screenshots in: ./screenshots/papa-burger-test/`);
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
