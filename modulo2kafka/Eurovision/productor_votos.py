from kafka import KafkaProducer
import json
import time
import random

# Configuración: indicamos que enviaremos JSONs y las Keys serán strings
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
    key_serializer=lambda k: k.encode('utf-8')
)

candidatos = ["Alice", "Bob", "Charlie", "Diana"]

print("📱 App de Votación iniciada. Enviando votos...")

for i in range(1, 1000):
    # Simulamos 5 usuarios votando (IDs del 1 al 5)
    id_usuario = f"usuario-{random.randint(1, 5)}"
    
    mensaje = {
        "id_voto": i, # Añadimos un contador secuencial
        "candidato": random.choice(candidatos),
        "origen": "App iOS"
    }
    
    # La KEY (id_usuario) es vital. Kafka hará un hash y lo enviará siempre a la misma partición.
    producer.send('votos-eurovision', key=id_usuario, value=mensaje)
    print(f"Enviado {id_usuario}: {mensaje}")
    time.sleep(1)

producer.close()
