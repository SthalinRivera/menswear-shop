<template>
    <UDashboardPanel id="roles-management">
        <!-- Header -->
        <template #header>
            <UDashboardNavbar title="Gestión de Roles">
                <template #leading>
                    <UDashboardSidebarCollapse />
                </template>

                <template #right>
                    <UButton color="primary" variant="solid" icon="i-heroicons-plus" @click="showCreateModal = true"
                        label="Nuevo Rol" />
                </template>
            </UDashboardNavbar>
        </template>

        <!-- Body -->
        <template #body>
            <div class="space-y-4">
                <!-- Filtros -->
                <div
                    class="flex flex-wrap items-center justify-between gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                    <div class="flex flex-wrap items-center gap-3">
                        <!-- Búsqueda -->
                        <UInput v-model="searchQuery" placeholder="Buscar por nombre o descripción..."
                            icon="i-heroicons-magnifying-glass" class="min-w-[300px]" @input="debouncedSearch" />

                        <!-- Filtro por tipo -->
                        <USelect v-model="filters.tipo" :options="tipoOptions" placeholder="Tipo de rol"
                            class="min-w-[180px]" @change="loadRoles" />

                        <!-- Filtro por nivel -->
                        <UInput v-model="filters.nivel_min" type="number" placeholder="Nivel min" class="w-28"
                            @change="loadRoles" />
                        <span class="text-gray-400">-</span>
                        <UInput v-model="filters.nivel_max" type="number" placeholder="Nivel max" class="w-28"
                            @change="loadRoles" />

                        <!-- Filtro por estado -->
                        <USelect v-model="filters.activo" :options="statusOptions" placeholder="Estado"
                            class="min-w-[150px]" @change="loadRoles" />
                    </div>

                    <div class="flex items-center gap-2">
                        <!-- Actualizar -->
                        <UButton color="gray" variant="ghost" icon="i-heroicons-arrow-path" @click="loadRoles"
                            :loading="loading" title="Actualizar" />
                    </div>
                </div>

                <!-- Estadísticas -->
                <div v-if="stats" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <UCard>
                        <template #header>
                            <h3 class="text-lg font-semibold">Total Roles</h3>
                        </template>
                        <div class="text-3xl font-bold">{{ stats.total }}</div>
                        <div class="text-sm text-gray-500 mt-2">{{ stats.activos }} activos</div>
                    </UCard>

                    <UCard>
                        <template #header>
                            <h3 class="text-lg font-semibold">Sistema</h3>
                        </template>
                        <div class="text-3xl font-bold text-blue-600">{{ stats.sistema }}</div>
                    </UCard>

                    <UCard>
                        <template #header>
                            <h3 class="text-lg font-semibold">Negocio</h3>
                        </template>
                        <div class="text-3xl font-bold text-green-600">{{ stats.negocio }}</div>
                    </UCard>

                    <UCard>
                        <template #header>
                            <h3 class="text-lg font-semibold">Personalizado</h3>
                        </template>
                        <div class="text-3xl font-bold text-purple-600">{{ stats.personalizado }}</div>
                    </UCard>
                </div>

                <!-- Tabla de roles -->
                <div class="border rounded-lg overflow-hidden">
                    <UTable :rows="roles" :columns="columns" :loading="loading" :empty-state="{
                        icon: 'i-heroicons-shield-check',
                        label: 'No se encontraron roles',
                        description: 'Intenta cambiar los filtros o crear un nuevo rol'
                    }" class="w-full">
                        <!-- Columna de nivel -->
                        <template #nivel-cell="{ row }">
                            <div class="flex items-center gap-2">
                                <UIcon :name="getLevelIcon(row.original.nivel)" class="w-4 h-4"
                                    :class="getLevelColor(row.original.nivel)" />
                                <span>{{ row.original.nivel }}</span>
                            </div>
                        </template>

                        <!-- Columna de tipo -->
                        <template #tipo-cell="{ row }">
                            <UBadge :color="getTypeColor(row.original.tipo)" variant="subtle" class="capitalize">
                                {{ row.original.tipo }}
                            </UBadge>
                        </template>

                        <!-- Columna de estado -->
                        <template #activo-cell="{ row }">
                            <UBadge :color="row.original.activo ? 'green' : 'red'" variant="subtle">
                                {{ row.original.activo ? 'Activo' : 'Inactivo' }}
                            </UBadge>
                        </template>

                        <!-- Columna de usuarios -->
                        <template #total_usuarios-cell="{ row }">
                            <div class="flex items-center gap-2">
                                <UIcon name="i-heroicons-users" class="w-4 h-4 text-gray-400" />
                                <span>{{ row.original.total_usuarios || 0 }}</span>
                            </div>
                        </template>

                        <!-- Columna de permisos -->
                        <template #total_permisos-cell="{ row }">
                            <div class="flex items-center gap-2">
                                <UIcon name="i-heroicons-key" class="w-4 h-4 text-gray-400" />
                                <span>{{ row.original.total_permisos || 0 }}</span>
                            </div>
                        </template>

                        <!-- Columna de fecha creación -->
                        <template #fecha_creacion-cell="{ row }">
                            {{ formatDate(row.original.fecha_creacion) }}
                        </template>

                        <!-- Columna de acciones -->
                        <template #actions-cell="{ row }">
                            <div class="flex items-center gap-1">
                                <!-- Ver detalles -->
                                <UButton color="gray" variant="ghost" icon="i-heroicons-eye" size="xs"
                                    @click="viewRoleDetails(row.original)" title="Ver detalles" />

                                <!-- Editar -->
                                <UButton color="primary" variant="ghost" icon="i-heroicons-pencil-square" size="xs"
                                    @click="editRole(row.original)" title="Editar" />

                                <!-- Menú de acciones -->
                                <UDropdownMenu>
                                    <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-vertical"
                                        size="xs" />
                                    <template #content>
                                        <!-- Ver usuarios -->
                                        <UButton variant="ghost" icon="i-heroicons-users" label="Ver usuarios"
                                            @click="viewRoleUsers(row.original)" />

                                        <!-- Gestionar permisos -->
                                        <UButton variant="ghost" icon="i-heroicons-key" label="Gestionar permisos"
                                            @click="managePermissions(row.original)" />

                                        <UDivider />

                                        <!-- Activar/Desactivar -->
                                        <UButton :variant="row.original.activo ? 'ghost' : 'ghost'"
                                            :icon="row.original.activo ? 'i-heroicons-x-circle' : 'i-heroicons-check-circle'"
                                            :label="row.original.activo ? 'Desactivar' : 'Activar'"
                                            @click="toggleRoleStatus(row.original)" />

                                        <!-- Eliminar -->
                                        <UButton variant="ghost" color="red" icon="i-heroicons-trash" label="Eliminar"
                                            @click="deleteRole(row.original)" />
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
                        {{ Math.min(currentPage * pageSize, totalRoles) }} de
                        {{ totalRoles }} roles
                    </div>

                    <UPagination v-model="currentPage" :page-count="pageSize" :total="totalRoles"
                        @update:model-value="loadRoles" />
                </div>
            </div>
        </template>
    </UDashboardPanel>

    <!-- Modal para crear/editar rol -->
    <UModal v-model="showCreateModal">
        <UCard>
            <template #header>
                <h3 class="text-lg font-semibold">
                    {{ editingRole ? 'Editar Rol' : 'Crear Nuevo Rol' }}
                </h3>
            </template>

            <UForm :state="roleForm" class="space-y-4" @submit="saveRole">
                <UFormGroup label="Nombre" required>
                    <UInput v-model="roleForm.nombre" placeholder="Ej: Gerente de Ventas" :maxlength="100" />
                </UFormGroup>

                <UFormGroup label="Descripción">
                    <UTextarea v-model="roleForm.descripcion" placeholder="Descripción del rol..." :maxlength="255" />
                </UFormGroup>

                <div class="grid grid-cols-2 gap-4">
                    <UFormGroup label="Nivel" required>
                        <UInput v-model="roleForm.nivel" type="number" min="1" max="100" placeholder="1-100" />
                    </UFormGroup>

                    <UFormGroup label="Tipo" required>
                        <USelect v-model="roleForm.tipo" :options="tipoOptions" />
                    </UFormGroup>
                </div>

                <UFormGroup label="Estado">
                    <UToggle v-model="roleForm.activo" :label="roleForm.activo ? 'Activo' : 'Inactivo'" />
                </UFormGroup>

                <!-- Selección de permisos -->
                <UFormGroup label="Permisos">
                    <div class="space-y-2">
                        <div v-for="modulo in permisosPorModulo" :key="modulo.nombre">
                            <div class="flex items-center justify-between p-2 bg-gray-50 rounded">
                                <span class="font-medium">{{ modulo.nombre }}</span>
                                <UToggle v-model="modulo.seleccionado"
                                    @update:model-value="toggleAllPermissions(modulo)" />
                            </div>
                            <div class="grid grid-cols-2 gap-2 mt-2 ml-4">
                                <UCheckbox v-for="permiso in modulo.permisos" :key="permiso.permiso_id"
                                    v-model="roleForm.permisos" :value="permiso.permiso_id" :label="permiso.nombre"
                                    :description="permiso.descripcion" />
                            </div>
                        </div>
                    </div>
                </UFormGroup>

                <template #footer>
                    <div class="flex justify-end gap-2">
                        <UButton color="gray" variant="ghost" @click="showCreateModal = false">
                            Cancelar
                        </UButton>
                        <UButton type="submit" color="primary" :loading="savingRole">
                            {{ editingRole ? 'Actualizar' : 'Crear' }}
                        </UButton>
                    </div>
                </template>
            </UForm>
        </UCard>
    </UModal>

    <!-- Modal para ver detalles del rol -->
    <UModal v-model="showDetailsModal" size="2xl">
        <UCard v-if="selectedRole">
            <template #header>
                <div class="flex items-center justify-between">
                    <h3 class="text-lg font-semibold">Detalles del Rol</h3>
                    <UButton color="gray" variant="ghost" icon="i-heroicons-x-mark" @click="showDetailsModal = false" />
                </div>
            </template>

            <div class="space-y-6">
                <!-- Información básica -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Nombre</label>
                        <p class="mt-1 font-medium">{{ selectedRole.nombre }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Tipo</label>
                        <UBadge :color="getTypeColor(selectedRole.tipo)" class="mt-1">
                            {{ selectedRole.tipo }}
                        </UBadge>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Nivel</label>
                        <p class="mt-1">{{ selectedRole.nivel }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Estado</label>
                        <UBadge :color="selectedRole.activo ? 'green' : 'red'" class="mt-1">
                            {{ selectedRole.activo ? 'Activo' : 'Inactivo' }}
                        </UBadge>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Usuarios asignados</label>
                        <p class="mt-1">{{ selectedRole.total_usuarios || 0 }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">Permisos</label>
                        <p class="mt-1">{{ selectedRole.total_permisos || 0 }}</p>
                    </div>
                </div>

                <!-- Descripción -->
                <div v-if="selectedRole.descripcion">
                    <label class="block text-sm font-medium text-gray-500">Descripción</label>
                    <p class="mt-1 text-gray-700">{{ selectedRole.descripcion }}</p>
                </div>

                <!-- Permisos por módulo -->
                <div>
                    <label class="block text-sm font-medium text-gray-500 mb-2">Permisos</label>
                    <div class="space-y-3">
                        <div v-for="(permisos, modulo) in selectedRole.permisos_por_modulo" :key="modulo"
                            class="border rounded p-3">
                            <h4 class="font-medium mb-2">{{ modulo }}</h4>
                            <div class="grid grid-cols-2 gap-2">
                                <div v-for="permiso in permisos" :key="permiso.permiso_id" class="text-sm">
                                    <div class="flex items-center gap-2">
                                        <UIcon :name="permiso.concedido ? 'i-heroicons-check' : 'i-heroicons-x-mark'"
                                            :class="permiso.concedido ? 'text-green-500' : 'text-red-500'"
                                            class="w-4 h-4" />
                                        <span>{{ permiso.nombre }}</span>
                                    </div>
                                    <div class="text-xs text-gray-500 ml-6">{{ permiso.descripcion }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Usuarios asignados -->
                <div v-if="selectedRole.usuarios && selectedRole.usuarios.length > 0">
                    <label class="block text-sm font-medium text-gray-500 mb-2">Usuarios Asignados</label>
                    <div class="border rounded overflow-hidden">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500">Usuario</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500">Tipo</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500">Asignación</th>
                                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500">Estado</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                <tr v-for="usuario in selectedRole.usuarios" :key="usuario.usuario_id">
                                    <td class="px-4 py-2 text-sm">
                                        <div>{{ usuario.email }}</div>
                                        <div v-if="usuario.empleado_nombre" class="text-xs text-gray-500">
                                            {{ usuario.empleado_nombre }} {{ usuario.empleado_apellido }}
                                        </div>
                                        <div v-else-if="usuario.cliente_nombre" class="text-xs text-gray-500">
                                            {{ usuario.cliente_nombre }} {{ usuario.cliente_apellido }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-2 text-sm">{{ usuario.tipo_usuario }}</td>
                                    <td class="px-4 py-2 text-sm">
                                        <div>{{ formatDate(usuario.fecha_asignacion) }}</div>
                                        <div v-if="usuario.asignado_por_email" class="text-xs text-gray-500">
                                            Por: {{ usuario.asignado_por_email }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-2">
                                        <UBadge :color="usuario.rol_activo ? 'green' : 'red'" size="xs">
                                            {{ usuario.rol_activo ? 'Activo' : 'Inactivo' }}
                                        </UBadge>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </UCard>
    </UModal>
</template>
<script setup lang="ts">
import type { Role, RoleForm, RoleFilters } from '~/types/role'
import { useDebounceFn } from '@vueuse/core'
import { useRoles } from '~/composables/useRoles'

definePageMeta({
    layout: 'dashboard',
    middleware: ['auth']
})

/* ===============================
   COMPOSABLES
================================ */
const {
    getRoles,
    getRoleById,
    getPermissions,
    createRole,
    updateRole,
    deleteRole
} = useRoles()

const toast = useToast()

/* ===============================
   STATE
================================ */
const loading = ref(false)
const savingRole = ref(false)

const currentPage = ref(1)
const pageSize = 10
const totalRoles = ref(0)

const roles = ref<Role[]>([])
const stats = ref<any>(null)

const selectedRole = ref<Role | null>(null)
const editingRole = ref<Role | null>(null)

const showCreateModal = ref(false)
const showDetailsModal = ref(false)

const searchQuery = ref('')

const filters = ref<RoleFilters>({
    tipo: '',
    nivel_min: '',
    nivel_max: '',
    activo: 'true'
})

const roleForm = ref<RoleForm>({
    nombre: '',
    descripcion: '',
    nivel: 10,
    tipo: 'Personalizado',
    activo: true,
    permisos: []
})

const allPermissions = ref<any[]>([])
const permisosPorModulo = ref<any[]>([])

/* ===============================
   UI HELPERS
================================ */
const getTypeColor = (type: string) => {
    const colors: Record<string, string> = {
        Sistema: 'red',
        Negocio: 'blue',
        Personalizado: 'green'
    }
    return colors[type] || 'gray'
}

const getLevelIcon = (level: number) => {
    if (level >= 80) return 'i-heroicons-shield-check'
    if (level >= 50) return 'i-heroicons-shield-exclamation'
    return 'i-heroicons-shield'
}

const getLevelColor = (level: number) => {
    if (level >= 80) return 'text-red-500'
    if (level >= 50) return 'text-yellow-500'
    return 'text-green-500'
}

const formatDate = (date: string) => {
    if (!date) return ''
    return new Date(date).toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    })
}

/* ===============================
   LOAD ROLES
================================ */
const loadRoles = async () => {
    try {
        loading.value = true

        const params: any = {
            page: currentPage.value,
            limit: pageSize
        }

        if (searchQuery.value) params.q = searchQuery.value
        if (filters.value.tipo) params.tipo = filters.value.tipo
        if (filters.value.nivel_min) params.nivel_min = filters.value.nivel_min
        if (filters.value.nivel_max) params.nivel_max = filters.value.nivel_max
        if (filters.value.activo !== '') params.activo = filters.value.activo

        const { data } = await getRoles(params)

        if (data.value?.success) {
            roles.value = data.value.data
            totalRoles.value = data.value.meta?.pagination?.total || 0
            stats.value = data.value.meta?.stats
        }
    } catch (error) {
        toast.add({
            title: 'Error',
            description: 'No se pudieron cargar los roles',
            color: 'red'
        })
    } finally {
        loading.value = false
    }
}

/* ===============================
   LOAD PERMISSIONS
================================ */
const loadPermissions = async () => {
    try {
        const { data } = await getPermissions()

        if (data.value?.success) {
            allPermissions.value = data.value.data.todos

            const grouped: Record<string, any> = {}

            allPermissions.value.forEach(p => {
                if (!grouped[p.modulo]) {
                    grouped[p.modulo] = {
                        nombre: p.modulo,
                        permisos: [],
                        seleccionado: false
                    }
                }
                grouped[p.modulo].permisos.push(p)
            })

            permisosPorModulo.value = Object.values(grouped)
        }
    } catch (error) {
        console.error('Error permisos:', error)
    }
}

/* ===============================
   SEARCH
================================ */
const debouncedSearch = useDebounceFn(() => {
    currentPage.value = 1
    loadRoles()
}, 500)

/* ===============================
   DETAILS
================================ */
const viewRoleDetails = async (role: Role) => {
    const { data } = await getRoleById(role.rol_id)

    if (data.value?.success) {
        selectedRole.value = data.value.data
        showDetailsModal.value = true
    }
}

/* ===============================
   EDIT ROLE
================================ */
const editRole = async (role: Role) => {
    editingRole.value = role

    roleForm.value = {
        nombre: role.nombre,
        descripcion: role.descripcion || '',
        nivel: role.nivel,
        tipo: role.tipo,
        activo: role.activo,
        permisos: []
    }

    const { data } = await getRoleById(role.rol_id)

    if (data.value?.success) {
        roleForm.value.permisos = data.value.data.permisos
            .filter((p: any) => p.concedido)
            .map((p: any) => p.permiso_id)
    }

    showCreateModal.value = true
}

/* ===============================
   SAVE ROLE
================================ */
const saveRole = async () => {
    try {
        savingRole.value = true

        const action = editingRole.value
            ? updateRole(editingRole.value.rol_id, roleForm.value)
            : createRole(roleForm.value)

        const { data } = await action

        if (data.value?.success) {
            toast.add({
                title: 'Éxito',
                description: editingRole.value
                    ? 'Rol actualizado correctamente'
                    : 'Rol creado correctamente',
                color: 'green'
            })

            showCreateModal.value = false
            editingRole.value = null

            roleForm.value = {
                nombre: '',
                descripcion: '',
                nivel: 10,
                tipo: 'Personalizado',
                activo: true,
                permisos: []
            }

            loadRoles()
        }
    } finally {
        savingRole.value = false
    }
}

/* ===============================
   DELETE ROLE
================================ */
const deleteRoleAction = async (role: Role) => {
    if (!confirm(`¿Eliminar el rol "${role.nombre}"?`)) return

    const { data } = await deleteRole(role.rol_id)

    if (data.value?.success) {
        toast.add({
            title: 'Éxito',
            description: 'Rol eliminado correctamente',
            color: 'green'
        })
        loadRoles()
    }
}

/* ===============================
   PERMISSIONS
================================ */
const toggleAllPermissions = (modulo: any) => {
    if (modulo.seleccionado) {
        modulo.permisos.forEach((p: any) => {
            if (!roleForm.value.permisos.includes(p.permiso_id)) {
                roleForm.value.permisos.push(p.permiso_id)
            }
        })
    } else {
        roleForm.value.permisos = roleForm.value.permisos.filter(
            id => !modulo.permisos.some((p: any) => p.permiso_id === id)
        )
    }
}

/* ===============================
   INIT
================================ */
onMounted(() => {
    loadRoles()
    loadPermissions()
})
</script>
