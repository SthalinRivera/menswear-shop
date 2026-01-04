<script setup lang="ts">
import type { TableColumn } from '@nuxt/ui'
import { upperFirst } from 'scule'
import { getPaginationRowModel } from '@tanstack/table-core'
import type { Row } from '@tanstack/table-core'
import type { Product, Category, Brand } from '~/types/product'

const UAvatar = resolveComponent('UAvatar')
const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const UCheckbox = resolveComponent('UCheckbox')
const UTooltip = resolveComponent('UTooltip')
const UModal = resolveComponent('UModal')
const UInput = resolveComponent('UInput')
const USelect = resolveComponent('USelect')
const UTextarea = resolveComponent('UTextarea')

const toast = useToast()
const table = useTemplateRef('table')

const { getProducts, getCategories, getBrands, deleteProduct } = useProducts()
definePageMeta({
  layout: 'dashboard',
  middleware: ['guest'] // Asegúrate de que solo usuarios no autenticados puedan acceder
})

// Filtros
const searchQuery = ref('')
const selectedCategory = ref('all')
const selectedBrand = ref('all')
const selectedGender = ref('all')
const promotionFilter = ref('all')
const priceRange = ref({ min: '', max: '' })
const statusFilter = ref('active')
const sortBy = ref('fecha_creacion')
const sortOrder = ref('desc')

const columnFilters = ref([])
const columnVisibility = ref()
const rowSelection = ref({})

// Paginación
const pagination = ref({
  pageIndex: 0,
  pageSize: 20
})

// Datos
const { data: productsData, refresh, pending } = await getProducts({
  page: 1,
  limit: 20,
  sortBy: sortBy.value,
  sortOrder: sortOrder.value
})

const { data: categoriesData } = await getCategories()
const { data: brandsData } = await getBrands()

const data = computed(() => productsData.value?.data || [])
const categories = computed(() => categoriesData.value || [])
const brands = computed(() => brandsData.value || [])

// Modal para agregar/editar
const showProductModal = ref(false)
const editingProduct = ref<Product | null>(null)
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

// Modal para variantes
const showVariantModal = ref(false)
const selectedProduct = ref<Product | null>(null)
const variantForm = ref({
  talla: '',
  color_nombre: '',
  color_hex: '',
  codigo_barras: '',
  ubicacion_almacen: ''
})

// Modal para ajustar stock
const showStockModal = ref(false)
const selectedVariant = ref<any>(null)
const stockForm = ref({
  cantidad: 1,
  almacen_id: '',
  tipo_movimiento: 'Entrada',
  motivo: 'Ajuste manual',
  costo_unitario: ''
})

// Funciones
function openAddProduct() {
  editingProduct.value = null
  productForm.value = {
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
  }
  showProductModal.value = true
}

function openEditProduct(product: Product) {
  editingProduct.value = product
  productForm.value = {
    sku: product.sku,
    nombre: product.nombre,
    descripcion: product.descripcion,
    categoria_id: product.categoria_id.toString(),
    marca_id: product.marca_id.toString(),
    genero: product.genero,
    temporada: product.temporada,
    material_principal: product.material_principal,
    cuidados: product.cuidados,
    precio_compra: product.precio_compra,
    precio_venta: product.precio_venta,
    impuesto_porcentaje: product.impuesto_porcentaje,
    stock_minimo: product.stock_minimo,
    stock_maximo: product.stock_maximo
  }
  showProductModal.value = true
}

function openAddVariant(product: Product) {
  selectedProduct.value = product
  variantForm.value = {
    talla: '',
    color_nombre: '',
    color_hex: '',
    codigo_barras: '',
    ubicacion_almacen: ''
  }
  showVariantModal.value = true
}

function openAdjustStock(variant: any) {
  selectedVariant.value = variant
  stockForm.value = {
    cantidad: 1,
    almacen_id: '',
    tipo_movimiento: 'Entrada',
    motivo: 'Ajuste manual',
    costo_unitario: ''
  }
  showStockModal.value = true
}

async function handleSaveProduct() {
  try {
    const { createProduct, updateProduct } = useProducts()

    if (editingProduct.value) {
      const { data, error } = await updateProduct(editingProduct.value.producto_id, productForm.value)
      if (error.value) throw error.value
      toast.add({ title: 'Producto actualizado', color: 'green' })
    } else {
      const { data, error } = await createProduct(productForm.value)
      if (error.value) throw error.value
      toast.add({ title: 'Producto creado', color: 'green' })
    }

    showProductModal.value = false
    refresh()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.message || 'Error al guardar el producto',
      color: 'red'
    })
  }
}

