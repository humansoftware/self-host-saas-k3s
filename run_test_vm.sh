#!/bin/sh
set -e
set -u
set -x

RESTART=0
if [ "${1:-}" = "--restart" ]; then
    RESTART=1
fi

# Install Multipass if not present
if ! command -v multipass >/dev/null 2>&1; then
    sudo snap install multipass
fi

# Delete existing instance only if --restart is passed
if [ "$RESTART" -eq 1 ]; then
    if multipass info k3s-test >/dev/null 2>&1; then
        multipass delete k3s-test
        multipass purge
    fi
    # Export your public key as an environment variable
    export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

    # Generate cloud-init.yaml with your public key
    envsubst <cloud-init.yaml >cloud-init.generated.yaml
    # Launch VM
    multipass launch --name k3s-test --cpus 2 --memory 4G --disk 20G 24.04 --cloud-init cloud-init.yaml

    # Inject your public SSH key into the VM for Ansible access
    multipass exec k3s-test -- mkdir -p /home/ubuntu/.ssh
    multipass exec k3s-test -- bash -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> /home/ubuntu/.ssh/authorized_keys"
    multipass exec k3s-test -- chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
fi

# Get IP
export HOST_PUBLIC_IP=$(multipass info k3s-test | awk '/IPv4/ {print $2}')
envsubst <inventory.sample.yml >inventory.yml

# Install Ansible external collections
ansible-galaxy install -r requirements.yml
# Run playbook
export ANSIBLE_HOST_KEY_CHECKING=False # Disable host key checking
ansible-playbook -i inventory.yml playbook.yml
