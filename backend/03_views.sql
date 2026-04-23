CREATE OR REPLACE VIEW v_mascotas_vacunacion_pendiente AS
SELECT 
    m.id AS mascota_id,
    m.nombre AS mascota_nombre,
    iv.id AS vacuna_id, 
    iv.nombre AS vacuna_pendiente,
    d.nombre AS dueno_nombre,
    d.telefono AS contacto_dueno
FROM mascotas m
JOIN duenos d ON m.dueno_id = d.id
CROSS JOIN inventario_vacunas iv
LEFT JOIN vacunas_aplicadas va ON va.mascota_id = m.id AND va.vacuna_id = iv.id
WHERE va.id IS NULL AND iv.stock_actual > 0;