async function handleSaveVariant() {
  try {
    const { createVariant } = useProducts()

    if (!selectedProduct.value) return

    const { data, error } = await createVariant(
      selectedProduct.value.producto_id,
      variantForm.value
    )

    if (error.value) throw error.value

    toast.add({ title: 'Variante creada', color: 'green' })
    showVariantModal.value = false
    refresh()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.message || 'Error al crear la variante',
      color: 'red'
    })
  }
}

async function handleAdjustStock() {
  try {
    const { updateVariantStock } = useProducts()

    if (!selectedVariant.value) return

    const { data, error } = await updateVariantStock(
      selectedVariant.value.variante_id,
      stockForm.value
    )

    if (error.value) throw error.value

    toast.add({ title: 'Stock actualizado', color: 'green' })
    showStockModal.value = false
    refresh()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.message || 'Error al ajustar el stock',
      color: 'red'
    })
  }
}

async function handleDeleteProduct(product: Product) {
  const confirmed = confirm(`¿Estás seguro de eliminar el producto "${product.nombre}"?`)
  if (!confirmed) return

  try {
    const { error } = await deleteProduct(product.producto_id)
    if (error.value) throw error.value

    toast.add({ title: 'Producto eliminado', color: 'green' })
    refresh()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.message || 'Error al eliminar el producto',
      color: 'red'
    })
  }
}

function getRowItems(row: Row<Product>) {
  return [
    { type: 'label', label: 'Acciones' },
    {
      label: 'Copiar SKU',
      icon: 'i-lucide-copy',
      onSelect() {
        navigator.clipboard.writeText(row.original.sku)
        toast.add({ title: 'SKU copiado', color: 'green' })
      }
    },
    {
      label: 'Ver detalles',
      icon: 'i-lucide-eye',
      onSelect() {
        navigateTo(`/products/${row.original.producto_id}`)
      }
    },
    {
      label: 'Editar producto',
      icon: 'i-lucide-edit',
      onSelect() {
        openEditProduct(row.original)
      }
    },
    {
      label: 'Agregar variante',
      icon: 'i-lucide-plus',
      onSelect() {
        openAddVariant(row.original)
      }
    },
    {
      label: row.original.activo ? 'Desactivar' : 'Activar',
      icon: row.original.activo ? 'i-lucide-toggle-left' : 'i-lucide-toggle-right',
      onSelect() {
        // Lógica para activar/desactivar
        toast.add({
          title: row.original.activo ? 'Producto desactivado' : 'Producto activado',
          color: 'green'
        })
      }
    },
    { type: 'separator' },
    {
      label: 'Eliminar producto',
      icon: 'i-lucide-trash',
      color: 'error',
      onSelect() {
        handleDeleteProduct(row.original)
      }
    }
  ]
}

