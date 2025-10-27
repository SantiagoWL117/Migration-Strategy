import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface CartModifier {
  id: number
  name: string
  price: number
}

interface CartItem {
  dishId: number
  name: string
  price: number
  quantity: number
  modifiers: CartModifier[]
  restaurantId: number
}

interface CartStore {
  items: CartItem[]
  restaurantId: number | null
  
  addItem: (item: CartItem) => void
  removeItem: (dishId: number) => void
  updateQuantity: (dishId: number, quantity: number) => void
  clearCart: () => void
  
  subtotal: () => number
  tax: () => number
  total: () => number
  itemCount: () => number
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],
      restaurantId: null,

      addItem: (newItem) => {
        const { items, restaurantId } = get()

        // Check if adding from different restaurant
        if (restaurantId && restaurantId !== newItem.restaurantId) {
          const confirmed = confirm(
            'Adding items from a different restaurant will clear your current cart. Continue?'
          )
          if (!confirmed) return
          
          set({
            items: [newItem],
            restaurantId: newItem.restaurantId,
          })
          return
        }

        // Check if item already exists
        const existingItemIndex = items.findIndex(
          (item) => item.dishId === newItem.dishId
        )

        if (existingItemIndex >= 0) {
          // Update quantity
          const updatedItems = [...items]
          updatedItems[existingItemIndex].quantity += newItem.quantity
          set({ items: updatedItems })
        } else {
          // Add new item
          set({
            items: [...items, newItem],
            restaurantId: newItem.restaurantId,
          })
        }
      },

      removeItem: (dishId) => {
        set((state) => ({
          items: state.items.filter((item) => item.dishId !== dishId),
        }))
      },

      updateQuantity: (dishId, quantity) => {
        if (quantity <= 0) {
          get().removeItem(dishId)
          return
        }

        set((state) => ({
          items: state.items.map((item) =>
            item.dishId === dishId ? { ...item, quantity } : item
          ),
        }))
      },

      clearCart: () => {
        set({ items: [], restaurantId: null })
      },

      subtotal: () => {
        const { items } = get()
        return items.reduce((total, item) => {
          const itemTotal = item.price * item.quantity
          const modifiersTotal = item.modifiers.reduce(
            (sum, mod) => sum + mod.price * item.quantity,
            0
          )
          return total + itemTotal + modifiersTotal
        }, 0)
      },

      tax: () => {
        const subtotal = get().subtotal()
        return subtotal * 0.13 // 13% HST for Ontario
      },

      total: () => {
        return get().subtotal() + get().tax()
      },

      itemCount: () => {
        return get().items.reduce((count, item) => count + item.quantity, 0)
      },
    }),
    {
      name: 'menuca-cart-storage',
    }
  )
)

