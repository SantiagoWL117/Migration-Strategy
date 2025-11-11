/**
 * Batch 3: Chicco St-Louis, Chicco Hopital, Chicco Cantley, Chicco Shawarma Maloney, Cuisine Bombay
 */

import { scrapeV2Restaurant } from '../../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🚀 Starting Batch 3: 5 restaurants in parallel\n');
  const startTime = Date.now();

  const results = await Promise.allSettled([
    scrapeV2Restaurant({
      restaurantName: 'Chicco Pizza St-Louis',
      baseUrl: 'https://1783ruesaint-louis.chiccopizzashawarma.com',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-stlouis',
      outputDir: './scraped-data/chicco-stlouis'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Pizza de l Hopital',
      baseUrl: 'https://405bouldelhopital.chiccopizzashawarma.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-hopital',
      outputDir: './scraped-data/chicco-hopital'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Shawarma Cantley',
      baseUrl: 'https://435monteedelasource.chiccopizzashawarma.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-cantley',
      outputDir: './scraped-data/chicco-cantley'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Shawarma Maloney',
      baseUrl: 'https://992boulevardmaloneyest.chiccopizzashawarma.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-shawarma-maloney',
      outputDir: './scraped-data/chicco-shawarma-maloney'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Cuisine Bombay Indienne',
      baseUrl: 'https://bombayindienne.ca/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/bombay-indienne',
      outputDir: './scraped-data/bombay-indienne'
    })
  ]);

  const endTime = Date.now();
  const totalTime = ((endTime - startTime) / 1000 / 60).toFixed(2);

  console.log('\n' + '='.repeat(60));
  console.log('BATCH 3 COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total time: ${totalTime} minutes\n`);

  const names = ['Chicco St-Louis', 'Chicco Hopital', 'Chicco Cantley', 'Chicco Shawarma Maloney', 'Cuisine Bombay'];
  results.forEach((result, idx) => {
    console.log(`\n${idx + 1}. ${names[idx]}:`);
    if (result.status === 'fulfilled') {
      const { summary } = result.value;
      console.log(`   ✅ Success: ${summary.successCount}/${summary.totalDishes} dishes`);
      console.log(`   📊 Groups: ${summary.totalGroups}, Options: ${summary.totalOptions}`);
      if (summary.errorCount > 0) {
        console.log(`   ⚠️  Errors: ${summary.errorCount}`);
      }
    } else {
      console.log(`   ❌ Failed: ${result.reason}`);
    }
  });

  console.log('\n' + '='.repeat(60) + '\n');
}

main().catch(error => {
  console.error('Batch scrape failed:', error);
  process.exit(1);
});
