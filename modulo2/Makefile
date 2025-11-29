.PHONY: help download-cache build up down restart logs clean shell-spark jupyter test

# Variables
# Autodetección de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
	else echo "docker compose"; fi)
COMPOSE_FILE=docker-compose.yaml
SPARK_VERSION=3.5.0
HADOOP_VERSION=3.3.6

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles para Módulo 2 - Spark/PySpark:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

download-cache: ## Descargar Spark a la caché local
	@echo "📦 Descargando Spark ${SPARK_VERSION}..."
	@cd Spark && chmod +x download-cache.sh && ./download-cache.sh

build: ## Construir la imagen Docker de Spark
	@echo "🔨 Construyendo imagen de Spark..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build

up: ## Levantar el contenedor de Spark
	@echo "🚀 Levantando Spark..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo "✅ Spark Master UI: http://localhost:8080"
	@echo "✅ Spark Application UI: http://localhost:4040"
	@echo "✅ Jupyter Notebook: http://localhost:8888"
	@echo "✅ Spark History Server: http://localhost:18080"

down: ## Detener y eliminar contenedores
	@echo "🛑 Deteniendo Spark..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

restart: down up ## Reiniciar Spark

logs: ## Ver logs del contenedor Spark
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f spark-master

clean: down ## Limpiar todo (contenedores, volúmenes, imágenes)
	@echo "🧹 Limpiando contenedores, volúmenes e imágenes..."
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v --rmi all
	@echo "✅ Limpieza completada"

shell-spark: ## Abrir shell en el contenedor Spark
	docker exec -it spark-master bash

spark-submit: ## Ejecutar spark-submit (ejemplo)

test: ## Ejecuta el notebook de pruebas dentro del contenedor y verifica salida
	@echo "🧪 Ejecutando test de notebook en spark-master..."
	@docker exec spark-master bash -c "jupyter nbconvert --to notebook --execute /home/hadoop/notebooks/test.ipynb --output /home/hadoop/notebooks/test.executed.ipynb" >/tmp/mod2_test.out 2>/tmp/mod2_test.err || true
	@if grep -q "Writing" /tmp/mod2_test.err; then \
	  echo "✅ Test ejecutado correctamente: /home/hadoop/notebooks/test.executed.ipynb"; \
	else \
	  echo "❌ Test fallido"; \
	  echo "--- STDOUT ---"; cat /tmp/mod2_test.out || true; \
	  echo "--- STDERR ---"; cat /tmp/mod2_test.err || true; \
	  exit 1; \
	fi
	@echo "📊 Ejemplo de spark-submit:"
	@echo "docker exec -it spark-master spark-submit --master spark://spark-master:7077 /ruta/al/script.py"

pyspark-shell: ## Abrir PySpark shell
	docker exec -it spark-master pyspark --master spark://spark-master:7077

jupyter: ## Abrir Jupyter con PySpark
	@echo "🚀 Jupyter Notebook disponible en:"
	@docker exec spark-master jupyter notebook list 2>/dev/null || echo "http://localhost:8888"

test-hdfs: ## Probar conexión con HDFS del módulo1
	@echo "🔗 Probando conexión con HDFS..."
	docker exec -it spark-master hdfs dfs -ls /

test-spark: ## Ejecutar un test básico de Spark
	@echo "🧪 Ejecutando test de Spark..."
	docker exec -it spark-master spark-submit \
		--master spark://spark-master:7077 \
		--deploy-mode client \
		--py-files /opt/spark/python/lib/pyspark.zip \
		/tmp/test-spark.py

status: ## Ver estado de los servicios
	@echo "📊 Estado de Spark:"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

install: download-cache build up ## Instalación completa (download + build + up)
	@echo "✅ Instalación completada"
	@echo ""
	@make status
