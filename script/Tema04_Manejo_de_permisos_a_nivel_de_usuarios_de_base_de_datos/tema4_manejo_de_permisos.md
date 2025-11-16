Trabajo Práctico: Manejo de Permisos a Nivel de Usuarios en Base de Datos

Proyecto: Sistema de Gestión de Tickets
Base de Datos: SistemaTicketsDB

En este trabajo práctico, se desarrollaron configuraciones de permisos en la base de datos SistemaTicketsDB, diseñada para gestionar tickets de soporte, usuarios y técnicos. Se enfocó en la asignación de permisos a usuarios individuales y roles, asegurando que el acceso a los datos sea seguro y controlado.

Las siguientes actividades fueron realizadas para este fin:

1. Creación de Usuarios con Permisos Diferenciados

En una base de datos, los permisos de usuario se asignan para limitar o permitir acciones como lectura (SELECT), inserción (INSERT), actualización (UPDATE) o eliminación (DELETE). Estos permisos permiten que los administradores controlen el acceso a datos críticos, impidiendo modificaciones no autorizadas.

Implementación

Se crearon dos usuarios con niveles de acceso diferenciados:

Usuario con Permiso de Administrador (AdminTickets): Este usuario fue asignado al rol db_owner, que proporciona acceso completo a la base de datos. Así, puede realizar todas las operaciones sobre las tablas (Tickets, Usuario, Historial, etc.) sin restricciones.

Usuario con Permiso de Solo Lectura (UsuarioFinal_Lectura): Este usuario solo tiene permisos de lectura sobre la tabla Tickets. Puede realizar consultas (SELECT) en Tickets, pero no tiene capacidad para modificar, borrar o insertar datos.

Prueba

Se verificó el acceso de cada usuario. Mientras que AdminTickets podía insertar y leer datos sin restricciones, UsuarioFinal_Lectura sólo pudo realizar consultas (SELECT) en la tabla Tickets, recibiendo un error al intentar un INSERT o UPDATE directo.

2. Asignación de Permisos de Ejecución de Procedimientos Almacenados

Los procedimientos almacenados (SP) permiten encapsular lógicas específicas (como la creación de un ticket) y ejecutarlas mediante permisos controlados. Asignar permisos de EXECUTE sobre un SP permite a los usuarios realizar operaciones indirectas sin tener acceso directo a las tablas.

Implementación

Se utilizó el procedimiento almacenado sp_CrearNuevoTicket (creado para el Tema 2), que inserta un registro en Tickets y otro en Historial de forma transaccional.

Al usuario UsuarioFinal_Lectura (que solo tiene permisos de SELECT a la tabla), se le otorgó adicionalmente el permiso de EXECUTE sobre sp_CrearNuevoTicket.

Prueba

Esta fue la prueba central de la Tarea 1:

UsuarioFinal_Lectura intentó insertar un ticket directamente con una sentencia INSERT INTO Tickets (...) y recibió un error, ya que solo tiene permisos de lectura sobre la tabla.

UsuarioFinal_Lectura intentó insertar un ticket usando el SP (EXEC sp_CrearNuevoTicket ...) y la operación fue exitosa. El ticket se creó correctamente en la tabla Tickets y su correspondiente registro en Historial.

Esto demuestra cómo un usuario sin permisos de escritura puede insertar datos de forma segura y controlada.

3. Creación de Roles para Simplificar la Gestión de Permisos

Los roles en bases de datos permiten agrupar permisos y asignarlos a múltiples usuarios de forma más eficiente. Un rol puede contener permisos específicos que se aplican a todos los usuarios asignados a él.

Implementación

Se creó el rol Rol_Ver_Categorias, que otorga permisos de SELECT (lectura) únicamente sobre la tabla Categoria_Problema. Se crearon dos usuarios adicionales:

UsuarioConRol: Fue asignado al rol Rol_Ver_Categorias.

UsuarioSinRol: No tiene ningún rol ni permiso asignado.

Prueba

UsuarioConRol pudo consultar los datos en Categoria_Problema (SELECT \* FROM Categoria_Problema) gracias a su asignación al rol.

UsuarioSinRol, al no tener permisos de lectura, no pudo acceder a Categoria_Problema y recibió un error al intentar realizar la misma consulta.

Conclusión

La gestión de permisos en la base de datos SistemaTicketsDB proporciona un entorno seguro y organizado al:

Proteger los Datos: Se limita el acceso solo a usuarios autorizados (AdminTickets vs. UsuarioFinal_Lectura), minimizando el riesgo de manipulaciones no autorizadas.

Facilitar la Administración con Roles: La creación del rol Rol_Ver_Categorias simplifica la asignación de permisos de lectura a grupos de usuarios.

Aumentar la Flexibilidad mediante Procedimientos Almacenados: Se permite a los usuarios (como UsuarioFinal_Lectura) realizar acciones controladas (como la creación de tickets) mediante permisos de EXECUTE en procedimientos específicos, sin otorgar acceso directo de INSERT a las tablas.

Este esquema de permisos es fundamental para asegurar que cada usuario acceda solo a las funcionalidades y datos necesarios, maximizando la seguridad y la eficacia en el manejo de la información dentro del sistema de tickets.
