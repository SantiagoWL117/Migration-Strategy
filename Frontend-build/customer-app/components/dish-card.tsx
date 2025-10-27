'use client'

import { useState } from 'react'
import { Plus } from 'lucide-react'
import { useCartStore } from '@/lib/store/cart-store'
import { DishCustomizationModal } from './dish-customization-modal'

// Interface matching actual menuca_v3.dishes schema (verified via MCP 2025-10-24)
interface DishModifier {
  modifier_id: number
  modifier_name: string
  price: number | null
  modifier_type: string
  is_default: boolean
  is_included: boolean
  display_order: number
}

interface Dish {
  id: number
  name: string
  description?: string
  base_price: number
  image_url?: string
  is_active: boolean
  has_customization: boolean
  modifiers?: DishModifier[]
}

interface DishCardProps {
  dish: Dish
  restaurantId: number
}

export function DishCard({ dish, restaurantId }: DishCardProps) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const addItem = useCartStore((state) => state.addItem)

  const handleAddToCart = () => {
    // If dish has modifiers, open modal for customization
    if (dish.modifiers && dish.modifiers.length > 0) {
      setIsModalOpen(true)
    } else {
      // Add directly without customization
      addItem({
        dishId: dish.id,
        name: dish.name,
        price: dish.base_price || 0,
        quantity: 1,
        modifiers: [],
        restaurantId,
      })
    }
  }

  return (
    <>
      <DishCustomizationModal
        dish={dish}
        restaurantId={restaurantId}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <div className="bg-white rounded-lg border border-gray-200 hover:border-gray-300 hover:shadow-sm transition-all p-3 flex gap-3">
      {/* Dish Image - Square thumbnail */}
      <div className={`${dish.image_url ? 'w-[120px] h-[120px]' : 'w-0'} rounded-md bg-gray-100 flex-shrink-0 overflow-hidden`}>
        {dish.image_url && (
          <img
            src={dish.image_url}
            alt={dish.name}
            className="w-full h-full object-cover"
          />
        )}
      </div>

      {/* Dish Info */}
      <div className="flex-1 min-w-0 flex flex-col">
        <h3 className="text-base font-semibold text-gray-900 mb-1 leading-tight">
          {dish.name}
        </h3>
        {dish.description && (
          <p className="text-sm text-gray-600 mb-2 line-clamp-2 leading-snug">
            {dish.description}
          </p>
        )}
        <div className="mt-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-base font-bold text-gray-900">
              ${dish.base_price ? dish.base_price.toFixed(2) : '0.00'}
            </span>
            {dish.has_customization && (
              <span className="text-xs text-gray-500">Customizable</span>
            )}
          </div>
          {/* Add Button */}
          {dish.is_active ? (
            <button
              onClick={handleAddToCart}
              className="w-8 h-8 bg-red-600 text-white rounded-full flex items-center justify-center hover:bg-red-700 transition-colors flex-shrink-0"
            >
              <Plus className="w-4 h-4" />
            </button>
          ) : (
            <span className="text-xs text-gray-400">Unavailable</span>
          )}
        </div>
      </div>
    </div>
    </>
  )
}

