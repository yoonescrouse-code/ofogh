#!/bin/bash
# Memory Bank Update Script

set -e

# Determine script location
if [ -f /.dockerenv ]; then
    # Inside Docker
    MEMORY_BANK_DIR="/openwrt/memory-bank"
    OPENWRT_SOURCE="/openwrt/source"
else
    # On host
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    MEMORY_BANK_DIR="$SCRIPT_DIR/memory-bank"
    OPENWRT_SOURCE="$SCRIPT_DIR/openwrt-source"
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p "$MEMORY_BANK_DIR"

# Update build information
cat > "$MEMORY_BANK_DIR/latest-build-info.md" << EOF
# Latest Build Information

**Last Updated:** $(date)

## Build Environment
- Docker Image: Ubuntu 22.04
- Target Board: BPI-R3
- Chip: MT7986 (MediaTek)
- OpenWrt Version: $(cd "$OPENWRT_SOURCE" 2>/dev/null && git describe --tags 2>/dev/null || echo "Unknown")

## Build Status
- Last Build: $(ls -t "$MEMORY_BANK_DIR"/*.log 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "No builds yet")
- Output Location: \`bin/targets/mediatek/mt7986/\`

## Common Commands
\`\`\`bash
# Start container
docker-compose up -d

# Enter container
docker-compose exec openwrt-builder bash

# Run build
./build.sh

# Update memory bank
./update-memory-bank.sh
\`\`\`

## Directory Structure
- \`dl/\`: Downloaded packages (outside Docker)
- \`bin/\`: Build outputs (outside Docker)
- \`memory-bank/\`: Build logs and information
- \`docker-history/\`: Bash history persistence
EOF

# Update build history
if [ -f "$MEMORY_BANK_DIR/build-history.txt" ]; then
    echo "" >> "$MEMORY_BANK_DIR/build-history.txt"
    echo "Memory bank updated: $TIMESTAMP" >> "$MEMORY_BANK_DIR/build-history.txt"
fi

echo "Memory bank updated successfully at $TIMESTAMP"

