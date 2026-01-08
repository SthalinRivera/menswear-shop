<script setup lang="ts">
import { ref, watchEffect, computed } from 'vue'

const route = useRoute()
const id = route.params.id

const config = useRuntimeConfig()

// Fetch del producto
const { data, pending, error } = await useFetch(
    `${config.public.apiBaseUrl}/products/${id}`,
    {
        default: () => ({ data: [] }) // fallback por si no hay datos
    }
)

// Computed para obtener el primer producto del array
const producto = computed(() => data.value?.data || null)


// Imagen seleccionada
const selectedImage = ref<string | null>(null)

watchEffect(() => {
    console.log('Datos fetch:', data.value)
    console.log('Producto:', producto.value)

    const imagenes = producto.value?.imagenes
    if (imagenes?.length) {
        const principal = imagenes.find(i => i.es_principal)
        selectedImage.value = principal?.url || imagenes[0].url
    }
})
</script>

<template>
    <UContainer class="py-12">

        <!-- LOADING -->
        <div v-if="pending" class="grid md:grid-cols-2 gap-10">
            <USkeleton class="aspect-square rounded-2xl shadow animate-pulse" />
            <div class="space-y-4">
                <USkeleton class="h-8 w-3/4 rounded-md animate-pulse" />
                <USkeleton class="h-6 w-full rounded-md animate-pulse" />
                <USkeleton class="h-10 w-1/3 rounded-md animate-pulse" />
            </div>
        </div>

        <!-- ERROR -->
        <UAlert v-if="error" color="red" title="Error al cargar el producto" icon="i-heroicons-exclamation-circle"
            class="mb-6 rounded-xl shadow-md" />

        <!-- PRODUCTO -->
        <div v-if="producto" class="grid grid-cols-1 md:grid-cols-2 gap-12">

            <!-- GALERÍA -->
            <div class="space-y-6">

                <!-- Imagen principal -->
                <div class="aspect-square rounded-2xl overflow-hidden bg-gray-100 dark:bg-gray-800 shadow-lg">
                    <img v-if="selectedImage" :src="selectedImage"
                        class="w-full h-full object-cover transition-transform duration-300 hover:scale-105" />
                </div>

                <!-- Miniaturas -->
                <div v-if="producto?.imagenes?.length > 1" class="flex gap-3">
                    <button v-for="img in producto.imagenes" :key="img.url" @click="selectedImage = img.url" :class="['w-20 h-20 rounded-xl overflow-hidden border transition-all duration-200',
                        selectedImage === img.url
                            ? 'border-primary ring-2 ring-primary'
                            : 'border-gray-300 dark:border-gray-700']">
                        <img :src="img.url" class="w-full h-full object-cover" />
                    </button>
                </div>

            </div>

            <!-- INFORMACIÓN -->
            <div class="space-y-8 flex flex-col justify-between">

                <div class="space-y-4">
                    <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 dark:text-white leading-tight">
                        {{ producto.nombre }}
                    </h1>
                    <p class="text-gray-600 dark:text-gray-300 text-lg">
                        {{ producto.descripcion }}
                    </p>
                </div>

                <!-- Precio -->
                <div class="flex items-center gap-4">
                    <UBadge color="primary" size="xl" class="text-2xl font-bold px-6 py-3 rounded-lg shadow-md">
                        S/ {{ producto.precio_final }}
                    </UBadge>
                    <span v-if="producto.precio_promocion" class="line-through text-gray-400 dark:text-gray-500">
                        S/ {{ producto.precio_venta }}
                    </span>
                </div>

                <!-- Variantes -->
                <div v-if="producto.variantes?.length" class="space-y-3">
                    <h2 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-3">Variantes disponibles</h2>

                    <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                        <UCard v-for="v in producto.variantes" :key="v.variante_id"
                            class="hover:shadow-lg transition-all duration-200 rounded-xl p-4 border border-gray-200 dark:border-gray-700">
                            <div class="space-y-3">
                                <p class="text-sm font-medium">
                                    Talla: <UBadge variant="soft">{{ v.talla }}</UBadge>
                                </p>

                                <div class="flex items-center gap-2">
                                    <span class="w-5 h-5 rounded-full border border-gray-300 dark:border-gray-600"
                                        :style="{ backgroundColor: v.color_hex }" />
                                    <span class="text-xs">{{ v.color_nombre }}</span>
                                </div>

                                <p class="text-xs font-medium">
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
        </div>

        <!-- FALLBACK -->
        <div v-else class="text-center py-20 text-gray-500 dark:text-gray-400">
            Cargando producto...
        </div>

    </UContainer>
</template>
