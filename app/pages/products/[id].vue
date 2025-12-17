<script setup lang="ts">
import type { Product } from '~/types/product'

const route = useRoute()
const toast = useToast()
const { getProductById } = useProducts()
const colorMode = useColorMode()

const productId = computed(() => parseInt(route.params.id as string))

// Usa useAsyncData para manejar la carga de datos
const { data: product, pending, error, refresh } = useAsyncData(
    `product-${productId.value}`,
    async () => {
        if (!productId.value) return null

        // getProductById devuelve un objeto con data.value, no los datos directamente
        const response = await getProductById(productId.value)

        // Verifica si hay error
        if (response.error.value) {
            console.error('Error al obtener producto:', response.error.value)
            return null
        }

        // La API responde con { success: true, data: { producto } }
        console.log('Respuesta completa:', response.data.value)

        // Accede a los datos dentro de data.data
        return response.data.value?.data || null
    },
    {
        watch: [productId] // Se ejecuta de nuevo cuando cambia el productId
    }
)

// Log para debug
watch(product, (newProduct) => {
    console.log('Producto actualizado:', newProduct)
})

definePageMeta({
    layout: 'dashboard',
    middleware: ['guest']
})

// Estado para pestañas
const activeTab = ref('details')

// Funciones
function copyToClipboard(text: string, message: string) {
    navigator.clipboard.writeText(text)
    toast.add({
        title: message,
        icon: 'i-lucide-check',
        color: 'green'
    })
}

// Calcular margen de ganancia
const profitMargin = computed(() => {
    if (!product.value) return 0
    const costo = parseFloat(product.value.precio_compra)
    const venta = parseFloat(product.value.precio_venta)
    return venta > 0 ? ((venta - costo) / venta * 100).toFixed(1) : 0
})

// Función para alternar modo claro/oscuro
const toggleDarkMode = () => {
    colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
}
</script>

