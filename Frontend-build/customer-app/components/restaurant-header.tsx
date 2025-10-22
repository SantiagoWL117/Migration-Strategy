'use client'

import { Star, MapPin, Clock, Phone, Mail } from 'lucide-react'

interface Restaurant {
  id: number
  name: string
  slug: string
  logo_url?: string
  description?: string
  is_online: boolean
  avg_rating?: number
  total_reviews?: number
  restaurant_locations?: Array<{
    street_address: string
    city_id: number
    latitude: number
    longitude: number
  }>
  restaurant_contacts?: Array<{
    email?: string
    phone?: string
  }>
}

interface RestaurantHeaderProps {
  restaurant: Restaurant
}

export function RestaurantHeader({ restaurant }: RestaurantHeaderProps) {
  const location = restaurant.restaurant_locations?.[0]
  const contact = restaurant.restaurant_contacts?.[0]

  return (
    <div className="bg-white border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex flex-col md:flex-row gap-6">
          {/* Restaurant Logo */}
          <div className="w-32 h-32 rounded-lg bg-gray-200 flex-shrink-0 overflow-hidden">
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
          </div>

          {/* Restaurant Info */}
          <div className="flex-1">
            <div className="flex items-start justify-between mb-2">
              <h1 className="text-3xl font-bold text-gray-900">{restaurant.name}</h1>
              {!restaurant.is_online && (
                <span className="bg-red-100 text-red-800 px-3 py-1 rounded-full text-sm font-medium">
                  Closed
                </span>
              )}
              {restaurant.is_online && (
                <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                  Open
                </span>
              )}
            </div>

            {restaurant.description && (
              <p className="text-gray-600 mb-4">{restaurant.description}</p>
            )}

            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 text-sm">
              {/* Rating */}
              {restaurant.avg_rating && (
                <div className="flex items-center gap-2">
                  <Star className="w-5 h-5 text-yellow-500 fill-current" />
                  <span className="font-medium">{restaurant.avg_rating.toFixed(1)}</span>
                  {restaurant.total_reviews && (
                    <span className="text-gray-500">({restaurant.total_reviews} reviews)</span>
                  )}
                </div>
              )}

              {/* Address */}
              {location && (
                <div className="flex items-center gap-2 text-gray-600">
                  <MapPin className="w-5 h-5" />
                  <span>{location.street_address}</span>
                </div>
              )}

              {/* Hours */}
              <div className="flex items-center gap-2 text-gray-600">
                <Clock className="w-5 h-5" />
                <span>11:00 AM - 10:00 PM</span>
              </div>

              {/* Contact */}
              {contact && (
                <div className="flex items-center gap-2 text-gray-600">
                  {contact.phone && (
                    <>
                      <Phone className="w-5 h-5" />
                      <span>{contact.phone}</span>
                    </>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

