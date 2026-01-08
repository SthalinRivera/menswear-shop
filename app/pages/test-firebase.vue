<script setup lang="ts">
import { ref } from 'vue'


const files = ref<File[]>([])
const imageUrls = ref<string[]>([])
const error = ref('')

const {
    uploadMultipleImages,
    deleteImage,
    uploadProgress
} = useFirebaseUpload()

const handleChange = (e: Event) => {
    const input = e.target as HTMLInputElement
    if (input.files) {
        files.value = Array.from(input.files)
    }
}

const upload = async () => {
    if (!files.value.length) return

    try {
        error.value = ''
        const urls = await uploadMultipleImages(files.value, 'products/')
        imageUrls.value.push(...urls)
    } catch (err: any) {
        error.value = err.message
    }
}

const removeImage = async (url: string) => {
    try {
        await deleteImage(url)
        imageUrls.value = imageUrls.value.filter(img => img !== url)
    } catch (err: any) {
        error.value = err.message
    }
}
</script>

<template>
    <div class="max-w-4xl mx-auto p-6 bg-white dark:bg-gray-900 rounded-xl shadow space-y-6">

        <h1 class="text-2xl font-bold text-center">🔥 Firebase Upload & Delete</h1>

        <input type="file" multiple accept="image/*" @change="handleChange" class="block w-full text-sm
             file:mr-4 file:py-2 file:px-4
             file:rounded-lg file:border-0
             file:bg-blue-600 file:text-white
             hover:file:bg-blue-700" />

        <button @click="upload" class="w-full py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
            Subir imágenes
        </button>

        <!-- Progreso -->
        <div v-if="uploadProgress > 0">
            <p class="text-sm">Progreso: {{ uploadProgress.toFixed(0) }}%</p>
            <div class="w-full bg-gray-200 h-2 rounded-full">
                <div class="bg-blue-600 h-2 rounded-full transition-all" :style="{ width: uploadProgress + '%' }"></div>
            </div>
        </div>

        <!-- Galería -->
        <div v-if="imageUrls.length" class="grid grid-cols-2 md:grid-cols-3 gap-4">
            <div v-for="url in imageUrls" :key="url" class="relative group">
                <img :src="url" class="h-40 w-full object-cover rounded-lg shadow" />

                <button @click="removeImage(url)"
                    class="absolute top-2 right-2 bg-red-600 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition">
                    ✕
                </button>
            </div>
        </div>

        <p v-if="error" class="text-red-600 text-center">{{ error }}</p>
    </div>
</template>
