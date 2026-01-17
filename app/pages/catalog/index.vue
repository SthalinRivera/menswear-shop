<script setup lang="ts">
import CatalogoProductos from '~/components/catalog/CatalogoProductos.vue'
import FiltrosProductos from '~/components/catalog/FiltrosProductos.vue'


const config = useRuntimeConfig()
const { data } = await useFetch(`${config.public.apiBaseUrl}/products/catalog`)

// Estado para productos filtrados
const productos = ref(data.value?.data || [])
const productosFiltrados = ref(productos.value)

// Función para manejar cambio de filtros
const handleFilterChange = (filteredProducts: any[]) => {
  productosFiltrados.value = filteredProducts
}
</script>

<template>
  <UContainer>
    <!-- Banner opcional -->
    <ZapatillasBanner />
    
    <div class="mt-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
        Catálogo de Zapatillas
      </h1>
      <p class="text-gray-600 dark:text-gray-400 mb-8">
        Encuentra las mejores zapatillas deportivas y casual
      </p>
      
      <div class="flex flex-col lg:flex-row gap-6">
        <!-- Columna de filtros (izquierda) -->
        <div class="lg:w-1/4">
          <FiltrosProductos 
            :productos="productos"
            @update:filtered="handleFilterChange"
          />
        </div>
        
        <!-- Columna de productos (derecha) -->
        <div class="lg:w-3/4">
          <div v-if="productosFiltrados.length === 0" class="text-center py-12">
            <UIcon name="i-heroicons-magnifying-glass" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p class="text-gray-600 dark:text-gray-400">No se encontraron productos con los filtros seleccionados.</p>
            <UButton 
              @click="productosFiltrados = productos" 
              color="primary" 
              variant="outline" 
              class="mt-4"
            >
              Mostrar todos los productos
            </UButton>
          </div>
          
          <CatalogoProductos 
            v-else
            :productos="productosFiltrados" 
          />
        </div>
      </div>
    </div>
  </UContainer>
</template>