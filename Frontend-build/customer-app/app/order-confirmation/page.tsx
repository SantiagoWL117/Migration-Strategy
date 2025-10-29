'use client'

import { useSearchParams, useRouter } from 'next/navigation'
import { Suspense, useEffect, useState } from 'react'
import { CheckCircle, Package, Clock } from 'lucide-react'
import { QuickSignInPrompt } from '@/components/quick-signin-prompt'
import { createClient } from '@/lib/supabase/client'

function OrderConfirmationContent() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()
  const searchParams = useSearchParams()
  const paymentIntentId = searchParams.get('payment_intent')

  // Check if user is authenticated
  useEffect(() => {
    const checkAuth = async () => {
      const supabase = createClient()
      const { data: { session } } = await supabase.auth.getSession()
      setIsAuthenticated(!!session)
      setIsLoading(false)
    }
    checkAuth()
  }, [])

  if (!paymentIntentId) {
    return (
      <main className="min-h-screen bg-gray-50">
        <header className="bg-white border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <h1 className="text-2xl font-bold text-red-600">
              <a href="/">Menu.ca</a>
            </h1>
          </div>
        </header>

        <div className="max-w-2xl mx-auto px-4 py-16 text-center">
          <h2 className="text-2xl font-bold mb-4">No order found</h2>
          <p className="text-gray-600 mb-6">We couldn't find your order details.</p>
          <button
            onClick={() => router.push('/')}
            className="bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700"
          >
            Browse Restaurants
          </button>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <h1 className="text-2xl font-bold text-red-600">
            <a href="/">Menu.ca</a>
          </h1>
        </div>
      </header>

      {/* Confirmation Message */}
      <div className="max-w-3xl mx-auto px-4 py-16">
        {/* Success Card */}
        <div className="bg-white rounded-lg shadow-md p-8 text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-green-100 rounded-full mb-6">
            <CheckCircle className="w-12 h-12 text-green-600" />
          </div>

          <h2 className="text-3xl font-bold mb-3">Order Confirmed!</h2>
          <p className="text-lg text-gray-600 mb-6">
            Thank you for your order. Your payment has been processed successfully.
          </p>

          {/* Payment Intent ID */}
          <div className="bg-gray-50 rounded-lg p-4 mb-6 max-w-md mx-auto">
            <p className="text-sm text-gray-600 mb-1">Order Reference</p>
            <p className="font-mono text-sm text-gray-800 break-all">{paymentIntentId}</p>
          </div>

          {/* What's Next Section */}
          <div className="border-t pt-6 mt-6">
            <h3 className="text-xl font-semibold mb-4">What happens next?</h3>

            <div className="grid md:grid-cols-2 gap-6 text-left">
              <div className="flex gap-3">
                <div className="flex-shrink-0">
                  <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                    <Package className="w-5 h-5 text-red-600" />
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-1">Order Preparation</h4>
                  <p className="text-sm text-gray-600">
                    The restaurant is preparing your order with care
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <div className="flex-shrink-0">
                  <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                    <Clock className="w-5 h-5 text-red-600" />
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-1">Estimated Delivery</h4>
                  <p className="text-sm text-gray-600">
                    Your order will arrive in 30-45 minutes
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Sign-In Prompt for Guest Orders */}
        {!isLoading && !isAuthenticated && (
          <div className="mb-6">
            <div className="bg-gradient-to-r from-red-50 to-orange-50 border-2 border-red-200 rounded-lg p-6">
              <h3 className="text-xl font-bold text-gray-900 mb-2">
                Track this order in real-time! 📱
              </h3>
              <p className="text-gray-700 mb-4">
                Create an account in 30 seconds to get live delivery updates, save your favorites, and re-order with one tap.
              </p>
              <QuickSignInPrompt
                message="Enter your phone number to unlock:"
                redirectTo={`/order-tracking?payment_intent=${paymentIntentId}`}
                showGuestOption={false}
              />
              <div className="mt-4 flex flex-wrap gap-3 text-sm text-gray-600">
                <span className="flex items-center gap-1">✓ Real-time order tracking</span>
                <span className="flex items-center gap-1">✓ Order history</span>
                <span className="flex items-center gap-1">✓ Quick re-orders</span>
                <span className="flex items-center gap-1">✓ Save favorites</span>
              </div>
            </div>
          </div>
        )}

        {/* Email Confirmation Notice */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <p className="text-sm text-blue-800">
            <strong>Note:</strong> You will receive an order confirmation email shortly with your order details.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button
            onClick={() => router.push('/')}
            className="w-full bg-red-600 text-white py-3 rounded-lg hover:bg-red-700 font-medium transition-colors"
          >
            Browse More Restaurants
          </button>

          <button
            onClick={() => router.push('/orders')}
            className="w-full bg-white text-gray-700 py-3 rounded-lg border border-gray-300 hover:bg-gray-50 font-medium transition-colors"
          >
            View Order History
          </button>
        </div>

        {/* Support Section */}
        <div className="text-center mt-8 pt-8 border-t">
          <p className="text-sm text-gray-600">
            Need help with your order?{' '}
            <a href="/support" className="text-red-600 hover:text-red-700 font-medium">
              Contact Support
            </a>
          </p>
        </div>
      </div>
    </main>
  )
}

export default function OrderConfirmationPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
      <OrderConfirmationContent />
    </Suspense>
  )
}
