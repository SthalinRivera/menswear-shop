// ~/types/user.ts
export interface User {
    usuario_id: number
    email: string
    tipo_usuario: 'Administrador' | 'Empleado' | 'Cliente'
    provider: 'local' | 'google'
    email_verificado: boolean
    activo: boolean
    fecha_creacion: string
    fecha_ultimo_login: string | null
    cliente_id: number | null
    empleado_id: number | null
    cliente_info?: any
    empleado_info?: any
    permisos?: any[]
    roles: string
    sesiones_activas?: any[]
    token_verificacion?: string
}

export interface UserForm {
    email: string
    tipo_usuario: string
    roles: string[]
    activo: boolean
    cliente_id: number | null
    empleado_id: number | null
}

export interface UserStats {
    total: number
    activos: number
    verificados: number
    empleados: number
    clientes: number
    administradores: number
    google_users: number
    local_users: number
}

export interface UserFilters {
    tipo_usuario: string
    activo: string
    email_verificado: string
}