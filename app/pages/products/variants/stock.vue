<template>
    <div class="container mx-auto px-4 py-8">
        <!-- Breadcrumb -->
        <div class="mb-6">
            <UBreadcrumb :items="breadcrumbItems" />
        </div>

        <!-- Encabezado -->
        <UPageHeader>
            <template #title>
                <h1 class="text-3xl font-bold text-gray-900">Gestión de Stock</h1>
            </template>
            <template #description>
                <p class="text-gray-600">
                    Producto: <strong>{{ product?.nombre }}</strong> | SKU: {{ product?.sku }}
                </p>
            </template>
            <template #actions>
                <UButton color="gray" variant="outline" icon="i-heroicons-arrow-left" to="/dashboard/products"
                    class="mr-2">
                    Volver
                </UButton>
                <UButton color="primary" icon="i-heroicons-plus" @click="showStockModal = true">
                    Ajustar Stock
                </UButton>
            </template>
        </UPageHeader>

        <!-- Estadísticas rápidas -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 my-6">
            <UCard>
                <template #header>
                    <h3 class="text-sm font-medium text-gray-500">Stock Total</h3>
                </template>
                <div class="flex items-center justify-between">
                    <p class="text-3xl font-bold text-gray-900">{{ totalStock }}</p>
                    <UIcon name="i-heroicons-cube" class="w-8 h-8 text-blue-500" />
                </div>
            </UCard>

            <UCard>
                <template #header>
                    <h3 class="text-sm font-medium text-gray-500">Variantes</h3>
                </template>
                <div class="flex items-center justify-between">
                    <p class="text-3xl font-bold text-gray-900">{{ variants.length }}</p>
                    <UIcon name="i-heroicons-swatch" class="w-8 h-8 text-green-500" />
                </div>
            </UCard>

            <UCard>
                <template #header>
                    <h3 class="text-sm font-medium text-gray-500">Bajo Stock</h3>
                </template>
                <div class="flex items-center justify-between">
                    <p class="text-3xl font-bold text-gray-900">{{ lowStockCount }}</p>
                    <UIcon name="i-heroicons-exclamation-triangle" class="w-8 h-8 text-orange-500" />
                </div>
            </UCard>

            <UCard>
                <template #header>
                    <h3 class="text-sm font-medium text-gray-500">Agotados</h3>
                </template>
                <div class="flex items-center justify-between">
                    <p class="text-3xl font-bold text-gray-900">{{ outOfStockCount }}</p>
                    <UIcon name="i-heroicons-x-circle" class="w-8 h-8 text-red-500" />
                </div>
            </UCard>
        </div>

        <!-- Filtros y búsqueda -->
        <UCard class="mb-6">
            <template #header>
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <h2 class="text-lg font-semibold text-gray-800">Stock por Variante</h2>
                    <div class="flex items-center gap-3">
                        <UInput v-model="searchQuery" placeholder="Buscar por talla, color..."
                            icon="i-heroicons-magnifying-glass" class="w-full md:w-64" />
                        <USelect v-model="filterStatus" :options="statusOptions" placeholder="Estado" class="w-32" />
                        <USelect v-model="filterWarehouse" :options="warehouseFilterOptions" placeholder="Almacén"
                            class="w-40" />
                    </div>
                </div>
            </template>

            <!-- Tabla de stock -->
            <UTable :rows="filteredVariants" :columns="columns" :loading="loading" :empty-state="{
                icon: 'i-heroicons-cube',
                label: 'No hay variantes disponibles',
                description: 'Crea variantes para gestionar el stock de este producto'
            }" class="w-full">
                <!-- Columna de variante -->
                <template #variante-data="{ row }">
                    <div class="flex items-center gap-3">
                        <div class="w-6 h-6 rounded-full border border-gray-300"
                            :style="{ backgroundColor: row.color_hex || '#cccccc' }" />
                        <div>
                            <p class="font-medium text-gray-900">{{ row.talla }}</p>
                            <p class="text-sm text-gray-500">{{ row.color_nombre }}</p>
                        </div>
                    </div>
                </template>

                <!-- Columna de stock -->
                <template #stock-data="{ row }">
                    <div class="space-y-1">
                        <div class="flex items-center gap-2">
                            <span class="font-medium">{{ row.stock_actual }}</span>
                            <UBadge :color="getStockColor(row.stock_actual, row.stock_minimo)" variant="subtle"
                                size="sm">
                                {{ getStockStatus(row.stock_actual, row.stock_minimo) }}
                            </UBadge>
                        </div>
                        <div class="text-xs text-gray-500">
                            Mín: {{ row.stock_minimo || 0 }}
                        </div>
                    </div>
                </template>

                <!-- Columna de almacenes -->
                <template #almacenes-data="{ row }">
                    <div class="space-y-1">
                        <div v-for="location in row.inventario" :key="location.almacen_id"
                            class="flex items-center justify-between text-sm">
                            <span class="text-gray-600">{{ location.almacen_nombre }}</span>
                            <span class="font-medium">{{ location.cantidad }}</span>
                        </div>
                        <p v-if="!row.inventario?.length" class="text-sm text-gray-400">
                            Sin ubicación
                        </p>
                    </div>
                </template>

                <!-- Columna de acciones -->
                <template #actions-data="{ row }">
                    <div class="flex items-center gap-2">
                        <UButton color="blue" variant="ghost" icon="i-heroicons-pencil" size="sm"
                            @click="editVariant(row)" />
                        <UButton color="green" variant="ghost" icon="i-heroicons-arrow-up-tray" size="sm"
                            @click="adjustStock(row, 'Entrada')" />
                        <UButton color="red" variant="ghost" icon="i-heroicons-arrow-down-tray" size="sm"
                            @click="adjustStock(row, 'Salida')" />
                        <UDropdown :items="moreActions(row)">
                            <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-vertical" size="sm" />
                        </UDropdown>
                    </div>
                </template>
            </UTable>

            <!-- Paginación -->
            <template #footer>
                <div class="flex items-center justify-between">
                    <div class="text-sm text-gray-500">
                        Mostrando {{ filteredVariants.length }} de {{ variants.length }} variantes
                    </div>
                    <UPagination v-if="variants.length > pageSize" v-model="currentPage" :page-count="pageSize"
                        :total="variants.length" />
                </div>
            </template>
        </UCard>

        <!-- Movimientos recientes -->
        <UCard>
            <template #header>
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-800">Movimientos Recientes</h2>
                    <UButton color="gray" variant="ghost" icon="i-heroicons-arrow-path" @click="refreshMovements" />
                </div>
            </template>

            <div v-if="movementsLoading" class="text-center py-8">
                <UIcon name="i-heroicons-arrow-path" class="w-8 h-8 animate-spin text-primary mx-auto" />
                <p class="mt-2 text-gray-600">Cargando movimientos...</p>
            </div>

            <div v-else-if="movements.length === 0" class="text-center py-8">
                <UIcon name="i-heroicons-document-text" class="w-12 h-12 text-gray-400 mx-auto" />
                <p class="mt-4 text-gray-600">No hay movimientos registrados</p>
            </div>

            <div v-else class="space-y-4">
                <div v-for="movement in movements" :key="movement.movimiento_id"
                    class="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                    <div class="flex items-center gap-4">
                        <div class="w-10 h-10 rounded-full flex items-center justify-center"
                            :class="movementClass(movement.tipo_movimiento)">
                            <UIcon :name="movementIcon(movement.tipo_movimiento)" class="w-5 h-5 text-white" />
                        </div>
                        <div>
                            <p class="font-medium text-gray-900">{{ movement.tipo_movimiento }}</p>
                            <p class="text-sm text-gray-600">{{ movement.motivo }}</p>
                            <p class="text-xs text-gray-500">
                                {{ formatDate(movement.created_at) }} • {{ movement.empleado_nombre }}
                            </p>
                        </div>
                    </div>
                    <div class="text-right">
                        <p class="text-lg font-bold" :class="movementTextClass(movement.tipo_movimiento)">
                            {{ movement.tipo_movimiento === 'Entrada' ? '+' : '-' }}{{ movement.cantidad }}
                        </p>
                        <p class="text-sm text-gray-600">
                            {{ movement.variante_talla }} • {{ movement.variante_color }}
                        </p>
                        <p class="text-xs text-gray-500">{{ movement.almacen_nombre }}</p>
                    </div>
                </div>
            </div>
        </UCard>

        <!-- Modal de ajuste de stock -->
        <UModal v-model="showStockModal">
            <UCard>
                <template #header>
                    <div class="flex items-center gap-2">
                        <UIcon name="i-heroicons-arrows-up-down" class="w-6 h-6 text-primary" />
                        <h3 class="text-lg font-semibold text-gray-900">
                            {{ modalTitle }}
                        </h3>
                    </div>
                </template>

                <div class="space-y-4">
                    <!-- Variante seleccionada -->
                    <div v-if="selectedVariant" class="p-4 bg-gray-50 rounded-lg">
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full border border-gray-300"
                                :style="{ backgroundColor: selectedVariant.color_hex || '#cccccc' }" />
                            <div>
                                <p class="font-medium">{{ selectedVariant.talla }} - {{ selectedVariant.color_nombre }}
                                </p>
                                <p class="text-sm text-gray-600">
                                    Stock actual: <span class="font-medium">{{ selectedVariant.stock_actual }}</span>
                                    unidades
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Tipo de ajuste -->
                    <UFormGroup label="Tipo de Ajuste" required>
                        <URadioGroup v-model="stockForm.tipo_movimiento">
                            <URadio value="Entrada" label="Entrada (Agregar stock)" />
                            <URadio value="Salida" label="Salida (Reducir stock)" />
                            <URadio value="Ajuste" label="Ajuste manual (Establecer cantidad exacta)" />
                        </URadioGroup>
                    </UFormGroup>

                    <!-- Cantidad -->
                    <UFormGroup label="Cantidad" required :error="stockErrors.cantidad">
                        <div class="space-y-2">
                            <UInput v-model="stockForm.cantidad" type="number" min="1"
                                placeholder="Cantidad a ajustar" />
                            <div class="flex items-center gap-4 text-sm">
                                <span class="text-gray-600">Stock actual: {{ currentVariantStock }}</span>
                                <span class="text-gray-600">
                                    Nuevo stock: {{ calculateNewStock }}
                                </span>
                            </div>
                        </div>
                    </UFormGroup>

                    <!-- Almacén -->
                    <UFormGroup label="Almacén" required :error="stockErrors.almacen_id">
                        <USelect v-model="stockForm.almacen_id" :options="warehouseOptions"
                            placeholder="Seleccionar almacén" option-attribute="label" value-attribute="value" />
                    </UFormGroup>

                    <!-- Motivo -->
                    <UFormGroup label="Motivo" required :error="stockErrors.motivo">
                        <USelect v-model="stockForm.motivo" :options="reasonOptions" placeholder="Seleccionar motivo"
                            @update:model-value="updateCustomReason" />
                        <UInput v-if="stockForm.motivo === 'Otro'" v-model="stockForm.motivo_custom"
                            placeholder="Especificar motivo..." class="mt-2" />
                    </UFormGroup>

                    <!-- Observaciones -->
                    <UFormGroup label="Observaciones">
                        <UTextarea v-model="stockForm.observaciones" placeholder="Observaciones adicionales..."
                            :rows="3" />
                    </UFormGroup>
                </div>

                <template #footer>
                    <div class="flex justify-end gap-3">
                        <UButton color="gray" variant="ghost" @click="closeStockModal">
                            Cancelar
                        </UButton>
                        <UButton color="primary" :loading="stockLoading" @click="saveStockAdjustment">
                            Confirmar Ajuste
                        </UButton>
                    </div>
                </template>
            </UCard>
        </UModal>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from '#imports'

