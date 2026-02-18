OpenWrt Build (Docker) - BPI-R3 (MT7986)
========================================

Single-page notes for building OpenWrt for the Banana Pi BPI-R3 (MT7986) using Docker.


Minimal Workflow
----------------

.. code-block:: bash

   # Build Docker image (on host)
   docker-compose build

   # Start container (on host)
   docker-compose up -d

   # Enter container
   docker-compose exec openwrt-builder bash

   # Inside container: prepare source on first run
   cd /openwrt/source
   git clone https://git.openwrt.org/openwrt/openwrt.git .

   # Update feeds
   ./scripts/feeds update -a
   ./scripts/feeds install -a

   # Configure (menuconfig, choose BPI-R3 / MT7986)
   make menuconfig

   # Build
   make -j$(nproc) V=s


Persistent Directories
----------------------

These are **outside Docker** but mounted inside:

- ``./dl/``  →  ``/openwrt/dl``   (downloaded sources)
- ``./bin/`` →  ``/openwrt/bin``  (firmware images)
- ``./openwrt-source/`` → ``/openwrt/source`` (OpenWrt tree)
- ``./docker-history/`` → ``/root/.history`` (bash history)
- ``./memory-bank/`` → ``/openwrt/memory-bank`` (logs/notes, optional)

So you build **inside** the container, but artifacts and downloads live on the host.


Typical Commands
----------------

On the host:

.. code-block:: bash

   # Start / stop / inspect
   docker-compose up -d
   docker-compose ps
   docker-compose down

   # Enter build shell
   docker-compose exec openwrt-builder bash

Inside the container:

.. code-block:: bash

   cd /openwrt/source

   # Update to latest OpenWrt
   git pull

   # Re-run configuration if needed
   make menuconfig

   # Build again (reuses dl/ and bin/ on host)
   make -j$(nproc) V=s

Built images appear on the host under:

.. code-block:: text

   ./bin/targets/mediatek/mt7986/   # For BPI-R3
   ./bin/targets/x86/64/             # For x86_64
   ./bin/targets/x86/generic/        # For x86 32-bit


Building for x86 (to run on PC)
--------------------------------

To build OpenWrt for x86 and run it on your Linux PC:

.. code-block:: bash

   # Inside container
   cd /openwrt/source
   make menuconfig
   # Select: Target System → x86 → x86_64 → Generic

   # Or configure directly:
   cat > .config << 'EOF'
   CONFIG_TARGET_x86=y
   CONFIG_TARGET_x86_64=y
   CONFIG_TARGET_x86_64_Generic=y
   EOF
   make defconfig

   # Build
   make -j$(nproc) V=s

   # On host: run with QEMU (or use ./run-x86.sh helper script)
   ./run-x86.sh
   
   # Or manually:
   cd bin/targets/x86/64/
   qemu-system-x86_64 -machine type=q35,accel=kvm -cpu host -smp 2 -m 512M \
     -drive file=openwrt-x86-64-generic-squashfs-combined.img,format=raw,if=virtio \
     -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
     -device virtio-net,netdev=net0 -nographic

See ``RUN_X86.md`` for detailed instructions.

