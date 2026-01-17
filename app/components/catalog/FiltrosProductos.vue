<script setup lang="ts">
import type { Producto } from '~/types/product'

interface Props {
  productos: Producto[]
  onFilterChange?: (filteredProducts: Producto[]) => void
}

const props = withDefaults(defineProps<Props>(), {
  onFilterChange: () => {}
})

const emit = defineEmits<{
  'update:filtered': [Producto[]]
}>()

// Estados para los filtros
const searchQuery = ref('')
const selectedBrands = ref<string[]>([])
const selectedCategories = ref<string[]>([])
const priceRange = ref<[number, number]>([0, 1000])
const selectedSizes = ref<string[]>([])
const minRating = ref(0)
const inStockOnly = ref(false)
const onSaleOnly = ref(false)

// Función para generar rating (MOVER AL INICIO)
const getRandomRating = (id: number) => {
  const ratings = [4.6, 4.8, 4.4, 4.9, 4.8]
  return ratings[id % ratings.length] || 4.5
}

// Extraer opciones únicas de los productos
const brands = computed(() => {
  const uniqueBrands = [...new Set(props.productos.map(p => p.marca_nombre))]
  return uniqueBrands.sort()
})

const categories = computed(() => {
  const uniqueCats = [...new Set(props.productos.map(p => p.categoria_nombre))]
  return uniqueCats.sort()
})

const sizes = computed(() => {
  const allSizes = ['35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45']
  return allSizes
})

// Calcular precios máximo y mínimo
const priceStats = computed(() => {
  if (props.productos.length === 0) return { min: 0, max: 1000 }
  
  const prices = props.productos.map(p => 
    p.es_promocion && p.precio_promocion 
      ? Number(p.precio_promocion)
      : Number(p.precio_final)
  )
  
  return {
    min: Math.floor(Math.min(...prices)),
    max: Math.ceil(Math.max(...prices))
  }
})

// Inicializar rango de precios
watch(priceStats, (stats) => {
  priceRange.value = [stats.min, stats.max]
}, { immediate: true })

// Función para filtrar productos
const filteredProducts = computed(() => {
  return props.productos.filter(product => {
    // Búsqueda por texto
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      const matchesSearch = 
        product.nombre.toLowerCase().includes(query) ||
        product.marca_nombre.toLowerCase().includes(query) ||
        product.categoria_nombre.toLowerCase().includes(query)
      
      if (!matchesSearch) return false
    }
    
    // Filtro por marca
    if (selectedBrands.value.length > 0 && 
        !selectedBrands.value.includes(product.marca_nombre)) {
      return false
    }
    
    // Filtro por categoría
    if (selectedCategories.value.length > 0 && 
        !selectedCategories.value.includes(product.categoria_nombre)) {
      return false
    }
    
    // Filtro por precio
    const productPrice = product.es_promocion && product.precio_promocion
      ? Number(product.precio_promocion)
      : Number(product.precio_final)
    
    if (productPrice < priceRange.value[0] || productPrice > priceRange.value[1]) {
      return false
    }
    
    // Filtro por stock
    if (inStockOnly.value && Number(product.stock_total) <= 0) {
      return false
    }
    
    // Filtro por promoción
    if (onSaleOnly.value && !product.es_promocion) {
      return false
    }
    
    // Filtro por rating (simulado)
    const productRating = getRandomRating(product.producto_id)
    if (minRating.value > 0 && productRating < minRating.value) {
      return false
    }
    
    return true
  })
})

// Emitir cambios de filtro
watch(filteredProducts, (products) => {
  emit('update:filtered', products)
  props.onFilterChange(products)
}, { deep: true })

// Función para resetear filtros
const resetFilters = () => {
  searchQuery.value = ''
  selectedBrands.value = []
  selectedCategories.value = []
  priceRange.value = [priceStats.value.min, priceStats.value.max]
  selectedSizes.value = []
  minRating.value = 0
  inStockOnly.value = false
  onSaleOnly.value = false
}

// Contador de productos filtrados
const filteredCount = computed(() => filteredProducts.value.length)
</script>

