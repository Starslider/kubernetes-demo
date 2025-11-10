# Flatcar OS USB Boot and Installation on HP EliteDesk 800 G3 Mini (Live Config Edition)

Since you'll boot the HP EliteDesk 800 G3 Mini from the USB stick with the Flatcar ISO (live environment) and create the Ignition config directly in the live session, this revised guide skips the pre-boot prep (downloading ISO, flashing USB, BIOS/booting). It starts from the live shell and focuses on creating the Butane config, compiling to Ignition, installing to disk, and verifying the Kubernetes worker setup (v1.34.1, containerd v2.1.4, auto-join to `192.168.1.30:6443`).

**Key Notes**:
- **Live Session**: You're in a root shell (`core@core-01 ~ $`) with full sudo—no password.
- **Internet**: Ensure network is up (`ip addr show`; ping `8.8.8.8`).
- **Data Loss**: Install overwrites target disk—backup first!
- **Ignition**: Compiled on-the-fly in live session; no external HTTP server needed (applied directly).

## Step 1: Prepare Butane and Dependencies in Live Session

1. **Update Packages** (if needed; live has basics):
   ```
   sudo emerge-webrsync  # Sync portage (rarely needed in live)
   ```

2. **Install Butane** (temporary in live RAM):
   ```
   cd /tmp
   wget https://github.com/coreos/butane/releases/download/v0.25.1/butane-x86_64-unknown-linux-gnu
   chmod +x butane-x86_64-unknown-linux-gnu
   mkdir -p ~/bin
   mv butane-x86_64-unknown-linux-gnu ~/bin/butane
   export PATH="$HOME/bin:$PATH"
   which butane  # Should show: /home/core/bin/butane
   ```

3. **Regenerate Join Token** (do this first on control plane via SSH, then note it here):
   - On control plane: `kubeadm token create --print-join-command`.
   - Copy the full command (e.g., `kubeadm join 192.168.1.30:6443 --token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:...`).

## Step 2: Create the Butane Config File

In the live shell, create `config.yaml` with `vi` or `nano` (install if needed: `sudo emerge app-editors/nano`). Update:
- `hostname` and `--node-name` (e.g., `flatcar-worker-02`).
- Join command in `kubeadm-join.service` (use fresh token/hash).

```
vi config.yaml
```

Paste this content:

```yaml
variant: flatcar
version: 1.0.0

passwd:
  users:
    - name: kubeuser
      groups: [sudo, wheel]
      password_hash: "$6$EXAMPLE_SALT$EXAMPLE_HASH_REPLACE_WITH_YOUR_OWN_PASSWORD_HASH"

storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: flatcar-worker-03
    - path: /etc/extensions/kubernetes.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/kubernetes/kubernetes-v1.34.1-x86-64.raw
    - path: /etc/extensions/containerd.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/containerd/containerd-2.1.4-x86-64.raw
  links:
    - path: /etc/extensions/containerd-flatcar.raw
      target: /dev/null
      overwrite: true

systemd:
  units:
    - name: containerd.service
      enabled: true
    - name: kubeadm-join.service
      enabled: true
      contents: |
        [Unit]
        Description=Kubeadm join service
        Requires=containerd.service kubelet.service
        After=containerd.service kubelet.service
        After=network-online.target
        ConditionPathExists=!/etc/kubernetes/kubelet.conf
        BindsTo=containerd.service

        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/bin/true
        ExecStartPre=/usr/bin/kubeadm join <CONTROL_PLANE_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH> --node-name flatcar-worker-02

        [Install]
        WantedBy=multi-user.target
```

- Save/exit (vi: `:wq`; nano: Ctrl+X > Y > Enter).

## Step 3: Compile Butane to Ignition

```
butane -o config.ign config.yaml
```

- Output: `config.ign` (JSON; ~5-10KB). Verify: `ls -l config.ign`.
- If errors: Check YAML syntax (`butane -p config.yaml` for pretty-print).

## Step 4: Install Flatcar to Disk

1. **Identify Target Disk**:
   ```
   lsblk -f  # e.g., /dev/sda (internal SSD/HDD; avoid USB)
   fdisk -l /dev/sda  # Confirm size/type
   ```

