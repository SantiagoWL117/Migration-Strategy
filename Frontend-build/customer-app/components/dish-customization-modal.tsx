'use client'

import { useState } from 'react'
import { X, Plus, Minus, Check } from 'lucide-react'
import { useCartStore } from '@/lib/store/cart-store'

interface DishModifier {
  modifier_id: number | string  // Can be string now for composite IDs
  group_id?: number
  group_name?: string
  modifier_name: string
  price: number | null
  modifier_type: string
  is_default: boolean
  is_included: boolean
  display_order: number
  min_selection?: number
  max_selection?: number
  free_quantity?: number
}

interface Dish {
  id: number
  name: string
  description?: string
  base_price: number
  image_url?: string
  modifiers?: DishModifier[]
}

interface DishCustomizationModalProps {
  dish: Dish
  restaurantId: number
  isOpen: boolean
  onClose: () => void
}

export function DishCustomizationModal({ dish, restaurantId, isOpen, onClose }: DishCustomizationModalProps) {
  const [quantity, setQuantity] = useState(1)
  const [selectedModifiers, setSelectedModifiers] = useState<(number | string)[]>(
    // Pre-select default modifiers
    dish.modifiers?.filter(m => m.is_default).map(m => m.modifier_id) || []
  )
  const addItem = useCartStore((state) => state.addItem)

  if (!isOpen) return null

  const modifiers = dish.modifiers || []

  // Debug logging
  console.log('Modal opened for dish:', {
    dishName: dish.name,
    totalModifiers: modifiers.length,
    modifierTypes: [...new Set(modifiers.map(m => m.modifier_type))],
    allModifiers: modifiers
  })

  // Group modifiers by group_name (NEW structure) or fall back to modifier_type (OLD structure)
  const modifiersByGroup = modifiers.reduce((acc, mod) => {
    const groupKey = mod.group_name || mod.modifier_type || 'other'
    if (!acc[groupKey]) acc[groupKey] = []
    acc[groupKey].push(mod)
    return acc
  }, {} as Record<string, DishModifier[]>)

  console.log('Modifiers grouped:', {
    totalModifiers: modifiers.length,
    groups: Object.keys(modifiersByGroup),
    groupCounts: Object.entries(modifiersByGroup).map(([name, items]) => ({ name, count: items.length }))
  })

  const toggleModifier = (modifierId: number | string) => {
    setSelectedModifiers(prev =>
      prev.includes(modifierId as any)
        ? prev.filter(id => id !== modifierId)
        : [...prev, modifierId as any]
    )
  }

  const calculateTotal = () => {
    const basePrice = dish.base_price || 0
    const modifiersCost = modifiers
      .filter(m => selectedModifiers.includes(m.modifier_id))
      .reduce((sum, m) => sum + (m.price || 0), 0)
    return (basePrice + modifiersCost) * quantity
  }

  const handleAddToCart = () => {
    const selectedModifierDetails = modifiers
      .filter(m => selectedModifiers.includes(m.modifier_id))
      .map(m => ({
        id: m.modifier_id,
        name: m.modifier_name,
        price: m.price || 0
      }))

    addItem({
      dishId: dish.id,
      name: dish.name,
      price: dish.base_price || 0,
      quantity,
      modifiers: selectedModifierDetails,
      restaurantId,
    })

    onClose()
  }

  const formatModifierType = (type: string) => {
    return type
      .split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black bg-opacity-50 z-50"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
        <div
          className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden pointer-events-auto"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="relative">
            {dish.image_url && (
              <div className="h-48 bg-gray-100">
                <img
                  src={dish.image_url}
                  alt={dish.name}
                  className="w-full h-full object-cover"
                />
              </div>
            )}
            <button
              onClick={onClose}
              className="absolute top-3 right-3 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg hover:bg-gray-100 transition-colors"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Content */}
          <div className="p-6 overflow-y-auto max-h-[calc(90vh-250px)]">
            <h2 className="text-2xl font-bold text-gray-900 mb-2">{dish.name}</h2>
            {dish.description && (
              <p className="text-gray-600 text-sm mb-4">{dish.description}</p>
            )}
            <p className="text-xl font-bold text-gray-900 mb-6">
              ${dish.base_price ? dish.base_price.toFixed(2) : '0.00'}
            </p>

            {/* Modifiers by Group */}
            {Object.entries(modifiersByGroup).length > 0 ? (
              <div className="space-y-6">
                {Object.entries(modifiersByGroup).map(([groupName, mods]) => (
                  <div key={groupName}>
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">
                      {groupName}
                      {mods[0]?.min_selection !== undefined && (
                        <span className="text-sm font-normal text-gray-500 ml-2">
                          (Select {mods[0].min_selection} - {mods[0].max_selection})
                        </span>
                      )}
                    </h3>
                    <div className="space-y-2">
                      {mods.map((modifier) => {
                        const isSelected = selectedModifiers.includes(modifier.modifier_id)
                        const isIncluded = modifier.is_included
                        const hasPrice = modifier.price && modifier.price > 0

                        return (
                          <button
                            key={modifier.modifier_id}
                            onClick={() => !isIncluded && toggleModifier(modifier.modifier_id)}
                            className={`w-full flex items-center justify-between p-3 rounded-lg border-2 transition-all ${
                              isIncluded
                                ? 'border-gray-200 bg-gray-50 cursor-default'
                                : isSelected
                                ? 'border-red-600 bg-red-50'
                                : 'border-gray-200 hover:border-gray-300'
                            }`}
                          >
                            <div className="flex items-center gap-3">
                              <div
                                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                                  isIncluded
                                    ? 'border-gray-400 bg-gray-400'
                                    : isSelected
                                    ? 'border-red-600 bg-red-600'
                                    : 'border-gray-300'
                                }`}
                              >
                                {(isSelected || isIncluded) && (
                                  <Check className="w-3 h-3 text-white" />
                                )}
                              </div>
                              <div className="text-left">
                                <span className="text-sm font-medium text-gray-900">
                                  {modifier.modifier_name}
                                </span>
                                {isIncluded && (
                                  <span className="ml-2 text-xs text-gray-500">(Included)</span>
                                )}
                              </div>
                            </div>
                            {hasPrice && (
                              <span className="text-sm font-semibold text-gray-700">
                                +${modifier.price!.toFixed(2)}
                              </span>
                            )}
                          </button>
                        )
                      })}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm">No customization options available.</p>
            )}
          </div>

          {/* Footer */}
          <div className="border-t border-gray-200 p-4 bg-gray-50">
            {/* Quantity Selector */}
            <div className="flex items-center justify-between mb-4">
              <span className="text-sm font-medium text-gray-700">Quantity</span>
              <div className="flex items-center gap-3 border border-gray-300 rounded-lg">
                <button
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="p-2 hover:bg-gray-100 transition-colors rounded-l-lg"
                >
                  <Minus className="w-4 h-4 text-gray-600" />
                </button>
                <span className="text-base font-semibold text-gray-900 w-8 text-center">
                  {quantity}
                </span>
                <button
                  onClick={() => setQuantity(quantity + 1)}
                  className="p-2 hover:bg-gray-100 transition-colors rounded-r-lg"
                >
                  <Plus className="w-4 h-4 text-gray-600" />
                </button>
              </div>
            </div>

            {/* Add to Cart Button */}
            <button
              onClick={handleAddToCart}
              className="w-full bg-red-600 text-white py-3 rounded-lg font-semibold hover:bg-red-700 transition-colors flex items-center justify-between px-4"
            >
              <span>Add to Cart</span>
              <span className="font-bold">${calculateTotal().toFixed(2)}</span>
            </button>
          </div>
        </div>
      </div>
    </>
  )
}
