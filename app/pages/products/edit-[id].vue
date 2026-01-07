<template>
    <div class="container mx-auto px-4 py-8">
        <!-- Breadcrumb con Nuxt UI -->
        <div class="mb-6">
            <UBreadcrumb :items="breadcrumbItems" />
        </div>

        <!-- Encabezado -->
        <UPageHeader>
            <template #title>
                <h1 class="text-3xl font-bold text-gray-900">Editar Producto</h1>
            </template>
            <template #description>
                <p class="text-gray-600">Actualiza la información del producto {{ product?.nombre || '' }}</p>
            </template>
            <template #actions>
                <UButton color="gray" variant="outline" @click="$router.back()" class="mr-2">
                    Cancelar
                </UButton>
                <UButton color="primary" :disabled="loading || !isFormValid" :loading="loading" @click="saveProduct">
                    Guardar Cambios
                </UButton>
            </template>
        </UPageHeader>

        <!-- Alertas -->
        <div class="my-6">
            <UAlert v-if="error" title="Error" :description="error" color="red" variant="subtle"
                icon="i-heroicons-exclamation-triangle" class="mb-4" />
            <UAlert v-if="success" title="Éxito" description="Producto actualizado exitosamente" color="green"
                variant="subtle" icon="i-heroicons-check-circle" class="mb-4" />
        </div>

        <!-- Loading state -->
        <div v-if="loadingInitial" class="text-center py-12">
            <UIcon name="i-heroicons-arrow-path" class="w-12 h-12 animate-spin text-primary mx-auto" />
            <p class="mt-4 text-gray-600">Cargando información del producto...</p>
        </div>

        <!-- Product not found -->
        <UCard v-else-if="!product" class="my-6">
            <template #header>
                <div class="text-center">
                    <UIcon name="i-heroicons-exclamation-circle" class="w-12 h-12 text-gray-400 mx-auto" />
                    <h3 class="mt-4 text-lg font-medium text-gray-900">Producto no encontrado</h3>
                    <p class="mt-2 text-gray-600">El producto que buscas no existe o ha sido eliminado</p>
                </div>
            </template>
            <div class="flex justify-center">
                <UButton to="/dashboard/products" color="primary">
                    Volver a Productos
                </UButton>
            </div>
        </UCard>

        <!-- Formulario principal -->
        <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-6">
            <!-- Columna izquierda -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Información básica -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Información Básica</h2>
                    </template>

                    <div class="space-y-4">
                        <!-- SKU -->
                        <UFormGroup label="SKU" required :error="errors.sku">
                            <UInput v-model="form.sku" placeholder="Ej: PROD-001"
                                :ui="{ icon: { trailing: { pointer: '' } } }">
                                <template #trailing>
                                    <UIcon name="i-heroicons-tag" class="w-4 h-4 text-gray-400" />
                                </template>
                            </UInput>
                        </UFormGroup>

                        <!-- Nombre -->
                        <UFormGroup label="Nombre del Producto" required :error="errors.nombre">
                            <UInput v-model="form.nombre" placeholder="Ej: Camisa Oxford Slim Fit"
                                :ui="{ icon: { trailing: { pointer: '' } } }">
                                <template #trailing>
                                    <UIcon name="i-heroicons-shopping-bag" class="w-4 h-4 text-gray-400" />
                                </template>
                            </UInput>
                        </UFormGroup>

                        <!-- Descripción -->
                        <UFormGroup label="Descripción" :error="errors.descripcion">
                            <UTextarea v-model="form.descripcion" placeholder="Descripción detallada del producto..."
                                :rows="4" />
                        </UFormGroup>

                        <!-- Categoría y Marca -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <UFormGroup label="Categoría" required :error="errors.categoria_id">
                                <USelect v-model="form.categoria_id" :options="categoryOptions"
                                    placeholder="Seleccionar categoría" option-attribute="label"
                                    value-attribute="value" />
                            </UFormGroup>

                            <UFormGroup label="Marca" required :error="errors.marca_id">
                                <USelect v-model="form.marca_id" :options="brandOptions" placeholder="Seleccionar marca"
                                    option-attribute="label" value-attribute="value" />
                            </UFormGroup>
                        </div>

                        <!-- Género y Temporada -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <UFormGroup label="Género">
                                <USelect v-model="form.genero" :options="genderOptions" placeholder="Sin especificar" />
                            </UFormGroup>

                            <UFormGroup label="Temporada">
                                <USelect v-model="form.temporada" :options="seasonOptions" placeholder="Todo el año" />
                            </UFormGroup>
                        </div>
                    </div>
                </UCard>

                <!-- Precios y Stock -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Precios y Stock</h2>
                    </template>

                    <div class="space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <UFormGroup label="Precio de Compra (MXN)" :error="errors.precio_compra">
                                <UInput v-model="form.precio_compra" type="number" min="0" step="0.01"
                                    :ui="{ icon: { leading: { pointer: '' } } }">
                                    <template #leading>
                                        <span class="text-gray-500">$</span>
                                    </template>
                                </UInput>
                            </UFormGroup>

                            <UFormGroup label="Precio de Venta (MXN)" required :error="errors.precio_venta">
                                <UInput v-model="form.precio_venta" type="number" min="0" step="0.01"
                                    :ui="{ icon: { leading: { pointer: '' } } }">
                                    <template #leading>
                                        <span class="text-gray-500">$</span>
                                    </template>
                                </UInput>
                            </UFormGroup>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <UFormGroup label="Stock Mínimo">
                                <UInput v-model="form.stock_minimo" type="number" min="0" />
                            </UFormGroup>

                            <UFormGroup label="Stock Máximo">
                                <UInput v-model="form.stock_maximo" type="number" min="0" />
                            </UFormGroup>
                        </div>

                        <!-- Promoción -->
                        <UDivider label="Configuración de Promoción" class="my-6" />

                        <div class="flex items-center justify-between mb-4">
                            <span class="text-sm font-medium text-gray-700">Activar promoción</span>
                            <UToggle v-model="form.es_promocion" @change="togglePromotion" />
                        </div>

                        <div v-if="form.es_promocion" class="space-y-4 animate-fadeIn">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Porcentaje de Descuento">
                                    <UInput v-model="form.porcentaje_descuento" type="number" min="0" max="100"
                                        step="0.1" :ui="{ icon: { trailing: { pointer: '' } } }">
                                        <template #trailing>
                                            <span class="text-gray-500">%</span>
                                        </template>
                                    </UInput>
                                </UFormGroup>

                                <UFormGroup label="Precio Promocional">
                                    <UInput :model-value="promotionalPrice" readonly
                                        :ui="{ icon: { leading: { pointer: '' } } }">
                                        <template #leading>
                                            <span class="text-gray-500">$</span>
                                        </template>
                                    </UInput>
                                </UFormGroup>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Fecha Inicio">
                                    <UInput v-model="form.fecha_inicio_promocion" type="date" />
                                </UFormGroup>

                                <UFormGroup label="Fecha Fin">
                                    <UInput v-model="form.fecha_fin_promocion" type="date" />
                                </UFormGroup>
                            </div>
                        </div>
                    </div>
                </UCard>

                <!-- Características -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Características</h2>
                    </template>

                    <div class="space-y-4">
                        <UFormGroup label="Material Principal">
                            <UInput v-model="form.material_principal"
                                placeholder="Ej: Algodón 100%, Poliéster, Cuero..." />
                        </UFormGroup>

                        <UFormGroup label="Instrucciones de Cuidado">
                            <UTextarea v-model="form.cuidados"
                                placeholder="Ej: Lavar a máquina en agua fría, no usar blanqueador..." :rows="3" />
                        </UFormGroup>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <UFormGroup label="Peso (gramos)">
                                <UInput v-model="form.peso" type="number" min="0"
                                    :ui="{ icon: { trailing: { pointer: '' } } }">
                                    <template #trailing>
                                        <span class="text-gray-500">g</span>
                                    </template>
                                </UInput>
                            </UFormGroup>

                            <UFormGroup label="Dimensiones (cm)">
                                <div class="grid grid-cols-3 gap-2">
                                    <UInput v-model="form.largo" type="number" min="0" placeholder="Largo" />
                                    <UInput v-model="form.ancho" type="number" min="0" placeholder="Ancho" />
                                    <UInput v-model="form.alto" type="number" min="0" placeholder="Alto" />
                                </div>
                            </UFormGroup>
                        </div>
                    </div>
                </UCard>
            </div>

            <!-- Columna derecha -->
            <div class="space-y-6">
                <!-- Estado -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Estado</h2>
                    </template>

                    <div class="space-y-4">
                        <UFormGroup label="Estado del Producto">
                            <URadioGroup v-model="form.activo">
                                <URadio :value="true" label="Activo" />
                                <URadio :value="false" label="Inactivo" />
                            </URadioGroup>
                        </UFormGroup>

                        <UFormGroup label="Fecha de Creación">
                            <p class="text-gray-900">{{ formatDate(product.created_at) }}</p>
                        </UFormGroup>

                        <UFormGroup label="Última Actualización">
                            <p class="text-gray-900">{{ formatDate(product.updated_at) }}</p>
                        </UFormGroup>
                    </div>
                </UCard>

                <!-- Imágenes -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Imágenes</h2>
                    </template>

                    <div class="space-y-4">
                        <!-- Imagen principal -->
                        <UFormGroup label="Imagen Principal">
                            <div class="relative">
                                <div v-if="form.imagen_url"
                                    class="w-full h-48 rounded-lg overflow-hidden border border-gray-300">
                                    <img :src="form.imagen_url" alt="Producto" class="w-full h-full object-cover" />
                                    <UButton color="red" variant="solid" size="xs" icon="i-heroicons-x-mark"
                                        class="absolute top-2 right-2" @click="form.imagen_url = ''" />
                                </div>
                                <div v-else
                                    class="w-full h-48 border-2 border-dashed border-gray-300 rounded-lg flex flex-col items-center justify-center">
                                    <UIcon name="i-heroicons-photo" class="w-12 h-12 text-gray-400" />
                                    <p class="mt-2 text-sm text-gray-600">No hay imagen</p>
                                    <UInput v-model="form.imagen_url" placeholder="URL de la imagen" size="sm"
                                        class="mt-2 w-64" />
                                </div>
                            </div>
                        </UFormGroup>

                        <!-- Galería -->
                        <UFormGroup label="Galería de Imágenes">
                            <div class="space-y-2">
                                <div v-for="(image, index) in form.galeria_imagenes" :key="index"
                                    class="flex items-center gap-2">
                                    <UInput v-model="form.galeria_imagenes[index]" placeholder="URL de la imagen"
                                        size="sm" class="flex-1" />
                                    <UButton color="red" variant="ghost" size="sm" icon="i-heroicons-trash"
                                        @click="removeGalleryImage(index)" />
                                </div>
                                <UButton block variant="outline" icon="i-heroicons-plus" @click="addGalleryImage">
                                    Agregar Imagen
                                </UButton>
                            </div>
                        </UFormGroup>
                    </div>
                </UCard>

                <!-- Variantes -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Variantes</h2>
                    </template>

                    <div class="space-y-3">
                        <div v-for="variant in product.variantes || []" :key="variant.variante_id"
                            class="p-3 border border-gray-200 rounded-lg hover:border-gray-300 transition">
                            <div class="flex justify-between items-center mb-2">
                                <span class="font-medium text-gray-900">{{ variant.talla }} - {{ variant.color_nombre
                                    }}</span>
                                <UBadge :color="variant.stock_actual > 0 ? 'green' : 'red'" variant="subtle">
                                    {{ variant.stock_actual }} unidades
                                </UBadge>
                            </div>
                            <div class="flex items-center gap-2">
                                <div class="w-4 h-4 rounded-full border border-gray-300"
                                    :style="{ backgroundColor: variant.color_hex }" />
                                <span class="text-sm text-gray-600">{{ variant.codigo_barras }}</span>
                            </div>
                        </div>
                        <UButton block variant="outline" icon="i-heroicons-cog-6-tooth" @click="goToVariants">
                            Gestionar Variantes
                        </UButton>
                    </div>
                </UCard>

                <!-- Acciones -->
                <UCard>
                    <template #header>
                        <h2 class="text-xl font-semibold text-gray-800">Acciones</h2>
                    </template>

                    <div class="space-y-3">
                        <UButton block variant="outline" icon="i-heroicons-document-duplicate"
                            @click="duplicateProduct">
                            Duplicar Producto
                        </UButton>
                        <UButton block variant="outline" icon="i-heroicons-clock" @click="viewHistory">
                            Ver Historial
                        </UButton>
                        <UButton block color="red" variant="outline" icon="i-heroicons-trash" @click="confirmDelete">
                            Eliminar Producto
                        </UButton>
                    </div>
                </UCard>
            </div>
        </div>

        <!-- Modal de confirmación de eliminación -->
        <UModal v-model="showDeleteModal">
            <UCard>
                <template #header>
                    <div class="flex items-center gap-2">
                        <UIcon name="i-heroicons-exclamation-triangle" class="w-6 h-6 text-red-500" />
                        <h3 class="text-lg font-semibold text-gray-900">Confirmar Eliminación</h3>
                    </div>
                </template>

                <p class="text-gray-600 mb-6">
                    ¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.
                </p>

                <template #footer>
                    <div class="flex justify-end gap-3">
                        <UButton color="gray" variant="ghost" @click="showDeleteModal = false">
                            Cancelar
                        </UButton>
                        <UButton color="red" :loading="deleting" @click="deleteProduct">
                            Eliminar
                        </UButton>
                    </div>
                </template>
            </UCard>
        </UModal>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from '#imports'

