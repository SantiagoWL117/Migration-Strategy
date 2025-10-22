'use client'

import { useState } from 'react'
import { DishCard } from './dish-card'

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

interface Course {
  id: number
  name_en: string
  name_fr?: string
  display_order: number
  dishes: Dish[]
}

interface MenuDisplayProps {
  menu: Course[]
  restaurantId: number
}

export function MenuDisplay({ menu, restaurantId }: MenuDisplayProps) {
  const [selectedCategory, setSelectedCategory] = useState<number | null>(
    menu[0]?.id || null
  )

  if (!menu || menu.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500 text-lg">No menu available</p>
      </div>
    )
  }

  return (
    <div>
      {/* Category Navigation */}
      <div className="sticky top-24 bg-gray-50 z-10 pb-4 mb-6">
        <div className="flex gap-2 overflow-x-auto pb-2">
          {menu.map((category) => (
            <button
              key={category.id}
              onClick={() => setSelectedCategory(category.id)}
              className={`px-4 py-2 rounded-lg font-medium whitespace-nowrap transition-colors ${
                selectedCategory === category.id
                  ? 'bg-red-600 text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-100'
              }`}
            >
              {category.name_en}
            </button>
          ))}
        </div>
      </div>

      {/* Dishes by Category */}
      <div className="space-y-12">
        {menu.map((category) => {
          // Filter to show only selected category if one is selected
          if (selectedCategory && category.id !== selectedCategory) {
            return null
          }

          return (
            <div key={category.id} id={`category-${category.id}`}>
              <h2 className="text-2xl font-bold mb-6">{category.name_en}</h2>
              <div className="grid gap-4">
                {category.dishes.map((dish) => (
                  <DishCard
                    key={dish.id}
                    dish={dish}
                    restaurantId={restaurantId}
                  />
                ))}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

