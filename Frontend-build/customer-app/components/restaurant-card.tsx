'use client'

import { Star, MapPin, Clock } from 'lucide-react'
import Image from 'next/image'

interface Restaurant {
  id: string
  name: string
  slug: string
  image_url: string | null
  description: string | null
  cuisine_type: string | null
  average_rating: number | null
  review_count: number | null
  delivery_fee: number | null
  minimum_order: number | null
  estimated_delivery_time: string | null
  is_featured: boolean | null
  is_active: boolean | null
  distance_km?: number | null
  can_deliver?: boolean | null
}

interface RestaurantCardProps {
  restaurant: Restaurant
}

export function RestaurantCard({ restaurant }: RestaurantCardProps) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
      {/* Restaurant Image */}
      <div className="relative h-48 bg-gray-200">
        {restaurant.image_url ? (
          <Image
            src={restaurant.image_url}
            alt={restaurant.name}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <span className="text-4xl font-bold">{restaurant.name[0]}</span>
          </div>
        )}
        {!restaurant.is_active && (
          <div className="absolute inset-0 bg-black bg-opacity-60 flex items-center justify-center">
            <span className="text-white font-semibold">Currently Closed</span>
          </div>
        )}
        {restaurant.is_featured && (
          <div className="absolute top-2 left-2 bg-red-600 text-white text-xs px-2 py-1 rounded">
            Featured
          </div>
        )}
      </div>

      {/* Restaurant Info */}
      <div className="p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {restaurant.name}
        </h3>

        <div className="flex items-center justify-between mb-2">
          {restaurant.cuisine_type && (
            <p className="text-sm text-gray-600">
              {restaurant.cuisine_type}
            </p>
          )}
          {restaurant.distance_km !== null && restaurant.distance_km !== undefined && (
            <div className="flex items-center gap-1 text-sm text-gray-600">
              <MapPin className="w-3 h-3" />
              <span>{restaurant.distance_km.toFixed(1)} km</span>
            </div>
          )}
        </div>

        {restaurant.description && (
          <p className="text-sm text-gray-500 mb-3 line-clamp-2">
            {restaurant.description}
          </p>
        )}

        <div className="flex items-center justify-between text-sm">
          {/* Rating - Show data or NULL indicator */}
          <div className="flex items-center gap-1 text-yellow-600">
            <Star className="w-4 h-4 fill-current" />
            <span className="font-medium">
              {restaurant.average_rating !== null && restaurant.average_rating !== undefined
                ? restaurant.average_rating.toFixed(1)
                : <span className="text-gray-400 text-xs">No rating</span>}
            </span>
            {restaurant.review_count && restaurant.review_count > 0 && (
              <span className="text-gray-500">
                ({restaurant.review_count})
              </span>
            )}
          </div>

          {/* Delivery Fee */}
          <div className="flex items-center gap-2 text-gray-600">
            {restaurant.delivery_fee !== null && restaurant.delivery_fee !== undefined ? (
              <span>${restaurant.delivery_fee.toFixed(2)}</span>
            ) : (
              <span className="text-gray-400 text-xs">Fee N/A</span>
            )}
          </div>
        </div>

        {/* Distance & Minimum Order */}
        <div className="mt-2 flex items-center justify-between text-sm text-gray-500">
          {/* Show distance if available, otherwise show delivery time or indicator */}
          {restaurant.distance_km !== null && restaurant.distance_km !== undefined ? (
            <div className="flex items-center gap-1 font-medium text-gray-700">
              <MapPin className="w-4 h-4 text-red-600" />
              <span>{restaurant.distance_km.toFixed(1)} km away</span>
            </div>
          ) : restaurant.estimated_delivery_time ? (
            <div className="flex items-center gap-1">
              <Clock className="w-4 h-4" />
              <span>{restaurant.estimated_delivery_time}</span>
            </div>
          ) : (
            <span className="text-gray-400 text-xs">Location N/A</span>
          )}
          {/* Minimum order */}
          {restaurant.minimum_order !== null && restaurant.minimum_order !== undefined && restaurant.minimum_order > 0 ? (
            <span>Min ${restaurant.minimum_order}</span>
          ) : (
            <span className="text-gray-400 text-xs">No min</span>
          )}
        </div>
      </div>
    </div>
  )
}