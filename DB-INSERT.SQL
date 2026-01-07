-- =============================================
-- SCRIPT 3: INSERTAR DATOS DE EJEMPLO
-- =============================================

-- Insertar empresa principal
INSERT INTO empresas (nombre, rfc, telefono, email, calle, ciudad, estado, pais) 
VALUES 
('Moda Express SA de CV', 'MEX123456ABC', '55-1234-5678', 'info@modaexpress.com', 'Av. Insurgentes Sur 1234', 'Ciudad de México', 'CDMX', 'México'),
('Tienda de Ropa Elegante', 'TRE987654XYZ', '55-8765-4321', 'ventas@ropaelegante.com', 'Calle Reforma 567', 'Guadalajara', 'Jalisco', 'México')
RETURNING empresa_id;

-- Insertar sucursales
INSERT INTO sucursales (empresa_id, nombre, codigo_sucursal, tipo, calle, ciudad, estado, telefono, email) 
VALUES 
(5, 'Moda Express Centro', 'SUC-001', 'Tienda', 'Av. Insurgentes Sur 1234', 'Ciudad de México', 'CDMX', '55-1234-5678', 'centro@modaexpress.com'),
(6, 'Moda Express Satélite', 'SUC-002', 'Tienda', 'Circuito Médicos 45', 'Naucalpan', 'Estado de México', '55-2345-6789', 'satelite@modaexpress.com'),
(5, 'Ropa Elegante Centro', 'SUC-101', 'Tienda', 'Calle Reforma 567', 'Guadalajara', 'Jalisco', '33-1234-5678', 'centro@ropaelegante.com')
RETURNING sucursal_id;

-- Insertar almacenes
INSERT INTO almacenes (sucursal_id, nombre, direccion, ciudad, telefono, responsable, capacidad_total, tipo) 
VALUES 
(7, 'Almacén Central CDMX', 'Av. Insurgentes Sur 1234', 'Ciudad de México', '55-1234-5678', 'Juan Pérez', 10000, 'Principal'),
(8, 'Almacén Satélite', 'Circuito Médicos 45', 'Naucalpan', '55-2345-6789', 'María García', 5000, 'Sucursal'),
(9, 'Almacén Guadalajara', 'Calle Reforma 567', 'Guadalajara', '33-1234-5678', 'Carlos López', 8000, 'Principal')
RETURNING almacen_id;

-- Actualizar sucursales con almacén principal
UPDATE sucursales SET almacen_principal_id = 1 WHERE sucursal_id = 1;
UPDATE sucursales SET almacen_principal_id = 2 WHERE sucursal_id = 2;
UPDATE sucursales SET almacen_principal_id = 3 WHERE sucursal_id = 3;

-- Insertar categorías principales
INSERT INTO categorias (nombre, descripcion, nivel) VALUES
('Ropa de Hombre', 'Ropa para hombres', 1),
('Ropa de Mujer', 'Ropa para mujeres', 1),
('Ropa Infantil', 'Ropa para niños y niñas', 1),
('Accesorios', 'Complementos y accesorios', 1),
('Calzado', 'Zapatos y tenis para toda la familia', 1);

-- Subcategorías para Hombre
INSERT INTO categorias (nombre, descripcion, categoria_padre_id, nivel) VALUES
('Camisas', 'Camisas formales e informales', 1, 2),
('Pantalones', 'Pantalones de vestir y casual', 1, 2),
('Playeras', 'Playeras y polos', 1, 2),
('Suéteres', 'Suéteres y sudaderas', 1, 2),
('Jeans', 'Pantalones de mezclilla', 1, 2),
('Ropa Interior', 'Calzoncillos y calcetines', 1, 2);

-- Subcategorías para Mujer
INSERT INTO categorias (nombre, descripcion, categoria_padre_id, nivel) VALUES
('Blusas', 'Blusas y tops', 2, 2),
('Vestidos', 'Vestidos formales e informales', 2, 2),
('Faldas', 'Faldas de diferentes estilos', 2, 2),
('Pantalones Mujer', 'Pantalones para mujer', 2, 2),
('Ropa Deportiva', 'Ropa para hacer ejercicio', 2, 2),
('Lencería', 'Ropa interior femenina', 2, 2);

-- Subcategorías para Calzado
INSERT INTO categorias (nombre, descripcion, categoria_padre_id, nivel) VALUES
('Tenis', 'Zapatos deportivos', 5, 2),
('Zapatos Formales', 'Zapatos de vestir', 5, 2),
('Sandalias', 'Sandalias para hombre y mujer', 5, 2),
('Botas', 'Botas de diferentes estilos', 5, 2);

-- Insertar marcas
INSERT INTO marcas (nombre, descripcion, pais_origen, sitio_web, contacto_email) VALUES
('Zara', 'Moda rápida española líder en tendencias', 'España', 'www.zara.com', 'contact@zara.com'),
('Nike', 'Ropa y calzado deportivo de alta calidad', 'Estados Unidos', 'www.nike.com', 'info@nike.com'),
('Levi''s', 'Jeans y ropa casual icónica', 'Estados Unidos', 'www.levi.com', 'contact@levi.com'),
('Adidas', 'Ropa deportiva y estilo de vida', 'Alemania', 'www.adidas.com', 'info@adidas.com'),
('Tommy Hilfiger', 'Ropa casual premium americana', 'Estados Unidos', 'www.tommy.com', 'contact@tommy.com'),
('H&M', 'Moda rápida a precios accesibles', 'Suecia', 'www.hm.com', 'info@hm.com'),
('Calvin Klein', 'Ropa interior y moda contemporánea', 'Estados Unidos', 'www.calvinklein.com', 'contact@ck.com'),
('Under Armour', 'Ropa deportiva de alto rendimiento', 'Estados Unidos', 'www.underarmour.com', 'info@ua.com'),
('Puma', 'Ropa y calzado deportivo', 'Alemania', 'www.puma.com', 'contact@puma.com'),
('Columbia', 'Ropa para exteriores y deportes', 'Estados Unidos', 'www.columbia.com', 'info@columbia.com');

-- Insertar proveedores
INSERT INTO proveedores (nombre_empresa, nombre_contacto, telefono, email, direccion, ciudad, pais, rfc, tipo_proveedor, calificacion) VALUES
('Distribuidora de Moda SA', 'Roberto Mendoza', '55-1111-2222', 'roberto@distmoda.com', 'Av. Industrial 456', 'Ciudad de México', 'México', 'DMS123456ABC', 'Distribuidor', 4.5),
('Textiles Mexicanos', 'Sofía Ramírez', '55-3333-4444', 'sofia@textilesmx.com', 'Calzada de Tlalpan 789', 'Ciudad de México', 'México', 'TMX789123DEF', 'Fabricante', 4.8),
('Importaciones Internacionales', 'Luis Fernández', '55-5555-6666', 'luis@importint.com', 'Blvd. Miguel de la Madrid 321', 'Guadalajara', 'México', 'IIN456789GHI', 'Internacional', 4.2),
('Mayorista de Ropa', 'Ana Torres', '55-7777-8888', 'ana@mayoristaropa.com', 'Calle Morelos 654', 'Monterrey', 'México', 'MRP987654JKL', 'Mayorista', 4.0),
('Proveedora Deportiva', 'Carlos Ruiz', '55-9999-0000', 'carlos@prodeportes.com', 'Av. Universidad 987', 'Puebla', 'México', 'PDP654321MNO', 'Distribuidor', 4.7);

