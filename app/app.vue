<script setup lang="ts">
const colorMode = useColorMode()

const color = computed(() => colorMode.value === 'dark' ? '#1b1718' : 'white')

useHead({
  meta: [
    { charset: 'utf-8' },
    { name: 'viewport', content: 'width=device-width, initial-scale=1' },
    { key: 'theme-color', name: 'theme-color', content: color }
  ],
  link: [
    { rel: 'icon', href: '/favicon.ico' }
  ],
  htmlAttrs: {
    lang: 'en'
  }
})

const title = 'Ricen Store'
const description = 'Estilo urbano'

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
  ogImage: '/og-ricen.png',
  twitterImage: '/og-ricen.png',
  twitterCard: 'summary_large_image'
})
</script>

<template>
  <ClientOnly>
    <UApp>
      <NuxtLoadingIndicator />

      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>
    </UApp>
  </ClientOnly>
</template>