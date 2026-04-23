CREATE OR REPLACE PROCEDURE sp_agendar_cita(
    p_mascota_id INT,
    p_veterinario_id INT,
    p_fecha_hora TIMESTAMP,
    p_motivo TEXT,
    OUT p_cita_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO citas (mascota_id, veterinario_id, fecha_hora, motivo)
    VALUES (p_mascota_id, p_veterinario_id, p_fecha_hora, p_motivo)
    RETURNING id INTO p_cita_id;
    
    COMMIT;
END;
$$;

-- Función para calcular el total facturado
CREATE OR REPLACE FUNCTION fn_total_facturado(p_mascota_id INT, p_anio INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(costo_cobrado), 0) INTO v_total
    FROM vacunas_aplicadas
    WHERE mascota_id = p_mascota_id 
    AND EXTRACT(YEAR FROM fecha_aplicacion) = p_anio;
    
    RETURN v_total;
END;
$$;