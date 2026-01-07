-- =============================================
-- BASE DE DATOS: TIENDA_ROPA
-- =============================================



-- =============================================
-- EXTENSIONES NECESARIAS
-- =============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- TABLA: Empresas (Multi-tenant si aplica)
-- =============================================
CREATE TABLE empresas (
    empresa_id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    nombre_comercial VARCHAR(200),
    rfc VARCHAR(20) UNIQUE,
    regimen_fiscal VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(255),
    sitio_web VARCHAR(255),
    -- Dirección fiscal
    calle VARCHAR(255),
    numero_exterior VARCHAR(20),
    numero_interior VARCHAR(20),
    colonia VARCHAR(100),
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    codigo_postal VARCHAR(10),
    pais VARCHAR(100) DEFAULT 'México',
    -- Configuración
    moneda_principal CHAR(3) DEFAULT 'MXN',
    zona_horaria VARCHAR(50) DEFAULT 'America/Mexico_City',
    idioma CHAR(2) DEFAULT 'es',
    formato_fecha VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    -- Logos y branding
    logo_url VARCHAR(500),
    favicon_url VARCHAR(500),
    color_principal CHAR(7) DEFAULT '#007bff',
    -- Estado
    activa BOOLEAN DEFAULT TRUE,
    plan VARCHAR(20) DEFAULT 'Basico' CHECK (plan IN ('Gratuito', 'Basico', 'Profesional', 'Empresarial')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Sucursales (Multi-sucursal)
-- =============================================
CREATE TABLE sucursales (
    sucursal_id SERIAL PRIMARY KEY,
    empresa_id INT NOT NULL REFERENCES empresas(empresa_id) ON DELETE CASCADE,
    nombre VARCHAR(150) NOT NULL,
    codigo_sucursal VARCHAR(20) UNIQUE,
    tipo VARCHAR(20) DEFAULT 'Tienda' CHECK (tipo IN ('Tienda', 'Almacén', 'Oficina', 'Outlet')),
    -- Dirección
    calle VARCHAR(255),
    numero_exterior VARCHAR(20),
    colonia VARCHAR(100),
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(255),
    -- Configuración
    almacen_principal_id INT,
    gerente_id INT,
    horario_apertura TIME DEFAULT '09:00:00',
    horario_cierre TIME DEFAULT '21:00:00',
    dias_apertura TEXT DEFAULT 'Lunes,Martes,Miércoles,Jueves,Viernes,Sábado',
    -- Estado
    activa BOOLEAN DEFAULT TRUE,
    fecha_apertura DATE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Categorias (Jerarquía de productos)
-- =============================================
CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_padre_id INT REFERENCES categorias(categoria_id) ON DELETE SET NULL,
    nivel INT DEFAULT 1,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categorias_nivel ON categorias(nivel);
CREATE INDEX idx_categorias_activa ON categorias(activa);

-- =============================================
-- TABLA: Marcas
-- =============================================
CREATE TABLE marcas (
    marca_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    pais_origen VARCHAR(100),
    sitio_web VARCHAR(255),
    contacto_email VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Proveedores
-- =============================================
CREATE TABLE proveedores (
    proveedor_id SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(200) NOT NULL,
    nombre_contacto VARCHAR(150),
    telefono VARCHAR(20),
    email VARCHAR(255),
    direccion TEXT,
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    rfc VARCHAR(20),
    tipo_proveedor VARCHAR(20) DEFAULT 'Distribuidor' 
        CHECK (tipo_proveedor IN ('Fabricante', 'Distribuidor', 'Mayorista', 'Internacional')),
    plazo_entrega_dias INT DEFAULT 15,
    calificacion DECIMAL(3,2) CHECK (calificacion BETWEEN 0 AND 5),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_proveedores_tipo ON proveedores(tipo_proveedor);
CREATE INDEX idx_proveedores_activo ON proveedores(activo);

-- =============================================
-- TABLA: Productos
-- =============================================
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT NOT NULL REFERENCES categorias(categoria_id),
    marca_id INT REFERENCES marcas(marca_id),
    genero VARCHAR(20) DEFAULT 'Unisex' 
        CHECK (genero IN ('Hombre', 'Mujer', 'Unisex', 'Niño', 'Niña')),
    temporada VARCHAR(20) DEFAULT 'Todo el año' 
        CHECK (temporada IN ('Primavera', 'Verano', 'Otoño', 'Invierno', 'Todo el año')),
    material_principal VARCHAR(100),
    cuidados TEXT,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    impuesto_porcentaje DECIMAL(5,2) DEFAULT 16.00,
    es_promocion BOOLEAN DEFAULT FALSE,
    porcentaje_descuento DECIMAL(5,2) DEFAULT 0,
    precio_promocion DECIMAL(10,2),
    fecha_inicio_promocion DATE,
    fecha_fin_promocion DATE,
    stock_minimo INT DEFAULT 5,
    stock_maximo INT DEFAULT 100,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Campos generados
ALTER TABLE productos
ADD COLUMN margen_ganancia DECIMAL(5,2) 
    GENERATED ALWAYS AS (
        CASE 
            WHEN precio_compra > 0 THEN ((precio_venta - precio_compra) / precio_compra) * 100
            ELSE 0
        END
    ) STORED,
ADD COLUMN costo_impuesto DECIMAL(10,2) 
    GENERATED ALWAYS AS (precio_venta * (impuesto_porcentaje/100)) STORED,
ADD COLUMN precio_final DECIMAL(10,2) 
    GENERATED ALWAYS AS (precio_venta + (precio_venta * (impuesto_porcentaje/100))) STORED;

CREATE INDEX idx_productos_sku ON productos(sku);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_marca ON productos(marca_id);
CREATE INDEX idx_productos_genero ON productos(genero);
CREATE INDEX idx_productos_temporada ON productos(temporada);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_promocion ON productos(es_promocion);
CREATE INDEX idx_productos_fecha_creacion ON productos(fecha_creacion);

-- =============================================
-- TABLA: Variantes_Producto (Tallas, colores)
-- =============================================
CREATE TABLE variantes_producto (
    variante_id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL REFERENCES productos(producto_id) ON DELETE CASCADE,
    talla VARCHAR(20) NOT NULL,
    color_nombre VARCHAR(50),
    color_hex VARCHAR(7),
    stock_actual INT DEFAULT 0,
    stock_reservado INT DEFAULT 0,
    ubicacion_almacen VARCHAR(50),
    codigo_barras VARCHAR(100) UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_ultima_entrada DATE,
    fecha_ultima_salida DATE
);

-- Campo generado
ALTER TABLE variantes_producto
ADD COLUMN stock_disponible INT 
    GENERATED ALWAYS AS (stock_actual - stock_reservado) STORED;

CREATE UNIQUE INDEX uk_producto_talla_color 
    ON variantes_producto(producto_id, talla, color_nombre);
CREATE INDEX idx_variantes_stock_disponible ON variantes_producto(stock_disponible);
CREATE INDEX idx_variantes_talla ON variantes_producto(talla);
CREATE INDEX idx_variantes_producto ON variantes_producto(producto_id);

-- =============================================
-- TABLA: Almacenes
-- =============================================
CREATE TABLE almacenes (
    almacen_id SERIAL PRIMARY KEY,
    sucursal_id INT REFERENCES sucursales(sucursal_id),
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    ciudad VARCHAR(100),
    telefono VARCHAR(20),
    responsable VARCHAR(150),
    capacidad_total INT,
    capacidad_utilizada INT DEFAULT 0,
    tipo VARCHAR(20) DEFAULT 'Principal' 
        CHECK (tipo IN ('Principal', 'Sucursal', 'Externo', 'Outlet')),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agregar foreign key desde sucursales
ALTER TABLE sucursales 
ADD CONSTRAINT fk_sucursales_almacen 
FOREIGN KEY (almacen_principal_id) 
REFERENCES almacenes(almacen_id);

-- =============================================
-- TABLA: Inventario
-- =============================================
CREATE TABLE inventario (
    inventario_id SERIAL PRIMARY KEY,
    variante_id INT NOT NULL REFERENCES variantes_producto(variante_id),
    almacen_id INT NOT NULL REFERENCES almacenes(almacen_id),
    cantidad INT NOT NULL DEFAULT 0,
    ubicacion VARCHAR(50),
    nivel_reabastecimiento INT DEFAULT 10,
    fecha_ultimo_conteo DATE,
    responsable_conteo VARCHAR(150),
    observaciones TEXT,
    UNIQUE(variante_id, almacen_id)
);

CREATE INDEX idx_inventario_cantidad ON inventario(cantidad);
CREATE INDEX idx_inventario_almacen ON inventario(almacen_id);

-- =============================================
-- TABLA: Clientes
-- =============================================
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    codigo_cliente VARCHAR(20) UNIQUE NOT NULL,
    tipo_cliente VARCHAR(20) DEFAULT 'Minorista' 
        CHECK (tipo_cliente IN ('Minorista', 'Mayorista', 'Empresarial', 'VIP')),
    nombre VARCHAR(150) NOT NULL,
    apellido VARCHAR(150),
    email VARCHAR(255) UNIQUE,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    genero CHAR(1) DEFAULT 'M' CHECK (genero IN ('M', 'F', 'O')),
    dni VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    codigo_postal VARCHAR(10),
    pais VARCHAR(100) DEFAULT 'México',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    puntos_fidelidad INT DEFAULT 0,
    total_compras DECIMAL(15,2) DEFAULT 0,
    ultima_compra DATE,
    frecuencia_compra_dias INT,
    segmento VARCHAR(20) DEFAULT 'Nuevo' 
        CHECK (segmento IN ('Nuevo', 'Ocasional', 'Frecuente', 'Leal')),
    acepta_marketing BOOLEAN DEFAULT TRUE,
    notas TEXT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_tipo ON clientes(tipo_cliente);
CREATE INDEX idx_clientes_segmento ON clientes(segmento);
CREATE INDEX idx_clientes_fecha_registro ON clientes(fecha_registro);
CREATE INDEX idx_clientes_puntos ON clientes(puntos_fidelidad);

-- =============================================
-- TABLA: Empleados
-- =============================================
CREATE TABLE empleados (
    empleado_id SERIAL PRIMARY KEY,
    sucursal_id INT REFERENCES sucursales(sucursal_id),
    codigo_empleado VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    apellido VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    fecha_contratacion DATE NOT NULL,
    puesto VARCHAR(20) DEFAULT 'Vendedor' 
        CHECK (puesto IN ('Vendedor', 'Cajero', 'Supervisor', 'Gerente', 'Almacenista', 'Administrativo')),
    departamento VARCHAR(20) DEFAULT 'Ventas' 
        CHECK (departamento IN ('Ventas', 'Almacén', 'Administración', 'RRHH', 'Marketing')),
    salario_base DECIMAL(10,2),
    comision_porcentaje DECIMAL(5,2) DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_empleados_puesto ON empleados(puesto);
CREATE INDEX idx_empleados_departamento ON empleados(departamento);
CREATE INDEX idx_empleados_activo ON empleados(activo);

-- =============================================
-- TABLA: Usuarios (Sistema de autenticación)
-- =============================================
CREATE TABLE usuarios (
    usuario_id SERIAL PRIMARY KEY,
    empleado_id INT REFERENCES empleados(empleado_id) ON DELETE CASCADE,
    cliente_id INT REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    contrasena_hash VARCHAR(255),
    tipo_usuario VARCHAR(20) DEFAULT 'Cliente' 
        CHECK (tipo_usuario IN ('Empleado', 'Cliente', 'Administrador', 'Proveedor', 'Sistema')),
    -- Campos para OAuth/Google
    google_id VARCHAR(255) UNIQUE,
    facebook_id VARCHAR(255) UNIQUE,
    apple_id VARCHAR(255) UNIQUE,
    -- Información de autenticación
    provider VARCHAR(20) DEFAULT 'local' 
        CHECK (provider IN ('local', 'google', 'facebook', 'apple')),
    email_verificado BOOLEAN DEFAULT FALSE,
    token_verificacion VARCHAR(255),
    fecha_verificacion TIMESTAMP,
    -- Configuración de seguridad
    requiere_2fa BOOLEAN DEFAULT FALSE,
    secret_2fa VARCHAR(255),
    intentos_fallidos INT DEFAULT 0,
    bloqueado_hasta TIMESTAMP,
    ultimo_cambio_contrasena TIMESTAMP,
    -- Token de sesión/reset
    reset_token VARCHAR(255),
    reset_expira TIMESTAMP,
    -- Estado
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_login TIMESTAMP,
    ip_ultimo_login VARCHAR(45),
    dispositivo_ultimo_login VARCHAR(255)
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_google ON usuarios(google_id);
CREATE INDEX idx_usuarios_tipo ON usuarios(tipo_usuario);
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

-- =============================================
-- TABLA: Roles
-- =============================================
CREATE TABLE roles (
    rol_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    nivel INT DEFAULT 1,
    tipo VARCHAR(20) DEFAULT 'Negocio' 
        CHECK (tipo IN ('Sistema', 'Negocio', 'Personalizado')),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(usuario_id)
);

-- =============================================
-- TABLA: Permisos
-- =============================================
CREATE TABLE permisos (
    permiso_id SERIAL PRIMARY KEY,
    codigo VARCHAR(100) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    modulo VARCHAR(20) NOT NULL 
        CHECK (modulo IN ('Ventas', 'Inventario', 'Clientes', 'Compras', 'Reportes', 'Configuracion', 'Empleados', 'Marketing')),
    submodulo VARCHAR(100),
    nivel VARCHAR(20) DEFAULT 'Lectura' 
        CHECK (nivel IN ('Lectura', 'Escritura', 'Eliminacion', 'Administracion')),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Roles_Permisos
-- =============================================
CREATE TABLE roles_permisos (
    rol_permiso_id SERIAL PRIMARY KEY,
    rol_id INT NOT NULL REFERENCES roles(rol_id) ON DELETE CASCADE,
    permiso_id INT NOT NULL REFERENCES permisos(permiso_id) ON DELETE CASCADE,
    concedido BOOLEAN DEFAULT TRUE,
    fecha_concesion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    concedido_por INT REFERENCES usuarios(usuario_id),
    UNIQUE(rol_id, permiso_id)
);

-- =============================================
-- TABLA: Usuarios_Roles
-- =============================================
CREATE TABLE usuarios_roles (
    usuario_rol_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    rol_id INT NOT NULL REFERENCES roles(rol_id),
    asignado_por INT REFERENCES usuarios(usuario_id),
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATE,
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(usuario_id, rol_id)
);

CREATE INDEX idx_usuarios_roles_usuario ON usuarios_roles(usuario_id);
CREATE INDEX idx_usuarios_roles_activo ON usuarios_roles(activo);

-- =============================================
-- TABLA: Usuarios_Empresa (Asignación)
-- =============================================
CREATE TABLE usuarios_empresa (
    usuario_empresa_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    empresa_id INT NOT NULL REFERENCES empresas(empresa_id) ON DELETE CASCADE,
    sucursal_id INT REFERENCES sucursales(sucursal_id),
    es_administrador_empresa BOOLEAN DEFAULT FALSE,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    asignado_por INT REFERENCES usuarios(usuario_id),
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(usuario_id, empresa_id)
);

CREATE INDEX idx_usuarios_empresa_empresa ON usuarios_empresa(empresa_id);

-- =============================================
-- TABLA: Ventas (Cabecera)
-- =============================================
CREATE TABLE ventas (
    venta_id SERIAL PRIMARY KEY,
    sucursal_id INT REFERENCES sucursales(sucursal_id),
    codigo_venta VARCHAR(50) UNIQUE NOT NULL,
    cliente_id INT REFERENCES clientes(cliente_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_venta VARCHAR(20) DEFAULT 'Presencial' 
        CHECK (tipo_venta IN ('Presencial', 'Online', 'Telefónica', 'Mayorista')),
    estado_venta VARCHAR(20) DEFAULT 'Pendiente' 
        CHECK (estado_venta IN ('Pendiente', 'Pagada', 'Cancelada', 'Reembolsada', 'Enviada', 'Entregada')),
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    descuento_total DECIMAL(12,2) DEFAULT 0,
    impuesto_total DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,
    metodo_pago VARCHAR(20) DEFAULT 'Efectivo' 
        CHECK (metodo_pago IN ('Efectivo', 'Tarjeta Crédito', 'Tarjeta Débito', 'Transferencia', 'PayPal', 'Mercado Pago')),
    referencia_pago VARCHAR(100),
    notas TEXT,
    direccion_envio TEXT,
    costo_envio DECIMAL(10,2) DEFAULT 0,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ventas_fecha_venta ON ventas(fecha_venta);
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_empleado ON ventas(empleado_id);
CREATE INDEX idx_ventas_estado ON ventas(estado_venta);
CREATE INDEX idx_ventas_tipo ON ventas(tipo_venta);
CREATE INDEX idx_ventas_codigo_venta ON ventas(codigo_venta);

-- =============================================
-- TABLA: Detalles_Venta
-- =============================================
CREATE TABLE detalles_venta (
    detalle_id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL REFERENCES ventas(venta_id) ON DELETE CASCADE,
    variante_id INT NOT NULL REFERENCES variantes_producto(variante_id),
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_unitario DECIMAL(10,2) DEFAULT 0,
    impuesto_unitario DECIMAL(10,2) DEFAULT 0,
    comision_empleado DECIMAL(10,2) DEFAULT 0,
    devuelto BOOLEAN DEFAULT FALSE,
    cantidad_devuelta INT DEFAULT 0,
    motivo_devolucion TEXT
);

-- Campo generado
ALTER TABLE detalles_venta
ADD COLUMN precio_total DECIMAL(12,2) 
    GENERATED ALWAYS AS (
        (precio_unitario - descuento_unitario + impuesto_unitario) * cantidad
    ) STORED;

CREATE INDEX idx_detalles_venta_venta ON detalles_venta(venta_id);
CREATE INDEX idx_detalles_venta_variante ON detalles_venta(variante_id);

-- =============================================
-- TABLA: Pedidos_Compra (a proveedores)
-- =============================================
CREATE TABLE pedidos_compra (
    pedido_id SERIAL PRIMARY KEY,
    codigo_pedido VARCHAR(50) UNIQUE NOT NULL,
    proveedor_id INT NOT NULL REFERENCES proveedores(proveedor_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_pedido DATE DEFAULT CURRENT_DATE,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    estado VARCHAR(20) DEFAULT 'Pendiente' 
        CHECK (estado IN ('Pendiente', 'Enviado', 'Recibido', 'Cancelado', 'Parcial')),
    subtotal DECIMAL(12,2) DEFAULT 0,
    iva DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) DEFAULT 0,
    metodo_pago VARCHAR(20) DEFAULT 'Crédito 30 días' 
        CHECK (metodo_pago IN ('Contado', 'Crédito 15 días', 'Crédito 30 días', 'Crédito 60 días')),
    condiciones_envio TEXT,
    notas TEXT,
    factura_proveedor VARCHAR(100),
    fecha_factura DATE,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pedidos_proveedor ON pedidos_compra(proveedor_id);
CREATE INDEX idx_pedidos_estado ON pedidos_compra(estado);
CREATE INDEX idx_pedidos_fecha_pedido ON pedidos_compra(fecha_pedido);

-- =============================================
-- TABLA: Detalles_Pedido_Compra
-- =============================================
CREATE TABLE detalles_pedido_compra (
    detalle_pedido_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES pedidos_compra(pedido_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    recibido INT DEFAULT 0
);

-- Campos generados
ALTER TABLE detalles_pedido_compra
ADD COLUMN total_linea DECIMAL(12,2) 
    GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
ADD COLUMN pendiente INT 
    GENERATED ALWAYS AS (cantidad - recibido) STORED;

CREATE INDEX idx_detalles_pedido ON detalles_pedido_compra(pedido_id);
CREATE INDEX idx_detalles_pedido_producto ON detalles_pedido_compra(producto_id);

-- =============================================
-- TABLA: Recepciones_Mercancia
-- =============================================
CREATE TABLE recepciones_mercancia (
    recepcion_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES pedidos_compra(pedido_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    numero_factura VARCHAR(100),
    condiciones TEXT,
    observaciones TEXT,
    estado VARCHAR(20) DEFAULT 'Completa' 
        CHECK (estado IN ('Parcial', 'Completa', 'Rechazada')),
    creado_por INT REFERENCES empleados(empleado_id)
);

CREATE INDEX idx_recepciones_pedido ON recepciones_mercancia(pedido_id);
CREATE INDEX idx_recepciones_fecha ON recepciones_mercancia(fecha_recepcion);

-- =============================================
-- TABLA: Movimientos_Inventario
-- =============================================
CREATE TABLE movimientos_inventario (
    movimiento_id SERIAL PRIMARY KEY,
    variante_id INT NOT NULL REFERENCES variantes_producto(variante_id),
    almacen_id INT NOT NULL REFERENCES almacenes(almacen_id),
    tipo_movimiento VARCHAR(20) NOT NULL 
        CHECK (tipo_movimiento IN ('Entrada', 'Salida', 'Ajuste', 'Transferencia', 'Devolución')),
    cantidad INT NOT NULL,
    cantidad_anterior INT,
    cantidad_nueva INT,
    referencia_id INT,
    tipo_referencia VARCHAR(20) 
        CHECK (tipo_referencia IN ('Venta', 'Compra', 'Ajuste', 'Transferencia', 'Devolución')),
    empleado_id INT REFERENCES empleados(empleado_id),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    costo_unitario DECIMAL(10,2),
    valor_total DECIMAL(12,2)
);

CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento);
CREATE INDEX idx_movimientos_variante ON movimientos_inventario(variante_id);
CREATE INDEX idx_movimientos_tipo ON movimientos_inventario(tipo_movimiento);
CREATE INDEX idx_movimientos_almacen ON movimientos_inventario(almacen_id);

-- =============================================
-- TABLA: Transferencias_Almacen
-- =============================================
CREATE TABLE transferencias_almacen (
    transferencia_id SERIAL PRIMARY KEY,
    codigo_transferencia VARCHAR(50) UNIQUE NOT NULL,
    almacen_origen_id INT NOT NULL REFERENCES almacenes(almacen_id),
    almacen_destino_id INT NOT NULL REFERENCES almacenes(almacen_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_solicitud DATE DEFAULT CURRENT_DATE,
    fecha_envio DATE,
    fecha_recepcion DATE,
    estado VARCHAR(20) DEFAULT 'Pendiente' 
        CHECK (estado IN ('Pendiente', 'Enviado', 'Recibido', 'Cancelado')),
    notas TEXT,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Detalles_Transferencia
-- =============================================
CREATE TABLE detalles_transferencia (
    detalle_transferencia_id SERIAL PRIMARY KEY,
    transferencia_id INT NOT NULL REFERENCES transferencias_almacen(transferencia_id) ON DELETE CASCADE,
    variante_id INT NOT NULL REFERENCES variantes_producto(variante_id),
    cantidad INT NOT NULL,
    cantidad_enviada INT DEFAULT 0,
    cantidad_recibida INT DEFAULT 0
);

-- =============================================
-- TABLA: Ajustes_Inventario
-- =============================================
CREATE TABLE ajustes_inventario (
    ajuste_id SERIAL PRIMARY KEY,
    codigo_ajuste VARCHAR(50) UNIQUE NOT NULL,
    almacen_id INT NOT NULL REFERENCES almacenes(almacen_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_ajuste DATE DEFAULT CURRENT_DATE,
    tipo_ajuste VARCHAR(20) NOT NULL 
        CHECK (tipo_ajuste IN ('Físico', 'Dañado', 'Robo', 'Caducado', 'Donación', 'Muestra')),
    motivo TEXT,
    estado VARCHAR(20) DEFAULT 'Pendiente' 
        CHECK (estado IN ('Pendiente', 'Aprobado', 'Rechazado', 'Completado')),
    aprobado_por INT REFERENCES empleados(empleado_id),
    fecha_aprobacion DATE,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Detalles_Ajuste_Inventario
-- =============================================
CREATE TABLE detalles_ajuste_inventario (
    detalle_ajuste_id SERIAL PRIMARY KEY,
    ajuste_id INT NOT NULL REFERENCES ajustes_inventario(ajuste_id) ON DELETE CASCADE,
    variante_id INT NOT NULL REFERENCES variantes_producto(variante_id),
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    costo_unitario DECIMAL(10,2),
    observaciones TEXT
);

-- Campos generados
ALTER TABLE detalles_ajuste_inventario
ADD COLUMN diferencia INT 
    GENERATED ALWAYS AS (cantidad_nueva - cantidad_anterior) STORED,
ADD COLUMN valor_diferencia DECIMAL(12,2) 
    GENERATED ALWAYS AS ((cantidad_nueva - cantidad_anterior) * costo_unitario) STORED;

-- =============================================
-- TABLA: Devoluciones
-- =============================================
CREATE TABLE devoluciones (
    devolucion_id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL REFERENCES ventas(venta_id),
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    empleado_id INT NOT NULL REFERENCES empleados(empleado_id),
    fecha_devolucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(30) DEFAULT 'Otro' 
        CHECK (motivo IN ('Defectuoso', 'Talla incorrecta', 'Color diferente', 'No le gustó', 'Arrepentimiento', 'Otro')),
    estado VARCHAR(20) DEFAULT 'Solicitada' 
        CHECK (estado IN ('Solicitada', 'Aprobada', 'Rechazada', 'Completada')),
    tipo_reembolso VARCHAR(20) DEFAULT 'Vale' 
        CHECK (tipo_reembolso IN ('Efectivo', 'Tarjeta', 'Vale', 'Cambio')),
    monto_reembolso DECIMAL(12,2),
    notas TEXT,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Detalles_Devolucion
-- =============================================
CREATE TABLE detalles_devolucion (
    detalle_devolucion_id SERIAL PRIMARY KEY,
    devolucion_id INT NOT NULL REFERENCES devoluciones(devolucion_id) ON DELETE CASCADE,
    detalle_venta_id INT NOT NULL REFERENCES detalles_venta(detalle_id),
    cantidad_devuelta INT NOT NULL,
    monto_reembolsado DECIMAL(10,2),
    producto_aceptado BOOLEAN DEFAULT TRUE,
    motivo_rechazo TEXT
);

-- =============================================
-- TABLA: Cupones_Descuento
-- =============================================
CREATE TABLE cupones_descuento (
    cupon_id SERIAL PRIMARY KEY,
    codigo_cupon VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    tipo_descuento VARCHAR(20) DEFAULT 'Porcentaje' 
        CHECK (tipo_descuento IN ('Porcentaje', 'Monto Fijo')),
    valor_descuento DECIMAL(10,2) NOT NULL,
    minimo_compra DECIMAL(10,2) DEFAULT 0,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    usos_maximos INT DEFAULT 1,
    usos_actuales INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    aplica_categorias JSONB,
    excluye_productos JSONB,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cupones_codigo ON cupones_descuento(codigo_cupon);
CREATE INDEX idx_cupones_fechas ON cupones_descuento(fecha_inicio, fecha_fin);
CREATE INDEX idx_cupones_activo ON cupones_descuento(activo);

-- =============================================
-- TABLA: Cupones_Usados
-- =============================================
CREATE TABLE cupones_usados (
    cupon_usado_id SERIAL PRIMARY KEY,
    cupon_id INT NOT NULL REFERENCES cupones_descuento(cupon_id),
    venta_id INT NOT NULL REFERENCES ventas(venta_id),
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    fecha_uso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_descuento_aplicado DECIMAL(10,2),
    UNIQUE(cupon_id, venta_id)
);

-- =============================================
-- TABLA: Programas_Fidelidad
-- =============================================
CREATE TABLE programas_fidelidad (
    programa_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    puntos_por_dolar DECIMAL(5,2) DEFAULT 1.00,
    valor_punto DECIMAL(5,2) DEFAULT 0.10,
    minimo_canje_puntos INT DEFAULT 100,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT TRUE,
    condiciones TEXT,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Transacciones_Puntos
-- =============================================
CREATE TABLE transacciones_puntos (
    transaccion_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    programa_id INT NOT NULL REFERENCES programas_fidelidad(programa_id),
    tipo_transaccion VARCHAR(20) NOT NULL 
        CHECK (tipo_transaccion IN ('Acumulación', 'Canje', 'Ajuste')),
    puntos INT NOT NULL,
    descripcion VARCHAR(255),
    referencia_id INT,
    tipo_referencia VARCHAR(20) 
        CHECK (tipo_referencia IN ('Venta', 'Devolución', 'Promoción')),
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    saldo_anterior INT,
    saldo_nuevo INT
);

CREATE INDEX idx_transacciones_cliente ON transacciones_puntos(cliente_id);
CREATE INDEX idx_transacciones_fecha ON transacciones_puntos(fecha_transaccion);

-- =============================================
-- TABLA: Wishlists
-- =============================================
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    nombre_lista VARCHAR(100) DEFAULT 'Favoritos',
    es_publica BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uk_wishlists_cliente_nombre ON wishlists(cliente_id, nombre_lista);

-- =============================================
-- TABLA: Items_Wishlist
-- =============================================
CREATE TABLE items_wishlist (
    item_wishlist_id SERIAL PRIMARY KEY,
    wishlist_id INT NOT NULL REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    prioridad INT DEFAULT 1,
    UNIQUE(wishlist_id, producto_id)
);

-- =============================================
-- TABLA: Reseñas_Productos
-- =============================================
CREATE TABLE reseñas_productos (
    reseña_id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    titulo VARCHAR(200),
    comentario TEXT,
    aprobada BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_aprobacion DATE,
    aprobada_por INT REFERENCES empleados(empleado_id)
);

CREATE INDEX idx_reseñas_producto ON reseñas_productos(producto_id);
CREATE INDEX idx_reseñas_calificacion ON reseñas_productos(calificacion);
CREATE INDEX idx_reseñas_aprobada ON reseñas_productos(aprobada);

-- =============================================
-- TABLA: Historial_Precios
-- =============================================
CREATE TABLE historial_precios (
    historial_id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(30) DEFAULT 'Otro' 
        CHECK (motivo IN ('Ajuste estacional', 'Cambio costo', 'Promoción', 'Competencia', 'Otro')),
    cambiado_por INT REFERENCES empleados(empleado_id)
);

CREATE INDEX idx_historial_precios_producto_fecha ON historial_precios(producto_id, fecha_cambio);

-- =============================================
-- TABLA: Eventos_Promocionales
-- =============================================
CREATE TABLE eventos_promocionales (
    evento_id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo_evento VARCHAR(20) DEFAULT 'Rebajas' 
        CHECK (tipo_evento IN ('Rebajas', 'Liquidación', 'Lanzamiento', 'Temporada', 'Aniversario')),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    presupuesto DECIMAL(12,2),
    costo_real DECIMAL(12,2),
    impacto_ventas DECIMAL(5,2),
    responsable_id INT REFERENCES empleados(empleado_id),
    estado VARCHAR(20) DEFAULT 'Planificado' 
        CHECK (estado IN ('Planificado', 'En curso', 'Finalizado', 'Cancelado')),
    notas TEXT,
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Productos_Evento
-- =============================================
CREATE TABLE productos_evento (
    producto_evento_id SERIAL PRIMARY KEY,
    evento_id INT NOT NULL REFERENCES eventos_promocionales(evento_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES productos(producto_id),
    descuento_aplicado DECIMAL(5,2),
    precio_promocional DECIMAL(10,2),
    unidades_vendidas INT DEFAULT 0,
    meta_ventas INT
);

-- =============================================
-- TABLA: Tareas
-- =============================================
CREATE TABLE tareas (
    tarea_id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    empleado_asignado INT REFERENCES empleados(empleado_id),
    creado_por INT REFERENCES empleados(empleado_id),
    fecha_creacion DATE DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE,
    fecha_completada DATE,
    estado VARCHAR(20) DEFAULT 'Pendiente' 
        CHECK (estado IN ('Pendiente', 'En progreso', 'Completada', 'Cancelada')),
    prioridad VARCHAR(20) DEFAULT 'Media' 
        CHECK (prioridad IN ('Baja', 'Media', 'Alta', 'Urgente')),
    tipo_tarea VARCHAR(20) DEFAULT 'Administrativa' 
        CHECK (tipo_tarea IN ('Inventario', 'Ventas', 'Cliente', 'Marketing', 'Administrativa')),
    observaciones TEXT
);

CREATE INDEX idx_tareas_estado ON tareas(estado);
CREATE INDEX idx_tareas_prioridad ON tareas(prioridad);
CREATE INDEX idx_tareas_fecha_vencimiento ON tareas(fecha_vencimiento);

-- =============================================
-- TABLA: Sesiones
-- =============================================
CREATE TABLE sesiones (
    sesion_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    token_sesion VARCHAR(255) UNIQUE NOT NULL,
    token_refresh VARCHAR(255),
    dispositivo VARCHAR(255),
    navegador VARCHAR(255),
    sistema_operativo VARCHAR(100),
    ip_address VARCHAR(45),
    ubicacion JSONB,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP,
    activa BOOLEAN DEFAULT TRUE,
    motivo_cierre VARCHAR(255)
);

CREATE INDEX idx_sesiones_token ON sesiones(token_sesion);
CREATE INDEX idx_sesiones_usuario_activa ON sesiones(usuario_id, activa);
CREATE INDEX idx_sesiones_fecha_expiracion ON sesiones(fecha_expiracion);

-- =============================================
-- TABLA: Logs_Autenticacion
-- =============================================
CREATE TABLE logs_autenticacion (
    log_id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuarios(usuario_id) ON DELETE SET NULL,
    email_proporcionado VARCHAR(255),
    accion VARCHAR(30) NOT NULL 
        CHECK (accion IN ('Login', 'Logout', 'Login_Fallido', 'Cambio_Contrasena', 'Reset_Solicitado', 'Cuenta_Bloqueada', '2FA_Verificado')),
    exito BOOLEAN DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    dispositivo VARCHAR(255),
    ubicacion_aproximada VARCHAR(255),
    detalles TEXT,
    fecha_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_logs_fecha_usuario ON logs_autenticacion(fecha_log, usuario_id);
CREATE INDEX idx_logs_accion ON logs_autenticacion(accion);
CREATE INDEX idx_logs_exito ON logs_autenticacion(exito);

-- =============================================
-- TABLA: Politicas_Seguridad
-- =============================================
CREATE TABLE politicas_seguridad (
    politica_id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    -- Configuración contraseñas
    longitud_minima INT DEFAULT 8,
    requiere_mayusculas BOOLEAN DEFAULT TRUE,
    requiere_minusculas BOOLEAN DEFAULT TRUE,
    requiere_numeros BOOLEAN DEFAULT TRUE,
    requiere_simbolos BOOLEAN DEFAULT FALSE,
    expiracion_dias INT DEFAULT 90,
    historico_contrasenas INT DEFAULT 5,
    -- Configuración sesiones
    tiempo_inactividad_minutos INT DEFAULT 30,
    maximo_sesiones_simultaneas INT DEFAULT 3,
    -- Configuración intentos
    max_intentos_login INT DEFAULT 5,
    bloqueo_minutos INT DEFAULT 30,
    -- 2FA
    requiere_2fa BOOLEAN DEFAULT FALSE,
    metodos_2fa JSONB,
    -- Otras
    fuerza_contrasena VARCHAR(20) DEFAULT 'Media' 
        CHECK (fuerza_contrasena IN ('Baja', 'Media', 'Alta', 'Muy_Alta')),
    aplica_desde DATE NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    creado_por INT REFERENCES usuarios(usuario_id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLA: Historial_Contrasenas
-- =============================================
CREATE TABLE historial_contrasenas (
    historial_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cambiado_por INT REFERENCES usuarios(usuario_id),
    ip_address VARCHAR(45)
);

CREATE INDEX idx_historial_contrasenas_usuario ON historial_contrasenas(usuario_id);

-- =============================================
-- TABLA: Notificaciones
-- =============================================
CREATE TABLE notificaciones (
    notificacion_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(20) DEFAULT 'Sistema' 
        CHECK (tipo IN ('Sistema', 'Venta', 'Inventario', 'Cliente', 'Promocion', 'Alerta')),
    prioridad VARCHAR(20) DEFAULT 'Media' 
        CHECK (prioridad IN ('Baja', 'Media', 'Alta', 'Urgente')),
    leida BOOLEAN DEFAULT FALSE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_lectura TIMESTAMP,
    accion_url VARCHAR(500),
    datos_adicionales JSONB
);

CREATE INDEX idx_notificaciones_usuario_leida ON notificaciones(usuario_id, leida);
CREATE INDEX idx_notificaciones_fecha_envio ON notificaciones(fecha_envio);

-- =============================================
-- TABLA: Auditorias
-- =============================================
CREATE TABLE auditorias (
    auditoria_id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(100),
    accion VARCHAR(10) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
    id_registro INT,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    realizado_por INT REFERENCES empleados(empleado_id),
    fecha_auditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

CREATE INDEX idx_auditorias_tabla ON auditorias(tabla_afectada);
CREATE INDEX idx_auditorias_fecha ON auditorias(fecha_auditoria);
CREATE INDEX idx_auditorias_accion ON auditorias(accion);

-- =============================================
-- TABLA: Configuraciones_Tienda
-- =============================================
CREATE TABLE configuraciones_tienda (
    config_id SERIAL PRIMARY KEY,
    empresa_id INT REFERENCES empresas(empresa_id),
    clave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo VARCHAR(50) DEFAULT 'text',
    categoria VARCHAR(50),
    descripcion TEXT,
    editable BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_por INT REFERENCES empleados(empleado_id),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uk_configuraciones_empresa_clave ON configuraciones_tienda(empresa_id, clave);