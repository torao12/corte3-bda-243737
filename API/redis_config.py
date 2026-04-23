import redis
import json
import os

# Conexión a Redis (usando el nombre del servicio en docker-compose)
redis_client = redis.Redis(host='redis', port=6379, db=0, decode_responses=True)

def get_cache(key):
    data = redis_client.get(key)
    if data:
        print(f"[CACHE HIT] {key}") # Log solicitado 
        return json.loads(data)
    print(f"[CACHE MISS] {key}") # Log solicitado 
    return None

def set_cache(key, value, ttl=300): # TTL de 5 min por defecto [cite: 166]
    redis_client.setex(key, ttl, json.dumps(value))

def invalidate_cache(key):
    redis_client.delete(key)
    print(f"[CACHE INVALIDATED] {key}")