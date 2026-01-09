<template>



    <UDashboardPanel id="create-product">
        <template #header>
            <UDashboardNavbar title="Nuevo Producto">
                <template #leading>
                    <UDashboardSidebarCollapse />
                </template>

                <template #right>
                    <UButton label="Cancelar" color="neutral" variant="ghost" to="/products" />
                    <UButton label="Guardar producto" color="primary" @click="saveVariant" />
                </template>
            </UDashboardNavbar>
        </template>
        <template #body>
            <!-- Breadcrumb -->
            <div class="mb-6">
                <UBreadcrumb :items="breadcrumbItems" />
            </div>

            <!-- Encabezado -->
            <UPageHeader>
                <template #title>
                    <h1 class="text-3xl font-bold text-gray-900">Crear Variante</h1>
                </template>
                <template #description>
                    <p class="text-gray-600">
                        Agregar nueva variante para: <strong>{{ product?.nombre }}</strong>
                    </p>
                </template>
                <template #actions>
                    <UButton color="gray" variant="outline" @click="cancel" class="mr-2">
                        Cancelar
                    </UButton>
                    <UButton color="primary" :disabled="loading || !isFormValid" :loading="loading"
                        @click="saveVariant">
                        Crear Variante
                    </UButton>
                </template>
            </UPageHeader>

            <!-- Alertas -->
            <UAlert v-if="error" title="Error" :description="error" color="red" variant="subtle"
                icon="i-heroicons-exclamation-triangle" class="my-6" />
            <UAlert v-if="success" title="Éxito" description="Variante creada exitosamente" color="green"
                variant="subtle" icon="i-heroicons-check-circle" class="my-6" />

            <!-- Loading state -->
            <div v-if="loadingProduct" class="text-center py-12">
                <UIcon name="i-heroicons-arrow-path" class="w-12 h-12 animate-spin text-primary mx-auto" />
                <p class="mt-4 text-gray-600">Cargando información del producto...</p>
            </div>

            <!-- Contenido principal -->
            <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-6">
                <!-- Formulario de variante -->
                <div class="space-y-6">
                    <UCard>
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800">Información de la Variante</h2>
                        </template>

                        <div class="space-y-4">
                            <!-- Talla -->
                            <UFormGroup label="Talla" required :error="errors.talla">
                                <div class="space-y-2">
                                    <UInput v-model="form.talla" placeholder="Ej: S, M, L, XL, 30x32, 38, etc."
                                        :ui="{ icon: { trailing: { pointer: '' } } }">
                                        <template #trailing>
                                            <UIcon name="i-heroicons-tag" class="w-4 h-4 text-gray-400" />
                                        </template>
                                    </UInput>
                                    <p class="text-xs text-gray-500">
                                        Para productos sin talla, usa "Única", "Unica" o "Único"
                                    </p>
                                </div>
                            </UFormGroup>

                            <!-- Color -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Nombre del Color" required :error="errors.color_nombre">
                                    <UInput v-model="form.color_nombre"
                                        placeholder="Ej: Rojo, Azul Marino, Negro, Blanco..."
                                        :ui="{ icon: { trailing: { pointer: '' } } }">
                                        <template #trailing>
                                            <UIcon name="i-heroicons-paint-brush" class="w-4 h-4 text-gray-400" />
                                        </template>
                                    </UInput>
                                </UFormGroup>

                                <UFormGroup label="Código HEX del Color">
                                    <div class="flex items-center gap-2">
                                        <UInput v-model="form.color_hex" placeholder="#000000"
                                            :ui="{ icon: { trailing: { pointer: '' } } }">
                                            <template #trailing>
                                                <div class="w-4 h-4 rounded-full border border-gray-300"
                                                    :style="{ backgroundColor: form.color_hex || '#ffffff' }" />
                                            </template>
                                        </UInput>
                                        <UColorPicker v-model="form.color_hex" class="shrink-0" />
                                    </div>
                                    <p class="text-xs text-gray-500 mt-1">
                                        Código hexadecimal (opcional)
                                    </p>
                                </UFormGroup>
                            </div>

                            <!-- Código de barras -->
                            <UFormGroup label="Código de Barras" required :error="errors.codigo_barras">
                                <div class="space-y-2">
                                    <UInput v-model="form.codigo_barras" placeholder="Ej: 8801234560011"
                                        :ui="{ icon: { trailing: { pointer: '' } } }">
                                        <template #trailing>
                                            <UIcon name="i-heroicons-qr-code" class="w-4 h-4 text-gray-400" />
                                        </template>
                                    </UInput>
                                    <div class="flex items-center justify-between">
                                        <p class="text-xs text-gray-500">
                                            Código EAN-13 o UPC recomendado
                                        </p>
                                        <UButton size="xs" color="gray" variant="ghost"
                                            icon="i-heroicons-arrows-up-down" @click="generateBarcode">
                                            Generar
                                        </UButton>
                                    </div>
                                </div>
                            </UFormGroup>

                            <!-- Stock inicial -->
                            <UFormGroup label="Stock Inicial" required :error="errors.stock_actual">
                                <div class="space-y-2">
                                    <div class="flex items-center gap-2">
                                        <UInput v-model="form.stock_actual" type="number" min="0"
                                            :ui="{ icon: { trailing: { pointer: '' } } }">
                                            <template #trailing>
                                                <UIcon name="i-heroicons-cube" class="w-4 h-4 text-gray-400" />
                                            </template>
                                        </UInput>
                                        <span class="text-gray-600">unidades</span>
                                    </div>
                                    <p class="text-xs text-gray-500">
                                        Stock disponible al momento de crear la variante
                                    </p>
                                </div>
                            </UFormGroup>



                            <!-- Almacén destino -->
                            <UFormGroup label="Almacén Destino" required :error="errors.almacen_id">
                                <div class="space-y-2">
                                    <select v-model="form.almacen_id" class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm
           focus:border-primary-500 focus:ring-2 focus:ring-primary-500
           disabled:bg-gray-100 disabled:cursor-not-allowed">
                                        <option disabled value="">
                                            Seleccionar almacén
                                        </option>

                                        <option v-for="option in warehouseOptions" :key="option.value"
                                            :value="option.value">
                                            {{ option.label }}
                                        </option>
                                    </select>
                                    <p class="text-xs text-gray-500">
                                        Almacén donde se registrará el stock inicial
                                    </p>
                                </div>
                            </UFormGroup>



                            <!-- Estado -->
                            <UFormGroup label="Estado">
                                <URadioGroup v-model="form.activo">
                                    <URadio :value="true" label="Activa" />
                                    <URadio :value="false" label="Inactiva" />
                                </URadioGroup>
                            </UFormGroup>
                        </div>
                    </UCard>

                    <!-- Resumen del producto -->
                    <UCard>
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800">Producto Base</h2>
                        </template>

                        <div class="space-y-4">
                            <div class="flex items-start gap-4">
                                <div class="w-20 h-20 flex-shrink-0">
                                    <img v-if="product?.imagen_url" :src="product.imagen_url" :alt="product.nombre"
                                        class="w-full h-full object-cover rounded-lg" />
                                    <div v-else
                                        class="w-full h-full bg-gray-100 rounded-lg flex items-center justify-center">
                                        <UIcon name="i-heroicons-photo" class="w-8 h-8 text-gray-400" />
                                    </div>
                                </div>
                                <div class="flex-1">
                                    <h3 class="font-medium text-gray-900">{{ product?.nombre }}</h3>
                                    <p class="text-sm text-gray-600 mt-1">{{ product?.descripcion?.substring(0, 100)
                                    }}...
                                    </p>
                                    <div class="flex items-center gap-4 mt-2">
                                        <span class="text-sm text-gray-500">SKU: {{ product?.sku }}</span>
                                        <span class="text-sm text-gray-500">Precio: ${{ product?.precio_venta }}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Variantes existentes -->
                            <div class="border-t pt-4">
                                <h4 class="font-medium text-gray-700 mb-3">Variantes Existentes</h4>
                                <div class="space-y-2 max-h-48 overflow-y-auto">
                                    <div v-for="variant in existingVariants" :key="variant.variante_id"
                                        class="flex items-center justify-between p-2 border border-gray-200 rounded">
                                        <div class="flex items-center gap-2">
                                            <span class="font-medium">{{ variant.talla }}</span>
                                            <div class="w-3 h-3 rounded-full border border-gray-300"
                                                :style="{ backgroundColor: variant.color_hex || '#cccccc' }" />
                                            <span class="text-sm text-gray-600">{{ variant.color_nombre }}</span>
                                        </div>
                                        <UBadge :color="variant.stock_actual > 0 ? 'green' : 'red'" variant="subtle"
                                            size="sm">
                                            {{ variant.stock_actual }}
                                        </UBadge>
                                    </div>
                                    <p v-if="existingVariants.length === 0" class="text-sm text-gray-500 text-center">
                                        No hay variantes registradas
                                    </p>
                                </div>
                            </div>
                        </div>
                    </UCard>
                </div>

                <!-- Vista previa y reglas -->
                <div class="space-y-6">
                    <!-- Vista previa -->
                    <UCard>
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800">Vista Previa</h2>
                        </template>

                        <div class="space-y-4">
                            <div class="flex items-center justify-center p-6 bg-gray-50 rounded-lg">
                                <div class="text-center">
                                    <div
                                        class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg">
                                        <span class="font-medium">{{ form.talla || 'Talla' }}</span>
                                        <div class="w-4 h-4 rounded-full border border-gray-300"
                                            :style="{ backgroundColor: form.color_hex || '#cccccc' }" />
                                        <span class="text-gray-600">{{ form.color_nombre || 'Color' }}</span>
                                    </div>
                                    <p class="mt-4 text-sm text-gray-600">
                                        Código: {{ form.codigo_barras || 'Sin código' }}
                                    </p>
                                    <p class="text-sm text-gray-600">
                                        Stock: {{ form.stock_actual || 0 }} unidades
                                    </p>
                                </div>
                            </div>

                            <!-- Resumen de datos -->
                            <div class="space-y-3">
                                <div class="grid grid-cols-2 gap-4">
                                    <div class="text-sm">
                                        <span class="text-gray-500">Talla:</span>
                                        <span class="ml-2 font-medium">{{ form.talla || 'No especificada' }}</span>
                                    </div>
                                    <div class="text-sm">
                                        <span class="text-gray-500">Color:</span>
                                        <span class="ml-2 font-medium">{{ form.color_nombre || 'No especificado'
                                        }}</span>
                                    </div>
                                </div>
                                <div class="grid grid-cols-2 gap-4">
                                    <div class="text-sm">
                                        <span class="text-gray-500">Código:</span>
                                        <span class="ml-2 font-medium">{{ form.codigo_barras || 'Sin código' }}</span>
                                    </div>
                                    <div class="text-sm">
                                        <span class="text-gray-500">Stock:</span>
                                        <span class="ml-2 font-medium">{{ form.stock_actual || 0 }} unidades</span>
                                    </div>
                                </div>
                                <div class="text-sm">
                                    <span class="text-gray-500">Almacén:</span>
                                    <span class="ml-2 font-medium">
                                        {{ selectedWarehouse?.nombre || 'No seleccionado' }}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </UCard>

                    <!-- Reglas y validaciones -->
                    <UCard>
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800">Reglas y Validaciones</h2>
                        </template>

                        <div class="space-y-3">
                            <div class="flex items-start gap-2">
                                <UIcon name="i-heroicons-check-circle" class="w-5 h-5 text-green-500 shrink-0 mt-0.5" />
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Combinación única</p>
                                    <p class="text-xs text-gray-600">
                                        La combinación de talla y color debe ser única para este producto
                                    </p>
                                </div>
                            </div>

                            <div class="flex items-start gap-2">
                                <UIcon name="i-heroicons-check-circle" class="w-5 h-5 text-green-500 shrink-0 mt-0.5" />
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Código único</p>
                                    <p class="text-xs text-gray-600">
                                        El código de barras debe ser único en todo el sistema
                                    </p>
                                </div>
                            </div>

                            <div class="flex items-start gap-2">
                                <UIcon name="i-heroicons-check-circle" class="w-5 h-5 text-green-500 shrink-0 mt-0.5" />
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Stock mínimo</p>
                                    <p class="text-xs text-gray-600">
                                        El stock inicial puede ser 0 si el producto está agotado
                                    </p>
                                </div>
                            </div>

                            <div class="flex items-start gap-2">
                                <UIcon name="i-heroicons-check-circle" class="w-5 h-5 text-green-500 shrink-0 mt-0.5" />
                                <div>
                                    <p class="text-sm font-medium text-gray-900">Almacén requerido</p>
                                    <p class="text-xs text-gray-600">
                                        Se debe seleccionar un almacén para registrar el stock
                                    </p>
                                </div>
                            </div>

                            <!-- Validación de combinación existente -->
                            <div v-if="duplicateVariant" class="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                                <div class="flex items-center gap-2">
                                    <UIcon name="i-heroicons-exclamation-triangle" class="w-5 h-5 text-red-500" />
                                    <p class="text-sm font-medium text-red-700">
                                        ¡Combinación existente!
                                    </p>
                                </div>
                                <p class="text-xs text-red-600 mt-1">
                                    Ya existe una variante con talla "{{ form.talla }}" y color "{{ form.color_nombre
                                    }}"
                                </p>
                            </div>
                        </div>
                    </UCard>

                    <!-- Acciones rápidas -->
                    <UCard>
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800">Acciones Rápidas</h2>
                        </template>

                        <div class="space-y-3">
                            <UButton block variant="outline" icon="i-heroicons-document-duplicate"
                                @click="duplicateFromExisting">
                                Duplicar de Existente
                            </UButton>
                            <UButton block variant="outline" icon="i-heroicons-bolt" @click="generateMultiple">
                                Crear Múltiples Variantes
                            </UButton>
                            <UButton block variant="outline" icon="i-heroicons-arrow-left" @click="cancel">
                                Volver al Producto
                            </UButton>
                        </div>
                    </UCard>
                </div>
            </div>
        </template>
    </UDashboardPanel>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from '#imports'

