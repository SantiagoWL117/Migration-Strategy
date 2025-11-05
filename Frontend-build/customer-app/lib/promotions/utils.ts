/**
 * Marketing & Promotions - Utility Functions
 */

import type { DiscountType, PromotionalDeal, PromotionalCoupon } from './types'

/**
 * Format discount for display
 * @example formatDiscount('percentage', 20) => "20% OFF"
 * @example formatDiscount('fixed_amount', 5) => "$5 OFF"
 */
export function formatDiscount(type: DiscountType, value: number): string {
  switch (type) {
    case 'percentage':
      return `${value}% OFF`
    case 'fixed_amount':
      return `$${value.toFixed(2)} OFF`
    case 'free_delivery':
      return 'FREE DELIVERY'
    case 'buy_x_get_y':
      return 'SPECIAL OFFER'
    default:
      return 'DISCOUNT'
  }
}

/**
 * Calculate discount amount from order total
 */
export function calculateDiscountAmount(
  discountType: DiscountType,
  discountValue: number,
  orderTotal: number,
  maxDiscountAmount?: number
): number {
  let discount = 0

  switch (discountType) {
    case 'percentage':
      discount = (orderTotal * discountValue) / 100
      break
    case 'fixed_amount':
      discount = discountValue
      break
    case 'free_delivery':
      // Delivery fee is typically passed separately
      discount = 0
      break
    default:
      discount = 0
  }

  // Apply max discount cap if specified
  if (maxDiscountAmount && discount > maxDiscountAmount) {
    discount = maxDiscountAmount
  }

  // Don't allow discount to exceed order total
  if (discount > orderTotal) {
    discount = orderTotal
  }

  return Math.round(discount * 100) / 100 // Round to 2 decimals
}

/**
 * Check if deal/coupon is currently active based on dates
 */
export function isActiveNow(startDate: string, endDate: string): boolean {
  const now = new Date()
  const start = new Date(startDate)
  const end = new Date(endDate)

  return now >= start && now <= end
}

/**
 * Format date range for display
 * @example "Valid until Nov 15, 2025"
 * @example "Nov 1 - Nov 30, 2025"
 */
export function formatDateRange(startDate: string, endDate: string): string {
  const start = new Date(startDate)
  const end = new Date(endDate)
  const now = new Date()

  const options: Intl.DateTimeFormatOptions = {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  }

  // If already started, just show end date
  if (start <= now) {
    return `Valid until ${end.toLocaleDateString('en-US', options)}`
  }

  // If future, show range
  return `${start.toLocaleDateString('en-US', options)} - ${end.toLocaleDateString('en-US', options)}`
}

/**
 * Calculate time remaining for flash sales/limited offers
 * Returns object with days, hours, minutes, seconds
 */
export function getTimeRemaining(endDate: string): {
  total: number
  days: number
  hours: number
  minutes: number
  seconds: number
  isExpired: boolean
} {
  const total = new Date(endDate).getTime() - new Date().getTime()

  if (total <= 0) {
    return { total: 0, days: 0, hours: 0, minutes: 0, seconds: 0, isExpired: true }
  }

  return {
    total,
    days: Math.floor(total / (1000 * 60 * 60 * 24)),
    hours: Math.floor((total / (1000 * 60 * 60)) % 24),
    minutes: Math.floor((total / 1000 / 60) % 60),
    seconds: Math.floor((total / 1000) % 60),
    isExpired: false,
  }
}

/**
 * Format countdown timer display
 * @example "2h 34m 15s"
 * @example "15m 42s"
 */
export function formatCountdown(endDate: string): string {
  const { days, hours, minutes, seconds, isExpired } = getTimeRemaining(endDate)

  if (isExpired) return 'EXPIRED'

  const parts: string[] = []

  if (days > 0) parts.push(`${days}d`)
  if (hours > 0) parts.push(`${hours}h`)
  if (minutes > 0 || parts.length > 0) parts.push(`${minutes}m`)
  parts.push(`${seconds}s`)

  return parts.join(' ')
}

/**
 * Check if order meets minimum amount requirement
 */
export function meetsMinimumOrder(orderTotal: number, minOrderAmount?: number): boolean {
  if (!minOrderAmount) return true
  return orderTotal >= minOrderAmount
}

/**
 * Format minimum order message
 * @example "Add $5.00 more to use this coupon"
 */
export function getMinimumOrderMessage(orderTotal: number, minOrderAmount: number): string {
  const remaining = minOrderAmount - orderTotal

  if (remaining <= 0) {
    return `Minimum order of $${minOrderAmount.toFixed(2)} met!`
  }

  return `Add $${remaining.toFixed(2)} more to use this coupon`
}

/**
 * Get badge color for deal type
 */
export function getDealBadgeColor(dealType: string): string {
  switch (dealType) {
    case 'flash_sale':
      return 'bg-red-100 text-red-700 border-red-200'
    case 'coupon':
      return 'bg-green-100 text-green-700 border-green-200'
    case 'loyalty':
      return 'bg-purple-100 text-purple-700 border-purple-200'
    default:
      return 'bg-blue-100 text-blue-700 border-blue-200'
  }
}

/**
 * Get service type icon
 */
export function getServiceTypeIcon(serviceType: string): string {
  switch (serviceType) {
    case 'delivery':
      return '🚚'
    case 'pickup':
      return '🏃'
    case 'dine_in':
      return '🍽️'
    default:
      return '📦'
  }
}

/**
 * Sort deals by priority (flash sales first, then by display order)
 */
export function sortDeals(deals: PromotionalDeal[]): PromotionalDeal[] {
  return [...deals].sort((a, b) => {
    // Flash sales always first
    if (a.deal_type === 'flash_sale' && b.deal_type !== 'flash_sale') return -1
    if (a.deal_type !== 'flash_sale' && b.deal_type === 'flash_sale') return 1

    // Then by display order
    return a.display_order - b.display_order
  })
}

/**
 * Check if coupon is platform-wide or restaurant-specific
 */
export function getCouponScope(coupon: PromotionalCoupon): 'platform' | 'restaurant' {
  return coupon.platform_wide ? 'platform' : 'restaurant'
}

/**
 * Format usage limit display
 * @example "3 of 5 uses remaining"
 * @example "Unlimited uses"
 */
export function formatUsageLimit(
  totalLimit: number | null,
  timesRedeemed: number
): string {
  if (!totalLimit) return 'Unlimited uses'

  const remaining = totalLimit - timesRedeemed

  if (remaining <= 0) return 'No uses remaining'
  if (remaining === 1) return '1 use remaining'

  return `${remaining} of ${totalLimit} uses remaining`
}
