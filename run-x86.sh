#!/bin/bash
# Quick script to run OpenWrt x86 image with QEMU

set -e

# Find x86 image (prefer combined images, then rootfs)
# First try uncompressed, then compressed
IMAGE=$(find bin/targets/x86 -name "*combined*.img" -not -name "*.gz" 2>/dev/null | head -1)

if [ -z "$IMAGE" ]; then
    # Try any .img file
    IMAGE=$(find bin/targets/x86 -name "*.img" -not -name "*.gz" 2>/dev/null | head -1)
fi

if [ -z "$IMAGE" ]; then
    # Try to find and extract compressed image
    GZ_IMAGE=$(find bin/targets/x86 -name "*combined*.img.gz" 2>/dev/null | head -1)
    if [ -z "$GZ_IMAGE" ]; then
        GZ_IMAGE=$(find bin/targets/x86 -name "*.img.gz" 2>/dev/null | head -1)
    fi
    if [ -n "$GZ_IMAGE" ]; then
        echo "Extracting $GZ_IMAGE..."
        gunzip "$GZ_IMAGE"
        IMAGE="${GZ_IMAGE%.gz}"
    else
        echo "Error: No x86 OpenWrt image found."
        echo ""
        echo "Available images:"
        find bin/targets/x86 -name "*.img*" 2>/dev/null | head -5
        echo ""
        echo "Build OpenWrt for x86 first:"
        echo "  1. Enter container: docker-compose exec openwrt-builder bash"
        echo "  2. cd /openwrt/source"
        echo "  3. make menuconfig (select x86 target)"
        echo "  4. make -j\$(nproc) V=s"
        exit 1
    fi
fi

echo "Starting OpenWrt x86 with image: $IMAGE"
echo ""
echo "Access options:"
echo "  SSH:    ssh root@localhost -p 2222"
echo "  Web UI: http://localhost:8080 (if LuCI installed)"
echo "  Console: Already shown below (press Enter for login)"
echo ""
echo "Note: Default root password is usually empty - set it immediately!"
echo "Exit: Press Ctrl+A then X"
echo ""

# Check if KVM is available
if [ -c /dev/kvm ]; then
    ACCEL="kvm"
    echo "Using KVM acceleration"
else
    ACCEL="tcg"
    echo "Warning: KVM not available, using TCG (slower)"
fi

# Run QEMU
qemu-system-x86_64 \
  -machine type=q35,accel=${ACCEL} \
  -cpu host \
  -smp 2 \
  -m 512M \
  -drive file="$IMAGE",format=raw,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
  -device virtio-net,netdev=net0 \
  -nographic


