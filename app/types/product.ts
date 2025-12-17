
import type { AvatarProps } from '@nuxt/ui'
export interface ProductVariant {
    variante_id: number
    producto_id: number
    talla: string
    color_nombre: string
    color_hex: string
    stock_actual: number
    stock_reservado: number
    stock_disponible: number
    stock_total_almacenes: string
    ubicacion_almacen: string | null
    codigo_barras: string
    activo: boolean
    fecha_ultima_entrada: string | null
    fecha_ultima_salida: string | null
    inventario?: Array<{
        almacen_id: number
        nombre: string
        cantidad: number
        ubicacion: string
    }>
}

export interface Product {
    producto_id: number
    sku: string
    nombre: string
    descripcion: string
    categoria_id: number
    marca_id: number
    genero: string
    temporada: string
    material_principal: string
    cuidados: string
    precio_compra: string
    precio_venta: string
    impuesto_porcentaje: string
    es_promocion: boolean
    porcentaje_descuento: string
    precio_promocion: string | null
    fecha_inicio_promocion: string | null
    fecha_fin_promocion: string | null
    stock_minimo: number
    stock_maximo: number
    activo: boolean
    fecha_creacion: string
    fecha_actualizacion: string
    margen_ganancia: string
    costo_impuesto: string
    precio_final: string
    categoria_nombre: string
    marca_nombre: string
    stock_total: string
    variantes: ProductVariant[]
    imagenes: any[]
}

export interface ProductsResponse {
    success: boolean
    data: Product[]
    pagination: {
        page: number
        limit: number
        total: number
        pages: number
    }
}

export interface ProductStats {
    top_selling: Array<{
        producto_id: number
        nombre: string
        sku: string
        total_vendido: number
        ingresos_totales: number
        veces_vendido: number
    }>
    best_margin: Array<{
        producto_id: number
        nombre: string
        sku: string
        precio_compra: string
        precio_venta: string
        margen_ganancia: string
    }>
    no_sales: Array<{
        producto_id: number
        nombre: string
        sku: string
        fecha_creacion: string
        stock_minimo: number
        stock_actual: number
    }>
    low_stock: Array<{
        producto_id: number
        nombre: string
        sku: string
        stock_total: number
        stock_minimo: number
        estado: 'CRÍTICO' | 'BAJO' | 'OK'
    }>
    active_promotions: Array<{
        producto_id: number
        nombre: string
        sku: string
        precio_venta: string
        precio_promocion: string
        porcentaje_descuento: string
        fecha_inicio_promocion: string
        fecha_fin_promocion: string
    }>
}

export interface Category {
    categoria_id: number
    nombre: string
    categoria_padre_id: number | null
    descripcion: string | null
    activo: boolean
    categoria_padre_nombre?: string
}

export interface Brand {
    marca_id: number
    nombre: string
    descripcion: string | null
    activo: boolean
}

export interface Warehouse {
    almacen_id: number
    nombre: string
    ubicacion: string
    capacidad: number
    activo: boolean
}