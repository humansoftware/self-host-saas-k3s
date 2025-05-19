#!/bin/sh
set -e
set -u
set -x

# Install Multipass if not present
if ! command -v multipass >/dev/null 2>&1; then
    sudo snap install multipass
fi

# Delete existing instance if it exists
if multipass info k3s-test >/dev/null 2>&1; then
    multipass delete k3s-test
    multipass purge
fi

# Launch VM
multipass launch --name k3s-test --cpus 2 --memory 4G --disk 20G 24.04 || true

# Inject your public SSH key into the VM for Ansible access
multipass exec k3s-test -- mkdir -p /home/ubuntu/.ssh
multipass exec k3s-test -- bash -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> /home/ubuntu/.ssh/authorized_keys"
multipass exec k3s-test -- chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

# Get IP
VM_IP=$(multipass info k3s-test | awk '/IPv4/ {print $2}')

# Write inventory
cat >inventory_multipass.ini <<EOF
[all]
k3s-test ansible_host=$VM_IP ansible_user=ubuntu
EOF

# Run playbook
export ANSIBLE_HOST_KEY_CHECKING=False # Disable host key checking
ansible-playbook -i inventory_multipass.ini playbook.yml
