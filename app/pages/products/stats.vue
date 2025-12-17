<script setup lang="ts">
import { useProducts } from '~/composables/useProducts'
import type { ProductStats } from '~/types/product'

const { getProductStats, getLowStockProducts } = useProducts()

// Cargar estadísticas
const { data: stats, pending: statsPending } = await getProductStats()
const { data: lowStockProducts, pending: lowStockPending } = await getLowStockProducts(10)

// Filtros para gráficos
const timeRange = ref('30d')
const chartType = ref('bar')

// Datos para gráficos (ejemplo)
const salesChartData = ref({
    labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'],
    datasets: [
        {
            label: 'Ventas',
            data: [65, 59, 80, 81, 56, 55],
            backgroundColor: 'rgba(59, 130, 246, 0.5)'
        },
        {
            label: 'Margen',
            data: [28, 48, 40, 19, 86, 27],
            backgroundColor: 'rgba(34, 197, 94, 0.5)'
        }
    ]
})

const inventoryChartData = ref({
    labels: ['En stock', 'Bajo stock', 'Agotado'],
    datasets: [{
        data: [120, 25, 8],
        backgroundColor: [
            'rgba(34, 197, 94, 0.5)',
            'rgba(234, 179, 8, 0.5)',
            'rgba(239, 68, 68, 0.5)'
        ]
    }]
})
</script>

