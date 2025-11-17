/*
================================================================================================
|| PROYECTO: SISTEMA DE GESTIÓN DE TICKETS
|| ASIGNATURA: BASE DE DATOS I
|| TEMA 1: Procedimientos y funciones almacenadas
|| AUTORES: Cabrera, Fernandez, Mumbach, Pavon
|| FECHA: 15/11/2025
================================================================================================
*/

-- -------------------------------------------------------------------
-- 0. CONFIGURACIÓN INICIAL Y LIMPIEZA
-- -------------------------------------------------------------------
USE SistemaTicketsDB;
GO

PRINT '--- 0. Limpiando SPs y Funciones anteriores (si existen)... ---';

-- Limpieza de SPs
IF OBJECT_ID('sp_CrearNuevoTicket', 'P') IS NOT NULL DROP PROCEDURE sp_CrearNuevoTicket;
IF OBJECT_ID('sp_ModificarTicket', 'P') IS NOT NULL DROP PROCEDURE sp_ModificarTicket;
IF OBJECT_ID('sp_BorrarTicketLogico', 'P') IS NOT NULL DROP PROCEDURE sp_BorrarTicketLogico;
GO

-- Limpieza de Funciones
IF OBJECT_ID('fn_ObtenerNombreUsuario', 'FN') IS NOT NULL DROP FUNCTION fn_ObtenerNombreUsuario;
IF OBJECT_ID('fn_CalcularAntiguedadTicket', 'FN') IS NOT NULL DROP FUNCTION fn_CalcularAntiguedadTicket;
IF OBJECT_ID('fn_ContarTicketsAbiertosPorTecnico', 'FN') IS NOT NULL DROP FUNCTION fn_ContarTicketsAbiertosPorTecnico;
GO

PRINT '--- Limpieza finalizada. ---';
GO

-- -------------------------------------------------------------------
-- 1. CREACIÓN DE PROCEDIMIENTOS ALMACENADOS (Tarea 1)
-- -------------------------------------------------------------------

-- 1.1 SP para INSERTAR (CREATE)
PRINT 'Creando sp_CrearNuevoTicket...';
GO
CREATE PROCEDURE sp_CrearNuevoTicket
    @id_usuario_creador INT,
    @id_categoria_problema INT,
    @descripcion_problema VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoTicketID INT;
    BEGIN TRANSACTION;
    BEGIN TRY
        
        INSERT INTO dbo.Ticket (descripcion, prioridad, estado, id_usuario, id_tecnico, id_categoria)
        VALUES (@descripcion_problema, 'Media', 'Abierto', @id_usuario_creador, NULL, @id_categoria_problema);

        SET @NuevoTicketID = SCOPE_IDENTITY();

        -- El SP asegura que el historial se cree
        INSERT INTO dbo.Historial (comentario, id_ticket, registrado_por_usuario)
        VALUES ('Ticket creado por el usuario vía SP.', @NuevoTicketID, @id_usuario_creador);

        COMMIT TRANSACTION;
        PRINT '-> SP: Ticket ' + CAST(@NuevoTicketID AS VARCHAR) + ' creado exitosamente.';
        SELECT * FROM dbo.Ticket WHERE id_ticket = @NuevoTicketID; -- Devuelve el ticket creado

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT '-> SP: Error al crear ticket.';
        THROW;
    END CATCH
END
GO

-- 1.2 SP para MODIFICAR (UPDATE)
PRINT 'Creando sp_ModificarTicket...';
GO
CREATE PROCEDURE sp_ModificarTicket
    @id_ticket_modificar INT,
    @id_tecnico_registra INT, -- Quién hace el cambio
    @nuevo_estado VARCHAR(50) = NULL,
    @nueva_prioridad VARCHAR(50) = NULL,
    @nuevo_tecnico_asignado INT = NULL,
    @comentario_adicional VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ComentarioHistorial VARCHAR(MAX) = 'Técnico (ID ' + CAST(@id_tecnico_registra AS VARCHAR) + ') actualizó el ticket: ';
    
    BEGIN TRANSACTION;
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM dbo.Ticket WHERE id_ticket = @id_ticket_modificar AND activo = 1)
        BEGIN
            PRINT 'Error: El ticket no existe o está inactivo.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Construir el comentario para el historial
        IF @nuevo_estado IS NOT NULL 
        BEGIN
            UPDATE dbo.Ticket SET estado = @nuevo_estado WHERE id_ticket = @id_ticket_modificar;
            SET @ComentarioHistorial = @ComentarioHistorial + 'Estado cambiado a [' + @nuevo_estado + ']. ';
        END
        
        IF @nueva_prioridad IS NOT NULL
        BEGIN
            UPDATE dbo.Ticket SET prioridad = @nueva_prioridad WHERE id_ticket = @id_ticket_modificar;
            SET @ComentarioHistorial = @ComentarioHistorial + 'Prioridad cambiada a [' + @nueva_prioridad + ']. ';
        END

        IF @nuevo_tecnico_asignado IS NOT NULL
        BEGIN
            UPDATE dbo.Ticket SET id_tecnico = @nuevo_tecnico_asignado WHERE id_ticket = @id_ticket_modificar;
            SET @ComentarioHistorial = @ComentarioHistorial + 'Asignado a Técnico ID [' + CAST(@nuevo_tecnico_asignado AS VARCHAR) + ']. ';
        END

        IF @comentario_adicional IS NOT NULL
        BEGIN
             SET @ComentarioHistorial = @ComentarioHistorial + 'Comentario: [' + @comentario_adicional + '].';
        END

        -- El SP asegura que el historial se cree
        INSERT INTO dbo.Historial (comentario, id_ticket, registrado_por_tecnico)
        VALUES (@ComentarioHistorial, @id_ticket_modificar, @id_tecnico_registra);

        COMMIT TRANSACTION;
        PRINT '-> SP: Ticket ' + CAST(@id_ticket_modificar AS VARCHAR) + ' modificado exitosamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT '-> SP: Error al modificar ticket.';
        THROW;
    END CATCH
