# 🛍️ Sistema de Tienda de Ropa – Nuxt 3

Sistema web moderno para la gestión y venta de ropa en línea, desarrollado con **Nuxt 3**.  
Incluye autenticación, gestión de productos, carrito de compras, roles y permisos, y un panel administrativo.

---

## 🚀 Tecnologías Utilizadas

- **Nuxt 3** (Vue 3 + Vite)
- **TypeScript**
- **Tailwind CSS**
- **Pinia** (gestión de estado)
- **Zod** (validación de formularios)
- **Nuxt UI**
- **JWT (Access & Refresh Token)**
- **API REST**
- **OAuth 2.0 (Google Login)**

---

## 📦 Funcionalidades Principales

### 👤 Autenticación y Seguridad
- Registro de usuarios
- Inicio de sesión con email y contraseña
- Inicio de sesión con Google
- Manejo de Access Token y Refresh Token
- Middleware de protección de rutas
- Cierre de sesión seguro

### 🛒 Tienda
- Catálogo de productos
- Vista detallada de productos
- Carrito de compras persistente
- Gestión de stock
- Precios con descuentos

### 🧑‍💼 Administración
- Dashboard administrativo
- Gestión de usuarios
- Gestión de roles y permisos
- Gestión de productos y categorías
- Activar / desactivar roles
- Control de niveles de acceso

---

## 🗂️ Estructura del Proyecto

```bash
├── assets/
├── components/
├── composables/
│   ├── useAuthService.ts
│   ├── useRoles.ts
│   └── useApiFetch.ts
├── layouts/
├── middleware/
│   ├── auth.ts
│   └── guest.ts
├── pages/
│   ├── auth/
│   ├── dashboard/
│   └── index.vue
├── services/
├── stores/
├── types/
├── nuxt.config.ts
└── README.md
