# OpenWrt Build Environment for BPI-R3 (MT7986)

Docker-based build environment for compiling OpenWrt firmware for the Banana Pi BPI-R3 board with MediaTek MT7986 chipset.

## Quick Start

```bash
# Build Docker image
docker-compose build

# Start container
docker-compose up -d

# Enter container
docker-compose exec openwrt-builder bash

# Prepare OpenWrt source (first time, inside container)
docker-compose exec openwrt-builder bash
cd /openwrt/source
git clone https://git.openwrt.org/openwrt/openwrt.git .
./scripts/feeds update -a
./scripts/feeds install -a

# Configure & build (inside container)
make menuconfig           # Select BPI-R3 / MT7986 target
make -j$(nproc) V=s       # Build
```

## Features

- ✅ Docker-based Ubuntu 22.04 build environment
- ✅ Persistent `dl/` and `bin/` directories (outside Docker)
- ✅ Bash history persistence across container sessions
- ✅ Optional memory bank directory for logs/notes
- ✅ Sphinx documentation (single-page quick notes)

## Documentation

Build and view the documentation:

```bash
# Build documentation
make build-docs

# Serve documentation locally
make serve-docs
# Then open http://localhost:8000
```

Documentation is also available in `docs/build/html/` after building.

## Directory Structure

```
openwrt/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── update-memory-bank.sh   # Memory bank updater
├── Makefile                # Convenience commands
├── dl/                     # Downloaded packages (persistent)
├── bin/                    # Build outputs (persistent)
├── docker-history/         # Bash history (persistent)
├── memory-bank/            # Build logs and info
├── openwrt-source/         # OpenWrt source code
└── docs/                   # Sphinx documentation
```

## Memory Bank

The memory bank system tracks build information:

```bash
# Update memory bank
make update-memory
# or
./update-memory-bank.sh

# View latest build info
cat memory-bank/latest-build-info.md
```

## Requirements

- Docker 20.10+
- Docker Compose 1.29+
- 50GB+ free disk space
- 8GB+ RAM recommended

## License

This build environment setup is provided as-is. OpenWrt itself is licensed under GPL.