const route = useRoute()
const router = useRouter()
const toast = useToast()

// Breadcrumb items
const breadcrumbItems = [
    { label: 'Dashboard', to: '/dashboard' },
    { label: 'Productos', to: '/dashboard/products' },
    { label: 'Editar', to: `/dashboard/products/edit/${route.params.id}` },
    { label: 'Stock' }
]

// Estado reactivo
const product = ref(null)
const variants = ref([])
const movements = ref([])
const warehouses = ref([])
const loading = ref(false)
const movementsLoading = ref(false)
const searchQuery = ref('')
const filterStatus = ref('all')
const filterWarehouse = ref('all')
const currentPage = ref(1)
const pageSize = 10

// Modal de stock
const showStockModal = ref(false)
const selectedVariant = ref(null)
const stockLoading = ref(false)
const stockForm = ref({
    tipo_movimiento: 'Entrada',
    cantidad: 1,
    almacen_id: null,
    motivo: '',
    motivo_custom: '',
    observaciones: ''
})
const stockErrors = ref({})

// Columnas de la tabla
const columns = [
    {
        key: 'variante',
        label: 'Variante'
    },
    {
        key: 'stock',
        label: 'Stock'
    },
    {
        key: 'codigo_barras',
        label: 'Código'
    },
    {
        key: 'almacenes',
        label: 'Ubicaciones'
    },
    {
        key: 'actions',
        label: 'Acciones'
    }
]

