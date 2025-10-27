'use client'

import { useState, useEffect } from 'react'
import { Search, Sparkles } from 'lucide-react'
import { useRouter } from 'next/navigation'

export function SearchBar() {
  const [query, setQuery] = useState('')
  const [placeholder, setPlaceholder] = useState('What are you in the mood for?')
  const [isTyping, setIsTyping] = useState(false)
  const router = useRouter()

  // Rotating placeholder suggestions - now with AI examples!
  useEffect(() => {
    const suggestions = [
      'What are you in the mood for?',
      'Try "I want something healthy and spicy"',
      'Try "comfort food for a rainy day"',
      'Try "vegan options near me"',
      'Try "date night restaurants"',
      'Try "late night pizza"'
    ]
    
    let index = 0
    const interval = setInterval(() => {
      if (!isTyping) {
        index = (index + 1) % suggestions.length
        setPlaceholder(suggestions[index])
      }
    }, 3000)

    return () => clearInterval(interval)
  }, [isTyping])

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    if (query.trim()) {
      router.push(`/search?q=${encodeURIComponent(query)}`)
    }
  }

  const popularSearches = ['Pizza', 'Sushi', 'Burgers', 'Thai', 'Chinese', 'Healthy']

  return (
    <div>
      <form onSubmit={handleSearch} className="relative">
        <div className="relative bg-white rounded-full shadow-xl overflow-hidden">
          <div className="flex items-center px-6 py-4">
            <Sparkles className="w-5 h-5 text-yellow-500 mr-3 animate-pulse" />
            <input
              type="text"
              placeholder={placeholder}
              value={query}
              onChange={(e) => {
                setQuery(e.target.value)
                setIsTyping(e.target.value.length > 0)
              }}
              onBlur={() => setIsTyping(false)}
              className="flex-1 outline-none text-lg text-gray-900 placeholder-gray-500"
            />
            <button
              type="submit"
              className="ml-4 bg-red-600 text-white p-3 rounded-full hover:bg-red-700 transition-colors"
            >
              <Search className="w-5 h-5" />
            </button>
          </div>
        </div>
      </form>

      {/* Popular Searches */}
      <div className="mt-4 flex flex-wrap gap-2">
        <span className="text-sm text-red-100">Popular:</span>
        {popularSearches.map((term) => (
          <button
            key={term}
            onClick={() => {
              setQuery(term.toLowerCase())
              router.push(`/search?q=${encodeURIComponent(term.toLowerCase())}`)
            }}
            className="text-sm bg-white/20 text-white px-3 py-1 rounded-full hover:bg-white/30 transition-colors"
          >
            {term}
          </button>
        ))}
      </div>
    </div>
  )
}