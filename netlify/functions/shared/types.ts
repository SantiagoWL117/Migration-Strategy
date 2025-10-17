// Shared TypeScript types for Netlify Edge Functions
// Auto-generated from Supabase schema

export interface SupabaseUser {
  id: string;
  role: 'admin' | 'super_admin' | 'restaurant_owner' | 'user';
  email: string;
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

// Restaurant types
export interface CreateRestaurantRequest {
  name: string;
  status: 'pending' | 'active' | 'suspended' | 'inactive' | 'closed';
  timezone: string;
  cuisine_slug: string;
  created_by?: number;
}

export interface AddCuisineRequest {
  restaurant_id: number;
  cuisine_slug: string;
  is_primary?: boolean;
}

export interface CreateCuisineTypeRequest {
  name: string;
  slug?: string;
  description?: string;
  display_order?: number;
}

export interface CreateRestaurantTagRequest {
  name: string;
  slug?: string;
  category: 'dietary' | 'service' | 'atmosphere' | 'feature' | 'payment';
  description?: string;
}

export interface AddTagRequest {
  restaurant_id: number;
  tag_slug: string;
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


