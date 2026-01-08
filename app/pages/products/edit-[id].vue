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
                        @click="saveProduct" />
                </template>
            </UDashboardNavbar>
        </template>

        <template #body>
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
                    <UButton color="primary" :disabled="loading || !isFormValid" :loading="loading"
                        @click="saveProduct">
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
            <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-1">
                <!-- Columna izquierda -->
                <div class="lg:col-span-2 space-y-6">
                    <!-- Información básica -->
                    <UCard>
                        <!-- Header -->
                        <template #header>
                            <div>
                                <h2 class="text-xl font-bold text-gray-800 dark:text-gray-100">Información Básica</h2>
                                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                                    Complete los datos principales del producto
                                </p>
                            </div>
                        </template>

                        <div class="space-y-6 p-6">
                            <!-- SKU y Nombre -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <!-- SKU -->
                                <div class="space-y-2">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                        SKU <span class="text-red-500">*</span>
                                        <span v-if="errors.sku" class="text-red-500 text-xs font-normal ml-2">{{
                                            errors.sku
                                        }}</span>
                                    </label>
                                    <div class="relative">
                                        <div
                                            class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                                stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                                            </svg>
                                        </div>
                                        <input v-model="form.sku" type="text" placeholder="Ej: PROD-001"
                                            class="block w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400" />
                                    </div>
                                    <p class="text-xs text-gray-400 dark:text-gray-500 italic">Identificador único del
                                        producto</p>
                                </div>

                                <!-- Nombre -->
                                <div class="space-y-2">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                        Nombre del Producto <span class="text-red-500">*</span>
                                        <span v-if="errors.nombre" class="text-red-500 text-xs font-normal ml-2">{{
                                            errors.nombre
                                        }}</span>
                                    </label>
                                    <div class="relative">
                                        <div
                                            class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                                stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                                            </svg>
                                        </div>
                                        <input v-model="form.nombre" type="text"
                                            placeholder="Ej: Camisa Oxford Slim Fit"
                                            class="block w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400" />
                                    </div>
                                </div>
                            </div>

                            <!-- Descripción -->
                            <div class="space-y-2 relative">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                    Descripción
                                    <span v-if="errors.descripcion" class="text-red-500 text-xs font-normal ml-2">{{
                                        errors.descripcion }}</span>
                                </label>
                                <textarea v-model="form.descripcion" rows="4"
                                    placeholder="Ingrese una descripción detallada del producto..."
                                    class="block w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400 resize-none"></textarea>
                                <div class="absolute bottom-3 right-3">
                                    <span
                                        class="text-xs text-gray-400 dark:text-gray-500 bg-white dark:bg-gray-800 px-2 py-1 rounded">
                                        {{ form.descripcion?.length || 0 }}/500
                                    </span>
                                </div>
                            </div>

                            <!-- Categoría y Marca -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <!-- Categoría -->
                                <div class="space-y-2 relative">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                        Categoría <span class="text-red-500">*</span>
                                        <span v-if="errors.categoria_id"
                                            class="text-red-500 text-xs font-normal ml-2">{{
                                                errors.categoria_id }}</span>
                                    </label>
                                    <select v-model="form.categoria_id"
                                        class="block w-full pl-10 pr-10 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400 appearance-none">
                                        <option value="">Seleccionar categoría</option>
                                        <option v-for="category in categoryOptions" :key="category.value"
                                            :value="category.value">{{
                                                category.label }}</option>
                                    </select>
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                        </svg>
                                    </div>
                                    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>

                                <!-- Marca -->
                                <div class="space-y-2 relative">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                        Marca <span class="text-red-500">*</span>
                                        <span v-if="errors.marca_id" class="text-red-500 text-xs font-normal ml-2">{{
                                            errors.marca_id }}</span>
                                    </label>
                                    <select v-model="form.marca_id"
                                        class="block w-full pl-10 pr-10 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400 appearance-none">
                                        <option value="">Seleccionar marca</option>
                                        <option v-for="brand in brandOptions" :key="brand.value" :value="brand.value">{{
                                            brand.label
                                        }}</option>
                                    </select>
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                        </svg>
                                    </div>
                                    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>
                            </div>

                            <!-- Género y Temporada -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <!-- Género -->
                                <div class="space-y-2 relative">
                                    <label
                                        class="block text-sm font-medium text-gray-700 dark:text-gray-300">Género</label>
                                    <select v-model="form.genero"
                                        class="block w-full pl-10 pr-10 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400 appearance-none">
                                        <option value="">Sin especificar</option>
                                        <option v-for="gender in genderOptions" :key="gender.value"
                                            :value="gender.value">{{
                                                gender.label }}</option>
                                    </select>
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                        </svg>
                                    </div>
                                    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>

                                <!-- Temporada -->
                                <div class="space-y-2 relative">
                                    <label
                                        class="block text-sm font-medium text-gray-700 dark:text-gray-300">Temporada</label>
                                    <select v-model="form.temporada"
                                        class="block w-full pl-10 pr-10 py-3 border border-gray-300 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 hover:border-blue-400 appearance-none">
                                        <option value="">Todo el año</option>
                                        <option v-for="season in seasonOptions" :key="season.value"
                                            :value="season.value">{{
                                                season.label }}</option>
                                    </select>
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                                        </svg>
                                    </div>
                                    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                        <svg class="h-5 w-5 text-gray-400 dark:text-gray-500" fill="none"
                                            stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>
                            </div>

                            <!-- Indicadores de estado -->
                            <div
                                class="flex items-center justify-between pt-4 mt-6 border-t border-gray-100 dark:border-gray-700">
                                <div class="flex items-center space-x-2">
                                    <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                                    <span class="text-sm text-gray-500 dark:text-gray-400">Formulario activo</span>
                                </div>
                                <div class="text-xs text-gray-400 dark:text-gray-500">
                                    Todos los campos marcados con <span class="text-red-500">*</span> son obligatorios
                                </div>
                            </div>
                        </div>
                    </UCard>


                    <!-- Precios y Stock -->
                    <UCard>
                        <!-- Header -->
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800 dark:text-gray-100">Precios y Stock</h2>
                        </template>

                        <div class="space-y-6">
                            <!-- Precios -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Precio de
                                        Compra
                                        (MXN)</label>
                                    <div class="flex items-center">
                                        <span class="text-gray-500 dark:text-gray-400 mr-2">$</span>
                                        <input type="number" min="0" step="0.01" v-model="form.precio_compra"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <p v-if="errors.precio_compra" class="text-red-500 text-sm mt-1">{{
                                        errors.precio_compra }}</p>
                                </div>

                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Precio de
                                        Venta
                                        (MXN)</label>
                                    <div class="flex items-center">
                                        <span class="text-gray-500 dark:text-gray-400 mr-2">$</span>
                                        <input type="number" min="0" step="0.01" v-model="form.precio_venta"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <p v-if="errors.precio_venta" class="text-red-500 text-sm mt-1">{{
                                        errors.precio_venta }}</p>
                                </div>
                            </div>

                            <!-- Stock -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Stock
                                        Mínimo</label>
                                    <input type="number" min="0" v-model="form.stock_minimo"
                                        class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Stock
                                        Máximo</label>
                                    <input type="number" min="0" v-model="form.stock_maximo"
                                        class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                            </div>

                            <!-- Divider -->
                            <div class="border-t border-gray-200 dark:border-gray-700 my-6 relative">
                                <span
                                    class="absolute -top-3 left-1/2 -translate-x-1/2 bg-white dark:bg-gray-900 px-2 text-gray-500 dark:text-gray-400 text-sm">
                                    Configuración de Promoción
                                </span>
                            </div>

                            <!-- Activar promoción -->
                            <div class="flex items-center justify-between mb-4">
                                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Activar
                                    promoción</span>
                                <input type="checkbox" v-model="form.es_promocion" @change="togglePromotion"
                                    class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- Campos de promoción -->
                            <div v-if="form.es_promocion" class="space-y-4 animate-fadeIn">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label
                                            class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Porcentaje
                                            de
                                            Descuento</label>
                                        <div class="flex items-center">
                                            <input type="number" min="0" max="100" step="0.1"
                                                v-model="form.porcentaje_descuento"
                                                class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                            <span class="text-gray-500 dark:text-gray-400 ml-2">%</span>
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Precio
                                            Promocional</label>
                                        <div class="flex items-center">
                                            <span class="text-gray-500 dark:text-gray-400 mr-2">$</span>
                                            <input type="text" :value="promotionalPrice" readonly
                                                class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-100 cursor-not-allowed" />
                                        </div>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Fecha
                                            Inicio</label>
                                        <input type="date" v-model="form.fecha_inicio_promocion"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Fecha
                                            Fin</label>
                                        <input type="date" v-model="form.fecha_fin_promocion"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </UCard>


                    <!-- Características -->
                    <UCard>
                        <!-- Header -->
                        <template #header>
                            <h2 class="text-xl font-semibold text-gray-800 dark:text-gray-100">Características</h2>
                        </template>

                        <div class="space-y-6">
                            <!-- Material Principal -->
                            <div>
                                <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Material
                                    Principal</label>
                                <input type="text" v-model="form.material_principal"
                                    placeholder="Ej: Algodón 100%, Poliéster, Cuero..."
                                    class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- Instrucciones de Cuidado -->
                            <div>
                                <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Instrucciones de
                                    Cuidado</label>
                                <textarea v-model="form.cuidados"
                                    placeholder="Ej: Lavar a máquina en agua fría, no usar blanqueador..." rows="3"
                                    class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"></textarea>
                            </div>

                            <!-- Peso y Dimensiones -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Peso -->
                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Peso
                                        (gramos)</label>
                                    <div class="flex items-center">
                                        <input type="number" min="0" v-model="form.peso"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                        <span class="text-gray-500 dark:text-gray-400 ml-2">g</span>
                                    </div>
                                </div>

                                <!-- Dimensiones -->
                                <div>
                                    <label class="block text-gray-700 dark:text-gray-300 font-medium mb-1">Dimensiones
                                        (cm)</label>
                                    <div class="grid grid-cols-3 gap-2">
                                        <input type="number" min="0" v-model="form.largo" placeholder="Largo"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                        <input type="number" min="0" v-model="form.ancho" placeholder="Ancho"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                        <input type="number" min="0" v-model="form.alto" placeholder="Alto"
                                            class="w-full border border-gray-300 dark:border-gray-600 rounded px-3 py-2 bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                </div>
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
                                    <span class="font-medium text-gray-900">{{ variant.talla }} - {{
                                        variant.color_nombre
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
                            <UButton block color="red" variant="outline" icon="i-heroicons-trash"
                                @click="confirmDelete">
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

        </template>
    </UDashboardPanel>
</template>


<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from '#imports'

const { createProduct, getCategories, getBrands, updateProduct } = useProducts()
definePageMeta({
    layout: 'dashboard',
    middleware: ['auth']
})
const route = useRoute()
const router = useRouter()
const toast = useToast()
const config = useRuntimeConfig()


const isLoading = ref(false)
const isUploading = ref(false)

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
    // material_principal: '',
    // cuidados: '',
    precio_compra: 0,
    precio_venta: 0,
    stock_minimo: 0,
    stock_maximo: 0,
    es_promocion: false,
    porcentaje_descuento: 0,
    fecha_inicio_promocion: '',
    fecha_fin_promocion: '',
    motivo_cambio: 'Otro',
    // imagen_url: '',
    // galeria_imagenes: [],
    // activo: true,
    // peso: null,
    // largo: null,
    // ancho: null,
    // alto: null
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

        const apiBase = useRuntimeConfig().public.apiBaseUrl


        const { data, error } = await useFetch(`/products/${route.params.id}`, {
            baseURL: apiBase
        })

        if (error.value) {
            console.error('Error al traer producto desde API:', error.value)
        }

        if (data.value?.data) {
            product.value = data.value.data

            // Llenar el formulario con los datos del producto
            Object.keys(form.value).forEach(key => {
                if (product.value[key] !== undefined) {
                    form.value[key] = product.value[key]
                }
            })
            console.log('Formulario llenado:', form.value)

            // Asegurar que galeria_imagenes sea un array
            // if (!Array.isArray(form.value.galeria_imagenes)) {
            //     form.value.galeria_imagenes = []
            //     console.log('Galería inicializada como array vacío')
            // }
        } else {
            console.warn('No se encontró data en la respuesta del producto')
        }
    } catch (err) {
        error.value = 'Error al cargar el producto'
        console.error('Excepción en fetchProduct:', err)
        toast.add({
            title: 'Error',
            description: 'No se pudo cargar la información del producto',
            color: 'red'
        })
    } finally {
        loadingInitial.value = false
        console.log('fetchProduct finalizado, loadingInitial =', loadingInitial.value)
    }
}

