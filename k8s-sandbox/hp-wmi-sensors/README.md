# HP WMI Sensors Kernel Module Loader

This component builds and loads the `hp-wmi-sensors` kernel module on Flatcar Container Linux nodes to expose fan speed and additional hardware sensors on HP business-class PCs.

## Overview

HP EliteDesk systems (and other HP business PCs) expose hardware monitoring data via WMI, but the `hp-wmi-sensors` kernel driver is not compiled in Flatcar's default kernel configuration. This component:

1. Builds the `hp-wmi-sensors.ko` kernel module from the Linux kernel source
2. Deploys it as a DaemonSet on Flatcar nodes
3. Loads the module to expose fan RPM, temperatures, and other sensors via hwmon
4. Makes metrics available to Prometheus node-exporter

## Supported Hardware

- HP EliteDesk 800 G3 Mini (tested)
- HP EliteDesk G2-G6 series
- Other HP business-class PCs with WMI sensor support

## Available Metrics

Once loaded, the following metrics become available:

- `node_hwmon_fan_rpm` - Fan speed in RPM
- `node_hwmon_fan_alarm` - Fan fault/alarm status
- Additional temperature sensors from HP WMI
- Voltage and current sensors (on some models)

## Architecture

### Components

- **Dockerfile**: Multi-stage build that compiles the kernel module
- **build-module.sh**: Script to download kernel source and build the module
- **load-module.sh**: Runtime script that loads the module on the host
- **daemonset.yaml**: Kubernetes DaemonSet that runs on Flatcar nodes only

### Build Process

1. GitHub Actions workflow triggers on changes to this directory
2. Alpine Linux container downloads Linux kernel 6.12 source
3. Module is compiled with `CONFIG_SENSORS_HP_WMI=m`
4. Container image is pushed to `ghcr.io/starslider/hp-wmi-sensors-loader`

### Runtime Process

1. DaemonSet runs on nodes matching hostnames (flatcar-worker-*)
2. Container runs with privileged access and host mounts
3. Module is copied to `/opt/bin/` on the host
4. `insmod` loads the module into the running kernel
5. Container monitors module status and reloads if needed

## Deployment

Managed via ArgoCD:

```bash
kubectl apply -f k8s-sandbox/apps/hp-wmi-sensors.yaml
```

## Verification

Check if the module is loaded:

```bash
# Check DaemonSet status
kubectl get daemonset -n kube-system hp-wmi-sensors-loader

# View logs
kubectl logs -n kube-system -l app=hp-wmi-sensors-loader

# Verify module on a node
kubectl debug node/flatcar-worker-01 -it --image=alpine -- chroot /host lsmod | grep hp_wmi

# Check for fan sensors
kubectl debug node/flatcar-worker-01 -it --image=alpine -- \
  chroot /host sh -c 'ls -la /sys/class/hwmon/hwmon*/fan*'
```

Check node-exporter metrics:

```bash
# Port-forward to node-exporter on a Flatcar node
kubectl port-forward -n monitoring <node-exporter-pod> 9100:9100

# Query fan metrics
curl http://localhost:9100/metrics | grep node_hwmon_fan
```

## Troubleshooting

### Module fails to load

Check dmesg on the host:
```bash
kubectl debug node/flatcar-worker-01 -it --image=alpine -- chroot /host dmesg | tail -50
```

Common issues:
- **Version mismatch**: Module built for different kernel version
- **Missing symbols**: Kernel configuration differences
- **Hardware not supported**: System doesn't have WMI sensor interface

### No fan sensors after loading

Some HP systems may not expose fan data via WMI. Check available WMI devices:

```bash
kubectl debug node/flatcar-worker-01 -it --image=alpine -- \
  ls /host/sys/bus/wmi/devices/
```

Look for `8F1F6435-9F42-42C8-BADC-0E9424F20C9A` (HP WMI Sensors GUID).

### Rebuild for different kernel version

Update the `KERNEL_VERSION` build arg in the Dockerfile and rebuild:

```bash
docker build --build-arg KERNEL_VERSION=6.12.66 -t hp-wmi-sensors-loader .
```

## References

- [Linux HP WMI Sensors Driver Documentation](https://docs.kernel.org/hwmon/hp-wmi-sensors.html)
- [HP WMI Sensors Driver Source](https://github.com/kangtastic/hp-wmi-sensors)
- [Phoronix: HP Business-Class PCs Linux 6.5 Sensors](https://www.phoronix.com/news/HP-WMI-Sensors-Linux-Driver)
- [Flatcar: Building Custom Kernel Modules](https://www.flatcar.org/docs/latest/reference/developer-guides/kernel-modules/)

## License

The `hp-wmi-sensors` kernel module is part of the Linux kernel and licensed under GPL-2.0.
