<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

const fileRef = ref<HTMLInputElement>()
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

// Interfaces basadas en la respuesta del API
interface Usuario {
  usuario_id: number
  email: string
  nombre: string
  tipo_usuario: string
  email_verificado: boolean
  provider: string
  fecha_creacion: string
}

interface PerfilEmpleado {
  empleado_id: number
  sucursal_id: number
  codigo_empleado: string
  nombre: string
  apellido: string
  email: string
  telefono: string | null
  fecha_nacimiento: string | null
  fecha_contratacion: string
  puesto: string
  departamento: string
  salario_base: string
  comision_porcentaje: string
  activo: boolean
  fecha_creacion: string
  sucursal_nombre: string
}

interface PerfilCliente {
  cliente_id: number
  nombre: string
  apellido: string
  email: string
  telefono: string | null
  direccion: string | null
  fecha_nacimiento: string | null
  fecha_registro: string
  total_compras_count: number
  total_gastado: string | null
}

interface Role {
  nombre: string
  nivel: number
}

interface ApiResponse {
  success: boolean
  data: {
    usuario: Usuario
    perfil: PerfilEmpleado | PerfilCliente | {}
    roles: Role[]
  }
}

// Schema para el formulario
const profileSchema = z.object({
  nombre: z.string().min(2, 'El nombre es demasiado corto'),
  apellido: z.string().min(2, 'El apellido es demasiado corto'),
  email: z.string().email('Correo electrónico inválido'),
  telefono: z.string().optional(),
  puesto: z.string().optional(),
  departamento: z.string().optional(),
  fecha_nacimiento: z.string().optional(),
  avatar: z.string().optional(),
  bio: z.string().optional()
})

type ProfileSchema = z.output<typeof profileSchema>

// Estado para el formulario
const formData = reactive({
  nombre: '',
  apellido: '',
  email: '',
  telefono: '',
  puesto: '',
  departamento: '',
  fecha_nacimiento: '',
  avatar: '',
  bio: ''
})

// Datos adicionales
const usuarioId = ref(0)
const usuarioTipo = ref('')
const usuarioNombre = ref('')
const fechaCreacion = ref('')
const provider = ref('')
const rolesUsuario = ref<Role[]>([])

// Datos específicos para empleado
const codigoEmpleado = ref('')
const fechaContratacion = ref('')
const sucursalNombre = ref('')
const estadoEmpleado = ref('')
const salarioBase = ref('0.00')
const comisionPorcentaje = ref('0.00')

// Datos específicos para cliente
const clienteId = ref<number | null>(null)
const totalCompras = ref(0)
const totalGastado = ref('0.00')
const fechaRegistro = ref('')
const direccion = ref('')

// Estado para la carga
const isLoading = ref(true)
const toast = useToast()

// Obtener token de cookie
const accessToken = useCookie('access_token')
const token = accessToken.value

// Estado para controlar si el perfil está vacío
const perfilVacio = ref(false)
const esClienteSinPerfil = ref(false)

// Obtener datos del perfil
onMounted(async () => {
  await fetchProfile()
})