const fetchCategories = async () => {
    try {
        const { data: catRes } = await getCategories()
        if (catRes.value?.success) categories.value = catRes.value.data ?? []
    } catch (err) {
        console.error('Excepción fetchCategories:', err)
    }
}

const fetchBrands = async () => {
    try {
        const { data: brandRes } = await getBrands()
        if (brandRes.value?.success) brands.value = brandRes.value.data ?? []
    } catch (err) {
        console.error('Excepción fetchBrands:', err)
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
    console.group('🚀 saveProduct')
    loading.value = true
    error.value = ''

    const payload = {
        ...form.value,
        categoria_id: Number(form.value.categoria_id),
        marca_id: Number(form.value.marca_id),
        precio_compra: Number(form.value.precio_compra),
        precio_venta: Number(form.value.precio_venta),
        stock_minimo: Number(form.value.stock_minimo),
        stock_maximo: Number(form.value.stock_maximo),
        porcentaje_descuento: Number(form.value.porcentaje_descuento),
        motivo_cambio: ['Ajuste estacional', 'Cambio costo', 'Promoción', 'Competencia', 'Otro']
            .includes(form.value.motivo_cambio)
            ? form.value.motivo_cambio
            : 'Ajuste estacional'
    }

    console.log('📤 Payload:', payload)

    const { data, error: updateError, status } =
        await updateProduct(Number(route.params.id), payload)

    console.log('📥 Status:', status.value)
    console.log('📥 Data:', data.value)
    console.log('❌ Error:', updateError.value)

    // ⛔ ERROR BACKEND
    if (updateError.value) {
        error.value = updateError.value.data?.message || 'Error al guardar el producto'

        toast.add({
            title: 'Error',
            description: error.value,
            color: 'red'
        })

        loading.value = false
        console.groupEnd()
        return
    }

    // ✅ OK
    form.value = data.value.data
    success.value = true

    toast.add({
        title: 'Éxito',
        description: 'Producto actualizado correctamente',
        color: 'green'
    })

    setTimeout(() => (success.value = false), 3000)
    loading.value = false
    console.groupEnd()
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

            const { data } = await useFetch('/products', {
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

        await useFetch(`/products/${route.params.id}`, {
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