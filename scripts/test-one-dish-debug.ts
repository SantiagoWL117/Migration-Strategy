/**
 * Test ONLY dishes 1-5 to debug the Continue button issue
 */

import { scrapeV2Restaurant } from '../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🔍 Testing first 5 dishes only\n');

  const result = await scrapeV2Restaurant({
    restaurantName: 'Cosenza Pizza & Calzones',
    baseUrl: 'https://cosenzapizzancalzones.ca/index.php/menu',
    version: 'v2',
    headless: false,
    screenshotsDir: './screenshots/test-debug',
    outputDir: './scraped-data/test-debug'
  });

  console.log('\n✅ Test complete!');
  console.log(`Scraped: ${result.summary.successCount}/${result.summary.totalDishes}`);
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
