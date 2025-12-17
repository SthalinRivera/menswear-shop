// ~/types/role.ts
export interface Role {
    rol_id: number
    nombre: string
    descripcion: string | null
    nivel: number
    tipo: 'Sistema' | 'Negocio' | 'Personalizado'
    activo: boolean
    fecha_creacion: string
    creado_por: number | null
    creado_por_email?: string
    total_usuarios: number
    total_permisos: number
    permisos?: any[]
    permisos_por_modulo?: Record<string, any[]>
    usuarios?: any[]
    modulos_disponibles?: string[]
}

export interface RoleForm {
    nombre: string
    descripcion: string
    nivel: number
    tipo: string
    activo: boolean
    permisos: number[]
}

export interface RoleFilters {
    tipo: string
    nivel_min: string
    nivel_max: string
    activo: string
}

export interface Permission {
    permiso_id: number
    codigo: string
    nombre: string
    descripcion: string | null
    modulo: string
    submodulo: string | null
    nivel: 'Lectura' | 'Escritura' | 'Eliminacion' | 'Administracion'
    activo: boolean
    fecha_creacion: string
}