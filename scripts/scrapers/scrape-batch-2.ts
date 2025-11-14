/**
 * Batch 2: Capital Bites, Capri Pizza, Chicco Buckingham, Chicco Maloney, Chicco Anger
 */

import { scrapeV2Restaurant } from '../../menu-scraper/src/scrapers/v2-scraper';

async function main() {
  console.log('\n🚀 Starting Batch 2: 5 restaurants in parallel\n');
  const startTime = Date.now();

  const results = await Promise.allSettled([
    scrapeV2Restaurant({
      restaurantName: 'Capital Bites',
      baseUrl: 'https://capitalbites.ca/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/capital-bites',
      outputDir: './scraped-data/capital-bites'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Capri Pizza',
      baseUrl: 'https://capripizzaottawa.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/capri-pizza',
      outputDir: './scraped-data/capri-pizza'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Pizza Shawarma Buckingham',
      baseUrl: 'https://1009chemdemasson.chiccopizzashawarma.com/index.php/restaurant/chicco-pizza-shawarma-buckingham',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-buckingham',
      outputDir: './scraped-data/chicco-buckingham'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Pizza Maloney',
      baseUrl: 'https://842boulevardmaloneyest.chiccopizzashawarma.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-maloney',
      outputDir: './scraped-data/chicco-maloney'
    }),

    scrapeV2Restaurant({
      restaurantName: 'Chicco Pizza Shawarma Anger',
      baseUrl: 'https://1096chemindemontrealo.chiccopizzashawarma.com/index.php/menu',
      version: 'v2',
      headless: true,
      screenshotsDir: './screenshots/chicco-anger',
      outputDir: './scraped-data/chicco-anger'
    })
  ]);

  const endTime = Date.now();
  const totalTime = ((endTime - startTime) / 1000 / 60).toFixed(2);

  console.log('\n' + '='.repeat(60));
  console.log('BATCH 2 COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total time: ${totalTime} minutes\n`);

  const names = ['Capital Bites', 'Capri Pizza', 'Chicco Buckingham', 'Chicco Maloney', 'Chicco Anger'];
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
