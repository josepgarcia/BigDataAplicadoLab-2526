from kafka import KafkaConsumer
import json

# Unimos este consumidor al grupo "grupo-escrutinio"
consumer = KafkaConsumer(
    'votos-eurovision',
    bootstrap_servers=['localhost:9092'],
    group_id='grupo-escrutinio', # IMPORTANTE
    auto_offset_reset='earliest',
    value_deserializer=lambda m: json.loads(m.decode('utf-8')),
    key_deserializer=lambda k: k.decode('utf-8') if k else None
)

print("📊 Centro de Escrutinio iniciado. Esperando votos...")

for mensaje in consumer:
    id_voto = mensaje.value["id_voto"]
    candidato = mensaje.value["candidato"]
    print(f"Recibido Voto #{id_voto} en [Partición {mensaje.partition}] - Key: {mensaje.key} -> {candidato}")
