## Proyecto de Estudio: Diseño e Implementación de una Base de Datos para la Gestión de Tickets.

### Universidad Nacional del Nordeste

### Facultad de Ciencias Exactas y Naturales y Agrimensura

### Asignatura: Bases de Datos I

## Profesores:

Darío O. Villegas  
Juan José Cuzziol  
Walter O. Vallejos  
Numa Badaracco

## Autores:

Cabrera, Wilson Alexis.  
Fernandez, Facundo Nicolás.  
Mumbach, Juan Ignacio.  
Pavon, Máximo David Octavio.

## Año: 2025

---

# CAPÍTULO I: INTRODUCCIÓN

a) Tema

Diseño e Implementación de una Base de Datos Relacional para un Sistema de Gestión de Tickets de Soporte Técnico.

b) Definición o planteamiento del Problema

En la actualidad, las empresas dependen en gran medida de la tecnología para el desarrollo de sus operaciones. Esto genera la necesidad de contar con un área de soporte técnico capaz de atender incidencias de hardware, software, redes o servicios internos de manera rápida y ordenada.

El uso de sistemas o software no dedicado a este objetivo, u organizaciones que registran estos incidentes de forma manual (a través de correos electrónicos, llamadas telefónicas o incluso mensajes informales) provoca desorganización, pérdida de información, retrasos en la atención y dificultad para medir la eficiencia del área de soporte.

c) Objetivo del Trabajo Práctico

i. Preguntas Generales

¿Cómo podemos optimizar la gestión de incidencias, el seguimiento de técnicos y la trazabilidad de las soluciones en un área de soporte?

ii. Preguntas Específicas

¿Cómo podemos registrar una incidencia de forma unificada?

¿Cómo asignamos un técnico responsable a un ticket?

¿Cómo evitamos que un ticket quede "olvidado" sin resolver?

¿Cómo puede un usuario consultar el estado de sus tickets?

¿Cómo medimos el tiempo de respuesta y la eficiencia de los técnicos?

iii. Objetivos Generales

Dar solución a la problemática de la falta de un sistema centralizado para la gestión de incidencias, mejorando la trazabilidad y los tiempos de respuesta del área de soporte.

iv. Objetivos Específicos

Centralizar la creación de tickets de soporte.

Optimizar la asignación de tickets a técnicos según su especialidad.

Permitir un seguimiento integral de cada incidencia a través de un historial.

Obtener métricas de desempeño que apoyen la toma de decisiones.

d) Descripción del Sistema

El sistema de gestión de tickets permitirá a los usuarios (empleados o clientes externos) generar solicitudes de asistencia (tickets). Estos serán asignados a técnicos responsables y categorizados según su tipo y prioridad.

El sistema cuenta con perfiles de Usuario (quien crea el ticket) y Técnico (quien lo resuelve). Cada técnico puede tener una o más Especialidades, y cada ticket se asigna a una Categoría de Problema. La tabla central Tickets vincula al usuario, al técnico y la categoría.

La tabla Historial es fundamental, ya que documenta cada acción (creación, comentario, cambio de estado, asignación) realizada sobre un ticket, garantizando una trazabilidad completa desde que se abre hasta que se cierra.

e) Alcance

El alcance del proyecto se limita al diseño e implementación de la base de datos relacional. Incluye el script de creación de tablas, el diccionario de datos y la investigación de conceptos aplicados (Roles, SPs, Índices, JSON).

# CAPÍTULO II: MARCO CONCEPTUAL O REFERENCIAL

A continuación, se detallan los conceptos teóricos fundamentales de SQL Server que se han investigado y aplicado directamente en el diseño de la base de datos del Sistema de Tickets.

## TEMA 1: "Manejo de permisos a nivel de usuarios de base de datos"

La seguridad es un pilar fundamental de nuestro sistema. Para ello, se utiliza un esquema de permisos y roles para asegurar que los usuarios solo accedan a la información que les corresponde.

### Permisos

