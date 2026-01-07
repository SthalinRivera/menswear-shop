<script setup lang="ts">
const { createProduct, getCategories, getBrands, uploadProductImages } = useProducts()
const toast = useToast()

definePageMeta({
    layout: 'dashboard',
    middleware: ['auth']
})

// Datos reactivos
const categories = ref<any[]>([])
const brands = ref<any[]>([])
const isLoading = ref(false)

// Cargar datos
const loadData = async () => {
    try {
        isLoading.value = true

        // Cargar categorías
        const { data: categoriesResponse } = await getCategories()
        if (categoriesResponse.value?.success) {
            categories.value = categoriesResponse.value.data || []
            console.log('Categorías cargadas:', categories.value)
        }

        // Cargar marcas
        const { data: brandsResponse } = await getBrands()
        if (brandsResponse.value?.success) {
            brands.value = brandsResponse.value.data || []
            console.log('Marcas cargadas:', brands.value)
        }
    } catch (error) {
        console.error('Error cargando datos:', error)
        toast.add({
            title: 'Error',
            description: 'No se pudieron cargar los datos',
            color: 'red'
        })
    } finally {
        isLoading.value = false
    }
}

// Cargar datos al montar el componente
onMounted(() => {
    loadData()
})

const productForm = ref({
    sku: '',
    nombre: '',
    descripcion: '',
    categoria_id: '',
    marca_id: '',
    genero: 'Unisex',
    temporada: 'Todo el año',
    material_principal: '',
    cuidados: '',
    precio_compra: '',
    precio_venta: '',
    impuesto_porcentaje: '16.00',
    stock_minimo: 5,
    stock_maximo: 100
})

const previewImages = ref<Array<{ file: File; url: string; id: string }>>([])
const selectedImages = ref<File[]>([])
const isUploading = ref(false)
const isDragging = ref(false)

// Para debugging
watchEffect(() => {
    console.log('Categorías en ref:', categories.value)
    console.log('Marcas en ref:', brands.value)
})

const handleImageUpload = (event: Event) => {
    const input = event.target as HTMLInputElement
    processFiles(input.files)
}

const handleDrop = (event: DragEvent) => {
    event.preventDefault()
    isDragging.value = false
    processFiles(event.dataTransfer?.files)
}

const handleDragOver = (event: DragEvent) => {
    event.preventDefault()
    isDragging.value = true
}

const handleDragLeave = () => {
    isDragging.value = false
}

const processFiles = (files: FileList | null) => {
    if (!files) return

    const maxImages = 5
    const availableSlots = maxImages - previewImages.value.length
    const filesToAdd = Array.from(files).slice(0, availableSlots)

    filesToAdd.forEach(file => {
        if (!file.type.startsWith('image/')) {
            toast.add({
                title: 'Error',
                description: 'Solo se permiten archivos de imagen',
                color: 'red'
            })
            return
        }

        const maxSize = 5 * 1024 * 1024
        if (file.size > maxSize) {
            toast.add({
                title: 'Error',
                description: 'La imagen es demasiado grande (máx. 5MB)',
                color: 'red'
            })
            return
        }

        const url = URL.createObjectURL(file)
        previewImages.value.push({
            file,
            url,
            id: Math.random().toString(36).substring(7)
        })
        selectedImages.value.push(file)
    })
}

const removeImage = (index: number) => {
    URL.revokeObjectURL(previewImages.value[index].url)
    previewImages.value.splice(index, 1)
    selectedImages.value.splice(index, 1)
}

const getFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

