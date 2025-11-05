'use client'

import { Clock, Tag, MapPin, Truck, ShoppingBag, Utensils } from 'lucide-react'
import { formatDiscount, formatDateRange, getTimeRemaining, formatCountdown } from '@/lib/promotions/utils'
import type { DiscountType } from '@/lib/promotions/types'

interface DealCardProps {
  dealId: number
  title: string
  description?: string
  discountType: DiscountType
  discountValue: number
  restaurantName: string
  restaurantLogo?: string
  restaurantSlug: string
  startDate: string
  endDate: string
  minOrderAmount?: number
  serviceTypes: string[]
  dealType?: string
  onViewDeal?: () => void
}

export function DealCard({
  dealId,
  title,
  description,
  discountType,
  discountValue,
  restaurantName,
  restaurantLogo,
  restaurantSlug,
  startDate,
  endDate,
  minOrderAmount,
  serviceTypes,
  dealType = 'standard',
  onViewDeal,
}: DealCardProps) {
  const { isExpired } = getTimeRemaining(endDate)
  const isFlashSale = dealType === 'flash_sale'

  if (isExpired) return null

  const getServiceIcon = (type: string) => {
    switch (type) {
      case 'delivery':
        return <Truck className="w-4 h-4" />
      case 'pickup':
        return <ShoppingBag className="w-4 h-4" />
      case 'dine_in':
        return <Utensils className="w-4 h-4" />
      default:
        return null
    }
  }

  return (
    <div className="bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100 group">
      {/* Flash Sale Banner */}
      {isFlashSale && (
        <div className="bg-gradient-to-r from-red-500 to-orange-500 text-white px-4 py-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4" />
            <span className="text-sm font-bold uppercase tracking-wide">Flash Sale</span>
          </div>
          <span className="text-sm font-mono font-semibold">
            {formatCountdown(endDate)}
          </span>
        </div>
      )}

      <div className="p-5">
        {/* Discount Badge */}
        <div className="flex items-start justify-between mb-3">
          <div className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold text-lg ${
            isFlashSale
              ? 'bg-red-100 text-red-700 border-2 border-red-300'
              : 'bg-green-100 text-green-700 border-2 border-green-300'
          }`}>
            <Tag className="w-5 h-5" />
            {formatDiscount(discountType, discountValue)}
          </div>
        </div>

        {/* Deal Title */}
        <h3 className="font-bold text-gray-900 text-xl mb-2 line-clamp-2 group-hover:text-red-600 transition-colors">
          {title}
        </h3>

        {/* Description */}
        {description && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
            {description}
          </p>
        )}

        {/* Restaurant Info */}
        <div className="flex items-center gap-3 mb-3 pb-3 border-b border-gray-100">
          {restaurantLogo ? (
            <img
              src={restaurantLogo}
              alt={restaurantName}
              className="w-10 h-10 rounded-full object-cover border-2 border-gray-200"
            />
          ) : (
            <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
              <MapPin className="w-5 h-5 text-gray-500" />
            </div>
          )}
          <div className="flex-1 min-w-0">
            <p className="font-semibold text-gray-900 truncate">{restaurantName}</p>
            <p className="text-xs text-gray-500">Restaurant</p>
          </div>
        </div>

        {/* Service Types */}
        <div className="flex items-center gap-2 mb-3">
          {serviceTypes.map((type) => (
            <div
              key={type}
              className="flex items-center gap-1 text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded-full"
            >
              {getServiceIcon(type)}
              <span className="capitalize">{type.replace('_', ' ')}</span>
            </div>
          ))}
        </div>

        {/* Minimum Order */}
        {minOrderAmount && minOrderAmount > 0 && (
          <p className="text-xs text-gray-600 mb-3">
            Min. order: <span className="font-semibold">${minOrderAmount.toFixed(2)}</span>
          </p>
        )}

        {/* Valid Until */}
        {!isFlashSale && (
          <p className="text-xs text-gray-500 mb-4">
            {formatDateRange(startDate, endDate)}
          </p>
        )}

        {/* CTA Button */}
        <button
          onClick={onViewDeal}
          className={`w-full py-2.5 px-4 rounded-lg font-semibold transition-colors ${
            isFlashSale
              ? 'bg-gradient-to-r from-red-500 to-orange-500 hover:from-red-600 hover:to-orange-600 text-white'
              : 'bg-red-600 hover:bg-red-700 text-white'
          }`}
        >
          View Deal
        </button>
      </div>
    </div>
  )
}
