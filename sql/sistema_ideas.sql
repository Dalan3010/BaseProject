-- ============================================================
-- Plataforma de Descubrimiento y Validación de Ideas
-- Script de base de datos: esquema, datos de ejemplo y datos masivos
--
-- Motor: PostgreSQL 13+ (probado en PostgreSQL 17)
--
-- Ejecución:
--   psql -U <usuario> -f sql/sistema_ideas.sql
--
-- El script crea la base de datos `sistema_ideas` si no existe, se
-- conecta a ella y luego crea el esquema y carga los datos.
-- Es seguro ejecutarlo más de una vez: no duplica registros.
-- ============================================================

\set ON_ERROR_STOP on

-- ============================================================
-- 0. CREAR LA BASE DE DATOS Y CONECTARSE
-- ============================================================

SELECT 'CREATE DATABASE sistema_ideas'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'sistema_ideas'
)\gexec

\c sistema_ideas

-- ============================================================
-- 1. EXTENSIONES
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 2. ESQUEMA
-- ============================================================

CREATE TABLE IF NOT EXISTS personas (
    id_persona UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_completo VARCHAR(40) NOT NULL,
    fecha_nacimiento DATE,
    ciudad VARCHAR(30),
    departamento VARCHAR(30),
    nivel_educativo VARCHAR(20),
    tiene_experiencia_emprendedora BOOLEAN DEFAULT FALSE,
    tiempo_disponible VARCHAR(50),
    nivel_comodidad_tecnologica VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    correo_electronico VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(50) NOT NULL,
    id_persona UUID NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_persona
        FOREIGN KEY (id_persona)
        REFERENCES personas(id_persona)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ideas (
    id_idea UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL,
    problema TEXT NOT NULL,
    puntuacion_oportunidad REAL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_idea_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chats (
    id_idea UUID PRIMARY KEY,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_idea
        FOREIGN KEY (id_idea)
        REFERENCES ideas(id_idea)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS mensajes (
    id_mensaje UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_idea UUID NOT NULL,
    rol VARCHAR(30) NOT NULL,
    contenido JSON NOT NULL,
    marca_temporal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensaje_chat
        FOREIGN KEY (id_idea)
        REFERENCES chats(id_idea)
        ON DELETE CASCADE,
    CONSTRAINT chk_mensaje_rol
        CHECK (rol IN ('usuario', 'asistente', 'sistema'))
);

CREATE TABLE IF NOT EXISTS archivos (
    id_archivo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_idea UUID NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    url_archivo TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_archivo_chat
        FOREIGN KEY (id_idea)
        REFERENCES chats(id_idea)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ideas_usuario
    ON ideas(id_usuario);

CREATE INDEX IF NOT EXISTS idx_mensajes_chat_fecha
    ON mensajes(id_idea, marca_temporal);

CREATE INDEX IF NOT EXISTS idx_archivos_idea
    ON archivos(id_idea);

-- Los hashes bcrypt ocupan 60 caracteres.
-- La columna original VARCHAR(50) es insuficiente.
ALTER TABLE usuarios
    ALTER COLUMN contrasena TYPE VARCHAR(255);

-- ============================================================
-- 3. DATOS DE EJEMPLO
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 3.1 Personas
-- ------------------------------------------------------------

INSERT INTO personas (
    id_persona,
    nombre_completo,
    fecha_nacimiento,
    ciudad,
    departamento,
    nivel_educativo,
    tiene_experiencia_emprendedora,
    tiempo_disponible,
    nivel_comodidad_tecnologica
)
VALUES
(
    '10000000-0000-4000-8000-000000000001',
    'Mariana Rojas Pérez',
    '1998-05-14',
    'Valledupar',
    'Cesar',
    'Universitario',
    TRUE,
    '10 horas semanales',
    'Intermedio'
),
(
    '10000000-0000-4000-8000-000000000002',
    'Santiago Vega Molina',
    '2001-09-22',
    'Aguachica',
    'Cesar',
    'Técnico',
    FALSE,
    '15 horas semanales',
    'Básico'
),
(
    '10000000-0000-4000-8000-000000000003',
    'Laura Martínez López',
    '1995-03-10',
    'Bogotá',
    'Cundinamarca',
    'Universitario',
    TRUE,
    '6 horas semanales',
    'Avanzado'
),
(
    '10000000-0000-4000-8000-000000000004',
    'Andrés Patiño Ruiz',
    '2000-11-08',
    'Medellín',
    'Antioquia',
    'Tecnólogo',
    FALSE,
    '8 horas semanales',
    'Intermedio'
),
(
    '10000000-0000-4000-8000-000000000005',
    'Valentina Herrera Díaz',
    '1997-07-19',
    'Santa Marta',
    'Magdalena',
    'Posgrado',
    TRUE,
    '12 horas semanales',
    'Avanzado'
)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3.2 Usuarios
-- Contraseña de prueba: Demo1234!
-- Se almacena como hash bcrypt.
-- ------------------------------------------------------------

INSERT INTO usuarios (
    id_usuario,
    correo_electronico,
    contrasena,
    id_persona
)
VALUES
(
    '20000000-0000-4000-8000-000000000001',
    'mariana@example.com',
    crypt('Demo1234!', gen_salt('bf')),
    '10000000-0000-4000-8000-000000000001'
),
(
    '20000000-0000-4000-8000-000000000002',
    'santiago@example.com',
    crypt('Demo1234!', gen_salt('bf')),
    '10000000-0000-4000-8000-000000000002'
),
(
    '20000000-0000-4000-8000-000000000003',
    'laura@example.com',
    crypt('Demo1234!', gen_salt('bf')),
    '10000000-0000-4000-8000-000000000003'
),
(
    '20000000-0000-4000-8000-000000000004',
    'andres@example.com',
    crypt('Demo1234!', gen_salt('bf')),
    '10000000-0000-4000-8000-000000000004'
),
(
    '20000000-0000-4000-8000-000000000005',
    'valentina@example.com',
    crypt('Demo1234!', gen_salt('bf')),
    '10000000-0000-4000-8000-000000000005'
)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3.3 Ideas de emprendimiento
-- ------------------------------------------------------------

INSERT INTO ideas (
    id_idea,
    id_usuario,
    problema,
    puntuacion_oportunidad
)
VALUES
(
    '30000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    'Los pequeños comercios de Valledupar tienen dificultades para promocionar sus productos y conseguir clientes mediante plataformas digitales.',
    85.5
),
(
    '30000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000001',
    'Los restaurantes pequeños tienen dificultades para controlar sus inventarios y reducir las pérdidas de alimentos.',
    91.2
),
(
    '30000000-0000-4000-8000-000000000003',
    '20000000-0000-4000-8000-000000000002',
    'Los estudiantes universitarios no cuentan con información centralizada sobre las rutas y horarios de transporte.',
    78.9
),
(
    '30000000-0000-4000-8000-000000000004',
    '20000000-0000-4000-8000-000000000003',
    'Las ciudades presentan dificultades para identificar zonas con riesgo de inundación debido a la insuficiencia de información y análisis predictivo.',
    94.0
),
(
    '30000000-0000-4000-8000-000000000005',
    '20000000-0000-4000-8000-000000000004',
    'Las clínicas veterinarias pequeñas administran manualmente sus citas y los historiales de sus pacientes.',
    82.3
),
(
    '30000000-0000-4000-8000-000000000006',
    '20000000-0000-4000-8000-000000000005',
    'Los restaurantes turísticos desperdician alimentos por una planificación deficiente de la demanda diaria.',
    88.7
)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3.4 Chats
-- Cada idea tiene un chat.
-- chats.id_idea funciona como PK y FK.
-- ------------------------------------------------------------

INSERT INTO chats (id_idea)
VALUES
('30000000-0000-4000-8000-000000000001'),
('30000000-0000-4000-8000-000000000002'),
('30000000-0000-4000-8000-000000000003'),
('30000000-0000-4000-8000-000000000004'),
('30000000-0000-4000-8000-000000000005'),
('30000000-0000-4000-8000-000000000006')
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3.5 Mensajes de los chats
-- contenido es de tipo JSON.
-- Los roles permitidos son: usuario, asistente, sistema.
-- ------------------------------------------------------------

INSERT INTO mensajes (
    id_mensaje,
    id_idea,
    rol,
    contenido,
    marca_temporal
)
VALUES

-- CHAT 1: Comercio digital

(
    '40000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'sistema',
    '{"texto":"Eres un asistente especializado en evaluar oportunidades de emprendimiento."}'::json,
    '2026-10-20 09:00:00'
),
(
    '40000000-0000-4000-8000-000000000002',
    '30000000-0000-4000-8000-000000000001',
    'usuario',
    '{"texto":"Quiero crear una plataforma para ayudar a pequeños comercios de Valledupar a vender sus productos."}'::json,
    '2026-10-20 09:01:00'
),
(
    '40000000-0000-4000-8000-000000000003',
    '30000000-0000-4000-8000-000000000001',
    'asistente',
    '{"texto":"La idea tiene potencial. Recomiendo validar las necesidades de los comerciantes, identificar competidores y desarrollar un MVP."}'::json,
    '2026-10-20 09:02:00'
),

-- CHAT 2: Inventario

(
    '40000000-0000-4000-8000-000000000004',
    '30000000-0000-4000-8000-000000000002',
    'usuario',
    '{"texto":"Quiero desarrollar un sistema de inventario inteligente para restaurantes pequeños."}'::json,
    '2026-10-20 10:00:00'
),
(
    '40000000-0000-4000-8000-000000000005',
    '30000000-0000-4000-8000-000000000002',
    'asistente',
    '{"texto":"Puedes implementar alertas de existencias, predicción de consumo y seguimiento de productos próximos a vencer."}'::json,
    '2026-10-20 10:01:00'
),

-- CHAT 3: Transporte

(
    '40000000-0000-4000-8000-000000000006',
    '30000000-0000-4000-8000-000000000003',
    'usuario',
    '{"texto":"Necesito evaluar una aplicación que muestre las rutas y horarios del transporte universitario."}'::json,
    '2026-10-21 08:00:00'
),
(
    '40000000-0000-4000-8000-000000000007',
    '30000000-0000-4000-8000-000000000003',
    'asistente',
    '{"texto":"Sugiero comenzar con encuestas a estudiantes y verificar la disponibilidad de datos de rutas y horarios."}'::json,
    '2026-10-21 08:01:00'
),

-- CHAT 4: Análisis predictivo

(
    '40000000-0000-4000-8000-000000000008',
    '30000000-0000-4000-8000-000000000004',
    'usuario',
    '{"texto":"Me interesa desarrollar un sistema de inteligencia artificial para predecir riesgos de inundaciones urbanas."}'::json,
    '2026-10-22 14:00:00'
),
(
    '40000000-0000-4000-8000-000000000009',
    '30000000-0000-4000-8000-000000000004',
    'asistente',
    '{"texto":"Puedes utilizar registros históricos de precipitaciones, datos geográficos y modelos de aprendizaje automático. Es importante validar la calidad de los datos."}'::json,
    '2026-10-22 14:01:00'
),

-- CHAT 5: Veterinaria

(
    '40000000-0000-4000-8000-000000000010',
    '30000000-0000-4000-8000-000000000005',
    'usuario',
    '{"texto":"Quiero crear un software para administrar citas y pacientes de una clínica veterinaria."}'::json,
    '2026-10-23 11:00:00'
),
(
    '40000000-0000-4000-8000-000000000011',
    '30000000-0000-4000-8000-000000000005',
    'asistente',
    '{"texto":"El sistema podría incluir agenda, recordatorios, historial médico y administración de servicios."}'::json,
    '2026-10-23 11:01:00'
),

-- CHAT 6: Desperdicio alimentario

(
    '40000000-0000-4000-8000-000000000012',
    '30000000-0000-4000-8000-000000000006',
    'usuario',
    '{"texto":"Busco una solución tecnológica para reducir el desperdicio de alimentos en restaurantes turísticos."}'::json,
    '2026-10-24 15:00:00'
),
(
    '40000000-0000-4000-8000-000000000013',
    '30000000-0000-4000-8000-000000000006',
    'asistente',
    '{"texto":"Recomiendo evaluar un sistema de pronóstico de demanda basado en ventas históricas, temporadas turísticas e inventarios."}'::json,
    '2026-10-24 15:01:00'
)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3.6 Archivos
-- Las URL son ficticias. No corresponden a archivos reales.
-- ------------------------------------------------------------

INSERT INTO archivos (
    id_archivo,
    id_idea,
    nombre,
    url_archivo
)
VALUES
(
    '50000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000001',
    'estudio_mercado.pdf',
    'https://example.com/archivos/estudio_mercado.pdf'
),
(
    '50000000-0000-4000-8000-000000000002',
    '30000000-0000-4000-8000-000000000002',
    'analisis_inventario.xlsx',
    'https://example.com/archivos/analisis_inventario.xlsx'
),
(
    '50000000-0000-4000-8000-000000000003',
    '30000000-0000-4000-8000-000000000004',
    'datos_inundaciones.csv',
    'https://example.com/archivos/datos_inundaciones.csv'
),
(
    '50000000-0000-4000-8000-000000000004',
    '30000000-0000-4000-8000-000000000006',
    'proyeccion_demanda.xlsx',
    'https://example.com/archivos/proyeccion_demanda.xlsx'
)
ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================================
-- 4. DATOS MASIVOS (100 REGISTROS POR TABLA PRINCIPAL)
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 4.1 Generar 100 personas
-- ------------------------------------------------------------

INSERT INTO personas (
    id_persona,
    nombre_completo,
    fecha_nacimiento,
    ciudad,
    departamento,
    nivel_educativo,
    tiene_experiencia_emprendedora,
    tiempo_disponible,
    nivel_comodidad_tecnologica
)
SELECT
    md5('demo2026_persona_' || n)::uuid,

    (ARRAY[
        'Ana', 'Luis', 'María', 'Carlos',
        'Sofía', 'Andrés', 'Valeria', 'Daniel',
        'Camila', 'Miguel', 'Paula', 'Juan',
        'Natalia', 'David', 'Laura', 'Julián',
        'Daniela', 'Santiago', 'Isabella', 'Mateo'
    ])[1 + ((n - 1) % 20)]
    || ' ' ||
    (ARRAY[
        'García', 'Martínez', 'Rodríguez',
        'Pérez', 'Gómez'
    ])[1 + (((n - 1) / 20) % 5)]
    || ' ' ||
    (ARRAY[
        'López', 'Torres', 'Ramírez',
        'Morales', 'Vargas', 'Castro',
        'Rojas', 'Herrera', 'Díaz', 'Mendoza'
    ])[1 + (((n - 1) / 10) % 10)],

    DATE '1987-01-01' + ((n * 137) % 8000),

    (ARRAY[
        'Valledupar', 'Aguachica', 'Bogotá',
        'Medellín', 'Santa Marta', 'Barranquilla',
        'Cartagena', 'Bucaramanga', 'Cúcuta',
        'Montería', 'Sincelejo', 'Riohacha'
    ])[1 + ((n - 1) % 12)],

    (ARRAY[
        'Cesar', 'Cesar', 'Bogotá D.C.',
        'Antioquia', 'Magdalena', 'Atlántico',
        'Bolívar', 'Santander', 'Norte de Santander',
        'Córdoba', 'Sucre', 'La Guajira'
    ])[1 + ((n - 1) % 12)],

    (ARRAY[
        'Bachiller', 'Técnico', 'Tecnólogo',
        'Universitario', 'Posgrado'
    ])[1 + ((n - 1) % 5)],

    n % 3 = 0,

    (ARRAY[
        '5 horas semanales',
        '10 horas semanales',
        '15 horas semanales',
        '20 horas semanales',
        'Tiempo completo'
    ])[1 + ((n - 1) % 5)],

    (ARRAY[
        'Básico', 'Intermedio', 'Avanzado'
    ])[1 + ((n - 1) % 3)]

FROM generate_series(1, 100) AS g(n)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4.2 Generar 100 usuarios
-- Contraseña DEMO: Demo1234!
-- Se guarda con hash bcrypt.
-- ------------------------------------------------------------

INSERT INTO usuarios (
    id_usuario,
    correo_electronico,
    contrasena,
    id_persona,
    fecha_creacion
)
SELECT
    md5('demo2026_usuario_' || g.n)::uuid,

    'usuario.demo' ||
    LPAD(g.n::text, 3, '0') ||
    '@example.com',

    crypt('Demo1234!', gen_salt('bf')),

    p.id_persona,

    CURRENT_TIMESTAMP
        - INTERVAL '120 days'
        + g.n * INTERVAL '1 minute'

FROM generate_series(1, 100) AS g(n)
JOIN personas p
    ON p.id_persona =
       md5('demo2026_persona_' || g.n)::uuid
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4.3 Generar 100 ideas de emprendimiento
-- ------------------------------------------------------------

INSERT INTO ideas (
    id_idea,
    id_usuario,
    problema,
    puntuacion_oportunidad,
    fecha_creacion
)
SELECT
    md5('demo2026_idea_' || g.n)::uuid,

    u.id_usuario,

    (ARRAY[
        'Los restaurantes pequeños no cuentan con sistemas para gestionar sus inventarios.',
        'Los agricultores tienen dificultades para comercializar directamente sus productos.',
        'Los estudiantes universitarios necesitan mejores herramientas de organización académica.',
        'Las clínicas veterinarias presentan problemas en la gestión de citas médicas.',
        'Los pequeños comerciantes desconocen herramientas de marketing digital.',
        'Los ciudadanos tienen dificultades para encontrar servicios técnicos confiables.',
        'Los emprendedores carecen de orientación financiera para iniciar negocios.',
        'Los restaurantes desperdician alimentos por una planificación deficiente.',
        'Los productores artesanales necesitan canales de venta digitales.',
        'Los estudiantes necesitan plataformas accesibles de formación tecnológica.',
        'Los negocios locales no disponen de soluciones económicas de facturación.',
        'Los hoteles pequeños tienen dificultades para administrar sus reservas.',
        'Los agricultores necesitan monitorear la humedad de sus cultivos.',
        'Los emprendedores necesitan validar sus ideas antes de invertir dinero.',
        'Las empresas pequeñas no cuentan con herramientas para analizar sus ventas.',
        'Los servicios de transporte necesitan mejorar la información sobre sus rutas.',
        'Los comercios necesitan automatizar la atención de sus clientes.',
        'Los emprendimientos gastronómicos presentan dificultades para estimar la demanda.',
        'Los municipios necesitan herramientas digitales para gestionar residuos.',
        'Los trabajadores independientes necesitan plataformas para ofrecer sus servicios.'
    ])[1 + ((g.n - 1) % 20)]

    || ' Zona piloto: ' || p.ciudad ||
    '. Caso de estudio ' ||
    LPAD(g.n::text, 3, '0') || '.',

    (55 + ((g.n * 7) % 41))::REAL,

    CURRENT_TIMESTAMP
        - INTERVAL '100 days'
        + g.n * INTERVAL '12 hours'

FROM generate_series(1, 100) AS g(n)

JOIN usuarios u
    ON u.id_usuario =
       md5('demo2026_usuario_' || g.n)::uuid

JOIN personas p
    ON p.id_persona = u.id_persona

ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4.4 Generar 100 chats
-- Un chat asociado a cada idea.
-- ------------------------------------------------------------

INSERT INTO chats (
    id_idea,
    fecha_creacion
)
SELECT
    i.id_idea,
    i.fecha_creacion

FROM generate_series(1, 100) AS g(n)

JOIN ideas i
    ON i.id_idea =
       md5('demo2026_idea_' || g.n)::uuid

ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4.5 Generar 300 mensajes
-- Tres mensajes por chat:
-- 1. Sistema
-- 2. Usuario
-- 3. Asistente IA
-- ------------------------------------------------------------

INSERT INTO mensajes (
    id_mensaje,
    id_idea,
    rol,
    contenido,
    marca_temporal
)
SELECT
    md5(
        'demo2026_mensaje_' ||
        g.n || '_' || m.paso
    )::uuid,

    i.id_idea,

    CASE m.paso
        WHEN 1 THEN 'sistema'
        WHEN 2 THEN 'usuario'
        WHEN 3 THEN 'asistente'
    END,

    json_build_object(
        'texto',
        CASE m.paso

            WHEN 1 THEN
                'Eres un asistente de inteligencia artificial especializado en análisis de negocios, emprendimiento y validación de oportunidades.'

            WHEN 2 THEN
                'Quiero evaluar esta oportunidad de negocio: '
                || i.problema ||
                ' ¿Qué posibilidades de éxito tiene?'

            WHEN 3 THEN
                'Esta propuesta merece ser evaluada mediante entrevistas con clientes, análisis de competidores, estudio de mercado y desarrollo de un producto mínimo viable. Su puntuación inicial de oportunidad es '
                || i.puntuacion_oportunidad ||
                ' sobre 100. Este valor es ilustrativo y necesita validación con datos reales.'

        END,

        'tipo', 'conversacion_demo',
        'numero_mensaje', m.paso
    ),

    i.fecha_creacion
        + m.paso * INTERVAL '1 minute'

FROM generate_series(1, 100) AS g(n)

CROSS JOIN generate_series(1, 3) AS m(paso)

JOIN ideas i
    ON i.id_idea =
       md5('demo2026_idea_' || g.n)::uuid

JOIN chats c
    ON c.id_idea = i.id_idea

ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4.6 Generar 100 archivos
-- Las direcciones son ficticias.
-- No se crean archivos reales.
-- ------------------------------------------------------------

INSERT INTO archivos (
    id_archivo,
    id_idea,
    nombre,
    url_archivo,
    fecha_creacion
)
SELECT
    md5('demo2026_archivo_' || g.n)::uuid,

    i.id_idea,

    'documento_' ||
    LPAD(g.n::text, 3, '0') ||

    CASE
        WHEN g.n % 3 = 0 THEN '.csv'
        WHEN g.n % 3 = 1 THEN '.pdf'
        ELSE '.xlsx'
    END,

    'https://example.com/archivos/demo/documento_' ||
    LPAD(g.n::text, 3, '0') ||

    CASE
        WHEN g.n % 3 = 0 THEN '.csv'
        WHEN g.n % 3 = 1 THEN '.pdf'
        ELSE '.xlsx'
    END,

    i.fecha_creacion + INTERVAL '5 minutes'

FROM generate_series(1, 100) AS g(n)

JOIN ideas i
    ON i.id_idea =
       md5('demo2026_idea_' || g.n)::uuid

JOIN chats c
    ON c.id_idea = i.id_idea

ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================================
-- 5. VERIFICACIÓN
-- ============================================================

SELECT 'personas' AS tabla, COUNT(*) AS registros FROM personas
UNION ALL
SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL
SELECT 'ideas', COUNT(*) FROM ideas
UNION ALL
SELECT 'chats', COUNT(*) FROM chats
UNION ALL
SELECT 'mensajes', COUNT(*) FROM mensajes
UNION ALL
SELECT 'archivos', COUNT(*) FROM archivos
ORDER BY tabla;

-- Resumen por idea: mensajes, archivos y perfil del emprendedor.

SELECT
    p.nombre_completo,
    p.ciudad,
    p.departamento,
    u.correo_electronico,
    i.problema,
    i.puntuacion_oportunidad,
    COUNT(DISTINCT m.id_mensaje) AS total_mensajes,
    COUNT(DISTINCT a.id_archivo) AS total_archivos
FROM personas p
JOIN usuarios u ON p.id_persona = u.id_persona
JOIN ideas i ON u.id_usuario = i.id_usuario
LEFT JOIN mensajes m ON i.id_idea = m.id_idea
LEFT JOIN archivos a ON i.id_idea = a.id_idea
GROUP BY
    p.nombre_completo,
    p.ciudad,
    p.departamento,
    u.correo_electronico,
    i.id_idea
ORDER BY i.puntuacion_oportunidad DESC;