const columns: TableColumn<Product>[] = [
  {
    id: 'select',
    header: ({ table }) =>
      h(UCheckbox, {
        'modelValue': table.getIsSomePageRowsSelected()
          ? 'indeterminate'
          : table.getIsAllPageRowsSelected(),
        'onUpdate:modelValue': (value: boolean | 'indeterminate') =>
          table.toggleAllPageRowsSelected(!!value),
        'ariaLabel': 'Seleccionar todos'
      }),
    cell: ({ row }) =>
      h(UCheckbox, {
        'modelValue': row.getIsSelected(),
        'onUpdate:modelValue': (value: boolean | 'indeterminate') => row.toggleSelected(!!value),
        'ariaLabel': 'Seleccionar fila'
      })
  },
  {
    accessorKey: 'sku',
    header: 'SKU',
    cell: ({ row }) =>
      h('div', { class: 'font-mono text-xs' }, row.original.sku)
  },
  {
    accessorKey: 'nombre',
    header: 'Producto',
    cell: ({ row }) => {
      return h('div', { class: 'flex flex-col gap-1' }, [
        h('p', { class: 'font-medium text-highlighted line-clamp-1' }, row.original.nombre),
        h('p', { class: 'text-xs text-muted line-clamp-2' }, row.original.descripcion || 'Sin descripción')
      ])
    }
  },
  {
    accessorKey: 'categoria_nombre',
    header: 'Categoría'
  },
  {
    accessorKey: 'marca_nombre',
    header: 'Marca'
  },
  {
    accessorKey: 'stock_total',
    header: 'Stock',
    cell: ({ row }) => {
      const stock = Number(row.original.stock_total)
      const minStock = row.original.stock_minimo

      let color = 'green'
      let icon = 'i-lucide-check-circle'
      let badgeColor: 'green' | 'yellow' | 'red' = 'green'

      if (stock === 0) {
        color = 'red'
        badgeColor = 'red'
        icon = 'i-lucide-x-circle'
      } else if (stock <= minStock) {
        color = 'yellow'
        badgeColor = 'yellow'
        icon = 'i-lucide-alert-circle'
      }

      return h('div', { class: 'flex items-center gap-2' }, [
        h('i', { class: `${icon} text-${color}-500 text-sm` }),
        h(UBadge, {
          variant: 'subtle',
          color: badgeColor,
          class: 'font-medium'
        }, () => stock.toString())
      ])
    }
  },
  {
    accessorKey: 'precio_final',
    header: 'Precio',
    cell: ({ row }) => {
      const price = parseFloat(row.original.precio_final)
      const promotionPrice = row.original.es_promocion && row.original.precio_promocion
        ? parseFloat(row.original.precio_promocion)
        : null

      return h('div', { class: 'flex flex-col gap-1' }, [
        promotionPrice ?
          h('div', { class: 'flex items-center gap-2' }, [
            h('span', { class: 'text-sm line-through text-muted' }, `$${price.toFixed(2)}`),
            h('span', { class: 'font-bold text-green-600' }, `$${promotionPrice.toFixed(2)}`)
          ]) :
          h('span', { class: 'font-medium' }, `$${price.toFixed(2)}`),
        row.original.es_promocion &&
        h(UBadge, {
          variant: 'subtle',
          color: 'green',
          class: 'text-xs'
        }, () => `-${row.original.porcentaje_descuento}%`)
      ])
    }
  },
  {
    accessorKey: 'variantes',
    header: 'Variantes',
    cell: ({ row }) => {
      const variants = row.original.variantes?.length || 0
      const colors = new Set(row.original.variantes?.map(v => v.color_nombre)).size
      const sizes = new Set(row.original.variantes?.map(v => v.talla)).size

      return h(UTooltip, {
        content: `${variants} variantes • ${colors} colores • ${sizes} tallas`
      }, () =>
        h('div', { class: 'flex items-center gap-1 text-sm text-muted' }, [
          h('i', { class: 'i-lucide-palette' }),
          h('span', {}, `${colors}C / ${sizes}T`)
        ])
      )
    }
  },
  {
    accessorKey: 'activo',
    header: 'Estado',
    cell: ({ row }) => {
      const color = row.original.activo ? 'green' as const : 'gray' as const
      const text = row.original.activo ? 'Activo' : 'Inactivo'

      return h(UBadge, {
        variant: row.original.activo ? 'solid' : 'subtle',
        color
      }, () => text)
    }
  },
  {
    id: 'actions',
    cell: ({ row }) => {
      return h(
        'div',
        { class: 'text-right' },
        h(
          UDropdownMenu,
          {
            content: { align: 'end' },
            items: getRowItems(row)
          },
          () =>
            h(UButton, {
              icon: 'i-lucide-ellipsis-vertical',
              color: 'neutral',
              variant: 'ghost',
              class: 'ml-auto'
            })
        )
      )
    }
  }
]
const loadProducts = async () => {
  const params: any = {
    page: pagination.value.pageIndex + 1,
    limit: pagination.value.pageSize,
    sortBy: sortBy.value,
    sortOrder: sortOrder.value
  }

  if (searchQuery.value) params.q = searchQuery.value
  if (selectedCategory.value !== 'all') params.categoria_id = selectedCategory.value
  if (selectedBrand.value !== 'all') params.marca_id = selectedBrand.value
  if (selectedGender.value !== 'all') params.genero = selectedGender.value
  if (promotionFilter.value !== 'all') params.enPromocion = promotionFilter.value === 'promo'
  if (priceRange.value.min) params.minPrice = priceRange.value.min
  if (priceRange.value.max) params.maxPrice = priceRange.value.max
  if (statusFilter.value !== 'all') params.activo = statusFilter.value === 'active'

  await refresh({ params })
}
// Watchers para filtros
watch(
  [
    searchQuery,
    selectedCategory,
    selectedBrand,
    selectedGender,
    promotionFilter,
    priceRange,
    statusFilter,
    sortBy,
    sortOrder,
    () => pagination.value.pageIndex,
    () => pagination.value.pageSize
  ],
  loadProducts
)
</script>

