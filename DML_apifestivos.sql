-- ============================================================
-- DML - API CALENDARIO LABORAL POR PAÍSES
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. TIPOS DE FESTIVO
-- ============================================================

INSERT INTO tipofestivo (tipo, descripcion)
VALUES
(
    'FIJO',
    'Festivo cuya fecha no se modifica.'
),
(
    'LEY_PUENTE',
    'Festivo cuya fecha se traslada al siguiente lunes.'
),
(
    'PASCUA',
    'Festivo calculado a partir del Domingo de Pascua.'
),
(
    'PASCUA_LEY_PUENTE',
    'Festivo calculado a partir del Domingo de Pascua y trasladado al siguiente lunes.'
)
ON CONFLICT (tipo) DO NOTHING;


-- ============================================================
-- 2. PAÍSES
-- ============================================================

INSERT INTO pais (nombre, codigo)
VALUES
(
    'Colombia',
    'CO'
)
ON CONFLICT (codigo) DO NOTHING;


-- ============================================================
-- 3. FESTIVOS FIJOS
-- ============================================================
-- Tipo: FIJO
--
-- Estos festivos conservan siempre el mismo día y mes.
-- ============================================================

INSERT INTO festivo
(
    nombre,
    dia,
    mes,
    diaspascua,
    idpais,
    idtipofestivo
)
SELECT
    datos.nombre,
    datos.dia,
    datos.mes,
    NULL,
    p.id,
    t.id
FROM
(
    VALUES
        ('Año Nuevo', 1, 1),
        ('Día del Trabajo', 1, 5),
        ('Independencia de Colombia', 20, 7),
        ('Batalla de Boyacá', 7, 8),
        ('Inmaculada Concepción', 8, 12),
        ('Navidad', 25, 12)
) AS datos(nombre, dia, mes)
CROSS JOIN pais p
CROSS JOIN tipofestivo t
WHERE
    p.codigo = 'CO'
    AND t.tipo = 'FIJO'
    AND NOT EXISTS (
        SELECT 1
        FROM festivo f
        WHERE f.nombre = datos.nombre
          AND f.idpais = p.id
    );


-- ============================================================
-- 4. FESTIVOS - LEY DE PUENTE
-- ============================================================
-- La fecha original se toma de día + mes.
-- Posteriormente la aplicación determina si debe trasladarse
-- al siguiente lunes.
-- ============================================================

INSERT INTO festivo
(
    nombre,
    dia,
    mes,
    diaspascua,
    idpais,
    idtipofestivo
)
SELECT
    datos.nombre,
    datos.dia,
    datos.mes,
    NULL,
    p.id,
    t.id
FROM
(
    VALUES
        ('Santos Reyes', 6, 1),
        ('San José', 19, 3),
        ('San Pedro y San Pablo', 29, 6),
        ('Asunción de la Virgen', 15, 8),
        ('Día de la Raza', 12, 10),
        ('Todos los Santos', 1, 11),
        ('Independencia de Cartagena', 11, 11)
) AS datos(nombre, dia, mes)
CROSS JOIN pais p
CROSS JOIN tipofestivo t
WHERE
    p.codigo = 'CO'
    AND t.tipo = 'LEY_PUENTE'
    AND NOT EXISTS (
        SELECT 1
        FROM festivo f
        WHERE f.nombre = datos.nombre
          AND f.idpais = p.id
    );


-- ============================================================
-- 5. FESTIVOS BASADOS EN PASCUA
-- ============================================================
-- diaspascua indica cuántos días se deben sumar/restar
-- respecto al Domingo de Pascua.
--
-- Jueves Santo       = Pascua - 3
-- Viernes Santo      = Pascua - 2
-- Domingo de Pascua  = Pascua + 0
-- ============================================================

INSERT INTO festivo
(
    nombre,
    dia,
    mes,
    diaspascua,
    idpais,
    idtipofestivo
)
SELECT
    datos.nombre,
    NULL,
    NULL,
    datos.diaspascua,
    p.id,
    t.id
FROM
(
    VALUES
        ('Jueves Santo', -3),
        ('Viernes Santo', -2),
        ('Domingo de Pascua', 0)
) AS datos(nombre, diaspascua)
CROSS JOIN pais p
CROSS JOIN tipofestivo t
WHERE
    p.codigo = 'CO'
    AND t.tipo = 'PASCUA'
    AND NOT EXISTS (
        SELECT 1
        FROM festivo f
        WHERE f.nombre = datos.nombre
          AND f.idpais = p.id
    );


-- ============================================================
-- 6. FESTIVOS BASADOS EN PASCUA + LEY DE PUENTE
-- ============================================================
--
-- Ascensión del Señor      = Pascua + 40
-- Corpus Christi           = Pascua + 61
-- Sagrado Corazón de Jesús = Pascua + 68
--
-- Después del cálculo se traslada al siguiente lunes.
-- ============================================================

INSERT INTO festivo
(
    nombre,
    dia,
    mes,
    diaspascua,
    idpais,
    idtipofestivo
)
SELECT
    datos.nombre,
    NULL,
    NULL,
    datos.diaspascua,
    p.id,
    t.id
FROM
(
    VALUES
        ('Ascensión del Señor', 40),
        ('Corpus Christi', 61),
        ('Sagrado Corazón de Jesús', 68)
) AS datos(nombre, diaspascua)
CROSS JOIN pais p
CROSS JOIN tipofestivo t
WHERE
    p.codigo = 'CO'
    AND t.tipo = 'PASCUA_LEY_PUENTE'
    AND NOT EXISTS (
        SELECT 1
        FROM festivo f
        WHERE f.nombre = datos.nombre
          AND f.idpais = p.id
    );


-- ============================================================
-- 7. CALENDARIOS ANUALES
-- ============================================================
-- Se pueden registrar los años que la aplicación necesita.
--
-- 2028 se incluye como ejemplo de año bisiesto.
-- ============================================================

INSERT INTO calendario (anio, idpais)
SELECT anio, p.id
FROM
(
    VALUES
        (2026),
        (2027),
        (2028),
        (2029),
        (2030)
) AS datos(anio)
CROSS JOIN pais p
WHERE
    p.codigo = 'CO'
ON CONFLICT (anio, idpais) DO NOTHING;


-- ============================================================
-- FIN DEL DML
-- ============================================================