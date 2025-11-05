```
 ____  ____    _      _           _
| __ )|  _ \  / \    | |    __ _ | |__
|  _ \| | | |/ _ \   | |   / _` || '_ \
| |_) | |_| / ___ \  | |__| (_| || |_) |
|____/|____/_/   \_\ |_____\__,_||_.__/

```

## Iniciar laboratorio para el módulo 1

- Clonamos el repositorio y entramos en la carpeta /modulo1
- Utilizamos make para las diferentes tareas:

```bash
# Descargamos la caché (hadoop + hive)
make download-cache

# Construimos las imagenes
make build

# Levantamos los contenedores
make up
```

## Directorio /tmp/hadoop-hadoop

El sistema HDFS se almacena en /tmp/hadoop-hadoop, pero forma parte de un volúmen (tal y como puede verse en docker-compose), por lo que al reinciar el contenedor se monta de nuevo el volumen y los datos no desaparecen.

Ver también el script de arranque que usa esa ruta: start-hadoop.sh y la imagen que la expone en el contenedor: Dockerfile.

Al hacer un `make clean` si que se borra.

## Problema escritura webdfs

Al intentar crear un directorio se producía un error:
Permission denied: user=dr.who, access=WRITE, inode="/":hadoop:supergroup:drwxr-xr-x

Para solucionarlo añadimos al core-site.xml

```xml
  <property>
    <name>hadoop.http.staticuser.user</name>
    <value>hadoop</value>
  </property>
```

Se puede verificar que la propiedad esté activa:

```bash
# debería devolver hadoop
hdfs getconf -confKey hadoop.http.staticuser.user

# También debería devolver hadoop a través de hdfs
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prueba_webhdfs?op=MKDIRS"
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prueba_webhdfs2?op=MKDIRS&user.name=hadoop"
```

## "replication = 3" pero solo hay réplicas en 2 slaves — ¿por qué no está en el master?

"replication = 3" es el factor deseado; si solo ves 2 réplicas, el NameNode no pudo colocar la tercera. Motivos comunes y pasos rápidos:

- Causas probables:

  - En el master no está corriendo un DataNode (el master no forma parte de los datanodes).
  - El DataNode del master está deshabilitado (exclude), en modo decommission o no responde.
  - El re-replicado está en curso o falta espacio en nodos.
  - Políticas de colocación / rack-awareness impiden usar el master.

- Comprobaciones rápidas (ejecutar como usuario hadoop en el master):

```bash
sudo -u hadoop $HADOOP_HOME/bin/hdfs dfsadmin -report
sudo -u hadoop $HADOOP_HOME/bin/hdfs fsck /test.txt -files -blocks -locations
jps   # ver si DataNode está corriendo en el master
```

- Acciones comunes:
  - Si falta el DataNode en el master: añadir su hostname a $HADOOP_HOME/etc/hadoop/workers y arrancar datanode:

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
