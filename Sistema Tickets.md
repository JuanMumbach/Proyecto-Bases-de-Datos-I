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

Este proyecto se enfoca en el diseño e implementación de una base de datos para la gestión de Tickets que puede ser aplicado tanto a clientes externos o trabajadores internos. El propósito es resolver los problemas de gestión de tickets, su seguimiento y su finalización. El sistema que se desarrollará está orientado a optimizar estos procesos, centralizando toda la información clave en una base de datos relacional.

En la actualidad, las empresas dependen en gran medida de la tecnología para el desarrollo de sus operaciones. Esto genera la necesidad de contar con un área de soporte técnico capaz de atender incidencias de hardware, software, redes o servicios internos de manera rápida y ordenada.

El uso de sistemas o software no dedicado a este objetivo, u organizaciones que registran estos incidentes de forma manual (a través de correos electrónicos, llamadas telefónicas o incluso mensajes informales) provoca desorganización, pérdida de información, retrasos en la atención y dificultad para medir la eficiencia del área de soporte.

Para dar respuesta a esta problemática, se plantea el desarrollo de un sistema de gestión de tickets de soporte técnico. Este sistema permitirá a los usuarios generar solicitudes de asistencia (tickets), que serán asignadas a técnicos responsables y categorizadas según su tipo y prioridad. Cada ticket contará con un historial de acciones que documente las actividades realizadas hasta su resolución.

El objetivo principal es diseñar una base de datos relacional que organice de manera eficiente la información de usuarios, técnicos, tickets y estados, posibilitando un seguimiento integral de cada incidencia. De esta forma, la empresa podrá mejorar la trazabilidad de los problemas, reducir los tiempos de resolución y obtener métricas de desempeño que apoyen la toma de decisiones.


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

| Campo       | Tipo de Dato | Longitud | Nulable | Clave                        | Descripción                                         |
| ----------- | ------------ | -------- | ------- | ---------------------------- | --------------------------------------------------- |
| id_usuario  | INT          | 10       | NO      | PK                           | Identificador único del usuario(Aut).               |
| nombre      | VARCHAR      | 255      | NO      |                              | Nombre completo del usuario.                        |
| correo      | VARCHAR      | 255      | NO      | UQ                           | Dirección de correo elect del usuario (Único).      |
| telefono    | VARCHAR      | 20       | SÍ      |                              | Número de teléfono del usuario.                     |
| empresa     | VARCHAR      | 255      | SÍ      |                              | Nombre de la empresa a la que pertenece el usuario. |
| date_create | DATETIME     |          | NO      |                              | Auditoría: Fecha y hora de creación del registro.   |
| user_create | VARCHAR      | 100      | NO      |                              | Auditoría: Usuario de BD que creó el registro.      |
| activo      | BIT          |          | NO      |                              | Borrado Lógico: 1 (Activo) o 0 (Inactivo).          |

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