<template>
    <UDashboardPanel :ui="{
        base: 'min-h-screen transition-colors duration-200',
        body: 'p-4 sm:p-6'
    }">
        <template #header>
            <UDashboardNavbar :ui="{
                base: 'transition-colors duration-200',
                background: 'bg-white dark:bg-gray-900',
                border: 'border-b border-gray-200 dark:border-gray-800'
            }">
                <template #leading>
                    <div class="flex items-center gap-3">
                        <UDashboardSidebarCollapse class="text-gray-700 dark:text-gray-300" />
                        <UButton icon="i-lucide-arrow-left" color="neutral" variant="ghost" :ui="{
                            base: 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                        }" @click="$router.back()" />
                    </div>
                </template>

                <template #title>
                    <div class="flex items-center gap-3">
                        <div v-if="pending" class="animate-pulse h-8 w-48 bg-gray-200 dark:bg-gray-700 rounded" />
                        <template v-else>
                            <h1 class="text-lg font-semibold text-gray-900 dark:text-white">
                                {{ product?.nombre }}
                            </h1>
                            <UBadge variant="subtle" color="neutral" class="font-mono text-xs" :ui="{
                                background: 'bg-gray-100 dark:bg-gray-800',
                                color: 'text-gray-700 dark:text-gray-300'
                            }">
                                {{ product?.sku }}
                            </UBadge>
                        </template>
                    </div>
                </template>

                <template #right>
                    <div class="flex items-center gap-2">
                        <UButton icon="i-lucide-sun-moon" color="neutral" variant="ghost" :ui="{
                            base: 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                        }" @click="toggleDarkMode" />
                        <UButton icon="i-lucide-edit" label="Editar" color="primary" variant="solid" />
                        <UButton icon="i-lucide-printer" label="Imprimir" color="neutral" variant="outline" :ui="{
                            base: 'border-gray-300 dark:border-gray-700 text-gray-700 dark:text-gray-300'
                        }" />
                        <UDropdownMenu :items="[
                            {
                                label: 'Copiar SKU',
                                icon: 'i-lucide-copy',
                                onClick: () => copyToClipboard(product?.sku || '', 'SKU copiado')
                            },
                            {
                                label: 'Copiar código de barras',
                                icon: 'i-lucide-barcode',
                                onClick: () => copyToClipboard(product?.sku || '', 'Código copiado')
                            },
                            { type: 'separator' },
                            { label: 'Ver historial de precios', icon: 'i-lucide-history' },
                            { label: 'Ver movimientos de inventario', icon: 'i-lucide-warehouse' },
                            { type: 'separator' },
                            { label: 'Exportar datos', icon: 'i-lucide-download' },
                            {
                                label: 'Desactivar producto',
                                icon: 'i-lucide-toggle-left',
                                color: 'error'
                            }
                        ]">
                            <UButton icon="i-lucide-more-vertical" color="neutral" variant="ghost" :ui="{
                                base: 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                            }" />
                        </UDropdownMenu>
                    </div>
                </template>
            </UDashboardNavbar>
        </template>

        <template #body>
            <!-- Loading State -->
            <div v-if="pending" class="space-y-4">
                <div class="animate-pulse h-64 bg-gray-200 dark:bg-gray-700 rounded-lg" />
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div v-for="i in 6" :key="i" class="h-24 bg-gray-200 dark:bg-gray-700 rounded-lg" />
                </div>
            </div>

            <!-- Error State -->
            <div v-else-if="error" class="text-center py-12">
                <i class="i-lucide-alert-circle text-4xl text-red-500 dark:text-red-400 mx-auto mb-4" />
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                    Error al cargar el producto
                </h3>
                <p class="text-gray-600 dark:text-gray-400 mb-6">{{ error.message }}</p>
                <UButton label="Intentar nuevamente" icon="i-lucide-refresh-cw" @click="refresh" />
            </div>

            <!-- Success State -->
            <div v-else-if="product" class="space-y-6">
                <!-- Encabezado -->
                <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                    <div class="flex flex-col md:flex-row gap-6">
                        <!-- Imagen -->
                        <div class="w-48 h-48 bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center">
                            <i class="i-lucide-image text-gray-400 dark:text-gray-600 text-4xl" />
                        </div>

                        <!-- Información principal -->
                        <div class="flex-1">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                                        {{ product.nombre }}
                                    </h2>
                                    <p class="text-gray-600 dark:text-gray-400 mt-2">
                                        {{ product.descripcion }}
                                    </p>
                                </div>

                                <div class="text-right">
                                    <div class="text-3xl font-bold text-primary-600 dark:text-primary-400">
                                        ${{ parseFloat(product.precio_final).toFixed(2) }}
                                    </div>
                                    <div v-if="product.es_promocion" class="flex items-center gap-2 mt-1">
                                        <span class="text-sm line-through text-gray-500 dark:text-gray-500">
                                            ${{ parseFloat(product.precio_venta).toFixed(2) }}
                                        </span>
                                        <UBadge variant="solid" color="green">
                                            -{{ product.porcentaje_descuento }}%
                                        </UBadge>
                                    </div>
                                </div>
                            </div>

                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Categoría</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.categoria_nombre }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Marca</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.marca_nombre }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Género</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.genero }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Temporada</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.temporada }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pestañas -->
                <UTabs v-model="activeTab" :items="[
                    { label: 'Detalles', value: 'details' },
                    { label: 'Variantes', value: 'variants' },
                    { label: 'Inventario', value: 'inventory' },
                    { label: 'Movimientos', value: 'movements' },
                    { label: 'Ventas', value: 'sales' },
                    { label: 'Reseñas', value: 'reviews' }
                ]" :ui="{
            wrapper: 'border-b border-gray-200 dark:border-gray-800',
            list: {
                base: 'flex space-x-8',
                background: 'bg-transparent',
                marker: {
                    wrapper: 'relative',
                    base: 'absolute inset-x-0 bottom-0 h-0.5',
                    background: 'bg-primary-500 dark:bg-primary-400',
                    rounded: ''
                }
            },
            tab: {
                base: 'py-3 px-1 font-medium text-sm',
                active: 'text-primary-600 dark:text-primary-400',
                inactive: 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
            }
        }" />

                <!-- Contenido de pestañas -->
                <div v-if="activeTab === 'details'" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Información del producto -->
                    <div class="lg:col-span-2 space-y-6">
                        <div
                            class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                Información del Producto
                            </h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Material Principal</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.material_principal || 'No especificado' }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Instrucciones de Cuidado</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ product.cuidados || 'No especificado' }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Creado el</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ new Date(product.fecha_creacion).toLocaleDateString() }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Última actualización</p>
                                    <p class="font-medium text-gray-900 dark:text-white">
                                        {{ new Date(product.fecha_actualizacion).toLocaleDateString() }}
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Precios y costos -->
                        <div
                            class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                Precios y Costos
                            </h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Precio Compra</p>
                                    <p class="text-lg font-bold text-gray-900 dark:text-white">
                                        ${{ parseFloat(product.precio_compra).toFixed(2) }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Precio Venta</p>
                                    <p class="text-lg font-bold text-gray-900 dark:text-white">
                                        ${{ parseFloat(product.precio_venta).toFixed(2) }}
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Impuesto</p>
                                    <p class="text-lg font-bold text-gray-900 dark:text-white">
                                        {{ product.impuesto_porcentaje }}%
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Margen de Ganancia</p>
                                    <p class="text-lg font-bold text-green-600 dark:text-green-500">
                                        {{ profitMargin }}%
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Estadísticas -->
                    <div class="space-y-6">
                        <div
                            class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                Estadísticas
                            </h3>
                            <div class="space-y-4">
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Stock Total</p>
                                    <div class="flex items-center gap-2 mt-1">
                                        <div class="text-2xl font-bold text-gray-900 dark:text-white">
                                            {{ product.stock_total || 0 }}
                                        </div>
                                        <UBadge
                                            :color="parseInt(product.stock_total || 0) <= product.stock_minimo ? 'red' : 'green'"
                                            variant="subtle" :ui="{
                                                background: parseInt(product.stock_total || 0) <= product.stock_minimo
                                                    ? 'bg-red-100 dark:bg-red-900/30'
                                                    : 'bg-green-100 dark:bg-green-900/30',
                                                color: parseInt(product.stock_total || 0) <= product.stock_minimo
                                                    ? 'text-red-800 dark:text-red-300'
                                                    : 'text-green-800 dark:text-green-300'
                                            }">
                                            {{ parseInt(product.stock_total || 0) <= product.stock_minimo ? 'Bajo'
                                                : 'Normal' }} </UBadge>
                                    </div>
                                </div>

                                <div class="pt-4 border-t border-gray-200 dark:border-gray-800">
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Límites de Stock</p>
                                    <div class="mt-2">
                                        <div class="flex justify-between text-sm mb-1">
                                            <span class="text-gray-700 dark:text-gray-300">Mínimo: {{
                                                product.stock_minimo }}</span>
                                            <span class="text-gray-700 dark:text-gray-300">Máximo: {{
                                                product.stock_maximo }}</span>
                                        </div>
                                        <UProgress
                                            :value="((parseInt(product.stock_total || 0) / product.stock_maximo) * 100) || 0"
                                            :color="parseInt(product.stock_total || 0) <= product.stock_minimo ? 'red' : 'green'"
                                            size="sm" :ui="{
                                                background: 'bg-gray-200 dark:bg-gray-700',
                                                rounded: 'rounded-full'
                                            }" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Estado del producto -->
                        <div
                            class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                Estado
                            </h3>
                            <div class="space-y-3">
                                <div class="flex justify-between items-center">
                                    <span class="text-sm text-gray-700 dark:text-gray-300">Producto Activo</span>
                                    <UToggle v-model="product.activo" :ui="{
                                        background: 'bg-gray-200 dark:bg-gray-700',
                                        ring: 'ring-gray-300 dark:ring-gray-600',
                                        checked: {
                                            background: 'bg-primary-500 dark:bg-primary-400'
                                        }
                                    }" />
                                </div>
                                <div v-if="product.es_promocion"
                                    class="pt-3 border-t border-gray-200 dark:border-gray-800">
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Promoción Activa</p>
                                    <div class="mt-2 space-y-1">
                                        <p class="text-xs text-gray-600 dark:text-gray-400">
                                            Desde: {{ new Date(product.fecha_inicio_promocion!).toLocaleDateString() }}
                                        </p>
                                        <p class="text-xs text-gray-600 dark:text-gray-400">
                                            Hasta: {{ new Date(product.fecha_fin_promocion!).toLocaleDateString() }}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pestaña de variantes -->
                <div v-if="activeTab === 'variants'" class="space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Variantes del Producto
                        </h3>
                        <UButton icon="i-lucide-plus" label="Agregar Variante" color="primary" size="sm" />
                    </div>

                    <div v-if="!product.variantes || product.variantes.length === 0" class="text-center py-12">
                        <i class="i-lucide-package-open text-4xl text-gray-400 dark:text-gray-600 mx-auto mb-4" />
                        <p class="text-gray-500 dark:text-gray-400">
                            No hay variantes registradas para este producto.
                        </p>
                        <UButton label="Agregar la primera variante" color="primary" variant="outline" class="mt-4" :ui="{
                            base: 'border-primary-300 dark:border-primary-700 text-primary-600 dark:text-primary-400'
                        }" />
                    </div>

                    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <div v-for="variant in product.variantes" :key="variant.variante_id"
                            class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 hover:border-gray-300 dark:hover:border-gray-700 transition-colors duration-200">
                            <div class="flex justify-between items-start">
                                <div>
                                    <div class="flex items-center gap-2">
                                        <div class="w-4 h-4 rounded border border-gray-300 dark:border-gray-700"
                                            :style="{ backgroundColor: variant.color_hex || '#ccc' }" />
                                        <span class="font-medium text-gray-900 dark:text-white">
                                            {{ variant.color_nombre }}
                                        </span>
                                    </div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                                        Talla: {{ variant.talla }}
                                    </p>
                                </div>
                                <UDropdownMenu :items="[
                                    { label: 'Ajustar stock', icon: 'i-lucide-warehouse' },
                                    { label: 'Editar', icon: 'i-lucide-edit' },
                                    { label: 'Copiar código de barras', icon: 'i-lucide-copy' },
                                    { type: 'separator' },
                                    { label: 'Eliminar', icon: 'i-lucide-trash', color: 'error' }
                                ]">
                                    <UButton icon="i-lucide-more-vertical" color="neutral" variant="ghost" size="sm"
                                        :ui="{
                                            base: 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                                        }" />
                                </UDropdownMenu>
                            </div>

                            <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-800">
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">Stock Actual</p>
                                        <p class="font-bold text-lg text-gray-900 dark:text-white">
                                            {{ variant.stock_actual || 0 }}
                                        </p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">Disponible</p>
                                        <p class="font-bold text-lg text-gray-900 dark:text-white">
                                            {{ variant.stock_disponible || 0 }}
                                        </p>
                                    </div>
                                </div>

                                <div class="mt-3">
                                    <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Código de Barras</p>
                                    <div class="flex items-center gap-2">
                                        <code
                                            class="text-xs bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300 px-2 py-1 rounded">
                      {{ variant.codigo_barras || 'N/A' }}
                    </code>
                                        <UButton icon="i-lucide-copy" size="xs" variant="ghost" :ui="{
                                            base: 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                                        }" @click="copyToClipboard(variant.codigo_barras || '', 'Código copiado')" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pestaña de inventario -->
                <div v-if="activeTab === 'inventory'" class="space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Inventario por Almacén
                        </h3>
                        <UButton icon="i-lucide-plus" label="Nuevo Movimiento" color="primary" size="sm" />
                    </div>

                    <div
                        class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
                        <UTable :columns="[
                            { key: 'almacen', label: 'Almacén' },
                            { key: 'variante', label: 'Variante' },
                            { key: 'ubicacion', label: 'Ubicación' },
                            { key: 'cantidad', label: 'Cantidad' },
                            { key: 'ultimo_movimiento', label: 'Último Movimiento' },
                            { key: 'acciones', label: '' }
                        ]" :rows="[]" :empty-state="{
                icon: 'i-lucide-warehouse',
                label: 'No hay inventario registrado',
                description: 'Registra el primer movimiento de inventario'
            }" :ui="{
                wrapper: 'overflow-x-auto',
                base: 'min-w-full divide-y divide-gray-200 dark:divide-gray-800',
                thead: 'bg-gray-50 dark:bg-gray-800',
                tbody: 'divide-y divide-gray-200 dark:divide-gray-800',
                tr: {
                    base: '',
                    selected: 'bg-gray-50 dark:bg-gray-800/50',
                    active: 'hover:bg-gray-50 dark:hover:bg-gray-800/50'
                },
                th: {
                    base: 'px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider',
                    padding: 'px-6 py-3'
                },
                td: {
                    base: 'px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-300',
                    padding: 'px-6 py-4'
                }
            }" />
                    </div>
                </div>

                <!-- Pestaña de movimientos -->
                <div v-if="activeTab === 'movements'" class="space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Historial de Movimientos
                        </h3>
                        <div class="flex items-center gap-2">
                            <UInput icon="i-lucide-search" placeholder="Buscar movimientos..." size="sm" :ui="{
                                base: 'w-full sm:w-64',
                                icon: {
                                    trailing: {
                                        pointer: ''
                                    }
                                },
                                variant: {
                                    outline: 'bg-white dark:bg-gray-900 border-gray-300 dark:border-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-primary-500 dark:focus:ring-primary-400 focus:border-primary-500 dark:focus:border-primary-400'
                                }
                            }" />
                            <USelect :options="['Todos', 'Entradas', 'Salidas', 'Ajustes']" placeholder="Filtrar"
                                size="sm" class="w-32" :ui="{
                                    base: 'w-full',
                                    variant: {
                                        outline: 'bg-white dark:bg-gray-900 border-gray-300 dark:border-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-primary-500 dark:focus:ring-primary-400 focus:border-primary-500 dark:focus:border-primary-400'
                                    }
                                }" />
                        </div>
                    </div>

                    <div
                        class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
                        <UTable :columns="[
                            { key: 'fecha', label: 'Fecha' },
                            { key: 'tipo', label: 'Tipo' },
                            { key: 'cantidad', label: 'Cantidad' },
                            { key: 'almacen', label: 'Almacén' },
                            { key: 'empleado', label: 'Responsable' },
                            { key: 'motivo', label: 'Motivo' }
                        ]" :rows="[]" :empty-state="{
                icon: 'i-lucide-history',
                label: 'No hay movimientos registrados',
                description: 'Los movimientos de inventario aparecerán aquí'
            }" :ui="{
                wrapper: 'overflow-x-auto',
                base: 'min-w-full divide-y divide-gray-200 dark:divide-gray-800',
                thead: 'bg-gray-50 dark:bg-gray-800',
                tbody: 'divide-y divide-gray-200 dark:divide-gray-800',
                tr: {
                    base: '',
                    selected: 'bg-gray-50 dark:bg-gray-800/50',
                    active: 'hover:bg-gray-50 dark:hover:bg-gray-800/50'
                },
                th: {
                    base: 'px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider',
                    padding: 'px-6 py-3'
                },
                td: {
                    base: 'px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-300',
                    padding: 'px-6 py-4'
                }
            }" />
                    </div>
                </div>

                <!-- Pestaña de ventas -->
                <div v-if="activeTab === 'sales'" class="space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Historial de Ventas
                        </h3>
                        <div class="flex items-center gap-2">
                            <UInput icon="i-lucide-search" placeholder="Buscar ventas..." size="sm" :ui="{
                                base: 'w-full sm:w-64',
                                icon: {
                                    trailing: {
                                        pointer: ''
                                    }
                                },
                                variant: {
                                    outline: 'bg-white dark:bg-gray-900 border-gray-300 dark:border-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-primary-500 dark:focus:ring-primary-400 focus:border-primary-500 dark:focus:border-primary-400'
                                }
                            }" />
                            <USelect :options="['Últimos 7 días', 'Último mes', 'Último trimestre', 'Este año']"
                                placeholder="Periodo" size="sm" class="w-40" :ui="{
                                    base: 'w-full',
                                    variant: {
                                        outline: 'bg-white dark:bg-gray-900 border-gray-300 dark:border-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:ring-primary-500 dark:focus:ring-primary-400 focus:border-primary-500 dark:focus:border-primary-400'
                                    }
                                }" />
                        </div>
                    </div>

                    <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
                                <p class="text-sm text-gray-500 dark:text-gray-400">Ventas Totales</p>
                                <p class="text-2xl font-bold text-gray-900 dark:text-white">0</p>
                            </div>
                            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
                                <p class="text-sm text-gray-500 dark:text-gray-400">Ingresos Totales</p>
                                <p class="text-2xl font-bold text-green-600 dark:text-green-500">$0.00</p>
                            </div>
                            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
                                <p class="text-sm text-gray-500 dark:text-gray-400">Promedio por Venta</p>
                                <p class="text-2xl font-bold text-blue-600 dark:text-blue-500">$0.00</p>
                            </div>
                        </div>

                        <div class="text-center py-12">
                            <i class="i-lucide-shopping-cart text-4xl text-gray-400 dark:text-gray-600 mx-auto mb-4" />
                            <p class="text-gray-500 dark:text-gray-400">
                                No hay datos de ventas disponibles para este producto.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Pestaña de reseñas -->
                <div v-if="activeTab === 'reviews'" class="space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                            Reseñas de Clientes
                        </h3>
                        <div class="flex items-center gap-2">
                            <UButton icon="i-lucide-star" label="Ver todas las reseñas" color="neutral"
                                variant="outline" size="sm" :ui="{
                                    base: 'border-gray-300 dark:border-gray-700 text-gray-700 dark:text-gray-300'
                                }" />
                        </div>
                    </div>

                    <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
                        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
                            <div>
                                <div class="flex items-center gap-2">
                                    <div class="text-3xl font-bold text-gray-900 dark:text-white">0.0</div>
                                    <div class="flex">
                                        <i class="i-lucide-star text-yellow-400" v-for="i in 5" :key="i" />
                                    </div>
                                </div>
                                <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                                    Basado en 0 reseñas
                                </p>
                            </div>
                            <div class="flex items-center gap-4">
                                <div class="text-center">
                                    <p class="text-sm text-gray-500 dark:text-gray-400">5 estrellas</p>
                                    <UProgress value="0" size="sm" class="w-32" />
                                </div>
                                <div class="text-center">
                                    <p class="text-sm text-gray-500 dark:text-gray-400">4 estrellas</p>
                                    <UProgress value="0" size="sm" class="w-32" />
                                </div>
                            </div>
                        </div>

                        <div class="text-center py-12">
                            <i class="i-lucide-message-square text-4xl text-gray-400 dark:text-gray-600 mx-auto mb-4" />
                            <p class="text-gray-500 dark:text-gray-400">
                                Este producto aún no tiene reseñas.
                            </p>
                            <UButton label="Solicitar reseña" color="primary" variant="outline" class="mt-4" :ui="{
                                base: 'border-primary-300 dark:border-primary-700 text-primary-600 dark:text-primary-400'
                            }" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Not Found State -->
            <div v-else class="text-center py-12">
                <i class="i-lucide-package-search text-4xl text-gray-400 dark:text-gray-600 mx-auto mb-4" />
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                    Producto no encontrado
                </h3>
                <p class="text-gray-600 dark:text-gray-400 mb-6">
                    El producto que buscas no existe o ha sido eliminado.
                </p>
                <UButton label="Volver a productos" icon="i-lucide-arrow-left" @click="$router.push('/products')" />
            </div>
        </template>
    </UDashboardPanel>
</template>