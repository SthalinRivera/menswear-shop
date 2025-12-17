import type { Role } from '~/types/role'

export const useRoles = () => {

    const getRoles = (params: any) => {
        return useApiFetch(`/api/v1/roles`, { params })
    }

    const getRoleById = (id: number) => {
        return useApiFetch(`/api/v1/roles/${id}`)
    }

    const getPermissions = () => {
        return useApiFetch(`/api/v1/roles/permissions`)
    }

    const createRole = (data: any) => {
        return useApiFetch(`/api/v1/roles`, {
            method: 'POST',
            body: data
        })
    }

    const updateRole = (id: number, data: any) => {
        return useApiFetch(`/api/v1/roles/${id}`, {
            method: 'PUT',
            body: data
        })
    }

    const deleteRole = (id: number) => {
        return useApiFetch(`/api/v1/roles/${id}`, {
            method: 'DELETE'
        })
    }

    return {
        getRoles,
        getRoleById,
        getPermissions,
        createRole,
        updateRole,
        deleteRole
    }
}