// Opciones
const statusOptions = [
    { label: 'Todos', value: 'all' },
    { label: 'Disponible', value: 'available' },
    { label: 'Bajo Stock', value: 'low' },
    { label: 'Agotado', value: 'out' }
]

const reasonOptions = [
    { label: 'Compra', value: 'Compra' },
    { label: 'Devolución', value: 'Devolución' },
    { label: 'Ajuste físico', value: 'Ajuste físico' },
    { label: 'Transferencia', value: 'Transferencia' },
    { label: 'Venta', value: 'Venta' },
    { label: 'Merma', value: 'Merma' },
    { label: 'Dañado', value: 'Dañado' },
    { label: 'Promoción', value: 'Promoción' },
    { label: 'Otro', value: 'Otro' }
]

// Computed
const totalStock = computed(() => {
    return variants.value.reduce((sum, variant) => sum + variant.stock_actual, 0)
})

const lowStockCount = computed(() => {
    return variants.value.filter(variant =>
        variant.stock_actual > 0 &&
        variant.stock_actual <= (variant.stock_minimo || 5)
    ).length
})

const outOfStockCount = computed(() => {
    return variants.value.filter(variant => variant.stock_actual === 0).length
})

const filteredVariants = computed(() => {
    let filtered = variants.value

    // Filtrar por búsqueda
    if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(variant =>
            variant.talla.toLowerCase().includes(query) ||
            variant.color_nombre.toLowerCase().includes(query) ||
            variant.codigo_barras.toLowerCase().includes(query)
        )
    }

    // Filtrar por estado
    if (filterStatus.value !== 'all') {
        filtered = filtered.filter(variant => {
            switch (filterStatus.value) {
                case 'available':
                    return variant.stock_actual > (variant.stock_minimo || 5)
                case 'low':
                    return variant.stock_actual > 0 && variant.stock_actual <= (variant.stock_minimo || 5)
                case 'out':
                    return variant.stock_actual === 0
                default:
                    return true
            }
        })
    }

    // Filtrar por almacén
    if (filterWarehouse.value !== 'all' && filterWarehouse.value) {
        filtered = filtered.filter(variant =>
            variant.inventario?.some(inv => inv.almacen_id === parseInt(filterWarehouse.value))
        )
    }

    return filtered
})