Un permiso es una autorización específica para realizar una acción (`SELECT`, `INSERT`, `UPDATE`, etc.) sobre un objeto (como una tabla).

### Roles

Un rol es un "paquete" de permisos que se puede asignar a un usuario. En lugar de dar permisos uno por uno, creamos roles que definen perfiles de trabajo.

**Aplicación en el Sistema de Tickets:**

- **`Rol_UsuarioFinal`**: Este rol solo tendría permiso de `INSERT` sobre la tabla `Tickets` y `SELECT` _únicamente_ sobre los tickets y el historial donde su `id_usuario` coincida con el del registro. Esto impide que un usuario vea los tickets de otros.
- **`Rol_Tecnico`**: Este rol tendría permisos de `SELECT` sobre todas las tablas `Tickets` y `Categoria_Problema`, y permisos de `UPDATE` sobre la tabla `Tickets` (para cambiar el `estado` o asignarse un `id_tecnico`). No tendría permiso para `DELETE`, garantizando la integridad.

Este modelo asegura que los datos estén protegidos y que cada perfil (usuario y técnico) opere solo dentro de su ámbito.

## TEMA 2: "Procedimientos y funciones almacenadas"

Para encapsular la lógica de negocio, centralizar operaciones y mejorar la seguridad, se utiliza lógica almacenada dentro de la base de datos.

### Procedimientos Almacenados (SP)

Son conjuntos de instrucciones SQL que se ejecutan como una unidad.

**Aplicación en el Sistema de Tickets:**
Se crearía un procedimiento `sp_CrearNuevoTicket`. Cuando un usuario crea un ticket, la aplicación no ejecuta dos `INSERT` por separado. En su lugar, llama a este procedimiento pasándole los datos (ej. `id_usuario`, `descripcion`, `id_categoria`).
El SP se encarga de:

1.  Iniciar una transacción.
2.  Hacer `INSERT` en la tabla `Tickets`.
3.  Hacer `INSERT` en la tabla `Historial` (con el comentario "Ticket Creado").
4.  Confirmar la transacción.

Esto garantiza la **atomicidad** (o se hacen las dos inserciones, o no se hace ninguna) y es más seguro, ya que el `Rol_UsuarioFinal` solo tendría permiso de `EXECUTE` sobre este SP, y no permiso de `INSERT` directo sobre las tablas.

### Funciones Almacenadas (FN)

Son rutinas que siempre devuelven un valor y no pueden modificar datos.

**Aplicación en el Sistema de Tickets:**
Se podría crear una función `fn_ContarTicketsAbiertos(@id_tecnico)` que recibe un ID de técnico y devuelve un número entero. Esta función es ideal para un dashboard, permitiendo saber rápidamente cuántos tickets tiene asignados un técnico sin necesidad de ejecutar una consulta compleja desde la aplicación.

## TEMA 3: "Optimización de consultas a través de índices"

Un sistema de tickets puede crecer a miles de registros. Sin una correcta optimización, las consultas se volverían lentas. Los índices son la principal herramienta para garantizar el rendimiento.

### Índices Agrupados (Clustered)

Definen el orden físico de almacenamiento de la tabla. Solo puede haber uno.

**Aplicación en el Sistema de Tickets:**
Por defecto, la `PRIMARY KEY` (`id_ticket`) de la tabla `Tickets` se crea como el **índice agrupado**. Esto significa que la tabla está físicamente ordenada por el ID del ticket. Es la forma más rápida posible de buscar un ticket específico por su número (`WHERE id_ticket = 123`).

### Índices No Agrupados (Non-Clustered)

Son estructuras separadas, como el índice de un libro, que contienen un puntero a la fila de datos.

**Aplicación en el Sistema de Tickets:**
Es **fundamental** crear un **índice no agrupado** en la columna `id_usuario` de la tabla `Tickets`. Cuando un usuario inicie sesión y el sistema ejecute la consulta "mostrar todos mis tickets" (`WHERE id_usuario = 1`), este índice permite al motor encontrar esos tickets instantáneamente, sin tener que escanear la tabla `Tickets` completa. También se crearían índices en `id_tecnico` y `id_categoria` por razones similares.

