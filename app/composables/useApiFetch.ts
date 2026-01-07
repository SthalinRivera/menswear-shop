export const useApiFetch = <T>(url: string, options: any = {}) => {
    const config = useRuntimeConfig()
    const token = useCookie('access_token')

    console.log('📡 Llamando API:', `${config.public.apiBaseUrl}${url}`)
    console.log('🔐 Token:', token.value)
    return useFetch<T>(`${config.public.apiBaseUrl}${url}`, {

        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: token.value ? `Bearer ${token.value}` : ''
        }
    })
}