definePageMeta({
    layout: 'dashboard',
    middleware: ['auth']
})
const config = useRuntimeConfig()

const apiBase = config.public.apiBaseUrl



const route = useRoute()
const router = useRouter()
const toast = useToast()

const id = route.query.product_id

// Breadcrumb items
const breadcrumbItems = [
    { label: 'Dashboard', to: '/dashboard' },
    { label: 'Productos', to: '/dashboard/products' },
    { label: 'Editar', to: `/dashboard/products/edit/${id}` },
    { label: 'Crear Variante' }
]

// Estado reactivo
const product = ref(null)
const existingVariants = ref([])
const warehouses = ref([])
const loading = ref(false)
const loadingProduct = ref(true)
const error = ref('')
const success = ref(false)
const errors = ref({})

// Formulario
const form = ref({
    talla: '',
    color_nombre: '',
    color_hex: '#000000',
    codigo_barras: '',
    stock_actual: 0,
    almacen_id: null,
    activo: true
})

// Computed
const isFormValid = computed(() => {
    return form.value.talla && form.value.color_nombre &&
        form.value.codigo_barras && form.value.almacen_id !== null
})

const duplicateVariant = computed(() => {
    if (!form.value.talla || !form.value.color_nombre) return false
    return existingVariants.value.some(variant =>
        variant.talla === form.value.talla &&
        variant.color_nombre.toLowerCase() === form.value.color_nombre.toLowerCase()
    )
})

