#!/bin/bash
# Load hp-wmi-sensors kernel module on Flatcar host
set -euo pipefail

MODULE_NAME="hp-wmi-sensors"
HOST_MODULE_DIR="/host/opt/bin"

echo "HP WMI Sensors Module Loader"
echo "============================="

# Check if running with proper privileges
if [ ! -d /host ]; then
    echo "ERROR: /host not mounted. This container must run with hostPath volumes."
    exit 1
fi

# Get host kernel version
KERNEL_VERSION=$(chroot /host uname -r)
echo "Host kernel version: ${KERNEL_VERSION}"

# Check if module is already loaded
if chroot /host lsmod | grep -q "${MODULE_NAME}"; then
    echo "✓ ${MODULE_NAME} module already loaded"

    # Show hwmon devices
    echo ""
    echo "Available hwmon devices:"
    ls -1 /host/sys/class/hwmon/

    echo ""
    echo "Checking for fan sensors..."
    for hwmon in /host/sys/class/hwmon/hwmon*; do
        if [ -f "${hwmon}/name" ]; then
            name=$(cat "${hwmon}/name")
            echo "  ${hwmon}: ${name}"
            if ls "${hwmon}"/fan* 2>/dev/null | grep -q .; then
                echo "    ✓ Fan sensors found!"
                ls -1 "${hwmon}"/fan* | while read sensor; do
                    echo "      - $(basename ${sensor})"
                done
            fi
        fi
    done

    # Keep container running
    echo ""
    echo "Monitoring module status..."
    while true; do
        sleep 300
        if ! chroot /host lsmod | grep -q "${MODULE_NAME}"; then
            echo "WARNING: Module unloaded, reloading..."
            chroot /host insmod "${HOST_MODULE_DIR}/${MODULE_NAME}.ko" || true
        fi
    done
fi

# Copy module to host persistent location
echo "Copying module to ${HOST_MODULE_DIR}..."
mkdir -p "${HOST_MODULE_DIR}"
cp /lib/modules/*.ko "${HOST_MODULE_DIR}/${MODULE_NAME}.ko"

# Try to load the module
echo "Loading ${MODULE_NAME} module..."
if chroot /host insmod "${HOST_MODULE_DIR}/${MODULE_NAME}.ko"; then
    echo "✓ Module loaded successfully"

    # Wait a moment for hwmon devices to appear
    sleep 2

    # Show hwmon devices
    echo ""
    echo "Available hwmon devices:"
    ls -1 /host/sys/class/hwmon/

    echo ""
    echo "Checking for fan sensors..."
    found_fans=0
    for hwmon in /host/sys/class/hwmon/hwmon*; do
        if [ -f "${hwmon}/name" ]; then
            name=$(cat "${hwmon}/name")
            echo "  ${hwmon}: ${name}"
            if ls "${hwmon}"/fan* 2>/dev/null | grep -q .; then
                echo "    ✓ Fan sensors found!"
                ls -1 "${hwmon}"/fan* | while read sensor; do
                    value=""
                    if [ -f "${sensor}" ]; then
                        value=$(cat "${sensor}" 2>/dev/null || echo "N/A")
                    fi
                    echo "      - $(basename ${sensor}): ${value}"
                done
                found_fans=1
            fi
        fi
    done

    if [ ${found_fans} -eq 0 ]; then
        echo "  ⚠ No fan sensors found yet. Check dmesg for errors:"
        chroot /host dmesg | tail -20
    fi

    # Keep container running and monitor module
    echo ""
    echo "Monitoring module status..."
    while true; do
        sleep 300
        if ! chroot /host lsmod | grep -q "${MODULE_NAME}"; then
            echo "WARNING: Module unloaded, reloading..."
            chroot /host insmod "${HOST_MODULE_DIR}/${MODULE_NAME}.ko" || true
        fi
    done
else
    echo "✗ Failed to load module"
    echo "Checking dmesg for errors..."
    chroot /host dmesg | tail -30
    exit 1
fi
