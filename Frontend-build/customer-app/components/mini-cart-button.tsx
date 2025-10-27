'use client'

import { ShoppingCart } from 'lucide-react'
import { useCartStore } from '@/lib/store/cart-store'
import { useRouter } from 'next/navigation'

interface MiniCartButtonProps {
  fullWidth?: boolean
}

export function MiniCartButton({ fullWidth = false }: MiniCartButtonProps) {
  const itemCount = useCartStore((state) => state.itemCount())
  const total = useCartStore((state) => state.total())
  const router = useRouter()

  const handleClick = () => {
    router.push('/checkout')
  }

  if (itemCount === 0) {
    return null // Hide button when cart is empty (industry standard)
  }

  return (
    <button
      onClick={handleClick}
      className={`${
        fullWidth ? 'w-full' : ''
      } bg-red-600 text-white px-6 py-3.5 rounded-xl hover:bg-red-700 transition-all flex items-center justify-between gap-4 shadow-xl hover:shadow-2xl relative overflow-hidden group`}
    >
      {/* Animated background effect */}
      <div className="absolute inset-0 bg-gradient-to-r from-red-700 to-red-600 opacity-0 group-hover:opacity-100 transition-opacity" />

      <div className="flex items-center gap-3 relative z-10">
        <div className="relative">
          <ShoppingCart className="w-5 h-5" />
          <span className="absolute -top-2 -right-2 bg-white text-red-600 text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center shadow-md">
            {itemCount}
          </span>
        </div>
        <div className="text-left">
          <span className="font-semibold block text-sm">View Cart</span>
          <span className="text-xs text-red-100 block">{itemCount} {itemCount === 1 ? 'item' : 'items'}</span>
        </div>
      </div>
      <span className="font-bold text-lg relative z-10">${total.toFixed(2)}</span>
    </button>
  )
}