END
GO

-- 1.3 SP para BORRAR (DELETE LÓGICO)
PRINT 'Creando sp_BorrarTicketLogico...';
GO
CREATE PROCEDURE sp_BorrarTicketLogico
    @id_ticket_borrar INT,
    @id_tecnico_registra INT -- Quién hace el cambio
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.Ticket WHERE id_ticket = @id_ticket_borrar)
        BEGIN
            PRINT 'Error: El ticket no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 1. Actualizar el ticket a inactivo (Borrado Lógico)
        UPDATE dbo.Ticket
        SET activo = 0,
            estado = 'Cerrado (Borrado)'
        WHERE id_ticket = @id_ticket_borrar;

        -- 2. El SP asegura que el historial se cree
        INSERT INTO dbo.Historial (comentario, id_ticket, registrado_por_tecnico)
        VALUES ('Ticket dado de baja (borrado lógico) por Técnico ID ' + CAST(@id_tecnico_registra AS VARCHAR), @id_ticket_borrar, @id_tecnico_registra);

        COMMIT TRANSACTION;
        PRINT '-> SP: Ticket ' + CAST(@id_ticket_borrar AS VARCHAR) + ' borrado (lógicamente) exitosamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT '-> SP: Error al borrar lógicamente el ticket.';
        THROW;
    END CATCH
END
GO

PRINT '--- 1. Creación de SPs finalizada. ---';
GO

-- -------------------------------------------------------------------
-- 2. CREACIÓN DE FUNCIONES ALMACENADAS (Tarea 4)
-- -------------------------------------------------------------------

-- 2.1 Función para obtener el nombre de un usuario
PRINT 'Creando fn_ObtenerNombreUsuario...';
GO
CREATE FUNCTION fn_ObtenerNombreUsuario (@id_usuario INT)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @NombreUsuario VARCHAR(255);
    SELECT @NombreUsuario = nombre FROM dbo.Usuario WHERE id_usuario = @id_usuario;
    RETURN @NombreUsuario;
END
GO

-- 2.2 Función para calcular la antigüedad (en días) de un ticket
PRINT 'Creando fn_CalcularAntiguedadTicket...';
GO
CREATE FUNCTION fn_CalcularAntiguedadTicket (@id_ticket INT)
RETURNS INT
AS
BEGIN
    DECLARE @DiasAbierto INT;
    SELECT @DiasAbierto = DATEDIFF(DAY, fecha_creacion, GETDATE()) FROM dbo.Ticket WHERE id_ticket = @id_ticket;
    RETURN @DiasAbierto;
END
GO

-- 2.3 Función para contar tickets abiertos de un técnico
PRINT 'Creando fn_ContarTicketsAbiertosPorTecnico...';
GO
CREATE FUNCTION fn_ContarTicketsAbiertosPorTecnico (@id_tecnico INT)
RETURNS INT
AS
BEGIN
    DECLARE @NumTickets INT;
    SELECT @NumTickets = COUNT(*) 
    FROM dbo.Ticket 
    WHERE id_tecnico = @id_tecnico AND estado <> 'Cerrado' AND activo = 1;
    RETURN @NumTickets;
END
GO

PRINT '--- 2. Creación de Funciones finalizada. ---';
GO

-- -------------------------------------------------------------------
-- 3. PRUEBA DE CARGA DE DATOS (Tarea 2)
-- -------------------------------------------------------------------
PRINT '--- 3. Iniciando Pruebas de Carga de Lotes... ---';
GO

-- 3.1 PRUEBA DE LOTE CON INSERT DIRECTO
PRINT '--- Lote 1: INSERT directo (3 tickets)... ---';

-- CORRECCIÓN: Declaramos las variables DENTRO de este lote
DECLARE @UsuarioPrueba_L1 INT = 1; 
DECLARE @CategoriaPrueba_L1 INT = 2; 

