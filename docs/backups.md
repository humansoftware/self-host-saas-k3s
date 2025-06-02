# Backups Guide

This guide explains how to set up and manage backups in your Self-Host SaaS K3s cluster.

## Backup Strategy

### 1. Volume Backups

1. Configure Longhorn backups:
   ```yaml
   apiVersion: longhorn.io/v1beta1
   kind: BackupTarget
   metadata:
     name: default
   spec:
     type: s3
     s3:
       bucketName: your-backblaze-bucket
       endpoint: s3.us-west-002.backblazeb2.com
       accessKeyId: your-backblaze-key-id
       secretAccessKey: your-backblaze-application-key
   ```

2. Create backup schedule:
   ```yaml
   apiVersion: longhorn.io/v1beta1
   kind: RecurringJob
   metadata:
     name: daily-backup
   spec:
     task: backup
     cron: "0 0 * * *"
     retain: 7
     concurrency: 2
   ```

### 2. Application Backups

1. Create backup job:
   ```yaml
   apiVersion: batch/v1
   kind: CronJob
   metadata:
     name: app-backup
   spec:
     schedule: "0 1 * * *"
     jobTemplate:
       spec:
         template:
           spec:
             containers:
             - name: backup
               image: your-backup-image
               command: ["/backup.sh"]
               volumeMounts:
               - name: data
                 mountPath: /data
             volumes:
             - name: data
               persistentVolumeClaim:
                 claimName: your-app-data
   ```

## Backup Management

### 1. Manual Backups

1. Create volume backup:
   ```bash
   # Using Longhorn UI
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   # Navigate to Volumes > Select Volume > Backup
   ```

2. Create application backup:
   ```bash
   # Trigger backup job
   kubectl create job --from=cronjob/app-backup manual-backup
   ```

### 2. Automated Backups

1. Configure backup schedules:
   ```yaml
   apiVersion: longhorn.io/v1beta1
   kind: RecurringJob
   metadata:
     name: hourly-backup
   spec:
     task: backup
     cron: "0 * * * *"
     retain: 24
   ```

2. Monitor backup jobs:
   ```bash
   # Check backup status
   kubectl get recurringjobs
   kubectl get backups
   ```

## Restore Procedures

### 1. Volume Restore

1. Restore from backup:
   ```bash
   # Using Longhorn UI
   kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
   # Navigate to Backups > Select Backup > Restore
   ```

2. Verify restore:
   ```bash
   # Check volume status
   kubectl get volumes -n longhorn-system
   kubectl get pvc
   ```

### 2. Application Restore

1. Restore application data:
   ```bash
   # Create restore job
   kubectl create job --from=cronjob/app-restore manual-restore
   ```

2. Verify application:
   ```bash
   # Check application status
   kubectl get pods
   kubectl logs -l app=your-app
   ```

## Backup Verification

### 1. Regular Testing

1. Test backup integrity:
   ```bash
   # Create test restore
   kubectl create job --from=cronjob/backup-test test-restore
   ```

2. Verify backup content:
   ```bash
   # Check backup files
   kubectl exec -it backup-test-pod -- ls -l /restored-data
   ```

### 2. Backup Monitoring

1. Monitor backup status:
   ```bash
   # Check backup jobs
   kubectl get jobs
   kubectl get cronjobs
   ```

2. Review backup logs:
   ```bash
   # Check backup logs
   kubectl logs -l job-name=app-backup
   ```

## Disaster Recovery

### 1. Recovery Plan

1. Document recovery steps:
   ```markdown
   # Recovery Steps
   1. Restore volumes from Longhorn backups
   2. Restore application data
   3. Verify application functionality
   4. Update DNS if necessary
   ```

2. Test recovery procedure:
   ```bash
   # Create test environment
   kubectl create namespace recovery-test
   # Execute recovery steps
   ```

### 2. Backup Retention

1. Configure retention policies:
   ```yaml
   apiVersion: longhorn.io/v1beta1
   kind: RecurringJob
   metadata:
     name: weekly-backup
   spec:
     task: backup
     cron: "0 0 * * 0"
     retain: 30
   ```

2. Clean up old backups:
   ```bash
   # List old backups
   kubectl get backups --sort-by=.metadata.creationTimestamp
   # Delete old backups
   kubectl delete backup old-backup-name
   ```

## Troubleshooting

### 1. Common Issues

1. **Backup fails**
   - Check storage credentials
   - Verify network connectivity
   - Check storage capacity

2. **Restore fails**
   - Verify backup integrity
   - Check volume status
   - Verify application configuration

3. **Backup schedule issues**
   - Check CronJob status
   - Verify timezone settings
   - Check resource limits

### 2. Debugging

1. Check backup logs:
   ```bash
   # Longhorn logs
   kubectl logs -n longhorn-system -l app=longhorn-manager
   
   # Backup job logs
   kubectl logs -l job-name=app-backup
   ```

2. Verify backup configuration:
   ```bash
   # Check backup target
   kubectl get backuptarget
   
   # Check recurring jobs
   kubectl get recurringjobs
   ```

## Best Practices

1. **Backup Strategy**
   - Regular automated backups
   - Multiple backup locations
   - Test restore procedures

2. **Retention Policy**
   - Define clear retention periods
   - Regular cleanup of old backups
   - Monitor storage usage

3. **Security**
   - Encrypt backup data
   - Secure backup credentials
   - Regular security audits

## Next Steps

1. [Security hardening](security.md)
2. [Application deployment](applications.md)
3. [Monitoring setup](monitoring.md) 