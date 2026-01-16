<template>
    <UDashboardPanel id="customer-management">
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
           hola
        </template>
    </UDashboardPanel>

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