const warehouseOptions = computed(() => {
    return warehouses.value.map(warehouse => ({
        label: `${warehouse.nombre} (${warehouse.sucursal_nombre})`,
        value: warehouse.almacen_id,
        data: warehouse
    }))
})

const selectedWarehouse = computed(() => {
    return warehouses.value.find(w => w.almacen_id === form.value.almacen_id)
})

// Métodos
const fetchProduct = async () => {
    try {
        loadingProduct.value = true
        const { data } = await useFetch(`/products/${id}`, {
            baseURL: apiBase
        })

        if (data.value?.data) {
            product.value = data.value.data
            existingVariants.value = product.value.variantes || []
        }
    } catch (err) {
        error.value = 'Error al cargar el producto'
        toast.add({
            title: 'Error',
            description: 'No se pudo cargar la información del producto',
            color: 'red'
        })
    } finally {
        loadingProduct.value = false
    }
}

const fetchWarehouses = async () => {
    try {
        const { data } = await useFetch('/warehouses', {
            baseURL: apiBase
        })

        if (data.value?.data) {
            warehouses.value = data.value.data
        }
    } catch (err) {
        console.error('Error fetching warehouses:', err)
    }
}

const validateForm = () => {
    errors.value = {}

    if (!form.value.talla.trim()) {
        errors.value.talla = 'La talla es requerida'
    }

    if (!form.value.color_nombre.trim()) {
        errors.value.color_nombre = 'El color es requerido'
    }

    if (!form.value.codigo_barras.trim()) {
        errors.value.codigo_barras = 'El código de barras es requerido'
    } else if (form.value.codigo_barras.length < 8) {
        errors.value.codigo_barras = 'El código debe tener al menos 8 caracteres'
    }

    if (form.value.stock_actual < 0) {
        errors.value.stock_actual = 'El stock no puede ser negativo'
    }

    if (form.value.almacen_id === null) {
        errors.value.almacen_id = 'Debe seleccionar un almacén'
    }

    return Object.keys(errors.value).length === 0
}

