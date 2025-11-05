/**
 * Marketing & Promotions - TypeScript Types
 * Based on menuca_v3.promotional_deals and menuca_v3.promotional_coupons schemas
 */

export type DiscountType = 'percentage' | 'fixed_amount' | 'free_delivery' | 'buy_x_get_y'

export type DealType = 'standard' | 'flash_sale' | 'coupon' | 'loyalty'

export type ServiceType = 'delivery' | 'pickup' | 'dine_in'

// Coupon Validation Response
export interface CouponValidation {
  valid: boolean
  error_code?: string
  discount_amount: number
  coupon_id?: number
  coupon_name?: string
  final_total: number
}

// Coupon Usage Limit Check
export interface CouponUsage {
  coupon_id: number
  total_limit: number | null
  total_used: number
  total_remaining: number | null
  customer_used: number
  can_use: boolean
}

// Best Deal Response
export interface BestDeal {
  has_deal: boolean
  deal_id?: number
  coupon_id?: number
  deal_type?: DealType
  discount_amount: number
  final_total: number
  deal_title?: string
  coupon_code?: string
}

// Promotional Deal
export interface PromotionalDeal {
  id: number
  uuid: string
  restaurant_id: number
  name: string
  description?: string
  deal_type: DealType
  discount_type: DiscountType
  discount_value: number
  is_enabled: boolean
  date_start: string
  date_stop: string
  availability_types?: ServiceType[]
  min_order_amount?: number
  max_discount_amount?: number
  terms_and_conditions?: string
  display_order: number
  usage_limit?: number
  times_redeemed: number
  created_at: string
  updated_at: string
}

// Promotional Coupon
export interface PromotionalCoupon {
  id: number
  uuid: string
  restaurant_id?: number
  platform_wide: boolean
  code: string
  name: string
  description?: string
  discount_type: DiscountType
  discount_value: number
  is_active: boolean
  start_date: string
  end_date: string
  usage_limit_total?: number
  usage_limit_per_customer?: number
  min_order_amount?: number
  max_discount_amount?: number
  applicable_service_types?: ServiceType[]
  terms_and_conditions?: string
  times_redeemed: number
  created_at: string
  updated_at: string
}

// Flash Sale
export interface FlashSale extends PromotionalDeal {
  deal_type: 'flash_sale'
  quantity_available: number
  quantity_claimed: number
}

// Flash Sale Claim Response
export interface FlashSaleClaim {
  success: boolean
  coupon_code?: string
  message: string
  error_code?: 'SOLD_OUT' | 'EXPIRED' | 'ALREADY_CLAIMED' | 'NOT_FOUND'
}

// Applied Discount (for checkout state)
export interface AppliedDiscount {
  type: 'coupon' | 'deal'
  id: number
  code?: string
  name: string
  discountAmount: number
  discountType: DiscountType
  discountValue: number
}

// Coupon Error Codes
export enum CouponErrorCode {
  NOT_FOUND = 'COUPON_NOT_FOUND',
  EXPIRED = 'COUPON_EXPIRED',
  INACTIVE = 'COUPON_INACTIVE',
  INVALID_RESTAURANT = 'COUPON_INVALID_RESTAURANT',
  MIN_ORDER_NOT_MET = 'MIN_ORDER_NOT_MET',
  USAGE_LIMIT_REACHED = 'USAGE_LIMIT_REACHED',
  CUSTOMER_ALREADY_USED = 'CUSTOMER_ALREADY_USED',
}

// User-friendly error messages
export const COUPON_ERROR_MESSAGES: Record<CouponErrorCode, string> = {
  [CouponErrorCode.NOT_FOUND]: 'Coupon code not found. Please check and try again.',
  [CouponErrorCode.EXPIRED]: 'This coupon has expired.',
  [CouponErrorCode.INACTIVE]: 'This coupon is no longer active.',
  [CouponErrorCode.INVALID_RESTAURANT]: 'This coupon is not valid for this restaurant.',
  [CouponErrorCode.MIN_ORDER_NOT_MET]: 'Minimum order amount not met for this coupon.',
  [CouponErrorCode.USAGE_LIMIT_REACHED]: 'This coupon has reached its usage limit.',
  [CouponErrorCode.CUSTOMER_ALREADY_USED]: "You've already used this coupon.",
}
