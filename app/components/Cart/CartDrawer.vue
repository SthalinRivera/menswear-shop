<template>
  <!-- Overlay -->
  <transition name="fade">
    <div v-if="cartStore.isOpen" 
         class="fixed inset-0 bg-black/50 z-40" 
         @click="cartStore.closeCart()" />
  </transition>

  <!-- Drawer - Modal tipo app móvil -->
  <transition name="slide-up">
    <div v-if="cartStore.isOpen" 
         class="fixed inset-x-0 bottom-0 z-50 md:hidden">
      <!-- Handle para arrastrar (opcional) -->
      <div class="mx-auto w-12 h-1.5 bg-gray-300 dark:bg-gray-600 rounded-full mb-2" />
      
      <!-- Contenido del modal móvil -->
      <div class="bg-white dark:bg-gray-900 rounded-t-2xl shadow-2xl max-h-[85vh] flex flex-col">
        
        <!-- Header móvil -->
        <div class="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-800">
          <div class="flex items-center gap-3">
            <div class="relative">
              <svg class="w-6 h-6 text-gray-700 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
              </svg>
              <span v-if="cartStore.totalItems > 0" 
                    class="absolute -top-2 -right-2 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
                {{ cartStore.totalItems }}
              </span>
            </div>
            <div>
              <h2 class="font-bold text-gray-900 dark:text-white">Carrito</h2>
              <p class="text-xs text-gray-500 dark:text-gray-400">{{ cartStore.totalItems }} items</p>
            </div>
          </div>
          <button @click="cartStore.closeCart()" 
                  class="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full transition">
            <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Empty State móvil -->
        <div v-if="cartStore.isEmpty" class="flex-1 flex flex-col items-center justify-center p-8">
          <div class="w-20 h-20 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mb-4">
            <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
            </svg>
          </div>
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">Carrito vacío</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400 text-center mb-6">Agrega productos para comenzar</p>
          <button @click="cartStore.closeCart()" 
                  class="w-full py-3 bg-black dark:bg-white text-white dark:text-black text-sm font-bold rounded-lg hover:opacity-90 transition">
            Explorar productos
          </button>
        </div>

        <!-- Items del carrito móvil -->
        <div v-else class="flex-1 overflow-y-auto">
          <div class="p-4 space-y-3">
            <div v-for="item in cartStore.items" :key="item.id" 
                 class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-3">
              
              <div class="flex gap-3">
                <!-- Imagen -->
                <div class="flex-shrink-0">
                  <div class="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-lg overflow-hidden">
                    <img v-if="item.imagen_url" :src="item.imagen_url" :alt="item.nombre" 
                         class="w-full h-full object-cover" />
                    <div v-else class="w-full h-full flex items-center justify-center">
                      <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                    </div>
                  </div>
                </div>

                <!-- Información del producto -->
                <div class="flex-1 min-w-0">
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <h3 class="font-semibold text-gray-900 dark:text-white text-sm mb-1 line-clamp-1">
                        {{ item.nombre }}
                      </h3>
                      
                      <!-- Variantes -->
                      <div v-if="item.color_nombre || item.talla" class="flex items-center gap-2 mb-2">
                        <span v-if="item.color_nombre" class="text-xs text-gray-500 dark:text-gray-400">
                          {{ item.color_nombre }}
                        </span>
                        <span v-if="item.talla" class="text-xs px-2 py-0.5 bg-gray-100 dark:bg-gray-700 rounded">
                          {{ item.talla }}
                        </span>
                      </div>
                      
                      <!-- Precio unitario -->
                      <p class="text-xs text-gray-600 dark:text-gray-400 mb-2">
                        S/ {{ item.precio_final.toFixed(2) }} c/u
                      </p>
                    </div>
                    
                    <!-- Botón eliminar - SIEMPRE VISIBLE -->
                    <button @click="cartStore.removeItem(item.id)" 
                            class="ml-2 p-2 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition flex-shrink-0">
                      <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>

                  <!-- Controles de cantidad y precio total -->
                  <div class="flex items-center justify-between mt-2 pt-2 border-t border-gray-100 dark:border-gray-700">
                    <div class="flex items-center gap-2">
                      <button @click="cartStore.updateQuantity(item.id, item.cantidad - 1)" 
                              :disabled="item.cantidad <= 1"
                              class="w-8 h-8 flex items-center justify-center border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-40">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M20 12H4" />
                        </svg>
                      </button>
                      <span class="w-10 text-center font-bold text-gray-900 dark:text-white">
                        {{ item.cantidad }}
                      </span>
                      <button @click="cartStore.updateQuantity(item.id, item.cantidad + 1)" 
                              class="w-8 h-8 flex items-center justify-center border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" />
                        </svg>
                      </button>
                    </div>
                    <div class="text-right">
                      <p class="font-bold text-gray-900 dark:text-white">
                        S/ {{ (item.precio_final * item.cantidad).toFixed(2) }}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer móvil -->
        <div v-if="!cartStore.isEmpty" class="border-t border-gray-100 dark:border-gray-800 p-4 bg-white dark:bg-gray-900">
          <!-- Resumen compacto -->
          <div class="mb-4">
            <div class="flex justify-between items-center mb-2">
              <span class="text-gray-600 dark:text-gray-400">Total:</span>
              <span class="text-xl font-bold text-gray-900 dark:text-white">
                S/ {{ cartStore.total.toFixed(2) }}
              </span>
            </div>
            <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400">
              <span>Incluye IVA (18%)</span>
              <span v-if="cartStore.subtotal <= 150">+ S/ 15.00 envío</span>
              <span v-else class="text-green-600 dark:text-green-400">✓ Envío gratis</span>
            </div>
          </div>

          <!-- Botón de WhatsApp -->
          <button @click="shareOnWhatsApp" 
                  class="w-full mb-3 py-3 bg-gradient-to-r from-green-500 to-green-600 text-white text-sm font-bold rounded-lg hover:opacity-90 transition flex items-center justify-center gap-2">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.76.982.998-3.675-.236-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.9 6.994c-.004 5.45-4.437 9.88-9.885 9.88m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.333.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.333 11.893-11.893 0-3.18-1.24-6.162-3.495-8.411"/>
            </svg>
            Compartir por WhatsApp
          </button>

          <!-- Acciones principales -->
          <div class="flex gap-2">
            <button @click="cartStore.clearCart()" 
                    class="flex-1 py-3 text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800 transition">
              Vaciar
            </button>
            <button class="flex-1 py-3 text-sm font-bold bg-black dark:bg-white text-white dark:text-black rounded-lg hover:opacity-90 transition">
              Pagar
            </button>
          </div>
        </div>
      </div>
    </div>
  </transition>

  <!-- Drawer Desktop (mantener versión original con WhatsApp) -->
  <transition name="slide">
    <aside v-if="cartStore.isOpen" 
           class="hidden md:flex fixed inset-y-0 right-0 w-full max-w-sm bg-white dark:bg-gray-900 shadow-2xl z-50 flex-col">
      
      <!-- Header Desktop -->
      <div class="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-800">
        <div class="flex items-center gap-2">
          <div class="p-2 bg-gray-100 dark:bg-gray-800 rounded-lg">
            <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
            </svg>
          </div>
          <div>
            <h2 class="font-semibold text-gray-900 dark:text-white">Tu carrito</h2>
            <p class="text-xs text-gray-500 dark:text-gray-400">{{ cartStore.totalItems }} items</p>
          </div>
        </div>
        <button @click="cartStore.closeCart()" class="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition">
          <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Empty State Desktop -->
      <div v-if="cartStore.isEmpty" class="flex-1 flex flex-col items-center justify-center p-8">
        <div class="w-20 h-20 bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center mb-6">
          <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
          </svg>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Carrito vacío</h3>
        <p class="text-sm text-gray-500 dark:text-gray-400 text-center mb-6">Agrega productos para comenzar</p>
        <button @click="cartStore.closeCart()" class="px-6 py-2.5 bg-gray-900 dark:bg-white text-white dark:text-gray-900 text-sm font-medium rounded-lg hover:opacity-90 transition">
          Explorar productos
        </button>
      </div>

      <!-- Cart Items Desktop -->
      <div v-else class="flex-1 overflow-y-auto">
        <div class="p-4 space-y-3">
          <div v-for="item in cartStore.items" :key="item.id" 
               class="group relative p-3 bg-gray-50 dark:bg-gray-800/50 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-800 transition">
            
            <div class="flex gap-3">
              <!-- Image Desktop -->
              <div class="flex-shrink-0">
                <div class="w-16 h-16 bg-gray-200 dark:bg-gray-700 rounded-lg overflow-hidden">
                  <img v-if="item.imagen_url" :src="item.imagen_url" :alt="item.nombre" 
                       class="w-full h-full object-cover" />
                  <div v-else class="w-full h-full flex items-center justify-center">
                    <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Info Desktop -->
              <div class="flex-1 min-w-0">
                <div class="flex justify-between items-start mb-1">
                  <h3 class="font-medium text-gray-900 dark:text-white truncate text-sm">{{ item.nombre }}</h3>
                  <button @click="cartStore.removeItem(item.id)" 
                          class="p-1 hover:bg-red-100 dark:hover:bg-red-900/30 rounded transition">
                    <svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>

                <!-- Variants Desktop -->
                <div v-if="item.color_nombre || item.talla" class="mb-2">
                  <div class="flex items-center gap-2">
                    <span v-if="item.color_nombre" class="text-xs text-gray-500 dark:text-gray-400">
                      {{ item.color_nombre }}
                    </span>
                    <span v-if="item.talla" class="text-xs px-2 py-0.5 bg-gray-200 dark:bg-gray-700 rounded">
                      {{ item.talla }}
                    </span>
                  </div>
                </div>

                <!-- Price & Quantity Desktop -->
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <button @click="cartStore.updateQuantity(item.id, item.cantidad - 1)" 
                            :disabled="item.cantidad <= 1"
                            class="w-7 h-7 flex items-center justify-center border border-gray-300 dark:border-gray-600 rounded hover:bg-gray-200 dark:hover:bg-gray-700 disabled:opacity-30">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M20 12H4" />
                      </svg>
                    </button>
                    <span class="w-8 text-center font-medium text-gray-900 dark:text-white text-sm">
                      {{ item.cantidad }}
                    </span>
                    <button @click="cartStore.updateQuantity(item.id, item.cantidad + 1)" 
                            class="w-7 h-7 flex items-center justify-center border border-gray-300 dark:border-gray-600 rounded hover:bg-gray-200 dark:hover:bg-gray-700">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" />
                      </svg>
                    </button>
                  </div>
                  <div class="text-right">
                    <p class="text-sm font-semibold text-gray-900 dark:text-white">
                      S/ {{ (item.precio_final * item.cantidad).toFixed(2) }}
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                      S/ {{ item.precio_final.toFixed(2) }} c/u
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer Desktop -->
      <div v-if="!cartStore.isEmpty" class="border-t border-gray-100 dark:border-gray-800 p-4 bg-white dark:bg-gray-900">
        <!-- Summary Desktop -->
        <div class="space-y-3 mb-4">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500 dark:text-gray-400">Subtotal</span>
            <span class="font-medium text-gray-900 dark:text-white">
              S/ {{ cartStore.subtotal.toFixed(2) }}
            </span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500 dark:text-gray-400">Envío</span>
            <span class="font-medium text-green-600 dark:text-green-400">
              {{ cartStore.subtotal > 150 ? 'Gratis' : 'S/ 15.00' }}
            </span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500 dark:text-gray-400">IVA (18%)</span>
            <span class="font-medium text-gray-900 dark:text-white">
              S/ {{ (cartStore.subtotal * 0.18).toFixed(2) }}
            </span>
          </div>
          <div class="flex justify-between items-center pt-3 border-t border-gray-200 dark:border-gray-700">
            <span class="font-semibold text-gray-900 dark:text-white">Total</span>
            <span class="text-xl font-bold text-primary-600 dark:text-primary-400">
              S/ {{ cartStore.total.toFixed(2) }}
            </span>
          </div>
        </div>

        <!-- Botón WhatsApp Desktop -->
        <button @click="shareOnWhatsApp" 
                class="w-full mb-3 py-3 bg-gradient-to-r from-green-500 to-green-600 text-white text-sm font-bold rounded-lg hover:opacity-90 transition flex items-center justify-center gap-2">
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.76.982.998-3.675-.236-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.9 6.994c-.004 5.45-4.437 9.88-9.885 9.88m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.333.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.333 11.893-11.893 0-3.18-1.24-6.162-3.495-8.411"/>
          </svg>
          Compartir pedido por WhatsApp
        </button>

        <!-- Actions Desktop -->
        <div class="space-y-2">
          <button @click="cartStore.clearCart()" 
                  class="w-full py-2.5 text-sm font-medium text-red-600 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition">
            Vaciar carrito
          </button>
          <button @click="cartStore.closeCart()" 
                  class="w-full py-2.5 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg transition">
            Seguir comprando
          </button>
          <button class="w-full py-2.5 text-sm font-medium bg-black dark:bg-white text-white dark:text-black rounded-lg hover:opacity-90 transition">
            Proceder al pago
          </button>
        </div>

        <!-- Secure Badge Desktop -->
        <div class="mt-4 pt-4 border-t border-gray-100 dark:border-gray-800">
          <div class="flex items-center justify-center gap-2 text-xs text-gray-500 dark:text-gray-400">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            <span>Compra 100% segura • Devolución en 30 días</span>
          </div>
        </div>
      </div>
    </aside>
  </transition>
