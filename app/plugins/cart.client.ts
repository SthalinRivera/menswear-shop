import { useCartStore } from '~/stores/cart'

export default defineNuxtPlugin(() => {
  // Solo en el cliente
  if (process.client) {
    const cartStore = useCartStore()
    // Inicializar el carrito al cargar la página
    cartStore.initialize()
  }
})