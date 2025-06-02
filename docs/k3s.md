# K3s

[K3s](https://k3s.io/) is a lightweight, certified Kubernetes distribution designed for production workloads in resource-constrained environments and edge locations. It is easy to install, simple to operate, and optimized for both development and production use cases.

## Why K3s?

- **Lightweight:** Minimal resource requirements compared to standard Kubernetes.
- **Simplicity:** Single binary, easy upgrades, and reduced operational overhead.
- **Production Ready:** CNCF certified, supports all standard Kubernetes APIs.
- **Great for Edge/IoT:** Designed for environments where resources are limited.

## K3s Installation Options

The K3s installation in this project uses specific options to fit the deployment requirements:

- **Docker Registry Integration:** Docker is used as a local registry to store and distribute container images within the cluster.
- **Traefik as Ingress Controller:** Traefik is enabled by default to manage ingress resources.
- **Automatic TLS with Cert-Manager:** Cert-Manager is installed to automate TLS certificate management using Let's Encrypt.

You can review or customize these options in the Ansible role variables and installation scripts.  

## Variables to Customize in the K3s Role

The following variables can be customized for the K3s role. These are typically set in your Ansible group or host variables:

| Variable               | Description                                      | Example Value                                |
| ---------------------- | ------------------------------------------------ | -------------------------------------------- |
| `k3s_token`            | Cluster join token for K3s nodes                 | `"REPLACE_WITH_YOUR_K3S_TOKEN"`              |
| `k3s_local_kubeconfig` | Path to local kubeconfig file                    | `"{{ lookup('env', 'HOME') }}/.kube/config"` |
| `letsencrypt_email`    | Email for Let's Encrypt certificate registration | `"your@email.com"`                           |

See [group_vars/all/secrets.example.yml](https://github.com/humansoftware/self-host-saas-k3s/blob/main/group_vars/all/secrets.example.yml) for a full list of secrets and example values.

## How to Verify K3s Installation

After running the Ansible playbook, verify your K3s installation:

1. **Check Node Status:**
```sh
kubectl get nodes
```

2. **List All resources in All Namespaces:**
```sh
kubectl get all --all-namespaces
```

3. **Inspect Cluster Info:**
```sh
kubectl cluster-info
```

## Cert-Manager

[Cert-Manager](https://cert-manager.io/) is used to automate the management and issuance of TLS certificates in your cluster.

- **Check Cert-Manager Status:**
```sh
kubectl get pods -n cert-manager
```

- **List Issuers and Certificates:**
```sh
kubectl get issuers,clusterissuers -A
kubectl get certificates -A
```

## Ingress Controller

Traefik is the default ingress controller bundled with K3s. It automatically manages ingress resources and routes external traffic to your services.

- **Check Traefik Pods:**
```sh
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik
```

- **List Ingress Resources:**
```sh
kubectl get ingress --all-namespaces
``` 

- **Check Ingress Controller Pods:**
```sh
kubectl get pods -n ingress-nginx
```

- **List Ingress Resources:**
```sh
kubectl get ingress --all-namespaces
```

## Additional Resources

- [K3s Documentation](https://docs.k3s.io/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Kubernetes Ingress Docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)