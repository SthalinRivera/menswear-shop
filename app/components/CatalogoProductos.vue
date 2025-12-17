<script setup lang="ts">
interface Producto {
    producto_id: number
    nombre: string
    descripcion: string
    precio_final: string
    categoria_nombre: string
    marca_nombre: string
    imagenes: { url?: string }[]
}

const props = defineProps<{
    productos: Producto[]
}>()

// Si no hay imagen → usa un placeholder
const getImage = (p: Producto) => {
    return p.imagenes?.[0]?.url || "https://placehold.co/400x400?text=Sin+Imagen"
}
</script>

<template>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 py-6">
        <UCard v-for="p in productos" :key="p.producto_id"
            class="border border-gray-200 dark:border-gray-700 hover:shadow-lg transition">
            <img :src="getImage(p)" alt="Producto" class="w-full h-48 object-cover rounded-md mb-3" />

            <h3 class="text-lg font-semibold mb-2">{{ p.nombre }}</h3>

            <p class="text-sm text-gray-600 dark:text-gray-300 line-clamp-2 mb-3">
                {{ p.descripcion }}
            </p>

            <div class="text-sm text-gray-500 dark:text-gray-400 mb-3">
                Categoría: {{ p.categoria_nombre }}
                <br />
                Marca: {{ p.marca_nombre }}
            </div>

            <div class="text-xl font-bold mb-4">
                S/ {{ Number(p.precio_final).toFixed(2) }}
            </div>

            <UButton color="primary" block @click="$router.push(`/${p.producto_id}`)">
                Ver detalles
            </UButton>
        </UCard>
    </div>
</template>