const warehouseOptions = computed(() => {
    return warehouses.value.map(warehouse => ({
        label: `${warehouse.nombre} (${warehouse.sucursal_nombre})`,
        value: warehouse.almacen_id
    }))
})

const warehouseFilterOptions = computed(() => {
    const options = [{ label: 'Todos los almacenes', value: 'all' }]
    warehouses.value.forEach(warehouse => {
        options.push({
            label: `${warehouse.nombre} (${warehouse.sucursal_nombre})`,
            value: warehouse.almacen_id
        })
    })
    return options
})

const currentVariantStock = computed(() => {
    return selectedVariant.value?.stock_actual || 0
})

const calculateNewStock = computed(() => {
    if (!selectedVariant.value || !stockForm.value.cantidad) return currentVariantStock.value

    const cantidad = parseInt(stockForm.value.cantidad)
    switch (stockForm.value.tipo_movimiento) {
        case 'Entrada':
            return currentVariantStock.value + cantidad
        case 'Salida':
            return Math.max(0, currentVariantStock.value - cantidad)
        case 'Ajuste':
            return cantidad
        default:
            return currentVariantStock.value
    }
})

const modalTitle = computed(() => {
    if (!selectedVariant.value) return 'Ajustar Stock'
    return `Ajustar Stock - ${selectedVariant.value.talla} ${selectedVariant.value.color_nombre}`
})

