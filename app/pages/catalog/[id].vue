<script setup lang="ts">
import { ref, watchEffect, computed, onMounted, onUnmounted } from 'vue'
import { useCartStore } from '~/stores/cart'
import { useFavoritesStore } from '~/stores/favorites'
const route = useRoute()
const toast = useToast()
const id = route.params.id
const config = useRuntimeConfig()
const cartStore = useCartStore()
const favoritesStore = useFavoritesStore()
// Fetch del producto
const { data, pending, error } = await useFetch(
    `${config.public.apiBaseUrl}/products/${id}`,
    { default: () => ({ data: [] }) }
)

const producto = computed(() => data.value?.data || null)
const selectedImage = ref<string | null>(null)
const selectedVariant = ref<any>(null)
const quantity = ref(1)

// Modal de galería
const showGallery = ref(false)
const galleryIndex = ref(0)

watchEffect(() => {
    const imagenes = producto.value?.imagenes
    if (imagenes?.length) {
        const principal = imagenes.find(i => i.es_principal)
        selectedImage.value = principal?.url || imagenes[0].url
    }
    if (producto.value?.variantes?.length) {
        selectedVariant.value = producto.value.variantes[0]
    }
})

// Funciones galería
const openGallery = (index: number) => {
    galleryIndex.value = index
    showGallery.value = true
    document.body.style.overflow = 'hidden' // Bloquear scroll
}

const closeGallery = () => {
    showGallery.value = false
    document.body.style.overflow = 'auto' // Restaurar scroll
}

const nextImage = () => {
    if (!producto.value?.imagenes) return
    galleryIndex.value = (galleryIndex.value + 1) % producto.value.imagenes.length
}

const prevImage = () => {
    if (!producto.value?.imagenes) return
    galleryIndex.value = (galleryIndex.value - 1 + producto.value.imagenes.length) % producto.value.imagenes.length
}

// Cerrar con Escape
const handleKeydown = (e: KeyboardEvent) => {
    if (e.key === 'Escape' && showGallery.value) {
        closeGallery()
    }
}

// Cerrar al hacer click fuera
const handleOutsideClick = (e: MouseEvent) => {
    const target = e.target as HTMLElement
    if (target.classList.contains('gallery-modal-overlay')) {
        closeGallery()
    }
}

onMounted(() => {
    window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
    window.removeEventListener('keydown', handleKeydown)
    document.body.style.overflow = 'auto'
})

// Agregar al carrito
const addToCart = () => {
  if (!producto.value) return
  
  const itemToAdd = {
    product_id: producto.value.producto_id,
    nombre: producto.value.nombre,
    precio_final: parseFloat(producto.value.precio_final),
    cantidad: quantity.value,
    sku: selectedVariant.value?.sku || producto.value.sku,
    variante_id: selectedVariant.value?.variante_id,
    color_nombre: selectedVariant.value?.color_nombre,
    talla: selectedVariant.value?.talla,
    imagen_url: selectedImage.value || producto.value.imagenes?.[0]?.url || '/placeholder-image.jpg'
  }
  
  cartStore.addItem(itemToAdd)
  
  toast.add({
    title: '¡Producto agregado!',
    description: `${producto.value.nombre} se ha agregado al carrito`,
    icon: 'i-lucide-check',
    color: 'green'
  })
  
  cartStore.openCart()
}

const incrementQuantity = () => {
  if (selectedVariant.value && quantity.value < selectedVariant.value.stock_disponible) {
    quantity.value++
  }
}

const decrementQuantity = () => {
  if (quantity.value > 1) {
    quantity.value--
  }
}

// Estado para cabecera flotante
const isScrolled = ref(false)

// Manejador de scroll
const handleScroll = () => {
  isScrolled.value = window.scrollY > 50
}

// En el onMounted
onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

// Manejadores para los eventos
const handleBack = () => {
  console.log('Regresando...')
}

const handleFavorite = (isFavorite: boolean) => {
  console.log('Favorito:', isFavorite)
}

const handleShare = () => {
  console.log('Compartiendo producto...')
}


