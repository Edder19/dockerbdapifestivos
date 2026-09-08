-- ============================================================
-- DDL - API CALENDARIO LABORAL POR PAÍSES
-- Base de datos: calendariolaboral
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 1. TABLA PAIS
-- ============================================================

CREATE TABLE IF NOT EXISTS pais (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(10) NOT NULL UNIQUE
);


-- ============================================================
-- 2. TABLA TIPO FESTIVO
-- ============================================================

CREATE TABLE IF NOT EXISTS tipofestivo (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NOT NULL
);


-- ============================================================
-- 3. TABLA FESTIVO
-- ============================================================
-- Esta tabla almacena la REGLA del festivo.
--
-- dia + mes:
--     Para festivos fijos y festivos trasladables.
--
-- diaspascua:
--     Para festivos calculados a partir del Domingo de Pascua.
--
-- IMPORTANTE:
-- No se almacena el año aquí porque una misma regla
-- puede utilizarse para diferentes años.
-- ============================================================

CREATE TABLE IF NOT EXISTS festivo (
    id BIGSERIAL PRIMARY KEY,

    nombre VARCHAR(255) NOT NULL,

    dia INTEGER,
    mes INTEGER,

    diaspascua INTEGER,

    idpais BIGINT NOT NULL,

    idtipofestivo BIGINT NOT NULL,

    CONSTRAINT fk_festivo_pais
        FOREIGN KEY (idpais)
        REFERENCES pais(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_festivo_tipo
        FOREIGN KEY (idtipofestivo)
        REFERENCES tipofestivo(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_festivo_dia
        CHECK (dia IS NULL OR dia BETWEEN 1 AND 31),

    CONSTRAINT chk_festivo_mes
        CHECK (mes IS NULL OR mes BETWEEN 1 AND 12),

    CONSTRAINT chk_festivo_calculo
        CHECK (
            (dia IS NOT NULL AND mes IS NOT NULL)
            OR
            (diaspascua IS NOT NULL)
        )
);


-- ============================================================
-- 4. TABLA CALENDARIO
-- ============================================================
-- Representa el calendario de un país para un año específico.
--
-- Ejemplos:
-- Colombia - 2026
-- Colombia - 2027
-- Colombia - 2028
--
-- El año permite:
--   - determinar si es bisiesto
--   - determinar si tiene 365 o 366 días
--   - calcular Domingo de Pascua
--   - calcular los festivos dependientes de Pascua
--   - generar el calendario anual
-- ============================================================

CREATE TABLE IF NOT EXISTS calendario (
    id BIGSERIAL PRIMARY KEY,

    anio INTEGER NOT NULL,

    idpais BIGINT NOT NULL,

    CONSTRAINT uq_calendario_anio_pais
        UNIQUE (anio, idpais),

    CONSTRAINT chk_calendario_anio
        CHECK (anio BETWEEN 1900 AND 2100),

    CONSTRAINT fk_calendario_pais
        FOREIGN KEY (idpais)
        REFERENCES pais(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================================
-- 5. ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_festivo_pais
    ON festivo(idpais);

CREATE INDEX IF NOT EXISTS idx_festivo_tipo
    ON festivo(idtipofestivo);

CREATE INDEX IF NOT EXISTS idx_calendario_pais
    ON calendario(idpais);

CREATE INDEX IF NOT EXISTS idx_calendario_anio
    ON calendario(anio);


-- ============================================================
-- FIN DEL DDL
-- ============================================================