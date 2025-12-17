// ~/middleware/guest.ts
import { useAuthService } from '~/services/auth.service'

export default defineNuxtRouteMiddleware((to, from) => {
    const { isAuthenticated } = useAuthService()

    const guestRoutes = ['/login', '/signup']
    if (guestRoutes.includes(to.path) && isAuthenticated()) {
        return navigateTo('/dashboard')
    }
})
