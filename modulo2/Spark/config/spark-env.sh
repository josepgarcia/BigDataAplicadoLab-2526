#!/usr/bin/env bash

# Detectar arquitectura automáticamente
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export HADOOP_HOME=/usr/local/hadoop
export SPARK_HOME=/opt/spark
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

export SPARK_MASTER_HOST=spark-master
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080

export SPARK_WORKER_CORES=2
export SPARK_WORKER_MEMORY=2g
export SPARK_DAEMON_MEMORY=1g

export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3