const saveVariant = async () => {
    console.log('🟡 Iniciando guardado de variante')

    if (duplicateVariant.value) {
        toast.add({
            title: 'Advertencia',
            description: 'Ya existe una variante con esta combinación',
            color: 'orange'
        })
        return
    }

    if (!validateForm()) {
        toast.add({
            title: 'Error de validación',
            description: 'Corrige los errores del formulario',
            color: 'red'
        })
        return
    }

    try {
        loading.value = true
        error.value = ''

        const variantData = {
            ...form.value,
            producto_id: Number(id) // ✅ CORRECTO
        }

        console.log('📤 Enviando variante:', variantData)

        const { data, error: apiError } = await useApiFetch(
            `/products/${id}/variantes`,
            {
                method: 'POST',
                body: variantData
            }
        )
        console.log('📥 Respuesta:', data.value)
        console.log('⚠️ Error API:', apiError.value)

        if (apiError.value) throw apiError.value

        success.value = true

        toast.add({
            title: 'Éxito',
            description: 'Variante creada correctamente',
            color: 'green'
        })

        setTimeout(() => {
            router.push(`/products`)
        }, 1500)

    } catch (err) {
        console.error('🔥 Error al guardar variante:', err)
        error.value = 'Error al crear la variante'

        toast.add({
            title: 'Error',
            description: 'No se pudo crear la variante',
            color: 'red'
        })
    } finally {
        loading.value = false
    }
}

