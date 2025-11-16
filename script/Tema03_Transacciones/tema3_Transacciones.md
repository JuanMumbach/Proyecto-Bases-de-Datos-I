TEMA 3: MANEJO DE TRANSACCIONES Y GARANTÍA DE INTEGRIDAD

Proyecto: Sistema de Gestión de Tickets
Base de Datos: SistemaTicketsDB

I. Fundamento Teórico: Propiedades ACID

Una Transacción es una secuencia de una o más operaciones DML (Data Manipulation Language) que se tratan como una única unidad lógica de trabajo. Es fundamental en cualquier sistema de misión crítica para garantizar la fiabilidad de los datos.

Toda transacción exitosa debe cumplir con las propiedades ACID:

Atomicidad (Atomicity): Una transacción debe completarse en su totalidad, o no completarse en absoluto. Si una parte falla, todas las operaciones se revierten. El uso de ROLLBACK implementa esta propiedad.

Consistencia (Consistency): La transacción lleva la base de datos de un estado válido a otro, manteniendo todas las reglas de integridad (claves foráneas, unicidad, etc.).

Aislamiento (Isolation): Los efectos de una transacción no confirmada son invisibles para otras transacciones concurrentes.

Durabilidad (Durability): Una vez que la transacción se confirma (COMMIT), los cambios son permanentes, incluso si hay un fallo del sistema.

II. Implementación Práctica: Transacciones Controladas

El objetivo fue demostrar la Atomicidad (ROLLBACK) y la Durabilidad (COMMIT) a través de dos pruebas opuestas:

1. Prueba de Éxito: Confirmación (COMMIT)

Objetivo: Asegurar que la asignación de un ticket (UPDATE Ticket) y su registro en el historial (INSERT Historial) se confirmen siempre juntos.

|

| Acción DML | Estado | Mensaje de Control |
| BEGIN TRANSACTION | Inicio del Bloque Atómico. |  |
| UPDATE Ticket | Éxito (Asignación) |  |
| INSERT Historial | Éxito (Registro de la asignación) |  |
| COMMIT TRANSACTION | Confirmación: Los cambios son permanentes. | Transacción de Éxito: COMMIT realizado. |

Demostración: Se verifica el estado final del Ticket 1 (Estado: En proceso, Tecnico: 2) y la existencia de la nueva fila en Historial.

2. Prueba de Fallo: Reversión Total (ROLLBACK)

Objetivo: Demostrar que un fallo intencional en un paso posterior revierte las sentencias anteriores que sí fueron exitosas.

| Acción DML | Estado | Resultado del Bloque |
| DML Éxito Temporal (2x) | Inserción de un ticket temporal y su historial. | Cambios pendientes de confirmación. |
| Fallo Forzado (FK 999) | Falla por Violación de Llave Foránea (id_usuario = 999). | El flujo salta al CATCH. |
| ROLLBACK TRANSACTION | Reversión Total: Se anulan el ticket temporal y su historial. | Transacción de Fallo: ROLLBACK realizado. |

Demostración: Se verifica que el SELECT final del ticket temporal devuelve CERO FILAS y que el conteo de registros en la tabla Historial es el mismo que antes de la transacción, probando que el sistema revirtió todos los efectos.

III. Conclusión de la Implementación

El uso de BEGIN TRY...CATCH con ROLLBACK garantiza que el Sistema de Tickets siempre mantenga la integridad de los datos. En un escenario donde, por ejemplo, el ticket se asigna pero el registro de historial falla, la transacción completa se anula, evitando que la base de datos entre en un estado inconsistente (donde el ticket está asignado, pero nadie sabe quién lo hizo).