const handleFavoriteToggle = () => {
    if (!producto.value) return
    
    const favoriteProduct = {
        product_id: producto.value.producto_id,
        nombre: producto.value.nombre,
        precio_final: parseFloat(producto.value.precio_final),
        precio_venta: producto.value.precio_promocion ? parseFloat(producto.value.precio_venta) : undefined,
        es_promocion: producto.value.es_promocion,
        porcentaje_descuento: producto.value.porcentaje_descuento,
        imagen_url: selectedImage.value || producto.value.imagenes?.[0]?.url || '/placeholder-image.jpg',
        marca_nombre: producto.value.marca_nombre,
        sku: selectedVariant.value?.sku || producto.value.sku
    }
    
    const isNowFavorite = favoritesStore.toggleFavorite(favoriteProduct)
    
    toast.add({
        title: isNowFavorite ? '¡Agregado a favoritos!' : 'Eliminado de favoritos',
        description: isNowFavorite 
            ? `${producto.value.nombre} se ha guardado en tus favoritos`
            : `${producto.value.nombre} se ha removido de tus favoritos`,
        icon: isNowFavorite ? 'i-lucide-heart' : 'i-lucide-heart-off',
        color: isNowFavorite ? 'red' : 'gray'
    })
}
</script>

<template>
    <div class="min-h-screen bg-white dark:bg-gray-900">
  <HeaderBack 
      :isScrolled="isScrolled" 
      @back="handleBack"
      @favorite="handleFavorite"
      @share="handleShare"
    />
        <!-- LOADING -->
        <div v-if="pending" class="p-4 md:p-8">
            <div class="grid md:grid-cols-2 gap-6 md:gap-12">
                <!-- Imagen loading -->
                <div class="space-y-4">
                    <div class="aspect-square rounded-2xl bg-gray-200 dark:bg-gray-800 animate-pulse" />
                    <div class="flex gap-3">
                        <div v-for="i in 4" :key="i"
                            class="w-16 h-16 md:w-20 md:h-20 rounded-lg bg-gray-200 dark:bg-gray-800 animate-pulse" />
                    </div>
                </div>
                <!-- Info loading -->
                <div class="space-y-6">
                    <div class="h-8 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-3/4" />
                    <div class="space-y-2">
                        <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded animate-pulse" />
                        <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-2/3" />
                    </div>
                    <div class="h-10 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-1/3" />
                </div>
            </div>
        </div>

        <!-- ERROR -->
        <div v-if="error" class="m-4 md:m-8 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 p-4">
            <div class="flex items-center gap-3">
                <div class="w-5 h-5 text-red-500">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                    </svg>
                </div>
                <div>
                    <h3 class="font-semibold text-red-800 dark:text-red-300">Error al cargar el producto</h3>
                    <p class="text-sm text-red-600 dark:text-red-400">Intenta nuevamente en unos momentos</p>
                </div>
            </div>
        </div>

        <!-- MODAL DE GALERÍA (puro Tailwind CSS) -->
        <div v-if="showGallery && producto?.imagenes" 
             @click="handleOutsideClick"
             class="gallery-modal-overlay fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm transition-opacity duration-300">
            <div class="relative w-full h-full max-w-7xl max-h-[90vh] flex items-center justify-center p-4">
                <!-- Botón cerrar -->
                <button @click="closeGallery" 
                        class="absolute top-4 right-4 z-10 w-10 h-10 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center transition-colors group">
                    <svg class="w-6 h-6 text-white group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>

                <!-- Botón anterior -->
                <button @click="prevImage" 
                        class="absolute left-4 top-1/2 transform -translate-y-1/2 z-10 w-12 h-12 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center transition-colors group">
                    <svg class="w-6 h-6 text-white group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                </button>

                <!-- Botón siguiente -->
                <button @click="nextImage" 
                        class="absolute right-4 top-1/2 transform -translate-y-1/2 z-10 w-12 h-12 bg-white/10 hover:bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center transition-colors group">
                    <svg class="w-6 h-6 text-white group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                </button>

                <!-- Contador -->
                <div class="absolute top-4 left-4 z-10 px-3 py-1 bg-black/50 backdrop-blur-sm rounded-full text-white text-sm font-medium">
                    {{ galleryIndex + 1 }} / {{ producto.imagenes.length }}
                </div>

                <!-- Imagen principal del modal -->
                <div class="relative w-full h-full flex items-center justify-center">
                    <img :src="producto.imagenes[galleryIndex].url" 
                         class="max-w-full max-h-full object-contain rounded-lg transition-transform duration-300"
                         :key="galleryIndex" />
                </div>

                <!-- Miniaturas en modal -->
                <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex gap-2 z-10">
                    <button v-for="(img, index) in producto.imagenes" 
                            :key="img.url"
                            @click="galleryIndex = index"
                            :class="[
                                'w-16 h-16 md:w-20 md:h-20 rounded-lg overflow-hidden border-2 transition-all duration-200 hover:scale-105',
                                galleryIndex === index 
                                    ? 'border-white ring-2 ring-white ring-opacity-50' 
                                    : 'border-white/30 hover:border-white/60'
                            ]">
                        <img :src="img.url" class="w-full h-full object-cover" />
                    </button>
                </div>
            </div>
        </div>

        <!-- PRODUCTO -->
        <div v-if="producto" class="pb-20 md:pb-0">
            <div class="max-w-7xl mx-auto">
                <!-- Desktop Layout -->
                <div class="hidden md:grid md:grid-cols-2 gap-12 p-8">
                    <!-- GALERÍA DESKTOP -->
                    <div class="space-y-6">
                        <!-- Imagen principal -->
                        <div class="aspect-square rounded-3xl overflow-hidden bg-gray-100 dark:bg-gray-800 shadow-xl">
                            <img v-if="selectedImage" :src="selectedImage"
                                class="w-full h-full object-cover transition-transform duration-500 hover:scale-105 cursor-zoom-in"
                                @click="openGallery(producto.imagenes?.findIndex(img => img.url === selectedImage) || 0)" />
                        </div>

                        <!-- Miniaturas desktop -->
                        <div v-if="producto?.imagenes?.length > 1" class="flex gap-4">
                            <button v-for="(img, index) in producto.imagenes" :key="img.url"
                                @click="selectedImage = img.url"
                                :class="['w-20 h-20 rounded-xl overflow-hidden border-2 transition-all duration-300 hover:scale-105',
                                    selectedImage === img.url
                                        ? 'border-blue-500 ring-2 ring-blue-500 ring-opacity-30 shadow-md'
                                        : 'border-gray-300 dark:border-gray-700 hover:border-gray-400 dark:hover:border-gray-600']">
                                <img :src="img.url" class="w-full h-full object-cover" />
                            </button>
                        </div>
                    </div>

                    <!-- INFORMACIÓN DESKTOP -->
                    <div class="space-y-8">
                        <!-- Encabezado -->
                        <div class="space-y-4">
                            <div class="flex items-center gap-3">
                                <span class="px-3 py-1 bg-gray-100 dark:bg-gray-800 rounded-full text-sm text-gray-600 dark:text-gray-400">
                                    {{ producto.marca_nombre }}
                                </span>
                                <span v-if="producto.es_promocion" class="px-3 py-1 bg-red-500 text-white rounded-full text-sm font-medium">
                                    -{{ producto.porcentaje_descuento }}% OFF
                                </span>
                            </div>

                            <h1 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white leading-tight">
                                {{ producto.nombre }}
                            </h1>

                            <!-- Rating desktop -->
                            <div class="flex items-center gap-6">
                                <div class="flex items-center">
                                    <div class="flex">
                                        <svg v-for="i in 5" :key="i" class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                        </svg>
                                    </div>
                                    <span class="ml-2 text-lg font-semibold text-gray-900 dark:text-white">4.8</span>
                                    <span class="ml-1 text-gray-500 dark:text-gray-400">(128 reviews)</span>
                                </div>
                                <div class="flex items-center gap-2">
                                    <div class="w-2 h-2 rounded-full animate-pulse bg-green-500" />
                                    <span class="text-gray-600 dark:text-gray-400">
                                        {{ Number(producto.stock_total) > 0 ? 'En stock' : 'Agotado' }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Descripción desktop -->
                        <div class="space-y-3">
                            <h2 class="text-xl font-semibold text-gray-900 dark:text-white">Descripción</h2>
                            <p class="text-gray-600 dark:text-gray-300 text-lg leading-relaxed">
                                {{ producto.descripcion }}
                            </p>
                        </div>

                        <!-- Precio desktop -->
                        <div class="space-y-2">
                            <div class="flex items-baseline gap-4">
                                <span class="text-5xl font-bold text-gray-900 dark:text-white">
                                    S/ {{ producto.precio_final }}
                                </span>
                                <span v-if="producto.precio_promocion"
                                    class="text-2xl line-through text-gray-400 dark:text-gray-500">
                                    S/ {{ producto.precio_venta }}
                                </span>
                            </div>
                            <p class="text-gray-600 dark:text-gray-400">
                                IVA incluído • Envío gratis • Devolución en 30 días
                            </p>
                        </div>

                        <!-- Variantes desktop -->
                        <div v-if="producto.variantes?.length" class="space-y-6">
                            <!-- Tallas -->
                            <div class="space-y-3">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Seleccionar talla</h3>
                                <div class="flex flex-wrap gap-3">
                                    <button v-for="talla in [...new Set(producto.variantes.map(v => v.talla))]"
                                        :key="talla" :class="[
                                            'px-6 py-3 text-base font-medium rounded-xl border-2 transition-all duration-200',
                                            selectedVariant?.talla === talla
                                                ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300'
                                                : 'border-gray-300 dark:border-gray-700 hover:border-gray-400 dark:hover:border-gray-600 text-gray-700 dark:text-gray-300'
                                        ]" @click="selectedVariant = producto.variantes.find(v => v.talla === talla)">
                                        {{ talla }}
                                    </button>
                                </div>
                            </div>

                            <!-- Colores -->
                            <div class="space-y-3">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Seleccionar color</h3>
                                <div class="flex flex-wrap gap-4">
                                    <button v-for="v in producto.variantes" :key="v.variante_id"
                                        @click="selectedVariant = v" :class="[
                                            'relative group',
                                            selectedVariant?.variante_id === v.variante_id
                                                ? 'ring-2 ring-blue-500 ring-offset-2'
                                                : ''
                                        ]">
                                        <div class="w-16 h-16 rounded-full border-4 border-white dark:border-gray-800 shadow-lg"
                                            :style="{ backgroundColor: v.color_hex }" />
                                        <span
                                            class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 text-xs text-gray-600 dark:text-gray-400 whitespace-nowrap">
                                            {{ v.color_nombre }}
                                        </span>
                                    </button>
                                </div>
                            </div>

                            <!-- Stock detallado -->
                            <div class="bg-gray-50 dark:bg-gray-800/50 rounded-2xl p-6">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Stock disponible</h3>
                                <div class="grid grid-cols-3 gap-4">
                                    <div v-for="v in producto.variantes" :key="v.variante_id" :class="[
                                        'p-4 rounded-xl border transition-all duration-200',
                                        v.stock_disponible > 0
                                            ? 'border-green-200 dark:border-green-800 bg-green-50/50 dark:bg-green-900/20'
                                            : 'border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-800/50',
                                        'hover:shadow-md',
                                        selectedVariant?.variante_id === v.variante_id
                                            ? 'ring-2 ring-blue-500 ring-opacity-50'
                                            : ''
                                    ]" @click="selectedVariant = v">
                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between">
                                                <span class="font-semibold text-gray-900 dark:text-white">{{ v.talla }}</span>
                                                <span class="text-sm text-gray-500 dark:text-gray-400">{{ v.color_nombre }}</span>
                                            </div>
                                            <div class="flex items-center justify-between">
                                                <span class="text-sm text-gray-600 dark:text-gray-400">Disponible:</span>
                                                <span :class="[
                                                    'px-2 py-1 rounded-full text-xs font-medium',
                                                    v.stock_disponible > 0
                                                        ? 'bg-green-100 dark:bg-green-900/50 text-green-800 dark:text-green-300'
                                                        : 'bg-red-100 dark:bg-red-900/50 text-red-800 dark:text-red-300'
                                                ]">
                                                    {{ v.stock_disponible }} unidades
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Cantidad y acciones desktop -->
                        <div class="space-y-6 pt-6 border-t border-gray-200 dark:border-gray-800">
                            <!-- Selector de cantidad -->
                            <div class="flex items-center gap-6">
                                <span class="text-lg font-semibold text-gray-900 dark:text-white">Cantidad:</span>
                                <div class="flex items-center gap-3">
                                    <button @click="decrementQuantity" :disabled="quantity <= 1"
                                        class="w-10 h-10 flex items-center justify-center rounded-lg border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                        <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                                        </svg>
                                    </button>
                                    <span class="w-16 text-center text-2xl font-bold text-gray-900 dark:text-white">{{ quantity }}</span>
                                    <button @click="incrementQuantity" 
                                            :disabled="selectedVariant && quantity >= selectedVariant.stock_disponible"
                                            class="w-10 h-10 flex items-center justify-center rounded-lg border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                        <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                        </svg>
                                    </button>
                                </div>
                            </div>

                            <!-- Botones de acción desktop -->
                            <div class="flex gap-4">
                               <button @click="handleFavoriteToggle" 
        :class="[
            'flex items-center justify-center gap-2 px-6 py-4 rounded-xl border-2 transition-colors',
            favoritesStore.isFavorite(producto.producto_id)
                ? 'border-red-500 bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-300'
                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-700 dark:text-gray-300'
        ]">
    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path v-if="favoritesStore.isFavorite(producto.producto_id)"
              stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        <path v-else
              stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
    </svg>
    {{ favoritesStore.isFavorite(producto.producto_id) ? 'En favoritos' : 'Favorito' }}