const route = useRoute()
const router = useRouter()
const toast = useToast()

// Breadcrumb items
const breadcrumbItems = [
    { label: 'Dashboard', to: '/dashboard' },
    { label: 'Productos', to: '/dashboard/products' },
    { label: 'Editar Producto' }
]

// Opciones para selects
const genderOptions = [
    { label: 'Sin especificar', value: '' },
    { label: 'Hombre', value: 'Hombre' },
    { label: 'Mujer', value: 'Mujer' },
    { label: 'Unisex', value: 'Unisex' },
    { label: 'Infantil', value: 'Infantil' }
]

const seasonOptions = [
    { label: 'Todo el año', value: '' },
    { label: 'Primavera', value: 'Primavera' },
    { label: 'Verano', value: 'Verano' },
    { label: 'Otoño', value: 'Otoño' },
    { label: 'Invierno', value: 'Invierno' }
]

// Estado reactivo
const product = ref(null)
const categories = ref([])
const brands = ref([])
const loading = ref(false)
const loadingInitial = ref(true)
const error = ref('')
const success = ref(false)
const errors = ref({})
const showDeleteModal = ref(false)
const deleting = ref(false)

// Formulario
const form = ref({
    sku: '',
    nombre: '',
    descripcion: '',
    categoria_id: '',
    marca_id: '',
    genero: '',
    temporada: '',
    material_principal: '',
    cuidados: '',
    precio_compra: 0,
    precio_venta: 0,
    stock_minimo: 0,
    stock_maximo: 0,
    es_promocion: false,
    porcentaje_descuento: 0,
    fecha_inicio_promocion: '',
    fecha_fin_promocion: '',
    imagen_url: '',
    galeria_imagenes: [],
    activo: true,
    peso: null,
    largo: null,
    ancho: null,
    alto: null
})