async function handleSaveProduct() {
    try {
        isUploading.value = true
        console.log("productos  enviados ", productForm.value);

        const { data, error } = await createProduct(productForm.value)

        if (error.value) throw error.value

        if (selectedImages.value.length > 0 && data.value?.producto_id) {
            try {
                await uploadProductImages(data.value.producto_id, selectedImages.value)
                toast.add({
                    title: 'Éxito',
                    description: 'Imágenes subidas correctamente',
                    color: 'green',
                    icon: 'i-heroicons-check-circle'
                })
            } catch (uploadError: any) {
                toast.add({
                    title: 'Advertencia',
                    description: 'Producto creado, pero hubo un error al subir las imágenes',
                    color: 'amber',
                    icon: 'i-heroicons-exclamation-triangle'
                })
            }
        }

        toast.add({
            title: '¡Producto creado!',
            description: 'El producto ha sido creado exitosamente',
            color: 'green',
            icon: 'i-heroicons-check-circle'
        })

        navigateTo(`/products/variants/create?product_id=${data.value?.producto_id}`)
    } catch (error: any) {
        toast.add({
            title: 'Error',
            description: error.message || 'Error al crear el producto',
            color: 'red',
            icon: 'i-heroicons-x-circle'
        })
    } finally {
        isUploading.value = false
    }
}

onBeforeUnmount(() => {
    previewImages.value.forEach(image => {
        URL.revokeObjectURL(image.url)
    })
})
</script>

