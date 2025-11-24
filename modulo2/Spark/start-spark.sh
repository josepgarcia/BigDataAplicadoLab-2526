#!/bin/bash

echo "🚀 Iniciando Spark Master..."

# Configurar HDFS como almacenamiento por defecto
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
cat > $HADOOP_CONF_DIR/core-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://master:9000</value>
    </property>
</configuration>
EOF

# Iniciar Spark Master
$SPARK_HOME/sbin/start-master.sh

# Iniciar Spark Worker (conectado al master local)
$SPARK_HOME/sbin/start-worker.sh spark://spark-master:7077

# Iniciar History Server
$SPARK_HOME/sbin/start-history-server.sh

# Configurar Jupyter
mkdir -p /home/hadoop/.jupyter
cat > /home/hadoop/.jupyter/jupyter_notebook_config.py <<EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.token = ''
c.NotebookApp.password = ''
c.NotebookApp.notebook_dir = '/home/hadoop/notebooks'
c.NotebookApp.allow_root = True
EOF

# Iniciar Jupyter en background
nohup jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root > /opt/spark/logs/jupyter.log 2>&1 &

echo "✅ Spark Master iniciado en spark://spark-master:7077"
echo "✅ Spark Master UI disponible en http://localhost:8080"
echo "✅ Jupyter Notebook disponible en http://localhost:8888"
echo "✅ History Server disponible en http://localhost:18080"

# Mantener el contenedor vivo
tail -f $SPARK_HOME/logs/spark-*.out
