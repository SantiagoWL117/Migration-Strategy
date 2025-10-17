// Shared TypeScript types for Supabase Edge Functions

export interface SupabaseUser {
  id: string;
  role?: string;
  email?: string;
  permissions?: string[];
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ValidationResult {
  valid: boolean;
  error?: string;
  errors?: Record<string, string>;
}

// Franchise types
export interface CreateFranchiseParentRequest {
  name: string;
  franchise_brand_name: string;
  city_id: number;
  province_id: number;
  timezone?: string;
  created_by?: number;
}

export interface ConvertToFranchiseRequest {
  restaurant_id: number;
  parent_restaurant_id: number;
  updated_by?: number;
}

export interface BatchLinkFranchiseRequest {
  parent_restaurant_id: number;
  child_restaurant_ids: number[];
  updated_by?: number;
}

export interface CascadeMenuRequest {
  parent_restaurant_id: number;
  child_restaurant_ids?: number[];
  dish_id?: number;
  include_pricing?: boolean;
}










