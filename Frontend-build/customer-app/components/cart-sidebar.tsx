'use client'

import { ShoppingCart, Plus, Minus, Trash2 } from 'lucide-react'
import { useCartStore } from '@/lib/store/cart-store'
import { useRouter } from 'next/navigation'

export function CartSidebar() {
  const items = useCartStore((state) => state.items)
  const updateQuantity = useCartStore((state) => state.updateQuantity)
  const removeItem = useCartStore((state) => state.removeItem)
  const subtotal = useCartStore((state) => state.subtotal())
  const tax = useCartStore((state) => state.tax())
  const total = useCartStore((state) => state.total())
  const itemCount = useCartStore((state) => state.itemCount())
  const router = useRouter()

  const handleCheckout = () => {
    router.push('/checkout')
  }

  if (items.length === 0) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <div className="flex items-center gap-2 mb-4">
          <ShoppingCart className="w-5 h-5 text-gray-400" />
          <h3 className="text-lg font-semibold text-gray-900">Your Cart</h3>
        </div>
        <div className="text-center py-8">
          <ShoppingCart className="w-16 h-16 text-gray-300 mx-auto mb-3" />
          <p className="text-gray-500 text-sm">Your cart is empty</p>
          <p className="text-gray-400 text-xs mt-1">Add items to get started</p>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
      {/* Header */}
      <div className="bg-gray-50 px-4 py-3 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <ShoppingCart className="w-5 h-5 text-red-600" />
            <h3 className="text-lg font-semibold text-gray-900">Your Cart</h3>
          </div>
          <span className="text-sm text-gray-600 bg-white px-2 py-1 rounded-full">
            {itemCount} {itemCount === 1 ? 'item' : 'items'}
          </span>
        </div>
      </div>

      {/* Cart Items */}
      <div className="p-4 space-y-3 max-h-[400px] overflow-y-auto">
        {items.map((item) => {
          const itemSubtotal = (item.price + item.modifiers.reduce((sum, mod) => sum + mod.price, 0)) * item.quantity

          return (
            <div key={item.dishId} className="border-b border-gray-100 pb-3 last:border-0">
              {/* Item Name */}
              <div className="flex justify-between items-start mb-2">
                <h4 className="text-sm font-medium text-gray-900 flex-1 leading-tight">
                  {item.name}
                </h4>
                <button
                  onClick={() => removeItem(item.dishId)}
                  className="text-gray-400 hover:text-red-600 transition-colors ml-2"
                  aria-label="Remove item"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              {/* Modifiers */}
              {item.modifiers.length > 0 && (
                <div className="mb-2">
                  {item.modifiers.map((modifier, idx) => (
                    <p key={idx} className="text-xs text-gray-600">
                      + {modifier.name} ${modifier.price.toFixed(2)}
                    </p>
                  ))}
                </div>
              )}

              {/* Quantity Controls & Price */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 border border-gray-200 rounded-lg">
                  <button
                    onClick={() => updateQuantity(item.dishId, item.quantity - 1)}
                    className="p-1.5 hover:bg-gray-50 transition-colors rounded-l-lg"
                    aria-label="Decrease quantity"
                  >
                    <Minus className="w-3.5 h-3.5 text-gray-600" />
                  </button>
                  <span className="text-sm font-medium text-gray-900 w-6 text-center">
                    {item.quantity}
                  </span>
                  <button
                    onClick={() => updateQuantity(item.dishId, item.quantity + 1)}
                    className="p-1.5 hover:bg-gray-50 transition-colors rounded-r-lg"
                    aria-label="Increase quantity"
                  >
                    <Plus className="w-3.5 h-3.5 text-gray-600" />
                  </button>
                </div>
                <span className="text-sm font-semibold text-gray-900">
                  ${itemSubtotal.toFixed(2)}
                </span>
              </div>
            </div>
          )
        })}
      </div>

      {/* Totals */}
      <div className="border-t border-gray-200 p-4 space-y-2">
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Subtotal</span>
          <span className="text-gray-900 font-medium">${subtotal.toFixed(2)}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Tax (HST 13%)</span>
          <span className="text-gray-900 font-medium">${tax.toFixed(2)}</span>
        </div>
        <div className="flex justify-between text-base font-bold pt-2 border-t border-gray-200">
          <span className="text-gray-900">Total</span>
          <span className="text-gray-900">${total.toFixed(2)}</span>
        </div>
      </div>

      {/* Checkout Button */}
      <div className="p-4 pt-0">
        <button
          onClick={handleCheckout}
          className="w-full bg-red-600 text-white py-3 rounded-lg font-semibold hover:bg-red-700 transition-colors shadow-sm"
        >
          Proceed to Checkout
        </button>
      </div>
    </div>
  )
}
