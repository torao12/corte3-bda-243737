from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import redis_config # Importante: debe existir el archivo redis_config.py
import os

app = FastAPI()

# Permite que tanto el puerto 8080 (Docker) como el 5500 (Live Server) funcionen
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class VacunaRequest(BaseModel):
    mascota_id: int
    vacuna_id: int
    vet_id: int
    costo: float

# Configuración de conexión interna de Docker
DB_CONFIG = {
    "host": "db",
    "database": "clinica_vet",
    "user": "postgres",
    "password": "password",
    "port": 5432
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

@app.get("/mascotas/vacunacion-pendiente")
def list_vacunacion_pendiente():
    cache_key = "vacunacion_pendiente"
    try:
        # Intento de obtener datos de Redis [cite: 163, 165]
        cached = redis_config.get_cache(cache_key)
        if cached: return cached

        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT * FROM v_mascotas_vacunacion_pendiente;")
        results = cur.fetchall()
        redis_config.set_cache(cache_key, results)
        cur.close()
        conn.close()
        return results
    except Exception as e:
        # Si falla, devuelve el error real para que lo veas en la consola
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/mascotas/buscar")
def buscar_mascota(nombre: str, vet_id: int):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        # RLS: Comunicar identidad al motor de Postgres [cite: 144, 145]
        cur.execute("SET app.current_vet_id = %s;", (vet_id,))
        # Hardening: Consulta parametrizada contra SQLi [cite: 153, 154]
        query = "SELECT * FROM mascotas WHERE nombre ILIKE %s;"
        cur.execute(query, (f"%{nombre}%",))
        results = cur.fetchall()
        cur.close()
        conn.close()
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/vacunas/aplicar")
def aplicar_vacuna(req: VacunaRequest):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO vacunas_aplicadas (mascota_id, vacuna_id, veterinario_id, costo_cobrado) VALUES (%s, %s, %s, %s)",
            (req.mascota_id, req.vacuna_id, req.vet_id, req.costo)
        )
        conn.commit()
        # Invalidación de caché obligatoria [cite: 167]
        redis_config.invalidate_cache("vacunacion_pendiente")
        cur.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))