## TEMA 4: "Manejo de tipos de datos JSON"

Si bien nuestro diseño es puramente relacional y normalizado, SQL Server ofrece flexibilidad para manejar datos semi-estructurados usando JSON.

### ¿Qué es JSON?

Es un formato de texto ligero para intercambiar datos, estándar en aplicaciones web y APIs.

### ¿Por qué se utiliza JSON?

Permite almacenar datos flexibles sin una estructura fija.

**Aplicación en el Sistema de Tickets:**
Aunque no se implementó en el esquema principal, una mejora a futuro podría ser añadir una columna `DatosAdicionales` (de tipo `NVARCHAR(MAX)`) en la tabla `Historial`.
Cuando se crea un ticket (`INSERT` en `Historial`), se podría almacenar información contextual como un JSON:
`{ "navegador": "Chrome 120.0", "SO": "Windows 11", "IP": "200.51.10.3" }`

SQL Server tiene funciones nativas para consultar estos datos JSON si fuera necesario, ofreciendo una gran flexibilidad para almacenar información de diagnóstico sin tener que agregar 10 columnas nuevas a la tabla.

---

# CAPÍTULO III: METODOLOGÍA SEGUIDA

a) Cómo se realizó el Trabajo Práctico

El presente trabajo práctico se desarrolló de manera grupal, fomentando la colaboración y el trabajo coordinado entre los integrantes del equipo.
Para la gestión del proyecto y el trabajo conjunto se utilizaron herramientas colaborativas que facilitaron la comunicación, el control de versiones y la organización de los archivos.

Se empleó GitHub como plataforma principal para el control de versiones y gestión del código, lo que permitió la integración de los aportes de cada integrante y el seguimiento de los cambios realizados en el diseño de la base de datos.
Además, se utilizó Google Drive para el almacenamiento y organización de la documentación, incluyendo reportes, diagramas y avances del proyecto, garantizando la accesibilidad y sincronización de los materiales entre todos los miembros del grupo.

El trabajo se realizó siguiendo una metodología iterativa, donde se fueron desarrollando y ajustando los modelos de datos conforme se analizaban las necesidades del sistema de gestión de tickets. Cada etapa fue validada en conjunto, asegurando la coherencia entre el diseño conceptual, lógico y físico de la base de datos.

b) Herramientas (Instrumentos y procedimientos)

Para el desarrollo del sistema de gestión de tickets, se utilizaron diversas herramientas que facilitaron tanto el diseño conceptual y lógico como la implementación física de la base de datos. Entre las principales se destacan:

ERDPlus: Utilizado para la creación del modelo Entidad–Relación (E–R), permitiendo representar de forma clara las entidades, atributos y relaciones necesarias para el sistema.

Draw.io: Empleado para la elaboración de diagramas complementarios, tales como diagramas de flujo y casos de uso, que ayudaron a comprender los procesos de registro, asignación y resolución de tickets.

SQL Server: Sistema de gestión de base de datos elegido para la implementación del modelo relacional. En esta herramienta se crearon las tablas, claves primarias y foráneas, así como las restricciones necesarias para garantizar la integridad de los datos.

Diagrama Entidad–Relación (DER): Representó de manera visual las entidades del sistema (usuarios, técnicos, tickets, historial, entre otras) y sus respectivas relaciones.

Modelo Relacional: Permitió traducir el modelo conceptual al nivel lógico mediante la definición de las tablas y sus campos con sus respectivos tipos de datos.

Diccionario de Datos: Documentó cada campo, tipo de dato, clave y descripción de todas las tablas que conforman la base de datos, sirviendo como guía técnica para su correcta implementación y mantenimiento.

# CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS

## Diccionario de Datos