async function fetchProfile() {
  try {
    console.log('📡 Solicitando datos del perfil...')

    const { data, error } = await useFetch<ApiResponse>('http://localhost:4000/api/v1/auth/profile', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })

    if (error.value) {
      console.error('❌ Error en la solicitud:', error.value)
      throw new Error(error.value.message)
    }

    console.log('✅ Respuesta recibida:', data.value)

    if (data.value?.success && data.value.data) {
      const { usuario, perfil, roles } = data.value.data

      console.log('👤 Datos de usuario:', usuario)
      console.log('📋 Datos de perfil:', perfil)
      console.log('👥 Roles:', roles)

      // Guardar datos del usuario
      usuarioId.value = usuario.usuario_id
      usuarioTipo.value = usuario.tipo_usuario
      usuarioNombre.value = usuario.nombre || ''
      fechaCreacion.value = formatSpanishDate(usuario.fecha_creacion)
      provider.value = usuario.provider
      rolesUsuario.value = roles

      // Verificar si el perfil está vacío
      perfilVacio.value = Object.keys(perfil).length === 0

      if (perfilVacio.value) {
        console.log('⚠️ Perfil vacío detectado')

        // Si es cliente y perfil vacío
        if (usuario.tipo_usuario === 'Cliente') {
          esClienteSinPerfil.value = true
          console.log('🆕 Cliente sin perfil, mostrando formulario para crear perfil')

          // Usar datos básicos del usuario para el formulario
          // Dividir el nombre completo en nombre y apellido si es posible
          const nombreCompleto = usuario.nombre || ''
          const nombres = nombreCompleto.split(' ')
          formData.nombre = nombres[0] || ''
          formData.apellido = nombres.slice(1).join(' ') || ''
          formData.email = usuario.email || ''
          formData.bio = `Cliente registrado con ${provider.value === 'google' ? 'Google' : provider.value}`
        }

        toast.add({
          title: 'Información',
          description: usuario.tipo_usuario === 'Cliente'
            ? 'Completa tu perfil de cliente para continuar'
            : 'Tu perfil está incompleto',
          icon: 'i-lucide-info',
          color: 'warning'
        })

      } else {
        // Perfil tiene datos
        if (usuario.tipo_usuario === 'Empleado' && 'empleado_id' in perfil) {
          const perfilEmpleado = perfil as PerfilEmpleado

          console.log('💼 Datos de empleado detectados:', perfilEmpleado)

          // ASIGNAR DATOS DIRECTAMENTE AL FORMULARIO
          formData.nombre = perfilEmpleado.nombre || ''
          formData.apellido = perfilEmpleado.apellido || ''
          formData.email = perfilEmpleado.email || usuario.email || ''
          formData.telefono = perfilEmpleado.telefono || ''
          formData.puesto = perfilEmpleado.puesto || ''
          formData.departamento = perfilEmpleado.departamento || ''

          // Formatear fecha si existe
          if (perfilEmpleado.fecha_nacimiento) {
            formData.fecha_nacimiento = formatDateForInput(perfilEmpleado.fecha_nacimiento)
          }

          // Datos adicionales para empleado
          codigoEmpleado.value = perfilEmpleado.codigo_empleado || ''
          fechaContratacion.value = formatSpanishDate(perfilEmpleado.fecha_contratacion)
          sucursalNombre.value = perfilEmpleado.sucursal_nombre || ''
          estadoEmpleado.value = perfilEmpleado.activo ? 'Activo' : 'Inactivo'
          salarioBase.value = perfilEmpleado.salario_base || '0.00'
          comisionPorcentaje.value = perfilEmpleado.comision_porcentaje || '0.00'

          // Bio opcional para empleado
          formData.bio = `Empleado en ${perfilEmpleado.sucursal_nombre}, trabajando como ${perfilEmpleado.puesto} en el departamento de ${perfilEmpleado.departamento}.`

        } else if (usuario.tipo_usuario === 'Cliente' && 'cliente_id' in perfil) {
          const perfilCliente = perfil as PerfilCliente

          console.log('🛒 Datos de cliente detectados:', perfilCliente)

          // ASIGNAR DATOS DIRECTAMENTE AL FORMULARIO
          formData.nombre = perfilCliente.nombre || ''
          formData.apellido = perfilCliente.apellido || ''
          formData.email = perfilCliente.email || usuario.email || ''
          formData.telefono = perfilCliente.telefono || ''

          // Formatear fecha si existe
          if (perfilCliente.fecha_nacimiento) {
            formData.fecha_nacimiento = formatDateForInput(perfilCliente.fecha_nacimiento)
          }

          // Datos adicionales para cliente
          clienteId.value = perfilCliente.cliente_id
          totalCompras.value = perfilCliente.total_compras_count || 0
          totalGastado.value = perfilCliente.total_gastado || '0.00'
          fechaRegistro.value = formatSpanishDate(perfilCliente.fecha_registro)
          direccion.value = perfilCliente.direccion || ''

          // Bio opcional para cliente
          formData.bio = `Cliente desde ${formatSpanishDate(perfilCliente.fecha_registro)}.`
        }
      }

      console.log('📝 Datos del formulario cargados:', formData)
    } else {
      console.error('❌ Respuesta del API no exitosa:', data.value)
      toast.add({
        title: 'Error',
        description: 'No se pudieron obtener los datos del perfil',
        icon: 'i-lucide-alert-circle',
        color: 'error'
      })
    }
  } catch (error) {
    console.error('❌ Error fetching profile:', error)
    toast.add({
      title: 'Error',
      description: 'No se pudo cargar la información del perfil',
      icon: 'i-lucide-alert-circle',
      color: 'error'
    })
  } finally {
    isLoading.value = false
  }
}

