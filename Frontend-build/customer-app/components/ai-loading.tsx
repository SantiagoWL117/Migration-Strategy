'use client'

import { Sparkles } from 'lucide-react'

export function AILoading() {
  return (
    <div className="flex flex-col items-center justify-center py-12">
      <div className="relative">
        <div className="w-16 h-16 bg-gradient-to-r from-red-600 to-orange-600 rounded-full animate-pulse" />
        <Sparkles className="w-8 h-8 text-yellow-300 absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 animate-spin" />
      </div>
      <p className="mt-4 text-gray-600 animate-pulse">AI is analyzing your request...</p>
      <div className="flex gap-1 mt-2">
        <div className="w-2 h-2 bg-red-600 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
        <div className="w-2 h-2 bg-orange-600 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
        <div className="w-2 h-2 bg-red-600 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
      </div>
    </div>
  )
}
