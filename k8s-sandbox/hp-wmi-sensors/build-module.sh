#!/bin/sh
# Build hp-wmi-sensors kernel module for Flatcar Linux
set -eux

KERNEL_VERSION=${KERNEL_VERSION:-"6.12.66"}
KERNEL_MAJOR=$(echo ${KERNEL_VERSION} | cut -d. -f1)
KERNEL_MINOR=$(echo ${KERNEL_VERSION} | cut -d. -f2)

# Install build dependencies
apk add --no-cache \
    build-base \
    linux-headers \
    curl \
    xz \
    perl \
    elfutils-dev \
    bash \
    bc \
    bison \
    flex \
    openssl-dev

# Download kernel source
cd /tmp
curl -L "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_MAJOR}.${KERNEL_MINOR}.tar.xz" | tar -xJ
cd "linux-${KERNEL_MAJOR}.${KERNEL_MINOR}"

# Minimal config for module build
make defconfig
scripts/config --module SENSORS_HP_WMI
make modules_prepare

# Build the module (allow symbol warnings since we'll load on correct kernel)
make M=drivers/hwmon CONFIG_SENSORS_HP_WMI=m KBUILD_MODPOST_WARN=1

# Copy output
mkdir -p /output
find drivers/hwmon \( -name "hp-wmi-sensors.ko" -o -name "hp_wmi_sensors.ko" \) -exec cp {} /output/ \;

echo "Built modules:"
ls -lh /output/