-- Insertar productos (ropa de hombre)
INSERT INTO productos (sku, nombre, descripcion, categoria_id, marca_id, genero, temporada, material_principal, cuidados, precio_compra, precio_venta, stock_minimo, stock_maximo) VALUES
('PROD-001', 'Camisa Oxford Slim Fit', 'Camisa de vestir en algodón oxford, corte slim fit, ideal para oficina', 3, 3, 'Hombre', 'Todo el año', 'Algodón 100%', 'Lavado a máquina en agua fría, no usar blanqueador', 350.00, 799.00, 10, 100),
('PROD-002', 'Jeans 501 Original', 'Jeans clásicos Levi''s 501, corte recto, color azul medio', 3, 3, 'Hombre', 'Todo el año', 'Mezclilla 100% algodón', 'Lavar al revés en agua fría, secar al aire', 450.00, 1299.00, 15, 150),
('PROD-003', 'Polo Básico Algodón', 'Polo de algodón pima, cuello ribeteado, corte regular', 3, 6, 'Hombre', 'Verano', 'Algodón Pima 100%', 'Lavado a máquina en agua tibia, secar a baja temperatura', 180.00, 399.00, 20, 200),
('PROD-004', 'Suéter de Lana Merino', 'Suéter de lana merino, cuello redondo, ideal para invierno', 3, 5, 'Hombre', 'Invierno', 'Lana Merino 100%', 'Lavado a mano en agua fría, secar plano', 420.00, 899.00, 8, 80),
('PROD-005', 'Chamarra Denim', 'Chamarra de mezclilla, forrada, estilo tipo trucker', 3, 3, 'Hombre', 'Otoño', 'Mezclilla', 'Lavar en seco profesionalmente', 550.00, 1499.00, 12, 120),

-- Ropa de mujer
('PROD-006', 'Vestido Largo Floral', 'Vestido largo con estampado floral, corte sirena, para ocasiones especiales', 4, 1, 'Mujer', 'Primavera', 'Poliéster y elastano', 'Lavado a mano, no retorcer', 320.00, 899.00, 10, 100),
('PROD-007', 'Blusa Seda Natural', 'Blusa de seda natural, cuello barco, mangas largas', 4, 7, 'Mujer', 'Todo el año', 'Seda 100%', 'Lavado en seco solamente', 280.00, 699.00, 15, 150),
('PROD-008', 'Falda Plisada Midi', 'Falda plisada midi, cintura alta, material fluido', 4, 1, 'Mujer', 'Verano', 'Poliéster', 'Lavado a máquina en ciclo suave', 190.00, 499.00, 18, 180),
('PROD-009', 'Leggings Deportivos', 'Leggings para yoga y ejercicio, alta compresión', 4, 8, 'Mujer', 'Todo el año', 'Nylon y Spandex', 'Lavado a máquina en agua fría', 220.00, 599.00, 25, 250),
('PROD-010', 'Top Deportivo Sin Mangas', 'Top deportivo para entrenamiento, soporte medio', 4, 2, 'Mujer', 'Todo el año', 'Poliester y elastano', 'Lavado a máquina, secar al aire', 150.00, 349.00, 30, 300),

-- Calzado
('PROD-011', 'Tenis Running Nike Air', 'Tenis para running con tecnología Air, amortiguación superior', 5, 2, 'Unisex', 'Todo el año', 'Malla y sintéticos', 'Limpiar con paño húmedo', 650.00, 1799.00, 12, 120),
('PROD-012', 'Zapatos Formales Oxford', 'Zapatos de vestir Oxford, piel genuina, suela de cuero', 5, 5, 'Hombre', 'Todo el año', 'Piel de becerro', 'Limpiar con crema para calzado', 480.00, 1299.00, 10, 100),
('PROD-013', 'Sandalias Gladiador', 'Sandalias estilo gladiador, correas ajustables, tacón bajo', 5, 1, 'Mujer', 'Verano', 'Cuero sintético', 'Limpiar con paño seco', 210.00, 549.00, 20, 200),
('PROD-014', 'Botas de Cuero', 'Botas de cuero para hombre, estilo casual', 5, 3, 'Hombre', 'Invierno', 'Cuero genuino', 'Aplicar crema protectora regularmente', 720.00, 1999.00, 8, 80),

-- Productos en promoción
('PROD-015', 'Chamarra Impermeable', 'Chamara impermeable con capucha, ideal para lluvia', 5, 10, 'Unisex', 'Invierno', 'Nylon impermeable', 'Lavar a máquina en agua fría', 380.00, 899.00, 15, 150),
('PROD-016', 'Conjunto Deportivo Adidas', 'Conjunto deportivo completo: sudadera y pants', 5, 4, 'Unisex', 'Todo el año', 'Algodón y poliéster', 'Lavado a máquina, no usar suavizante', 320.00, 799.00, 18, 180),

-- Accesorios
('PROD-017', 'Cinturón de Cuero', 'Cinturón de cuero genuino, hebilla metálica', 4, 7, 'Hombre', 'Todo el año', 'Cuero', 'Limpiar con paño húmedo', 85.00, 249.00, 25, 250),
('PROD-018', 'Bolso Tote Grande', 'Bolso tote de tela resistente, múltiples compartimentos', 4, 1, 'Mujer', 'Todo el año', 'Lona de algodón', 'Limpiar con espuma especial', 120.00, 349.00, 20, 200),
('PROD-019', 'Gorra Baseball', 'Gorra ajustable con logo bordado', 4, 2, 'Unisex', 'Verano', 'Algodón y poliéster', 'Lavado a mano', 60.00, 199.00, 30, 300),
('PROD-020', 'Bufanda de Lana', 'Bufanda larga de lana, ideal para invierno', 4, 5, 'Unisex', 'Invierno', 'Lana acrílica', 'Lavado a mano en agua fría', 75.00, 229.00, 35, 350);

-- Actualizar algunos productos para promoción
UPDATE productos SET 
    es_promocion = TRUE,
    porcentaje_descuento = 20.00,
    precio_promocion = precio_venta * 0.80,
    fecha_inicio_promocion = CURRENT_DATE,
    fecha_fin_promocion = CURRENT_DATE + INTERVAL '30 days'
WHERE sku IN ('PROD-015', 'PROD-016', 'PROD-019', 'PROD-020');

