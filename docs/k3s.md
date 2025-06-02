# K3s Guide

This guide explains how to manage and maintain your K3s cluster in Self-Host SaaS K3s.

## Cluster Management

### 1. Node Management

1. Add a new node:
   ```bash
   # On the new node
   curl -sfL https://get.k3s.io | K3S_URL=https://server:6443 K3S_TOKEN=your-token sh -
   ```

2. Remove a node:
   ```bash
   # On the node to remove
   /usr/local/bin/k3s-uninstall.sh
   
   # On the server
   kubectl delete node node-name
   ```

### 2. Cluster Operations

1. Check cluster status:
   ```bash
   # Get node status
   kubectl get nodes
   
   # Get system pods
   kubectl get pods -n kube-system
   ```

2. Update K3s:
   ```bash
   # Update K3s
   curl -sfL https://get.k3s.io | sh -
   ```

## System Components

### 1. Traefik Ingress

1. Configure Traefik:
   ```yaml
   apiVersion: helm.cattle.io/v1
   kind: HelmChartConfig
   metadata:
     name: traefik
     namespace: kube-system
   spec:
     valuesContent: |-
       metrics:
         prometheus:
           enabled: true
       ports:
         web:
           redirectTo: websecure
         websecure:
           tls:
             enabled: true
   ```

2. Create Ingress:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: your-app
     annotations:
       kubernetes.io/ingress.class: traefik
   spec:
     rules:
     - host: your-app.your-domain.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: your-app
               port:
                 number: 80
   ```

### 2. Local Storage

1. Configure Longhorn:
   ```yaml
   apiVersion: longhorn.io/v1beta1
   kind: Setting
   metadata:
     name: default-replica-count
   spec:
     value: "3"
   ```

2. Create StorageClass:
   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: longhorn
   provisioner: driver.longhorn.io
   allowVolumeExpansion: true
   parameters:
     numberOfReplicas: "3"
     staleReplicaTimeout: "30"
   ```

## Security

### 1. Network Policies

1. Create network policy:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: default-deny
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
     - Egress
   ```

2. Allow specific traffic:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: allow-app
   spec:
     podSelector:
       matchLabels:
         app: your-app
     ingress:
     - from:
       - podSelector:
           matchLabels:
             app: allowed-app
       ports:
       - protocol: TCP
         port: 80
   ```

### 2. RBAC

1. Create ServiceAccount:
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: your-app
   ```

2. Create Role:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: your-app
   rules:
   - apiGroups: [""]
     resources: ["pods"]
     verbs: ["get", "list", "watch"]
   ```

3. Create RoleBinding:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: your-app
   subjects:
   - kind: ServiceAccount
     name: your-app
   roleRef:
     kind: Role
     name: your-app
     apiGroup: rbac.authorization.k8s.io
   ```

## Maintenance

### 1. System Updates

1. Update system packages:
   ```bash
   # On each node
   sudo apt update
   sudo apt upgrade
   ```

2. Update K3s:
   ```bash
   # On the server
   curl -sfL https://get.k3s.io | sh -
   ```

### 2. Resource Management

1. Monitor resources:
   ```bash
   # Check node resources
   kubectl top nodes
   
   # Check pod resources
   kubectl top pods -A
   ```

2. Clean up resources:
   ```bash
   # Remove completed jobs
   kubectl delete jobs --field-selector status.successful=1
   
   # Remove old deployments
   kubectl delete deployment old-deployment
   ```

## Troubleshooting

### 1. Common Issues

1. **Node not ready**
   - Check node status: `kubectl describe node node-name`
   - Check system logs: `journalctl -u k3s`
   - Verify network connectivity

2. **Pod issues**
   - Check pod status: `kubectl describe pod pod-name`
   - Check pod logs: `kubectl logs pod-name`
   - Verify resource limits

3. **Network issues**
   - Check Traefik logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=traefik`
   - Verify network policies
   - Check DNS configuration

### 2. Debugging

1. Check system logs:
   ```bash
   # K3s logs
   journalctl -u k3s
   
   # Container logs
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
   ```

2. Verify configuration:
   ```bash
   # Check K3s config
   cat /etc/rancher/k3s/k3s.yaml
   
   # Check system pods
   kubectl get pods -n kube-system
   ```

## Best Practices

1. **Cluster Management**
   - Regular updates
   - Resource monitoring
   - Backup configuration

2. **Security**
   - Network policies
   - RBAC configuration
   - Regular security audits

3. **Maintenance**
   - Regular cleanup
   - Resource optimization
   - Documentation updates

## Next Steps

1. [Application deployment](applications.md)
2. [Monitoring setup](monitoring.md)
3. [Backup configuration](backups.md) 