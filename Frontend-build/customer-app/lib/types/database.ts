// Database types for Menu.ca V3

export interface Restaurant {
  id: number
  name: string
  slug: string
  description?: string
  cuisine_type?: string
  image_url?: string
  average_rating?: number
  review_count?: number
  delivery_fee?: number
  minimum_order?: number
  estimated_delivery_time?: string
  is_active: boolean
  is_featured: boolean
  created_at: string
  updated_at: string
}

export interface RestaurantLocation {
  id: number
  restaurant_id: number
  latitude: number
  longitude: number
  address: string
  city?: string
  province?: string
  postal_code?: string
}
