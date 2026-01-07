<script setup lang="ts">
const { createProduct, getCategories, getBrands } = useProducts()
const toast = useToast()

definePageMeta({
    layout: 'dashboard',
    middleware: ['auth']
})

const { data: categoriesData } = await getCategories()
const { data: brandsData } = await getBrands()

const categories = computed(() => categoriesData.value || [])
const brands = computed(() => brandsData.value || [])

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

async function handleSaveProduct() {
    try {
        const { data, error } = await createProduct(productForm.value)

        if (error.value) throw error.value

        toast.add({ title: 'Producto creado', color: 'green' })

        // Redirigir a la lista o a agregar variantes
        navigateTo(`/products/variants/create?product_id=${data.value?.producto_id}`)
    } catch (error: any) {
        toast.add({
            title: 'Error',
            description: error.message || 'Error al crear el producto',
            color: 'red'
        })
    }
}
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
                    <UButton label="Guardar producto" color="primary" @click="handleSaveProduct" />
                </template>
            </UDashboardNavbar>
        </template>

        <template #body>
            <div class="max-w-3xl mx-auto">
                <UCard>
                    <form @submit.prevent="handleSaveProduct" class="space-y-6">
                        <!-- Información Básica -->
                        <div class="space-y-4">
                            <h3 class="text-lg font-semibold">Información Básica</h3>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="SKU" required>
                                    <UInput v-model="productForm.sku" placeholder="PROD-001" required />
                                </UFormGroup>

                                <UFormGroup label="Nombre" required>
                                    <UInput v-model="productForm.nombre" placeholder="Nombre del producto" required />
                                </UFormGroup>

                                <UFormGroup label="Categoría" required>
                                    <USelect v-model="productForm.categoria_id" :options="categories"
                                        option-attribute="nombre" value-attribute="categoria_id"
                                        placeholder="Seleccionar categoría" required />
                                </UFormGroup>

                                <UFormGroup label="Marca">
                                    <USelect v-model="productForm.marca_id" :options="brands" option-attribute="nombre"
                                        value-attribute="marca_id" placeholder="Seleccionar marca" />
                                </UFormGroup>
                            </div>
                        </div>

                        <!-- Detalles del Producto -->
                        <div class="space-y-4">
                            <h3 class="text-lg font-semibold">Detalles del Producto</h3>

                            <UFormGroup label="Descripción">
                                <UTextarea v-model="productForm.descripcion" placeholder="Descripción del producto"
                                    rows="3" />
                            </UFormGroup>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Género">
                                    <USelect v-model="productForm.genero"
                                        :options="['Hombre', 'Mujer', 'Unisex', 'Niño', 'Niña']"
                                        placeholder="Seleccionar género" />
                                </UFormGroup>

                                <UFormGroup label="Temporada">
                                    <USelect v-model="productForm.temporada"
                                        :options="['Primavera', 'Verano', 'Otoño', 'Invierno', 'Todo el año']"
                                        placeholder="Seleccionar temporada" />
                                </UFormGroup>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Material Principal">
                                    <UInput v-model="productForm.material_principal" placeholder="Ej: Algodón 100%" />
                                </UFormGroup>

                                <UFormGroup label="Instrucciones de Cuidado">
                                    <UTextarea v-model="productForm.cuidados"
                                        placeholder="Instrucciones de lavado y cuidado" rows="2" />
                                </UFormGroup>
                            </div>
                        </div>

                        <!-- Precios y Stock -->
                        <div class="space-y-4">
                            <h3 class="text-lg font-semibold">Precios y Stock</h3>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <UFormGroup label="Precio Compra" required>
                                    <UInput v-model="productForm.precio_compra" type="number" step="0.01"
                                        placeholder="0.00" required />
                                </UFormGroup>

                                <UFormGroup label="Precio Venta" required>
                                    <UInput v-model="productForm.precio_venta" type="number" step="0.01"
                                        placeholder="0.00" required />
                                </UFormGroup>

                                <UFormGroup label="Stock Mínimo">
                                    <UInput v-model="productForm.stock_minimo" type="number" placeholder="5" />
                                </UFormGroup>

                                <UFormGroup label="Stock Máximo">
                                    <UInput v-model="productForm.stock_maximo" type="number" placeholder="100" />
                                </UFormGroup>
                            </div>
                        </div>
                    </form>
                </UCard>
            </div>
        </template>
    </UDashboardPanel>
</template>