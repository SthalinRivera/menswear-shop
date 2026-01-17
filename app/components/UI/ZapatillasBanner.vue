<template>
  <div class="flex items-center justify-center p-0 md:p-8 zapatillas-banner">
    <UContainer>
      <div class="w-full max-w-6xl">
        <div class="flex flex-col lg:flex-row items-center gap-2 lg:gap-12">
          
          <!-- Sección de slider de imágenes -->
          <div class="w-full lg:w-1/2">
            <!-- Contenedor del slider -->
            <div class="relative h-[280px] sm:h-[350px] md:h-[500px] rounded-2xl md:rounded-3xl overflow-hidden shadow-xl dark:shadow-gray-900/30">
              
              <!-- Slides -->
              <div class="absolute inset-0 transition-transform duration-500 ease-in-out" 
                   :style="{ transform: `translateX(-${currentSlide * 100}%)` }">
                
                <!-- Slide 1 -->
                <div class="absolute inset-0 w-full h-full">
                  <img 
                    :src="slides[0].image" 
                    :alt="slides[0].name"
                    class="w-full h-full object-cover"
                  >
                  <div class="absolute top-3 left-3 md:top-6 md:left-6 bg-gradient-to-r from-red-500 to-pink-600 text-white font-bold py-1 px-3 md:py-2 md:px-4 rounded-full shadow-lg transform -rotate-6 text-xs md:text-sm">
                    65% OFF
                  </div>
                  <div class="absolute bottom-3 left-3 md:bottom-6 md:left-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-lg md:rounded-xl py-1 px-3 md:py-2 md:px-4 shadow-lg max-w-[80%]">
                    <p class="font-bold text-gray-800 dark:text-gray-100 text-sm md:text-base">{{ slides[0].name }}</p>
                    <p class="text-xs md:text-sm text-gray-600 dark:text-gray-300">{{ slides[0].description }}</p>
                  </div>
                </div>
                
                <!-- Slide 2 -->
                <div class="absolute inset-0 w-full h-full left-full">
                  <img 
                    :src="slides[1].image" 
                    :alt="slides[1].name"
                    class="w-full h-full object-cover"
                  >
                  <div class="absolute top-3 right-3 md:top-6 md:right-6 bg-gradient-to-r from-green-500 to-emerald-600 text-white font-bold py-1 px-3 md:py-2 md:px-4 rounded-full shadow-lg transform rotate-6 text-xs md:text-sm">
                    50% OFF
                  </div>
                  <div class="absolute bottom-3 right-3 md:bottom-6 md:right-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-lg md:rounded-xl py-1 px-3 md:py-2 md:px-4 shadow-lg max-w-[80%]">
                    <p class="font-bold text-gray-800 dark:text-gray-100 text-sm md:text-base">{{ slides[1].name }}</p>
                    <p class="text-xs md:text-sm text-gray-600 dark:text-gray-300">{{ slides[1].description }}</p>
                  </div>
                </div>
                
                <!-- Slide 3 -->
                <div class="absolute inset-0 w-full h-full left-[200%]">
                  <img 
                    :src="slides[2].image" 
                    :alt="slides[2].name"
                    class="w-full h-full object-cover"
                  >
                  <div class="absolute top-3 left-1/2 transform -translate-x-1/2 bg-gradient-to-r from-orange-500 to-red-600 text-white font-bold py-1 px-3 md:py-2 md:px-4 rounded-full shadow-lg text-xs md:text-sm">
                    NUEVO
                  </div>
                  <div class="absolute bottom-3 left-1/2 transform -translate-x-1/2 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-lg md:rounded-xl py-1 px-3 md:py-2 md:px-4 shadow-lg max-w-[90%]">
                    <p class="font-bold text-gray-800 dark:text-gray-100 text-sm md:text-base">{{ slides[2].name }}</p>
                    <p class="text-xs md:text-sm text-gray-600 dark:text-gray-300">{{ slides[2].description }}</p>
                  </div>
                </div>
              </div>
              
              <!-- Botones de navegación -->
              <button 
                @click="prevSlide"
                class="absolute left-2 md:left-4 top-1/2 transform -translate-y-1/2 bg-white/80 hover:bg-white dark:bg-gray-800/80 dark:hover:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-full p-1 md:p-2 shadow-lg hover:shadow-xl transition-all z-20"
                aria-label="Slide anterior"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 md:h-6 md:w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              
              <button 
                @click="nextSlide"
                class="absolute right-2 md:right-4 top-1/2 transform -translate-y-1/2 bg-white/80 hover:bg-white dark:bg-gray-800/80 dark:hover:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-full p-1 md:p-2 shadow-lg hover:shadow-xl transition-all z-20"
                aria-label="Slide siguiente"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 md:h-6 md:w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </button>
              
              <!-- Indicadores -->
              <div class="absolute bottom-2 md:bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-1 md:space-x-2 z-20">
                <button 
                  v-for="(_, index) in slides" 
                  :key="index"
                  @click="goToSlide(index)"
                  class="w-2 h-2 md:w-3 md:h-2 rounded-full transition-all"
                  :class="[
                    currentSlide === index 
                      ? 'bg-white dark:bg-gray-300 md:scale-125' 
                      : 'bg-white/60 dark:bg-gray-600 hover:bg-white/80 dark:hover:bg-gray-500'
                  ]"
                  :aria-label="`Ir al slide ${index + 1}`"
                ></button>
              </div>
            </div>
          </div>
          
          <!-- Sección de contenido -->
          <div class="w-full lg:w-1/2 text-center lg:text-left">
            
            <!-- Tarjeta 1 -->
            <div class="mb-4 md:mb-8 p-3 md:p-5 bg-white dark:bg-gray-800 rounded-xl md:rounded-2xl shadow-lg dark:shadow-gray-900/30">
              <div class="flex items-center justify-center lg:justify-start space-x-2 md:space-x-3 mb-2 md:mb-3">
                <div class="w-8 h-8 md:w-10 md:h-10 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 md:h-5 md:w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                </div>
                <h2 class="text-sm md:text-xl font-bold text-gray-900 dark:text-gray-100">
                  <span class="hidden sm:inline">Tus favoritos con</span> Envío gratis
                </h2>
              </div>
              <p class="text-gray-700 dark:text-gray-300 mb-2 md:mb-4 text-sm md:text-base">
                <span class="font-bold text-lg md:text-2xl text-blue-600 dark:text-blue-400">Hasta 65% OFF</span> en seleccionados
              </p>
              <NuxtLink 
                to="/catalog"
                class="block w-full bg-gradient-to-r from-gray-800 to-gray-900 hover:from-gray-900 hover:to-black dark:from-gray-700 dark:to-gray-800 dark:hover:from-gray-600 dark:hover:to-gray-700 text-white font-semibold py-2 md:py-3 px-4 md:px-6 rounded-full shadow-md hover:shadow-lg transition-all text-sm md:text-base text-center"
              >
                Ver catálogo
              </NuxtLink>
            </div>
            
            <!-- Tarjeta 2 -->
            <div class="p-3 md:p-5 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 rounded-xl md:rounded-2xl shadow-lg border border-blue-100 dark:border-gray-700">
              <div class="flex items-center justify-center lg:justify-start space-x-2 md:space-x-3 mb-2 md:mb-3">
                <div class="w-8 h-8 md:w-10 md:h-10 bg-gradient-to-r from-green-500 to-teal-600 rounded-full flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 md:h-5 md:w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M5 2a2 2 0 00-2 2v14l3.5-2 3.5 2 3.5-2 3.5 2V4a2 2 0 00-2-2H5zm4.707 3.707a1 1 0 00-1.414-1.414l-3 3a1 1 0 000 1.414l3 3a1 1 0 001.414-1.414L8.414 9H10a3 3 0 013 3v1a1 1 0 102 0v-1a5 5 0 00-5-5H8.414l1.293-1.293z" clip-rule="evenodd" />
                  </svg>
                </div>
                <h2 class="text-sm md:text-xl font-bold text-gray-900 dark:text-gray-100">
                  <span class="hidden sm:inline">Zapatillas Running</span> Hasta 50% OFF
                </h2>
              </div>
              <p class="text-gray-700 dark:text-gray-300 mb-2 md:mb-4 text-xs md:text-base">Tecnología avanzada para máximo rendimiento.</p>
              <NuxtLink 
                to="/catalog?category=running"
                class="block w-full bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 text-white font-semibold py-2 md:py-3 px-4 md:px-6 rounded-full shadow-md hover:shadow-lg transition-all text-sm md:text-base text-center"
              >
                Ver catálogo Running
              </NuxtLink>
            </div>
            
            <!-- Información adicional -->
            <div class="mt-4 md:mt-8 flex flex-wrap justify-center lg:justify-start gap-2 md:gap-4 text-xs md:text-sm text-gray-500 dark:text-gray-400">
              <div class="flex items-center bg-white dark:bg-gray-800 rounded-lg px-2 py-1 md:px-0 md:py-0 md:bg-transparent shadow-sm md:shadow-none">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 md:h-5 md:w-5 text-green-500 dark:text-green-400 mr-1 md:mr-2" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
                Envío gratis + S/. 50
              </div>
              <div class="flex items-center bg-white dark:bg-gray-800 rounded-lg px-2 py-1 md:px-0 md:py-0 md:bg-transparent shadow-sm md:shadow-none">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 md:h-5 md:w-5 text-green-500 dark:text-green-400 mr-1 md:mr-2" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
                Devoluciones gratis
              </div>
              <div class="flex items-center bg-white dark:bg-gray-800 rounded-lg px-2 py-1 md:px-0 md:py-0 md:bg-transparent shadow-sm md:shadow-none">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 md:h-5 md:w-5 text-green-500 dark:text-green-400 mr-1 md:mr-2" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
                Pago seguro
              </div>
            </div>
          </div>
        </div>
      </div>
    </UContainer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const currentSlide = ref(0)