const generateBarcode = () => {
    // Generar un código EAN-13 aleatorio (solo para demo)
    const randomCode = '88' + Math.floor(10000000000 + Math.random() * 90000000000).toString().substring(0, 11)
    form.value.codigo_barras = randomCode
}

const duplicateFromExisting = () => {
    if (existingVariants.value.length > 0) {
        const lastVariant = existingVariants.value[existingVariants.value.length - 1]
        form.value.talla = lastVariant.talla
        form.value.color_nombre = lastVariant.color_nombre
        form.value.color_hex = lastVariant.color_hex
        form.value.stock_actual = lastVariant.stock_actual
    }
}

const generateMultiple = () => {
    router.push(`/dashboard/products/${id}/variants/multiple`)
}

const cancel = () => {
    router.push(`/dashboard/products/edit/${id}`)
}

// Ciclo de vida
onMounted(() => {
    fetchProduct()
    fetchWarehouses()
})

// Watchers
watch(() => form.value.color_nombre, (newColor) => {
    // Mapear colores comunes a códigos HEX
    const colorMap = {
        'rojo': '#FF0000',
        'verde': '#00FF00',
        'azul': '#0000FF',
        'negro': '#000000',
        'blanco': '#FFFFFF',
        'amarillo': '#FFFF00',
        'naranja': '#FFA500',
        'morado': '#800080',
        'rosa': '#FFC0CB',
        'gris': '#808080',
        'marron': '#A52A2A',
        'beige': '#F5F5DC',
        'turquesa': '#40E0D0',
        'lila': '#C8A2C8',
        'dorado': '#FFD700',
        'plateado': '#C0C0C0'
    }

    const lowerColor = newColor.toLowerCase()
    if (colorMap[lowerColor] && !form.value.color_hex) {
        form.value.color_hex = colorMap[lowerColor]
    }
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