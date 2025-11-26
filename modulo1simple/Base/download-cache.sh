#!/bin/bash

# Script para descargar Hadoop y Hive al caché local
# Esto acelera significativamente las reconstrucciones de contenedores

DOWNLOAD_DIR="./downloads"
SOURCE_DIR="../modulo1/Base/downloads"
HADOOP_VERSION="3.4.1"
HIVE_VERSION="2.3.9"

echo "================================================"
echo "📦 Descargando archivos al caché local"
echo "================================================"
echo ""

# Crear directorio si no existe
mkdir -p "$DOWNLOAD_DIR"

# Descargar/Copiar Hadoop si no existe
if [ ! -f "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    # Intentar copiar desde modulo1 primero
    if [ -f "$SOURCE_DIR/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
        echo "📋 Copiando Hadoop ${HADOOP_VERSION} desde modulo1..."
        cp "$SOURCE_DIR/hadoop-${HADOOP_VERSION}.tar.gz" "$DOWNLOAD_DIR/"
        echo "✅ Hadoop copiado desde caché de modulo1"
    else
        echo "⬇️  Descargando Hadoop ${HADOOP_VERSION}..."
        wget -q --show-progress \
            https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
            -O "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz"
        echo "✅ Hadoop descargado"
    fi
else
    echo "✅ Hadoop ${HADOOP_VERSION} ya existe en caché"
fi

echo ""

# Descargar/Copiar Hive si no existe
if [ ! -f "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz" ]; then
    # Intentar copiar desde modulo1 primero
    if [ -f "$SOURCE_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz" ]; then
        echo "📋 Copiando Hive ${HIVE_VERSION} desde modulo1..."
        cp "$SOURCE_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz" "$DOWNLOAD_DIR/"
        echo "✅ Hive copiado desde caché de modulo1"
    else
        echo "⬇️  Descargando Hive ${HIVE_VERSION}..."
        wget -q --show-progress \
            https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
            -O "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz"
        echo "✅ Hive descargado"
    fi
else
    echo "✅ Hive ${HIVE_VERSION} ya existe en caché"
fi

echo ""
echo "================================================"
echo "✅ Caché actualizado"
echo "================================================"
echo ""
echo "Archivos en caché:"
ls -lh "$DOWNLOAD_DIR"
echo ""
echo "💡 Ahora las reconstrucciones serán mucho más rápidas"
echo "   usando: make build"
