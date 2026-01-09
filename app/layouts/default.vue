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
        <UNavigationMenu :items="items" orientation="vertical" class="-mx-2.5" />

        <USeparator class="my-6" />

        <UButton label="Sign in" color="neutral" variant="subtle" to="/login" leading-icon="i-lucide-log-in" block
          class="mb-3" />

        <UButton label="Sign up" color="primary" to="/signup" leading-icon="i-lucide-user-plus" block />
      </template>
    </UHeader>

    <main class=" items-center justify-center px-4 py-10">
      <slot />
    </main>

    <footer class="bg-gray-100 dark:bg-gray-900 text-gray-500 dark:text-gray-400 text-center py-6">
      © 2025 Tu Tienda de Ropa. Todos los derechos reservados.
    </footer>
  </div>
</template>

<script setup>

</script>
