#!/bin/sh

set -e
set -u
set -x

# Detect script folder and ensure script is run from the parent folder
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
if [ "$PWD" != "$PARENT_DIR" ]; then
    echo "Please run this script from the project root or parent folder, e.g.:"
    echo "  ./tests/$(basename "$0")"
    exit 1
fi

VM_NAME="saas-server"

RESTART=0
if [ "${1:-}" = "--restart" ]; then
    RESTART=1
fi

# Install Multipass if not present
if ! command -v multipass >/dev/null 2>&1; then
    sudo snap install multipass
fi

# Check if saas-server VM is running
IS_SAAS_SERVER_VM_RUNNING=0
if multipass list | grep -q "${VM_NAME}"; then
    IS_SAAS_SERVER_VM_RUNNING=1
fi

# Delete existing instance only if --restart is passed
if [ "$RESTART" -eq 1 ] || [ "$IS_SAAS_SERVER_VM_RUNNING" -eq 0 ]; then
    if [ "$IS_SAAS_SERVER_VM_RUNNING" -eq 1 ]; then
        multipass delete ${VM_NAME}
        multipass purge
    fi
    # Export your public key as an environment variable
    export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

    # Generate cloud-init.yaml with your public key
    envsubst <samples/cloud-init.yaml >tests/cloud-init.generated.yaml
    # Launch VM
    multipass launch --name ${VM_NAME} --cpus 2 --memory 6G --disk 35G 24.04 --cloud-init ./tests/cloud-init.generated.yaml
fi

# Get IP
export HOST_PUBLIC_IP=$(multipass list | grep ${VM_NAME} | awk '{print $3}')
envsubst <samples/inventory.sample.yml >tests/inventory.yml

# Install Ansible external collections
ansible-galaxy install -r requirements.yml
# Run playbook
export ANSIBLE_HOST_KEY_CHECKING=False # Disable host key checking
ansible-playbook -i tests/inventory.yml playbook.yml -e @tests/secrets.yml