</button>
                                <button @click="addToCart" 
                                        :disabled="!producto || Number(producto.stock_total) === 0 || (selectedVariant && selectedVariant.stock_disponible === 0)"
                                        class="flex-1 flex items-center justify-center gap-2 px-6 py-4 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-medium disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                    </svg>
                                    {{ Number(producto.stock_total) > 0 ? 'Agregar al carrito' : 'Agotado' }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MOBILE LAYOUT -->
                <div class="md:hidden">
                    <!-- Imagen móvil -->
                    <div class="relative">
                        <div class="aspect-square overflow-hidden bg-gray-100 dark:bg-gray-800">
                            <img v-if="selectedImage" :src="selectedImage" class="w-full h-full object-cover" />
                        </div>

                        <!-- Indicador móvil -->
                        <div v-if="producto?.imagenes?.length > 1" class="absolute top-4 right-4">
                            <span class="px-2 py-1 text-xs font-bold bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm rounded-full">
                                {{ producto.imagenes.findIndex(img => img.url === selectedImage) + 1 }}/{{ producto.imagenes.length }}
                            </span>
                        </div>

                        <!-- Botón galería móvil -->
                        <button v-if="producto?.imagenes?.length > 1"
                            @click="openGallery(producto.imagenes.findIndex(img => img.url === selectedImage))"
                            class="absolute bottom-4 right-4 w-10 h-10 bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg">
                            <svg class="w-5 h-5 text-gray-700 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                            </svg>
                        </button>
                    </div>

                    <!-- Contenido móvil -->
                    <div class="p-4 space-y-6">
                        <!-- Encabezado móvil -->
                        <div class="space-y-3">
                            <div class="flex items-center gap-2">
                                <span class="px-2 py-1 bg-gray-100 dark:bg-gray-800 rounded text-xs text-gray-600 dark:text-gray-400">
                                    {{ producto.marca_nombre }}
                                </span>
                                <span v-if="producto.es_promocion" class="px-2 py-1 bg-red-500 text-white rounded text-xs font-medium">
                                    -{{ producto.porcentaje_descuento }}%
                                </span>
                            </div>

                            <h1 class="text-2xl font-bold text-gray-900 dark:text-white leading-tight">
                                {{ producto.nombre }}
                            </h1>

                            <!-- Rating y stock móvil -->
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="flex items-center">
                                        <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                        </svg>
                                        <span class="ml-1 text-sm font-semibold text-gray-900 dark:text-white">4.8</span>
                                        <span class="ml-1 text-xs text-gray-500 dark:text-gray-400">(128)</span>
                                    </div>
                                </div>
                                <div class="flex items-center gap-2">
                                    <div class="w-2 h-2 rounded-full animate-pulse"
                                        :class="Number(producto.stock_total) > 0 ? 'bg-green-500' : 'bg-red-500'" />
                                    <span class="text-xs text-gray-600 dark:text-gray-400">
                                        {{ Number(producto.stock_total) > 0 ? 'En stock' : 'Agotado' }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Precio móvil -->
                        <div class="space-y-2">
                            <div class="flex items-baseline gap-3">
                                <span class="text-3xl font-bold text-gray-900 dark:text-white">
                                    S/ {{ producto.precio_final }}
                                </span>
                                <span v-if="producto.precio_promocion"
                                    class="text-lg line-through text-gray-400 dark:text-gray-500">
                                    S/ {{ producto.precio_venta }}
                                </span>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">
                                IVA incluído · Envío gratis en pedidos mayores a S/ 150
                            </p>
                        </div>

                        <!-- Descripción móvil -->
                        <div class="space-y-2">
                            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Descripción</h2>
                            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
                                {{ producto.descripcion }}
                            </p>
                        </div>

                        <!-- Variantes móvil -->
                        <div v-if="producto.variantes?.length" class="space-y-4">
                            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Variantes disponibles</h2>

                            <!-- Tallas móvil -->
                            <div class="space-y-3">
                                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Talla</p>
                                <div class="flex flex-wrap gap-2">
                                    <button v-for="talla in [...new Set(producto.variantes.map(v => v.talla))]" :key="talla"
                                        :class="[
                                            'px-4 py-2 text-sm font-medium rounded-lg border transition-colors',
                                            selectedVariant?.talla === talla
                                                ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300'
                                                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-700 dark:text-gray-300'
                                        ]" @click="selectedVariant = producto.variantes.find(v => v.talla === talla)">
                                        {{ talla }}
                                    </button>
                                </div>
                            </div>

                            <!-- Colores móvil -->
                            <div class="space-y-3">
                                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Color</p>
                                <div class="flex flex-wrap gap-3">
                                    <button v-for="v in producto.variantes" :key="v.variante_id"
                                        @click="selectedVariant = v" :class="[
                                            'relative group',
                                            selectedVariant?.variante_id === v.variante_id ? 'ring-2 ring-blue-500 ring-offset-2' : ''
                                        ]">
                                        <div class="w-12 h-12 rounded-full border-2 transition-all" :class="[
                                            'border-gray-300 dark:border-gray-600',
                                            'group-hover:border-gray-400 dark:group-hover:border-gray-500'
                                        ]" :style="{ backgroundColor: v.color_hex }" />
                                        <span
                                            class="absolute -bottom-4 left-1/2 transform -translate-x-1/2 text-xs text-gray-600 dark:text-gray-400 whitespace-nowrap">
                                            {{ v.color_nombre }}
                                        </span>
                                    </button>
                                </div>
                            </div>

                            <!-- Grid de stock móvil -->
                            <div class="grid grid-cols-2 gap-3 mt-6">
                                <div v-for="v in producto.variantes" :key="v.variante_id" :class="[
                                    'p-3 rounded-lg border transition-colors',
                                    v.stock_disponible > 0
                                        ? 'border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20'
                                        : 'border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800',
                                    'hover:shadow-sm',
                                    selectedVariant?.variante_id === v.variante_id
                                        ? 'ring-2 ring-blue-500 ring-opacity-50'
                                        : ''
                                ]" @click="selectedVariant = v">
                                    <div class="space-y-2">
                                        <div class="flex items-center justify-between">
                                            <span class="text-sm font-medium text-gray-900 dark:text-white">{{ v.talla }}</span>
                                            <span class="text-xs text-gray-500 dark:text-gray-400">{{ v.color_nombre }}</span>
                                        </div>
                                        <div class="flex items-center justify-between">
                                            <span class="text-xs text-gray-600 dark:text-gray-400">Stock:</span>
                                            <span :class="[
                                                'px-2 py-1 rounded-full text-xs font-medium',
                                                v.stock_disponible > 0
                                                    ? 'bg-green-100 dark:bg-green-900/50 text-green-800 dark:text-green-300'
                                                    : 'bg-red-100 dark:bg-red-900/50 text-red-800 dark:text-red-300'
                                            ]">
                                                {{ v.stock_disponible }}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Cantidad móvil -->
                        <div class="space-y-3">
                            <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Cantidad</p>
                            <div class="flex items-center gap-3">
                                <button @click="decrementQuantity" :disabled="quantity <= 1"
                                    class="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                    <svg class="w-4 h-4 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                                    </svg>
                                </button>
                                <span class="w-12 text-center text-lg font-bold text-gray-900 dark:text-white">{{ quantity }}</span>
                                <button @click="incrementQuantity" 
                                        :disabled="selectedVariant && quantity >= selectedVariant.stock_disponible"
                                        class="w-8 h-8 flex items-center justify-center rounded-lg border border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                    <svg class="w-4 h-4 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Botones fijos móvil -->
                    <div class="fixed bottom-0 left-0 right-0 p-4 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 shadow-lg z-40">
                        <button @click="addToCart" 
                                :disabled="!producto || Number(producto.stock_total) === 0"
                                class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                            <div class="flex items-center justify-center gap-2">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                                </svg>
                                {{ Number(producto.stock_total) > 0 ? 'Agregar al carrito' : 'Agotado' }}
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
/* Asegurar que los botones fijos móviles no se solapen */
.pb-20 {
    padding-bottom: 5rem;
}

/* Mejoras visuales desktop */
@media (min-width: 768px) {
    .pb-20 {
        padding-bottom: 0;
    }
}

/* Animaciones para el modal */
@keyframes fadeIn {
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}

@keyframes slideIn {
    from {
        transform: scale(0.95);
        opacity: 0;
    }
    to {
        transform: scale(1);
        opacity: 1;
    }
}

.gallery-modal-overlay {
    animation: fadeIn 0.3s ease-out;
}

.gallery-modal-overlay img {
    animation: slideIn 0.3s ease-out;
}

/* Animación pulse para stock */
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

/* Optimización de imágenes */
img {
    content-visibility: auto;
}
</style>