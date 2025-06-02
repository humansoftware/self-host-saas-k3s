# Prerequisites

Before installing Self-Host SaaS K3s, ensure you have the following requirements in place.

## Server Requirements

### Hardware
- CPU: 2+ cores
- RAM: 4GB minimum (8GB recommended)
- Storage: 20GB minimum (SSD recommended)
- Network: 1Gbps connection

### Software
- Ubuntu 24.04 LTS
- SSH access with sudo privileges
- Static IP address (public or private)

## Local Machine Setup

### Required Software

1. **Ansible**
   ```bash
   sudo apt update
   sudo apt install -y ansible
   ```

2. **Python Packages**
   ```bash
   pip install kubernetes openshift
   ```

3. **Helm 3**
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

### SSH Key Setup

1. Generate SSH key if you don't have one:
   ```bash
   ssh-keygen -t rsa -b 4096
   ```

2. Add your public key to the server:
   ```bash
   ssh-copy-id ubuntu@YOUR_SERVER_PUBLIC_IP
   ```

## Network Requirements


### DNS Configuration

1. Set up DNS records for your domain (optional):
   ```
   registry.yourdomain.com -> YOUR_SERVER_IP
   *.yourdomain.com -> YOUR_SERVER_IP
   ```


## Verification

Before proceeding with installation, verify:

1. Server meets requirements:
   ```bash
   ansible all -i inventory.yml -m shell -a "free -h && df -h && nproc"
   ```
