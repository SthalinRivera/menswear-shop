<template>
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
        <!-- Header -->
        <header class="sticky top-0 z-40 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
            <div class="max-w-7xl mx-auto px-4 py-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <button @click="goBack" 
                                class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                            <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                            </svg>
                        </button>
                        <div>
                            <h1 class="text-xl font-bold text-gray-900 dark:text-white">Mis Favoritos</h1>
                            <p class="text-sm text-gray-500 dark:text-gray-400">
                                {{ favoritesStore.totalItems }} 
                                {{ favoritesStore.totalItems === 1 ? 'producto' : 'productos' }}
                            </p>
                        </div>
                    </div>
                    <button v-if="!favoritesStore.isEmpty"
                            @click="clearFavoritesDialog = true"
                            class="px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition-colors">
                        Limpiar todo
                    </button>
                </div>
            </div>
        </header>

        <!-- Contenido Principal -->
        <main class="max-w-7xl mx-auto px-4 py-6">
            <!-- Estado vacío -->
            <div v-if="favoritesStore.isEmpty" class="text-center py-16">
                <div class="w-24 h-24 mx-auto mb-6 text-gray-300 dark:text-gray-700">
                    <svg class="w-full h-full" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">No tienes favoritos aún</h2>
                <p class="text-gray-600 dark:text-gray-400 mb-8">Guarda productos que te gusten para verlos después</p>
                <NuxtLink to="/catalog"
                         class="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 text-white font-medium rounded-lg transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    Explorar productos
                </NuxtLink>
            </div>

            <!-- Grid de productos favoritos con el mismo estilo -->
            <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-4 xl:grid-cols-5 gap-2">
                <div v-for="(product, index) in favoritesStore.sortedByDate" 
                     :key="product.product_id"
                     :class="[
                        'group relative block bg-white dark:bg-gray-800 rounded-xl sm:rounded-2xl overflow-hidden shadow-sm dark:shadow-gray-900/20',
                        !loadingStates[product.product_id] ? 'hover:shadow-lg dark:hover:shadow-gray-900/30 transition-all duration-300 hover:-translate-y-1' : 'pointer-events-none'
                     ]"> 

                    <!-- Badge de descuento -->
                    <div v-if="product.es_promocion && !loadingStates[product.product_id]"
                         class="absolute top-2 left-2 z-20 px-2 py-1 sm:px-2.5 sm:py-1 bg-red-500 dark:bg-red-600 text-white text-[10px] sm:text-xs font-bold rounded-full shadow-sm dark:shadow-red-900/50">
                        -{{ product.porcentaje_descuento || 0 }}%
                    </div>

                    <!-- Contenedor de imagen con skeleton -->
                    <div class="relative aspect-square bg-gray-100 dark:bg-gray-700">
                        <!-- Skeleton Loading para la imagen -->
                        <div v-if="loadingStates[product.product_id]"
                             class="absolute inset-0 z-10 animate-pulse">
                            <div class="absolute inset-0 bg-gray-200 dark:bg-gray-700 rounded-xl sm:rounded-2xl"></div>
                            <div class="absolute inset-0 border border-gray-300/30 dark:border-gray-600/30 rounded-xl sm:rounded-2xl"></div>
                            <div class="absolute inset-0 flex items-center justify-center">
                                <svg class="w-10 h-10 text-gray-300 dark:text-gray-600" fill="none" stroke="currentColor"
                                     viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1"
                                          d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                        </div>

                        <!-- Imagen real -->
                        <img :src="getImage(product)" :alt="product.nombre" :class="[
                            'absolute inset-0 w-full h-full object-contain p-2 sm:p-3 transition-all duration-300',
                            loadingStates[product.product_id] ? 'opacity-0' : 'opacity-100 group-hover:p-1.5'
                        ]" @load="onImageLoad(product.product_id)" @error="onImageError(product.product_id)" loading="lazy" />

                        <!-- Botón eliminar favorito - solo en desktop y cuando la imagen está cargada -->
                        <button v-if="!loadingStates[product.product_id]"
                                @click.stop="removeFromFavorites(product.product_id)"
                                class="absolute bottom-2 right-2 z-20 w-9 h-9 sm:w-8 sm:h-8 bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm rounded-full shadow-md dark:shadow-gray-900/50 flex items-center justify-center  transition-all duration-300 hover:scale-110 hover:bg-red-50 dark:hover:bg-red-900/30">
                            <svg class="w-6 h-6 sm:w-6 sm:h-6 text-red-500 dark:text-red-400" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>

                    <!-- Contenido -->
                    <div class="p-2 sm:p-3 space-y-1.5 sm:space-y-2">
                        <!-- Precio y Rating -->
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-1 sm:gap-1.5">
                                <svg v-if="!loadingStates[product.product_id]" class="w-3 h-3 sm:w-4 sm:h-4 text-yellow-500 dark:text-yellow-400"
                                     fill="currentColor" viewBox="0 0 20 20">
                                    <path
                                        d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                </svg>
                                <span class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white">
                                    {{ getRandomRating(index) }}
                                </span>
                            </div>

                            <div class="text-right">
                                <div class="flex items-baseline gap-1 sm:gap-1.5">
                                    <span class="text-sm sm:text-lg font-bold text-gray-900 dark:text-white">
                                        S/ {{ product.precio_final.toFixed(2) }}
                                    </span>
                                    <span v-if="product.precio_venta && product.precio_venta > product.precio_final" 
                                          class="text-[10px] sm:text-xs text-gray-500 dark:text-gray-400 line-through">
                                        S/ {{ product.precio_venta.toFixed(2) }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Nombre del producto -->
                        <NuxtLink :to="`/catalog/${product.product_id}`">
                            <h3 class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white line-clamp-2 leading-tight min-h-[2rem] sm:min-h-[2.5rem] hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                                {{ product.nombre }}
                            </h3>
                        </NuxtLink>

                        <!-- Marca y Stock -->
                        <div class="flex items-center justify-between pt-1 sm:pt-2 border-t border-gray-100 dark:border-gray-700">
                            <span class="text-[10px] sm:text-xs text-gray-500 dark:text-gray-400 font-medium">
                                {{ product.marca_nombre || 'Marca' }}
                            </span>

                            <div class="flex items-center gap-1 sm:gap-1.5">
                                <div :class="[
                                    'w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full',
                                    isProductAvailable(product) ? 'bg-green-500 dark:bg-green-400 animate-pulse' : 'bg-gray-300 dark:bg-gray-600'
                                ]" />
                                <span class="text-[10px] sm:text-xs text-gray-500 dark:text-gray-400">
                                    {{ isProductAvailable(product) ? 'Disponible' : 'Agotado' }}
                                </span>
                            </div>
                        </div>

                        <!-- Botones de acción - solo cuando la imagen está cargada -->
                        <template v-if="!loadingStates[product.product_id]">
                            <!-- Botón de ver producto y agregar al carrito - Desktop -->
                            <div class="hidden sm:flex gap-2 mt-1 sm:mt-2">
                                <NuxtLink :to="`/catalog/${product.product_id}`"
                                         class="flex-1 py-1.5 sm:py-2 text-[10px] sm:text-sm font-semibold text-center text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 rounded-lg sm:rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-all duration-300 hover:scale-[1.02] flex items-center justify-center gap-1 sm:gap-2">
                                    <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                    Ver
                                </NuxtLink>
                                
                                <button @click.stop="addToCart(product)"
                                        :class="[
                                            'flex-1 py-1.5 sm:py-2 text-[10px] sm:text-sm font-semibold bg-gray-900 dark:bg-gray-700 text-white rounded-lg sm:rounded-xl hover:bg-gray-800 dark:hover:bg-gray-600 transition-all duration-300 hover:scale-[1.02] flex items-center justify-center gap-1 sm:gap-2',
                                            !isProductAvailable(product) ? 'opacity-50 cursor-not-allowed' : ''
                                        ]"
                                        :disabled="!isProductAvailable(product)">
                                    <svg class="w-3 h-3 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                    </svg>
                                    Agregar
                                </button>
                            </div>

                            <!-- Botón único para móvil -->
                            <button @click.stop="addToCart(product)"
                                    :class="[
                                        'w-full py-1.5 text-[10px] font-semibold bg-gray-900 dark:bg-gray-700 text-white rounded-lg hover:bg-gray-800 dark:hover:bg-gray-600 transition-colors duration-200 flex sm:hidden items-center justify-center gap-1',
                                        !isProductAvailable(product) ? 'opacity-50 cursor-not-allowed' : ''
                                    ]"
                                    :disabled="!isProductAvailable(product)">
                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                </svg>
                                Agregar al carrito
                            </button>
                        </template>
                    </div>

                    <!-- Indicador de producto nuevo -->
                    <div v-if="index < 2 && !loadingStates[product.product_id]"
                         class="absolute top-2 right-2 px-1.5 py-0.5 sm:px-2 sm:py-1 bg-blue-500 dark:bg-blue-600 text-white text-[8px] sm:text-xs font-bold rounded sm:rounded-lg z-20">
                        NUEVO
                    </div>

                    <!-- Efecto hover para desktop - solo cuando la imagen está cargada -->
                    <div v-if="!loadingStates[product.product_id]"
                         class="absolute inset-0 rounded-xl sm:rounded-2xl pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-300 hidden sm:block">
                        <div class="absolute inset-0 border-2 border-blue-500/20 dark:border-blue-400/20 rounded-xl sm:rounded-2xl" />
                        <div class="absolute inset-0 bg-gradient-to-br from-blue-500/5 dark:from-blue-400/5 via-transparent to-transparent rounded-xl sm:rounded-2xl" />
                    </div>
                </div>
            </div>
        </main>

        <!-- Modal de confirmación para limpiar favoritos -->
        <div v-if="clearFavoritesDialog" 
             class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 dark:bg-black/70 backdrop-blur-sm p-4">
            <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 max-w-md w-full border border-gray-200 dark:border-gray-700 shadow-xl">
                <div class="text-center">
                    <div class="mx-auto w-16 h-16 mb-4 text-red-500 dark:text-red-400">
                        <svg class="w-full h-full" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">¿Eliminar todos los favoritos?</h3>
                    <p class="text-gray-600 dark:text-gray-400 mb-6">
                        Se eliminarán {{ favoritesStore.totalItems }} productos de tu lista de favoritos. Esta acción no se puede deshacer.
                    </p>
                    <div class="flex gap-3">
                        <button @click="clearFavoritesDialog = false"
                                class="flex-1 px-4 py-3 text-sm font-medium text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                            Cancelar
                        </button>
                        <button @click="clearAllFavorites"
                                class="flex-1 px-4 py-3 text-sm font-medium text-white bg-red-600 dark:bg-red-500 hover:bg-red-700 dark:hover:bg-red-600 rounded-lg transition-colors">
                            Eliminar todo
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { useFavoritesStore, type FavoriteProduct } from '~/stores/favorites'
import { useCartStore } from '~/stores/cart'

