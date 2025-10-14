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

## Año: 2024

- - -  

# CAPÍTULO I: INTRODUCCIÓN

Este proyecto se enfoca en el diseño e implementación de una base de datos para la gestión de Tickets que puede ser aplicado tanto a clientes externos o trabajadores internos. El propósito es resolver los problemas de gestión de tickets, su seguimiento y su finalización. El sistema que se desarrollará está orientado a optimizar estos procesos, centralizando toda la información clave en una base de datos relacional.

En la actualidad, las empresas dependen en gran medida de la tecnología para el desarrollo de sus operaciones. Esto genera la necesidad de contar con un área de soporte técnico capaz de atender incidencias de hardware, software, redes o servicios internos de manera rápida y ordenada.

El uso de sistemas o software no dedicado a este objetivo, u organizaciones que registran estos incidentes de forma manual (a través de correos electrónicos, llamadas telefónicas o incluso mensajes informales) provoca desorganización, pérdida de información, retrasos en la atención y dificultad para medir la eficiencia del área de soporte.

Para dar respuesta a esta problemática, se plantea el desarrollo de un sistema de gestión de tickets de soporte técnico. Este sistema permitirá a los usuarios generar solicitudes de asistencia (tickets), que serán asignadas a técnicos responsables y categorizadas según su tipo y prioridad. Cada ticket contará con un historial de acciones que documente las actividades realizadas hasta su resolución.

El objetivo principal es diseñar una base de datos relacional que organice de manera eficiente la información de usuarios, técnicos, tickets y estados, posibilitando un seguimiento integral de cada incidencia. De esta forma, la empresa podrá mejorar la trazabilidad de los problemas, reducir los tiempos de resolución y obtener métricas de desempeño que apoyen la toma de decisiones.

# CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS

## Diccionario de Datos

### Tabla: Usuario
Almacena la información de los usuarios que pueden crear tickets.

| Campo | Tipo de Dato | Longitud | Nulable | Clave | Descripción |
|-------|--------------|----------|----------|-------|-------------|
| id_usuario | INT| 10 | NO | PK | Identificador único del usuario. |
| nombre | VARCHAR | 255 | NO | | Nombre completo del usuario. |
| correo | VARCHAR | 255 | NO | | Dirección de correo electrónico del usuario. |
| telefono | VARCHAR | 20 | SÍ | | Número de teléfono del usuario. |
| empresa | VARCHAR | 255 | SÍ | | Nombre de la empresa a la que pertenece el usuario. |

### Tabla: Tecnico
Almacena la información de los técnicos que resuelven los tickets.

| Campo	| Tipo de Dato | Longitud | Nulable | Clave | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_tecnico | INT | 10 | NO | PK | Identificador único del técnico. |
| nombre | VARCHAR | 255 | NO | | Nombre completo del técnico. |
| correo | VARCHAR | 255 | NO | | Dirección de correo electrónico del técnico. |


### Tabla: Especialidad
Contiene las diferentes especialidades en las que un técnico puede estar calificado.

| Campo | Tipo de Dato |	Longitud |	Nulable	Clave |	Descripción |
| --- | --- | --- | --- | --- |
| id_especialidad | INT | 10 | NO | PK | Identificador único de la especialidad. |
| tipo_especialidad | VARCHAR | 100 | NO | | Nombre o descripción de la especialidad. |


### Tabla: Tecnico_Especialidad
Tabla intermedia para la relación N:M entre Tecnico y Especialidad, indicando qué especialidades tiene cada técnico.

| Campo	| Tipo de Dato |	Longitud |	Nulable	Clave |	Descripción |
| --- | --- | --- | --- | --- |
| id_tecnico | INT | 10 | NO | PK, FK | Identificador del técnico (clave foránea de Tecnico). |
| id_especialidad | INT | 10 | NO | PK, FK | Identificador de la especialidad (clave foránea de Especialidad). |






 