-- Insertar variantes de productos (tallas y colores)
INSERT INTO variantes_producto (producto_id, talla, color_nombre, color_hex, stock_actual, codigo_barras) VALUES
-- Camisa Oxford (PROD-001)
(1, 'S', 'Blanco', '#FFFFFF', 25, '8801234560011'),
(1, 'M', 'Blanco', '#FFFFFF', 30, '8801234560012'),
(1, 'L', 'Blanco', '#FFFFFF', 28, '8801234560013'),
(1, 'S', 'Azul', '#0000FF', 20, '8801234560014'),
(1, 'M', 'Azul', '#0000FF', 22, '8801234560015'),
(1, 'L', 'Azul', '#0000FF', 18, '8801234560016'),

-- Jeans 501 (PROD-002)
(2, '30x32', 'Azul Medio', '#1E90FF', 15, '8801234560021'),
(2, '32x32', 'Azul Medio', '#1E90FF', 20, '8801234560022'),
(2, '34x32', 'Azul Medio', '#1E90FF', 18, '8801234560023'),
(2, '30x32', 'Azul Oscuro', '#00008B', 12, '8801234560024'),
(2, '32x32', 'Azul Oscuro', '#00008B', 16, '8801234560025'),
(2, '34x32', 'Azul Oscuro', '#00008B', 14, '8801234560026'),

-- Polo Básico (PROD-003)
(3, 'S', 'Negro', '#000000', 40, '8801234560031'),
(3, 'M', 'Negro', '#000000', 45, '8801234560032'),
(3, 'L', 'Negro', '#000000', 42, '8801234560033'),
(3, 'S', 'Rojo', '#FF0000', 35, '8801234560034'),
(3, 'M', 'Rojo', '#FF0000', 38, '8801234560035'),
(3, 'L', 'Rojo', '#FF0000', 36, '8801234560036'),
(3, 'S', 'Azul Marino', '#000080', 30, '8801234560037'),
(3, 'M', 'Azul Marino', '#000080', 32, '8801234560038'),
(3, 'L', 'Azul Marino', '#000080', 30, '8801234560039'),

-- Vestido Floral (PROD-006)
(6, 'XS', 'Multicolor', '#FF69B4', 8, '8801234560061'),
(6, 'S', 'Multicolor', '#FF69B4', 10, '8801234560062'),
(6, 'M', 'Multicolor', '#FF69B4', 12, '8801234560063'),
(6, 'L', 'Multicolor', '#FF69B4', 10, '8801234560064'),
(6, 'S', 'Blanco/Rosa', '#FFC0CB', 6, '8801234560065'),
(6, 'M', 'Blanco/Rosa', '#FFC0CB', 8, '8801234560066'),
(6, 'L', 'Blanco/Rosa', '#FFC0CB', 7, '8801234560067'),

-- Tenis Running (PROD-011)
(11, '7', 'Negro/Rojo', '#000000', 15, '8801234560111'),
(11, '8', 'Negro/Rojo', '#000000', 18, '8801234560112'),
(11, '9', 'Negro/Rojo', '#000000', 20, '8801234560113'),
(11, '10', 'Negro/Rojo', '#000000', 16, '8801234560114'),
(11, '8', 'Blanco/Azul', '#FFFFFF', 12, '8801234560115'),
(11, '9', 'Blanco/Azul', '#FFFFFF', 14, '8801234560116'),
(11, '10', 'Blanco/Azul', '#FFFFFF', 10, '8801234560117'),

-- Bolso Tote (PROD-018) - sin tallas, solo colores
(18, 'Única', 'Beige', '#F5F5DC', 25, '8801234560181'),
(18, 'Única', 'Negro', '#000000', 30, '8801234560182'),
(18, 'Única', 'Azul Marino', '#000080', 22, '8801234560183'),

-- Gorra Baseball (PROD-019)
(19, 'Ajustable', 'Negro', '#000000', 40, '8801234560191'),
(19, 'Ajustable', 'Blanco', '#FFFFFF', 35, '8801234560192'),
(19, 'Ajustable', 'Rojo', '#FF0000', 30, '8801234560193'),
(19, 'Ajustable', 'Azul', '#0000FF', 25, '8801234560194');

-- Insertar inventario en almacenes
INSERT INTO inventario (variante_id, almacen_id, cantidad, ubicacion) 
SELECT v.variante_id, 1, v.stock_actual, 'Rack ' || CEIL(RANDOM() * 10)::VARCHAR
FROM variantes_producto v
WHERE v.stock_actual > 0;

-- Insertar también en otros almacenes
INSERT INTO inventario (variante_id, almacen_id, cantidad, ubicacion) 
SELECT v.variante_id, 2, FLOOR(v.stock_actual * 0.5), 'Rack ' || CEIL(RANDOM() * 5)::VARCHAR
FROM variantes_producto v
WHERE v.stock_actual > 10 AND RANDOM() > 0.5;

INSERT INTO inventario (variante_id, almacen_id, cantidad, ubicacion) 
SELECT v.variante_id, 3, FLOOR(v.stock_actual * 0.3), 'Rack ' || CEIL(RANDOM() * 8)::VARCHAR
FROM variantes_producto v
WHERE v.stock_actual > 15 AND RANDOM() > 0.7;

-- Insertar empleados
INSERT INTO empleados (sucursal_id, codigo_empleado, nombre, apellido, email, telefono, fecha_contratacion, puesto, departamento, salario_base, comision_porcentaje) VALUES
(1, 'EMP-001', 'Juan Carlos', 'González', 'juan.gonzalez@modaexpress.com', '55-1111-2222', '2020-03-15', 'Gerente', 'Administración', 25000.00, 0.00),
(1, 'EMP-002', 'Ana María', 'López', 'ana.lopez@modaexpress.com', '55-2222-3333', '2021-06-10', 'Supervisor', 'Ventas', 18000.00, 2.5),
(1, 'EMP-003', 'Carlos', 'Martínez', 'carlos.martinez@modaexpress.com', '55-3333-4444', '2022-01-20', 'Vendedor', 'Ventas', 12000.00, 3.0),
(1, 'EMP-004', 'María Fernanda', 'Rodríguez', 'maria.rodriguez@modaexpress.com', '55-4444-5555', '2022-03-05', 'Cajero', 'Ventas', 11000.00, 1.5),
(1, 'EMP-005', 'Pedro', 'Sánchez', 'pedro.sanchez@modaexpress.com', '55-5555-6666', '2021-11-15', 'Almacenista', 'Almacén', 10500.00, 0.0),
(2, 'EMP-006', 'Laura', 'García', 'laura.garcia@modaexpress.com', '55-6666-7777', '2022-02-28', 'Gerente', 'Administración', 24000.00, 0.0),
(2, 'EMP-007', 'Roberto', 'Hernández', 'roberto.hernandez@modaexpress.com', '55-7777-8888', '2022-05-10', 'Vendedor', 'Ventas', 11500.00, 3.0),
(2, 'EMP-008', 'Sofía', 'Ramírez', 'sofia.ramirez@modaexpress.com', '55-8888-9999', '2022-07-22', 'Vendedor', 'Ventas', 11500.00, 3.0),
(3, 'EMP-009', 'Miguel', 'Torres', 'miguel.torres@ropaelegante.com', '33-1111-2222', '2021-09-12', 'Gerente', 'Administración', 23000.00, 0.0),
(3, 'EMP-010', 'Patricia', 'Díaz', 'patricia.diaz@ropaelegante.com', '33-2222-3333', '2022-04-18', 'Supervisor', 'Ventas', 17000.00, 2.5);

