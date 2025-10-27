'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'
import { SearchBar } from './search-bar-ai'
import { MapPin, Star, Clock } from 'lucide-react'

const floatingFoods = ['🍕', '🍔', '🍱', '🌮', '🍜', '🥗']
const taglines = [
  'Order pizza in minutes',
  'Fresh sushi delivered',
  'Burgers to your door',
  'Thai food, fast delivery',
  'Healthy meals, happy you'
]

export function HeroSection() {
  const [orderCount, setOrderCount] = useState(2341)
  const [currentTagline, setCurrentTagline] = useState(0)
  const [displayedText, setDisplayedText] = useState('')
  const [isTyping, setIsTyping] = useState(true)

  // Increment order counter
  useEffect(() => {
    const interval = setInterval(() => {
      setOrderCount(prev => prev + Math.floor(Math.random() * 3) + 1)
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  // Typing animation for taglines
  useEffect(() => {
    const text = taglines[currentTagline]
    if (isTyping) {
      if (displayedText.length < text.length) {
        const timeout = setTimeout(() => {
          setDisplayedText(text.slice(0, displayedText.length + 1))
        }, 50)
        return () => clearTimeout(timeout)
      } else {
        setTimeout(() => setIsTyping(false), 2000)
      }
    } else {
      setTimeout(() => {
        setCurrentTagline((prev) => (prev + 1) % taglines.length)
        setDisplayedText('')
        setIsTyping(true)
      }, 500)
    }
  }, [displayedText, currentTagline, isTyping])

  return (
    <section className="relative bg-red-600 text-white py-20 md:py-24 overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0 z-0">
        <Image
          src="/hero-bg.jpg"
          alt="Delicious food background"
          fill
          className="object-cover animate-slow-zoom"
          priority
        />
        <div className="absolute inset-0 bg-gradient-to-r from-red-600/90 to-red-700/90" />
        
        {/* Floating Food Icons */}
        <div className="absolute inset-0">
          {floatingFoods.map((food, index) => (
            <div
              key={index}
              className="absolute text-4xl animate-float opacity-20"
              style={{
                left: `${15 + index * 15}%`,
                animationDelay: `${index * 0.5}s`,
                top: `${20 + (index % 2) * 40}%`
              }}
            >
              {food}
            </div>
          ))}
        </div>
      </div>
      
      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Trust Badges */}
        <div className="flex items-center justify-center gap-6 mb-8 text-sm">
          <div className="flex items-center gap-2 bg-white/10 backdrop-blur px-4 py-2 rounded-full">
            <Clock className="w-4 h-4" />
            <span className="font-medium">{orderCount.toLocaleString()} orders today</span>
          </div>
          <div className="flex items-center gap-2 bg-white/10 backdrop-blur px-4 py-2 rounded-full">
            <Star className="w-4 h-4 fill-current" />
            <span className="font-medium">4.8 avg rating</span>
          </div>
        </div>

        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-5xl md:text-6xl font-bold mb-4 drop-shadow-lg">
            Order food from your favorite restaurants
          </h2>
          
          {/* Typing Animation */}
          <p className="text-xl text-red-100 mb-8 h-7">
            <span className="inline-block min-w-[1px]">
              {displayedText}
              {isTyping && <span className="animate-blink">|</span>}
            </span>
          </p>

          {/* Location Badge */}
          <div className="flex items-center justify-center gap-2 mb-8">
            <MapPin className="w-5 h-5" />
            <span className="text-lg">Delivering to Toronto</span>
            <button className="text-red-200 hover:text-white underline text-sm">
              Change
            </button>
          </div>

          <SearchBar />

          {/* Stats */}
          <div className="mt-8 flex items-center justify-center gap-8 text-sm text-red-100">
            <span>961 restaurants</span>
            <span>•</span>
            <span>50+ cuisines</span>
            <span>•</span>
            <span>Avg delivery 30 min</span>
          </div>
        </div>
      </div>
    </section>
  )
}
