#!/bin/bash

set -euo pipefail

DOWNLOAD_DIR="./downloads"
SPARK_VERSION="3.5.0"
HADOOP_VERSION="3.3.6"

SPARK_BASE_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}"
HADOOP_BASE_URL="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}"

SPARK_TGZ="spark-${SPARK_VERSION}-bin-hadoop3.tgz"
HADOOP_TGZ="hadoop-${HADOOP_VERSION}.tar.gz"

mkdir -p "$DOWNLOAD_DIR"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

download_with_resume() {
    local url="$1"; shift
    local out="$1"; shift
    wget -q -c --show-progress \
        --tries=10 \
        --timeout=30 \
        --read-timeout=30 \
        --connect-timeout=10 \
        --dns-timeout=10 \
        --waitretry=5 \
        --retry-connrefused \
        "$url" -O "$out"
}

verify_sha512() {
    local file="$1"; shift
    local sha_file="$1"; shift

    if ! has_cmd shasum; then
        echo "❌ 'shasum' no está disponible para validar SHA-512." >&2
        return 1
    fi

    echo "🔎 Verificando SHA-512 de $(basename "$file")..."

    # Obtiene primera línea no vacía y normaliza CRLF
    local line
    line=$(tr -d '\r' <"$sha_file" | awk 'NF{print; exit}')

    # Requiere formato con hash + nombre de archivo (exacto).
    # Acepta separador con 1+ espacios y prefijo opcional '*'
    local hash fname_in
    if [[ "$line" =~ ^([0-9a-fA-F]{128})[[:space:]]+\*?([^[:space:]]+)$ ]]; then
        hash=${BASH_REMATCH[1]}
        fname_in=${BASH_REMATCH[2]}
    else
        echo "❌ $sha_file debe contener 'HASH  nombre-de-archivo'." >&2
        return 1
    fi

    local fname
    fname=$(basename "$file")
    if [[ "$fname_in" != "$fname" ]]; then
        echo "❌ El .sha512 hace referencia a '$fname_in' y no a '$fname'." >&2
        return 1
    fi

    (
        cd "$(dirname "$file")"
        printf "%s  %s\n" "$hash" "$fname" | shasum -a 512 -c - >/dev/null
    ) && echo "✅ SHA-512 válido para $fname" || {
        echo "❌ SHA-512 no coincide para $fname" >&2
        echo "🧹 Eliminando archivo corrupto: $file" >&2
        rm -f -- "$file"
        echo "↻ Se descargará de nuevo en la próxima ejecución." >&2
        return 1
    }
}

# Si ambos paquetes existen y sus checksums son válidos, no hacer nada
SPARK_TGZ_PATH="$DOWNLOAD_DIR/$SPARK_TGZ"
SPARK_SHA512_PATH="$SPARK_TGZ_PATH.sha512"
HADOOP_TGZ_PATH="$DOWNLOAD_DIR/$HADOOP_TGZ"
HADOOP_SHA512_PATH="$HADOOP_TGZ_PATH.sha512"

if [ -f "$SPARK_TGZ_PATH" ] && [ -f "$SPARK_SHA512_PATH" ] \
   && [ -f "$HADOOP_TGZ_PATH" ] && [ -f "$HADOOP_SHA512_PATH" ]; then
    echo "🔎 Comprobando paquetes en caché..."
    if verify_sha512 "$SPARK_TGZ_PATH" "$SPARK_SHA512_PATH" \
       && verify_sha512 "$HADOOP_TGZ_PATH" "$HADOOP_SHA512_PATH"; then
        echo "✅ Paquetes presentes y verificados. Nada que hacer."
        exit 0
    fi
fi

echo "📦 Descargando componentes..."

# Spark (salto por componente si ya es válido)
SPARK_SKIP=0
if [ -f "$SPARK_TGZ_PATH" ] && [ -f "$SPARK_SHA512_PATH" ]; then
    if verify_sha512 "$SPARK_TGZ_PATH" "$SPARK_SHA512_PATH" >/dev/null 2>&1; then
        echo "✅ Spark ${SPARK_VERSION} ya verificado. Nada que hacer para Spark."
        SPARK_SKIP=1
    fi
fi

if [ "$SPARK_SKIP" -eq 0 ]; then
    if [ ! -f "$SPARK_TGZ_PATH" ]; then
        echo "⬇️  Descargando Spark ${SPARK_VERSION}..."
        download_with_resume "$SPARK_BASE_URL/$SPARK_TGZ" "$SPARK_TGZ_PATH"
    else
        echo "✅ Spark ${SPARK_VERSION} ya existe en caché"
    fi

    if [ ! -f "$SPARK_SHA512_PATH" ]; then
        echo "⬇️  Descargando checksum SHA-512 de Spark..."
        download_with_resume "$SPARK_BASE_URL/$SPARK_TGZ.sha512" "$SPARK_SHA512_PATH"
    fi

    verify_sha512 "$SPARK_TGZ_PATH" "$SPARK_SHA512_PATH"
fi

# Hadoop (salto por componente si ya es válido)
HADOOP_SKIP=0
if [ -f "$HADOOP_TGZ_PATH" ] && [ -f "$HADOOP_SHA512_PATH" ]; then
    if verify_sha512 "$HADOOP_TGZ_PATH" "$HADOOP_SHA512_PATH" >/dev/null 2>&1; then
        echo "✅ Hadoop ${HADOOP_VERSION} ya verificado. Nada que hacer para Hadoop."
        HADOOP_SKIP=1
    fi
fi

if [ "$HADOOP_SKIP" -eq 0 ]; then
    if [ ! -f "$HADOOP_TGZ_PATH" ]; then
        echo "⬇️  Descargando Hadoop ${HADOOP_VERSION}..."
        download_with_resume "$HADOOP_BASE_URL/$HADOOP_TGZ" "$HADOOP_TGZ_PATH"
    else
        echo "✅ Hadoop ${HADOOP_VERSION} ya existe en caché"
    fi

    if [ ! -f "$HADOOP_SHA512_PATH" ]; then
        echo "⬇️  Descargando checksum SHA-512 de Hadoop..."
        download_with_resume "$HADOOP_BASE_URL/$HADOOP_TGZ.sha512" "$HADOOP_SHA512_PATH"
    fi

    verify_sha512 "$HADOOP_TGZ_PATH" "$HADOOP_SHA512_PATH"
fi

echo ""
echo "✅ Todos los componentes están listos en $DOWNLOAD_DIR"
