# Harbor Container Registry

Harbor provides a private container registry for your Kubernetes cluster, with features like vulnerability scanning and image signing.

## Configuration

### Basic Setup

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

### Registry Credentials

Set up registry credentials in `group_vars/all/secrets.yml`:
```yaml
registry_password: "your-registry-password"
registry_username: "admin"
```

## Using Harbor

### Accessing the UI

1. Set up port forwarding:
   ```bash
   kubectl port-forward svc/harbor-portal -n harbor 8081:80
   ```

2. Access the UI at [http://localhost:8081](http://localhost:8081)

### Pushing Images

1. Log in to the registry:
   ```bash
   docker login registry.local:5000 -u admin -p your-password
   ```

2. Tag your image:
   ```bash
   docker tag my-image:latest registry.local:5000/my-project/my-image:latest
   ```

3. Push the image:
   ```bash
   docker push registry.local:5000/my-project/my-image:latest
   ```

### Pulling Images

1. Log in to the registry:
   ```bash
   docker login registry.local:5000 -u admin -p your-password
   ```

2. Pull the image:
   ```bash
   docker pull registry.local:5000/my-project/my-image:latest
   ```

### Using in Kubernetes

1. Create a secret for registry access:
   ```bash
   kubectl create secret docker-registry harbor-secret \
     --docker-server=registry.local:5000 \
     --docker-username=admin \
     --docker-password=your-password
   ```

2. Use in your deployment:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-app
   spec:
     template:
       spec:
         containers:
         - name: my-app
           image: registry.local:5000/my-project/my-image:latest
         imagePullSecrets:
         - name: harbor-secret
   ```

## Features

### Vulnerability Scanning

1. Enable scanning in Harbor UI:
   - Go to Administration > Interrogation Services
   - Enable vulnerability scanning

2. Scan an image:
   - Select your image in the UI
   - Click "Scan" button
   - View results in the UI

### Image Signing

1. Configure notary:
   ```yaml
   harbor_helm_values:
     notary:
       enabled: true
   ```

2. Sign an image:
   ```bash
   docker trust sign registry.local:5000/my-project/my-image:latest
   ```

### Project Management

1. Create a project:
   - Go to Projects in Harbor UI
   - Click "New Project"
   - Set project name and access level

2. Configure project settings:
   - Set retention policy
   - Configure webhooks
   - Manage members

## Security

### Access Control

1. User Management:
   - Create users in Harbor UI
   - Assign roles to users
   - Configure LDAP/AD integration

2. Project Access:
   - Set project visibility
   - Configure user permissions
   - Manage robot accounts

### TLS Configuration

1. Configure TLS in `group_vars/all/variables.yml`:
   ```yaml
   harbor_helm_values:
     externalURL: https://registry.local
     tls:
       enabled: true
       secretName: harbor-tls
   ```

2. Add certificates:
   ```bash
   kubectl create secret tls harbor-tls \
     --cert=path/to/cert.pem \
     --key=path/to/key.pem \
     -n harbor
   ```

## Troubleshooting

### Common Issues

1. **Login Failures**
   - Verify credentials
   - Check network connectivity
   - Verify TLS certificates

2. **Push/Pull Issues**
   - Check registry status:
     ```bash
     kubectl get pods -n harbor
     ```
   - Verify image pull secrets
   - Check storage capacity

3. **UI Access Problems**
   - Check port-forward status
   - Verify service is running
   - Check network policies

### Maintenance

1. Regular tasks:
   - Monitor storage usage
   - Clean up old images
   - Review vulnerability scans

2. Backup:
   - Backup Harbor database
   - Export project settings
   - Document configurations 