# Applications Guide

This guide explains how to deploy and manage applications in your Self-Host SaaS K3s cluster.

## Overview

The deployment and management of applications in this cluster follows a GitOps approach using Flux for Continuous Deployment (CD) and GitHub Actions for Continuous Integration (CI).

## Example Application

For reference, you can check out the example application at:
https://github.com/humansoftware/example_self_hosted_saas_app


## Configuring your applications

To deploy applications to your cluster, you need to configure them in the cluster's configuration:

1. Edit the file `group_vars/all/secrets.yml` to specify which applications to deploy
2. Add your application repositories to the `flux_app_repos` list
3. Each repository should be specified in the format: `owner/repo-name`

For an example configuration, see [secrets.example.yml](..https://github.com/humansoftware/self-host-saas-k3s/blob/main/group_vars/all/secrets.example.yml)

### GitHub Authentication

The cluster needs access to your GitHub repositories for two purposes:
1. Flux needs to clone repositories to deploy applications
2. GitHub Actions need to interact with GitHub's API

To enable this access:
1. Create a GitHub Personal Access Token (PAT) with appropriate permissions:
   - `repo` scope for private repositories
   - `workflow` scope for GitHub Actions
2. Add this token to the `github_pat` field in `group_vars/all/secrets.yml`

The token will be securely stored and used by both Flux and GitHub Actions runners.

## Application Structure

### Continuous Integration (CI)
- GitHub Actions is used for CI
- Actions are defined in your application repository as you would normally do in GitHub
- Key differences from standard GitHub Actions:
  - Actions run in your self-hosted cluster instead of GitHub runners
  - Pull request statuses and logs are updated the same way as with native GitHub runners

### Docker Image Publishing

To publish Docker images to Harbor:

1. Set up a GitHub secret for your application containing the Harbor admin password
   - This password should match what you configured in the secrets configuration
2. Use the following credentials for Docker login:
   - Username: `admin`
   - Password: The Harbor admin password secret you configured
   - host: harbor.local

### Continuous Deployment (CD)

#### Kubernetes Configuration
- Applications must include Kubernetes Custom Resource Definitions (CRDs) in the `flux` folder
- These configurations define your application's components:
  - Jobs
  - Services
  - Pods
  - Other Kubernetes resources
- The configurations can reference Docker images published by your CI pipelines

#### Kustomize Integration
- Flux uses Kustomize for managing Kubernetes configurations
- Each application should include a `kustomization.yaml` file that:
  - References the Kubernetes manifests
  - Defines common labels and annotations
  - Manages environment-specific configurations
- For more information about Kustomize, see the [official documentation](https://kustomize.io/)
- To learn how Flux integrates with Kustomize, refer to the [Flux Kustomize documentation](https://fluxcd.io/flux/components/kustomize/)

#### Flux UI - Weave-gitops

Execute the following command to create a port-forward for the flux UI:
```bash
kubectl -n flux-system port-forward svc/weave-gitops 9001:9001
```

Visit [http://localhost:9001](http://localhost:9001) and log in with admin and the password you specified in secrets.

## Best Practices

1. Keep your Kubernetes configurations in the `flux` folder organized and well-documented
2. Ensure your GitHub Actions workflows are properly configured for self-hosted runners
3. Securely manage your Harbor credentials using GitHub secrets
4. Follow the example application structure for consistency