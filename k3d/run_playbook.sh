#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

set -x # Print each command before executing it.

HOSTNAME=$(hostname)
echo "Running playbook on host: $HOSTNAME"
echo "Current user: $(whoami)"

CLUSTER_NAME=humank8s

# Always create a fresh cluster for testing
k3d cluster delete $CLUSTER_NAME || true
k3d cluster create $CLUSTER_NAME

mkdir -p /etc/rancher/k3s
k3d kubeconfig get $CLUSTER_NAME >/etc/rancher/k3s/k3s.yaml

# This is a workaround for the issue where the k3d cluster name is not set correctly in the kubeconfig file.
# The k3d cluster name is set to "k3d-$CLUSTER_NAME" in the kubeconfig file, but it should be set to "$CLUSTER_NAME".
if grep -qaE 'docker|containerd' /proc/1/cgroup || [ -f /.dockerenv ]; then
    # Running inside a container
    echo "Running inside a container"

    K3S_LB_HOSTNAME="k3d-${CLUSTER_NAME}-serverlb"
    sed -i "s|server: https://.*|server: https://${K3S_LB_HOSTNAME}:6443|g" /etc/rancher/k3s/k3s.yaml
    cat /etc/rancher/k3s/k3s.yaml
fi

# Wait for the k3s API server to be ready
for i in $(seq 1 10); do
    if kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes; then
        echo "k3s API server is ready."
        break
    fi
    echo "Waiting for k3s API server to be ready..."
    sleep 10
done

ansible-playbook playbook.yml -i inventory.ini
