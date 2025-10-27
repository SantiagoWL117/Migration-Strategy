'use client'

import { Plus } from 'lucide-react'
import { useCartStore } from '@/lib/store/cart-store'

interface Dish {
  id: number
  name_en: string
  name_fr?: string
  description_en?: string
  description_fr?: string
  price: number
  image_url?: string
  is_available: boolean
  dish_modifiers?: Array<{
    id: number
    name_en: string
    name_fr?: string
    price_modifier: number
    modifier_type: string
  }>
}

interface DishCardProps {
  dish: Dish
  restaurantId: number
}

export function DishCard({ dish, restaurantId }: DishCardProps) {
  const addItem = useCartStore((state) => state.addItem)

  const handleAddToCart = () => {
    // If dish has modifiers, open modal for customization
    // For now, just add directly
    addItem({
      dishId: dish.id,
      name: dish.name_en,
      price: dish.price,
      quantity: 1,
      modifiers: [],
      restaurantId,
    })
  }

  return (
    <div className="bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow p-4 flex gap-4">
      {/* Dish Image */}
      {dish.image_url && (
        <div className="w-24 h-24 rounded-lg bg-gray-200 flex-shrink-0 overflow-hidden">
          <img
            src={dish.image_url}
            alt={dish.name_en}
            className="w-full h-full object-cover"
          />
        </div>
      )}

      {/* Dish Info */}
      <div className="flex-1 min-w-0">
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {dish.name_en}
        </h3>
        {dish.description_en && (
          <p className="text-sm text-gray-600 mb-2 line-clamp-2">
            {dish.description_en}
          </p>
        )}
        <div className="flex items-center justify-between">
          <span className="text-lg font-bold text-gray-900">
            ${dish.price.toFixed(2)}
          </span>
          {dish.dish_modifiers && dish.dish_modifiers.length > 0 && (
            <span className="text-xs text-gray-500">Customizable</span>
          )}
        </div>
      </div>

      {/* Add Button */}
      <div className="flex-shrink-0 flex items-center">
        {dish.is_available ? (
          <button
            onClick={handleAddToCart}
            className="w-10 h-10 bg-red-600 text-white rounded-full flex items-center justify-center hover:bg-red-700 transition-colors"
          >
            <Plus className="w-5 h-5" />
          </button>
        ) : (
          <span className="text-sm text-gray-400">Unavailable</span>
        )}
      </div>
    </div>
  )
}

