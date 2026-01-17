<script setup lang="ts">

import CatalogoProductos from '~/components/catalog/CatalogoProductos.vue';
import ZapatillasBanner from '~/components/UI/ZapatillasBanner.vue';
const config = useRuntimeConfig()
const products = ref([])
const { data } = await useFetch(`${config.public.apiBaseUrl}/products/catalog`)

</script>


<template>
  <ZapatillasBanner/>

  <UContainer class="mt-10">

    <!-- TÍTULO DEL CATÁLOGO -->
    <div class="text-center mb-8">
      <h1 class="text-3xl md:text-4xl font-bold tracking-tight text-gray-900 dark:text-white">
        🔥 Lo Nuevo en Zapatillas
      </h1>
      <p class="mt-3 text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
        Descubre los últimos modelos en tendencia. Diseño, comodidad y estilo para cada paso que das.
      </p>
    </div>

    <!-- COMPONENTE DEL CATÁLOGO -->
    <CatalogoProductos :productos="data?.data" />

  </UContainer>
</template>