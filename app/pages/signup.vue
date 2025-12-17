<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuthService } from '~/services/auth.service'  // <--- IMPORT NECESARIO
definePageMeta({
    layout: 'auth',
    middleware: ['guest']
})

useSeoMeta({
    title: 'Sign up',
    description: 'Create an account to get started'
})

const toast = useToast()
const router = useRouter()
const { register } = useAuthService()

const fields = [
    {
        name: 'nombre',
        type: 'text' as const,
        label: 'First Name',
        placeholder: 'Enter your first name',
        required: true
    },
    {
        name: 'apellido',
        type: 'text' as const,
        label: 'Last Name',
        placeholder: 'Enter your last name'
    },
    {
        name: 'email',
        type: 'text' as const,
        label: 'Email',
        placeholder: 'Enter your email',
        required: true
    },
    {
        name: 'telefono',
        type: 'text' as const,
        label: 'Phone',
        placeholder: 'Enter your phone number'
    },
    {
        name: 'password',
        label: 'Password',
        type: 'password' as const,
        placeholder: 'Enter your password',
        required: true
    }
]

const providers = [{
    label: 'Google',
    icon: 'i-simple-icons-google',
    onClick: () => {
        window.location.href = 'http://localhost:3000/api/v1/auth/google'
    }
}]

const schema = z.object({
    nombre: z.string().min(1, 'First name is required'),
    apellido: z.string().optional(),
    email: z.string().email('Invalid email'),
    telefono: z.string().optional(),
    password: z.string().min(8, 'Must be at least 8 characters')
})

type Schema = z.output<typeof schema>

const isLoading = ref(false)

async function onSubmit(payload: FormSubmitEvent<Schema>) {
    isLoading.value = true

    try {
        const response = await register(payload.data)

        if (response.success) {
            toast.add({
                title: 'Success',
                description: response.message,
                color: 'green',
                icon: 'i-heroicons-check-circle'
            })

            // Redirigir a login o página de verificación
            router.push('/login?registered=true')
        } else {
            toast.add({
                title: 'Error',
                description: response.message || 'Registration failed',
                color: 'red',
                icon: 'i-heroicons-exclamation-circle'
            })
        }
    } catch (error: any) {
        toast.add({
            title: 'Error',
            description: error.message || 'An error occurred during registration',
            color: 'red',
            icon: 'i-heroicons-exclamation-circle'
        })
    } finally {
        isLoading.value = false
    }
}
</script>

<template>
    <UAuthForm :fields="fields" :schema="schema" :providers="providers" title="Create an account"
        :submit="{ label: 'Create account', loading: isLoading }" @submit="onSubmit">
        <template #description>
            Already have an account? <ULink to="/login" class="text-primary font-medium">Login</ULink>.
        </template>

        <template #footer>
            By signing up, you agree to our <ULink to="/terms" class="text-primary font-medium">Terms of Service</ULink>
            .
        </template>
    </UAuthForm>
</template>