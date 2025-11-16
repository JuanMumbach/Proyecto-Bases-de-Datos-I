USE SistemaTicketsDB;
GO

---------------------------------------------------------------------
-- PREPARACIÓN Y RESET DE DATOS (IMPORTANTE: Ejecutar siempre primero)
---------------------------------------------------------------------

-- 1. Restaurar el Ticket 1 a un estado no asignado para la prueba de Éxito.
UPDATE Ticket
SET 
    id_tecnico = NULL, 
    estado = 'Abierto'
WHERE id_ticket = 1;

-- 2. Limpiar registros de historial previos para la Prueba 1.
DELETE FROM Historial 
WHERE comentario LIKE 'Ticket asignado a técnico y puesto En proceso.';

PRINT '--- PREPARACIÓN COMPLETA. Ticket 1 restaurado. ---';
GO

---------------------------------------------------
-- PRUEBA 1: TRANSACCIÓN DE ÉXITO (COMMIT)
-- Objetivo: Demostrar que el UPDATE y el INSERT se confirman juntos.
---------------------------------------------------

PRINT '--- PRUEBA 1: Transacción de Éxito (COMMIT) ---';

-- Paso 1: Verificar el estado inicial del ticket ID 1
SELECT id_ticket, estado, id_tecnico AS Tecnico_Antes FROM Ticket WHERE id_ticket = 1;

-- Paso 2: Iniciar la Transacción (Actualización + Inserción)
BEGIN TRANSACTION AsignacionYRegistro; 

BEGIN TRY
    -- 1. DML ÉXITO: Asignar Ticket 1 al Técnico 2 y cambiar estado
    UPDATE Ticket
    SET 
        id_tecnico = 2, 
        estado = 'En proceso'
    WHERE id_ticket = 1;

    -- 2. DML ÉXITO: Registrar el evento en el historial
    INSERT INTO Historial (comentario, id_ticket, registrado_por_usuario, registrado_por_tecnico)
    VALUES ('Ticket asignado a técnico y puesto En proceso.', 1, NULL, 2);

    -- 3. Si ambos DML anteriores fueron exitosos, confirmar los cambios
    COMMIT TRANSACTION AsignacionYRegistro; 
    PRINT 'Transacción de Éxito: COMMIT realizado. Los cambios son permanentes.'; 

END TRY
BEGIN CATCH
    -- Si ocurre algún error, deshacer todos los cambios
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION AsignacionYRegistro;
        
    PRINT 'Transacción de Éxito: ¡FALLO inesperado! ROLLBACK realizado.';
    THROW;
END CATCH

-- Paso 3: Verificar el estado final (Debe mostrar id_tecnico = 2 y estado = 'En proceso')
SELECT id_ticket, estado, id_tecnico AS Tecnico_Despues FROM Ticket WHERE id_ticket = 1;
SELECT comentario FROM Historial WHERE id_ticket = 1 AND registrado_por_tecnico = 2;
GO

---------------------------------------------------
-- PRUEBA 2: TRANSACCIÓN DE FALLO (ROLLBACK)
-- Objetivo: Demostrar que el error forzado revierte los DML anteriores exitosos.
---------------------------------------------------

PRINT '--- PRUEBA 2: Transacción de Fallo (ROLLBACK) ---';

-- Paso 1: Contar registros iniciales en Historial para la verificación del ROLLBACK
DECLARE @CountBefore INT;
SELECT @CountBefore = COUNT(*) FROM Historial;
PRINT 'Total de registros en Historial ANTES del intento: ' + CAST(@CountBefore AS VARCHAR);

BEGIN TRANSACTION InsercionFallida;

BEGIN TRY
    -- 1. DML ÉXITO TEMPORAL: Insertar un ticket (Este cambio será revertido)
    INSERT INTO Ticket (descripcion, prioridad, estado, id_usuario, id_categoria, id_tecnico)
    VALUES ('Ticket temporal antes de fallo.', 'Baja', 'Abierto', 1, 1, NULL);
    
    DECLARE @TicketFallidoID INT = SCOPE_IDENTITY();

    -- 2. DML ÉXITO TEMPORAL: Insertar en Historial (Este cambio será revertido)
    INSERT INTO Historial (comentario, id_ticket, registrado_por_usuario, registrado_por_tecnico)
    VALUES ('Registro temporal antes de fallo.', @TicketFallidoID, 1, NULL);

    -- 3. FORZAR FALLO: Insertar en Ticket con una FK inexistente (id_usuario = 999)
    INSERT INTO Ticket (descripcion, prioridad, estado, id_usuario, id_categoria, id_tecnico)
    VALUES ('FALLO FORZADO', 'Alta', 'Abierto', 999, 1, NULL); 
    
    -- Este COMMIT NUNCA se ejecuta
    COMMIT TRANSACTION InsercionFallida;
    
END TRY
BEGIN CATCH
    -- El error de la FK activa este bloque
    PRINT 'Error detectado. Mensaje: ' + ERROR_MESSAGE();
    
    -- Se hace ROLLBACK para deshacer TODOS los pasos (1 y 2)
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION InsercionFallida; 
        
    PRINT 'Transacción de Fallo: ROLLBACK realizado. Todos los cambios deshechos.'; 
END CATCH

-- Paso 3: Verificar el estado final (Prueba de Atomicidad)
-- El ticket insertado en el paso 1 NO debe existir (cero filas).
SELECT * FROM Ticket WHERE descripcion LIKE 'Ticket temporal antes de fallo.';
-- El conteo debe ser igual al total ANTES del intento.
SELECT COUNT(*) AS Total_Historial_Despues FROM Historial; 
GO

