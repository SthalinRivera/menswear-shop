// ~/services/auth.service.ts
import type { LoginResponse, User, RegisterData, LoginData } from '~/types/auth'

export const useAuthService = () => {

  const config = useRuntimeConfig()

  const baseURL = config.public.apiBaseUrl
  if (!baseURL) {
    console.warn('[AuthService] apiBaseUrl no está definida')
  }
  // 🍪 Cookies (IMPORTANTE)
  const accessToken = useCookie('access_token', {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/'
  })

  const refreshTokenCookie = useCookie('refresh_token', {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/'
  })

  const userCookie = useCookie('user', {
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/'
  })


  return {
    async login(credentials: LoginData): Promise<LoginResponse> {
      const response = await $fetch<LoginResponse>(`${baseURL}/auth/login`, {
        method: 'POST',
        body: credentials,
        headers: { 'Content-Type': 'application/json' },
      })

      if (response.success) {
        accessToken.value = response.data.accessToken
        refreshTokenCookie.value = response.data.refreshToken
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
      if (token) {
        const response = await $fetch(`${baseURL}/auth/logout`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        })
      }

      accessToken.value = null
      refreshTokenCookie.value = null
      userCookie.value = null
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
        accessToken.value = response.data.accessToken
        refreshTokenCookie.value = response.data.refreshToken
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
