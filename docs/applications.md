# Applications Guide

This guide explains how to deploy and manage applications in your Self-Host SaaS K3s cluster.

## Application Deployment

### 1. Using Harbor Registry

1. Build and push your application:
   ```bash
   # Build the image
   docker build -t harbor.your-domain.com/your-project/your-app:latest .

   # Login to Harbor
   docker login harbor.your-domain.com

   # Push the image
   docker push harbor.your-domain.com/your-project/your-app:latest
   ```

2. Create a deployment:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: your-app
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: your-app
     template:
       metadata:
         labels:
           app: your-app
       spec:
         containers:
         - name: your-app
           image: harbor.your-domain.com/your-project/your-app:latest
           ports:
           - containerPort: 80
   ```

### 2. Using GitHub Actions

1. Configure workflow:
   ```yaml
   name: Deploy Application
   on:
     push:
       branches: [ main ]
   
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@v2
       
       - name: Build and Push
         uses: docker/build-push-action@v2
         with:
           push: true
           tags: ${{ secrets.REGISTRY_URL }}/your-app:latest
       
       - name: Deploy to K3s
         uses: azure/k8s-deploy@v1
         with:
           manifests: |
             k8s/deployment.yaml
           images: |
             ${{ secrets.REGISTRY_URL }}/your-app:latest
   ```

## Persistent Storage

### 1. Using Longhorn

1. Create a PersistentVolumeClaim:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: your-app-data
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: longhorn
     resources:
       requests:
         storage: 10Gi
   ```

2. Mount in deployment:
   ```yaml
   spec:
     containers:
     - name: your-app
       volumeMounts:
       - name: data
         mountPath: /data
     volumes:
     - name: data
       persistentVolumeClaim:
         claimName: your-app-data
   ```

## Ingress Configuration

### 1. Using Traefik

1. Create Ingress resource:
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

### 2. TLS Configuration

1. Create TLS secret:
   ```bash
   kubectl create secret tls your-app-tls \
     --cert=path/to/cert.pem \
     --key=path/to/key.pem
   ```

2. Add TLS to Ingress:
   ```yaml
   spec:
     tls:
     - hosts:
       - your-app.your-domain.com
       secretName: your-app-tls
   ```

## Application Management

### 1. Scaling

1. Manual scaling:
   ```bash
   kubectl scale deployment your-app --replicas=3
   ```

2. Auto-scaling:
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: your-app
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: your-app
     minReplicas: 1
     maxReplicas: 10
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 80
   ```

### 2. Updates

1. Rolling updates:
   ```bash
   kubectl set image deployment/your-app your-app=harbor.your-domain.com/your-project/your-app:new-version
   ```

2. Rollback:
   ```bash
   kubectl rollout undo deployment/your-app
   ```

## Monitoring

### 1. Resource Usage

1. Check pod status:
   ```bash
   kubectl get pods
   kubectl describe pod your-app-pod
   ```

2. Monitor resources:
   ```bash
   kubectl top pods
   kubectl top nodes
   ```

### 2. Logs

1. View logs:
   ```bash
   kubectl logs -f deployment/your-app
   ```

2. Previous container logs:
   ```bash
   kubectl logs -f deployment/your-app --previous
   ```

## Backup and Restore

### 1. Application Data

1. Backup PVC:
   ```bash
   # Create backup
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   # Use Longhorn UI to create backup
   ```

2. Restore from backup:
   ```bash
   # Use Longhorn UI to restore
   # Or use kubectl
   kubectl create -f restore.yaml
   ```

## Troubleshooting

### 1. Common Issues

1. **Pod not starting**
   - Check events: `kubectl describe pod your-app-pod`
   - Check logs: `kubectl logs your-app-pod`
   - Verify image: `kubectl get pod your-app-pod -o yaml`

2. **Storage issues**
   - Check PVC status: `kubectl get pvc`
   - Verify Longhorn volumes: `kubectl get volumes -n longhorn-system`
   - Check storage class: `kubectl get storageclass`

3. **Ingress issues**
   - Check ingress status: `kubectl get ingress`
   - Verify service: `kubectl get svc`
   - Check Traefik logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=traefik`

### 2. Debugging Tools

1. **kubectl debug**
   ```bash
   kubectl debug -it your-app-pod --image=busybox
   ```

2. **Port forwarding**
   ```bash
   kubectl port-forward svc/your-app 8080:80
   ```

## Best Practices

1. **Resource Management**
   - Set resource requests and limits
   - Use horizontal pod autoscaling
   - Monitor resource usage

2. **Security**
   - Use network policies
   - Implement pod security policies
   - Regular security updates

3. **Backup Strategy**
   - Regular volume backups
   - Test restore procedures
   - Document recovery steps

## Next Steps

1. [Set up monitoring](monitoring.md)
2. [Configure backups](backups.md)
3. [Security hardening](security.md) 