Diccionario de Datos
A continuación, se detalla el diccionario de datos que define la estructura de la base de datos relacional para el sistema de gestión de tickets. El diseño incluye columnas de auditoría (date_create, user_create) para rastrear la creación de registros y una columna activo para implementar el borrado lógico (soft delete), preservando la integridad histórica de los datos.

### Tabla: Usuario

Almacena la información de los usuarios que pueden crear tickets.

| Campo       | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                         |
| ----------- | ------------ | -------- | ------- | ----- | --------------------------------------------------- |
| id_usuario  | INT          | 10       | NO      | PK    | Identificador único del usuario(Aut).               |
| nombre      | VARCHAR      | 255      | NO      |       | Nombre completo del usuario.                        |
| correo      | VARCHAR      | 255      | NO      | UQ    | Dirección de correo elect del usuario (Único).      |
| telefono    | VARCHAR      | 20       | SÍ      |       | Número de teléfono del usuario.                     |
| empresa     | VARCHAR      | 255      | SÍ      |       | Nombre de la empresa a la que pertenece el usuario. |
| date_create | DATETIME     |          | NO      |       | Auditoría: Fecha y hora de creación del registro.   |
| user_create | VARCHAR      | 100      | NO      |       | Auditoría: Usuario de BD que creó el registro.      |
| activo      | BIT          |          | NO      |       | Borrado Lógico: 1 (Activo) o 0 (Inactivo).          |

### Tabla: Tecnico

Almacena la información de los técnicos que resuelven los tickets.

| Campo       | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                        |
| ----------- | ------------ | -------- | ------- | ----- | -------------------------------------------------- |
| id_tecnico  | INT          | 10       | NO      | PK    | Identificador único del técnico (Autoincremental). |
| nombre      | VARCHAR      | 255      | NO      | UQ    | Nombre completo del técnico (Único).               |
| correo      | VARCHAR      | 255      | NO      | O     | Nombre completo del técnico.                       |
| date_create | DATETIME     |          | NO      |       | Auditoría: Fecha y hora de creación del registro.  |
| user_create | VARCHAR      | 100      | NO      |       | Auditoría: Usuario de BD que creó el registro.     |
| activo      | BIT          |          | NO      |       | Borrado Lógico: 1 (Activo) o 0 (Inactivo).         |

### Tabla: Especialidad

Contiene las diferentes especialidades en las que un técnico puede estar calificado.

| Campo             | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                      |
| ----------------- | ------------ | -------- | ------- | ----- | ------------------------------------------------ |
| id_especialidad   | INT          | 10       | NO      | PK    | Identificador único de la especialidad(Autoi).   |
| tipo_especialidad | VARCHAR      | 100      | NO      | UQ    | Nombre o descripción de la especialidad (Único). |
| date_create       | DATETIME     |          | NO      |       | Auditoría:Fecha y hora de creación del registro. |
| user_create       | VARCHAR      | 100      | NO      |       | Auditoría: Usuario de BD que creó el registro.   |
| activo            | BIT          |          | NO      |       | Borrado Lógico: 1 (Activo) o 0 (Inactivo).       |

### Tabla: Tecnico_Especialidad

Tabla intermedia para la relación N:M entre Tecnico y Especialidad.

| Campo           | Tipo de Dato | Longitud | Nulable | Clave  | Descripción                                                       |
| --------------- | ------------ | -------- | ------- | ------ | ----------------------------------------------------------------- |
| id_tecnico      | INT          | 10       | NO      | PK, FK | Identificador del técnico (clave foránea de Tecnico).             |
| id_especialidad | INT          | 10       | NO      | PK, FK | Identificador de la especialidad (clave foránea de Especialidad). |
| date_create     | DATETIME     |          | NO      |        | Auditoría: Fecha en que se asignó la especialidad.                |
| user_create     | VARCHAR      | 100      | NO      |        | Auditoría: Usuario de BD que asignó la especialidad.              |

### Tabla: Categoria_Problema

Almacena los diferentes tipos de problemas que un usuario puede reportar.

