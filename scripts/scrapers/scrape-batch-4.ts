/**
 * Batch 4: Kirkwood Pizza, La Nawab, Little Gyros, Pachino Pizza, River Pizza
 * Note: Kirkwood uses kirkwoodpizza.ca (not /index.php/menu)
 */

import { scrapeV2Restaurant } from '../../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🚀 Starting Batch 4: 5 restaurants in parallel\n');
  const startTime = Date.now();

  const results = await Promise.allSettled([
    scrapeV2Restaurant({
      restaurantName: 'Kirkwood Pizza',
      baseUrl: 'https://kirkwoodpizza.ca',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/kirkwood-pizza',
      outputDir: './scraped-data/kirkwood-pizza'
    }),

    scrapeV2Restaurant({
      restaurantName: 'La Nawab',
      baseUrl: 'https://lanawab.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/la-nawab',
      outputDir: './scraped-data/la-nawab'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Little Gyros Greek Grill',
      baseUrl: 'https://kitchener.littlegyrosgreek.ca/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/little-gyros',
      outputDir: './scraped-data/little-gyros'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Pachino Pizza',
      baseUrl: 'https://order.pachinopizza.ca/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/pachino-pizza',
      outputDir: './scraped-data/pachino-pizza'
    }),

    scrapeV2Restaurant({
      restaurantName: 'River Pizza',
      baseUrl: 'https://order.riverpizza.ca',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/river-pizza',
      outputDir: './scraped-data/river-pizza'
    })
  ]);

  const endTime = Date.now();
  const totalTime = ((endTime - startTime) / 1000 / 60).toFixed(2);

  console.log('\n' + '='.repeat(60));
  console.log('BATCH 4 COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total time: ${totalTime} minutes\n`);

  const names = ['Kirkwood Pizza', 'La Nawab', 'Little Gyros', 'Pachino Pizza', 'River Pizza'];
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
