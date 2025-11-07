/**
 * Merge Database Dishes with Scraped Modifiers
 *
 * Strategy:
 * 1. Get Papa Burger Maloney dishes from database (64 dishes with names)
 * 2. Get scraped modifiers (80 dishes with perfect modifier data)
 * 3. Match by position/index
 * 4. Create import-ready data
 */

import * as fs from 'fs';
import * as path from 'path';

interface DatabaseDish {
  id: number;
  name: string;
  legacy_v1_id: number;
  description: string | null;
}

interface ScrapedDish {
  dish: {
    name: string;
    basePrice: number | null;
  };
  groups: any[];
}

async function mergeDatabaseWithScraped() {
  console.log('\n🔗 Merging Database Dishes with Scraped Modifiers\n');

  // Load the scraped data
  const scrapedPath = './scraped-data/papa-burger-test/papa-burger-2025-11-07T18-30-45-915Z.json';
  const scraped = JSON.parse(fs.readFileSync(scrapedPath, 'utf-8'));

  console.log(`📂 Loaded scraped data: ${scraped.dishes.length} dishes`);
  console.log(`   Total Groups: ${scraped.summary.totalGroups}`);
  console.log(`   Total Options: ${scraped.summary.totalOptions}\n`);

  // Database dishes from Papa Burger Maloney (ID: 822)
  const dbDishes: DatabaseDish[] = [
    { id: 15769, name: "Diet Pepsi", legacy_v1_id: 121201, description: null },
    { id: 15810, name: "7 Up", legacy_v1_id: 121202, description: null },
    { id: 15817, name: "Ginger Ale", legacy_v1_id: 121203, description: null },
    { id: 15861, name: "Orange Crush", legacy_v1_id: 121204, description: null },
    { id: 15955, name: "Grape Crush", legacy_v1_id: 121205, description: null },
    { id: 15961, name: "Iced Tea", legacy_v1_id: 121206, description: null },
    { id: 15962, name: "Cream Soda", legacy_v1_id: 121207, description: null },
    { id: 15963, name: "Mountain Dew", legacy_v1_id: 121208, description: null },
    { id: 15990, name: "Bubbly", legacy_v1_id: 121209, description: null },
    { id: 16255, name: "Juice", legacy_v1_id: 121210, description: null },
    { id: 16256, name: "Root Beer", legacy_v1_id: 121211, description: null },
    { id: 16257, name: "Perrier", legacy_v1_id: 121212, description: null },
    { id: 16258, name: "Eau Aquafina", legacy_v1_id: 121213, description: null },
    { id: 21154, name: "Frites", legacy_v1_id: 121152, description: null },
    { id: 21155, name: "Frites épicée", legacy_v1_id: 121153, description: null },
    { id: 21156, name: "Rondelles d'oignon", legacy_v1_id: 121154, description: null },
    { id: 21157, name: "Pain à l'ail (12\")", legacy_v1_id: 121155, description: null },
    { id: 21158, name: "Bâtonnetes de fromage", legacy_v1_id: 121156, description: null },
    { id: 21159, name: "Doigts de poulet", legacy_v1_id: 121157, description: null },
    { id: 21160, name: "Zucchinis", legacy_v1_id: 121158, description: null },
    { id: 21161, name: "Frites Patates Douces", legacy_v1_id: 121159, description: null },
    { id: 21162, name: "Cornichons Panés Frits", legacy_v1_id: 121160, description: null },
    { id: 21163, name: "Poutine", legacy_v1_id: 121161, description: null },
    { id: 21164, name: "Papa Poutine", legacy_v1_id: 121162, description: null },
    { id: 21165, name: "Poutine au Poulet", legacy_v1_id: 121163, description: null },
    { id: 21166, name: "Poutine au Steak", legacy_v1_id: 121164, description: null },
    { id: 21167, name: "Burger Originale (Burger Seule)", legacy_v1_id: 121165, description: null },
    { id: 21168, name: "Burger Originale Combo", legacy_v1_id: 121166, description: null },
    { id: 21169, name: "Cheeseburger (Burger Seule)", legacy_v1_id: 121167, description: null },
    { id: 21170, name: "Cheeseburger Combo", legacy_v1_id: 121168, description: null },
    { id: 21171, name: "Papa Burger (Burger Seule)", legacy_v1_id: 121169, description: null },
    { id: 21172, name: "Papa Burger Combo", legacy_v1_id: 121170, description: null },
    { id: 21173, name: "American Burger (Burger Seule) HIDE", legacy_v1_id: 121171, description: null },
    { id: 21174, name: "American Burger Combo HIDE", legacy_v1_id: 121172, description: null },
    { id: 21175, name: "Hot Burger (Burger Seule)", legacy_v1_id: 121173, description: null },
    { id: 21176, name: "Hot Burger Combo", legacy_v1_id: 121174, description: null },
    { id: 21177, name: "Burger Amateur de Viande (Burger Seule)", legacy_v1_id: 121175, description: null },
    { id: 21178, name: "Burger Amateur de Viande Combo", legacy_v1_id: 121176, description: null },
    { id: 21179, name: "Hamburger Double (Burger Seule)", legacy_v1_id: 121177, description: null },
    { id: 21180, name: "Hamburger Double Combo", legacy_v1_id: 121178, description: null },
    { id: 21181, name: "Burger au poulet et bacon (Burger Seule)", legacy_v1_id: 121179, description: null },
    { id: 21182, name: "Burger au poulet Combo", legacy_v1_id: 121180, description: null },
    { id: 21183, name: "Club Burger (Burger Seule) HIDE", legacy_v1_id: 121181, description: null },
    { id: 21184, name: "Burger Végétarien (Burger Seule) HIDE", legacy_v1_id: 121182, description: null },
    { id: 21185, name: "Burger Végétarien Combo HIDE", legacy_v1_id: 121183, description: null },
    { id: 21186, name: "Hamburger Steak", legacy_v1_id: 121184, description: null },
    { id: 21187, name: "Papa Nachos", legacy_v1_id: 121185, description: null },
    { id: 21188, name: "Papa Club Sandwich", legacy_v1_id: 121186, description: null },
    { id: 21189, name: "Club Sandwich Poutine", legacy_v1_id: 121187, description: null },
    { id: 21190, name: "Burger au poulet avec frites", legacy_v1_id: 121188, description: null },
    { id: 21191, name: "Bouchées de poulet avec frites", legacy_v1_id: 121189, description: null },
    { id: 21192, name: "Doigts de pouet (2) avec frites", legacy_v1_id: 121190, description: null },
    { id: 21193, name: "Tartelette 3 choco", legacy_v1_id: 121191, description: null },
    { id: 21194, name: "Tartelette au sirop d'érable du Québec", legacy_v1_id: 121192, description: null },
    { id: 21195, name: "Gâteau fromage", legacy_v1_id: 121193, description: null },
    { id: 21196, name: "Brownies pour enfant", legacy_v1_id: 121194, description: null },
    { id: 21197, name: "Gâteau carrots", legacy_v1_id: 121195, description: null },
    { id: 21198, name: "Baklava", legacy_v1_id: 121196, description: null },
    { id: 21199, name: "12 Mini Beignets HIDE", legacy_v1_id: 121197, description: null },
    { id: 21200, name: "24 Mini Beignets HIDE", legacy_v1_id: 121198, description: null },
    { id: 21201, name: "36 Mini Beignets HIDE", legacy_v1_id: 121199, description: null },
    { id: 21202, name: "Pepsi", legacy_v1_id: 121200, description: null },
    { id: 21203, name: "Club Burger Combo HIDE", legacy_v1_id: 121214, description: null },
    { id: 21396, name: "Salade de Poulet Suprême", legacy_v1_id: 122855, description: null },
  ];

  console.log(`📊 Database has ${dbDishes.length} dishes\n`);

  // Merge strategy: Match first 64 by position
  const merged = [];
  const minLength = Math.min(dbDishes.length, scraped.dishes.length);

  for (let i = 0; i < minLength; i++) {
    const dbDish = dbDishes[i];
    const scrapedDish = scraped.dishes[i];

    merged.push({
      database_id: dbDish.id,
      legacy_v1_id: dbDish.legacy_v1_id,
      name: dbDish.name,
      description: dbDish.description,
      basePrice: scrapedDish.dish.basePrice,
      groups: scrapedDish.groups,
      match_confidence: 'position-based'
    });
  }

  // Handle remaining scraped dishes (65-80)
  if (scraped.dishes.length > dbDishes.length) {
    console.log(`⚠️  ${scraped.dishes.length - dbDishes.length} extra dishes found in scraper:\n`);
    for (let i = dbDishes.length; i < scraped.dishes.length; i++) {
      const scrapedDish = scraped.dishes[i];
      console.log(`   ${i + 1}. ${scrapedDish.dish.name} - ${scrapedDish.groups.length} groups`);

      merged.push({
        database_id: null,
        legacy_v1_id: null,
        name: scrapedDish.dish.name || `New Dish ${i + 1}`,
        description: null,
        basePrice: scrapedDish.dish.basePrice,
        groups: scrapedDish.groups,
        match_confidence: 'new-dish'
      });
    }
  }

  // Save merged data
  const outputPath = './scraped-data/papa-burger-test/papa-burger-MERGED.json';
  fs.writeFileSync(outputPath, JSON.stringify({
    restaurant: 'Papa Burger Maloney',
    restaurant_id: 822,
    total_dishes: merged.length,
    matched_dishes: minLength,
    new_dishes: Math.max(0, scraped.dishes.length - dbDishes.length),
    dishes: merged
  }, null, 2));

  console.log(`\n✅ Merge complete!`);
  console.log(`   Total: ${merged.length} dishes`);
  console.log(`   Matched: ${minLength} dishes`);
  console.log(`   New: ${Math.max(0, scraped.dishes.length - dbDishes.length)} dishes`);
  console.log(`\n💾 Saved to: ${outputPath}`);
}

mergeDatabaseWithScraped().catch(console.error);
