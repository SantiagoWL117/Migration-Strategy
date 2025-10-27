'use client'

import { useState } from 'react'
import { Search, MapPin } from 'lucide-react'
import { useRouter } from 'next/navigation'

export function SearchBar() {
  const [query, setQuery] = useState('')
  const [location, setLocation] = useState('')
  const router = useRouter()

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    
    // Build search URL with query params
    const params = new URLSearchParams()
    if (query) params.set('q', query)
    if (location) params.set('location', location)
    
    router.push(`/search?${params.toString()}`)
  }

  return (
    <form onSubmit={handleSearch} className="bg-white rounded-lg shadow-lg p-2 flex flex-col sm:flex-row gap-2">
      {/* Search Input */}
      <div className="flex-1 flex items-center gap-2 px-4 py-2 border-b sm:border-b-0 sm:border-r border-gray-200">
        <Search className="w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Search for restaurants, dishes..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-1 outline-none text-gray-900 placeholder-gray-400"
        />
      </div>

      {/* Location Input */}
      <div className="flex-1 flex items-center gap-2 px-4 py-2">
        <MapPin className="w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Enter your address"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          className="flex-1 outline-none text-gray-900 placeholder-gray-400"
        />
      </div>

      {/* Search Button */}
      <button
        type="submit"
        className="bg-red-600 text-white px-8 py-3 rounded-md hover:bg-red-700 font-medium transition-colors"
      >
        Search
      </button>
    </form>
  )
}

