<script setup lang="ts">
import type { TableColumn } from '@nuxt/ui'
import { debounce } from 'lodash-es'

const UAvatar = resolveComponent('UAvatar')
const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const UCheckbox = resolveComponent('UCheckbox')
const UTooltip = resolveComponent('UTooltip')
const USelect = resolveComponent('USelect')

const toast = useToast()


const { getProducts, getCategories, getBrands, deleteProduct, toggleProductStatus } = useProducts()

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

// Filtros
const searchQuery = ref('')
const selectedCategory = ref('all')
const selectedBrand = ref('all')
const selectedGender = ref('all')
const promotionFilter = ref('all')
const priceRange = ref({ min: '', max: '' })
const statusFilter = ref('all')
const sortBy = ref('fecha_creacion')
const sortOrder = ref('desc')

// Paginación
const pagination = ref({
  pageIndex: 0,
  pageSize: 20
})

// Datos reactivos
const productsData = ref<any>(null)
const categoriesData = ref<any>(null)
const brandsData = ref<any>(null)
const pending = ref(false)

// Cargar datos iniciales
onMounted(async () => {
  await loadData()
})

async function loadData() {
  pending.value = true
  try {
    // Cargar categorías y marcas
    const [categoriesRes, brandsRes] = await Promise.all([
      getCategories(),
      getBrands()
    ])

    categoriesData.value = categoriesRes.data.value
    brandsData.value = brandsRes.data.value

    // Cargar productos
    await loadProducts()
  } catch (error) {
    console.error('Error loading data:', error)
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar los datos',
      color: 'red'
    })
  } finally {
    pending.value = false
  }
}

const categories = computed(() => {
  if (!categoriesData.value) return []
  return Array.isArray(categoriesData.value)
    ? categoriesData.value
    : categoriesData.value?.data || []
})

const brands = computed(() => {
  if (!brandsData.value) return []
  return Array.isArray(brandsData.value)
    ? brandsData.value
    : brandsData.value?.data || []
})

const data = computed(() => productsData.value?.data || [])
const totalProducts = computed(() => productsData.value?.total || 0)
const totalPages = computed(() => productsData.value?.total_pages || 1)

// Función para cargar productos con parámetros
const loadProducts = async () => {
  pending.value = true
  try {
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
    if (promotionFilter.value !== 'all') {
      params.enPromocion = promotionFilter.value === 'promo'
    }
    if (priceRange.value.min) params.minPrice = parseFloat(priceRange.value.min)
    if (priceRange.value.max) params.maxPrice = parseFloat(priceRange.value.max)
    if (statusFilter.value !== 'all') {
      params.activo = statusFilter.value === 'active'
    }

    const { data: result, error } = await getProducts(params)

    if (error.value) {
      throw error.value
    }

    productsData.value = result.value
    console.log("Products loaded:", productsData.value)
  } catch (error: any) {
    console.error('Error loading products:', error)
    toast.add({
      title: 'Error',
      description: error.message || 'Error al cargar productos',
      color: 'red'
    })
  } finally {
    pending.value = false
  }
}

// Debounce para búsqueda
const debouncedLoadProducts = debounce(() => {
  // Resetear a página 1 cuando se aplica un filtro
  pagination.value.pageIndex = 0
  loadProducts()
}, 300)

