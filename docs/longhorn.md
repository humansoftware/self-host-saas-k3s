# Longhorn Storage

Longhorn provides persistent storage for your Kubernetes cluster with backup capabilities to Backblaze.

## Configuration

### Backblaze Setup

Back blaze is a cheap distributed file system storage solution, compatible with S3. It's used for backups for DBs, container registry and anything that needed to be backed up, really. 

You must configure longhorn to use your backblaze bucket as backup.

1. Create a Backblaze account and bucket:

- Sign up at [Backblaze](https://www.backblaze.com)
- Create a new private bucket
- Generate application key with write access

2. Configure Backblaze credentials in `group_vars/all/secrets.yml`:

```yaml
backblaze_key_id: "your-backblaze-key-id"
backblaze_application_key: "your-backblaze-application-key"
backblaze_bucket: "your-backblaze-bucket"
backblaze_region: "your-region"
```

See [Example secrets file](https://github.com/humansoftware/self-host-saas-k3s/blob/main/group_vars/all/secrets.example.yml) for details.

### Managing Backups

The ansible scripts will automatically configure automatic weekly backups for you, see the corresponding section in [longhorn role](https://github.com/humansoftware/self-host-saas-k3s/blob/main/roles/longhorn/tasks/main.yml) for details.

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
 

### Backup Verification

1. Check backup status:
   - By using the UI, as explained above

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

If you fill variables right, backups should be all automatically configured for you, it should be plug and play.      