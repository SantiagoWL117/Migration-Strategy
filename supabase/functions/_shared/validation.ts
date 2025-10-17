// Input validation utilities

import type { ValidationResult } from './types.ts';

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
 * Validate positive integer
 */
export function validatePositiveInteger(value: any): boolean {
  const num = parseInt(value, 10);
  return !isNaN(num) && num > 0 && Number.isInteger(num);
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
 * Sanitize input string
 */
export function sanitizeString(input: string): string {
  return input
    .trim()
    .replace(/\s+/g, ' ')
    .substring(0, 1000); // Max length safety
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










