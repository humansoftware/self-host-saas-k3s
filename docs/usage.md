# Usage Guide

This guide will walk you through the installation, configuration, and usage of Self-Host SaaS K3s.

## Installation

### Prerequisites

- A bare metal server running Ubuntu 24.04
- Ansible installed on your local machine
- SSH access to the target server with sudo privileges
- Python 3 and required packages:
  ```bash
  pip install kubernetes openshift
  ```
- Helm 3 installed on your local machine

### SSH Key Setup

1. Add your SSH public key to the server:
   ```bash
   ssh-copy-id ubuntu@YOUR_SERVER_PUBLIC_IP
   ```
   Or manually add your `~/.ssh/id_rsa.pub` to `/home/ubuntu/.ssh/authorized_keys` on the server.

### Installation Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/humansoftware/self-host-saas-k3s.git
   cd self-host-saas-k3s
   ```

2. Configure secrets:
   ```bash
   cp group_vars/all/secrets.example.yml group_vars/all/secrets.yml
   ```
   Edit `group_vars/all/secrets.yml` and fill in all required values.

3. Update inventory:
   ```bash
   cp inventory.sample.yml inventory.yml
   ```
   Edit `inventory.yml` with your server details.

4. Run the playbook:
   ```bash
   ansible-galaxy install -r requirements.yml
   ansible-playbook -i inventory.yml playbook.yml --extra-vars action=install
   ```

## K3s Cluster

### Accessing the Cluster

For security reasons, the Kubernetes API port is not open by default. To access the cluster:

1. Set up an SSH tunnel:
   ```bash
   ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP &
   ```

2. Use kubectl:
   ```bash
   export KUBECONFIG=/path/to/kubeconfig
   kubectl get nodes
   ```

### Local Testing

For local development and testing:

1. Use the provided helper scripts:
   ```bash
   ./run_test_vm.sh
   ./vmkubectl.sh get nodes
   ```

## Container Registry

### Accessing Harbor UI

1. Set up port forwarding:
   ```bash
   kubectl port-forward svc/harbor-portal -n harbor 8081:80
   ```

2. Access the UI at [http://localhost:8081](http://localhost:8081)

### Registry Configuration

The registry is configured with:
- Private access
- TLS encryption
- Basic authentication
- Integration with k3s

## CI/CD

### GitHub Actions Setup

1. Configure repository secrets:
   - `REGISTRY_URL`: Your Harbor registry URL
   - `REGISTRY_USERNAME`: Registry username
   - `REGISTRY_PASSWORD`: Registry password
   - `KUBE_CONFIG`: Base64 encoded kubeconfig

2. Use the provided GitHub Actions workflows:
   - `build-and-push.yml`: Build and push Docker images
   - `deploy.yml`: Deploy to Kubernetes

## Backups

### Longhorn Configuration

1. Access the Longhorn UI:
   ```bash
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   ```
   Then visit [http://localhost:8080](http://localhost:8080)

2. Configure Backblaze backup:
   - Set up Backblaze credentials in `group_vars/all/secrets.yml`
   - Configure backup schedules in Longhorn UI

## Security

### Firewall Configuration

The firewall is configured to:
- Allow SSH access (port 22)
- Block all other incoming traffic by default
- Allow necessary outbound traffic

### Accessing UIs Securely

All UIs are accessed through SSH tunnels:
1. Longhorn UI: `kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80`
2. Harbor UI: `kubectl port-forward svc/harbor-portal -n harbor 8081:80`
3. Traefik Dashboard: `kubectl -n kube-system port-forward svc/traefik 8082:80`

### Security Best Practices

1. Keep your server updated:
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. Use strong passwords and rotate them regularly

3. Monitor logs for suspicious activity:
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
   ```

4. Regularly backup your data using Longhorn

5. Keep your Ansible playbook and roles updated
