<template>
  <header :class="[
    'sticky top-0 z-40 transition-all duration-300',
    isScrolled 
      ? 'bg-white/90 dark:bg-gray-900/90 backdrop-blur-md border-b border-gray-200 dark:border-gray-800 shadow-sm' 
      : 'bg-transparent'
  ]">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between">
        <!-- Botón de regresar -->
        <button 
          @click="goBack"
          class="group flex items-center gap-2 px-4 py-2 rounded-full transition-all duration-300 hover:scale-105 active:scale-95"
          :class="[
            isScrolled 
              ? 'bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-300' 
              : 'bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm hover:bg-white dark:hover:bg-gray-800 text-gray-800 dark:text-gray-200 shadow-lg'
          ]"
        >
          <!-- Icono de flecha -->
          <svg 
            class="w-5 h-5 transition-transform duration-300 group-hover:-translate-x-1" 
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          
          <!-- Texto -->
          <span class="font-medium text-sm hidden sm:inline-block">
            Volver
          </span>
          
          <!-- Badge para mostrar que hay cambios -->
          <span 
            v-if="hasChanges"
            class="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full animate-ping"
          />
        </button>

    

 <!-- Botón de compartir - Modo Claro/Oscuro Mejorado -->
<button 
  @click="shareProduct"
  class="group relative p-2 rounded-full transition-all duration-300 hover:scale-110 active:scale-95"
  :class="[
    isScrolled 
      ? 'bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm hover:bg-white dark:hover:bg-gray-700/80 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 shadow-md hover:shadow-lg' 
      : 'bg-white/90 dark:bg-gray-900/90 backdrop-blur-md hover:bg-white dark:hover:bg-gray-800/90 text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white shadow-lg hover:shadow-xl border border-white/20 dark:border-gray-700/20'
  ]"
  aria-label="Compartir producto"
>
  <!-- Efecto de pulso en hover -->
  <div class="absolute inset-0 rounded-full bg-gradient-to-r from-blue-400/0 via-blue-400/0 to-blue-400/0 group-hover:from-blue-400/10 group-hover:via-blue-400/5 group-hover:to-blue-400/10 transition-all duration-500" />
  
  <!-- Icono SVG con animación -->
  <svg class="w-5 h-5 relative transition-all duration-300 group-hover:rotate-12 group-hover:text-blue-600 dark:group-hover:text-blue-400" 
       fill="none" 
       stroke="currentColor" 
       viewBox="0 0 24 24"
       aria-hidden="true">
    <path stroke-linecap="round" 
          stroke-linejoin="round" 
          stroke-width="2" 
          d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
  </svg>
  
  <!-- Tooltip para ambos modos -->
  <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 px-2 py-1 rounded text-xs font-medium whitespace-nowrap opacity-0 group-hover:opacity-100 transition-all duration-200 pointer-events-none
              bg-gray-900 dark:bg-gray-800 text-white dark:text-gray-200
              shadow-lg">
    Compartir
    <div class="absolute -top-1 left-1/2 transform -translate-x-1/2 w-2 h-2 rotate-45
                bg-gray-900 dark:bg-gray-800" />
  </div>
</button>
        </div>
      </div>

  </header>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from '#imports'

const router = useRouter()
const isFavorite = ref(false)
const hasChanges = ref(false)

// Props
const props = defineProps({
  isScrolled: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['back', 'favorite', 'share'])

// Función para regresar
const goBack = () => {
  emit('back')
  router.back()
}



// Función para compartir
const shareProduct = () => {
  emit('share')
  
  // Web Share API si está disponible
  if (navigator.share) {
    navigator.share({
      title: document.title,
      url: window.location.href
    })
  } else {
    // Fallback: copiar al portapapeles
    navigator.clipboard.writeText(window.location.href)
    alert('¡Enlace copiado al portapapeles!')
  }
}
</script>

<style scoped>
/* Animación para el efecto de pulso */
@keyframes ping {
  75%, 100% {
    transform: scale(2);
    opacity: 0;
  }
}

.animate-ping {
  animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;
}
</style>