2. **Clear Existing Partitions** (if needed - WARNING: This will destroy all data!):
   ```
   # Use gdisk for GPT disks (safer than fdisk for GPT)
   sudo gdisk /dev/sda
   
   # In gdisk interactive mode, run these commands:
   # x        (enter expert mode)
   # z        (zap/destroy GPT and MBR data structures)
   # Y        (confirm destruction)
   # Y        (confirm blank out MBR)
   
   # Alternative one-liner method:
   sudo sgdisk --zap-all /dev/sda
   
   # Verify partitions are gone:
   sudo fdisk -l /dev/sda
   ```

3. **Run flatcar-install** (with Embedded Ignition):
   ```
   # Check available options first
   sudo flatcar-install -h
   
   # Basic installation command
   sudo flatcar-install -d /dev/sda -i config.ign
   ```
   - **Options**:
     - `-d /dev/sda`: Target disk (wipes partitions!).
     - `-i config.ign`: Embeds your config directly (no URL needed).
     - Verbose: Add `-v`.
   
   **Alternative syntax if above doesn't work:**
   ```
   sudo flatcar-install /dev/sda -i config.ign
   ```
   - Process: Partitions disk, writes image (~1-2GB download if not copied), applies Ignition (~5-10 min). Success: "Installation complete! Rebooting now."

**HP Tip**: If NVMe SSD, use `/dev/nvme0n1`. Monitor with `watch lsblk`.

## Step 5: Reboot and Verify Installation

1. **Reboot**:
   ```
   sudo reboot
   ```
   - Remove USB. System boots from disk (GRUB auto-selects Flatcar).

2. **SSH Access**:
   ```
   ssh kubeuser@<node-ip>  # Password: "kube"
   ```
   - Find IP: Router DHCP or attach monitor/keyboard to HP console.

3. **On-Node Verification**:
   ```
   hostname  # flatcar-worker-02
   cat /etc/os-release  # Flatcar Linux 4230.2.4 (stable)
   systemd-sysext status | grep -E 'kubernetes|containerd'  # Applied v1.34.1 & v2.1.4 (no containerd-flatcar)
   kubeadm version | head -1  # v1.34.1
   containerd --version  # v2.1.4
   sudo systemctl status kubeadm-join containerd kubelet  # Active/exited success
   sudo journalctl -u kubeadm-join -e  # "This node has joined the cluster"
   ```

4. **From Control Plane Verification**:
   ```
   kubectl get nodes -o wide  # Ready, containerd://2.1.4
   kubectl get pods -n kube-system -o wide | grep flatcar-worker-02  # DaemonSets Running
   ```

## Step 6: Test and Cleanup

- **Pod Test**: `kubectl run test --image=nginx --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"flatcar-worker-02"}}}'`; verify on node.
- **Kubectl on Node**: SCP `admin.conf` from control plane and configure as in prior manuals.
- **Updates**: `sudo systemctl enable --now systemd-sysupdate.timer` (add K8s/containerd confs).
- **Live Session Cleanup**: Not needed—reboot discards RAM changes.

## Troubleshooting (Live Config Edition)

| Issue | Cause | Fix |
|-------|-------|-----|
| **Butane Not Found** | Missing Binary | Redownload in live: `wget ...` as in Step 1. |
| **Compile Fails** | YAML Error | Edit `config.yaml`; test with `butane -p`. |
| **Install Fails (Download)** | Network | `ping extensions.flatcar.org`; use `--copy-extension-images` to pre-fetch. |
| **Ignition Embed Error** | File Path | Ensure `config.ign` in current dir; use absolute: `--ignition-file /path/to/config.ign`. |
| **Sysext Not Applied Post-Boot** | Built-in Conflict | Verify link to `/dev/null`; `sudo systemctl restart systemd-sysext`. |
| **No SSH** | Password/IP | Console login as `core` (no pass); set via `sudo passwd kubeuser` if needed. |
| **Change Hostname Post-Install** | Need Different Name | See hostname change methods below. |

## Changing Hostname After Installation

If you need to change the hostname after Flatcar is installed, you have several options:

### Method 1: Temporary Change (until reboot)
```bash
sudo hostnamectl set-hostname new-hostname
```

### Method 2: Permanent Change via /etc/hostname
```bash
# Edit the hostname file
sudo vi /etc/hostname
# Replace content with your new hostname, save and exit

# Apply immediately
sudo hostnamectl set-hostname $(cat /etc/hostname)

# Restart networking services
sudo systemctl restart systemd-networkd
```

### Method 3: Update Kubernetes Node Name (if already joined)
If the node is already joined to the cluster, you'll need to:

1. **Drain and delete the old node** (from control plane):
   ```bash
   kubectl drain flatcar-worker-02 --ignore-daemonsets --delete-emptydir-data
   kubectl delete node flatcar-worker-02
   ```

2. **Change hostname on the worker node**:
   ```bash
   sudo vi /etc/hostname  # Change to new name
   sudo hostnamectl set-hostname new-hostname
   ```

3. **Reset and rejoin with new name**:
   ```bash
   sudo kubeadm reset -f
   # Get new join command from control plane
   sudo kubeadm join 192.168.1.30:6443 --token <new-token> --discovery-token-ca-cert-hash sha256:<hash> --node-name new-hostname
   ```

### Method 4: Complete Reinstall (cleanest option)
If you want a completely clean setup:
1. Boot from USB again
2. Update the `inline: new-hostname` in your `config.yaml`
3. Update the `--node-name new-hostname` in the kubeadm-join service
4. Recompile with `butane -o config.ign config.yaml`
5. Reinstall with `sudo flatcar-install -d /dev/sda -i config.ign`

## Changing IP Address After Installation

Flatcar uses `systemd-networkd` for network management. Here are methods to change the IP address:

### Method 1: DHCP to Static IP Conversion
If currently using DHCP and want to switch to static:

1. **Create network configuration file**:
   ```bash
   sudo mkdir -p /etc/systemd/network
   sudo vi /etc/systemd/network/10-static.network
   ```

2. **Add static IP configuration**:
   ```ini
   [Match]
   Name=eth0
   # Or use: Name=en*  for any ethernet interface

   [Network]
   DHCP=no
   Address=192.168.1.36/24
   Gateway=192.168.1.1
   DNS=8.8.8.8
   DNS=8.8.4.4
   ```

3. **Apply the changes**:
   ```bash
   sudo systemctl restart systemd-networkd
   sudo systemctl restart systemd-resolved
   ```

### Method 2: Modify Existing Static Configuration
If already using static IP:

1. **Find existing network file**:
   ```bash
   ls /etc/systemd/network/
   ```

2. **Edit the configuration**:
   ```bash
   sudo vi /etc/systemd/network/10-static.network
   # Update the Address= line with new IP
   ```

3. **Restart networking**:
   ```bash
   sudo systemctl restart systemd-networkd
   ```

### Method 3: Temporary IP Change (until reboot)
```bash
# Remove old IP
sudo ip addr del 192.168.1.42/24 dev eth0

# Add new IP
sudo ip addr add 192.168.1.36/24 dev eth0

# Update default route if needed
sudo ip route del default
sudo ip route add default via 192.168.1.1
```

### Method 4: Using nmcli (if NetworkManager is installed)
```bash
# List connections
sudo nmcli connection show

# Modify connection
sudo nmcli connection modify "Wired connection 1" ipv4.addresses "192.168.1.36/24"
sudo nmcli connection modify "Wired connection 1" ipv4.gateway "192.168.1.1"
sudo nmcli connection modify "Wired connection 1" ipv4.method manual

# Apply changes
sudo nmcli connection up "Wired connection 1"
```

### Updating Kubernetes After IP Change
If the node is part of a Kubernetes cluster:

1. **Update kubelet configuration** (if needed):
   ```bash
   sudo vi /var/lib/kubelet/kubeadm-flags.env
   # Add or update: --node-ip=NEW_IP_ADDRESS
   ```

2. **Restart kubelet**:
   ```bash
   sudo systemctl restart kubelet
   ```

3. **Verify from control plane**:
   ```bash
   kubectl get nodes -o wide
   # Check that Internal-IP shows the new address
   ```

### Method 5: Complete Reinstall with Static IP (cleanest option)
Add network configuration to your Butane config before installation:

```yaml
storage:
  files:
    - path: /etc/systemd/network/10-static.network
      mode: 0644
      contents:
        inline: |
          [Match]
          Name=eth0

          [Network]
          DHCP=no
          Address=192.168.1.36/24
          Gateway=192.168.1.1
          DNS=8.8.8.8
          DNS=8.8.4.4
```

**Important Notes:**
- Replace `eth0` with your actual interface name (check with `ip link show`)
- Ensure the new IP doesn't conflict with other devices
- Update any firewall rules or port forwards on your router
- SSH connections will be interrupted during IP changes

For more: [Flatcar ISO Install Docs](https://www.flatcar.org/docs/latest/installing/bare-metal/installing-to-disk/). Your worker auto-joins on first boot—reprovision for changes. Let me know how it goes!