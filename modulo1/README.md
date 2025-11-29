# Módulo 1 - Hadoop Multi-Nodo

## Descripción

Este módulo proporciona un clúster Hadoop completo con 3 nodos (1 master + 2 slaves) para simular un entorno distribuido real.

## Características

- Hadoop 3.4.1 con HDFS y YARN
- Hive 2.3.9 para consultas SQL sobre HDFS
- Clúster de 3 nodos (master + 2 slaves)
- HDFS con replicación factor 3
- Tolerancia a fallos y distribución de datos
- Ideal para aprender sobre arquitecturas distribuidas

## Requisitos Previos

- Docker y Docker Compose instalados
- Make instalado
- `wget` disponible en el sistema (macOS: `brew install wget`)

> **Nota para Windows 11**: Ver la [guía de configuración WSL2](../README.md#-uso-en-windows-11) en el README principal.

## Instalación Rápida

```bash
# 1. Descargar paquetes (Hadoop + Hive) a la caché local
make download-cache

# 2. Construir las imágenes Docker
make build

# 3. Levantar el clúster
make up
```

## Comandos Disponibles

```bash
make help          # Ver todos los comandos disponibles
make download-cache# Descargar paquetes a la caché local
make build         # Construir las imágenes Docker
make up            # Levantar el clúster Hadoop (3 nodos)
make clean         # Detener y limpiar contenedores y volúmenes
make deep-clean    # Limpieza profunda (incluye imágenes y caché)
make shell-master  # Acceder al shell del master como usuario hadoop
make shell-slave1  # Acceder al shell del slave1 como usuario hadoop
make shell-slave2  # Acceder al shell del slave2 como usuario hadoop
```

## Interfaces Web

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **MapReduce Job History Server**: http://localhost:19888
- **HiveServer2 Web UI**: http://localhost:10002

## Arquitectura del Clúster

```
┌─────────────────┐
│  hadoop-master  │  NameNode, ResourceManager, HiveServer2
│   (master)      │  Ports: 9870, 8088, 19888, 10000, 10002, 9083
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│slave1 │ │slave2 │  DataNode, NodeManager
│       │ │       │  Ports: 8042, 9864
└───────┘ └───────┘
```

## Ejemplo de Uso de HDFS

```bash
# Acceder al master
make shell-master

# Listar archivos en HDFS
hdfs dfs -ls /

# Crear directorio
hdfs dfs -mkdir /user/hadoop/datos

# Subir archivo (se replicará en 3 nodos)
echo "test data" > /tmp/test.txt
hdfs dfs -put /tmp/test.txt /user/hadoop/datos/

# Verificar replicación
hdfs fsck /user/hadoop/datos/test.txt -files -blocks -locations

# Ver contenido
hdfs dfs -cat /user/hadoop/datos/test.txt
```

## Ejemplo de Uso de Hive

```bash
# Acceder al master
make shell-master

# Iniciar Beeline (cliente Hive)
beeline -u jdbc:hive2://localhost:10000

# Crear tabla
CREATE TABLE IF NOT EXISTS empleados (
    id INT,
    nombre STRING,
    salario DOUBLE
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

# Cargar datos
LOAD DATA LOCAL INPATH '/tmp/empleados.csv' INTO TABLE empleados;

# Consultar
SELECT * FROM empleados WHERE salario > 50000;
```

## Directorio /tmp/hadoop-hadoop

El sistema HDFS se almacena en `/tmp/hadoop-hadoop`, pero forma parte de un volumen (tal y como puede verse en `docker-compose.yml`), por lo que al reiniciar el contenedor se monta de nuevo el volumen y los datos no desaparecen.

Ver también:
- Script de arranque que usa esa ruta: `start-hadoop.sh`
- Imagen que la expone en el contenedor: `Dockerfile`

Al hacer un `make clean` sí que se borra el volumen.

## Troubleshooting

### Problema escritura WebHDFS

Al intentar crear un directorio se producía un error:
```
Permission denied: user=dr.who, access=WRITE, inode="/":hadoop:supergroup:drwxr-xr-x
```

**Solución**: Ya está configurado en `core-site.xml`:

```xml
<property>
  <name>hadoop.http.staticuser.user</name>
  <value>hadoop</value>
</property>
```

Verificar que la propiedad esté activa:

```bash
# Debería devolver "hadoop"
hdfs getconf -confKey hadoop.http.staticuser.user

# También debería funcionar a través de WebHDFS
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prueba_webhdfs?op=MKDIRS"
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prueba_webhdfs2?op=MKDIRS&user.name=hadoop"
```

### "replication = 3" pero solo hay réplicas en 2 slaves

**Causa**: El master no está corriendo un DataNode (el master no forma parte de los datanodes por defecto).

**Comprobaciones rápidas** (ejecutar como usuario hadoop en el master):

```bash
# Ver estado del clúster
hdfs dfsadmin -report

# Verificar bloques y ubicaciones
hdfs fsck /test.txt -files -blocks -locations

# Ver si DataNode está corriendo en el master
jps
```

**Acciones comunes**:

- Si falta el DataNode en el master: añadir su hostname a `$HADOOP_HOME/etc/hadoop/workers` y arrancar datanode:
  ```bash
  sudo -u hadoop $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
  ```

- Refrescar nodos si usas exclude/include:
  ```bash
  sudo -u hadoop $HADOOP_HOME/bin/hdfs dfsadmin -refreshNodes
  ```

- Forzar y esperar replicación:
  ```bash
  sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -setrep -w 3 /test.txt
  ```

### El clúster no inicia

```bash
# Ver logs de cada contenedor
docker logs hadoop-master
docker logs hadoop-slave1
docker logs hadoop-slave2

# Verificar estado
docker ps -a | grep hadoop
```

### Error de permisos en HDFS

Los comandos HDFS deben ejecutarse como usuario `hadoop`. Si usas `docker exec`, añade `-u hadoop`:

```bash
docker exec -u hadoop hadoop-master hdfs dfs -ls /
```

## Diferencias con `modulo1simple`

- **Nodos**: 3 nodos (master + 2 slaves) vs 1 nodo
- **Replicación**: Factor 3 vs Factor 1
- **Recursos**: Mayor consumo de CPU y memoria
- **Uso**: Simulación de clúster real vs Desarrollo y pruebas rápidas
- **Tolerancia a fallos**: Sí (puede perder 1-2 nodos) vs No

## Estructura del Proyecto

```
modulo1/
├── Makefile                        # Comandos disponibles
├── docker-compose.yml              # Configuración de servicios
└── Base/
    ├── Dockerfile                  # Imagen Docker
    ├── download-cache.sh           # Script de descarga
    ├── start-hadoop.sh             # Script de inicio
    ├── config/                     # Configuraciones Hadoop/Hive
    │   ├── core-site.xml
    │   ├── hdfs-site.xml
    │   ├── yarn-site.xml
    │   ├── mapred-site.xml
    │   ├── hive-site.xml
    │   ├── workers
    │   └── ...
    └── (downloads centralizados en /downloads en la raíz del proyecto)
```

## Autor

Josep Garcia
