/**
 * Type definitions for menu scraping system
 */

// Core types matching the database schema
export interface ModifierOption {
  name: string;
  priceDelta: number;
  isDefault?: boolean;
  description?: string;
  maxQuantity?: number;
}

export interface ModifierGroup {
  name: string;
  description?: string;
  selectType: 'single' | 'multi';
  minSelections: number;
  maxSelections: number | null;
  allowQuantityPerOption?: boolean;
  isRequired: boolean;
  displayOrder: number;
  stepOrder?: number | null; // For V1 multi-step wizards
  options: ModifierOption[];
}

export interface ScrapedDish {
  restaurant: string;
  restaurantUrl: string;
  dish: {
    name: string;
    description?: string;
    basePrice: number | null;
    category?: string;
  };
  groups: ModifierGroup[];
  metadata: {
    scrapedAt: string;
    version: 'v1' | 'v2';
    dishUrl: string;
  };
}

export interface ScraperResult {
  success: boolean;
  dishes: ScrapedDish[];
  errors: Array<{
    dishName?: string;
    error: string;
    timestamp: string;
  }>;
  summary: {
    totalDishes: number;
    successCount: number;
    errorCount: number;
    totalGroups: number;
    totalOptions: number;
  };
}

// Scraper configuration
export interface ScraperConfig {
  restaurantName: string;
  baseUrl: string;
  version: 'v1' | 'v2';
  headless?: boolean;
  timeout?: number;
  screenshotsDir?: string;
  outputDir?: string;
}

// V1-specific types (Papa Burger style)
export interface V1StepData {
  stepNumber: number;
  groupName: string;
  options: Array<{
    name: string;
    priceDelta: number;
    linkText: string;
  }>;
  isRequired: boolean;
  nextButtonEnabled: boolean;
}

// V2-specific types (MENU.CA V2 style)
export interface V2GroupData {
  groupName: string;
  inputType: 'radio' | 'checkbox';
  options: Array<{
    name: string;
    priceDelta: number;
    inputId: string;
    labelText: string;
  }>;
  hintText?: string;
  isRequired: boolean;
}

export interface DishConfiguration {
  dishId: number;
  basePriceSnapshot: number;
  totalPrice: number;
  selectedOptions: Array<{
    groupId: number;
    optionId: number;
    quantity: number;
    priceDeltaSnapshot: number;
  }>;
}