-- Insertar clientes
INSERT INTO clientes (codigo_cliente, tipo_cliente, nombre, apellido, email, telefono, fecha_nacimiento, genero, direccion, ciudad, estado, segmento, puntos_fidelidad, total_compras, acepta_marketing) VALUES
('CLI-001', 'VIP', 'Alejandro', 'Mendoza', 'alejandro.mendoza@gmail.com', '55-1234-5678', '1985-05-15', 'M', 'Calle Rosa 123, Col. Del Valle', 'Ciudad de México', 'CDMX', 'Leal', 1250, 25800.00, TRUE),
('CLI-002', 'Minorista', 'Fernanda', 'Castillo', 'fernanda.castillo@hotmail.com', '55-2345-6789', '1992-08-22', 'F', 'Av. Revolución 456, Col. Nápoles', 'Ciudad de México', 'CDMX', 'Frecuente', 780, 15200.00, TRUE),
('CLI-003', 'Mayorista', 'Roberto Carlos', 'Silva', 'rc.silva@empresa.com', '55-3456-7890', '1978-11-30', 'M', 'Blvd. Manuel Ávila Camacho 789', 'Naucalpan', 'Estado de México', 'Leal', 2100, 42150.00, TRUE),
('CLI-004', 'Minorista', 'Gabriela', 'Ortega', 'gaby.ortega@yahoo.com', '55-4567-8901', '1995-03-10', 'F', 'Calle Pirul 45, Col. Las Águilas', 'Ciudad de México', 'CDMX', 'Ocasional', 320, 6800.00, TRUE),
('CLI-005', 'Empresarial', 'Empresas Unidas SA', 'Contacto General', 'compras@empresasunidas.com', '55-5678-9012', NULL, 'M', 'Paseo de la Reforma 1250', 'Ciudad de México', 'CDMX', 'Leal', 4500, 89500.00, FALSE),
('CLI-006', 'Minorista', 'Luis Alberto', 'Vargas', 'luis.vargas@outlook.com', '55-6789-0123', '1988-07-18', 'M', 'Calle Naranjo 78, Col. Roma Norte', 'Ciudad de México', 'CDMX', 'Nuevo', 50, 1200.00, TRUE),
('CLI-007', 'VIP', 'Carolina', 'Ríos', 'caro.rios@gmail.com', '55-7890-1234', '1990-12-05', 'F', 'Av. Insurgentes Sur 2345', 'Ciudad de México', 'CDMX', 'Frecuente', 920, 18400.00, TRUE),
('CLI-008', 'Minorista', 'Javier', 'Morales', 'javier.morales@gmail.com', '55-8901-2345', '1982-09-25', 'M', 'Calle Manzana 12, Col. Condesa', 'Ciudad de México', 'CDMX', 'Ocasional', 180, 4500.00, TRUE),
('CLI-009', 'Mayorista', 'Boutique Elegante', 'Ana Karen', 'ana@boutiqueelegante.com', '33-1234-5678', NULL, 'F', 'Calle López Cotilla 567', 'Guadalajara', 'Jalisco', 'Frecuente', 1500, 30500.00, TRUE),
('CLI-010', 'Minorista', 'Diego', 'Cervantes', 'diego.cervantes@gmail.com', '33-2345-6789', '1993-06-14', 'M', 'Av. Chapultepec 890', 'Guadalajara', 'Jalisco', 'Nuevo', 30, 800.00, TRUE);

-- Insertar usuarios (autenticación)
INSERT INTO usuarios (empleado_id, cliente_id, email, username, contrasena_hash, tipo_usuario, provider, email_verificado, activo) VALUES
-- Usuarios empleados (con contraseña encriptada: Password123!)
(1, NULL, 'juan.gonzalez@modaexpress.com', 'jgonzalez', crypt('Password123!', gen_salt('bf')), 'Empleado', 'local', TRUE, TRUE),
(2, NULL, 'ana.lopez@modaexpress.com', 'alopez', crypt('Password123!', gen_salt('bf')), 'Empleado', 'local', TRUE, TRUE),
(3, NULL, 'carlos.martinez@modaexpress.com', 'cmartinez', crypt('Password123!', gen_salt('bf')), 'Empleado', 'local', TRUE, TRUE),
(6, NULL, 'laura.garcia@modaexpress.com', 'lgarcia', crypt('Password123!', gen_salt('bf')), 'Empleado', 'local', TRUE, TRUE),
(9, NULL, 'miguel.torres@ropaelegante.com', 'mtorres', crypt('Password123!', gen_salt('bf')), 'Empleado', 'local', TRUE, TRUE),

-- Usuarios clientes con login tradicional
(NULL, 1, 'alejandro.mendoza@gmail.com', 'amendoza', crypt('Cliente123!', gen_salt('bf')), 'Cliente', 'local', TRUE, TRUE),
(NULL, 2, 'fernanda.castillo@hotmail.com', 'fcastillo', crypt('Cliente123!', gen_salt('bf')), 'Cliente', 'local', TRUE, TRUE),
(NULL, 3, 'rc.silva@empresa.com', 'rsilva', crypt('Empresa123!', gen_salt('bf')), 'Cliente', 'local', TRUE, TRUE),

-- Usuarios clientes con Google OAuth (simulado)
(NULL, 4, 'gaby.ortega@yahoo.com', NULL, NULL, 'Cliente', 'google', TRUE, TRUE),
(NULL, 7, 'caro.rios@gmail.com', NULL, NULL, 'Cliente', 'google', TRUE, TRUE);

-- Actualizar usuarios con Google ID simulado
UPDATE usuarios SET google_id = 'google_' || cliente_id || '_' || md5(email) 
WHERE provider = 'google' AND cliente_id IS NOT NULL;

-- Insertar roles del sistema
INSERT INTO roles (nombre, descripcion, nivel, tipo) VALUES
('Super Administrador', 'Acceso completo al sistema', 100, 'Sistema'),
('Administrador Tienda', 'Administrador de tienda física', 80, 'Negocio'),
('Gerente de Ventas', 'Gerente del departamento de ventas', 70, 'Negocio'),
('Vendedor', 'Personal de ventas en piso', 50, 'Negocio'),
('Almacenista', 'Personal de almacén e inventario', 40, 'Negocio'),
('Cliente Regular', 'Cliente estándar', 10, 'Personalizado'),
('Cliente VIP', 'Cliente con privilegios especiales', 15, 'Personalizado');

