DROP ROLE IF EXISTS vet_role, recepcion_role, admin_role;

CREATE ROLE vet_role;
GRANT SELECT ON mascotas, citas, vet_atiende_mascota TO vet_role;
GRANT SELECT, INSERT ON vacunas_aplicadas TO vet_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vet_role;

CREATE ROLE recepcion_role;
GRANT SELECT ON mascotas, duenos, citas TO recepcion_role;
GRANT INSERT ON citas TO recepcion_role;
REVOKE SELECT ON vacunas_aplicadas FROM recepcion_role; -- Protección de datos médicos [cite: 119]

CREATE ROLE admin_role WITH SUPERUSER;