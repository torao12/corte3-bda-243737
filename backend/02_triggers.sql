CREATE OR REPLACE FUNCTION fn_log_historial_cita()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historial_movimientos (tipo, referencia_id, descripcion)
    VALUES ('NUEVA_CITA', NEW.id, 'Se agendó cita para mascota ID: ' || NEW.mascota_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: trg_historial_cita
CREATE TRIGGER trg_historial_cita
AFTER INSERT ON citas
FOR EACH ROW
EXECUTE FUNCTION fn_log_historial_cita();