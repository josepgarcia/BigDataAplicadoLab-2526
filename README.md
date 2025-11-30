```
 ____  ____    _      _           _
| __ )|  _ \  / \    | |    __ _ | |__
|  _ \| | | |/ _ \   | |   / _` || '_ \
| |_) | |_| / ___ \  | |__| (_| || |_) |
|____/|____/_/   \_\ |_____\__,_||_.__/

```

# Big Data Aplicado - Laboratorio

Repositorio de laboratorios para el curso de Big Data Aplicado. Incluye entornos Docker para Hadoop, Spark y otras tecnologías del ecosistema Big Data.

## 📚 Módulos Disponibles

### [Módulo 1 - Hadoop Multi-Nodo](modulo1/README.md)

Clúster Hadoop con 3 nodos (1 master + 2 slaves) para simular un entorno distribuido real.

- Hadoop 3.4.1 con HDFS y YARN
- Hive 2.3.9 para consultas SQL
- Replicación factor 3
- Ideal para aprender sobre distribución de datos y tolerancia a fallos

**[📖 Ver documentación completa →](modulo1/README.md)**

### [Módulo 1 Simple - Hadoop Single Node](modulo1simple/README.md)

Versión simplificada de Hadoop en un solo nodo para desarrollo y pruebas rápidas.

- Hadoop 3.4.1 en modo pseudo-distribuido
- HDFS con replicación factor 1
- Carpeta compartida con ejemplos MapReduce
- Menor consumo de recursos

**[📖 Ver documentación completa →](modulo1simple/README.md)**

### [Módulo 2 - Hadoop & Spark Single Node](modulo2/README.md)

Entorno optimizado con Hadoop y Apache Spark en un solo nodo.

- Hadoop 3.4.1 (HDFS + YARN)
- Apache Spark 3.5.0 (Master + Worker)
- PySpark con Jupyter Notebook
- Optimizado para bajo consumo de recursos
- Conexión con HDFS

**[📖 Ver documentación completa →](modulo2/README.md)**

## 🚀 Inicio Rápido

```bash
# Clonar el repositorio
git clone https://github.com/josepgarcia/BigDataAplicadoLab-2526.git
cd BigDataAplicadoLab-2526

# Si tienes descargas previas en carpetas locales, migrarlas al sistema centralizado
./migrate-downloads.sh

# Elegir un módulo y seguir su README
cd modulo2  # o modulo1, modulo1simple
make download-cache  # Descarga a /downloads (compartido por todos los módulos)
make build
make up
```

## 📦 Sistema Centralizado de Downloads

Todos los módulos comparten un único directorio `/downloads` en la raíz del proyecto. Esto significa que:

- **Una sola descarga**: Si un módulo descarga un archivo, todos los demás módulos pueden usarlo
- **Ahorro de espacio**: No hay duplicación de archivos entre módulos
- **Más rápido**: Los Makefiles verifican si el archivo ya existe antes de descargar

### Migración desde el Sistema Anterior

Si tienes descargas previas en carpetas locales (`modulo1/Base/downloads`, etc.), ejecuta el script de migración:

```bash
./migrate-downloads.sh
```

Este script moverá todos los archivos al directorio central `/downloads` sin duplicar archivos existentes.

## 📋 Requisitos Previos

- **Docker** y **Docker Compose** instalados
- **Make** instalado
- **wget** disponible en el sistema
  - macOS: `brew install wget`
  - Linux: generalmente preinstalado
  - Windows: ver sección WSL2 abajo

## 🪟 Uso en Windows 11

### Opción Recomendada: WSL2 + Docker Desktop

Para ejecutar estos módulos en Windows 11, se recomienda usar **WSL2 (Windows Subsystem for Linux 2)** con Docker Desktop:

#### 1. Instalar WSL2

```powershell
# En PowerShell como administrador
wsl --install
```

Esto instalará Ubuntu por defecto. Reinicia el equipo si es necesario.

#### 1.1 Instalar WSL2

```powershell
# En PowerShell como administrador
wsl.exe --install Ubuntu-22.04
```

#### 2. Instalar Docker Desktop

- Descarga desde [docker.com](https://www.docker.com/products/docker-desktop/)
- Durante la instalación, asegúrate de habilitar la integración con WSL2
- En Docker Desktop → Settings → Resources → WSL Integration, activa tu distribución Ubuntu

#### 3. Configurar el entorno en WSL2

```bash
# Abrir terminal WSL (Ubuntu)
# Instalar dependencias
sudo apt update
sudo apt install make wget git

# Clonar el repositorio
cd ~
git clone https://github.com/josepgarcia/BigDataAplicadoLab-2526.git
cd BigDataAplicadoLab-2526
```

#### 4. Ejecutar comandos normalmente

```bash
cd modulo1simple  # o el módulo que prefieras
make download-cache
make build
make up
make test  # si está disponible
```

### ⚠️ Consideraciones Importantes para Windows

- **Finales de línea**: Git en Windows puede convertir LF a CRLF. Configura Git para mantener LF:

  ```bash
  git config --global core.autocrlf input
  ```

- **Rendimiento**: Trabaja siempre dentro del sistema de archivos de WSL2 (`/home/usuario/...`) en lugar de `/mnt/c/...` para mejor rendimiento.

- **Acceso a interfaces web**: Las URLs funcionan igual desde Windows (localhost)

- **PowerShell vs WSL**: Ejecuta los comandos `make` desde la terminal WSL (Ubuntu), no desde PowerShell o CMD.

### Alternativa: Git Bash (No Recomendado)

Si prefieres no usar WSL2, puedes intentar con Git Bash, pero pueden surgir problemas de compatibilidad con scripts bash y permisos. WSL2 es la opción más robusta y compatible.

## 🛠️ Comandos Comunes

Cada módulo incluye un `Makefile` con comandos útiles:

```bash
make help          # Ver todos los comandos disponibles
make download-cache# Descargar paquetes a la caché local
make build         # Construir imágenes Docker
make up            # Levantar servicios
make down          # Detener servicios
make clean         # Limpiar contenedores y volúmenes
make logs          # Ver logs
make shell-*       # Acceder al shell de un contenedor
```

## 📂 Estructura del Repositorio

```
BigDataAplicadoLab-2526/
├── downloads/            # Caché centralizado de descargas (compartido por todos los módulos)
├── modulo1/              # Hadoop multi-nodo (3 nodos)
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   └── Base/
├── modulo1simple/        # Hadoop single-node
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   ├── Base/
│   └── ejercicios/       # Scripts y datos de ejemplo
├── modulo2/              # Hadoop & Spark Single Node (Optimizado)
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   ├── Base/
│   ├── ejercicios/
│   ├── data/
│   └── notebooks/
├── migrate-downloads.sh   # Script de migración al sistema centralizado
└── README.md             # Este archivo
```

## 🔗 Enlaces Útiles

- [Apache Hadoop Documentation](https://hadoop.apache.org/docs/stable/)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Docker Documentation](https://docs.docker.com/)
- [WSL2 Documentation](https://learn.microsoft.com/en-us/windows/wsl/)

## 👤 Autor

Josep Garcia

## 📄 Licencia

Este proyecto es de uso educativo para el curso de Big Data Aplicado.
