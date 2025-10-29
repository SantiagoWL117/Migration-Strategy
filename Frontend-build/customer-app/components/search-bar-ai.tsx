'use client'

import { useState, useEffect, useRef } from 'react'
import { Search, Sparkles, Mic, X } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface AISuggestion {
  cuisines: string[]
  restaurants: string[]
  message: string
  confidence: number
}

export function SearchBar() {
  const [query, setQuery] = useState('')
  const [placeholder, setPlaceholder] = useState('What are you in the mood for?')
  const [isTyping, setIsTyping] = useState(false)
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [aiSuggestion, setAiSuggestion] = useState<AISuggestion | null>(null)
  const [isLoadingAI, setIsLoadingAI] = useState(false)
  const router = useRouter()
  const searchRef = useRef<HTMLDivElement>(null)
  const debounceTimer = useRef<NodeJS.Timeout | undefined>(undefined)

  // Rotating placeholder suggestions
  useEffect(() => {
    const suggestions = [
      'What are you in the mood for?',
      'Try "spicy thai food"',
      'Try "pizza near me"',
      'Try "healthy salads"',
      'Try "sushi delivery"',
      'Try "late night burgers"',
      'Try "I want something healthy and spicy"',
      'Try "comfort food for a rainy day"'
    ]
    
    let index = 0
    const interval = setInterval(() => {
      if (!isTyping && !query) {
        index = (index + 1) % suggestions.length
        setPlaceholder(suggestions[index])
      }
    }, 3000)

    return () => clearInterval(interval)
  }, [isTyping, query])

  // AI-powered search suggestions
  useEffect(() => {
    if (query.length > 3) {
      clearTimeout(debounceTimer.current)
      debounceTimer.current = setTimeout(async () => {
        setIsLoadingAI(true)
        try {
          const response = await fetch('/api/ai-search', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query })
          })
          
          if (response.ok) {
            const data = await response.json()
            setAiSuggestion(data)
            setShowSuggestions(true)
          }
        } catch (error) {
          console.error('AI search error:', error)
        } finally {
          setIsLoadingAI(false)
        }
      }, 300)
    } else {
      setAiSuggestion(null)
      setShowSuggestions(false)
    }
  }, [query])

  // Close suggestions when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowSuggestions(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const handleSearch = (searchQuery?: string) => {
    const finalQuery = searchQuery || query
    if (finalQuery.trim()) {
      router.push(`/search?q=${encodeURIComponent(finalQuery)}`)
      setShowSuggestions(false)
    }
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    handleSearch()
  }

  const popularSearches = ['Pizza', 'Sushi', 'Burgers', 'Thai', 'Chinese', 'Healthy']

  return (
    <div className="relative" ref={searchRef}>
      <form onSubmit={handleSubmit} className="relative">
        <div className="relative bg-white rounded-full shadow-xl overflow-hidden">
          <div className="flex items-center px-6 py-4">
            <Sparkles className="w-5 h-5 text-yellow-500 mr-3 animate-pulse" />
            <input
              type="text"
              placeholder={placeholder}
              value={query}
              onChange={(e) => {
                setQuery(e.target.value)
                setIsTyping(true)
              }}
              onBlur={() => setTimeout(() => setIsTyping(false), 200)}
              onFocus={() => setShowSuggestions(!!aiSuggestion)}
              className="flex-1 outline-none text-lg text-gray-900 placeholder-gray-500"
            />
            {query && (
              <button
                type="button"
                onClick={() => {
                  setQuery('')
                  setShowSuggestions(false)
                }}
                className="mr-3 text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            )}
            <button
              type="button"
              className="mr-3 text-gray-400 hover:text-gray-600"
              title="Voice search (coming soon)"
            >
              <Mic className="w-5 h-5" />
            </button>
            <button
              type="submit"
              className="ml-2 bg-red-600 text-white p-3 rounded-full hover:bg-red-700 transition-colors"
            >
              <Search className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* AI Suggestions Dropdown */}
        {showSuggestions && aiSuggestion && (
          <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-2xl shadow-2xl overflow-hidden z-50">
            {isLoadingAI ? (
              <div className="p-4 text-center text-gray-500">
                <div className="flex items-center justify-center gap-2">
                  <Sparkles className="w-5 h-5 animate-spin" />
                  <span>AI is thinking...</span>
                </div>
              </div>
            ) : (
              <>
                {aiSuggestion.message && (
                  <div className="px-4 py-3 bg-gradient-to-r from-red-50 to-orange-50 border-b">
                    <p className="text-sm text-gray-700 flex items-center gap-2">
                      <Sparkles className="w-4 h-4 text-yellow-500" />
                      {aiSuggestion.message}
                    </p>
                  </div>
                )}
                
                {aiSuggestion.restaurants.length > 0 && (
                  <div className="p-4">
                    <p className="text-xs text-gray-500 mb-2">Recommended restaurants</p>
                    <div className="space-y-2">
                      {aiSuggestion.restaurants.map((restaurant) => (
                        <button
                          key={restaurant}
                          onClick={() => handleSearch(restaurant)}
                          className="w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors"
                        >
                          <span className="font-medium">{restaurant}</span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}
                
                {aiSuggestion.cuisines.length > 0 && (
                  <div className="px-4 pb-4">
                    <p className="text-xs text-gray-500 mb-2">Related cuisines</p>
                    <div className="flex flex-wrap gap-2">
                      {aiSuggestion.cuisines.map((cuisine) => (
                        <button
                          key={cuisine}
                          onClick={() => handleSearch(cuisine)}
                          className="px-3 py-1 bg-gray-100 text-sm rounded-full hover:bg-gray-200 transition-colors capitalize"
                        >
                          {cuisine}
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </form>

      {/* Popular Searches */}
      <div className="mt-4 flex flex-wrap gap-2">
        <span className="text-sm text-red-100">Popular:</span>
        {popularSearches.map((term) => (
          <button
            key={term}
            onClick={() => handleSearch(term.toLowerCase())}
            className="text-sm bg-white/20 text-white px-3 py-1 rounded-full hover:bg-white/30 transition-colors backdrop-blur"
          >
            {term}
          </button>
        ))}
      </div>
    </div>
  )
}