</template>

<script setup lang="ts">
import { useCartStore } from '~/stores/cart'

const cartStore = useCartStore()

// Inicializar al montar
onMounted(() => {
  cartStore.initialize()
})

// Función para compartir por WhatsApp
const shareOnWhatsApp = () => {
  // Verificar si hay productos en el carrito
  if (cartStore.isEmpty) {
    alert('Agrega productos al carrito primero')
    return
  }

  // Crear el mensaje para WhatsApp
  let message = `¡Hola! Me gustaría hacer este pedido:\n\n`
  
  // Agregar cada producto al mensaje
  cartStore.items.forEach((item, index) => {
    message += `${index + 1}. ${item.nombre}`
    if (item.color_nombre) message += ` - Color: ${item.color_nombre}`
    if (item.talla) message += ` - Talla: ${item.talla}`
    message += `\n   Cantidad: ${item.cantidad}`
    message += `\n   Precio: S/ ${item.precio_final.toFixed(2)} c/u`
    message += `\n   Subtotal: S/ ${(item.precio_final * item.cantidad).toFixed(2)}`
    message += `\n\n`
  })
  
  // Agregar resumen
  message += `📊 RESUMEN DEL PEDIDO:\n`
  message += `Total items: ${cartStore.totalItems}\n`
  message += `Subtotal: S/ ${cartStore.subtotal.toFixed(2)}\n`
  message += `IVA (18%): S/ ${(cartStore.subtotal * 0.18).toFixed(2)}\n`
  message += `Envío: ${cartStore.subtotal > 150 ? 'GRATIS' : 'S/ 15.00'}\n`
  message += `TOTAL: S/ ${cartStore.total.toFixed(2)}\n\n`
  
  // Agregar información del cliente (puedes personalizar esto)
  message += `📋 MIS DATOS:\n`
  message += `(Por favor, completa tus datos)\n`
  message += `Nombre: \n`
  message += `Teléfono: \n`
  message += `Dirección: \n`
  message += `Referencia: \n\n`
  
  message += `¿Podrías ayudarme con este pedido? ¡Gracias!`
  
  // Codificar el mensaje para URL
  const encodedMessage = encodeURIComponent(message)
  
  // Número de WhatsApp (cambia este por el número de tu tienda)
  const phoneNumber = '51910985938' // Reemplaza con el número de tu tienda
  
  // Crear la URL de WhatsApp
  const whatsappUrl = `https://wa.me/${phoneNumber}?text=${encodedMessage}`
  
  // Abrir en nueva ventana
  window.open(whatsappUrl, '_blank')
}

// Si quieres permitir que el cliente ingrese su número de WhatsApp:
//  const shareOnWhatsApp = async () => {
//    const phone = prompt('Ingresa tu número de WhatsApp (ej: 51912345678):')
//    if (phone) {
//      // Resto del código para generar el mensaje
//      const whatsappUrl = `https://wa.me/${phone}?text=${encodedMessage}`
//      window.open(whatsappUrl, '_blank')
//    }
//  }
</script>

<style scoped>
/* Animaciones para móvil (slide-up) */
.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}

/* Animaciones para desktop (slide-right) */
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(100%);
}

/* Overlay fade */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Scrollbar personalizado */
::-webkit-scrollbar {
  width: 4px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 2px;
}

.dark ::-webkit-scrollbar-thumb {
  background: #4b5563;
}

/* Line clamp para truncar texto */
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>