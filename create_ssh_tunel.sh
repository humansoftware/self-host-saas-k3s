#!/bin/sh

# -----------------------------------------------------------------------------
# This script:
#   - Copies the kubeconfig from the Multipass VM (saas-server) to /tmp/multipass_kubectl
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
#   ./vmkubectl.sh describe node saas-server
# -----------------------------------------------------------------------------
set -e
set -u
set -x

VM_NAME="saas-server"
KUBECONFIG_PATH="/tmp/multipass_kubectl"

# Run multipass list once and store output
MP_LIST_OUTPUT=$(multipass list)

# Check if saas-server VM is running
IS_SAAS_SERVER_VM_RUNNING=0
if echo "$MP_LIST_OUTPUT" | grep -q "${VM_NAME}"; then
    IS_SAAS_SERVER_VM_RUNNING=1
fi

# Check if the VM is running
if [ "$IS_SAAS_SERVER_VM_RUNNING" -eq 0 ]; then
    echo "Multipass VM '$VM_NAME' is not running."
    echo "Please run './run_tests.sh' to start and provision the VM first."
    exit 1
fi

SSH_PORT=2222

# Get VM IP
VM_IP=$(echo "$MP_LIST_OUTPUT" | grep "${VM_NAME}" | awk '{print $3}')

# Start SSH tunnel in background (if not already running)
if ! pgrep -f "ssh -N -L 6443:localhost:6443 -p $SSH_PORT ubuntu@${VM_IP}" >/dev/null; then
    ssh -N -L 6443:localhost:6443 -p $SSH_PORT ubuntu@"$VM_IP" &
    TUNNEL_PID=$!
    echo "Started SSH tunnel with PID $TUNNEL_PID"
    sleep 2
else
    echo "SSH tunnel already running."
    EXISTING_PID=$(pgrep -f "ssh -N -L 6443:localhost:6443 -p $SSH_PORT ubuntu@${VM_IP}" | head -n1)
    echo "To kill the existing tunnel, run: kill $EXISTING_PID"
fi

# Copy kubeconfig from VM
# multipass exec "$VM_NAME" -- sudo cat /etc/rancher/k3s/k3s.yaml >"$KUBECONFIG_PATH"

# Test kubectl connection
# KUBECONFIG="$KUBECONFIG_PATH" kubectl --insecure-skip-tls-verify "$@"