| Campo        | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                            |
| ------------ | ------------ | -------- | ------- | ----- | ------------------------------------------------------ |
| id_categoria | INT          | 10       | NO      | PK    | Identificador único de la categoría (Autoincremental). |
| nombre       | VARCHAR      | 100      | NO      | UQ    | Nombre de la categoría del problema (Único).           |
| date_create  | DATETIME     |          | NO      |       | Auditoría: Fecha y hora de creación del registro.      |
| user_create  | VARCHAR      | 100      | NO      |       | Auditoría: Usuario de BD que creó el registro.         |
| activo       | BIT          |          | NO      |       | Borrado Lógico: 1 (Activo) o 0 (Inactivo).             |

### Tabla: Tickets

Es la tabla central del sistema. Almacena cada incidencia reportada por los usuarios.

| Campo          | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                                           |
| -------------- | ------------ | -------- | ------- | ----- | --------------------------------------------------------------------- |
| id_ticket      | INT          | 10       | NO      | PK    | Identificador único del ticket (Autoincremental).                     |
| fecha_creacion | DATETIME     |          | NO      |       | Fecha y hora en que se creó el ticket (Valor por defecto: GETDATE()). |
| descripcion    | VARCHAR      | MAX      | NO      |       | Descripción detallada del problema reportado.                         |
| prioridad      | VARCHAR      | 50       | NO      |       | Nivel de urgencia (Valor por defecto: "Media").                       |
| estado         | VARCHAR      | 50       | NO      |       | Estado actual (Valor por defecto: "Abierto").                         |
| id_usuario     | INT          | 10       | NO      | FK    | ID del usuario que reportó el ticket.                                 |
| id_tecnico     | INT          | 10       | SÍ      | FK    | ID del técnico asignado. Es nulo si aún no ha sido asignado.          |
| id_categoria   | INT          | 10       | NO      | FK    | ID de la categoría del problema.                                      |
| user_create    | VARCHAR      | 100      | NO      |       | Auditoría: Usuario de BD que creó el registro.                        |
| activo         | BIT          |          | NO      |       | Borrado Lógico: 1 (Activo) o 0 (Inactivo).                            |

### Tabla: Historial

Registra todos los eventos, comentarios y cambios de estado asociados a un ticket.

| Campo                  | Tipo de Dato | Longitud | Nulable | Clave | Descripción                                                      |
| ---------------------- | ------------ | -------- | ------- | ----- | ---------------------------------------------------------------- |
| id_historial           | INT          | 10       | NO      | PK    | Identificador único del registro de historial (Autoincremental). |
| fecha                  | DATETIME     |          | NO      |       | Fecha y hora del evento (Valor por defecto: GETDATE()).          |
| comentario             | VARCHAR      | MAX      | SÍ      |       | Comentario o descripción de la acción realizada.                 |
| registrado_por_usuario | INT          | 10       | SÍ      | FK    | ID del usuario que registró el evento (si aplica).               |
| registrado_por_tecnico | INT          | 10       | SÍ      | FK    | ID del técnico que registró el evento (si aplica).               |
| id_ticket              | INT          | 10       | NO      | FK    | ID del ticket al que pertenece este historial.                   |

# CAPÍTULO V: BIBLIOGRAFÍA DE CONSULTA

Tema 04 - Manejo de permisos a nivel de usuarios de base de datos
Creación de Logins (Microsoft Learn)
https://learn.microsoft.com/es-es/sql/t-sql/statements/create-login-transact-sql
Creación de Roles (Microsoft Learn)
https://learn.microsoft.com/es-es/sql/t-sql/statements/create-role-transact-sql
Asignación de permisos con GRANT (Microsoft Learn)
https://learn.microsoft.com/es-es/sql/t-sql/statements/grant-transact-sql
Suplantación de permisos con EXECUTE AS (Microsoft Learn)
https://learn.microsoft.com/es-es/sql/t-sql/statements/execute-as-transact-sql
