<script setup lang="ts">
import type { TableColumn } from '@nuxt/ui'
import { upperFirst } from 'scule'
import { getPaginationRowModel } from '@tanstack/table-core'
import type { Row } from '@tanstack/table-core'
import type { User } from '~/types'
import type { Customer } from '~/types/customer'

const UAvatar = resolveComponent('UAvatar')
const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const UCheckbox = resolveComponent('UCheckbox')

definePageMeta({
  layout: 'dashboard',
  middleware: ['guest']
})

const toast = useToast()
const table = useTemplateRef('table')

/* =======================
   ESTADO DE TABLA
======================= */
const columnFilters = ref([{ id: 'email', value: '' }])
const columnVisibility = ref()
const rowSelection = ref({})
const statusFilter = ref('all')

const pagination = ref({
  pageIndex: 0,
  pageSize: 10
})

/* =======================
   API FETCH (TU HELPER)
======================= */
const { data, status, error } = await useApiFetch<Customer[]>('/customers', {
  lazy: true
})

console.log("data",data);

watch(error, (err) => {
  if (err) {
    toast.add({
      title: 'Error',
      description: 'No se pudo cargar la lista de clientes',
      color: 'red'
    })
  }
})

/* =======================
   FILTRO STATUS
======================= */
watch(statusFilter, (value) => {
  if (!table.value?.tableApi) return

  const column = table.value.tableApi.getColumn('status')
  if (!column) return

  column.setFilterValue(value === 'all' ? undefined : value)
})

/* =======================
   FILTRO EMAIL
======================= */
const email = computed({
  get: () =>
    (table.value?.tableApi?.getColumn('email')?.getFilterValue() as string) || '',
  set: (value: string) => {
    table.value?.tableApi
      ?.getColumn('email')
      ?.setFilterValue(value || undefined)
  }
})

/* =======================
   DROPDOWN ACTIONS
======================= */
function getRowItems(row: Row<User>) {
  return [
    { type: 'label', label: 'Actions' },
    {
      label: 'Copy customer ID',
      icon: 'i-lucide-copy',
      onSelect() {
        navigator.clipboard.writeText(String(row.original.id))
        toast.add({
          title: 'Copied',
          description: 'Customer ID copied to clipboard'
        })
      }
    },
    { type: 'separator' },
    {
      label: 'Delete customer',
      icon: 'i-lucide-trash',
      color: 'error',
      async onSelect() {
        try {
          await useApiFetch(`/customers/${row.original.id}`, {
            method: 'DELETE'
          })
          toast.add({
            title: 'Deleted',
            description: 'Customer deleted successfully'
          })
          refresh()
        } catch {
          toast.add({
            title: 'Error',
            description: 'Could not delete customer',
            color: 'red'
          })
        }
      }
    }
  ]
}

/* =======================
   COLUMNAS
======================= */
const columns: TableColumn<Customer>[] = [
  {
    accessorKey: 'cliente_id',
    header: 'ID'
  },
  {
    id: 'cliente',
    header: 'Cliente',
    cell: ({ row }) =>
      h('div', { class: 'flex flex-col' }, [
        h('span', { class: 'font-medium' },
          `${row.original.nombre} ${row.original.apellido}`
        ),
        h('span', { class: 'text-sm text-muted' },
          row.original.email
        )
      ])
  },
  {
    accessorKey: 'tipo_cliente',
    header: 'Tipo'
  },
  {
    accessorKey: 'pais',
    header: 'País'
  },
  {
    accessorKey: 'segmento',
    header: 'Segmento'
  },
  {
    accessorKey: 'activo',
    header: 'Estado',
    cell: ({ row }) =>
      h(
        UBadge,
        {
          color: row.original.activo ? 'success' : 'error',
          variant: 'subtle'
        },
        () => (row.original.activo ? 'Activo' : 'Inactivo')
      )
  }
]

</script>

<template>
  <UDashboardPanel id="customers">
    <template #header>
      <UDashboardNavbar title="Customers">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>
        <template #right>
          <CustomersAddModal @success="refresh()" />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <div class="flex justify-between gap-2 mb-4">
        <UInput
          v-model="email"
          placeholder="Filter email..."
          icon="i-lucide-search"
        />

        <USelect
          v-model="statusFilter"
          :items="[
            { label: 'All', value: 'all' },
            { label: 'Subscribed', value: 'subscribed' },
            { label: 'Unsubscribed', value: 'unsubscribed' },
            { label: 'Bounced', value: 'bounced' }
          ]"
          class="w-40"
        />
      </div>

      <UTable
        ref="table"
       :data="data || []"
        :columns="columns"
        :loading="status === 'pending'"
        v-model:column-filters="columnFilters"
        v-model:column-visibility="columnVisibility"
        v-model:row-selection="rowSelection"
        v-model:pagination="pagination"
        :pagination-options="{ getPaginationRowModel: getPaginationRowModel() }"
      />

      <div class="flex justify-between items-center pt-4">
        <span class="text-sm text-muted">
          {{ table?.tableApi?.getFilteredRowModel().rows.length || 0 }} results
        </span>

        <UPagination
          :total="table?.tableApi?.getFilteredRowModel().rows.length"
          :items-per-page="pagination.pageSize"
          :page="pagination.pageIndex + 1"
          @update:page="p => table?.tableApi?.setPageIndex(p - 1)"
        />
      </div>
    </template>
  </UDashboardPanel>
</template>
