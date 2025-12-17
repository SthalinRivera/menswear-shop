// ~/types/auth.ts
export interface User {
    usuario_id: number
    email: string
    tipo_usuario: string
    nombre: string
    apellido: string
    roles: string[]
    email_verificado?: boolean
    provider?: string
    fecha_creacion?: string
}

export interface LoginData {
    email: string
    password: string
}

export interface RegisterData {
    email: string
    password: string
    nombre: string
    apellido?: string
    telefono?: string
    fecha_nacimiento?: string
    genero?: string
}

export interface LoginResponse {
    success: boolean
    message: string
    data: {
        user: User
        access_token: string
        refresh_token: string
    }
}