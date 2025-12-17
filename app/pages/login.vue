<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuthService } from '~/services/auth.service'  // <--- IMPORT NECESARIO

definePageMeta({
    layout: 'auth',
    middleware: ['guest'] // Asegúrate de que solo usuarios no autenticados puedan acceder
})

useSeoMeta({
    title: 'Login',
    description: 'Login to your account to continue'
})

const toast = useToast()
const router = useRouter()
const { login, isAuthenticated } = useAuthService()

const fields = [{
    name: 'email',
    type: 'text' as const,
    label: 'Email',
    placeholder: 'Enter your email',
    required: true
}, {
    name: 'password',
    label: 'Password',
    type: 'password' as const,
    placeholder: 'Enter your password',
    required: true
}, {
    name: 'remember',
    label: 'Remember me',
    type: 'checkbox' as const
}]

const config = useRuntimeConfig()

const providers = [
    {
        label: 'Google',
        icon: 'i-simple-icons-google',
        onClick: () => {
            window.location.href = `${config.public.apiBaseUrl}/auth/google`
        }
    }
]

const schema = z.object({
    email: z.string().email('Invalid email'),
    password: z.string().min(1, 'Password is required')
})

type Schema = z.output<typeof schema>

const isLoading = ref(false)

async function onSubmit(payload: FormSubmitEvent<Schema>) {
    isLoading.value = true

    try {
        const response = await login({
            email: payload.data.email,
            password: payload.data.password
        })

        if (response.success) {
            toast.add({
                title: 'Success',
                description: response.message,
                color: 'green',
                icon: 'i-heroicons-check-circle'
            })

            // Redirigir al dashboard
            router.push('/dashboard')
        } else {
            toast.add({
                title: 'Error',
                description: response.message || 'Login failed',
                color: 'red',
                icon: 'i-heroicons-exclamation-circle'
            })
        }
    } catch (error: any) {
        toast.add({
            title: 'Error',
            description: error.message || 'An error occurred during login',
            color: 'red',
            icon: 'i-heroicons-exclamation-circle'
        })
    } finally {
        isLoading.value = false
    }
}
</script>

<template>
    <UAuthForm :fields="fields" :schema="schema" :providers="providers" title="Welcome back" icon="i-lucide-lock"
        :submit="{ label: 'Sign in', loading: isLoading }" @submit="onSubmit">
        <template #description>
            Don't have an account? <ULink to="/signup" class="text-primary font-medium">Sign up</ULink>.
        </template>

        <template #password-hint>
            <ULink to="/forgot-password" class="text-primary font-medium" tabindex="-1">Forgot password?</ULink>
        </template>

        <template #footer>
            By signing in, you agree to our <ULink to="/terms" class="text-primary font-medium">Terms of Service</ULink>
            .
        </template>
    </UAuthForm>
</template>