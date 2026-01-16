<script setup lang="ts">
import type CatalogoProductosVue from '~/components/CatalogoProductos.vue';
import ZapatillasBanner from '~/components/UI/ZapatillasBanner.vue';
const config = useRuntimeConfig()
const products = ref([])
const { data } = await useFetch(`${config.public.apiBaseUrl}/products/catalog`)

</script>


<template>
  

<ZapatillasBanner/>
  
  <UContainer class="">

      <!-- COMPONENTE DEL CATÁLOGO -->
    <CatalogoProductos :productos="data?.data" />

  </UContainer>
</template>
