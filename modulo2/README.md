# Módulo 2 - Apache Spark y PySpark

## Descripción

Este módulo proporciona un entorno Apache Spark standalone con integración a HDFS del módulo1. Además, se ha preparado el entorno para funcionar en local (sin HDFS) cuando el módulo1 no está levantado.

## Características

- Apache Spark 3.5.0
- PySpark con librerías de Data Science (pandas, numpy, matplotlib, seaborn)
- Jupyter Notebook integrado
- Conexión con HDFS del módulo1
- Spark Master UI
- Spark History Server

### Cambios y correcciones aplicadas (2025-11-29)

- Detección automática de `JAVA_HOME` en la imagen Docker (ARM64) para evitar rutas `amd64` inválidas.
- Configuración de Spark para entorno local sin HDFS:
  - `spark.hadoop.fs.defaultFS = file:///` en `Spark/config/spark-defaults.conf`.
  - `spark.io.compression.codec = snappy` para evitar warnings del History Server.
- Notebook de prueba creado: `notebooks/test.ipynb` con celdas para:
  - Import y versiones de Python/PySpark.
  - Creación de `SparkSession` contra `spark://spark-master:7077`.
  - Operaciones con RDD y DataFrame.
  - Lectura de CSV local explícita: `file:///home/hadoop/data/sample.csv`.
- Datos de ejemplo añadidos: `data/sample.csv`.

## Requisitos Previos

- Docker y Docker Compose instalados
- Módulo 1 (Hadoop) corriendo
- Make instalado
- `wget` disponible en el sistema (macOS: `brew install wget`)
- `shasum` (incluido en macOS) para verificar SHA-512

> **Nota para Windows 11**: Ver la [guía de configuración WSL2](../README.md#-uso-en-windows-11) en el README principal.

## Instalación Rápida

```bash
# 1. Descargar paquetes (Spark + Hadoop cliente) con verificación
make download-cache

# 2. Instalación completa
make install

# 3. Verificar estado
make status
```

## Ejecutar el test del módulo

Ejecuta el notebook de prueba dentro del contenedor y valida que se genera el archivo ejecutado.

```bash
make test
```

Salida esperada:

- `✅ Test ejecutado correctamente: /home/hadoop/notebooks/test.executed.ipynb`

En caso de fallo, el objetivo muestra `STDOUT` y `STDERR` de `nbconvert` para diagnóstico.

## Comandos Disponibles

```bash
make help          # Ver todos los comandos disponibles
make download-cache# Descargar paquetes a la caché local (con verificación)
make build         # Construir la imagen Docker
make up            # Levantar Spark
make down          # Detener Spark
make restart       # Reiniciar Spark
make logs          # Ver logs
make clean         # Limpiar todo
make shell-spark   # Abrir shell en el contenedor
make pyspark-shell # Abrir PySpark shell
make jupyter       # Ver URL de Jupyter
make test-hdfs     # Probar conexión con HDFS
make status        # Ver estado de servicios
```

## Descarga y Verificación

- El script `Spark/download-cache.sh` descarga los paquetes a `Spark/downloads/`:
  - `spark-<version>-bin-hadoop3.tgz` (Spark)
  - `hadoop-<version>.tar.gz` (cliente HDFS)
- Verificación de integridad obligatoria con SHA-512:
  - Se descarga el `.sha512` oficial y se exige formato “HASH nombre-de-archivo”.
  - Si el checksum no coincide, se elimina automáticamente el paquete descargado y se informa. En la siguiente ejecución se descargará de nuevo.
- Reanudación de descargas y robustez de red:
  - Usa `wget -c` para continuar descargas interrumpidas.
  - Incluye reintentos y timeouts (`--tries`, `--timeout`, etc.).
- Idempotente y por componente:
  - Si Spark o Hadoop ya están presentes y verificados, se omiten individualmente.
  - Si ambos están verificados, el script finaliza sin hacer nada.

## Interfaces Web

- **Spark Master UI**: http://localhost:8080
- **Spark Application UI**: http://localhost:4040
- **Spark History Server**: http://localhost:18080
- **Jupyter Notebook**: http://localhost:8888

## Integración con HDFS

El módulo2 se conecta automáticamente al HDFS del módulo1. Para probar:

```bash
# Desde el contenedor de Spark
docker exec -it spark-master bash
hdfs dfs -ls /
```

## Uso de Jupyter

1. Abrir http://localhost:8888
2. Navegar a `/notebooks/ejemplo-pyspark.ipynb`
3. Ejecutar las celdas para ver ejemplos de integración con HDFS.
   Si HDFS no está disponible, usa el notebook `notebooks/test.ipynb` y rutas locales `file:///`.

## Ejemplo de Código PySpark

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Ejemplo") \
    .master("spark://spark-master:7077") \
    .config("spark.hadoop.fs.defaultFS", "file:///") \
    .getOrCreate()

# Leer datos locales (sin HDFS)
df = spark.read.csv("file:///home/hadoop/data/sample.csv", header=True, inferSchema=True)
df.show()
```

## Troubleshooting

### Error de conexión con HDFS

```bash
# Verificar que módulo1 está corriendo
cd ../modulo1
make status

# Verificar conectividad de red
docker network ls | grep modulo1_hadoop-net
```

### Jupyter no se inicia

```bash
make logs
# Buscar errores relacionados con Jupyter
```

### Fallo de checksum en descarga

```bash
# Reintenta la descarga/verificación
make download-cache

# Si persiste, borra manualmente el paquete (se mantiene el .sha512)
rm -f Spark/downloads/spark-3.5.0-bin-hadoop3.tgz \
    Spark/downloads/hadoop-3.3.6.tar.gz
make download-cache
```

## Estructura del Proyecto

```
modulo2/
├── Makefile                        # Comandos disponibles
├── docker-compose.yaml             # Configuración de servicios
├── Spark/
│   ├── Dockerfile                  # Imagen Docker
│   ├── download-cache.sh           # Script de descarga
│   ├── start-spark.sh              # Script de inicio
│   ├── config/                     # Configuraciones Spark
│   └── downloads/                  # Caché de descargas
├── notebooks/                      # Jupyter notebooks
└── data/                           # Datos locales
```
