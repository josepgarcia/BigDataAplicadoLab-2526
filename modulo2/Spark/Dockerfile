FROM ubuntu:22.04

# Variables de entorno
ENV HADOOP_VERSION=3.3.6
ENV SPARK_VERSION=3.5.0
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# Instalar dependencias base
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    ssh \
    rsync \
    vim \
    nano \
    net-tools \
    python3 \
    python3-pip \
    python3-venv \
    dos2unix \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar JAVA_HOME dinámicamente después de instalar Java
RUN JAVA_HOME=$(dirname $(dirname $(update-alternatives --query java | grep 'Value:' | awk '{print $2}'))) && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment && \
    echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> /etc/environment

# Configurar JAVA_HOME para este build
RUN export JAVA_HOME=$(dirname $(dirname $(update-alternatives --query java | grep 'Value:' | awk '{print $2}')))

# Crear usuario hadoop
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd && \
    usermod -aG sudo hadoop

# Instalar Hadoop (cliente para HDFS)
COPY downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/hadoop.tar.gz
RUN tar -xzf /tmp/hadoop.tar.gz -C /usr/local/ && \
    mv /usr/local/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm /tmp/hadoop.tar.gz && \
    chown -R hadoop:hadoop $HADOOP_HOME

# Configuración básica de Hadoop (cliente)
RUN mkdir -p $HADOOP_HOME/logs && \
    chown -R hadoop:hadoop $HADOOP_HOME/logs

# Instalar Spark
COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/spark.tgz
RUN tar -xzf /tmp/spark.tgz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 $SPARK_HOME && \
    rm /tmp/spark.tgz && \
    chown -R hadoop:hadoop $SPARK_HOME

# Instalar librerías Python para Data Science
RUN pip3 install --no-cache-dir \
    pyspark==${SPARK_VERSION} \
    pandas==2.1.3 \
    numpy==1.26.2 \
    matplotlib==3.8.2 \
    seaborn==0.13.0 \
    jupyter==1.0.0 \
    jupyterlab==4.0.9 \
    notebook==7.0.6 \
    ipykernel==6.27.1 \
    findspark==2.0.1 \
    pyarrow==14.0.1

# Configuración Spark
COPY config/spark-defaults.conf $SPARK_HOME/conf/
COPY config/spark-env.sh $SPARK_HOME/conf/
COPY config/log4j2.properties $SPARK_HOME/conf/
RUN chmod +x $SPARK_HOME/conf/spark-env.sh && \
    dos2unix $SPARK_HOME/conf/spark-env.sh

# Crear directorios necesarios
RUN mkdir -p $SPARK_HOME/logs \
    $SPARK_HOME/work \
    $SPARK_HOME/tmp \
    /home/hadoop/notebooks \
    /home/hadoop/data && \
    chown -R hadoop:hadoop $SPARK_HOME /home/hadoop

# Script de inicio
COPY start-spark.sh /start-spark.sh
RUN chmod +x /start-spark.sh && dos2unix /start-spark.sh

# Configurar SSH (para Spark standalone)
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Puertos Spark
EXPOSE 8080 7077 4040 18080 8888

USER hadoop
WORKDIR /home/hadoop

CMD ["/start-spark.sh"]
