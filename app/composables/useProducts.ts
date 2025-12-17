import type {
    Product,
    ProductsResponse,
    ProductStats,
    Category,
    Brand,
    Warehouse
} from '~/types/product'

export const useProducts = () => {

    // ========== PRODUCTOS ==========
    const getProducts = (params?: Record<string, any>) => {
        const query = params
            ? `?${new URLSearchParams(params).toString()}`
            : ''
        return useApiFetch<ProductsResponse>(`/api/v1/products${query}`)
    }

    const getProductById = (id: number) => {
        return useApiFetch<Product>(`/api/v1/products/${id}`)
    }

    const createProduct = (productData: Partial<Product>) => {
        return useApiFetch(`/api/v1/products`, {
            method: 'POST',
            body: productData
        })
    }

    const updateProduct = (id: number, productData: Partial<Product>) => {
        return useApiFetch(`/api/v1/products/${id}`, {
            method: 'PUT',
            body: productData
        })
    }

    const deleteProduct = (id: number) => {
        return useApiFetch(`/api/v1/products/${id}`, {
            method: 'DELETE'
        })
    }

    const searchByBarcode = (barcode: string) => {
        return useApiFetch<Product>(`/api/v1/products/barcode/${barcode}`)
    }

    // ========== VARIANTES ==========
    const createVariant = (producto_id: number, data: any) => {
        return useApiFetch(`/api/v1/products/${producto_id}/variantes`, {
            method: 'POST',
            body: data
        })
    }

    const updateVariantStock = (variante_id: number, data: any) => {
        return useApiFetch(`/api/v1/products/variantes/${variante_id}/stock`, {
            method: 'PUT',
            body: data
        })
    }

    // ========== ESTADÍSTICAS ==========
    const getLowStockProducts = (limit?: number) => {
        return useApiFetch<Product[]>(
            `/api/v1/products/stats/low-stock?limit=${limit}`
        )
    }

    const getProductStats = () => {
        return useApiFetch<ProductStats>(
            `/api/v1/products/stats/overview`
        )
    }

    // ========== DATOS MAESTROS ==========
    const getCategories = () => {
        return useApiFetch<Category[]>(`/api/categories`)
    }

    const getBrands = () => {
        return useApiFetch<Brand[]>(`/api/brands`)
    }

    const getWarehouses = () => {
        return useApiFetch<Warehouse[]>(`/api/warehouses`)
    }

    return {
        getProducts,
        getProductById,
        createProduct,
        updateProduct,
        deleteProduct,
        searchByBarcode,
        createVariant,
        updateVariantStock,
        getLowStockProducts,
        getProductStats,
        getCategories,
        getBrands,
        getWarehouses
    }
}
