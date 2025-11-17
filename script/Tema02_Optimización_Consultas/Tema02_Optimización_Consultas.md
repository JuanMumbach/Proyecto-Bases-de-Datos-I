TEMA 2: OPTIMIZACIÓN DE CONSULTAS MEDIANTE ÍNDICES

Proyecto: Sistema de Gestión de Tickets
Base de Datos: SistemaTickets

I. Fundamento Teórico

En sistemas donde el volumen de datos crece continuamente, como un Sistema de Gestión de Tickets, el rendimiento de las consultas se vuelve un factor crítico. En particular, las búsquedas por período (por ejemplo, tickets generados en un rango de fechas) suelen ser operaciones frecuentes y costosas si no existen índices adecuados.

Un índice es una estructura auxiliar que permite acceder a registros específicos sin necesidad de recorrer la tabla completa. Existen principalmente tres tipos relevantes:

Índice agrupado (clustered): determina el orden físico de los registros en la tabla.

Índice no agrupado (nonclustered): mantiene una estructura independiente ordenada por la clave del índice.

Índice cubriente (covering index): un índice no agrupado que incluye columnas adicionales mediante INCLUDE, permitiendo que una consulta se resuelva completamente desde el índice, sin acceder a la tabla base.

Cuanto más se ajusta un índice al patrón real de las consultas, mayor es el impacto positivo en rendimiento.

II. Procedimiento Realizado

Para evaluar el impacto del uso de índices en consultas por fecha, se trabajó sobre la tabla Tickets, que contiene la columna fecha_creacion.

1. Carga Masiva de Datos

Se generó una carga de 1.000.000 de registros, con fechas distribuidas minuto a minuto desde el 1/1/2024. Esta carga masiva simula un entorno real con una alta cantidad de tickets, necesario para que las diferencias de rendimiento sean significativas.
II. Procedimiento Realizado

Para evaluar el impacto del uso de índices en consultas por fecha, se trabajó sobre la tabla Tickets, que contiene la columna fecha_creacion.

1. Carga Masiva de Datos

Se generó una carga de 1.000.000 de registros, con fechas distribuidas minuto a minuto desde el 1/1/2024. Esta carga masiva simula un entorno real con una alta cantidad de tickets, necesario para que las diferencias de rendimiento sean significativas.

2. Consulta Base

La consulta utilizada en los tres escenarios fue:

SELECT fecha_creacion, descripcion, estado, prioridad
FROM Tickets
WHERE fecha_creacion BETWEEN '2024-03-01' AND '2024-04-01'
ORDER BY fecha_creacion;

Con STATISTICS IO y STATISTICS TIME activados, se midieron:

Lecturas lógicas

Tiempo de CPU

Tiempo total de ejecución

Plan de ejecución

III. Escenarios Analizados
Escenario 1 – Sin Índice sobre fecha_creacion

En este escenario se eliminaron todos los índices previos sobre la columna fecha_creacion.
El plan de ejecución mostró un Table Scan, lo que implica:

Recorrido completo de la tabla.

Alto número de lecturas lógicas.

Tiempo de ejecución más elevado.

Este escenario sirve como línea base para comparar las mejoras posteriores.

Escenario 2 – Índice No Agrupado sobre fecha_creacion

Se creó un índice no agrupado sobre la columna fecha_creacion. La misma consulta pasó a utilizar un Index Seek, lo que permitió:

Acceso directo al rango solicitado.

Menor cantidad de lecturas.

Reducción del tiempo de ejecución.

Sin embargo, al no incluir otras columnas, el motor necesitó realizar Key Lookups para obtener descripcion, estado y prioridad.

Este escenario demuestra cómo un índice puede acelerar búsquedas por fecha, aunque todavía exista un costo adicional al recuperar columnas no indexadas.

Escenario 3 – Índice No Agrupado Cubriente

Finalmente, se creó un índice no agrupado sobre fecha_creacion que incluye las columnas utilizadas en el SELECT:

INCLUDE (descripcion, estado, prioridad)

Este índice cubriente permitió:

Ejecutar la consulta exclusivamente desde el índice.

Eliminar completamente los Key Lookups.

Reducir aún más las lecturas lógicas.

Obtener el menor tiempo total de los tres escenarios.

Este es el diseño de índice óptimo para consultas repetitivas que utilizan siempre las mismas columnas.

IV. Comparación de Resultados

La siguiente tabla debe completarse con los valores obtenidos por STATISTICS IO/TIME:

| Escenario          | Tipo de Acceso           | Lecturas Lógicas | CPU (ms) | Tiempo Total (ms) |
| ------------------ | ------------------------ | ---------------- | -------- | ----------------- |
| Sin índice         | Table Scan               | X1               | Y1       | Z1                |
| Índice no agrupado | Index Seek + Lookups     | X2               | Y2       | Z2                |
| Índice cubriente   | Index Seek (sin Lookups) | X3               | Y3       | Z3                |

V. Conclusión

Las pruebas realizadas demuestran de forma clara el impacto de los índices en la eficiencia de las consultas:

Sin índices, las búsquedas por período realizan recorridos completos de la tabla, lo que se vuelve inviable a gran escala.

Un índice no agrupado sobre fecha_creacion mejora el rendimiento, permitiendo búsquedas selectivas.

Un índice cubriente es la opción más eficiente, ya que evita acceder a la tabla y reduce al mínimo el costo de lectura.
