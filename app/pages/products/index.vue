<script setup lang="ts">
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'

const UAvatar = resolveComponent('UAvatar')
const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const UCheckbox = resolveComponent('UCheckbox')
const UTooltip = resolveComponent('UTooltip')
const UModal = resolveComponent('UModal')
const UInput = resolveComponent('UInput')
const USelect = resolveComponent('USelect')

const toast = useToast()
const table = useTemplateRef('table')

const { getProducts, getCategories, getBrands, deleteProduct } = useProducts()

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth'] // Cambié de 'guest' a 'auth' para proteger la página
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
console.log("productsData", productsData.value)

const { data: categoriesData } = await getCategories()
const { data: brandsData } = await getBrands()

const data = computed(() => productsData.value?.data || [])
const categories = computed(() => {
  return Array.isArray(categoriesData.value)
    ? categoriesData.value
    : categoriesData.value?.data ?? []
})

const brands = computed(() => {
  return Array.isArray(brandsData.value)
    ? brandsData.value
    : brandsData.value?.data ?? []
})
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

async function handleDeleteProduct(product: any) {
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

function getRowItems(row: any) {
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
        navigateTo(`/products/edit-${row.original.producto_id}`)
      }
    },
    {
      label: 'Agregar variante',
      icon: 'i-lucide-plus',
      onSelect() {
        navigateTo(`/products/variants/create?product_id=${row.original.producto_id}`)
      }
    },
    {
      label: 'Ajustar stock',
      icon: 'i-lucide-box',
      onSelect() {
        navigateTo(`/products/variants/stock?product_id=${row.original.producto_id}`)
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

const columns: TableColumn<any>[] = [
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
      const colors = new Set(row.original.variantes?.map((v: any) => v.color_nombre)).size
      const sizes = new Set(row.original.variantes?.map((v: any) => v.talla)).size

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
</script>

<template>
  <UDashboardPanel id="products">
    <template #header>
      <UDashboardNavbar title="Productos">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>

        <template #right>
          <UButton label="Agregar producto" icon="i-lucide-plus" color="primary" to="/products/create" />
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
            value-attribute="categoria_id" />

          <USelect v-model="selectedBrand" :options="[{ value: 'all', label: 'Todas las marcas' }, ...brands]"
            option-attribute="nombre" value-attribute="marca_id" />
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
            <UButton icon="i-lucide-refresh-ccw" color="neutral" variant="ghost" size="sm" :loading="pending"
              @click="refresh()" />
          </div>
        </div>
      </div>

      <!-- Tabla -->
      <UTable ref="table" v-model:pagination="pagination" :pagination-options="{
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
    </template>
  </UDashboardPanel>
</template>