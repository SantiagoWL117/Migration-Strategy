/**
 * Configuration for all restaurants to scrape
 * Add your 26 restaurants here
 */

export interface RestaurantConfig {
  id: string; // Unique identifier
  name: string;
  version: 'v1' | 'v2';
  baseUrl: string;
  dishLimit?: number; // Max dishes to scrape (default: all)
  notes?: string;
}

export const RESTAURANTS: RestaurantConfig[] = [
  // V1 Sites (Papa Burger style - multi-step modals)
  {
    id: 'papa-burger',
    name: 'Papa Burger',
    version: 'v1',
    baseUrl: 'https://papaburger.ca/?p=menu',
    dishLimit: 15,
    notes: 'Multi-step combo customization with sauces and drinks'
  },

  // V2 Sites (MENU.CA V2 - single-page customization)
  {
    id: 'parea-greek',
    name: 'Paréa Authentic Greek',
    version: 'v2',
    baseUrl: 'https://ordereast.eatparea.com/index.php/menu',
    dishLimit: 15,
    notes: 'Grouped customization with toppings, sauces, extras'
  },

  // Add your other 24 restaurants below:
  // Example structure:
  // {
  //   id: 'restaurant-slug',
  //   name: 'Restaurant Display Name',
  //   version: 'v1' or 'v2',
  //   baseUrl: 'https://restaurant-url.com/menu',
  //   dishLimit: 10, // optional
  //   notes: 'Any special notes about this restaurant'
  // },

];

// Helper to find restaurant by ID
export function getRestaurantById(id: string): RestaurantConfig | undefined {
  return RESTAURANTS.find(r => r.id === id);
}

// Get all V1 restaurants
export function getV1Restaurants(): RestaurantConfig[] {
  return RESTAURANTS.filter(r => r.version === 'v1');
}

// Get all V2 restaurants
export function getV2Restaurants(): RestaurantConfig[] {
  return RESTAURANTS.filter(r => r.version === 'v2');
}

// Export restaurant count
export const RESTAURANT_COUNT = RESTAURANTS.length;