<template>
  <UDashboardPanel id="products">
    <template #header>
      <UDashboardNavbar title="Productos">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>

        <template #right>
          <UButton label="Agregar producto" icon="i-lucide-plus" color="primary" @click="openAddProduct" />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <!-- Filtros -->
      <div class="space-y-4 mb-6 p-4 bg-elevated/50 rounded-lg">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
          <UInput v-model="searchQuery" icon="i-lucide-search" placeholder="Buscar productos..."
            class="lg:col-span-2" />

          <USelect v-model="selectedCategory"
            :options="[{ value: 'all', label: 'Todas las categorías' }, ...categories]" option-attribute="nombre"
            value-attribute="categoria_id" placeholder="Categoría" />

          <USelect v-model="selectedBrand" :options="[{ value: 'all', label: 'Todas las marcas' }, ...brands]"
            option-attribute="nombre" value-attribute="marca_id" placeholder="Marca" />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-3">
          <USelect v-model="selectedGender" :options="[
            { value: 'all', label: 'Todos los géneros' },
            { value: 'Hombre', label: 'Hombre' },
            { value: 'Mujer', label: 'Mujer' },
            { value: 'Unisex', label: 'Unisex' },
            { value: 'Niño', label: 'Niño' },
            { value: 'Niña', label: 'Niña' }
          ]" placeholder="Género" />

          <USelect v-model="promotionFilter" :options="[
            { value: 'all', label: 'Todos' },
            { value: 'promo', label: 'En promoción' },
            { value: 'no-promo', label: 'Sin promoción' }
          ]" placeholder="Promoción" />

          <USelect v-model="statusFilter" :options="[
            { value: 'all', label: 'Todos' },
            { value: 'active', label: 'Activos' },
            { value: 'inactive', label: 'Inactivos' }
          ]" placeholder="Estado" />

          <UInput v-model="priceRange.min" icon="i-lucide-dollar-sign" placeholder="Precio min" type="number" />

          <UInput v-model="priceRange.max" icon="i-lucide-dollar-sign" placeholder="Precio max" type="number" />
        </div>

        <div class="flex justify-between items-center">
          <div class="flex items-center gap-2">
            <span class="text-sm text-muted">Ordenar por:</span>
            <USelect v-model="sortBy" :options="[
              { value: 'fecha_creacion', label: 'Fecha creación' },
              { value: 'nombre', label: 'Nombre' },
              { value: 'precio_final', label: 'Precio' },
              { value: 'stock_total', label: 'Stock' }
            ]" size="sm" class="w-40" />
            <UButton :icon="sortOrder === 'asc' ? 'i-lucide-arrow-up' : 'i-lucide-arrow-down'" color="neutral"
              variant="ghost" size="sm" @click="sortOrder = sortOrder === 'asc' ? 'desc' : 'asc'" />
          </div>

          <div class="flex items-center gap-2">
            <UDropdownMenu :items="table?.tableApi
              ?.getAllColumns()
              .filter((column: any) => column.getCanHide())
              .map((column: any) => ({
                label: upperFirst(column.id),
                type: 'checkbox' as const,
                checked: column.getIsVisible(),
                onUpdateChecked(checked: boolean) {
                  table?.tableApi?.getColumn(column.id)?.toggleVisibility(!!checked)
                },
                onSelect(e?: Event) {
                  e?.preventDefault()
                }
              }))
              " :content="{ align: 'end' }">
              <UButton label="Columnas" color="neutral" variant="outline" size="sm"
                trailing-icon="i-lucide-settings-2" />
            </UDropdownMenu>

            <UButton icon="i-lucide-refresh-ccw" color="neutral" variant="ghost" size="sm" :loading="pending"
              @click="refresh()" />
          </div>
        </div>
      </div>

      <!-- Tabla -->
      <UTable ref="table" v-model:column-filters="columnFilters" v-model:column-visibility="columnVisibility"
        v-model:row-selection="rowSelection" v-model:pagination="pagination" :pagination-options="{
          getPaginationRowModel: getPaginationRowModel()
        }" class="shrink-0" :data="data" :columns="columns" :loading="pending" :ui="{
          base: 'border-separate border-spacing-0',
          thead: '[&>tr]:bg-elevated/50',
          tbody: '[&>tr]:last:[&>td]:border-b-0',
          th: 'py-3 border-y border-default first:border-l last:border-r',
          td: 'border-b border-default py-3',
          separator: 'h-0'
        }" />

      <!-- Paginación -->
      <div class="flex items-center justify-between gap-3 border-t border-default pt-4 mt-4">
        <div class="text-sm text-muted">
          {{ table?.tableApi?.getFilteredSelectedRowModel().rows.length || 0 }} de
          {{ table?.tableApi?.getFilteredRowModel().rows.length || 0 }} productos seleccionados.
        </div>

        <div class="flex items-center gap-1.5">
          <UPagination :default-page="(table?.tableApi?.getState().pagination.pageIndex || 0) + 1"
            :items-per-page="table?.tableApi?.getState().pagination.pageSize"
            :total="table?.tableApi?.getFilteredRowModel().rows.length"
            @update:page="(p: number) => table?.tableApi?.setPageIndex(p - 1)" />
        </div>
      </div>

      <!-- Modal: Agregar/Editar Producto -->
      <UModal v-model="showProductModal" :ui="{ width: 'sm:max-w-2xl' }">
        <UCard>
          <template #header>
            <div class="flex justify-between items-center">
              <h3 class="text-lg font-semibold">
                {{ editingProduct ? 'Editar Producto' : 'Agregar Producto' }}
              </h3>
              <UButton icon="i-lucide-x" color="neutral" variant="ghost" @click="showProductModal = false" />
            </div>
          </template>

          <form @submit.prevent="handleSaveProduct" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <UFormGroup label="SKU" required>
                <UInput v-model="productForm.sku" placeholder="PROD-001" required />
              </UFormGroup>

              <UFormGroup label="Nombre" required>
                <UInput v-model="productForm.nombre" placeholder="Nombre del producto" required />
              </UFormGroup>

              <UFormGroup label="Categoría" required>
                <USelect v-model="productForm.categoria_id" :options="categories" option-attribute="nombre"
                  value-attribute="categoria_id" placeholder="Seleccionar categoría" required />
              </UFormGroup>

              <UFormGroup label="Marca">
                <USelect v-model="productForm.marca_id" :options="brands" option-attribute="nombre"
                  value-attribute="marca_id" placeholder="Seleccionar marca" />
              </UFormGroup>

              <UFormGroup label="Género">
                <USelect v-model="productForm.genero" :options="['Hombre', 'Mujer', 'Unisex', 'Niño', 'Niña']"
                  placeholder="Seleccionar género" />
              </UFormGroup>

              <UFormGroup label="Temporada">
                <USelect v-model="productForm.temporada"
                  :options="['Primavera', 'Verano', 'Otoño', 'Invierno', 'Todo el año']"
                  placeholder="Seleccionar temporada" />
              </UFormGroup>

              <UFormGroup label="Precio Compra" required>
                <UInput v-model="productForm.precio_compra" type="number" step="0.01" placeholder="0.00" required />
              </UFormGroup>

              <UFormGroup label="Precio Venta" required>
                <UInput v-model="productForm.precio_venta" type="number" step="0.01" placeholder="0.00" required />
              </UFormGroup>

              <UFormGroup label="Stock Mínimo">
                <UInput v-model="productForm.stock_minimo" type="number" placeholder="5" />
              </UFormGroup>

              <UFormGroup label="Stock Máximo">
                <UInput v-model="productForm.stock_maximo" type="number" placeholder="100" />
              </UFormGroup>
            </div>

            <UFormGroup label="Descripción">
              <UTextarea v-model="productForm.descripcion" placeholder="Descripción del producto" rows="3" />
            </UFormGroup>

            <UFormGroup label="Material Principal">
              <UInput v-model="productForm.material_principal" placeholder="Ej: Algodón 100%" />
            </UFormGroup>

            <UFormGroup label="Instrucciones de Cuidado">
              <UTextarea v-model="productForm.cuidados" placeholder="Instrucciones de lavado y cuidado" rows="2" />
            </UFormGroup>
          </form>

          <template #footer>
            <div class="flex justify-end gap-3">
              <UButton label="Cancelar" color="neutral" variant="ghost" @click="showProductModal = false" />
              <UButton :label="editingProduct ? 'Actualizar' : 'Crear'" color="primary" @click="handleSaveProduct" />
            </div>
          </template>
        </UCard>
      </UModal>

      <!-- Modal: Agregar Variante -->
      <UModal v-model="showVariantModal">
        <UCard>
          <template #header>
            <div class="flex justify-between items-center">
              <h3 class="text-lg font-semibold">Agregar Variante</h3>
              <UButton icon="i-lucide-x" color="neutral" variant="ghost" @click="showVariantModal = false" />
            </div>
          </template>

          <form @submit.prevent="handleSaveVariant" class="space-y-4">
            <UFormGroup label="Producto">
              <UInput :model-value="selectedProduct?.nombre" disabled />
            </UFormGroup>

            <div class="grid grid-cols-2 gap-4">
              <UFormGroup label="Talla" required>
                <UInput v-model="variantForm.talla" placeholder="S, M, L, XL" required />
              </UFormGroup>

              <UFormGroup label="Color" required>
                <UInput v-model="variantForm.color_nombre" placeholder="Negro, Azul, Rojo" required />
              </UFormGroup>

              <UFormGroup label="Código de Barras">
                <UInput v-model="variantForm.codigo_barras" placeholder="8801234567890" />
              </UFormGroup>

              <UFormGroup label="Ubicación en Almacén">
                <UInput v-model="variantForm.ubicacion_almacen" placeholder="Estante A-01" />
              </UFormGroup>
            </div>

            <UFormGroup label="Color (Hex)">
              <div class="flex items-center gap-3">
                <UInput v-model="variantForm.color_hex" placeholder="#000000" />
                <div class="w-8 h-8 rounded border" :style="{ backgroundColor: variantForm.color_hex || '#f3f4f6' }" />
              </div>
            </UFormGroup>
          </form>

          <template #footer>
            <div class="flex justify-end gap-3">
              <UButton label="Cancelar" color="neutral" variant="ghost" @click="showVariantModal = false" />
              <UButton label="Agregar Variante" color="primary" @click="handleSaveVariant" />
            </div>
          </template>
        </UCard>
      </UModal>

      <!-- Modal: Ajustar Stock -->
      <UModal v-model="showStockModal">
        <UCard>
          <template #header>
            <div class="flex justify-between items-center">
              <h3 class="text-lg font-semibold">Ajustar Stock</h3>
              <UButton icon="i-lucide-x" color="neutral" variant="ghost" @click="showStockModal = false" />
            </div>
          </template>

          <form @submit.prevent="handleAdjustStock" class="space-y-4">
            <UFormGroup label="Variante">
              <div class="space-y-1">
                <p class="text-sm font-medium">
                  {{ selectedVariant?.talla }} - {{ selectedVariant?.color_nombre }}
                </p>
                <p class="text-xs text-muted">
                  Stock actual: {{ selectedVariant?.stock_actual }}
                </p>
              </div>
            </UFormGroup>

            <div class="grid grid-cols-2 gap-4">
              <UFormGroup label="Tipo de Movimiento" required>
                <USelect v-model="stockForm.tipo_movimiento" :options="['Entrada', 'Salida']" required />
              </UFormGroup>

              <UFormGroup label="Cantidad" required>
                <UInput v-model="stockForm.cantidad" type="number" min="1" required />
              </UFormGroup>
              <!-- Aquí deberías cargar los almacenes -->
              <UFormGroup label="Almacén" required>
                <USelect v-model="stockForm.almacen_id" :options="[]" placeholder="Seleccionar almacén" required />
              </UFormGroup>

              <UFormGroup label="Costo Unitario">
                <UInput v-model="stockForm.costo_unitario" type="number" step="0.01" placeholder="0.00" />
              </UFormGroup>
            </div>

            <UFormGroup label="Motivo">
              <UTextarea v-model="stockForm.motivo" placeholder="Descripción del motivo del ajuste" rows="2" />
            </UFormGroup>
          </form>

          <template #footer>
            <div class="flex justify-end gap-3">
              <UButton label="Cancelar" color="neutral" variant="ghost" @click="showStockModal = false" />
              <UButton label="Ajustar Stock" color="primary" @click="handleAdjustStock" />
            </div>
          </template>
        </UCard>
      </UModal>


    </template>
  </UDashboardPanel>
</template>