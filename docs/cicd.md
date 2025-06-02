# CI/CD Setup

This project uses GitHub Actions for CI/CD and Flux for GitOps deployments. This combination provides a robust, automated deployment pipeline that's easy to maintain and monitor.

## GitHub Actions

### Self-Hosted Runner

The project sets up a self-hosted GitHub Actions runner on your server. This allows you to:

- Run CI/CD jobs directly on your infrastructure
- Access your private container registry
- Deploy applications to your K3s cluster
- Keep sensitive information within your network

### Repository Configuration

1. Add the following secrets to your GitHub repository:
   ```yaml
   REGISTRY_URL: "registry.local:5000"
   REGISTRY_USERNAME: "admin"
   REGISTRY_PASSWORD: "your-registry-password"
   KUBE_CONFIG: "base64-encoded-kubeconfig"
   ```

2. Use the provided GitHub Actions workflows:
   - `.github/workflows/build-and-push.yml`: Builds and pushes Docker images
   - `.github/workflows/deploy.yml`: Deploys to Kubernetes

### Example Workflow

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3
      - name: Build and Push
        uses: ./.github/actions/build-and-push
        with:
          image: my-app
          tag: ${{ github.sha }}
```

## Flux

### GitOps Deployment

Flux is configured to:

- Watch your Git repository for changes
- Automatically deploy updates to your cluster
- Keep your cluster state in sync with Git
- Provide deployment status and history

### Repository Structure

```
apps/
  ├── base/
  │   └── my-app/
  │       ├── deployment.yaml
  │       └── service.yaml
  └── overlays/
      └── production/
          └── my-app/
              └── kustomization.yaml
```

### Monitoring Deployments

1. Check Flux status:
   ```bash
   kubectl get gitrepository
   kubectl get kustomization
   ```

2. View deployment logs:
   ```bash
   kubectl logs -n flux-system -l app.kubernetes.io/name=flux
   ```

## Pull Request Status

GitHub Actions and Flux work together to provide status updates on your pull requests:

1. **Build Status**: Shows if your Docker image builds successfully
2. **Test Status**: Displays test results
3. **Deployment Status**: Indicates if the deployment was successful
4. **Preview Environment**: (Optional) Creates a preview environment for testing

## Configuration

### GitHub Actions Runner

Configure the runner in `group_vars/all/variables.yml`:

```yaml
github_actions_runner:
  name: "k3s-runner"
  labels: "k3s,self-hosted"
  token: "your-github-token"
```

### Flux Configuration

Configure Flux in `group_vars/all/variables.yml`:

```yaml
flux:
  git:
    url: "https://github.com/your-org/your-repo"
    branch: "main"
    path: "apps"
  interval: "1m"
```

## Troubleshooting

### Common Issues

1. **Runner Connection Issues**
   - Check runner logs: `journalctl -u github-runner`
   - Verify GitHub token is valid
   - Ensure network connectivity

2. **Deployment Failures**
   - Check Flux logs: `kubectl logs -n flux-system -l app.kubernetes.io/name=flux`
   - Verify kubeconfig is correct
   - Check image pull secrets

3. **Registry Access**
   - Verify registry credentials
   - Check network policies
   - Ensure TLS certificates are valid 