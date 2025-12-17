<template>
  <UDashboardPanel id="users-management">
    <!-- Header con acciones principales -->
    <template #header>
      <UDashboardNavbar title="Gestión de Usuarios">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>

        <template #right>
          <div class="flex items-center gap-2">
            <!-- Botón para exportar usuarios -->
            <UButton color="primary" variant="solid" icon="i-heroicons-arrow-down-tray" @click="exportUsers"
              :loading="exporting" label="Exportar" />

            <!-- Botón para crear nuevo usuario -->
            <UButton color="primary" variant="solid" icon="i-heroicons-plus" @click="showCreateModal = true"
              label="Nuevo Usuario" />
          </div>
        </template>
      </UDashboardNavbar>
    </template>

    <!-- Filtros y controles -->
    <template #body>
      <div class="space-y-4">
        <!-- Barra de búsqueda y filtros -->
        <div class="flex flex-wrap items-center justify-between gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
          <div class="flex flex-wrap items-center gap-3">
            <!-- Búsqueda por email/nombre -->
            <UInput v-model="searchQuery" placeholder="Buscar por email o nombre..." icon="i-heroicons-magnifying-glass"
              class="min-w-[300px]" @input="debouncedSearch" />

            <!-- Filtro por tipo de usuario -->
            <USelect v-model="filters.tipo_usuario" :options="userTypeOptions" placeholder="Tipo de usuario"
              class="min-w-[180px]" @change="loadUsers" />

            <!-- Filtro por estado -->
            <USelect v-model="filters.activo" :options="statusOptions" placeholder="Estado" class="min-w-[150px]"
              @change="loadUsers" />

            <!-- Filtro por verificación de email -->
            <USelect v-model="filters.email_verificado" :options="verificationOptions" placeholder="Email verificado"
              class="min-w-[180px]" @change="loadUsers" />
          </div>

          <!-- Botones de acción -->
          <div class="flex items-center gap-2">
            <!-- Actualizar lista -->
            <UButton color="gray" variant="ghost" icon="i-heroicons-arrow-path" @click="loadUsers" :loading="loading"
              title="Actualizar" />

            <!-- Vista de columnas -->
            <UDropdownMenu :items="[
              {
                type: 'label',
                label: 'Columnas visibles'
              },
              ...columns.filter(col => col.id !== 'select' && col.id !== 'actions').map(col => ({
                label: col.header,
                type: 'checkbox',
                checked: visibleColumns.includes(col.id),
                onUpdateChecked: (checked: boolean) => toggleColumnVisibility(col.id, checked)
              }))
            ]">
              <UButton color="gray" variant="outline" icon="i-heroicons-adjustments-horizontal" label="Columnas" />
            </UDropdownMenu>
          </div>
        </div>

        <!-- Tabla de usuarios -->
        <div class="border rounded-lg overflow-hidden">
          <UTable :rows="users" :columns="filteredColumns" :loading="loading" :empty-state="{
            icon: 'i-heroicons-user-group',
            label: 'No se encontraron usuarios',
            description: 'Intenta cambiar los filtros o crear un nuevo usuario'
          }" class="w-full">
            <!-- Columna de selección -->
            <template #select-header="{ row, column }">
              <UCheckbox :model-value="selectedUsers.includes(row.original.usuario_id)"
                @update:model-value="toggleUserSelection(row.original.usuario_id)" />
            </template>

            <template #select-cell="{ row, column }">
              <UCheckbox :model-value="selectedUsers.includes(row.original.usuario_id)"
                @update:model-value="toggleUserSelection(row.original.usuario_id)" />
            </template>

            <!-- Columna de email -->
            <template #email-cell="{ row }">
              <div class="flex items-center gap-2">
                <UIcon v-if="row.original.email_verificado" name="i-heroicons-check-circle"
                  class="w-4 h-4 text-green-500" title="Email verificado" />
                <UIcon v-else name="i-heroicons-exclamation-circle" class="w-4 h-4 text-yellow-500"
                  title="Email no verificado" />
                <span>{{ row.original.email }}</span>
              </div>
            </template>

            <!-- Columna de tipo de usuario -->
            <template #tipo_usuario-cell="{ row }">
              <UBadge :color="getUserTypeColor(row.original.tipo_usuario)" variant="subtle" class="capitalize">
                {{ row.original.tipo_usuario }}
              </UBadge>
            </template>

            <!-- Columna de estado -->
            <template #activo-cell="{ row }">
              <UBadge :color="row.original.activo ? 'green' : 'red'" variant="subtle">
                {{ row.original.activo ? 'Activo' : 'Inactivo' }}
              </UBadge>
            </template>

            <!-- Columna de roles -->
            <template #roles-cell="{ row }">
              <div class="flex flex-wrap gap-1">
                <UBadge v-for="role in getRolesArray(row.original.roles)" :key="role" color="blue" variant="outline"
                  size="xs">
                  {{ role }}
                </UBadge>
              </div>
            </template>

            <!-- Columna de fecha de creación -->
            <template #fecha_creacion-cell="{ row }">
              {{ formatDate(row.original.fecha_creacion) }}
            </template>

            <!-- Columna de última conexión -->
            <template #fecha_ultimo_login-cell="{ row }">
              <span v-if="row.original.fecha_ultimo_login">
                {{ formatDate(row.original.fecha_ultimo_login) }}
              </span>
              <span v-else class="text-gray-400">Nunca</span>
            </template>

            <!-- Columna de acciones -->
            <template #actions-cell="{ row }">
              <div class="flex items-center gap-1">
                <!-- Ver detalles -->
                <UButton color="gray" variant="ghost" icon="i-heroicons-eye" size="xs"
                  @click="viewUserDetails(row.original)" title="Ver detalles" />

                <!-- Editar usuario -->
                <UButton color="primary" variant="ghost" icon="i-heroicons-pencil-square" size="xs"
                  @click="editUser(row.original)" title="Editar" />

                <!-- Menú de acciones -->
                <UDropdownMenu>
                  <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-vertical" size="xs" />
                  <template #content>
                    <!-- Verificar email -->
                    <UButton v-if="!row.original.email_verificado" variant="ghost" icon="i-heroicons-envelope"
                      label="Verificar email" @click="verifyUserEmail(row.original)" />

                    <!-- Activar/Desactivar -->
                    <UButton :variant="row.original.activo ? 'ghost' : 'ghost'"
                      :icon="row.original.activo ? 'i-heroicons-x-circle' : 'i-heroicons-check-circle'"
                      :label="row.original.activo ? 'Desactivar' : 'Activar'" @click="toggleUserStatus(row.original)" />

                    <!-- Ver sesiones -->
                    <UButton variant="ghost" icon="i-heroicons-computer-desktop" label="Ver sesiones"
                      @click="viewUserSessions(row.original)" />

                    <!-- Cerrar sesiones -->
                    <UButton variant="ghost" icon="i-heroicons-arrow-right-on-rectangle" label="Cerrar sesiones"
                      @click="closeUserSessions(row.original)" />

                    <UDivider />

                    <!-- Eliminar usuario -->
                    <UButton variant="ghost" color="red" icon="i-heroicons-trash" label="Eliminar"
                      @click="deleteUser(row.original)" />
                  </template>
                </UDropdownMenu>
              </div>
            </template>
          </UTable>
        </div>

        <!-- Paginación -->
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-500">
            Mostrando {{ (currentPage - 1) * pageSize + 1 }} a
            {{ Math.min(currentPage * pageSize, totalUsers) }} de
            {{ totalUsers }} usuarios
            <span v-if="selectedUsers.length > 0">
              | {{ selectedUsers.length }} seleccionados
            </span>
          </div>

          <UPagination v-model="currentPage" :page-count="pageSize" :total="totalUsers"
            @update:model-value="loadUsers" />
        </div>

        <!-- Estadísticas -->
        <div v-if="stats" class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <UCard>
            <template #header>
              <h3 class="text-lg font-semibold">Total Usuarios</h3>
            </template>
            <div class="text-3xl font-bold">{{ stats.total }}</div>
          </UCard>

          <UCard>
            <template #header>
              <h3 class="text-lg font-semibold">Activos</h3>
            </template>
            <div class="text-3xl font-bold text-green-600">{{ stats.activos }}</div>
          </UCard>

          <UCard>
            <template #header>
              <h3 class="text-lg font-semibold">Verificados</h3>
            </template>
            <div class="text-3xl font-bold text-blue-600">{{ stats.verificados }}</div>
          </UCard>

          <UCard>
            <template #header>
              <h3 class="text-lg font-semibold">Empleados</h3>
            </template>
            <div class="text-3xl font-bold text-purple-600">{{ stats.empleados }}</div>
          </UCard>
        </div>
      </div>
    </template>
  </UDashboardPanel>

  <!-- Modal para crear/editar usuario -->
  <UModal v-model="showCreateModal">
    <UCard>
      <template #header>
        <h3 class="text-lg font-semibold">
          {{ editingUser ? 'Editar Usuario' : 'Crear Nuevo Usuario' }}
        </h3>
      </template>

      <UForm :state="userForm" class="space-y-4" @submit="saveUser">
        <UFormGroup label="Email" required>
          <UInput v-model="userForm.email" type="email" placeholder="correo@ejemplo.com" :disabled="!!editingUser" />
        </UFormGroup>

        <UFormGroup label="Tipo de Usuario">
          <USelect v-model="userForm.tipo_usuario" :options="userTypeOptions" />
        </UFormGroup>

        <UFormGroup label="Roles">
          <USelectMenu v-model="userForm.roles" :options="availableRoles" multiple placeholder="Seleccionar roles" />
        </UFormGroup>

        <UFormGroup label="Estado">
          <UToggle v-model="userForm.activo" :label="userForm.activo ? 'Activo' : 'Inactivo'" />
        </UFormGroup>

        <UFormGroup v-if="userForm.tipo_usuario === 'Cliente'" label="Cliente Asociado">
          <USelect v-model="userForm.cliente_id" :options="clientes" option-attribute="nombre"
            placeholder="Seleccionar cliente" />
        </UFormGroup>

        <UFormGroup v-if="userForm.tipo_usuario === 'Empleado'" label="Empleado Asociado">
          <USelect v-model="userForm.empleado_id" :options="empleados" option-attribute="nombre"
            placeholder="Seleccionar empleado" />
        </UFormGroup>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="ghost" @click="showCreateModal = false">
              Cancelar
            </UButton>
            <UButton type="submit" color="primary" :loading="savingUser">
              {{ editingUser ? 'Actualizar' : 'Crear' }}
            </UButton>
          </div>
        </template>
      </UForm>
    </UCard>
  </UModal>

  <!-- Modal para ver detalles del usuario -->
  <UModal v-model="showDetailsModal" size="2xl">
    <UCard v-if="selectedUser">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold">Detalles del Usuario</h3>
          <UButton color="gray" variant="ghost" icon="i-heroicons-x-mark" @click="showDetailsModal = false" />
        </div>
      </template>

      <div class="space-y-4">
        <!-- Información básica -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-500">Email</label>
            <p class="mt-1">{{ selectedUser.email }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-500">Tipo</label>
            <UBadge :color="getUserTypeColor(selectedUser.tipo_usuario)" class="mt-1">
              {{ selectedUser.tipo_usuario }}
            </UBadge>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-500">Estado</label>
            <UBadge :color="selectedUser.activo ? 'green' : 'red'" class="mt-1">
              {{ selectedUser.activo ? 'Activo' : 'Inactivo' }}
            </UBadge>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-500">Email Verificado</label>
            <UBadge :color="selectedUser.email_verificado ? 'green' : 'yellow'" class="mt-1">
              {{ selectedUser.email_verificado ? 'Sí' : 'No' }}
            </UBadge>
          </div>
        </div>

        <!-- Información adicional -->
        <div v-if="selectedUser.cliente_info">
          <h4 class="font-medium mb-2">Información del Cliente</h4>
          <div class="bg-gray-50 dark:bg-gray-800 p-3 rounded">
            <p><strong>Nombre:</strong> {{ selectedUser.cliente_info.nombre }} {{ selectedUser.cliente_info.apellido }}
            </p>
            <p><strong>Teléfono:</strong> {{ selectedUser.cliente_info.telefono }}</p>
            <p><strong>Total compras:</strong> {{ selectedUser.cliente_info.total_compras_count }}</p>
            <p><strong>Total gastado:</strong> ${{ selectedUser.cliente_info.total_gastado }}</p>
          </div>
        </div>

        <div v-if="selectedUser.empleado_info">
          <h4 class="font-medium mb-2">Información del Empleado</h4>
          <div class="bg-gray-50 dark:bg-gray-800 p-3 rounded">
            <p><strong>Nombre:</strong> {{ selectedUser.empleado_info.nombre }} {{ selectedUser.empleado_info.apellido
            }}
            </p>
            <p><strong>Puesto:</strong> {{ selectedUser.empleado_info.puesto }}</p>
            <p><strong>Ventas realizadas:</strong> {{ selectedUser.empleado_info.ventas_realizadas }}</p>
            <p><strong>Total ventas:</strong> ${{ selectedUser.empleado_info.ventas_total }}</p>
          </div>
        </div>

        <!-- Roles y permisos -->
        <div>
          <h4 class="font-medium mb-2">Roles Asignados</h4>
          <div class="flex flex-wrap gap-2">
            <UBadge v-for="role in getRolesArray(selectedUser.roles)" :key="role" color="blue" variant="outline">
              {{ role }}
            </UBadge>
          </div>
        </div>

        <div v-if="selectedUser.permisos">
          <h4 class="font-medium mb-2">Permisos</h4>
          <div class="bg-gray-50 dark:bg-gray-800 p-3 rounded max-h-40 overflow-y-auto">
            <div v-for="modulo in groupByModule(selectedUser.permisos)" :key="modulo.nombre">
              <h5 class="font-medium">{{ modulo.nombre }}</h5>
              <ul class="pl-4">
                <li v-for="permiso in modulo.permisos" :key="permiso.permiso_id">
                  {{ permiso.nombre }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </UCard>
  </UModal>
</template>

<script setup lang="ts">
import type { User, UserForm, UserStats, UserFilters } from '~/types/user'
import { useDebounceFn } from '@vueuse/core'

// Configuración de la página
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

// Estados reactivos
const loading = ref(false)
const exporting = ref(false)
const savingUser = ref(false)
const currentPage = ref(1)
const pageSize = 10
const totalUsers = ref(0)
const stats = ref<UserStats | null>(null)

// Datos
const users = ref<User[]>([])
const selectedUsers = ref<number[]>([])
const selectedUser = ref<User | null>(null)
const editingUser = ref<User | null>(null)
const clientes = ref<any[]>([])
const empleados = ref<any[]>([])
const availableRoles = ref<string[]>([])

// Filtros
const searchQuery = ref('')
const filters = ref<UserFilters>({
  tipo_usuario: '',
  activo: '',
  email_verificado: ''
})

// Modales
const showCreateModal = ref(false)
const showDetailsModal = ref(false)

// Formulario de usuario
const userForm = ref<UserForm>({
  email: '',
  tipo_usuario: 'Cliente',
  roles: [],
  activo: true,
  cliente_id: null,
  empleado_id: null
})

// Columnas de la tabla
const columns = [
  { id: 'select', header: 'Seleccionar', width: 50 },
  { id: 'usuario_id', header: 'ID', width: 80 },
  { id: 'email', header: 'Email' },
  { id: 'tipo_usuario', header: 'Tipo' },
  { id: 'roles', header: 'Roles' },
  { id: 'activo', header: 'Estado' },
  { id: 'email_verificado', header: 'Verificado' },
  { id: 'fecha_creacion', header: 'Creado' },
  { id: 'fecha_ultimo_login', header: 'Último Login' },
  { id: 'actions', header: 'Acciones', width: 100 }
]

const visibleColumns = ref(['select', 'email', 'tipo_usuario', 'roles', 'activo', 'actions'])
const filteredColumns = computed(() =>
  columns.filter(col => visibleColumns.includes(col.id))
)

// Opciones para filtros
const userTypeOptions = [
  { label: 'Todos', value: '' },
  { label: 'Administrador', value: 'Administrador' },
  { label: 'Empleado', value: 'Empleado' },
  { label: 'Cliente', value: 'Cliente' }
]

const statusOptions = [
  { label: 'Todos', value: '' },
  { label: 'Activo', value: 'true' },
  { label: 'Inactivo', value: 'false' }
]

const verificationOptions = [
  { label: 'Todos', value: '' },
  { label: 'Verificado', value: 'true' },
  { label: 'No verificado', value: 'false' }
]

// Funciones auxiliares
const getRolesArray = (rolesString: string) => {
  return rolesString ? rolesString.split(', ').filter(r => r) : []
}

const getUserTypeColor = (type: string) => {
  const colors: Record<string, string> = {
    'Administrador': 'red',
    'Empleado': 'blue',
    'Cliente': 'green'
  }
  return colors[type] || 'gray'
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const groupByModule = (permisos: any[]) => {
  const grouped = permisos.reduce((acc, permiso) => {
    if (!acc[permiso.modulo]) {
      acc[permiso.modulo] = {
        nombre: permiso.modulo,
        permisos: []
      }
    }
    acc[permiso.modulo].permisos.push(permiso)
    return acc
  }, {})
  return Object.values(grouped)
}

// Cargar datos
const loadUsers = async () => {
  try {
    loading.value = true

    // Construir query params
    const params: any = {
      page: currentPage.value,
      limit: pageSize
    }

    if (searchQuery.value) params.q = searchQuery.value
    if (filters.value.tipo_usuario) params.tipo_usuario = filters.value.tipo_usuario
    if (filters.value.activo !== '') params.activo = filters.value.activo
    if (filters.value.email_verificado !== '') params.email_verificado = filters.value.email_verificado

    // Cargar usuarios
    const { data: usersData } = await useFetch('/api/v1/users', {
      params,
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (usersData.value?.success) {
      users.value = usersData.value.data
      totalUsers.value = usersData.value.meta?.pagination?.total || 0
      stats.value = usersData.value.meta?.stats
    }

    // Cargar roles disponibles
    const { data: rolesData } = await useFetch('/api/v1/roles', {
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (rolesData.value?.success) {
      availableRoles.value = rolesData.value.data.map((role: any) => role.nombre)
    }

  } catch (error) {
    console.error('Error al cargar usuarios:', error)
    useToast().add({
      title: 'Error',
      description: 'No se pudieron cargar los usuarios',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

// Búsqueda con debounce
const debouncedSearch = useDebounceFn(() => {
  currentPage.value = 1
  loadUsers()
}, 500)

// Selección de usuarios
const toggleUserSelection = (userId: number) => {
  const index = selectedUsers.value.indexOf(userId)
  if (index > -1) {
    selectedUsers.value.splice(index, 1)
  } else {
    selectedUsers.value.push(userId)
  }
}

const toggleColumnVisibility = (columnId: string, visible: boolean) => {
  if (visible && !visibleColumns.value.includes(columnId)) {
    visibleColumns.value.push(columnId)
  } else if (!visible) {
    visibleColumns.value = visibleColumns.value.filter(id => id !== columnId)
  }
}

// CRUD Operations
const viewUserDetails = async (user: User) => {
  try {
    const { data } = await useFetch(`/api/v1/users/${user.usuario_id}`, {
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      selectedUser.value = data.value.data
      showDetailsModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar detalles:', error)
  }
}

const editUser = (user: User) => {
  editingUser.value = user
  userForm.value = {
    email: user.email,
    tipo_usuario: user.tipo_usuario,
    roles: getRolesArray(user.roles),
    activo: user.activo,
    cliente_id: user.cliente_id,
    empleado_id: user.empleado_id
  }
  showCreateModal.value = true
}

const saveUser = async () => {
  try {
    savingUser.value = true

    const url = editingUser.value
      ? `/api/v1/users/${editingUser.value.usuario_id}`
      : '/api/v1/users'

    const method = editingUser.value ? 'PUT' : 'POST'

    const { data } = await useFetch(url, {
      method,
      body: userForm.value,
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      useToast().add({
        title: 'Éxito',
        description: editingUser.value
          ? 'Usuario actualizado correctamente'
          : 'Usuario creado correctamente',
        color: 'green'
      })

      showCreateModal.value = false
      editingUser.value = null
      userForm.value = {
        email: '',
        tipo_usuario: 'Cliente',
        roles: [],
        activo: true,
        cliente_id: null,
        empleado_id: null
      }

      loadUsers()
    }
  } catch (error) {
    console.error('Error al guardar usuario:', error)
    useToast().add({
      title: 'Error',
      description: 'No se pudo guardar el usuario',
      color: 'red'
    })
  } finally {
    savingUser.value = false
  }
}

const toggleUserStatus = async (user: User) => {
  try {
    const { data } = await useFetch(`/api/v1/users/${user.usuario_id}`, {
      method: 'PUT',
      body: { activo: !user.activo },
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      useToast().add({
        title: 'Éxito',
        description: `Usuario ${user.activo ? 'desactivado' : 'activado'} correctamente`,
        color: 'green'
      })
      loadUsers()
    }
  } catch (error) {
    console.error('Error al cambiar estado:', error)
  }
}

const deleteUser = async (user: User) => {
  if (!confirm(`¿Estás seguro de eliminar al usuario ${user.email}?`)) return

  try {
    const { data } = await useFetch(`/api/v1/users/${user.usuario_id}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      useToast().add({
        title: 'Éxito',
        description: 'Usuario eliminado correctamente',
        color: 'green'
      })
      loadUsers()
    }
  } catch (error) {
    console.error('Error al eliminar usuario:', error)
  }
}

const verifyUserEmail = async (user: User) => {
  try {
    const { data } = await useFetch('/api/v1/users/verify-email', {
      method: 'POST',
      body: { token: user.token_verificacion },
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      useToast().add({
        title: 'Éxito',
        description: 'Email verificado correctamente',
        color: 'green'
      })
      loadUsers()
    }
  } catch (error) {
    console.error('Error al verificar email:', error)
  }
}

const viewUserSessions = async (user: User) => {
  // Implementar vista de sesiones
  console.log('Ver sesiones de:', user.email)
}

const closeUserSessions = async (user: User) => {
  if (!confirm('¿Cerrar todas las sesiones de este usuario?')) return

  try {
    const { data } = await useFetch(`/api/v1/users/${user.usuario_id}/sessions/close`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value?.success) {
      useToast().add({
        title: 'Éxito',
        description: 'Sesiones cerradas correctamente',
        color: 'green'
      })
    }
  } catch (error) {
    console.error('Error al cerrar sesiones:', error)
  }
}

const exportUsers = async () => {
  try {
    exporting.value = true

    const { data } = await useFetch('/api/v1/users/export', {
      params: { format: 'csv' },
      headers: {
        Authorization: `Bearer ${useCookie('token').value}`
      }
    })

    if (data.value) {
      // Crear y descargar archivo
      const blob = new Blob([data.value], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `usuarios_${new Date().toISOString().split('T')[0]}.csv`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)

      useToast().add({
        title: 'Éxito',
        description: 'Usuarios exportados correctamente',
        color: 'green'
      })
    }
  } catch (error) {
    console.error('Error al exportar:', error)
    useToast().add({
      title: 'Error',
      description: 'No se pudieron exportar los usuarios',
      color: 'red'
    })
  } finally {
    exporting.value = false
  }
}

// Cargar datos iniciales
onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
:deep(.table-row:hover) {
  background-color: rgba(0, 0, 0, 0.02);
}

:deep(.table-cell) {
  padding: 12px;
  vertical-align: middle;
}

:deep(.table-header) {
  background-color: #f8fafc;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
}
</style>