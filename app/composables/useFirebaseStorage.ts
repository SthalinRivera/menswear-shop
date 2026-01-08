import { ref } from 'vue'
import {
    ref as storageRef,
    uploadBytesResumable,
    getDownloadURL,
    deleteObject
} from 'firebase/storage'
import { useNuxtApp } from '#app'

export const useFirebaseUpload = () => {
    const uploadProgress = ref(0)
    const { $storage } = useNuxtApp()

    if (!$storage) {
        throw new Error('Firebase Storage no está disponible')
    }

    // 🔹 Subir UNA imagen
    const uploadImage = async (file: File, path: string) => {
        const fileName = `${Date.now()}_${file.name}`
        const refFile = storageRef($storage, `${path}${fileName}`)

        const task = uploadBytesResumable(refFile, file)

        return new Promise<string>((resolve, reject) => {
            task.on(
                'state_changed',
                snap => {
                    uploadProgress.value =
                        (snap.bytesTransferred / snap.totalBytes) * 100
                },
                reject,
                async () => {
                    resolve(await getDownloadURL(task.snapshot.ref))
                }
            )
        })
    }

    // 🔹 Subir MÚLTIPLES imágenes
    const uploadMultipleImages = async (
        files: File[],
        productId: number
    ): Promise<string[]> => {
        if (!Array.isArray(files)) {
            throw new Error('files debe ser un array de File')
        }

        const urls: string[] = []

        for (const file of files) {
            const url = await uploadImage(file, `products/${productId}/`)
            urls.push(url)
        }

        return urls
    }

    // 🔴 Eliminar imagen
    const deleteImage = async (url: string) => {
        const refFile = storageRef($storage, url)
        await deleteObject(refFile)
    }

    return {
        uploadProgress,
        uploadImage,
        uploadMultipleImages,
        deleteImage
    }
}