// Configura tus imágenes aquí
const slides = ref([
  {
    image: '/img1.webp',
    name: 'Running Pro Max',
    description: 'Tecnología Air Comfort'
  },
  {
    image: '/img2.jpg',
    name: 'Urban Style',
    description: 'Diseño moderno y elegante'
  },
  {
    image: '/img1.webp',
    name: 'Basket Pro',
    description: 'Máximo agarre y comodidad'
  }
])

let autoSlideInterval: NodeJS.Timeout | null = null

const nextSlide = (): void => {
  currentSlide.value = (currentSlide.value + 1) % slides.value.length
}

const prevSlide = (): void => {
  currentSlide.value = (currentSlide.value - 1 + slides.value.length) % slides.value.length
}

const goToSlide = (index: number): void => {
  currentSlide.value = index
}

const startAutoSlide = (): void => {
  autoSlideInterval = setInterval(() => {
    nextSlide()
  }, 4000)
}

const stopAutoSlide = (): void => {
  if (autoSlideInterval) {
    clearInterval(autoSlideInterval)
    autoSlideInterval = null
  }
}

// Pausar autoslide al hacer hover
const pauseOnHover = (): void => {
  stopAutoSlide()
}

const resumeOnLeave = (): void => {
  startAutoSlide()
}

onMounted(() => {
  startAutoSlide()
})

onUnmounted(() => {
  stopAutoSlide()
})
</script>

<style scoped>
.zapatillas-banner {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* Ajustes específicos para móvil */
@media (max-width: 640px) {
  .zapatillas-banner {
    padding: 0.5rem;
  }
}

/* Mejoras para tablets */
@media (min-width: 641px) and (max-width: 1024px) {
  .zapatillas-banner {
    padding: 1rem;
  }
}

/* Transiciones suaves */
.zapatillas-banner,
.zapatillas-banner * {
  transition: background-color 0.3s ease, border-color 0.3s ease;
}

/* Mejora de rendimiento */
.slide-container {
  will-change: transform;
  backface-visibility: hidden;
}

/* Optimización para móviles */
img {
  -webkit-user-drag: none;
  user-select: none;
}

/* Estilos para enlaces */
a {
  text-decoration: none;
  display: inline-block;
}

/* Hover effects mejorados para botones */
a:hover {
  transform: translateY(-2px);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

/* Focus styles para accesibilidad */
a:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Responsive para slider buttons */
@media (max-width: 640px) {
  .slide-buttons button {
    padding: 0.25rem;
  }
  
  .slide-buttons svg {
    width: 1rem;
    height: 1rem;
  }
}
</style>