// Función para formatear fecha para input type="date"
function formatDateForInput(dateString: string): string {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toISOString().split('T')[0]
  } catch {
    return ''
  }
}

// Función para formatear fecha en español
function formatSpanishDate(dateString: string): string {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    })
  } catch {
    return dateString
  }
}

async function onSubmit(event: FormSubmitEvent<ProfileSchema>) {
  try {
    let endpoint = ''
    let updateData: any = {}

    if (usuarioTipo.value === 'Empleado') {
      endpoint = 'http://localhost:4000/api/v1/auth/empleado/update'
      updateData = {
        nombre: formData.nombre,
        apellido: formData.apellido,
        telefono: formData.telefono || null,
        fecha_nacimiento: formData.fecha_nacimiento || null,
        puesto: formData.puesto,
        departamento: formData.departamento
      }
    } else if (usuarioTipo.value === 'Cliente') {
      // Si es cliente sin perfil, crear perfil, si no, actualizar
      endpoint = perfilVacio.value
        ? 'http://localhost:4000/api/v1/auth/cliente/create'
        : 'http://localhost:4000/api/v1/auth/cliente/update'

      updateData = {
        nombre: formData.nombre,
        apellido: formData.apellido,
        telefono: formData.telefono || null,
        fecha_nacimiento: formData.fecha_nacimiento || null,
        direccion: direccion.value || null
      }

      // Si es creación, incluir email
      if (perfilVacio.value) {
        updateData.email = formData.email
      }
    }

    console.log('📤 Enviando datos:', updateData)
    console.log('📍 Endpoint:', endpoint)

    const { data, error } = await useFetch(endpoint, {
      method: perfilVacio.value && usuarioTipo.value === 'Cliente' ? 'POST' : 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updateData)
    })

    if (error.value) {
      throw new Error(error.value.message)
    }

    console.log('✅ Respuesta:', data.value)

    toast.add({
      title: '¡Éxito!',
      description: perfilVacio.value
        ? 'Perfil creado correctamente'
        : 'Tu perfil ha sido actualizado correctamente.',
      icon: 'i-lucide-check',
      color: 'success'
    })

    // Recargar datos después de actualizar
    await fetchProfile()

  } catch (error) {
    console.error('❌ Error updating profile:', error)
    toast.add({
      title: 'Error',
      description: 'No se pudo actualizar el perfil',
      icon: 'i-lucide-alert-circle',
      color: 'error'
    })
  }
}

function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement

  if (!input.files?.length) {
    return
  }

  // Crear URL temporal para vista previa
  formData.avatar = URL.createObjectURL(input.files[0]!)

  // Subir el archivo al servidor
  uploadAvatar(input.files[0])
}

function onFileClick() {
  fileRef.value?.click()
}

// Función para subir avatar al servidor
async function uploadAvatar(file: File) {
  const formDataUpload = new FormData()
  formDataUpload.append('avatar', file)

  try {
    const { data, error } = await useFetch('http://localhost:4000/api/v1/auth/profile/avatar', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: formDataUpload
    })

    if (error.value) {
      throw new Error(error.value.message)
    }

    toast.add({
      title: '¡Éxito!',
      description: 'Avatar actualizado correctamente',
      icon: 'i-lucide-check',
      color: 'success'
    })
  } catch (error) {
    console.error('Error uploading avatar:', error)
    toast.add({
      title: 'Error',
      description: 'No se pudo subir el avatar',
      icon: 'i-lucide-alert-circle',
      color: 'error'
    })
  }
}
</script>

