<script setup lang="ts">
const route = useRoute()
const id = route.params.id

// Cargar producto
const { data, pending, error } = await useFetch(`https://menswear-shop-api.vercel.app/api/v1/products/${id}`)
</script>

<template>
    <UContainer class="py-12">

        <!-- CARGANDO -->
        <div v-if="pending" class="space-y-6">
            <USkeleton class="h-64 w-full rounded-xl" />
            <USkeleton class="h-8 w-3/4" />
            <USkeleton class="h-6 w-full" />
            <USkeleton class="h-6 w-2/3" />
        </div>

        <!-- ERROR -->
        <UAlert v-if="error" color="red" title="Error al cargar el producto"
            description="Hubo un problema al obtener los datos." class="mb-6" icon="i-heroicons-exclamation-circle" />

        <div v-if="data?.data" class="grid grid-cols-1 md:grid-cols-2 gap-10">

            <!-- Imagen -->
            <UCard class="flex items-center justify-center aspect-square bg-gray-100 dark:bg-gray-800">
                <div class="flex flex-col items-center text-gray-500 dark:text-gray-400">
                    <UIcon name="i-heroicons-photo" class="text-6xl mb-2" />
                    <span>Imagen del Producto</span>
                </div>
            </UCard>

            <!-- Información -->
            <div>
                <h1 class="text-4xl font-bold mb-4">
                    {{ data.data.nombre }}
                </h1>

                <p class="text-gray-600 dark:text-gray-300 mb-6 leading-relaxed">
                    {{ data.data.descripcion }}
                </p>

                <!-- Precio -->
                <UBadge color="primary" class="text-2xl px-4 py-2">
                    S/ {{ data.data.precio_final }}
                </UBadge>

                <!-- Variantes -->

                <!-- Variantes -->
                <h2 class="text-lg font-semibold mb-2">Variantes</h2>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
                    <UCard v-for="v in data.data.variantes" :key="v.variante_id" :ui="{ rounded: 'rounded-lg' }"
                        class="hover:shadow-sm transition">
                        <div class="space-y-1">

                            <!-- Talla -->
                            <p class="text-sm font-medium">
                                Talla:
                                <UBadge color="primary" variant="soft">{{ v.talla }}</UBadge>
                            </p>

                            <!-- Color -->
                            <div class="flex items-center gap-2">
                                <div class="w-5 h-5 rounded-full border" :style="{ backgroundColor: v.color_hex }" />
                                <span class="text-xs text-gray-600 dark:text-gray-300">
                                    {{ v.color_nombre }}
                                </span>
                            </div>

                            <!-- Stock -->
                            <p class="text-xs text-gray-600 dark:text-gray-300">
                                Stock:
                                <UBadge :color="v.stock_disponible > 0 ? 'green' : 'red'" variant="subtle">
                                    {{ v.stock_disponible }}
                                </UBadge>
                            </p>
                        </div>
                    </UCard>
                </div>


            </div>

        </div>

        <!-- Productos Relacionados -->
        <div v-if="data?.data?.productos_relacionados?.length" class="mt-16">
            <h2 class="text-2xl font-bold mb-6">Productos Relacionados</h2>

            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">

                <ULink v-for="p in data.data.productos_relacionados" :key="p.producto_id"
                    :to="`/productos/${p.producto_id}`" class="block">
                    <UCard class="hover:shadow-md transition bg-white dark:bg-gray-800">

                        <!-- mini imagen -->
                        <div
                            class="aspect-square rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center mb-3">
                            <UIcon name="i-heroicons-photo" class="text-4xl text-gray-500 dark:text-gray-400" />
                        </div>

                        <p class="font-semibold">{{ p.nombre }}</p>
                        <p class="text-sm text-gray-600 dark:text-gray-300">
                            S/ {{ p.precio_final }}
                        </p>

                    </UCard>
                </ULink>

            </div>
        </div>

    </UContainer>
</template>
