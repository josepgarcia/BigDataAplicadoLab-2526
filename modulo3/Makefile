.PHONY: help up up-carga up-generar-carga clean status shell-prometheus shell-grafana shell-nginx

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles para Módulo 3 - DevOps & Monitoring:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Flujo recomendado:"
	@echo "  1. make up                 # Levantar monitoring básico"
	@echo "  2. make up-carga           # Añadir Nginx + exporter"
	@echo "  3. make up-generar-carga   # Añadir generadores de tráfico y estrés"
	@echo "  4. make clean              # Parar y limpiar todo"

# Autodetección de Docker Compose (V2 "docker compose" o V1 "docker-compose")
DOCKER_COMPOSE := $(shell \
    if docker compose version >/dev/null 2>&1; then echo "docker compose"; \
    elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; \
    else echo "docker compose"; fi)

up: ## Levantar stack de monitoring básico
	@echo "🚀 Levantando stack DevOps & Monitoring..."
	$(DOCKER_COMPOSE) up -d
	@echo "⏳ Esperando 10 segundos a que los servicios estén listos..."
	@for i in $$(seq 1 10); do \
		printf "\r["; \
		for j in $$(seq 1 10); do \
			if [ $$j -le $$i ]; then printf "██"; else printf "░░"; fi; \
		done; \
		printf "] $$i/10s"; \
		sleep 1; \
	done
	@echo ""
	@echo "✅ Stack levantado!"
	@echo "📊 Prometheus:     http://localhost:9090"
	@echo "📊 Grafana:        http://localhost:3000  (admin/admin)"
	@echo "📊 Node Exporter:  http://localhost:9100"
	@echo "📊 cAdvisor:       http://localhost:8080"

up-carga: ## Añadir Nginx + nginx-exporter (profile: carga)
	@echo "🚀 Levantando Nginx + nginx-exporter..."
	$(DOCKER_COMPOSE) --profile carga up -d
	@echo "✅ Nginx levantado!"
	@echo "🌐 Nginx:          http://localhost:8081"
	@echo "📊 Nginx Exporter: http://localhost:9113"

up-generar-carga: ## Añadir generadores de tráfico y estrés (profiles: carga + generar-carga)
	@echo "🚀 Levantando generadores de carga (requiere Nginx)..."
	$(DOCKER_COMPOSE) --profile carga --profile generar-carga up -d
	@echo "✅ Generadores de carga activos!"
	@echo "🔥 traffic-generator: haciendo peticiones HTTP a Nginx"
	@echo "🔥 stress-ng:         generando carga de CPU y memoria"

clean: ## Limpiar contenedores, volúmenes y red (todos los profiles)
	@echo "🧹 Limpiando contenedores, volúmenes y red..."
	$(DOCKER_COMPOSE) --profile carga --profile generar-carga down -v
	@echo "✅ Limpieza completada!"

status: ## Ver estado de los contenedores
	@$(DOCKER_COMPOSE) --profile carga --profile generar-carga ps -a

shell-prometheus: ## Acceder al shell de Prometheus
	docker exec -it modulo3-prometheus sh

shell-grafana: ## Acceder al shell de Grafana
	docker exec -it modulo3-grafana bash

shell-nginx: ## Acceder al shell de Nginx
	docker exec -it modulo3-nginx bash
