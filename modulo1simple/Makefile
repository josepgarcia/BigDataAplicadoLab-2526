.PHONY: help download-cache build up clean shell-master

help:
	@echo "Información de todas las opciones"

# Descargar Hadoop y Hive al caché local (acelera reconstrucciones)
download-cache:
	@echo "📦 Descargando archivos al caché local..."
	@cd Base && ./download-cache.sh

# Variables
# Autodetección de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
    if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
    elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
    else echo "docker compose"; fi)

# Construir las imágenes
build:
	@echo "🔨 Construyendo imágenes Docker..."
	$(DOCKER_COMPOSE) build

# Levantar el clúster
up:
	@echo "🚀 Levantando clúster Hadoop (1 nodo)..."
	$(DOCKER_COMPOSE) up -d
	@echo "⏳ Esperando 20 segundos a que los servicios estén listos..."
	@for i in $$(seq 1 20); do \
		printf "\r["; \
		for j in $$(seq 1 20); do \
			if [ $$j -le $$i ]; then printf "█"; else printf "░"; fi; \
		done; \
		printf "] $$i/20s"; \
		sleep 1; \
	done; \
	echo ""
	@echo "✅ Clúster levantado!"
	@echo "📊 NameNode UI: http://localhost:9870"
	@echo "📊 ResourceManager UI: http://localhost:8088"

clean:
	@echo "🧹 Limpiando contenedores, volúmenes y red del proyecto..."
	$(DOCKER_COMPOSE) down -v
	@echo "✅ Limpieza completada!"

# Ejecutar test MapReduce
test:
	@echo "🧪 Ejecutando test MapReduce..."
	@cd ejercicios && sh test_docker.sh

# Acceder al shell del master
shell-master:
	docker exec -it -u hadoop hadoop-master-simple bash
