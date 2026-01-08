import { useFirebase } from './useFirebaseStorage'
import type { Ref } from 'vue'

export interface ImagePreview {
    file: File
    url: string
    id: string
    firebaseRef?: any
    firebaseUrl?: string
    fileName: string
    uploadProgress?: number
}

export const useProductImages = () => {
    const { uploadImage, uploadMultipleImages, deleteImage, generateUniqueFileName } = useFirebase()
    const toast = useToast()

    /**
     * Subir imágenes a Firebase y actualizar el producto
     */
    const uploadProductImages = async (
        productId: string | number,
        images: File[],
        onProgress?: (progress: number) => void
    ): Promise<Array<{ url: string; fileName: string; originalName: string }>> => {
        try {
            if (!images.length) {
                return []
            }

            // Path específico para el producto
            const path = `products/${productId}/images/`

            // Mostrar progreso si se proporciona callback
            let progress = 0
            const progressStep = 100 / images.length

            const uploadedImages = []

            for (let i = 0; i < images.length; i++) {
                const file = images[i]

                try {
                    // Subir imagen individual
                    const result = await uploadImage(file, path, generateUniqueFileName(file))

                    uploadedImages.push({
                        url: result.url,
                        fileName: result.ref.name,
                        originalName: file.name,
                        size: file.size,
                        type: file.type
                    })

                    // Actualizar progreso
                    progress += progressStep
                    if (onProgress) {
                        onProgress(Math.min(100, Math.round(progress)))
                    }

                    // Pequeña pausa para evitar rate limits
                    if (i < images.length - 1) {
                        await new Promise(resolve => setTimeout(resolve, 100))
                    }

                } catch (error) {
                    console.error(`Error al subir imagen ${i + 1}:`, error)
                    toast.add({
                        title: 'Error en imagen',
                        description: `No se pudo subir ${file.name}`,
                        color: 'red',
                        icon: 'i-heroicons-exclamation-triangle'
                    })
                }
            }

            return uploadedImages

        } catch (error: any) {
            console.error('Error general al subir imágenes:', error)
            toast.add({
                title: 'Error',
                description: 'No se pudieron subir las imágenes',
                color: 'red',
                icon: 'i-heroicons-x-circle'
            })
            throw error
        }
    }

    /**
     * Manejar arrastrar y soltar
     */
    const handleImageDrop = (
        event: DragEvent,
        previewImages: Ref<ImagePreview[]>,
        selectedImages: Ref<File[]>,
        maxImages: number = 5
    ) => {
        event.preventDefault()

        const files = event.dataTransfer?.files
        if (!files) return

        const availableSlots = maxImages - previewImages.value.length
        const filesToAdd = Array.from(files).slice(0, availableSlots)

        filesToAdd.forEach(file => {
            if (!file.type.startsWith('image/')) {
                toast.add({
                    title: 'Error',
                    description: 'Solo se permiten archivos de imagen',
                    color: 'red',
                    icon: 'i-heroicons-x-circle'
                })
                return
            }

            const maxSize = 5 * 1024 * 1024 // 5MB
            if (file.size > maxSize) {
                toast.add({
                    title: 'Error',
                    description: 'La imagen es demasiado grande (máx. 5MB)',
                    color: 'red',
                    icon: 'i-heroicons-x-circle'
                })
                return
            }

            const url = URL.createObjectURL(file)
            previewImages.value.push({
                file,
                url,
                id: Math.random().toString(36).substring(7),
                fileName: file.name
            })
            selectedImages.value.push(file)
        })
    }

    /**
     * Optimizar imagen antes de subir
     */
    const optimizeImage = async (file: File, maxWidth: number = 1200, quality: number = 0.8): Promise<File> => {
        return new Promise((resolve, reject) => {
            const reader = new FileReader()

            reader.onload = (e) => {
                const img = new Image()
                img.onload = () => {
                    const canvas = document.createElement('canvas')

                    // Calcular nuevas dimensiones manteniendo aspect ratio
                    let width = img.width
                    let height = img.height

                    if (width > maxWidth) {
                        height = (height * maxWidth) / width
                        width = maxWidth
                    }

                    canvas.width = width
                    canvas.height = height

                    const ctx = canvas.getContext('2d')
                    if (!ctx) {
                        reject(new Error('No se pudo crear contexto del canvas'))
                        return
                    }

                    ctx.drawImage(img, 0, 0, width, height)

                    canvas.toBlob(
                        (blob) => {
                            if (!blob) {
                                reject(new Error('No se pudo optimizar la imagen'))
                                return
                            }

                            const optimizedFile = new File([blob], file.name, {
                                type: 'image/webp', // Cambiar a WebP para mejor compresión
                                lastModified: Date.now()
                            })

                            resolve(optimizedFile)
                        },
                        'image/webp',
                        quality
                    )
                }

                img.onerror = reject
                img.src = e.target?.result as string
            }

            reader.onerror = reject
            reader.readAsDataURL(file)
        })
    }

    /**
     * Limpiar URLs de objetos creados
     */
    const cleanupImageUrls = (previewImages: Ref<ImagePreview[]>) => {
        previewImages.value.forEach(image => {
            URL.revokeObjectURL(image.url)
        })
    }

    /**
     * Validar imagen antes de subir
     */
    const validateImage = (file: File): { valid: boolean; message?: string } => {
        // Validar tipo
        const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
        if (!allowedTypes.includes(file.type)) {
            return {
                valid: false,
                message: 'Tipo de archivo no permitido. Use JPG, PNG, WebP o GIF'
            }
        }

        // Validar tamaño (5MB)
        const maxSize = 5 * 1024 * 1024
        if (file.size > maxSize) {
            return {
                valid: false,
                message: 'La imagen es demasiado grande (máx. 5MB)'
            }
        }

        // Validar dimensión mínima
        return new Promise((resolve) => {
            const img = new Image()
            img.onload = () => {
                if (img.width < 100 || img.height < 100) {
                    resolve({
                        valid: false,
                        message: 'La imagen es demasiado pequeña (mín. 100x100px)'
                    })
                } else {
                    resolve({ valid: true })
                }
            }
            img.onerror = () => {
                resolve({
                    valid: false,
                    message: 'No se pudo cargar la imagen para validar'
                })
            }
            img.src = URL.createObjectURL(file)
        })
    }

    return {
        uploadProductImages,
        handleImageDrop,
        optimizeImage,
        cleanupImageUrls,
        validateImage,
        generateUniqueFileName
    }
}