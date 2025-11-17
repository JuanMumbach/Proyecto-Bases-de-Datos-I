En este trabajo práctico, se implementó lógica de negocio directamente en la base de datos SistemaTicketsDB mediante el uso de Procedimientos Almacenados (SP) y Funciones Almacenadas (FN), cumpliendo con las consignas del Tema 1.

Las siguientes actividades fueron realizadas para este fin

1. Creación de Procedimientos Almacenados (CRUD)

(Tarea 1) Se crearon tres procedimientos almacenados transaccionales. Es fundamental que todas las operaciones de modificación (INSERT, UPDATE, DELETE) registren automáticamente un evento en la tabla Historial para mantener la trazabilidad.

sp_CrearNuevoTicket Recibe los datos del usuario y la categoría, e inserta un nuevo registro en dbo.Tickets y su correspondiente evento de Ticket Creado en dbo.Historial.

sp_ModificarTicket Permite a un técnico modificar un ticket (asignárselo, cambiar estado o prioridad). Automáticamente, inserta un registro en dbo.Historial con el detalle del cambio (ej. Estado cambiado a En Proceso).

sp_BorrarTicketLogico Siguiendo el diseño de la base de datos, este SP no realiza un DELETE físico. En su lugar, ejecuta un borrado lógico (UPDATE dbo.Tickets SET activo = 0). Además, registra en el Historial que el ticket fue Dado de baja lógicamente.

2. Creación de Funciones Almacenadas

(Tarea 4) Se desarrollaron tres funciones escalares para encapsular cálculos y consultas comunes.

fn_ObtenerNombreUsuario Recibe un id_usuario y devuelve el nombre (VARCHAR) de ese usuario. Útil para mostrar en reportes.

fn_CalcularAntiguedadTicket Recibe un id_ticket y devuelve un número (INT) que representa los días que han pasado desde la fecha_creacion del ticket (ej. calcular la edad).

fn_ContarTicketsAbiertosPorTecnico Recibe un id_tecnico y devuelve un número (INT) de cuántos tickets tiene ese técnico asignados que no estén Cerrado.

3. Pruebas de Ejecución (Tareas 2 y 3)

El script T-SQL asociado (tarea_procedimientos_funciones.sql) incluye una sección de Pruebas donde se demuestra el funcionamiento

Prueba de Lote INSERT (Tarea 2) Se inserta un lote de 3 tickets usando sentencias INSERT directas.

Prueba de Lote sp_CrearNuevoTicket (Tarea 2) Se inserta un segundo lote de 3 tickets invocando al SP sp_CrearNuevoTicket en un bucle (WHILE).

Prueba de sp_ModificarTicket (Tarea 3) Se modifica uno de los tickets creados mediante INSERT directo, invocando a sp_ModificarTicket.

Prueba de sp_BorrarTicketLogico (Tarea 3) Se borra lógicamente otro de los tickets creados invocando a sp_BorrarTicketLogico.

Prueba de Funciones (Tarea 4) Se ejecutan las 3 funciones (fn_...) para demostrar su salida.

El uso de Procedimientos Almacenados nos permite encapsular la lógica de negocio (como la obligación de registrar en el historial) y garantizar la atomicidad de las operaciones con transacciones. Insertar mediante SPs es más seguro y asegura que se cumplan todas las reglas de negocio (como crear el historial), algo que un INSERT directo no hace.

Las Funciones nos permiten reutilizar código y simplificar las consultas que se harían desde la aplicación, mejorando el mantenimiento del sistema.