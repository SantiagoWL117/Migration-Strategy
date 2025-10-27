'use client'

import { useState, useEffect } from 'react'
import { useCartStore } from '@/lib/store/cart-store'
import { useRouter } from 'next/navigation'
import { Trash2, Plus, Minus } from 'lucide-react'
import { Elements } from '@stripe/react-stripe-js'
import { getStripe } from '@/lib/stripe/config'
import { StripeCheckoutForm } from '@/components/stripe-checkout-form'

export default function CheckoutPage() {
  const router = useRouter()
  const items = useCartStore((state) => state.items)
  const updateQuantity = useCartStore((state) => state.updateQuantity)
  const removeItem = useCartStore((state) => state.removeItem)
  const clearCart = useCartStore((state) => state.clearCart)
  const subtotal = useCartStore((state) => state.subtotal())
  const tax = useCartStore((state) => state.tax())
  const total = useCartStore((state) => state.total())

  const [clientSecret, setClientSecret] = useState<string | null>(null)
  const [isLoadingPayment, setIsLoadingPayment] = useState(false)
  const [showPaymentForm, setShowPaymentForm] = useState(false)

  // Delivery form state
  const [deliveryInfo, setDeliveryInfo] = useState({
    name: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    postalCode: '',
    instructions: ''
  })

  const deliveryFee = 3.99
  const finalTotal = total + deliveryFee

  // Get restaurant ID from first item
  const restaurantId = items[0]?.restaurantId || 0

  // Validate delivery form
  const validateDeliveryInfo = () => {
    if (!deliveryInfo.name.trim()) {
      alert('Please enter your name')
      return false
    }
    if (!deliveryInfo.email.trim() || !deliveryInfo.email.includes('@')) {
      alert('Please enter a valid email')
      return false
    }
    if (!deliveryInfo.phone.trim()) {
      alert('Please enter your phone number')
      return false
    }
    if (!deliveryInfo.address.trim()) {
      alert('Please enter your delivery address')
      return false
    }
    if (!deliveryInfo.city.trim()) {
      alert('Please enter your city')
      return false
    }
    if (!deliveryInfo.postalCode.trim()) {
      alert('Please enter your postal code')
      return false
    }
    return true
  }

  // Create Payment Intent when user clicks "Proceed to Payment"
  const handleProceedToPayment = async () => {
    // Validate delivery info first
    if (!validateDeliveryInfo()) {
      return
    }

    setIsLoadingPayment(true)

    try {
      const response = await fetch('/api/create-payment-intent', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          amount: finalTotal,
          restaurantId,
          items: items.map(item => ({
            dishId: item.dishId,
            name: item.name,
            quantity: item.quantity,
            price: item.price
          }))
        }),
      })

      if (!response.ok) {
        throw new Error('Failed to create payment intent')
      }

      const data = await response.json()
      setClientSecret(data.clientSecret)
      setShowPaymentForm(true)
    } catch (error) {
      console.error('Error creating payment intent:', error)
      alert('Failed to initialize payment. Please try again.')
    } finally {
      setIsLoadingPayment(false)
    }
  }

  const handlePaymentSuccess = async (paymentIntentId: string) => {
    try {
      // Create order in database
      const response = await fetch('/api/orders/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          restaurantId,
          items: items.map(item => ({
            dishId: item.dishId,
            name: item.name,
            quantity: item.quantity,
            price: item.price,
            modifiers: item.modifiers
          })),
          paymentIntentId,
          customerInfo: {
            name: deliveryInfo.name,
            email: deliveryInfo.email,
            phone: deliveryInfo.phone
          },
          deliveryInfo: {
            address: deliveryInfo.address,
            city: deliveryInfo.city,
            postalCode: deliveryInfo.postalCode,
            instructions: deliveryInfo.instructions
          },
          totals: {
            subtotal,
            tax,
            deliveryFee,
            total: finalTotal
          }
        }),
      })

      if (!response.ok) {
        throw new Error('Failed to create order')
      }

      const data = await response.json()
      console.log('Order created:', data.order)

      // Clear cart
      clearCart()

      // Redirect to confirmation with order ID
      router.push(`/order-confirmation?payment_intent=${paymentIntentId}&order_id=${data.order.id}`)
    } catch (error) {
      console.error('Error creating order:', error)
      // Still redirect to confirmation even if order creation fails
      // (Payment already succeeded, order can be recovered from Stripe webhook)
      clearCart()
      router.push(`/order-confirmation?payment_intent=${paymentIntentId}`)
    }
  }

  if (items.length === 0) {
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
          <h2 className="text-2xl font-bold mb-4">Your cart is empty</h2>
          <p className="text-gray-600 mb-6">Add some delicious items to get started!</p>
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
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-red-600">
              <a href="/">Menu.ca</a>
            </h1>
            <button
              onClick={() => router.back()}
              className="text-gray-600 hover:text-gray-900"
            >
              ← Back
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-8">
        <h2 className="text-3xl font-bold mb-8">Checkout</h2>

        <div className="grid lg:grid-cols-[1fr,400px] gap-8">
          {/* Cart Items */}
          <div className="space-y-4">
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-semibold mb-4">Your Items</h3>
              
              {items.map((item) => (
                <div key={item.dishId} className="flex gap-4 py-4 border-b last:border-b-0">
                  <div className="flex-1">
                    <h4 className="font-semibold">{item.name}</h4>
                    <p className="text-sm text-gray-600">${item.price.toFixed(2)} each</p>
                    {item.modifiers.length > 0 && (
                      <p className="text-sm text-gray-500 mt-1">
                        + {item.modifiers.map(m => m.name).join(', ')}
                      </p>
                    )}
                  </div>

                  {/* Quantity Controls */}
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => updateQuantity(item.dishId, item.quantity - 1)}
                      className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-100"
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="w-8 text-center font-medium">{item.quantity}</span>
                    <button
                      onClick={() => updateQuantity(item.dishId, item.quantity + 1)}
                      className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-100"
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>

                  {/* Item Total */}
                  <div className="flex items-center gap-4">
                    <span className="font-semibold">
                      ${(item.price * item.quantity).toFixed(2)}
                    </span>
                    <button
                      onClick={() => removeItem(item.dishId)}
                      className="text-red-600 hover:text-red-700"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* Payment Form */}
            {showPaymentForm && clientSecret && (
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-xl font-semibold mb-4">Payment Details</h3>
                <Elements
                  stripe={getStripe()}
                  options={{
                    clientSecret,
                    appearance: {
                      theme: 'stripe',
                      variables: {
                        colorPrimary: '#dc2626',
                      }
                    }
                  }}
                >
                  <StripeCheckoutForm
                    totalAmount={finalTotal}
                    onSuccess={handlePaymentSuccess}
                  />
                </Elements>
              </div>
            )}

            {/* Delivery Info */}
            {!showPaymentForm && (
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-xl font-semibold mb-4">Delivery Details</h3>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Full Name <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="text"
                      placeholder="John Doe"
                      value={deliveryInfo.name}
                      onChange={(e) => setDeliveryInfo({...deliveryInfo, name: e.target.value})}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Email <span className="text-red-600">*</span>
                      </label>
                      <input
                        type="email"
                        placeholder="john@example.com"
                        value={deliveryInfo.email}
                        onChange={(e) => setDeliveryInfo({...deliveryInfo, email: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Phone <span className="text-red-600">*</span>
                      </label>
                      <input
                        type="tel"
                        placeholder="(555) 123-4567"
                        value={deliveryInfo.phone}
                        onChange={(e) => setDeliveryInfo({...deliveryInfo, phone: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Delivery Address <span className="text-red-600">*</span>
                    </label>
                    <input
                      type="text"
                      placeholder="123 Main Street"
                      value={deliveryInfo.address}
                      onChange={(e) => setDeliveryInfo({...deliveryInfo, address: e.target.value})}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        City <span className="text-red-600">*</span>
                      </label>
                      <input
                        type="text"
                        placeholder="Toronto"
                        value={deliveryInfo.city}
                        onChange={(e) => setDeliveryInfo({...deliveryInfo, city: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Postal Code <span className="text-red-600">*</span>
                      </label>
                      <input
                        type="text"
                        placeholder="M5H 2N2"
                        value={deliveryInfo.postalCode}
                        onChange={(e) => setDeliveryInfo({...deliveryInfo, postalCode: e.target.value})}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Delivery Instructions (Optional)
                    </label>
                    <textarea
                      placeholder="e.g., Ring doorbell, leave at door"
                      rows={3}
                      value={deliveryInfo.instructions}
                      onChange={(e) => setDeliveryInfo({...deliveryInfo, instructions: e.target.value})}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-600 focus:border-transparent"
                    />
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Order Summary */}
          <div>
            <div className="bg-white rounded-lg shadow-md p-6 sticky top-8">
              <h3 className="text-xl font-semibold mb-4">Order Summary</h3>
              
              <div className="space-y-2 mb-4">
                <div className="flex justify-between">
                  <span className="text-gray-600">Subtotal</span>
                  <span className="font-medium">${subtotal.toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Tax (13%)</span>
                  <span className="font-medium">${tax.toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Delivery Fee</span>
                  <span className="font-medium">$3.99</span>
                </div>
              </div>

              <div className="border-t pt-4 mb-6">
                <div className="flex justify-between text-lg font-bold">
                  <span>Total</span>
                  <span>${finalTotal.toFixed(2)}</span>
                </div>
              </div>

              {!showPaymentForm ? (
                <button
                  className="w-full bg-red-600 text-white py-3 rounded-lg hover:bg-red-700 font-medium transition-colors disabled:bg-gray-400"
                  onClick={handleProceedToPayment}
                  disabled={isLoadingPayment}
                >
                  {isLoadingPayment ? 'Loading...' : 'Proceed to Payment'}
                </button>
              ) : (
                <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm text-center">
                  ✓ Ready to pay. Complete payment form on the left.
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}

