<template>
  <div class="min-h-screen flex flex-col bg-white dark:bg-gray-900">
    <UHeader>
      <!-- Izquierda -->
      <template #left>
        <NuxtLink to="/">
          <!-- Logo modo claro -->
          <img
            src="/logo-light.png"
            alt="Logo Tienda"
            class="w-28 h-auto block dark:hidden"
          />
          <!-- Logo modo oscuro -->
          <img
            src="/logo-dark.png"
            alt="Logo Tienda"
            class="w-28 h-auto hidden dark:block"
          />
        </NuxtLink>
      </template>

      <!-- Menú central -->
      <UNavigationMenu :items="items" variant="link" />

      <!-- Derecha -->
      <template #right>
        <UColorModeButton />
        
        <!-- Botón de favoritos -->
        <UButton 
          icon="i-lucide-heart" 
          color="neutral" 
          variant="ghost" 
          :to="favoritesLink" 
          class="relative"
          :ui="{ rounded: 'rounded-full' }"
        >
          <span 
            v-if="favoritesStore.totalItems > 0" 
            class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-bold"
          >
            {{ favoritesStore.totalItems }}
          </span>
        </UButton>
        
        <!-- Botón del carrito -->
        <UButton 
          icon="i-lucide-shopping-cart" 
          color="neutral" 
          variant="ghost" 
          @click="openCart" 
          class="relative"
          :ui="{ rounded: 'rounded-full' }"
        >
          <span 
            v-if="cartStore.totalItems > 0" 
            class="absolute -top-1 -right-1 bg-primary-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-bold"
          >
            {{ cartStore.totalItems }}
          </span>
        </UButton>
        
        <!-- Botón móvil (solo icono) -->
        <UButton icon="i-lucide-log-in" color="neutral" variant="ghost" to="/login" class="lg:hidden" />

        <!-- Botón Iniciar sesión con icono -->
        <UButton label="Sign in" color="neutral" variant="outline" to="/login" leading-icon="i-lucide-log-in"
          class="hidden lg:inline-flex" />

        <!-- Botón Registrarse con icono -->
        <UButton label="Sign up" color="primary" to="/signup" leading-icon="i-lucide-user-plus"
          trailing-icon="i-lucide-arrow-right" class="hidden lg:inline-flex" />
      </template>

      <!-- Menú móvil -->
      <template #body>
        <UNavigationMenu :items="mobileMenuItems" orientation="vertical" class="-mx-2.5" />

        <USeparator class="my-6" />

        <UButton label="Sign in" color="neutral" variant="subtle" to="/login" leading-icon="i-lucide-log-in" block
          class="mb-3" />

        <UButton label="Sign up" color="primary" to="/signup" leading-icon="i-lucide-user-plus" block />
      </template>
    </UHeader>

    <main class="items-center justify-center py-4">
      <slot />
    </main>

    <!-- Componente del carrito -->
    <CartDrawer />
    
    <footer class="bg-gray-100 dark:bg-gray-900 text-gray-500 dark:text-gray-400 text-center py-6">
      © 2025 Tu Tienda de Ropa. Todos los derechos reservados.
    </footer>
  </div>
</template>

<script setup>
import { useCartStore } from '~/stores/cart'
import { useFavoritesStore } from '~/stores/favorites'

const cartStore = useCartStore()
const favoritesStore = useFavoritesStore()
const colorMode = useColorMode()

// Computed para el enlace de favoritos
const favoritesLink = computed(() => {
  return favoritesStore.totalItems > 0 ? '/catalog/favorites' : '#'
})

// Función para abrir el carrito
const openCart = () => {
  cartStore.initialize() // Cargar datos antes de abrir
  cartStore.openCart()
}

// Menú de navegación
const items = [

  {
    label: 'Catálogo',
    to: '/catalog',
    icon: 'i-lucide-layout-grid'
   },
  // {
  //   label: 'Categorias',
  //   to: '/catalog/categories',
  //   icon: 'i-lucide-flame'
  // }
]

// Menú móvil (incluye el badge de favoritos)
const mobileMenuItems = computed(() => {
  return items.map(item => ({
    ...item,
    label: item.badge 
      ? `${item.label} (${item.badge})`
      : item.label
  }))
})

// Inicializar stores al montar
onMounted(() => {
  cartStore.initialize()
  favoritesStore.initialize()
})
</script>