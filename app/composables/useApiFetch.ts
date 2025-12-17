export const useApiFetch = <T>(url: string, options: any = {}) => {
    const config = useRuntimeConfig()
    const token = useCookie('access_token')

    return useFetch<T>(`${config.public.apiBaseUrl}${url}`, {
        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: token.value ? `Bearer ${token.value}` : ''
        }
    })
}
