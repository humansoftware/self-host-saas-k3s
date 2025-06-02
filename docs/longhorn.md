# Longhorn Storage

Longhorn provides persistent storage for your Kubernetes cluster with backup capabilities to Backblaze.

## Configuration

### Backblaze Setup

1. Create a Backblaze account and bucket:
   - Sign up at [Backblaze](https://www.backblaze.com)
   - Create a new bucket
   - Generate application keys

2. Configure Backblaze credentials in `group_vars/all/secrets.yml`:
   ```yaml
   backblaze_key_id: "your-backblaze-key-id"
   backblaze_application_key: "your-backblaze-application-key"
   backblaze_bucket: "your-backblaze-bucket"
   ```

### Longhorn Configuration

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

## Using Longhorn

### Creating Persistent Volumes

1. Create a PVC:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: my-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: longhorn
     resources:
       requests:
         storage: 1Gi
   ```

2. Use in a pod:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
   spec:
     containers:
     - name: my-container
       image: nginx
       volumeMounts:
       - name: my-volume
         mountPath: /data
     volumes:
     - name: my-volume
       persistentVolumeClaim:
         claimName: my-pvc
   ```

### Managing Backups

1. Create a backup:
   ```bash
   kubectl -n longhorn-system exec -it <longhorn-manager-pod> -- longhorn backup create --volume <volume-name>
   ```

2. List backups:
   ```bash
   kubectl -n longhorn-system exec -it <longhorn-manager-pod> -- longhorn backup ls
   ```

3. Restore from backup:
   ```bash
   kubectl -n longhorn-system exec -it <longhorn-manager-pod> -- longhorn backup restore <backup-name>
   ```

## Accessing the UI

1. Set up port forwarding:
   ```bash
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   ```

2. Access the UI at [http://localhost:8080](http://localhost:8080)

### UI Features

- Volume management
- Backup scheduling
- Performance monitoring
- Disaster recovery
- Volume snapshots

## Backup Configuration

### Automated Backups

1. Configure backup schedule in Longhorn UI:
   - Go to Settings > Backup
   - Set backup interval
   - Configure retention policy

2. Or use Kubernetes CronJob:
   ```yaml
   apiVersion: batch/v1
   kind: CronJob
   metadata:
     name: longhorn-backup
   spec:
     schedule: "0 0 * * *"
     jobTemplate:
       spec:
         template:
           spec:
             containers:
             - name: backup
               image: longhornio/longhorn-manager
               command: ["longhorn", "backup", "create"]
               args: ["--volume", "my-volume"]
   ```

### Backup Verification

1. Check backup status:
   ```bash
   kubectl -n longhorn-system exec -it <longhorn-manager-pod> -- longhorn backup ls
   ```

2. Verify backup in Backblaze:
   - Log in to Backblaze
   - Navigate to your bucket
   - Check backup files

## Troubleshooting

### Common Issues

1. **Backup Failures**
   - Check Backblaze credentials
   - Verify network connectivity
   - Check Longhorn logs:
     ```bash
     kubectl logs -n longhorn-system -l app=longhorn-manager
     ```

2. **Volume Issues**
   - Check volume status:
     ```bash
     kubectl get pv
     kubectl get pvc
     ```
   - Check Longhorn UI for details
   - Verify node resources

3. **Performance Issues**
   - Monitor volume metrics in UI
   - Check node resources
   - Adjust volume settings

### Maintenance

1. Regular checks:
   - Monitor backup success
   - Check volume health
   - Review storage usage

2. Cleanup:
   - Remove old backups
   - Delete unused volumes
   - Clean up snapshots 