// Computed
const isFormValid = computed(() => {
    return form.value.sku && form.value.nombre && form.value.categoria_id &&
        form.value.marca_id && form.value.precio_venta > 0
})

const promotionalPrice = computed(() => {
    if (form.value.es_promocion && form.value.precio_venta && form.value.porcentaje_descuento) {
        const discount = form.value.precio_venta * (form.value.porcentaje_descuento / 100)
        return (form.value.precio_venta - discount).toFixed(2)
    }
    return '0.00'
})

const categoryOptions = computed(() => {
    return categories.value.map(cat => ({
        label: cat.nombre,
        value: cat.categoria_id
    }))
})

const brandOptions = computed(() => {
    return brands.value.map(brand => ({
        label: brand.nombre,
        value: brand.marca_id
    }))
})

// Métodos
const fetchProduct = async () => {
    try {
        loadingInitial.value = true
        const { data } = await useFetch(`/api/products/${route.params.id}`, {
            baseURL: useRuntimeConfig().public.apiBase
        })

        if (data.value?.data) {
            product.value = data.value.data

            // Llenar el formulario con los datos del producto
            Object.keys(form.value).forEach(key => {
                if (product.value[key] !== undefined) {
                    form.value[key] = product.value[key]
                }
            })

            // Asegurar que galeria_imagenes sea un array
            if (!Array.isArray(form.value.galeria_imagenes)) {
                form.value.galeria_imagenes = []
            }
        }
    } catch (err) {
        error.value = 'Error al cargar el producto'
        toast.add({
            title: 'Error',
            description: 'No se pudo cargar la información del producto',
            color: 'red'
        })
    } finally {
        loadingInitial.value = false
    }
}

