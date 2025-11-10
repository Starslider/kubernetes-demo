# 🚀 Kubernetes on Arch Linux Home Lab

<div align="center">

![Kubernetes Version](https://img.shields.io/badge/Kubernetes-v1.34-326ce5?style=flat-square&logo=kubernetes&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Latest-1793d1?style=flat-square&logo=arch-linux&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)
[![Documentation](https://img.shields.io/badge/Documentation-Read%20Now-blue?style=flat-square)](k8s-sandbox/README.md)

A comprehensive guide and configuration for deploying a production-ready Kubernetes cluster on Arch Linux VMs for your home lab

</div>

## 🎯 Overview

This repository provides a complete setup guide and configuration for deploying a Kubernetes cluster on Arch Linux virtual machines. While primarily targeting Unraid environments, the setup is adaptable to any virtualization platform.

### ✨ Key Features

- 🔧 Step-by-step installation guide
- 🔐 Security-focused configuration with Authentik
- 🌐 Complete networking setup with Cilium
- 📦 Production-grade components
- 🚀 GitOps with ArgoCD
- 🎮 Gaming server support (DayZ)
- 🏠 Home automation with Home Assistant
- 🔍 Monitoring with VictoriaMetrics & Grafana
- 🗄️ Container registry with Harbor
- 📝 Workflow automation with n8n
- 🌍 DNS management with External DNS
- 🔒 Certificate management with cert-manager

## 🏗️ Architecture

### Core Components

- **Control Plane Node**
  - 4 CPU cores
  - 8GB RAM
  - Core services: containerd, kubelet, kubeadm

- **Worker Nodes (x3)**
  - 2 CPU cores each
  - 8GB RAM each
  - Same core services as control plane

### 🌟 Included Applications

<table>
<tr>
<td align="center">
  <img src="https://raw.githubusercontent.com/cncf/artwork/master/projects/argo/icon/color/argo-icon-color.svg" width="40" height="40"/><br/>
  ArgoCD<br/>
  <sub>GitOps Engine</sub>
</td>
<td align="center">
  <img src="https://raw.githubusercontent.com/cilium/cilium/master/Documentation/images/logo-solo.svg" width="40" height="40"/><br/>
  Cilium<br/>
  <sub>Networking</sub>
</td>
<td align="center">
  <img src="https://goauthentik.io/img/icon.svg" width="40" height="40"/><br/>
  Authentik<br/>
  <sub>Identity</sub>
</td>
<td align="center">
  <img src="https://raw.githubusercontent.com/cert-manager/cert-manager/master/logo/logo.png" width="40" height="40"/><br/>
  cert-manager<br/>
  <sub>Certificates</sub>
</td>
</tr>
<tr>
<td align="center">
  <img src="images/victoriametrics-logo.png" width="40" height="40"/><br/>
  VictoriaMetrics<br/>
  <sub>Monitoring</sub>
</td>
<td align="center">
  <img src="https://raw.githubusercontent.com/grafana/grafana/main/public/img/grafana_icon.svg" width="40" height="40"/><br/>
  Grafana<br/>
  <sub>Dashboards</sub>
</td>
<td align="center">
  <img src="https://avatars.githubusercontent.com/u/68335991?v=4" width="40" height="40"/><br/>
  External Secrets<br/>
  <sub>Secrets Management</sub>
</td>
<td align="center">
  <img src="https://goharbor.io/img/logos/harbor-icon-color.png" width="40" height="40"/><br/>
  Harbor<br/>
  <sub>Registry</sub>
</td>
</tr>
<tr>
<td align="center">
  <img src="https://avatars.githubusercontent.com/u/45487711" width="40" height="40"/><br/>
  n8n<br/>
  <sub>Automation</sub>
</td>
<td align="center">
  <img src="https://raw.githubusercontent.com/kubernetes-sigs/external-dns/master/docs/img/external-dns.png" width="40" height="40"/><br/>
  External DNS<br/>
  <sub>DNS Management</sub>
</td>
<td align="center">
  <img src="https://www.kubeblog.com/wp-content/uploads/2024/09/gateway-api-logo-1.png" width="40" height="40"/><br/>
  Gateway API<br/>
  <sub>Ingress/Traffic</sub>
</td>
<td align="center">
  <img src="https://artifacthub.io/static/media/placeholder_pkg_helm.png" width="40" height="40"/><br/>
  NFS Storage<br/>
  <sub>Persistent Volumes</sub>
</td>
</tr>
</table>

See [Applications Directory](k8s-sandbox/apps) for the complete list of available applications.

## 🚀 Getting Started

1. **Prerequisites**
   - Host machine with virtualization support
   - Minimum 16GB RAM (32GB+ recommended)
   - Unraid or other virtualization platform
   - Basic Linux knowledge

2. **Quick Start**
   ```bash
   # Clone the repository
   git clone https://github.com/Starslider/kubernetes-demo.git
   cd kubernetes-demo

   # Follow the installation guide
   less k8s-sandbox/README.md
   ```

See the [Installation Guide](k8s-sandbox/README.md) for detailed instructions.

## 📂 Repository Structure

```text
kubernetes-demo/
├── k8s-sandbox/
│   ├── apps/            # Application configurations
│   ├── argocd/          # ArgoCD setup
│   ├── authentik/       # Identity management
│   ├── cert-manager/    # Certificate management
│   ├── cilium/          # Network policies
│   └── ...              # Other components
├── images/              # Image assets
├── scripts/             # Utility scripts
├── README.md            # Main documentation
├── LICENSE              # License file
└── ...                  # Other files
```

## 🛠️ Development

### Tools & Versions

- <img src="https://raw.githubusercontent.com/cncf/artwork/master/projects/kubernetes/icon/color/kubernetes-icon-color.svg" width="20"/> [Kubernetes](https://github.com/kubernetes/kubernetes) ([latest](https://github.com/kubernetes/kubernetes/releases/latest))
- <img src="https://raw.githubusercontent.com/containerd/containerd/main/docs/logos/containerd-icon-color.svg" width="20"/> [containerd](https://github.com/containerd/containerd) ([latest](https://github.com/containerd/containerd/releases/latest))
- <img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Archlinux-icon-crystal-64.svg" width="20"/> [Arch Linux](https://archlinux.org/)
- <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png" width="20"/> [kubeadm](https://github.com/kubernetes/kubeadm) ([latest](https://github.com/kubernetes/kubeadm/releases/latest))
- <img src="https://raw.githubusercontent.com/cilium/cilium/master/Documentation/images/logo-solo.svg" width="20"/> [Cilium](https://github.com/cilium/cilium) ([latest](https://github.com/cilium/cilium/releases/latest))
- <img src="https://raw.githubusercontent.com/argoproj/argo-cd/master/docs/assets/logo.png" width="20"/> [ArgoCD](https://github.com/argoproj/argo-cd) ([latest](https://github.com/argoproj/argo-cd/releases/latest))
- <img src="https://raw.githubusercontent.com/cert-manager/cert-manager/master/logo/logo.png" width="20"/> [cert-manager](https://github.com/cert-manager/cert-manager) ([latest](https://github.com/cert-manager/cert-manager/releases/latest))
- <img src="https://goauthentik.io/img/icon.svg" width="20"/> [Authentik](https://github.com/goauthentik/authentik) ([latest](https://github.com/goauthentik/authentik/releases/latest))
- <img src="https://goharbor.io/img/logos/harbor-icon-color.png" width="20"/> [Harbor](https://github.com/goharbor/harbor) ([latest](https://github.com/goharbor/harbor/releases/latest))
- <img src="https://raw.githubusercontent.com/kubernetes-sigs/external-dns/master/docs/img/external-dns.png" width="20"/> [External DNS](https://github.com/kubernetes-sigs/external-dns) ([latest](https://github.com/kubernetes-sigs/external-dns/releases/latest))
- <img src="images/victoriametrics-logo.png" width="20"/> [VictoriaMetrics](https://github.com/VictoriaMetrics/VictoriaMetrics) ([latest](https://github.com/VictoriaMetrics/VictoriaMetrics/releases/latest))
- <img src="https://raw.githubusercontent.com/grafana/grafana/main/public/img/grafana_icon.svg" width="20"/> [Grafana](https://github.com/grafana/grafana) ([latest](https://github.com/grafana/grafana/releases/latest))
- <img src="https://avatars.githubusercontent.com/u/45487711" width="20"/> [n8n](https://github.com/n8n-io/n8n) ([latest](https://github.com/n8n-io/n8n/releases/latest))

### Best Practices

1. Test configuration changes with \`--dry-run\`
2. Verify network connectivity before operations
3. Use static IP addressing
4. Follow GitOps workflow with ArgoCD

## 📚 Documentation

- [Installation Guide](k8s-sandbox/README.md)
- [Applications Overview](k8s-sandbox/apps/README.md)
- [ArgoCD Setup](k8s-sandbox/argocd/README.md)
- [Network Configuration](k8s-sandbox/cilium/README.md)

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

---

<div align="center">

Made with ❤️ by [Starslider](https://github.com/Starslider)

<sub>If you find this project helpful, please consider giving it a ⭐️</sub>

</div>