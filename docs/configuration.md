# Configuration Guide

This guide explains all the configurable components of Self-Host SaaS K3s and how to customize them for your needs.

## Configuration Files

### Inventory File

The `inventory.yml` file defines your server configuration:

```yaml
all:
  hosts:
    your-server:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
  children:
    k3s_cluster:
      hosts:
        your-server:
```

### Secrets

The `group_vars/all/secrets.yml` file contains all sensitive information:

```yaml
# Server Configuration
host_public_ip: "YOUR_SERVER_PUBLIC_IP"

# Registry Configuration
registry_password: "your-registry-password"
registry_username: "admin"

# Backblaze Configuration
backblaze_key_id: "your-backblaze-key-id"
backblaze_application_key: "your-backblaze-application-key"
backblaze_bucket: "your-backblaze-bucket"
```

### Variables

The `group_vars/all/variables.yml` file contains non-sensitive configuration:

```yaml
# K3s Configuration
k3s_version: "v1.28.0+k3s1"
k3s_install_path: "/usr/local/bin"
k3s_config_path: "/etc/rancher/k3s"

# Registry Configuration
registry_hostname: "registry.local"
registry_port: 5000

# Longhorn Configuration
longhorn_version: "1.5.1"
longhorn_backup_enabled: true
```

## Component Configuration

### K3s Cluster

Configure the K3s cluster in `group_vars/all/variables.yml`:

```yaml
k3s_extra_args: >
  --disable traefik
  --disable servicelb
  --disable-cloud-controller
  --disable-network-policy
  --disable-helm-controller
  --disable local-storage
  --disable metrics-server
  --disable coredns
  --disable-network-policy
  --disable-helm-controller
  --disable local-storage
  --disable metrics-server
  --disable coredns
```

### Container Registry (Harbor)

Configure Harbor in `group_vars/all/variables.yml`:

```yaml
harbor_helm_values:
  expose:
    type: clusterIP
  externalURL: https://registry.local
  persistence:
    enabled: true
    persistentVolumeClaim:
      registry:
        size: 10Gi
      chartmuseum:
        size: 5Gi
      jobservice:
        size: 1Gi
      database:
        size: 1Gi
      redis:
        size: 1Gi
```

### Longhorn Storage

Configure Longhorn in `group_vars/all/variables.yml`:

```yaml
longhorn_helm_values:
  persistence:
    defaultClass: true
  defaultSettings:
    backupTarget: s3://your-backblaze-bucket
    backupTargetCredentialSecret: backblaze-secret
  backupstore:
    pollInterval: 300
```

### Firewall

Configure the firewall in `group_vars/all/variables.yml`:

```yaml
firewall_rules:
  - port: 22
    protocol: tcp
    source: 0.0.0.0/0
  - port: 80
    protocol: tcp
    source: 0.0.0.0/0
  - port: 443
    protocol: tcp
    source: 0.0.0.0/0
```

## Customizing Components

### Adding Custom Kubernetes Resources

Create a new file in `roles/install_k8s_apps/templates/` with your Kubernetes manifests:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-app
spec:
  # ... deployment spec
```

### Modifying Existing Components

1. K3s: Edit `roles/k3s_cluster/tasks/main.yml`
2. Harbor: Edit `roles/harbor/tasks/main.yml`
3. Longhorn: Edit `roles/longhorn/tasks/main.yml`
4. Firewall: Edit `roles/firewall/tasks/main.yml`

## Environment Variables

The following environment variables can be set before running the playbook:

- `HOST_PUBLIC_IP`: Your server's public IP address
- `K3S_TOKEN`: Custom K3s token (optional)
- `REGISTRY_PASSWORD`: Harbor registry password

## Troubleshooting Configuration

### Common Issues

1. **K3s Installation Fails**
   - Check if ports 6443 and 10250 are available
   - Verify system requirements are met
   - Check logs: `journalctl -u k3s`

2. **Registry Access Issues**
   - Verify Harbor is running: `kubectl get pods -n harbor`
   - Check Harbor logs: `kubectl logs -n harbor -l app=harbor`

3. **Longhorn Backup Issues**
   - Verify Backblaze credentials
   - Check Longhorn manager logs: `kubectl logs -n longhorn-system -l app=longhorn-manager`

### Debugging

Enable Ansible debug mode:
```bash
ansible-playbook -i inventory.yml playbook.yml -vvv
```

Check component logs:
```bash
# K3s logs
journalctl -u k3s

# Harbor logs
kubectl logs -n harbor -l app=harbor

# Longhorn logs
kubectl logs -n longhorn-system -l app=longhorn-manager
```