-- Insertar permisos
INSERT INTO permisos (codigo, nombre, descripcion, modulo, nivel) VALUES
-- Módulo Ventas
('VENTAS_CREAR', 'Crear ventas', 'Permite crear nuevas ventas', 'Ventas', 'Escritura'),
('VENTAS_VER', 'Ver ventas', 'Permite ver el listado de ventas', 'Ventas', 'Lectura'),
('VENTAS_EDITAR', 'Editar ventas', 'Permite editar ventas existentes', 'Ventas', 'Escritura'),
('VENTAS_ANULAR', 'Anular ventas', 'Permite anular ventas', 'Ventas', 'Eliminacion'),
('VENTAS_REPORTES', 'Reportes de ventas', 'Acceso a reportes de ventas', 'Ventas', 'Lectura'),
-- Módulo Inventario
('INV_VER', 'Ver inventario', 'Ver niveles de inventario', 'Inventario', 'Lectura'),
('INV_EDITAR', 'Editar inventario', 'Modificar niveles de inventario', 'Inventario', 'Escritura'),
('INV_AJUSTAR', 'Ajustar inventario', 'Realizar ajustes de inventario', 'Inventario', 'Escritura'),
-- Módulo Clientes
('CLIENTES_VER', 'Ver clientes', 'Ver información de clientes', 'Clientes', 'Lectura'),
('CLIENTES_EDITAR', 'Editar clientes', 'Modificar información de clientes', 'Clientes', 'Escritura'),
-- Módulo Productos
('PRODUCTOS_VER', 'Ver productos', 'Ver catálogo de productos', 'Ventas', 'Lectura'),
('PRODUCTOS_EDITAR', 'Editar productos', 'Modificar productos', 'Ventas', 'Escritura'),
-- Módulo Configuración
('CONFIG_VER', 'Ver configuración', 'Ver configuración del sistema', 'Configuracion', 'Lectura'),
('CONFIG_EDITAR', 'Editar configuración', 'Modificar configuración del sistema', 'Configuracion', 'Administracion'),
-- Módulo Empleados
('EMPLEADOS_VER', 'Ver empleados', 'Ver información de empleados', 'Empleados', 'Lectura'),
('EMPLEADOS_EDITAR', 'Editar empleados', 'Modificar información de empleados', 'Empleados', 'Escritura');

-- Asignar permisos a roles
-- Super Administrador (todos los permisos)
INSERT INTO roles_permisos (rol_id, permiso_id)
SELECT 1, permiso_id FROM permisos;

-- Administrador Tienda
INSERT INTO roles_permisos (rol_id, permiso_id)
SELECT 2, permiso_id FROM permisos 
WHERE codigo IN ('VENTAS_CREAR', 'VENTAS_VER', 'VENTAS_EDITAR', 'VENTAS_ANULAR', 'VENTAS_REPORTES',
                 'INV_VER', 'INV_EDITAR', 'INV_AJUSTAR', 'CLIENTES_VER', 'CLIENTES_EDITAR',
                 'PRODUCTOS_VER', 'PRODUCTOS_EDITAR', 'EMPLEADOS_VER');

-- Gerente de Ventas
INSERT INTO roles_permisos (rol_id, permiso_id)
SELECT 3, permiso_id FROM permisos 
WHERE codigo IN ('VENTAS_CREAR', 'VENTAS_VER', 'VENTAS_EDITAR', 'VENTAS_REPORTES',
                 'INV_VER', 'CLIENTES_VER', 'CLIENTES_EDITAR', 'PRODUCTOS_VER');

-- Vendedor
INSERT INTO roles_permisos (rol_id, permiso_id)
SELECT 4, permiso_id FROM permisos 
WHERE codigo IN ('VENTAS_CREAR', 'VENTAS_VER', 'CLIENTES_VER', 'PRODUCTOS_VER');

-- Almacenista
INSERT INTO roles_permisos (rol_id, permiso_id)
SELECT 5, permiso_id FROM permisos 
WHERE codigo IN ('INV_VER', 'INV_EDITAR', 'INV_AJUSTAR', 'PRODUCTOS_VER');

-- Asignar roles a usuarios
-- Empleados
INSERT INTO usuarios_roles (usuario_id, rol_id, activo) VALUES
(1, 1, TRUE),  -- Juan: Super Administrador
(2, 2, TRUE),  -- Ana: Administrador Tienda
(3, 4, TRUE),  -- Carlos: Vendedor
(4, 2, TRUE),  -- Laura: Administrador Tienda
(5, 2, TRUE);  -- Miguel: Administrador Tienda

-- Clientes
INSERT INTO usuarios_roles (usuario_id, rol_id, activo) VALUES
(6, 6, TRUE),  -- Alejandro: Cliente Regular
(7, 6, TRUE),  -- Fernanda: Cliente Regular
(8, 6, TRUE),  -- Roberto: Cliente Regular
(9, 7, TRUE),  -- Gabriela: Cliente VIP (Google)
(10, 7, TRUE); -- Carolina: Cliente VIP (Google)

-- Insertar ventas de ejemplo
INSERT INTO ventas (sucursal_id, codigo_venta, cliente_id, empleado_id, tipo_venta, estado_venta, subtotal, descuento_total, impuesto_total, total, metodo_pago) VALUES
(1, 'VTA-2023001', 1, 3, 'Presencial', 'Pagada', 2598.00, 0.00, 415.68, 3013.68, 'Tarjeta Crédito'),
(1, 'VTA-2023002', 2, 3, 'Presencial', 'Pagada', 1299.00, 0.00, 207.84, 1506.84, 'Efectivo'),
(1, 'VTA-2023003', 3, 4, 'Mayorista', 'Pagada', 5498.00, 200.00, 879.68, 6177.68, 'Transferencia'),
(2, 'VTA-2023004', 4, 7, 'Presencial', 'Pagada', 899.00, 0.00, 143.84, 1042.84, 'Tarjeta Débito'),
(2, 'VTA-2023005', 5, 8, 'Empresarial', 'Pagada', 10297.00, 500.00, 1647.52, 11444.52, 'Transferencia'),
(3, 'VTA-2023006', 9, 10, 'Presencial', 'Pagada', 2397.00, 100.00, 383.52, 2680.52, 'Tarjeta Crédito'),
(1, 'VTA-2023007', 6, 3, 'Presencial', 'Pagada', 399.00, 0.00, 63.84, 462.84, 'Efectivo'),
(1, 'VTA-2023008', 7, 4, 'Presencial', 'Pagada', 1799.00, 0.00, 287.84, 2086.84, 'Tarjeta Crédito');

-- Detalles de ventas
INSERT INTO detalles_venta (venta_id, variante_id, cantidad, precio_unitario, descuento_unitario, impuesto_unitario) VALUES
-- Venta 1
(1, 1, 2, 799.00, 0.00, 127.84),  -- 2 Camisas Oxford M Blanco
(1, 4, 1, 1299.00, 0.00, 207.84), -- 1 Jeans 501 32x32 Azul Medio

-- Venta 2
(2, 4, 1, 1299.00, 0.00, 207.84), -- 1 Jeans 501 32x32 Azul Medio

