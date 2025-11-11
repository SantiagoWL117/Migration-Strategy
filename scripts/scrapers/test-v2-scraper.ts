/**
 * Test the V2 scraper on Cosenza Pizza & Calzones
 *
 * This tests single-page form sites with:
 * - Address/pickup modal gate
 * - Radio button and checkbox modifiers
 * - Add-to-cart functionality
 */

import { scrapeV2Restaurant } from '../../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🍕 Testing V2 Scraper on Cosenza Pizza & Calzones\n');

  const result = await scrapeV2Restaurant({
    restaurantName: 'Cosenza Pizza & Calzones',
    baseUrl: 'https://cosenzapizzancalzones.ca/index.php/menu',
    version: 'v2',
    headless: false,
    screenshotsDir: './screenshots/cosenza-pizza',
    outputDir: './scraped-data/cosenza-pizza'
  });

  console.log('\n✅ Test complete!');
  console.log(`Check output in: ./scraped-data/cosenza-pizza/`);
  console.log(`Screenshots in: ./screenshots/cosenza-pizza/`);

  if (result.summary.errorCount > 0) {
    console.log('\n⚠️  Errors encountered:');
    result.errors.forEach(error => {
      console.log(`  - ${error.dishName || 'Unknown'}: ${error.error}`);
    });
  }
}

main().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
