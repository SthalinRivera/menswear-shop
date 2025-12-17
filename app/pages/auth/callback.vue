<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router'

definePageMeta({
    layout: 'auth'
})

const router = useRouter()
const route = useRoute()

const accessToken = useCookie('access_token')
const refreshToken = useCookie('refresh_token')

onMounted(() => {
    const at = route.query.access_token as string | undefined
    const rt = route.query.refresh_token as string | undefined

    if (at) accessToken.value = at
    if (rt) refreshToken.value = rt

    setTimeout(() => {
        router.push('/dashboard')
    }, 1000)
})
</script>

<template>

    <div class="">
        <!-- Progreso -->
        <UProgress :value="100" :ui="{
            root: 'bg-gray-200 dark:bg-gray-800',
            indicator: 'bg-primary-500',
        }" size="lg" />

        <!-- Texto -->
        <p class="text-center mt-4 text-sm text-gray-600 dark:text-gray-400">
            Autenticando con Google...
        </p>
    </div>

</template>