-- Venta 3 (Mayorista)
(3, 1, 5, 799.00, 20.00, 127.84),  -- 5 Camisas Oxford M Blanco con descuento
(3, 5, 3, 1299.00, 30.00, 207.84), -- 3 Jeans 501 34x32 Azul Medio con descuento
(3, 10, 2, 599.00, 10.00, 95.84),  -- 2 Leggings Deportivos M Negro con descuento

-- Venta 4
(4, 20, 1, 899.00, 0.00, 143.84),  -- 1 Vestido Floral M Multicolor

-- Venta 5 (Empresarial)
(5, 1, 10, 799.00, 50.00, 127.84), -- 10 Camisas con descuento mayorista
(5, 5, 5, 1299.00, 50.00, 207.84), -- 5 Jeans con descuento mayorista

-- Venta 6
(6, 28, 1, 1799.00, 0.00, 287.84), -- 1 Tenis Running 9 Negro/Rojo
(6, 31, 1, 599.00, 100.00, 95.84), -- 1 Leggings con descuento promoción

-- Venta 7
(7, 7, 1, 399.00, 0.00, 63.84),    -- 1 Polo Negro M

-- Venta 8
(8, 28, 1, 1799.00, 0.00, 287.84); -- 1 Tenis Running 9 Negro/Rojo

-- Actualizar comisiones de empleados basadas en ventas
UPDATE detalles_venta dv
SET comision_empleado = (dv.precio_unitario - dv.descuento_unitario) * dv.cantidad * 0.03
FROM ventas v
WHERE dv.venta_id = v.venta_id
AND v.empleado_id IN (3, 4, 7, 8, 10);

-- Insertar pedidos a proveedores
INSERT INTO pedidos_compra (codigo_pedido, proveedor_id, empleado_id, fecha_pedido, fecha_entrega_estimada, estado, subtotal, iva, total, metodo_pago) VALUES
('PED-2023001', 1, 1, '2023-01-15', '2023-01-30', 'Recibido', 15000.00, 2400.00, 17400.00, 'Crédito 30 días'),
('PED-2023002', 2, 1, '2023-02-10', '2023-02-25', 'Recibido', 22000.00, 3520.00, 25520.00, 'Crédito 30 días'),
('PED-2023003', 3, 6, '2023-03-05', '2023-03-20', 'Enviado', 18000.00, 2880.00, 20880.00, 'Crédito 15 días'),
('PED-2023004', 4, 9, '2023-03-20', '2023-04-05', 'Pendiente', 12500.00, 2000.00, 14500.00, 'Contado');

-- Detalles de pedidos
INSERT INTO detalles_pedido_compra (pedido_id, producto_id, cantidad, precio_unitario, recibido) VALUES
(1, 1, 100, 350.00, 100),  -- 100 Camisas Oxford
(1, 2, 50, 450.00, 50),   -- 50 Jeans 501
(2, 3, 200, 180.00, 200),  -- 200 Polos Básicos
(2, 6, 80, 320.00, 80),    -- 80 Vestidos Florales
(3, 11, 60, 650.00, 60),   -- 60 Tenis Running
(3, 15, 100, 380.00, 100), -- 100 Chamarras Impermeables
(4, 17, 150, 85.00, 0),    -- 150 Cinturones
(4, 19, 200, 60.00, 0);    -- 200 Gorras Baseball

-- Insertar recepciones de mercancía
INSERT INTO recepciones_mercancia (pedido_id, empleado_id, numero_factura, condiciones, observaciones, estado) VALUES
(1, 5, 'FAC-001-2023', 'Buen estado', 'Todo recibido correctamente', 'Completa'),
(2, 5, 'FAC-002-2023', 'Algunas cajas dañadas', 'Faltaron 5 polos que serán reenviados', 'Parcial');

-- Insertar movimientos de inventario
INSERT INTO movimientos_inventario (variante_id, almacen_id, tipo_movimiento, cantidad, referencia_id, tipo_referencia, empleado_id, motivo, costo_unitario) 
SELECT 
    v.variante_id,
    1,
    'Entrada',
    CASE 
        WHEN p.producto_id = 1 THEN 25
        WHEN p.producto_id = 2 THEN 15
        WHEN p.producto_id = 3 THEN 40
        WHEN p.producto_id = 6 THEN 10
        ELSE 20
    END,
    1,
    'Compra',
    5,
    'Reabastecimiento por pedido PED-2023001',
    p.precio_compra
FROM variantes_producto v
JOIN productos p ON v.producto_id = p.producto_id
WHERE p.producto_id IN (1, 2, 3, 6) 
AND v.color_nombre = 'Blanco' 
AND v.talla = 'M'
LIMIT 10;

-- Insertar programas de fidelidad
INSERT INTO programas_fidelidad (nombre, descripcion, puntos_por_dolar, valor_punto, minimo_canje_puntos, fecha_inicio, fecha_fin, activo, condiciones) VALUES
('Programa Elite', 'Programa de fidelidad para clientes frecuentes', 2.00, 0.10, 100, '2023-01-01', '2023-12-31', TRUE, 'Acumula 2 puntos por cada dólar gastado'),
('Programa Básico', 'Programa de fidelidad estándar', 1.00, 0.05, 200, '2023-01-01', '2023-12-31', TRUE, 'Acumula 1 punto por cada dólar gastado');

-- Insertar transacciones de puntos
INSERT INTO transacciones_puntos (cliente_id, programa_id, tipo_transaccion, puntos, descripcion, referencia_id, tipo_referencia, saldo_anterior, saldo_nuevo) VALUES
(1, 1, 'Acumulación', 516, 'Compra VTA-2023001', 1, 'Venta', 0, 516),
(2, 2, 'Acumulación', 150, 'Compra VTA-2023002', 2, 'Venta', 0, 150),
(3, 1, 'Acumulación', 1235, 'Compra mayorista VTA-2023003', 3, 'Venta', 0, 1235),
(7, 1, 'Acumulación', 360, 'Compra VTA-2023008', 8, 'Venta', 0, 360);

-- Actualizar puntos de clientes
UPDATE clientes c
SET puntos_fidelidad = (
    SELECT COALESCE(SUM(puntos), 0)
    FROM transacciones_puntos tp
    WHERE tp.cliente_id = c.cliente_id
    AND tp.tipo_transaccion = 'Acumulación'
)
WHERE cliente_id IN (1, 2, 3, 7);

-- Insertar wishlists
INSERT INTO wishlists (cliente_id, nombre_lista, es_publica) VALUES
(1, 'Favoritos', FALSE),
(1, 'Para comprar en invierno', TRUE),
(2, 'Mi lista de deseos', FALSE),
(4, 'Favoritos', FALSE),
(7, 'Ropa de trabajo', TRUE);