// Métodos
const fetchProduct = async () => {
    try {
        loading.value = true
        const { data } = await useFetch(`/api/products/${route.params.id}`, {
            baseURL: useRuntimeConfig().public.apiBase,
            params: { include_variants: true, include_inventory: true }
        })

        if (data.value?.data) {
            product.value = data.value.data
            variants.value = product.value.variantes || []
        }
    } catch (err) {
        toast.add({
            title: 'Error',
            description: 'No se pudo cargar la información del producto',
            color: 'red'
        })
    } finally {
        loading.value = false
    }
}

const fetchWarehouses = async () => {
    try {
        const { data } = await useFetch('/api/warehouses', {
            baseURL: useRuntimeConfig().public.apiBase
        })

        if (data.value?.data) {
            warehouses.value = data.value.data
        }
    } catch (err) {
        console.error('Error fetching warehouses:', err)
    }
}

const fetchMovements = async () => {
    try {
        movementsLoading.value = true
        const { data } = await useFetch(`/api/products/${route.params.id}/movements`, {
            baseURL: useRuntimeConfig().public.apiBase,
            params: { limit: 10 }
        })

        if (data.value?.data) {
            movements.value = data.value.data
        }
    } catch (err) {
        console.error('Error fetching movements:', err)
    } finally {
        movementsLoading.value = false
    }
}

const getStockColor = (stock, minStock) => {
    minStock = minStock || 5
    if (stock === 0) return 'red'
    if (stock <= minStock) return 'orange'
    return 'green'
}

const getStockStatus = (stock, minStock) => {
    minStock = minStock || 5
    if (stock === 0) return 'Agotado'
    if (stock <= minStock) return 'Bajo Stock'
    return 'Disponible'
}

const editVariant = (variant) => {
    router.push(`/dashboard/products/${route.params.id}/variants/edit/${variant.variante_id}`)
}

const adjustStock = (variant, type = 'Entrada') => {
    selectedVariant.value = variant
    stockForm.value = {
        tipo_movimiento: type,
        cantidad: 1,
        almacen_id: null,
        motivo: '',
        motivo_custom: '',
        observaciones: ''
    }
    stockErrors.value = {}
    showStockModal.value = true
}

const moreActions = (variant) => {
    return [
        [{
            label: 'Ver detalles',
            icon: 'i-heroicons-eye',
            click: () => viewVariantDetails(variant)
        }],
        [{
            label: 'Transferir stock',
            icon: 'i-heroicons-arrow-right-left',
            click: () => transferStock(variant)
        }],
        [{
            label: 'Eliminar variante',
            icon: 'i-heroicons-trash',
            click: () => deleteVariant(variant)
        }]
    ]
}

const viewVariantDetails = (variant) => {
    console.log('View variant details:', variant)
    // Implementar vista de detalles
}

const transferStock = (variant) => {
    console.log('Transfer stock:', variant)
    // Implementar transferencia
}

