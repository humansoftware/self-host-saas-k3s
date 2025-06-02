# K3s Cluster

This project uses K3s, a lightweight Kubernetes distribution, to provide a powerful container orchestration platform on a single server.

## Installation Options

K3s is installed with the following options:

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
```

These options are chosen to:
- Minimize resource usage
- Allow custom component installation
- Provide flexibility in configuration
- Enable better control over the cluster

## Accessing the Cluster

### Local Configuration

After running the Ansible playbook, your local kubeconfig will be automatically configured. You can:

1. Set the KUBECONFIG environment variable:
   ```bash
   export KUBECONFIG=/path/to/kubeconfig
   ```

2. Use kubectl:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

### Remote Access

For security, the Kubernetes API is not exposed directly. To access it remotely:

1. Set up an SSH tunnel:
   ```bash
   ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP &
   ```

2. Configure your local kubeconfig to use the tunnel:
   ```yaml
   apiVersion: v1
   kind: Config
   clusters:
   - cluster:
       server: https://localhost:6443
       certificate-authority-data: <your-ca-data>
     name: k3s
   ```

## Cluster Components

### Core Components

- **etcd**: Distributed key-value store
- **kube-apiserver**: Kubernetes API server
- **kube-controller-manager**: Controller manager
- **kube-scheduler**: Pod scheduler
- **kubelet**: Node agent

### Optional Components

The following components are installed separately:
- Traefik (Ingress controller)
- Longhorn (Storage)
- Harbor (Container registry)
- Cert-Manager (TLS certificates)

## Resource Management

### Node Resources

Monitor node resources:
```bash
kubectl top nodes
kubectl describe nodes
```

### Pod Resources

Set resource limits in your deployments:
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

## Configuration

### K3s Options

Configure K3s in `group_vars/all/variables.yml`:

```yaml
k3s_version: "v1.28.0+k3s1"
k3s_install_path: "/usr/local/bin"
k3s_config_path: "/etc/rancher/k3s"
```

### Custom Components

Add custom components by creating manifests in `roles/install_k8s_apps/templates/`:

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

## Troubleshooting

### Common Issues

1. **Node Not Ready**
   - Check kubelet logs: `journalctl -u kubelet`
   - Verify system resources
   - Check network connectivity

2. **Pod Scheduling Issues**
   - Check node resources: `kubectl describe nodes`
   - Verify pod resource requests
   - Check node taints and tolerations

3. **API Server Issues**
   - Check API server logs: `journalctl -u k3s`
   - Verify etcd health
   - Check certificate validity

### Debugging

Enable debug logging:
```bash
k3s server --debug
```

View component logs:
```bash
# K3s logs
journalctl -u k3s

# Kubelet logs
journalctl -u kubelet

# Container logs
kubectl logs -n kube-system -l component=kube-apiserver
``` 