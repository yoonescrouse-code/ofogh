# Running OpenWrt x86 on Linux PC

This guide shows how to build OpenWrt for x86 and run it on your Linux PC using QEMU/KVM.

## Build OpenWrt for x86

### Inside Docker Container

```bash
# Enter container
docker-compose exec openwrt-builder bash

# Navigate to source
cd /openwrt/source

# Configure for x86
make menuconfig
```

In menuconfig, select:
- **Target System**: `x86`
- **Subtarget**: `x86_64` (for 64-bit) or `Generic x86` (for 32-bit)
- **Target Profile**: Choose based on your needs (e.g., `Generic`)

Or configure directly:

```bash
# For x86_64 (64-bit)
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

# Or for 32-bit x86
cat > .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_generic=y
CONFIG_TARGET_x86_generic_Generic=y
EOF

# Apply configuration
make defconfig

# Build
make -j$(nproc) V=s
```

## Run x86 OpenWrt Image

### Option 1: Using QEMU/KVM (Recommended)

**Install QEMU:**

```bash
# On host (Ubuntu/Debian)
sudo apt-get install qemu-system-x86 qemu-utils

# On host (Fedora/RHEL)
sudo dnf install qemu-system-x86 qemu-img
```

**Find the built image:**

```bash
# On host
ls -lh bin/targets/x86/64/openwrt-*.img.gz
# or for 32-bit:
ls -lh bin/targets/x86/generic/openwrt-*.img.gz
```

**Run the image:**

```bash
# Images are usually already extracted, but if compressed:
cd bin/targets/x86/64/
# Only if needed: gunzip openwrt-*.img.gz

# Use the combined image (contains bootloader + rootfs)
# Run with QEMU (adjust memory/disk as needed)
qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -cpu host \
  -smp 2 \
  -m 512M \
  -drive file=openwrt-*.img,format=raw,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
  -device virtio-net,netdev=net0 \
  -nographic
```

**Access OpenWrt:**

- SSH: `ssh root@localhost -p 2222` (default password is usually empty, set it first)
- Web UI: `http://localhost:8080` (if LuCI is installed)
- Serial console: Already shown in terminal (press Enter to get login prompt)

**Exit QEMU:** Press `Ctrl+A` then `X`

### Option 2: Using VirtualBox

1. **Convert image to VDI format:**

```bash
# Install VBoxManage (comes with VirtualBox)
qemu-img convert -f raw openwrt-*.img -O vdi openwrt.vdi

# Or use VBoxManage directly
VBoxManage convertfromraw openwrt-*.img openwrt.vdi --format VDI
```

2. **Create VM in VirtualBox:**
   - New VM → Type: Linux, Version: Other Linux (64-bit)
   - Memory: 512MB
   - Hard disk: Use existing → Select `openwrt.vdi`
   - Network: NAT or Bridged (as needed)

3. **Start VM and access via console or SSH**

### Option 3: Using Docker (Container)

You can also run OpenWrt in a Docker container, but this requires a different approach (using OpenWrt's Docker images or building a containerized version).

## Quick Test Script

Create a script to run OpenWrt easily:

```bash
#!/bin/bash
# run-openwrt-x86.sh

IMAGE=$(find bin/targets/x86 -name "*.img" -not -name "*.gz" | head -1)

if [ -z "$IMAGE" ]; then
    echo "No x86 image found. Build OpenWrt for x86 first."
    exit 1
fi

echo "Starting OpenWrt x86 with image: $IMAGE"
echo "SSH: ssh root@localhost -p 2222"
echo "Web: http://localhost:8080"
echo "Press Ctrl+A then X to exit"

qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -cpu host \
  -smp 2 \
  -m 512M \
  -drive file="$IMAGE",format=raw,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
  -device virtio-net,netdev=net0 \
  -nographic
```

Make it executable:

```bash
chmod +x run-openwrt-x86.sh
./run-openwrt-x86.sh
```

## Network Configuration

### Port Forwarding

The QEMU command above forwards:
- Host port 2222 → Guest port 22 (SSH)
- Host port 8080 → Guest port 80 (HTTP)

Change ports as needed:
```bash
hostfwd=tcp::<HOST_PORT>-:<GUEST_PORT>
```

### Bridge Network (Advanced)

For a bridge network that gives the VM its own IP:

```bash
# Create bridge (requires root)
sudo ip link add br0 type bridge
sudo ip link set br0 up

# Run QEMU with bridge
qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -cpu host \
  -smp 2 \
  -m 512M \
  -drive file="$IMAGE",format=raw,if=virtio \
  -netdev bridge,id=net0,br=br0 \
  -device virtio-net,netdev=net0 \
  -nographic
```

## Troubleshooting

### KVM not available

If you get "kvm acceleration not available":
```bash
# Check if KVM is available
lsmod | grep kvm

# If not, enable virtualization in BIOS
# Or run without KVM (slower):
# Remove: -machine type=q35,accel=kvm
# Use: -machine type=q35
```

### Image not booting

- Try different image formats (ext4, squashfs)
- Check if image is for correct architecture (x86_64 vs x86)
- Increase memory: `-m 1024M`

### Can't access via SSH

- Check if SSH is enabled in OpenWrt: `opkg install openssh-server`
- Verify port forwarding: `netstat -tlnp | grep 2222`
- Try accessing via serial console first

## Notes

- Default OpenWrt root password is usually empty (set it immediately!)
- Images are in: `bin/targets/x86/64/` or `bin/targets/x86/generic/`
- For production use, configure networking properly
- Consider installing LuCI web interface: `opkg install luci`


