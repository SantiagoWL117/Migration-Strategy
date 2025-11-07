/**
 * Firecrawl Name Scraper - Get dish names using Firecrawl
 */

import FirecrawlApp from '@mendable/firecrawl-js';
import * as fs from 'fs';
import * as path from 'path';

interface DishName {
  index: number;
  name: string;
  description: string | null;
  price: string | null;
  category: string | null;
}

async function scrapeNamesWithFirecrawl(url: string, restaurantName: string, outputDir: string = './scraped-data/firecrawl') {
  console.log('\n🔥 Firecrawl Name Scraper\n');
  console.log(`Restaurant: ${restaurantName}`);
  console.log(`URL: ${url}\n`);

  fs.mkdirSync(outputDir, { recursive: true });

  const firecrawl = new FirecrawlApp({ apiKey: 'fc-ac838657c3104fb78ac162ef8792fc97' });

  try {
    console.log('🕷️  Scraping with Firecrawl...');
    const result = await firecrawl.scrape(url, {
      formats: ['markdown'],
      waitFor: 3000
    });

    if (!result.markdown) {
      throw new Error('No markdown content returned');
    }

    console.log(`✅ Got ${result.markdown.length} characters of content\n`);

    // Save raw markdown
    const mdPath = path.join(outputDir, `${restaurantName.toLowerCase().replace(/\s+/g, '-')}-raw.md`);
    fs.writeFileSync(mdPath, result.markdown);
    console.log(`💾 Saved raw markdown to: ${mdPath}\n`);

    // Parse dish names from markdown
    console.log('📝 Parsing dish names...\n');
    const dishes: DishName[] = [];
    const lines = result.markdown.split('\n');

    let currentCategory: string | null = null;
    let buffer: string[] = []; // Buffer to collect lines before price table
    let dishIndex = 0;
    let categoryBuffer: string[] = []; // Separate buffer for category detection

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Skip empty lines
      if (!line) continue;

      // Detect categories after [Haut] links
      if (line.includes('[Haut]')) {
        // Next non-empty line after [Haut] is usually a category
        categoryBuffer = [];
        buffer = [];
        continue;
      }

      // Skip standalone images
      if (line.startsWith('![') && !line.startsWith('|')) {
        continue;
      }

      // Skip table separator lines
      if (line.match(/^\|\s*---/)) continue;

      // Check if this is a table row (starts with |)
      if (line.match(/^\|/)) {
        // Check if this line has a price and order button (it's a price row)
        if (line.includes('Choisissez cet item') && line.includes('$')) {
          const priceMatch = line.match(/\$\s*(\d+[.,]\d{2})/);

          if (priceMatch && buffer.length > 0) {
            // Check for size variant in price line
            const sizeMatch = line.match(/\|\s*»\s*([^|$]+?)\s*\|/);

            let dishName: string;
            let description: string | null = null;

            // Use category buffer if we just passed [Haut] and buffer[0] looks like category
            if (categoryBuffer.length > 0 && buffer.length >= 2 && buffer[0].length < 50 && !buffer[0].includes(',')) {
              currentCategory = categoryBuffer[0] || buffer[0];
              console.log(`\n📁 ${currentCategory}`);
              categoryBuffer = [];
            }

            if (sizeMatch && sizeMatch[1].trim()) {
              // Has size variant (e.g., "Petit", "Grande")
              // First line in buffer is dish name
              dishName = `${buffer[0]} (${sizeMatch[1].trim()})`;
              // Second line (if exists) is description
              if (buffer.length > 1) {
                description = buffer.slice(1).join(' ').trim() || null;
              }
            } else {
              // No size variant
              // First line is dish name
              dishName = buffer[0];
              // Remaining lines are description
              if (buffer.length > 1) {
                description = buffer.slice(1).join(' ').trim() || null;
              }
              // Clear buffer after use
              buffer = [];
            }

            dishes.push({
              index: dishIndex++,
              name: dishName,
              description,
              price: priceMatch[1],
              category: currentCategory
            });

            console.log(`  ${dishIndex}. ${dishName} - $${priceMatch[1]}`);
          }
        }
        continue;
      }

      // Regular text line - add to buffer
      // If we just passed [Haut], first line is likely category
      if (categoryBuffer.length === 0 && buffer.length === 0) {
        categoryBuffer.push(line);
        currentCategory = line;
        console.log(`\n📁 ${currentCategory}`);
      } else {
        buffer.push(line);
      }
    }

    console.log(`\n✅ Found ${dishes.length} dishes\n`);

    // Save parsed dishes
    const jsonPath = path.join(outputDir, `${restaurantName.toLowerCase().replace(/\s+/g, '-')}-names.json`);
    fs.writeFileSync(jsonPath, JSON.stringify({
      restaurant: restaurantName,
      url,
      scrapedAt: new Date().toISOString(),
      totalDishes: dishes.length,
      dishes
    }, null, 2));

    console.log(`💾 Saved dish names to: ${jsonPath}`);

    return {
      success: true,
      totalDishes: dishes.length,
      dishes,
      outputPath: jsonPath
    };

  } catch (error: any) {
    console.error('❌ Firecrawl error:', error.message);
    return {
      success: false,
      totalDishes: 0,
      dishes: [],
      error: error.message
    };
  }
}

// CLI
async function main() {
  const result = await scrapeNamesWithFirecrawl(
    'https://papaburger.ca/?p=menu',
    'Papa Burger',
    './scraped-data/papa-burger-firecrawl'
  );

  if (result.success) {
    console.log('\n🎉 Done!');
  } else {
    console.error('\n❌ Failed:', result.error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

export { scrapeNamesWithFirecrawl };