<template>
    <UDashboardPanel>
        <template #header>
            <UDashboardNavbar title="Estadísticas de Productos">
                <template #leading>
                    <UDashboardSidebarCollapse />
                </template>

                <template #right>
                    <div class="flex items-center gap-2">
                        <USelect v-model="timeRange" :options="[
                            { value: '7d', label: 'Últimos 7 días' },
                            { value: '30d', label: 'Últimos 30 días' },
                            { value: '90d', label: 'Últimos 90 días' },
                            { value: '1y', label: 'Último año' }
                        ]" size="sm" class="w-40" />
                        <UButton icon="i-lucide-download" label="Exportar" color="neutral" variant="outline"
                            size="sm" />
                    </div>
                </template>
            </UDashboardNavbar>
        </template>

        <template #body>
            <div class="space-y-6">
                <!-- Resumen general -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    <UCard>
                        <template #header>
                            <div class="flex items-center gap-2">
                                <i class="i-lucide-trending-up text-blue-500" />
                                <h3 class="text-sm font-medium">Productos Activos</h3>
                            </div>
                        </template>
                        <div class="text-3xl font-bold">156</div>
                        <p class="text-xs text-muted mt-2">+12 este mes</p>
                    </UCard>

                    <UCard>
                        <template #header>
                            <div class="flex items-center gap-2">
                                <i class="i-lucide-alert-triangle text-yellow-500" />
                                <h3 class="text-sm font-medium">Stock Bajo</h3>
                            </div>
                        </template>
                        <div class="text-3xl font-bold">25</div>
                        <p class="text-xs text-muted mt-2">Necesitan reabastecimiento</p>
                    </UCard>

                    <UCard>
                        <template #header>
                            <div class="flex items-center gap-2">
                                <i class="i-lucide-percent text-green-500" />
                                <h3 class="text-sm font-medium">En Promoción</h3>
                            </div>
                        </template>
                        <div class="text-3xl font-bold">18</div>
                        <p class="text-xs text-muted mt-2">-15% descuento promedio</p>
                    </UCard>

                    <UCard>
                        <template #header>
                            <div class="flex items-center gap-2">
                                <i class="i-lucide-x-circle text-red-500" />
                                <h3 class="text-sm font-medium">Sin Ventas</h3>
                            </div>
                        </template>
                        <div class="text-3xl font-bold">8</div>
                        <p class="text-xs text-muted mt-2">Últimos 60 días</p>
                    </UCard>
                </div>

                <!-- Gráficos -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <!-- Gráfico de ventas -->
                    <UCard>
                        <template #header>
                            <div class="flex justify-between items-center">
                                <h3 class="text-lg font-semibold">Ventas y Margen</h3>
                                <USelect v-model="chartType" :options="['bar', 'line', 'area']" size="xs"
                                    class="w-24" />
                            </div>
                        </template>
                        <div class="h-64">
                            <!-- Aquí iría el componente de gráfico (Chart.js, etc.) -->
                            <div class="h-full flex items-center justify-center bg-gray-50 rounded">
                                <p class="text-muted">Gráfico de ventas y margen</p>
                            </div>
                        </div>
                    </UCard>

                    <!-- Gráfico de inventario -->
                    <UCard>
                        <template #header>
                            <h3 class="text-lg font-semibold">Estado del Inventario</h3>
                        </template>
                        <div class="h-64">
                            <!-- Aquí iría el componente de gráfico -->
                            <div class="h-full flex items-center justify-center bg-gray-50 rounded">
                                <p class="text-muted">Gráfico de inventario</p>
                            </div>
                        </div>
                    </UCard>
                </div>

                <!-- Productos más vendidos -->
                <UCard>
                    <template #header>
                        <h3 class="text-lg font-semibold">Productos Más Vendidos</h3>
                    </template>

                    <div v-if="statsPending" class="space-y-3">
                        <div v-for="i in 5" :key="i" class="animate-pulse h-12 bg-gray-200 rounded" />
                    </div>

                    <div v-else-if="stats?.top_selling" class="space-y-4">
                        <div v-for="product in stats.top_selling" :key="product.producto_id"
                            class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                                    <i class="i-lucide-package text-gray-400" />
                                </div>
                                <div>
                                    <p class="font-medium">{{ product.nombre }}</p>
                                    <p class="text-xs text-muted">{{ product.sku }}</p>
                                </div>
                            </div>

                            <div class="flex items-center gap-6">
                                <div class="text-right">
                                    <p class="font-bold">${{ product.ingresos_totales.toFixed(2) }}</p>
                                    <p class="text-xs text-muted">{{ product.total_vendido }} unidades</p>
                                </div>
                                <UBadge variant="subtle" color="green">
                                    {{ product.veces_vendido }} ventas
                                </UBadge>
                            </div>
                        </div>
                    </div>
                </UCard>

                <!-- Productos con stock bajo -->
                <UCard>
                    <template #header>
                        <div class="flex justify-between items-center">
                            <h3 class="text-lg font-semibold">Stock Bajo / Crítico</h3>
                            <UButton label="Ver todos" color="neutral" variant="ghost" size="sm"
                                to="/products/low-stock" />
                        </div>
                    </template>

                    <div v-if="lowStockPending" class="space-y-3">
                        <div v-for="i in 5" :key="i" class="animate-pulse h-12 bg-gray-200 rounded" />
                    </div>

                    <div v-else-if="lowStockProducts" class="space-y-4">
                        <div v-for="product in lowStockProducts" :key="product.producto_id"
                            class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                                    <i class="i-lucide-alert-triangle text-yellow-500" />
                                </div>
                                <div>
                                    <p class="font-medium">{{ product.nombre }}</p>
                                    <p class="text-xs text-muted">{{ product.sku }} • {{ product.categoria_nombre }}</p>
                                </div>
                            </div>

                            <div class="flex items-center gap-4">
                                <div class="text-right">
                                    <p class="font-bold" :class="{
                                        'text-red-600': product.estado_stock === 'CRÍTICO',
                                        'text-yellow-600': product.estado_stock === 'BAJO'
                                    }">
                                        {{ product.stock_total }} / {{ product.stock_minimo }}
                                    </p>
                                    <p class="text-xs text-muted">Stock actual / mínimo</p>
                                </div>
                                <UBadge :variant="product.estado_stock === 'CRÍTICO' ? 'solid' : 'subtle'"
                                    :color="product.estado_stock === 'CRÍTICO' ? 'red' : 'yellow'">
                                    {{ product.estado_stock }}
                                </UBadge>
                            </div>
                        </div>
                    </div>
                </UCard>

                <!-- Productos en promoción -->
                <UCard>
                    <template #header>
                        <h3 class="text-lg font-semibold">Promociones Activas</h3>
                    </template>

                    <div v-if="statsPending" class="space-y-3">
                        <div v-for="i in 5" :key="i" class="animate-pulse h-12 bg-gray-200 rounded" />
                    </div>

                    <div v-else-if="stats?.active_promotions"
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <div v-for="promo in stats.active_promotions" :key="promo.producto_id"
                            class="border rounded-lg p-4 hover:border-gray-300">
                            <div class="flex justify-between items-start">
                                <div>
                                    <p class="font-medium">{{ promo.nombre }}</p>
                                    <p class="text-xs text-muted">{{ promo.sku }}</p>
                                </div>
                                <UBadge variant="solid" color="green">
                                    -{{ promo.porcentaje_descuento }}%
                                </UBadge>
                            </div>

                            <div class="mt-4">
                                <div class="flex justify-between items-center mb-2">
                                    <span class="text-sm line-through text-muted">${{
                                        parseFloat(promo.precio_venta).toFixed(2)
                                        }}</span>
                                    <span class="text-lg font-bold text-green-600">${{
                                        parseFloat(promo.precio_promocion).toFixed(2)
                                        }}</span>
                                </div>

                                <div class="text-xs text-muted">
                                    <p>Válido hasta: {{ new Date(promo.fecha_fin_promocion).toLocaleDateString() }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </UCard>
            </div>
        </template>
    </UDashboardPanel>
</template>