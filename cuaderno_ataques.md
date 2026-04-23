# Cuaderno de Ataques - Seguridad de Base de Datos

### Sección 1: Ataques de SQL Injection que fallan
| Ataque | Input Probado | Pantalla | Resultado | Línea de Código Defensora |
| :--- | :--- | :--- | :--- | :--- |
| Quote-escape | `' OR '1'='1` | Búsqueda | "Sin resultados" | `main.py` Línea 45 |
| Stacked Query | `'; DROP TABLE mascotas;` | Búsqueda | Error 500 (controlado) | `main.py` Línea 45 |
| Union-based | `UNION SELECT 1,2,3...` | Búsqueda | "Sin resultados" | `main.py` Línea 45 |

[cite_start]*Nota: Las capturas `214938.png` y `214951.png` demuestran el fallo del ataque Quote-escape[cite: 190].*

### Sección 2: Demostración de RLS en acción
- [cite_start]**Veterinario 1 (Dr. López):** Al consultar, el RLS filtra mediante `app.current_vet_id = 1`, mostrando únicamente a Firulais, Toby y Max[cite: 32, 201].
- [cite_start]**Veterinario 2 (Dra. García):** Al consultar, el sistema establece `vet_id = 2`, permitiendo ver exclusivamente a Misifú, Luna y Dante[cite: 33, 201].
- [cite_start]**Política aplicada:** La política `policy_vet_mascotas` en la tabla `mascotas` restringe el acceso basándose en la tabla de asignación `vet_atiende_mascota`[cite: 202].

### Sección 3: Demostración de Caché Redis
- [cite_start]**Key utilizada:** `vacunacion_pendiente`[cite: 208].
- [cite_start]**TTL:** 5 minutos (300s)[cite: 208].
- **Flujo demostrado:**
    1. [cite_start]**Primera consulta:** `[CACHE MISS]` - Latencia observada: ~150ms[cite: 205].
    2. [cite_start]**Segunda consulta:** `[CACHE HIT]` - Latencia observada: ~10ms[cite: 205].
    3. [cite_start]**Acción:** Se aplica una vacuna a una mascota[cite: 206].
    4. [cite_start]**Invalidación:** El backend ejecuta `redis_config.invalidate_cache`, eliminando la key[cite: 167].
    5. [cite_start]**Tercera consulta:** `[CACHE MISS]` - Los datos se refrescan desde la BD[cite: 207].