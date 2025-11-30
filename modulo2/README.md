# Módulo 2 - Hadoop & Spark Single Node

## Descripción

Este módulo proporciona un entorno Hadoop y Spark simplificado de un solo nodo (pseudo-distribuido) para desarrollo y pruebas rápidas.

## Características

- Hadoop 3.4.1 en modo pseudo-distribuido (single-node)
- Apache Spark 3.5.0 (Master + Worker)
- HDFS con replicación factor 1
- YARN para ejecución de trabajos MapReduce
- Jupyter Notebook con PySpark preconfigurado
- Carpeta compartida `ejercicios/` para scripts y datos
- Persistencia de datos en `data/` y notebooks en `notebooks/`
- Scripts de prueba MapReduce incluidos

## Requisitos Previos

- Docker y Docker Compose instalados
- Make instalado
- `wget` disponible en el sistema (macOS: `brew install wget`)

> **Nota para Windows 11**: Ver la [guía de configuración WSL2](../README.md#-uso-en-windows-11) en el README principal.

## Instalación Rápida

```bash
# 1. Descargar paquetes (Hadoop + Hive) a la caché local
make download-cache

# 2. Construir la imagen Docker
make build

# 3. Levantar el contenedor
make up
```

## Comandos Disponibles

```bash
make help          # Ver todos los comandos disponibles
make download-cache# Descargar paquetes a la caché local
make build         # Construir la imagen Docker
make up            # Levantar el clúster Hadoop (1 nodo)
make clean         # Detener y limpiar contenedores y volúmenes
make deep-clean    # Limpieza profunda (incluye imágenes y caché)
make shell-master  # Acceder al shell del contenedor como usuario hadoop
make test          # Ejecutar test MapReduce (word count)
```

## Interfaces Web

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **Spark Master UI**: http://localhost:8080
- **Spark Application UI**: http://localhost:4040, http://localhost:4041, http://localhost:4042
- **Jupyter Notebook**: http://localhost:8888
- **Spark History Server**: http://localhost:18080

## Carpeta Compartida `ejercicios/`

La carpeta `ejercicios/` está montada en el contenedor en `/home/hadoop/ejercicios`, permitiendo compartir archivos entre el host y el contenedor.

Contenido incluido:
- `mapper.py` - Script mapper para MapReduce
- `reducer.py` - Script reducer para MapReduce
- `quijote.txt` - Datos de ejemplo (El Quijote)
- `test_docker.sh` - Script para ejecutar test desde el host
- `test_bash.sh` - Script para ejecutar test desde dentro del contenedor

## Ejecutar Test MapReduce

### Desde el host (recomendado)

```bash
make test
```

Este comando ejecuta `test_docker.sh`, que:
1. Sube `quijote.txt` a HDFS
2. Ejecuta un trabajo MapReduce de conteo de palabras
3. Muestra los primeros 20 resultados

### Desde dentro del contenedor

```bash
# Acceder al contenedor
make shell-master

# Ejecutar el test
cd ejercicios
bash test_bash.sh
```

## Ejemplo de Uso de HDFS

```bash
# Acceder al contenedor
make shell-master

# Listar archivos en HDFS
hdfs dfs -ls /

# Crear directorio
hdfs dfs -mkdir /user/hadoop/datos

# Subir archivo
hdfs dfs -put /home/hadoop/ejercicios/quijote.txt /user/hadoop/datos/

# Ver contenido
hdfs dfs -cat /user/hadoop/datos/quijote.txt | head -n 10
```

## Ejemplo de Uso de Spark

### PySpark Shell

```bash
# Acceder al contenedor
make shell-master

# Iniciar PySpark
pyspark
```

### Jupyter Notebook

1. Levantar el entorno (`make up`).
2. Abrir http://localhost:8888 en el navegador.
3. Crear un nuevo notebook Python 3.
4. Probar el siguiente código:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Test").getOrCreate()
df = spark.createDataFrame([(1, "a"), (2, "b")], ["id", "val"])
df.show()
```

## Troubleshooting

### El contenedor no inicia

```bash
# Ver logs del contenedor
docker logs hadoop-master-simple

# Verificar estado
docker ps -a | grep hadoop-master-simple
```

### Error de permisos en HDFS

Los comandos HDFS deben ejecutarse como usuario `hadoop`. Si usas `docker exec`, añade `-u hadoop`:

```bash
docker exec -u hadoop hadoop-master-simple hdfs dfs -ls /
```

### Limpiar y reiniciar

```bash
# Limpieza completa
make clean

# Reconstruir y levantar
make build
make up
```

## Optimizaciones para Máquinas Menos Potentes

Este módulo está optimizado para funcionar en máquinas con recursos limitados. Las siguientes optimizaciones han sido aplicadas:

### Límites de Recursos Docker
- **Memoria máxima**: 2GB (límite) / 1GB (reservado)
- **CPU máxima**: 1.5 cores (límite) / 0.5 cores (reservado)

### Optimizaciones de Hadoop
- **NameNode**: Heap reducido a 512MB (por defecto ~1GB)
- **DataNode**: Heap reducido a 256MB
- **ResourceManager**: Heap reducido a 512MB
- **NodeManager**: Heap reducido a 256MB
- **JobHistoryServer**: Heap reducido a 256MB
- **Garbage Collector**: G1GC optimizado para bajo consumo

### Optimizaciones de YARN
- **Memoria total disponible**: 1GB (por defecto 8GB)
- **Memoria mínima por contenedor**: 128MB
- **Memoria máxima por contenedor**: 512MB
- **vCores disponibles**: 1 (en lugar de cores físicos)
- **Intervalo de monitoreo**: 3 segundos (reducido overhead)

### Optimizaciones de MapReduce
- **Memoria por tarea Map**: 256MB (por defecto 1024MB)
- **Memoria por tarea Reduce**: 256MB (por defecto 1024MB)
- **Memoria ApplicationMaster**: 512MB
- **Map tasks por defecto**: 2
- **Reduce tasks por defecto**: 1

### Optimizaciones de Hive
- **HiveServer2 heap**: 512MB
- **Hive Metastore heap**: 256MB
- **Reducers máximos**: 2 (por defecto 1009)
- **Paralelismo deshabilitado**: Para reducir uso de recursos
- **Ejecución vectorizada**: Habilitada para mejor rendimiento con menos recursos

### Optimizaciones de Spark
- **Driver Memory**: 512MB (por defecto 1GB)
- **Executor Memory**: 512MB (por defecto 1GB)
- **Executor Cores**: 1 (por defecto todos los disponibles)
- **Worker Memory**: 1GB
- **Daemon Memory**: 512MB

## Diferencias con `modulo1`

- **Nodos**: 1 nodo (master) vs 3 nodos (master + 2 slaves)
- **Replicación**: Factor 1 vs Factor 3
- **Recursos**: Menor consumo de CPU y memoria (optimizado para máquinas menos potentes)
- **Uso**: Desarrollo y pruebas vs Simulación de clúster

## Estructura del Proyecto

```
modulo2/
├── Makefile                        # Comandos disponibles
├── docker-compose.yml              # Configuración del servicio
├── Base/
│   ├── Dockerfile                  # Imagen Docker
│   ├── download-cache.sh           # Script de descarga
│   ├── start-hadoop.sh             # Script de inicio
│   ├── config/                     # Configuraciones Hadoop y Spark
│   └── (downloads centralizados en /downloads en la raíz del proyecto)
├── ejercicios/                     # Carpeta compartida
│   ├── mapper.py                   # Mapper MapReduce
│   ├── reducer.py                  # Reducer MapReduce
│   ├── quijote.txt                 # Datos de ejemplo
│   ├── test_docker.sh              # Test desde host
│   └── test_bash.sh                # Test desde contenedor
├── data/                           # Persistencia de datos HDFS/Local
└── notebooks/                      # Persistencia de Jupyter Notebooks
```

## Autor

Josep Garcia
```