const router = useRouter()
const toast = useToast()
const favoritesStore = useFavoritesStore()
const cartStore = useCartStore()
const clearFavoritesDialog = ref(false)

// Estado para controlar carga de imágenes
const loadingStates = ref<Record<number, boolean>>({})

// Obtener imagen del producto
const getImage = (product: FavoriteProduct) => {
    return product.imagen_url || 'https://placehold.co/300x300/e2e8f0/64748b?text=Producto'
}

// Función para generar un rating aleatorio
const getRandomRating = (index: number) => {
    const ratings = [4.6, 4.8, 4.4, 4.9, 4.8]
    return ratings[index % ratings.length] || 4.5
}

// Verificar si un producto está disponible
const isProductAvailable = (product: FavoriteProduct) => {
    // Como no tenemos stock en FavoriteProduct, asumimos que está disponible
    // Puedes modificar esto si agregas stock al interface FavoriteProduct
    return true
}

// Observador para detectar cuando las imágenes se cargan
const onImageLoad = (id: number) => {
    loadingStates.value[id] = false
}

const onImageError = (id: number) => {
    loadingStates.value[id] = false
    // Si hay error, intentamos cargar una imagen placeholder
    const products = favoritesStore.items
    const product = products.find(p => p.product_id === id)
    if (product) {
        product.imagen_url = 'https://placehold.co/300x300/e2e8f0/64748b?text=Producto'
    }
}

