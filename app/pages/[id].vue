<script setup lang="ts">
import { ref, watchEffect, computed } from 'vue'

const route = useRoute()
const id = route.params.id
const config = useRuntimeConfig()

// Fetch del producto
const { data, pending, error } = await useFetch(
    `${config.public.apiBaseUrl}/products/${id}`,
    { default: () => ({ data: [] }) }
)

const producto = computed(() => data.value?.data || null)
const selectedImage = ref<string | null>(null)
const selectedVariant = ref<any>(null)
const quantity = ref(1)

// Galería móvil
const showGallery = ref(false)
const galleryIndex = ref(0)

watchEffect(() => {
    const imagenes = producto.value?.imagenes
    if (imagenes?.length) {
        const principal = imagenes.find(i => i.es_principal)
        selectedImage.value = principal?.url || imagenes[0].url
    }
    if (producto.value?.variantes?.length) {
        selectedVariant.value = producto.value.variantes[0]
    }
})

// Funciones galería
const openGallery = (index: number) => {
    galleryIndex.value = index
    showGallery.value = true
}

const nextImage = () => {
    if (!producto.value?.imagenes) return
    galleryIndex.value = (galleryIndex.value + 1) % producto.value.imagenes.length
}

const prevImage = () => {
    if (!producto.value?.imagenes) return
    galleryIndex.value = (galleryIndex.value - 1 + producto.value.imagenes.length) % producto.value.imagenes.length
}

// Agregar al carrito
const addToCart = () => {
    // Lógica para agregar al carrito
    console.log('Agregando al carrito:', {
        producto: producto.value,
        variante: selectedVariant.value,
        cantidad: quantity.value
    })
}
</script>