const fetchCategories = async () => {
    try {
        const { data } = await useFetch('/api/categories', {
            params: { limit: 100, only_active: true },
            baseURL: useRuntimeConfig().public.apiBase
        })

        if (data.value?.data) {
            categories.value = data.value.data
        }
    } catch (err) {
        console.error('Error fetching categories:', err)
    }
}

const fetchBrands = async () => {
    try {
        const { data } = await useFetch('/api/brands', {
            params: { limit: 100, only_active: true },
            baseURL: useRuntimeConfig().public.apiBase
        })

        if (data.value?.data) {
            brands.value = data.value.data
        }
    } catch (err) {
        console.error('Error fetching brands:', err)
    }
}

const validateForm = () => {
    errors.value = {}

    if (!form.value.sku.trim()) {
        errors.value.sku = 'El SKU es requerido'
    }

    if (!form.value.nombre.trim()) {
        errors.value.nombre = 'El nombre es requerido'
    }

    if (!form.value.categoria_id) {
        errors.value.categoria_id = 'La categoría es requerida'
    }

    if (!form.value.marca_id) {
        errors.value.marca_id = 'La marca es requerida'
    }

    if (!form.value.precio_venta || form.value.precio_venta <= 0) {
        errors.value.precio_venta = 'El precio de venta debe ser mayor a 0'
    }

    if (form.value.precio_compra && form.value.precio_compra < 0) {
        errors.value.precio_compra = 'El precio de compra no puede ser negativo'
    }

    return Object.keys(errors.value).length === 0
}

