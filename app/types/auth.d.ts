// ~/types/auth.d.ts
import { useAuthService } from '~/services/auth.service';

declare module '#app' {
    interface NuxtApp {
        $auth: ReturnType<typeof useAuthService>
    }
}

declare module '@vue/runtime-core' {
    interface ComponentCustomProperties {
        $auth: ReturnType<typeof useAuthService>
    }
}

export { }