# Security Configuration

This project implements a security-first approach to protect your self-hosted infrastructure.

## Firewall Configuration

### Default Rules

The firewall is configured with the following default rules:

```yaml
firewall_rules:
  - port: 22
    protocol: tcp
    source: 0.0.0.0/0
    description: "SSH access"
  - port: 80
    protocol: tcp
    source: 0.0.0.0/0
    description: "HTTP access"
  - port: 443
    protocol: tcp
    source: 0.0.0.0/0
    description: "HTTPS access"
```

### Customizing Rules

1. Edit `group_vars/all/variables.yml`:
   ```yaml
   firewall_rules:
     - port: 22
       protocol: tcp
       source: YOUR_IP/32  # Restrict SSH to your IP
     - port: 80
       protocol: tcp
       source: 0.0.0.0/0
     - port: 443
       protocol: tcp
       source: 0.0.0.0/0
   ```

2. Apply changes:
   ```bash
   ansible-playbook -i inventory.yml playbook.yml --tags firewall
   ```

## Accessing Services

### SSH Access

1. Basic SSH connection:
   ```bash
   ssh ubuntu@YOUR_SERVER_PUBLIC_IP
   ```

2. SSH with key:
   ```bash
   ssh -i ~/.ssh/id_rsa ubuntu@YOUR_SERVER_PUBLIC_IP
   ```

### Kubernetes Access

1. Set up SSH tunnel:
   ```bash
   ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP &
   ```

2. Configure kubectl:
   ```bash
   export KUBECONFIG=/path/to/kubeconfig
   kubectl get nodes
   ```

### UI Access

All UIs are accessed through SSH tunnels for security:

1. Longhorn UI:
   ```bash
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   # Access at http://localhost:8080
   ```

2. Harbor UI:
   ```bash
   kubectl port-forward svc/harbor-portal -n harbor 8081:80
   # Access at http://localhost:8081
   ```

3. Traefik Dashboard:
   ```bash
   kubectl -n kube-system port-forward svc/traefik 8082:80
   # Access at http://localhost:8082
   ```

## Security Best Practices

### 1. Regular Updates

Keep your system updated:
```bash
sudo apt update && sudo apt upgrade
```

### 2. Password Management

- Use strong passwords
- Rotate passwords regularly
- Use password managers
- Enable 2FA where possible

### 3. Monitoring

Monitor for suspicious activity:
```bash
# Check system logs
sudo journalctl -f

# Check Kubernetes logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

### 4. Backup Security

- Encrypt backups
- Use secure backup locations
- Test backup restoration regularly

## Network Security

### Ingress Configuration

1. Configure Traefik:
   ```yaml
   traefik_helm_values:
     ingressRoute:
       dashboard:
         enabled: true
         auth:
           basic:
             users:
               admin: $apr1$xyz...  # Generated with htpasswd
   ```

2. Set up TLS:
   ```yaml
   cert_manager:
     enabled: true
     clusterIssuer:
       name: letsencrypt-prod
   ```

### Network Policies

Example network policy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: my-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Troubleshooting

### Common Security Issues

1. **SSH Access Denied**
   - Check SSH key permissions
   - Verify firewall rules
   - Check SSH logs: `sudo journalctl -u ssh`

2. **Kubernetes Access Issues**
   - Verify SSH tunnel
   - Check kubeconfig
   - Verify certificates

3. **UI Access Problems**
   - Check port-forward status
   - Verify service is running
   - Check network policies

### Security Auditing

1. Run security scans:
   ```bash
   # Check for vulnerabilities
   trivy image your-image:tag
   
   # Scan Kubernetes cluster
   trivy k8s --report summary
   ```

2. Review logs:
   ```bash
   # System logs
   sudo journalctl -f
   
   # Kubernetes logs
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
   ``` 