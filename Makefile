.PHONY: help build-docs serve-docs clean-docs update-memory

help:
	@echo "Available targets:"
	@echo "  docker-build    - Build Docker image"
	@echo "  docker-up       - Start Docker container"
	@echo "  docker-shell    - Enter Docker container"
	@echo "  build-docs      - Build Sphinx documentation"
	@echo "  serve-docs      - Serve documentation on http://localhost:8000"
	@echo "  update-memory   - Update memory bank"
	@echo "  clean-docs      - Clean documentation build files"

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-shell:
	docker-compose exec openwrt-builder bash

build-docs:
	@if [ ! -d "docs/venv" ]; then \
		echo "Creating virtual environment..."; \
		cd docs && python3 -m venv venv; \
	fi
	@echo "Installing dependencies..."
	cd docs && ./venv/bin/pip install -q -r requirements.txt
	@echo "Building documentation..."
	cd docs && ./venv/bin/python -m sphinx -b html source build/html

serve-docs: build-docs
	cd docs/build/html && python3 -m http.server 8000

update-memory:
	./update-memory-bank.sh

clean-docs:
	cd docs && rm -rf build/ venv/