<template>
  <!-- El template se mantiene igual -->
  <div class="sticky top-4 space-y-6 p-4 bg-white dark:bg-gray-800 rounded-xl shadow-sm">
    <!-- Título y contador -->
    <div class="flex items-center justify-between border-b pb-4">
      <h2 class="text-lg font-bold text-gray-900 dark:text-white">Filtros</h2>
      <div class="text-sm text-gray-500 dark:text-gray-400">
        {{ filteredCount }} productos
      </div>
    </div>

    <!-- Barra de búsqueda -->
    <div class="space-y-2">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Buscar producto</label>
      <div class="relative">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar por nombre, marca..."
          class="w-full px-4 py-2 pl-10 bg-gray-50 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        >
        <svg class="absolute left-3 top-2.5 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
    </div>

    <!-- Filtro por marca -->
    <div class="space-y-3">
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Marca</h3>
      <div class="space-y-2 max-h-40 overflow-y-auto pr-2">
        <label v-for="brand in brands" :key="brand" class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700 p-1 rounded">
          <input
            type="checkbox"
            :value="brand"
            v-model="selectedBrands"
            class="rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          >
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ brand }}</span>
        </label>
      </div>
    </div>

    <!-- Filtro por categoría -->
    <div class="space-y-3">
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Categoría</h3>
      <div class="space-y-2 max-h-40 overflow-y-auto pr-2">
        <label v-for="category in categories" :key="category" class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700 p-1 rounded">
          <input
            type="checkbox"
            :value="category"
            v-model="selectedCategories"
            class="rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          >
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ category }}</span>
        </label>
      </div>
    </div>

    <!-- Filtro por precio -->
    <div class="space-y-4">
      <div class="flex justify-between">
        <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Precio</h3>
        <span class="text-sm text-blue-600 dark:text-blue-400 font-medium">
          S/ {{ priceRange[0] }} - S/ {{ priceRange[1] }}
        </span>
      </div>
      
      <div class="px-1">
        <input
          v-model="priceRange"
          type="range"
          :min="priceStats.min"
          :max="priceStats.max"
          step="10"
          class="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-blue-500"
        />
        
        <div class="flex justify-between mt-2 text-xs text-gray-500 dark:text-gray-400">
          <span>S/ {{ priceStats.min }}</span>
          <span>S/ {{ priceStats.max }}</span>
        </div>
      </div>
    </div>

    <!-- Filtro por rating -->
    <div class="space-y-3">
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Rating mínimo</h3>
      <div class="flex items-center gap-3">
        <button
          v-for="rating in [0, 4, 4.5]"
          :key="rating"
          @click="minRating = rating"
          :class="[
            'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
            minRating === rating
              ? 'bg-blue-500 text-white'
              : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
          ]"
        >
          {{ rating === 0 ? 'Todos' : `${rating}+` }}
        </button>
      </div>
    </div>

    <!-- Filtros rápidos -->
    <div class="space-y-3">
      <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Otros filtros</h3>
      <div class="space-y-2">
        <label class="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            v-model="inStockOnly"
            class="rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          >
          <span class="text-sm text-gray-700 dark:text-gray-300">Solo disponibles</span>
        </label>
        
        <label class="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            v-model="onSaleOnly"
            class="rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500"
          >
          <span class="text-sm text-gray-700 dark:text-gray-300">Solo ofertas</span>
        </label>
      </div>
    </div>

    <!-- Botón resetear filtros -->
    <button
      @click="resetFilters"
      class="w-full py-2.5 text-sm font-semibold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg hover:bg-blue-100 dark:hover:bg-blue-900/30 transition-colors"
    >
      Limpiar filtros
    </button>

    <!-- Vista rápida de filtros activos -->
    <div v-if="selectedBrands.length > 0 || selectedCategories.length > 0 || minRating > 0 || inStockOnly || onSaleOnly" 
         class="pt-4 border-t border-gray-200 dark:border-gray-700">
      <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-2">Filtros activos</h4>
      <div class="flex flex-wrap gap-2">
        <span
          v-for="brand in selectedBrands"
          :key="`brand-${brand}`"
          class="inline-flex items-center gap-1 px-2 py-1 text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full"
        >
          {{ brand }}
          <button @click="selectedBrands = selectedBrands.filter(b => b !== brand)" class="hover:text-red-500">
            ×
          </button>
        </span>
        
        <span
          v-if="minRating > 0"
          class="inline-flex items-center gap-1 px-2 py-1 text-xs bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-full"
        >
          Rating {{ minRating }}+
          <button @click="minRating = 0" class="hover:text-red-500">
            ×
          </button>
        </span>
        
        <span
          v-if="inStockOnly"
          class="inline-flex items-center gap-1 px-2 py-1 text-xs bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-full"
        >
          Disponible
          <button @click="inStockOnly = false" class="hover:text-red-500">
            ×
          </button>
        </span>
        
        <span
          v-if="onSaleOnly"
          class="inline-flex items-center gap-1 px-2 py-1 text-xs bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-full"
        >
          En oferta
          <button @click="onSaleOnly = false" class="hover:text-red-500">
            ×
          </button>
        </span>
      </div>
    </div>
  </div>
</template>


<style scoped>
/* Personalización de la barra de rango */
input[type="range"]::-webkit-slider-thumb {
  appearance: none;
  height: 16px;
  width: 16px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

input[type="range"]::-moz-range-thumb {
  height: 16px;
  width: 16px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Scrollbar personalizado */
::-webkit-scrollbar {
  width: 4px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}

.dark ::-webkit-scrollbar-track {
  background: #374151;
}

.dark ::-webkit-scrollbar-thumb {
  background: #4b5563;
}

.dark ::-webkit-scrollbar-thumb:hover {
  background: #6b7280;
}
</style>