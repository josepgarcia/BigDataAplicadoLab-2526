```
 ____  ____    _      _           _
| __ )|  _ \  / \    | |    __ _ | |__
|  _ \| | | |/ _ \   | |   / _` || '_ \
| |_) | |_| / ___ \  | |__| (_| || |_) |
|____/|____/_/   \_\ |_____\__,_||_.__/

```

## Iniciar laboratorio para el módulo 1

- Clonamos el repositorio y entramos en la carpeta /modulo1
- Utilizamos make para las diferentes tareas:

```bash
# Descargamos la caché (hadoop + hive)
make download-cache

# Construimos las imagenes
make build

# Levantamos los contenedores
make up
```
