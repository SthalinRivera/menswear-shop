<template>
  <div class="min-h-screen bg-white dark:bg-gray-900">
    <!-- Header Minimalista -->
    <header class="sticky top-0 z-30 bg-white/95 dark:bg-gray-900/95 backdrop-blur-sm border-b border-gray-200 dark:border-gray-800">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <!-- Logo -->
          <NuxtLink to="/" class="flex items-center">
            <span class="text-xl font-bold text-gray-900 dark:text-white">RICEN</span>
            <span class="ml-1 text-xl font-light text-gray-500 dark:text-gray-400">STORE</span>
          </NuxtLink>

          <!-- Navegación Desktop -->
          <nav class="hidden md:flex items-center space-x-8">
            <NuxtLink to="/" class="text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-black dark:hover:text-white transition">
              Inicio
            </NuxtLink>
            <NuxtLink to="/products" class="text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-black dark:hover:text-white transition">
              Productos
            </NuxtLink>
            <NuxtLink to="/categories" class="text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-black dark:hover:text-white transition">
              Categorías
            </NuxtLink>
            <NuxtLink to="/brands" class="text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-black dark:hover:text-white transition">
              Marcas
            </NuxtLink>
          </nav>

          <!-- Acciones -->
          <div class="flex items-center space-x-3">
            <!-- Theme Toggle -->
            <button @click="toggleDark" class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
              <svg v-if="isDark" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
              </svg>
            </button>

            <!-- Carrito -->
            <button @click="openCart" class="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
              <svg class="w-5 h-5 text-gray-700 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
              </svg>
              <span v-if="cartStore.totalItems > 0" 
                    class="absolute -top-1 -right-1 w-5 h-5 bg-black dark:bg-white text-white dark:text-black text-xs rounded-full flex items-center justify-center font-bold">
                {{ cartStore.totalItems }}
              </span>
            </button>

            <!-- Login Button -->
            <NuxtLink to="/login" 
                      class="hidden md:inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-black dark:hover:text-white transition">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              Ingresar
            </NuxtLink>

            <!-- Mobile Menu -->
            <button class="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Contenido Principal -->
    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer Minimalista -->
    <footer class="mt-auto border-t border-gray-200 dark:border-gray-800 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col md:flex-row justify-between items-center">
          <div class="mb-4 md:mb-0">
            <div class="flex items-center">
              <span class="text-xl font-bold text-gray-900 dark:text-white">RICEN</span>
              <span class="ml-1 text-xl font-light text-gray-500 dark:text-gray-400">STORE</span>
            </div>
            <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
              Moda premium para el estilo moderno
            </p>
          </div>
          
          <div class="text-sm text-gray-500 dark:text-gray-400">
            <p>© 2024 RICEN STORE. Todos los derechos reservados.</p>
          </div>
        </div>
      </div>
    </footer>

    <!-- Drawer del Carrito -->
    <CartDrawer />
  </div>
</template>

<script setup>
import { useCartStore } from '~/stores/cart'

const cartStore = useCartStore()
const colorMode = useColorMode()
const isDark = computed(() => colorMode.value === 'dark')

const toggleDark = () => {
  colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
}

// Función para abrir el carrito
const openCart = () => {
  cartStore.initialize() // Cargar datos antes de abrir
  cartStore.openCart()
}

// Inicializar carrito al montar
onMounted(() => {
  cartStore.initialize()
})
</script>

<style scoped>

</style>