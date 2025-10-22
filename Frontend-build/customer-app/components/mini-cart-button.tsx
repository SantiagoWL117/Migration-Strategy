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
    return (
      <button
        className={`${
          fullWidth ? 'w-full' : ''
        } flex items-center gap-2 px-4 py-2 text-gray-400 cursor-not-allowed`}
        disabled
      >
        <ShoppingCart className="w-5 h-5" />
        <span>Cart (0)</span>
      </button>
    )
  }

  return (
    <button
      onClick={handleClick}
      className={`${
        fullWidth ? 'w-full' : ''
      } bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition-colors flex items-center justify-between gap-4 shadow-lg`}
    >
      <div className="flex items-center gap-2">
        <div className="relative">
          <ShoppingCart className="w-5 h-5" />
          <span className="absolute -top-2 -right-2 bg-white text-red-600 text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
            {itemCount}
          </span>
        </div>
        <span className="font-medium">View Cart</span>
      </div>
      <span className="font-bold">${total.toFixed(2)}</span>
    </button>
  )
}

