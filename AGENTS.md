# AGENTS.md - Guidelines for AI Coding Agents

This document provides instructions for AI agents working on the BigDataAplicadoLab-2526 repository.

## Project Overview

Educational Big Data lab environment with Docker-based Hadoop and Spark clusters:
- **modulo1**: Multi-node Hadoop cluster (1 master + 2 slaves)
- **modulo1simple**: Single-node Hadoop (pseudo-distributed)
- **modulo2**: Single-node Hadoop + Spark with Jupyter Notebook

## Build/Run Commands

All commands are executed via Makefiles in each module directory.

### Core Commands (all modules)

```bash
cd modulo2  # or modulo1, modulo1simple

make help            # Show available commands
make download-cache  # Download Hadoop/Hive/Spark to central /downloads cache
make build           # Build Docker images
make up              # Start the cluster (waits 20s for services)
make clean           # Stop containers and remove volumes
make shell-master    # Access master container shell as hadoop user
```

### Running Tests

```bash
# Run MapReduce word count test (modulo1simple, modulo2 only)
make test

# Or manually from inside container:
make shell-master
cd ejercicios
bash test_bash.sh
```

### Module-Specific Commands

```bash
# modulo1 only (multi-node)
make shell-slave1    # Access slave1 container
make shell-slave2    # Access slave2 container
```

## Directory Structure

```
BigDataAplicadoLab-2526/
├── downloads/              # Centralized download cache (shared)
├── modulo1/                # Multi-node Hadoop
├── modulo1simple/          # Single-node Hadoop
├── modulo2/                # Hadoop + Spark
│   ├── Makefile
│   ├── docker-compose.yml
│   ├── Base/
│   │   ├── Dockerfile
│   │   ├── start-cluster.sh
│   │   └── config/         # Hadoop, Hive, Spark configs
│   ├── ejercicios/         # MapReduce exercises (mounted)
│   ├── data/               # Persistent data directory
│   └── notebooks/          # Jupyter notebooks
└── migrate-downloads.sh
```

## Code Style Guidelines

### Python Scripts (MapReduce)

```python
#!/usr/bin/env python3
"""Optional module docstring."""
import sys

for line in sys.stdin:
    line = line.strip()
    words = line.split()
    for word in words:
        print('%s\t%s' % (word, 1))
```

- Use `#!/usr/bin/env python3` shebang
- Use `sys.stdin` for input processing
- Output tab-separated key-value pairs: `print('%s\t%s' % (key, value))`
- Handle `ValueError` when parsing counts in reducers
- Keep scripts simple and focused

### Bash/Shell Scripts

```bash
#!/bin/bash

# Use strict mode for critical scripts
set -eu

# Variables in SCREAMING_SNAKE_CASE
HADOOP_VERSION="3.4.1"
INPUT_HDFS="/quijote.txt"

# Use local for function variables
download_file() {
    local url="$1"
    local out="$2"
    wget -q -c "$url" -O "$out"
}

# Emoji prefixes for user feedback
echo "📦 Downloading..."
echo "✅ Completed"
echo "⚠️  Warning"
```

- Use `#!/bin/bash` shebang
- Use `set -eu` for strict error handling in critical scripts
- Variables: `SCREAMING_SNAKE_CASE` for constants
- Always quote variable expansions: `"$VARIABLE"`
- Use `local` keyword for function-scoped variables
- Add emoji prefixes for user feedback
- Use `sudo -u hadoop` for Hadoop commands

### Dockerfiles

- Chain apt-get and cleanup in same RUN layer
- Use cache-first download pattern (check local file before wget)
- Run `dos2unix` on copied scripts for Windows compatibility
- Group related ENV declarations

```dockerfile
# Cache-first pattern example
RUN if [ -f /tmp/downloads/hadoop-${VERSION}.tar.gz ]; then \
    cp /tmp/downloads/hadoop-${VERSION}.tar.gz /tmp/hadoop.tar.gz; \
    else \
    wget -q "https://..." -O /tmp/hadoop.tar.gz; \
    fi
```

### Docker Compose

- Add comments explaining port purposes
- Set resource limits under deploy section
- Use context path relative to project root

### Makefiles

- Use `.PHONY` for non-file targets
- Add `## Comment` after targets for auto-generated help
- Auto-detect Docker Compose v1/v2 compatibility

## Configuration Files

### Hadoop XML (Base/config/)
- `core-site.xml` - fs.defaultFS setting (hdfs://master:9000)
- `hdfs-site.xml` - Replication factor
- `yarn-site.xml` - YARN resource settings
- `mapred-site.xml` - MapReduce framework

### Spark (Base/config/)
- `spark-defaults.conf` - Memory, cores, master URL
- `spark-env.sh` - Environment variables

## Environment Requirements

- Docker and Docker Compose (v1 or v2)
- Make
- wget (macOS: `brew install wget`)
- Windows: Use WSL2 with Ubuntu

## Web UIs (when cluster is running)

| Service | URL | Port |
|---------|-----|------|
| HDFS NameNode | http://localhost:9870 | 9870 |
| YARN ResourceManager | http://localhost:8088 | 8088 |
| Spark Master | http://localhost:8080 | 8080 |
| Spark Application | http://localhost:4040 | 4040 |
| Jupyter Notebook | http://localhost:8888 | 8888 |
| Spark History | http://localhost:18080 | 18080 |

## Common Tasks

### Adding a New Exercise

1. Create Python script in `moduloX/ejercicios/`
2. Follow MapReduce pattern (mapper.py, reducer.py)
3. Add test data file if needed
4. Update test_bash.sh to include new exercise

### Modifying Configuration

1. Edit files in `Base/config/`
2. Rebuild image: `make build`
3. Restart cluster: `make clean && make up`

### Debugging Container Issues

```bash
docker logs modulo2-master          # View logs
docker ps -a | grep modulo2         # Check container status
docker exec -it modulo2-master bash # Access container as root
```

## Important Notes

- Run HDFS commands as `hadoop` user (use `make shell-master`)
- Downloads are cached in `/downloads` at project root (shared across modules)
- Line endings must be LF (Unix-style) - scripts use `dos2unix`
- Container names follow pattern: `moduloX-master`, `hadoop-slaveN`
- Always wait for services after `make up` (20s automatic delay)
