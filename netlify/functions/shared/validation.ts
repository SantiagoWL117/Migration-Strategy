// Input validation utilities

import type { ValidationResult } from './types';

/**
 * Validate required fields exist
 */
export function validateRequired(
  data: Record<string, any>,
  fields: string[]
): ValidationResult {
  const missing = fields.filter(field => !data[field]);
  
  if (missing.length > 0) {
    return {
      valid: false,
      error: `Missing required fields: ${missing.join(', ')}`,
      errors: missing.reduce((acc, field) => ({
        ...acc,
        [field]: 'This field is required'
      }), {})
    };
  }

  return { valid: true };
}

/**
 * Validate restaurant status
 */
export function validateRestaurantStatus(status: string): boolean {
  return ['pending', 'active', 'suspended', 'inactive', 'closed'].includes(status);
}

/**
 * Validate timezone (IANA timezone format)
 */
export function validateTimezone(timezone: string): boolean {
  // Common Canadian timezones
  const validTimezones = [
    'America/Toronto',
    'America/Montreal',
    'America/Vancouver',
    'America/Edmonton',
    'America/Winnipeg',
    'America/Regina',
    'America/Halifax',
    'America/St_Johns',
  ];
  
  return validTimezones.includes(timezone);
}

/**
 * Validate slug format (lowercase, alphanumeric, hyphens only)
 */
export function validateSlug(slug: string): boolean {
  return /^[a-z0-9-]+$/.test(slug);
}

/**
 * Generate slug from name
 */
export function generateSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

/**
 * Validate tag category
 */
export function validateTagCategory(category: string): boolean {
  return ['dietary', 'service', 'atmosphere', 'feature', 'payment'].includes(category);
}

/**
 * Validate email format
 */
export function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Validate restaurant name
 */
export function validateRestaurantName(name: string): ValidationResult {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: 'Restaurant name is required' };
  }

  if (name.length < 2) {
    return { valid: false, error: 'Restaurant name must be at least 2 characters' };
  }

  if (name.length > 255) {
    return { valid: false, error: 'Restaurant name must be less than 255 characters' };
  }

  return { valid: true };
}

/**
 * Validate cuisine name
 */
export function validateCuisineName(name: string): ValidationResult {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: 'Cuisine name is required' };
  }

  if (name.length < 2) {
    return { valid: false, error: 'Cuisine name must be at least 2 characters' };
  }

  if (name.length > 100) {
    return { valid: false, error: 'Cuisine name must be less than 100 characters' };
  }

  return { valid: true };
}

/**
 * Validate tag name
 */
export function validateTagName(name: string): ValidationResult {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: 'Tag name is required' };
  }

  if (name.length < 2) {
    return { valid: false, error: 'Tag name must be at least 2 characters' };
  }

  if (name.length > 50) {
    return { valid: false, error: 'Tag name must be less than 50 characters' };
  }

  return { valid: true };
}

/**
 * Sanitize input string
 */
export function sanitizeString(input: string): string {
  return input
    .trim()
    .replace(/\s+/g, ' ')
    .substring(0, 1000); // Max length safety
}

/**
 * Validate positive integer
 */
export function validatePositiveInteger(value: any): boolean {
  const num = parseInt(value, 10);
  return !isNaN(num) && num > 0 && Number.isInteger(num);
}


