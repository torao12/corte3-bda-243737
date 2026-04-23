ALTER TABLE mascotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vacunas_aplicadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE citas ENABLE ROW LEVEL SECURITY;

-- Política de Mascotas para Veterinarios
CREATE POLICY policy_vet_mascotas ON mascotas FOR SELECT TO vet_role
USING (id IN (SELECT mascota_id FROM vet_atiende_mascota WHERE vet_id = CAST(current_setting('app.current_vet_id') AS INT)));

-- Acceso total para Admin y Recepción [cite: 140]
CREATE POLICY policy_admin_recep_mascotas ON mascotas FOR SELECT TO admin_role, recepcion_role USING (true);

-- Política de Citas
CREATE POLICY policy_vet_citas ON citas FOR SELECT TO vet_role
USING (veterinario_id = CAST(current_setting('app.current_vet_id') AS INT));

CREATE POLICY policy_all_citas ON citas FOR SELECT TO admin_role, recepcion_role USING (true);