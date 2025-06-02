# Installation Guide

This guide will walk you through the installation of Self-Host SaaS K3s on your server.

## Preparation

1. Ensure you have completed all [prerequisites](prerequisites.md)
2. Verify your server meets the requirements
3. Have your configuration files ready

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/humansoftware/self-host-saas-k3s.git
cd self-host-saas-k3s
```

### 2. Configure Secrets

1. Copy the secrets template:
   ```bash
   cp group_vars/all/secrets.example.yml group_vars/all/secrets.yml
   ```

2. Edit `group_vars/all/secrets.yml`:
   ```yaml
   # Server Configuration
   host_public_ip: "YOUR_SERVER_PUBLIC_IP"

   # Registry Configuration
   registry_password: "your-registry-password"
   registry_username: "admin"

   # Backblaze Configuration (if using backups)
   backblaze_key_id: "your-backblaze-key-id"
   backblaze_application_key: "your-backblaze-application-key"
   backblaze_bucket: "your-backblaze-bucket"
   ```

### 3. Update Inventory

1. Copy the sample inventory:
   ```bash
   cp inventory.sample.yml inventory.yml
   ```

2. Edit `inventory.yml`:
   ```yaml
   all:
     hosts:
       your-server:
         ansible_host: YOUR_SERVER_IP
         ansible_user: ubuntu
         ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```

### 4. Install Dependencies

```bash
ansible-galaxy install -r requirements.yml
```

### 5. Run the Playbook

```bash
ansible-playbook -i inventory.yml playbook.yml --extra-vars action=install
```

## Verification

### 1. Check K3s Installation

```bash
# Set up SSH tunnel
ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP &

# Configure kubectl
export KUBECONFIG=/path/to/kubeconfig

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

### 2. Verify Harbor Registry

```bash
# Set up port forwarding
kubectl port-forward svc/harbor-portal -n harbor 8081:80

# Access UI at http://localhost:8081
```

### 3. Check Longhorn Storage

```bash
# Set up port forwarding
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80

# Access UI at http://localhost:8080
```

## Post-Installation

### 1. Configure GitHub Actions

1. Add repository secrets:
   - `REGISTRY_URL`
   - `REGISTRY_USERNAME`
   - `REGISTRY_PASSWORD`
   - `KUBE_CONFIG`

2. Test CI/CD pipeline:
   ```bash
   # Push a test commit
   git commit --allow-empty -m "Test CI/CD"
   git push
   ```

### 2. Set Up Backups

1. Configure Backblaze in Longhorn UI:
   - Go to Settings > Backup
   - Add Backblaze credentials
   - Test backup

2. Set up backup schedule:
   - Configure retention policy
   - Set backup interval
   - Test backup creation

### 3. Security Hardening

1. Review firewall rules:
   ```bash
   sudo ufw status
   ```

2. Update passwords:
   - Harbor admin password
   - Backblaze credentials
   - SSH keys

## Troubleshooting

### Common Issues

1. **Playbook Fails**
   - Check Ansible logs
   - Verify prerequisites
   - Check network connectivity

2. **K3s Issues**
   - Check K3s logs: `journalctl -u k3s`
   - Verify system resources
   - Check network configuration

3. **Registry Issues**
   - Check Harbor pods: `kubectl get pods -n harbor`
   - Verify storage
   - Check network policies

### Getting Help

1. Check logs:
   ```bash
   # K3s logs
   journalctl -u k3s

   # Harbor logs
   kubectl logs -n harbor -l app=harbor

   # Longhorn logs
   kubectl logs -n longhorn-system -l app=longhorn-manager
   ```

2. Review documentation:
   - [K3s Documentation](k3s.md)
   - [Harbor Documentation](harbor.md)
   - [Longhorn Documentation](longhorn.md)

## Next Steps

1. [Configure your applications](applications.md)
2. [Set up monitoring](monitoring.md)
3. [Manage backups](backups.md) 