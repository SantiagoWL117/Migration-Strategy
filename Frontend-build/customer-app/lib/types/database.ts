// Database types for Menu.ca V3

export interface Restaurant {
  id: string | number
  name: string
  slug: string
  description?: string | null
  cuisine_type?: string | null
  image_url?: string | null
  average_rating?: number | null
  review_count?: number | null
  delivery_fee?: number | null
  minimum_order?: number | null
  estimated_delivery_time?: string | null
  is_active: boolean | null
  is_featured: boolean | null
  created_at?: string
  updated_at?: string
  distance_km?: number | null
  can_deliver?: boolean | null
  [key: string]: any
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
