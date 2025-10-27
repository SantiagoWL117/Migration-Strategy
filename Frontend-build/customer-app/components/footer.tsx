'use client'

import { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { Facebook, Twitter, Instagram, Youtube, Mail, Shield, Check, ChevronUp } from 'lucide-react'

const popularCuisines = ['Pizza', 'Chinese', 'Sushi', 'Indian', 'Thai', 'Mexican', 'Italian', 'Burgers']
const topCities = ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa', 'Edmonton', 'Winnipeg', 'Quebec City']

export function Footer() {
  const [email, setEmail] = useState('')
  const [subscribed, setSubscribed] = useState(false)

  const handleSubscribe = (e: React.FormEvent) => {
    e.preventDefault()
    if (email) {
      setSubscribed(true)
      setTimeout(() => setSubscribed(false), 3000)
      setEmail('')
    }
  }

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  return (
    <footer className="bg-black text-white">
      {/* Newsletter Section */}
      <div className="bg-gradient-to-r from-red-600 to-orange-600 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl mx-auto text-center">
            <h3 className="text-3xl font-bold mb-3">Get exclusive deals in your inbox</h3>
            <p className="text-red-100 mb-6">Subscribe and get $5 off your first order</p>
            
            <form onSubmit={handleSubscribe} className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                className="flex-1 px-4 py-3 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-white"
                required
              />
              <button
                type="submit"
                className="bg-white text-red-600 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors flex items-center justify-center gap-2"
              >
                {subscribed ? (
                  <>
                    <Check className="w-5 h-5" />
                    Subscribed!
                  </>
                ) : (
                  <>
                    <Mail className="w-5 h-5" />
                    Subscribe
                  </>
                )}
              </button>
            </form>
          </div>
        </div>
      </div>

      {/* Main Footer */}
      <div className="py-12 border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8">
            {/* Brand Column */}
            <div className="lg:col-span-1">
              <Image
                src="/menu-ca-logo.png"
                alt="Menu.ca"
                width={120}
                height={40}
                className="mb-4"
              />
              <p className="text-gray-400 text-sm mb-6">Your favorite food, delivered fast</p>
              
              {/* App Store Buttons */}
              <div className="space-y-3 mb-6">
                <button className="bg-gray-900 border border-gray-800 rounded-lg px-4 py-2 flex items-center gap-3 hover:bg-gray-800 transition-colors">
                  <span className="text-2xl">🍎</span>
                  <div className="text-left">
                    <div className="text-xs text-gray-400">Download on the</div>
                    <div className="font-semibold">App Store</div>
                  </div>
                </button>
                <button className="bg-gray-900 border border-gray-800 rounded-lg px-4 py-2 flex items-center gap-3 hover:bg-gray-800 transition-colors">
                  <span className="text-2xl">▶️</span>
                  <div className="text-left">
                    <div className="text-xs text-gray-400">Get it on</div>
                    <div className="font-semibold">Google Play</div>
                  </div>
                </button>
              </div>

              {/* Social Icons */}
              <div className="flex gap-3">
                <a href="#" className="bg-gray-900 p-2 rounded-full hover:bg-gray-800 transition-colors">
                  <Facebook className="w-5 h-5" />
                </a>
                <a href="#" className="bg-gray-900 p-2 rounded-full hover:bg-gray-800 transition-colors">
                  <Twitter className="w-5 h-5" />
                </a>
                <a href="#" className="bg-gray-900 p-2 rounded-full hover:bg-gray-800 transition-colors">
                  <Instagram className="w-5 h-5" />
                </a>
                <a href="#" className="bg-gray-900 p-2 rounded-full hover:bg-gray-800 transition-colors">
                  <Youtube className="w-5 h-5" />
                </a>
              </div>
            </div>

            {/* Popular Cuisines */}
            <div>
              <h4 className="font-semibold mb-4">Popular Cuisines</h4>
              <ul className="space-y-2">
                {popularCuisines.map(cuisine => (
                  <li key={cuisine}>
                    <Link href={`/search?q=${cuisine.toLowerCase()}`} className="text-gray-400 hover:text-white transition-colors">
                      {cuisine}
                    </Link>
                  </li>
                ))}
                <li>
                  <Link href="/cuisines" className="text-red-400 hover:text-red-300 transition-colors">
                    View all →
                  </Link>
                </li>
              </ul>
            </div>

            {/* Top Cities */}
            <div>
              <h4 className="font-semibold mb-4">Top Cities</h4>
              <ul className="space-y-2">
                {topCities.slice(0, 6).map(city => (
                  <li key={city}>
                    <Link href={`/city/${city.toLowerCase()}`} className="text-gray-400 hover:text-white transition-colors">
                      {city}
                    </Link>
                  </li>
                ))}
                <li>
                  <Link href="/cities" className="text-red-400 hover:text-red-300 transition-colors">
                    More cities →
                  </Link>
                </li>
              </ul>
            </div>

            {/* Support */}
            <div>
              <h4 className="font-semibold mb-4">Support</h4>
              <ul className="space-y-2">
                <li><Link href="/help" className="text-gray-400 hover:text-white transition-colors">Help Center</Link></li>
                <li><Link href="/contact" className="text-gray-400 hover:text-white transition-colors">Contact Us</Link></li>
                <li><Link href="/partners" className="text-gray-400 hover:text-white transition-colors">Partner with us</Link></li>
                <li><Link href="/careers" className="text-gray-400 hover:text-white transition-colors">Careers</Link></li>
                <li><Link href="/blog" className="text-gray-400 hover:text-white transition-colors">Blog</Link></li>
              </ul>
            </div>

            {/* Legal */}
            <div>
              <h4 className="font-semibold mb-4">Legal</h4>
              <ul className="space-y-2">
                <li><Link href="/terms" className="text-gray-400 hover:text-white transition-colors">Terms of Service</Link></li>
                <li><Link href="/privacy" className="text-gray-400 hover:text-white transition-colors">Privacy Policy</Link></li>
                <li><Link href="/cookies" className="text-gray-400 hover:text-white transition-colors">Cookie Policy</Link></li>
                <li><Link href="/accessibility" className="text-gray-400 hover:text-white transition-colors">Accessibility</Link></li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Trust Section */}
      <div className="py-8 border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col lg:flex-row items-center justify-between gap-8">
            {/* Payment Methods */}
            <div className="flex items-center gap-6">
              <span className="text-sm text-gray-400">Accepted Payments</span>
              <div className="flex gap-3">
                <div className="bg-gray-900 px-3 py-2 rounded">💳 Visa</div>
                <div className="bg-gray-900 px-3 py-2 rounded">💳 Mastercard</div>
                <div className="bg-gray-900 px-3 py-2 rounded">🍎 Apple Pay</div>
                <div className="bg-gray-900 px-3 py-2 rounded">🇬 Google Pay</div>
              </div>
            </div>

            {/* Security Badge */}
            <div className="flex items-center gap-2 text-sm text-gray-400">
              <Shield className="w-4 h-4" />
              <span>SSL Secure • PCI Compliant</span>
            </div>
          </div>

          {/* Stats Bar */}
          <div className="mt-8 pt-8 border-t border-gray-800 text-center">
            <div className="flex flex-col sm:flex-row items-center justify-center gap-6 text-sm">
              <span className="text-gray-400">
                <span className="text-white font-semibold">10M+</span> Happy Customers
              </span>
              <span className="hidden sm:inline text-gray-600">•</span>
              <span className="text-gray-400">
                <span className="text-white font-semibold">50K+</span> Restaurant Partners
              </span>
              <span className="hidden sm:inline text-gray-600">•</span>
              <span className="text-gray-400">
                <span className="text-white font-semibold">24/7</span> Customer Support
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="py-6">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-6 text-sm text-gray-400">
              <span>© 2024 Menu.ca</span>
              <button className="flex items-center gap-1 hover:text-white transition-colors">
                🇨🇦 Canada
              </button>
              <button className="flex items-center gap-1 hover:text-white transition-colors">
                EN | FR
              </button>
            </div>
            
            <div className="text-sm text-gray-400">
              Made with <span className="text-red-500">❤️</span> in Canada
            </div>
          </div>
        </div>
      </div>

      {/* Back to Top Button */}
      <button
        onClick={scrollToTop}
        className="fixed bottom-8 right-8 bg-red-600 text-white p-3 rounded-full shadow-lg hover:bg-red-700 transition-colors z-50"
        aria-label="Back to top"
      >
        <ChevronUp className="w-6 h-6" />
      </button>
    </footer>
  )
}