<template>
    <div class="min-h-screen bg-white dark:bg-gray-900">

        <!-- LOADING -->
        <div v-if="pending" class="p-4 md:p-8">
            <div class="grid md:grid-cols-2 gap-6 md:gap-12">
                <!-- Imagen loading -->
                <div class="space-y-4">
                    <div class="aspect-square rounded-2xl bg-gray-200 dark:bg-gray-800 animate-pulse" />
                    <div class="flex gap-3">
                        <div v-for="i in 4" :key="i"
                            class="w-16 h-16 md:w-20 md:h-20 rounded-lg bg-gray-200 dark:bg-gray-800 animate-pulse" />
                    </div>
                </div>
                <!-- Info loading -->
                <div class="space-y-6">
                    <div class="h-8 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-3/4" />
                    <div class="space-y-2">
                        <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded animate-pulse" />
                        <div class="h-4 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-2/3" />
                    </div>
                    <div class="h-10 bg-gray-200 dark:bg-gray-800 rounded animate-pulse w-1/3" />
                </div>
            </div>
        </div>

        <!-- ERROR -->
        <UAlert v-if="error" color="red" title="Error al cargar el producto" icon="i-heroicons-exclamation-circle"
            class="m-4 md:m-8 rounded-lg" variant="solid" />

        <!-- PRODUCTO -->
        <div v-if="producto" class="pb-20 md:pb-0">
            <!-- Container responsive -->
            <div class="max-w-7xl mx-auto">
                <!-- Desktop Layout -->
                <div class="hidden md:grid md:grid-cols-2 gap-12 p-8">

                    <!-- GALERÍA DESKTOP -->
                    <div class="space-y-6">
                        <!-- Imagen principal -->
                        <div class="aspect-square rounded-3xl overflow-hidden bg-gray-100 dark:bg-gray-800 shadow-xl">
                            <img v-if="selectedImage" :src="selectedImage"
                                class="w-full h-full object-cover transition-transform duration-500 hover:scale-105 cursor-zoom-in"
                                @click="openGallery(producto.imagenes?.findIndex(img => img.url === selectedImage) || 0)" />
                        </div>

                        <!-- Miniaturas desktop -->
                        <div v-if="producto?.imagenes?.length > 1" class="flex gap-4">
                            <button v-for="(img, index) in producto.imagenes" :key="img.url"
                                @click="selectedImage = img.url"
                                :class="['w-20 h-20 rounded-xl overflow-hidden border-2 transition-all duration-300 hover:scale-105',
                                    selectedImage === img.url
                                        ? 'border-primary-500 ring-2 ring-primary-500 ring-opacity-30 shadow-md'
                                        : 'border-gray-300 dark:border-gray-700 hover:border-gray-400 dark:hover:border-gray-600']">
                                <img :src="img.url" class="w-full h-full object-cover" />
                            </button>
                        </div>
                    </div>

                    <!-- INFORMACIÓN DESKTOP -->
                    <div class="space-y-8">
                        <!-- Encabezado -->
                        <div class="space-y-4">
                            <div class="flex items-center gap-3">
                                <UBadge size="sm" color="gray" variant="subtle" class="text-xs">
                                    {{ producto.marca_nombre }}
                                </UBadge>
                                <UBadge v-if="producto.es_promocion" size="sm" color="red" variant="solid">
                                    -{{ producto.porcentaje_descuento }}% OFF
                                </UBadge>
                            </div>

                            <h1 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white leading-tight">
                                {{ producto.nombre }}
                            </h1>

                            <!-- Rating desktop -->
                            <div class="flex items-center gap-6">
                                <div class="flex items-center">
                                    <div class="flex">
                                        <UIcon v-for="i in 5" :key="i" name="i-heroicons-star-solid"
                                            class="w-5 h-5 text-yellow-400" />
                                    </div>
                                    <span class="ml-2 text-lg font-semibold text-gray-900 dark:text-white">4.8</span>
                                    <span class="ml-1 text-gray-500 dark:text-gray-400">(128 reviews)</span>
                                </div>
                                <div class="flex items-center gap-2">
                                    <div class="w-2 h-2 rounded-full animate-pulse bg-green-500" />
                                    <span class="text-gray-600 dark:text-gray-400">
                                        {{ Number(producto.stock_total) > 0 ? 'En stock' : 'Agotado' }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Descripción desktop -->
                        <div class="space-y-3">
                            <h2 class="text-xl font-semibold text-gray-900 dark:text-white">Descripción</h2>
                            <p class="text-gray-600 dark:text-gray-300 text-lg leading-relaxed">
                                {{ producto.descripcion }}
                            </p>
                        </div>

                        <!-- Precio desktop -->
                        <div class="space-y-2">
                            <div class="flex items-baseline gap-4">
                                <span class="text-5xl font-bold text-gray-900 dark:text-white">
                                    S/ {{ producto.precio_final }}
                                </span>
                                <span v-if="producto.precio_promocion"
                                    class="text-2xl line-through text-gray-400 dark:text-gray-500">
                                    S/ {{ producto.precio_venta }}
                                </span>
                            </div>
                            <p class="text-gray-600 dark:text-gray-400">
                                IVA incluído • Envío gratis • Devolución en 30 días
                            </p>
                        </div>

                        <!-- Variantes desktop -->
                        <div v-if="producto.variantes?.length" class="space-y-6">
                            <!-- Tallas -->
                            <div class="space-y-3">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Seleccionar talla</h3>
                                <div class="flex flex-wrap gap-3">
                                    <button v-for="talla in [...new Set(producto.variantes.map(v => v.talla))]"
                                        :key="talla" :class="[
                                            'px-6 py-3 text-base font-medium rounded-xl border-2 transition-all duration-200',
                                            selectedVariant?.talla === talla
                                                ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300'
                                                : 'border-gray-300 dark:border-gray-700 hover:border-gray-400 dark:hover:border-gray-600 text-gray-700 dark:text-gray-300'
                                        ]" @click="selectedVariant = producto.variantes.find(v => v.talla === talla)">
                                        {{ talla }}
                                    </button>
                                </div>
                            </div>

                            <!-- Colores -->
                            <div class="space-y-3">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Seleccionar color</h3>
                                <div class="flex flex-wrap gap-4">
                                    <button v-for="v in producto.variantes" :key="v.variante_id"
                                        @click="selectedVariant = v" :class="[
                                            'relative group',
                                            selectedVariant?.variante_id === v.variante_id
                                                ? 'ring-2 ring-primary-500 ring-offset-2'
                                                : ''
                                        ]">
                                        <div class="w-16 h-16 rounded-full border-4 border-white dark:border-gray-800 shadow-lg"
                                            :style="{ backgroundColor: v.color_hex }" />
                                        <span
                                            class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 text-xs text-gray-600 dark:text-gray-400 whitespace-nowrap">
                                            {{ v.color_nombre }}
                                        </span>
                                    </button>
                                </div>
                            </div>

                            <!-- Stock detallado -->
                            <div class="bg-gray-50 dark:bg-gray-800/50 rounded-2xl p-6">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Stock disponible
                                </h3>
                                <div class="grid grid-cols-3 gap-4">
                                    <div v-for="v in producto.variantes" :key="v.variante_id" :class="[
                                        'p-4 rounded-xl border transition-all duration-200',
                                        v.stock_disponible > 0
                                            ? 'border-green-200 dark:border-green-800 bg-green-50/50 dark:bg-green-900/20'
                                            : 'border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-800/50',
                                        'hover:shadow-md',
                                        selectedVariant?.variante_id === v.variante_id
                                            ? 'ring-2 ring-primary-500 ring-opacity-50'
                                            : ''
                                    ]" @click="selectedVariant = v">
                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between">
                                                <span class="font-semibold text-gray-900 dark:text-white">{{ v.talla
                                                }}</span>
                                                <span class="text-sm text-gray-500 dark:text-gray-400">{{ v.color_nombre
                                                }}</span>
                                            </div>
                                            <div class="flex items-center justify-between">
                                                <span
                                                    class="text-sm text-gray-600 dark:text-gray-400">Disponible:</span>
                                                <UBadge :color="v.stock_disponible > 0 ? 'green' : 'red'" size="sm"
                                                    variant="subtle">
                                                    {{ v.stock_disponible }} unidades
                                                </UBadge>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Cantidad y acciones desktop -->
                        <div class="space-y-6 pt-6 border-t border-gray-200 dark:border-gray-800">
                            <!-- Selector de cantidad -->
                            <div class="flex items-center gap-6">
                                <span class="text-lg font-semibold text-gray-900 dark:text-white">Cantidad:</span>
                                <div class="flex items-center gap-3">
                                    <UButton icon="i-heroicons-minus" size="lg" color="gray" variant="outline"
                                        @click="quantity > 1 ? quantity-- : null" :disabled="quantity <= 1" />
                                    <span class="w-16 text-center text-2xl font-bold text-gray-900 dark:text-white">{{
                                        quantity }}</span>
                                    <UButton icon="i-heroicons-plus" size="lg" color="gray" variant="outline"
                                        @click="quantity++" />
                                </div>
                            </div>

                            <!-- Botones de acción desktop -->
                            <div class="flex gap-4">
                                <UButton size="xl" color="gray" variant="outline" :ui="{ rounded: 'rounded-xl' }"
                                    class="flex-1">
                                    <template #leading>
                                        <UIcon name="i-heroicons-heart" class="w-6 h-6" />
                                    </template>
                                    Favorito
                                </UButton>
                                <UButton size="xl" color="primary" :ui="{ rounded: 'rounded-xl' }" class="flex-1"
                                    @click="addToCart" :disabled="Number(producto.stock_total) === 0">
                                    <template #leading>
                                        <UIcon name="i-heroicons-shopping-cart" class="w-6 h-6" />
                                    </template>
                                    {{ Number(producto.stock_total) > 0 ? 'Agregar al carrito' : 'Agotado' }}
                                </UButton>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MOBILE LAYOUT -->
                <div class="md:hidden">
                    <!-- Imagen móvil -->
                    <div class="relative">
                        <div class="aspect-square overflow-hidden bg-gray-100 dark:bg-gray-800">
                            <img v-if="selectedImage" :src="selectedImage" class="w-full h-full object-cover" />
                        </div>

                        <!-- Indicador móvil -->
                        <div v-if="producto?.imagenes?.length > 1" class="absolute top-4 right-4">
                            <UBadge color="white"
                                class="px-2 py-1 text-xs font-bold bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm">
                                {{producto.imagenes.findIndex(img => img.url === selectedImage) + 1}}/{{
                                    producto.imagenes.length }}
                            </UBadge>
                        </div>

                        <!-- Botón galería móvil -->
                        <button v-if="producto?.imagenes?.length > 1"
                            @click="openGallery(producto.imagenes.findIndex(img => img.url === selectedImage))"
                            class="absolute bottom-4 right-4 w-10 h-10 bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg">
                            <UIcon name="i-heroicons-photo" class="w-5 h-5 text-gray-700 dark:text-gray-300" />
                        </button>
                    </div>

                    <!-- Contenido móvil -->
                    <div class="p-4 space-y-6">
                        <!-- Encabezado móvil -->
                        <div class="space-y-3">
                            <div class="flex items-center gap-2">
                                <UBadge size="sm" color="gray" variant="subtle" class="text-xs">
                                    {{ producto.marca_nombre }}
                                </UBadge>
                                <UBadge size="sm" color="primary" variant="soft" class="text-xs">
                                    {{ producto.categoria_nombre }}
                                </UBadge>
                                <UBadge v-if="producto.es_promocion" size="sm" color="red" variant="solid"
                                    class="text-xs">
                                    -{{ producto.porcentaje_descuento }}%
                                </UBadge>
                            </div>

                            <h1 class="text-2xl font-bold text-gray-900 dark:text-white leading-tight">
                                {{ producto.nombre }}
                            </h1>

                            <!-- Rating y stock móvil -->
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="flex items-center">
                                        <UIcon name="i-heroicons-star-solid" class="w-5 h-5 text-yellow-400" />
                                        <span
                                            class="ml-1 text-sm font-semibold text-gray-900 dark:text-white">4.8</span>
                                        <span class="ml-1 text-xs text-gray-500 dark:text-gray-400">(128)</span>
                                    </div>
                                </div>
                                <div class="flex items-center gap-2">
                                    <div class="w-2 h-2 rounded-full animate-pulse"
                                        :class="Number(producto.stock_total) > 0 ? 'bg-green-500' : 'bg-red-500'" />
                                    <span class="text-xs text-gray-600 dark:text-gray-400">
                                        {{ Number(producto.stock_total) > 0 ? 'En stock' : 'Agotado' }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Precio móvil -->
                        <div class="space-y-2">
                            <div class="flex items-baseline gap-3">
                                <span class="text-3xl font-bold text-gray-900 dark:text-white">
                                    S/ {{ producto.precio_final }}
                                </span>
                                <span v-if="producto.precio_promocion"
                                    class="text-lg line-through text-gray-400 dark:text-gray-500">
                                    S/ {{ producto.precio_venta }}
                                </span>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">
                                IVA incluído · Envío gratis en pedidos mayores a S/ 150
                            </p>
                        </div>

                        <!-- Descripción móvil -->
                        <div class="space-y-2">
                            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Descripción</h2>
                            <p class="text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
                                {{ producto.descripcion }}
                            </p>
                        </div>

                        <!-- Variantes móvil -->
                        <div v-if="producto.variantes?.length" class="space-y-4">
                            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Variantes disponibles</h2>

                            <!-- Tallas móvil -->
                            <div class="space-y-3">
                                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Talla</p>
                                <div class="flex flex-wrap gap-2">
                                    <button v-for="v in [...new Set(producto.variantes.map(v => v.talla))]" :key="v"
                                        :class="[
                                            'px-4 py-2 text-sm font-medium rounded-lg border transition-colors',
                                            selectedVariant?.talla === v
                                                ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300'
                                                : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-700 dark:text-gray-300'
                                        ]" @click="selectedVariant = producto.variantes.find(v => v.talla === v)">
                                        {{ v }}
                                    </button>
                                </div>
                            </div>

                            <!-- Colores móvil -->
                            <div class="space-y-3">
                                <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Color</p>
                                <div class="flex flex-wrap gap-3">
                                    <button v-for="v in producto.variantes" :key="v.variante_id"
                                        @click="selectedVariant = v" :class="[
                                            'relative group',
                                            selectedVariant?.variante_id === v.variante_id ? 'ring-2 ring-primary-500 ring-offset-2' : ''
                                        ]">
                                        <div class="w-12 h-12 rounded-full border-2 transition-all" :class="[
                                            'border-gray-300 dark:border-gray-600',
                                            'group-hover:border-gray-400 dark:group-hover:border-gray-500'
                                        ]" :style="{ backgroundColor: v.color_hex }" />
                                        <span
                                            class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 text-xs text-gray-600 dark:text-gray-400 whitespace-nowrap">
                                            {{ v.color_nombre }}
                                        </span>
                                    </button>
                                </div>
                            </div>

                            <!-- Grid de stock móvil -->
                            <div class="grid grid-cols-2 gap-3">
                                <div v-for="v in producto.variantes" :key="v.variante_id" :class="[
                                    'p-3 rounded-lg border transition-colors',
                                    v.stock_disponible > 0
                                        ? 'border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20'
                                        : 'border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800',
                                    'hover:shadow-sm',
                                    selectedVariant?.variante_id === v.variante_id
                                        ? 'ring-2 ring-primary-500 ring-opacity-50'
                                        : ''
                                ]" @click="selectedVariant = v">
                                    <div class="space-y-2">
                                        <div class="flex items-center justify-between">
                                            <span class="text-sm font-medium text-gray-900 dark:text-white">{{ v.talla
                                            }}</span>
                                            <span class="text-xs text-gray-500 dark:text-gray-400">{{ v.color_nombre
                                            }}</span>
                                        </div>
                                        <div class="flex items-center justify-between">
                                            <span class="text-xs text-gray-600 dark:text-gray-400">Stock:</span>
                                            <UBadge :color="v.stock_disponible > 0 ? 'green' : 'red'" size="xs"
                                                variant="subtle">
                                                {{ v.stock_disponible }}
                                            </UBadge>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Cantidad móvil -->
                        <div class="space-y-3">
                            <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Cantidad</p>
                            <div class="flex items-center gap-3">
                                <UButton icon="i-heroicons-minus" size="sm" color="gray" variant="outline"
                                    @click="quantity > 1 ? quantity-- : null" :disabled="quantity <= 1" />
                                <span class="w-12 text-center text-lg font-bold text-gray-900 dark:text-white">{{
                                    quantity }}</span>
                                <UButton icon="i-heroicons-plus" size="sm" color="gray" variant="outline"
                                    @click="quantity++" />
                            </div>
                        </div>
                    </div>

                    <!-- Botones fijos móvil -->
                    <div
                        class="fixed bottom-0 left-0 right-0 p-4 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 shadow-lg z-50">
                        <div class="flex items-center gap-3">
                            <UButton icon="i-heroicons-heart" size="lg" color="gray" variant="outline"
                                :ui="{ rounded: 'rounded-full', padding: { lg: 'p-3' } }" />
                            <UButton size="lg" color="primary" class="flex-1" :ui="{ rounded: 'rounded-full' }"
                                @click="addToCart" :disabled="Number(producto.stock_total) === 0">
                                <template #leading>
                                    <UIcon name="i-heroicons-shopping-cart" class="w-5 h-5" />
                                </template>
                                {{ Number(producto.stock_total) > 0 ? 'Agregar al carrito' : 'Agotado' }}
                            </UButton>
                        </div>
                    </div>
                </div>
            </div>
        </div>



    </div>
</template>

<style scoped>
/* Asegurar que los botones fijos móviles no se solapen */
.pb-20 {
    padding-bottom: 5rem;
}

/* Mejoras visuales desktop */
@media (min-width: 768px) {
    .pb-20 {
        padding-bottom: 0;
    }
}

/* Animaciones */
@keyframes pulse {

    0%,
    100% {
        opacity: 1;
    }

    50% {
        opacity: 0.5;
    }
}

.animate-pulse {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* Optimización de imágenes */
img {
    content-visibility: auto;
}
</style>