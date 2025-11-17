/* ==========================================================
   TEMA 02 - OPTIMIZACIÓN DE CONSULTAS MEDIANTE ÍNDICES
   Tabla: Tickets (Sistema de Gestión de Tickets)
   Integrador - Bases de Datos I
   ========================================================== */

-- 1) Seleccionar la base de datos del proyecto
USE SistemaTickets;   -- Cambiar si usaste otro nombre de BD
GO

-- 2) Verificar que exista la tabla Tickets
IF OBJECT_ID('dbo.Tickets', 'U') IS NULL
BEGIN
    RAISERROR('La tabla dbo.Tickets no existe. Revisar script_DDL_SistemaTickets.', 16, 1);
    RETURN;
END
GO

/* ==========================================================
   CARGA MASIVA SOBRE TICKETS (1.000.000 REGISTROS)
   Requisito del integrador:
   - Tabla con campo fecha
   - Script automatizable
   ========================================================== */

SET NOCOUNT ON;
GO

;WITH N AS (
    SELECT TOP (1000000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Tickets (
    fecha_creacion,
    descripcion,
    prioridad,
    estado,
    id_usuario,
    id_tecnico,
    id_categoria,
    user_create,
    activo
)
SELECT
    DATEADD(MINUTE, n, '2024-01-01') AS fecha_creacion,  -- Distribuye fechas a lo largo del tiempo
    CONCAT('Ticket generado automáticamente #', n) AS descripcion,
    CASE (n % 3)
        WHEN 0 THEN 'Alta'
        WHEN 1 THEN 'Media'
        ELSE 'Baja'
    END AS prioridad,
    CASE (n % 4)
        WHEN 0 THEN 'Abierto'
        WHEN 1 THEN 'En Progreso'
        WHEN 2 THEN 'Resuelto'
        ELSE 'Cerrado'
    END AS estado,
    1 AS id_usuario,       -- Asegurarse que exista Usuario con id_usuario = 1
    NULL AS id_tecnico,    -- Sin técnico asignado (nullable)
    1 AS id_categoria,     -- Asegurarse que exista Categoria_Problema con id_categoria = 1
    SUSER_SNAME() AS user_create,
    1 AS activo;
GO
/* ==========================================================
   ELIMINAR ÍNDICES PREVIOS SOBRE fecha_creacion (SI EXISTEN)
   Para partir de un escenario "sin índice"
   ========================================================== */

IF EXISTS (SELECT 1 FROM sys.indexes 
           WHERE name = 'IX_Tickets_FechaCreacion'
             AND object_id = OBJECT_ID('dbo.Tickets'))
    DROP INDEX IX_Tickets_FechaCreacion ON dbo.Tickets;
GO

IF EXISTS (SELECT 1 FROM sys.indexes 
           WHERE name = 'IX_Tickets_FechaCreacion_Incl'
             AND object_id = OBJECT_ID('dbo.Tickets'))
    DROP INDEX IX_Tickets_FechaCreacion_Incl ON dbo.Tickets;
GO

/* ==========================================================
   ESCENARIO 1: SIN ÍNDICE SOBRE fecha_creacion
   - Medir tiempos y lecturas
   - Observar plan (Table Scan)
   ========================================================== */

-- Activar estadísticas
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- IMPORTANTE: Activar en SSMS:
--   Query -> Include Actual Execution Plan
-- antes de ejecutar este bloque.

SELECT
    t.fecha_creacion,
    t.descripcion,
    t.estado,
    t.prioridad
FROM dbo.Tickets AS t
WHERE t.fecha_creacion BETWEEN '2024-03-01' AND '2024-04-01'
ORDER BY t.fecha_creacion;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
/* ==========================================================
   ESCENARIO 2: ÍNDICE NO AGRUPADO SOBRE fecha_creacion
   (equivalente a la idea de "índice agrupado sobre fecha"
    planteada en la consigna, considerando que la PK ya
    utiliza el índice agrupado de la tabla).
   ========================================================== */

CREATE NONCLUSTERED INDEX IX_Tickets_FechaCreacion
ON dbo.Tickets(fecha_creacion);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    t.fecha_creacion,
    t.descripcion,
    t.estado,
    t.prioridad
FROM dbo.Tickets AS t
WHERE t.fecha_creacion BETWEEN '2024-03-01' AND '2024-04-01'
ORDER BY t.fecha_creacion;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO



/* ==========================================================
   ELIMINAR ÍNDICE IX_Tickets_FechaCreacion
   (requisito de la consigna)
   ========================================================== */

DROP INDEX IX_Tickets_FechaCreacion ON dbo.Tickets;
GO

/* ==========================================================
   ESCENARIO 3: ÍNDICE NO AGRUPADO CUBRIENTE SOBRE fecha_creacion
   - Clave: fecha_creacion
   - Columnas incluidas: descripcion, estado, prioridad
   - Busca que toda la consulta "viva" dentro del índice
   ========================================================== */

CREATE NONCLUSTERED INDEX IX_Tickets_FechaCreacion_Incl
ON dbo.Tickets(fecha_creacion)
INCLUDE (descripcion, estado, prioridad);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    t.fecha_creacion,
    t.descripcion,
    t.estado,
    t.prioridad
FROM dbo.Tickets AS t
WHERE t.fecha_creacion BETWEEN '2024-03-01' AND '2024-04-01'
ORDER BY t.fecha_creacion;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