<template>
    <UDashboardPanel id="create-product">
        <template #header>
            <UDashboardNavbar title="Nuevo Producto">
                <template #leading>
                    <UDashboardSidebarCollapse />
                </template>

                <template #right>
                    <UButton label="Cancelar" color="neutral" variant="ghost" to="/products" />
                    <UButton label="Guardar producto" color="primary" :loading="isUploading" :disabled="isUploading"
                        @click="handleSaveProduct" />
                </template>
            </UDashboardNavbar>
        </template>

        <template #body>
            <div class="">
                <UCard>
                    <!-- Contenido Principal -->
                    <div class="">
                        <!-- Loading Overlay -->
                        <div v-if="isLoading"
                            class="fixed inset-0 bg-white/90 dark:bg-gray-900/90 z-50 flex items-center justify-center">
                            <div class="text-center">
                                <div class="relative">
                                    <div class="w-16 h-16 border-4 border-blue-200 rounded-full"></div>
                                    <div
                                        class="w-16 h-16 border-4 border-blue-600 rounded-full animate-spin absolute top-0 left-0 border-t-transparent">
                                    </div>
                                </div>
                                <p class="mt-4 text-gray-600 dark:text-gray-400 font-medium">Cargando datos...</p>
                            </div>
                        </div>

                        <!-- Grid de Formularios -->
                        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                            <!-- Columna Principal -->
                            <div class="lg:col-span-2 space-y-8">
                                <!-- Tarjeta Información Básica -->
                                <div
                                    class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-800 overflow-hidden">
                                    <div class="p-6 border-b border-gray-200 dark:border-gray-800">
                                        <div class="flex items-center space-x-3">
                                            <div
                                                class="p-3 rounded-xl bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20">
                                                <svg class="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none"
                                                    stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 class="text-lg font-bold text-gray-900 dark:text-white">Información
                                                    Básica</h2>
                                                <p class="text-sm text-gray-500 dark:text-gray-400">Datos principales
                                                    del producto</p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="p-6 space-y-6">
                                        <!-- Grid de Campos -->
                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <!-- SKU -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    SKU <span class="text-red-500">*</span>
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14" />
                                                        </svg>
                                                    </div>
                                                    <input v-model="productForm.sku" type="text" required
                                                        class="w-full pl-10 pr-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                        placeholder="Ej: PROD-001">
                                                </div>
                                            </div>

                                            <!-- Nombre -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Nombre <span class="text-red-500">*</span>
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                                        </svg>
                                                    </div>
                                                    <input v-model="productForm.nombre" type="text" required
                                                        class="w-full pl-10 pr-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                        placeholder="Nombre del producto">
                                                </div>
                                            </div>

                                            <!-- Categoría -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Categoría <span class="text-red-500">*</span>
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M3 7a2 2 0 012-2h5l2 2h7a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V7z" />
                                                        </svg>
                                                    </div>
                                                    <select v-model.number="productForm.categoria_id"
                                                        :disabled="isLoading" required
                                                        class="w-full pl-10 pr-10 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 appearance-none transition-colors">
                                                        <option value="" disabled selected>Seleccionar categoría
                                                        </option>
                                                        <option v-for="category in categories"
                                                            :key="category.categoria_id" :value="category.categoria_id">
                                                            {{ category.nombre }}
                                                        </option>
                                                    </select>
                                                    <div
                                                        class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2" d="M19 9l-7 7-7-7" />
                                                        </svg>
                                                    </div>
                                                </div>
                                                <div v-if="!isLoading && categories.length === 0"
                                                    class="mt-2 text-sm text-gray-500">
                                                    No hay categorías disponibles
                                                </div>
                                            </div>

                                            <!-- Marca -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Marca
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                                                        </svg>
                                                    </div>
                                                    <select v-model="productForm.marca_id" :disabled="isLoading"
                                                        class="w-full pl-10 pr-10 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 appearance-none transition-colors">
                                                        <option value="" selected>Seleccionar marca</option>
                                                        <option v-for="brand in brands" :key="brand.marca_id"
                                                            :value="brand.marca_id">
                                                            {{ brand.nombre }}
                                                        </option>
                                                    </select>
                                                    <div
                                                        class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2" d="M19 9l-7 7-7-7" />
                                                        </svg>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Tarjeta Detalles del Producto -->
                                <div
                                    class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-800 overflow-hidden">
                                    <div class="p-6 border-b border-gray-200 dark:border-gray-800">
                                        <div class="flex items-center space-x-3">
                                            <div
                                                class="p-3 rounded-xl bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20">
                                                <svg class="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none"
                                                    stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 class="text-lg font-bold text-gray-900 dark:text-white">Detalles del
                                                    Producto</h2>
                                                <p class="text-sm text-gray-500 dark:text-gray-400">Características
                                                    específicas</p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="p-6 space-y-6">
                                        <!-- Descripción -->
                                        <div>
                                            <label
                                                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                Descripción
                                            </label>
                                            <textarea v-model="productForm.descripcion" rows="4"
                                                class="w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors resize-none"
                                                placeholder="Describe el producto en detalle..."></textarea>
                                        </div>

                                        <!-- Grid de Características -->
                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <!-- Género -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Género
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5 1.195a4 4 0 01-4 4m4-4a4 4 0 00-4-4m-4.5 8a4 4 0 01-4-4m4 4a4 4 0 004-4m0 0H3" />
                                                        </svg>
                                                    </div>
                                                    <select v-model="productForm.genero"
                                                        class="w-full pl-10 pr-10 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 appearance-none transition-colors">
                                                        <option>Hombre</option>
                                                        <option>Mujer</option>
                                                        <option>Unisex</option>
                                                        <option>Niño</option>
                                                        <option>Niña</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <!-- Temporada -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Temporada
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                        </svg>
                                                    </div>
                                                    <select v-model="productForm.temporada"
                                                        class="w-full pl-10 pr-10 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 appearance-none transition-colors">
                                                        <option>Primavera</option>
                                                        <option>Verano</option>
                                                        <option>Otoño</option>
                                                        <option>Invierno</option>
                                                        <option>Todo el año</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <!-- Material Principal -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Material Principal
                                                </label>
                                                <div class="relative">
                                                    <div
                                                        class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <svg class="w-5 h-5 text-gray-400" fill="none"
                                                            stroke="currentColor" viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2"
                                                                d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                                                        </svg>
                                                    </div>
                                                    <input v-model="productForm.material_principal" type="text"
                                                        class="w-full pl-10 pr-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                        placeholder="Ej: Algodón 100%, Poliéster, etc.">
                                                </div>
                                            </div>

                                            <!-- Cuidados -->
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Instrucciones de Cuidado
                                                </label>
                                                <textarea v-model="productForm.cuidados" rows="2"
                                                    class="w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors resize-none"
                                                    placeholder="Instrucciones de lavado y cuidado..."></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Columna Lateral -->
                            <div class="space-y-8">
                                <!-- Tarjeta Imágenes -->
                                <div
                                    class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-800 overflow-hidden">
                                    <div class="p-6 border-b border-gray-200 dark:border-gray-800">
                                        <div class="flex items-center space-x-3">
                                            <div
                                                class="p-3 rounded-xl bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20">
                                                <svg class="w-6 h-6 text-amber-600 dark:text-amber-400" fill="none"
                                                    stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 class="text-lg font-bold text-gray-900 dark:text-white">Imágenes
                                                </h2>
                                                <p class="text-sm text-gray-500 dark:text-gray-400">Hasta 5 imágenes</p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="p-6 space-y-6">
                                        <!-- Área de Arrastrar y Soltar -->
                                        <div @drop="handleDrop" @dragover="handleDragOver" @dragleave="handleDragLeave"
                                            @click="$refs.fileInput?.click()" :class="[
                                                'border-3 border-dashed rounded-2xl p-8 text-center transition-all cursor-pointer',
                                                isDragging
                                                    ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/10 border-solid scale-[1.02]'
                                                    : 'border-gray-300 dark:border-gray-700 hover:border-blue-400 hover:bg-gray-50 dark:hover:bg-gray-800'
                                            ]">
                                            <input ref="fileInput" type="file" multiple accept="image/*"
                                                @change="handleImageUpload" class="hidden">

                                            <div class="flex flex-col items-center justify-center space-y-4">
                                                <div
                                                    class="p-4 rounded-full bg-gradient-to-br from-blue-100 to-indigo-100 dark:from-blue-900/30 dark:to-indigo-900/30">
                                                    <svg class="w-10 h-10 text-blue-600 dark:text-blue-400" fill="none"
                                                        stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round"
                                                            stroke-width="2"
                                                            d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                                                    </svg>
                                                </div>
                                                <div>
                                                    <p class="font-medium text-gray-900 dark:text-white">Arrastra y
                                                        suelta imágenes</p>
                                                    <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">o haz clic
                                                        para buscar</p>
                                                </div>
                                                <p class="text-xs text-gray-400 dark:text-gray-500 px-8">
                                                    JPG, PNG, WebP (máx. 5MB)
                                                </p>
                                            </div>
                                        </div>

                                        <!-- Vista Previa de Imágenes -->
                                        <div v-if="previewImages.length > 0" class="space-y-4">
                                            <div class="flex items-center justify-between">
                                                <h3 class="font-medium text-gray-900 dark:text-white">Vista Previa</h3>
                                                <span class="text-sm text-gray-500">
                                                    {{ previewImages.length }}/5 imágenes
                                                </span>
                                            </div>

                                            <div class="grid grid-cols-2 gap-4">
                                                <div v-for="(image, index) in previewImages" :key="image.id"
                                                    class="relative group">
                                                    <div
                                                        class="aspect-square rounded-xl overflow-hidden bg-gray-100 dark:bg-gray-800">
                                                        <img :src="image.url" :alt="`Preview ${index + 1}`"
                                                            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300">
                                                    </div>

                                                    <!-- Overlay de información -->
                                                    <div
                                                        class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity rounded-xl">
                                                        <div class="absolute bottom-3 left-3 right-3">
                                                            <p class="text-xs font-medium text-white truncate">
                                                                {{ image.file.name }}
                                                            </p>
                                                            <p class="text-xs text-gray-200">
                                                                {{ getFileSize(image.file.size) }}
                                                            </p>
                                                        </div>
                                                    </div>

                                                    <!-- Botón Eliminar -->
                                                    <button @click.stop="removeImage(index)"
                                                        class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-7 h-7 flex items-center justify-center shadow-lg hover:bg-red-600 transition-colors hover:scale-110">
                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                            viewBox="0 0 24 24">
                                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                                stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                                        </svg>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Tarjeta Precios y Stock -->
                                <div
                                    class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-800 overflow-hidden">
                                    <div class="p-6 border-b border-gray-200 dark:border-gray-800">
                                        <div class="flex items-center space-x-3">
                                            <div
                                                class="p-3 rounded-xl bg-gradient-to-br from-emerald-50 to-green-50 dark:from-emerald-900/20 dark:to-green-900/20">
                                                <svg class="w-6 h-6 text-emerald-600 dark:text-emerald-400" fill="none"
                                                    stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 class="text-lg font-bold text-gray-900 dark:text-white">Precios y
                                                    Stock</h2>
                                                <p class="text-sm text-gray-500 dark:text-gray-400">Información
                                                    financiera</p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="p-6 space-y-6">
                                        <!-- Precio Compra -->
                                        <div>
                                            <label
                                                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                Precio de Compra <span class="text-red-500">*</span>
                                            </label>
                                            <div class="relative">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="text-gray-500 font-medium">$</span>
                                                </div>
                                                <input v-model="productForm.precio_compra" type="number" step="0.01"
                                                    required
                                                    class="w-full pl-10 pr-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                    placeholder="0.00">
                                            </div>
                                        </div>

                                        <!-- Precio Venta -->
                                        <div>
                                            <label
                                                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                Precio de Venta <span class="text-red-500">*</span>
                                            </label>
                                            <div class="relative">
                                                <div
                                                    class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                    <span class="text-gray-500 font-medium">$</span>
                                                </div>
                                                <input v-model="productForm.precio_venta" type="number" step="0.01"
                                                    required
                                                    class="w-full pl-10 pr-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                    placeholder="0.00">
                                            </div>
                                        </div>

                                        <!-- Stock Mínimo y Máximo -->
                                        <div class="grid grid-cols-2 gap-4">
                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Stock Mínimo
                                                </label>
                                                <input v-model="productForm.stock_minimo" type="number"
                                                    class="w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                    placeholder="5">
                                            </div>

                                            <div>
                                                <label
                                                    class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Stock Máximo
                                                </label>
                                                <input v-model="productForm.stock_maximo" type="number"
                                                    class="w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-colors"
                                                    placeholder="100">
                                            </div>
                                        </div>

                                        <!-- Margen Calculado -->
                                        <div v-if="productForm.precio_compra && productForm.precio_venta"
                                            class="bg-gradient-to-r from-emerald-50 to-green-50 dark:from-emerald-900/20 dark:to-green-900/20 rounded-xl p-4">
                                            <div class="flex items-center justify-between">
                                                <div>
                                                    <p class="text-sm font-medium text-gray-700 dark:text-gray-300">
                                                        Margen de Ganancia</p>
                                                    <p class="text-xs text-gray-500">Basado en precios ingresados</p>
                                                </div>
                                                <span :class="[
                                                    'text-lg font-bold',
                                                    parseFloat(productForm.precio_venta) > parseFloat(productForm.precio_compra)
                                                        ? 'text-emerald-600 dark:text-emerald-400'
                                                        : 'text-red-600 dark:text-red-400'
                                                ]">
                                                    {{
                                                        ((parseFloat(productForm.precio_venta) -
                                                            parseFloat(productForm.precio_compra)) /
                                                            parseFloat(productForm.precio_compra) * 100).toFixed(1)
                                                    }}%
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Botones de Acción Móvil -->
                        <div
                            class="lg:hidden fixed bottom-0 left-0 right-0 p-4 bg-white/95 dark:bg-gray-900/95 backdrop-blur-lg border-t border-gray-200 dark:border-gray-800 shadow-2xl">
                            <div class="flex space-x-3">
                                <button @click="$router.push('/products')"
                                    class="flex-1 px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-700 text-gray-700 dark:text-gray-300 font-medium hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                                    Cancelar
                                </button>
                                <button @click="handleSaveProduct" :disabled="isUploading || isLoading"
                                    class="flex-1 px-4 py-3 rounded-lg bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-medium hover:from-blue-700 hover:to-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg">
                                    <span v-if="isUploading" class="flex items-center justify-center space-x-2">
                                        <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor"
                                                stroke-width="4"></circle>
                                            <path class="opacity-75" fill="currentColor"
                                                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                            </path>
                                        </svg>
                                        <span>Guardando...</span>
                                    </span>
                                    <span v-else>Guardar</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </UCard>
            </div>
        </template>
    </UDashboardPanel>
</template>