// Inicializar el store y estados de carga
onMounted(() => {
    favoritesStore.initialize()
    
    // Inicializar estados de carga
    favoritesStore.items.forEach(product => {
        loadingStates.value[product.product_id] = true
    })
})

// Observar cambios en los productos
watch(() => favoritesStore.items, (newProducts) => {
    newProducts.forEach(product => {
        if (!(product.product_id in loadingStates.value)) {
            loadingStates.value[product.product_id] = true
        }
    })
}, { immediate: true })

// Navegación
const goBack = () => {
    router.back()
}

// Eliminar un producto de favoritos
const removeFromFavorites = (productId: number) => {
    favoritesStore.removeItem(productId)
    
    toast.add({
        title: 'Eliminado de favoritos',
        description: 'El producto ha sido removido de tu lista',
        icon: 'i-lucide-trash-2',
        color: 'blue'
    })
}

// Limpiar todos los favoritos
const clearAllFavorites = () => {
    favoritesStore.clearFavorites()
    clearFavoritesDialog.value = false
    
    toast.add({
        title: 'Favoritos eliminados',
        description: 'Todos los productos han sido removidos de tu lista',
        icon: 'i-lucide-check',
        color: 'green'
    })
}

// Agregar al carrito desde favoritos
const addToCart = (product: FavoriteProduct) => {
    if (!isProductAvailable(product)) {
        toast.add({
            title: 'Producto no disponible',
            description: 'Este producto no está disponible en este momento',
            icon: 'i-lucide-x',
            color: 'red'
        })
        return
    }
    
    const cartItem = {
        product_id: product.product_id,
        nombre: product.nombre,
        precio_final: product.precio_final,
        cantidad: 1,
        sku: product.sku || '',
        imagen_url: product.imagen_url || '/placeholder-image.jpg'
    }
    
    cartStore.addItem(cartItem)
    
    toast.add({
        title: '¡Agregado al carrito!',
        description: `${product.nombre} se ha agregado al carrito`,
        icon: 'i-lucide-shopping-cart',
        color: 'green'
    })
    
    cartStore.openCart()
}
</script>

<style scoped>
/* Estilos para truncar texto */
.line-clamp-2 {
    overflow: hidden;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
}

/* Animación del skeleton */
@keyframes pulse {
    0%, 100% {
        opacity: 1;
    }
    50% {
        opacity: 0.5;
    }
}

.animate-pulse {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* Asegurar que el contenedor de imagen tenga aspect ratio cuadrado */
.aspect-square {
    aspect-ratio: 1 / 1;
}

/* Suavizar la transición de la imagen */
img {
    transition: opacity 0.3s ease, padding 0.3s ease;
}

/* Desactivar interacciones durante la carga */
.pointer-events-none {
    pointer-events: none;
}
</style>