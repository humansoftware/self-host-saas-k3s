#!/bin/zsh
# Script to start all useful kubectl port-forwards for Self-Host SaaS K3s
# Run this script from your terminal. Each port-forward runs in the background.
# Stop with Ctrl+C or kill the processes manually.

# Forward Grafana UI
kubectl -n monitoring port-forward svc/grafana 3000:80 &
echo "Grafana: http://localhost:3000 (admin/admin or your custom credentials)"

# Forward Prometheus UI
kubectl -n monitoring port-forward svc/prometheus-server 9090:80 &
echo "Prometheus: http://localhost:9090"

# Forward Longhorn UI
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80 &
echo "Longhorn: http://localhost:8080"

# Forward Harbor UI (via Traefik)
kubectl -n kube-system port-forward svc/traefik 8081:80 &
echo "Harbor: http://localhost:8081 (admin/<your password>)"

# Forward Flux UI (Weave GitOps)
kubectl -n flux-system port-forward svc/weave-gitops 9001:9001 &
echo "Flux UI: http://localhost:9001 (admin/<your password>)"

# Wait for background jobs
wait
