/**
 * Restaurant configurations for Menu.ca scrapers
 *
 * Organized by version (V1 vs V2) for the 26 locations to scrape
 */

import { ScraperConfig } from './types';

export const V1_RESTAURANTS: Record<string, Omit<ScraperConfig, 'headless' | 'screenshotsDir' | 'outputDir'>> = {
  'papa-burger': {
    restaurantName: 'Papa Burger',
    baseUrl: 'https://papaburger.ca/?p=menu',
    version: 'v1'
  },
  // Add your other 25 V1 restaurants here
  // Example:
  // 'restaurant-2': {
  //   restaurantName: 'Restaurant 2',
  //   baseUrl: 'https://restaurant2.ca/?p=menu',
  //   version: 'v1'
  // },
};

export const V2_RESTAURANTS: Record<string, Omit<ScraperConfig, 'headless' | 'screenshotsDir' | 'outputDir'>> = {
  // Add V2 restaurants here when ready
  // Example:
  // 'parea-greek': {
  //   restaurantName: 'Parea Greek',
  //   baseUrl: 'https://order.menu.ca/merchant/17322',
  //   version: 'v2'
  // },
};

export function getRestaurantConfig(slug: string): Omit<ScraperConfig, 'headless' | 'screenshotsDir' | 'outputDir'> | null {
  return V1_RESTAURANTS[slug] || V2_RESTAURANTS[slug] || null;
}

export function listAllRestaurants(): string[] {
  return [...Object.keys(V1_RESTAURANTS), ...Object.keys(V2_RESTAURANTS)];
}
