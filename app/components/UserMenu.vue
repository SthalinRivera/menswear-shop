<script setup lang="ts">
import type { DropdownMenuItem } from '@nuxt/ui'

defineProps<{
  collapsed?: boolean
}>()

const colorMode = useColorMode()
const appConfig = useAppConfig()
// Usar tu servicio de auth
const { $auth } = useNuxtApp()
const toast = useToast()
const router = useRouter()
// Obtener usuario real del auth service
const User = computed(() => {
  const currentUser = $auth.getCurrentUser()
  return currentUser ? {
    name: `${currentUser.nombre} ${currentUser.apellido}`.trim() || currentUser.email,
    avatar: {
      src: `https://ui-avatars.com/api/?name=${encodeURIComponent(currentUser.nombre || currentUser.email)}&background=random`,
      alt: currentUser.nombre || currentUser.email
    },
    email: currentUser.email,
    roles: currentUser.roles
  } : {
    name: 'Invitado',
    avatar: {
      src: 'https://ui-avatars.com/api/?name=Invitado&background=gray',
      alt: 'Invitado'
    }
  }
})
const colors = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
const neutrals = ['slate', 'gray', 'zinc', 'neutral', 'stone']

const user = ref({
  name: 'Benjamin Canac',
  avatar: {
    src: 'https://github.com/benjamincanac.png',
    alt: 'Benjamin Canac'
  }
})

const items = computed<DropdownMenuItem[][]>(() => ([[{
  type: 'label',
  label: user.value.name,
  avatar: user.value.avatar
}], [{
  label: 'Profile',
  icon: 'i-lucide-user'
}, {
  label: 'Billing',
  icon: 'i-lucide-credit-card'
}, {
  label: 'Settings',
  icon: 'i-lucide-settings',
  to: '/settings'
}], [{
  label: 'Theme',
  icon: 'i-lucide-palette',
  children: [{
    label: 'Primary',
    slot: 'chip',
    chip: appConfig.ui.colors.primary,
    content: {
      align: 'center',
      collisionPadding: 16
    },
    children: colors.map(color => ({
      label: color,
      chip: color,
      slot: 'chip',
      checked: appConfig.ui.colors.primary === color,
      type: 'checkbox',
      onSelect: (e) => {
        e.preventDefault()

        appConfig.ui.colors.primary = color
      }
    }))
  }, {
    label: 'Neutral',
    slot: 'chip',
    chip: appConfig.ui.colors.neutral === 'neutral' ? 'old-neutral' : appConfig.ui.colors.neutral,
    content: {
      align: 'end',
      collisionPadding: 16
    },
    children: neutrals.map(color => ({
      label: color,
      chip: color === 'neutral' ? 'old-neutral' : color,
      slot: 'chip',
      type: 'checkbox',
      checked: appConfig.ui.colors.neutral === color,
      onSelect: (e) => {
        e.preventDefault()

        appConfig.ui.colors.neutral = color
      }
    }))
  }]
}, {
  label: 'Appearance',
  icon: 'i-lucide-sun-moon',
  children: [{
    label: 'Light',
    icon: 'i-lucide-sun',
    type: 'checkbox',
    checked: colorMode.value === 'light',
    onSelect(e: Event) {
      e.preventDefault()

      colorMode.preference = 'light'
    }
  }, {
    label: 'Dark',
    icon: 'i-lucide-moon',
    type: 'checkbox',
    checked: colorMode.value === 'dark',
    onUpdateChecked(checked: boolean) {
      if (checked) {
        colorMode.preference = 'dark'
      }
    },
    onSelect(e: Event) {
      e.preventDefault()
    }
  }]
}],

[{
  label: 'Documentation',
  icon: 'i-lucide-book-open',
  to: '#',
  target: '_blank'
}, {
  label: 'GitHub repository',
  icon: 'i-simple-icons-github',
  to: '#',
  target: '_blank'
}, {
  label: 'Log out',
  icon: 'i-lucide-log-out',
  onSelect: async () => {
    try {
      await $auth.logout()

      toast.add({
        title: 'Sesión cerrada',
        description: 'Has cerrado sesión exitosamente',
        color: 'green',
        icon: 'i-heroicons-check-circle'
      })

      // Redirigir al login
      router.push('/login')
    } catch (error) {
      toast.add({
        title: 'Error',
        description: 'No se pudo cerrar la sesión',
        color: 'red',
        icon: 'i-heroicons-exclamation-circle'
      })
    }
  }
}]]))
</script>

<template>
  <UDropdownMenu :items="items" :content="{ align: 'center', collisionPadding: 12 }"
    :ui="{ content: collapsed ? 'w-48' : 'w-(--reka-dropdown-menu-trigger-width)' }">
    <UButton v-bind="{
      ...user,
      label: collapsed ? undefined : user?.name,
      trailingIcon: collapsed ? undefined : 'i-lucide-chevrons-up-down'
    }" color="neutral" variant="ghost" block :square="collapsed" class="data-[state=open]:bg-elevated" :ui="{
      trailingIcon: 'text-dimmed'
    }" />

    <template #chip-leading="{ item }">
      <div class="inline-flex items-center justify-center shrink-0 size-5">
        <span class="rounded-full ring ring-bg bg-(--chip-light) dark:bg-(--chip-dark) size-2" :style="{
          '--chip-light': `var(--color-${(item as any).chip}-500)`,
          '--chip-dark': `var(--color-${(item as any).chip}-400)`
        }" />
      </div>
    </template>
  </UDropdownMenu>
</template>
