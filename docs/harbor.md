# Harbor Container Registry

Harbor is an open-source container registry that secures, stores, and signs container images. It's chosen for this project because it provides enterprise-grade features like vulnerability scanning, image signing, and role-based access control.

All services and containers in k3s will load their images from harbor and CI/CD will publish and refer to images in harbor as well.

## Configuration Variables

The following variables can be customized in `group_vars/all/secrets.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `harbor_admin_password` | Admin password for Harbor UI | "ChangeMe123!" |
| `harbor_registry_size` | Size of registry storage | "6Gi" |

## Accessing Harbor

### UI Access

Only access through ssh tunnel is set, as exposing harbor UI port would pose a security risk. 


1. Run the following command on your local machine (with `kubectl` configured to access your cluster):

```bash
kubectl -n kube-system port-forward svc/traefik 8081:80
# kubectl port-forward svc/harbor-portal -n harbor 8081:80 would point directly to the service
```

2. Access the Harbor UI at [http://localhost:8081](http://localhost:8081)

- Default username: `admin`
- Password: Set in `harbor_admin_password`

The UI can be useful to see which images are built, restore backups, set tags, etc.

### Docker Login

Using the harbor password secret, it's possible to execute `docker login` in CI/CD and publish docker images built by your applications.

## Verifying Installation

To verify Harbor is correctly installed:

1. Check Harbor resources:
```bash
kubectl get all -n harbor
```
