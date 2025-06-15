#!/bin/sh
set -e
set -u
set -x

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
    envsubst <cloud-init.yaml >cloud-init.generated.yaml
    # Launch VM
    multipass launch --name ${VM_NAME} --cpus 2 --memory 4G --disk 35G 24.04 --cloud-init cloud-init.generated.yaml
fi

# Get IP
export HOST_PUBLIC_IP=$(multipass list | grep ${VM_NAME} | awk '{print $3}')
envsubst <inventory.sample.yml >inventory.yml

# Install Ansible external collections
ansible-galaxy install -r requirements.yml
# Run playbook
export ANSIBLE_HOST_KEY_CHECKING=False # Disable host key checking
ansible-playbook -i inventory.yml playbook.yml
