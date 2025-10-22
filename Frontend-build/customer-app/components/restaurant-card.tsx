'use client'

import { Star, MapPin, Clock } from 'lucide-react'

interface Restaurant {
  id: number
  name: string
  slug: string
  logo_url?: string
  description?: string
  cuisines?: string[]
  is_online: boolean
  distance_km?: number
  avg_rating?: number
  total_reviews?: number
}

interface RestaurantCardProps {
  restaurant: Restaurant
}

export function RestaurantCard({ restaurant }: RestaurantCardProps) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
      {/* Restaurant Image/Logo */}
      <div className="relative h-48 bg-gray-200">
        {restaurant.logo_url ? (
          <img
            src={restaurant.logo_url}
            alt={restaurant.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <span className="text-4xl font-bold">{restaurant.name[0]}</span>
          </div>
        )}
        {!restaurant.is_online && (
          <div className="absolute inset-0 bg-black bg-opacity-60 flex items-center justify-center">
            <span className="text-white font-semibold">Currently Closed</span>
          </div>
        )}
      </div>

      {/* Restaurant Info */}
      <div className="p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {restaurant.name}
        </h3>

        {restaurant.description && (
          <p className="text-sm text-gray-600 mb-2 line-clamp-2">
            {restaurant.description}
          </p>
        )}

        {restaurant.cuisines && restaurant.cuisines.length > 0 && (
          <p className="text-sm text-gray-500 mb-3">
            {restaurant.cuisines.join(' • ')}
          </p>
        )}

        <div className="flex items-center justify-between text-sm">
          {/* Rating */}
          {restaurant.avg_rating && (
            <div className="flex items-center gap-1 text-yellow-600">
              <Star className="w-4 h-4 fill-current" />
              <span className="font-medium">{restaurant.avg_rating.toFixed(1)}</span>
              {restaurant.total_reviews && (
                <span className="text-gray-500">
                  ({restaurant.total_reviews})
                </span>
              )}
            </div>
          )}

          {/* Distance */}
          {restaurant.distance_km && (
            <div className="flex items-center gap-1 text-gray-600">
              <MapPin className="w-4 h-4" />
              <span>{restaurant.distance_km.toFixed(1)} km</span>
            </div>
          )}
        </div>

        {/* Delivery Time (placeholder - could be calculated from service_config) */}
        <div className="mt-2 flex items-center gap-1 text-sm text-gray-500">
          <Clock className="w-4 h-4" />
          <span>25-35 min</span>
        </div>
      </div>
    </div>
  )
}

