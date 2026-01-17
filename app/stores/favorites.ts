import { defineStore } from 'pinia'

export interface FavoriteProduct {
    product_id: number
    nombre: string
    precio_final: number
    precio_venta?: number
    es_promocion?: boolean
    porcentaje_descuento?: number
    imagen_url?: string
    marca_nombre?: string
    sku?: string
    addedAt: number // timestamp
}

export const useFavoritesStore = defineStore('favorites', {
    state: () => ({
        items: [] as FavoriteProduct[],
        isInitialized: false
    }),

    getters: {
        totalItems: (state) => state.items.length,
        isEmpty: (state) => state.items.length === 0,
        // Puedes agregar más getters según necesites
        sortedByDate: (state) => {
            return [...state.items].sort((a, b) => b.addedAt - a.addedAt)
        }
    },

    actions: {
        // Inicializar desde localStorage
        initialize() {
            if (typeof window !== 'undefined' && !this.isInitialized) {
                try {
                    const saved = localStorage.getItem('favorites')
                    if (saved) {
                        this.items = JSON.parse(saved)
                    }
                    this.isInitialized = true
                } catch (error) {
                    console.error('Error al cargar favoritos:', error)
                    this.items = []
                }
            }
        },

        // Guardar en localStorage
        saveToStorage() {
            if (typeof window !== 'undefined') {
                try {
                    localStorage.setItem('favorites', JSON.stringify(this.items))
                } catch (error) {
                    console.error('Error al guardar favoritos:', error)
                }
            }
        },

        // Agregar producto a favoritos
        addItem(product: Omit<FavoriteProduct, 'addedAt'>) {
            const existing = this.items.find(item => item.product_id === product.product_id)
            
            if (!existing) {
                this.items.push({
                    ...product,
                    addedAt: Date.now()
                })
                this.saveToStorage()
                return true
            }
            return false
        },

        // Remover producto de favoritos
        removeItem(productId: number) {
            this.items = this.items.filter(item => item.product_id !== productId)
            this.saveToStorage()
        },

        // Verificar si un producto está en favoritos
        isFavorite(productId: number): boolean {
            return this.items.some(item => item.product_id === productId)
        },

        // Toggle (agregar/remover)
        toggleFavorite(product: Omit<FavoriteProduct, 'addedAt'>) {
            if (this.isFavorite(product.product_id)) {
                this.removeItem(product.product_id)
                return false
            } else {
                this.addItem(product)
                return true
            }
        },

        // Limpiar todos los favoritos
        clearFavorites() {
            this.items = []
            if (typeof window !== 'undefined') {
                localStorage.removeItem('favorites')
            }
        },

        // Obtener IDs de productos favoritos (útil para API)
        getFavoriteIds(): number[] {
            return this.items.map(item => item.product_id)
        }
    }
})