const saveProduct = async () => {
    if (!validateForm()) {
        toast.add({
            title: 'Error de validación',
            description: 'Por favor corrige los errores en el formulario',
            color: 'red'
        })
        return
    }

    try {
        loading.value = true
        error.value = ''

        const { data } = await useFetch(`/api/products/${route.params.id}`, {
            method: 'PUT',
            body: form.value,
            baseURL: useRuntimeConfig().public.apiBase
        })

        if (data.value?.data) {
            success.value = true
            product.value = data.value.data

            toast.add({
                title: 'Éxito',
                description: 'Producto actualizado correctamente',
                color: 'green'
            })

            // Ocultar éxito después de 3 segundos
            setTimeout(() => {
                success.value = false
            }, 3000)
        }
    } catch (err) {
        error.value = 'Error al guardar el producto'

        // Manejar errores de validación del backend
        if (err.data?.errors) {
            errors.value = err.data.errors.reduce((acc, error) => {
                acc[error.field] = error.message
                return acc
            }, {})
        }

        toast.add({
            title: 'Error',
            description: 'No se pudo guardar el producto',
            color: 'red'
        })
    } finally {
        loading.value = false
    }
}

const togglePromotion = () => {
    if (!form.value.es_promocion) {
        form.value.porcentaje_descuento = 0
        form.value.fecha_inicio_promocion = ''
        form.value.fecha_fin_promocion = ''
    }
}

const addGalleryImage = () => {
    form.value.galeria_imagenes.push('')
}

const removeGalleryImage = (index) => {
    form.value.galeria_imagenes.splice(index, 1)
}

const goToVariants = () => {
    router.push(`/dashboard/products/${route.params.id}/variants`)
}

const duplicateProduct = async () => {
    const confirmed = await confirm('¿Crear una copia de este producto?')

    if (confirmed) {
        try {
            const duplicateData = { ...form.value, sku: `${form.value.sku}-COPY` }
            delete duplicateData.producto_id

            const { data } = await useFetch('/api/products', {
                method: 'POST',
                body: duplicateData,
                baseURL: useRuntimeConfig().public.apiBase
            })

            if (data.value?.data) {
                router.push(`/dashboard/products/edit/${data.value.data.producto_id}`)

                toast.add({
                    title: 'Éxito',
                    description: 'Producto duplicado correctamente',
                    color: 'green'
                })
            }
        } catch (err) {
            toast.add({
                title: 'Error',
                description: 'No se pudo duplicar el producto',
                color: 'red'
            })
        }
    }
}

const viewHistory = () => {
    // Implementar navegación a historial
    console.log('Ver historial del producto')
}

const confirmDelete = () => {
    showDeleteModal.value = true
}

const deleteProduct = async () => {
    try {
        deleting.value = true

        await useFetch(`/api/products/${route.params.id}`, {
            method: 'DELETE',
            baseURL: useRuntimeConfig().public.apiBase
        })

        toast.add({
            title: 'Éxito',
            description: 'Producto eliminado correctamente',
            color: 'green'
        })

        router.push('/dashboard/products')
    } catch (err) {
        toast.add({
            title: 'Error',
            description: 'No se pudo eliminar el producto',
            color: 'red'
        })
        showDeleteModal.value = false
    } finally {
        deleting.value = false
    }
}

const formatDate = (dateString) => {
    if (!dateString) return 'N/A'
    return new Date(dateString).toLocaleDateString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
}

// Watchers
watch(() => form.value.porcentaje_descuento, (newValue) => {
    if (newValue > 100) {
        form.value.porcentaje_descuento = 100
    } else if (newValue < 0) {
        form.value.porcentaje_descuento = 0
    }
})

// Ciclo de vida
onMounted(() => {
    fetchProduct()
    fetchCategories()
    fetchBrands()
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

input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

input[type="number"] {
    -moz-appearance: textfield;
}
</style>