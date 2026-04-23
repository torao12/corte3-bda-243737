# Cuaderno de Ataques - Seguridad de Base de Datos

### Sección 1: Ataques de SQL Injection que fallan
| Ataque | Input Probado | Pantalla | Resultado | Línea de Código Defensora |
| :--- | :--- | :--- | :--- | :--- |
| Quote-escape | `' OR '1'='1` | Búsqueda | "Sin resultados" | `main.py` Línea 45 |
| Stacked Query | `'; DROP TABLE mascotas;` | Búsqueda | Error 500 (controlado) | `main.py` Línea 45 |
| Union-based | `UNION SELECT 1,2,3...` | Búsqueda | "Sin resultados" | `main.py` Línea 45 |

*Nota: Las capturas `214938.png` y `214951.png` demuestran el fallo del ataque Quote-escape
### Sección 2: Demostración de RLS en acción
- **Veterinario 1 (Dr. López):** Al consultar, el RLS filtra mediante `app.current_vet_id = 1`, mostrando únicamente a Firulais, Toby y Max.
- **Veterinario 2 (Dra. García):** Al consultar, el sistema establece `vet_id = 2`, permitiendo ver exclusivamente a Misifú, Luna y Dante.
-**Política aplicada:** La política `policy_vet_mascotas` en la tabla `mascotas` restringe el acceso basándose en la tabla de asignación `vet_atiende_mascota`.

### Sección 3: Demostración de Caché Redis
- **Key utilizada:** `vacunacion_pendiente`.
- **TTL:** 5 minutos (300s).
- **Flujo demostrado:**
    1. **Primera consulta:** `[CACHE MISS]` - Latencia observada: ~150ms.
    2. **Segunda consulta:** `[CACHE HIT]` - Latencia observada: ~10ms.
    3. **Acción:** Se aplica una vacuna a una mascota.
    4. **Invalidación:** El backend ejecuta `redis_config.invalidate_cache`, eliminando la key.
    5. **Tercera consulta:** `[CACHE MISS]` - Los datos se refrescan desde la BD.