<template>
  <div v-if="isLoading" class="flex justify-center items-center h-64">
    <UCard>
      <div class="flex items-center gap-2">
        <UIcon name="i-lucide-loader-2" class="animate-spin" />
        <span>Cargando perfil...</span>
      </div>
    </UCard>
  </div>

  <UForm v-else id="settings" :schema="profileSchema" :state="formData" @submit="onSubmit">
    <!-- Encabezado dinámico -->
    <UPageCard :title="usuarioTipo === 'Cliente' ? 'Perfil de Cliente' : 'Perfil de Empleado'" :description="perfilVacio
      ? 'Completa tu información para continuar'
      : 'Esta información se mostrará públicamente.'" variant="naked" orientation="horizontal" class="mb-4">
      <UButton form="settings" :label="perfilVacio ? 'Crear perfil' : 'Guardar cambios'"
        :color="perfilVacio ? 'green' : 'primary'" type="submit" class="w-fit lg:ms-auto" />
    </UPageCard>

    <!-- Mensaje para cliente sin perfil -->
    <div v-if="perfilVacio && usuarioTipo === 'Cliente'" class="mb-6">
      <UAlert title="¡Bienvenido!"
        description="Completa tu perfil para disfrutar de todos los beneficios de ser cliente."
        icon="i-lucide-user-plus" color="warning" variant="subtle" />
    </div>

    <UPageCard variant="subtle">
      <!-- Nombre -->
      <UFormField name="nombre" label="Nombre" description="Tu nombre para identificarte." required
        class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="formData.nombre" autocomplete="off" placeholder="Ingresa tu nombre" />
      </UFormField>
      <USeparator />

      <!-- Apellido -->
      <UFormField name="apellido" label="Apellido" description="Tu apellido para completar tu identificación." required
        class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="formData.apellido" autocomplete="off" placeholder="Ingresa tu apellido" />
      </UFormField>
      <USeparator />

      <!-- Email -->
      <UFormField name="email" label="Correo Electrónico"
        description="Usado para iniciar sesión y recibir notificaciones." required
        class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="formData.email" type="email" autocomplete="off" :disabled="!perfilVacio"
          :ui="{ base: 'disabled:opacity-50 disabled:cursor-not-allowed' }" />
      </UFormField>
      <USeparator />

      <!-- Teléfono -->
      <UFormField name="telefono" label="Teléfono" description="Número de contacto para comunicación."
        class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="formData.telefono" type="tel" autocomplete="off" placeholder="Ingresa tu número telefónico" />
      </UFormField>
      <USeparator />

      <!-- Puesto y Departamento solo para empleados -->
      <template v-if="usuarioTipo === 'Empleado' && !perfilVacio">
        <!-- Puesto -->
        <UFormField name="puesto" label="Puesto" description="Tu posición actual en la empresa." required
          class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="formData.puesto" autocomplete="off" placeholder="Ingresa tu puesto" />
        </UFormField>
        <USeparator />

        <!-- Departamento -->
        <UFormField name="departamento" label="Departamento" description="Área de la empresa a la que perteneces."
          required class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="formData.departamento" autocomplete="off" placeholder="Ingresa tu departamento" />
        </UFormField>
        <USeparator />
      </template>

      <!-- Dirección solo para clientes -->
      <template v-if="usuarioTipo === 'Cliente'">
        <UFormField name="direccion" label="Dirección" description="Tu dirección de envío y facturación."
          class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="direccion" autocomplete="off" placeholder="Ingresa tu dirección completa" />
        </UFormField>
        <USeparator />
      </template>

      <!-- Fecha de Nacimiento -->
      <UFormField name="fecha_nacimiento" label="Fecha de Nacimiento"
        description="Tu fecha de nacimiento para registro."
        class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="formData.fecha_nacimiento" type="date" autocomplete="off" />
      </UFormField>
      <USeparator />

      <!-- Avatar -->
      <UFormField name="avatar" label="Foto de Perfil" description="JPG, GIF o PNG. Máximo 1MB."
        class="flex max-sm:flex-col justify-between sm:items-center gap-4">
        <div class="flex flex-wrap items-center gap-3">
          <UAvatar :src="formData.avatar" :alt="formData.nombre" size="lg" />
          <UButton label="Seleccionar" color="neutral" @click="onFileClick" />
          <input ref="fileRef" type="file" class="hidden" accept=".jpg, .jpeg, .png, .gif" @change="onFileChange">
        </div>
      </UFormField>
      <USeparator />

      <!-- Bio/Descripción -->
      <UFormField name="bio" label="Biografía"
        description="Descripción breve de tu perfil. Los enlaces se convierten automáticamente."
        class="flex max-sm:flex-col justify-between items-start gap-4" :ui="{ container: 'w-full' }">
        <UTextarea v-model="formData.bio" :rows="5" autoresize class="w-full"
          placeholder="Ingresa una descripción sobre ti..." />
      </UFormField>
    </UPageCard>

    <!-- Información del sistema -->
    <UPageCard variant="subtle" class="mt-4">
      <h3 class="text-lg font-semibold mb-4">Información del Sistema</h3>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <!-- Información común -->
        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">ID de Usuario</label>
          <p class="text-sm text-gray-500 dark:text-gray-400 font-mono">{{ usuarioId }}</p>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Tipo de Usuario</label>
          <p class="text-sm text-gray-500 dark:text-gray-400 font-semibold">{{ usuarioTipo }}</p>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Fecha de Registro</label>
          <p class="text-sm text-gray-500 dark:text-gray-400">{{ fechaCreacion }}</p>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Email Verificado</label>
          <p class="text-sm text-green-600 dark:text-green-400 font-semibold">Sí</p>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Método de Registro</label>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            <span v-if="provider === 'google'" class="flex items-center gap-1">
              <UIcon name="i-lucide-mail" class="w-4 h-4" />
              Google
            </span>
            <span v-else class="flex items-center gap-1">
              <UIcon name="i-lucide-user" class="w-4 h-4" />
              {{ provider }}
            </span>
          </p>
        </div>

        <!-- Estado del perfil -->
        <div>
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Estado del Perfil</label>
          <p :class="{
            'text-sm font-semibold text-green-600 dark:text-green-400': !perfilVacio,
            'text-sm font-semibold text-yellow-600 dark:text-yellow-400': perfilVacio
          }">
            {{ perfilVacio ? 'Incompleto' : 'Completo' }}
          </p>
        </div>

        <!-- Información específica para empleado -->
        <template v-if="usuarioTipo === 'Empleado' && !perfilVacio">
          <div>
            <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Código de Empleado</label>
            <p class="text-sm text-gray-500 dark:text-gray-400 font-mono">{{ codigoEmpleado || 'No asignado' }}</p>
          </div>

          <div>
            <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Estado</label>
            <p :class="{
              'text-sm font-semibold text-green-600 dark:text-green-400': estadoEmpleado === 'Activo',
              'text-sm font-semibold text-red-600 dark:text-red-400': estadoEmpleado === 'Inactivo'
            }">
              {{ estadoEmpleado }}
            </p>
          </div>
        </template>

        <!-- Roles -->
        <div v-if="rolesUsuario.length > 0" class="md:col-span-2 lg:col-span-3">
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">Roles y Permisos</label>
          <div class="flex flex-wrap gap-2">
            <UBadge v-for="role in rolesUsuario" :key="role.nombre" color="primary" variant="subtle" class="px-3 py-1">
              <div class="flex items-center gap-2">
                <span>{{ role.nombre }}</span>
                <span class="text-xs opacity-75">(Nivel {{ role.nivel }})</span>
              </div>
            </UBadge>
          </div>
        </div>

        <!-- Mensaje si no hay roles -->
        <div v-else class="md:col-span-2 lg:col-span-3">
          <label class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">Roles y Permisos</label>
          <p class="text-sm text-gray-500 dark:text-gray-400">No se han asignado roles específicos</p>
        </div>
      </div>
    </UPageCard>
  </UForm>
</template>