# Módulo 1 Simple - Hadoop Single Node

## Descripción

Este módulo proporciona un entorno Hadoop simplificado de un solo nodo (pseudo-distribuido) para desarrollo y pruebas rápidas.

## Características

- Hadoop 3.4.1 en modo pseudo-distribuido (single-node)
- HDFS con replicación factor 1
- YARN para ejecución de trabajos MapReduce
- Carpeta compartida `ejercicios/` para scripts y datos
- Scripts de prueba MapReduce incluidos

## Requisitos Previos

- Docker y Docker Compose instalados
- Make instalado
- `wget` disponible en el sistema (macOS: `brew install wget`)

## Uso en Windows 11

### Opción Recomendada: WSL2 + Docker Desktop

Para ejecutar este módulo en Windows 11, se recomienda usar **WSL2 (Windows Subsystem for Linux 2)** con Docker Desktop:

1. **Instalar WSL2**:
   ```powershell
   # En PowerShell como administrador
   wsl --install
   ```
   Esto instalará Ubuntu por defecto. Reinicia el equipo si es necesario.

2. **Instalar Docker Desktop**:
   - Descarga desde [docker.com](https://www.docker.com/products/docker-desktop/)
   - Durante la instalación, asegúrate de habilitar la integración con WSL2
   - En Docker Desktop → Settings → Resources → WSL Integration, activa tu distribución Ubuntu

3. **Configurar el entorno en WSL2**:
   ```bash
   # Abrir terminal WSL (Ubuntu)
   # Instalar dependencias
   sudo apt update
   sudo apt install make wget git
   
   # Clonar el repositorio
   cd ~
   git clone <tu-repositorio>
   cd BigDataAplicadoLab-2526/modulo1simple
   ```

4. **Ejecutar comandos normalmente**:
   ```bash
   make download-cache
   make build
   make up
   make test
   ```
Si todo va bien, deberías ver los resultados del conteo de palabras en el archivo `quijote.txt`.

### Consideraciones Importantes

- **Finales de línea**: Git en Windows puede convertir LF a CRLF. Configura Git para mantener LF:
  ```bash
  git config --global core.autocrlf input
  ```

- **Rendimiento**: Trabaja siempre dentro del sistema de archivos de WSL2 (`/home/usuario/...`) en lugar de `/mnt/c/...` para mejor rendimiento.

- **Acceso a interfaces web**: Las URLs funcionan igual desde Windows:
  - NameNode UI: http://localhost:9870
  - ResourceManager UI: http://localhost:8088

- **PowerShell vs WSL**: Ejecuta los comandos `make` desde la terminal WSL (Ubuntu), no desde PowerShell o CMD.

### Alternativa: Git Bash (No Recomendado)

Si prefieres no usar WSL2, puedes intentar con Git Bash, pero pueden surgir problemas de compatibilidad con scripts bash y permisos. WSL2 es la opción más robusta y compatible.

## Instalación Rápida

```bash
# 1. Descargar paquetes (Hadoop + Hive) a la caché local
make download-cache

# 2. Construir la imagen Docker
make build

# 3. Levantar el contenedor
make up
```

## Comandos Disponibles

```bash
make help          # Ver todos los comandos disponibles
make download-cache# Descargar paquetes a la caché local
make build         # Construir la imagen Docker
make up            # Levantar el clúster Hadoop (1 nodo)
make clean         # Detener y limpiar contenedores y volúmenes
make deep-clean    # Limpieza profunda (incluye imágenes y caché)
make shell-master  # Acceder al shell del contenedor como usuario hadoop
make test          # Ejecutar test MapReduce (word count)
```

## Interfaces Web

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088

## Carpeta Compartida `ejercicios/`

La carpeta `ejercicios/` está montada en el contenedor en `/home/hadoop/ejercicios`, permitiendo compartir archivos entre el host y el contenedor.

Contenido incluido:
- `mapper.py` - Script mapper para MapReduce
- `reducer.py` - Script reducer para MapReduce
- `quijote.txt` - Datos de ejemplo (El Quijote)
- `test_docker.sh` - Script para ejecutar test desde el host
- `test_bash.sh` - Script para ejecutar test desde dentro del contenedor

## Ejecutar Test MapReduce

### Desde el host (recomendado)

```bash
make test
```

Este comando ejecuta `test_docker.sh`, que:
1. Sube `quijote.txt` a HDFS
2. Ejecuta un trabajo MapReduce de conteo de palabras
3. Muestra los primeros 20 resultados

### Desde dentro del contenedor

```bash
# Acceder al contenedor
make shell-master

# Ejecutar el test
cd ejercicios
bash test_bash.sh
```

## Ejemplo de Uso de HDFS

```bash
# Acceder al contenedor
make shell-master

# Listar archivos en HDFS
hdfs dfs -ls /

# Crear directorio
hdfs dfs -mkdir /user/hadoop/datos

# Subir archivo
hdfs dfs -put /home/hadoop/ejercicios/quijote.txt /user/hadoop/datos/

# Ver contenido
hdfs dfs -cat /user/hadoop/datos/quijote.txt | head -n 10
```

## Troubleshooting

### El contenedor no inicia

```bash
# Ver logs del contenedor
docker logs hadoop-master-simple

# Verificar estado
docker ps -a | grep hadoop-master-simple
```

### Error de permisos en HDFS

Los comandos HDFS deben ejecutarse como usuario `hadoop`. Si usas `docker exec`, añade `-u hadoop`:

```bash
docker exec -u hadoop hadoop-master-simple hdfs dfs -ls /
```

### Limpiar y reiniciar

```bash
# Limpieza completa
make clean

# Reconstruir y levantar
make build
make up
```

## Diferencias con `modulo1`

- **Nodos**: 1 nodo (master) vs 3 nodos (master + 2 slaves)
- **Replicación**: Factor 1 vs Factor 3
- **Recursos**: Menor consumo de CPU y memoria
- **Uso**: Desarrollo y pruebas vs Simulación de clúster

## Estructura del Proyecto

```
modulo1simple/
├── Makefile                        # Comandos disponibles
├── docker-compose.yml              # Configuración del servicio
├── Base/
│   ├── Dockerfile                  # Imagen Docker
│   ├── download-cache.sh           # Script de descarga
│   ├── start-hadoop.sh             # Script de inicio
│   ├── config/                     # Configuraciones Hadoop
│   └── downloads/                  # Caché de descargas
└── ejercicios/                     # Carpeta compartida
    ├── mapper.py                   # Mapper MapReduce
    ├── reducer.py                  # Reducer MapReduce
    ├── quijote.txt                 # Datos de ejemplo
    ├── test_docker.sh              # Test desde host
    └── test_bash.sh                # Test desde contenedor
```

## Autor

Josep Garcia