-- Items en wishlists
INSERT INTO items_wishlist (wishlist_id, producto_id, prioridad) VALUES
(1, 4, 1),   -- Suéter de Lana Merino
(1, 12, 2),  -- Zapatos Formales Oxford
(2, 14, 1),  -- Botas de Cuero
(2, 20, 2),  -- Bufanda de Lana
(3, 6, 1),   -- Vestido Largo Floral
(4, 11, 1),  -- Tenis Running Nike Air
(5, 1, 1),   -- Camisa Oxford
(5, 2, 2);   -- Jeans 501

-- Insertar reseñas de productos
INSERT INTO reseñas_productos (producto_id, cliente_id, calificacion, titulo, comentario, aprobada, fecha_aprobacion, aprobada_por) VALUES
(2, 1, 5, 'Excelentes jeans', 'La calidad de los Levi''s 501 es insuperable. Muy cómodos y duraderos.', TRUE, '2023-02-15', 1),
(1, 2, 4, 'Buena camisa', 'La camisa es de buena calidad, pero la talla me quedó un poco grande.', TRUE, '2023-02-20', 2),
(11, 7, 5, 'Los mejores tenis', 'Perfectos para correr. Muy cómodos y con buen soporte.', TRUE, '2023-03-10', 2),
(6, 4, 3, 'Regular', 'El vestido es bonito pero la tela no es de la mejor calidad.', FALSE, NULL, NULL);

-- Insertar historial de precios
INSERT INTO historial_precios (producto_id, precio_anterior, precio_nuevo, motivo, cambiado_por) VALUES
(1, 750.00, 799.00, 'Ajuste estacional', 1),
(2, 1199.00, 1299.00, 'Aumento de costo', 1),
(15, 999.00, 899.00, 'Promoción', 2),
(19, 249.00, 199.00, 'Competencia', 2);

-- Insertar eventos promocionales
INSERT INTO eventos_promocionales (nombre, descripcion, tipo_evento, fecha_inicio, fecha_fin, presupuesto, responsable_id, estado, creado_por) VALUES
('Rebajas de Invierno', 'Descuentos en ropa de invierno', 'Rebajas', '2023-01-15', '2023-02-15', 50000.00, 2, 'Finalizado', 1),
('Liquidación de Verano', 'Gran liquidación de temporada verano', 'Liquidación', '2023-06-01', '2023-06-30', 30000.00, 6, 'Planificado', 1),
('Aniversario Tienda', 'Celebración 5 años con descuentos especiales', 'Aniversario', '2023-08-15', '2023-08-31', 75000.00, 9, 'Planificado', 1);

-- Productos en eventos
INSERT INTO productos_evento (evento_id, producto_id, descuento_aplicado, precio_promocional, meta_ventas) VALUES
(1, 4, 25.00, 674.25, 50),   -- Suéter de Lana
(1, 14, 20.00, 1599.20, 30), -- Botas de Cuero
(1, 20, 30.00, 160.30, 100), -- Bufanda de Lana
(2, 3, 40.00, 239.40, 200),  -- Polo Básico
(2, 8, 35.00, 324.35, 80);   -- Falda Plisada

-- Insertar tareas
INSERT INTO tareas (titulo, descripcion, empleado_asignado, creado_por, fecha_vencimiento, estado, prioridad, tipo_tarea) VALUES
('Revisar inventario mensual', 'Realizar conteo físico de todo el inventario', 5, 1, '2023-04-05', 'Pendiente', 'Alta', 'Inventario'),
('Capacitación nuevos vendedores', 'Capacitar a 2 nuevos vendedores en técnicas de venta', 2, 1, '2023-03-25', 'En progreso', 'Media', 'Empleados'),
('Actualizar precios de temporada', 'Actualizar precios para colección primavera-verano', 2, 1, '2023-03-20', 'Completada', 'Alta', 'Ventas'),
('Revisar pedido pendiente', 'Seguimiento a pedido PED-2023004 con proveedor', 9, 9, '2023-04-10', 'Pendiente', 'Media', 'Compras');

-- Insertar notificaciones
INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo, prioridad, leida, accion_url) VALUES
(1, 'Nuevo pedido recibido', 'Se ha recibido completamente el pedido PED-2023001', 'Inventario', 'Media', FALSE, '/inventario/pedidos/1'),
(2, 'Venta exitosa', 'Has realizado una venta por $3,013.68', 'Venta', 'Baja', TRUE, '/ventas/1'),
(6, 'Puntos acumulados', 'Has ganado 516 puntos por tu compra reciente', 'Promocion', 'Baja', FALSE, '/mi-cuenta/puntos'),
(9, 'Producto en promoción', 'El suéter de lana que tienes en tu wishlist tiene 25% de descuento', 'Promocion', 'Media', FALSE, '/producto/4');

-- Insertar auditorías de ejemplo
INSERT INTO auditorias (tabla_afectada, accion, id_registro, datos_anteriores, datos_nuevos, realizado_por, ip_address) VALUES
('productos', 'UPDATE', 1, '{"precio_venta": 750.00}', '{"precio_venta": 799.00}', 1, '192.168.1.100'),
('usuarios', 'INSERT', 6, NULL, '{"email": "alejandro.mendoza@gmail.com", "tipo_usuario": "Cliente"}', 1, '192.168.1.100'),
('ventas', 'INSERT', 1, NULL, '{"total": 3013.68, "cliente_id": 1}', 3, '192.168.1.105');

-- Insertar configuraciones adicionales
INSERT INTO configuraciones_tienda (empresa_id, clave, valor, tipo, categoria, descripcion) VALUES
(1, 'tienda.telefono', '55-1234-5678', 'text', 'General', 'Teléfono principal de la tienda'),
(1, 'tienda.horario', 'Lunes a Viernes: 10:00 - 21:00, Sábado: 10:00 - 20:00, Domingo: 11:00 - 19:00', 'text', 'General', 'Horario de atención'),
(1, 'envio.costo_gratis_desde', '999.00', 'decimal', 'Ventas', 'Monto mínimo para envío gratis'),
(1, 'inventario.alerta_stock_bajo', 'true', 'boolean', 'Inventario', 'Activar alertas de stock bajo'),
(1, 'email.notificaciones_ventas', 'ventas@modaexpress.com', 'email', 'Ventas', 'Email para notificaciones de ventas'),
(2, 'tienda.telefono', '33-1234-5678', 'text', 'General', 'Teléfono principal de la tienda'),
(2, 'tienda.horario', 'Lunes a Sábado: 10:00 - 20:00', 'text', 'General', 'Horario de atención');

-- Actualizar total_compras en clientes basado en ventas reales
UPDATE clientes c
SET total_compras = (
    SELECT COALESCE(SUM(v.total), 0)
    FROM ventas v
    WHERE v.cliente_id = c.cliente_id
    AND v.estado_venta = 'Pagada'
),
ultima_compra = (
    SELECT MAX(v.fecha_venta)
    FROM ventas v
    WHERE v.cliente_id = c.cliente_id
    AND v.estado_venta = 'Pagada'
)
WHERE cliente_id IN (SELECT DISTINCT cliente_id FROM ventas);

