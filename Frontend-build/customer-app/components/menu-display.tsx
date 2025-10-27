'use client'

import { useState } from 'react'
import { DishCard } from './dish-card'

// Interfaces matching actual menuca_v3 schema (verified via MCP 2025-10-24)
interface Dish {
  id: number
  name: string
  description?: string
  base_price: number
  image_url?: string
  is_active: boolean
  prices?: any // JSONB field for complex pricing
  size_options?: any // JSONB field for size variants
  has_customization: boolean
  dish_modifiers?: Array<{
    id: number
    name?: string
    price: number
    modifier_type?: string
    ingredient_id: number
  }>
}

interface Course {
  id: number
  name: string
  description?: string
  display_order: number
  is_active: boolean
  dishes: Dish[]
}

interface MenuDisplayProps {
  menu: Course[]
  restaurantId: number
}

export function MenuDisplay({ menu, restaurantId }: MenuDisplayProps) {
  if (!menu || menu.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500 text-lg">No menu available</p>
      </div>
    )
  }

  // Filter out empty categories
  const menuWithDishes = menu.filter(cat => cat.dishes && cat.dishes.length > 0)

  return (
    <div>
      {/* Sticky Category Navigation - Jump to section */}
      <div className="sticky top-24 bg-white z-20 border-b shadow-sm mb-4">
        <div className="max-w-7xl mx-auto px-4 py-2">
          <div className="flex gap-1.5 overflow-x-auto scrollbar-hide">
            {menuWithDishes.map((category) => (
              <a
                key={category.id}
                href={`#category-${category.id}`}
                className="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap transition-all bg-gray-100 hover:bg-red-600 hover:text-white text-gray-700"
              >
                {category.name}
                <span className="ml-1.5 text-xs opacity-75">({category.dishes.length})</span>
              </a>
            ))}
          </div>
        </div>
      </div>

      {/* ALL Dishes - Grouped by Category */}
      <div className="space-y-6">
        {menuWithDishes.map((category) => (
          <section key={category.id} id={`category-${category.id}`} className="scroll-mt-28">
            {/* Category Header - Compact */}
            <div className="mb-3">
              <h2 className="text-lg font-semibold text-gray-900">{category.name}</h2>
              {category.description && (
                <p className="text-sm text-gray-600 mt-1">{category.description}</p>
              )}
              <div className="h-0.5 w-10 bg-red-600 mt-1.5 rounded-full"></div>
            </div>

            {/* Dishes Grid - 2 columns on desktop */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {category.dishes.map((dish) => (
                <DishCard
                  key={dish.id}
                  dish={dish}
                  restaurantId={restaurantId}
                />
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  )
}

