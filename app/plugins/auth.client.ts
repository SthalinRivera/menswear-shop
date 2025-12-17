// ~/plugins/auth.client.ts
import { useAuthService } from '~/services/auth.service'

export default defineNuxtPlugin(() => {
    return {
        provide: {
            auth: useAuthService()
        }
    }
})