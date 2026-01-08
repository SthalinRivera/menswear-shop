<script setup lang="ts">
import type CatalogoProductosVue from '~/components/CatalogoProductos.vue';
const config = useRuntimeConfig()

const { data } = await useFetch(`${config.public.apiBaseUrl}/products`)
</script>





<template>
  <UContainer class="min-h-screen flex flex-col items-center justify-center text-center py-20">

    <!-- TÍTULO -->
    <h1 class="text-4xl font-bold mb-4 text-gray-900 dark:text-white">
      Próximamente: Nuestra Tienda Virtual
    </h1>

    <!-- DESCRIPCIÓN -->
    <p class="text-gray-600 dark:text-gray-300 mb-8 max-w-xl">
      Estamos preparando nuestro catálogo de ropa para que puedas explorar y comprar online.
      Mantente atento a nuestras novedades.
    </p>

    <!-- BOTONES Nuxt UI -->
    <div class="flex gap-4 flex-wrap justify-center mb-12">
      <UButton to="/catalogo" color="primary" variant="solid" size="lg">
        Ver Catálogo
      </UButton>

      <UButton to="/contacto" color="primary" variant="outline" size="lg">
        Contáctanos
      </UButton>
    </div>

    <!-- COMPONENTE DEL CATÁLOGO -->
    <CatalogoProductos :productos="data?.data" />

  </UContainer>
</template>
