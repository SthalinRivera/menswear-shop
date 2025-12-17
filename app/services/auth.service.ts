// ~/services/auth.service.ts
import type { LoginResponse, User, RegisterData, LoginData } from '~/types/auth'

export const useAuthService = () => {

  const config = useRuntimeConfig()
  const baseURL = config.public.API_BASE_URL || 'https://menswear-shop-api.vercel.app/api/v1'
  console.log('AuthService initialized with baseURL:', baseURL)

  // Definir cookies aquí, accesibles para todos los métodos
  const accessToken = useCookie('access_token')
  const refreshTokenCookie = useCookie('refresh_token')
  const userCookie = useCookie('user')

  return {
    async login(credentials: LoginData): Promise<LoginResponse> {
      const response = await $fetch<LoginResponse>(`${baseURL}/auth/login`, {
        method: 'POST',
        body: credentials,
        headers: { 'Content-Type': 'application/json' },
      })

      if (response.success) {
        accessToken.value = response.data.access_token
        refreshTokenCookie.value = response.data.refresh_token
        userCookie.value = JSON.stringify(response.data.user)
      }

      return response
    },

    async logout() {
      if (!process.client) {
        console.warn("[AuthService] Logout ejecutado en SSR — sin acceso a cookies")
        return
      }

      const token = accessToken.value
      console.log('[AuthService] Token que se enviará al backend:', token)

      if (token) {
        const response = await $fetch(`${baseURL}/auth/logout`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        })
        console.log('[AuthService] Logout response:', response)
      }

      accessToken.value = null
      refreshTokenCookie.value = null
      userCookie.value = null

      console.log('[AuthService] Cookies limpiadas')
    },


    async refreshToken() {
      if (!process.client) return null

      const token = refreshTokenCookie.value
      if (!token) throw new Error('No refresh token available')

      const response = await $fetch(`${baseURL}/auth/refresh-token`, {
        method: 'POST',
        body: { refresh_token: token },
        headers: { 'Content-Type': 'application/json' },
      })

      if (response.success) {
        accessToken.value = response.data.access_token
        refreshTokenCookie.value = response.data.refresh_token
      }

      return response
    },

    isAuthenticated(): boolean {
      return !!accessToken.value
    },

    getToken(): string | null {
      return accessToken.value
    },

    getCurrentUser(): User | null {
      const userStr = userCookie.value
      return userStr ? JSON.parse(userStr) : null
    },

    async getProfile(): Promise<User | null> {
      const token = accessToken.value
      if (!token) return null

      const response = await $fetch(`${baseURL}/auth/profile`, {
        headers: { 'Authorization': `Bearer ${token}` },
      })
      return response.data.usuario
    },

    async register(userData: RegisterData) {
      const response = await $fetch(`${baseURL}/auth/register`, {
        method: 'POST',
        body: userData,
        headers: { 'Content-Type': 'application/json' },
      })
      return response
    }
  }
}
