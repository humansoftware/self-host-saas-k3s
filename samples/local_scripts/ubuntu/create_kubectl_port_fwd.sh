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