INSERT INTO dbo.Ticket (descripcion, prioridad, estado, id_usuario, id_tecnico, id_categoria) -- CORREGIDO A PLURAL
VALUES 
('Impresora no funciona (Lote 1)', 'Media', 'Abierto', @UsuarioPrueba_L1, NULL, @CategoriaPrueba_L1),
('Mouse no detectado (Lote 1)', 'Baja', 'Abierto', @UsuarioPrueba_L1, NULL, @CategoriaPrueba_L1),
('Monitor parpadea (Lote 1)', 'Alta', 'Abierto', @UsuarioPrueba_L1, NULL, @CategoriaPrueba_L1);
GO

PRINT '-> Lote 1 insertado. (Note que NO se creó historial para estos tickets)';
SELECT * FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 1)%'; -- CORREGIDO A PLURAL
SELECT * FROM dbo.Historial WHERE id_ticket IN (SELECT id_ticket FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 1)%'); -- CORREGIDO A PLURAL
GO

-- 3.2 PRUEBA DE LOTE CON STORED PROCEDURE
PRINT '--- Lote 2: INSERT vía SP (3 tickets)... ---';

-- CORRECCIÓN: Volvemos a declarar las variables para ESTE NUEVO LOTE
DECLARE @UsuarioPrueba_L2 INT = 1; 
DECLARE @CategoriaPrueba_L2 INT = 2; 

DECLARE @Counter INT = 1;
WHILE @Counter <= 3
BEGIN
    EXEC sp_CrearNuevoTicket
        @id_usuario_creador = @UsuarioPrueba_L2,
        @id_categoria_problema = @CategoriaPrueba_L2,
        @descripcion_problema = 'Pantalla azul al iniciar (Lote 2)';
    SET @Counter = @Counter + 1;
END;
GO

PRINT '-> Lote 2 insertado. (El SP SÍ creó el historial para estos tickets)';
SELECT * FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 2)%'; -- CORREGIDO A PLURAL
SELECT * FROM dbo.Historial WHERE id_ticket IN (SELECT id_ticket FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 2)%'); -- CORREGIDO A PLURAL
GO

-- -------------------------------------------------------------------
-- 4. PRUEBAS DE FUNCIONAMIENTO (Tareas 3 y 4)
-- -------------------------------------------------------------------
PRINT '--- 4. Iniciando Pruebas de Funcionamiento (Update/Delete/Funciones)... ---';
GO

-- CORRECCIÓN: Volvemos a declarar las variables para ESTE NUEVO LOTE
DECLARE @TicketID_Modificar INT;
DECLARE @TicketID_Borrar INT;
DECLARE @TecnicoPrueba INT = 1; -- Asume que el Técnico con ID 1 (Juan) existe

-- Capturamos IDs de los lotes que creamos para las pruebas
SET @TicketID_Modificar = (SELECT TOP 1 id_ticket FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 1)%' AND estado = 'Abierto');
SET @TicketID_Borrar = (SELECT TOP 1 id_ticket FROM dbo.Ticket WHERE descripcion LIKE '%(Lote 2)%' AND estado = 'Abierto');

-- 4.1 PRUEBA DE UPDATE (Tarea 3)
PRINT '--- Prueba UPDATE: Asignando y cambiando estado del Ticket ' + CAST(@TicketID_Modificar AS VARCHAR) + '... ---';
EXEC sp_ModificarTicket
    @id_ticket_modificar = @TicketID_Modificar,
    @id_tecnico_registra = @TecnicoPrueba,
    @nuevo_estado = 'En Proceso',
    @nuevo_tecnico_asignado = @TecnicoPrueba,
    @comentario_adicional = 'Técnico revisando el caso (Prueba Tarea 3).';


-- 4.2 PRUEBA DE DELETE LÓGICO (Tarea 3)
PRINT '--- Prueba DELETE: Dando de baja lógicamente el Ticket ' + CAST(@TicketID_Borrar AS VARCHAR) + '... ---';
EXEC sp_BorrarTicketLogico
    @id_ticket_borrar = @TicketID_Borrar,
    @id_tecnico_registra = @TecnicoPrueba;
GO

-- 4.3 PRUEBA DE FUNCIONES (Tarea 4)
PRINT '--- Pruebas de Funciones ---';
SELECT 'Prueba fn_ObtenerNombreUsuario (ID 1):' AS Prueba, dbo.fn_ObtenerNombreUsuario(1) AS Resultado;
SELECT 'Prueba fn_CalcularAntiguedadTicket (ID 1):' AS Prueba, dbo.fn_CalcularAntiguedadTicket(1) AS 'Días Abierto';
SELECT 'Prueba fn_ContarTicketsAbiertosPorTecnico (ID 1):' AS Prueba, dbo.fn_ContarTicketsAbiertosPorTecnico(1) AS 'Tickets Abiertos';
GO

PRINT '--- Fin del script Tarea 1 (SPs y Funciones) ---';