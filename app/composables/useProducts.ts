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
        return useApiFetch<ProductsResponse>(`/products${query}`)
    }

    const getProductById = (id: number) => {
        return useApiFetch<Product>(`/products/${id}`)
    }

    const createProduct = (productData: Partial<Product>) => {
        return useApiFetch(`/products`, {
            method: 'POST',
            body: productData
        })
    }

    const updateProduct = (id: number, productData: Partial<Product>) => {
        return useApiFetch(`/products/${id}`, {
            method: 'PUT',
            body: productData
        })
    }

    const deleteProduct = (id: number) => {
        return useApiFetch(`/products/${id}`, {
            method: 'DELETE'
        })
    }

    const searchByBarcode = (barcode: string) => {
        return useApiFetch<Product>(`/products/barcode/${barcode}`)
    }

    // ========== VARIANTES ==========
    const createVariant = (producto_id: number, data: any) => {
        return useApiFetch(`/products/${producto_id}/variantes`, {
            method: 'POST',
            body: data
        })
    }

    const updateVariantStock = (variante_id: number, data: any) => {
        return useApiFetch(`/products/variantes/${variante_id}/stock`, {
            method: 'PUT',
            body: data
        })
    }

    // ========== ESTADÍSTICAS ==========
    const getLowStockProducts = (limit?: number) => {
        return useApiFetch<Product[]>(
            `/products/stats/low-stock?limit=${limit}`
        )
    }

    const getProductStats = () => {
        return useApiFetch<ProductStats>(
            `/products/stats/overview`
        )
    }

    // ========== DATOS MAESTROS ==========
    const getCategories = () => {
        return useApiFetch<Category[]>(`/categories`)
    }

    const getBrands = () => {
        return useApiFetch<Brand[]>(`/brands`)
    }

    const getWarehouses = () => {
        return useApiFetch<Warehouse[]>(`/warehouses`)
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
