import { useCartStore } from '~/stores/cart'
import type { CartItem } from '~/stores/cart'

export const useCart = () => {
  const cartStore = useCartStore()
  
  return {
    // Estado
    items: computed(() => cartStore.items),
    totalItems: computed(() => cartStore.totalItems),
    subtotal: computed(() => cartStore.subtotal),
    total: computed(() => cartStore.total),
    isEmpty: computed(() => cartStore.isEmpty),
    isOpen: computed({
      get: () => cartStore.isOpen,
      set: (value) => cartStore.isOpen = value
    }),
    
    // Acciones
    addItem: cartStore.addItem,
    removeItem: cartStore.removeItem,
    updateQuantity: cartStore.updateQuantity,
    clearCart: cartStore.clearCart,
    openCart: cartStore.openCart,
    closeCart: cartStore.closeCart
  }
}