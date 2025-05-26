#!/bin/sh

# -----------------------------------------------------------------------------
# This script:
#   - Copies the kubeconfig from the Multipass VM (k3s-test) to /tmp/multipass_kubectl
#   - Rewrites the kubeconfig to use localhost:6443 as the API endpoint
#   - Starts an SSH tunnel from your host to the VM for port 6443
#   - Runs 'kubectl' with any arguments you provide, using the tunneled connection
#   - (Optionally) can kill the tunnel after the test
#
# If the VM is not running, it will instruct you to run 'run_tests.sh' first.
#
# Usage:
#   ./vmkubectl.sh <kubectl arguments>
#
# Examples:
#   ./vmkubectl.sh get nodes
#   ./vmkubectl.sh get pods -A
#   ./vmkubectl.sh describe node k3s-test
# -----------------------------------------------------------------------------
set -e
set -u

VM_NAME="k3s-test"
KUBECONFIG_PATH="/tmp/multipass_kubectl"

# Check if the VM is running
if ! multipass info "$VM_NAME" | grep -q "Running"; then
    echo "Multipass VM '$VM_NAME' is not running."
    echo "Please run './run_tests.sh' to start and provision the VM first."
    exit 1
fi

# Get VM IP
VM_IP=$(multipass info "$VM_NAME" | awk '/IPv4/ {print $2}')

# Copy kubeconfig from VM
multipass exec "$VM_NAME" -- sudo cat /etc/rancher/k3s/k3s.yaml >"$KUBECONFIG_PATH"

# Replace server IP with localhost in kubeconfig
sed -i "s|server: https://.*:6443|server: https://localhost:6443|g" "$KUBECONFIG_PATH"

# Start SSH tunnel in background (if not already running)
if ! pgrep -f "ssh -N -L 6443:localhost:6443 ubuntu@${VM_IP}" >/dev/null; then
    ssh -N -L 6443:localhost:6443 ubuntu@"$VM_IP" &
    TUNNEL_PID=$!
    echo "Started SSH tunnel with PID $TUNNEL_PID"
    # Give the tunnel a moment to establish
    sleep 2
else
    echo "SSH tunnel already running."
    EXISTING_PID=$(pgrep -f "ssh -N -L 6443:localhost:6443 ubuntu@${VM_IP}" | head -n1)
    echo "To kill the existing tunnel, run: kill $EXISTING_PID"
fi

# Test kubectl connection
KUBECONFIG="$KUBECONFIG_PATH" kubectl --insecure-skip-tls-verify "$@"

# Optionally, kill the tunnel after the test (uncomment if desired)
# kill $TUNNEL_PID
