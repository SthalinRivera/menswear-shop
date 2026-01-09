<template>
  <div class="zapatillas-banner flex items-center justify-center p-4 md:p-8 bg-gradient-to-br from-gray-50 to-gray-100">
     <UContainer class="">
    <div class="w-full max-w-6xl">
      <div class="flex flex-col lg:flex-row items-center gap-8 lg:gap-12">
        
        <!-- Sección de slider de imágenes -->
        <div class="w-full lg:w-1/2">
          <!-- Contenedor del slider -->
          <div class="relative h-[400px] md:h-[500px] rounded-3xl overflow-hidden shadow-2xl">
            
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
                <div class="absolute top-6 left-6 bg-gradient-to-r from-red-500 to-pink-600 text-white font-bold py-2 px-4 rounded-full shadow-lg transform -rotate-6">
                  65% OFF
                </div>
                <div class="absolute bottom-6 left-6 bg-white/90 backdrop-blur-sm rounded-xl py-2 px-4 shadow-lg">
                  <p class="font-bold text-gray-800">{{ slides[0].name }}</p>
                  <p class="text-sm text-gray-600">{{ slides[0].description }}</p>
                </div>
              </div>
              
              <!-- Slide 2 -->
              <div class="absolute inset-0 w-full h-full left-full">
                <img 
                  :src="slides[1].image" 
                  :alt="slides[1].name"
                  class="w-full h-full object-cover"
                >
                <div class="absolute top-6 right-6 bg-gradient-to-r from-green-500 to-emerald-600 text-white font-bold py-2 px-4 rounded-full shadow-lg transform rotate-6">
                  50% OFF
                </div>
                <div class="absolute bottom-6 right-6 bg-white/90 backdrop-blur-sm rounded-xl py-2 px-4 shadow-lg">
                  <p class="font-bold text-gray-800">{{ slides[1].name }}</p>
                  <p class="text-sm text-gray-600">{{ slides[1].description }}</p>
                </div>
              </div>
              
              <!-- Slide 3 -->
              <div class="absolute inset-0 w-full h-full left-[200%]">
                <img 
                  :src="slides[2].image" 
                  :alt="slides[2].name"
                  class="w-full h-full object-cover"
                >
                <div class="absolute top-6 left-1/2 transform -translate-x-1/2 bg-gradient-to-r from-orange-500 to-red-600 text-white font-bold py-2 px-4 rounded-full shadow-lg">
                  NUEVO
                </div>
                <div class="absolute bottom-6 left-1/2 transform -translate-x-1/2 bg-white/90 backdrop-blur-sm rounded-xl py-2 px-4 shadow-lg">
                  <p class="font-bold text-gray-800">{{ slides[2].name }}</p>
                  <p class="text-sm text-gray-600">{{ slides[2].description }}</p>
                </div>
              </div>
            </div>
            
            <!-- Botones de navegación -->
            <button 
              @click="prevSlide"
              class="absolute left-4 top-1/2 transform -translate-y-1/2 bg-white/80 hover:bg-white text-gray-800 rounded-full p-2 shadow-lg hover:shadow-xl transition-all z-20"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <button 
              @click="nextSlide"
              class="absolute right-4 top-1/2 transform -translate-y-1/2 bg-white/80 hover:bg-white text-gray-800 rounded-full p-2 shadow-lg hover:shadow-xl transition-all z-20"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            
            <!-- Indicadores/puntos -->
            <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2 z-20">
              <button 
                v-for="(_, index) in slides" 
                :key="index"
                @click="goToSlide(index)"
                class="w-3 h-2 rounded-full transition-all"
                :class="currentSlide === index ? 'bg-white scale-125' : 'bg-white hover:bg-white/80'"
              ></button>
            </div>
          </div>
          
        
        </div>
        
        <!-- Sección de contenido -->
        <div class="w-full lg:w-1/2 text-center lg:text-left">
          
          
          <div class="mb-8 p-5 bg-white rounded-2xl shadow-lg">
            <div class="flex items-center justify-center lg:justify-start space-x-3 mb-3">
              <div class="w-10 h-10 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </div>
              <h2 class="text-xl font-bold text-gray-900">Tus favoritos con envío gratis</h2>
            </div>
            <p class="text-gray-700 mb-4">
              <span class="font-bold text-2xl text-blue-600">hasta el 65% de descuento</span> en zapatillas seleccionadas.
            </p>
            <button class="bg-gradient-to-r from-gray-800 to-gray-900 hover:from-gray-900 hover:to-black text-white font-semibold py-3 px-6 rounded-full shadow-md hover:shadow-lg transition-all">
              Ver catálogo
            </button>
          </div>
          
          <div class="p-5 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl shadow-lg border border-blue-100">
            <div class="flex items-center justify-center lg:justify-start space-x-3 mb-3">
              <div class="w-10 h-10 bg-gradient-to-r from-green-500 to-teal-600 rounded-full flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M5 2a2 2 0 00-2 2v14l3.5-2 3.5 2 3.5-2 3.5 2V4a2 2 0 00-2-2H5zm4.707 3.707a1 1 0 00-1.414-1.414l-3 3a1 1 0 000 1.414l3 3a1 1 0 001.414-1.414L8.414 9H10a3 3 0 013 3v1a1 1 0 102 0v-1a5 5 0 00-5-5H8.414l1.293-1.293z" clip-rule="evenodd" />
                </svg>
              </div>
              <h2 class="text-xl font-bold text-gray-900">Zapatillas Running con hasta 50% de descuento</h2>
            </div>
            <p class="text-gray-700 mb-4">Tecnología avanzada para máximo rendimiento.</p>
            <button class="bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 text-white font-semibold py-3 px-6 rounded-full shadow-md hover:shadow-lg transition-all">
              Ver catálogo
            </button>
          </div>
          
          <div class="mt-8 flex flex-wrap justify-center lg:justify-start gap-4 text-sm text-gray-500">
            <div class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mr-2" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              Envío gratis en pedidos +$50
            </div>
            <div class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mr-2" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              Devoluciones gratuitas
            </div>
            <div class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mr-2" viewBox="0 0 20 20" fill="currentColor">
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

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const currentSlide = ref(0)

// Configura tus imágenes aquí
// Ajusta las rutas según donde tengas tus imágenes en /public
const slides = [
  {
    image: '/img1.webp', // Ruta a tu imagen en public/
    name: 'Running Pro Max',
    description: 'Tecnología Air Comfort'
  },
  {
    image: '/img2.jpg', // Ruta a tu imagen en public/
    name: 'Urban Style',
    description: 'Diseño moderno'
  },
  {
    image: '/img1.webp', // Ruta a tu imagen en public/
    name: 'Basket Pro',
    description: 'Máximo agarre'
  }
]

let autoSlideInterval = null

const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % slides.length
}

const prevSlide = () => {
  currentSlide.value = (currentSlide.value - 1 + slides.length) % slides.length
}

const goToSlide = (index) => {
  currentSlide.value = index
}

const startAutoSlide = () => {
  autoSlideInterval = setInterval(() => {
    nextSlide()
  }, 4000)
}

const stopAutoSlide = () => {
  if (autoSlideInterval) {
    clearInterval(autoSlideInterval)
    autoSlideInterval = null
  }
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
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

@media (max-width: 768px) {
  .zapatillas-banner {
    padding-top: 1rem;
    padding-bottom: 1rem;
  }
}
</style>