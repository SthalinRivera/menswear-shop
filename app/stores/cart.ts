import { defineStore } from 'pinia'

export interface CartItem {
    id: number
    product_id: number
    nombre: string
    precio_final: number
    cantidad: number
    variante_id?: number
    color_nombre?: string
    talla?: string
    sku?: string
    imagen_url?: string
}

export const useCartStore = defineStore('cart', {
    state: () => ({
        items: [] as CartItem[],
        isOpen: false
    }),

    getters: {
        totalItems: (state) => state.items.reduce((total, item) => total + item.cantidad, 0),
        subtotal: (state) => state.items.reduce((total, item) => total + (item.precio_final * item.cantidad), 0),
        total: (state) => {
            const subtotal = state.items.reduce((total, item) => total + (item.precio_final * item.cantidad), 0)
            const iva = subtotal * 0.18
            return subtotal + iva
        },
        isEmpty: (state) => state.items.length === 0
    },

    actions: {
        // Función para inicializar el carrito (cargar desde localStorage)
        initialize() {
            if (typeof window !== 'undefined') {
                try {
                    const saved = localStorage.getItem('cart')
                    if (saved) {
                        this.items = JSON.parse(saved)
                    }
                } catch (error) {
                    console.error('Error al cargar carrito:', error)
                    this.items = []
                }
            }
        },

        // Función para guardar en localStorage
        saveToStorage() {
            if (typeof window !== 'undefined') {
                try {
                    localStorage.setItem('cart', JSON.stringify(this.items))
                } catch (error) {
                    console.error('Error al guardar carrito:', error)
                }
            }
        },

        addItem(item: Omit<CartItem, 'id'>) {
            const existing = this.items.find(i => 
                i.product_id === item.product_id && 
                i.variante_id === item.variante_id
            )

            if (existing) {
                existing.cantidad += item.cantidad
            } else {
                this.items.push({ id: Date.now(), ...item })
            }
            this.saveToStorage()
        },

        removeItem(id: number) {
            this.items = this.items.filter(item => item.id !== id)
            this.saveToStorage()
        },

        updateQuantity(id: number, cantidad: number) {
            const item = this.items.find(item => item.id === id)
            if (item) {
                item.cantidad = Math.max(1, cantidad)
                this.saveToStorage()
            }
        },

        clearCart() {
            this.items = []
            if (typeof window !== 'undefined') {
                localStorage.removeItem('cart')
            }
        },

        openCart() {
            this.isOpen = true
        },

        closeCart() {
            this.isOpen = false
        }
    }
})