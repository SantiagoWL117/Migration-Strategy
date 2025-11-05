'use client'

import { Sparkles, X } from 'lucide-react'
import { formatDiscount } from '@/lib/promotions/utils'
import type { DiscountType } from '@/lib/promotions/types'

interface BestDealBannerProps {
  dealTitle: string
  discountAmount: number
  discountType: DiscountType
  discountValue: number
  onRemove?: () => void
  showRemove?: boolean
}

export function BestDealBanner({
  dealTitle,
  discountAmount,
  discountType,
  discountValue,
  onRemove,
  showRemove = true,
}: BestDealBannerProps) {
  return (
    <div className="bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-300 rounded-lg p-4 relative overflow-hidden">
      {/* Decorative background pattern */}
      <div className="absolute top-0 right-0 w-32 h-32 bg-green-100 rounded-full -translate-y-1/2 translate-x-1/2 opacity-30" />
      <div className="absolute bottom-0 left-0 w-24 h-24 bg-emerald-100 rounded-full translate-y-1/2 -translate-x-1/2 opacity-30" />

      <div className="relative flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 flex-1">
          {/* Icon */}
          <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 shadow-lg">
            <Sparkles className="w-6 h-6 text-white" fill="white" />
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <span className="text-xs font-bold text-green-700 uppercase tracking-wide bg-green-200 px-2 py-0.5 rounded">
                Best Deal Applied!
              </span>
            </div>
            <h3 className="font-bold text-green-900 text-lg leading-tight mb-0.5">
              {dealTitle}
            </h3>
            <div className="flex items-center gap-2 flex-wrap">
              <p className="text-sm text-green-700 font-medium">
                You're saving{' '}
                <span className="font-bold text-lg">
                  ${discountAmount.toFixed(2)}
                </span>
              </p>
              <span className="text-xs bg-green-200 text-green-800 px-2 py-0.5 rounded font-semibold">
                {formatDiscount(discountType, discountValue)}
              </span>
            </div>
          </div>
        </div>

        {/* Remove Button */}
        {showRemove && onRemove && (
          <button
            onClick={onRemove}
            className="text-green-700 hover:text-green-900 p-2 hover:bg-green-100 rounded-full transition-colors flex-shrink-0"
            aria-label="Remove deal"
          >
            <X className="w-5 h-5" />
          </button>
        )}
      </div>

      {/* Success indicator animation */}
      <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-green-400 animate-pulse" />
    </div>
  )
}
