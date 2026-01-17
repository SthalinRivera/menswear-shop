<script setup lang="ts">
interface Producto {
  producto_id: number
  nombre: string
  precio_final: string
  categoria_nombre: string
  marca_nombre: string
  es_promocion: boolean
  porcentaje_descuento: string
  precio_promocion: string | null
  stock_total: string
  imagenes: {
    url: string
    es_principal?: boolean
  }[]
}

const props = defineProps<{
  productos: Producto[]
}>()

const cartStore = useCartStore()
const toast = useToast()

// Función para obtener la imagen principal
const getImage = (p: Producto) => {
  const principal = p.imagenes?.find(i => i.es_principal)
  return principal?.url
    || p.imagenes?.[0]?.url
    || 'https://placehold.co/300x300/e2e8f0/64748b?text=Producto'
}

// Función para generar un rating aleatorio
const getRandomRating = (id: number) => {
  const ratings = [4.6, 4.8, 4.4, 4.9, 4.8]
  return ratings[id % ratings.length] || 4.5
}

// Estado para controlar carga de imágenes
const loadingStates = ref<Record<number, boolean>>({})

// Observador para detectar cuando las imágenes se cargan
const onImageLoad = (id: number) => {
  loadingStates.value[id] = false
}

const onImageError = (id: number) => {
  loadingStates.value[id] = false
}

// Inicializar estados de carga
watch(() => props.productos, (newProductos) => {
  newProductos.forEach(p => {
    loadingStates.value[p.producto_id] = true
  })
}, { immediate: true })



</script>

<template>
  <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-4 xl:grid-cols-5 gap-2">
    <NuxtLink v-for="(p, index) in productos" :key="p.producto_id" :to="`catalog/${p.producto_id}`" :class="[
      'group relative block bg-white dark:bg-gray-800 rounded-xl sm:rounded-2xl overflow-hidden shadow-sm no-underline',
      !loadingStates[p.producto_id] ? 'hover:shadow-lg transition-all duration-300 hover:-translate-y-1' : 'pointer-events-none'
    ]">

      <!-- Badge de descuento -->
      <div v-if="p.es_promocion && !loadingStates[p.producto_id]"
        class="absolute top-2 left-2 z-20 px-2 py-1 sm:px-2.5 sm:py-1 bg-red-500 text-white text-[10px] sm:text-xs font-bold rounded-full shadow-sm">
        -{{ Number(p.porcentaje_descuento) }}%
      </div>

      <!-- Contenedor de imagen con skeleton -->
      <div class="relative aspect-square">
        <!-- Skeleton Loading para la imagen -->

        <div v-if="loadingStates[p.producto_id]"
          class="absolute inset-0 z-10 bg-gray-150 dark:bg-gray-750 rounded-xl sm:rounded-2xl">
          <div class="absolute inset-0 border border-gray-300/30 dark:border-gray-600/30 rounded-xl sm:rounded-2xl">
          </div>
          <div class="absolute inset-0 flex items-center justify-center opacity-20">
            <svg class="w-10 h-10 text-gray-400 dark:text-gray-600" fill="none" stroke="currentColor"
              viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1"
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
        </div>

        <!-- Imagen real -->
        <img :src="getImage(p)" :alt="p.nombre" :class="[
          'absolute inset-0 w-full h-full object-contain p-2 sm:p-3 transition-opacity duration-300',
          loadingStates[p.producto_id] ? 'opacity-0' : 'opacity-100 group-hover:p-1.5'
        ]" @load="onImageLoad(p.producto_id)" @error="onImageError(p.producto_id)" loading="lazy" />
      </div>

      <!-- Contenido -->
      <div class="p-2 sm:p-3 space-y-1.5 sm:space-y-2">
        <!-- Precio y Rating -->
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-1 sm:gap-1.5">
            <svg v-if="!loadingStates[p.producto_id]" class="w-3 h-3 sm:w-4 sm:h-4 text-yellow-500 dark:text-yellow-400"
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
                S/ {{ p.es_promocion && p.precio_promocion ? Number(p.precio_promocion).toFixed(2) :
                  Number(p.precio_final).toFixed(2) }}
              </span>
              <span v-if="p.es_promocion" class="text-[10px] sm:text-xs text-gray-400 dark:text-gray-500 line-through">
                S/ {{ Number(p.precio_final).toFixed(2) }}
              </span>
            </div>
          </div>
        </div>

        <!-- Nombre del producto -->
        <h3
          class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white line-clamp-2 leading-tight min-h-[2rem] sm:min-h-[2.5rem]">
          {{ p.nombre }}
        </h3>

        <!-- Marca y Stock -->
        <div class="flex items-center justify-between pt-1 sm:pt-2 border-t border-gray-100 dark:border-gray-700">
          <span class="text-[10px] sm:text-xs text-gray-500 dark:text-gray-400 font-medium">
            {{ p.marca_nombre }}
          </span>

          <div class="flex items-center gap-1 sm:gap-1.5">
            <div :class="[
              'w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full',
              Number(p.stock_total) > 0 ? 'bg-green-500 animate-pulse' : 'bg-gray-300 dark:bg-gray-600'
            ]" />
            <span class="text-[10px] sm:text-xs text-gray-500 dark:text-gray-400">
              {{ Number(p.stock_total) > 0 ? 'Disponible' : 'Agotado' }}
            </span>
          </div>
        </div>
      </div>
  
  


    <!-- Indicador de producto nuevo -->
    <div v-if="index < 2 && !loadingStates[p.producto_id]"
      class="absolute top-2 right-2 px-1.5 py-0.5 sm:px-2 sm:py-1 bg-blue-500 text-white text-[8px] sm:text-xs font-bold rounded sm:rounded-lg z-20">
      NUEVO
    </div>

    <!-- Efecto hover para desktop - solo cuando la imagen está cargada -->
    <div v-if="!loadingStates[p.producto_id]"
      class="absolute inset-0 rounded-xl sm:rounded-2xl pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-300 hidden sm:block">
      <div class="absolute inset-0 border-2 border-blue-500/20 rounded-xl sm:rounded-2xl" />
      <div
        class="absolute inset-0 bg-gradient-to-br from-blue-500/5 via-transparent to-transparent rounded-xl sm:rounded-2xl" />
    </div>
   </NuxtLink>
  </div> 
</template>

<style scoped>
.line-clamp-2 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}

/* Animación del skeleton */
@keyframes pulse {

  0%,
  100% {
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