-- Actualizar segmento basado en total_compras
UPDATE clientes 
SET segmento = CASE 
    WHEN total_compras > 20000 THEN 'Leal'
    WHEN total_compras > 10000 THEN 'Frecuente'
    WHEN total_compras > 3000 THEN 'Ocasional'
    ELSE 'Nuevo'
END,
frecuencia_compra_dias = CASE 
    WHEN ultima_compra IS NOT NULL THEN 
        EXTRACT(DAY FROM CURRENT_DATE - ultima_compra)
    ELSE NULL
END;

-- Insertar transferencias entre almacenes
INSERT INTO transferencias_almacen (codigo_transferencia, almacen_origen_id, almacen_destino_id, empleado_id, fecha_solicitud, estado, creado_por) VALUES
('TRF-2023001', 1, 2, 5, '2023-02-10', 'Recibido', 1),
('TRF-2023002', 2, 3, 5, '2023-03-15', 'Enviado', 1);

-- Detalles de transferencias
INSERT INTO detalles_transferencia (transferencia_id, variante_id, cantidad, cantidad_enviada, cantidad_recibida) VALUES
(1, 1, 10, 10, 10),   -- Camisas Oxford S Blanco
(1, 2, 5, 5, 5),      -- Camisas Oxford M Blanco
(2, 7, 15, 15, 0),    -- Polos Negro M
(2, 8, 10, 10, 0);    -- Polos Negro L

-- Insertar cupones de descuento
INSERT INTO cupones_descuento (codigo_cupon, descripcion, tipo_descuento, valor_descuento, minimo_compra, fecha_inicio, fecha_fin, usos_maximos, activo, creado_por) VALUES
('BIENVENIDA20', '20% de descuento en primera compra', 'Porcentaje', 20.00, 500.00, '2023-01-01', '2023-12-31', 1000, TRUE, 1),
('VERANO2023', '15% de descuento en ropa de verano', 'Porcentaje', 15.00, 800.00, '2023-06-01', '2023-08-31', 500, TRUE, 2),
('ENVIOGRATIS', 'Envío gratis en cualquier compra', 'Monto Fijo', 99.00, 0.00, '2023-01-01', '2023-12-31', 2000, TRUE, 1);

-- Cupones usados
INSERT INTO cupones_usados (cupon_id, venta_id, cliente_id, monto_descuento_aplicado) VALUES
(1, 4, 4, 179.80),  -- 20% de $899.00
(3, 2, 2, 99.00);   -- Envío gratis

-- Insertar ajustes de inventario
INSERT INTO ajustes_inventario (codigo_ajuste, almacen_id, empleado_id, tipo_ajuste, motivo, estado, aprobado_por, fecha_aprobacion, creado_por) VALUES
('AJT-2023001', 1, 5, 'Dañado', 'Producto dañado en transporte', 'Aprobado', 1, '2023-02-05', 5),
('AJT-2023002', 2, 5, 'Robo', 'Falta de mercancía no justificada', 'Pendiente', NULL, NULL, 5);

-- Detalles de ajustes
INSERT INTO detalles_ajuste_inventario (ajuste_id, variante_id, cantidad_anterior, cantidad_nueva, costo_unitario, observaciones) VALUES
(1, 1, 25, 23, 350.00, '2 camisas con defectos de fabrica'),
(1, 4, 15, 14, 450.00, '1 jean con rotura');

-- Insertar sesiones activas
INSERT INTO sesiones (usuario_id, token_sesion, token_refresh, dispositivo, navegador, sistema_operativo, ip_address, fecha_expiracion, activa) VALUES
(1, 'session_token_emp_001', 'refresh_token_emp_001', 'Desktop', 'Chrome 110', 'Windows 10', '192.168.1.100', CURRENT_TIMESTAMP + INTERVAL '1 day', TRUE),
(6, 'session_token_cli_001', 'refresh_token_cli_001', 'iPhone 13', 'Safari 16', 'iOS 16', '192.168.1.150', CURRENT_TIMESTAMP + INTERVAL '7 days', TRUE),
(9, 'session_token_cli_004', 'refresh_token_cli_004', 'Samsung Galaxy S21', 'Chrome Mobile', 'Android 13', '192.168.1.200', CURRENT_TIMESTAMP + INTERVAL '30 days', TRUE);

-- Insertar logs de autenticación
INSERT INTO logs_autenticacion (usuario_id, email_proporcionado, accion, exito, ip_address, user_agent, dispositivo) VALUES
(1, 'juan.gonzalez@modaexpress.com', 'Login', TRUE, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'Desktop'),
(6, 'alejandro.mendoza@gmail.com', 'Login', TRUE, '192.168.1.150', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15', 'iPhone'),
(9, 'gaby.ortega@yahoo.com', 'Login', TRUE, '192.168.1.200', 'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36', 'Samsung Galaxy');

-- Insertar política de seguridad
INSERT INTO politicas_seguridad (nombre, descripcion, longitud_minima, requiere_mayusculas, requiere_minusculas, requiere_numeros, requiere_simbolos, expiracion_dias, historico_contrasenas, tiempo_inactividad_minutos, maximo_sesiones_simultaneas, max_intentos_login, bloqueo_minutos, fuerza_contrasena, aplica_desde, activa, creado_por) VALUES
('Política Corporativa', 'Política de seguridad para empleados y clientes', 8, TRUE, TRUE, TRUE, TRUE, 90, 5, 30, 3, 5, 30, 'Alta', '2023-01-01', TRUE, 1);

-- Insertar historial de contraseñas
INSERT INTO historial_contrasenas (usuario_id, contrasena_hash, ip_address) 
SELECT usuario_id, contrasena_hash, '192.168.1.100'
FROM usuarios 
WHERE contrasena_hash IS NOT NULL;

-- =============================================
-- ACTUALIZAR CAMPOS GENERADOS DESPUÉS DE INSERTS
-- =============================================

-- Los campos GENERATED ALWAYS AS se calculan automáticamente en PostgreSQL
-- No necesitan actualización manual

-- Verificar algunos datos insertados
SELECT 'Base de datos poblada exitosamente' as mensaje;
SELECT COUNT(*) as total_productos FROM productos;
SELECT COUNT(*) as total_clientes FROM clientes;
SELECT COUNT(*) as total_ventas FROM ventas;
SELECT COUNT(*) as total_empleados FROM empleados;
SELECT COUNT(*) as total_usuarios FROM usuarios;

-- Mostrar resumen
SELECT 
    'Resumen de datos insertados:' as titulo,
    (SELECT COUNT(*) FROM productos) as productos,
    (SELECT COUNT(*) FROM variantes_producto) as variantes,
    (SELECT COUNT(*) FROM clientes) as clientes,
    (SELECT COUNT(*) FROM empleados) as empleados,
    (SELECT COUNT(*) FROM ventas) as ventas,
    (SELECT SUM(total) FROM ventas) as total_ventas_mxn,
    (SELECT COUNT(*) FROM usuarios) as usuarios;