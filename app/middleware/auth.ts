// ~/middleware/auth.ts
export default defineNuxtRouteMiddleware((to, from) => {
    const accessToken = useCookie('access_token')

    // Rutas protegidas
    const protectedRoutes = ['/dashboard', '/profile', '/settings']

    // Si la ruta requiere auth y NO hay token → redirigir
    if (protectedRoutes.some(route => to.path.startsWith(route))) {
        if (!accessToken.value) {
            return navigateTo('/login')
        }
    }
})
