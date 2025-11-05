'use client'

import { useState } from 'react'
import { Loader2, Tag, X, Check } from 'lucide-react'
import type { CouponValidation } from '@/lib/promotions/types'
import { COUPON_ERROR_MESSAGES, CouponErrorCode } from '@/lib/promotions/types'

interface CouponInputProps {
  onApply: (code: string) => Promise<CouponValidation>
  onRemove: () => void
  appliedCoupon?: {
    code: string
    name: string
    discountAmount: number
  } | null
  disabled?: boolean
}

export function CouponInput({ onApply, onRemove, appliedCoupon, disabled }: CouponInputProps) {
  const [code, setCode] = useState('')
  const [isValidating, setIsValidating] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleApply = async () => {
    if (!code.trim()) {
      setError('Please enter a coupon code')
      return
    }

    setIsValidating(true)
    setError(null)

    try {
      const validation = await onApply(code.trim().toUpperCase())

      if (!validation.valid && validation.error_code) {
        // Show user-friendly error message
        const errorMessage =
          COUPON_ERROR_MESSAGES[validation.error_code as CouponErrorCode] ||
          'Invalid coupon code. Please try again.'
        setError(errorMessage)
      } else {
        // Success - clear input
        setCode('')
      }
    } catch (err) {
      console.error('Coupon validation error:', err)
      setError('Failed to validate coupon. Please try again.')
    } finally {
      setIsValidating(false)
    }
  }

  const handleRemove = () => {
    setCode('')
    setError(null)
    onRemove()
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      handleApply()
    }
  }

  // Show applied coupon state
  if (appliedCoupon) {
    return (
      <div className="bg-green-50 border-2 border-green-200 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
              <Check className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <p className="font-semibold text-green-900">{appliedCoupon.name}</p>
                <span className="text-xs bg-green-200 text-green-800 px-2 py-0.5 rounded font-mono">
                  {appliedCoupon.code}
                </span>
              </div>
              <p className="text-sm text-green-700">
                You saved ${appliedCoupon.discountAmount.toFixed(2)}!
              </p>
            </div>
          </div>
          <button
            onClick={handleRemove}
            disabled={disabled}
            className="text-green-700 hover:text-green-900 p-2 hover:bg-green-100 rounded-full transition-colors disabled:opacity-50"
            aria-label="Remove coupon"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>
    )
  }

  // Show input state
  return (
    <div className="space-y-2">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
            <Tag className="w-5 h-5" />
          </div>
          <input
            type="text"
            value={code}
            onChange={(e) => setCode(e.target.value.toUpperCase())}
            onKeyPress={handleKeyPress}
            placeholder="Enter coupon code"
            disabled={disabled || isValidating}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed font-mono uppercase"
          />
        </div>
        <button
          onClick={handleApply}
          disabled={disabled || isValidating || !code.trim()}
          className="px-6 py-2.5 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center gap-2 whitespace-nowrap"
        >
          {isValidating ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              Validating...
            </>
          ) : (
            'Apply'
          )}
        </button>
      </div>

      {/* Error Message */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3 flex items-start gap-2">
          <X className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
          <p className="text-sm text-red-700">{error}</p>
        </div>
      )}

      {/* Helper Text */}
      {!error && (
        <p className="text-xs text-gray-500 pl-1">
          Have a coupon code? Enter it above to save on your order.
        </p>
      )}
    </div>
  )
}
