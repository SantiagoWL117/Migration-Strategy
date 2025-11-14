/**
 * Test dishes 74-80 with the new required modifier logic
 */

import { scrapeV2Restaurant } from '../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🔍 Testing dishes 74-80 with required modifier handling\n');

  // Temporarily modify scraper to only test specific dishes
  const result = await scrapeV2Restaurant({
    restaurantName: 'Cosenza Pizza & Calzones',
    baseUrl: 'https://cosenzapizzancalzones.ca/index.php/menu',
    version: 'v2',
    headless: false,
    screenshotsDir: './screenshots/test-74-80',
    outputDir: './scraped-data/test-74-80'
  });

  console.log('\n✅ Test complete!');
  console.log(`Scraped: ${result.summary.successCount}/${result.summary.totalDishes}`);
  console.log(`Errors: ${result.summary.errorCount}`);

  if (result.summary.errorCount > 0) {
    console.log('\n❌ Failed dishes:');
    result.errors.forEach(error => {
      console.log(`  - ${error.dishName || 'Unknown'}: ${error.error}`);
    });
  }
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