// Watchers para filtros
watch(
  [
    searchQuery,
    selectedCategory,
    selectedBrand,
    selectedGender,
    promotionFilter,
    () => priceRange.value.min,
    () => priceRange.value.max,
    statusFilter,
    sortBy,
    sortOrder
  ],
  debouncedLoadProducts
)
function resetFilters() {
  searchQuery.value = ''
  selectedCategory.value = 'all'
  selectedBrand.value = 'all'
  selectedGender.value = 'all'
  promotionFilter.value = 'all'
  statusFilter.value = 'all'
  priceRange.value = { min: '', max: '' }
  sortBy.value = 'fecha_creacion'
  sortOrder.value = 'desc'
  pagination.value.pageIndex = 0

  loadProducts()
}
// Watcher para paginación
watch(
  [() => pagination.value.pageIndex, () => pagination.value.pageSize],
  loadProducts
)
const selectedRowsCount = computed(() => {
  return table?.tableApi?.getFilteredSelectedRowModel()?.rows?.length ?? 0
})
// Función para truncar descripción
const truncateDescription = (text: string, maxLength: number = 20) => {
  if (!text) return 'Sin descripción'
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

async function handleDeleteProduct(product: any) {
  const confirmed = confirm(`¿Estás seguro de eliminar el producto "${product.nombre}"?`)
  if (!confirmed) return

  try {
    const { error } = await deleteProduct(product.producto_id)
    if (error.value) throw error.value

    toast.add({ title: 'Producto eliminado', color: 'green' })
    await loadProducts()
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
      onSelect: async () => {
        try {
          const nuevoEstado = !row.original.activo

          const { error } = await toggleProductStatus(
            row.original.producto_id,
            nuevoEstado
          )

          if (error.value) throw error.value

          toast.add({
            title: nuevoEstado ? 'Producto activado' : 'Producto desactivado',
            color: 'green'
          })

          loadProducts()
        } catch (err: any) {
          toast.add({
            title: 'Error',
            description: err.message || 'No se pudo cambiar el estado',
            color: 'red'
          })
        }
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
        h('p', { class: 'text-xs text-muted line-clamp-2' },
          truncateDescription(row.original.descripcion)
        )
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
    accessorKey: 'stock_total',  // ← CORRECTO
    header: 'Stock',
    cell: ({ row }) => {
      const stock = Number(row.original.stock_total) || 0  // ← Ahora busca "stock_total"
      const minStock = Number(row.original.stock_minimo) || 5

      let color: 'green' | 'yellow' | 'red' = 'green'

      if (stock === 0) color = 'red'
      else if (stock <= minStock) color = 'yellow'

      return h(UBadge, {
        color: color,
        variant: 'subtle',
        class: 'font-medium px-3'
      }, () => stock.toString())
    }
  },
  {
    accessorKey: 'precio_final',
    header: 'Precio',
    cell: ({ row }) => {
      const price = parseFloat(row.original.precio_final) || 0
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
        }, () => `-${row.original.porcentaje_descuento || 0}%`)
      ])
    }
  },
  {
    accessorKey: 'variantes',
    header: 'Variantes',
    cell: ({ row }) => {
      const variants = row.original.variantes?.length || 0
      const colors = new Set(row.original.variantes?.map((v: any) => v.color_nombre) || []).size
      const sizes = new Set(row.original.variantes?.map((v: any) => v.talla) || []).size

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

      <div
        class="space-y-4 mb-6 p-4 rounded-lg bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800">

        <!-- Buscador / Categoría / Marca -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
          <!-- Buscar -->
          <input v-model="searchQuery" type="text" placeholder="Buscar productos..." class="lg:col-span-2 w-full rounded-md border px-3 py-2 text-sm
             border-neutral-300 dark:border-neutral-700
             bg-white dark:bg-neutral-800
             focus:outline-none focus:ring-2 focus:ring-primary-500" />

          <!-- Categoría -->
          <select v-model="selectedCategory" class="w-full rounded-md border px-3 py-2 text-sm
             border-neutral-300 dark:border-neutral-700
             bg-white dark:bg-neutral-800">
            <option value="all">Todas las categorías</option>
            <option v-for="c in categories" :key="c.categoria_id" :value="c.categoria_id">
              {{ c.nombre }}
            </option>
          </select>

          <!-- Marca -->
          <select v-model="selectedBrand" class="w-full rounded-md border px-3 py-2 text-sm
             border-neutral-300 dark:border-neutral-700
             bg-white dark:bg-neutral-800">
            <option value="all">Todas las marcas</option>
            <option v-for="b in brands" :key="b.marca_id" :value="b.marca_id">
              {{ b.nombre }}
            </option>
          </select>
        </div>

        <!-- Género / Promoción / Estado / Precio -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-3">
          <select v-model="selectedGender" class="input">
            <option value="all">Todos los géneros</option>
            <option value="Hombre">Hombre</option>
            <option value="Mujer">Mujer</option>
            <option value="Unisex">Unisex</option>
            <option value="Niño">Niño</option>
            <option value="Niña">Niña</option>
          </select>

          <select v-model="promotionFilter" class="input">
            <option value="all">Todos</option>
            <option value="promo">En promoción</option>
            <option value="no-promo">Sin promoción</option>
          </select>

          <select v-model="statusFilter" class="input">
            <option value="all">Todos</option>
            <option value="active">Activos</option>
            <option value="inactive">Inactivos</option>
          </select>

          <input v-model="priceRange.min" type="number" placeholder="Precio min" class="input"
            @keyup.enter="debouncedLoadProducts" />

          <input v-model="priceRange.max" type="number" placeholder="Precio max" class="input"
            @keyup.enter="debouncedLoadProducts" />
        </div>

        <!-- Orden / Acciones -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <!-- Orden -->
          <div class="flex items-center gap-2">
            <span class="text-sm text-neutral-500">Ordenar por:</span>

            <select v-model="sortBy" class="input w-40">
              <option value="fecha_creacion">Fecha creación</option>
              <option value="nombre">Nombre</option>
              <option value="precio_final">Precio</option>
              <option value="stock_total">Stock</option>
            </select>

            <button class="px-2 py-1 rounded-md border border-neutral-300 dark:border-neutral-700"
              @click="sortOrder = sortOrder === 'asc' ? 'desc' : 'asc'">
              {{ sortOrder === 'asc' ? '↑' : '↓' }}
            </button>
          </div>

          <!-- Botones -->
          <div class="flex items-center gap-2">
            <button @click="resetFilters" class="text-sm px-3 py-2 rounded-md border
               border-neutral-300 dark:border-neutral-700
               hover:bg-neutral-100 dark:hover:bg-neutral-800">
              Limpiar filtros
            </button>

            <button @click="loadProducts" :disabled="pending" class="text-sm px-3 py-2 rounded-md bg-primary-600 text-white
               hover:bg-primary-700 disabled:opacity-50">
              {{ pending ? 'Cargando...' : 'Actualizar' }}
            </button>
          </div>
        </div>
      </div>

      <UTable ref="table" v-model:pagination="pagination" :data="data" :columns="columns" :loading="pending" />
      <!-- Paginación -->

      <div v-if="totalProducts > 0" class="flex items-center justify-between gap-3 border-t border-default pt-4 mt-4">
        <div class="text-sm text-muted">
          Mostrando {{ (pagination.pageIndex * pagination.pageSize) + 1 }} a
          {{ Math.min((pagination.pageIndex + 1) * pagination.pageSize, totalProducts) }}
          de {{ totalProducts }} productos

          <span v-if="selectedRowsCount > 0">
            • {{ selectedRowsCount }} seleccionados
          </span>
        </div>

        <div class="flex items-center gap-1.5">
          <UPagination :model-value="pagination.pageIndex + 1" :page-count="totalPages" :total="totalProducts"
            :items-per-page="pagination.pageSize" @update:modelValue="(page) => pagination.pageIndex = page - 1" />

          <USelect v-model="pagination.pageSize" :options="[10, 20, 50, 100]" size="xs" class="w-20" />
        </div>
      </div>


    </template>
  </UDashboardPanel>
</template>