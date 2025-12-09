#!/bin/zsh
# Script to start all useful kubectl port-forwards for Self-Host SaaS K3s
# Run this script from your terminal. Each port-forward runs in the background.
# Stop with Ctrl+C or kill the processes manually.
SSH_PORT=2222
HOST_PUBLIC_IP="YOUR_HOST_PUBLIC_IP" # Replace with your actual host public IP

# Check if a ssh tunnel is already running
if pgrep -f "ssh -N -L 6443:localhost:6443 -p $SSH_PORT ubuntu@$HOST_PUBLIC_IP" >/dev/null; then
    echo "SSH tunnel is already running. Exiting."
else
    # Create ssh tunnel to the host
    ssh -N -L 6443:localhost:6443 -p $SSH_PORT ubuntu@$HOST_PUBLIC_IP &
    echo "SSH tunnel created. You can now use kubectl to connect to the cluster."
fi

# Defaults: release name for kube-prometheus-stack (override with env var)
PROM_RELEASE="${PROM_RELEASE:-kube-prom-stack}"
# Defaults: release name for loki (override with env var)
LOKI_RELEASE="${LOKI_RELEASE:-loki}"

# Forward Grafana UI (service name from kube-prometheus-stack)
GRAFANA_SVC="${PROM_RELEASE}-grafana"
if kubectl -n monitoring get svc "${GRAFANA_SVC}" >/dev/null 2>&1; then
    kubectl -n monitoring port-forward svc/${GRAFANA_SVC} 3000:80 &
    echo "Grafana: http://localhost:3000 (admin/admin or your custom credentials)"
else
    echo "Warning: service ${GRAFANA_SVC} not found in namespace monitoring; skipping Grafana port-forward"
fi

# Forward Prometheus UI (service name from kube-prometheus-stack)
PROM_SVC="${PROM_RELEASE}-kube-prome-prometheus"
if kubectl -n monitoring get svc "${PROM_SVC}" >/dev/null 2>&1; then
    kubectl -n monitoring port-forward svc/${PROM_SVC} 9090:9090 &
    echo "Prometheus: http://localhost:9090"
else
    echo "Warning: service ${PROM_SVC} not found in namespace monitoring; skipping Prometheus port-forward"
fi

# Forward Loki (ingest/query API)
if kubectl -n monitoring get svc "loki" >/dev/null 2>&1; then
    kubectl -n monitoring port-forward svc/loki 3100:3100 &
    echo "Loki: http://localhost:3100/ready (service: loki)"
else
    echo "Warning: service lokinot found in namespace monitoring; skipping Loki port-forward"
fi

# Forward Alertmanager UI (service name from kube-prometheus-stack)
AM_SVC="${PROM_RELEASE}-kube-prome-alertmanager"
if kubectl -n monitoring get svc "${AM_SVC}" >/dev/null 2>&1; then
    kubectl -n monitoring port-forward svc/${AM_SVC} 9093:9093 &
    echo "Alertmanager: http://localhost:9093"
else
    echo "Warning: service ${AM_SVC} not found in namespace monitoring; skipping Alertmanager port-forward"
fi

# Forward Longhorn UI
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80 &
echo "Longhorn: http://localhost:8080"

# Forward Harbor UI (via Traefik)
kubectl -n kube-system port-forward svc/traefik 8081:80 &
echo "Harbor: http://localhost:8081 (admin/<your password>)"

# Forward Mailu  UI
kubectl -n mailu port-forward svc/mailu-front 8083:80 &
echo "Mailu Webmail: http://localhost:8083/webmail (admin@<your domain>/<your password>)"
echo "Mailu Admin: http://localhost:8083/admin (admin@<your domain>/<your password>)"

# Port-forward Postgres service to local port 15432 instead of 5432
kubectl port-forward svc/postgres-postgresql -n postgres 15432:5432 &
echo "Postgres: localhost:15432 (user: postgres, see secrets for password)"

# Port-forward Cassandra service to local port 9042
kubectl port-forward svc/cassandra -n cassandra 9042:9042 &
echo "Cassandra: localhost:9042"

# Port-forward Elasticsearch service to local port 9200
kubectl port-forward svc/elasticsearch-master -n elasticsearch 9200:9200 &
echo "Elasticsearch: http://localhost:9200"

# Forward Argo CD UI
kubectl -n argocd port-forward svc/argocd-server 8082:80 &
echo "Argo CD: http://localhost:8082 (admin/see secrets for password)"

# Wait for background jobs
wait
