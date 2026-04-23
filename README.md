# Decisiones de Diseño - Clínica Veterinaria
**Estudiante:** Ian Mauricio Morales Montejo

### 1. Política RLS en la tabla `mascotas`
Se aplicó la política `policy_vet_mascotas` con la cláusula:
`USING (id IN (SELECT mascota_id FROM vet_atiende_mascota WHERE vet_id = CAST(current_setting('app.current_vet_id') AS INT)))`
Esta política filtra las filas para que un veterinario solo pueda realizar `SELECT` sobre las mascotas que tiene asignadas explícitamente en la tabla de relación.

### 2. Vector de ataque en la identidad del veterinario
El vector de ataque es la **suplantación de identidad por manipulación de parámetros**. [cite_start]Si un usuario cambia manualmente el `vet_id` en la URL de la petición, podría saltarse el RLS[cite: 227]. [cite_start]Mi sistema mitiga esto en la API al forzar que la identidad se establezca mediante la sesión del backend, aunque para una versión productiva se requeriría el uso de JWT[cite: 174].

### 3. Uso de SECURITY DEFINER
No se utilizó `SECURITY DEFINER` en los procedimientos almacenados[cite: 158]. [cite_start]No fue necesario ya que los roles cuentan con permisos suficientes sobre las secuencias y tablas para ejecutar sus funciones bajo su propio contexto, evitando así el riesgo de escalada de privilegios por manipulación del `search_path`.

### 4. Caché Redis: TTL y Justificación
Se eligió un **TTL de 300 segundos (5 minutos)**. Un valor más bajo saturaría la base de datos con consultas costosas de la vista; un valor más alto podría mostrar datos desactualizados de vacunación, aunque esto se mitiga con la estrategia de **invalidación activa** al insertar nuevas vacunas.

### 5. Hardening en el Backend
En el archivo `api/main.py`, línea 45: `cur.execute(query, (f"%{nombre}%",))`.
Esta línea utiliza **consultas parametrizadas** provistas por el driver `psycopg2`, lo que garantiza que cualquier entrada del usuario sea tratada como un literal y no como código ejecutable, neutralizando ataques de tipo Quote-escape.

### 6. Revocación de permisos al Veterinario
Si se revoca todo excepto `SELECT` en mascotas:
1. No podría registrar nuevas aplicaciones de vacunas (`INSERT` denegado en `vacunas_aplicadas`).
2. No podría agendar nuevas citas (`INSERT` denegado en `citas`).
3. El sistema fallaría al intentar actualizar contadores o historiales que dependan de disparadores.