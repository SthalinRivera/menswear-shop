export const useProductImagesService = () => {

    const createProductImages = (payload: {
        producto_id: number
        imagenes: {
            url: string
            es_principal?: boolean
            nombre_archivo?: string
        }[]
    }) => {
        return useApiFetch('/images', {
            method: 'POST',
            body: payload
        })
    }

    return {
        createProductImages
    }
}
