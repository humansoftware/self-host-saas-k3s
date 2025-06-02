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

## Configuration Files

### 1. Server IP Configuration

Set your server's public IP in `group_vars/all/secrets.yml`:
```yaml
host_public_ip: "YOUR_SERVER_PUBLIC_IP"
```

### 2. Inventory Setup

1. Copy the sample inventory:
   ```bash
   cp inventory.sample.yml inventory.yml
   ```

2. Update the inventory with your server details:
   ```yaml
   all:
     hosts:
       your-server:
         ansible_host: YOUR_SERVER_IP
         ansible_user: ubuntu
         ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```

### 3. Secrets Configuration

1. Copy the secrets template:
   ```bash
   cp group_vars/all/secrets.example.yml group_vars/all/secrets.yml
   ```

2. Update the secrets file with your values:
   ```yaml
   # Registry Configuration
   registry_password: "your-registry-password"
   registry_username: "admin"

   # Backblaze Configuration (if using backups)
   backblaze_key_id: "your-backblaze-key-id"
   backblaze_application_key: "your-backblaze-application-key"
   backblaze_bucket: "your-backblaze-bucket"
   ```

### 4. Cloud-Init Configuration

If you're using cloud-init for server provisioning:

1. Copy the cloud-init template:
   ```bash
   cp cloud-init.yaml cloud-init.generated.yaml
   ```

2. Update the cloud-init configuration:
   ```yaml
   #cloud-config
   hostname: your-hostname
   users:
     - name: ubuntu
       sudo: ALL=(ALL) NOPASSWD:ALL
       ssh_authorized_keys:
         - "YOUR_SSH_PUBLIC_KEY"
   ```

## Network Requirements

### Required Ports

- **Inbound**:
  - 22 (SSH)
  - 80 (HTTP, optional)
  - 443 (HTTPS, optional)

- **Outbound**:
  - 80 (HTTP)
  - 443 (HTTPS)
  - 53 (DNS)

### DNS Configuration

1. Set up DNS records for your domain (optional):
   ```
   registry.yourdomain.com -> YOUR_SERVER_IP
   *.yourdomain.com -> YOUR_SERVER_IP
   ```

2. Update your local hosts file for testing:
   ```
   YOUR_SERVER_IP registry.local
   ```

## Verification

Before proceeding with installation, verify:

1. SSH access works:
   ```bash
   ssh ubuntu@YOUR_SERVER_PUBLIC_IP
   ```

2. Ansible can connect:
   ```bash
   ansible all -i inventory.yml -m ping
   ```

3. Server meets requirements:
   ```bash
   ansible all -i inventory.yml -m shell -a "free -h && df -h && nproc"
   ```

## Next Steps

Once all prerequisites are met, proceed to the [Installation Guide](installation.md). 