const deleteVariant = async (variant) => {
    const confirmed = await confirm(`¿Eliminar variante ${variant.talla} - ${variant.color_nombre}?`)
    if (confirmed) {
        try {
            await useFetch(`/api/products/variants/${variant.variante_id}`, {
                method: 'DELETE',
                baseURL: useRuntimeConfig().public.apiBase
            })

            toast.add({
                title: 'Éxito',
                description: 'Variante eliminada correctamente',
                color: 'green'
            })

            fetchProduct() // Refrescar datos
        } catch (err) {
            toast.add({
                title: 'Error',
                description: 'No se pudo eliminar la variante',
                color: 'red'
            })
        }
    }
}

const refreshMovements = () => {
    fetchMovements()
}

const movementClass = (type) => {
    switch (type) {
        case 'Entrada':
            return 'bg-green-500'
        case 'Salida':
            return 'bg-red-500'
        default:
            return 'bg-blue-500'
    }
}

const movementIcon = (type) => {
    switch (type) {
        case 'Entrada':
            return 'i-heroicons-arrow-up-tray'
        case 'Salida':
            return 'i-heroicons-arrow-down-tray'
        default:
            return 'i-heroicons-arrows-up-down'
    }
}

const movementTextClass = (type) => {
    switch (type) {
        case 'Entrada':
            return 'text-green-600'
        case 'Salida':
            return 'text-red-600'
        default:
            return 'text-blue-600'
    }
}

const formatDate = (dateString) => {
    if (!dateString) return ''
    return new Date(dateString).toLocaleDateString('es-MX', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
}

const validateStockForm = () => {
    stockErrors.value = {}

    if (!stockForm.value.cantidad || stockForm.value.cantidad < 1) {
        stockErrors.value.cantidad = 'La cantidad debe ser mayor a 0'
    }

    if (stockForm.value.tipo_movimiento === 'Salida' &&
        stockForm.value.cantidad > currentVariantStock.value) {
        stockErrors.value.cantidad = `No hay suficiente stock (disponible: ${currentVariantStock.value})`
    }

    if (!stockForm.value.almacen_id) {
        stockErrors.value.almacen_id = 'Seleccione un almacén'
    }

    if (!stockForm.value.motivo) {
        stockErrors.value.motivo = 'Seleccione un motivo'
    }

    if (stockForm.value.motivo === 'Otro' && !stockForm.value.motivo_custom) {
        stockErrors.value.motivo = 'Especifique el motivo'
    }

    return Object.keys(stockErrors.value).length === 0
}

const saveStockAdjustment = async () => {
    if (!validateStockForm()) {
        return
    }

    try {
        stockLoading.value = true

        const motivo = stockForm.value.motivo === 'Otro'
            ? stockForm.value.motivo_custom
            : stockForm.value.motivo

        const movementData = {
            variante_id: selectedVariant.value.variante_id,
            tipo_movimiento: stockForm.value.tipo_movimiento,
            cantidad: parseInt(stockForm.value.cantidad),
            almacen_id: parseInt(stockForm.value.almacen_id),
            motivo,
            observaciones: stockForm.value.observaciones
        }

        await useFetch('/api/inventory/movements', {
            method: 'POST',
            body: movementData,
            baseURL: useRuntimeConfig().public.apiBase
        })

        toast.add({
            title: 'Éxito',
            description: 'Stock actualizado correctamente',
            color: 'green'
        })

        closeStockModal()
        fetchProduct()
        fetchMovements()
    } catch (err) {
        toast.add({
            title: 'Error',
            description: 'No se pudo actualizar el stock',
            color: 'red'
        })
    } finally {
        stockLoading.value = false
    }
}

const updateCustomReason = (value) => {
    if (value !== 'Otro') {
        stockForm.value.motivo_custom = ''
    }
}

const closeStockModal = () => {
    showStockModal.value = false
    selectedVariant.value = null
    stockForm.value = {
        tipo_movimiento: 'Entrada',
        cantidad: 1,
        almacen_id: null,
        motivo: '',
        motivo_custom: '',
        observaciones: ''
    }
    stockErrors.value = {}
}

// Ciclo de vida
onMounted(() => {
    fetchProduct()
    fetchWarehouses()
    fetchMovements()
})
</script>

<style scoped>
.animate-fadeIn {
    animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>