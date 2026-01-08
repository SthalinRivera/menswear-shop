
// plugins/firebase.ts
import { defineNuxtPlugin } from '#app';
import { initializeApp } from 'firebase/app';
import { getStorage } from 'firebase/storage';

export default defineNuxtPlugin(nuxtApp => {
    const config = useRuntimeConfig();

    const firebaseConfig = {
        apiKey: config.public.firebaseApiKey,
        authDomain: config.public.firebaseAuthDomain,
        databaseURL: config.public.firebaseDatabaseUrl,
        projectId: config.public.firebaseProjectId,
        storageBucket: config.public.firebaseStorageBucket,
        messagingSenderId: config.public.firebaseMessagingSenderId,
        appId: config.public.firebaseAppId
    }

    const app = initializeApp(firebaseConfig)
    const storage = getStorage(app)

    nuxtApp.provide('storage', storage)
})