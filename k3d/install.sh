#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

# Install dependencies
apt update
apt install -y curl apt-transport-https ca-certificates
# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io
# Add the current user to the docker group
usermod -aG docker $USER

# Install k3s with docker
curl -sfL https://get.k3s.io | sh -s - --docker
# Wait for k3s to be ready
while ! kubectl get nodes; do
    echo "Waiting for k3s to be ready..."
    sleep 5
done
# Install Ansible
apt update
apt install -y ansible

# Run the Ansible playbook
./run_playbook.sh
