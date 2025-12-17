// ~/utils/auth.ts
export const isLoggedIn = () => {
    const token = useCookie('access_token')
    return !!token.value // true si existe, false si no
}
