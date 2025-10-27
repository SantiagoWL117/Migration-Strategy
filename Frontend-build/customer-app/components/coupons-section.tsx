'use client'

import { useState, useEffect } from 'react'
import { Clock, Tag, Zap, CheckCircle2 } from 'lucide-react'
import Image from 'next/image'

interface Coupon {
  id: string
  restaurant: string
  discount: string
  code?: string
  expiresIn: number // hours
  type: 'percentage' | 'dollar' | 'special'
  minOrder?: number
  category: string
  isNew?: boolean
  savings?: string
}

const mockCoupons: Coupon[] = [
  {
    id: '1',
    restaurant: 'Tony\'s Pizza',
    discount: '20% OFF',
    code: 'PIZZA20',
    expiresIn: 2,
    type: 'percentage',
    category: 'Pizza',
    savings: 'Save up to $8'
  },
  {
    id: '2',
    restaurant: 'Sakura Sushi',
    discount: '$10 OFF',
    code: 'AUTO',
    expiresIn: 5,
    type: 'dollar',
    minOrder: 40,
    category: 'Sushi',
    isNew: true,
    savings: 'Save $10'
  },
  {
    id: '3',
    restaurant: 'Burger Palace',
    discount: 'BOGO',
    code: 'BURGER2',
    expiresIn: 1,
    type: 'special',
    category: 'Burgers',
    savings: 'Save 50%'
  },
  {
    id: '4',
    restaurant: 'Thai Spice',
    discount: '15% OFF',
    expiresIn: 3,
    type: 'percentage',
    category: 'Thai',
    isNew: true,
    savings: 'Save up to $6'
  }
]

export function CouponsSection() {
  const [selectedCategory, setSelectedCategory] = useState('All Deals')
  const [timeLeft, setTimeLeft] = useState<Record<string, number>>({})

  const categories = ['All Deals', 'Pizza', 'Sushi', 'Burgers', 'Thai', 'New User']

  // Update countdown timers
  useEffect(() => {
    const interval = setInterval(() => {
      const newTimeLeft: Record<string, number> = {}
      mockCoupons.forEach(coupon => {
        const hoursLeft = coupon.expiresIn
        const totalSeconds = hoursLeft * 3600 - (Date.now() % 3600000) / 1000
        newTimeLeft[coupon.id] = Math.max(0, totalSeconds)
      })
      setTimeLeft(newTimeLeft)
    }, 1000)

    return () => clearInterval(interval)
  }, [])

  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = Math.floor(seconds % 60)
    return `${hours}h ${minutes}m ${secs}s`
  }

  const filteredCoupons = selectedCategory === 'All Deals' 
    ? mockCoupons 
    : mockCoupons.filter(c => c.category === selectedCategory)

  return (
    <section className="relative py-16 overflow-hidden bg-black">
      {/* Subtle gradient overlay for depth */}
      <div className="absolute inset-0 bg-gradient-to-b from-gray-900/50 to-black" />

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-10">
          <div className="inline-flex items-center gap-2 bg-red-600/20 border border-red-600/50 rounded-full px-4 py-1 mb-4">
            <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
            <span className="text-red-400 text-sm font-medium">LIVE DEALS</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-3">
            Exclusive Offers
          </h2>
          <p className="text-gray-400 text-lg">Limited time deals from top-rated restaurants</p>
        </div>

        {/* Category Pills */}
        <div className="flex flex-wrap justify-center gap-2 mb-8">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-5 py-2.5 rounded-full text-sm font-medium transition-all duration-200 ${
                selectedCategory === category
                  ? 'bg-gradient-to-r from-red-600 to-orange-600 text-white shadow-lg shadow-red-600/30'
                  : 'bg-gray-900 text-gray-300 hover:bg-gray-800 border border-gray-800'
              }`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Coupons Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {filteredCoupons.map(coupon => (
            <div
              key={coupon.id}
              className="relative group"
            >
              {/* Glow effect on hover */}
              <div className="absolute -inset-0.5 bg-gradient-to-r from-red-600 to-orange-600 rounded-2xl opacity-0 group-hover:opacity-75 blur transition duration-300" />
              
              {/* Card content */}
              <div className="relative bg-gray-900/80 backdrop-blur-xl rounded-2xl border border-gray-800 overflow-hidden hover:border-gray-700 transition-all duration-200">
                {/* Limited Time Badge */}
                {coupon.expiresIn <= 2 && (
                  <div className="absolute top-3 right-3 bg-gradient-to-r from-red-600 to-orange-600 text-white text-xs px-3 py-1.5 rounded-full flex items-center gap-1 animate-pulse">
                    <Zap className="w-3 h-3" />
                    <span className="font-bold">LIMITED TIME</span>
                  </div>
                )}

                <div className="p-6">
                  {/* Restaurant Name with NEW badge */}
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-sm text-gray-400">{coupon.restaurant}</h3>
                    {coupon.isNew && (
                      <span className="text-xs bg-green-600/20 text-green-400 px-2 py-0.5 rounded-full font-medium">
                        NEW
                      </span>
                    )}
                  </div>

                  {/* Discount Amount */}
                  <div className="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-orange-500 mb-1">
                    {coupon.discount}
                  </div>

                  {/* Savings Amount */}
                  {coupon.savings && (
                    <p className="text-sm text-green-400 mb-3">{coupon.savings}</p>
                  )}

                  {/* Min Order */}
                  {coupon.minOrder && (
                    <p className="text-sm text-gray-500 mb-4">
                      Min. order ${coupon.minOrder}
                    </p>
                  )}

                  {/* Coupon Code */}
                  <div className="bg-black/50 border border-gray-700 rounded-lg px-4 py-3 mb-4 flex items-center justify-between group/code hover:border-gray-600 transition-colors cursor-pointer">
                    <span className="text-sm font-mono text-gray-300">
                      {coupon.code === 'AUTO' ? '✨ Auto-applied' : coupon.code || 'No code needed'}
                    </span>
                    {coupon.code && coupon.code !== 'AUTO' && (
                      <span className="text-xs text-gray-500 group-hover/code:text-gray-400">Click to copy</span>
                    )}
                  </div>

                  {/* Expiry Timer with Progress Bar */}
                  <div className="mb-4">
                    <div className="flex items-center justify-between text-sm mb-2">
                      <span className="text-gray-400">Expires in</span>
                      <span className="text-gray-300 font-mono">
                        {formatTime(timeLeft[coupon.id] || 0)}
                      </span>
                    </div>
                    {/* Progress Bar */}
                    <div className="h-1 bg-gray-800 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-gradient-to-r from-red-600 to-orange-600 transition-all duration-1000"
                        style={{ 
                          width: `${((timeLeft[coupon.id] || 0) / (coupon.expiresIn * 3600)) * 100}%` 
                        }}
                      />
                    </div>
                  </div>

                  {/* Use Button */}
                  <button className="w-full bg-gradient-to-r from-red-600 to-orange-600 text-white py-3 rounded-xl hover:shadow-lg hover:shadow-red-600/20 transition-all duration-200 font-semibold relative overflow-hidden group">
                    <span className="relative z-10">Claim Deal</span>
                    <div className="absolute inset-0 bg-gradient-to-r from-orange-600 to-red-600 opacity-0 group-hover:opacity-100 transition-opacity duration-200" />
                  </button>

                  {/* Verified Badge */}
                  <div className="flex items-center justify-center gap-1 mt-3 text-xs text-gray-500">
                    <CheckCircle2 className="w-3 h-3" />
                    <span>Verified Partner</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
